From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: broadcom: b44: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 18 Sep 2016 00:11:35 +0200
Message-ID: <1474150295-24622-2-git-send-email-tremyfr@gmail.com>
References: <1474150295-24622-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: zambrano@broadcom.com, davem@davemloft.net, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35468 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754693AbcIQWLu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 18:11:50 -0400
In-Reply-To: <1474150295-24622-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/broadcom/b44.c |   98 +++++++++++++++++++----------------
 1 files changed, 54 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 936f06f..17aa33c 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -1832,58 +1832,65 @@ static int b44_nway_reset(struct net_device *dev)
 	return r;
 }
 
-static int b44_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int b44_get_link_ksettings(struct net_device *dev,
+				  struct ethtool_link_ksettings *cmd)
 {
 	struct b44 *bp = netdev_priv(dev);
+	u32 supported, advertising;
 
 	if (bp->flags & B44_FLAG_EXTERNAL_PHY) {
 		BUG_ON(!dev->phydev);
-		return phy_ethtool_gset(dev->phydev, cmd);
+		return phy_ethtool_ksettings_get(dev->phydev, cmd);
 	}
 
-	cmd->supported = (SUPPORTED_Autoneg);
-	cmd->supported |= (SUPPORTED_100baseT_Half |
-			  SUPPORTED_100baseT_Full |
-			  SUPPORTED_10baseT_Half |
-			  SUPPORTED_10baseT_Full |
-			  SUPPORTED_MII);
+	supported = (SUPPORTED_Autoneg);
+	supported |= (SUPPORTED_100baseT_Half |
+		      SUPPORTED_100baseT_Full |
+		      SUPPORTED_10baseT_Half |
+		      SUPPORTED_10baseT_Full |
+		      SUPPORTED_MII);
 
-	cmd->advertising = 0;
+	advertising = 0;
 	if (bp->flags & B44_FLAG_ADV_10HALF)
-		cmd->advertising |= ADVERTISED_10baseT_Half;
+		advertising |= ADVERTISED_10baseT_Half;
 	if (bp->flags & B44_FLAG_ADV_10FULL)
-		cmd->advertising |= ADVERTISED_10baseT_Full;
+		advertising |= ADVERTISED_10baseT_Full;
 	if (bp->flags & B44_FLAG_ADV_100HALF)
-		cmd->advertising |= ADVERTISED_100baseT_Half;
+		advertising |= ADVERTISED_100baseT_Half;
 	if (bp->flags & B44_FLAG_ADV_100FULL)
-		cmd->advertising |= ADVERTISED_100baseT_Full;
-	cmd->advertising |= ADVERTISED_Pause | ADVERTISED_Asym_Pause;
-	ethtool_cmd_speed_set(cmd, ((bp->flags & B44_FLAG_100_BASE_T) ?
-				    SPEED_100 : SPEED_10));
-	cmd->duplex = (bp->flags & B44_FLAG_FULL_DUPLEX) ?
+		advertising |= ADVERTISED_100baseT_Full;
+	advertising |= ADVERTISED_Pause | ADVERTISED_Asym_Pause;
+	cmd->base.speed = (bp->flags & B44_FLAG_100_BASE_T) ?
+		SPEED_100 : SPEED_10;
+	cmd->base.duplex = (bp->flags & B44_FLAG_FULL_DUPLEX) ?
 		DUPLEX_FULL : DUPLEX_HALF;
-	cmd->port = 0;
-	cmd->phy_address = bp->phy_addr;
-	cmd->transceiver = (bp->flags & B44_FLAG_EXTERNAL_PHY) ?
-		XCVR_EXTERNAL : XCVR_INTERNAL;
-	cmd->autoneg = (bp->flags & B44_FLAG_FORCE_LINK) ?
+	cmd->base.port = 0;
+	cmd->base.phy_address = bp->phy_addr;
+	cmd->base.autoneg = (bp->flags & B44_FLAG_FORCE_LINK) ?
 		AUTONEG_DISABLE : AUTONEG_ENABLE;
-	if (cmd->autoneg == AUTONEG_ENABLE)
-		cmd->advertising |= ADVERTISED_Autoneg;
+	if (cmd->base.autoneg == AUTONEG_ENABLE)
+		advertising |= ADVERTISED_Autoneg;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	if (!netif_running(dev)){
-		ethtool_cmd_speed_set(cmd, 0);
-		cmd->duplex = 0xff;
+		cmd->base.speed = 0;
+		cmd->base.duplex = 0xff;
 	}
-	cmd->maxtxpkt = 0;
-	cmd->maxrxpkt = 0;
+
 	return 0;
 }
 
