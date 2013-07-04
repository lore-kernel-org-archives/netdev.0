From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH] net: convert mvneta to build_skb()
Date: Thu, 4 Jul 2013 19:35:52 +0200
Message-ID: <20130704173552.GA23370@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:34408 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756593Ab3GDRfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jul 2013 13:35:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 0180a5e651dd771de18bf2c031ecfe7bb4c88d3e Mon Sep 17 00:00:00 2001
From: Willy Tarreau <w@1wt.eu>
Date: Sat, 15 Jun 2013 23:25:15 +0200
Subject: [PATCH] net: convert mvneta to build_skb()

We store the frag_size in the mvneta_port struct. In practice we'd need
a single bit to know how to free the data, but since we need the size to
call build_skb() anyway, let's store the full size.

With this patch, I observed a reproducible 2% performance improvement on
HTTP-based benchmarks.

Signed-off-by: Willy Tarreau <w@1wt.eu>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
Cc: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 71 ++++++++++++++++++++++++-----------
 1 file changed, 50 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index c966785..0f2c6df 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -225,6 +225,7 @@ struct mvneta_stats {
 
 struct mvneta_port {
 	int pkt_size;
+	unsigned int frag_size;
 	void __iomem *base;
 	struct mvneta_rx_queue *rxqs;
 	struct mvneta_tx_queue *txqs;
@@ -1259,22 +1260,33 @@ static int mvneta_rx_refill(struct mvneta_port *pp,
 
 {
 	dma_addr_t phys_addr;
-	struct sk_buff *skb;
-
-	skb = netdev_alloc_skb(pp->dev, pp->pkt_size);
-	if (!skb)
+	void *data;
+	unsigned int skb_size;
+
+	skb_size = SKB_DATA_ALIGN(pp->pkt_size + MVNETA_MH_SIZE + NET_SKB_PAD) +
+		SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	if (skb_size <= PAGE_SIZE) {
+		data = netdev_alloc_frag(skb_size);
+		pp->frag_size = skb_size;
+	} else {
+		data = kmalloc(skb_size, GFP_ATOMIC);
+		pp->frag_size = 0;
+	}
+	if (!data)
 		return -ENOMEM;
 
-	phys_addr = dma_map_single(pp->dev->dev.parent, skb->head,
+	phys_addr = dma_map_single(pp->dev->dev.parent, data,
 				   MVNETA_RX_BUF_SIZE(pp->pkt_size),
 				   DMA_FROM_DEVICE);
 	if (unlikely(dma_mapping_error(pp->dev->dev.parent, phys_addr))) {
-		dev_kfree_skb(skb);
+		if (pp->frag_size)
+			put_page(virt_to_head_page(data));
+		else
+			kfree(data);
 		return -ENOMEM;
 	}
 
-	mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)skb);
-
+	mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)data);
 	return 0;
 }
 
@@ -1328,9 +1340,13 @@ static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
 	rx_done = mvneta_rxq_busy_desc_num_get(pp, rxq);
 	for (i = 0; i < rxq->size; i++) {
 		struct mvneta_rx_desc *rx_desc = rxq->descs + i;
-		struct sk_buff *skb = (struct sk_buff *)rx_desc->buf_cookie;
+		void *data = (void *)rx_desc->buf_cookie;
+
+		if (pp->frag_size)
+			put_page(virt_to_head_page(data));
+		else
+			kfree(data);
 
-		dev_kfree_skb_any(skb);
 		dma_unmap_single(pp->dev->dev.parent, rx_desc->buf_phys_addr,
 				 rx_desc->data_size, DMA_FROM_DEVICE);
 	}
@@ -1359,6 +1375,7 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 	while (rx_done < rx_todo) {
 		struct mvneta_rx_desc *rx_desc = mvneta_rxq_next_desc_get(rxq);
 		struct sk_buff *skb;
+		unsigned char *data;
 		u32 rx_status;
 		int rx_bytes, err;
 
@@ -1366,14 +1383,14 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		rx_done++;
 		rx_filled++;
 		rx_status = rx_desc->status;
-		skb = (struct sk_buff *)rx_desc->buf_cookie;
+		data = (unsigned char *)rx_desc->buf_cookie;
 
 		if (!mvneta_rxq_desc_is_first_last(rx_desc) ||
-		    (rx_status & MVNETA_RXD_ERR_SUMMARY)) {
+		    (rx_status & MVNETA_RXD_ERR_SUMMARY) ||
+		    !(skb = build_skb(data, pp->frag_size))) {
 			dev->stats.rx_errors++;
 			mvneta_rx_error(pp, rx_desc);
-			mvneta_rx_desc_fill(rx_desc, rx_desc->buf_phys_addr,
-					    (u32)skb);
+			/* leave the descriptor untouched */
 			continue;
 		}
 
@@ -1388,7 +1405,7 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		u64_stats_update_end(&pp->rx_stats.syncp);
 
 		/* Linux processing */
-		skb_reserve(skb, MVNETA_MH_SIZE);
+		skb_reserve(skb, MVNETA_MH_SIZE + NET_SKB_PAD);
 		skb_put(skb, rx_bytes);
 
 		skb->protocol = eth_type_trans(skb, dev);
@@ -1905,12 +1922,21 @@ static int mvneta_rxq_fill(struct mvneta_port *pp, struct mvneta_rx_queue *rxq,
 	int i;
 
 	for (i = 0; i < num; i++) {
-		struct sk_buff *skb;
+		void *data;
 		struct mvneta_rx_desc *rx_desc;
 		unsigned long phys_addr;
+		unsigned int skb_size;
 
-		skb = dev_alloc_skb(pp->pkt_size);
-		if (!skb) {
+		skb_size = SKB_DATA_ALIGN(pp->pkt_size + MVNETA_MH_SIZE + NET_SKB_PAD) +
+			SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+		if (skb_size <= PAGE_SIZE) {
+			data = netdev_alloc_frag(skb_size);
+			pp->frag_size = skb_size;
+		} else {
+			data = kmalloc(skb_size, GFP_ATOMIC);
+			pp->frag_size = 0;
+		}
+		if (!data) {
 			netdev_err(dev, "%s:rxq %d, %d of %d buffs  filled\n",
 				__func__, rxq->id, i, num);
 			break;
@@ -1918,15 +1944,18 @@ static int mvneta_rxq_fill(struct mvneta_port *pp, struct mvneta_rx_queue *rxq,
 
 		rx_desc = rxq->descs + i;
 		memset(rx_desc, 0, sizeof(struct mvneta_rx_desc));
-		phys_addr = dma_map_single(dev->dev.parent, skb->head,
+		phys_addr = dma_map_single(dev->dev.parent, data,
 					   MVNETA_RX_BUF_SIZE(pp->pkt_size),
 					   DMA_FROM_DEVICE);
 		if (unlikely(dma_mapping_error(dev->dev.parent, phys_addr))) {
-			dev_kfree_skb(skb);
+			if (pp->frag_size)
+				put_page(virt_to_head_page(data));
+			else
+				kfree(data);
 			break;
 		}
 
-		mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)skb);
+		mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)data);
 	}
 
 	/* Add this number of RX descriptors as non occupied (ready to
-- 
1.7.12.2.21.g234cd45.dirty
