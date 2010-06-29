From: "Choi, David" <David.Choi@Micrel.Com>
Subject: [PATCH linux-2.6.35-rc3] micrel phy driver - updated(1)
Date: Mon, 28 Jun 2010 18:23:41 -0700
Message-ID: <C43529A246480145B0A6D0234BDB0F0D0212A3@MELANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c11o148.mxlogic.net ([208.65.144.71]:58529 "EHLO
	p01c11o148.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365Ab0F2BXp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 21:23:45 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello all:

This patch fixes what Ben mentioned, namely duplicated ids.

From: David J. Choi <david.choi@micrel.com>

Body of the explanation: This patch has changes as followings;
 -support the interrupt from phy devices from Micrel Inc.
 -support more phy devices, ks8737, ks8721, ks8041, ks8051 from Micrel.
 -remove vsc8201 because this device was used only internal test at Micrel.

Signed-off-by: David J. Choi <david.choi@micrel.com>

---
--- ./linux-2.6.35-rc3/drivers/net/phy/micrel.c.orig	2010-06-28 17:55:30.000000000 -0700
+++ ./linux-2.6.35-rc3/drivers/net/phy/micrel.c	2010-06-28 18:06:00.000000000 -0700
@@ -12,7 +12,8 @@
  * Free Software Foundation;  either version 2 of the  License, or (at your
  * option) any later version.
  *
- * Support : ksz9021 , vsc8201, ks8001
+ * Support : ksz9021 1000/100/10 phy from Micrel
+ *		ks8001, ks8737, ks8721, ks8041, ks8051 100/10 phy
  */
 
 #include <linux/kernel.h>
@@ -20,37 +21,146 @@
 #include <linux/phy.h>
 
 #define	PHY_ID_KSZ9021			0x00221611
-#define	PHY_ID_VSC8201			0x000FC413
+#define	PHY_ID_KS8737			0x00221720
+#define	PHY_ID_KS8041			0x00221510
+#define	PHY_ID_KS8051			0x00221550
+/* both for ks8001 Rev. A/B, and for ks8721 Rev 3. */
 #define	PHY_ID_KS8001			0x0022161A
 
+/* general Interrupt control/status reg in vendor specific block. */
+#define MII_KSZPHY_INTCS			0x1B
+#define	KSZPHY_INTCS_JABBER			(1 << 15)
+#define	KSZPHY_INTCS_RECEIVE_ERR		(1 << 14)
+#define	KSZPHY_INTCS_PAGE_RECEIVE		(1 << 13)
+#define	KSZPHY_INTCS_PARELLEL			(1 << 12)
+#define	KSZPHY_INTCS_LINK_PARTNER_ACK		(1 << 11)
+#define	KSZPHY_INTCS_LINK_DOWN			(1 << 10)
+#define	KSZPHY_INTCS_REMOTE_FAULT		(1 << 9)
+#define	KSZPHY_INTCS_LINK_UP			(1 << 8)
+#define	KSZPHY_INTCS_ALL			(KSZPHY_INTCS_LINK_UP |\
+						KSZPHY_INTCS_LINK_DOWN)
+
+/* general PHY control reg in vendor specific block. */
+#define	MII_KSZPHY_CTRL			0x1F
+/* bitmap of PHY register to set interrupt mode */
+#define KSZPHY_CTRL_INT_ACTIVE_HIGH		(1 << 9)
+#define KSZ9021_CTRL_INT_ACTIVE_HIGH		(1 << 14)
+#define KS8737_CTRL_INT_ACTIVE_HIGH		(1 << 14)
+
+static int kszphy_ack_interrupt(struct phy_device *phydev)
+{
+	/* bit[7..0] int status, which is a read and clear register. */
+	int rc;
+
+	rc = phy_read(phydev, MII_KSZPHY_INTCS);
+
+	return (rc < 0) ? rc : 0;
+}
+
+static int kszphy_set_interrupt(struct phy_device *phydev)
+{
+	int temp;
+	temp = (PHY_INTERRUPT_ENABLED == phydev->interrupts) ?
+		KSZPHY_INTCS_ALL : 0;
+	return phy_write(phydev, MII_KSZPHY_INTCS, temp);
+}
+
+static int kszphy_config_intr(struct phy_device *phydev)
+{
+	int temp, rc;
+
+	/* set the interrupt pin active low */
+	temp = phy_read(phydev, MII_KSZPHY_CTRL);
+	temp &= ~KSZPHY_CTRL_INT_ACTIVE_HIGH;
+	phy_write(phydev, MII_KSZPHY_CTRL, temp);
+	rc = kszphy_set_interrupt(phydev);
+	return rc < 0 ? rc : 0;
+}
+
+static int ksz9021_config_intr(struct phy_device *phydev)
+{
+	int temp, rc;
+
+	/* set the interrupt pin active low */
+	temp = phy_read(phydev, MII_KSZPHY_CTRL);
+	temp &= ~KSZ9021_CTRL_INT_ACTIVE_HIGH;
+	phy_write(phydev, MII_KSZPHY_CTRL, temp);
+	rc = kszphy_set_interrupt(phydev);
+	return rc < 0 ? rc : 0;
+}
+
+static int ks8737_config_intr(struct phy_device *phydev)
+{
+	int temp, rc;
+
+	/* set the interrupt pin active low */
+	temp = phy_read(phydev, MII_KSZPHY_CTRL);
+	temp &= ~KS8737_CTRL_INT_ACTIVE_HIGH;
+	phy_write(phydev, MII_KSZPHY_CTRL, temp);
+	rc = kszphy_set_interrupt(phydev);
+	return rc < 0 ? rc : 0;
+}
 
 static int kszphy_config_init(struct phy_device *phydev)
 {
 	return 0;
 }
 
