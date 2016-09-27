From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH v3 net-next] net: phy: Add Edge-rate driver for Microsemi PHYs.
Date: Tue, 27 Sep 2016 19:17:55 +0530
Message-ID: <1474984075-12312-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0086.outbound.protection.outlook.com ([104.47.37.86]:20608
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934109AbcI0Ns0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Sep 2016 09:48:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

All the review comments updated and resending for review.

Edge-rate:
As system and networking speeds increase, a signal's output transition,
also know as the edge rate or slew rate (V/ns), takes on greater importance
because high-speed signals come with a price. That price is an assortment of
interference problems like ringing on the line, signal overshoot and
undershoot, extended signal settling times, crosstalk noise, transmission
line reflections, false signal detection by the receiving device and
electromagnetic interference (EMI) -- all of which can negate the potential
gains designers are seeking when they try to increase system speeds through
the use of higher performance logic devices. The fact is, faster signaling
edge rates can cause a higher level of electrical noise or other type of
interference that can actually lead to slower line speeds and lower maximum
system frequencies. This parameter allow the board designers to change the 
driving strange, and thereby change the EMI behavioral.

Edge-rate value get from Device Tree.

Tested on Beaglebone Black with VSC 8531 PHY.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

---
Change set:
v1:
- Initial version of Edge-rate driver add by using IOCTL.
v2: 
- Changed edge-rate parameter to Device Tree with magic number.
v3: 
- Added Device Tree documentati0n and edge-rate parameter table.
  Added probe function initialize the vsc8531 private data structure.
---

 .../devicetree/bindings/net/mscc-phy-vsc8531.txt   | 61 ++++++++++++++++
 drivers/net/phy/mscc.c                             | 85 ++++++++++++++++++++++
 include/dt-bindings/net/mscc-phy-vsc8531.h         | 23 ++++++
 3 files changed, 169 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
 create mode 100644 include/dt-bindings/net/mscc-phy-vsc8531.h

diff --git a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
new file mode 100644
index 0000000..7ba3855
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
@@ -0,0 +1,61 @@
+* Microsemi - vsc8531 Giga bit ethernet phy
+
+Required properties:
+- compatible	: Should contain phy id as "ethernet-phy-idAAAA.BBBB"
+		  If the phy's identifier is known then the list may contain an entry
+		  of the form: "ethernet-phy-idAAAA.BBBB" where
+		  AAAA - The value of the 16 bit Phy Identifier 1 register as
+			 4 hex digits. This is the chip vendor OUI bits 3:18
+		  BBBB - The value of the 16 bit Phy Identifier 2 register as
+			 4 hex digits. This is the chip vendor OUI bits 19:24,
+			 followed by 10 bits of a vendor specific ID.
+- reg		: The ID number for the phy, usually a small integer
+
+Optional properties:
+- vsc8531,edge-rate	: Edge rate sets the drive strength of the MAC
+			  interface output signals.  Changing the drive
+			  strength will affect the edge rate of the output
+			  signal.  The goal of this setting is to help
+			  reduce electrical emission (EMI) by being able
+			  to reprogram drive strength and in effect slow
+			  down the edge rate if desired.  Table 5 shows the
+			  impact to the edge rate per VDDMAC supply for each
+			  drive strength setting. Default edge rate is set as
+			  Fastest edge rate (i.e. 7).
+			  Ref: Table:1 - Edge rate change below.
+
+Note: see dt-bindings/net/mscc-vsc8531.h for applicable values
+
+Table: 1 - Edge rate change
+-----------------------------------------------------------------------------|
+|                             Edge Rate Change (VDDMAC)                      |
+|									     |
+| Reg Setting	3.3V		2.5V		1.8V		1.5V         |
+|----------------------------------------------------------------------------|
+| 111 		Default		Deafult		Default		Default      |
+| (Fastest)					(recommended)	(recommended)|
+|----------------------------------------------------------------------------|
+| 110		-2%		-3%		-5%		-6%          |
+|----------------------------------------------------------------------------|
+| 101		-4%		-6%		-9%		-14%         |
+|----------------------------------------------------------------------------|
+| 100		-7%		-10%		-16%		-21%         |
+|		(recommended)	(recommended)                                |
+|----------------------------------------------------------------------------|
+| 011		-10%		-14%		-23%		-29%         |
+|----------------------------------------------------------------------------|
+| 010		-17%		-23%		-35%		-42%         |
+|----------------------------------------------------------------------------|
+| 001		-29%		-37%		-52%		-58%         |
+|----------------------------------------------------------------------------|
+| 000		-53%		-63%		-76%		-77%         |
+| (slowest)								     |
+|----------------------------------------------------------------------------|
+
+Example:
+
+        vsc8531_0: ethernet-phy@0 {
+                compatible = "ethernet-phy-id0007.0570";
+                reg = <0>;
+                vsc8531,edge-rate = /bits/ 8 <MSCC_EDGE_RATE_CNTL_FASTEST>;
+        };
diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index d350deb..de29354 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -11,6 +11,8 @@
 #include <linux/mdio.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/of.h>
+#include <dt-bindings/net/mscc-phy-vsc8531.h>
 
 enum rgmii_rx_clock_delay {
 	RGMII_RX_CLK_DELAY_0_2_NS = 0,
@@ -37,6 +39,10 @@ enum rgmii_rx_clock_delay {
 #define MII_VSC85XX_INT_MASK_MASK	  0xa000
 #define MII_VSC85XX_INT_STATUS		  26
 
+#define MSCC_PHY_WOL_MAC_CONTROL          27
+#define EDGE_RATE_CNTL_POS                5
+#define EDGE_RATE_CNTL_MASK               0x00E0
+
 #define MSCC_EXT_PAGE_ACCESS		  31
 #define MSCC_PHY_PAGE_STANDARD		  0x0000 /* Standard registers */
 #define MSCC_PHY_PAGE_EXTENDED_2	  0x0002 /* Extended reg - page 2 */
@@ -50,6 +56,10 @@ enum rgmii_rx_clock_delay {
 #define PHY_ID_VSC8531			  0x00070570
 #define PHY_ID_VSC8541			  0x00070770
 
+struct vsc8531_private {
+	u8 edge_rate;
+};
+
 static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 {
 	int rc;
@@ -58,6 +68,30 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 	return rc;
 }
 
+static int vsc85xx_edge_rate_cntl_set(struct phy_device *phydev,
+				      u8 edge_rate)
+{
+	int rc;
+	u16 reg_val;
+
+	mutex_lock(&phydev->lock);
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
+	if (rc != 0)
+		goto out_unlock;
+	reg_val = phy_read(phydev, MSCC_PHY_WOL_MAC_CONTROL);
+	reg_val &= ~(EDGE_RATE_CNTL_MASK);
+	reg_val |= (edge_rate << EDGE_RATE_CNTL_POS);
+	rc = phy_write(phydev, MSCC_PHY_WOL_MAC_CONTROL, reg_val);
+	if (rc != 0)
+		goto out_unlock;
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+
+out_unlock:
+	mutex_unlock(&phydev->lock);
+
+	return rc;
+}
+
 static int vsc85xx_mac_if_set(struct phy_device *phydev,
 			      phy_interface_t interface)
 {
@@ -116,9 +150,41 @@ out_unlock:
 	return rc;
 }
 
+#ifdef CONFIG_OF_MDIO
+static int vsc8531_of_init(struct phy_device *phydev)
+{
+	int rc;
+	struct vsc8531_private *vsc8531 = phydev->priv;
+	struct device *dev = &phydev->mdio.dev;
+	struct device_node *of_node = dev->of_node;
+
+	if (!of_node)
+		return -ENODEV;
+
+	rc = of_property_read_u8(of_node, "vsc8531,edge-rate",
+				 &vsc8531->edge_rate);
+	if (rc == -EINVAL) {
+		vsc8531->edge_rate = MSCC_EDGE_RATE_CNTL_FASTEST;
+		rc = 0;
+	}
+
+	return rc;
+}
+#else
+static int vsc8531_of_init(struct phy_device *phydev)
+{
+	return 0;
+}
+#endif /* CONFIG_OF_MDIO */
+
 static int vsc85xx_config_init(struct phy_device *phydev)
 {
 	int rc;
+	struct vsc8531_private *vsc8531 = phydev->priv;
+
+	rc = vsc8531_of_init(phydev);
+	if (rc)
+		return rc;
 
 	rc = vsc85xx_default_config(phydev);
 	if (rc)
@@ -128,6 +194,10 @@ static int vsc85xx_config_init(struct phy_device *phydev)
 	if (rc)
 		return rc;
 
+	rc = vsc85xx_edge_rate_cntl_set(phydev, vsc8531->edge_rate);
+	if (rc)
+		return rc;
+
 	rc = genphy_config_init(phydev);
 
 	return rc;
@@ -160,6 +230,19 @@ static int vsc85xx_config_intr(struct phy_device *phydev)
 	return rc;
 }
 
+static int vsc85xx_probe(struct phy_device *phydev)
+{
+	struct vsc8531_private *vsc8531;
+
+	vsc8531 = devm_kzalloc(&phydev->mdio.dev, sizeof(*vsc8531), GFP_KERNEL);
+	if (!vsc8531)
+		return -ENOMEM;
+
+	phydev->priv = vsc8531;
+
+	return 0;
+}
+
 /* Microsemi VSC85xx PHYs */
 static struct phy_driver vsc85xx_driver[] = {
 {
@@ -177,6 +260,7 @@ static struct phy_driver vsc85xx_driver[] = {
 	.config_intr    = &vsc85xx_config_intr,
 	.suspend	= &genphy_suspend,
 	.resume		= &genphy_resume,
+	.probe          = &vsc85xx_probe,
 },
 {
 	.phy_id		= PHY_ID_VSC8541,
@@ -193,6 +277,7 @@ static struct phy_driver vsc85xx_driver[] = {
 	.config_intr    = &vsc85xx_config_intr,
 	.suspend	= &genphy_suspend,
 	.resume		= &genphy_resume,
+	.probe          = &vsc85xx_probe,
 }
 
 };
diff --git a/include/dt-bindings/net/mscc-phy-vsc8531.h b/include/dt-bindings/net/mscc-phy-vsc8531.h
new file mode 100644
index 0000000..e245f40
--- /dev/null
+++ b/include/dt-bindings/net/mscc-phy-vsc8531.h
@@ -0,0 +1,23 @@
+/*
+ * Device Tree constants for Microsemi VSC8531 PHY
+ *
+ * Author: Nagaraju Lakkaraju
+ *
+ * License: Dual MIT/GPL
+ * Copyright (c) 2016 Microsemi Corporation
+ */
+
+#ifndef _DT_BINDINGS_MSCC_VSC8531_H
+#define _DT_BINDINGS_MSCC_VSC8531_H
+
+/* MAC interface Edge rate control pad */
+#define MSCC_EDGE_RATE_CNTL_SLOWEST      0
+#define MSCC_EDGE_RATE_CNTL_PLUS_1       1
+#define MSCC_EDGE_RATE_CNTL_PLUS_2       2
+#define MSCC_EDGE_RATE_CNTL_PLUS_3       3
+#define MSCC_EDGE_RATE_CNTL_PLUS_4       4
+#define MSCC_EDGE_RATE_CNTL_PLUS_5       5
+#define MSCC_EDGE_RATE_CNTL_PLUS_6       6
+#define MSCC_EDGE_RATE_CNTL_FASTEST      7
+
+#endif
-- 
2.7.4
