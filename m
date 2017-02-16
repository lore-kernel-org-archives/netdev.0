From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: oki-semi: pch_gbe: use new api ethtool_{get|set}_link_ksettings
Date: Thu, 16 Feb 2017 09:10:49 +0100
Message-ID: <1487232649-27462-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 .../ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c    |   58 +++++++++++++-------
 1 files changed, 38 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
index b19be7c..2109327 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
@@ -73,62 +73,80 @@ struct pch_gbe_stats {
 #define PCH_GBE_MAC_REGS_LEN    (sizeof(struct pch_gbe_regs) / 4)
 #define PCH_GBE_REGS_LEN        (PCH_GBE_MAC_REGS_LEN + PCH_GBE_PHY_REGS_LEN)
 /**
- * pch_gbe_get_settings - Get device-specific settings
+ * pch_gbe_get_link_ksettings - Get device-specific settings
  * @netdev: Network interface device structure
  * @ecmd:   Ethtool command
  * Returns:
  *	0:			Successful.
  *	Negative value:		Failed.
  */
-static int pch_gbe_get_settings(struct net_device *netdev,
-				 struct ethtool_cmd *ecmd)
+static int pch_gbe_get_link_ksettings(struct net_device *netdev,
+				      struct ethtool_link_ksettings *ecmd)
 {
 	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	u32 supported, advertising;
 	int ret;
 
-	ret = mii_ethtool_gset(&adapter->mii, ecmd);
-	ecmd->supported &= ~(SUPPORTED_TP | SUPPORTED_1000baseT_Half);
-	ecmd->advertising &= ~(ADVERTISED_TP | ADVERTISED_1000baseT_Half);
+	ret = mii_ethtool_get_link_ksettings(&adapter->mii, ecmd);
+
+	ethtool_convert_link_mode_to_legacy_u32(&supported,
+						ecmd->link_modes.supported);
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						ecmd->link_modes.advertising);
+
+	supported &= ~(SUPPORTED_TP | SUPPORTED_1000baseT_Half);
+	advertising &= ~(ADVERTISED_TP | ADVERTISED_1000baseT_Half);
+
+	ethtool_convert_legacy_u32_to_link_mode(ecmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(ecmd->link_modes.advertising,
+						advertising);
 
 	if (!netif_carrier_ok(adapter->netdev))
-		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->base.speed = SPEED_UNKNOWN;
 	return ret;
 }
 
 /**
- * pch_gbe_set_settings - Set device-specific settings
+ * pch_gbe_set_link_ksettings - Set device-specific settings
  * @netdev: Network interface device structure
  * @ecmd:   Ethtool command
  * Returns:
  *	0:			Successful.
  *	Negative value:		Failed.
  */
-static int pch_gbe_set_settings(struct net_device *netdev,
-				 struct ethtool_cmd *ecmd)
+static int pch_gbe_set_link_ksettings(struct net_device *netdev,
+				      const struct ethtool_link_ksettings *ecmd)
 {
 	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
 	struct pch_gbe_hw *hw = &adapter->hw;
-	u32 speed = ethtool_cmd_speed(ecmd);
+	struct ethtool_link_ksettings copy_ecmd;
+	u32 speed = ecmd->base.speed;
+	u32 advertising;
 	int ret;
 
 	pch_gbe_hal_write_phy_reg(hw, MII_BMCR, BMCR_RESET);
 
+	memcpy(&copy_ecmd, ecmd, sizeof(*ecmd));
+
 	/* when set_settings() is called with a ethtool_cmd previously
 	 * filled by get_settings() on a down link, speed is -1: */
 	if (speed == UINT_MAX) {
 		speed = SPEED_1000;
-		ethtool_cmd_speed_set(ecmd, speed);
-		ecmd->duplex = DUPLEX_FULL;
+		copy_ecmd.base.speed = speed;
+		copy_ecmd.base.duplex = DUPLEX_FULL;
 	}
-	ret = mii_ethtool_sset(&adapter->mii, ecmd);
+	ret = mii_ethtool_set_link_ksettings(&adapter->mii, &copy_ecmd);
 	if (ret) {
-		netdev_err(netdev, "Error: mii_ethtool_sset\n");
+		netdev_err(netdev, "Error: mii_ethtool_set_link_ksettings\n");
 		return ret;
 	}
 	hw->mac.link_speed = speed;
-	hw->mac.link_duplex = ecmd->duplex;
-	hw->phy.autoneg_advertised = ecmd->advertising;
-	hw->mac.autoneg = ecmd->autoneg;
+	hw->mac.link_duplex = copy_ecmd.base.duplex;
+	ethtool_convert_link_mode_to_legacy_u32(
+		&advertising, copy_ecmd.link_modes.advertising);
+	hw->phy.autoneg_advertised = advertising;
+	hw->mac.autoneg = copy_ecmd.base.autoneg;
 
 	/* reset the link */
 	if (netif_running(adapter->netdev)) {
@@ -487,8 +505,6 @@ static int pch_gbe_get_sset_count(struct net_device *netdev, int sset)
 }
 
 static const struct ethtool_ops pch_gbe_ethtool_ops = {
-	.get_settings = pch_gbe_get_settings,
-	.set_settings = pch_gbe_set_settings,
 	.get_drvinfo = pch_gbe_get_drvinfo,
 	.get_regs_len = pch_gbe_get_regs_len,
 	.get_regs = pch_gbe_get_regs,
@@ -503,6 +519,8 @@ static int pch_gbe_get_sset_count(struct net_device *netdev, int sset)
 	.get_strings = pch_gbe_get_strings,
 	.get_ethtool_stats = pch_gbe_get_ethtool_stats,
 	.get_sset_count = pch_gbe_get_sset_count,
+	.get_link_ksettings = pch_gbe_get_link_ksettings,
+	.set_link_ksettings = pch_gbe_set_link_ksettings,
 };
 
 void pch_gbe_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
