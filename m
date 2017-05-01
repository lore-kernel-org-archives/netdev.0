From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 07/18] net: dsa: mv88e6xxx: move VTU VID accessors
Date: Mon,  1 May 2017 14:05:16 -0400
Message-ID: <20170501180527.11756-8-vivien.didelot@savoirfairelinux.com>
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

Add helpers to access the VTU VID register in the global1_vtu.c file.

At the same time, move mv88e6xxx_g1_vtu_vid_write at the beginning of
_mv88e6xxx_vtu_loadpurge, which adds no functional changes but makes
future patches simpler.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 57 +++++++++++++--------------------
 drivers/net/dsa/mv88e6xxx/global1.h     |  4 +++
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 29 +++++++++++++++++
 3 files changed, 56 insertions(+), 34 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index ec621879439d..dce490e78347 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1337,12 +1337,6 @@ static int mv88e6xxx_stu_data_write(struct mv88e6xxx_chip *chip,
 	return _mv88e6xxx_vtu_stu_data_write(chip, entry, 2);
 }
 
-static int _mv88e6xxx_vtu_vid_write(struct mv88e6xxx_chip *chip, u16 vid)
-{
-	return mv88e6xxx_g1_write(chip, GLOBAL_VTU_VID,
-				  vid & GLOBAL_VTU_VID_MASK);
-}
-
 static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 				  struct mv88e6xxx_vtu_entry *entry)
 {
@@ -1358,13 +1352,10 @@ static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 	if (err)
 		return err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_VID, &val);
+	err = mv88e6xxx_g1_vtu_vid_read(chip, &next);
 	if (err)
 		return err;
 
-	next.vid = val & GLOBAL_VTU_VID_MASK;
-	next.valid = !!(val & GLOBAL_VTU_VID_VALID);
-
 	if (next.valid) {
 		err = mv88e6xxx_vtu_data_read(chip, &next);
 		if (err)
@@ -1410,7 +1401,9 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 				    int (*cb)(struct switchdev_obj *obj))
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	struct mv88e6xxx_vtu_entry next;
+	struct mv88e6xxx_vtu_entry next = {
+		.vid = chip->info->max_vid,
+	};
 	u16 pvid;
 	int err;
 
@@ -1423,7 +1416,7 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 	if (err)
 		goto unlock;
 
-	err = _mv88e6xxx_vtu_vid_write(chip, GLOBAL_VTU_VID_MASK);
+	err = mv88e6xxx_g1_vtu_vid_write(chip, &next);
 	if (err)
 		goto unlock;
 
@@ -1464,13 +1457,16 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 				    struct mv88e6xxx_vtu_entry *entry)
 {
 	u16 op = GLOBAL_VTU_OP_VTU_LOAD_PURGE;
-	u16 reg = 0;
 	int err;
 
 	err = mv88e6xxx_g1_vtu_op_wait(chip);
 	if (err)
 		return err;
 
+	err = mv88e6xxx_g1_vtu_vid_write(chip, entry);
+	if (err)
+		return err;
+
 	if (!entry->valid)
 		goto loadpurge;
 
@@ -1496,14 +1492,7 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 		op |= (entry->fid & 0xf0) << 8;
 		op |= entry->fid & 0xf;
 	}
-
-	reg = GLOBAL_VTU_VID_VALID;
 loadpurge:
-	reg |= entry->vid & GLOBAL_VTU_VID_MASK;
-	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_VID, reg);
-	if (err)
-		return err;
-
 	return mv88e6xxx_g1_vtu_op(chip, op);
 }
 
@@ -1513,7 +1502,6 @@ static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
 	struct mv88e6xxx_vtu_entry next = {
 		.sid = sid,
 	};
-	u16 val;
 	int err;
 
 	err = mv88e6xxx_g1_vtu_op_wait(chip);
@@ -1532,12 +1520,10 @@ static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
 	if (err)
 		return err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_VID, &val);
+	err = mv88e6xxx_g1_vtu_vid_read(chip, &next);
 	if (err)
 		return err;
 
