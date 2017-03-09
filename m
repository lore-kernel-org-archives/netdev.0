From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net] net: phy: marvell: Fix double free of hwmon device
Date: Thu,  9 Mar 2017 20:53:31 +0100
Message-ID: <1489089211-1052-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42545 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751383AbdCITyB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 14:54:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hwmon temperature sensor devices is registered using a devm_hwmon
API call.  The marvell_release() would then manually free the device,
not using a devm_hmon API, resulting in the device being removed
twice, leading to a crash in kernfs_find_ns() during the second
removal.

Remove the manual removal, which makes marvell_release() empty, so
remove it as well.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Fixes: 0b04680fdae4 ("phy: marvell: Add support for temperature sensor")
---
 drivers/net/phy/marvell.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index f9d0fa315a47..272b051a0199 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -1883,17 +1883,6 @@ static int m88e1510_probe(struct phy_device *phydev)
 	return m88e1510_hwmon_probe(phydev);
 }
 
-static void marvell_remove(struct phy_device *phydev)
-{
-#ifdef CONFIG_HWMON
-
-	struct marvell_priv *priv = phydev->priv;
-
-	if (priv && priv->hwmon_dev)
-		hwmon_device_unregister(priv->hwmon_dev);
-#endif
-}
-
 static struct phy_driver marvell_drivers[] = {
 	{
 		.phy_id = MARVELL_PHY_ID_88E1101,
@@ -1974,7 +1963,6 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = &m88e1121_probe,
-		.remove = &marvell_remove,
 		.config_init = &m88e1121_config_init,
 		.config_aneg = &m88e1121_config_aneg,
 		.read_status = &marvell_read_status,
@@ -2087,7 +2075,6 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES | SUPPORTED_FIBRE,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = &m88e1510_probe,
-		.remove = &marvell_remove,
 		.config_init = &m88e1510_config_init,
 		.config_aneg = &m88e1510_config_aneg,
 		.read_status = &marvell_read_status,
@@ -2109,7 +2096,6 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = m88e1510_probe,
-		.remove = &marvell_remove,
 		.config_init = &marvell_config_init,
 		.config_aneg = &m88e1510_config_aneg,
 		.read_status = &marvell_read_status,
@@ -2127,7 +2113,6 @@ static struct phy_driver marvell_drivers[] = {
 		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E1545",
 		.probe = m88e1510_probe,
-		.remove = &marvell_remove,
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.config_init = &marvell_config_init,
-- 
2.11.0
