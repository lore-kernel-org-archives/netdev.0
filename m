From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: brocade: bna: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 28 Nov 2016 23:52:19 +0100
Message-ID: <1480373539-3257-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: rasesh.mody@cavium.com, sudarsana.kalluru@cavium.com,
        Dept-GELinuxNICDev@cavium.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |   54 +++++++++++++----------
 1 files changed, 30 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index 31f61a7..2865939 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -240,40 +240,46 @@
 #define BNAD_ETHTOOL_STATS_NUM	ARRAY_SIZE(bnad_net_stats_strings)
 
 static int
-bnad_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
+bnad_get_link_ksettings(struct net_device *netdev,
+			struct ethtool_link_ksettings *cmd)
 {
-	cmd->supported = SUPPORTED_10000baseT_Full;
-	cmd->advertising = ADVERTISED_10000baseT_Full;
-	cmd->autoneg = AUTONEG_DISABLE;
-	cmd->supported |= SUPPORTED_FIBRE;
-	cmd->advertising |= ADVERTISED_FIBRE;
-	cmd->port = PORT_FIBRE;
-	cmd->phy_address = 0;
+	u32 supported, advertising;
+
+	supported = SUPPORTED_10000baseT_Full;
+	advertising = ADVERTISED_10000baseT_Full;
+	cmd->base.autoneg = AUTONEG_DISABLE;
+	supported |= SUPPORTED_FIBRE;
+	advertising |= ADVERTISED_FIBRE;
+	cmd->base.port = PORT_FIBRE;
+	cmd->base.phy_address = 0;
 
 	if (netif_carrier_ok(netdev)) {
-		ethtool_cmd_speed_set(cmd, SPEED_10000);
-		cmd->duplex = DUPLEX_FULL;
+		cmd->base.speed = SPEED_10000;
+		cmd->base.duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
-		cmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
-	cmd->transceiver = XCVR_EXTERNAL;
-	cmd->maxtxpkt = 0;
-	cmd->maxrxpkt = 0;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	return 0;
 }
 
 static int
-bnad_set_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
+bnad_set_link_ksettings(struct net_device *netdev,
+			const struct ethtool_link_ksettings *cmd)
 {
 	/* 10G full duplex setting supported only */
-	if (cmd->autoneg == AUTONEG_ENABLE)
-		return -EOPNOTSUPP; else {
-		if ((ethtool_cmd_speed(cmd) == SPEED_10000)
-		    && (cmd->duplex == DUPLEX_FULL))
-			return 0;
-	}
+	if (cmd->base.autoneg == AUTONEG_ENABLE)
+		return -EOPNOTSUPP;
+
+	if ((cmd->base.speed == SPEED_10000) &&
+	    (cmd->base.duplex == DUPLEX_FULL))
+		return 0;
 
 	return -EOPNOTSUPP;
 }
@@ -1118,8 +1124,6 @@
 }
 
 static const struct ethtool_ops bnad_ethtool_ops = {
-	.get_settings = bnad_get_settings,
-	.set_settings = bnad_set_settings,
 	.get_drvinfo = bnad_get_drvinfo,
 	.get_wol = bnad_get_wol,
 	.get_link = ethtool_op_get_link,
@@ -1137,6 +1141,8 @@
 	.set_eeprom = bnad_set_eeprom,
 	.flash_device = bnad_flash_device,
 	.get_ts_info = ethtool_op_get_ts_info,
+	.get_link_ksettings = bnad_get_link_ksettings,
+	.set_link_ksettings = bnad_set_link_ksettings,
 };
 
 void
-- 
1.7.4.4
