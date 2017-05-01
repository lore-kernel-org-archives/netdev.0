From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 08/18] net: dsa: mv88e6xxx: move generic VTU GetNext
Date: Mon,  1 May 2017 14:05:17 -0400
Message-ID: <20170501180527.11756-9-vivien.didelot@savoirfairelinux.com>
References: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Even though every switch model has a different way to access the VTU
Data bits, the base implementation of the VTU GetNext operation remains
the same: wait, write the first VID to iterate from, start the
operation, and read the next VID.

Move this generic implementation into global1_vtu.c and abstract the
handling of the start VID (similarly to the ATU GetNext implementation),
before introducing a new chip operation for specific chips.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 31 ++-----------------------------
 drivers/net/dsa/mv88e6xxx/global1.h     |  2 ++
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 29 +++++++++++++++++++++++++++++
 3 files changed, 33 insertions(+), 29 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index dce490e78347..70b420e134ce 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1340,19 +1340,11 @@ static int mv88e6xxx_stu_data_write(struct mv88e6xxx_chip *chip,
 static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 				  struct mv88e6xxx_vtu_entry *entry)
 {
-	struct mv88e6xxx_vtu_entry next = { 0 };
+	struct mv88e6xxx_vtu_entry next = *entry;
 	u16 val;
 	int err;
 
-	err = mv88e6xxx_g1_vtu_op_wait(chip);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_VTU_GET_NEXT);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_vtu_vid_read(chip, &next);
+	err = mv88e6xxx_g1_vtu_getnext(chip, &next);
 	if (err)
 		return err;
 
@@ -1416,10 +1408,6 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 	if (err)
 		goto unlock;
 
-	err = mv88e6xxx_g1_vtu_vid_write(chip, &next);
-	if (err)
-		goto unlock;
-
 	do {
 		err = _mv88e6xxx_vtu_getnext(chip, &next);
 		if (err)
@@ -1582,10 +1570,6 @@ static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 	}
 
 	/* Set every FID bit used by the VLAN entries */
-	err = mv88e6xxx_g1_vtu_vid_write(chip, &vlan);
-	if (err)
-		return err;
-
 	do {
 		err = _mv88e6xxx_vtu_getnext(chip, &vlan);
 		if (err)
@@ -1668,9 +1652,6 @@ static int _mv88e6xxx_vtu_get(struct mv88e6xxx_chip *chip, u16 vid,
 
 	entry->vid = vid - 1;
 	entry->valid = false;
-	err = mv88e6xxx_g1_vtu_vid_write(chip, entry);
-	if (err)
-		return err;
 
 	err = _mv88e6xxx_vtu_getnext(chip, entry);
 	if (err)
@@ -1703,10 +1684,6 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 
 	mutex_lock(&chip->reg_lock);
 
-	err = mv88e6xxx_g1_vtu_vid_write(chip, &vlan);
-	if (err)
-		goto unlock;
-
 	do {
 		err = _mv88e6xxx_vtu_getnext(chip, &vlan);
 		if (err)
@@ -2065,10 +2042,6 @@ static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 		return err;
 
 	/* Dump VLANs' Filtering Information Databases */
-	err = mv88e6xxx_g1_vtu_vid_write(chip, &vlan);
-	if (err)
-		return err;
-
 	do {
 		err = _mv88e6xxx_vtu_getnext(chip, &vlan);
 		if (err)
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 22fe22bd82cd..66216848fc0d 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -64,6 +64,8 @@ int mv88e6xxx_g1_vtu_vid_write(struct mv88e6xxx_chip *chip,
 			       struct mv88e6xxx_vtu_entry *entry);
 int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op);
+int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_vtu_entry *entry);
 int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip);
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
index 6ac3d0eeae6b..c3f55be873b3 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -113,6 +113,35 @@ int mv88e6xxx_g1_vtu_vid_write(struct mv88e6xxx_chip *chip,
 
 /* VLAN Translation Unit Operations */
 
+int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_vtu_entry *entry)
+{
+	int err;
+
+	err = mv88e6xxx_g1_vtu_op_wait(chip);
+	if (err)
+		return err;
+
+	/* To get the next higher active VID, the VTU GetNext operation can be
+	 * started again without setting the VID registers since it already
+	 * contains the last VID.
+	 *
+	 * To save a few hardware accesses and abstract this to the caller,
+	 * write the VID only once, when the entry is given as invalid.
+	 */
+	if (!entry->valid) {
+		err = mv88e6xxx_g1_vtu_vid_write(chip, entry);
+		if (err)
+			return err;
+	}
+
+	err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_VTU_GET_NEXT);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g1_vtu_vid_read(chip, entry);
+}
+
 int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip)
 {
 	int err;
-- 
2.12.2
