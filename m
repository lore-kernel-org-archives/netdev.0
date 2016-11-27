From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 09/11] qede: Better utilize the qede_[rt]x_queue
Date: Sun, 27 Nov 2016 16:51:11 +0200
Message-ID: <1480258273-24973-10-git-send-email-Yuval.Mintz@cavium.com>
References: <1480258273-24973-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:47106 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752487AbcK0OxD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 09:53:03 -0500
In-Reply-To: <1480258273-24973-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve the cacheline usage of both queues by reordering -
This reduces the cachelines required for egress datapath processing
from 3 to 2 and those required by ingress datapath processing by 2.

It also changes a couple of datapath related functions that currently
require either the fastpath or the qede_dev, changing them to be based
on the tx/rx queue instead.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h         |  80 +++++++-----
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |   4 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 166 +++++++++++-------------
 3 files changed, 125 insertions(+), 125 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 4ebc638..fd4fde5 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -243,27 +243,34 @@ struct qede_agg_info {
 };
 
 struct qede_rx_queue {
-	__le16			*hw_cons_ptr;
-	struct sw_rx_data	*sw_rx_ring;
-	u16			sw_rx_cons;
-	u16			sw_rx_prod;
-	struct qed_chain	rx_bd_ring;
-	struct qed_chain	rx_comp_ring;
-	void __iomem		*hw_rxq_prod_addr;
+	__le16 *hw_cons_ptr;
+	void __iomem *hw_rxq_prod_addr;
 
-	/* GRO */
-	struct qede_agg_info	tpa_info[ETH_TPA_MAX_AGGS_NUM];
+	/* Required for the allocation of replacement buffers */
+	struct device *dev;
+
+	u16 sw_rx_cons;
+	u16 sw_rx_prod;
+
+	u16 rx_buf_size;
+	u16 rx_buf_seg_size;
+
+	u64 rcv_pkts;
 
-	int			rx_buf_size;
-	unsigned int		rx_buf_seg_size;
+	u16 num_rx_buffers; /* Slowpath */
+	u8 rxq_id;
+
+	struct sw_rx_data *sw_rx_ring;
+	struct qed_chain rx_bd_ring;
+	struct qed_chain rx_comp_ring ____cacheline_aligned;
+
+	/* GRO */
+	struct qede_agg_info tpa_info[ETH_TPA_MAX_AGGS_NUM];
 
-	u16			num_rx_buffers;
-	u16			rxq_id;
 
-	u64			rcv_pkts;
-	u64			rx_hw_errors;
-	u64			rx_alloc_errors;
-	u64			rx_ip_frags;
+	u64 rx_hw_errors;
+	u64 rx_alloc_errors;
+	u64 rx_ip_frags;
 
 	void *handle;
 };
@@ -281,22 +288,28 @@ struct sw_tx_bd {
 };
 
 struct qede_tx_queue {
-	int			index; /* Queue index */
-	__le16			*hw_cons_ptr;
-	struct sw_tx_bd		*sw_tx_ring;
-	u16			sw_tx_cons;
-	u16			sw_tx_prod;
-	struct qed_chain	tx_pbl;
-	void __iomem		*doorbell_addr;
-	union db_prod		tx_db;
-
-	u16			num_tx_buffers;
-	u64			xmit_pkts;
-	u64			stopped_cnt;
-
-	bool			is_legacy;
-	void *handle;
+	bool is_legacy;
+	u16 sw_tx_cons;
+	u16 sw_tx_prod;
+	u16 num_tx_buffers; /* Slowpath only */
+
+	u64 xmit_pkts;
+	u64 stopped_cnt;
+
+	__le16 *hw_cons_ptr;
+
+	/* Needed for the mapping of packets */
+	struct device *dev;
 
+	void __iomem *doorbell_addr;
+	union db_prod tx_db;
+	int index; /* Slowpath only */
+
+	struct sw_tx_bd *sw_tx_ring;
+	struct qed_chain tx_pbl;
+
+	/* Slowpath; Should be kept in end [unless missing padding] */
+	void *handle;
 };
 
 #define BD_UNMAP_ADDR(bd)		HILO_U64(le32_to_cpu((bd)->addr.hi), \
