From: Shruti Kanetkar <Shruti@Freescale.com>
Subject: [PATCH 4/4] net/phy: Add the autocross feature for forced links on VSC82x4
Date: Fri, 15 Nov 2013 16:58:25 -0600
Message-ID: <1384556305-17133-4-git-send-email-Shruti@Freescale.com>
References: <1384556305-17133-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Madalin Bucur <madalin.bucur@Freescale.com>,
	Shruti Kanetkar <Shruti@Freescale.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:43789 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753513Ab3KOW6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 17:58:48 -0500
In-Reply-To: <1384556305-17133-1-git-send-email-Shruti@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Madalin Bucur <madalin.bucur@freescale.com>

Add auto-MDI/MDI-X capability for forced (autonegotiation disabled)
10/100 Mbps speeds on Vitesse VSC82x4 PHYs. Exported previously static
function genphy_setup_forced() required by the new config_aneg handler
in the Vitesse PHY module.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
Signed-off-by: Shruti Kanetkar <Shruti@freescale.com>
---
 drivers/net/phy/phy_device.c |  4 +--
 drivers/net/phy/vitesse.c    | 75 +++++++++++++++++++++++++++++++++++++++++---
 include/linux/phy.h          |  1 +
 3 files changed, 73 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 74630e9..d6447b3 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -697,7 +697,7 @@ static int genphy_config_advert(struct phy_device *phydev)
  *   to the values in phydev. Assumes that the values are valid.
  *   Please see phy_sanitize_settings().
  */
-static int genphy_setup_forced(struct phy_device *phydev)
+int genphy_setup_forced(struct phy_device *phydev)
 {
 	int err;
 	int ctl = 0;
@@ -716,7 +716,7 @@ static int genphy_setup_forced(struct phy_device *phydev)
 
 	return err;
 }
-
+EXPORT_SYMBOL(genphy_setup_forced);
 
 /**
  * genphy_restart_aneg - Enable and Restart Autonegotiation
diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 40406bc..508e435 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -3,7 +3,7 @@
  *
  * Author: Kriston Carson
  *
- * Copyright (c) 2005, 2009 Freescale Semiconductor, Inc.
+ * Copyright (c) 2005, 2009, 2011 Freescale Semiconductor, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -18,6 +18,11 @@
 #include <linux/ethtool.h>
 #include <linux/phy.h>
 
+/* Vitesse Extended Page Magic Register(s) */
+#define MII_VSC82X4_EXT_PAGE_16E	0x10
+#define MII_VSC82X4_EXT_PAGE_17E	0x11
+#define MII_VSC82X4_EXT_PAGE_18E	0x12
+
 /* Vitesse Extended Control Register 1 */
 #define MII_VSC8244_EXT_CON1           0x17
 #define MII_VSC8244_EXTCON1_INIT       0x0000
@@ -54,6 +59,9 @@
 #define MII_VSC8221_AUXCONSTAT_INIT	0x0004 /* need to set this bit? */
 #define MII_VSC8221_AUXCONSTAT_RESERVED	0x0004
 
+/* Vitesse Extended Page Access Register */
+#define MII_VSC82X4_EXT_PAGE_ACCESS	0x1f
+
 #define PHY_ID_VSC8234			0x000fc620
 #define PHY_ID_VSC8244			0x000fc6c0
 #define PHY_ID_VSC8574			0x000704a0
@@ -154,6 +162,63 @@ static int vsc8221_config_init(struct phy_device *phydev)
 	 */
 }
 
