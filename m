From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 02/10] net: dsa: mv88e6xxx: clarify SMI PHY functions
Date: Sat, 17 Jun 2017 23:06:33 -0400
Message-ID: <20170618030641.32463-3-vivien.didelot@savoirfairelinux.com>
References: <20170618030641.32463-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:52126 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751949AbdFRDJD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 23:09:03 -0400
In-Reply-To: <20170618030641.32463-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marvell chips with an SMI PHY access in Global 2 registers handle both
Clause 22 and Clause 45 of IEEE 802.3.

The 88E6390 family has addition bits to target the internal or external
PHYs connected to the device, and a Setup function in addition to the
default (register) Access function.

Prefix the SMI PHY Command and Data registers macros, implement clear
helpers for Clause 22 and 44 Access functions, rename variable to match
the SMI and switch vocabulary (device and register addresses for Clause
22 and port and device class for Clause 45.)

Finally do not use complex macros but simple 16-bit mask to document the
registers organization.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/global2.c | 248 +++++++++++++++++++++---------------
 drivers/net/dsa/mv88e6xxx/global2.h |  41 +++---
 2 files changed, 166 insertions(+), 123 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index baa86b1abad3..f20a60af35cb 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -13,6 +13,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/bitfield.h>
 #include <linux/interrupt.h>
 #include <linux/irqdomain.h>
 
@@ -541,171 +542,206 @@ int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 
 static int mv88e6xxx_g2_smi_phy_wait(struct mv88e6xxx_chip *chip)
 {
-	return mv88e6xxx_g2_wait(chip, GLOBAL2_SMI_PHY_CMD,
-				 GLOBAL2_SMI_PHY_CMD_BUSY);
+	return mv88e6xxx_g2_wait(chip, MV88E6XXX_G2_SMI_PHY_CMD,
+				 MV88E6XXX_G2_SMI_PHY_CMD_BUSY);
 }
 
 static int mv88e6xxx_g2_smi_phy_cmd(struct mv88e6xxx_chip *chip, u16 cmd)
 {
 	int err;
 
-	err = mv88e6xxx_g2_write(chip, GLOBAL2_SMI_PHY_CMD, cmd);
+	err = mv88e6xxx_g2_write(chip, MV88E6XXX_G2_SMI_PHY_CMD,
+				 MV88E6XXX_G2_SMI_PHY_CMD_BUSY | cmd);
 	if (err)
 		return err;
 
 	return mv88e6xxx_g2_smi_phy_wait(chip);
 }
 
-static int mv88e6xxx_g2_smi_phy_write_addr(struct mv88e6xxx_chip *chip,
-					   int addr, int device, int reg,
-					   bool external)
+static int mv88e6xxx_g2_smi_phy_access(struct mv88e6xxx_chip *chip,
+				       bool external, bool c45, u16 op, int dev,
+				       int reg)
 {
-	int cmd = SMI_CMD_OP_45_WRITE_ADDR | (addr << 5) | device;
-	int err;
+	u16 cmd = op;
 
 	if (external)
-		cmd |= GLOBAL2_SMI_PHY_CMD_EXTERNAL;
+		cmd |= MV88E6390_G2_SMI_PHY_CMD_FUNC_EXTERNAL;
+	else
+		cmd |= MV88E6390_G2_SMI_PHY_CMD_FUNC_INTERNAL; /* empty mask */
 
-	err = mv88e6xxx_g2_smi_phy_wait(chip);
-	if (err)
-		return err;
+	if (c45)
+		cmd |= MV88E6XXX_G2_SMI_PHY_CMD_MODE_45; /* empty mask */
+	else
+		cmd |= MV88E6XXX_G2_SMI_PHY_CMD_MODE_22;
 
-	err = mv88e6xxx_g2_write(chip, GLOBAL2_SMI_PHY_DATA, reg);
-	if (err)
-		return err;
+	dev <<= __bf_shf(MV88E6XXX_G2_SMI_PHY_CMD_DEV_ADDR_MASK);
+	cmd |= dev & MV88E6XXX_G2_SMI_PHY_CMD_DEV_ADDR_MASK;
+	cmd |= reg & MV88E6XXX_G2_SMI_PHY_CMD_REG_ADDR_MASK;
 
 	return mv88e6xxx_g2_smi_phy_cmd(chip, cmd);
 }
 
