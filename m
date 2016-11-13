From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: atheros: atl1: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 13 Nov 2016 18:35:14 +0100
Message-ID: <1479058514-22438-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: jcliburn@gmail.com, chris.snook@gmail.com, davem@davemloft.net,
        jarod@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35537 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753258AbcKMRfY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 12:35:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

The previous implementation of set_settings was modifying
the value of advertising, but with the new API, it's not
possible. The structure ethtool_link_ksettings is defined
as const.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c |   66 ++++++++++++++++-------------
 1 files changed, 36 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 9aede18..7dad8e4 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -3214,66 +3214,72 @@ static int atl1_get_sset_count(struct net_device *netdev, int sset)
 	}
 }
 
-static int atl1_get_settings(struct net_device *netdev,
-	struct ethtool_cmd *ecmd)
+static int atl1_get_link_ksettings(struct net_device *netdev,
+				   struct ethtool_link_ksettings *cmd)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 	struct atl1_hw *hw = &adapter->hw;
+	u32 supported, advertising;
 
-	ecmd->supported = (SUPPORTED_10baseT_Half |
+	supported = (SUPPORTED_10baseT_Half |
 			   SUPPORTED_10baseT_Full |
 			   SUPPORTED_100baseT_Half |
 			   SUPPORTED_100baseT_Full |
 			   SUPPORTED_1000baseT_Full |
 			   SUPPORTED_Autoneg | SUPPORTED_TP);
-	ecmd->advertising = ADVERTISED_TP;
+	advertising = ADVERTISED_TP;
 	if (hw->media_type == MEDIA_TYPE_AUTO_SENSOR ||
 	    hw->media_type == MEDIA_TYPE_1000M_FULL) {
-		ecmd->advertising |= ADVERTISED_Autoneg;
+		advertising |= ADVERTISED_Autoneg;
 		if (hw->media_type == MEDIA_TYPE_AUTO_SENSOR) {
-			ecmd->advertising |= ADVERTISED_Autoneg;
-			ecmd->advertising |=
+			advertising |= ADVERTISED_Autoneg;
+			advertising |=
 			    (ADVERTISED_10baseT_Half |
 			     ADVERTISED_10baseT_Full |
 			     ADVERTISED_100baseT_Half |
 			     ADVERTISED_100baseT_Full |
 			     ADVERTISED_1000baseT_Full);
 		} else
-			ecmd->advertising |= (ADVERTISED_1000baseT_Full);
+			advertising |= (ADVERTISED_1000baseT_Full);
 	}
-	ecmd->port = PORT_TP;
-	ecmd->phy_address = 0;
-	ecmd->transceiver = XCVR_INTERNAL;
+	cmd->base.port = PORT_TP;
+	cmd->base.phy_address = 0;
 
 	if (netif_carrier_ok(adapter->netdev)) {
 		u16 link_speed, link_duplex;
 		atl1_get_speed_and_duplex(hw, &link_speed, &link_duplex);
-		ethtool_cmd_speed_set(ecmd, link_speed);
+		cmd->base.speed = link_speed;
 		if (link_duplex == FULL_DUPLEX)
-			ecmd->duplex = DUPLEX_FULL;
+			cmd->base.duplex = DUPLEX_FULL;
 		else
-			ecmd->duplex = DUPLEX_HALF;
+			cmd->base.duplex = DUPLEX_HALF;
 	} else {
-		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
-		ecmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
 	if (hw->media_type == MEDIA_TYPE_AUTO_SENSOR ||
 	    hw->media_type == MEDIA_TYPE_1000M_FULL)
-		ecmd->autoneg = AUTONEG_ENABLE;
+		cmd->base.autoneg = AUTONEG_ENABLE;
 	else
-		ecmd->autoneg = AUTONEG_DISABLE;
+		cmd->base.autoneg = AUTONEG_DISABLE;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	return 0;
 }
 
-static int atl1_set_settings(struct net_device *netdev,
-	struct ethtool_cmd *ecmd)
+static int atl1_set_link_ksettings(struct net_device *netdev,
+				   const struct ethtool_link_ksettings *cmd)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 	struct atl1_hw *hw = &adapter->hw;
 	u16 phy_data;
 	int ret_val = 0;
 	u16 old_media_type = hw->media_type;
+	u32 advertising;
 
 	if (netif_running(adapter->netdev)) {
 		if (netif_msg_link(adapter))
@@ -3282,12 +3288,12 @@ static int atl1_set_settings(struct net_device *netdev,
 		atl1_down(adapter);
 	}
 
-	if (ecmd->autoneg == AUTONEG_ENABLE)
+	if (cmd->base.autoneg == AUTONEG_ENABLE)
 		hw->media_type = MEDIA_TYPE_AUTO_SENSOR;
 	else {
-		u32 speed = ethtool_cmd_speed(ecmd);
+		u32 speed = cmd->base.speed;
 		if (speed == SPEED_1000) {
-			if (ecmd->duplex != DUPLEX_FULL) {
+			if (cmd->base.duplex != DUPLEX_FULL) {
 				if (netif_msg_link(adapter))
 					dev_warn(&adapter->pdev->dev,
 						"1000M half is invalid\n");
@@ -3296,12 +3302,12 @@ static int atl1_set_settings(struct net_device *netdev,
 			}
 			hw->media_type = MEDIA_TYPE_1000M_FULL;
 		} else if (speed == SPEED_100) {
-			if (ecmd->duplex == DUPLEX_FULL)
+			if (cmd->base.duplex == DUPLEX_FULL)
 				hw->media_type = MEDIA_TYPE_100M_FULL;
 			else
 				hw->media_type = MEDIA_TYPE_100M_HALF;
 		} else {
-			if (ecmd->duplex == DUPLEX_FULL)
+			if (cmd->base.duplex == DUPLEX_FULL)
 				hw->media_type = MEDIA_TYPE_10M_FULL;
 			else
 				hw->media_type = MEDIA_TYPE_10M_HALF;
@@ -3309,7 +3315,7 @@ static int atl1_set_settings(struct net_device *netdev,
 	}
 	switch (hw->media_type) {
 	case MEDIA_TYPE_AUTO_SENSOR:
-		ecmd->advertising =
+		advertising =
 		    ADVERTISED_10baseT_Half |
 		    ADVERTISED_10baseT_Full |
 		    ADVERTISED_100baseT_Half |
@@ -3318,12 +3324,12 @@ static int atl1_set_settings(struct net_device *netdev,
 		    ADVERTISED_Autoneg | ADVERTISED_TP;
 		break;
 	case MEDIA_TYPE_1000M_FULL:
-		ecmd->advertising =
+		advertising =
 		    ADVERTISED_1000baseT_Full |
 		    ADVERTISED_Autoneg | ADVERTISED_TP;
 		break;
 	default:
-		ecmd->advertising = 0;
+		advertising = 0;
 		break;
 	}
 	if (atl1_phy_setup_autoneg_adv(hw)) {
@@ -3663,8 +3669,6 @@ static int atl1_nway_reset(struct net_device *netdev)
 }
 
 static const struct ethtool_ops atl1_ethtool_ops = {
-	.get_settings		= atl1_get_settings,
-	.set_settings		= atl1_set_settings,
 	.get_drvinfo		= atl1_get_drvinfo,
 	.get_wol		= atl1_get_wol,
 	.set_wol		= atl1_set_wol,
@@ -3681,6 +3685,8 @@ static int atl1_nway_reset(struct net_device *netdev)
 	.nway_reset		= atl1_nway_reset,
 	.get_ethtool_stats	= atl1_get_ethtool_stats,
 	.get_sset_count		= atl1_get_sset_count,
+	.get_link_ksettings	= atl1_get_link_ksettings,
+	.set_link_ksettings	= atl1_set_link_ksettings,
 };
 
 module_pci_driver(atl1_driver);
-- 
1.7.4.4
