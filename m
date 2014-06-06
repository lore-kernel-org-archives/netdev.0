From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] net: use ethtool_cmd_speed_set helper to set ethtool speed value
Date: Fri,  6 Jun 2014 14:17:01 +0200
Message-ID: <1402057021-12867-3-git-send-email-jiri@resnulli.us>
References: <1402057021-12867-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:50218 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646AbaFFMRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 08:17:09 -0400
Received: by mail-wg0-f48.google.com with SMTP id n12so2439751wgh.31
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 05:17:08 -0700 (PDT)
In-Reply-To: <1402057021-12867-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 12 +++++++-----
 drivers/net/ntb_netdev.c                     |  1 -
 drivers/s390/net/qeth_core_main.c            | 19 +++++++++++--------
 3 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index fca9a0e..d3d2154 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -141,6 +141,7 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	struct e1000_dev_spec_82575 *dev_spec = &hw->dev_spec._82575;
 	struct e1000_sfp_flags *eth_flags = &dev_spec->eth_flags;
 	u32 status;
+	u32 speed;
 
 	status = rd32(E1000_STATUS);
 	if (hw->phy.media_type == e1000_media_type_copper) {
@@ -215,13 +216,13 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	if (status & E1000_STATUS_LU) {
 		if ((status & E1000_STATUS_2P5_SKU) &&
 		    !(status & E1000_STATUS_2P5_SKU_OVER)) {
-			ecmd->speed = SPEED_2500;
+			speed = SPEED_2500;
 		} else if (status & E1000_STATUS_SPEED_1000) {
-			ecmd->speed = SPEED_1000;
+			speed = SPEED_1000;
 		} else if (status & E1000_STATUS_SPEED_100) {
-			ecmd->speed = SPEED_100;
+			speed = SPEED_100;
 		} else {
-			ecmd->speed = SPEED_10;
+			speed = SPEED_10;
 		}
 		if ((status & E1000_STATUS_FD) ||
 		    hw->phy.media_type != e1000_media_type_copper)
@@ -229,9 +230,10 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		else
 			ecmd->duplex = DUPLEX_HALF;
 	} else {
-		ecmd->speed = SPEED_UNKNOWN;
+		speed = SPEED_UNKNOWN;
 		ecmd->duplex = DUPLEX_UNKNOWN;
 	}
+	ethtool_cmd_speed_set(ecmd, speed);
 	if ((hw->phy.media_type == e1000_media_type_fiber) ||
 	    hw->mac.autoneg)
 		ecmd->autoneg = AUTONEG_ENABLE;
diff --git a/drivers/net/ntb_netdev.c b/drivers/net/ntb_netdev.c
index 27536aa..5a7e639 100644
--- a/drivers/net/ntb_netdev.c
+++ b/drivers/net/ntb_netdev.c
@@ -298,7 +298,6 @@ static int ntb_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	cmd->supported = SUPPORTED_Backplane;
 	cmd->advertising = ADVERTISED_Backplane;
-	cmd->speed = SPEED_UNKNOWN;
 	ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
 	cmd->duplex = DUPLEX_FULL;
 	cmd->port = PORT_OTHER;
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 549e9fd..18ddb24 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -5726,6 +5726,7 @@ int qeth_core_ethtool_get_settings(struct net_device *netdev,
 	struct qeth_card *card = netdev->ml_priv;
 	enum qeth_link_types link_type;
 	struct carrier_info carrier_info;
+	u32 speed;
 
 	if ((card->info.type == QETH_CARD_TYPE_IQD) || (card->info.guestlan))
 		link_type = QETH_LINK_TYPE_10GBIT_ETH;
@@ -5740,28 +5741,29 @@ int qeth_core_ethtool_get_settings(struct net_device *netdev,
 	case QETH_LINK_TYPE_FAST_ETH:
 	case QETH_LINK_TYPE_LANE_ETH100:
 		qeth_set_ecmd_adv_sup(ecmd, SPEED_100, PORT_TP);
-		ecmd->speed = SPEED_100;
+		speed = SPEED_100;
 		ecmd->port = PORT_TP;
 		break;
 
 	case QETH_LINK_TYPE_GBIT_ETH:
 	case QETH_LINK_TYPE_LANE_ETH1000:
 		qeth_set_ecmd_adv_sup(ecmd, SPEED_1000, PORT_FIBRE);
-		ecmd->speed = SPEED_1000;
+		speed = SPEED_1000;
 		ecmd->port = PORT_FIBRE;
 		break;
 
 	case QETH_LINK_TYPE_10GBIT_ETH:
 		qeth_set_ecmd_adv_sup(ecmd, SPEED_10000, PORT_FIBRE);
-		ecmd->speed = SPEED_10000;
+		speed = SPEED_10000;
 		ecmd->port = PORT_FIBRE;
 		break;
 
 	default:
 		qeth_set_ecmd_adv_sup(ecmd, SPEED_10, PORT_TP);
-		ecmd->speed = SPEED_10;
+		speed = SPEED_10;
 		ecmd->port = PORT_TP;
 	}
+	ethtool_cmd_speed_set(ecmd, speed);
 
 	/* Check if we can obtain more accurate information.	 */
 	/* If QUERY_CARD_INFO command is not supported or fails, */
@@ -5806,18 +5808,19 @@ int qeth_core_ethtool_get_settings(struct net_device *netdev,
 
 	switch (carrier_info.port_speed) {
 	case CARD_INFO_PORTS_10M:
-		ecmd->speed = SPEED_10;
+		speed = SPEED_10;
 		break;
 	case CARD_INFO_PORTS_100M:
-		ecmd->speed = SPEED_100;
+		speed = SPEED_100;
 		break;
 	case CARD_INFO_PORTS_1G:
-		ecmd->speed = SPEED_1000;
+		speed = SPEED_1000;
 		break;
 	case CARD_INFO_PORTS_10G:
-		ecmd->speed = SPEED_10000;
+		speed = SPEED_10000;
 		break;
 	}
+	ethtool_cmd_speed_set(ecmd, speed);
 
 	return 0;
 }
-- 
1.9.0
