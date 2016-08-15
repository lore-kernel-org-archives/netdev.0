From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/6] net: dsa: mv88e6xxx: rework Global2 SMI PHY access
Date: Mon, 15 Aug 2016 17:18:59 -0400
Message-ID: <20160815211902.2236-4-vivien.didelot@savoirfairelinux.com>
References: <20160815211902.2236-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160815211902.2236-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Describe the presence of the Global2 SMI PHY registers, used to
indirectly access the internal SMI devices registers on some chips.

Also temporarily forward declare mv88e6xxx_g2_smi_phy_{read,write} to
use them in mv88e6xxx_mdio_{read,write}_indirect, before getting rid of
the later.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 97 +++++++++++++++++++++++------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 49 +++++++++---------
 2 files changed, 90 insertions(+), 56 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 44debf2..924a2af 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -841,52 +841,34 @@ static void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 	mutex_unlock(&chip->reg_lock);
 }
 
-static int mv88e6xxx_mdio_wait(struct mv88e6xxx_chip *chip)
-{
-	return mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_SMI_OP,
-			      GLOBAL2_SMI_OP_BUSY);
-}
-
 static int _mv88e6xxx_atu_wait(struct mv88e6xxx_chip *chip)
 {
 	return mv88e6xxx_wait(chip, REG_GLOBAL, GLOBAL_ATU_OP,
 			      GLOBAL_ATU_OP_BUSY);
 }
 
+static int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr,
+				     int reg, u16 *val);
+static int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr,
+				      int reg, u16 val);
+
 static int mv88e6xxx_mdio_read_indirect(struct mv88e6xxx_chip *chip,
 					int addr, int regnum)
 {
-	int ret;
-
-	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_SMI_OP,
-				   GLOBAL2_SMI_OP_22_READ | (addr << 5) |
-				   regnum);
-	if (ret < 0)
-		return ret;
-
-	ret = mv88e6xxx_mdio_wait(chip);
-	if (ret < 0)
-		return ret;
+	u16 val;
+	int err;
 
-	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL2, GLOBAL2_SMI_DATA);
+	err = mv88e6xxx_g2_smi_phy_read(chip, addr, regnum, &val);
+	if (err)
+		return err;
 
-	return ret;
+	return val;
 }
 
 static int mv88e6xxx_mdio_write_indirect(struct mv88e6xxx_chip *chip,
 					 int addr, int regnum, u16 val)
 {
-	int ret;
-
-	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_SMI_DATA, val);
-	if (ret < 0)
-		return ret;
-
-	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL2, GLOBAL2_SMI_OP,
-				   GLOBAL2_SMI_OP_22_WRITE | (addr << 5) |
-				   regnum);
-
-	return mv88e6xxx_mdio_wait(chip);
+	return mv88e6xxx_g2_smi_phy_write(chip, addr, regnum, val);
 }
 
 static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
@@ -3057,6 +3039,57 @@ static int mv88e6xxx_g2_eeprom_write16(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_g2_eeprom_cmd(chip, cmd);
 }
 
+static int mv88e6xxx_g2_smi_phy_wait(struct mv88e6xxx_chip *chip)
+{
+	return mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_SMI_PHY_CMD,
+			      GLOBAL2_SMI_PHY_CMD_BUSY);
+}
+
+static int mv88e6xxx_g2_smi_phy_cmd(struct mv88e6xxx_chip *chip, u16 cmd)
+{
+	int err;
+
+	err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_SMI_PHY_CMD, cmd);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g2_smi_phy_wait(chip);
+}
+
+static int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr,
+				     int reg, u16 *val)
+{
+	u16 cmd = GLOBAL2_SMI_PHY_CMD_OP_22_READ_DATA | (addr << 5) | reg;
+	int err;
+
+	err = mv88e6xxx_g2_smi_phy_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g2_smi_phy_cmd(chip, cmd);
+	if (err)
+		return err;
+
+	return mv88e6xxx_read(chip, REG_GLOBAL2, GLOBAL2_SMI_PHY_DATA, val);
+}
+
+static int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr,
+				      int reg, u16 val)
+{
+	u16 cmd = GLOBAL2_SMI_PHY_CMD_OP_22_WRITE_DATA | (addr << 5) | reg;
+	int err;
+
+	err = mv88e6xxx_g2_smi_phy_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_SMI_PHY_DATA, val);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g2_smi_phy_cmd(chip, cmd);
+}
+
 static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 {
 	u16 reg;
@@ -3236,7 +3269,7 @@ static int mv88e6xxx_mdio_read(struct mii_bus *bus, int port, int regnum)
 
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU))
 		ret = mv88e6xxx_mdio_read_ppu(chip, addr, regnum);
