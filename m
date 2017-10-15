From: Roman Yeryomin <roman@advem.lv>
Subject: [PATCH net-next 09/10] net: korina: use dma api instead of dma_cache_* functions
Date: Sun, 15 Oct 2017 19:24:17 +0300
Message-ID: <20171015162417.1183-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1l1v.rtu.lv ([213.175.92.62]:52644 "EHLO mail.pbx.lv"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S1751441AbdJOQdK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 12:33:10 -0400
Received: from ubrain.corp.ubnt.com (unknown [213.175.92.61])
        by mail.pbx.lv (MailSystem) with ESMTPSA id 1AE91191951
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 19:23:38 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 44 ++++++++++++++++++-------------------------
 1 file changed, 18 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 9520fa1e35a2..8fa60d1fe022 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -113,6 +113,7 @@ struct korina_private {
 	struct dma_reg *tx_dma_regs;
 	struct dma_desc *td_ring; /* transmit descriptor ring */
 	struct dma_desc *rd_ring; /* receive descriptor ring  */
+	dma_addr_t ring_dma;
 
 	struct sk_buff *tx_skb[KORINA_NUM_TDS];
 	struct sk_buff *rx_skb[KORINA_NUM_RDS];
@@ -257,6 +258,7 @@ static int korina_send_packet(struct sk_buff *skb, struct net_device *dev)
 	struct korina_private *lp = netdev_priv(dev);
 	u32 chain_prev, chain_next, dmandptr;
 	struct dma_desc *td;
+	dma_addr_t dma_addr;
 
 	td = &lp->td_ring[lp->tx_chain_tail];
 
@@ -267,10 +269,10 @@ static int korina_send_packet(struct sk_buff *skb, struct net_device *dev)
 	lp->tx_count++;
 	lp->tx_skb[lp->tx_chain_tail] = skb;
 
-	dma_cache_wback((u32)skb->data, skb->len);
+	dma_addr = dma_map_single(&dev->dev, skb->data, skb->len, DMA_TO_DEVICE);
 
-	/* Setup the transmit descriptor. */
-	dma_cache_inv((u32) td, sizeof(*td));
+	/* flush descriptor */
+	wmb();
 
 	td->ca = CPHYSADDR(skb->data);
 	chain_prev = (lp->tx_chain_tail - 1) & KORINA_TDS_MASK;
@@ -299,7 +301,7 @@ static int korina_send_packet(struct sk_buff *skb, struct net_device *dev)
 		lp->tx_chain_status = desc_filled;
 	}
 
-	dma_cache_wback((u32) td, sizeof(*td));
+	dma_unmap_single(&dev->dev, dma_addr, skb->len, DMA_TO_DEVICE);
 
 	return NETDEV_TX_OK;
 }
@@ -375,8 +377,6 @@ static int korina_rx(struct net_device *dev, int limit)
 	u32 devcs, pkt_len, dmas;
 	int count;
 
-	dma_cache_inv((u32)rd, sizeof(*rd));
-
 	for (count = 0; count < limit; count++) {
 		skb = lp->rx_skb[lp->rx_next_done];
 		skb_new = NULL;
@@ -416,9 +416,6 @@ static int korina_rx(struct net_device *dev, int limit)
 		 * descriptor then */
 		pkt_buf = (u8 *)lp->rx_skb[lp->rx_next_done]->data;
 
-		/* invalidate the cache */
-		dma_cache_inv((unsigned long)pkt_buf, pkt_len - 4);
-
 		/* Malloc up new buffer. */
 		skb_new = netdev_alloc_skb_ip_align(dev, KORINA_RBSIZE);
 
@@ -455,7 +452,6 @@ static int korina_rx(struct net_device *dev, int limit)
 			~DMA_DESC_COD;
 
 		lp->rx_next_done = (lp->rx_next_done + 1) & KORINA_RDS_MASK;
-		dma_cache_wback((u32)rd, sizeof(*rd));
 		rd = &lp->rd_ring[lp->rx_next_done];
 		writel(~DMA_STAT_DONE, &lp->rx_dma_regs->dmas);
 	}
@@ -470,7 +466,6 @@ static int korina_rx(struct net_device *dev, int limit)
 		rd->devcs = 0;
 		skb = lp->rx_skb[lp->rx_next_done];
 		rd->ca = CPHYSADDR(skb->data);
-		dma_cache_wback((u32)rd, sizeof(*rd));
 		korina_chain_rx(lp, rd);
 	}
 
@@ -676,6 +671,13 @@ static int korina_alloc_ring(struct net_device *dev)
 	struct sk_buff *skb;
 	int i;
 
+	lp->td_ring = dma_alloc_coherent(NULL, TD_RING_SIZE + RD_RING_SIZE,
+						&lp->ring_dma, GFP_ATOMIC);
+	if (!lp->td_ring)
+		return -ENOMEM;
+
+	lp->rd_ring = &lp->td_ring[KORINA_NUM_TDS];
+
 	/* Initialize the transmit descriptors */
 	for (i = 0; i < KORINA_NUM_TDS; i++) {
 		lp->td_ring[i].control = DMA_DESC_IOF;
@@ -707,6 +709,8 @@ static int korina_alloc_ring(struct net_device *dev)
 
 	lp->rx_next_done  = 0;
 
+	wmb();
+
 	return 0;
 }
 
@@ -728,6 +732,9 @@ static void korina_free_ring(struct net_device *dev)
 			dev_kfree_skb_any(lp->tx_skb[i]);
 		lp->tx_skb[i] = NULL;
 	}
+
+	dma_free_coherent(NULL, TD_RING_SIZE + RD_RING_SIZE,
+					lp->td_ring, lp->ring_dma);
 }
 
 /*
@@ -979,19 +986,6 @@ static int korina_probe(struct platform_device *pdev)
 		goto probe_err_dma_tx;
 	}
 
-	lp->td_ring = kmalloc(TD_RING_SIZE + RD_RING_SIZE, GFP_KERNEL);
-	if (!lp->td_ring) {
-		rc = -ENXIO;
-		goto probe_err_td_ring;
-	}
-
-	dma_cache_inv((unsigned long)(lp->td_ring),
-			TD_RING_SIZE + RD_RING_SIZE);
-
-	/* now convert TD_RING pointer to KSEG1 */
-	lp->td_ring = (struct dma_desc *)KSEG1ADDR(lp->td_ring);
-	lp->rd_ring = &lp->td_ring[KORINA_NUM_TDS];
-
 	spin_lock_init(&lp->lock);
 	/* just use the rx dma irq */
 	dev->irq = lp->rx_irq;
@@ -1026,8 +1020,6 @@ static int korina_probe(struct platform_device *pdev)
 	return rc;
 
 probe_err_register:
-	kfree(lp->td_ring);
-probe_err_td_ring:
 	iounmap(lp->tx_dma_regs);
 probe_err_dma_tx:
 	iounmap(lp->rx_dma_regs);
-- 
2.11.0
