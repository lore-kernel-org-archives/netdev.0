From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: neterion: vxge: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 12 Feb 2017 17:33:13 +0100
Message-ID: <1486917193-7054-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: jdmason@kudzu.us, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/neterion/vxge/vxge-ethtool.c |   47 ++++++++++++---------
 1 files changed, 27 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c b/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
index 9a29670..db55e6d 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
@@ -38,9 +38,9 @@
 };
 
 /**
- * vxge_ethtool_sset - Sets different link parameters.
+ * vxge_ethtool_set_link_ksettings - Sets different link parameters.
  * @dev: device pointer.
- * @info: pointer to the structure with parameters given by ethtool to set
+ * @cmd: pointer to the structure with parameters given by ethtool to set
  * link information.
  *
  * The function sets different link parameters provided by the user onto
@@ -48,44 +48,51 @@
  * Return value:
  * 0 on success.
  */
-static int vxge_ethtool_sset(struct net_device *dev, struct ethtool_cmd *info)
+static int
+vxge_ethtool_set_link_ksettings(struct net_device *dev,
+				const struct ethtool_link_ksettings *cmd)
 {
 	/* We currently only support 10Gb/FULL */
-	if ((info->autoneg == AUTONEG_ENABLE) ||
-	    (ethtool_cmd_speed(info) != SPEED_10000) ||
-	    (info->duplex != DUPLEX_FULL))
+	if ((cmd->base.autoneg == AUTONEG_ENABLE) ||
+	    (cmd->base.speed != SPEED_10000) ||
+	    (cmd->base.duplex != DUPLEX_FULL))
 		return -EINVAL;
 
 	return 0;
 }
 
 /**
- * vxge_ethtool_gset - Return link specific information.
+ * vxge_ethtool_get_link_ksettings - Return link specific information.
  * @dev: device pointer.
- * @info: pointer to the structure with parameters given by ethtool
+ * @cmd: pointer to the structure with parameters given by ethtool
  * to return link information.
  *
  * Returns link specific information like speed, duplex etc.. to ethtool.
  * Return value :
  * return 0 on success.
  */
-static int vxge_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)
+static int vxge_ethtool_get_link_ksettings(struct net_device *dev,
+					   struct ethtool_link_ksettings *cmd)
 {
-	info->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
-	info->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
-	info->port = PORT_FIBRE;
+	ethtool_link_ksettings_zero_link_mode(cmd, supported);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, 10000baseT_Full);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, FIBRE);
 
-	info->transceiver = XCVR_EXTERNAL;
+	ethtool_link_ksettings_zero_link_mode(cmd, advertising);
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, 10000baseT_Full);
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, FIBRE);
+
+	cmd->base.port = PORT_FIBRE;
 
 	if (netif_carrier_ok(dev)) {
-		ethtool_cmd_speed_set(info, SPEED_10000);
-		info->duplex = DUPLEX_FULL;
+		cmd->base.speed = SPEED_10000;
+		cmd->base.duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(info, SPEED_UNKNOWN);
-		info->duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
 
-	info->autoneg = AUTONEG_DISABLE;
+	cmd->base.autoneg = AUTONEG_DISABLE;
 	return 0;
 }
 
@@ -1126,8 +1133,6 @@ static int vxge_fw_flash(struct net_device *dev, struct ethtool_flash *parms)
 }
 
 static const struct ethtool_ops vxge_ethtool_ops = {
-	.get_settings		= vxge_ethtool_gset,
-	.set_settings		= vxge_ethtool_sset,
 	.get_drvinfo		= vxge_ethtool_gdrvinfo,
 	.get_regs_len		= vxge_ethtool_get_regs_len,
 	.get_regs		= vxge_ethtool_gregs,
@@ -1139,6 +1144,8 @@ static int vxge_fw_flash(struct net_device *dev, struct ethtool_flash *parms)
 	.get_sset_count		= vxge_ethtool_get_sset_count,
 	.get_ethtool_stats	= vxge_get_ethtool_stats,
 	.flash_device		= vxge_fw_flash,
+	.get_link_ksettings	= vxge_ethtool_get_link_ksettings,
+	.set_link_ksettings	= vxge_ethtool_set_link_ksettings,
 };
 
 void vxge_initialize_ethtool_ops(struct net_device *ndev)
-- 
1.7.4.4
