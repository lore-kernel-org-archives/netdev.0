From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: nicvf: use new api ethtool_{get|set}_link_ksettings
Date: Sat, 10 Dec 2016 15:00:48 +0100
Message-ID: <1481378448-22278-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: sgoutham@cavium.com, rric@kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    |   56 +++++++++++---------
 1 files changed, 31 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
index b048241..2e74bba 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
@@ -116,33 +116,34 @@ struct nicvf_stat {
 static const unsigned int nicvf_n_drv_stats = ARRAY_SIZE(nicvf_drv_stats);
 static const unsigned int nicvf_n_queue_stats = ARRAY_SIZE(nicvf_queue_stats);
 
-static int nicvf_get_settings(struct net_device *netdev,
-			      struct ethtool_cmd *cmd)
+static int nicvf_get_link_ksettings(struct net_device *netdev,
+				    struct ethtool_link_ksettings *cmd)
 {
 	struct nicvf *nic = netdev_priv(netdev);
+	u32 supported, advertising;
 
-	cmd->supported = 0;
-	cmd->transceiver = XCVR_EXTERNAL;
+	supported = 0;
+	advertising = 0;
 
 	if (!nic->link_up) {
-		cmd->duplex = DUPLEX_UNKNOWN;
-		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
+		cmd->base.duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
 		return 0;
 	}
 
 	switch (nic->speed) {
 	case SPEED_1000:
-		cmd->port = PORT_MII | PORT_TP;
-		cmd->autoneg = AUTONEG_ENABLE;
-		cmd->supported |= SUPPORTED_MII | SUPPORTED_TP;
-		cmd->supported |= SUPPORTED_1000baseT_Full |
+		cmd->base.port = PORT_MII | PORT_TP;
+		cmd->base.autoneg = AUTONEG_ENABLE;
+		supported |= SUPPORTED_MII | SUPPORTED_TP;
+		supported |= SUPPORTED_1000baseT_Full |
 				  SUPPORTED_1000baseT_Half |
 				  SUPPORTED_100baseT_Full  |
 				  SUPPORTED_100baseT_Half  |
 				  SUPPORTED_10baseT_Full   |
 				  SUPPORTED_10baseT_Half;
-		cmd->supported |= SUPPORTED_Autoneg;
-		cmd->advertising |= ADVERTISED_1000baseT_Full |
+		supported |= SUPPORTED_Autoneg;
+		advertising |= ADVERTISED_1000baseT_Full |
 				    ADVERTISED_1000baseT_Half |
 				    ADVERTISED_100baseT_Full  |
 				    ADVERTISED_100baseT_Half  |
@@ -151,24 +152,29 @@ static int nicvf_get_settings(struct net_device *netdev,
 		break;
 	case SPEED_10000:
 		if (nic->mac_type == BGX_MODE_RXAUI) {
-			cmd->port = PORT_TP;
-			cmd->supported |= SUPPORTED_TP;
+			cmd->base.port = PORT_TP;
+			supported |= SUPPORTED_TP;
 		} else {
-			cmd->port = PORT_FIBRE;
-			cmd->supported |= SUPPORTED_FIBRE;
+			cmd->base.port = PORT_FIBRE;
+			supported |= SUPPORTED_FIBRE;
 		}
-		cmd->autoneg = AUTONEG_DISABLE;
-		cmd->supported |= SUPPORTED_10000baseT_Full;
+		cmd->base.autoneg = AUTONEG_DISABLE;
+		supported |= SUPPORTED_10000baseT_Full;
 		break;
 	case SPEED_40000:
-		cmd->port = PORT_FIBRE;
-		cmd->autoneg = AUTONEG_DISABLE;
-		cmd->supported |= SUPPORTED_FIBRE;
-		cmd->supported |= SUPPORTED_40000baseCR4_Full;
+		cmd->base.port = PORT_FIBRE;
+		cmd->base.autoneg = AUTONEG_DISABLE;
+		supported |= SUPPORTED_FIBRE;
+		supported |= SUPPORTED_40000baseCR4_Full;
 		break;
 	}
-	cmd->duplex = nic->duplex;
-	ethtool_cmd_speed_set(cmd, nic->speed);
+	cmd->base.duplex = nic->duplex;
+	cmd->base.speed = nic->speed;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	return 0;
 }
@@ -770,7 +776,6 @@ static int nicvf_set_pauseparam(struct net_device *dev,
 }
 
 static const struct ethtool_ops nicvf_ethtool_ops = {
-	.get_settings		= nicvf_get_settings,
 	.get_link		= nicvf_get_link,
 	.get_drvinfo		= nicvf_get_drvinfo,
 	.get_msglevel		= nicvf_get_msglevel,
@@ -793,6 +798,7 @@ static int nicvf_set_pauseparam(struct net_device *dev,
 	.get_pauseparam         = nicvf_get_pauseparam,
 	.set_pauseparam         = nicvf_set_pauseparam,
 	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_link_ksettings	= nicvf_get_link_ksettings,
 };
 
 void nicvf_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
