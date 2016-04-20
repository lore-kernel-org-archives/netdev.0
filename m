From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net 1/3] qede: Fix various memory allocation error flows for fastpath
Date: Wed, 20 Apr 2016 03:03:27 -0400
Message-ID: <1461135809-9776-2-git-send-email-manish.chopra@qlogic.com>
References: <1461135809-9776-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:40661 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754335AbcDTHpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 03:45:19 -0400
In-Reply-To: <1461135809-9776-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch handles memory allocation failures for fastpath
gracefully in the driver.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <yuval.mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 140 ++++++++++++++++-----------
 1 file changed, 85 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 518af32..5cf1eb2 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -750,6 +750,12 @@ static bool qede_has_tx_work(struct qede_fastpath *fp)
 	return false;
 }
 
+static inline void qede_rx_bd_ring_consume(struct qede_rx_queue *rxq)
+{
+	qed_chain_consume(&rxq->rx_bd_ring);
+	rxq->sw_rx_cons++;
+}
+
 /* This function reuses the buffer(from an offset) from
  * consumer index to producer index in the bd ring
  */
@@ -773,6 +779,21 @@ static inline void qede_reuse_page(struct qede_dev *edev,
 	curr_cons->data = NULL;
 }
 
+/* In case of allocation failures reuse buffers
+ * from consumer index to produce buffers for firmware
+ */
+static void qede_recycle_rx_bd_ring(struct qede_rx_queue *rxq,
+				    struct qede_dev *edev, u8 count)
+{
+	struct sw_rx_data *curr_cons;
+
+	for (; count > 0; count--) {
+		curr_cons = &rxq->sw_rx_ring[rxq->sw_rx_cons & NUM_RX_BDS_MAX];
+		qede_reuse_page(edev, rxq, curr_cons);
+		qede_rx_bd_ring_consume(rxq);
+	}
+}
+
 static inline int qede_realloc_rx_buffer(struct qede_dev *edev,
 					 struct qede_rx_queue *rxq,
 					 struct sw_rx_data *curr_cons)
