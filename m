From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 18/18] net: dsa: mv88e6xxx: add VTU support for 88E6390
Date: Mon,  1 May 2017 14:05:27 -0400
Message-ID: <20170501180527.11756-19-vivien.didelot@savoirfairelinux.com>
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

The 6390 family of chips use only 2 of the 3 VTU Data registers to pack
the MemberTag and PortState VLAN data. This means that they must be
written or read before or after each VTU/STU operations.

Implement this variant to add support for VTU with such chips. These
chips have a 13th bit for the VID thus set their max_vid to 8191.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c        |  18 +++++
 drivers/net/dsa/mv88e6xxx/global1.h     |   4 ++
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 124 ++++++++++++++++++++++++++++++++
 3 files changed, 146 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index aede0194e341..19581d783d8e 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2998,6 +2998,8 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6390_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
@@ -3028,6 +3030,8 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6390_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
@@ -3058,6 +3062,8 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6390_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
@@ -3122,6 +3128,8 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6390_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3344,6 +3352,8 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6390_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3376,6 +3386,8 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.watchdog_ops = &mv88e6390_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6390_g1_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
+	.vtu_getnext = mv88e6390_g1_vtu_getnext,
+	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
@@ -3615,6 +3627,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6190",
 		.num_databases = 4096,
 		.num_ports = 11,	/* 10 + Z80 */
+		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
@@ -3632,6 +3645,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6190X",
 		.num_databases = 4096,
 		.num_ports = 11,	/* 10 + Z80 */
+		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
@@ -3649,6 +3663,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6191",
 		.num_databases = 4096,
 		.num_ports = 11,	/* 10 + Z80 */
+		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
@@ -3684,6 +3699,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6290",
 		.num_databases = 4096,
 		.num_ports = 11,	/* 10 + Z80 */
+		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
@@ -3806,6 +3822,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6390",
 		.num_databases = 4096,
 		.num_ports = 11,	/* 10 + Z80 */
+		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
@@ -3822,6 +3839,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6390X",
 		.num_databases = 4096,
 		.num_ports = 11,	/* 10 + Z80 */
+		.max_vid = 8191,
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 3750,
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 82e9812b8ba7..46a4ea0f8c47 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -58,6 +58,10 @@ int mv88e6352_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
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
index 8e77974fb2f8..9aea22d4c9e2 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -179,6 +179,56 @@ static int mv88e6185_g1_vtu_data_write(struct mv88e6xxx_chip *chip,
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
 
 static int mv88e6xxx_g1_vtu_stu_getnext(struct mv88e6xxx_chip *chip,
@@ -309,6 +359,38 @@ int mv88e6352_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
 	return 0;
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
+	if (entry->valid) {
+		err = mv88e6390_g1_vtu_data_read(chip, entry->member);
+		if (err)
+			return err;
+
+		/* Fetch VLAN PortState data from the STU */
+		err = mv88e6xxx_g1_vtu_stu_get(chip, entry);
+		if (err)
+			return err;
+
+		err = mv88e6390_g1_vtu_data_read(chip, entry->state);
+		if (err)
+			return err;
+
+		err = mv88e6xxx_g1_vtu_fid_read(chip, entry);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 int mv88e6185_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 			       struct mv88e6xxx_vtu_entry *entry)
 {
@@ -375,6 +457,48 @@ int mv88e6352_g1_vtu_loadpurge(struct mv88e6xxx_chip *chip,
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
+		err = mv88e6390_g1_vtu_data_write(chip, entry->member);
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
2.12.2
