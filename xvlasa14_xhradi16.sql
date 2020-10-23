-- ----------------------------------------------- --
--              DATABAZOVE SYSTEMY
--          author:   xvlasa14
--          date:   20. 3. 2020
-- ----------------------------------------------- --

-- -------- T A B L E   L I S T ------------------ --
-- DON - table for data about dons
-- RANKED_MEMBER - other members of family
-- CRIME - info about crimes
-- CRIME_COMMITED - about commited crimes
-- MURDER - about murders
-- MURDER_ORDER - who orders which murder
-- MEETING - about meetings
-- MEETING_ATTENDANCE - who attends meets
-- FAMILY - about families
-- AFFLIATION - who is affiliated to which fam
-- ALIANCE - allies <3
-- MEDIATED_CRIME - family mediated crimes
-- TERRITORY - all territories
-- TERRITORY_OWNED - which territory is owned
-- ----------------------------------------------- --

-- clear tables before running
    DROP TABLE don CASCADE CONSTRAINTS;
    DROP TABLE ranked_member CASCADE CONSTRAINTS;
    DROP TABLE crime CASCADE CONSTRAINTS;
    DROP TABLE crime_commited CASCADE CONSTRAINTS;
    DROP TABLE murder CASCADE CONSTRAINTS;
    DROP TABLE murder_order CASCADE CONSTRAINTS;
    DROP TABLE meeting CASCADE CONSTRAINTS;
    DROP TABLE meeting_attendance CASCADE CONSTRAINTS;
    DROP TABLE family CASCADE CONSTRAINTS;
    DROP TABLE affiliation CASCADE CONSTRAINTS;
    DROP TABLE aliance CASCADE CONSTRAINTS;
    DROP TABLE mediated_crime CASCADE CONSTRAINTS;
    DROP TABLE territory CASCADE CONSTRAINTS;
    DROP TABLE territory_owned CASCADE CONSTRAINTS;

-- -------------------------------------------------------------------------------------------
--                                  C R E A T E   T A B L E S
-- -------------------------------------------------------------------------------------------
CREATE TABLE family (
    id_family   VARCHAR(255) NOT NULL PRIMARY KEY
);

CREATE TABLE don (
    id_don          INT             DEFAULT NULL PRIMARY KEY,       -- will be generated through trigger
    alias           VARCHAR(255)    DEFAULT NULL,
    name_don        VARCHAR(255)    NOT NULL,
    surname_don     VARCHAR(255)    NOT NULL,
    birth_date      VARCHAR(255)    NOT NULL,   CHECK(REGEXP_LIKE(birth_date, '[0-9]{2}(-)[0-9]{2}(-)[0-9]{4}')),   -- DD-MM-YYY format
    shoe_size       INT             NOT NULL,   CHECK(REGEXP_LIKE(shoe_size, '[0-9]{2}')),   -- NN format
    familia         VARCHAR(255)    NOT NULL,

    CONSTRAINT fk_familia FOREIGN KEY (familia)
        REFERENCES family(id_family)
);

CREATE TABLE ranked_member (
    id_member               INT             GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    name_member             VARCHAR(255)    NOT NULL,
    surname_member          VARCHAR(255)    NOT NULL,
    birth_date_member       VARCHAR(255)    NOT NULL,   CHECK(REGEXP_LIKE(birth_date_member, '[0-9]{2}(-)[0-9]{2}(-)[0-9]{4}')), -- DD-MM-YYY format
    gender_member           VARCHAR(255)    NOT NULL,   CHECK(REGEXP_LIKE(gender_member, '(male|female|m|f)')),   -- male, female, m or f format
    rank                    VARCHAR(255)    NOT NULL
);

CREATE TABLE crime (
    crime_id        INT             GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    crime_name      VARCHAR(255)    NOT NULL,
    crime_date      VARCHAR(255)    NOT NULL,   CHECK(REGEXP_LIKE(crime_date, '[0-9]{2}(-)[0-9]{2}(-)[0-9]{4}')), -- DD-MM-YYY format
    time            VARCHAR(255)    NOT NULL,   CHECK(REGEXP_LIKE(time, '((0[0-9])|[1-9]|(1[0-9])|(2[0-4]))(:)[0-5][0-9]'))   -- HH:MM format
);

