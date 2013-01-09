From: "Choi, David" <David.Choi@Micrel.Com>
Subject: [patch 3.8-rc2] drivers/net/phy/micrel.c
Date: Wed, 9 Jan 2013 20:09:37 +0000
Message-ID: <FD9AD8C5375B924CABC56D982DB3A802079D2509@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, David" <David.Choi@Micrel.Com>,
	"Doong, Ping" <Ping.Doong@Micrel.Com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c12o147.mxlogic.net ([208.65.145.70]:55925 "EHLO
	p01c12o147.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932488Ab3AIURW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 15:17:22 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David J. Choi <david.choi@micrel.com>

Summary of changes:
This patch is primarily intended to cover more Ethernet phys from Micrel Inc. Additionally it
.supports ksz8081/91, ksz8061, ksz9051 device.
.changes KSxxx to KSZxxx for unified naming convention. For example, change KS8737 to KSZ8737.
.changes 9021 to 90x1 for commonly used names between 9021 and 9031 device, as this patch includes 
 KSZ9031 which belongs to same family as 9021.

2 files(include/linux/micrel_phy.h, drivers/net/phy/micrel.c) are changed.

Signed-off-by: David J. Choi <david.choi@micrel.com>
---

--- linux-3.8-rc2/include/linux/micrel_phy.h.orig	2013-01-03 12:37:30.176895530 -0800
+++ linux-3.8-rc2/include/linux/micrel_phy.h	2013-01-09 11:32:10.361384007 -0800
@@ -17,12 +17,17 @@
 
 #define PHY_ID_KSZ8873MLL	0x000e7237
 #define PHY_ID_KSZ9021		0x00221610
-#define PHY_ID_KS8737		0x00221720
+#define PHY_ID_KSZ8737		0x00221720
+/* same id: KS8021, KS8031 */
 #define PHY_ID_KSZ8021		0x00221555
 #define PHY_ID_KSZ8041		0x00221510
 #define PHY_ID_KSZ8051		0x00221550
-/* both for ks8001 Rev. A/B, and for ks8721 Rev 3. */
+/* same id: ks8001 Rev. A/B, and ks8721 Rev 3. */
 #define PHY_ID_KSZ8001		0x0022161A
+/* same id: KS8081, KS8091 */
+#define	PHY_ID_KSZ8081		0x00221560
+#define	PHY_ID_KSZ8061		0x00221570
+#define	PHY_ID_KSZ9031		0x00221620
 
 /* struct phy_device dev_flags definitions */
 #define MICREL_PHY_50MHZ_CLK	0x00000001


--- linux-3.8-rc2/drivers/net/phy/micrel.c.orig	2013-01-03 10:12:26.961502521 -0800
+++ linux-3.8-rc2/drivers/net/phy/micrel.c	2013-01-09 11:24:03.119235092 -0800
@@ -12,8 +12,12 @@
  * Free Software Foundation;  either version 2 of the  License, or (at your
  * option) any later version.
  *
- * Support : ksz9021 1000/100/10 phy from Micrel
- *		ks8001, ks8737, ks8721, ks8041, ks8051 100/10 phy
+ * Support : Micrel Phys/switches:
+ *		Giga phys: ksz9021, ksz9031
+ *		100/10 Phys: ksz8001, ksz8021, ksz8031, ksz8041, ksz8051,
+ *			   ksz8061, ksz8081, ksz8091,
+ *			   ksz8721, ksz8737,
+ *		Switches: ksz8873
  */
 
 #include <linux/kernel.h>
@@ -44,8 +48,8 @@
 #define	MII_KSZPHY_CTRL			0x1F
 /* bitmap of PHY register to set interrupt mode */
 #define KSZPHY_CTRL_INT_ACTIVE_HIGH		(1 << 9)
-#define KSZ9021_CTRL_INT_ACTIVE_HIGH		(1 << 14)
-#define KS8737_CTRL_INT_ACTIVE_HIGH		(1 << 14)
+#define KSZ90X1_CTRL_INT_ACTIVE_HIGH		(1 << 14)
+#define KSZ8737_CTRL_INT_ACTIVE_HIGH		(1 << 14)
 #define KSZ8051_RMII_50MHZ_CLK			(1 << 7)
 
 static int kszphy_ack_interrupt(struct phy_device *phydev)
@@ -78,25 +82,25 @@ static int kszphy_config_intr(struct phy
 	return rc < 0 ? rc : 0;
 }
 
-static int ksz9021_config_intr(struct phy_device *phydev)
+static int ksz90x1_config_intr(struct phy_device *phydev)
 {
 	int temp, rc;
 
 	/* set the interrupt pin active low */
 	temp = phy_read(phydev, MII_KSZPHY_CTRL);
-	temp &= ~KSZ9021_CTRL_INT_ACTIVE_HIGH;
+	temp &= ~KSZ90X1_CTRL_INT_ACTIVE_HIGH;
 	phy_write(phydev, MII_KSZPHY_CTRL, temp);
 	rc = kszphy_set_interrupt(phydev);
 	return rc < 0 ? rc : 0;
 }
 
-static int ks8737_config_intr(struct phy_device *phydev)
+static int ksz8737_config_intr(struct phy_device *phydev)
 {
 	int temp, rc;
 
 	/* set the interrupt pin active low */
 	temp = phy_read(phydev, MII_KSZPHY_CTRL);
-	temp &= ~KS8737_CTRL_INT_ACTIVE_HIGH;
+	temp &= ~KSZ8737_CTRL_INT_ACTIVE_HIGH;
 	phy_write(phydev, MII_KSZPHY_CTRL, temp);
 	rc = kszphy_set_interrupt(phydev);
 	return rc < 0 ? rc : 0;
@@ -162,21 +166,21 @@ static int ksz8873mll_config_aneg(struct
 
 static struct phy_driver ksphy_driver[] = {
 {
-	.phy_id		= PHY_ID_KS8737,
+	.phy_id		= PHY_ID_KSZ8737,
 	.phy_id_mask	= 0x00fffff0,
-	.name		= "Micrel KS8737",
+	.name		= "Micrel KSZ8737",
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
-	.config_intr	= ks8737_config_intr,
+	.config_intr	= ksz8737_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8021,
 	.phy_id_mask	= 0x00ffffff,
-	.name		= "Micrel KSZ8021",
+	.name		= "Micrel KSZ8021 or KSZ8031",
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
 			   SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
@@ -214,7 +218,7 @@ static struct phy_driver ksphy_driver[]
 	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= PHY_ID_KSZ8001,
-	.name		= "Micrel KSZ8001 or KS8721",
+	.name		= "Micrel KSZ8001 or KSZ8721",
 	.phy_id_mask	= 0x00ffffff,
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
@@ -225,8 +229,32 @@ static struct phy_driver ksphy_driver[]
 	.config_intr	= kszphy_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
+	.phy_id		= PHY_ID_KSZ8081,
+	.name		= "Micrel KSZ8081 or KSZ8091",
+	.phy_id_mask	= 0x00fffff0,
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= kszphy_ack_interrupt,
+	.config_intr	= kszphy_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+}, {
+	.phy_id		= PHY_ID_KSZ8061,
+	.name		= "Micrel KSZ8061",
+	.phy_id_mask	= 0x00fffff0,
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= kszphy_ack_interrupt,
+	.config_intr	= kszphy_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+}, {
 	.phy_id		= PHY_ID_KSZ9021,
-	.phy_id_mask	= 0x000ffffe,
+	.phy_id_mask	= 0x00fffffe,
 	.name		= "Micrel KSZ9021 Gigabit PHY",
 	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause
 				| SUPPORTED_Asym_Pause),
@@ -235,7 +263,20 @@ static struct phy_driver ksphy_driver[]
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
-	.config_intr	= ksz9021_config_intr,
+	.config_intr	= ksz90x1_config_intr,
+	.driver		= { .owner = THIS_MODULE, },
+}, {
+	.phy_id		= PHY_ID_KSZ9031,
+	.phy_id_mask	= 0x00fffff0,
+	.name		= "Micrel KSZ9031 Gigabit PHY",
+	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause
+				| SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= kszphy_ack_interrupt,
+	.config_intr	= ksz90x1_config_intr,
 	.driver		= { .owner = THIS_MODULE, },
 }, {
 	.phy_id		= PHY_ID_KSZ8873MLL,
@@ -269,12 +310,15 @@ MODULE_AUTHOR("David J. Choi");
 MODULE_LICENSE("GPL");
 
 static struct mdio_device_id __maybe_unused micrel_tbl[] = {
-	{ PHY_ID_KSZ9021, 0x000ffffe },
+	{ PHY_ID_KSZ9021, 0x00fffffe },
+	{ PHY_ID_KSZ9031, 0x00fffff0 },
 	{ PHY_ID_KSZ8001, 0x00ffffff },
-	{ PHY_ID_KS8737, 0x00fffff0 },
+	{ PHY_ID_KSZ8737, 0x00fffff0 },
 	{ PHY_ID_KSZ8021, 0x00ffffff },
 	{ PHY_ID_KSZ8041, 0x00fffff0 },
 	{ PHY_ID_KSZ8051, 0x00fffff0 },
+	{ PHY_ID_KSZ8061, 0x00fffff0 },
+	{ PHY_ID_KSZ8081, 0x00fffff0 },
 	{ PHY_ID_KSZ8873MLL, 0x00fffff0 },
 	{ }
 };

---
