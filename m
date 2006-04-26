From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [resend PATCH 1/1] b44: fix ethool link settings support
Date: Wed, 26 Apr 2006 08:31:49 -0700
Message-ID: <1146065509.28067.52.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:42512 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S932413AbWDZWdR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 18:33:17 -0400
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The b44 driver support for setting link speed/duplex using ethtool was broken. 
This patch contains the following driver changes for link settings:
-clear the b44 flags of the previous settings before setting the phy
-allow access to get/set_settings() if interface is down
-set "advertised autoneg" setting dependent on autoneg enabled 
-return unknown speed/duplex if the interface is down

Signed-off-by: Gary Zambrano <zambrano@broadcom.com>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 3d30668..7b3dfc4 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1612,8 +1612,6 @@ static int b44_get_settings(struct net_d
 {
 	struct b44 *bp = netdev_priv(dev);
 
-	if (!netif_running(dev))
-		return -EAGAIN;
 	cmd->supported = (SUPPORTED_Autoneg);
 	cmd->supported |= (SUPPORTED_100baseT_Half |
 			  SUPPORTED_100baseT_Full |
@@ -1641,6 +1639,12 @@ static int b44_get_settings(struct net_d
 		XCVR_INTERNAL : XCVR_EXTERNAL;
 	cmd->autoneg = (bp->flags & B44_FLAG_FORCE_LINK) ?
 		AUTONEG_DISABLE : AUTONEG_ENABLE;
+	if (cmd->autoneg == AUTONEG_ENABLE)
+		cmd->advertising |= ADVERTISED_Autoneg;
+	if (!netif_running(dev)){
+		cmd->speed = 0; 
+		cmd->duplex = 0xff;
+	}
 	cmd->maxtxpkt = 0;
 	cmd->maxrxpkt = 0;
 	return 0;
@@ -1650,47 +1654,42 @@ static int b44_set_settings(struct net_d
 {
 	struct b44 *bp = netdev_priv(dev);
 
-	if (!netif_running(dev))
-		return -EAGAIN;
-
-	/* We do not support gigabit. */
-	if (cmd->autoneg == AUTONEG_ENABLE) {
-		if (cmd->advertising &
-		    (ADVERTISED_1000baseT_Half |
-		     ADVERTISED_1000baseT_Full))
-			return -EINVAL;
-	} else if ((cmd->speed != SPEED_100 &&
-		    cmd->speed != SPEED_10) ||
-		   (cmd->duplex != DUPLEX_HALF &&
-		    cmd->duplex != DUPLEX_FULL)) {
-			return -EINVAL;
-	}
-
 	spin_lock_irq(&bp->lock);
 
 	if (cmd->autoneg == AUTONEG_ENABLE) {
-		bp->flags &= ~B44_FLAG_FORCE_LINK;
-		bp->flags &= ~(B44_FLAG_ADV_10HALF |
+		bp->flags &= ~(B44_FLAG_FORCE_LINK |
+			       B44_FLAG_100_BASE_T |
+			       B44_FLAG_FULL_DUPLEX |
+			       B44_FLAG_ADV_10HALF |
 			       B44_FLAG_ADV_10FULL |
 			       B44_FLAG_ADV_100HALF |
 			       B44_FLAG_ADV_100FULL);
-		if (cmd->advertising & ADVERTISE_10HALF)
-			bp->flags |= B44_FLAG_ADV_10HALF;
-		if (cmd->advertising & ADVERTISE_10FULL)
-			bp->flags |= B44_FLAG_ADV_10FULL;
-		if (cmd->advertising & ADVERTISE_100HALF)
-			bp->flags |= B44_FLAG_ADV_100HALF;
-		if (cmd->advertising & ADVERTISE_100FULL)
-			bp->flags |= B44_FLAG_ADV_100FULL;
+		if (cmd->advertising & ADVERTISE_ALL) {
+			if (cmd->advertising & ADVERTISE_10HALF)
+				bp->flags |= B44_FLAG_ADV_10HALF;
+			if (cmd->advertising & ADVERTISE_10FULL)
+				bp->flags |= B44_FLAG_ADV_10FULL;
+			if (cmd->advertising & ADVERTISE_100HALF)
+				bp->flags |= B44_FLAG_ADV_100HALF;
+			if (cmd->advertising & ADVERTISE_100FULL)
+				bp->flags |= B44_FLAG_ADV_100FULL;
+		} else {
+			bp->flags |= (B44_FLAG_ADV_10HALF |
+				      B44_FLAG_ADV_10FULL |
+				      B44_FLAG_ADV_100HALF |
+				      B44_FLAG_ADV_100FULL);
+		}
 	} else {
 		bp->flags |= B44_FLAG_FORCE_LINK;
+		bp->flags &= ~(B44_FLAG_100_BASE_T | B44_FLAG_FULL_DUPLEX);
 		if (cmd->speed == SPEED_100)
 			bp->flags |= B44_FLAG_100_BASE_T;
 		if (cmd->duplex == DUPLEX_FULL)
 			bp->flags |= B44_FLAG_FULL_DUPLEX;
 	}
 
-	b44_setup_phy(bp);
+	if(netif_running(dev))
+		b44_setup_phy(bp);
 
 	spin_unlock_irq(&bp->lock);
 


