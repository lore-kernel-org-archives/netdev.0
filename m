From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [PATCH 1/6 resend] b44: fix manual speed/duplex/autoneg
 settings
Date: Tue, 20 Jun 2006 15:34:15 -0700
Message-ID: <1150842855.21197.53.camel@dhcp-10-7-81-7.broadcom.com>
References: <1150485545.8716.50.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:63242 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751444AbWFTWeu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 18:34:50 -0400
To: "Jeff Garzik" <jeff@garzik.org>
In-Reply-To: <1150485545.8716.50.camel@dhcp-10-7-81-7.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes for speed/duplex/autoneg settings and driver settings info.
This is a redo of a previous patch thanks to feedback from Jeff Garzik.

Signed-off-by: Gary Zambrano <zambrano@broadcom.com>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index d8233e0..41b1618 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1620,8 +1620,6 @@ static int b44_get_settings(struct net_d
 {
 	struct b44 *bp = netdev_priv(dev);
 
-	if (!netif_running(dev))
-		return -EAGAIN;
 	cmd->supported = (SUPPORTED_Autoneg);
 	cmd->supported |= (SUPPORTED_100baseT_Half |
 			  SUPPORTED_100baseT_Full |
@@ -1649,6 +1647,12 @@ static int b44_get_settings(struct net_d
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
@@ -1658,9 +1662,6 @@ static int b44_set_settings(struct net_d
 {
 	struct b44 *bp = netdev_priv(dev);
 
-	if (!netif_running(dev))
-		return -EAGAIN;
-
 	/* We do not support gigabit. */
 	if (cmd->autoneg == AUTONEG_ENABLE) {
 		if (cmd->advertising &
@@ -1677,28 +1678,39 @@ static int b44_set_settings(struct net_d
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
+		if (cmd->advertising == 0) {
+			bp->flags |= (B44_FLAG_ADV_10HALF |
+				      B44_FLAG_ADV_10FULL |
+				      B44_FLAG_ADV_100HALF |
+				      B44_FLAG_ADV_100FULL);
+		} else {
+			if (cmd->advertising & ADVERTISED_10baseT_Half)
+				bp->flags |= B44_FLAG_ADV_10HALF;
+			if (cmd->advertising & ADVERTISED_10baseT_Full)
+				bp->flags |= B44_FLAG_ADV_10FULL;
+			if (cmd->advertising & ADVERTISED_100baseT_Half)
+				bp->flags |= B44_FLAG_ADV_100HALF;
+			if (cmd->advertising & ADVERTISED_100baseT_Full)
+				bp->flags |= B44_FLAG_ADV_100FULL;
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
+	if (netif_running(dev))
+		b44_setup_phy(bp);
 
 	spin_unlock_irq(&bp->lock);
 


