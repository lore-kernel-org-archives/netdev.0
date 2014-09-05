From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH] greth: moved TX ring cleaning to NAPI rx poll func
Date: Fri,  5 Sep 2014 13:13:48 +0200
Message-ID: <1409915628-5249-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, software@gaisler.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsp-authed02.binero.net ([195.74.38.226]:12900 "EHLO
	vsp-authed-01-02.binero.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932164AbaIEMEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 08:04:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does not affect the 10/100 GRETH MAC.

Before all GBit GRETH TX descriptor ring cleaning was done in
start_xmit(), when descriptor list became full it activated
TX interrupt to start the NAPI rx poll function to do TX ring
cleaning.

With this patch the TX descriptor ring is always cleaned from
the NAPI rx poll function, triggered via TX or RX interrupt.
Otherwise we could end up in TX frames being sent but not
reported to the stack being sent. On the 10/100 GRETH this
is not an issue since the SKB is copied&aligned into private
buffers so that the SKB can be freed directly on start_xmit()

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/ethernet/aeroflex/greth.c |   86 ++++++++++++++++++--------------
 drivers/net/ethernet/aeroflex/greth.h |    2 +-
 2 files changed, 49 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 23578df..3005155 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -123,6 +123,12 @@ static inline void greth_enable_tx(struct greth_private *greth)
 	GRETH_REGORIN(greth->regs->control, GRETH_TXEN);
 }
 
+static inline void greth_enable_tx_and_irq(struct greth_private *greth)
+{
+	wmb(); /* BDs must been written to memory before enabling TX */
+	GRETH_REGORIN(greth->regs->control, GRETH_TXEN | GRETH_TXI);
+}
+
 static inline void greth_disable_tx(struct greth_private *greth)
 {
 	GRETH_REGANDIN(greth->regs->control, ~GRETH_TXEN);
@@ -447,29 +453,30 @@ out:
 	return err;
 }
 
+static inline u16 greth_num_free_bds(u16 tx_last, u16 tx_next)
+{
+	if (tx_next < tx_last)
+		return (tx_last - tx_next) - 1;
+	else
+		return GRETH_TXBD_NUM - (tx_next - tx_last) - 1;
+}
 
 static netdev_tx_t
 greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct greth_private *greth = netdev_priv(dev);
 	struct greth_bd *bdp;
-	u32 status = 0, dma_addr, ctrl;
+	u32 status, dma_addr;
 	int curr_tx, nr_frags, i, err = NETDEV_TX_OK;
 	unsigned long flags;
+	u16 tx_last;
 
 	nr_frags = skb_shinfo(skb)->nr_frags;
+	tx_last = greth->tx_last;
+	rmb(); /* tx_last is updated by the poll task */
 
-	/* Clean TX Ring */
-	greth_clean_tx_gbit(dev);
-
-	if (greth->tx_free < nr_frags + 1) {
-		spin_lock_irqsave(&greth->devlock, flags);/*save from poll/irq*/
-		ctrl = GRETH_REGLOAD(greth->regs->control);
-		/* Enable TX IRQ only if not already in poll() routine */
-		if (ctrl & GRETH_RXI)
-			GRETH_REGSAVE(greth->regs->control, ctrl | GRETH_TXI);
+	if (greth_num_free_bds(tx_last, greth->tx_next) < nr_frags + 1) {
 		netif_stop_queue(dev);
-		spin_unlock_irqrestore(&greth->devlock, flags);
 		err = NETDEV_TX_BUSY;
 		goto out;
 	}
@@ -488,6 +495,8 @@ greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev)
 	/* Linear buf */
 	if (nr_frags != 0)
 		status = GRETH_TXBD_MORE;
+	else
+		status = GRETH_BD_IE;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		status |= GRETH_TXBD_CSALL;
@@ -545,14 +554,12 @@ greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Enable the descriptor chain by enabling the first descriptor */
 	bdp = greth->tx_bd_base + greth->tx_next;
-	greth_write_bd(&bdp->stat, greth_read_bd(&bdp->stat) | GRETH_BD_EN);
-	greth->tx_next = curr_tx;
-	greth->tx_free -= nr_frags + 1;
-
-	wmb();
+	greth_write_bd(&bdp->stat,
+		       greth_read_bd(&bdp->stat) | GRETH_BD_EN);
 
 	spin_lock_irqsave(&greth->devlock, flags); /*save from poll/irq*/
-	greth_enable_tx(greth);
+	greth->tx_next = curr_tx;
+	greth_enable_tx_and_irq(greth);
 	spin_unlock_irqrestore(&greth->devlock, flags);
 
 	return NETDEV_TX_OK;
@@ -648,7 +655,6 @@ static void greth_clean_tx(struct net_device *dev)
 	if (greth->tx_free > 0) {
 		netif_wake_queue(dev);
 	}
-
 }
 
 static inline void greth_update_tx_stats(struct net_device *dev, u32 stat)
