From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 01/10] net: dsa: mv88e6xxx: add irl_init_all op
Date: Sat, 17 Jun 2017 23:06:32 -0400
Message-ID: <20170618030641.32463-2-vivien.didelot@savoirfairelinux.com>
References: <20170618030641.32463-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170618030641.32463-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some Marvell chips have an Ingress Rate Limit unit. But the command
values slightly differs between models: 88E6352 use 3-bit for operations
while 88E6390 use different 2-bit operations.

This commit kills the IRL flags in favor of a new operation implementing
the "Init all resources to the initial state" operation.

This fixes the operation of 88E6390 family where 0x1000 means Read the
selected resource 0, register 0 on port 16, instead of init all.

A mv88e6xxx_irl_setup helper is added to wrap the operation call.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c    | 47 +++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/chip.h    | 19 +++-----------
 drivers/net/dsa/mv88e6xxx/global2.c | 52 ++++++++++++++++++-------------------
 drivers/net/dsa/mv88e6xxx/global2.h | 44 ++++++++++++++++++++++++++-----
 4 files changed, 113 insertions(+), 49 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 19772e3dd67e..53b088166c28 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -941,6 +941,26 @@ static int mv88e6xxx_atu_setup(struct mv88e6xxx_chip *chip)
 	return mv88e6xxx_g1_atu_set_age_time(chip, 300000);
 }
 
