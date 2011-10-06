From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH 1/3] net/phy: added autocross feature for forced links on VSC82x4
Date: Thu, 6 Oct 2011 19:48:33 +0300
Message-ID: <1317919713-25840-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <afleming@freescale.com>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe002.messaging.microsoft.com ([216.32.180.12]:14324
	"EHLO VA3EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758253Ab1JFQsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 12:48:10 -0400
Received: from mail18-va3 (localhost.localdomain [127.0.0.1])	by
 mail18-va3-R.bigfish.com (Postfix) with ESMTP id F3FC9EF02BC	for
 <netdev@vger.kernel.org>; Thu,  6 Oct 2011 16:48:08 +0000 (UTC)
Received: from VA3EHSMHS026.bigfish.com (unknown [10.7.14.254])	by
 mail18-va3.bigfish.com (Postfix) with ESMTP id A0F6EB6004F	for
 <netdev@vger.kernel.org>; Thu,  6 Oct 2011 16:48:08 +0000 (UTC)
Received: from madalin-fedora64.ea.freescale.net
 (udp126375uds.ea.freescale.net [10.171.73.201])	by az33smr01.freescale.net
 (8.13.1/8.13.0) with ESMTP id p96Gm1TN004844	for <netdev@vger.kernel.org>;
 Thu, 6 Oct 2011 11:48:04 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added auto MDI/MDI-X capability for forced (autonegotiation disabled)
10/100 Mbps speeds on Vitesse VSC82x4 PHYs.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 drivers/net/phy/phy_device.c |    5 ++-
 drivers/net/phy/vitesse.c    |   67 ++++++++++++++++++++++++++++++++++++++++--
 include/linux/phy.h          |    3 +-
 3 files changed, 69 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 7216e68..a1e132c 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -6,7 +6,7 @@
  *
  * Author: Andy Fleming
  *
- * Copyright (c) 2004-2006, 2008-2010 Freescale Semiconductor, Inc.
+ * Copyright (c) 2004-2006, 2008-2011 Freescale Semiconductor, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -637,7 +637,7 @@ EXPORT_SYMBOL(gen10g_config_advert);
  *   to the values in phydev. Assumes that the values are valid.
  *   Please see phy_sanitize_settings().
  */
-static int genphy_setup_forced(struct phy_device *phydev)
+int genphy_setup_forced(struct phy_device *phydev)
 {
 	int err;
 	int ctl = 0;
@@ -656,6 +656,7 @@ static int genphy_setup_forced(struct phy_device *phydev)
 
 	return err;
 }
+EXPORT_SYMBOL(genphy_setup_forced);
 
 int gen10g_setup_forced(struct phy_device *phydev)
 {
diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index d0f36a1..ae87c1c 100644
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
@@ -45,6 +45,10 @@
 
 /* Vitesse Auxiliary Control/Status Register */
 #define MII_VSC8244_AUX_CONSTAT        	0x1c
+#define MII_VSC82X4_EXT_PAGE_16E	0x10
+#define MII_VSC82X4_EXT_PAGE_17E	0x11
+#define MII_VSC82X4_EXT_PAGE_18E	0x12
+#define MII_VSC82X4_EXT_PAGE_ACCESS	0x1f
 #define MII_VSC8244_AUXCONSTAT_INIT    	0x0000
 #define MII_VSC8244_AUXCONSTAT_DUPLEX  	0x0020
 #define MII_VSC8244_AUXCONSTAT_SPEED   	0x0018
@@ -140,6 +144,63 @@ static int vsc82xx_config_intr(struct phy_device *phydev)
 	return err;
 }
 
+/* vsc82x4_config_autocross_enable - Enable auto MDI/MDI-X for forced links
+ * @phydev: target phy_device struct
+ *
+ * Enable auto MDI/MDI-X when in 10/100 forced link speeds by writing
+ * special values in the VSC8234/VSC8244 extended reserved registers
+ *
+ */
+static int vsc82x4_config_autocross_enable(struct phy_device *phydev)
+{
+	int result;
+
+	if (AUTONEG_ENABLE == phydev->autoneg || phydev->speed > SPEED_100)
+		return 0;
+
+	result = phy_write(phydev, MII_VSC82X4_EXT_PAGE_ACCESS, 0x52b5);
+	if (result >= 0)
+		result = phy_write(phydev, MII_VSC82X4_EXT_PAGE_18E, 0x0012);
+	if (result >= 0)
+		result = phy_write(phydev, MII_VSC82X4_EXT_PAGE_17E, 0x2803);
+	if (result >= 0)
+		result = phy_write(phydev, MII_VSC82X4_EXT_PAGE_16E, 0x87fa);
+	if (result >= 0)
+		result = phy_write(phydev, MII_VSC82X4_EXT_PAGE_ACCESS, 0x0000);
+	else
+		phy_write(phydev, MII_VSC82X4_EXT_PAGE_ACCESS, 0x0000);
+
+	return result;
+}
+
+/**
+ * vsc82x4_config_aneg - restart auto-negotiation or write BMCR
+ * @phydev: target phy_device struct
+ *
+ * Description: If auto-negotiation is enabled, we configure the
+ *   advertising, and then restart auto-negotiation.  If it is not
+ *   enabled, then we write the BMCR and also start the auto
+ *   MDI/MDI-X feature
+ *
+ */
+static int vsc82x4_config_aneg(struct phy_device *phydev)
+{
+	int result;
+
+	/* Enable auto MDI/MDI-X when in 10/100 forced link speeds by
+	 * writing special values in the VSC8234 extended reserved registers */
+	if (AUTONEG_ENABLE != phydev->autoneg && SPEED_100 >= phydev->speed) {
+		result = genphy_setup_forced(phydev);
+
+		if (result < 0) /* error */
+			return result;
+
+		return vsc82x4_config_autocross_enable(phydev);
+	}
+
+	return genphy_config_aneg(phydev);
+}
+
 /* Vitesse 824x */
 static struct phy_driver vsc8244_driver = {
 	.phy_id		= PHY_ID_VSC8244,
@@ -148,7 +209,7 @@ static struct phy_driver vsc8244_driver = {
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &vsc824x_config_init,
-	.config_aneg	= &genphy_config_aneg,
+	.config_aneg	= &vsc82x4_config_aneg,
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
@@ -163,7 +224,7 @@ static struct phy_driver vsc8234_driver = {
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &vsc824x_config_init,
-	.config_aneg	= &genphy_config_aneg,
+	.config_aneg	= &vsc82x4_config_aneg,
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
diff --git a/include/linux/phy.h b/include/linux/phy.h
index d2d2fa4..3610a5e 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -6,7 +6,7 @@
  *
  * Author: Andy Fleming
  *
- * Copyright (c) 2004-2010 Freescale Semiconductor, Inc.
+ * Copyright (c) 2004-2011 Freescale Semiconductor, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -533,6 +533,7 @@ static inline int phy_read_status(struct phy_device *phydev) {
 	return phydev->drv->read_status(phydev);
 }
 
+int genphy_setup_forced(struct phy_device *phydev);
 int genphy_restart_aneg(struct phy_device *phydev);
 int genphy_config_aneg(struct phy_device *phydev);
 int genphy_update_link(struct phy_device *phydev);
-- 
1.7.0.1
