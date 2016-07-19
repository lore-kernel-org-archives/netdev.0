From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 07/12] net: dsa: mv88e6xxx: add cap for PVT
Date: Mon, 18 Jul 2016 20:45:35 -0400
Message-ID: <20160719004540.1066-8-vivien.didelot@savoirfairelinux.com>
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

Add flags to describe the presence of Cross-chip Port VLAN Table (PVT)
related registers and simplify the setup of Global 2.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 16 ++++++++--------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 28 +++++++++++++++++++++++-----
 2 files changed, 31 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index d1b4a7a..f346ad7 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3221,17 +3221,17 @@ static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
-	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
-	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
-	    mv88e6xxx_6320_family(chip)) {
-		/* Initialise cross-chip port VLAN table to reset
-		 * defaults.
-		 */
-		err = _mv88e6xxx_reg_write(chip, REG_GLOBAL2,
-					   GLOBAL2_PVT_ADDR, 0x9000);
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_PVT)) {
+		/* Initialize Cross-chip Port VLAN Table to reset defaults */
+		err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_PVT_ADDR,
+				      GLOBAL2_PVT_ADDR_OP_INIT_ONES);
 		if (err)
 			return err;
+	}
 
+	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
+	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
+	    mv88e6xxx_6320_family(chip)) {
 		/* Clear the priority override table. */
 		for (i = 0; i < 16; i++) {
 			err = _mv88e6xxx_reg_write(chip, REG_GLOBAL2,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index da61db4..4e03650 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -301,6 +301,10 @@
 #define GLOBAL2_INGRESS_OP	0x09
 #define GLOBAL2_INGRESS_DATA	0x0a
 #define GLOBAL2_PVT_ADDR	0x0b
+#define GLOBAL2_PVT_ADDR_BUSY	BIT(15)
+#define GLOBAL2_PVT_ADDR_OP_INIT_ONES	((0x01 << 12) | GLOBAL2_PVT_ADDR_BUSY)
+#define GLOBAL2_PVT_ADDR_OP_WRITE_PVLAN	((0x03 << 12) | GLOBAL2_PVT_ADDR_BUSY)
+#define GLOBAL2_PVT_ADDR_OP_READ	((0x04 << 12) | GLOBAL2_PVT_ADDR_BUSY)
 #define GLOBAL2_PVT_DATA	0x0c
 #define GLOBAL2_SWITCH_MAC	0x0d
 #define GLOBAL2_ATU_STATS	0x0e
@@ -389,6 +393,8 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_GLOBAL2,
 	MV88E6XXX_CAP_G2_MGMT_EN_2X,	/* (0x02) MGMT Enable Register 2x */
 	MV88E6XXX_CAP_G2_MGMT_EN_0X,	/* (0x03) MGMT Enable Register 0x */
+	MV88E6XXX_CAP_G2_PVT_ADDR,	/* (0x0b) Cross Chip Port VLAN Addr */
+	MV88E6XXX_CAP_G2_PVT_DATA,	/* (0x0c) Cross Chip Port VLAN Data */
 	MV88E6XXX_CAP_G2_SWITCH_MAC,	/* (0x0d) Switch MAC/WoL/WoF */
 
 	/* Multi-chip Addressing Mode.
@@ -433,6 +439,8 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_GLOBAL2		BIT(MV88E6XXX_CAP_GLOBAL2)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_2X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_2X)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_0X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_0X)
+#define MV88E6XXX_FLAG_G2_PVT_ADDR	BIT(MV88E6XXX_CAP_G2_PVT_ADDR)
+#define MV88E6XXX_FLAG_G2_PVT_DATA	BIT(MV88E6XXX_CAP_G2_PVT_DATA)
 #define MV88E6XXX_FLAG_G2_SWITCH_MAC	BIT(MV88E6XXX_CAP_G2_SWITCH_MAC)
 #define MV88E6XXX_FLAG_MULTI_CHIP	BIT(MV88E6XXX_CAP_MULTI_CHIP)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
@@ -443,6 +451,11 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_TEMP_LIMIT	BIT(MV88E6XXX_CAP_TEMP_LIMIT)
 #define MV88E6XXX_FLAG_VTU		BIT(MV88E6XXX_CAP_VTU)
 
+/* Cross-chip Port VLAN Table */
+#define MV88E6XXX_FLAGS_PVT		\
+	(MV88E6XXX_FLAG_G2_PVT_ADDR |	\
+	 MV88E6XXX_FLAG_G2_PVT_DATA)
+
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
@@ -457,7 +470,8 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_VTU)
+	 MV88E6XXX_FLAG_VTU |		\
+	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
@@ -467,7 +481,8 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
-	 MV88E6XXX_FLAG_VTU)
+	 MV88E6XXX_FLAG_VTU |		\
+	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
@@ -488,7 +503,8 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
-	 MV88E6XXX_FLAG_VTU)
+	 MV88E6XXX_FLAG_VTU |		\
+	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
@@ -500,7 +516,8 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
-	 MV88E6XXX_FLAG_VTU)
+	 MV88E6XXX_FLAG_VTU |		\
+	 MV88E6XXX_FLAGS_PVT)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
 	(MV88E6XXX_FLAG_EEE |		\
@@ -515,7 +532,8 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
-	 MV88E6XXX_FLAG_VTU)
+	 MV88E6XXX_FLAG_VTU |		\
+	 MV88E6XXX_FLAGS_PVT)
 
 struct mv88e6xxx_info {
 	enum mv88e6xxx_family family;
-- 
2.9.0
