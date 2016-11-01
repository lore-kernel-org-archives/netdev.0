From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: 3com: typhoon: use new api ethtool_{get|set}_link_ksettings
Date: Wed,  2 Nov 2016 00:11:51 +0100
Message-ID: <1478041911-22188-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: dave@thedillows.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/3com/typhoon.c |   60 +++++++++++++++++-----------------
 1 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 506b507..dbdf06f 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -996,28 +996,30 @@ enum state_values {
 }
 
 static int
-typhoon_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+typhoon_get_link_ksettings(struct net_device *dev,
+			   struct ethtool_link_ksettings *cmd)
 {
 	struct typhoon *tp = netdev_priv(dev);
+	u32 supported, advertising;
 
-	cmd->supported = SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
+	supported = SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
 				SUPPORTED_Autoneg;
 
 	switch (tp->xcvr_select) {
 	case TYPHOON_XCVR_10HALF:
-		cmd->advertising = ADVERTISED_10baseT_Half;
+		advertising = ADVERTISED_10baseT_Half;
 		break;
 	case TYPHOON_XCVR_10FULL:
-		cmd->advertising = ADVERTISED_10baseT_Full;
+		advertising = ADVERTISED_10baseT_Full;
 		break;
 	case TYPHOON_XCVR_100HALF:
-		cmd->advertising = ADVERTISED_100baseT_Half;
+		advertising = ADVERTISED_100baseT_Half;
 		break;
 	case TYPHOON_XCVR_100FULL:
-		cmd->advertising = ADVERTISED_100baseT_Full;
+		advertising = ADVERTISED_100baseT_Full;
 		break;
 	case TYPHOON_XCVR_AUTONEG:
-		cmd->advertising = ADVERTISED_10baseT_Half |
+		advertising = ADVERTISED_10baseT_Half |
 					    ADVERTISED_10baseT_Full |
 					    ADVERTISED_100baseT_Half |
 					    ADVERTISED_100baseT_Full |
@@ -1026,54 +1028,52 @@ enum state_values {
 	}
 
 	if(tp->capabilities & TYPHOON_FIBER) {
-		cmd->supported |= SUPPORTED_FIBRE;
-		cmd->advertising |= ADVERTISED_FIBRE;
-		cmd->port = PORT_FIBRE;
+		supported |= SUPPORTED_FIBRE;
+		advertising |= ADVERTISED_FIBRE;
+		cmd->base.port = PORT_FIBRE;
 	} else {
-		cmd->supported |= SUPPORTED_10baseT_Half |
+		supported |= SUPPORTED_10baseT_Half |
 		    			SUPPORTED_10baseT_Full |
 					SUPPORTED_TP;
-		cmd->advertising |= ADVERTISED_TP;
-		cmd->port = PORT_TP;
+		advertising |= ADVERTISED_TP;
+		cmd->base.port = PORT_TP;
 	}
 
 	/* need to get stats to make these link speed/duplex valid */
 	typhoon_do_get_stats(tp);
-	ethtool_cmd_speed_set(cmd, tp->speed);
-	cmd->duplex = tp->duplex;
-	cmd->phy_address = 0;
-	cmd->transceiver = XCVR_INTERNAL;
+	cmd->base.speed = tp->speed;
+	cmd->base.duplex = tp->duplex;
+	cmd->base.phy_address = 0;
 	if(tp->xcvr_select == TYPHOON_XCVR_AUTONEG)
-		cmd->autoneg = AUTONEG_ENABLE;
+		cmd->base.autoneg = AUTONEG_ENABLE;
 	else
-		cmd->autoneg = AUTONEG_DISABLE;
-	cmd->maxtxpkt = 1;
-	cmd->maxrxpkt = 1;
+		cmd->base.autoneg = AUTONEG_DISABLE;
 
 	return 0;
 }
 
 static int
-typhoon_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+typhoon_set_link_ksettings(struct net_device *dev,
+			   const struct ethtool_link_ksettings *cmd)
 {
 	struct typhoon *tp = netdev_priv(dev);
-	u32 speed = ethtool_cmd_speed(cmd);
+	u32 speed = cmd->base.speed;
 	struct cmd_desc xp_cmd;
 	__le16 xcvr;
 	int err;
 
 	err = -EINVAL;
-	if (cmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		xcvr = TYPHOON_XCVR_AUTONEG;
 	} else {
-		if (cmd->duplex == DUPLEX_HALF) {
+		if (cmd->base.duplex == DUPLEX_HALF) {
 			if (speed == SPEED_10)
 				xcvr = TYPHOON_XCVR_10HALF;
 			else if (speed == SPEED_100)
 				xcvr = TYPHOON_XCVR_100HALF;
 			else
 				goto out;
-		} else if (cmd->duplex == DUPLEX_FULL) {
+		} else if (cmd->base.duplex == DUPLEX_FULL) {
 			if (speed == SPEED_10)
 				xcvr = TYPHOON_XCVR_10FULL;
 			else if (speed == SPEED_100)
@@ -1091,12 +1091,12 @@ enum state_values {
 		goto out;
 
 	tp->xcvr_select = xcvr;
-	if(cmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		tp->speed = 0xff;	/* invalid */
 		tp->duplex = 0xff;	/* invalid */
 	} else {
 		tp->speed = speed;
-		tp->duplex = cmd->duplex;
+		tp->duplex = cmd->base.duplex;
 	}
 
 out:
@@ -1145,13 +1145,13 @@ enum state_values {
 }
 
 static const struct ethtool_ops typhoon_ethtool_ops = {
-	.get_settings		= typhoon_get_settings,
-	.set_settings		= typhoon_set_settings,
 	.get_drvinfo		= typhoon_get_drvinfo,
 	.get_wol		= typhoon_get_wol,
 	.set_wol		= typhoon_set_wol,
 	.get_link		= ethtool_op_get_link,
 	.get_ringparam		= typhoon_get_ringparam,
+	.get_link_ksettings	= typhoon_get_link_ksettings,
+	.set_link_ksettings	= typhoon_set_link_ksettings,
 };
 
 static int
-- 
1.7.4.4
