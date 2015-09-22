From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 27/33] arcnet: Remove function pointer macro indirections
Date: Tue, 22 Sep 2015 11:02:08 +0200
Message-ID: <1442912534-10821-28-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50251 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932756AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

It's clearer to use function pointer calls directly instead of the
macro indirections of ARCRESET, ACOMMAND, ASTATUS, and AINTMASK.

Remove the now unused macros too.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcdevice.h |  5 ----
 drivers/net/arcnet/arcnet.c    | 64 +++++++++++++++++++++---------------------
 2 files changed, 32 insertions(+), 37 deletions(-)

diff --git a/drivers/net/arcnet/arcdevice.h b/drivers/net/arcnet/arcdevice.h
index a05a77d..2577485 100644
--- a/drivers/net/arcnet/arcdevice.h
+++ b/drivers/net/arcnet/arcdevice.h
@@ -318,11 +318,6 @@ struct arcnet_local {
 	void __iomem *mem_start;	/* pointer to ioremap'ed MMIO */
 };
 
-#define ARCRESET(x)  (lp->hw.reset(dev, (x)))
-#define ACOMMAND(x)  (lp->hw.command(dev, (x)))
-#define ASTATUS()    (lp->hw.status(dev))
-#define AINTMASK(x)  (lp->hw.intmask(dev, (x)))
-
 #if ARCNET_DEBUG_MAX & D_SKB
 void arcnet_dump_skb(struct net_device *dev, struct sk_buff *skb, char *desc);
 #else
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index c8423ee..bcfdd91 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -361,7 +361,7 @@ int arcnet_open(struct net_device *dev)
 	 * time, actually reset it.
 	 */
 	error = -ENODEV;
-	if (ARCRESET(0) && ARCRESET(1))
+	if (lp->hw.reset(dev, 0) && lp->hw.reset(dev, 1))
 		goto out_module_put;
 
 	newmtu = choose_mtu();
@@ -404,22 +404,22 @@ int arcnet_open(struct net_device *dev)
 		arc_printk(D_NORMAL, dev, "WARNING!  Station address FF may confuse DOS networking programs!\n");
 
 	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
-	if (ASTATUS() & RESETflag) {
+	if (lp->hw.status(dev) & RESETflag) {
 		arc_printk(D_DEBUG, dev, "%s: %d: %s\n",
 			   __FILE__, __LINE__, __func__);
-		ACOMMAND(CFLAGScmd | RESETclear);
+		lp->hw.command(dev, CFLAGScmd | RESETclear);
 	}
 
 	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	/* make sure we're ready to receive IRQ's. */
-	AINTMASK(0);
+	lp->hw.intmask(dev, 0);
 	udelay(1);		/* give it time to set the mask before
 				 * we reset it again. (may not even be
 				 * necessary)
 				 */
 	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	lp->intmask = NORXflag | RECONflag;
-	AINTMASK(lp->intmask);
+	lp->hw.intmask(dev, lp->intmask);
 	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 
 	netif_start_queue(dev);
@@ -440,9 +440,9 @@ int arcnet_close(struct net_device *dev)
 	netif_stop_queue(dev);
 
 	/* flush TX and disable RX */
-	AINTMASK(0);
-	ACOMMAND(NOTXcmd);	/* stop transmit */
-	ACOMMAND(NORXcmd);	/* disable receive */
+	lp->hw.intmask(dev, 0);
+	lp->hw.command(dev, NOTXcmd);	/* stop transmit */
+	lp->hw.command(dev, NORXcmd);	/* disable receive */
 	mdelay(1);
 
 	/* shut down the card */
@@ -518,7 +518,7 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 
 	arc_printk(D_DURING, dev,
 		   "transmit requested (status=%Xh, txbufs=%d/%d, len=%d, protocol %x)\n",
-		   ASTATUS(), lp->cur_tx, lp->next_tx, skb->len, skb->protocol);
+		   lp->hw.status(dev), lp->cur_tx, lp->next_tx, skb->len, skb->protocol);
 
 	pkt = (struct archdr *)skb->data;
 	soft = &pkt->soft.rfc1201;
@@ -540,7 +540,7 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 	netif_stop_queue(dev);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	AINTMASK(0);
+	lp->hw.intmask(dev, 0);
 	if (lp->next_tx == -1)
 		txbuf = get_arcbuf(dev);
 	else
@@ -577,15 +577,15 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 	}
 
 	arc_printk(D_DEBUG, dev, "%s: %d: %s, status: %x\n",
-		   __FILE__, __LINE__, __func__, ASTATUS());
+		   __FILE__, __LINE__, __func__, lp->hw.status(dev));
 	/* make sure we didn't ignore a TX IRQ while we were in here */
-	AINTMASK(0);
+	lp->hw.intmask(dev, 0);
 
 	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	lp->intmask |= TXFREEflag | EXCNAKflag;