-	else if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_SMI_PHY))
+	else if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_SMI_PHY))
 		ret = mv88e6xxx_mdio_read_indirect(chip, addr, regnum);
 	else
 		ret = mv88e6xxx_mdio_read_direct(chip, addr, regnum);
@@ -3259,7 +3292,7 @@ static int mv88e6xxx_mdio_write(struct mii_bus *bus, int port, int regnum,
 
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU))
 		ret = mv88e6xxx_mdio_write_ppu(chip, addr, regnum, val);
-	else if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_SMI_PHY))
+	else if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_SMI_PHY))
 		ret = mv88e6xxx_mdio_write_indirect(chip, addr, regnum, val);
 	else
 		ret = mv88e6xxx_mdio_write_direct(chip, addr, regnum, val);
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 527a880..8be0f36 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -329,17 +329,16 @@
 #define GLOBAL2_EEPROM_DATA	0x15
 #define GLOBAL2_PTP_AVB_OP	0x16
 #define GLOBAL2_PTP_AVB_DATA	0x17
-#define GLOBAL2_SMI_OP		0x18
-#define GLOBAL2_SMI_OP_BUSY		BIT(15)
-#define GLOBAL2_SMI_OP_CLAUSE_22	BIT(12)
-#define GLOBAL2_SMI_OP_22_WRITE		((1 << 10) | GLOBAL2_SMI_OP_BUSY | \
-					 GLOBAL2_SMI_OP_CLAUSE_22)
-#define GLOBAL2_SMI_OP_22_READ		((2 << 10) | GLOBAL2_SMI_OP_BUSY | \
-					 GLOBAL2_SMI_OP_CLAUSE_22)
-#define GLOBAL2_SMI_OP_45_WRITE_ADDR	((0 << 10) | GLOBAL2_SMI_OP_BUSY)
-#define GLOBAL2_SMI_OP_45_WRITE_DATA	((1 << 10) | GLOBAL2_SMI_OP_BUSY)
-#define GLOBAL2_SMI_OP_45_READ_DATA	((2 << 10) | GLOBAL2_SMI_OP_BUSY)
-#define GLOBAL2_SMI_DATA	0x19
+#define GLOBAL2_SMI_PHY_CMD			0x18
+#define GLOBAL2_SMI_PHY_CMD_BUSY		BIT(15)
+#define GLOBAL2_SMI_PHY_CMD_MODE_22		BIT(12)
+#define GLOBAL2_SMI_PHY_CMD_OP_22_WRITE_DATA	((0x1 << 10) | \
+						 GLOBAL2_SMI_PHY_CMD_MODE_22 | \
+						 GLOBAL2_SMI_PHY_CMD_BUSY)
+#define GLOBAL2_SMI_PHY_CMD_OP_22_READ_DATA	((0x2 << 10) | \
+						 GLOBAL2_SMI_PHY_CMD_MODE_22 | \
+						 GLOBAL2_SMI_PHY_CMD_BUSY)
+#define GLOBAL2_SMI_PHY_DATA			0x19
 #define GLOBAL2_SCRATCH_MISC	0x1a
 #define GLOBAL2_SCRATCH_BUSY		BIT(15)
 #define GLOBAL2_SCRATCH_REGISTER_SHIFT	8
