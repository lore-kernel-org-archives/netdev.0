From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] bna: check for dma mapping errors
Date: Wed, 16 Sep 2015 15:27:43 +0200
Message-ID: <1442410063-30635-1-git-send-email-ivecera@redhat.com>
Cc: Rasesh Mody <rasesh.mody@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56745 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753055AbbIPN1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2015 09:27:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check for DMA mapping errors, recover from them and register them in
ethtool stats like other errors.

Cc: Rasesh Mody <rasesh.mody@qlogic.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c    |  2 ++
 drivers/net/ethernet/brocade/bna/bna_types.h    |  1 +
 drivers/net/ethernet/brocade/bna/bnad.c         | 29 ++++++++++++++++++++++++-
 drivers/net/ethernet/brocade/bna/bnad.h         |  2 ++
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |  4 ++++
 5 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 5d0753c..04b0d16 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -2400,6 +2400,7 @@ bna_rx_create(struct bna *bna, struct bnad *bnad,
 		q0->rcb->id = 0;
 		q0->rx_packets = q0->rx_bytes = 0;
 		q0->rx_packets_with_error = q0->rxbuf_alloc_failed = 0;
+		q0->rxbuf_map_failed = 0;
 
 		bna_rxq_qpt_setup(q0, rxp, dpage_count, PAGE_SIZE,
 			&dqpt_mem[i], &dsqpt_mem[i], &dpage_mem[i]);
@@ -2428,6 +2429,7 @@ bna_rx_create(struct bna *bna, struct bnad *bnad,
 					: rx_cfg->q1_buf_size;
 			q1->rx_packets = q1->rx_bytes = 0;
 			q1->rx_packets_with_error = q1->rxbuf_alloc_failed = 0;
+			q1->rxbuf_map_failed = 0;
 
 			bna_rxq_qpt_setup(q1, rxp, hpage_count, PAGE_SIZE,
 				&hqpt_mem[i], &hsqpt_mem[i],
diff --git a/drivers/net/ethernet/brocade/bna/bna_types.h b/drivers/net/ethernet/brocade/bna/bna_types.h
index e0e797f..c438d03 100644
--- a/drivers/net/ethernet/brocade/bna/bna_types.h
+++ b/drivers/net/ethernet/brocade/bna/bna_types.h
@@ -587,6 +587,7 @@ struct bna_rxq {
 	u64		rx_bytes;
 	u64		rx_packets_with_error;
 	u64		rxbuf_alloc_failed;
+	u64		rxbuf_map_failed;
 };
 
 /* RxQ pair */
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 506047c..21a0cfc 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -399,7 +399,13 @@ bnad_rxq_refill_page(struct bnad *bnad, struct bna_rcb *rcb, u32 nalloc)
 		}
 
 		dma_addr = dma_map_page(&bnad->pcidev->dev, page, page_offset,
-				unmap_q->map_size, DMA_FROM_DEVICE);
+					unmap_q->map_size, DMA_FROM_DEVICE);
+		if (dma_mapping_error(&bnad->pcidev->dev, dma_addr)) {
+			put_page(page);
+			BNAD_UPDATE_CTR(bnad, rxbuf_map_failed);
+			rcb->rxq->rxbuf_map_failed++;
+			goto finishing;
+		}
 
 		unmap->page = page;
 		unmap->page_offset = page_offset;
@@ -454,8 +460,15 @@ bnad_rxq_refill_skb(struct bnad *bnad, struct bna_rcb *rcb, u32 nalloc)
 			rcb->rxq->rxbuf_alloc_failed++;
 			goto finishing;
 		}
+
 		dma_addr = dma_map_single(&bnad->pcidev->dev, skb->data,
 					  buff_sz, DMA_FROM_DEVICE);
+		if (dma_mapping_error(&bnad->pcidev->dev, dma_addr)) {
+			dev_kfree_skb_any(skb);
+			BNAD_UPDATE_CTR(bnad, rxbuf_map_failed);
+			rcb->rxq->rxbuf_map_failed++;
+			goto finishing;
+		}
 
 		unmap->skb = skb;
 		dma_unmap_addr_set(&unmap->vector, dma_addr, dma_addr);
