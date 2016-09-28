From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH v4 net-next] net: phy: Add Edge-rate driver for Microsemi PHYs.
Date: Wed, 28 Sep 2016 17:04:09 +0530
Message-ID: <1475062449-22168-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0049.outbound.protection.outlook.com ([104.47.33.49]:17570
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753103AbcI1LeU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 07:34:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

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

Edge-rate parameters (vddmac, edge-slowdown) get from Device Tree.

Tested on Beaglebone Black with VSC 8531 PHY.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

---

All the review comments updated and resending for review.

Change set:
v1:
- Initial version of Edge-rate driver add by using IOCTL.
v2:
- Changed edge-rate parameter to Device Tree with magic number.
v3:
- Added Device Tree documentati0n and edge-rate parameter table.
  Added probe function initialize the vsc8531 private data structure.
v4:
- As per review comment, Device Tree parameters (vddmac, edge-slowdowni)
  added.

---

 .../devicetree/bindings/net/mscc-phy-vsc8531.txt   |  58 ++++++++++
 drivers/net/phy/mscc.c                             | 125 +++++++++++++++++++++
 include/dt-bindings/net/mscc-phy-vsc8531.h         |  21 ++++
 3 files changed, 204 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
 create mode 100644 include/dt-bindings/net/mscc-phy-vsc8531.h

diff --git a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
new file mode 100644
index 0000000..951043e
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
@@ -0,0 +1,58 @@
+* Microsemi - vsc8531 Giga bit ethernet phy
+
+Required properties:
+- compatible	: Should contain phy id as "ethernet-phy-idAAAA.BBBB"
+		  The PHY device uses the binding described in
+		  Documentation/devicetree/bindings/net/phy.txt
+
+Optional properties:
+- vsc8531,vddmac	: The vddmac in mV.
+- vsc8531,edge-slowdown	: % the edge should be slowed down relative to
+			  the fastest possible edge time. Native sign
+			  need not enter.
+			  Edge rate sets the drive strength of the MAC
+			  interface output signals.  Changing the drive
+			  strength will affect the edge rate of the output
+			  signal.  The goal of this setting is to help
+			  reduce electrical emission (EMI) by being able
+			  to reprogram drive strength and in effect slow
+			  down the edge rate if desired.  Table 5 shows the
+			  impact to the edge rate per VDDMAC supply for each
+			  drive strength setting.
+			  Ref: Table:1 - Edge rate change below.
+
+Note: see dt-bindings/net/mscc-phy-vsc8531.h for applicable values
+
+Table: 1 - Edge rate change
+----------------------------------------------------------------|
+| 		Edge Rate Change (VDDMAC)			|
+|								|
+| 3300 mV	2500 mV		1800 mV		1500 mV		|
+|---------------------------------------------------------------|
+| Default	Deafult		Default		Default		|
+| (Fastest)			(recommended)	(recommended)	|
+|---------------------------------------------------------------|
+| -2%		-3%		-5%		-6%		|
+|---------------------------------------------------------------|
+| -4%		-6%		-9%		-14%		|
+|---------------------------------------------------------------|
+| -7%		-10%		-16%		-21%		|
+|(recommended)	(recommended)					|
+|---------------------------------------------------------------|
+| -10%		-14%		-23%		-29%		|
+|---------------------------------------------------------------|
+| -17%		-23%		-35%		-42%		|
+|---------------------------------------------------------------|
+| -29%		-37%		-52%		-58%		|
+|---------------------------------------------------------------|
+| -53%		-63%		-76%		-77%		|
+| (slowest)							|
+|---------------------------------------------------------------|
+
+Example:
+
+        vsc8531_0: ethernet-phy@0 {
+                compatible = "ethernet-phy-id0007.0570";
+                vsc8531,vddmac		= /bits/ 16 <MSCC_VDDMAC_3300>;
+                vsc8531,edge-slowdown	= /bits/ 8  <17>;
+        };
diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index d350deb..a17573e 100644
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
@@ -50,6 +56,23 @@ enum rgmii_rx_clock_delay {
 #define PHY_ID_VSC8531			  0x00070570
 #define PHY_ID_VSC8541			  0x00070770
 
+struct edge_rate_table {
+	u16 vddmac;
+	int slowdown[MSCC_SLOWDOWN_MAX];
+};
+
+struct edge_rate_table edge_table[MSCC_VDDMAC_MAX] = {
+	{3300, { 0, -2, -4,  -7,  -10, -17, -29, -53} },
+	{2500, { 0, -3, -6,  -10, -14, -23, -37, -63} },
+	{1800, { 0, -5, -9,  -16, -23, -35, -52, -76} },
+	{1500, { 0, -6, -14, -21, -29, -42, -58, -77} },
+};
+
+struct vsc8531_private {
+	u8 edge_slowdown;
+	u16 vddmac;
+};
+
 static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 {
 	int rc;
@@ -58,6 +81,51 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 	return rc;
 }
 
+static u8 edge_rate_magic_get(u16 vddmac,
+			      int slowdown)
+{
+	int rc = (MSCC_SLOWDOWN_MAX - 1);
+	u8 vdd;
+	u8 sd;
+
+	for (vdd = 0; vdd < MSCC_VDDMAC_MAX; vdd++) {
+		if (edge_table[vdd].vddmac == vddmac) {
+			for (sd = 0; sd < MSCC_SLOWDOWN_MAX; sd++) {
+				if (edge_table[vdd].slowdown[sd] <= slowdown) {
+					rc = (MSCC_SLOWDOWN_MAX - sd - 1);
+					break;
+				}
+			}
+		}
+	}
+
+	return rc;
+}
+
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
@@ -116,9 +184,45 @@ out_unlock:
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
+	rc = of_property_read_u16(of_node, "vsc8531,vddmac",
+				  &vsc8531->vddmac);
+	if (rc == -EINVAL)
+		vsc8531->vddmac = MSCC_VDDMAC_3300;
+	rc = of_property_read_u8(of_node, "vsc8531,edge-slowdown",
+				 &vsc8531->edge_slowdown);
+	if (rc == -EINVAL)
+		vsc8531->edge_slowdown = 0;
+
+	rc = 0;
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
+	u8 edge_rate;
+
+	rc = vsc8531_of_init(phydev);
+	if (rc)
+		return rc;
 
 	rc = vsc85xx_default_config(phydev);
 	if (rc)
@@ -128,6 +232,12 @@ static int vsc85xx_config_init(struct phy_device *phydev)
 	if (rc)
 		return rc;
 
+	edge_rate = edge_rate_magic_get(vsc8531->vddmac,
+					-(int)vsc8531->edge_slowdown);
+	rc = vsc85xx_edge_rate_cntl_set(phydev, edge_rate);
+	if (rc)
+		return rc;
+
 	rc = genphy_config_init(phydev);
 
 	return rc;
@@ -160,6 +270,19 @@ static int vsc85xx_config_intr(struct phy_device *phydev)
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
@@ -177,6 +300,7 @@ static struct phy_driver vsc85xx_driver[] = {
 	.config_intr    = &vsc85xx_config_intr,
 	.suspend	= &genphy_suspend,
 	.resume		= &genphy_resume,
+	.probe          = &vsc85xx_probe,
 },
 {
 	.phy_id		= PHY_ID_VSC8541,
@@ -193,6 +317,7 @@ static struct phy_driver vsc85xx_driver[] = {
 	.config_intr    = &vsc85xx_config_intr,
 	.suspend	= &genphy_suspend,
 	.resume		= &genphy_resume,
+	.probe          = &vsc85xx_probe,
 }
 
 };
diff --git a/include/dt-bindings/net/mscc-phy-vsc8531.h b/include/dt-bindings/net/mscc-phy-vsc8531.h
new file mode 100644
index 0000000..2383dd2
--- /dev/null
+++ b/include/dt-bindings/net/mscc-phy-vsc8531.h
@@ -0,0 +1,21 @@
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
+/* MAC interface Edge rate control VDDMAC in milli Volts */
+#define MSCC_VDDMAC_3300		 3300
+#define MSCC_VDDMAC_2500		 2500
+#define MSCC_VDDMAC_1800		 1800
+#define MSCC_VDDMAC_1500		 1500
+#define MSCC_VDDMAC_MAX			 4
+#define MSCC_SLOWDOWN_MAX		 8
+
+#endif
-- 
2.7.4
