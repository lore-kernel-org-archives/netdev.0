From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 06/12] net: dsa: mv88e6xxx: rework Switch MAC setter
Date: Mon, 18 Jul 2016 20:45:34 -0400
Message-ID: <20160719004540.1066-7-vivien.didelot@savoirfairelinux.com>
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

Switches such as 88E6185 as 3 Switch MAC registers in Global 1. Newer
chips such as 88E6352 have freed these registers in favor of an indirect
access in a Switch MAC/WoL/WoF register in Global 2.

Explicit this difference with G1 and G2 helpers and flags.

Also, note that this indirect access is a single-register which doesn't
require to wait for the operation to complete (like Switch MAC, Trunk
Mapping, etc.), in contrary to multi-registers indirect accesses with
several operations and a busy bit.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 120 ++++++++++++++++------------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  19 ++----
 2 files changed, 64 insertions(+), 75 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index cf98884..d1b4a7a 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -283,68 +283,6 @@ static int mv88e6xxx_reg_write(struct mv88e6xxx_chip *chip, int addr,
 	return ret;
 }
 
-static int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr)
-{
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-	int err;
-
-	err = mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_MAC_01,
-				  (addr[0] << 8) | addr[1]);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_MAC_23,
-				  (addr[2] << 8) | addr[3]);
-	if (err)
-		return err;
-
-	return mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_MAC_45,
-				   (addr[4] << 8) | addr[5]);
-}
-
-static int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
-{
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-	int ret;
-	int i;
-
-	for (i = 0; i < 6; i++) {
-		int j;
-
-		/* Write the MAC address byte. */
-		ret = mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_SWITCH_MAC,
-					  GLOBAL2_SWITCH_MAC_BUSY |
-					  (i << 8) | addr[i]);
-		if (ret)
-			return ret;
-
-		/* Wait for the write to complete. */
-		for (j = 0; j < 16; j++) {
-			ret = mv88e6xxx_reg_read(chip, REG_GLOBAL2,
-						 GLOBAL2_SWITCH_MAC);
-			if (ret < 0)
-				return ret;
-
-			if ((ret & GLOBAL2_SWITCH_MAC_BUSY) == 0)
-				break;
-		}
-		if (j == 16)
-			return -ETIMEDOUT;
-	}
-
-	return 0;
-}
-
-static int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
-{
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_SWITCH_MAC))
-		return mv88e6xxx_set_addr_indirect(ds, addr);
-	else
-		return mv88e6xxx_set_addr_direct(ds, addr);
-}
-
 static int mv88e6xxx_mdio_read_direct(struct mv88e6xxx_chip *chip,
 				      int addr, int regnum)
 {
@@ -3019,6 +2957,24 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	return 0;
 }
 
+static int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
+{
+	int err;
+
+	err = mv88e6xxx_write(chip, REG_GLOBAL, GLOBAL_MAC_01,
+			      (addr[0] << 8) | addr[1]);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_write(chip, REG_GLOBAL, GLOBAL_MAC_23,
+			      (addr[2] << 8) | addr[3]);
+	if (err)
+		return err;
+
+	return mv88e6xxx_write(chip, REG_GLOBAL, GLOBAL_MAC_45,
+			       (addr[4] << 8) | addr[5]);
+}
+
 static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 {
 	struct dsa_switch *ds = chip->ds;
@@ -3194,6 +3150,28 @@ static int mv88e6xxx_g2_clear_trunk(struct mv88e6xxx_chip *chip)
 	return 0;
 }
 