CREATE TABLE crime_commited (
    operation       INT NOT NULL,
    criminal        INT NOT NULL,

    PRIMARY KEY (operation, criminal),

    CONSTRAINT fk_operation FOREIGN KEY (operation)
        REFERENCES crime(crime_id),
    CONSTRAINT fk_criminal FOREIGN KEY (criminal)
        REFERENCES ranked_member(id_member)
);

CREATE TABLE murder (
    murder_id       INT             GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    murder_date     VARCHAR(255)    NOT NULL,   CHECK(REGEXP_LIKE(murder_date, '[0-9]{2}(-)[0-9]{2}(-)[0-9]{4}')), -- DD-MM-YYY format
    murder_time     VARCHAR(255)    NOT NULL,   CHECK (REGEXP_LIKE(murder_time, '[0-2][0-9](:)[0-5][0-9]')),   -- male, female, m or f format
    murder_place    VARCHAR(255)    NOT NULL,
    way_of_murder   VARCHAR(255)    NOT NULL,
    victim          VARCHAR(255)    NOT NULL,
    murderer        INT NOT NULL,

    CONSTRAINT fk_murderer FOREIGN KEY (murderer)
        REFERENCES ranked_member(id_member)
);

CREATE TABLE murder_order (
    murder_name     INT NOT NULL,
    who_ordered     INT NOT NULL,

    PRIMARY KEY (murder_name, who_ordered),

    CONSTRAINT fk_murder FOREIGN KEY (murder_name)
        REFERENCES murder(murder_id),
    CONSTRAINT fk_who FOREIGN KEY (who_ordered)
        REFERENCES don(id_don)
);

CREATE TABLE affiliation (
    affiliated_family   VARCHAR(255) NOT NULL,
    affiliated_member   INT NOT NULL,

    PRIMARY KEY (affiliated_family, affiliated_member),

    CONSTRAINT fk_fam FOREIGN KEY (affiliated_family)
        REFERENCES family(id_family),
    CONSTRAINT fk_affmember FOREIGN KEY (affiliated_member)
        REFERENCES ranked_member(id_member)
);

CREATE TABLE aliance (
    first_ally      VARCHAR(255)    NOT NULL,
    second_ally     VARCHAR(255)    NOT NULL,

    CONSTRAINT fk_ally1 FOREIGN KEY (first_ally)
        REFERENCES family(id_family),
    CONSTRAINT fk_ally2 FOREIGN KEY (second_ally)
        REFERENCES family(id_family)
);

CREATE TABLE mediated_crime (
    operation           INT             NOT NULL,
    mediating_family    VARCHAR(255)    NOT NULL,

    PRIMARY KEY (operation, mediating_family),

    CONSTRAINT fk_medcrime FOREIGN KEY (operation)
        REFERENCES crime(crime_id),
    CONSTRAINT fk_medfam FOREIGN KEY (mediating_family)
        REFERENCES family(id_family)
);

CREATE TABLE territory (
    coordinates     VARCHAR(255) NOT NULL PRIMARY KEY, CHECK(REGEXP_LIKE(coordinates, '^(([1-9])|([1-8][0-9])|(90))(.)[0-9]{4}(N|W|S|E)\s(([1-9])|([1-9][0-9])|((1)[0-7][0-9])|(180))(.)[0-9]{4}(N|S|E|W)$')),
    street          VARCHAR(255) NOT NULL,
    city            VARCHAR(255) NOT NULL,
    area            VARCHAR(255) NOT NULL, CHECK(REGEXP_LIKE(area, '[0-9]*(km)(2)'))
);

CREATE TABLE territory_owned (
    owners          VARCHAR(255) NOT NULL,
    owned_territory VARCHAR(255) NOT NULL,

    PRIMARY KEY (owners, owned_territory),

    CONSTRAINT fk_owners FOREIGN KEY (owners)
        REFERENCES family(id_family),
    CONSTRAINT fk_owned FOREIGN KEY (owned_territory)
        REFERENCES territory(coordinates)
);

CREATE TABLE meeting (
    id_meeting          INT             GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    meeting_date        VARCHAR(255)    NOT NULL,   CHECK(REGEXP_LIKE(meeting_date, '[0-9]{2}(-)[0-9]{2}(-)[0-9]{4}')),
    meeting_time        VARCHAR(255)    NOT NULL,   CHECK (REGEXP_LIKE(meeting_time, '^((0[0-9])|[1-9]|(1[0-9])|(2[0-4]))(:)[0-5][0-9]$')),
    location            VARCHAR(255)    NOT NULL,

    CONSTRAINT fk_location FOREIGN KEY (location)
        REFERENCES territory(coordinates)
);

