From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: bnx2: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 13 Nov 2016 23:33:46 +0100
Message-ID: <1479076426-9024-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: rasesh.mody@cavium.com, harish.patil@cavium.com,
        Dept-GELinuxNICDev@cavium.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33398 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935048AbcKMWd4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 17:33:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   74 +++++++++++++++++++---------------
 1 files changed, 41 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index eab49ff..09d5b61 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6882,12 +6882,14 @@ static u32 bnx2_find_max_ring(u32 ring_size, u32 max_size)
 /* All ethtool functions called with rtnl_lock */
 
 static int
-bnx2_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+bnx2_get_link_ksettings(struct net_device *dev,
+			struct ethtool_link_ksettings *cmd)
 {
 	struct bnx2 *bp = netdev_priv(dev);
 	int support_serdes = 0, support_copper = 0;
+	u32 supported, advertising;
 
-	cmd->supported = SUPPORTED_Autoneg;
+	supported = SUPPORTED_Autoneg;
 	if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP) {
 		support_serdes = 1;
 		support_copper = 1;
@@ -6897,56 +6899,59 @@ static u32 bnx2_find_max_ring(u32 ring_size, u32 max_size)
 		support_copper = 1;
 
 	if (support_serdes) {
-		cmd->supported |= SUPPORTED_1000baseT_Full |
+		supported |= SUPPORTED_1000baseT_Full |
 			SUPPORTED_FIBRE;
 		if (bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE)
-			cmd->supported |= SUPPORTED_2500baseX_Full;
-
+			supported |= SUPPORTED_2500baseX_Full;
 	}
 	if (support_copper) {
-		cmd->supported |= SUPPORTED_10baseT_Half |
+		supported |= SUPPORTED_10baseT_Half |
 			SUPPORTED_10baseT_Full |
 			SUPPORTED_100baseT_Half |
 			SUPPORTED_100baseT_Full |
 			SUPPORTED_1000baseT_Full |
 			SUPPORTED_TP;
-
 	}
 
 	spin_lock_bh(&bp->phy_lock);
-	cmd->port = bp->phy_port;
-	cmd->advertising = bp->advertising;
+	cmd->base.port = bp->phy_port;
+	advertising = bp->advertising;
 
 	if (bp->autoneg & AUTONEG_SPEED) {
-		cmd->autoneg = AUTONEG_ENABLE;
+		cmd->base.autoneg = AUTONEG_ENABLE;
 	} else {
-		cmd->autoneg = AUTONEG_DISABLE;
+		cmd->base.autoneg = AUTONEG_DISABLE;
 	}
 
 	if (netif_carrier_ok(dev)) {
-		ethtool_cmd_speed_set(cmd, bp->line_speed);
-		cmd->duplex = bp->duplex;
+		cmd->base.speed = bp->line_speed;
+		cmd->base.duplex = bp->duplex;
 		if (!(bp->phy_flags & BNX2_PHY_FLAG_SERDES)) {
 			if (bp->phy_flags & BNX2_PHY_FLAG_MDIX)
-				cmd->eth_tp_mdix = ETH_TP_MDI_X;
+				cmd->base.eth_tp_mdix = ETH_TP_MDI_X;
 			else
-				cmd->eth_tp_mdix = ETH_TP_MDI;
+				cmd->base.eth_tp_mdix = ETH_TP_MDI;
 		}
 	}
 	else {
-		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
-		cmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
 	spin_unlock_bh(&bp->phy_lock);
 
-	cmd->transceiver = XCVR_INTERNAL;
-	cmd->phy_address = bp->phy_addr;
+	cmd->base.phy_address = bp->phy_addr;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	return 0;
 }
 
 static int
-bnx2_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+bnx2_set_link_ksettings(struct net_device *dev,
+			const struct ethtool_link_ksettings *cmd)
 {
 	struct bnx2 *bp = netdev_priv(dev);
 	u8 autoneg = bp->autoneg;
@@ -6957,24 +6962,26 @@ static u32 bnx2_find_max_ring(u32 ring_size, u32 max_size)
 
 	spin_lock_bh(&bp->phy_lock);
 
-	if (cmd->port != PORT_TP && cmd->port != PORT_FIBRE)
+	if (cmd->base.port != PORT_TP && cmd->base.port != PORT_FIBRE)
 		goto err_out_unlock;
 
-	if (cmd->port != bp->phy_port &&
+	if (cmd->base.port != bp->phy_port &&
 	    !(bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP))
 		goto err_out_unlock;
 
 	/* If device is down, we can store the settings only if the user
 	 * is setting the currently active port.
 	 */
-	if (!netif_running(dev) && cmd->port != bp->phy_port)
+	if (!netif_running(dev) && cmd->base.port != bp->phy_port)
 		goto err_out_unlock;
 
-	if (cmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		autoneg |= AUTONEG_SPEED;
 
-		advertising = cmd->advertising;
-		if (cmd->port == PORT_TP) {
+		ethtool_convert_link_mode_to_legacy_u32(
+			&advertising, cmd->link_modes.advertising);
+
+		if (cmd->base.port == PORT_TP) {
 			advertising &= ETHTOOL_ALL_COPPER_SPEED;
 			if (!advertising)
 				advertising = ETHTOOL_ALL_COPPER_SPEED;
@@ -6986,11 +6993,12 @@ static u32 bnx2_find_max_ring(u32 ring_size, u32 max_size)
 		advertising |= ADVERTISED_Autoneg;
 	}
 	else {
-		u32 speed = ethtool_cmd_speed(cmd);
-		if (cmd->port == PORT_FIBRE) {
+		u32 speed = cmd->base.speed;
+
+		if (cmd->base.port == PORT_FIBRE) {
 			if ((speed != SPEED_1000 &&
 			     speed != SPEED_2500) ||
-			    (cmd->duplex != DUPLEX_FULL))
+			    (cmd->base.duplex != DUPLEX_FULL))
 				goto err_out_unlock;
 
 			if (speed == SPEED_2500 &&
@@ -7001,7 +7009,7 @@ static u32 bnx2_find_max_ring(u32 ring_size, u32 max_size)
 
 		autoneg &= ~AUTONEG_SPEED;
 		req_line_speed = speed;
-		req_duplex = cmd->duplex;
+		req_duplex = cmd->base.duplex;
 		advertising = 0;
 	}
 
@@ -7015,7 +7023,7 @@ static u32 bnx2_find_max_ring(u32 ring_size, u32 max_size)
 	 * brought up.
 	 */
 	if (netif_running(dev))
-		err = bnx2_setup_phy(bp, cmd->port);
+		err = bnx2_setup_phy(bp, cmd->base.port);
 
 err_out_unlock:
 	spin_unlock_bh(&bp->phy_lock);
@@ -7800,8 +7808,6 @@ static int bnx2_set_channels(struct net_device *dev,
 }
 
 static const struct ethtool_ops bnx2_ethtool_ops = {
-	.get_settings		= bnx2_get_settings,
-	.set_settings		= bnx2_set_settings,
 	.get_drvinfo		= bnx2_get_drvinfo,
 	.get_regs_len		= bnx2_get_regs_len,
 	.get_regs		= bnx2_get_regs,
@@ -7825,6 +7831,8 @@ static int bnx2_set_channels(struct net_device *dev,
 	.get_sset_count		= bnx2_get_sset_count,
 	.get_channels		= bnx2_get_channels,
 	.set_channels		= bnx2_set_channels,
+	.get_link_ksettings	= bnx2_get_link_ksettings,
+	.set_link_ksettings	= bnx2_set_link_ksettings,
 };
 
 /* Called with rtnl_lock */
-- 
1.7.4.4
