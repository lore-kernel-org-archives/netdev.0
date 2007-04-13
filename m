From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH v2] phylib: enable RGMII-ID on the Marvell m88e1111 PHY
Date: Fri, 13 Apr 2007 01:26:56 -0500
Message-ID: <20070413012656.5f65ffd1.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:39610 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905AbXDMG1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 02:27:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support for configuring RGMII-ID (RGMII with internal delay) mode on the
88e1111 and 88e1145.

Also renamed 88e1111s -> 88e1111 (no references to an 88e1111s part were
found), and fixed some whitespace.

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
this version sets the delay bits conditionally

 drivers/net/phy/marvell.c |   62 +++++++++++++++++++++++++++++++++++++++------
 1 files changed, 54 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 22aec5c..b87f8d2 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -54,6 +54,12 @@
 #define MII_M1111_PHY_LED_CONTROL	0x18
 #define MII_M1111_PHY_LED_DIRECT	0x4100
 #define MII_M1111_PHY_LED_COMBINE	0x411c
+#define MII_M1111_PHY_EXT_CR		0x14
+#define MII_M1111_RX_DELAY		0x80
+#define MII_M1111_TX_DELAY		0x2
+#define MII_M1111_PHY_EXT_SR		0x1b
+#define MII_M1111_HWCFG_MODE_MASK	0xf
+#define MII_M1111_HWCFG_MODE_RGMII	0xb
 
 MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
@@ -131,6 +137,45 @@ static int marvell_config_aneg(struct phy_device *phydev)
 	return err;
 }
 
+static int m88e1111_config_init(struct phy_device *phydev)
+{
+	int err;
+
+	if ((phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
+	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)) {
+		int temp;
+
+		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
+			temp = phy_read(phydev, MII_M1111_PHY_EXT_CR);
+			if (temp < 0)
+				return temp;
+
+			temp |= (MII_M1111_RX_DELAY | MII_M1111_TX_DELAY);
+
+			err = phy_write(phydev, MII_M1111_PHY_EXT_CR, temp);
+			if (err < 0)
+				return err;
+		}
+
+		temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
+		if (temp < 0)
+			return temp;
+
+		temp &= ~(MII_M1111_HWCFG_MODE_MASK);
+		temp |= MII_M1111_HWCFG_MODE_RGMII;
+
+		err = phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);
+		if (err < 0)
+			return err;
+	}
+
+	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
 static int m88e1145_config_init(struct phy_device *phydev)
 {
 	int err;
@@ -152,7 +197,7 @@ static int m88e1145_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	if (phydev->interface == PHY_INTERFACE_MODE_RGMII) {
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
 		int temp = phy_read(phydev, MII_M1145_PHY_EXT_CR);
 		if (temp < 0)
 			return temp;
@@ -206,7 +251,7 @@ static struct phy_driver m88e1101_driver = {
 	.driver = {.owner = THIS_MODULE,},
 };
 
-static struct phy_driver m88e1111s_driver = {
+static struct phy_driver m88e1111_driver = {
 	.phy_id = 0x01410cc0,
 	.phy_id_mask = 0xfffffff0,
 	.name = "Marvell 88E1111",
@@ -216,6 +261,7 @@ static struct phy_driver m88e1111s_driver = {
 	.read_status = &genphy_read_status,
 	.ack_interrupt = &marvell_ack_interrupt,
 	.config_intr = &marvell_config_intr,
+	.config_init = &m88e1111_config_init,
 	.driver = {.owner = THIS_MODULE,},
 };
 
@@ -241,9 +287,9 @@ static int __init marvell_init(void)
 	if (ret)
 		return ret;
 
-	ret = phy_driver_register(&m88e1111s_driver);
+	ret = phy_driver_register(&m88e1111_driver);
 	if (ret)
-		goto err1111s;
+		goto err1111;
 
 	ret = phy_driver_register(&m88e1145_driver);
 	if (ret)
@@ -251,9 +297,9 @@ static int __init marvell_init(void)
 
 	return 0;
 
-      err1145:
-	phy_driver_unregister(&m88e1111s_driver);
-      err1111s:
+err1145:
+	phy_driver_unregister(&m88e1111_driver);
+err1111:
 	phy_driver_unregister(&m88e1101_driver);
 	return ret;
 }
@@ -261,7 +307,7 @@ static int __init marvell_init(void)
 static void __exit marvell_exit(void)
 {
 	phy_driver_unregister(&m88e1101_driver);
-	phy_driver_unregister(&m88e1111s_driver);
+	phy_driver_unregister(&m88e1111_driver);
 	phy_driver_unregister(&m88e1145_driver);
 }
 
-- 
1.5.0.1

