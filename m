From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH 2/2] phylib: Modify Vitesse RGMII skew settings
Date: Thu, 13 Oct 2011 09:33:55 -0500
Message-ID: <1318516435-24314-2-git-send-email-afleming@freescale.com>
References: <1318516435-24314-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:8660 "EHLO
	TX2EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822Ab1JMOg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 10:36:28 -0400
In-Reply-To: <1318516435-24314-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Vitesse driver was using the RGMII_ID interface type to determine if
skew was necessary.  However, we want to move away from using that
interface type, as it's really a property of the board's PHY connection.
However, some boards depend on it, so we want to support it, while
allowing new boards to use the more flexible "fixups" approach.  To do
this, we extract the code which adds skew into its own function, and
call that function when RGMII_ID has been selected.

Another side-effect of this change is that if your PHY has skew set
already, it doesn't clear it.  This way, the fixup code can modify the
register without config_init then clearing it.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/phy/vitesse.c |   34 ++++++++++++++++++++++------------
 1 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 5d8f6e1..0ec8e09 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -3,7 +3,7 @@
  *
  * Author: Kriston Carson
  *
- * Copyright (c) 2005 Freescale Semiconductor, Inc.
+ * Copyright (c) 2005, 2009 Freescale Semiconductor, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -61,32 +61,42 @@ MODULE_DESCRIPTION("Vitesse PHY driver");
 MODULE_AUTHOR("Kriston Carson");
 MODULE_LICENSE("GPL");
 
-static int vsc824x_config_init(struct phy_device *phydev)
+int vsc824x_add_skew(struct phy_device *phydev)
 {
-	int extcon;
 	int err;
-
-	err = phy_write(phydev, MII_VSC8244_AUX_CONSTAT,
-			MII_VSC8244_AUXCONSTAT_INIT);
-	if (err < 0)
-		return err;
+	int extcon;
 
 	extcon = phy_read(phydev, MII_VSC8244_EXT_CON1);
 
 	if (extcon < 0)
-		return err;
+		return extcon;
 
 	extcon &= ~(MII_VSC8244_EXTCON1_TX_SKEW_MASK |
 			MII_VSC8244_EXTCON1_RX_SKEW_MASK);
 
-	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
-		extcon |= (MII_VSC8244_EXTCON1_TX_SKEW |
-				MII_VSC8244_EXTCON1_RX_SKEW);
+	extcon |= (MII_VSC8244_EXTCON1_TX_SKEW |
+			MII_VSC8244_EXTCON1_RX_SKEW);
 
 	err = phy_write(phydev, MII_VSC8244_EXT_CON1, extcon);
 
 	return err;
 }
+EXPORT_SYMBOL(vsc824x_add_skew);
+
+static int vsc824x_config_init(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_write(phydev, MII_VSC8244_AUX_CONSTAT,
+			MII_VSC8244_AUXCONSTAT_INIT);
+	if (err < 0)
+		return err;
+
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
+		err = vsc824x_add_skew(phydev);
+
+	return err;
+}
 
 static int vsc824x_ack_interrupt(struct phy_device *phydev)
 {
-- 
1.7.3.4
