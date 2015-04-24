From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 05/21] ARCNET: remove unneeded macros
Date: Fri, 24 Apr 2015 19:20:39 +0200
Message-ID: <1429896055-31680-6-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The simple macros ARCRESET, ACOMMAND, ASTATUS, AINTMASK are unnecessary
indirections to the use of registers. This patch removes them and improves the
readability of the code.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcnet.c | 68 +++++++++++++++++++++++----------------------
 include/linux/arcdevice.h   |  7 -----
 2 files changed, 35 insertions(+), 40 deletions(-)

diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index f83034c..4990b0d 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -382,7 +382,7 @@ int arcnet_open(struct net_device *dev)
 	 * time, actually reset it.
 	 */
 	error = -ENODEV;
-	if (ARCRESET(0) && ARCRESET(1))
+	if (lp->hw.reset(dev, 0) && lp->hw.reset(dev, 1))
 		goto out_module_put;
 
 	newmtu = choose_mtu();
@@ -427,22 +427,22 @@ int arcnet_open(struct net_device *dev)
 		       "DOS networking programs!\n");
 
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
-	if (ASTATUS() & RESETflag) {
+	if (lp->hw.status(dev) & RESETflag) {
 	  	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
-		ACOMMAND(CFLAGScmd | RESETclear);
+		lp->hw.command(dev, CFLAGScmd | RESETclear);
 	}
 
 
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	/* make sure we're ready to receive IRQ's. */
-	AINTMASK(0);
+	lp->hw.intmask(dev, 0);
 	udelay(1);		/* give it time to set the mask before
 				 * we reset it again. (may not even be
 				 * necessary)
 				 */
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	lp->intmask = NORXflag | RECONflag;
-	AINTMASK(lp->intmask);
+	lp->hw.intmask(dev, lp->intmask);
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 
 	netif_start_queue(dev);
@@ -463,9 +463,9 @@ int arcnet_close(struct net_device *dev)
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
@@ -545,7 +545,7 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 
 	BUGMSG(D_DURING,
 	       "transmit requested (status=%Xh, txbufs=%d/%d, len=%d, protocol %x)\n",
-	       ASTATUS(), lp->cur_tx, lp->next_tx, skb->len,skb->protocol);
+	       lp->hw.status(dev), lp->cur_tx, lp->next_tx, skb->len, skb->protocol);
 
 	pkt = (struct archdr *) skb->data;
 	soft = &pkt->soft.rfc1201;
@@ -566,7 +566,7 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 	netif_stop_queue(dev);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	AINTMASK(0);
+	lp->hw.intmask(dev, 0);
 	if (lp->next_tx == -1) {
 		txbuf = get_arcbuf(dev);
 	} else {
@@ -601,14 +601,16 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 		freeskb = 0;
 	}
 
-	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n",__FILE__,__LINE__,__func__,ASTATUS());
+	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n",
+	       __FILE__, __LINE__, __func__, lp->hw.status(dev));
 	/* make sure we didn't ignore a TX IRQ while we were in here */
-	AINTMASK(0);
+	lp->hw.intmask(dev, 0);
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	lp->intmask |= TXFREEflag|EXCNAKflag;
-	AINTMASK(lp->intmask);
-	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n",__FILE__,__LINE__,__func__,ASTATUS());
+	lp->hw.intmask(dev, lp->intmask);
+	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n",
+	       __FILE__, __LINE__, __func__, lp->hw.status(dev));
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 	if (freeskb) {
@@ -627,7 +629,7 @@ static int go_tx(struct net_device *dev)
 	struct arcnet_local *lp = netdev_priv(dev);
 
 	BUGMSG(D_DURING, "go_tx: status=%Xh, intmask=%Xh, next_tx=%d, cur_tx=%d\n",
-	       ASTATUS(), lp->intmask, lp->next_tx, lp->cur_tx);
+	       lp->hw.status(dev), lp->intmask, lp->next_tx, lp->cur_tx);
 
 	if (lp->cur_tx != -1 || lp->next_tx == -1)
 		return 0;
@@ -638,7 +640,7 @@ static int go_tx(struct net_device *dev)
 	lp->next_tx = -1;
 
 	/* start sending */
