From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 11/11] qede: Add support for XDP_TX
Date: Sun, 27 Nov 2016 16:51:13 +0200
Message-ID: <1480258273-24973-12-git-send-email-Yuval.Mintz@cavium.com>
References: <1480258273-24973-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:47117 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752551AbcK0OxH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 09:53:07 -0500
In-Reply-To: <1480258273-24973-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for forwarding via XDP. Once the eBPF is attached,
driver would allocate & configurate a designated transmission queue
meant solely for forwarding packets. Said queue would share the
receive-queue's interrupt line, and would have it's own Tx statistics.

Infrastructure changes required for this [spread-out through the code]:
 - Determine the DMA direction of the receive buffers based on the presence
of the eBPF program.
 - Turn the sw Tx ring into a union, as regular/XDP queues have different
needs for releasing resources after completion [regular requires the SKB,
XDP requires the transmitted page].

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h         |  16 +-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |  22 ++-
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 213 ++++++++++++++++++++----
 3 files changed, 216 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index c65f3d2..5d6f8a9 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -263,6 +263,7 @@ struct qede_rx_queue {
 	u64 rcv_pkts;
 
 	u16 num_rx_buffers; /* Slowpath */
+	u8 data_direction;
 	u8 rxq_id;
 
 	struct sw_rx_data *sw_rx_ring;
@@ -295,6 +296,7 @@ struct sw_tx_bd {
 };
 
 struct qede_tx_queue {
+	u8 is_xdp;
 	bool is_legacy;
 	u16 sw_tx_cons;
 	u16 sw_tx_prod;
@@ -311,8 +313,18 @@ struct qede_tx_queue {
 	void __iomem *doorbell_addr;
 	union db_prod tx_db;
 	int index; /* Slowpath only */
+#define QEDE_TXQ_XDP_TO_IDX(edev, txq)	((txq)->index - \
+					 QEDE_MAX_TSS_CNT(edev))
+#define QEDE_TXQ_IDX_TO_XDP(edev, idx)	((idx) + QEDE_MAX_TSS_CNT(edev))
+
+	/* Regular Tx requires skb + metadata for release purpose,
+	 * while XDP requires only the pages themselves.
+	 */
+	union {
+		struct sw_tx_bd *skbs;
+		struct page **pages;
+	} sw_tx_ring;
 
-	struct sw_tx_bd *sw_tx_ring;
 	struct qed_chain tx_pbl;
 
 	/* Slowpath; Should be kept in end [unless missing padding] */
@@ -337,10 +349,12 @@ struct qede_fastpath {
 #define QEDE_FASTPATH_COMBINED	(QEDE_FASTPATH_TX | QEDE_FASTPATH_RX)
 	u8			type;
 	u8			id;
+	u8			xdp_xmit;
 	struct napi_struct	napi;
 	struct qed_sb_info	*sb_info;
 	struct qede_rx_queue	*rxq;
 	struct qede_tx_queue	*txq;
+	struct qede_tx_queue	*xdp_tx;
 
 #define VEC_NAME_SIZE	(sizeof(((struct net_device *)0)->name) + 8)
 	char	name[VEC_NAME_SIZE];
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 6c70e29..1c48f44 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -165,8 +165,13 @@ static void qede_get_strings_stats_txq(struct qede_dev *edev,
 	int i;
 
 	for (i = 0; i < QEDE_NUM_TQSTATS; i++) {
-		sprintf(*buf, "%d: %s", txq->index,
-			qede_tqstats_arr[i].string);
+		if (txq->is_xdp)
+			sprintf(*buf, "%d [XDP]: %s",
+				QEDE_TXQ_XDP_TO_IDX(edev, txq),
+				qede_tqstats_arr[i].string);
+		else
+			sprintf(*buf, "%d: %s", txq->index,
+				qede_tqstats_arr[i].string);
 		*buf += ETH_GSTRING_LEN;
 	}
 }
@@ -195,6 +200,9 @@ static void qede_get_strings_stats(struct qede_dev *edev, u8 *buf)
 		if (fp->type & QEDE_FASTPATH_RX)
 			qede_get_strings_stats_rxq(edev, fp->rxq, &buf);
 
+		if (fp->type & QEDE_FASTPATH_XDP)
+			qede_get_strings_stats_txq(edev, fp->xdp_tx, &buf);
+
 		if (fp->type & QEDE_FASTPATH_TX)
 			qede_get_strings_stats_txq(edev, fp->txq, &buf);
 	}
@@ -268,6 +276,9 @@ static void qede_get_ethtool_stats(struct net_device *dev,
 		if (fp->type & QEDE_FASTPATH_RX)
 			qede_get_ethtool_stats_rxq(fp->rxq, &buf);
 
+		if (fp->type & QEDE_FASTPATH_XDP)
+			qede_get_ethtool_stats_txq(fp->xdp_tx, &buf);
+
 		if (fp->type & QEDE_FASTPATH_TX)
 			qede_get_ethtool_stats_txq(fp->txq, &buf);
 	}
@@ -305,6 +316,9 @@ static int qede_get_sset_count(struct net_device *dev, int stringset)
 		/* Account for the Regular Rx statistics */
 		num_stats += QEDE_RSS_COUNT(edev) * QEDE_NUM_RQSTATS;
 
+		/* Account for XDP statistics [if needed] */
+		if (edev->xdp_prog)
+			num_stats += QEDE_RSS_COUNT(edev) * QEDE_NUM_TQSTATS;
 		return num_stats;
 
 	case ETH_SS_PRIV_FLAGS:
@@ -1216,7 +1230,7 @@ static int qede_selftest_transmit_traffic(struct qede_dev *edev,
 
 	/* Fill the entry in the SW ring and the BDs in the FW ring */
 	idx = txq->sw_tx_prod & NUM_TX_BDS_MAX;
-	txq->sw_tx_ring[idx].skb = skb;
+	txq->sw_tx_ring.skbs[idx].skb = skb;
 	first_bd = qed_chain_produce(&txq->tx_pbl);
 	memset(first_bd, 0, sizeof(*first_bd));
 	val = 1 << ETH_TX_1ST_BD_FLAGS_START_BD_SHIFT;
@@ -1270,7 +1284,7 @@ static int qede_selftest_transmit_traffic(struct qede_dev *edev,
 	dma_unmap_single(&edev->pdev->dev, BD_UNMAP_ADDR(first_bd),
 			 BD_UNMAP_LEN(first_bd), DMA_TO_DEVICE);
 	txq->sw_tx_cons++;
-	txq->sw_tx_ring[idx].skb = NULL;
+	txq->sw_tx_ring.skbs[idx].skb = NULL;
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 493e43c..88c16d2 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -94,6 +94,9 @@ enum qede_pci_private {
 
 #define TX_TIMEOUT		(5 * HZ)
 
+/* Utilize last protocol index for XDP */
+#define XDP_PI	11
+
 static void qede_remove(struct pci_dev *pdev);
 static void qede_shutdown(struct pci_dev *pdev);
 static void qede_link_update(void *dev, struct qed_link_output *link);
@@ -301,12 +304,12 @@ static int qede_free_tx_pkt(struct qede_dev *edev,
 			    struct qede_tx_queue *txq, int *len)
 {
 	u16 idx = txq->sw_tx_cons & NUM_TX_BDS_MAX;
-	struct sk_buff *skb = txq->sw_tx_ring[idx].skb;
+	struct sk_buff *skb = txq->sw_tx_ring.skbs[idx].skb;
 	struct eth_tx_1st_bd *first_bd;
 	struct eth_tx_bd *tx_data_bd;
 	int bds_consumed = 0;
 	int nbds;
-	bool data_split = txq->sw_tx_ring[idx].flags & QEDE_TSO_SPLIT_BD;
+	bool data_split = txq->sw_tx_ring.skbs[idx].flags & QEDE_TSO_SPLIT_BD;
 	int i, split_bd_len = 0;
 
 	if (unlikely(!skb)) {
@@ -346,8 +349,8 @@ static int qede_free_tx_pkt(struct qede_dev *edev,
 
 	/* Free skb */
 	dev_kfree_skb_any(skb);
-	txq->sw_tx_ring[idx].skb = NULL;
-	txq->sw_tx_ring[idx].flags = 0;
+	txq->sw_tx_ring.skbs[idx].skb = NULL;
+	txq->sw_tx_ring.skbs[idx].flags = 0;
 
 	return 0;
 }
@@ -358,7 +361,7 @@ static void qede_free_failed_tx_pkt(struct qede_tx_queue *txq,
 				    int nbd, bool data_split)
 {
 	u16 idx = txq->sw_tx_prod & NUM_TX_BDS_MAX;
-	struct sk_buff *skb = txq->sw_tx_ring[idx].skb;
+	struct sk_buff *skb = txq->sw_tx_ring.skbs[idx].skb;
 	struct eth_tx_bd *tx_data_bd;
 	int i, split_bd_len = 0;
 
@@ -394,8 +397,8 @@ static void qede_free_failed_tx_pkt(struct qede_tx_queue *txq,
 
 	/* Free skb */
 	dev_kfree_skb_any(skb);
-	txq->sw_tx_ring[idx].skb = NULL;
-	txq->sw_tx_ring[idx].flags = 0;
+	txq->sw_tx_ring.skbs[idx].skb = NULL;
+	txq->sw_tx_ring.skbs[idx].flags = 0;
 }
 
 static u32 qede_xmit_type(struct sk_buff *skb, int *ipv6_ext)
@@ -530,6 +533,47 @@ static inline void qede_update_tx_producer(struct qede_tx_queue *txq)
 	mmiowb();
 }
 
+static int qede_xdp_xmit(struct qede_dev *edev, struct qede_fastpath *fp,
+			 struct sw_rx_data *metadata, u16 padding, u16 length)
+{
+	struct qede_tx_queue *txq = fp->xdp_tx;
+	u16 idx = txq->sw_tx_prod & NUM_TX_BDS_MAX;
+	struct eth_tx_1st_bd *first_bd;
+
+	if (!qed_chain_get_elem_left(&txq->tx_pbl)) {
+		txq->stopped_cnt++;
+		return -ENOMEM;
+	}
+
+	first_bd = (struct eth_tx_1st_bd *)qed_chain_produce(&txq->tx_pbl);
+
+	memset(first_bd, 0, sizeof(*first_bd));
+	first_bd->data.bd_flags.bitfields =
+	    BIT(ETH_TX_1ST_BD_FLAGS_START_BD_SHIFT);
+	first_bd->data.bitfields |=
+	    (length & ETH_TX_DATA_1ST_BD_PKT_LEN_MASK) <<
+	    ETH_TX_DATA_1ST_BD_PKT_LEN_SHIFT;
+	first_bd->data.nbds = 1;
+
+	/* We can safely ignore the offset, as it's 0 for XDP */
+	BD_SET_UNMAP_ADDR_LEN(first_bd, metadata->mapping + padding, length);
+
+	/* Synchronize the buffer back to device, as program [probably]
+	 * have changed it.
+	 */
+	dma_sync_single_for_device(&edev->pdev->dev,
+				   metadata->mapping + padding,
+				   length, PCI_DMA_TODEVICE);
+
+	txq->sw_tx_ring.pages[idx] = metadata->data;
+	txq->sw_tx_prod++;
+
+	/* Mark the fastpath for future XDP doorbell */
+	fp->xdp_xmit = 1;
+
+	return 0;
+}
+
 /* Main transmit function */
 static netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 				   struct net_device *ndev)
@@ -573,7 +617,7 @@ static netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 
 	/* Fill the entry in the SW ring and the BDs in the FW ring */
 	idx = txq->sw_tx_prod & NUM_TX_BDS_MAX;
-	txq->sw_tx_ring[idx].skb = skb;
+	txq->sw_tx_ring.skbs[idx].skb = skb;
 	first_bd = (struct eth_tx_1st_bd *)
 		   qed_chain_produce(&txq->tx_pbl);
 	memset(first_bd, 0, sizeof(*first_bd));
@@ -693,7 +737,7 @@ static netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 			/* this marks the BD as one that has no
 			 * individual mapping
 			 */
-			txq->sw_tx_ring[idx].flags |= QEDE_TSO_SPLIT_BD;
+			txq->sw_tx_ring.skbs[idx].flags |= QEDE_TSO_SPLIT_BD;
 
 			first_bd->nbytes = cpu_to_le16(hlen);
 
@@ -802,6 +846,27 @@ int qede_txq_has_work(struct qede_tx_queue *txq)
 	return hw_bd_cons != qed_chain_get_cons_idx(&txq->tx_pbl);
 }
 
+static void qede_xdp_tx_int(struct qede_dev *edev, struct qede_tx_queue *txq)
+{
+	struct eth_tx_1st_bd *bd;
+	u16 hw_bd_cons;
+
+	hw_bd_cons = le16_to_cpu(*txq->hw_cons_ptr);
+	barrier();
+
+	while (hw_bd_cons != qed_chain_get_cons_idx(&txq->tx_pbl)) {
+		bd = (struct eth_tx_1st_bd *)qed_chain_consume(&txq->tx_pbl);
+
+		dma_unmap_single(&edev->pdev->dev, BD_UNMAP_ADDR(bd),
+				 PAGE_SIZE, DMA_BIDIRECTIONAL);
+		__free_page(txq->sw_tx_ring.pages[txq->sw_tx_cons &
+						  NUM_TX_BDS_MAX]);
+
+		txq->sw_tx_cons++;
+		txq->xmit_pkts++;
+	}
+}
+
 static int qede_tx_int(struct qede_dev *edev, struct qede_tx_queue *txq)
 {
 	struct netdev_queue *netdev_txq;
@@ -942,7 +1007,7 @@ static int qede_alloc_rx_buffer(struct qede_rx_queue *rxq)
 	 * for multiple RX buffer segment size mapping.
 	 */
 	mapping = dma_map_page(rxq->dev, data, 0,
-			       PAGE_SIZE, DMA_FROM_DEVICE);
+			       PAGE_SIZE, rxq->data_direction);
 	if (unlikely(dma_mapping_error(rxq->dev, mapping))) {
 		__free_page(data);
 		return -ENOMEM;
@@ -981,7 +1046,7 @@ static inline int qede_realloc_rx_buffer(struct qede_rx_queue *rxq,
 		}
 
 		dma_unmap_page(rxq->dev, curr_cons->mapping,
-			       PAGE_SIZE, DMA_FROM_DEVICE);
+			       PAGE_SIZE, rxq->data_direction);
 	} else {
 		/* Increment refcount of the page as we don't want
 		 * network stack to take the ownership of the page
@@ -1441,6 +1506,26 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 	rxq->xdp_no_pass++;
 
 	switch (act) {
+	case XDP_TX:
+		/* We need the replacement buffer before transmit. */
+		if (qede_alloc_rx_buffer(rxq)) {
+			qede_recycle_rx_bd_ring(rxq, 1);
+			return false;
+		}
+
+		/* Now if there's a transmission problem, we'd still have to
+		 * throw current buffer, as replacement was already allocated.
+		 */
+		if (qede_xdp_xmit(edev, fp, bd, cqe->placement_offset, len)) {
+			dma_unmap_page(rxq->dev, bd->mapping,
+				       PAGE_SIZE, DMA_BIDIRECTIONAL);
+			__free_page(bd->data);
+		}
+
+		/* Regardless, we've consumed an Rx BD */
+		qede_rx_bd_ring_consume(rxq);
+		return false;
+
 	default:
 		bpf_warn_invalid_xdp_action(act);
 	case XDP_ABORTED:
@@ -1740,6 +1825,10 @@ static bool qede_poll_is_more_work(struct qede_fastpath *fp)
 		if (qede_has_rx_work(fp->rxq))
 			return true;
 
+	if (fp->type & QEDE_FASTPATH_XDP)
+		if (qede_txq_has_work(fp->xdp_tx))
+			return true;
+
 	if (likely(fp->type & QEDE_FASTPATH_TX))
 		if (qede_txq_has_work(fp->txq))
 			return true;
@@ -1757,6 +1846,9 @@ static int qede_poll(struct napi_struct *napi, int budget)
 	if (likely(fp->type & QEDE_FASTPATH_TX) && qede_txq_has_work(fp->txq))
 		qede_tx_int(edev, fp->txq);
 
+	if ((fp->type & QEDE_FASTPATH_XDP) && qede_txq_has_work(fp->xdp_tx))
+		qede_xdp_tx_int(edev, fp->xdp_tx);
+
 	rx_work_done = (likely(fp->type & QEDE_FASTPATH_RX) &&
 			qede_has_rx_work(fp->rxq)) ?
 			qede_rx_int(fp, budget) : 0;
@@ -1771,6 +1863,14 @@ static int qede_poll(struct napi_struct *napi, int budget)
 		}
 	}
 
+	if (fp->xdp_xmit) {
+		u16 xdp_prod = qed_chain_get_prod_idx(&fp->xdp_tx->tx_pbl);
+
+		fp->xdp_xmit = 0;
+		fp->xdp_tx->tx_db.data.bd_prod = cpu_to_le16(xdp_prod);
+		qede_update_tx_producer(fp->xdp_tx);
+	}
+
 	return rx_work_done;
 }
 
@@ -2600,6 +2700,7 @@ static void qede_free_fp_array(struct qede_dev *edev)
 
 			kfree(fp->sb_info);
 			kfree(fp->rxq);
+			kfree(fp->xdp_tx);
 			kfree(fp->txq);
 		}
 		kfree(edev->fp_array);
@@ -2660,8 +2761,13 @@ static int qede_alloc_fp_array(struct qede_dev *edev)
 			if (!fp->rxq)
 				goto err;
 
-			if (edev->xdp_prog)
+			if (edev->xdp_prog) {
+				fp->xdp_tx = kzalloc(sizeof(*fp->xdp_tx),
+						     GFP_KERNEL);
+				if (!fp->xdp_tx)
+					goto err;
 				fp->type |= QEDE_FASTPATH_XDP;
+			}
 		}
 	}
 
