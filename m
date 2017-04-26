From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 09/18] net: dsa: mv88e6xxx: move VTU Data accessors
Date: Wed, 26 Apr 2017 11:53:27 -0400
Message-ID: <20170426155336.5937-10-vivien.didelot@savoirfairelinux.com>
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

The code to access the VTU Data registers currently only supports the
88E6185 family and alike: 2-bit membership adjacent to 2-bit port state.

Even though the 88E6352 family introduced an indirect table to program
the VLAN Spanning Tree states, the usage of the VTU Data registers
remains the same regardless the VTU or STU operation.

Now that the mv88e6xxx_vtu_entry structure contains both port membership
and states data, factorize the code to access them in global1_vtu.c.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 88 +++------------------------------
 drivers/net/dsa/mv88e6xxx/global1.h     |  4 ++
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 61 +++++++++++++++++++++++
 3 files changed, 72 insertions(+), 81 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 70b420e134ce..b163e40bf42e 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1263,80 +1263,6 @@ static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
 		netdev_err(ds->ports[port].netdev, "failed to flush ATU\n");
 }
 
-static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_chip *chip,
-					struct mv88e6xxx_vtu_entry *entry,
-					unsigned int nibble_offset)
-{
-	u16 regs[3];
-	int i, err;
-
-	for (i = 0; i < 3; ++i) {
-		u16 *reg = &regs[i];
-
-		err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_DATA_0_3 + i, reg);
-		if (err)
-			return err;
-	}
-
-	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
-		unsigned int shift = (i % 4) * 4 + nibble_offset;
-		u16 reg = regs[i / 4];
-
-		entry->state[i] = (reg >> shift) & GLOBAL_VTU_STU_DATA_MASK;
-	}
-
-	return 0;
-}
-
-static int mv88e6xxx_vtu_data_read(struct mv88e6xxx_chip *chip,
-				   struct mv88e6xxx_vtu_entry *entry)
-{
-	return _mv88e6xxx_vtu_stu_data_read(chip, entry, 0);
-}
-
-static int mv88e6xxx_stu_data_read(struct mv88e6xxx_chip *chip,
-				   struct mv88e6xxx_vtu_entry *entry)
-{
-	return _mv88e6xxx_vtu_stu_data_read(chip, entry, 2);
-}
-
-static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_chip *chip,
-					 struct mv88e6xxx_vtu_entry *entry,
-					 unsigned int nibble_offset)
-{
-	u16 regs[3] = { 0 };
-	int i, err;
-
-	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
-		unsigned int shift = (i % 4) * 4 + nibble_offset;
-		u8 data = entry->state[i];
-
-		regs[i / 4] |= (data & GLOBAL_VTU_STU_DATA_MASK) << shift;
-	}
-
-	for (i = 0; i < 3; ++i) {
-		u16 reg = regs[i];
-
-		err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_DATA_0_3 + i, reg);
-		if (err)
-			return err;
-	}
-
-	return 0;
-}
-
-static int mv88e6xxx_vtu_data_write(struct mv88e6xxx_chip *chip,
-				    struct mv88e6xxx_vtu_entry *entry)
-{
-	return _mv88e6xxx_vtu_stu_data_write(chip, entry, 0);
-}
-
-static int mv88e6xxx_stu_data_write(struct mv88e6xxx_chip *chip,
-				    struct mv88e6xxx_vtu_entry *entry)
-{
-	return _mv88e6xxx_vtu_stu_data_write(chip, entry, 2);
-}
-
 static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 				  struct mv88e6xxx_vtu_entry *entry)
 {
@@ -1349,10 +1275,6 @@ static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 		return err;
 
 	if (next.valid) {
-		err = mv88e6xxx_vtu_data_read(chip, &next);
-		if (err)
-			return err;
-
 		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G1_VTU_FID)) {
 			err = mv88e6xxx_g1_vtu_fid_read(chip, &next);
 			if (err)
@@ -1374,6 +1296,10 @@ static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 			if (err)
 				return err;
 		}
+
+		err = mv88e6185_g1_vtu_data_read(chip, &next);
+		if (err)
+			return err;
 	}
 
 	*entry = next;
@@ -1459,7 +1385,7 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 		goto loadpurge;
 
 	/* Write port member tags */
-	err = mv88e6xxx_vtu_data_write(chip, entry);
+	err = mv88e6185_g1_vtu_data_write(chip, entry);
 	if (err)
 		return err;
 
@@ -1513,7 +1439,7 @@ static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
 		return err;
 
 	if (next.valid) {
-		err = mv88e6xxx_stu_data_read(chip, &next);
+		err = mv88e6185_g1_vtu_data_read(chip, &next);
 		if (err)
 			return err;
 	}
@@ -1535,7 +1461,7 @@ static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
 		goto loadpurge;
 
 	/* Write port states */
-	err = mv88e6xxx_stu_data_write(chip, entry);
+	err = mv88e6185_g1_vtu_data_write(chip, entry);
 	if (err)
 		return err;
 loadpurge:
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 66216848fc0d..9644ca649838 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -62,6 +62,10 @@ int mv88e6xxx_g1_vtu_vid_read(struct mv88e6xxx_chip *chip,
 			      struct mv88e6xxx_vtu_entry *entry);
 int mv88e6xxx_g1_vtu_vid_write(struct mv88e6xxx_chip *chip,
 			       struct mv88e6xxx_vtu_entry *entry);
+int mv88e6185_g1_vtu_data_read(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry);
+int mv88e6185_g1_vtu_data_write(struct mv88e6xxx_chip *chip,
+				struct mv88e6xxx_vtu_entry *entry);
 int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op);
 int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
index efe43d7d9e10..e550c9f013e4 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -111,6 +111,67 @@ int mv88e6xxx_g1_vtu_vid_write(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_g1_write(chip, GLOBAL_VTU_VID, val);
 }
 
+/* Offset 0x07: VTU/STU Data Register 1
+ * Offset 0x08: VTU/STU Data Register 2
+ * Offset 0x09: VTU/STU Data Register 3
+ */
+
+int mv88e6185_g1_vtu_data_read(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 regs[3];
+	int i;
+
+	/* Read all 3 VTU/STU Data registers */
+	for (i = 0; i < 3; ++i) {
+		u16 *reg = &regs[i];
+		int err;
+
+		err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_DATA_0_3 + i, reg);
+		if (err)
+			return err;
+	}
+
+	/* Extract MemberTag and PortState data */
+	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
+		unsigned int member_offset = (i % 4) * 4;
+		unsigned int state_offset = member_offset + 2;
+
+		entry->member[i] = (regs[i / 4] >> member_offset) & 0x3;
+		entry->state[i] = (regs[i / 4] >> state_offset) & 0x3;
+	}
+
+	return 0;
+}
+
+int mv88e6185_g1_vtu_data_write(struct mv88e6xxx_chip *chip,
+				struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 regs[3] = { 0 };
+	int i;
+
+	/* Insert MemberTag and PortState data */
+	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
+		unsigned int member_offset = (i % 4) * 4;
+		unsigned int state_offset = member_offset + 2;
+
+		regs[i / 4] |= (entry->member[i] & 0x3) << member_offset;
+		regs[i / 4] |= (entry->state[i] & 0x3) << state_offset;
+	}
+
+	/* Write all 3 VTU/STU Data registers */
+	for (i = 0; i < 3; ++i) {
+		u16 reg = regs[i];
+		int err;
+
+		err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_DATA_0_3 + i, reg);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 /* VLAN Translation Unit Operations */
 
 int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
-- 
2.12.2
