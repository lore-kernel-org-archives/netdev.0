From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: [PATCH] phy: marvell: remove LED config override
Date: Fri, 10 Jun 2016 19:42:52 +0200
Message-ID: <20160610174252.14017-1-clemens.gruber@pqgruber.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Clemens Gruber <clemens.gruber@pqgruber.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Configuring the PHY LED registers for the Marvell 88E1510 and others is
not possible, because regardless of the values in marvell,reg-init, it
is later overridden in m88e1121_config_aneg with a non-standard default.

This became visible after we moved the call of marvell_of_reg_init in
commit 79be1a1c9090 ("phy: marvell: Fix and unify reg-init behavior").
Moving it to _config_init was necessary due to the PHY state machine
getting stuck if the PHY interrupts were not enabled early on.
As that default LED configuration is set in _config_aneg, it overrides
the marvell,reg-init configuration from the device tree.

This patch removes this override and allows the user to again set the
PHY LED configuration through marvell,reg-init or if that does not
exist, keep the original defaults as documented in the datasheet.

Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>
---
 drivers/net/phy/marvell.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 280e879..7a94039 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -115,10 +115,6 @@
 #define MII_88E1318S_PHY_WOL_CTRL_CLEAR_WOL_STATUS          BIT(12)
 #define MII_88E1318S_PHY_WOL_CTRL_MAGIC_PACKET_MATCH_ENABLE BIT(14)
 
-#define MII_88E1121_PHY_LED_CTRL	16
-#define MII_88E1121_PHY_LED_PAGE	3
-#define MII_88E1121_PHY_LED_DEF		0x0030
-
 #define MII_M1011_PHY_STATUS		0x11
 #define MII_M1011_PHY_STATUS_1000	0x8000
 #define MII_M1011_PHY_STATUS_100	0x4000
@@ -407,15 +403,7 @@ static int m88e1121_config_aneg(struct phy_device *phydev)
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
-- 
2.8.3