+static int mv88e6xxx_irl_setup(struct mv88e6xxx_chip *chip)
+{
+	int port;
+	int err;
+
+	if (!chip->info->ops->irl_init_all)
+		return 0;
+
+	for (port = 0; port < mv88e6xxx_num_ports(chip); port++) {
+		/* Disable ingress rate limiting by resetting all per port
+		 * ingress rate limit resources to their initial state.
+		 */
+		err = chip->info->ops->irl_init_all(chip, port);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int mv88e6xxx_pvt_map(struct mv88e6xxx_chip *chip, int dev, int port)
 {
 	u16 pvlan = 0;
@@ -2102,6 +2122,10 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 			goto unlock;
 	}
 
+	err = mv88e6xxx_irl_setup(chip);
+	if (err)
+		goto unlock;
+
 	err = mv88e6xxx_phy_setup(chip);
 	if (err)
 		goto unlock;
@@ -2339,6 +2363,7 @@ static int mv88e6xxx_set_eeprom(struct dsa_switch *ds,
 
 static const struct mv88e6xxx_ops mv88e6085_ops = {
 	/* MV88E6XXX_FAMILY_6097 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6185_phy_ppu_read,
 	.phy_write = mv88e6185_phy_ppu_write,
@@ -2393,6 +2418,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 
 static const struct mv88e6xxx_ops mv88e6097_ops = {
 	/* MV88E6XXX_FAMILY_6097 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -2423,6 +2449,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
 	/* MV88E6XXX_FAMILY_6165 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -2479,6 +2506,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 
 static const struct mv88e6xxx_ops mv88e6141_ops = {
 	/* MV88E6XXX_FAMILY_6341 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -2512,6 +2540,7 @@ static const struct mv88e6xxx_ops mv88e6141_ops = {
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
 	/* MV88E6XXX_FAMILY_6165 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -2542,6 +2571,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
 	/* MV88E6XXX_FAMILY_6165 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6165_phy_read,
 	.phy_write = mv88e6165_phy_write,
@@ -2565,6 +2595,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
 	/* MV88E6XXX_FAMILY_6351 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -2596,6 +2627,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
 	/* MV88E6XXX_FAMILY_6352 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -2630,6 +2662,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
 	/* MV88E6XXX_FAMILY_6351 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -2661,6 +2694,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
 	/* MV88E6XXX_FAMILY_6352 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -2722,6 +2756,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 
 static const struct mv88e6xxx_ops mv88e6190_ops = {
 	/* MV88E6XXX_FAMILY_6390 */
+	.irl_init_all = mv88e6390_g2_irl_init_all,
 	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -2755,6 +2790,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
 	/* MV88E6XXX_FAMILY_6390 */
+	.irl_init_all = mv88e6390_g2_irl_init_all,
 	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -2788,6 +2824,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
 	/* MV88E6XXX_FAMILY_6390 */
+	.irl_init_all = mv88e6390_g2_irl_init_all,
 	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -2821,6 +2858,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
 	/* MV88E6XXX_FAMILY_6352 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -2855,6 +2893,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
 	/* MV88E6XXX_FAMILY_6390 */
+	.irl_init_all = mv88e6390_g2_irl_init_all,
 	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -2889,6 +2928,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
 	/* MV88E6XXX_FAMILY_6320 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -2920,6 +2960,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
 	/* MV88E6XXX_FAMILY_6321 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -2950,6 +2991,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 
 static const struct mv88e6xxx_ops mv88e6341_ops = {
 	/* MV88E6XXX_FAMILY_6341 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -2983,6 +3025,7 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
 	/* MV88E6XXX_FAMILY_6351 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3014,6 +3057,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
 	/* MV88E6XXX_FAMILY_6351 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3045,6 +3089,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
 	/* MV88E6XXX_FAMILY_6352 */
+	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3079,6 +3124,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
 	/* MV88E6XXX_FAMILY_6390 */
+	.irl_init_all = mv88e6390_g2_irl_init_all,
 	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3115,6 +3161,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	/* MV88E6XXX_FAMILY_6390 */
+	.irl_init_all = mv88e6390_g2_irl_init_all,
 	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 409452ebc4b9..086444016352 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -121,8 +121,6 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_G2_INT,		/* (0x00) Interrupt Status */
 	MV88E6XXX_CAP_G2_MGMT_EN_2X,	/* (0x02) MGMT Enable Register 2x */
 	MV88E6XXX_CAP_G2_MGMT_EN_0X,	/* (0x03) MGMT Enable Register 0x */
-	MV88E6XXX_CAP_G2_IRL_CMD,	/* (0x09) Ingress Rate Command */
-	MV88E6XXX_CAP_G2_IRL_DATA,	/* (0x0a) Ingress Rate Data */
 	MV88E6XXX_CAP_G2_POT,		/* (0x0f) Priority Override Table */
 
 	/* Per VLAN Spanning Tree Unit (STU).
@@ -149,15 +147,8 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_G2_INT		BIT_ULL(MV88E6XXX_CAP_G2_INT)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_2X	BIT_ULL(MV88E6XXX_CAP_G2_MGMT_EN_2X)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_0X	BIT_ULL(MV88E6XXX_CAP_G2_MGMT_EN_0X)
-#define MV88E6XXX_FLAG_G2_IRL_CMD	BIT_ULL(MV88E6XXX_CAP_G2_IRL_CMD)
-#define MV88E6XXX_FLAG_G2_IRL_DATA	BIT_ULL(MV88E6XXX_CAP_G2_IRL_DATA)
 #define MV88E6XXX_FLAG_G2_POT		BIT_ULL(MV88E6XXX_CAP_G2_POT)
 
-/* Ingress Rate Limit unit */
-#define MV88E6XXX_FLAGS_IRL		\
-	(MV88E6XXX_FLAG_G2_IRL_CMD |	\
-	 MV88E6XXX_FLAG_G2_IRL_DATA)
-
 /* Multi-chip Addressing Mode */
 #define MV88E6XXX_FLAGS_MULTI_CHIP	\
 	(MV88E6XXX_FLAG_SMI_CMD |	\
@@ -175,7 +166,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
@@ -185,7 +175,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
@@ -200,7 +189,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6341	\
@@ -209,7 +197,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
@@ -219,7 +206,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
@@ -230,14 +216,12 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6390	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |        \
-	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 struct mv88e6xxx_ops;
@@ -358,6 +342,9 @@ struct mv88e6xxx_mdio_bus {
 };
 
 struct mv88e6xxx_ops {
+	/* Ingress Rate Limit unit (IRL) operations */
+	int (*irl_init_all)(struct mv88e6xxx_chip *chip, int port);
+
 	int (*get_eeprom)(struct mv88e6xxx_chip *chip,
 			  struct ethtool_eeprom *eeprom, u8 *data);
 	int (*set_eeprom)(struct mv88e6xxx_chip *chip,
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 8e8bc4ee464f..baa86b1abad3 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -149,27 +149,36 @@ static int mv88e6xxx_g2_clear_trunk(struct mv88e6xxx_chip *chip)
  * Offset 0x0A: Ingress Rate Data register
  */
 
-static int mv88e6xxx_g2_clear_irl(struct mv88e6xxx_chip *chip)
+static int mv88e6xxx_g2_irl_wait(struct mv88e6xxx_chip *chip)
 {
-	int port, err;
+	return mv88e6xxx_g2_wait(chip, MV88E6XXX_G2_IRL_CMD,
+				 MV88E6XXX_G2_IRL_CMD_BUSY);
+}
 
-	/* Init all Ingress Rate Limit resources of all ports */
-	for (port = 0; port < mv88e6xxx_num_ports(chip); ++port) {
-		/* XXX newer chips (like 88E6390) have different 2-bit ops */
-		err = mv88e6xxx_g2_write(chip, GLOBAL2_IRL_CMD,
-					 GLOBAL2_IRL_CMD_OP_INIT_ALL |
-					 (port << 8));
-		if (err)
-			break;
+static int mv88e6xxx_g2_irl_op(struct mv88e6xxx_chip *chip, u16 op, int port,
+			       int res, int reg)
+{
+	int err;
+
+	err = mv88e6xxx_g2_write(chip, MV88E6XXX_G2_IRL_CMD,
+				 MV88E6XXX_G2_IRL_CMD_BUSY | op | (port << 8) |
+				 (res << 5) | reg);
+	if (err)
+		return err;
 
-		/* Wait for the operation to complete */
-		err = mv88e6xxx_g2_wait(chip, GLOBAL2_IRL_CMD,
-					GLOBAL2_IRL_CMD_BUSY);
-		if (err)
-			break;
-	}
+	return mv88e6xxx_g2_irl_wait(chip);
+}
 
-	return err;
+int mv88e6352_g2_irl_init_all(struct mv88e6xxx_chip *chip, int port)
+{
+	return mv88e6xxx_g2_irl_op(chip, MV88E6352_G2_IRL_CMD_OP_INIT_ALL, port,
+				   0, 0);
+}
+
+int mv88e6390_g2_irl_init_all(struct mv88e6xxx_chip *chip, int port)
+{
+	return mv88e6xxx_g2_irl_op(chip, MV88E6390_G2_IRL_CMD_OP_INIT_ALL, port,
+				   0, 0);
 }
 
 /* Offset 0x0B: Cross-chip Port VLAN (Addr) Register
@@ -1030,15 +1039,6 @@ int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_IRL)) {
-		/* Disable ingress rate limiting by resetting all per port
-		 * ingress rate limit resources to their initial state.
-		 */
-		err = mv88e6xxx_g2_clear_irl(chip);
-			if (err)
-				return err;
-	}
-
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_POT)) {
 		/* Clear the priority override table. */
 		err = mv88e6xxx_g2_clear_pot(chip);
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 479d42971706..fb1871d4569c 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -42,13 +42,30 @@
 #define GLOBAL2_TRUNK_MAPPING	0x08
 #define GLOBAL2_TRUNK_MAPPING_UPDATE		BIT(15)
 #define GLOBAL2_TRUNK_MAPPING_ID_SHIFT		11
-#define GLOBAL2_IRL_CMD		0x09
-#define GLOBAL2_IRL_CMD_BUSY	BIT(15)
-#define GLOBAL2_IRL_CMD_OP_INIT_ALL	((0x001 << 12) | GLOBAL2_IRL_CMD_BUSY)
-#define GLOBAL2_IRL_CMD_OP_INIT_SEL	((0x010 << 12) | GLOBAL2_IRL_CMD_BUSY)
-#define GLOBAL2_IRL_CMD_OP_WRITE_SEL	((0x011 << 12) | GLOBAL2_IRL_CMD_BUSY)
-#define GLOBAL2_IRL_CMD_OP_READ_SEL	((0x100 << 12) | GLOBAL2_IRL_CMD_BUSY)
-#define GLOBAL2_IRL_DATA	0x0a
+
+/* Offset 0x09: Ingress Rate Command Register */
+#define MV88E6XXX_G2_IRL_CMD			0x09
+#define MV88E6XXX_G2_IRL_CMD_BUSY		0x8000
+#define MV88E6352_G2_IRL_CMD_OP_MASK		0x7000
+#define MV88E6352_G2_IRL_CMD_OP_NOOP		0x0000
+#define MV88E6352_G2_IRL_CMD_OP_INIT_ALL	0x1000
+#define MV88E6352_G2_IRL_CMD_OP_INIT_RES	0x2000
+#define MV88E6352_G2_IRL_CMD_OP_WRITE_REG	0x3000
+#define MV88E6352_G2_IRL_CMD_OP_READ_REG	0x4000
+#define MV88E6390_G2_IRL_CMD_OP_MASK		0x6000
+#define MV88E6390_G2_IRL_CMD_OP_READ_REG	0x0000
+#define MV88E6390_G2_IRL_CMD_OP_INIT_ALL	0x2000
+#define MV88E6390_G2_IRL_CMD_OP_INIT_RES	0x4000
+#define MV88E6390_G2_IRL_CMD_OP_WRITE_REG	0x6000
+#define MV88E6352_G2_IRL_CMD_PORT_MASK		0x0f00
+#define MV88E6390_G2_IRL_CMD_PORT_MASK		0x1f00
+#define MV88E6XXX_G2_IRL_CMD_RES_MASK		0x00e0
+#define MV88E6XXX_G2_IRL_CMD_REG_MASK		0x000f
+
+/* Offset 0x0A: Ingress Rate Data Register */
+#define MV88E6XXX_G2_IRL_DATA		0x0a
+#define MV88E6XXX_G2_IRL_DATA_MASK	0xffff
+
 #define GLOBAL2_PVT_ADDR	0x0b
 #define GLOBAL2_PVT_ADDR_BUSY	BIT(15)
 #define GLOBAL2_PVT_ADDR_OP_INIT_ONES	((0x01 << 12) | GLOBAL2_PVT_ADDR_BUSY)
@@ -127,6 +144,9 @@ static inline int mv88e6xxx_g2_require(struct mv88e6xxx_chip *chip)
 	return 0;
 }
 
+int mv88e6352_g2_irl_init_all(struct mv88e6xxx_chip *chip, int port);
+int mv88e6390_g2_irl_init_all(struct mv88e6xxx_chip *chip, int port);
+
 int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip,
 			      struct mii_bus *bus,
 			      int addr, int reg, u16 *val);
@@ -169,6 +189,16 @@ static inline int mv88e6xxx_g2_require(struct mv88e6xxx_chip *chip)
 	return 0;
 }
 
+int mv88e6352_g2_irl_init_all(struct mv88e6xxx_chip *chip, int port)
+{
+	return -EOPNOTSUPP;
+}
+
+int mv88e6390_g2_irl_init_all(struct mv88e6xxx_chip *chip, int port)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip,
 					    struct mii_bus *bus,
 					    int addr, int reg, u16 *val)
-- 
2.13.1