+static int mv88e6xxx_g2_smi_phy_access_c22(struct mv88e6xxx_chip *chip,
+					   bool external, u16 op, int dev,
+					   int reg)
+{
+	return mv88e6xxx_g2_smi_phy_access(chip, external, false, op, dev, reg);
+}
+
+/* IEEE 802.3 Clause 22 Read Data Register */
+static int mv88e6xxx_g2_smi_phy_read_data_c22(struct mv88e6xxx_chip *chip,
+					      bool external, int dev, int reg,
+					      u16 *data)
+{
+	u16 op = MV88E6XXX_G2_SMI_PHY_CMD_OP_22_READ_DATA;
+	int err;
+
+	err = mv88e6xxx_g2_smi_phy_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g2_smi_phy_access_c22(chip, external, op, dev, reg);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g2_read(chip, MV88E6XXX_G2_SMI_PHY_DATA, data);
+}
+
+/* IEEE 802.3 Clause 22 Write Data Register */
+static int mv88e6xxx_g2_smi_phy_write_data_c22(struct mv88e6xxx_chip *chip,
+					       bool external, int dev, int reg,
+					       u16 data)
+{
+	u16 op = MV88E6XXX_G2_SMI_PHY_CMD_OP_22_WRITE_DATA;
+	int err;
+
+	err = mv88e6xxx_g2_smi_phy_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g2_write(chip, MV88E6XXX_G2_SMI_PHY_DATA, data);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g2_smi_phy_access_c22(chip, external, op, dev, reg);
+}
+
+static int mv88e6xxx_g2_smi_phy_access_c45(struct mv88e6xxx_chip *chip,
+					   bool external, u16 op, int port,
+					   int dev)
+{
+	return mv88e6xxx_g2_smi_phy_access(chip, external, true, op, port, dev);
+}
+
+/* IEEE 802.3 Clause 45 Write Address Register */
+static int mv88e6xxx_g2_smi_phy_write_addr_c45(struct mv88e6xxx_chip *chip,
+					       bool external, int port, int dev,
+					       int addr)
+{
+	u16 op = MV88E6XXX_G2_SMI_PHY_CMD_OP_45_WRITE_ADDR;
+	int err;
+
+	err = mv88e6xxx_g2_smi_phy_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g2_write(chip, MV88E6XXX_G2_SMI_PHY_DATA, addr);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g2_smi_phy_access_c45(chip, external, op, port, dev);
+}
+
+/* IEEE 802.3 Clause 45 Read Data Register */
+static int mv88e6xxx_g2_smi_phy_read_data_c45(struct mv88e6xxx_chip *chip,
+					      bool external, int port, int dev,
+					      u16 *data)
+{
+	u16 op = MV88E6XXX_G2_SMI_PHY_CMD_OP_45_READ_DATA;
+	int err;
+
+	err = mv88e6xxx_g2_smi_phy_access_c45(chip, external, op, port, dev);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g2_read(chip, MV88E6XXX_G2_SMI_PHY_DATA, data);
+}
+
 static int mv88e6xxx_g2_smi_phy_read_c45(struct mv88e6xxx_chip *chip,
-					 int addr, int reg_c45, u16 *val,
-					 bool external)
+					 bool external, int port, int reg,
+					 u16 *data)
 {
-	int device = (reg_c45 >> 16) & 0x1f;
-	int reg = reg_c45 & 0xffff;
+	int dev = (reg >> 16) & 0x1f;
+	int addr = reg & 0xffff;
 	int err;
-	u16 cmd;
 
-	err = mv88e6xxx_g2_smi_phy_write_addr(chip, addr, device, reg,
-					      external);
+	err = mv88e6xxx_g2_smi_phy_write_addr_c45(chip, external, port, dev,
+						  addr);
 	if (err)
 		return err;
 
-	cmd = GLOBAL2_SMI_PHY_CMD_OP_45_READ_DATA | (addr << 5) | device;
-
-	if (external)
-		cmd |= GLOBAL2_SMI_PHY_CMD_EXTERNAL;
-
-	err = mv88e6xxx_g2_smi_phy_cmd(chip, cmd);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g2_read(chip, GLOBAL2_SMI_PHY_DATA, val);
-	if (err)
-		return err;
-
-	err = *val;
-
-	return 0;
+	return mv88e6xxx_g2_smi_phy_read_data_c45(chip, external, port, dev,
+						  data);
 }
 
