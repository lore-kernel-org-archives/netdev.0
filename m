From: Sean Cross <xobs@kosagi.com>
Subject: [PATCH v2] net/phy: micrel: Add OF configuration support
Date: Thu,  1 Aug 2013 06:53:54 +0000
Message-ID: <1375340034-23846-2-git-send-email-xobs@kosagi.com>
References: <1375340034-23846-1-git-send-email-xobs@kosagi.com>
Cc: David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sean Cross <xobs@kosagi.com>
To: Duan Fugang-B38611 <B38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.g1.pair.com ([66.39.3.162]:55631 "EHLO mail1.g1.pair.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751040Ab3HAHLR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 03:11:17 -0400
In-Reply-To: <1375340034-23846-1-git-send-email-xobs@kosagi.com>
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
 .../devicetree/bindings/net/micrel-phy.txt         |   20 ++++++++
 drivers/net/phy/micrel.c                           |   50 ++++++++++++++++++++
 2 files changed, 70 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/micrel-phy.txt

diff --git a/Documentation/devicetree/bindings/net/micrel-phy.txt b/Documentation/devicetree/bindings/net/micrel-phy.txt
new file mode 100644
index 0000000..97c1ef2
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/micrel-phy.txt
@@ -0,0 +1,20 @@
+Micrel KS8737, KSZ8041, KSZ8001, KS8721, KSZ8081, KSZ8091, KSZ8061, KSZ9021,
+KSZ9031, Ethernet PHYs, and KSZ8873MLL and KSZ886X Ethernet switches.
+
+Some boards require special tuning values, particularly when it comes to
+clock delays.  You can specify clock delay values by adding
+micrel-specific properties to an Ethernet OF device node.
+
+Optional properties:
+- micrel,clk-control-pad-skew : Timing offset for the MII clock line
+- micrel,rx-data-pad-skew : Timing offset for the RX MII pad
+- micrel,tx-data-pad-skew : Timing offset for the TX MII pad
+
+Example:
+	&enet {
+		micrel,clk-control-pad-skew = <0xf0f0>;
+		micrel,rx-data-pad-skew = <0x0000>;
+		micrel,tx-data-pad-skew = <0xffff>;
+		status = "okay";
+	};
+
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 2510435..e20aeee 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -25,6 +25,7 @@
 #include <linux/module.h>
 #include <linux/phy.h>
 #include <linux/micrel_phy.h>
+#include <linux/of.h>
 
 /* Operation Mode Strap Override */
 #define MII_KSZPHY_OMSO				0x16
@@ -53,6 +54,18 @@
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
 static int ksz_config_flags(struct phy_device *phydev)
 {
 	int regval;
@@ -65,6 +78,13 @@ static int ksz_config_flags(struct phy_device *phydev)
 	return 0;
 }
 
+static int kszphy_extended_write(struct phy_device *phydev,
+                                 u32 regnum, u16 val)
+{
+	phy_write(phydev, MII_KSZPHY_EXTREG, KSZPHY_EXTREG_WRITE | regnum);
+	return phy_write(phydev, MII_KSZPHY_EXTREG_WRITE, val);
+}
+
 static int kszphy_ack_interrupt(struct phy_device *phydev)
 {
 	/* bit[7..0] int status, which is a read and clear register. */
@@ -121,6 +141,36 @@ static int ks8737_config_intr(struct phy_device *phydev)
 
 static int kszphy_config_init(struct phy_device *phydev)
 {
+	struct device *dev = &phydev->dev;
+	struct device_node *of_node = dev->of_node;
+
+	if (!of_node && dev->parent->of_node)
+		of_node = dev->parent->of_node;
+
+	if (of_node) {
+		u32 val;
+
+		if (!of_property_read_u32(of_node,
+					  "micrel,clk-control-pad-skew",
+					  &val))
+			kszphy_extended_write(phydev,
+					      MII_KSZPHY_CLK_CONTROL_PAD_SKEW,
+					      val);
+
+		if (!of_property_read_u32(of_node,
+					  "micrel,rx-data-pad-skew",
+					  &val))
+			kszphy_extended_write(phydev,
+					      MII_KSZPHY_RX_DATA_PAD_SKEW,
+					      val);
+
+		if (!of_property_read_u32(of_node,
+					  "micrel,tx-data-pad-skew",
+					  &val))
+			kszphy_extended_write(phydev,
+					      MII_KSZPHY_TX_DATA_PAD_SKEW,
+					      val);
+	}
 	return 0;
 }
 
-- 
1.7.9.5