CREATE TABLE meeting_attendance (
    attending_don       INT NOT NULL,
    which_meeting       INT NOT NULL,

    PRIMARY KEY (attending_don, which_meeting),

    CONSTRAINT fk_attendee FOREIGN KEY (attending_don)
        REFERENCES don(id_don),
    CONSTRAINT fk_meet FOREIGN KEY (which_meeting)
        REFERENCES meeting(id_meeting)
);

-- -------------------------------------------------------------------------------------------
--                                    T R I G G E R S
-- -------------------------------------------------------------------------------------------
-- trigger #1 (auto generates primary key)
DROP SEQUENCE donID;
CREATE SEQUENCE donID;
CREATE OR REPLACE TRIGGER donID BEFORE INSERT ON don FOR EACH ROW
    BEGIN
        IF :NEW.id_don IS NULL THEN
            :NEW.id_don := donID.NEXTVAL;
        END IF;
    END;

-- triggers #2 (date validations)
CREATE OR REPLACE TRIGGER bDayMember BEFORE INSERT OR UPDATE OF birth_date_member ON ranked_member FOR EACH ROW
    BEGIN
        IF((SUBSTR(:NEW.birth_date_member, 4, 2) IN ('01', '03', '05', '07', '08', '10', '12'))) THEN      -- if months that have 31 days
            IF NOT ((SUBSTR(:NEW.birth_date_member, 1, 2) IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31'))) THEN
                RAISE_APPLICATION_ERROR(-20000, 'Oopsie. Invalid birth date. Max amout of days in this month is 31.');
            END IF;
        ELSE
            IF ((SUBSTR(:NEW.birth_date_member, 4, 2) IN ('04', '06', '09', '11'))) THEN             -- if months that have 30 days
                IF NOT ((SUBSTR(:NEW.birth_date_member, 1, 2) IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31'))) THEN
                    RAISE_APPLICATION_ERROR(-20000, 'Oopsie. Invalid birth date. Max amout of days in this month is 30.');
                END IF;
            ELSE
                IF ((SUBSTR(:NEW.birth_date_member, 4, 2) IN ('02'))) THEN                            -- if february (29 always passes)
                    IF NOT ((SUBSTR(:NEW.birth_date_member, 1, 2) IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29'))) THEN
                        RAISE_APPLICATION_ERROR(-20000, 'Oopsie. Invalid birth date. Max amout of days in this month is 29.');
                    END IF;
                ELSE RAISE_APPLICATION_ERROR(-20001, 'Oopsie. Invalid birth date. This month does not exist.');
                END IF;
            END IF;
        END IF;

        IF (CAST(SUBSTR(:NEW.birth_date_member, 7, 4) AS int) > 2000) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Oopsie. Invalid birth date. This year is too far into the future.');
        ELSE
            IF (CAST(SUBSTR(:NEW.birth_date_member, 7, 4) AS int) < 1800) THEN
                RAISE_APPLICATION_ERROR(-20002, 'Oopsie. Invalid birth date. This year is too far into the history.');
            END IF;
        END IF;
    END;

CREATE OR REPLACE TRIGGER bDayDon BEFORE INSERT OR UPDATE OF birth_date ON don FOR EACH ROW
    BEGIN
        IF((SUBSTR(:NEW.birth_date, 4, 2) IN ('01', '03', '05', '07', '08', '10', '12'))) THEN      -- if months that have 31 days
            IF NOT ((SUBSTR(:NEW.birth_date, 1, 2) IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31'))) THEN
                RAISE_APPLICATION_ERROR(-20000, 'Oopsie. Invalid birth date. Max amout of days in this month is 31.');
            END IF;
        ELSE
            IF ((SUBSTR(:NEW.birth_date, 4, 2) IN ('04', '06', '09', '11'))) THEN             -- if months that have 30 days
                IF NOT ((SUBSTR(:NEW.birth_date, 1, 2) IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31'))) THEN
                    RAISE_APPLICATION_ERROR(-20000, 'Oopsie. Invalid birth date. Max amout of days in this month is 30.');
                END IF;
            ELSE
                IF ((SUBSTR(:NEW.birth_date, 4, 2) IN ('02'))) THEN                            -- if february (29 always passes)
                    IF NOT ((SUBSTR(:NEW.birth_date, 1, 2) IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29'))) THEN
                        RAISE_APPLICATION_ERROR(-20000, 'Oopsie. Invalid birth date. Max amout of days in this month is 29.');
                    END IF;
                ELSE RAISE_APPLICATION_ERROR(-20001, 'Oopsie. Invalid birth date. This month does not exist.');
                END IF;
            END IF;
        END IF;

        IF (CAST(SUBSTR(:NEW.birth_date, 7, 4) AS int) > 2000) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Oopsie. Invalid birth date. This year is too far into the future.');
        ELSE
            IF (CAST(SUBSTR(:NEW.birth_date, 7, 4) AS int) < 1800) THEN
                RAISE_APPLICATION_ERROR(-20002, 'Oopsie. Invalid birth date. This year is too far into the history.');
            END IF;
        END IF;
    END;

-- -------------------------------------------------------------------------------------------
--                                    P R O C E D U R E S
--                                 authors: xvlasa14, xhradi16
-- -------------------------------------------------------------------------------------------
-- ukaze kolika procent setkani se don zucastnil
CREATE OR REPLACE PROCEDURE ucast(don_id IN INT)
is
cursor ucast2 is select * from meeting_attendance;
    setkani ucast2%ROWTYPE;
    potvrzeno NUMBER; --kolik z nich potrvdil
BEGIN
  potvrzeno := 0;
  open ucast2;
    loop
    fetch ucast2 into setkani;
    exit when ucast2%NOTFOUND;
    IF (setkani.attending_don = don_id) THEN
        potvrzeno := potvrzeno + 1;
    END IF;
    end loop;
close ucast2;
    IF potvrzeno > 0 THEN
        dbms_output.put_line('Don ' || don_id || ' se ucastil: ' || potvrzeno || ' setkani');
    ELSE IF potvrzeno = 0 THEN
        dbms_output.put_line('Don ' || don_id || ' se neucastil zadneho setkani');

        ELSE
            Raise_Application_Error (-20206, 'Error!');
        END IF;
    END IF;
END;
/
-- ukaze kolik procent vrazd spachal vybrany clen
CREATE OR REPLACE PROCEDURE procento_vrazd(member_id IN INT)
is
cursor vrah is select * from murder;
    udaje vrah%ROWTYPE;
    celkem NUMBER; --vsechny vrazdy
    spachano NUMBER; -- spachane clenem
BEGIN
  celkem := 0;
  spachano := 0;
  open vrah;
    loop
    fetch vrah into udaje;
    exit when vrah%NOTFOUND;
    IF (udaje.murderer = member_id) THEN
        spachano := spachano + 1;
    END IF;
    celkem := celkem + 1;
    end loop;
close vrah;
  dbms_output.put_line('Member ' || member_id || ' commited ' || (spachano * 100)/celkem || ' % of mudrers');
EXCEPTION
  WHEN ZERO_DIVIDE THEN
    dbms_output.put_line('There are no commited murders');
  WHEN OTHERS THEN
    Raise_Application_Error (-20206, 'Error!');
END;
/

-- -------------------------------------------------------------------------------------------
--                                    I N S E R T   D A T A
-- -------------------------------------------------------------------------------------------
-- create families
INSERT INTO family(id_family) VALUES ('Corleone family');
INSERT INTO family(id_family) VALUES ('Tattaglia family');
INSERT INTO family(id_family) VALUES ('Barzini family');
INSERT INTO family(id_family) VALUES ('Cuneo family');
INSERT INTO family(id_family) VALUES ('Stracci family');
-- family aliances
INSERT INTO aliance(first_ally, second_ally) VALUES('Tattaglia family', 'Barzini family');
INSERT INTO aliance(first_ally, second_ally) VALUES('Corleone family', 'Cuneo family');
-- create dons
INSERT INTO don(alias, name_don, surname_don, birth_date, shoe_size, familia)
    VALUES('don Corleone','Vito', 'Corleone', '29-04-1891', 42, 'Corleone family');
INSERT INTO don(alias, name_don, surname_don, birth_date, shoe_size, familia)
    VALUES('don Tattaglia','Phillip', 'Tattaglia', '18-09-1887', 41, 'Tattaglia family');
INSERT INTO don(alias, name_don, surname_don, birth_date, shoe_size, familia)
    VALUES('don Barzini','Emilio', 'Barzini', '03-10-1887', 41, 'Barzini family');
INSERT INTO don(alias, name_don, surname_don, birth_date, shoe_size, familia)
    VALUES('don Cuneo','Carmine', 'Cuneo', '01-10-1880', 43, 'Cuneo family');
INSERT INTO don(alias, name_don, surname_don, birth_date, shoe_size, familia)
    VALUES('don Stracci','Victor', 'Stracci', '04-09-1885', 44, 'Stracci family');

-- create other members of families
INSERT INTO ranked_member(name_member, surname_member, birth_date_member, gender_member, rank)
VALUES('Genco', 'Abbandando', '14-05-1892', 'male', 'Consigliere');
INSERT INTO ranked_member(name_member, surname_member, birth_date_member, gender_member, rank)
VALUES('Bruno', 'Tattaglia', '03-01-1913', 'male', 'Caporegime');
INSERT INTO ranked_member(name_member, surname_member, birth_date_member, gender_member, rank)
VALUES('Paul', 'Fortunato', '28-02-1900', 'male', 'Caporegime');
INSERT INTO ranked_member(name_member, surname_member, birth_date_member, gender_member, rank)
VALUES('Otilio', 'Cuneo', '18-02-1916', 'male', 'Caporegime');
INSERT INTO ranked_member(name_member, surname_member, birth_date_member, gender_member, rank)
VALUES('Mario', 'Stracci', '13-11-1890', 'male', 'Underboss');

-- add affiliation
INSERT INTO affiliation(affiliated_family, affiliated_member)
VALUES('Corleone family', 1);
INSERT INTO affiliation(affiliated_family, affiliated_member)
VALUES('Tattaglia family', 2);
INSERT INTO affiliation(affiliated_family, affiliated_member)
VALUES('Barzini family', 3);
INSERT INTO affiliation(affiliated_family, affiliated_member)
VALUES('Cuneo family', 4);
INSERT INTO affiliation(affiliated_family, affiliated_member)
VALUES('Stracci family', 5);

-- crimes and murder
INSERT INTO crime(crime_name, crime_date, time) VALUES('Bank robbery', '13-05-1921', '12:00');      -- crime
INSERT INTO crime_commited(operation, criminal) VALUES(1, 1);                                       -- who did it
INSERT INTO mediated_crime(operation, mediating_family) VALUES(1, 'Corleone family');               -- who mediated it

INSERT INTO crime(crime_name, crime_date, time) VALUES('Home invasion', '17-04-1933', '22:00');     -- crime
INSERT INTO crime_commited(operation, criminal) VALUES(2, 3);                                       -- who did it
INSERT INTO mediated_crime(operation, mediating_family) VALUES(2, 'Barzini family');                -- mediator

INSERT INTO murder(murder_date, murder_time, murder_place, way_of_murder, victim, murderer)
VALUES('13-03-1925', '13:13', 'Statue of Liberty', 'Slit throat', 'witness to kidnapping', 2);      -- murder

INSERT INTO murder(murder_date, murder_time, murder_place, way_of_murder, victim, murderer)
VALUES('25-05-1931', '02:30', 'Times Square', 'Strangulation', 'lawyer', 4);                        -- murder
INSERT INTO murder_order(murder_name, who_ordered) VALUES(2, 4);                                    -- who ordered it


-- territory
INSERT INTO territory(coordinates, street, city, area)
VALUES('40.7957N 73.9389W', 'East Harlem', 'New York', '2.32km2');          -- owned territory
INSERT INTO territory_owned(owners, owned_territory) VALUES('Stracci family', '40.7957N 73.9389W');

INSERT INTO territory(coordinates, street, city, area)
VALUES('40.7547N 73.9916W', 'Garment Sector', 'New York', '2.17km2');       -- owned territory
INSERT INTO territory_owned(owners, owned_territory) VALUES('Barzini family', '40.7547N 73.9916W');

INSERT INTO territory(coordinates, street, city, area)
VALUES('40.6959N 73.9956W', 'Brooklyn Heights', 'New York', '0.83km2');     -- owned territory
INSERT INTO territory_owned(owners, owned_territory) VALUES('Tattaglia family', '40.6959N 73.9956W');

INSERT INTO territory(coordinates, street, city, area)
VALUES('40.7191N 73.9973W', 'Little Italy', 'New York', '0.67km2');        -- owned territory
INSERT INTO territory_owned(owners, owned_territory) VALUES('Corleone family', '40.7191N 73.9973W');

INSERT INTO territory(coordinates, street, city, area)
VALUES('40.8520N 73.9007W', 'West Bronx', 'New York', '0.67km2');           -- owned territory
INSERT INTO territory_owned(owners, owned_territory) VALUES('Cuneo family', '40.8520N 73.9007W');

INSERT INTO territory(coordinates, street, city, area)
VALUES('40.7077N 74.0083W', 'Wall Street', 'New York', '0.25km2');        -- owned territory
INSERT INTO territory_owned(owners, owned_territory) VALUES('Corleone family', '40.7077N 74.0083W');

-- meetings
INSERT INTO meeting(meeting_date, meeting_time, location) VALUES ('14-02-1927', '01:00', '40.7191N 73.9973W');  -- meeting in Little Italy
INSERT INTO meeting_attendance(attending_don, which_meeting) VALUES(4, 1);      -- attended by don Cuneo
INSERT INTO meeting_attendance(attending_don, which_meeting) VALUES(1, 1);      -- attended by don Corleone

INSERT INTO meeting(meeting_date, meeting_time, location) VALUES ('15-06-1928', '18:30', '40.8520N 73.9007W');  -- meeting in Little Italy
INSERT INTO meeting_attendance(attending_don, which_meeting) VALUES(4, 2);      -- attended by don Cuneo
INSERT INTO meeting_attendance(attending_don, which_meeting) VALUES(1, 2);      -- attended by don Corleone

INSERT INTO meeting(meeting_date, meeting_time, location) VALUES ('01-08-1929', '12:00', '40.6959N 73.9956W');  -- meeting in Brooklyn Heights
INSERT INTO meeting_attendance(attending_don, which_meeting) VALUES(2, 3);      -- attended by don Tattaglia
INSERT INTO meeting_attendance(attending_don, which_meeting) VALUES(3, 3);      -- attended by don Barzini

-- -------------------------------------------------------------------------------------------
--                                       S E L E C T S
-- -------------------------------------------------------------------------------------------
-- T W O   T A B L E S   C O N N E C T E D
-- MURDERS: information about murder (murderer's name + surname and victim)
SELECT R.name_member AS murderer_name, R.surname_member AS murderer_surname, M.victim
FROM ranked_member R INNER JOIN murder M ON R.id_member = M.murderer;

-- LEADERS: information about who leads which family (don's Alias, name + surname and his family)
SELECT D.alias AS Alias, D.name_don AS name, D.surname_don AS surname, F.id_family AS family
FROM don D INNER JOIN family F ON D.familia = F.id_family;

-- T H R E E   T A B L E S   C O N N E C T E D
-- CRIMES: information about crimes commited (which crime, mediated by which family and when it was commited)
SELECT C.crime_name AS crime, F.id_family AS family, C.crime_date AS commited
FROM family F INNER JOIN mediated_crime M ON M.mediating_family = F.id_family INNER JOIN crime C ON C.crime_id = M.operation;

-- G R O U P   B Y
-- TERRITORY: information about territories of area 2km2 and more
SELECT T.city, T.street, T.area AS area, O.owners
FROM territory T, territory_owned O
GROUP BY T.city, T.street, O.owners, T.coordinates, O.owned_territory, T.area
HAVING T.coordinates = O.owned_territory AND CAST(SUBSTR(T.area, 1, 1) AS int) > 1;

-- FAMILY SIZE: information about size of each family (Which family and how many members it has including don)
SELECT F.id_family, COUNT(A.affiliated_member)+1
FROM family F, affiliation A
GROUP BY F.id_family, A.affiliated_family
HAVING A.affiliated_family = F.id_family;

-- E X I S T
-- NON-ALLIED FAMILIES: information about families that are not in any aliance (non-allied family)
SELECT F.id_family AS nonallied_family
FROM family F
WHERE NOT EXISTS (
	SELECT A.second_ally
	FROM aliance A
	WHERE A.second_ally = F.id_family or A.first_ally = F.id_family
);

-- I N
-- MEETINGS: information about meetings that happened in the year of 1927 (exact date of meeting and location (street and which city))
SELECT M.meeting_date, T.street, T.city
FROM territory T, meeting M
WHERE T.coordinates
IN (
	SELECT M.location
	FROM meeting M
	WHERE CAST(SUBSTR(M.meeting_date, 7, 4) AS int) = 1927
) and T.coordinates = M.location;

-- -------------------------------------------------------------------------------------------
--                                D E M O N S T R A T I O N S
-- -------------------------------------------------------------------------------------------
-- trigger #1
SELECT id_don, alias FROM don ORDER BY id_don;      -- id starts at 1 (don Corleone), ends at 5 (don Stracci)

-- trigger #2
INSERT INTO ranked_member(name_member, surname_member, birth_date_member, gender_member, rank)      --- inserting new member so trigger is called
VALUES('Tom', 'Hagen', '01-05-1910', 'male', 'Consigliere');        -- date of birth is correct
INSERT INTO affiliation(affiliated_family, affiliated_member)
VALUES('Corleone family', 6);
SELECT name_member, surname_member, birth_date_member FROM ranked_member;       -- all members have correct date of birth ([1-31]-[1-12]-[1801 - 1999])

-- procedure #1
BEGIN ucast(2); END;

-- procedure #2
BEGIN procento_vrazd(2); END;

-- -------------------------------------------------------------------------------------------
--                           I N D E X ,   E X P L A I N   P L A N
-- -------------------------------------------------------------------------------------------
-- explain plan #1
EXPLAIN PLAN FOR
SELECT F.id_family, COUNT(A.affiliated_member)+1
FROM family F, affiliation A
GROUP BY F.id_family, A.affiliated_family
HAVING A.affiliated_family = F.id_family;

SELECT * FROM TABLE(dbms_xplan.display);

-- index for member id
DROP INDEX ind_aff;
CREATE INDEX ind_aff ON affiliation(affiliated_member, affiliated_family);

-- explain plan #2
EXPLAIN PLAN FOR
SELECT F.id_family, COUNT(A.affiliated_member)+1
FROM family F, affiliation A
GROUP BY F.id_family, A.affiliated_family
HAVING A.affiliated_family = F.id_family;

SELECT * FROM TABLE(dbms_xplan.display);

-- -------------------------------------------------------------------------------------------
--                                    P R I V I L E G E S
-- -------------------------------------------------------------------------------------------
GRANT SELECT ON don TO xhradi16;
GRANT ALL ON ranked_member TO xhradi16;
GRANT ALL ON crime TO xhradi16;
GRANT ALL ON crime_commited TO xhradi16;
GRANT ALL ON murder TO xhradi16;
GRANT ALL ON murder_order TO xhradi16;
GRANT ALL ON meeting TO xhradi16;
GRANT ALL ON meeting_attendance TO xhradi16;
GRANT SELECT ON family TO xhradi16;
GRANT SELECT, INSERT, UPDATE ON affiliation TO xhradi16;
GRANT ALL ON aliance TO xhradi16;
GRANT ALL ON mediated_crime TO xhradi16;
GRANT SELECT, INSERT ON territory TO xhradi16;
GRANT ALL ON territory_owned TO xhradi16;

GRANT EXECUTE ON ucast TO xhradi16;
GRANT EXECUTE ON procento_vrazd TO xhradi16;
-- grant execute on procedures
-- -------------------------------------------------------------------------------------------
--                           M A T E R I A L I Z E D   V I E W
-- -------------------------------------------------------------------------------------------
-- list all murders (date, time, who did them) that weren't a ordered hit
DROP MATERIALIZED VIEW corleone_territory;
CREATE MATERIALIZED VIEW corleone_territory AS
SELECT T.street AS TERRITORY FROM xvlasa14.territory T, xvlasa14.territory_owned O WHERE T.coordinates = O.owned_territory AND O.owners = 'Corleone family';

-- granting permission
GRANT ALL ON corleone_territory TO xhradi16;
-- demonstration
SELECT * FROM corleone_territory;
UPDATE territory SET street = 'Little Italy' WHERE street = 'Little Italy NY';
SELECT * FROM corleone_territory;

-- -------------------------------------------------------------------------------------------
--                                       O T H E R
-- -------------------------------------------------------------------------------------------
-- G R O U P   B Y (get all ranked members from all families)
SELECT M.id_member AS ID, M.name_member AS name, M.surname_member as SURNAME, F.id_family as FAMILY
FROM ranked_member M, family F, affiliation AF
GROUP BY M.id_member, M.name_member, M.surname_member, F.id_family, M.id_member, AF.affiliated_family, AF.affiliated_member
HAVING M.id_member = AF.affiliated_member AND F.id_family = AF.affiliated_family
ORDER BY M.id_member;