@@ -3025,6 +3038,11 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	unmap = head_unmap;
 	dma_addr = dma_map_single(&bnad->pcidev->dev, skb->data,
 				  len, DMA_TO_DEVICE);
+	if (dma_mapping_error(&bnad->pcidev->dev, dma_addr)) {
+		dev_kfree_skb_any(skb);
+		BNAD_UPDATE_CTR(bnad, tx_skb_map_failed);
+		return NETDEV_TX_OK;
+	}
 	BNA_SET_DMA_ADDR(dma_addr, &txqent->vector[0].host_addr);
 	txqent->vector[0].length = htons(len);
 	dma_unmap_addr_set(&unmap->vectors[0], dma_addr, dma_addr);
@@ -3056,6 +3074,15 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 		dma_addr = skb_frag_dma_map(&bnad->pcidev->dev, frag,
 					    0, size, DMA_TO_DEVICE);
+		if (dma_mapping_error(&bnad->pcidev->dev, dma_addr)) {
+			/* Undo the changes starting at tcb->producer_index */
+			bnad_tx_buff_unmap(bnad, unmap_q, q_depth,
+					   tcb->producer_index);
+			dev_kfree_skb_any(skb);
+			BNAD_UPDATE_CTR(bnad, tx_skb_map_failed);
+			return NETDEV_TX_OK;
+		}
+
 		dma_unmap_len_set(&unmap->vectors[vect_id], dma_len, size);
 		BNA_SET_DMA_ADDR(dma_addr, &txqent->vector[vect_id].host_addr);
 		txqent->vector[vect_id].length = htons(size);
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index faedbf2..f4ed816 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -175,6 +175,7 @@ struct bnad_drv_stats {
 	u64		tx_skb_headlen_zero;
 	u64		tx_skb_frag_zero;
 	u64		tx_skb_len_mismatch;
+	u64		tx_skb_map_failed;
 
 	u64		hw_stats_updates;
 	u64		netif_rx_dropped;
@@ -189,6 +190,7 @@ struct bnad_drv_stats {
 	u64		rx_unmap_q_alloc_failed;
 
 	u64		rxbuf_alloc_failed;
+	u64		rxbuf_map_failed;
 };
 
 /* Complete driver stats */
diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index 2bdfc5d..0e4fdc3 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -90,6 +90,7 @@ static const char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
 	"tx_skb_headlen_zero",
 	"tx_skb_frag_zero",
 	"tx_skb_len_mismatch",
+	"tx_skb_map_failed",
 	"hw_stats_updates",
 	"netif_rx_dropped",
 
@@ -102,6 +103,7 @@ static const char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
 	"tx_unmap_q_alloc_failed",
 	"rx_unmap_q_alloc_failed",
 	"rxbuf_alloc_failed",
+	"rxbuf_map_failed",
 
 	"mac_stats_clr_cnt",
 	"mac_frame_64",
@@ -807,6 +809,7 @@ bnad_per_q_stats_fill(struct bnad *bnad, u64 *buf, int bi)
 							rx_packets_with_error;
 					buf[bi++] = rcb->rxq->
 							rxbuf_alloc_failed;
+					buf[bi++] = rcb->rxq->rxbuf_map_failed;
 					buf[bi++] = rcb->producer_index;
 					buf[bi++] = rcb->consumer_index;
 				}
@@ -821,6 +824,7 @@ bnad_per_q_stats_fill(struct bnad *bnad, u64 *buf, int bi)
 							rx_packets_with_error;
 					buf[bi++] = rcb->rxq->
 							rxbuf_alloc_failed;
+					buf[bi++] = rcb->rxq->rxbuf_map_failed;
 					buf[bi++] = rcb->producer_index;
 					buf[bi++] = rcb->consumer_index;
 				}
-- 
2.4.6
