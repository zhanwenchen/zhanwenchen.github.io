-- Script to create example Epic tables with fake data
-- For educational/workshop purposes only

-- Create databases if they don't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'FULL')
BEGIN
    CREATE DATABASE FULL;
END;

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'OMOP_FULL')
BEGIN
    CREATE DATABASE OMOP_FULL;
END;

USE FULL;

-- Drop tables if they exist to avoid conflicts
IF OBJECT_ID('FULL..ENCOUNTERS', 'U') IS NOT NULL
    DROP TABLE FULL..ENCOUNTERS;

-- Create the ENCOUNTERS table (inferred from your SELECT statement)
CREATE TABLE FULL..ENCOUNTERS (
    ENC_HASH VARCHAR(50) PRIMARY KEY,
    ADMISSION_DT DATETIME NOT NULL,
    DISCHARGE_DT DATETIME,
    PT_CLASS CHAR(1) NOT NULL, -- 'E' for ER, 'I' for IP, 'O' for OP, 'B' for OP
    ADMIT_SOURCE VARCHAR(50),
    DISCHARGE_DISP VARCHAR(50),
    COMPLAINT VARCHAR(255),
    SRV_CODE VARCHAR(50),
    PATIENT_TYPE VARCHAR(50)
);

-- Insert sample data into ENCOUNTERS
INSERT INTO FULL..ENCOUNTERS
    (ENC_HASH, ADMISSION_DT, DISCHARGE_DT, PT_CLASS, ADMIT_SOURCE, DISCHARGE_DISP, COMPLAINT, SRV_CODE, PATIENT_TYPE)
VALUES
    ('ENC001', '2023-01-10 08:30:00', '2023-01-10 15:45:00', 'E', 'SELF', 'HOME', 'Chest pain', 'ER001', 'EMERGENCY'),
    ('ENC002', '2023-01-11 10:15:00', '2023-01-15 14:00:00', 'I', 'ER', 'HOME', 'Pneumonia', 'MED001', 'INPATIENT'),
    ('ENC003', '2023-01-12 13:45:00', '2023-01-12 15:30:00', 'O', 'SELF', 'HOME', 'Annual physical', 'PC001', 'OUTPATIENT'),
    ('ENC004', '2023-01-14 09:00:00', '2023-01-14 09:45:00', 'B', 'SELF', 'HOME', 'Blood work', 'LAB001', 'OUTPATIENT'),
    ('ENC005', '2023-01-15 16:20:00', '2023-01-16 08:30:00', 'I', 'SELF', 'HOME', 'Abdominal pain', 'MED002', 'INPATIENT'),
    ('ENC006', '2023-01-16 11:00:00', '2023-01-16 11:30:00', 'O', 'SELF', 'HOME', 'Medication refill', 'PC002', 'OUTPATIENT'),
    ('ENC007', '2023-01-17 14:30:00', '2023-01-18 17:00:00', 'E', 'AMB', 'HOME', 'Broken arm', 'ER002', 'EMERGENCY'),
    ('ENC008', '2023-01-18 10:00:00', '2023-01-25 11:15:00', 'I', 'ER', 'SNF', 'Stroke', 'NEUR001', 'INPATIENT'),
    ('ENC009', '2023-01-19 15:45:00', '2023-01-19 16:30:00', 'O', 'SELF', 'HOME', 'Diabetes follow-up', 'ENDO001', 'OUTPATIENT'),
    ('ENC010', '2023-01-20 08:15:00', '2023-01-20 10:00:00', 'E', 'AMB', 'ADMIT', 'Car accident', 'ER003', 'EMERGENCY');

USE OMOP_FULL;

-- Drop tables if they exist to avoid conflicts
IF OBJECT_ID('OMOP_FULL..ENCOUNTER_XWALK', 'U') IS NOT NULL
    DROP TABLE OMOP_FULL..ENCOUNTER_XWALK;

IF OBJECT_ID('OMOP_FULL..ENCOUNTER_U', 'U') IS NOT NULL
    DROP TABLE OMOP_FULL..ENCOUNTER_U;

-- Create ENCOUNTER_XWALK table that maps encounters to visit_occurrence_id
CREATE TABLE OMOP_FULL..ENCOUNTER_XWALK (
    VISIT_OCCURRENCE_ID INT PRIMARY KEY,
    ENC_HASH VARCHAR(50) NOT NULL,
    IND_SEQ INT NOT NULL,
    -- Add any additional columns needed for xwalk
    CREATED_DT DATETIME DEFAULT GETDATE()
);

-- Insert sample data into ENCOUNTER_XWALK
INSERT INTO OMOP_FULL..ENCOUNTER_XWALK
    (VISIT_OCCURRENCE_ID, ENC_HASH, IND_SEQ)
VALUES
    (1001, 'ENC001', 1),
    (1002, 'ENC002', 1),
    (1003, 'ENC003', 1),
    (1004, 'ENC004', 1),
    (1005, 'ENC005', 1),
    (1006, 'ENC006', 1),
    (1007, 'ENC007', 1),
    (1008, 'ENC008', 1),
    (1009, 'ENC009', 1),
    (1010, 'ENC010', 1),
    (1011, 'ENC010', 2); -- Example of an encounter with multiple sequences

-- Now recreate the ENCOUNTER_U table as per your original SQL
-- This is based on your provided SQL query
EXEC('CREATE TABLE OMOP_FULL..ENCOUNTER_U AS
SELECT DISTINCT VISIT_OCCURRENCE_ID, IND_SEQ, E.ENC_HASH, ADMISSION_DT, MAX(DISCHARGE_DT) AS DISCHARGE_DT,
CASE WHEN PT_CLASS =''E'' THEN ''ER''
WHEN PT_CLASS =''I'' THEN ''IP''
WHEN PT_CLASS =''O'' OR PT_CLASS =''B'' THEN ''OP''
ELSE ''OP'' END AS ENC_TYPE,
 ADMIT_SOURCE, DISCHARGE_DISP, COMPLAINT, SRV_CODE, PATIENT_TYPE
FROM FULL..ENCOUNTERS E
LEFT JOIN OMOP_FULL..ENCOUNTER_XWALK X ON X.ENC_HASH=E.ENC_HASH
GROUP BY 1,2,3,4,6,7,8,9,10,11;');

-- Print success message
SELECT 'Example Epic tables created successfully with fake data' AS Status;
