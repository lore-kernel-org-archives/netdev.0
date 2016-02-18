From: Stefan Roese <sr@denx.de>
Subject: [PATCH] net: phy: Add SGMII support for Marvell 88E1510/1512/1514/1518
Date: Thu, 18 Feb 2016 10:59:07 +0100
Message-ID: <1455789547-6382-1-git-send-email-sr@denx.de>
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37985 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425918AbcBRJ7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 04:59:10 -0500
Received: by mail-wm0-f53.google.com with SMTP id a4so17048620wme.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 01:59:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add code to select SGMII-to-copper mode upon SGMII interface selection.

Signed-off-by: Stefan Roese <sr@denx.de>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/phy/marvell.c | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index e3eb964..1dcbd3f 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -133,6 +133,11 @@
 #define MII_88E3016_DISABLE_SCRAMBLER	0x0200
 #define MII_88E3016_AUTO_MDIX_CROSSOVER	0x0030
 
+#define MII_88E1510_GEN_CTRL_REG_1		0x14
+#define MII_88E1510_GEN_CTRL_REG_1_MODE_MASK	0x7
+#define MII_88E1510_GEN_CTRL_REG_1_MODE_SGMII	0x1	/* SGMII to copper */
+#define MII_88E1510_GEN_CTRL_REG_1_RESET	0x8000	/* Soft reset */
+
 MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
 MODULE_LICENSE("GPL");
@@ -438,6 +443,41 @@ static int m88e1318_config_aneg(struct phy_device *phydev)
 	return m88e1121_config_aneg(phydev);
 }
 
+static int m88e1510_config_init(struct phy_device *phydev)
+{
+	int err;
+	int temp;
+
+	/* SGMII-to-Copper mode initialization */
+	if (phydev->interface == PHY_INTERFACE_MODE_SGMII) {
+		/* Select page 18 */
+		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 18);
+		if (err < 0)
+			return err;
+
+		/* In reg 20, write MODE[2:0] = 0x1 (SGMII to Copper) */
+		temp = phy_read(phydev, MII_88E1510_GEN_CTRL_REG_1);
+		temp &= ~MII_88E1510_GEN_CTRL_REG_1_MODE_MASK;
+		temp |= MII_88E1510_GEN_CTRL_REG_1_MODE_SGMII;
+		err = phy_write(phydev, MII_88E1510_GEN_CTRL_REG_1, temp);
+		if (err < 0)
+			return err;
+
+		/* PHY reset is necessary after changing MODE[2:0] */
+		temp |= MII_88E1510_GEN_CTRL_REG_1_RESET;
+		err = phy_write(phydev, MII_88E1510_GEN_CTRL_REG_1, temp);
+		if (err < 0)
+			return err;
+
+		/* Reset page selection */
+		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0);
+		if (err < 0)
+			return err;
+	}
+
+	return 0;
+}
+
 static int m88e1510_config_aneg(struct phy_device *phydev)
 {
 	int err;
@@ -1259,6 +1299,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
+		.config_init = &m88e1510_config_init,
 		.config_aneg = &m88e1510_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
-- 
2.7.1
