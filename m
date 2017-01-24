From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net-next v6 2/4] net: dsa: mv88e6xxx: Add support for ethernet switch 88E6341
Date: Tue, 24 Jan 2017 21:10:24 +0100
Message-ID: <bb6e3987ee942277e99c78d1f28112d8b4ecb744.1485288602.git-series.gregory.clement@free-electrons.com>
References: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>,
        Jon Pannell <jpannell@marvell.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
In-Reply-To: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
References: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Marvell 88E6341 device is single-chip, 6-port Ethernet switch with
four integrated 10/100/1000Mbps Ethernet transceivers and one high speed
SerDes interfaces. It is partially compatible with switches of family
88E6352 and switches of family 88E6390.

This commit adds an initial support for this switch by describing its
capabilities to the driver and introducing a new family.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 54 ++++++++++++++++++++++++++--
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 19 +++++++++-
 2 files changed, 69 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 7d942f8a42a7..00db33ca1696 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -664,6 +664,11 @@ static bool mv88e6xxx_6320_family(struct mv88e6xxx_chip *chip)
 	return chip->info->family == MV88E6XXX_FAMILY_6320;
 }
 
+static bool mv88e6xxx_6341_family(struct mv88e6xxx_chip *chip)
+{
+	return chip->info->family == MV88E6XXX_FAMILY_6341;
+}
+
 static bool mv88e6xxx_6351_family(struct mv88e6xxx_chip *chip)
 {
 	return chip->info->family == MV88E6XXX_FAMILY_6351;
@@ -1688,7 +1693,8 @@ static int _mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
 			: GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
 
 	if (mv88e6xxx_6097_family(chip) || mv88e6xxx_6165_family(chip) ||
-	    mv88e6xxx_6351_family(chip) || mv88e6xxx_6352_family(chip)) {
+	    mv88e6xxx_6351_family(chip) || mv88e6xxx_6352_family(chip) ||
+	    mv88e6xxx_6341_family(chip)) {
 		struct mv88e6xxx_vtu_entry vstp;
 
 		/* Adding a VTU entry requires a valid STU entry. As VSTP is not
@@ -2543,7 +2549,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
 	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
 	    mv88e6xxx_6095_family(chip) || mv88e6xxx_6320_family(chip) ||
-	    mv88e6xxx_6185_family(chip))
+	    mv88e6xxx_6185_family(chip) || mv88e6xxx_6341_family(chip))
 		reg = PORT_CONTROL_2_MAP_DA;
 
 	if (mv88e6xxx_6095_family(chip) || mv88e6xxx_6185_family(chip)) {
@@ -2597,7 +2603,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 
 	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
 	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
-	    mv88e6xxx_6320_family(chip)) {
+	    mv88e6xxx_6320_family(chip) || mv88e6xxx_6341_family(chip)) {
 		/* Port ATU control: disable limiting the number of
 		 * address database entries that this port is allowed
 		 * to use.
@@ -3566,6 +3572,34 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.reset = mv88e6352_g1_reset,
 };
 
+static const struct mv88e6xxx_ops mv88e6341_ops = {
+	/* MV88E6XXX_FAMILY_6341 */
+	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
+	.port_set_speed = mv88e6390_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
+	.stats_snapshot = mv88e6390_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
+	.stats_get_strings = mv88e6320_stats_get_strings,
+	.stats_get_stats = mv88e6390_stats_get_stats,
+	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
+	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
+};
+
 static const struct mv88e6xxx_ops mv88e6390_ops = {
 	/* MV88E6XXX_FAMILY_6390 */
 	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
@@ -3953,6 +3987,20 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.ops = &mv88e6321_ops,
 	},
 
+	[MV88E6341] = {
+		.prod_num = PORT_SWITCH_ID_PROD_NUM_6341,
+		.family = MV88E6XXX_FAMILY_6341,
+		.name = "Marvell 88E6341",
+		.num_databases = 4096,
+		.num_ports = 6,
+		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
+		.age_time_coeff = 15000,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6341,
+		.ops = &mv88e6341_ops,
+	},
+
 	[MV88E6350] = {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6350,
 		.family = MV88E6XXX_FAMILY_6351,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index ce8b43b14e96..e0527db0ef6e 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -100,6 +100,7 @@
 #define PORT_SWITCH_ID_PROD_NUM_6240	0x240
 #define PORT_SWITCH_ID_PROD_NUM_6290	0x290
 #define PORT_SWITCH_ID_PROD_NUM_6321	0x310
+#define PORT_SWITCH_ID_PROD_NUM_6341	0x341
 #define PORT_SWITCH_ID_PROD_NUM_6352	0x352
 #define PORT_SWITCH_ID_PROD_NUM_6350	0x371
 #define PORT_SWITCH_ID_PROD_NUM_6351	0x375
@@ -382,7 +383,7 @@
 #define GLOBAL2_EEPROM_CMD_WRITE_EN	BIT(10)
 #define GLOBAL2_EEPROM_CMD_ADDR_MASK	0xff
 #define GLOBAL2_EEPROM_DATA	0x15
-#define GLOBAL2_EEPROM_ADDR	0x15 /* 6390 */
+#define GLOBAL2_EEPROM_ADDR	0x15 /* 6390, 6341 */
 #define GLOBAL2_PTP_AVB_OP	0x16
 #define GLOBAL2_PTP_AVB_DATA	0x17
 #define GLOBAL2_SMI_PHY_CMD			0x18
@@ -433,6 +434,7 @@ enum mv88e6xxx_model {
 	MV88E6290,
 	MV88E6320,
 	MV88E6321,
+	MV88E6341,
 	MV88E6350,
 	MV88E6351,
 	MV88E6352,
@@ -448,6 +450,7 @@ enum mv88e6xxx_family {
 	MV88E6XXX_FAMILY_6165,	/* 6123 6161 6165 */
 	MV88E6XXX_FAMILY_6185,	/* 6108 6121 6122 6131 6152 6155 6182 6185 */
 	MV88E6XXX_FAMILY_6320,	/* 6320 6321 */
+	MV88E6XXX_FAMILY_6341,	/* 6141 6341 */
 	MV88E6XXX_FAMILY_6351,	/* 6171 6175 6350 6351 */
 	MV88E6XXX_FAMILY_6352,	/* 6172 6176 6240 6352 */
 	MV88E6XXX_FAMILY_6390,  /* 6190 6190X 6191 6290 6390 6390X */
@@ -601,6 +604,20 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_PVT)
 
+#define MV88E6XXX_FLAGS_FAMILY_6341	\
+	(MV88E6XXX_FLAG_EEE |		\
+	 MV88E6XXX_FLAG_G1_ATU_FID |	\
+	 MV88E6XXX_FLAG_G1_VTU_FID |	\
+	 MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_G2_INT |	\
+	 MV88E6XXX_FLAG_G2_POT |	\
+	 MV88E6XXX_FLAG_STU |		\
+	 MV88E6XXX_FLAG_VTU |		\
+	 MV88E6XXX_FLAGS_IRL |		\
+	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
+	 MV88E6XXX_FLAGS_PVT |		\
+	 MV88E6XXX_FLAGS_SERDES)
+
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
 	(MV88E6XXX_FLAG_G1_ATU_FID |	\
 	 MV88E6XXX_FLAG_G1_VTU_FID |	\
-- 
git-series 0.9.1