-static int mv88e6xxx_g2_smi_phy_read_c22(struct mv88e6xxx_chip *chip,
-					 int addr, int reg, u16 *val,
-					 bool external)
+/* IEEE 802.3 Clause 45 Write Data Register */
+static int mv88e6xxx_g2_smi_phy_write_data_c45(struct mv88e6xxx_chip *chip,
+					       bool external, int port, int dev,
+					       u16 data)
 {
-	u16 cmd = GLOBAL2_SMI_PHY_CMD_OP_22_READ_DATA | (addr << 5) | reg;
+	u16 op = MV88E6XXX_G2_SMI_PHY_CMD_OP_45_WRITE_DATA;
 	int err;
 
-	if (external)
-		cmd |= GLOBAL2_SMI_PHY_CMD_EXTERNAL;
-
-	err = mv88e6xxx_g2_smi_phy_wait(chip);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g2_smi_phy_cmd(chip, cmd);
+	err = mv88e6xxx_g2_write(chip, MV88E6XXX_G2_SMI_PHY_DATA, data);
 	if (err)
 		return err;
 
-	return mv88e6xxx_g2_read(chip, GLOBAL2_SMI_PHY_DATA, val);
-}
-
-int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip,
-			      struct mii_bus *bus,
-			      int addr, int reg, u16 *val)
-{
-	struct mv88e6xxx_mdio_bus *mdio_bus = bus->priv;
-	bool external = mdio_bus->external;
-
-	if (reg & MII_ADDR_C45)
-		return mv88e6xxx_g2_smi_phy_read_c45(chip, addr, reg, val,
-						     external);
-	return mv88e6xxx_g2_smi_phy_read_c22(chip, addr, reg, val, external);
+	return mv88e6xxx_g2_smi_phy_access_c45(chip, external, op, port, dev);
 }
 
 static int mv88e6xxx_g2_smi_phy_write_c45(struct mv88e6xxx_chip *chip,
-					  int addr, int reg_c45, u16 val,
-					  bool external)
+					  bool external, int port, int reg,
+					  u16 data)
 {
-	int device = (reg_c45 >> 16) & 0x1f;
-	int reg = reg_c45 & 0xffff;
+	int dev = (reg >> 16) & 0x1f;
+	int addr = reg & 0xffff;
 	int err;
-	u16 cmd;
 
-	err = mv88e6xxx_g2_smi_phy_write_addr(chip, addr, device, reg,
-					      external);
+	err = mv88e6xxx_g2_smi_phy_write_addr_c45(chip, external, port, dev,
+						  addr);
 	if (err)
 		return err;
 
-	cmd = GLOBAL2_SMI_PHY_CMD_OP_45_WRITE_DATA | (addr << 5) | device;
-
-	if (external)
-		cmd |= GLOBAL2_SMI_PHY_CMD_EXTERNAL;
-
-	err = mv88e6xxx_g2_write(chip, GLOBAL2_SMI_PHY_DATA, val);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g2_smi_phy_cmd(chip, cmd);
-	if (err)
-		return err;
-
-	return 0;
+	return mv88e6xxx_g2_smi_phy_write_data_c45(chip, external, port, dev,
+						   data);
 }
 
-static int mv88e6xxx_g2_smi_phy_write_c22(struct mv88e6xxx_chip *chip,
-					  int addr, int reg, u16 val,
-					  bool external)
+int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
+			      int addr, int reg, u16 *val)
 {
-	u16 cmd = GLOBAL2_SMI_PHY_CMD_OP_22_WRITE_DATA | (addr << 5) | reg;
-	int err;
-
-	if (external)
-		cmd |= GLOBAL2_SMI_PHY_CMD_EXTERNAL;
+	struct mv88e6xxx_mdio_bus *mdio_bus = bus->priv;
+	bool external = mdio_bus->external;
 
-	err = mv88e6xxx_g2_smi_phy_wait(chip);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g2_write(chip, GLOBAL2_SMI_PHY_DATA, val);
-	if (err)
-		return err;
+	if (reg & MII_ADDR_C45)
+		return mv88e6xxx_g2_smi_phy_read_c45(chip, external, addr, reg,
+						     val);
 
-	return mv88e6xxx_g2_smi_phy_cmd(chip, cmd);
+	return mv88e6xxx_g2_smi_phy_read_data_c22(chip, external, addr, reg,
+						  val);
 }
 
-int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip,
-			       struct mii_bus *bus,
+int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
 			       int addr, int reg, u16 val)
 {
 	struct mv88e6xxx_mdio_bus *mdio_bus = bus->priv;
 	bool external = mdio_bus->external;
 
 	if (reg & MII_ADDR_C45)
-		return mv88e6xxx_g2_smi_phy_write_c45(chip, addr, reg, val,
-						      external);
+		return mv88e6xxx_g2_smi_phy_write_c45(chip, external, addr, reg,
+						      val);
 
-	return mv88e6xxx_g2_smi_phy_write_c22(chip, addr, reg, val, external);
+	return mv88e6xxx_g2_smi_phy_write_data_c22(chip, external, addr, reg,
+						   val);
 }
 
 static int mv88e6097_watchdog_action(struct mv88e6xxx_chip *chip, int irq)
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index fb1871d4569c..e4b40e896709 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -91,24 +91,31 @@
 #define GLOBAL2_EEPROM_ADDR	0x15 /* 6390, 6341 */
 #define GLOBAL2_PTP_AVB_OP	0x16
 #define GLOBAL2_PTP_AVB_DATA	0x17
