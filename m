From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 5/5] [net-next] qlge: Use one path to (re)fill rx buffers.
Date: Mon, 23 Feb 2009 12:42:17 -0800
Message-ID: <1235421737-32296-5-git-send-email-ron.mercer@qlogic.com>
References: <1235421737-32296-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:3006 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbZBWUpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 15:45:40 -0500
In-Reply-To: <1235421737-32296-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there are two paths for filling rx buffer queues. One is
used during initialization and the other during runtime.  This patch
removes ql_alloc_sbq_buffers() and ql_alloc_lbq_buffers() and replaces
them with a call to the runtime functions ql_update_lbq() and
ql_update_sbq().

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |  170 +++++++++++++++---------------------------
 1 files changed, 59 insertions(+), 111 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 1719845..655f3c4 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2105,47 +2105,6 @@ static void ql_free_lbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring
 	}
 }
 
-/*
- * Allocate and map a page for each element of the lbq.
- */
-static int ql_alloc_lbq_buffers(struct ql_adapter *qdev,
-				struct rx_ring *rx_ring)
-{
-	int i;
-	struct bq_desc *lbq_desc;
-	u64 map;
-	__le64 *bq = rx_ring->lbq_base;
-
-	for (i = 0; i < rx_ring->lbq_len; i++) {
-		lbq_desc = &rx_ring->lbq[i];
-		memset(lbq_desc, 0, sizeof(lbq_desc));
-		lbq_desc->addr = bq;
-		lbq_desc->index = i;
-		lbq_desc->p.lbq_page = alloc_page(GFP_ATOMIC);
-		if (unlikely(!lbq_desc->p.lbq_page)) {
-			QPRINTK(qdev, IFUP, ERR, "failed alloc_page().\n");
-			goto mem_error;
-		} else {
-			map = pci_map_page(qdev->pdev,
-					   lbq_desc->p.lbq_page,
-					   0, PAGE_SIZE, PCI_DMA_FROMDEVICE);
-			if (pci_dma_mapping_error(qdev->pdev, map)) {
-				QPRINTK(qdev, IFUP, ERR,
-					"PCI mapping failed.\n");
-				goto mem_error;
-			}
-			pci_unmap_addr_set(lbq_desc, mapaddr, map);
-			pci_unmap_len_set(lbq_desc, maplen, PAGE_SIZE);
-			*lbq_desc->addr = cpu_to_le64(map);
-		}
-		bq++;
-	}
-	return 0;
-mem_error:
-	ql_free_lbq_buffers(qdev, rx_ring);
-	return -ENOMEM;
-}
-
 static void ql_free_sbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
 	int i;
@@ -2168,63 +2127,72 @@ static void ql_free_sbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring
 	}
 }
 