-	next.valid = !!(val & GLOBAL_VTU_VID_VALID);
-
 	if (next.valid) {
 		err = mv88e6xxx_stu_data_read(chip, &next);
 		if (err)
@@ -1551,7 +1537,6 @@ static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
 static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
 				    struct mv88e6xxx_vtu_entry *entry)
 {
-	u16 reg = 0;
 	int err;
 
 	err = mv88e6xxx_g1_vtu_op_wait(chip);
@@ -1565,10 +1550,8 @@ static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
 	err = mv88e6xxx_stu_data_write(chip, entry);
 	if (err)
 		return err;
-
-	reg = GLOBAL_VTU_VID_VALID;
 loadpurge:
-	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_VID, reg);
+	err = mv88e6xxx_g1_vtu_vid_write(chip, entry);
 	if (err)
 		return err;
 
@@ -1582,7 +1565,9 @@ static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
 static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 {
 	DECLARE_BITMAP(fid_bitmap, MV88E6XXX_N_FID);
-	struct mv88e6xxx_vtu_entry vlan;
+	struct mv88e6xxx_vtu_entry vlan = {
+		.vid = chip->info->max_vid,
+	};
 	int i, err;
 
 	bitmap_zero(fid_bitmap, MV88E6XXX_N_FID);
@@ -1597,7 +1582,7 @@ static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 	}
 
 	/* Set every FID bit used by the VLAN entries */
-	err = _mv88e6xxx_vtu_vid_write(chip, GLOBAL_VTU_VID_MASK);
+	err = mv88e6xxx_g1_vtu_vid_write(chip, &vlan);
 	if (err)
 		return err;
 
@@ -1681,7 +1666,9 @@ static int _mv88e6xxx_vtu_get(struct mv88e6xxx_chip *chip, u16 vid,
 	if (!vid)
 		return -EINVAL;
 
-	err = _mv88e6xxx_vtu_vid_write(chip, vid - 1);
+	entry->vid = vid - 1;
+	entry->valid = false;
+	err = mv88e6xxx_g1_vtu_vid_write(chip, entry);
 	if (err)
 		return err;
 
@@ -1706,7 +1693,9 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 					u16 vid_begin, u16 vid_end)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	struct mv88e6xxx_vtu_entry vlan;
+	struct mv88e6xxx_vtu_entry vlan = {
+		.vid = vid_begin - 1,
+	};
 	int i, err;
 
 	if (!vid_begin)
@@ -1714,7 +1703,7 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 
 	mutex_lock(&chip->reg_lock);
 
-	err = _mv88e6xxx_vtu_vid_write(chip, vid_begin - 1);
+	err = mv88e6xxx_g1_vtu_vid_write(chip, &vlan);
 	if (err)
 		goto unlock;
 
@@ -2076,7 +2065,7 @@ static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 		return err;
 
 	/* Dump VLANs' Filtering Information Databases */
-	err = _mv88e6xxx_vtu_vid_write(chip, vlan.vid);
+	err = mv88e6xxx_g1_vtu_vid_write(chip, &vlan);
 	if (err)
 		return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 1bf235085215..22fe22bd82cd 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -58,6 +58,10 @@ int mv88e6xxx_g1_vtu_sid_read(struct mv88e6xxx_chip *chip,
 			      struct mv88e6xxx_vtu_entry *entry);
 int mv88e6xxx_g1_vtu_sid_write(struct mv88e6xxx_chip *chip,
 			       struct mv88e6xxx_vtu_entry *entry);
+int mv88e6xxx_g1_vtu_vid_read(struct mv88e6xxx_chip *chip,
+			      struct mv88e6xxx_vtu_entry *entry);
+int mv88e6xxx_g1_vtu_vid_write(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry);
 int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op);
 int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip);
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
index 201c063d15f2..6ac3d0eeae6b 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -82,6 +82,35 @@ int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op)
 	return mv88e6xxx_g1_vtu_op_wait(chip);
 }
 
+/* Offset 0x06: VTU VID Register */
+
+int mv88e6xxx_g1_vtu_vid_read(struct mv88e6xxx_chip *chip,
+			      struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_VID, &val);
+	if (err)
+		return err;
+
+	entry->vid = val & 0xfff;
+	entry->valid = !!(val & GLOBAL_VTU_VID_VALID);
+
+	return 0;
+}
+
+int mv88e6xxx_g1_vtu_vid_write(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 val = entry->vid & 0xfff;
+
+	if (entry->valid)
+		val |= GLOBAL_VTU_VID_VALID;
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_VTU_VID, val);
+}
+
 /* VLAN Translation Unit Operations */
 
 int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip)
-- 
2.12.2
