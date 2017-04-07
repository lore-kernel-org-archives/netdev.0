From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 2/5] qede: Correct XDP forward unmapping
Date: Fri, 7 Apr 2017 11:04:58 +0300
Message-ID: <1491552301-23953-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1491552301-23953-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ast@fb.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:43364 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754196AbdDGIGX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 04:06:23 -0400
In-Reply-To: <1491552301-23953-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver is currently using dma_unmap_single() with the address it
passed to device for the purpose of forwarding, but the XDP
transmission buffer was originally a page allocated for the rx-queue.
The mapped address is likely to differ from the original mapped
address due to the placement offset.

This difference is going to get even bigger once we support headroom.

Cache the original mapped address of the page, and use it for unmapping
of the buffer when completion arrives for the XDP forwarded packet.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h      |  9 +++++++--
 drivers/net/ethernet/qlogic/qede/qede_fp.c   | 17 +++++++++--------
 drivers/net/ethernet/qlogic/qede/qede_main.c |  8 ++++----
 3 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index e73a4a5..7ab2201 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -349,6 +349,11 @@ struct sw_tx_bd {
 #define QEDE_TSO_SPLIT_BD		BIT(0)
 };
 
+struct sw_tx_xdp {
+	struct page *page;
+	dma_addr_t mapping;
+};
+
 struct qede_tx_queue {
 	u8 is_xdp;
 	bool is_legacy;
@@ -372,11 +377,11 @@ struct qede_tx_queue {
 #define QEDE_TXQ_IDX_TO_XDP(edev, idx)	((idx) + QEDE_MAX_TSS_CNT(edev))
 
 	/* Regular Tx requires skb + metadata for release purpose,
-	 * while XDP requires only the pages themselves.
+	 * while XDP requires the pages and the mapped address.
 	 */
 	union {
 		struct sw_tx_bd *skbs;
-		struct page **pages;
+		struct sw_tx_xdp *xdp;
 	} sw_tx_ring;
 
 	struct qed_chain tx_pbl;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_fp.c b/drivers/net/ethernet/qlogic/qede/qede_fp.c
index c77e697..c61cfcf 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_fp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_fp.c
@@ -360,7 +360,8 @@ static int qede_xdp_xmit(struct qede_dev *edev, struct qede_fastpath *fp,
 				   metadata->mapping + padding,
 				   length, PCI_DMA_TODEVICE);
 
-	txq->sw_tx_ring.pages[idx] = metadata->data;
+	txq->sw_tx_ring.xdp[idx].page = metadata->data;
+	txq->sw_tx_ring.xdp[idx].mapping = metadata->mapping;
 	txq->sw_tx_prod++;
 
 	/* Mark the fastpath for future XDP doorbell */
@@ -384,19 +385,19 @@ int qede_txq_has_work(struct qede_tx_queue *txq)
 
 static void qede_xdp_tx_int(struct qede_dev *edev, struct qede_tx_queue *txq)
 {
-	struct eth_tx_1st_bd *bd;
-	u16 hw_bd_cons;
+	u16 hw_bd_cons, idx;
 
 	hw_bd_cons = le16_to_cpu(*txq->hw_cons_ptr);
 	barrier();
 
 	while (hw_bd_cons != qed_chain_get_cons_idx(&txq->tx_pbl)) {
-		bd = (struct eth_tx_1st_bd *)qed_chain_consume(&txq->tx_pbl);
+		qed_chain_consume(&txq->tx_pbl);
+		idx = txq->sw_tx_cons & NUM_TX_BDS_MAX;
 
-		dma_unmap_single(&edev->pdev->dev, BD_UNMAP_ADDR(bd),
-				 PAGE_SIZE, DMA_BIDIRECTIONAL);
-		__free_page(txq->sw_tx_ring.pages[txq->sw_tx_cons &
-						  NUM_TX_BDS_MAX]);
+		dma_unmap_page(&edev->pdev->dev,
+			       txq->sw_tx_ring.xdp[idx].mapping,
+			       PAGE_SIZE, DMA_BIDIRECTIONAL);
+		__free_page(txq->sw_tx_ring.xdp[idx].page);
 
 		txq->sw_tx_cons++;
 		txq->xmit_pkts++;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index abd9910..fa62c37 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1251,7 +1251,7 @@ static void qede_free_mem_txq(struct qede_dev *edev, struct qede_tx_queue *txq)
 {
 	/* Free the parallel SW ring */
 	if (txq->is_xdp)
-		kfree(txq->sw_tx_ring.pages);
+		kfree(txq->sw_tx_ring.xdp);
 	else
 		kfree(txq->sw_tx_ring.skbs);
 
@@ -1269,9 +1269,9 @@ static int qede_alloc_mem_txq(struct qede_dev *edev, struct qede_tx_queue *txq)
 
 	/* Allocate the parallel driver ring for Tx buffers */
 	if (txq->is_xdp) {
-		size = sizeof(*txq->sw_tx_ring.pages) * TX_RING_SIZE;
-		txq->sw_tx_ring.pages = kzalloc(size, GFP_KERNEL);
-		if (!txq->sw_tx_ring.pages)
+		size = sizeof(*txq->sw_tx_ring.xdp) * TX_RING_SIZE;
+		txq->sw_tx_ring.xdp = kzalloc(size, GFP_KERNEL);
+		if (!txq->sw_tx_ring.xdp)
 			goto err;
 	} else {
 		size = sizeof(*txq->sw_tx_ring.skbs) * TX_RING_SIZE;
-- 
1.9.3
