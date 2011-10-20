From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [RFC PATCH 14/17] lxt973: Clean up fixed-mode fiber PHY handling
Date: Thu, 20 Oct 2011 17:00:21 -0400
Message-ID: <1319144425-15547-15-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Cc: Kyle Moffett <Kyle.D.Moffett@boeing.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The LXT973 driver does not need to detect fiber/copper PHY modes in the
phy ->probe() method, it can instead check the register directly from
the ->config_aneg() method.

Furthermore, the driver should not manually poke the registers, but
instead adjust the PHY state variables and allow genphy_config_aneg() to
do the rest of the work.

NOTE: Needs testing by somebody with the hardware.

Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 drivers/net/phy/lxt.c |   33 +++++++++++++--------------------
 1 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
index 902d2d1..186dc94 100644
--- a/drivers/net/phy/lxt.c
+++ b/drivers/net/phy/lxt.c
@@ -122,31 +122,25 @@ static int lxt971_config_intr(struct phy_device *phydev)
 	return err;
 }
 
-static int lxt973_probe(struct phy_device *phydev)
+static int lxt973_config_aneg(struct phy_device *phydev)
 {
 	int val = phy_read(phydev, MII_LXT973_PCR);
+	if (val < 0)
+		return val;
 
+	/*
+	 * If the PHY is in fiber-only mode then ignore the ethtool settings
+	 * and force the required 100Base-FX mode.
+	 */
 	if (val & PCR_FIBER_SELECT) {
-		/*
-		 * If fiber is selected, then the only correct setting
-		 * is 100Mbps, full duplex, and auto negotiation off.
-		 */
-		val = phy_read(phydev, MII_BMCR);
-		val |= (BMCR_SPEED100 | BMCR_FULLDPLX);
-		val &= ~BMCR_ANENABLE;
-		phy_write(phydev, MII_BMCR, val);
-		/* Remember that the port is in fiber mode. */
-		phydev->priv = lxt973_probe;
-	} else {
-		phydev->priv = NULL;
+		phydev->supported = ADVERTISED_FIBRE|ADVERTISED_100baseT_Full;
+		phydev->advertising = phydev->supported;
+		phydev->autoneg = AUTONEG_DISABLE;
+		phydev->speed = SPEED_100;
+		phydev->duplex = DUPLEX_FULL;
 	}
-	return 0;
-}
 
-static int lxt973_config_aneg(struct phy_device *phydev)
-{
-	/* Do nothing if port is in fiber mode. */
-	return phydev->priv ? 0 : genphy_config_aneg(phydev);
+	return genphy_config_aneg(phydev);
 }
 
 static struct phy_driver lxt_drivers[] = { {
@@ -174,7 +168,6 @@ static struct phy_driver lxt_drivers[] = { {
 	.phy_id_mask	= 0xfffffff0,
 	.features	= PHY_BASIC_FEATURES,
 	.flags		= 0,
-	.probe		= lxt973_probe,
 	.config_aneg	= lxt973_config_aneg,
 	.driver 	= { .owner = THIS_MODULE,},
 } };
-- 
1.7.2.5