@@ -2708,9 +2814,9 @@ static void qede_update_pf_params(struct qed_dev *cdev)
 {
 	struct qed_pf_params pf_params;
 
-	/* 64 rx + 64 tx */
+	/* 64 rx + 64 tx + 64 XDP */
 	memset(&pf_params, 0, sizeof(struct qed_pf_params));
-	pf_params.eth_pf_params.num_cons = 128;
+	pf_params.eth_pf_params.num_cons = 192;
 	qed_ops->common->update_pf_params(cdev, &pf_params);
 }
 
@@ -2967,7 +3073,7 @@ static void qede_free_rx_buffers(struct qede_dev *edev,
 		data = rx_buf->data;
 
 		dma_unmap_page(&edev->pdev->dev,
-			       rx_buf->mapping, PAGE_SIZE, DMA_FROM_DEVICE);
+			       rx_buf->mapping, PAGE_SIZE, rxq->data_direction);
 
 		rx_buf->data = NULL;
 		__free_page(data);
@@ -3128,7 +3234,10 @@ static int qede_alloc_mem_rxq(struct qede_dev *edev, struct qede_rx_queue *rxq)
 static void qede_free_mem_txq(struct qede_dev *edev, struct qede_tx_queue *txq)
 {
 	/* Free the parallel SW ring */
-	kfree(txq->sw_tx_ring);
+	if (txq->is_xdp)
+		kfree(txq->sw_tx_ring.pages);
+	else
+		kfree(txq->sw_tx_ring.skbs);
 
 	/* Free the real RQ ring used by FW */
 	edev->ops->common->chain_free(edev->cdev, &txq->tx_pbl);
@@ -3137,17 +3246,22 @@ static void qede_free_mem_txq(struct qede_dev *edev, struct qede_tx_queue *txq)
 /* This function allocates all memory needed per Tx queue */
 static int qede_alloc_mem_txq(struct qede_dev *edev, struct qede_tx_queue *txq)
 {
-	int size, rc;
 	union eth_tx_bd_types *p_virt;
+	int size, rc;
 
 	txq->num_tx_buffers = edev->q_num_tx_buffers;
 
 	/* Allocate the parallel driver ring for Tx buffers */
-	size = sizeof(*txq->sw_tx_ring) * TX_RING_SIZE;
-	txq->sw_tx_ring = kzalloc(size, GFP_KERNEL);
-	if (!txq->sw_tx_ring) {
-		DP_NOTICE(edev, "Tx buffers ring allocation failed\n");
-		goto err;
+	if (txq->is_xdp) {
+		size = sizeof(*txq->sw_tx_ring.pages) * TX_RING_SIZE;
+		txq->sw_tx_ring.pages = kzalloc(size, GFP_KERNEL);
+		if (!txq->sw_tx_ring.pages)
+			goto err;
+	} else {
+		size = sizeof(*txq->sw_tx_ring.skbs) * TX_RING_SIZE;
+		txq->sw_tx_ring.skbs = kzalloc(size, GFP_KERNEL);
+		if (!txq->sw_tx_ring.skbs)
+			goto err;
 	}
 
 	rc = edev->ops->common->chain_alloc(edev->cdev,
@@ -3183,26 +3297,31 @@ static void qede_free_mem_fp(struct qede_dev *edev, struct qede_fastpath *fp)
  */
 static int qede_alloc_mem_fp(struct qede_dev *edev, struct qede_fastpath *fp)
 {
-	int rc;
+	int rc = 0;
 
 	rc = qede_alloc_mem_sb(edev, fp->sb_info, fp->id);
 	if (rc)
-		goto err;
+		goto out;
 
 	if (fp->type & QEDE_FASTPATH_RX) {
 		rc = qede_alloc_mem_rxq(edev, fp->rxq);
 		if (rc)
-			goto err;
+			goto out;
+	}
+
+	if (fp->type & QEDE_FASTPATH_XDP) {
+		rc = qede_alloc_mem_txq(edev, fp->xdp_tx);
+		if (rc)
+			goto out;
 	}
 
 	if (fp->type & QEDE_FASTPATH_TX) {
 		rc = qede_alloc_mem_txq(edev, fp->txq);
 		if (rc)
-			goto err;
+			goto out;
 	}
 
-	return 0;
-err:
+out:
 	return rc;
 }
 
@@ -3250,9 +3369,20 @@ static void qede_init_fp(struct qede_dev *edev)
 		fp->edev = edev;
 		fp->id = queue_id;
 
+		if (fp->type & QEDE_FASTPATH_XDP) {
+			fp->xdp_tx->index = QEDE_TXQ_IDX_TO_XDP(edev,
+								rxq_index);
+			fp->xdp_tx->is_xdp = 1;
+		}
 
 		if (fp->type & QEDE_FASTPATH_RX) {
 			fp->rxq->rxq_id = rxq_index++;
+
+			/* Determine how to map buffers for this queue */
+			if (fp->type & QEDE_FASTPATH_XDP)
+				fp->rxq->data_direction = DMA_BIDIRECTIONAL;
+			else
+				fp->rxq->data_direction = DMA_FROM_DEVICE;
 			fp->rxq->dev = &edev->pdev->dev;
 		}
 
@@ -3463,6 +3593,12 @@ static int qede_stop_queues(struct qede_dev *edev)
 			if (rc)
 				return rc;
 		}
+
+		if (fp->type & QEDE_FASTPATH_XDP) {
+			rc = qede_drain_txq(edev, fp->xdp_tx, true);
+			if (rc)
+				return rc;
+		}
 	}
 
 	/* Stop all Queues in reverse order */
@@ -3485,8 +3621,14 @@ static int qede_stop_queues(struct qede_dev *edev)
 			}
 		}
 
