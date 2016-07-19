From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 09/12] net: dsa: mv88e6xxx: add cap for IRL
Date: Mon, 18 Jul 2016 20:45:37 -0400
Message-ID: <20160719004540.1066-10-vivien.didelot@savoirfairelinux.com>
References: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add capability flags to describe the presence of Ingress Rate Limit unit
registers and an helper function to clear it.

In the meantime, fix a few harmless issues:

  - 6185 and 6095 don't have such registers (reserved)
  - the previous code didn't wait for the IRL operation to complete

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 50 ++++++++++++++++++++++-------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 23 ++++++++++++++--
 2 files changed, 53 insertions(+), 20 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 3422792..bc26b4f 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3150,6 +3150,29 @@ static int mv88e6xxx_g2_clear_trunk(struct mv88e6xxx_chip *chip)
 	return 0;
 }
 
+static int mv88e6xxx_g2_clear_irl(struct mv88e6xxx_chip *chip)
+{
+	int port, err;
+
+	/* Init all Ingress Rate Limit resources of all ports */
+	for (port = 0; port < chip->info->num_ports; ++port) {
+		/* XXX newer chips (like 88E6390) have different 2-bit ops */
+		err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_IRL_CMD,
+				      GLOBAL2_IRL_CMD_OP_INIT_ALL |
+				      (port << 8));
+		if (err)
+			break;
+
+		/* Wait for the operation to complete */
+		err = _mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_IRL_CMD,
+				      GLOBAL2_IRL_CMD_BUSY);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
 /* Indirect write to the Switch MAC/WoL/WoF register */
 static int mv88e6xxx_g2_switch_mac_write(struct mv88e6xxx_chip *chip,
 					 unsigned int pointer, u8 data)
@@ -3198,7 +3221,6 @@ static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 {
 	u16 reg;
 	int err;
-	int i;
 
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_2X)) {
 		/* Consider the frames with reserved multicast destination
@@ -3243,6 +3265,15 @@ static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_IRL)) {
+		/* Disable ingress rate limiting by resetting all per port
+		 * ingress rate limit resources to their initial state.
+		 */
+		err = mv88e6xxx_g2_clear_irl(chip);
+			if (err)
+				return err;
+	}
+
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_PVT)) {
 		/* Initialize Cross-chip Port VLAN Table to reset defaults */
 		err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_PVT_ADDR,
@@ -3258,23 +3289,6 @@ static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 			return err;
 	}
 
-	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
-	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
-	    mv88e6xxx_6185_family(chip) || mv88e6xxx_6095_family(chip) ||
-	    mv88e6xxx_6320_family(chip)) {
-		/* Disable ingress rate limiting by resetting all
-		 * ingress rate limit registers to their initial
-		 * state.
-		 */
-		for (i = 0; i < chip->info->num_ports; i++) {
-			err = _mv88e6xxx_reg_write(chip, REG_GLOBAL2,
-						   GLOBAL2_INGRESS_OP,
-						   0x9000 | (i << 8));
-			if (err)
-				return err;
-		}
-	}
-
 	return 0;
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 06b11fb..9ea5363 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -298,8 +298,13 @@
 #define GLOBAL2_TRUNK_MAPPING	0x08
 #define GLOBAL2_TRUNK_MAPPING_UPDATE		BIT(15)
 #define GLOBAL2_TRUNK_MAPPING_ID_SHIFT		11
-#define GLOBAL2_INGRESS_OP	0x09
-#define GLOBAL2_INGRESS_DATA	0x0a
+#define GLOBAL2_IRL_CMD		0x09
+#define GLOBAL2_IRL_CMD_BUSY	BIT(15)
+#define GLOBAL2_IRL_CMD_OP_INIT_ALL	((0x001 << 12) | GLOBAL2_IRL_CMD_BUSY)
+#define GLOBAL2_IRL_CMD_OP_INIT_SEL	((0x010 << 12) | GLOBAL2_IRL_CMD_BUSY)
+#define GLOBAL2_IRL_CMD_OP_WRITE_SEL	((0x011 << 12) | GLOBAL2_IRL_CMD_BUSY)
+#define GLOBAL2_IRL_CMD_OP_READ_SEL	((0x100 << 12) | GLOBAL2_IRL_CMD_BUSY)
+#define GLOBAL2_IRL_DATA	0x0a
 #define GLOBAL2_PVT_ADDR	0x0b
 #define GLOBAL2_PVT_ADDR_BUSY	BIT(15)
 #define GLOBAL2_PVT_ADDR_OP_INIT_ONES	((0x01 << 12) | GLOBAL2_PVT_ADDR_BUSY)
@@ -393,6 +398,8 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_GLOBAL2,
 	MV88E6XXX_CAP_G2_MGMT_EN_2X,	/* (0x02) MGMT Enable Register 2x */
 	MV88E6XXX_CAP_G2_MGMT_EN_0X,	/* (0x03) MGMT Enable Register 0x */
+	MV88E6XXX_CAP_G2_IRL_CMD,	/* (0x09) Ingress Rate Command */
+	MV88E6XXX_CAP_G2_IRL_DATA,	/* (0x0a) Ingress Rate Data */
 	MV88E6XXX_CAP_G2_PVT_ADDR,	/* (0x0b) Cross Chip Port VLAN Addr */
 	MV88E6XXX_CAP_G2_PVT_DATA,	/* (0x0c) Cross Chip Port VLAN Data */
 	MV88E6XXX_CAP_G2_SWITCH_MAC,	/* (0x0d) Switch MAC/WoL/WoF */
@@ -440,6 +447,8 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_GLOBAL2		BIT(MV88E6XXX_CAP_GLOBAL2)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_2X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_2X)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_0X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_0X)
+#define MV88E6XXX_FLAG_G2_IRL_CMD	BIT(MV88E6XXX_CAP_G2_IRL_CMD)
+#define MV88E6XXX_FLAG_G2_IRL_DATA	BIT(MV88E6XXX_CAP_G2_IRL_DATA)
 #define MV88E6XXX_FLAG_G2_PVT_ADDR	BIT(MV88E6XXX_CAP_G2_PVT_ADDR)
 #define MV88E6XXX_FLAG_G2_PVT_DATA	BIT(MV88E6XXX_CAP_G2_PVT_DATA)
 #define MV88E6XXX_FLAG_G2_SWITCH_MAC	BIT(MV88E6XXX_CAP_G2_SWITCH_MAC)
@@ -453,6 +462,11 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_TEMP_LIMIT	BIT(MV88E6XXX_CAP_TEMP_LIMIT)
 #define MV88E6XXX_FLAG_VTU		BIT(MV88E6XXX_CAP_VTU)
 
+/* Ingress Rate Limit unit */
+#define MV88E6XXX_FLAGS_IRL		\
+	(MV88E6XXX_FLAG_G2_IRL_CMD |	\
+	 MV88E6XXX_FLAG_G2_IRL_DATA)
+
 /* Cross-chip Port VLAN Table */
 #define MV88E6XXX_FLAGS_PVT		\
 	(MV88E6XXX_FLAG_G2_PVT_ADDR |	\
@@ -474,6 +488,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_VTU |		\
+	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
@@ -486,6 +501,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_VTU |		\
+	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
@@ -509,6 +525,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
 	 MV88E6XXX_FLAG_VTU |		\
+	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
@@ -523,6 +540,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_VTU |		\
+	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
@@ -540,6 +558,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
 	 MV88E6XXX_FLAG_VTU |		\
+	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_PVT)
 
 struct mv88e6xxx_info {
-- 
2.9.0
