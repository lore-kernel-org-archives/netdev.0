From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 06/18] net: dsa: mv88e6xxx: move VTU SID accessors
Date: Wed, 26 Apr 2017 11:53:24 -0400
Message-ID: <20170426155336.5937-7-vivien.didelot@savoirfairelinux.com>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add helpers to access the VTU SID register in the global1_vtu.c file.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 21 ++++++++-------------
 drivers/net/dsa/mv88e6xxx/global1.h     |  4 ++++
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 25 +++++++++++++++++++++++++
 3 files changed, 37 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 0452543a2463..ec621879439d 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1387,11 +1387,9 @@ static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 		}
 
 		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_STU)) {
-			err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_SID, &val);
+			err = mv88e6xxx_g1_vtu_sid_read(chip, &next);
 			if (err)
 				return err;
-
-			next.sid = val & GLOBAL_VTU_SID_MASK;
 		}
 	}
 
@@ -1482,8 +1480,7 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 		return err;
 
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_STU)) {
-		reg = entry->sid & GLOBAL_VTU_SID_MASK;
-		err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_SID, reg);
+		err = mv88e6xxx_g1_vtu_sid_write(chip, entry);
 		if (err)
 			return err;
 	}
@@ -1513,7 +1510,9 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
 				  struct mv88e6xxx_vtu_entry *entry)
 {
-	struct mv88e6xxx_vtu_entry next = { 0 };
+	struct mv88e6xxx_vtu_entry next = {
+		.sid = sid,
+	};
 	u16 val;
 	int err;
 
@@ -1521,8 +1520,7 @@ static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
 	if (err)
 		return err;
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_SID,
-				 sid & GLOBAL_VTU_SID_MASK);
+	err = mv88e6xxx_g1_vtu_sid_write(chip, &next);
 	if (err)
 		return err;
 
@@ -1530,12 +1528,10 @@ static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
 	if (err)
 		return err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_SID, &val);
+	err = mv88e6xxx_g1_vtu_sid_read(chip, &next);
 	if (err)
 		return err;
 
-	next.sid = val & GLOBAL_VTU_SID_MASK;
-
 	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_VID, &val);
 	if (err)
 		return err;
@@ -1576,8 +1572,7 @@ static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
 	if (err)
 		return err;
 
-	reg = entry->sid & GLOBAL_VTU_SID_MASK;
-	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_SID, reg);
+	err = mv88e6xxx_g1_vtu_sid_write(chip, entry);
 	if (err)
 		return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 353de283362f..1bf235085215 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -54,6 +54,10 @@ int mv88e6xxx_g1_vtu_fid_read(struct mv88e6xxx_chip *chip,
 			      struct mv88e6xxx_vtu_entry *entry);
 int mv88e6xxx_g1_vtu_fid_write(struct mv88e6xxx_chip *chip,
 			       struct mv88e6xxx_vtu_entry *entry);
+int mv88e6xxx_g1_vtu_sid_read(struct mv88e6xxx_chip *chip,
+			      struct mv88e6xxx_vtu_entry *entry);
+int mv88e6xxx_g1_vtu_sid_write(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry);
 int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op);
 int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip);
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
index 81d6f9f3c84a..201c063d15f2 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -39,6 +39,31 @@ int mv88e6xxx_g1_vtu_fid_write(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_g1_write(chip, GLOBAL_VTU_FID, val);
 }
 
+/* Offset 0x03: VTU SID Register */
+
+int mv88e6xxx_g1_vtu_sid_read(struct mv88e6xxx_chip *chip,
+			      struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_SID, &val);
+	if (err)
+		return err;
+
+	entry->sid = val & GLOBAL_VTU_SID_MASK;
+
+	return 0;
+}
+
+int mv88e6xxx_g1_vtu_sid_write(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 val = entry->sid & GLOBAL_VTU_SID_MASK;
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_VTU_SID, val);
+}
+
 /* Offset 0x05: VTU Operation Register */
 
 int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip)
-- 
2.12.2