-static int b44_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int b44_set_link_ksettings(struct net_device *dev,
+				  const struct ethtool_link_ksettings *cmd)
 {
 	struct b44 *bp = netdev_priv(dev);
 	u32 speed;
 	int ret;
+	u32 advertising;
 
 	if (bp->flags & B44_FLAG_EXTERNAL_PHY) {
 		BUG_ON(!dev->phydev);
@@ -1891,31 +1898,34 @@ static int b44_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		if (netif_running(dev))
 			b44_setup_phy(bp);
 
-		ret = phy_ethtool_sset(dev->phydev, cmd);
+		ret = phy_ethtool_ksettings_set(dev->phydev, cmd);
 
 		spin_unlock_irq(&bp->lock);
 
 		return ret;
 	}
 
-	speed = ethtool_cmd_speed(cmd);
+	speed = cmd->base.speed;
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
 	/* We do not support gigabit. */
-	if (cmd->autoneg == AUTONEG_ENABLE) {
-		if (cmd->advertising &
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
+		if (advertising &
 		    (ADVERTISED_1000baseT_Half |
 		     ADVERTISED_1000baseT_Full))
 			return -EINVAL;
 	} else if ((speed != SPEED_100 &&
 		    speed != SPEED_10) ||
-		   (cmd->duplex != DUPLEX_HALF &&
-		    cmd->duplex != DUPLEX_FULL)) {
+		   (cmd->base.duplex != DUPLEX_HALF &&
+		    cmd->base.duplex != DUPLEX_FULL)) {
 			return -EINVAL;
 	}
 
 	spin_lock_irq(&bp->lock);
 
-	if (cmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		bp->flags &= ~(B44_FLAG_FORCE_LINK |
 			       B44_FLAG_100_BASE_T |
 			       B44_FLAG_FULL_DUPLEX |
@@ -1923,19 +1933,19 @@ static int b44_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			       B44_FLAG_ADV_10FULL |
 			       B44_FLAG_ADV_100HALF |
 			       B44_FLAG_ADV_100FULL);
-		if (cmd->advertising == 0) {
+		if (advertising == 0) {
 			bp->flags |= (B44_FLAG_ADV_10HALF |
 				      B44_FLAG_ADV_10FULL |
 				      B44_FLAG_ADV_100HALF |
 				      B44_FLAG_ADV_100FULL);
 		} else {
-			if (cmd->advertising & ADVERTISED_10baseT_Half)
+			if (advertising & ADVERTISED_10baseT_Half)
 				bp->flags |= B44_FLAG_ADV_10HALF;
-			if (cmd->advertising & ADVERTISED_10baseT_Full)
+			if (advertising & ADVERTISED_10baseT_Full)
 				bp->flags |= B44_FLAG_ADV_10FULL;
-			if (cmd->advertising & ADVERTISED_100baseT_Half)
+			if (advertising & ADVERTISED_100baseT_Half)
 				bp->flags |= B44_FLAG_ADV_100HALF;
-			if (cmd->advertising & ADVERTISED_100baseT_Full)
+			if (advertising & ADVERTISED_100baseT_Full)
 				bp->flags |= B44_FLAG_ADV_100FULL;
 		}
 	} else {
@@ -1943,7 +1953,7 @@ static int b44_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		bp->flags &= ~(B44_FLAG_100_BASE_T | B44_FLAG_FULL_DUPLEX);
 		if (speed == SPEED_100)
 			bp->flags |= B44_FLAG_100_BASE_T;
-		if (cmd->duplex == DUPLEX_FULL)
+		if (cmd->base.duplex == DUPLEX_FULL)
 			bp->flags |= B44_FLAG_FULL_DUPLEX;
 	}
 
@@ -2110,8 +2120,6 @@ static int b44_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 
 static const struct ethtool_ops b44_ethtool_ops = {
 	.get_drvinfo		= b44_get_drvinfo,
-	.get_settings		= b44_get_settings,
-	.set_settings		= b44_set_settings,
 	.nway_reset		= b44_nway_reset,
 	.get_link		= ethtool_op_get_link,
 	.get_wol		= b44_get_wol,
@@ -2125,6 +2133,8 @@ static const struct ethtool_ops b44_ethtool_ops = {
 	.get_strings		= b44_get_strings,
 	.get_sset_count		= b44_get_sset_count,
 	.get_ethtool_stats	= b44_get_ethtool_stats,
+	.get_link_ksettings	= b44_get_link_ksettings,
+	.set_link_ksettings	= b44_set_link_ksettings,
 };
 
 static int b44_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
-- 
1.7.4.4
