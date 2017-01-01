From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 05/12] qede: Postpone reallocation until NAPI end
Date: Sun, 1 Jan 2017 13:57:04 +0200
Message-ID: <1483271831-25890-6-git-send-email-Yuval.Mintz@cavium.com>
References: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:51439 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932128AbdAAL6Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:58:16 -0500
In-Reply-To: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During Rx flow driver allocates a replacement buffer each time
it consumes an Rx buffer. Failing to do so, it would consume the
currently processed buffer and re-post it on the ring.
As a result, the Rx ring is always completely full [from driver POV].

We now allow the Rx ring to shorten by doing the re-allocations
at the end of the NAPI run. The only limitation is that we still want to
make sure each time we reallocate that we'd still have sufficient
elements in the Rx ring to guarantee that FW would be able to post
additional data and trigger an interrupt.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h      |  7 +++++--
 drivers/net/ethernet/qlogic/qede/qede_fp.c   | 23 +++++++++++++++++++----
 drivers/net/ethernet/qlogic/qede/qede_main.c |  3 ++-
 3 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index ab49263..1c5aac4 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -280,7 +280,7 @@ struct qede_rx_queue {
 	u16 sw_rx_cons;
 	u16 sw_rx_prod;
 
-	u16 num_rx_buffers; /* Slowpath */
+	u16 filled_buffers;
 	u8 data_direction;
 	u8 rxq_id;
 
@@ -293,6 +293,9 @@ struct qede_rx_queue {
 	struct qed_chain rx_bd_ring;
 	struct qed_chain rx_comp_ring ____cacheline_aligned;
 
+	/* Used once per each NAPI run */
+	u16 num_rx_buffers;
+
 	/* GRO */
 	struct qede_agg_info tpa_info[ETH_TPA_MAX_AGGS_NUM];
 
@@ -414,7 +417,7 @@ netdev_features_t qede_features_check(struct sk_buff *skb,
 				      struct net_device *dev,
 				      netdev_features_t features);
 void qede_tx_log_print(struct qede_dev *edev, struct qede_fastpath *fp);
-int qede_alloc_rx_buffer(struct qede_rx_queue *rxq);
+int qede_alloc_rx_buffer(struct qede_rx_queue *rxq, bool allow_lazy);
 int qede_free_tx_pkt(struct qede_dev *edev,
 		     struct qede_tx_queue *txq, int *len);
 int qede_poll(struct napi_struct *napi, int budget);
diff --git a/drivers/net/ethernet/qlogic/qede/qede_fp.c b/drivers/net/ethernet/qlogic/qede/qede_fp.c
index 1614eed..a06acab 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_fp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_fp.c
@@ -46,13 +46,22 @@
  * Content also used by slowpath *
  *********************************/
 
-int qede_alloc_rx_buffer(struct qede_rx_queue *rxq)
+int qede_alloc_rx_buffer(struct qede_rx_queue *rxq, bool allow_lazy)
 {
 	struct sw_rx_data *sw_rx_data;
 	struct eth_rx_bd *rx_bd;
 	dma_addr_t mapping;
 	struct page *data;
 
+	/* In case lazy-allocation is allowed, postpone allocation until the
+	 * end of the NAPI run. We'd still need to make sure the Rx ring has
+	 * sufficient buffers to guarantee an additional Rx interrupt.
+	 */
+	if (allow_lazy && likely(rxq->filled_buffers > 12)) {
+		rxq->filled_buffers--;
+		return 0;
+	}
+
 	data = alloc_pages(GFP_ATOMIC, 0);
 	if (unlikely(!data))
 		return -ENOMEM;
@@ -79,6 +88,7 @@ int qede_alloc_rx_buffer(struct qede_rx_queue *rxq)
 	rx_bd->addr.lo = cpu_to_le32(lower_32_bits(mapping));
 
 	rxq->sw_rx_prod++;
+	rxq->filled_buffers++;
 
 	return 0;
 }
@@ -523,7 +533,7 @@ static inline int qede_realloc_rx_buffer(struct qede_rx_queue *rxq,
 	curr_cons->page_offset += rxq->rx_buf_seg_size;
 
 	if (curr_cons->page_offset == PAGE_SIZE) {
-		if (unlikely(qede_alloc_rx_buffer(rxq))) {
+		if (unlikely(qede_alloc_rx_buffer(rxq, true))) {
 			/* Since we failed to allocate new buffer
 			 * current buffer can be used again.
 			 */
@@ -1002,7 +1012,7 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 	switch (act) {
 	case XDP_TX:
 		/* We need the replacement buffer before transmit. */
-		if (qede_alloc_rx_buffer(rxq)) {
+		if (qede_alloc_rx_buffer(rxq, true)) {
 			qede_recycle_rx_bd_ring(rxq, 1);
 			return false;
 		}
@@ -1116,7 +1126,7 @@ static int qede_rx_build_jumbo(struct qede_dev *edev,
 		}
 
 		/* We need a replacement buffer for each BD */
-		if (unlikely(qede_alloc_rx_buffer(rxq)))
+		if (unlikely(qede_alloc_rx_buffer(rxq, true)))
 			goto out;
 
 		/* Now that we've allocated the replacement buffer,
@@ -1293,6 +1303,11 @@ static int qede_rx_int(struct qede_fastpath *fp, int budget)
 		work_done++;
 	}
 
+	/* Allocate replacement buffers */
+	while (rxq->num_rx_buffers - rxq->filled_buffers)
+		if (qede_alloc_rx_buffer(rxq, false))
+			break;
+
 	/* Update producers */
 	qede_update_rx_prod(edev, rxq);
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index a679d42..be4121c 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1154,8 +1154,9 @@ static int qede_alloc_mem_rxq(struct qede_dev *edev, struct qede_rx_queue *rxq)
 		goto err;
 
 	/* Allocate buffers for the Rx ring */
+	rxq->filled_buffers = 0;
 	for (i = 0; i < rxq->num_rx_buffers; i++) {
-		rc = qede_alloc_rx_buffer(rxq);
+		rc = qede_alloc_rx_buffer(rxq, false);
 		if (rc) {
 			DP_ERR(edev,
 			       "Rx buffers allocation failed at index %d\n", i);
-- 
1.9.3
