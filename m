From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/8] net: dsa: mv88e6xxx: prefix Global VTU macros
Date: Thu, 15 Jun 2017 12:14:02 -0400
Message-ID: <20170615161406.20546-5-vivien.didelot@savoirfairelinux.com>
References: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prefix and document the Global VTU registers macros and give a clear
16-bit registers representation.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 23 ++++++-----
 drivers/net/dsa/mv88e6xxx/chip.h        |  4 +-
 drivers/net/dsa/mv88e6xxx/global1.h     | 69 ++++++++++++++++++++-------------
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 62 +++++++++++++++--------------
 4 files changed, 90 insertions(+), 68 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 066fa63c6b6e..f2ce054913e4 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1047,7 +1047,8 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 		if (!next.valid)
 			break;
 
-		if (next.member[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
+		if (next.member[port] ==
+		    MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 			continue;
 
 		/* reinit and dump this VLAN obj */
@@ -1055,7 +1056,8 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 		vlan->vid_end = next.vid;
 		vlan->flags = 0;
 
-		if (next.member[port] == GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED)
+		if (next.member[port] ==
+		    MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_UNTAGGED)
 			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
 
 		if (next.vid == pvid)
@@ -1143,7 +1145,7 @@ static int mv88e6xxx_vtu_get(struct mv88e6xxx_chip *chip, u16 vid,
 		/* Exclude all ports */
 		for (i = 0; i < mv88e6xxx_num_ports(chip); ++i)
 			entry->member[i] =
-				GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
+				MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_NON_MEMBER;
 
 		return mv88e6xxx_atu_new(chip, &entry->fid);
 	}
@@ -1185,7 +1187,7 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 				continue;
 
 			if (vlan.member[i] ==
-			    GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
+			    MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 				continue;
 
 			if (ds->ports[i].bridge_dev ==
@@ -1281,11 +1283,11 @@ static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 		return;
 
 	if (dsa_is_dsa_port(ds, port) || dsa_is_cpu_port(ds, port))
-		member = GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED;
+		member = MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_UNMODIFIED;
 	else if (untagged)
-		member = GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED;
+		member = MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_UNTAGGED;
 	else
-		member = GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED;
+		member = MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_TAGGED;
 
 	mutex_lock(&chip->reg_lock);
 
@@ -1312,15 +1314,16 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 		return err;
 
 	/* Tell switchdev if this VLAN is handled in software */
-	if (vlan.member[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
+	if (vlan.member[port] == MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 		return -EOPNOTSUPP;
 
-	vlan.member[port] = GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
+	vlan.member[port] = MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_NON_MEMBER;
 
 	/* keep the VLAN unless all ports are excluded */
 	vlan.valid = false;
 	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
-		if (vlan.member[i] != GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER) {
+		if (vlan.member[i] !=
+		    MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_NON_MEMBER) {
 			vlan.valid = true;
 			break;
 		}
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index d70873498501..409452ebc4b9 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -127,12 +127,12 @@ enum mv88e6xxx_cap {
 
 	/* Per VLAN Spanning Tree Unit (STU).
 	 * The Port State database, if present, is accessed through VTU
-	 * operations and dedicated SID registers. See GLOBAL_VTU_SID.
+	 * operations and dedicated SID registers. See MV88E6352_G1_VTU_SID.
 	 */
 	MV88E6XXX_CAP_STU,
 
 	/* VLAN Table Unit.
-	 * The VTU is used to program 802.1Q VLANs. See GLOBAL_VTU_OP.
+	 * The VTU is used to program 802.1Q VLANs. See MV88E6XXX_G1_VTU_OP.
 	 */
 	MV88E6XXX_CAP_VTU,
 };
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 126515532d53..56ba709628c7 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -47,10 +47,14 @@
 /* Offset 0x01: ATU FID Register */
 #define MV88E6352_G1_ATU_FID		0x01
 
-#define GLOBAL_VTU_FID		0x02
-#define GLOBAL_VTU_FID_MASK	0xfff
-#define GLOBAL_VTU_SID		0x03	/* 6097 6165 6351 6352 */
-#define GLOBAL_VTU_SID_MASK	0x3f
+/* Offset 0x02: VTU FID Register */
+#define MV88E6352_G1_VTU_FID		0x02
+#define MV88E6352_G1_VTU_FID_MASK	0x0fff
+
+/* Offset 0x03: VTU SID Register */
+#define MV88E6352_G1_VTU_SID		0x03
+#define MV88E6352_G1_VTU_SID_MASK	0x3f
+
 #define GLOBAL_CONTROL		0x04
 #define GLOBAL_CONTROL_SW_RESET		BIT(15)
 #define GLOBAL_CONTROL_PPU_ENABLE	BIT(14)
@@ -66,29 +70,40 @@
 #define GLOBAL_CONTROL_ATU_DONE_EN	BIT(2)
 #define GLOBAL_CONTROL_TCAM_EN		BIT(1)
 #define GLOBAL_CONTROL_EEPROM_DONE_EN	BIT(0)
-#define GLOBAL_VTU_OP		0x05
-#define GLOBAL_VTU_OP_BUSY	BIT(15)
-#define GLOBAL_VTU_OP_FLUSH_ALL		((0x01 << 12) | GLOBAL_VTU_OP_BUSY)
-#define GLOBAL_VTU_OP_VTU_LOAD_PURGE	((0x03 << 12) | GLOBAL_VTU_OP_BUSY)
-#define GLOBAL_VTU_OP_VTU_GET_NEXT	((0x04 << 12) | GLOBAL_VTU_OP_BUSY)
-#define GLOBAL_VTU_OP_STU_LOAD_PURGE	((0x05 << 12) | GLOBAL_VTU_OP_BUSY)
-#define GLOBAL_VTU_OP_STU_GET_NEXT	((0x06 << 12) | GLOBAL_VTU_OP_BUSY)
-#define GLOBAL_VTU_VID		0x06
-#define GLOBAL_VTU_VID_MASK	0xfff
-#define GLOBAL_VTU_VID_PAGE	BIT(13)
-#define GLOBAL_VTU_VID_VALID	BIT(12)
-#define GLOBAL_VTU_DATA_0_3	0x07
-#define GLOBAL_VTU_DATA_4_7	0x08
-#define GLOBAL_VTU_DATA_8_11	0x09
-#define GLOBAL_VTU_STU_DATA_MASK		0x03
-#define GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED	0x00
-#define GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED	0x01
-#define GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED	0x02
-#define GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER	0x03
-#define GLOBAL_STU_DATA_PORT_STATE_DISABLED	0x00
-#define GLOBAL_STU_DATA_PORT_STATE_BLOCKING	0x01
-#define GLOBAL_STU_DATA_PORT_STATE_LEARNING	0x02
-#define GLOBAL_STU_DATA_PORT_STATE_FORWARDING	0x03
+
+/* Offset 0x05: VTU Operation Register */
+#define MV88E6XXX_G1_VTU_OP			0x05
+#define MV88E6XXX_G1_VTU_OP_BUSY		0x8000
+#define MV88E6XXX_G1_VTU_OP_MASK		0x7000
+#define MV88E6XXX_G1_VTU_OP_FLUSH_ALL		0x1000
+#define MV88E6XXX_G1_VTU_OP_NOOP		0x2000
+#define MV88E6XXX_G1_VTU_OP_VTU_LOAD_PURGE	0x3000
+#define MV88E6XXX_G1_VTU_OP_VTU_GET_NEXT	0x4000
+#define MV88E6XXX_G1_VTU_OP_STU_LOAD_PURGE	0x5000
+#define MV88E6XXX_G1_VTU_OP_STU_GET_NEXT	0x6000
+
+/* Offset 0x06: VTU VID Register */
+#define MV88E6XXX_G1_VTU_VID		0x06
+#define MV88E6XXX_G1_VTU_VID_MASK	0x0fff
+#define MV88E6390_G1_VTU_VID_PAGE	0x2000
+#define MV88E6XXX_G1_VTU_VID_VALID	0x1000
+
+/* Offset 0x07: VTU/STU Data Register 1
+ * Offset 0x08: VTU/STU Data Register 2
+ * Offset 0x09: VTU/STU Data Register 3
+ */
+#define MV88E6XXX_G1_VTU_DATA1				0x07
+#define MV88E6XXX_G1_VTU_DATA2				0x08
+#define MV88E6XXX_G1_VTU_DATA3				0x09
+#define MV88E6XXX_G1_VTU_STU_DATA_MASK			0x0003
+#define MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_UNMODIFIED	0x0000
+#define MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_UNTAGGED	0x0001
+#define MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_TAGGED		0x0002
+#define MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_NON_MEMBER	0x0003
+#define MV88E6XXX_G1_STU_DATA_PORT_STATE_DISABLED	0x0000
+#define MV88E6XXX_G1_STU_DATA_PORT_STATE_BLOCKING	0x0001
+#define MV88E6XXX_G1_STU_DATA_PORT_STATE_LEARNING	0x0002
+#define MV88E6XXX_G1_STU_DATA_PORT_STATE_FORWARDING	0x0003
 
 /* Offset 0x0A: ATU Control Register */
 #define MV88E6XXX_G1_ATU_CTL		0x0a
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
index bf593c7aaa9b..8c8a0ec3d6e9 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -22,11 +22,11 @@ static int mv88e6xxx_g1_vtu_fid_read(struct mv88e6xxx_chip *chip,
 	u16 val;
 	int err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_FID, &val);
+	err = mv88e6xxx_g1_read(chip, MV88E6352_G1_VTU_FID, &val);
 	if (err)
 		return err;
 
-	entry->fid = val & GLOBAL_VTU_FID_MASK;
+	entry->fid = val & MV88E6352_G1_VTU_FID_MASK;
 
 	return 0;
 }
@@ -34,9 +34,9 @@ static int mv88e6xxx_g1_vtu_fid_read(struct mv88e6xxx_chip *chip,
 static int mv88e6xxx_g1_vtu_fid_write(struct mv88e6xxx_chip *chip,
 				      struct mv88e6xxx_vtu_entry *entry)
 {
-	u16 val = entry->fid & GLOBAL_VTU_FID_MASK;
+	u16 val = entry->fid & MV88E6352_G1_VTU_FID_MASK;
 
-	return mv88e6xxx_g1_write(chip, GLOBAL_VTU_FID, val);
+	return mv88e6xxx_g1_write(chip, MV88E6352_G1_VTU_FID, val);
 }
 
 /* Offset 0x03: VTU SID Register */
@@ -47,11 +47,11 @@ static int mv88e6xxx_g1_vtu_sid_read(struct mv88e6xxx_chip *chip,
 	u16 val;
 	int err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_SID, &val);
+	err = mv88e6xxx_g1_read(chip, MV88E6352_G1_VTU_SID, &val);
 	if (err)
 		return err;
 
-	entry->sid = val & GLOBAL_VTU_SID_MASK;
+	entry->sid = val & MV88E6352_G1_VTU_SID_MASK;
 
 	return 0;
 }
@@ -59,23 +59,25 @@ static int mv88e6xxx_g1_vtu_sid_read(struct mv88e6xxx_chip *chip,
 static int mv88e6xxx_g1_vtu_sid_write(struct mv88e6xxx_chip *chip,
 				      struct mv88e6xxx_vtu_entry *entry)
 {
-	u16 val = entry->sid & GLOBAL_VTU_SID_MASK;
+	u16 val = entry->sid & MV88E6352_G1_VTU_SID_MASK;
 
-	return mv88e6xxx_g1_write(chip, GLOBAL_VTU_SID, val);
+	return mv88e6xxx_g1_write(chip, MV88E6352_G1_VTU_SID, val);
 }
 
 /* Offset 0x05: VTU Operation Register */
 
 static int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip)
 {
-	return mv88e6xxx_g1_wait(chip, GLOBAL_VTU_OP, GLOBAL_VTU_OP_BUSY);
+	return mv88e6xxx_g1_wait(chip, MV88E6XXX_G1_VTU_OP,
+				 MV88E6XXX_G1_VTU_OP_BUSY);
 }
 
 static int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op)
 {
 	int err;
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_OP, op);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_VTU_OP,
+				 MV88E6XXX_G1_VTU_OP_BUSY | op);
 	if (err)
 		return err;
 
@@ -90,16 +92,16 @@ static int mv88e6xxx_g1_vtu_vid_read(struct mv88e6xxx_chip *chip,
 	u16 val;
 	int err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_VID, &val);
+	err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_VTU_VID, &val);
 	if (err)
 		return err;
 
 	entry->vid = val & 0xfff;
 
-	if (val & GLOBAL_VTU_VID_PAGE)
+	if (val & MV88E6390_G1_VTU_VID_PAGE)
 		entry->vid |= 0x1000;
 
-	entry->valid = !!(val & GLOBAL_VTU_VID_VALID);
+	entry->valid = !!(val & MV88E6XXX_G1_VTU_VID_VALID);
 
 	return 0;
 }
@@ -110,12 +112,12 @@ static int mv88e6xxx_g1_vtu_vid_write(struct mv88e6xxx_chip *chip,
 	u16 val = entry->vid & 0xfff;
 
 	if (entry->vid & 0x1000)
-		val |= GLOBAL_VTU_VID_PAGE;
+		val |= MV88E6390_G1_VTU_VID_PAGE;
 
 	if (entry->valid)
-		val |= GLOBAL_VTU_VID_VALID;
+		val |= MV88E6XXX_G1_VTU_VID_VALID;
 
-	return mv88e6xxx_g1_write(chip, GLOBAL_VTU_VID, val);
+	return mv88e6xxx_g1_write(chip, MV88E6XXX_G1_VTU_VID, val);
 }
 
 /* Offset 0x07: VTU/STU Data Register 1
@@ -134,7 +136,7 @@ static int mv88e6185_g1_vtu_data_read(struct mv88e6xxx_chip *chip,
 		u16 *reg = &regs[i];
 		int err;
 
-		err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_DATA_0_3 + i, reg);
+		err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_VTU_DATA1 + i, reg);
 		if (err)
 			return err;
 	}
@@ -171,7 +173,7 @@ static int mv88e6185_g1_vtu_data_write(struct mv88e6xxx_chip *chip,
 		u16 reg = regs[i];
 		int err;
 
-		err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_DATA_0_3 + i, reg);
+		err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_VTU_DATA1 + i, reg);
 		if (err)
 			return err;
 	}
@@ -189,7 +191,7 @@ static int mv88e6390_g1_vtu_data_read(struct mv88e6xxx_chip *chip, u8 *data)
 		u16 *reg = &regs[i];
 		int err;
 
-		err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_DATA_0_3 + i, reg);
+		err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_VTU_DATA1 + i, reg);
 		if (err)
 			return err;
 	}
@@ -221,7 +223,7 @@ static int mv88e6390_g1_vtu_data_write(struct mv88e6xxx_chip *chip, u8 *data)
 		u16 reg = regs[i];
 		int err;
 
-		err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_DATA_0_3 + i, reg);
+		err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_VTU_DATA1 + i, reg);
 		if (err)
 			return err;
 	}
@@ -240,7 +242,7 @@ static int mv88e6xxx_g1_vtu_stu_getnext(struct mv88e6xxx_chip *chip,
 	if (err)
 		return err;
 
-	err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_STU_GET_NEXT);
+	err = mv88e6xxx_g1_vtu_op(chip, MV88E6XXX_G1_VTU_OP_STU_GET_NEXT);
 	if (err)
 		return err;
 
@@ -295,7 +297,7 @@ static int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
 			return err;
 	}
 
-	err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_VTU_GET_NEXT);
+	err = mv88e6xxx_g1_vtu_op(chip, MV88E6XXX_G1_VTU_OP_VTU_GET_NEXT);
 	if (err)
 		return err;
 
@@ -320,7 +322,7 @@ int mv88e6185_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
 		/* VTU DBNum[3:0] are located in VTU Operation 3:0
 		 * VTU DBNum[7:4] are located in VTU Operation 11:8
 		 */
-		err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_OP, &val);
+		err = mv88e6xxx_g1_read(chip, MV88E6XXX_G1_VTU_OP, &val);
 		if (err)
 			return err;
 
@@ -394,7 +396,7 @@ int mv88e6390_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
 int mv88e6185_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 			       struct mv88e6xxx_vtu_entry *entry)
 {
-	u16 op = GLOBAL_VTU_OP_VTU_LOAD_PURGE;
+	u16 op = MV88E6XXX_G1_VTU_OP_VTU_LOAD_PURGE;
 	int err;
 
 	err = mv88e6xxx_g1_vtu_op_wait(chip);
@@ -444,7 +446,8 @@ int mv88e6352_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 			return err;
 
 		/* Load STU entry */
-		err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
+		err = mv88e6xxx_g1_vtu_op(chip,
+					  MV88E6XXX_G1_VTU_OP_STU_LOAD_PURGE);
 		if (err)
 			return err;
 
@@ -454,7 +457,7 @@ int mv88e6352_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 	}
 
 	/* Load/Purge VTU entry */
-	return mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_VTU_LOAD_PURGE);
+	return mv88e6xxx_g1_vtu_op(chip, MV88E6XXX_G1_VTU_OP_VTU_LOAD_PURGE);
 }
 
 int mv88e6390_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
@@ -481,7 +484,8 @@ int mv88e6390_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 			return err;
 
 		/* Load STU entry */
-		err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
+		err = mv88e6xxx_g1_vtu_op(chip,
+					  MV88E6XXX_G1_VTU_OP_STU_LOAD_PURGE);
 		if (err)
 			return err;
 
@@ -496,7 +500,7 @@ int mv88e6390_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 	}
 
 	/* Load/Purge VTU entry */
-	return mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_VTU_LOAD_PURGE);
+	return mv88e6xxx_g1_vtu_op(chip, MV88E6XXX_G1_VTU_OP_VTU_LOAD_PURGE);
 }
 
 int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip)
@@ -507,5 +511,5 @@ int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
-	return mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_FLUSH_ALL);
+	return mv88e6xxx_g1_vtu_op(chip, MV88E6XXX_G1_VTU_OP_FLUSH_ALL);
 }
-- 
2.13.1
