From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,try2 1/3] ep93xx_eth: fix RX/TXstatus ring full handling
Date: Mon, 30 Oct 2006 19:52:31 +0100
Message-ID: <20061030185231.GB14805@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ray Lehtiniemi <rayl@mail.com>,
	Herbert Valerio Riedel <hvr@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:46515 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1030573AbWJ3Swd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 13:52:33 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ray Lehtiniemi reported that an incoming UDP packet flood can lock up
the ep93xx ethernet driver.  Herbert Valerio Riedel noted that due to
the way ep93xx_eth manages the RX/TXstatus rings, it cannot distinguish
a full ring from an empty one, and correctly suggested that this was
likely to be causing this lockup to occur.

Instead of looking at the hardware's RX/TXstatus ring write pointers
to determine when to stop reading from those rings, we should just check
every individual RX/TXstatus descriptor's valid bit instead, since there
is no other way to distinguish an empty ring from a full ring, and if
there is a descriptor waiting, we take the hit of reading the descriptor
from memory anyway.

Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

Index: linux-2.6.19-rc3/drivers/net/arm/ep93xx_eth.c
===================================================================
--- linux-2.6.19-rc3.orig/drivers/net/arm/ep93xx_eth.c
+++ linux-2.6.19-rc3/drivers/net/arm/ep93xx_eth.c
@@ -193,12 +193,9 @@ static struct net_device_stats *ep93xx_g
 static int ep93xx_rx(struct net_device *dev, int *budget)
 {
 	struct ep93xx_priv *ep = netdev_priv(dev);
-	int tail_offset;
 	int rx_done;
 	int processed;
 
-	tail_offset = rdl(ep, REG_RXSTSQCURADD) - ep->descs_dma_addr;
-
 	rx_done = 0;
 	processed = 0;
 	while (*budget > 0) {
@@ -211,28 +208,23 @@ static int ep93xx_rx(struct net_device *
 
 		entry = ep->rx_pointer;
 		rstat = ep->descs->rstat + entry;
-		if ((void *)rstat - (void *)ep->descs == tail_offset) {
+
+		rstat0 = rstat->rstat0;
+		rstat1 = rstat->rstat1;
+		if (!(rstat0 & RSTAT0_RFP) || !(rstat1 & RSTAT1_RFP)) {
 			rx_done = 1;
 			break;
 		}
 
-		rstat0 = rstat->rstat0;
-		rstat1 = rstat->rstat1;
 		rstat->rstat0 = 0;
 		rstat->rstat1 = 0;
 
-		if (!(rstat0 & RSTAT0_RFP))
-			printk(KERN_CRIT "ep93xx_rx: buffer not done "
-					 " %.8x %.8x\n", rstat0, rstat1);
 		if (!(rstat0 & RSTAT0_EOF))
 			printk(KERN_CRIT "ep93xx_rx: not end-of-frame "
 					 " %.8x %.8x\n", rstat0, rstat1);
 		if (!(rstat0 & RSTAT0_EOB))
 			printk(KERN_CRIT "ep93xx_rx: not end-of-buffer "
 					 " %.8x %.8x\n", rstat0, rstat1);
-		if (!(rstat1 & RSTAT1_RFP))
-			printk(KERN_CRIT "ep93xx_rx: buffer1 not done "
-					 " %.8x %.8x\n", rstat0, rstat1);
 		if ((rstat1 & RSTAT1_BUFFER_INDEX) >> 16 != entry)
 			printk(KERN_CRIT "ep93xx_rx: entry mismatch "
 					 " %.8x %.8x\n", rstat0, rstat1);
@@ -301,13 +293,8 @@ err:
 
 static int ep93xx_have_more_rx(struct ep93xx_priv *ep)
 {
-	struct ep93xx_rstat *rstat;
-	int tail_offset;
-
-	rstat = ep->descs->rstat + ep->rx_pointer;
-	tail_offset = rdl(ep, REG_RXSTSQCURADD) - ep->descs_dma_addr;
-
-	return !((void *)rstat - (void *)ep->descs == tail_offset);
+	struct ep93xx_rstat *rstat = ep->descs->rstat + ep->rx_pointer;
+	return !!((rstat->rstat0 & RSTAT0_RFP) && (rstat->rstat1 & RSTAT1_RFP));
 }
 
 static int ep93xx_poll(struct net_device *dev, int *budget)
@@ -379,10 +366,8 @@ static int ep93xx_xmit(struct sk_buff *s
 static void ep93xx_tx_complete(struct net_device *dev)
 {
 	struct ep93xx_priv *ep = netdev_priv(dev);
-	int tail_offset;
 	int wake;
 
-	tail_offset = rdl(ep, REG_TXSTSQCURADD) - ep->descs_dma_addr;
 	wake = 0;
 
 	spin_lock(&ep->tx_pending_lock);
@@ -393,15 +378,13 @@ static void ep93xx_tx_complete(struct ne
 
 		entry = ep->tx_clean_pointer;
 		tstat = ep->descs->tstat + entry;
-		if ((void *)tstat - (void *)ep->descs == tail_offset)
-			break;
 
 		tstat0 = tstat->tstat0;
+		if (!(tstat0 & TSTAT0_TXFP))
+			break;
+
 		tstat->tstat0 = 0;
 
-		if (!(tstat0 & TSTAT0_TXFP))
-			printk(KERN_CRIT "ep93xx_tx_complete: buffer not done "
-					 " %.8x\n", tstat0);
 		if (tstat0 & TSTAT0_FA)
 			printk(KERN_CRIT "ep93xx_tx_complete: frame aborted "
 					 " %.8x\n", tstat0);
