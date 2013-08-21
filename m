From: Sean Cross <xobs@kosagi.com>
Subject: [PATCH v6] net/phy: micrel: Add OF configuration support for ksz9021
Date: Wed, 21 Aug 2013 01:46:12 +0000
Message-ID: <1377049572-30752-2-git-send-email-xobs@kosagi.com>
References: <1377049572-30752-1-git-send-email-xobs@kosagi.com>
Cc: David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sean Cross <xobs@kosagi.com>
To: Sascha Hauer <s.hauer@pengutronix.de>,
	Duan Fugang-B38611 <B38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.g1.pair.com ([66.39.3.162]:62747 "EHLO mail1.g1.pair.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751782Ab3HUCDY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 22:03:24 -0400
In-Reply-To: <1377049572-30752-1-git-send-email-xobs@kosagi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some boards require custom PHY configuration, for example due to trace
length differences.  Add the ability to configure these registers in
order to get the PHY to function on boards that need it.

Because PHYs are auto-detected based on MDIO device IDs, allow PHY
configuration to be specified in the parent Ethernet device node if no
PHY device node is present.

Signed-off-by: Sean Cross <xobs@kosagi.com>
---
 .../devicetree/bindings/net/micrel-ksz9021.txt     |   49 ++++++++++
 drivers/net/phy/micrel.c                           |  103 +++++++++++++++++++-
 2 files changed, 151 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/devicetree/bindings/net/micrel-ksz9021.txt

diff --git a/Documentation/devicetree/bindings/net/micrel-ksz9021.txt b/Documentation/devicetree/bindings/net/micrel-ksz9021.txt
new file mode 100644
index 0000000..997a63f
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/micrel-ksz9021.txt
@@ -0,0 +1,49 @@
+Micrel KSZ9021 Gigabit Ethernet PHY
+
+Some boards require special tuning values, particularly when it comes to
+clock delays.  You can specify clock delay values by adding
+micrel-specific properties to an Ethernet OF device node.
+
+All skew control options are specified in picoseconds.  The minimum
+value is 0, and the maximum value is 3000.
+
+Optional properties:
+ - rxc-skew-ps : Skew control of RXC pad
+ - rxdv-skew-ps : Skew control of RX CTL pad
+ - txc-skew-ps : Skew control of TXC pad
+ - txen-skew-ps : Skew control of TX_CTL pad
+ - rxd0-skew-ps : Skew control of RX data 0 pad
+ - rxd1-skew-ps : Skew control of RX data 1 pad
+ - rxd2-skew-ps : Skew control of RX data 2 pad
+ - rxd3-skew-ps : Skew control of RX data 3 pad
+ - txd0-skew-ps : Skew control of TX data 0 pad
+ - txd1-skew-ps : Skew control of TX data 1 pad
+ - txd2-skew-ps : Skew control of TX data 2 pad
+ - txd3-skew-ps : Skew control of TX data 3 pad
+
+Examples:
+
+	/* Attach to an Ethernet device with autodetected PHY */
+	&enet {
+		rxc-skew-ps = <3000>;
+		rxdv-skew-ps = <0>;
+		txc-skew-ps = <3000>;
+		txen-skew-ps = <0>;
+		status = "okay";
+	};
+
+	/* Attach to an explicitly-specified PHY */
+	mdio {
+		phy0: ethernet-phy@0 {
+			rxc-skew-ps = <3000>;
+			rxdv-skew-ps = <0>;
+			txc-skew-ps = <3000>;
+			txen-skew-ps = <0>;
+			reg = <0>;
+		};
+	};
+	ethernet@70000 {
+		status = "okay";
+		phy = <&phy0>;
+		phy-mode = "rgmii-id";
+	};
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 2510435..7c32dcb 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -25,6 +25,7 @@
 #include <linux/module.h>
 #include <linux/phy.h>
 #include <linux/micrel_phy.h>
+#include <linux/of.h>
 
 /* Operation Mode Strap Override */
 #define MII_KSZPHY_OMSO				0x16
@@ -53,6 +54,20 @@
 #define KS8737_CTRL_INT_ACTIVE_HIGH		(1 << 14)
 #define KSZ8051_RMII_50MHZ_CLK			(1 << 7)
 
+/* Write/read to/from extended registers */
+#define MII_KSZPHY_EXTREG                       0x0b
+#define KSZPHY_EXTREG_WRITE                     0x8000
+
+#define MII_KSZPHY_EXTREG_WRITE                 0x0c
+#define MII_KSZPHY_EXTREG_READ                  0x0d
+
+/* Extended registers */
+#define MII_KSZPHY_CLK_CONTROL_PAD_SKEW         0x104
+#define MII_KSZPHY_RX_DATA_PAD_SKEW             0x105
+#define MII_KSZPHY_TX_DATA_PAD_SKEW             0x106
+
+#define PS_TO_REG				200
+
 static int ksz_config_flags(struct phy_device *phydev)
 {
 	int regval;
@@ -65,6 +80,20 @@ static int ksz_config_flags(struct phy_device *phydev)
 	return 0;
 }
 
+static int kszphy_extended_write(struct phy_device *phydev,
+                                 u32 regnum, u16 val)
+{
+	phy_write(phydev, MII_KSZPHY_EXTREG, KSZPHY_EXTREG_WRITE | regnum);
+	return phy_write(phydev, MII_KSZPHY_EXTREG_WRITE, val);
+}
+
+static int kszphy_extended_read(struct phy_device *phydev,
+                                 u32 regnum)
+{
+	phy_write(phydev, MII_KSZPHY_EXTREG, regnum);
+	return phy_read(phydev, MII_KSZPHY_EXTREG_READ);
+}
+
 static int kszphy_ack_interrupt(struct phy_device *phydev)
 {
 	/* bit[7..0] int status, which is a read and clear register. */
@@ -141,6 +170,78 @@ static int ks8051_config_init(struct phy_device *phydev)
 	return rc < 0 ? rc : 0;
 }
 
+static int ksz9021_load_values_from_of(struct phy_device *phydev,
+				       struct device_node *of_node, u16 reg,
+				       char *field1, char *field2,
+				       char *field3, char *field4)
+{
+	int val1 = -1;
+	int val2 = -2;
+	int val3 = -3;
+	int val4 = -4;
+	int newval;
+	int matches = 0;
+
+	if (!of_property_read_u32(of_node, field1, &val1))
+		matches++;
+
+	if (!of_property_read_u32(of_node, field2, &val2))
+		matches++;
+
+	if (!of_property_read_u32(of_node, field3, &val3))
+		matches++;
+
+	if (!of_property_read_u32(of_node, field4, &val4))
+		matches++;
+
+	if (!matches)
+		return 0;
+
+	if (matches < 4)
+		newval = kszphy_extended_read(phydev, reg);
+	else
+		newval = 0;
+
+	if (val1 != -1)
+		newval = ((newval & 0xfff0) | ((val1 / PS_TO_REG) & 0xf) << 0);
+
+	if (val2 != -1)
+		newval = ((newval & 0xff0f) | ((val2 / PS_TO_REG) & 0xf) << 4);
+
+	if (val3 != -1)
+		newval = ((newval & 0xf0ff) | ((val3 / PS_TO_REG) & 0xf) << 8);
+
+	if (val4 != -1)
+		newval = ((newval & 0x0fff) | ((val4 / PS_TO_REG) & 0xf) << 12);
+
+	return kszphy_extended_write(phydev, reg, newval);
+}
+
+static int ksz9021_config_init(struct phy_device *phydev)
+{
+	struct device *dev = &phydev->dev;
+	struct device_node *of_node = dev->of_node;
+
+	if (!of_node && dev->parent->of_node)
+		of_node = dev->parent->of_node;
+
+	if (of_node) {
+		ksz9021_load_values_from_of(phydev, of_node,
+				    MII_KSZPHY_CLK_CONTROL_PAD_SKEW,
+				    "txen-skew-ps", "txc-skew-ps",
+				    "rxdv-skew-ps", "rxc-skew-ps");
+		ksz9021_load_values_from_of(phydev, of_node,
+				    MII_KSZPHY_RX_DATA_PAD_SKEW,
+				    "rxd0-skew-ps", "rxd1-skew-ps",
+				    "rxd2-skew-ps", "rxd3-skew-ps");
+		ksz9021_load_values_from_of(phydev, of_node,
+				    MII_KSZPHY_TX_DATA_PAD_SKEW,
+				    "txd0-skew-ps", "txd1-skew-ps",
+				    "txd2-skew-ps", "txd3-skew-ps");
+	}
+	return 0;
+}
+
 #define KSZ8873MLL_GLOBAL_CONTROL_4	0x06
 #define KSZ8873MLL_GLOBAL_CONTROL_4_DUPLEX	(1 << 6)
 #define KSZ8873MLL_GLOBAL_CONTROL_4_SPEED	(1 << 4)
@@ -281,7 +382,7 @@ static struct phy_driver ksphy_driver[] = {
 	.name		= "Micrel KSZ9021 Gigabit PHY",
 	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init,
+	.config_init	= ksz9021_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
-- 
1.7.9.5
