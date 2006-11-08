From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH] Add support for Marvell 88e1111S and 88e1145
Date: Wed, 8 Nov 2006 00:11:29 -0600 (CST)
Message-ID: <Pine.LNX.4.61.0611080010310.6936@ld0175-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:34229 "EHLO
	de01egw02.freescale.net") by vger.kernel.org with ESMTP
	id S1754348AbWKHGLe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 01:11:34 -0500
To: Netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch requires the new support for configurable PHY
interfaces.

Changes include:
* New support for 88e1145
* New support for 88e111s
* Fixing 88e1101 driver to not match non-88e1101 PHYs
* Increases in feature support across Marvell PHY product line
* Fixes a bunch of whitespace issues found by Lindent

Signed-off-by: Andrew Fleming <afleming@freescale.com>
---
 drivers/net/phy/marvell.c |  156 ++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 144 insertions(+), 12 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 0ad2532..5320ab9 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -43,6 +43,19 @@ #define MII_M1011_IMASK			0x12
 #define MII_M1011_IMASK_INIT		0x6400
 #define MII_M1011_IMASK_CLEAR		0x0000
 
+#define MII_M1011_PHY_SCR		0x10
+#define MII_M1011_PHY_SCR_AUTO_CROSS	0x0060
+
+#define MII_M1145_PHY_EXT_CR		0x14
+#define MII_M1145_RGMII_RX_DELAY	0x0080
+#define MII_M1145_RGMII_TX_DELAY	0x0002
+
+#define M1145_DEV_FLAGS_RESISTANCE	0x00000001
+
+#define MII_M1111_PHY_LED_CONTROL	0x18
+#define MII_M1111_PHY_LED_DIRECT	0x4100
+#define MII_M1111_PHY_LED_COMBINE	0x411c
+
 MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
 MODULE_LICENSE("GPL");
@@ -64,7 +77,7 @@ static int marvell_config_intr(struct ph
 {
 	int err;
 
-	if(phydev->interrupts == PHY_INTERRUPT_ENABLED)
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
 		err = phy_write(phydev, MII_M1011_IMASK, MII_M1011_IMASK_INIT);
 	else
 		err = phy_write(phydev, MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);
@@ -104,34 +117,153 @@ static int marvell_config_aneg(struct ph
 	if (err < 0)
 		return err;
 
+	err = phy_write(phydev, MII_M1011_PHY_SCR,
+			MII_M1011_PHY_SCR_AUTO_CROSS);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, MII_M1111_PHY_LED_CONTROL,
+			MII_M1111_PHY_LED_DIRECT);
+	if (err < 0)
+		return err;
 
 	err = genphy_config_aneg(phydev);
 
 	return err;
 }
 
+static int m88e1145_config_init(struct phy_device *phydev)
+{
+	int err;
+
+	/* Take care of errata E0 & E1 */
+	err = phy_write(phydev, 0x1d, 0x001b);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, 0x1e, 0x418f);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, 0x1d, 0x0016);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, 0x1e, 0xa2da);
+	if (err < 0)
+		return err;
+
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII) {
+		int temp = phy_read(phydev, MII_M1145_PHY_EXT_CR);
+		if (temp < 0)
+			return temp;
+
+		temp |= (MII_M1145_RGMII_RX_DELAY | MII_M1145_RGMII_TX_DELAY);
+
+		err = phy_write(phydev, MII_M1145_PHY_EXT_CR, temp);
+		if (err < 0)
+			return err;
+
+		if (phydev->dev_flags & M1145_DEV_FLAGS_RESISTANCE) {
+			err = phy_write(phydev, 0x1d, 0x0012);
+			if (err < 0)
+				return err;
+
+			temp = phy_read(phydev, 0x1e);
+			if (temp < 0)
+				return temp;
+
+			temp &= 0xf03f;
+			temp |= 2 << 9;	/* 36 ohm */
+			temp |= 2 << 6;	/* 39 ohm */
+
+			err = phy_write(phydev, 0x1e, temp);
+			if (err < 0)
+				return err;
+
+			err = phy_write(phydev, 0x1d, 0x3);
+			if (err < 0)
+				return err;
+
+			err = phy_write(phydev, 0x1e, 0x8000);
+			if (err < 0)
+				return err;
+		}
+	}
+
+	return 0;
+}
 
 static struct phy_driver m88e1101_driver = {
-	.phy_id		= 0x01410c00,
-	.phy_id_mask	= 0xffffff00,
-	.name		= "Marvell 88E1101",
-	.features	= PHY_GBIT_FEATURES,
-	.flags		= PHY_HAS_INTERRUPT,
-	.config_aneg	= &marvell_config_aneg,
-	.read_status	= &genphy_read_status,
-	.ack_interrupt	= &marvell_ack_interrupt,
-	.config_intr	= &marvell_config_intr,
-	.driver 	= { .owner = THIS_MODULE,},
+	.phy_id = 0x01410c60,
+	.phy_id_mask = 0xfffffff0,
+	.name = "Marvell 88E1101",
+	.features = PHY_GBIT_FEATURES,
+	.flags = PHY_HAS_INTERRUPT,
+	.config_aneg = &marvell_config_aneg,
+	.read_status = &genphy_read_status,
+	.ack_interrupt = &marvell_ack_interrupt,
+	.config_intr = &marvell_config_intr,
+	.driver = {.owner = THIS_MODULE,},
+};
+
+static struct phy_driver m88e1111s_driver = {
+	.phy_id = 0x01410cc0,
+	.phy_id_mask = 0xfffffff0,
+	.name = "Marvell 88E1111",
+	.features = PHY_GBIT_FEATURES,
+	.flags = PHY_HAS_INTERRUPT,
+	.config_aneg = &marvell_config_aneg,
+	.read_status = &genphy_read_status,
+	.ack_interrupt = &marvell_ack_interrupt,
+	.config_intr = &marvell_config_intr,
+	.driver = {.owner = THIS_MODULE,},
+};
+
+static struct phy_driver m88e1145_driver = {
+	.phy_id = 0x01410cd0,
+	.phy_id_mask = 0xfffffff0,
+	.name = "Marvell 88E1145",
+	.features = PHY_GBIT_FEATURES,
+	.flags = PHY_HAS_INTERRUPT,
+	.config_init = &m88e1145_config_init,
+	.config_aneg = &marvell_config_aneg,
+	.read_status = &genphy_read_status,
+	.ack_interrupt = &marvell_ack_interrupt,
+	.config_intr = &marvell_config_intr,
+	.driver = {.owner = THIS_MODULE,},
 };
 
 static int __init marvell_init(void)
 {
-	return phy_driver_register(&m88e1101_driver);
+	int ret;
+
+	ret = phy_driver_register(&m88e1101_driver);
+	if (ret)
+		return ret;
+
+	ret = phy_driver_register(&m88e1111s_driver);
+	if (ret)
+		goto err1111s;
+
+	ret = phy_driver_register(&m88e1145_driver);
+	if (ret)
+		goto err1145;
+
+	return 0;
+
+      err1145:
+	phy_driver_unregister(&m88e1111s_driver);
+      err1111s:
+	phy_driver_unregister(&m88e1101_driver);
+	return ret;
 }
 
 static void __exit marvell_exit(void)
 {
 	phy_driver_unregister(&m88e1101_driver);
+	phy_driver_unregister(&m88e1111s_driver);
+	phy_driver_unregister(&m88e1145_driver);
 }
 
 module_init(marvell_init);
-- 
1.4.2.3

