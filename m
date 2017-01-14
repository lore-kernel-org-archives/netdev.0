From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: marvell: sky2: use new api ethtool_{get|set}_link_ksettings
Date: Sat, 14 Jan 2017 23:26:22 +0100
Message-ID: <1484432782-1175-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: mlindner@marvell.com, stephen@networkplumber.org,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/marvell/sky2.c |   68 ++++++++++++++++++++--------------
 1 files changed, 40 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 18d6336..be003c5 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -3589,47 +3589,59 @@ static u32 sky2_supported_modes(const struct sky2_hw *hw)
 			| SUPPORTED_1000baseT_Full;
 }
 
-static int sky2_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int sky2_get_link_ksettings(struct net_device *dev,
+				   struct ethtool_link_ksettings *cmd)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
+	u32 supported, advertising;
 
-	ecmd->transceiver = XCVR_INTERNAL;
-	ecmd->supported = sky2_supported_modes(hw);
-	ecmd->phy_address = PHY_ADDR_MARV;
+	supported = sky2_supported_modes(hw);
+	cmd->base.phy_address = PHY_ADDR_MARV;
 	if (sky2_is_copper(hw)) {
-		ecmd->port = PORT_TP;
-		ethtool_cmd_speed_set(ecmd, sky2->speed);
-		ecmd->supported |=  SUPPORTED_Autoneg | SUPPORTED_TP;
+		cmd->base.port = PORT_TP;
+		cmd->base.speed = sky2->speed;
+		supported |=  SUPPORTED_Autoneg | SUPPORTED_TP;
 	} else {
-		ethtool_cmd_speed_set(ecmd, SPEED_1000);
-		ecmd->port = PORT_FIBRE;
-		ecmd->supported |=  SUPPORTED_Autoneg | SUPPORTED_FIBRE;
+		cmd->base.speed = SPEED_1000;
+		cmd->base.port = PORT_FIBRE;
+		supported |=  SUPPORTED_Autoneg | SUPPORTED_FIBRE;
 	}
 
-	ecmd->advertising = sky2->advertising;
-	ecmd->autoneg = (sky2->flags & SKY2_FLAG_AUTO_SPEED)
+	advertising = sky2->advertising;
+	cmd->base.autoneg = (sky2->flags & SKY2_FLAG_AUTO_SPEED)
 		? AUTONEG_ENABLE : AUTONEG_DISABLE;
-	ecmd->duplex = sky2->duplex;
+	cmd->base.duplex = sky2->duplex;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	return 0;
 }
 
-static int sky2_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int sky2_set_link_ksettings(struct net_device *dev,
+				   const struct ethtool_link_ksettings *cmd)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	const struct sky2_hw *hw = sky2->hw;
 	u32 supported = sky2_supported_modes(hw);
+	u32 new_advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&new_advertising,
+						cmd->link_modes.advertising);
 
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
-		if (ecmd->advertising & ~supported)
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
+		if (new_advertising & ~supported)
 			return -EINVAL;
 
 		if (sky2_is_copper(hw))
-			sky2->advertising = ecmd->advertising |
+			sky2->advertising = new_advertising |
 					    ADVERTISED_TP |
 					    ADVERTISED_Autoneg;
 		else
-			sky2->advertising = ecmd->advertising |
+			sky2->advertising = new_advertising |
 					    ADVERTISED_FIBRE |
 					    ADVERTISED_Autoneg;
 
@@ -3638,30 +3650,30 @@ static int sky2_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		sky2->speed = -1;
 	} else {
 		u32 setting;
-		u32 speed = ethtool_cmd_speed(ecmd);
+		u32 speed = cmd->base.speed;
 
 		switch (speed) {
 		case SPEED_1000:
-			if (ecmd->duplex == DUPLEX_FULL)
+			if (cmd->base.duplex == DUPLEX_FULL)
 				setting = SUPPORTED_1000baseT_Full;
-			else if (ecmd->duplex == DUPLEX_HALF)
+			else if (cmd->base.duplex == DUPLEX_HALF)
 				setting = SUPPORTED_1000baseT_Half;
 			else
 				return -EINVAL;
 			break;
 		case SPEED_100:
-			if (ecmd->duplex == DUPLEX_FULL)
+			if (cmd->base.duplex == DUPLEX_FULL)
 				setting = SUPPORTED_100baseT_Full;
-			else if (ecmd->duplex == DUPLEX_HALF)
+			else if (cmd->base.duplex == DUPLEX_HALF)
 				setting = SUPPORTED_100baseT_Half;
 			else
 				return -EINVAL;
 			break;
 
 		case SPEED_10:
-			if (ecmd->duplex == DUPLEX_FULL)
+			if (cmd->base.duplex == DUPLEX_FULL)
 				setting = SUPPORTED_10baseT_Full;
-			else if (ecmd->duplex == DUPLEX_HALF)
+			else if (cmd->base.duplex == DUPLEX_HALF)
 				setting = SUPPORTED_10baseT_Half;
 			else
 				return -EINVAL;
@@ -3674,7 +3686,7 @@ static int sky2_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 			return -EINVAL;
 
 		sky2->speed = speed;
-		sky2->duplex = ecmd->duplex;
+		sky2->duplex = cmd->base.duplex;
 		sky2->flags &= ~SKY2_FLAG_AUTO_SPEED;
 	}
 
@@ -4405,8 +4417,6 @@ static int sky2_set_features(struct net_device *dev, netdev_features_t features)
 }
 
 static const struct ethtool_ops sky2_ethtool_ops = {
-	.get_settings	= sky2_get_settings,
-	.set_settings	= sky2_set_settings,
 	.get_drvinfo	= sky2_get_drvinfo,
 	.get_wol	= sky2_get_wol,
 	.set_wol	= sky2_set_wol,
@@ -4429,6 +4439,8 @@ static int sky2_set_features(struct net_device *dev, netdev_features_t features)
 	.set_phys_id	= sky2_set_phys_id,
 	.get_sset_count = sky2_get_sset_count,
 	.get_ethtool_stats = sky2_get_ethtool_stats,
+	.get_link_ksettings = sky2_get_link_ksettings,
+	.set_link_ksettings = sky2_set_link_ksettings,
 };
 
 #ifdef CONFIG_SKY2_DEBUG
-- 
1.7.4.4
