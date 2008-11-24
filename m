From: Trent Piepho <tpiepho@freescale.com>
Subject: [PATCH] phylib: Add Vitesse VSC8221 SGMII PHY
Date: Mon, 24 Nov 2008 15:28:36 -0800
Message-ID: <1227569316-28242-1-git-send-email-tpiepho@freescale.com>
Cc: Trent Piepho <tpiepho@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:38709 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939AbYKXXg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 18:36:28 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id mAONaEPQ011817
	for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 16:36:26 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PHY is mostly compatible with the existing VSC8244 PHY.  The init sequence
is different and the interrupt mask lacks some bits present in the VSC8244.

Rather than making a copy of the existing VSC234x config_intr function and
change one constant, I modify it to select the interrupt mask based on
which driver is calling it.  This lets it be used by both drivers.

Signed-off-by: Trent Piepho <tpiepho@freescale.com>
---
 drivers/net/phy/vitesse.c |   64 ++++++++++++++++++++++++++++++++++++++------
 1 files changed, 55 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 8874497..dd3b244 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -34,6 +34,8 @@
 #define MII_VSC8244_IMASK_DUPLEX	0x1000
 #define MII_VSC8244_IMASK_MASK		0xf000
 
+#define MII_VSC8221_IMASK_MASK		0xa000
+
 /* Vitesse Interrupt Status Register */
 #define MII_VSC8244_ISTAT		0x1a
 #define MII_VSC8244_ISTAT_STATUS	0x8000
@@ -49,6 +51,12 @@
 #define MII_VSC8244_AUXCONSTAT_GBIT    	0x0010
 #define MII_VSC8244_AUXCONSTAT_100     	0x0008
 
+#define MII_VSC8221_AUXCONSTAT_INIT	0x0004 /* need to set this bit? */
+#define MII_VSC8221_AUXCONSTAT_RESERVED	0x0004
+
+#define PHY_ID_VSC8244			0x000fc6c0
+#define PHY_ID_VSC8221			0x000fc550
+
 MODULE_DESCRIPTION("Vitesse PHY driver");
 MODULE_AUTHOR("Kriston Carson");
 MODULE_LICENSE("GPL");
@@ -95,13 +103,15 @@ static int vsc824x_ack_interrupt(struct phy_device *phydev)
 	return (err < 0) ? err : 0;
 }
 
-static int vsc824x_config_intr(struct phy_device *phydev)
+static int vsc82xx_config_intr(struct phy_device *phydev)
 {
 	int err;
 
 	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
 		err = phy_write(phydev, MII_VSC8244_IMASK,
-				MII_VSC8244_IMASK_MASK);
+			phydev->drv->phy_id == PHY_ID_VSC8244 ?
+				MII_VSC8244_IMASK_MASK :
+				MII_VSC8221_IMASK_MASK);
 	else {
 		/*
 		 * The Vitesse PHY cannot clear the interrupt
@@ -120,7 +130,7 @@ static int vsc824x_config_intr(struct phy_device *phydev)
 
 /* Vitesse 824x */
 static struct phy_driver vsc8244_driver = {
-	.phy_id		= 0x000fc6c0,
+	.phy_id		= PHY_ID_VSC8244,
 	.name		= "Vitesse VSC8244",
 	.phy_id_mask	= 0x000fffc0,
 	.features	= PHY_GBIT_FEATURES,
@@ -129,19 +139,55 @@ static struct phy_driver vsc8244_driver = {
 	.config_aneg	= &genphy_config_aneg,
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
-	.config_intr	= &vsc824x_config_intr,
+	.config_intr	= &vsc82xx_config_intr,
 	.driver 	= { .owner = THIS_MODULE,},
 };
 
-static int __init vsc8244_init(void)
+static int vsc8221_config_init(struct phy_device *phydev)
 {
-	return phy_driver_register(&vsc8244_driver);
+	int err;
+
+	err = phy_write(phydev, MII_VSC8244_AUX_CONSTAT,
+			MII_VSC8221_AUXCONSTAT_INIT);
+	return err;
+
+	/* Perhaps we should set EXT_CON1 based on the interface?
+	   Options are 802.3Z SerDes or SGMII */
+}
+
+/* Vitesse 8221 */
+static struct phy_driver vsc8221_driver = {
+	.phy_id		= PHY_ID_VSC8221,
+	.phy_id_mask	= 0x000ffff0,
+	.name		= "Vitesse VSC8221",
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_init	= &vsc8221_config_init,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &vsc824x_ack_interrupt,
+	.config_intr	= &vsc82xx_config_intr,
+	.driver 	= { .owner = THIS_MODULE,},
+};
+
+static int __init vsc82xx_init(void)
+{
+	int err;
+
+	err = phy_driver_register(&vsc8244_driver);
+	if (err < 0)
+		return err;
+	err = phy_driver_register(&vsc8221_driver);
+	if (err < 0)
+		phy_driver_unregister(&vsc8244_driver);
+	return err;
 }
 
-static void __exit vsc8244_exit(void)
+static void __exit vsc82xx_exit(void)
 {
 	phy_driver_unregister(&vsc8244_driver);
+	phy_driver_unregister(&vsc8221_driver);
 }
 
-module_init(vsc8244_init);
-module_exit(vsc8244_exit);
+module_init(vsc82xx_init);
+module_exit(vsc82xx_exit);
-- 
1.5.4.1

