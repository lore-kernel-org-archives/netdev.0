From: Roman Yeryomin <roman@advem.lv>
Subject: [PATCH net-next 01/10] net: korina: optimize korina_send_packet logic
Date: Sun, 15 Oct 2017 19:22:42 +0300
Message-ID: <20171015162242.661-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1l1v.rtu.lv ([213.175.92.62]:52616 "EHLO mail.pbx.lv"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S1751386AbdJOQ2J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 12:28:09 -0400
Received: from ubrain.corp.ubnt.com (unknown [213.175.92.61])
        by mail.pbx.lv (MailSystem) with ESMTPSA id 79F6D19187F
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 19:22:04 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 76 ++++++++++++++-----------------------------
 1 file changed, 24 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 7cecd9dbc111..84b2654e2d06 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -200,8 +200,7 @@ static int korina_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct korina_private *lp = netdev_priv(dev);
 	unsigned long flags;
-	u32 length;
-	u32 chain_prev, chain_next;
+	u32 chain_prev, chain_next, dmandptr;
 	struct dma_desc *td;
 
 	spin_lock_irqsave(&lp->lock, flags);
@@ -211,10 +210,9 @@ static int korina_send_packet(struct sk_buff *skb, struct net_device *dev)
 	/* stop queue when full, drop pkts if queue already full */
 	if (lp->tx_count >= (KORINA_NUM_TDS - 2)) {
 		lp->tx_full = 1;
+		netif_stop_queue(dev);
 
-		if (lp->tx_count == (KORINA_NUM_TDS - 2))
-			netif_stop_queue(dev);
-		else {
+		if (lp->tx_count > (KORINA_NUM_TDS - 2)) {
 			dev->stats.tx_dropped++;
 			dev_kfree_skb_any(skb);
 			spin_unlock_irqrestore(&lp->lock, flags);
@@ -224,66 +222,40 @@ static int korina_send_packet(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	lp->tx_count++;
-
 	lp->tx_skb[lp->tx_chain_tail] = skb;
 
-	length = skb->len;
 	dma_cache_wback((u32)skb->data, skb->len);
 
 	/* Setup the transmit descriptor. */
 	dma_cache_inv((u32) td, sizeof(*td));
+
 	td->ca = CPHYSADDR(skb->data);
 	chain_prev = (lp->tx_chain_tail - 1) & KORINA_TDS_MASK;
 	chain_next = (lp->tx_chain_tail + 1) & KORINA_TDS_MASK;
 
-	if (readl(&(lp->tx_dma_regs->dmandptr)) == 0) {
-		if (lp->tx_chain_status == desc_empty) {
-			/* Update tail */
-			td->control = DMA_COUNT(length) |
-					DMA_DESC_COF | DMA_DESC_IOF;
-			/* Move tail */
-			lp->tx_chain_tail = chain_next;
-			/* Write to NDPTR */
-			writel(CPHYSADDR(&lp->td_ring[lp->tx_chain_head]),
+	dmandptr = readl(&(lp->tx_dma_regs->dmandptr));
+	/* Update tail */
+	td->control = DMA_COUNT(skb->len) | DMA_DESC_COF | DMA_DESC_IOF;
+	/* Move tail */
+	lp->tx_chain_tail = chain_next;
+
+	if (lp->tx_chain_status != desc_empty) {
+		/* Link to prev */
+		lp->td_ring[chain_prev].control &= ~DMA_DESC_COF;
+		lp->td_ring[chain_prev].link =  CPHYSADDR(td);
+	}
+
+	if (!dmandptr) {
+		/* Write to NDPTR */
+		writel(CPHYSADDR(&lp->td_ring[lp->tx_chain_head]),
 					&lp->tx_dma_regs->dmandptr);
-			/* Move head to tail */
-			lp->tx_chain_head = lp->tx_chain_tail;
-		} else {
-			/* Update tail */
-			td->control = DMA_COUNT(length) |
-					DMA_DESC_COF | DMA_DESC_IOF;
-			/* Link to prev */
-			lp->td_ring[chain_prev].control &=
-					~DMA_DESC_COF;
-			/* Link to prev */
-			lp->td_ring[chain_prev].link =  CPHYSADDR(td);
-			/* Move tail */
-			lp->tx_chain_tail = chain_next;
-			/* Write to NDPTR */
-			writel(CPHYSADDR(&lp->td_ring[lp->tx_chain_head]),
-					&(lp->tx_dma_regs->dmandptr));
-			/* Move head to tail */
-			lp->tx_chain_head = lp->tx_chain_tail;
-			lp->tx_chain_status = desc_empty;
-		}
+		/* Move head to tail */
+		lp->tx_chain_head = lp->tx_chain_tail;
+		lp->tx_chain_status = desc_empty;
 	} else {
-		if (lp->tx_chain_status == desc_empty) {
-			/* Update tail */
-			td->control = DMA_COUNT(length) |
-					DMA_DESC_COF | DMA_DESC_IOF;
-			/* Move tail */
-			lp->tx_chain_tail = chain_next;
-			lp->tx_chain_status = desc_filled;
-		} else {
-			/* Update tail */
-			td->control = DMA_COUNT(length) |
-					DMA_DESC_COF | DMA_DESC_IOF;
-			lp->td_ring[chain_prev].control &=
-					~DMA_DESC_COF;
-			lp->td_ring[chain_prev].link =  CPHYSADDR(td);
-			lp->tx_chain_tail = chain_next;
-		}
+		lp->tx_chain_status = desc_filled;
 	}
+
 	dma_cache_wback((u32) td, sizeof(*td));
 
 	netif_trans_update(dev);
-- 
2.11.0