-		if (fp->type & QEDE_FASTPATH_XDP)
+		/* Stop the XDP forwarding queue */
+		if (fp->type & QEDE_FASTPATH_XDP) {
+			rc = qede_stop_txq(edev, fp->xdp_tx, i);
+			if (rc)
+				return rc;
+
 			bpf_prog_put(fp->rxq->xdp_prog);
+		}
 	}
 
 	/* Stop the vport */
@@ -3510,7 +3652,14 @@ static int qede_start_txq(struct qede_dev *edev,
 	memset(&params, 0, sizeof(params));
 	memset(&ret_params, 0, sizeof(ret_params));
 
-	params.queue_id = txq->index;
+	/* Let the XDP queue share the queue-zone with one of the regular txq.
+	 * We don't really care about its coalescing.
+	 */
+	if (txq->is_xdp)
+		params.queue_id = QEDE_TXQ_XDP_TO_IDX(edev, txq);
+	else
+		params.queue_id = txq->index;
+
 	params.sb = fp->sb_info->igu_sb_id;
 	params.sb_idx = sb_idx;
 
@@ -3615,6 +3764,10 @@ static int qede_start_queues(struct qede_dev *edev, bool clear_stats)
 		}
 
 		if (fp->type & QEDE_FASTPATH_XDP) {
+			rc = qede_start_txq(edev, fp, fp->xdp_tx, i, XDP_PI);
+			if (rc)
+				return rc;
+
 			fp->rxq->xdp_prog = bpf_prog_add(edev->xdp_prog, 1);
 			if (IS_ERR(fp->rxq->xdp_prog)) {
 				rc = PTR_ERR(fp->rxq->xdp_prog);
-- 
1.9.3