+/* vsc82x4_config_autocross_enable - Enable auto MDI/MDI-X for forced links
+ * @phydev: target phy_device struct
+ *
+ * Enable auto MDI/MDI-X when in 10/100 forced link speeds by writing
+ * special values in the VSC8234/VSC8244 extended reserved registers
+ */
+static int vsc82x4_config_autocross_enable(struct phy_device *phydev)
+{
+	int ret;
+
+	if (phydev->autoneg == AUTONEG_ENABLE || phydev->speed > SPEED_100)
+		return 0;
+
+	/* map extended registers set 0x10 - 0x1e */
+	ret = phy_write(phydev, MII_VSC82X4_EXT_PAGE_ACCESS, 0x52b5);
+	if (ret >= 0)
+		ret = phy_write(phydev, MII_VSC82X4_EXT_PAGE_18E, 0x0012);
+	if (ret >= 0)
+		ret = phy_write(phydev, MII_VSC82X4_EXT_PAGE_17E, 0x2803);
+	if (ret >= 0)
+		ret = phy_write(phydev, MII_VSC82X4_EXT_PAGE_16E, 0x87fa);
+	/* map standard registers set 0x10 - 0x1e */
+	if (ret >= 0)
+		ret = phy_write(phydev, MII_VSC82X4_EXT_PAGE_ACCESS, 0x0000);
+	else
+		phy_write(phydev, MII_VSC82X4_EXT_PAGE_ACCESS, 0x0000);
+
+	return ret;
+}
+
+/* vsc82x4_config_aneg - restart auto-negotiation or write BMCR
+ * @phydev: target phy_device struct
+ *
+ * Description: If auto-negotiation is enabled, we configure the
+ *   advertising, and then restart auto-negotiation.  If it is not
+ *   enabled, then we write the BMCR and also start the auto
+ *   MDI/MDI-X feature
+ */
+static int vsc82x4_config_aneg(struct phy_device *phydev)
+{
+	int ret;
+
+	/* Enable auto MDI/MDI-X when in 10/100 forced link speeds by
+	 * writing special values in the VSC8234 extended reserved registers
+	 */
+	if (phydev->autoneg != AUTONEG_ENABLE && phydev->speed <= SPEED_100) {
+		ret = genphy_setup_forced(phydev);
+
+		if (ret < 0) /* error */
+			return ret;
+
+		return vsc82x4_config_autocross_enable(phydev);
+	}
+
+	return genphy_config_aneg(phydev);
+}
+
 /* Vitesse 82xx */
 static struct phy_driver vsc82xx_driver[] = {
 {
@@ -163,7 +228,7 @@ static struct phy_driver vsc82xx_driver[] = {
 	.features       = PHY_GBIT_FEATURES,
 	.flags          = PHY_HAS_INTERRUPT,
 	.config_init    = &vsc824x_config_init,
-	.config_aneg    = &genphy_config_aneg,
+	.config_aneg    = &vsc82x4_config_aneg,
 	.read_status    = &genphy_read_status,
 	.ack_interrupt  = &vsc824x_ack_interrupt,
 	.config_intr    = &vsc82xx_config_intr,
@@ -175,7 +240,7 @@ static struct phy_driver vsc82xx_driver[] = {
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &vsc824x_config_init,
-	.config_aneg	= &genphy_config_aneg,
+	.config_aneg	= &vsc82x4_config_aneg,
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
@@ -187,7 +252,7 @@ static struct phy_driver vsc82xx_driver[] = {
 	.features       = PHY_GBIT_FEATURES,
 	.flags          = PHY_HAS_INTERRUPT,
 	.config_init    = &vsc824x_config_init,
-	.config_aneg    = &genphy_config_aneg,
+	.config_aneg    = &vsc82x4_config_aneg,
 	.read_status    = &genphy_read_status,
 	.ack_interrupt  = &vsc824x_ack_interrupt,
 	.config_intr    = &vsc82xx_config_intr,
@@ -199,7 +264,7 @@ static struct phy_driver vsc82xx_driver[] = {
 	.features       = PHY_GBIT_FEATURES,
 	.flags          = PHY_HAS_INTERRUPT,
 	.config_init    = &vsc824x_config_init,
-	.config_aneg    = &genphy_config_aneg,
+	.config_aneg    = &vsc82x4_config_aneg,
 	.read_status    = &genphy_read_status,
 	.ack_interrupt  = &vsc824x_ack_interrupt,
 	.config_intr    = &vsc82xx_config_intr,
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 64ab823..48a4dc3 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -559,6 +559,7 @@ static inline int phy_read_status(struct phy_device *phydev) {
 	return phydev->drv->read_status(phydev);
 }
 
+int genphy_setup_forced(struct phy_device *phydev);
 int genphy_restart_aneg(struct phy_device *phydev);
 int genphy_config_aneg(struct phy_device *phydev);
 int genphy_update_link(struct phy_device *phydev);
-- 
1.8.3.1