-	AINTMASK(lp->intmask);
+	lp->hw.intmask(dev, lp->intmask);
 	arc_printk(D_DEBUG, dev, "%s: %d: %s, status: %x\n",
-		   __FILE__, __LINE__, __func__, ASTATUS());
+		   __FILE__, __LINE__, __func__, lp->hw.status(dev));
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 	if (freeskb)
@@ -603,7 +603,7 @@ static int go_tx(struct net_device *dev)
 	struct arcnet_local *lp = netdev_priv(dev);
 
 	arc_printk(D_DURING, dev, "go_tx: status=%Xh, intmask=%Xh, next_tx=%d, cur_tx=%d\n",
-		   ASTATUS(), lp->intmask, lp->next_tx, lp->cur_tx);
+		   lp->hw.status(dev), lp->intmask, lp->next_tx, lp->cur_tx);
 
 	if (lp->cur_tx != -1 || lp->next_tx == -1)
 		return 0;
@@ -615,7 +615,7 @@ static int go_tx(struct net_device *dev)
 	lp->next_tx = -1;
 
 	/* start sending */
-	ACOMMAND(TXcmd | (lp->cur_tx << 3));
+	lp->hw.command(dev, TXcmd | (lp->cur_tx << 3));
 
 	dev->stats.tx_packets++;
 	lp->lasttrans_dest = lp->lastload_dest;
@@ -631,7 +631,7 @@ void arcnet_timeout(struct net_device *dev)
 {
 	unsigned long flags;
 	struct arcnet_local *lp = netdev_priv(dev);
-	int status = ASTATUS();
+	int status = lp->hw.status(dev);
 	char *msg;
 
 	spin_lock_irqsave(&lp->lock, flags);
@@ -641,14 +641,14 @@ void arcnet_timeout(struct net_device *dev)
 		msg = "";
 		dev->stats.tx_aborted_errors++;
 		lp->timed_out = 1;
-		ACOMMAND(NOTXcmd | (lp->cur_tx << 3));
+		lp->hw.command(dev, NOTXcmd | (lp->cur_tx << 3));
 	}
 	dev->stats.tx_errors++;
 
 	/* make sure we didn't miss a TX or a EXC NAK IRQ */
-	AINTMASK(0);
+	lp->hw.intmask(dev, 0);
 	lp->intmask |= TXFREEflag | EXCNAKflag;
-	AINTMASK(lp->intmask);
+	lp->hw.intmask(dev, lp->intmask);
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
@@ -687,19 +687,19 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 	 * clear it right away (but nothing else).
 	 */
 	if (!netif_running(dev)) {
-		if (ASTATUS() & RESETflag)
-			ACOMMAND(CFLAGScmd | RESETclear);
-		AINTMASK(0);
+		if (lp->hw.status(dev) & RESETflag)
+			lp->hw.command(dev, CFLAGScmd | RESETclear);
+		lp->hw.intmask(dev, 0);
 		spin_unlock(&lp->lock);
 		return retval;
 	}
 
 	arc_printk(D_DURING, dev, "in arcnet_inthandler (status=%Xh, intmask=%Xh)\n",
-		   ASTATUS(), lp->intmask);
+		   lp->hw.status(dev), lp->intmask);
 
 	boguscount = 5;
 	do {
-		status = ASTATUS();
+		status = lp->hw.status(dev);
 		diagstatus = (status >> 8) & 0xFF;
 
 		arc_printk(D_DEBUG, dev, "%s: %d: %s: status=%x\n",
@@ -739,7 +739,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			if (lp->cur_rx != -1) {
 				arc_printk(D_DURING, dev, "enabling receive to buffer #%d\n",
 					   lp->cur_rx);
-				ACOMMAND(RXcmd | (lp->cur_rx << 3) | RXbcasts);
+				lp->hw.command(dev, RXcmd | (lp->cur_rx << 3) | RXbcasts);
 			}
 			didsomething++;
 		}
@@ -748,10 +748,10 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			arc_printk(D_DURING, dev, "EXCNAK IRQ (diagstat=%Xh)\n",
 				   diagstatus);
 
-			ACOMMAND(NOTXcmd);      /* disable transmit */
+			lp->hw.command(dev, NOTXcmd);      /* disable transmit */
 			lp->excnak_pending = 1;
 
-			ACOMMAND(EXCNAKclear);
+			lp->hw.command(dev, EXCNAKclear);
 			lp->intmask &= ~(EXCNAKflag);
 			didsomething++;
 		}
@@ -837,7 +837,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			didsomething++;
 		}
 		if (status & lp->intmask & RECONflag) {
-			ACOMMAND(CFLAGScmd | CONFIGclear);
+			lp->hw.command(dev, CFLAGScmd | CONFIGclear);
 			dev->stats.tx_carrier_errors++;
 
 			arc_printk(D_RECON, dev, "Network reconfiguration detected (status=%Xh)\n",
@@ -899,12 +899,12 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 	} while (--boguscount && didsomething);
 
 	arc_printk(D_DURING, dev, "arcnet_interrupt complete (status=%Xh, count=%d)\n",
-		   ASTATUS(), boguscount);
+		   lp->hw.status(dev), boguscount);
 	arc_printk(D_DURING, dev, "\n");
 
-	AINTMASK(0);
+	lp->hw.intmask(dev, 0);
 	udelay(1);
-	AINTMASK(lp->intmask);
+	lp->hw.intmask(dev, lp->intmask);
 
 	spin_unlock(&lp->lock);
 	return retval;
-- 
2.5.1
