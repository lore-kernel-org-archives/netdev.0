From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/6] net: dsa: mv88e6xxx: add support for 6390 VTU
Date: Thu, 16 Feb 2017 22:29:31 -0500
Message-ID: <20170217032931.15002-7-vivien.didelot@savoirfairelinux.com>
References: <20170217032931.15002-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170217032931.15002-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 6390 family of chips use only 2 of the 3 VTU Data registers to pack
the MemberTag and PortState VLAN data. This means that they must be
written or read before or after each VTU/STU operations.

Implement this variant to add support for VTU with such chips.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c        |  14 ++++
 drivers/net/dsa/mv88e6xxx/global1.h     |   4 ++
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 121 ++++++++++++++++++++++++++++++++
 3 files changed, 139 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 08a7b9d2ad14..a2fd2ee5c314 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2932,6 +2932,8 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6390_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
@@ -2960,6 +2962,8 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6390_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
@@ -2988,6 +2992,8 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6390_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3048,6 +3054,8 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6390_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3287,6 +3295,8 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6390_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3317,6 +3327,8 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6390_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6391_ops = {
@@ -3345,6 +3357,8 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6390_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 };
 
 static int mv88e6xxx_verify_madatory_ops(struct mv88e6xxx_chip *chip,
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 11213f50df07..d0305aebb36b 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -55,6 +55,10 @@ int mv88e6352_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
 			     struct mv88e6xxx_vtu_entry *entry);
 int mv88e6352_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 			       struct mv88e6xxx_vtu_entry *entry);
+int mv88e6390_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_vtu_entry *entry);
+int mv88e6390_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry);
 int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip);
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
index e1046a1b3c6d..bc791f373b5d 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -172,6 +172,56 @@ static int mv88e6185_g1_vtu_data_write(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
+static int mv88e6390_g1_vtu_data_read(struct mv88e6xxx_chip *chip, u8 *data)
+{
+	u16 regs[2];
+	int i;
+
+	/* Read the 2 VTU/STU Data registers */
+	for (i = 0; i < 2; ++i) {
+		u16 *reg = &regs[i];
+		int err;
+
+		err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_DATA_0_3 + i, reg);
+		if (err)
+			return err;
+	}
+
+	/* Extract data */
+	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
+		unsigned int offset = (i % 8) * 2;
+
+		data[i] = (regs[i / 8] >> offset) & 0x3;
+	}
+
+	return 0;
+}
+
+static int mv88e6390_g1_vtu_data_write(struct mv88e6xxx_chip *chip, u8 *data)
+{
+	u16 regs[2] = { 0 };
+	int i;
+
+	/* Insert data */
+	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
+		unsigned int offset = (i % 8) * 2;
+
+		regs[i / 8] |= (data[i] & 0x3) << offset;
+	}
+
+	/* Write the 2 VTU/STU Data registers */
+	for (i = 0; i < 2; ++i) {
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
 
 static int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
@@ -294,6 +344,35 @@ int mv88e6352_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_g1_vtu_fid_read(chip, entry);
 }
 
+int mv88e6390_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_vtu_entry *entry)
+{
+	int err;
+
+	/* Fetch VLAN MemberTag data from the VTU */
+	err = mv88e6xxx_g1_vtu_getnext(chip, entry);
+	if (err)
+		return err;
+
+	if (!entry->valid)
+		return 0;
+
+	err = mv88e6390_g1_vtu_data_read(chip, entry->member);
+	if (err)
+		return err;
+
+	/* Fetch VLAN PortState data from the STU */
+	err = mv88e6xxx_g1_vtu_fetch_stu(chip, entry);
+	if (err)
+		return err;
+
+	err = mv88e6390_g1_vtu_data_read(chip, entry->state);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g1_vtu_fid_read(chip, entry);
+}
+
 int mv88e6185_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 			       struct mv88e6xxx_vtu_entry *entry)
 {
@@ -360,6 +439,48 @@ int mv88e6352_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_VTU_LOAD_PURGE);
 }
 
+int mv88e6390_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry)
+{
+	int err;
+
+	err = mv88e6xxx_g1_vtu_op_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_vtu_vid_write(chip, entry);
+	if (err)
+		return err;
+
+	if (entry->valid) {
+		/* Write PortState data */
+		err = mv88e6390_g1_vtu_data_write(chip, entry->state);
+		if (err)
+			return err;
+
+		err = mv88e6xxx_g1_vtu_sid_write(chip, entry);
+		if (err)
+			return err;
+
+		/* Load STU entry */
+		err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
+		if (err)
+			return err;
+
+		/* Write MemberTag data */
+		err = mv88e6390_g1_vtu_data_write(chip, entry->state);
+		if (err)
+			return err;
+
+		err = mv88e6xxx_g1_vtu_fid_write(chip, entry);
+		if (err)
+			return err;
+	}
+
+	/* Load/Purge VTU entry */
+	return mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_VTU_LOAD_PURGE);
+}
+
 int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip)
 {
 	int err;
-- 
2.11.1