-#define GLOBAL2_SMI_PHY_CMD			0x18
-#define GLOBAL2_SMI_PHY_CMD_BUSY		BIT(15)
-#define GLOBAL2_SMI_PHY_CMD_EXTERNAL		BIT(13)
-#define GLOBAL2_SMI_PHY_CMD_MODE_22		BIT(12)
-#define GLOBAL2_SMI_PHY_CMD_OP_22_WRITE_DATA	((0x1 << 10) | \
-						 GLOBAL2_SMI_PHY_CMD_MODE_22 | \
-						 GLOBAL2_SMI_PHY_CMD_BUSY)
-#define GLOBAL2_SMI_PHY_CMD_OP_22_READ_DATA	((0x2 << 10) | \
-						 GLOBAL2_SMI_PHY_CMD_MODE_22 | \
-						 GLOBAL2_SMI_PHY_CMD_BUSY)
-#define GLOBAL2_SMI_PHY_CMD_OP_45_WRITE_ADDR	((0x0 << 10) | \
-						 GLOBAL2_SMI_PHY_CMD_BUSY)
-#define GLOBAL2_SMI_PHY_CMD_OP_45_WRITE_DATA	((0x1 << 10) | \
-						 GLOBAL2_SMI_PHY_CMD_BUSY)
-#define GLOBAL2_SMI_PHY_CMD_OP_45_READ_DATA	((0x3 << 10) | \
-						 GLOBAL2_SMI_PHY_CMD_BUSY)
 
-#define GLOBAL2_SMI_PHY_DATA			0x19
+/* Offset 0x18: SMI PHY Command Register */
+#define MV88E6XXX_G2_SMI_PHY_CMD			0x18
+#define MV88E6XXX_G2_SMI_PHY_CMD_BUSY			0x8000
+#define MV88E6390_G2_SMI_PHY_CMD_FUNC_MASK		0x6000
+#define MV88E6390_G2_SMI_PHY_CMD_FUNC_INTERNAL		0x0000
+#define MV88E6390_G2_SMI_PHY_CMD_FUNC_EXTERNAL		0x2000
+#define MV88E6390_G2_SMI_PHY_CMD_FUNC_SETUP		0x4000
+#define MV88E6XXX_G2_SMI_PHY_CMD_MODE_MASK		0x1000
+#define MV88E6XXX_G2_SMI_PHY_CMD_MODE_45		0x0000
+#define MV88E6XXX_G2_SMI_PHY_CMD_MODE_22		0x1000
+#define MV88E6XXX_G2_SMI_PHY_CMD_OP_MASK		0x0c00
+#define MV88E6XXX_G2_SMI_PHY_CMD_OP_22_WRITE_DATA	0x0400
+#define MV88E6XXX_G2_SMI_PHY_CMD_OP_22_READ_DATA	0x0800
+#define MV88E6XXX_G2_SMI_PHY_CMD_OP_45_WRITE_ADDR	0x0000
+#define MV88E6XXX_G2_SMI_PHY_CMD_OP_45_WRITE_DATA	0x0400
+#define MV88E6XXX_G2_SMI_PHY_CMD_OP_45_READ_DATA_INC	0x0800
+#define MV88E6XXX_G2_SMI_PHY_CMD_OP_45_READ_DATA	0x0c00
+#define MV88E6XXX_G2_SMI_PHY_CMD_DEV_ADDR_MASK		0x03e0
+#define MV88E6XXX_G2_SMI_PHY_CMD_REG_ADDR_MASK		0x001f
+#define MV88E6XXX_G2_SMI_PHY_CMD_SETUP_PTR_MASK		0x03ff
+
+/* Offset 0x19: SMI PHY Data Register */
+#define MV88E6XXX_G2_SMI_PHY_DATA	0x19
+
 #define GLOBAL2_SCRATCH_MISC	0x1a
 #define GLOBAL2_SCRATCH_BUSY		BIT(15)
 #define GLOBAL2_SCRATCH_REGISTER_SHIFT	8
-- 
2.13.1
