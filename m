From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 1/2] net: phy: genphy: Allow overwriting features
Date: Wed, 21 May 2014 15:29:44 +0200
Message-ID: <1400678985-24022-2-git-send-email-s.hauer@pengutronix.de>
References: <1400678985-24022-1-git-send-email-s.hauer@pengutronix.de>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49081 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbaEUN3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 09:29:55 -0400
In-Reply-To: <1400678985-24022-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_set_phy_supported allows overwiting hardware capabilities of
a phy with values from the devicetree. This does not work with
the genphy driver though because the genphys config_init function
will overwrite all values adjusted by of_set_phy_supported. Fix
this by initialising the genphy features in the phy_driver struct
and in config_init just limit the features to the ones the hardware
can actually support. The resulting features are a subset of the
devicetree specified features and the hardware features.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/phy/phy_device.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 0ce6066..9db3fba 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1072,9 +1072,6 @@ static int genphy_config_init(struct phy_device *phydev)
 	int val;
 	u32 features;
 
-	/* For now, I'll claim that the generic driver supports
-	 * all possible port types
-	 */
 	features = (SUPPORTED_TP | SUPPORTED_MII
 			| SUPPORTED_AUI | SUPPORTED_FIBRE |
 			SUPPORTED_BNC);
@@ -1107,8 +1104,8 @@ static int genphy_config_init(struct phy_device *phydev)
 			features |= SUPPORTED_1000baseT_Half;
 	}
 
-	phydev->supported = features;
-	phydev->advertising = features;
+	phydev->supported &= features;
+	phydev->advertising &= features;
 
 	return 0;
 }
@@ -1295,7 +1292,9 @@ static struct phy_driver genphy_driver[] = {
 	.name		= "Generic PHY",
 	.soft_reset	= genphy_soft_reset,
 	.config_init	= genphy_config_init,
-	.features	= 0,
+	.features	= PHY_GBIT_FEATURES | SUPPORTED_MII |
+			  SUPPORTED_AUI | SUPPORTED_FIBRE |
+			  SUPPORTED_BNC,
 	.config_aneg	= genphy_config_aneg,
 	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
-- 
2.0.0.rc0