+/* Indirect write to the Switch MAC/WoL/WoF register */
+static int mv88e6xxx_g2_switch_mac_write(struct mv88e6xxx_chip *chip,
+					 unsigned int pointer, u8 data)
+{
+	u16 val = (pointer << 8) | data;
+
+	return mv88e6xxx_update(chip, REG_GLOBAL2, GLOBAL2_SWITCH_MAC, val);
+}
+
+static int mv88e6xxx_g2_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
+{
+	int i, err;
+
+	for (i = 0; i < 6; i++) {
+		err = mv88e6xxx_g2_switch_mac_write(chip, i, addr[i]);
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
@@ -3327,6 +3305,24 @@ unlock:
 	return err;
 }
 
+static int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
+{
+	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
+	int err;
+
+	mutex_lock(&chip->reg_lock);
+
+	/* Has an indirect Switch MAC/WoL/WoF register in Global 2? */
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_SWITCH_MAC))
+		err = mv88e6xxx_g2_set_switch_mac(chip, addr);
+	else
+		err = mv88e6xxx_g1_set_switch_mac(chip, addr);
+
+	mutex_unlock(&chip->reg_lock);
+
+	return err;
+}
+
 static int mv88e6xxx_mdio_page_read(struct dsa_switch *ds, int port, int page,
 				    int reg)
 {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index d13b0b5..da61db4 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -303,7 +303,6 @@
 #define GLOBAL2_PVT_ADDR	0x0b
 #define GLOBAL2_PVT_DATA	0x0c
 #define GLOBAL2_SWITCH_MAC	0x0d
-#define GLOBAL2_SWITCH_MAC_BUSY BIT(15)
 #define GLOBAL2_ATU_STATS	0x0e
 #define GLOBAL2_PRIO_OVERRIDE	0x0f
 #define GLOBAL2_PRIO_OVERRIDE_FORCE_SNOOP	BIT(7)
@@ -390,6 +389,7 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_GLOBAL2,
 	MV88E6XXX_CAP_G2_MGMT_EN_2X,	/* (0x02) MGMT Enable Register 2x */
 	MV88E6XXX_CAP_G2_MGMT_EN_0X,	/* (0x03) MGMT Enable Register 0x */
+	MV88E6XXX_CAP_G2_SWITCH_MAC,	/* (0x0d) Switch MAC/WoL/WoF */
 
 	/* Multi-chip Addressing Mode.
 	 * Some chips require an indirect SMI access when their SMI device
@@ -415,13 +415,6 @@ enum mv88e6xxx_cap {
 	 */
 	MV88E6XXX_CAP_STU,
 
-	/* Switch MAC/WoL/WoF register.
-	 * This requires an indirect access to set the switch MAC address
-	 * through GLOBAL2_SWITCH_MAC, otherwise GLOBAL_MAC_01, GLOBAL_MAC_23,
-	 * and GLOBAL_MAC_45 are used with a direct access.
-	 */
-	MV88E6XXX_CAP_SWITCH_MAC_WOL_WOF,
-
 	/* Internal temperature sensor.
 	 * Available from any enabled port's PHY register 26, page 6.
 	 */
@@ -440,12 +433,12 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_GLOBAL2		BIT(MV88E6XXX_CAP_GLOBAL2)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_2X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_2X)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_0X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_0X)
+#define MV88E6XXX_FLAG_G2_SWITCH_MAC	BIT(MV88E6XXX_CAP_G2_SWITCH_MAC)
 #define MV88E6XXX_FLAG_MULTI_CHIP	BIT(MV88E6XXX_CAP_MULTI_CHIP)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_PPU_ACTIVE	BIT(MV88E6XXX_CAP_PPU_ACTIVE)
 #define MV88E6XXX_FLAG_SMI_PHY		BIT(MV88E6XXX_CAP_SMI_PHY)
 #define MV88E6XXX_FLAG_STU		BIT(MV88E6XXX_CAP_STU)
-#define MV88E6XXX_FLAG_SWITCH_MAC	BIT(MV88E6XXX_CAP_SWITCH_MAC_WOL_WOF)
 #define MV88E6XXX_FLAG_TEMP		BIT(MV88E6XXX_CAP_TEMP)
 #define MV88E6XXX_FLAG_TEMP_LIMIT	BIT(MV88E6XXX_CAP_TEMP_LIMIT)
 #define MV88E6XXX_FLAG_VTU		BIT(MV88E6XXX_CAP_VTU)
@@ -470,9 +463,9 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
+	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_VTU)
 
@@ -489,10 +482,10 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
+	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
-	 MV88E6XXX_FLAG_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
 	 MV88E6XXX_FLAG_VTU)
@@ -501,11 +494,11 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
+	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_VTU)
 
@@ -515,11 +508,11 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
+	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
 	 MV88E6XXX_FLAG_VTU)
-- 
2.9.0
