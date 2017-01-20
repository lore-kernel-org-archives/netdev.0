From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 7/8] net: dsa: mv88e6xxx: Implement Clause 45 access to SMI devices
Date: Sat, 21 Jan 2017 00:31:01 +0100
Message-ID: <1484955062-26718-8-git-send-email-andrew@lunn.ch>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40325 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752203AbdATXb4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 18:31:56 -0500
In-Reply-To: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 SERDES devices need clause 45 MDIO to access them.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/global2.c   | 108 ++++++++++++++++++++++++++++++++--
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |   7 +++
 2 files changed, 111 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index e2b00d1b0c28..d1a0b7d3ebb8 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -501,8 +501,60 @@ static int mv88e6xxx_g2_smi_phy_cmd(struct mv88e6xxx_chip *chip, u16 cmd)
 	return mv88e6xxx_g2_smi_phy_wait(chip);
 }
 
-int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr, int reg,
-			      u16 *val, bool external)
+static int mv88e6xxx_g2_smi_phy_write_addr(struct mv88e6xxx_chip *chip,
+					   int addr, int device, int reg,
+					   bool external)
+{
+	int cmd = SMI_CMD_OP_45_WRITE_ADDR | (addr << 5) | device;
+	int err;
+
+	if (external)
+		cmd |= GLOBAL2_SMI_PHY_CMD_EXTERNAL;
+
+	err = mv88e6xxx_g2_smi_phy_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g2_write(chip, GLOBAL2_SMI_PHY_DATA, reg);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g2_smi_phy_cmd(chip, cmd);
+}
+
+int mv88e6xxx_g2_smi_phy_read_c45(struct mv88e6xxx_chip *chip, int addr,
+				  int reg_c45, u16 *val, bool external)
+{
+	int device = (reg_c45 >> 16) & 0x1f;
+	int reg = reg_c45 & 0xffff;
+	int err;
+	u16 cmd;
+
+	err = mv88e6xxx_g2_smi_phy_write_addr(chip, addr, device, reg,
+					      external);
+	if (err)
+		return err;
+
+	cmd = GLOBAL2_SMI_PHY_CMD_OP_45_READ_DATA | (addr << 5) | device;
+
+	if (external)
+		cmd |= GLOBAL2_SMI_PHY_CMD_EXTERNAL;
+
+	err = mv88e6xxx_g2_smi_phy_cmd(chip, cmd);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g2_read(chip, GLOBAL2_SMI_PHY_DATA, val);
+	if (err)
+		return err;
+
+	err = *val;
+
+	return 0;
+}
+
+int mv88e6xxx_g2_smi_phy_read_c22(struct mv88e6xxx_chip *chip, int addr,
+				  int reg, u16 *val, bool external)
 {
 	u16 cmd = GLOBAL2_SMI_PHY_CMD_OP_22_READ_DATA | (addr << 5) | reg;
 	int err;
@@ -535,8 +587,46 @@ int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr, int reg,
 	return 0;
 }
 
-int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr, int reg,
-			       u16 val, bool external)
+int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr, int reg,
+			      u16 *val, bool external)
+{
+	if (reg & MII_ADDR_C45)
+		return mv88e6xxx_g2_smi_phy_read_c45(chip, addr, reg, val,
+						     external);
+	return mv88e6xxx_g2_smi_phy_read_c22(chip, addr, reg, val, external);
+}
+
+int mv88e6xxx_g2_smi_phy_write_c45(struct mv88e6xxx_chip *chip, int addr,
+				   int reg_c45, u16 val, bool external)
+{
+	int device = (reg_c45 >> 16) & 0x1f;
+	int reg = reg_c45 & 0xffff;
+	int err;
+	u16 cmd;
+
+	err = mv88e6xxx_g2_smi_phy_write_addr(chip, addr, device, reg,
+					      external);
+	if (err)
+		return err;
+
+	cmd = GLOBAL2_SMI_PHY_CMD_OP_45_WRITE_DATA | (addr << 5) | device;
+
+	if (external)
+		cmd |= GLOBAL2_SMI_PHY_CMD_EXTERNAL;
+
+	err = mv88e6xxx_g2_write(chip, GLOBAL2_SMI_PHY_DATA, val);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g2_smi_phy_cmd(chip, cmd);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+int mv88e6xxx_g2_smi_phy_write_c22(struct mv88e6xxx_chip *chip, int addr,
+				   int reg, u16 val, bool external)
 {
 	u16 cmd = GLOBAL2_SMI_PHY_CMD_OP_22_WRITE_DATA | (addr << 5) | reg;
 	int err;
@@ -555,6 +645,16 @@ int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr, int reg,
 	return mv88e6xxx_g2_smi_phy_cmd(chip, cmd);
 }
 
+int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr, int reg,
+			       u16 val, bool external)
+{
+	if (reg & MII_ADDR_C45)
+		return mv88e6xxx_g2_smi_phy_write_c45(chip, addr, reg, val,
+						      external);
+
+	return mv88e6xxx_g2_smi_phy_write_c22(chip, addr, reg, val, external);
+}
+
 static void mv88e6xxx_g2_irq_mask(struct irq_data *d)
 {
 	struct mv88e6xxx_chip *chip = irq_data_get_irq_chip_data(d);
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 7961467f709e..6cbde36027f1 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -399,6 +399,13 @@
 #define GLOBAL2_SMI_PHY_CMD_OP_22_READ_DATA	((0x2 << 10) | \
 						 GLOBAL2_SMI_PHY_CMD_MODE_22 | \
 						 GLOBAL2_SMI_PHY_CMD_BUSY)
+#define GLOBAL2_SMI_PHY_CMD_OP_45_WRITE_ADDR	((0x0 << 10) | \
+						 GLOBAL2_SMI_PHY_CMD_BUSY)
+#define GLOBAL2_SMI_PHY_CMD_OP_45_WRITE_DATA	((0x1 << 10) | \
+						 GLOBAL2_SMI_PHY_CMD_BUSY)
+#define GLOBAL2_SMI_PHY_CMD_OP_45_READ_DATA	((0x3 << 10) | \
+						 GLOBAL2_SMI_PHY_CMD_BUSY)
+
 #define GLOBAL2_SMI_PHY_DATA			0x19
 #define GLOBAL2_SCRATCH_MISC	0x1a
 #define GLOBAL2_SCRATCH_BUSY		BIT(15)
-- 
2.11.0