-/* Allocate and map an skb for each element of the sbq. */
-static int ql_alloc_sbq_buffers(struct ql_adapter *qdev,
+/* Free all large and small rx buffers associated
+ * with the completion queues for this device.
+ */
+static void ql_free_rx_buffers(struct ql_adapter *qdev)
+{
+	int i;
+	struct rx_ring *rx_ring;
+
+	for (i = 0; i < qdev->rx_ring_count; i++) {
+		rx_ring = &qdev->rx_ring[i];
+		if (rx_ring->lbq)
+			ql_free_lbq_buffers(qdev, rx_ring);
+		if (rx_ring->sbq)
+			ql_free_sbq_buffers(qdev, rx_ring);
+	}
+}
+
+static void ql_alloc_rx_buffers(struct ql_adapter *qdev)
+{
+	struct rx_ring *rx_ring;
+	int i;
+
+	for (i = 0; i < qdev->rx_ring_count; i++) {
+		rx_ring = &qdev->rx_ring[i];
+		if (rx_ring->type != TX_Q)
+			ql_update_buffer_queues(qdev, rx_ring);
+	}
+}
+
+static void ql_init_lbq_ring(struct ql_adapter *qdev,
+				struct rx_ring *rx_ring)
+{
+	int i;
+	struct bq_desc *lbq_desc;
+	__le64 *bq = rx_ring->lbq_base;
+
+	memset(rx_ring->lbq, 0, rx_ring->lbq_len * sizeof(struct bq_desc));
+	for (i = 0; i < rx_ring->lbq_len; i++) {
+		lbq_desc = &rx_ring->lbq[i];
+		memset(lbq_desc, 0, sizeof(*lbq_desc));
+		lbq_desc->index = i;
+		lbq_desc->addr = bq;
+		bq++;
+	}
+}
+
+static void ql_init_sbq_ring(struct ql_adapter *qdev,
 				struct rx_ring *rx_ring)
 {
 	int i;
 	struct bq_desc *sbq_desc;
-	struct sk_buff *skb;
-	u64 map;
 	__le64 *bq = rx_ring->sbq_base;
 
+	memset(rx_ring->sbq, 0, rx_ring->sbq_len * sizeof(struct bq_desc));
 	for (i = 0; i < rx_ring->sbq_len; i++) {
 		sbq_desc = &rx_ring->sbq[i];
-		memset(sbq_desc, 0, sizeof(sbq_desc));
+		memset(sbq_desc, 0, sizeof(*sbq_desc));
 		sbq_desc->index = i;
 		sbq_desc->addr = bq;
-		skb = netdev_alloc_skb(qdev->ndev, rx_ring->sbq_buf_size);
-		if (unlikely(!skb)) {
-			/* Better luck next round */
-			QPRINTK(qdev, IFUP, ERR,
-				"small buff alloc failed for %d bytes at index %d.\n",
-				rx_ring->sbq_buf_size, i);
-			goto mem_err;
-		}
-		skb_reserve(skb, QLGE_SB_PAD);
-		sbq_desc->p.skb = skb;
-		/*
-		 * Map only half the buffer. Because the
-		 * other half may get some data copied to it
-		 * when the completion arrives.
-		 */
-		map = pci_map_single(qdev->pdev,
-				     skb->data,
-				     rx_ring->sbq_buf_size / 2,
-				     PCI_DMA_FROMDEVICE);
-		if (pci_dma_mapping_error(qdev->pdev, map)) {
-			QPRINTK(qdev, IFUP, ERR, "PCI mapping failed.\n");
-			goto mem_err;
-		}
-		pci_unmap_addr_set(sbq_desc, mapaddr, map);
-		pci_unmap_len_set(sbq_desc, maplen, rx_ring->sbq_buf_size / 2);
-		*sbq_desc->addr = cpu_to_le64(map);
 		bq++;
 	}
-	return 0;
-mem_err:
-	ql_free_sbq_buffers(qdev, rx_ring);
-	return -ENOMEM;
 }
 
 static void ql_free_rx_resources(struct ql_adapter *qdev,
 				 struct rx_ring *rx_ring)
 {
-	if (rx_ring->sbq_len)
-		ql_free_sbq_buffers(qdev, rx_ring);
-	if (rx_ring->lbq_len)
-		ql_free_lbq_buffers(qdev, rx_ring);
-
 	/* Free the small buffer queue. */
 	if (rx_ring->sbq_base) {
 		pci_free_consistent(qdev->pdev,
@@ -2302,11 +2270,7 @@ static int ql_alloc_rx_resources(struct ql_adapter *qdev,
 			goto err_mem;
 		}
 
-		if (ql_alloc_sbq_buffers(qdev, rx_ring)) {
-			QPRINTK(qdev, IFUP, ERR,
-				"Small buffer allocation failed.\n");
-			goto err_mem;
-		}
+		ql_init_sbq_ring(qdev, rx_ring);
 	}
 
 	if (rx_ring->lbq_len) {
@@ -2334,14 +2298,7 @@ static int ql_alloc_rx_resources(struct ql_adapter *qdev,
 			goto err_mem;
 		}
 
-		/*
-		 * Allocate the buffers.
-		 */
-		if (ql_alloc_lbq_buffers(qdev, rx_ring)) {
-			QPRINTK(qdev, IFUP, ERR,
-				"Large buffer allocation failed.\n");
-			goto err_mem;
-		}
+		ql_init_lbq_ring(qdev, rx_ring);
 	}
 
 	return 0;
@@ -2489,10 +2446,10 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		bq_len = (rx_ring->lbq_len == 65536) ? 0 :
 			(u16) rx_ring->lbq_len;
 		cqicb->lbq_len = cpu_to_le16(bq_len);
-		rx_ring->lbq_prod_idx = rx_ring->lbq_len - 16;
+		rx_ring->lbq_prod_idx = 0;
 		rx_ring->lbq_curr_idx = 0;
-		rx_ring->lbq_clean_idx = rx_ring->lbq_prod_idx;
-		rx_ring->lbq_free_cnt = 16;
+		rx_ring->lbq_clean_idx = 0;
+		rx_ring->lbq_free_cnt = rx_ring->lbq_len;
 	}
 	if (rx_ring->sbq_len) {
 		cqicb->flags |= FLAGS_LS;	/* Load sbq values */
@@ -2504,10 +2461,10 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		bq_len = (rx_ring->sbq_len == 65536) ? 0 :
 			(u16) rx_ring->sbq_len;
 		cqicb->sbq_len = cpu_to_le16(bq_len);
-		rx_ring->sbq_prod_idx = rx_ring->sbq_len - 16;
+		rx_ring->sbq_prod_idx = 0;
 		rx_ring->sbq_curr_idx = 0;
-		rx_ring->sbq_clean_idx = rx_ring->sbq_prod_idx;
-		rx_ring->sbq_free_cnt = 16;
+		rx_ring->sbq_clean_idx = 0;
+		rx_ring->sbq_free_cnt = rx_ring->sbq_len;
 	}
 	switch (rx_ring->type) {
 	case TX_Q:
@@ -2560,17 +2517,6 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		QPRINTK(qdev, IFUP, ERR, "Failed to load CQICB.\n");
 		return err;
 	}
-	QPRINTK(qdev, IFUP, INFO, "Successfully loaded CQICB.\n");
-	/*
-	 * Advance the producer index for the buffer queues.
-	 */
-	wmb();
-	if (rx_ring->lbq_len)
-		ql_write_db_reg(rx_ring->lbq_prod_idx,
-				rx_ring->lbq_prod_idx_db_reg);
-	if (rx_ring->sbq_len)
-		ql_write_db_reg(rx_ring->sbq_prod_idx,
-				rx_ring->sbq_prod_idx_db_reg);
 	return err;
 }
 
@@ -3171,6 +3117,7 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 
 	ql_tx_ring_clean(qdev);
 
+	ql_free_rx_buffers(qdev);
 	spin_lock(&qdev->hw_lock);
 	status = ql_adapter_reset(qdev);
 	if (status)
@@ -3193,6 +3140,7 @@ static int ql_adapter_up(struct ql_adapter *qdev)
 	}
 	spin_unlock(&qdev->hw_lock);
 	set_bit(QL_ADAPTER_UP, &qdev->flags);
+	ql_alloc_rx_buffers(qdev);
 	ql_enable_interrupts(qdev);
 	ql_enable_all_completion_interrupts(qdev);
 	if ((ql_read32(qdev, STS) & qdev->port_init)) {
-- 
1.6.0.2