+static struct phy_driver ks8737_driver = {
+	.phy_id		= PHY_ID_KS8737,
+	.phy_id_mask	= 0x00fffff0,
+	.name		= "Micrel KS8737",
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= kszphy_ack_interrupt,
+	.config_intr	= ks8737_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+};
+
+static struct phy_driver ks8041_driver = {
+	.phy_id		= PHY_ID_KS8041,
+	.phy_id_mask	= 0x00fffff0,
+	.name		= "Micrel KS8041",
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
+				| SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= kszphy_ack_interrupt,
+	.config_intr	= kszphy_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+};
 
-static struct phy_driver ks8001_driver = {
-	.phy_id		= PHY_ID_KS8001,
-	.name		= "Micrel KS8001",
+static struct phy_driver ks8051_driver = {
+	.phy_id		= PHY_ID_KS8051,
 	.phy_id_mask	= 0x00fffff0,
-	.features	= PHY_BASIC_FEATURES,
-	.flags		= PHY_POLL,
+	.name		= "Micrel KS8051",
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
+				| SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
+	.ack_interrupt	= kszphy_ack_interrupt,
+	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 };
 
-static struct phy_driver vsc8201_driver = {
-	.phy_id		= PHY_ID_VSC8201,
-	.name		= "Micrel VSC8201",
+static struct phy_driver ks8001_driver = {
+	.phy_id		= PHY_ID_KS8001,
+	.name		= "Micrel KS8001 or KS8721",
 	.phy_id_mask	= 0x00fffff0,
-	.features	= PHY_BASIC_FEATURES,
-	.flags		= PHY_POLL,
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
+	.ack_interrupt	= kszphy_ack_interrupt,
+	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 };
 
@@ -58,11 +168,14 @@ static struct phy_driver ksz9021_driver 
 	.phy_id		= PHY_ID_KSZ9021,
 	.phy_id_mask	= 0x000fff10,
 	.name		= "Micrel KSZ9021 Gigabit PHY",
-	.features	= PHY_GBIT_FEATURES | SUPPORTED_Pause,
-	.flags		= PHY_POLL,
+	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause
+				| SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
+	.ack_interrupt	= kszphy_ack_interrupt,
+	.config_intr	= ksz9021_config_intr,
 	.driver		= { .owner = THIS_MODULE, },
 };
 
@@ -73,17 +186,29 @@ static int __init ksphy_init(void)
 	ret = phy_driver_register(&ks8001_driver);
 	if (ret)
 		goto err1;
-	ret = phy_driver_register(&vsc8201_driver);
+
+	ret = phy_driver_register(&ksz9021_driver);
 	if (ret)
 		goto err2;
 
-	ret = phy_driver_register(&ksz9021_driver);
+	ret = phy_driver_register(&ks8737_driver);
 	if (ret)
 		goto err3;
+	ret = phy_driver_register(&ks8041_driver);
+	if (ret)
+		goto err4;
+	ret = phy_driver_register(&ks8051_driver);
+	if (ret)
+		goto err5;
+
 	return 0;
 
+err5:
+	phy_driver_unregister(&ks8041_driver);
+err4:
+	phy_driver_unregister(&ks8737_driver);
 err3:
-	phy_driver_unregister(&vsc8201_driver);
+	phy_driver_unregister(&ksz9021_driver);
 err2:
 	phy_driver_unregister(&ks8001_driver);
 err1:
@@ -93,8 +218,10 @@ err1:
 static void __exit ksphy_exit(void)
 {
 	phy_driver_unregister(&ks8001_driver);
-	phy_driver_unregister(&vsc8201_driver);
+	phy_driver_unregister(&ks8737_driver);
 	phy_driver_unregister(&ksz9021_driver);
+	phy_driver_unregister(&ks8041_driver);
+	phy_driver_unregister(&ks8051_driver);
 }
 
 module_init(ksphy_init);
@@ -106,8 +233,10 @@ MODULE_LICENSE("GPL");
 
 static struct mdio_device_id micrel_tbl[] = {
 	{ PHY_ID_KSZ9021, 0x000fff10 },
-	{ PHY_ID_VSC8201, 0x00fffff0 },
 	{ PHY_ID_KS8001, 0x00fffff0 },
+	{ PHY_ID_KS8737, 0x00fffff0 },
+	{ PHY_ID_KS8041, 0x00fffff0 },
+	{ PHY_ID_KS8051, 0x00fffff0 },
 	{ }
 };
 

---
