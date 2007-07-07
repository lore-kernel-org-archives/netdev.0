From: "Michael Chan" <mchan@broadcom.com>
Subject: [2.6.23 4/9][BNX2]: Add ethtool support for remote PHY.
Date: Fri, 06 Jul 2007 20:29:42 -0700
Message-ID: <1183778982.5182.21.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3919 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771AbXGGChU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 22:37:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add ethtool support for remote PHY.

Modify the driver's ethtool_ops->get_settings and set_settings
functions to support remote PHY.  Users control the remote copper
PHY settings by specifying link settings for the tp (twisted pair)
port.

The nway_reset function is also modified to support remote PHY.
mii-tool operations are not supported on remote PHY and we will
return -EOPNOTSUPP.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 3268d16..514ad32 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5363,17 +5363,25 @@ static int
 bnx2_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct bnx2 *bp = netdev_priv(dev);
+	int support_serdes = 0, support_copper = 0;
 
 	cmd->supported = SUPPORTED_Autoneg;
-	if (bp->phy_flags & PHY_SERDES_FLAG) {
+	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG) {
+		support_serdes = 1;
+		support_copper = 1;
+	} else if (bp->phy_port == PORT_FIBRE)
+		support_serdes = 1;
+	else
+		support_copper = 1;
+
+	if (support_serdes) {
 		cmd->supported |= SUPPORTED_1000baseT_Full |
 			SUPPORTED_FIBRE;
 		if (bp->phy_flags & PHY_2_5G_CAPABLE_FLAG)
 			cmd->supported |= SUPPORTED_2500baseX_Full;
 
-		cmd->port = PORT_FIBRE;
 	}
-	else {
+	if (support_copper) {
 		cmd->supported |= SUPPORTED_10baseT_Half |
 			SUPPORTED_10baseT_Full |
 			SUPPORTED_100baseT_Half |
@@ -5381,9 +5389,10 @@ bnx2_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			SUPPORTED_1000baseT_Full |
 			SUPPORTED_TP;
 
-		cmd->port = PORT_TP;
 	}
 
+	spin_lock_bh(&bp->phy_lock);
+	cmd->port = bp->phy_port;
 	cmd->advertising = bp->advertising;
 
 	if (bp->autoneg & AUTONEG_SPEED) {
@@ -5401,6 +5410,7 @@ bnx2_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->speed = -1;
 		cmd->duplex = -1;
 	}
+	spin_unlock_bh(&bp->phy_lock);
 
 	cmd->transceiver = XCVR_INTERNAL;
 	cmd->phy_address = bp->phy_addr;
@@ -5416,6 +5426,15 @@ bnx2_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	u8 req_duplex = bp->req_duplex;
 	u16 req_line_speed = bp->req_line_speed;
 	u32 advertising = bp->advertising;
+	int err = -EINVAL;
+
+	spin_lock_bh(&bp->phy_lock);
+
+	if (cmd->port != PORT_TP && cmd->port != PORT_FIBRE)
+		goto err_out_unlock;
+
+	if (cmd->port != bp->phy_port && !(bp->phy_flags & REMOTE_PHY_CAP_FLAG))
+		goto err_out_unlock;
 
 	if (cmd->autoneg == AUTONEG_ENABLE) {
 		autoneg |= AUTONEG_SPEED;
@@ -5428,44 +5447,41 @@ bnx2_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			(cmd->advertising == ADVERTISED_100baseT_Half) ||
 			(cmd->advertising == ADVERTISED_100baseT_Full)) {
 
-			if (bp->phy_flags & PHY_SERDES_FLAG)
-				return -EINVAL;
+			if (cmd->port == PORT_FIBRE)
+				goto err_out_unlock;
 
 			advertising = cmd->advertising;
 
 		} else if (cmd->advertising == ADVERTISED_2500baseX_Full) {
-			if (!(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
-				return -EINVAL;
-		} else if (cmd->advertising == ADVERTISED_1000baseT_Full) {
+			if (!(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG) ||
+			    (cmd->port == PORT_TP))
+				goto err_out_unlock;
+		} else if (cmd->advertising == ADVERTISED_1000baseT_Full)
 			advertising = cmd->advertising;
-		}
-		else if (cmd->advertising == ADVERTISED_1000baseT_Half) {
-			return -EINVAL;
-		}
+		else if (cmd->advertising == ADVERTISED_1000baseT_Half)
+			goto err_out_unlock;
 		else {
-			if (bp->phy_flags & PHY_SERDES_FLAG) {
+			if (cmd->port == PORT_FIBRE)
 				advertising = ETHTOOL_ALL_FIBRE_SPEED;
-			}
-			else {
+			else
 				advertising = ETHTOOL_ALL_COPPER_SPEED;
-			}
 		}
 		advertising |= ADVERTISED_Autoneg;
 	}
 	else {
-		if (bp->phy_flags & PHY_SERDES_FLAG) {
+		if (cmd->port == PORT_FIBRE) {
 			if ((cmd->speed != SPEED_1000 &&
 			     cmd->speed != SPEED_2500) ||
 			    (cmd->duplex != DUPLEX_FULL))
-				return -EINVAL;
+				goto err_out_unlock;
 
 			if (cmd->speed == SPEED_2500 &&
 			    !(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
-				return -EINVAL;
-		}
-		else if (cmd->speed == SPEED_1000) {
-			return -EINVAL;
+				goto err_out_unlock;
 		}
+		else if (cmd->speed == SPEED_1000 || cmd->speed == SPEED_2500)
+			goto err_out_unlock;
+
 		autoneg &= ~AUTONEG_SPEED;
 		req_line_speed = cmd->speed;
 		req_duplex = cmd->duplex;
@@ -5477,13 +5493,12 @@ bnx2_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	bp->req_line_speed = req_line_speed;
 	bp->req_duplex = req_duplex;
 
-	spin_lock_bh(&bp->phy_lock);
-
-	bnx2_setup_phy(bp, bp->phy_port);
+	err = bnx2_setup_phy(bp, cmd->port);
 
+err_out_unlock:
 	spin_unlock_bh(&bp->phy_lock);
 
-	return 0;
+	return err;
 }
 
 static void
@@ -5610,6 +5625,14 @@ bnx2_nway_reset(struct net_device *dev)
 
 	spin_lock_bh(&bp->phy_lock);
 
+	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG) {
+		int rc;
+
+		rc = bnx2_setup_remote_phy(bp, bp->phy_port);
+		spin_unlock_bh(&bp->phy_lock);
+		return rc;
+	}
+
 	/* Force a link down visible on the other side */
 	if (bp->phy_flags & PHY_SERDES_FLAG) {
 		bnx2_write_phy(bp, bp->mii_bmcr, BMCR_LOOPBACK);
@@ -6219,6 +6242,9 @@ bnx2_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCGMIIREG: {
 		u32 mii_regval;
 
+		if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+			return -EOPNOTSUPP;
+
 		if (!netif_running(dev))
 			return -EAGAIN;
 
@@ -6235,6 +6261,9 @@ bnx2_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
+		if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+			return -EOPNOTSUPP;
+
 		if (!netif_running(dev))
 			return -EAGAIN;
 