@@ -670,20 +676,22 @@ static void greth_clean_tx_gbit(struct net_device *dev)
 {
 	struct greth_private *greth;
 	struct greth_bd *bdp, *bdp_last_frag;
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	u32 stat;
 	int nr_frags, i;
+	u16 tx_last;
 
 	greth = netdev_priv(dev);
+	tx_last = greth->tx_last;
 
-	while (greth->tx_free < GRETH_TXBD_NUM) {
+	while (tx_last != greth->tx_next) {
 
-		skb = greth->tx_skbuff[greth->tx_last];
+		skb = greth->tx_skbuff[tx_last];
 
 		nr_frags = skb_shinfo(skb)->nr_frags;
 
 		/* We only clean fully completed SKBs */
-		bdp_last_frag = greth->tx_bd_base + SKIP_TX(greth->tx_last, nr_frags);
+		bdp_last_frag = greth->tx_bd_base + SKIP_TX(tx_last, nr_frags);
 
 		GRETH_REGSAVE(greth->regs->status, GRETH_INT_TE | GRETH_INT_TX);
 		mb();
@@ -692,14 +700,14 @@ static void greth_clean_tx_gbit(struct net_device *dev)
 		if (stat & GRETH_BD_EN)
 			break;
 
-		greth->tx_skbuff[greth->tx_last] = NULL;
+		greth->tx_skbuff[tx_last] = NULL;
 
 		greth_update_tx_stats(dev, stat);
 		dev->stats.tx_bytes += skb->len;
 
-		bdp = greth->tx_bd_base + greth->tx_last;
+		bdp = greth->tx_bd_base + tx_last;
 
-		greth->tx_last = NEXT_TX(greth->tx_last);
+		tx_last = NEXT_TX(tx_last);
 
 		dma_unmap_single(greth->dev,
 				 greth_read_bd(&bdp->addr),
@@ -708,21 +716,26 @@ static void greth_clean_tx_gbit(struct net_device *dev)
 
 		for (i = 0; i < nr_frags; i++) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-			bdp = greth->tx_bd_base + greth->tx_last;
+			bdp = greth->tx_bd_base + tx_last;
 
 			dma_unmap_page(greth->dev,
 				       greth_read_bd(&bdp->addr),
 				       skb_frag_size(frag),
 				       DMA_TO_DEVICE);
 
-			greth->tx_last = NEXT_TX(greth->tx_last);
+			tx_last = NEXT_TX(tx_last);
 		}
-		greth->tx_free += nr_frags+1;
 		dev_kfree_skb(skb);
 	}
+	if (skb) { /* skb is set only if the above while loop was entered */
+		wmb();
+		greth->tx_last = tx_last;
 
-	if (netif_queue_stopped(dev) && (greth->tx_free > (MAX_SKB_FRAGS+1)))
-		netif_wake_queue(dev);
+		if (netif_queue_stopped(dev) &&
+		    (greth_num_free_bds(tx_last, greth->tx_next) >
+		    (MAX_SKB_FRAGS+1)))
+			netif_wake_queue(dev);
+	}
 }
 
 static int greth_rx(struct net_device *dev, int limit)
@@ -965,16 +978,12 @@ static int greth_poll(struct napi_struct *napi, int budget)
 	greth = container_of(napi, struct greth_private, napi);
 
 restart_txrx_poll:
-	if (netif_queue_stopped(greth->netdev)) {
-		if (greth->gbit_mac)
-			greth_clean_tx_gbit(greth->netdev);
-		else
-			greth_clean_tx(greth->netdev);
-	}
-
 	if (greth->gbit_mac) {
+		greth_clean_tx_gbit(greth->netdev);
 		work_done += greth_rx_gbit(greth->netdev, budget - work_done);
 	} else {
+		if (netif_queue_stopped(greth->netdev))
+			greth_clean_tx(greth->netdev);
 		work_done += greth_rx(greth->netdev, budget - work_done);
 	}
 
@@ -983,7 +992,8 @@ restart_txrx_poll:
 		spin_lock_irqsave(&greth->devlock, flags);
 
 		ctrl = GRETH_REGLOAD(greth->regs->control);
-		if (netif_queue_stopped(greth->netdev)) {
+		if ((greth->gbit_mac && (greth->tx_last != greth->tx_next)) ||
+		    (!greth->gbit_mac && netif_queue_stopped(greth->netdev))) {
 			GRETH_REGSAVE(greth->regs->control,
 					ctrl | GRETH_TXI | GRETH_RXI);
 			mask = GRETH_INT_RX | GRETH_INT_RE |
diff --git a/drivers/net/ethernet/aeroflex/greth.h b/drivers/net/ethernet/aeroflex/greth.h
index 232a622..ae16ac9 100644
--- a/drivers/net/ethernet/aeroflex/greth.h
+++ b/drivers/net/ethernet/aeroflex/greth.h
@@ -107,7 +107,7 @@ struct greth_private {
 
 	u16 tx_next;
 	u16 tx_last;
-	u16 tx_free;
+	u16 tx_free; /* only used on 10/100Mbit */
 	u16 rx_cur;
 
 	struct greth_regs *regs;	/* Address of controller registers. */
-- 
1.7.0.4
