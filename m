From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 09/11] net: dsa: mv88e6xxx: add port's RGMII delay setter
Date: Fri,  4 Nov 2016 03:23:34 +0100
Message-ID: <20161104022336.14273-10-vivien.didelot@savoirfairelinux.com>
References: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51674 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759778AbcKDCYe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 22:24:34 -0400
In-Reply-To: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some chips such as 88E6352 and 88E6390 can be programmed to add delays
to RXCLK for IND inputs or to GTXCLK for OUTD outputs when port is in
RGMII mode.

Add a port function to program such delays according to the provided PHY
interface mode.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      |  4 +++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  6 ++++
 drivers/net/dsa/mv88e6xxx/port.c      | 58 +++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  5 +++
 4 files changed, 73 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 49a6935..bb93d0a 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3220,6 +3220,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -3238,6 +3239,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3256,6 +3258,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -3302,6 +3305,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index ab48eb9..c7527c0 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -728,6 +728,12 @@ struct mv88e6xxx_ops {
 	int (*phy_write)(struct mv88e6xxx_chip *chip, int addr, int reg,
 			 u16 val);
 
+	/* RGMII Receive/Transmit Timing Control
+	 * Add delay on PHY_INTERFACE_MODE_RGMII_*ID, no delay otherwise.
+	 */
+	int (*port_set_rgmii_delay)(struct mv88e6xxx_chip *chip, int port,
+				    phy_interface_t mode);
+
 #define LINK_FORCED_DOWN	0
 #define LINK_FORCED_UP		1
 #define LINK_UNFORCED		-2
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 17b5444..838068d 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -35,6 +35,64 @@ int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
  * Link, Duplex and Flow Control have one force bit, one value bit.
  */
 
+static int mv88e6xxx_port_set_rgmii_delay(struct mv88e6xxx_chip *chip, int port,
+					  phy_interface_t mode)
+{
+	u16 reg;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_PCS_CTRL, &reg);
+	if (err)
+		return err;
+
+	reg &= ~(PORT_PCS_CTRL_RGMII_DELAY_RXCLK |
+		 PORT_PCS_CTRL_RGMII_DELAY_TXCLK);
+
+	switch (mode) {
+	case PHY_INTERFACE_MODE_RGMII_RXID:
+		reg |= PORT_PCS_CTRL_RGMII_DELAY_RXCLK;
+		break;
+	case PHY_INTERFACE_MODE_RGMII_TXID:
+		reg |= PORT_PCS_CTRL_RGMII_DELAY_TXCLK;
+		break;
+	case PHY_INTERFACE_MODE_RGMII_ID:
+		reg |= PORT_PCS_CTRL_RGMII_DELAY_RXCLK |
+			PORT_PCS_CTRL_RGMII_DELAY_TXCLK;
+		break;
+	default:
+		/* no delay */
+		break;
+	}
+
+	err = mv88e6xxx_port_write(chip, port, PORT_PCS_CTRL, reg);
+	if (err)
+		return err;
+
+	netdev_dbg(chip->ds->ports[port].netdev, "delay RXCLK %s, TXCLK %s\n",
+		   reg & PORT_PCS_CTRL_RGMII_DELAY_RXCLK ? "yes" : "no",
+		   reg & PORT_PCS_CTRL_RGMII_DELAY_TXCLK ? "yes" : "no");
+
+	return 0;
+}
+
+int mv88e6352_port_set_rgmii_delay(struct mv88e6xxx_chip *chip, int port,
+				   phy_interface_t mode)
+{
+	if (port < 5)
+		return -EOPNOTSUPP;
+
+	return mv88e6xxx_port_set_rgmii_delay(chip, port, mode);
+}
+
+int mv88e6390_port_set_rgmii_delay(struct mv88e6xxx_chip *chip, int port,
+				   phy_interface_t mode)
+{
+	if (port != 0)
+		return -EOPNOTSUPP;
+
+	return mv88e6xxx_port_set_rgmii_delay(chip, port, mode);
+}
+
 int mv88e6xxx_port_set_link(struct mv88e6xxx_chip *chip, int port, int link)
 {
 	u16 reg;
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index f73e90e..3472b79 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -21,6 +21,11 @@ int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port, int reg,
 int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
 			 u16 val);
 
+int mv88e6352_port_set_rgmii_delay(struct mv88e6xxx_chip *chip, int port,
+				   phy_interface_t mode);
+int mv88e6390_port_set_rgmii_delay(struct mv88e6xxx_chip *chip, int port,
+				   phy_interface_t mode);
+
 int mv88e6xxx_port_set_link(struct mv88e6xxx_chip *chip, int port, int link);
 
 int mv88e6xxx_port_set_duplex(struct mv88e6xxx_chip *chip, int port, int dup);
-- 
2.10.2