@@ -409,6 +408,8 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_G2_POT,		/* (0x0f) Priority Override Table */
 	MV88E6XXX_CAP_G2_EEPROM_CMD,	/* (0x14) EEPROM Command */
 	MV88E6XXX_CAP_G2_EEPROM_DATA,	/* (0x15) EEPROM Data */
+	MV88E6XXX_CAP_G2_SMI_PHY_CMD,	/* (0x18) SMI PHY Command */
+	MV88E6XXX_CAP_G2_SMI_PHY_DATA,	/* (0x19) SMI PHY Data */
 
 	/* PHY Polling Unit.
 	 * See GLOBAL_CONTROL_PPU_ENABLE and GLOBAL_STATUS_PPU_POLLING.
@@ -416,12 +417,6 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_PPU,
 	MV88E6XXX_CAP_PPU_ACTIVE,
 
-	/* SMI PHY Command and Data registers.
-	 * This requires an indirect access to PHY registers through
-	 * GLOBAL2_SMI_OP, otherwise direct access to PHY registers is done.
-	 */
-	MV88E6XXX_CAP_SMI_PHY,
-
 	/* Per VLAN Spanning Tree Unit (STU).
 	 * The Port State database, if present, is accessed through VTU
 	 * operations and dedicated SID registers. See GLOBAL_VTU_SID.
@@ -457,10 +452,11 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_G2_POT		BIT(MV88E6XXX_CAP_G2_POT)
 #define MV88E6XXX_FLAG_G2_EEPROM_CMD	BIT(MV88E6XXX_CAP_G2_EEPROM_CMD)
 #define MV88E6XXX_FLAG_G2_EEPROM_DATA	BIT(MV88E6XXX_CAP_G2_EEPROM_DATA)
+#define MV88E6XXX_FLAG_G2_SMI_PHY_CMD	BIT(MV88E6XXX_CAP_G2_SMI_PHY_CMD)
+#define MV88E6XXX_FLAG_G2_SMI_PHY_DATA	BIT(MV88E6XXX_CAP_G2_SMI_PHY_DATA)
 
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_PPU_ACTIVE	BIT(MV88E6XXX_CAP_PPU_ACTIVE)
-#define MV88E6XXX_FLAG_SMI_PHY		BIT(MV88E6XXX_CAP_SMI_PHY)
 #define MV88E6XXX_FLAG_STU		BIT(MV88E6XXX_CAP_STU)
 #define MV88E6XXX_FLAG_TEMP		BIT(MV88E6XXX_CAP_TEMP)
 #define MV88E6XXX_FLAG_TEMP_LIMIT	BIT(MV88E6XXX_CAP_TEMP_LIMIT)
@@ -486,6 +482,11 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_G2_PVT_ADDR |	\
 	 MV88E6XXX_FLAG_G2_PVT_DATA)
 
+/* Indirect PHY access via Global2 SMI PHY registers */
+#define MV88E6XXX_FLAGS_SMI_PHY		\
+	(MV88E6XXX_FLAG_G2_SMI_PHY_CMD |\
+	 MV88E6XXX_FLAG_G2_SMI_PHY_DATA)
+
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
@@ -533,14 +534,14 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
-	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_EEPROM16 |	\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_PVT)
+	 MV88E6XXX_FLAGS_PVT |		\
+	 MV88E6XXX_FLAGS_SMI_PHY)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
@@ -549,13 +550,13 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
-	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_VTU |		\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_PVT)
+	 MV88E6XXX_FLAGS_PVT |		\
+	 MV88E6XXX_FLAGS_SMI_PHY)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
 	(MV88E6XXX_FLAG_EEE |		\
@@ -565,7 +566,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
-	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
@@ -573,7 +573,8 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_EEPROM16 |	\
 	 MV88E6XXX_FLAGS_IRL |		\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_PVT)
+	 MV88E6XXX_FLAGS_PVT |		\
+	 MV88E6XXX_FLAGS_SMI_PHY)
 
 struct mv88e6xxx_info {
 	enum mv88e6xxx_family family;
-- 
2.9.3
