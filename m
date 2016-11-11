From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: alx: use new api ethtool_{get|set}_link_ksettings
Date: Fri, 11 Nov 2016 23:30:37 +0100
Message-ID: <1478903437-9049-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: jcliburn@gmail.com, chris.snook@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/atheros/alx/ethtool.c |   59 ++++++++++++++++-----------
 1 files changed, 35 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/ethtool.c b/drivers/net/ethernet/atheros/alx/ethtool.c
index 08e22df..2f4eabf 100644
--- a/drivers/net/ethernet/atheros/alx/ethtool.c
+++ b/drivers/net/ethernet/atheros/alx/ethtool.c
@@ -125,64 +125,75 @@ static u32 alx_get_supported_speeds(struct alx_hw *hw)
 	return supported;
 }
 
-static int alx_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+static int alx_get_link_ksettings(struct net_device *netdev,
+				  struct ethtool_link_ksettings *cmd)
 {
 	struct alx_priv *alx = netdev_priv(netdev);
 	struct alx_hw *hw = &alx->hw;
+	u32 supported, advertising;
 
-	ecmd->supported = SUPPORTED_Autoneg |
+	supported = SUPPORTED_Autoneg |
 			  SUPPORTED_TP |
 			  SUPPORTED_Pause |
 			  SUPPORTED_Asym_Pause;
 	if (alx_hw_giga(hw))
-		ecmd->supported |= SUPPORTED_1000baseT_Full;
-	ecmd->supported |= alx_get_supported_speeds(hw);
+		supported |= SUPPORTED_1000baseT_Full;
+	supported |= alx_get_supported_speeds(hw);
 
-	ecmd->advertising = ADVERTISED_TP;
+	advertising = ADVERTISED_TP;
 	if (hw->adv_cfg & ADVERTISED_Autoneg)
-		ecmd->advertising |= hw->adv_cfg;
+		advertising |= hw->adv_cfg;
 
-	ecmd->port = PORT_TP;
-	ecmd->phy_address = 0;
+	cmd->base.port = PORT_TP;
+	cmd->base.phy_address = 0;
 
 	if (hw->adv_cfg & ADVERTISED_Autoneg)
-		ecmd->autoneg = AUTONEG_ENABLE;
+		cmd->base.autoneg = AUTONEG_ENABLE;
 	else
-		ecmd->autoneg = AUTONEG_DISABLE;
-	ecmd->transceiver = XCVR_INTERNAL;
+		cmd->base.autoneg = AUTONEG_DISABLE;
 
 	if (hw->flowctrl & ALX_FC_ANEG && hw->adv_cfg & ADVERTISED_Autoneg) {
 		if (hw->flowctrl & ALX_FC_RX) {
-			ecmd->advertising |= ADVERTISED_Pause;
+			advertising |= ADVERTISED_Pause;
 
 			if (!(hw->flowctrl & ALX_FC_TX))
-				ecmd->advertising |= ADVERTISED_Asym_Pause;
+				advertising |= ADVERTISED_Asym_Pause;
 		} else if (hw->flowctrl & ALX_FC_TX) {
-			ecmd->advertising |= ADVERTISED_Asym_Pause;
+			advertising |= ADVERTISED_Asym_Pause;
 		}
 	}
 
-	ethtool_cmd_speed_set(ecmd, hw->link_speed);
-	ecmd->duplex = hw->duplex;
+	cmd->base.speed = hw->link_speed;
+	cmd->base.duplex = hw->duplex;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	return 0;
 }
 
-static int alx_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+static int alx_set_link_ksettings(struct net_device *netdev,
+				  const struct ethtool_link_ksettings *cmd)
 {
 	struct alx_priv *alx = netdev_priv(netdev);
 	struct alx_hw *hw = &alx->hw;
 	u32 adv_cfg;
+	u32 advertising;
 
 	ASSERT_RTNL();
 
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
-		if (ecmd->advertising & ~alx_get_supported_speeds(hw))
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
+
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
+		if (advertising & ~alx_get_supported_speeds(hw))
 			return -EINVAL;
-		adv_cfg = ecmd->advertising | ADVERTISED_Autoneg;
+		adv_cfg = advertising | ADVERTISED_Autoneg;
 	} else {
-		adv_cfg = alx_speed_to_ethadv(ethtool_cmd_speed(ecmd),
-					      ecmd->duplex);
+		adv_cfg = alx_speed_to_ethadv(cmd->base.speed,
+					      cmd->base.duplex);
 
 		if (!adv_cfg || adv_cfg == ADVERTISED_1000baseT_Full)
 			return -EINVAL;
@@ -300,8 +311,6 @@ static int alx_get_sset_count(struct net_device *netdev, int sset)
 }
 
 const struct ethtool_ops alx_ethtool_ops = {
-	.get_settings	= alx_get_settings,
-	.set_settings	= alx_set_settings,
 	.get_pauseparam	= alx_get_pauseparam,
 	.set_pauseparam	= alx_set_pauseparam,
 	.get_msglevel	= alx_get_msglevel,
@@ -310,4 +319,6 @@ static int alx_get_sset_count(struct net_device *netdev, int sset)
 	.get_strings	= alx_get_strings,
 	.get_sset_count	= alx_get_sset_count,
 	.get_ethtool_stats	= alx_get_ethtool_stats,
+	.get_link_ksettings	= alx_get_link_ksettings,
+	.set_link_ksettings	= alx_set_link_ksettings,
 };
-- 
1.7.4.4
