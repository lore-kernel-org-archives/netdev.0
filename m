From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: [PATCH] phy: marvell: fix LED configuration via marvell,reg-init
Date: Sat, 11 Jun 2016 17:21:26 +0200
Message-ID: <20160611152126.24024-1-clemens.gruber@pqgruber.com>
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Sergei Poselenov <sposelenov@emcraft.com>,
	Clemens Gruber <clemens.gruber@pqgruber.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Configuring the PHY LED registers for the Marvell 88E1510 and others is
not possible, because regardless of the values in marvell,reg-init, it
is later overridden in m88e1121_config_aneg with a non-standard default.

This patch moves that default configuration to .config_init to allow
setting the LED configuration through marvell,reg-init in the device
tree, which should override said default if it exists.

Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>
---
 drivers/net/phy/marvell.c | 38 ++++++++++++++++++++++++++------------
 1 file changed, 26 insertions(+), 12 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 280e879..79ccc11 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -407,15 +407,7 @@ static int m88e1121_config_aneg(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	oldpage = phy_read(phydev, MII_MARVELL_PHY_PAGE);
-
-	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_88E1121_PHY_LED_PAGE);
-	phy_write(phydev, MII_88E1121_PHY_LED_CTRL, MII_88E1121_PHY_LED_DEF);
-	phy_write(phydev, MII_MARVELL_PHY_PAGE, oldpage);
-
-	err = genphy_config_aneg(phydev);
-
-	return err;
+	return genphy_config_aneg(phydev);
 }
 
 static int m88e1318_config_aneg(struct phy_device *phydev)
@@ -636,6 +628,28 @@ static int m88e1111_config_init(struct phy_device *phydev)
 	return phy_write(phydev, MII_BMCR, BMCR_RESET);
 }
 
+static int m88e1121_config_init(struct phy_device *phydev)
+{
+	int err, oldpage;
+
+	oldpage = phy_read(phydev, MII_MARVELL_PHY_PAGE);
+
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_88E1121_PHY_LED_PAGE);
+	if (err < 0)
+		return err;
+
+	/* Default PHY LED config: LED[0] .. Link, LED[1] .. Activity */
+	err = phy_write(phydev, MII_88E1121_PHY_LED_CTRL,
+			MII_88E1121_PHY_LED_DEF);
+	if (err < 0)
+		return err;
+
+	phy_write(phydev, MII_MARVELL_PHY_PAGE, oldpage);
+
+	/* Set marvell,reg-init configuration from device tree */
+	return marvell_config_init(phydev);
+}
+
 static int m88e1510_config_init(struct phy_device *phydev)
 {
 	int err;
@@ -668,7 +682,7 @@ static int m88e1510_config_init(struct phy_device *phydev)
 			return err;
 	}
 
-	return marvell_config_init(phydev);
+	return m88e1121_config_init(phydev);
 }
 
 static int m88e1118_config_aneg(struct phy_device *phydev)
@@ -1196,7 +1210,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
-		.config_init = &marvell_config_init,
+		.config_init = &m88e1121_config_init,
 		.config_aneg = &m88e1121_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1215,7 +1229,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
-		.config_init = &marvell_config_init,
+		.config_init = &m88e1121_config_init,
 		.config_aneg = &m88e1318_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
-- 
2.8.3
