From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next v2 08/12] net: dsa: mv88e6xxx: add cap for Priority Override
Date: Mon, 18 Jul 2016 14:46:24 -0400
Message-ID: <20160718184628.13103-9-vivien.didelot@savoirfairelinux.com>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add flags and helpers to describe the presence of Priority Override
Table (POT) related registers and simplify the setup of Global 2.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 37 +++++++++++++++++++++++++----------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  7 +++++++
 2 files changed, 34 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 4e8bdc5..0864a78 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3176,6 +3176,29 @@ static int mv88e6xxx_g2_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
 	return err;
 }
 
+static int mv88e6xxx_g2_pot_write(struct mv88e6xxx_chip *chip, int pointer,
+				  u8 data)
+{
+	u16 val = (pointer << 8) | (data & 0x7);
+
+	return mv88e6xxx_update_write(chip, REG_GLOBAL2, GLOBAL2_PRIO_OVERRIDE,
+				      val);
+}
+
+static int mv88e6xxx_g2_clear_pot(struct mv88e6xxx_chip *chip)
+{
+	int i, err;
+
+	/* Clear all sixteen possible Priority Override entries */
+	for (i = 0; i < 16; i++) {
+		err = mv88e6xxx_g2_pot_write(chip, i, 0);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
 static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 {
 	u16 reg;
@@ -3233,17 +3256,11 @@ static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 			return err;
 	}
 
-	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
-	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
-	    mv88e6xxx_6320_family(chip)) {
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_POT)) {
 		/* Clear the priority override table. */
-		for (i = 0; i < 16; i++) {
-			err = _mv88e6xxx_reg_write(chip, REG_GLOBAL2,
-						   GLOBAL2_PRIO_OVERRIDE,
-						   0x8000 | (i << 8));
-			if (err)
-				return err;
-		}
+		err = mv88e6xxx_g2_clear_pot(chip);
+		if (err)
+			return err;
 	}
 
 	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 4e03650..06b11fb 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -396,6 +396,7 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_G2_PVT_ADDR,	/* (0x0b) Cross Chip Port VLAN Addr */
 	MV88E6XXX_CAP_G2_PVT_DATA,	/* (0x0c) Cross Chip Port VLAN Data */
 	MV88E6XXX_CAP_G2_SWITCH_MAC,	/* (0x0d) Switch MAC/WoL/WoF */
+	MV88E6XXX_CAP_G2_POT,		/* (0x0f) Priority Override Table */
 
 	/* Multi-chip Addressing Mode.
 	 * Some chips require an indirect SMI access when their SMI device
@@ -442,6 +443,7 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_G2_PVT_ADDR	BIT(MV88E6XXX_CAP_G2_PVT_ADDR)
 #define MV88E6XXX_FLAG_G2_PVT_DATA	BIT(MV88E6XXX_CAP_G2_PVT_DATA)
 #define MV88E6XXX_FLAG_G2_SWITCH_MAC	BIT(MV88E6XXX_CAP_G2_SWITCH_MAC)
+#define MV88E6XXX_FLAG_G2_POT		BIT(MV88E6XXX_CAP_G2_POT)
 #define MV88E6XXX_FLAG_MULTI_CHIP	BIT(MV88E6XXX_CAP_MULTI_CHIP)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_PPU_ACTIVE	BIT(MV88E6XXX_CAP_PPU_ACTIVE)
@@ -467,6 +469,7 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
+	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_STU |		\
@@ -478,6 +481,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
+	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
@@ -498,6 +502,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
+	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
@@ -511,6 +516,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
+	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
@@ -526,6 +532,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
+	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
-- 
2.9.0