@@ -781,8 +802,14 @@ static inline int qede_realloc_rx_buffer(struct qede_dev *edev,
 	curr_cons->page_offset += rxq->rx_buf_seg_size;
 
 	if (curr_cons->page_offset == PAGE_SIZE) {
-		if (unlikely(qede_alloc_rx_buffer(edev, rxq)))
+		if (unlikely(qede_alloc_rx_buffer(edev, rxq))) {
+			/* Since we failed to allocate new buffer
+			 * current buffer can be used again.
+			 */
+			curr_cons->page_offset -= rxq->rx_buf_seg_size;
+
 			return -ENOMEM;
+		}
 
 		dma_unmap_page(&edev->pdev->dev, curr_cons->mapping,
 			       PAGE_SIZE, DMA_FROM_DEVICE);
@@ -901,7 +928,10 @@ static int qede_fill_frag_skb(struct qede_dev *edev,
 			   len_on_bd);
 
 	if (unlikely(qede_realloc_rx_buffer(edev, rxq, current_bd))) {
-		tpa_info->agg_state = QEDE_AGG_STATE_ERROR;
+		/* Incr page ref count to reuse on allocation failure
+		 * so that it doesn't get freed while freeing SKB.
+		 */
+		atomic_inc(&current_bd->data->_count);
 		goto out;
 	}
 
@@ -915,6 +945,8 @@ static int qede_fill_frag_skb(struct qede_dev *edev,
 	return 0;
 
 out:
+	tpa_info->agg_state = QEDE_AGG_STATE_ERROR;
+	qede_recycle_rx_bd_ring(rxq, edev, 1);
 	return -ENOMEM;
 }
 
@@ -966,8 +998,9 @@ static void qede_tpa_start(struct qede_dev *edev,
 	tpa_info->skb = netdev_alloc_skb(edev->ndev,
 					 le16_to_cpu(cqe->len_on_first_bd));
 	if (unlikely(!tpa_info->skb)) {
+		DP_NOTICE(edev, "Failed to allocate SKB for gro\n");
 		tpa_info->agg_state = QEDE_AGG_STATE_ERROR;
-		return;
+		goto cons_buf;
 	}
 
 	skb_put(tpa_info->skb, le16_to_cpu(cqe->len_on_first_bd));
@@ -990,6 +1023,7 @@ static void qede_tpa_start(struct qede_dev *edev,
 	/* This is needed in order to enable forwarding support */
 	qede_set_gro_params(edev, tpa_info->skb, cqe);
 
+cons_buf: /* We still need to handle bd_len_list to consume buffers */
 	if (likely(cqe->ext_bd_len_list[0]))
 		qede_fill_frag_skb(edev, rxq, cqe->tpa_agg_index,
 				   le16_to_cpu(cqe->ext_bd_len_list[0]));
@@ -1244,17 +1278,17 @@ static int qede_rx_int(struct qede_fastpath *fp, int budget)
 				  "CQE in CONS = %u has error, flags = %x, dropping incoming packet\n",
 				  sw_comp_cons, parse_flag);
 			rxq->rx_hw_errors++;
-			qede_reuse_page(edev, rxq, sw_rx_data);
-			goto next_rx;
+			qede_recycle_rx_bd_ring(rxq, edev, fp_cqe->bd_num);
+			goto next_cqe;
 		}
 
 		skb = netdev_alloc_skb(edev->ndev, QEDE_RX_HDR_SIZE);
 		if (unlikely(!skb)) {
 			DP_NOTICE(edev,
 				  "Build_skb failed, dropping incoming packet\n");
-			qede_reuse_page(edev, rxq, sw_rx_data);
+			qede_recycle_rx_bd_ring(rxq, edev, fp_cqe->bd_num);
 			rxq->rx_alloc_errors++;
-			goto next_rx;
+			goto next_cqe;
 		}
 
 		/* Copy data into SKB */
@@ -1288,11 +1322,22 @@ static int qede_rx_int(struct qede_fastpath *fp, int budget)
 			if (unlikely(qede_realloc_rx_buffer(edev, rxq,
 							    sw_rx_data))) {
 				DP_ERR(edev, "Failed to allocate rx buffer\n");
+				/* Incr page ref count to reuse on allocation
+				 * failure so that it doesn't get freed while
+				 * freeing SKB.
+				 */
+
+				atomic_inc(&sw_rx_data->data->_count);
 				rxq->rx_alloc_errors++;
+				qede_recycle_rx_bd_ring(rxq, edev,
+							fp_cqe->bd_num);
+				dev_kfree_skb_any(skb);
 				goto next_cqe;
 			}
 		}
 
+		qede_rx_bd_ring_consume(rxq);
+
 		if (fp_cqe->bd_num != 1) {
 			u16 pkt_len = le16_to_cpu(fp_cqe->pkt_len);
 			u8 num_frags;
@@ -1303,18 +1348,27 @@ static int qede_rx_int(struct qede_fastpath *fp, int budget)
 			     num_frags--) {
 				u16 cur_size = pkt_len > rxq->rx_buf_size ?
 						rxq->rx_buf_size : pkt_len;
+				if (unlikely(!cur_size)) {
+					DP_ERR(edev,
+					       "Still got %d BDs for mapping jumbo, but length became 0\n",
+					       num_frags);
+					qede_recycle_rx_bd_ring(rxq, edev,
+								num_frags);
+					dev_kfree_skb_any(skb);
+					goto next_cqe;
+				}
 
-				WARN_ONCE(!cur_size,
-					  "Still got %d BDs for mapping jumbo, but length became 0\n",
-					  num_frags);
-
-				if (unlikely(qede_alloc_rx_buffer(edev, rxq)))
+				if (unlikely(qede_alloc_rx_buffer(edev, rxq))) {
+					qede_recycle_rx_bd_ring(rxq, edev,
+								num_frags);
+					dev_kfree_skb_any(skb);
 					goto next_cqe;
+				}
 
-				rxq->sw_rx_cons++;
 				sw_rx_index = rxq->sw_rx_cons & NUM_RX_BDS_MAX;
 				sw_rx_data = &rxq->sw_rx_ring[sw_rx_index];
-				qed_chain_consume(&rxq->rx_bd_ring);
+				qede_rx_bd_ring_consume(rxq);
+
 				dma_unmap_page(&edev->pdev->dev,
 					       sw_rx_data->mapping,
 					       PAGE_SIZE, DMA_FROM_DEVICE);
@@ -1330,7 +1384,7 @@ static int qede_rx_int(struct qede_fastpath *fp, int budget)
 				pkt_len -= cur_size;
 			}
 
-			if (pkt_len)
+			if (unlikely(pkt_len))
 				DP_ERR(edev,
 				       "Mapped all BDs of jumbo, but still have %d bytes\n",
 				       pkt_len);
@@ -1349,10 +1403,6 @@ static int qede_rx_int(struct qede_fastpath *fp, int budget)
 		skb_record_rx_queue(skb, fp->rss_id);
 
 		qede_skb_receive(edev, fp, skb, le16_to_cpu(fp_cqe->vlan_tag));
-
-		qed_chain_consume(&rxq->rx_bd_ring);
-next_rx:
-		rxq->sw_rx_cons++;
 next_rx_only:
 		rx_pkt++;
 
@@ -2257,7 +2307,7 @@ static void qede_free_sge_mem(struct qede_dev *edev,
 		struct qede_agg_info *tpa_info = &rxq->tpa_info[i];
 		struct sw_rx_data *replace_buf = &tpa_info->replace_buf;
 
-		if (replace_buf) {
+		if (replace_buf->data) {
 			dma_unmap_page(&edev->pdev->dev,
 				       dma_unmap_addr(replace_buf, mapping),
 				       PAGE_SIZE, DMA_FROM_DEVICE);
@@ -2377,7 +2427,7 @@ err:
 static int qede_alloc_mem_rxq(struct qede_dev *edev,
 			      struct qede_rx_queue *rxq)
 {
-	int i, rc, size, num_allocated;
+	int i, rc, size;
 
 	rxq->num_rx_buffers = edev->q_num_rx_buffers;
 
@@ -2394,6 +2444,7 @@ static int qede_alloc_mem_rxq(struct qede_dev *edev,
 	rxq->sw_rx_ring = kzalloc(size, GFP_KERNEL);
 	if (!rxq->sw_rx_ring) {
 		DP_ERR(edev, "Rx buffers ring allocation failed\n");
+		rc = -ENOMEM;
 		goto err;
 	}
 
@@ -2421,26 +2472,16 @@ static int qede_alloc_mem_rxq(struct qede_dev *edev,
 	/* Allocate buffers for the Rx ring */
 	for (i = 0; i < rxq->num_rx_buffers; i++) {
 		rc = qede_alloc_rx_buffer(edev, rxq);
-		if (rc)
-			break;
-	}
-	num_allocated = i;
-	if (!num_allocated) {
-		DP_ERR(edev, "Rx buffers allocation failed\n");
-		goto err;
-	} else if (num_allocated < rxq->num_rx_buffers) {
-		DP_NOTICE(edev,
-			  "Allocated less buffers than desired (%d allocated)\n",
-			  num_allocated);
+		if (rc) {
+			DP_ERR(edev,
+			       "Rx buffers allocation failed at index %d\n", i);
+			goto err;
+		}
 	}
 
-	qede_alloc_sge_mem(edev, rxq);
-
-	return 0;
-
+	rc = qede_alloc_sge_mem(edev, rxq);
 err:
-	qede_free_mem_rxq(edev, rxq);
-	return -ENOMEM;
+	return rc;
 }
 
 static void qede_free_mem_txq(struct qede_dev *edev,
@@ -2523,10 +2564,8 @@ static int qede_alloc_mem_fp(struct qede_dev *edev,
 	}
 
 	return 0;
-
 err:
-	qede_free_mem_fp(edev, fp);
-	return -ENOMEM;
+	return rc;
 }
 
 static void qede_free_mem_load(struct qede_dev *edev)
@@ -2549,22 +2588,13 @@ static int qede_alloc_mem_load(struct qede_dev *edev)
 		struct qede_fastpath *fp = &edev->fp_array[rss_id];
 
 		rc = qede_alloc_mem_fp(edev, fp);
-		if (rc)
-			break;
-	}
-
-	if (rss_id != QEDE_RSS_CNT(edev)) {
-		/* Failed allocating memory for all the queues */
-		if (!rss_id) {
+		if (rc) {
 			DP_ERR(edev,
-			       "Failed to allocate memory for the leading queue\n");
-			rc = -ENOMEM;
-		} else {
-			DP_NOTICE(edev,
-				  "Failed to allocate memory for all of RSS queues\n Desired: %d queues, allocated: %d queues\n",
-				  QEDE_RSS_CNT(edev), rss_id);
+			       "Failed to allocate memory for fastpath - rss id = %d\n",
+			       rss_id);
+			qede_free_mem_load(edev);
+			return rc;
 		}
-		edev->num_rss = rss_id;
 	}
 
 	return 0;
-- 
2.7.2