-	ACOMMAND(TXcmd | (lp->cur_tx << 3));
+	lp->hw.command(dev, TXcmd | (lp->cur_tx << 3));
 
 	dev->stats.tx_packets++;
 	lp->lasttrans_dest = lp->lastload_dest;
@@ -655,7 +657,7 @@ void arcnet_timeout(struct net_device *dev)
 {
 	unsigned long flags;
 	struct arcnet_local *lp = netdev_priv(dev);
-	int status = ASTATUS();
+	int status = lp->hw.status(dev);
 	char *msg;
 
 	spin_lock_irqsave(&lp->lock, flags);
@@ -665,14 +667,14 @@ void arcnet_timeout(struct net_device *dev)
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
 	lp->intmask |= TXFREEflag|EXCNAKflag;
-	AINTMASK(lp->intmask);
+	lp->hw.intmask(dev, lp->intmask);
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
@@ -713,19 +715,19 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 	 * away (but nothing else).
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
 
 	BUGMSG(D_DURING, "in arcnet_inthandler (status=%Xh, intmask=%Xh)\n",
-	       ASTATUS(), lp->intmask);
+	       lp->hw.status(dev), lp->intmask);
 
 	boguscount = 5;
 	do {
-		status = ASTATUS();
+		status = lp->hw.status(dev);
 		diagstatus = (status >> 8) & 0xFF;
 
 		BUGMSG(D_DEBUG, "%s: %d: %s: status=%x\n",
@@ -765,7 +767,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			if (lp->cur_rx != -1) {
 				BUGMSG(D_DURING, "enabling receive to buffer #%d\n",
 				       lp->cur_rx);
-				ACOMMAND(RXcmd | (lp->cur_rx << 3) | RXbcasts);
+				lp->hw.command(dev, RXcmd | (lp->cur_rx << 3) | RXbcasts);
 			}
 			didsomething++;
 		}
@@ -774,10 +776,10 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			BUGMSG(D_DURING, "EXCNAK IRQ (diagstat=%Xh)\n",
 			       diagstatus);
 
-			ACOMMAND(NOTXcmd);      /* disable transmit */
+			lp->hw.command(dev, NOTXcmd); /* disable transmit */
 			lp->excnak_pending = 1;
 
-			ACOMMAND(EXCNAKclear);
+			lp->hw.command(dev, EXCNAKclear);
 			lp->intmask &= ~(EXCNAKflag);
 			didsomething++;
 		}
@@ -860,7 +862,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			didsomething++;
 		}
 		if (status & lp->intmask & RECONflag) {
-			ACOMMAND(CFLAGScmd | CONFIGclear);
+			lp->hw.command(dev, CFLAGScmd | CONFIGclear);
 			dev->stats.tx_carrier_errors++;
 
 			BUGMSG(D_RECON, "Network reconfiguration detected (status=%Xh)\n",
@@ -921,12 +923,12 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 	while (--boguscount && didsomething);
 
 	BUGMSG(D_DURING, "arcnet_interrupt complete (status=%Xh, count=%d)\n",
-	       ASTATUS(), boguscount);
+	       lp->hw.status(dev), boguscount);
 	BUGMSG(D_DURING, "\n");
 
-	AINTMASK(0);
+	lp->hw.intmask(dev, 0);
 	udelay(1);
-	AINTMASK(lp->intmask);
+	lp->hw.intmask(dev, lp->intmask);
 
 	spin_unlock(&lp->lock);
 	return retval;
diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index 81f336f..c20f100 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -314,13 +314,6 @@ struct arcnet_local {
 };
 
 
-#define ARCRESET(x)  (lp->hw.reset(dev, (x)))
-#define ACOMMAND(x)  (lp->hw.command(dev, (x)))
-#define ASTATUS()    (lp->hw.status(dev))
-#define AINTMASK(x)  (lp->hw.intmask(dev, (x)))
-
-
-
 #if ARCNET_DEBUG_MAX & D_SKB
 void arcnet_dump_skb(struct net_device *dev, struct sk_buff *skb, char *desc);
 #else
-- 
2.1.4