@@ -363,8 +376,7 @@ void qede_reload(struct qede_dev *edev,
 void __qede_unlock(struct qede_dev *edev);
 bool qede_has_rx_work(struct qede_rx_queue *rxq);
 int qede_txq_has_work(struct qede_tx_queue *txq);
-void qede_recycle_rx_bd_ring(struct qede_rx_queue *rxq, struct qede_dev *edev,
-			     u8 count);
+void qede_recycle_rx_bd_ring(struct qede_rx_queue *rxq, u8 count);
 void qede_update_rx_prod(struct qede_dev *edev, struct qede_rx_queue *rxq);
 
 #define RX_RING_SIZE_POW	13
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index ef8c327..60a2e58 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -1337,13 +1337,13 @@ static int qede_selftest_receive_traffic(struct qede_dev *edev)
 					break;
 				}
 
-			qede_recycle_rx_bd_ring(rxq, edev, 1);
+			qede_recycle_rx_bd_ring(rxq, 1);
 			qed_chain_recycle_consumed(&rxq->rx_comp_ring);
 			break;
 		}
 
 		DP_INFO(edev, "Not the transmitted packet\n");
-		qede_recycle_rx_bd_ring(rxq, edev, 1);
+		qede_recycle_rx_bd_ring(rxq, 1);
 		qed_chain_recycle_consumed(&rxq->rx_comp_ring);
 	}
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index ec01de2..15520bf 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -96,8 +96,6 @@ enum qede_pci_private {
 
 static void qede_remove(struct pci_dev *pdev);
 static void qede_shutdown(struct pci_dev *pdev);
-static int qede_alloc_rx_buffer(struct qede_dev *edev,
-				struct qede_rx_queue *rxq);
 static void qede_link_update(void *dev, struct qed_link_output *link);
 
 /* The qede lock is used to protect driver state change and driver flows that
@@ -355,8 +353,7 @@ static int qede_free_tx_pkt(struct qede_dev *edev,
 }
 
 /* Unmap the data and free skb when mapping failed during start_xmit */
-static void qede_free_failed_tx_pkt(struct qede_dev *edev,
-				    struct qede_tx_queue *txq,
+static void qede_free_failed_tx_pkt(struct qede_tx_queue *txq,
 				    struct eth_tx_1st_bd *first_bd,
 				    int nbd, bool data_split)
 {
@@ -378,7 +375,7 @@ static void qede_free_failed_tx_pkt(struct qede_dev *edev,
 		nbd--;
 	}
 
-	dma_unmap_single(&edev->pdev->dev, BD_UNMAP_ADDR(first_bd),
+	dma_unmap_single(txq->dev, BD_UNMAP_ADDR(first_bd),
 			 BD_UNMAP_LEN(first_bd) + split_bd_len, DMA_TO_DEVICE);
 
 	/* Unmap the data of the skb frags */
@@ -386,7 +383,7 @@ static void qede_free_failed_tx_pkt(struct qede_dev *edev,
 		tx_data_bd = (struct eth_tx_bd *)
 			qed_chain_produce(&txq->tx_pbl);
 		if (tx_data_bd->nbytes)
-			dma_unmap_page(&edev->pdev->dev,
+			dma_unmap_page(txq->dev,
 				       BD_UNMAP_ADDR(tx_data_bd),
 				       BD_UNMAP_LEN(tx_data_bd), DMA_TO_DEVICE);
 	}
@@ -401,8 +398,7 @@ static void qede_free_failed_tx_pkt(struct qede_dev *edev,
 	txq->sw_tx_ring[idx].flags = 0;
 }
 
-static u32 qede_xmit_type(struct qede_dev *edev,
-			  struct sk_buff *skb, int *ipv6_ext)
+static u32 qede_xmit_type(struct sk_buff *skb, int *ipv6_ext)
 {
 	u32 rc = XMIT_L4_CSUM;
 	__be16 l3_proto;
@@ -469,18 +465,16 @@ static void qede_set_params_for_ipv6_ext(struct sk_buff *skb,
 	second_bd->data.bitfields2 = cpu_to_le16(bd2_bits2);
 }
 
-static int map_frag_to_bd(struct qede_dev *edev,
+static int map_frag_to_bd(struct qede_tx_queue *txq,
 			  skb_frag_t *frag, struct eth_tx_bd *bd)
 {
 	dma_addr_t mapping;
 
 	/* Map skb non-linear frag data for DMA */
-	mapping = skb_frag_dma_map(&edev->pdev->dev, frag, 0,
+	mapping = skb_frag_dma_map(txq->dev, frag, 0,
 				   skb_frag_size(frag), DMA_TO_DEVICE);
-	if (unlikely(dma_mapping_error(&edev->pdev->dev, mapping))) {
-		DP_NOTICE(edev, "Unable to map frag - dropping packet\n");
+	if (unlikely(dma_mapping_error(txq->dev, mapping)))
 		return -ENOMEM;
-	}
 
 	/* Setup the data pointer of the frag data */
 	BD_SET_UNMAP_ADDR_LEN(bd, mapping, skb_frag_size(frag));
@@ -500,8 +494,7 @@ static u16 qede_get_skb_hlen(struct sk_buff *skb, bool is_encap_pkt)
 
 /* +2 for 1st BD for headers and 2nd BD for headlen (if required) */
 #if ((MAX_SKB_FRAGS + 2) > ETH_TX_MAX_BDS_PER_NON_LSO_PACKET)
-static bool qede_pkt_req_lin(struct qede_dev *edev, struct sk_buff *skb,
-			     u8 xmit_type)
+static bool qede_pkt_req_lin(struct sk_buff *skb, u8 xmit_type)
 {
 	int allowed_frags = ETH_TX_MAX_BDS_PER_NON_LSO_PACKET - 1;
 
@@ -565,10 +558,10 @@ static netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 
 	WARN_ON(qed_chain_get_elem_left(&txq->tx_pbl) < (MAX_SKB_FRAGS + 1));
 
-	xmit_type = qede_xmit_type(edev, skb, &ipv6_ext);
+	xmit_type = qede_xmit_type(skb, &ipv6_ext);
 
 #if ((MAX_SKB_FRAGS + 2) > ETH_TX_MAX_BDS_PER_NON_LSO_PACKET)
-	if (qede_pkt_req_lin(edev, skb, xmit_type)) {
+	if (qede_pkt_req_lin(skb, xmit_type)) {
 		if (skb_linearize(skb)) {
 			DP_NOTICE(edev,
 				  "SKB linearization failed - silently dropping this SKB\n");
@@ -588,11 +581,11 @@ static netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 		1 << ETH_TX_1ST_BD_FLAGS_START_BD_SHIFT;
 
 	/* Map skb linear data for DMA and set in the first BD */
-	mapping = dma_map_single(&edev->pdev->dev, skb->data,
+	mapping = dma_map_single(txq->dev, skb->data,
 				 skb_headlen(skb), DMA_TO_DEVICE);
-	if (unlikely(dma_mapping_error(&edev->pdev->dev, mapping))) {
+	if (unlikely(dma_mapping_error(txq->dev, mapping))) {
 		DP_NOTICE(edev, "SKB mapping failed\n");
-		qede_free_failed_tx_pkt(edev, txq, first_bd, 0, false);
+		qede_free_failed_tx_pkt(txq, first_bd, 0, false);
 		qede_update_tx_producer(txq);
 		return NETDEV_TX_OK;
 	}
@@ -716,12 +709,11 @@ static netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 	/* Handle fragmented skb */
 	/* special handle for frags inside 2nd and 3rd bds.. */
 	while (tx_data_bd && frag_idx < skb_shinfo(skb)->nr_frags) {
-		rc = map_frag_to_bd(edev,
+		rc = map_frag_to_bd(txq,
 				    &skb_shinfo(skb)->frags[frag_idx],
 				    tx_data_bd);
 		if (rc) {
-			qede_free_failed_tx_pkt(edev, txq, first_bd, nbd,
-						data_split);
+			qede_free_failed_tx_pkt(txq, first_bd, nbd, data_split);
 			qede_update_tx_producer(txq);
 			return NETDEV_TX_OK;
 		}
@@ -741,12 +733,11 @@ static netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 
 		memset(tx_data_bd, 0, sizeof(*tx_data_bd));
 
-		rc = map_frag_to_bd(edev,
+		rc = map_frag_to_bd(txq,
 				    &skb_shinfo(skb)->frags[frag_idx],
 				    tx_data_bd);
 		if (rc) {
-			qede_free_failed_tx_pkt(edev, txq, first_bd, nbd,
-						data_split);
+			qede_free_failed_tx_pkt(txq, first_bd, nbd, data_split);
 			qede_update_tx_producer(txq);
 			return NETDEV_TX_OK;
 		}
@@ -903,8 +894,7 @@ static inline void qede_rx_bd_ring_consume(struct qede_rx_queue *rxq)
 /* This function reuses the buffer(from an offset) from
  * consumer index to producer index in the bd ring
  */
-static inline void qede_reuse_page(struct qede_dev *edev,
-				   struct qede_rx_queue *rxq,
+static inline void qede_reuse_page(struct qede_rx_queue *rxq,
 				   struct sw_rx_data *curr_cons)
 {
 	struct eth_rx_bd *rx_bd_prod = qed_chain_produce(&rxq->rx_bd_ring);
@@ -926,27 +916,62 @@ static inline void qede_reuse_page(struct qede_dev *edev,
 /* In case of allocation failures reuse buffers
  * from consumer index to produce buffers for firmware
  */
-void qede_recycle_rx_bd_ring(struct qede_rx_queue *rxq,
-			     struct qede_dev *edev, u8 count)
+void qede_recycle_rx_bd_ring(struct qede_rx_queue *rxq, u8 count)
 {
 	struct sw_rx_data *curr_cons;
 
 	for (; count > 0; count--) {
 		curr_cons = &rxq->sw_rx_ring[rxq->sw_rx_cons & NUM_RX_BDS_MAX];
-		qede_reuse_page(edev, rxq, curr_cons);
+		qede_reuse_page(rxq, curr_cons);
 		qede_rx_bd_ring_consume(rxq);
 	}
 }
 
-static inline int qede_realloc_rx_buffer(struct qede_dev *edev,
-					 struct qede_rx_queue *rxq,
+static int qede_alloc_rx_buffer(struct qede_rx_queue *rxq)
+{
+	struct sw_rx_data *sw_rx_data;
+	struct eth_rx_bd *rx_bd;
+	dma_addr_t mapping;
+	struct page *data;
+
+	data = alloc_pages(GFP_ATOMIC, 0);
+	if (unlikely(!data))
+		return -ENOMEM;
+
+	/* Map the entire page as it would be used
+	 * for multiple RX buffer segment size mapping.
+	 */
+	mapping = dma_map_page(rxq->dev, data, 0,
+			       PAGE_SIZE, DMA_FROM_DEVICE);
+	if (unlikely(dma_mapping_error(rxq->dev, mapping))) {
+		__free_page(data);
+		return -ENOMEM;
+	}
+
+	sw_rx_data = &rxq->sw_rx_ring[rxq->sw_rx_prod & NUM_RX_BDS_MAX];
+	sw_rx_data->page_offset = 0;
+	sw_rx_data->data = data;
+	sw_rx_data->mapping = mapping;
+
+	/* Advance PROD and get BD pointer */
+	rx_bd = (struct eth_rx_bd *)qed_chain_produce(&rxq->rx_bd_ring);
+	WARN_ON(!rx_bd);
+	rx_bd->addr.hi = cpu_to_le32(upper_32_bits(mapping));
+	rx_bd->addr.lo = cpu_to_le32(lower_32_bits(mapping));
+
+	rxq->sw_rx_prod++;
+
+	return 0;
+}
+
+static inline int qede_realloc_rx_buffer(struct qede_rx_queue *rxq,
 					 struct sw_rx_data *curr_cons)
 {
 	/* Move to the next segment in the page */
 	curr_cons->page_offset += rxq->rx_buf_seg_size;
 
 	if (curr_cons->page_offset == PAGE_SIZE) {
-		if (unlikely(qede_alloc_rx_buffer(edev, rxq))) {
+		if (unlikely(qede_alloc_rx_buffer(rxq))) {
 			/* Since we failed to allocate new buffer
 			 * current buffer can be used again.
 			 */
@@ -955,7 +980,7 @@ static inline int qede_realloc_rx_buffer(struct qede_dev *edev,
 			return -ENOMEM;
 		}
 
-		dma_unmap_page(&edev->pdev->dev, curr_cons->mapping,
+		dma_unmap_page(rxq->dev, curr_cons->mapping,
 			       PAGE_SIZE, DMA_FROM_DEVICE);
 	} else {
 		/* Increment refcount of the page as we don't want
@@ -963,7 +988,7 @@ static inline int qede_realloc_rx_buffer(struct qede_dev *edev,
 		 * which can be recycled multiple times by the driver.
 		 */
 		page_ref_inc(curr_cons->data);
-		qede_reuse_page(edev, rxq, curr_cons);
+		qede_reuse_page(rxq, curr_cons);
 	}
 
 	return 0;
@@ -1026,6 +1051,7 @@ static void qede_set_skb_csum(struct sk_buff *skb, u8 csum_flag)
 
 static inline void qede_skb_receive(struct qede_dev *edev,
 				    struct qede_fastpath *fp,
+				    struct qede_rx_queue *rxq,
 				    struct sk_buff *skb, u16 vlan_tag)
 {
 	if (vlan_tag)
@@ -1068,7 +1094,7 @@ static int qede_fill_frag_skb(struct qede_dev *edev,
 			   current_bd->data, current_bd->page_offset,
 			   len_on_bd);
 
-	if (unlikely(qede_realloc_rx_buffer(edev, rxq, current_bd))) {
+	if (unlikely(qede_realloc_rx_buffer(rxq, current_bd))) {
 		/* Incr page ref count to reuse on allocation failure
 		 * so that it doesn't get freed while freeing SKB.
 		 */
@@ -1087,7 +1113,8 @@ static int qede_fill_frag_skb(struct qede_dev *edev,
 
 out:
 	tpa_info->state = QEDE_AGG_STATE_ERROR;
-	qede_recycle_rx_bd_ring(rxq, edev, 1);
+	qede_recycle_rx_bd_ring(rxq, 1);
+
 	return -ENOMEM;
 }
 
@@ -1239,7 +1266,7 @@ static void qede_gro_receive(struct qede_dev *edev,
 
 send_skb:
 	skb_record_rx_queue(skb, fp->rxq->rxq_id);
-	qede_skb_receive(edev, fp, skb, vlan_tag);
+	qede_skb_receive(edev, fp, fp->rxq, skb, vlan_tag);
 }
 
 static inline void qede_tpa_cont(struct qede_dev *edev,
@@ -1414,7 +1441,7 @@ static struct sk_buff *qede_rx_allocate_skb(struct qede_dev *edev,
 	if (len + pad <= edev->rx_copybreak) {
 		memcpy(skb_put(skb, len),
 		       page_address(page) + pad + offset, len);
-		qede_reuse_page(edev, rxq, bd);
+		qede_reuse_page(rxq, bd);
 		goto out;
 	}
 
@@ -1435,7 +1462,7 @@ static struct sk_buff *qede_rx_allocate_skb(struct qede_dev *edev,
 	skb->data_len -= pull_len;
 	skb->tail += pull_len;
 
-	if (unlikely(qede_realloc_rx_buffer(edev, rxq, bd))) {
+	if (unlikely(qede_realloc_rx_buffer(rxq, bd))) {
 		/* Incr page ref count to reuse on allocation failure so
 		 * that it doesn't get freed while freeing SKB [as its
 		 * already mapped there].
@@ -1477,7 +1504,7 @@ static int qede_rx_build_jumbo(struct qede_dev *edev,
 		}
 
 		/* We need a replacement buffer for each BD */
-		if (unlikely(qede_alloc_rx_buffer(edev, rxq)))
+		if (unlikely(qede_alloc_rx_buffer(rxq)))
 			goto out;
 
 		/* Now that we've allocated the replacement buffer,
@@ -1487,7 +1514,7 @@ static int qede_rx_build_jumbo(struct qede_dev *edev,
 		bd = &rxq->sw_rx_ring[bd_cons_idx];
 		qede_rx_bd_ring_consume(rxq);
 
-		dma_unmap_page(&edev->pdev->dev, bd->mapping,
+		dma_unmap_page(rxq->dev, bd->mapping,
 			       PAGE_SIZE, DMA_FROM_DEVICE);
 
 		skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags++,
@@ -1582,7 +1609,7 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
 				  "CQE has error, flags = %x, dropping incoming packet\n",
 				  parse_flag);
 			rxq->rx_hw_errors++;
-			qede_recycle_rx_bd_ring(rxq, edev, fp_cqe->bd_num);
+			qede_recycle_rx_bd_ring(rxq, fp_cqe->bd_num);
 			return 0;
 		}
 	}
@@ -1593,7 +1620,7 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
 	skb = qede_rx_allocate_skb(edev, rxq, bd, len, pad);
 	if (!skb) {
 		rxq->rx_alloc_errors++;
-		qede_recycle_rx_bd_ring(rxq, edev, fp_cqe->bd_num);
+		qede_recycle_rx_bd_ring(rxq, fp_cqe->bd_num);
 		return 0;
 	}
 
@@ -1605,7 +1632,7 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
 							 fp_cqe, len);
 
 		if (unlikely(unmapped_frags > 0)) {
-			qede_recycle_rx_bd_ring(rxq, edev, unmapped_frags);
+			qede_recycle_rx_bd_ring(rxq, unmapped_frags);
 			dev_kfree_skb_any(skb);
 			return 0;
 		}
@@ -1618,7 +1645,7 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
 	skb_record_rx_queue(skb, rxq->rxq_id);
 
 	/* SKB is prepared - pass it to stack */
-	qede_skb_receive(edev, fp, skb, le16_to_cpu(fp_cqe->vlan_tag));
+	qede_skb_receive(edev, fp, rxq, skb, le16_to_cpu(fp_cqe->vlan_tag));
 
 	return 1;
 }
@@ -2875,47 +2902,6 @@ static void qede_free_mem_rxq(struct qede_dev *edev, struct qede_rx_queue *rxq)
 	edev->ops->common->chain_free(edev->cdev, &rxq->rx_comp_ring);
 }
 
-static int qede_alloc_rx_buffer(struct qede_dev *edev,
-				struct qede_rx_queue *rxq)
-{
-	struct sw_rx_data *sw_rx_data;
-	struct eth_rx_bd *rx_bd;
-	dma_addr_t mapping;
-	struct page *data;
-
-	data = alloc_pages(GFP_ATOMIC, 0);
-	if (unlikely(!data)) {
-		DP_NOTICE(edev, "Failed to allocate Rx data [page]\n");
-		return -ENOMEM;
-	}
-
-	/* Map the entire page as it would be used
-	 * for multiple RX buffer segment size mapping.
-	 */
-	mapping = dma_map_page(&edev->pdev->dev, data, 0,
-			       PAGE_SIZE, DMA_FROM_DEVICE);
-	if (unlikely(dma_mapping_error(&edev->pdev->dev, mapping))) {
-		__free_page(data);
-		DP_NOTICE(edev, "Failed to map Rx buffer\n");
-		return -ENOMEM;
-	}
-
-	sw_rx_data = &rxq->sw_rx_ring[rxq->sw_rx_prod & NUM_RX_BDS_MAX];
-	sw_rx_data->page_offset = 0;
-	sw_rx_data->data = data;
-	sw_rx_data->mapping = mapping;
-
-	/* Advance PROD and get BD pointer */
-	rx_bd = (struct eth_rx_bd *)qed_chain_produce(&rxq->rx_bd_ring);
-	WARN_ON(!rx_bd);
-	rx_bd->addr.hi = cpu_to_le32(upper_32_bits(mapping));
-	rx_bd->addr.lo = cpu_to_le32(lower_32_bits(mapping));
-
-	rxq->sw_rx_prod++;
-
-	return 0;
-}
-
 static int qede_alloc_sge_mem(struct qede_dev *edev, struct qede_rx_queue *rxq)
 {
 	dma_addr_t mapping;
@@ -3010,7 +2996,7 @@ static int qede_alloc_mem_rxq(struct qede_dev *edev, struct qede_rx_queue *rxq)
 
 	/* Allocate buffers for the Rx ring */
 	for (i = 0; i < rxq->num_rx_buffers; i++) {
-		rc = qede_alloc_rx_buffer(edev, rxq);
+		rc = qede_alloc_rx_buffer(rxq);
 		if (rc) {
 			DP_ERR(edev,
 			       "Rx buffers allocation failed at index %d\n", i);
@@ -3151,12 +3137,14 @@ static void qede_init_fp(struct qede_dev *edev)
 
 		if (fp->type & QEDE_FASTPATH_RX) {
 			fp->rxq->rxq_id = rxq_index++;
+			fp->rxq->dev = &edev->pdev->dev;
 		}
 
 		if (fp->type & QEDE_FASTPATH_TX) {
 			fp->txq->index = txq_index++;
 			if (edev->dev_info.is_legacy)
 				fp->txq->is_legacy = 1;
+			fp->txq->dev = &edev->pdev->dev;
 		}
 
 		snprintf(fp->name, sizeof(fp->name), "%s-fp-%d",
-- 
1.9.3
