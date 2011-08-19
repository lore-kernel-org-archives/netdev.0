From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 04/13] bna: SKB Check and Drop Macros
Date: Fri, 19 Aug 2011 14:39:23 -0700
Message-ID: <1313789972-22711-5-git-send-email-rmody@brocade.com>
References: <1313789972-22711-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:38045 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755130Ab1HSVkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 17:40:00 -0400
In-Reply-To: <1313789972-22711-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add macros to check and drop skb from transmit path and return.

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |   68 +++++++++++++++++-------------
 drivers/net/ethernet/brocade/bna/bnad.h |    2 +
 2 files changed, 40 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 095eac9..beeffa2 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -74,6 +74,36 @@ do {								\
 
 #define BNAD_TXRX_SYNC_MDELAY	250	/* 250 msecs */
 
+#define BNAD_DROP_AND_RETURN(_counter)	\
+{ \
+	dev_kfree_skb(skb); \
+	BNAD_UPDATE_CTR(bnad, _counter); \
+	return NETDEV_TX_OK; \
+}
+
+#define BNAD_DROP_AND_RETURN_IF(_condition, _counter)	\
+if (unlikely(_condition)) { \
+	BNAD_DROP_AND_RETURN(_counter); \
+}
+
+#define BNAD_PCI_UNMAP_SKB(_pdev, _array, _index, _depth, _skb, _frag) \
+{ \
+	int j; \
+	(_array)[_index].skb = NULL; \
+	dma_unmap_single(_pdev, dma_unmap_addr(&(_array)[_index], dma_addr), \
+			skb_headlen(_skb), DMA_TO_DEVICE); \
+	dma_unmap_addr_set(&(_array)[_index], dma_addr, 0); \
+	BNA_QE_INDX_ADD(_index, 1, _depth); \
+	for (j = 0; j < (_frag); j++) { \
+		prefetch(&(_array)[(_index) + 1]); \
+		dma_unmap_page(_pdev, dma_unmap_addr(&(_array)[_index], \
+						     dma_addr), \
+			  skb_shinfo(_skb)->frags[j].size, DMA_TO_DEVICE); \
+		dma_unmap_addr_set(&(_array)[_index], dma_addr, 0); \
+		BNA_QE_INDX_ADD(_index, 1, _depth); \
+	} \
+}
+
 /*
  * Reinitialize completions in CQ, once Rx is taken down
  */
@@ -169,7 +199,6 @@ bnad_free_txbufs(struct bnad *bnad,
 	struct bnad_unmap_q *unmap_q = tcb->unmap_q;
 	struct bnad_skb_unmap *unmap_array;
 	struct sk_buff		*skb;
-	int i;
 
 	/*
 	 * Just return if TX is stopped. This check is useful
@@ -195,32 +224,14 @@ bnad_free_txbufs(struct bnad *bnad,
 	while (wis) {
 		skb = unmap_array[unmap_cons].skb;
 
-		unmap_array[unmap_cons].skb = NULL;
-
 		sent_packets++;
 		sent_bytes += skb->len;
 		wis -= BNA_TXQ_WI_NEEDED(1 + skb_shinfo(skb)->nr_frags);
 
-		dma_unmap_single(&bnad->pcidev->dev,
-				 dma_unmap_addr(&unmap_array[unmap_cons],
-						dma_addr), skb_headlen(skb),
-				 DMA_TO_DEVICE);
-		dma_unmap_addr_set(&unmap_array[unmap_cons], dma_addr, 0);
-		BNA_QE_INDX_ADD(unmap_cons, 1, unmap_q->q_depth);
-
-		prefetch(&unmap_array[unmap_cons + 1]);
-		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			prefetch(&unmap_array[unmap_cons + 1]);
+		BNAD_PCI_UNMAP_SKB(&bnad->pcidev->dev, unmap_array, unmap_cons,
+				   unmap_q->q_depth, skb,
+				   skb_shinfo(skb)->nr_frags);
 
-			dma_unmap_page(&bnad->pcidev->dev,
-				       dma_unmap_addr(&unmap_array[unmap_cons],
-						      dma_addr),
-				       skb_shinfo(skb)->frags[i].size,
-				       DMA_TO_DEVICE);
-			dma_unmap_addr_set(&unmap_array[unmap_cons], dma_addr,
-					   0);
-			BNA_QE_INDX_ADD(unmap_cons, 1, unmap_q->q_depth);
-		}
 		dev_kfree_skb_any(skb);
 	}
 
@@ -2560,16 +2571,13 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	 * Takes care of the Tx that is scheduled between clearing the flag
 	 * and the netif_stop_all_queue() call.
 	 */
-	if (unlikely(!test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags))) {
-		dev_kfree_skb(skb);
-		return NETDEV_TX_OK;
-	}
+	BNAD_DROP_AND_RETURN_IF(!test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags),
+				tx_skb_stopping);
 
 	vectors = 1 + skb_shinfo(skb)->nr_frags;
-	if (vectors > BFI_TX_MAX_VECTORS_PER_PKT) {
-		dev_kfree_skb(skb);
-		return NETDEV_TX_OK;
-	}
+	BNAD_DROP_AND_RETURN_IF(vectors > BFI_TX_MAX_VECTORS_PER_PKT,
+				tx_skb_max_vectors);
+
 	wis = BNA_TXQ_WI_NEEDED(vectors);	/* 4 vectors per work item */
 	acked = 0;
 	if (unlikely(wis > BNA_QE_FREE_CNT(tcb, tcb->q_depth) ||
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index 60c2e9d..c4772e3 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -148,6 +148,8 @@ struct bnad_drv_stats {
 	u64		udpcsum_offload;
 	u64		csum_help;
 	u64		csum_help_err;
+	u64		tx_skb_stopping;
+	u64		tx_skb_max_vectors;
 
 	u64		hw_stats_updates;
 	u64		netif_rx_schedule;
-- 
1.7.1

