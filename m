From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 10/21] [next] qlge: Cleanup rx buffer allocations.
Date: Fri, 23 Jan 2009 07:16:28 -0800
Message-ID: <1232723799-8620-10-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754441AbZAWPR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:17:57 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There were two paths to fill rx buffer queues. One used during
initialization and another at runtime.  This patch causes the
same code to be used in both places.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |  184 ++++++++++++++---------------------------
 1 files changed, 63 insertions(+), 121 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index f3fa375..55c0f91 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2125,7 +2125,7 @@ static void ql_free_lbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring
 
 	for (i = 0; i < rx_ring->lbq_len; i++) {
 		lbq_desc = &rx_ring->lbq[i];
-		if (lbq_desc->p.lbq_page) {
+		if (lbq_desc && lbq_desc->p.lbq_page) {
 			pci_unmap_page(qdev->pdev,
 				       pci_unmap_addr(lbq_desc, mapaddr),
 				       pci_unmap_len(lbq_desc, maplen),
@@ -2137,47 +2137,6 @@ static void ql_free_lbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring
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
@@ -2185,11 +2144,7 @@ static void ql_free_sbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring
 
 	for (i = 0; i < rx_ring->sbq_len; i++) {
 		sbq_desc = &rx_ring->sbq[i];
-		if (sbq_desc == NULL) {
-			QPRINTK(qdev, IFUP, ERR, "sbq_desc %d is NULL.\n", i);
-			return;
-		}
-		if (sbq_desc->p.skb) {
+		if (sbq_desc && sbq_desc->p.skb) {
 			pci_unmap_single(qdev->pdev,
 					 pci_unmap_addr(sbq_desc, mapaddr),
 					 pci_unmap_len(sbq_desc, maplen),
@@ -2200,63 +2155,68 @@ static void ql_free_sbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring
 	}
 }
 
-/* Allocate and map an skb for each element of the sbq. */
-static int ql_alloc_sbq_buffers(struct ql_adapter *qdev,
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
+		memset(lbq_desc, 0, sizeof(lbq_desc));
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
 		memset(sbq_desc, 0, sizeof(sbq_desc));
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
-
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
@@ -2334,11 +2294,7 @@ static int ql_alloc_rx_resources(struct ql_adapter *qdev,
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
@@ -2366,14 +2322,7 @@ static int ql_alloc_rx_resources(struct ql_adapter *qdev,
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
@@ -2467,6 +2416,7 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	    qdev->doorbell_area + (DB_PAGE_SIZE * (128 + rx_ring->cq_id));
 	int err = 0;
 	u16 bq_len;
+	u64 tmp;
 
 	/* Set up the shadow registers for this ring. */
 	rx_ring->prod_idx_sh_reg = shadow_reg;
@@ -2512,7 +2462,8 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	    FLAGS_LI;		/* Load irq delay values */
 	if (rx_ring->lbq_len) {
 		cqicb->flags |= FLAGS_LL;	/* Load lbq values */
-		*((u64 *) rx_ring->lbq_base_indirect) = rx_ring->lbq_base_dma;
+		tmp = (u64)rx_ring->lbq_base_dma;;
+		*((__le64 *) rx_ring->lbq_base_indirect) = cpu_to_le64(tmp);
 		cqicb->lbq_addr =
 		    cpu_to_le64(rx_ring->lbq_base_indirect_dma);
 		bq_len = (rx_ring->lbq_buf_size == 65536) ? 0 :
@@ -2521,25 +2472,26 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
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
-		*((u64 *) rx_ring->sbq_base_indirect) = rx_ring->sbq_base_dma;
+		tmp = (u64)rx_ring->sbq_base_dma;;
+		*((__le64 *) rx_ring->sbq_base_indirect) = cpu_to_le64(tmp);
 		cqicb->sbq_addr =
 		    cpu_to_le64(rx_ring->sbq_base_indirect_dma);
 		cqicb->sbq_buf_size =
-		    cpu_to_le16(((rx_ring->sbq_buf_size / 2) + 8) & 0xfffffff8);
+		    cpu_to_le16((u16)(rx_ring->sbq_buf_size/2));
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
@@ -2592,17 +2544,6 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
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
 
@@ -3183,7 +3124,7 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 	ql_disable_interrupts(qdev);
 
 	ql_tx_ring_clean(qdev);
-
+	ql_free_rx_buffers(qdev);
 	status = ql_adapter_reset(qdev);
 	if (status)
 		QPRINTK(qdev, IFDOWN, ERR, "reset(func #%d) FAILED!\n",
@@ -3201,6 +3142,7 @@ static int ql_adapter_up(struct ql_adapter *qdev)
 		goto err_init;
 	}
 	set_bit(QL_ADAPTER_UP, &qdev->flags);
+	ql_alloc_rx_buffers(qdev);
 	ql_enable_all_completion_interrupts(qdev);
 	if ((ql_read32(qdev, STS) & qdev->port_init))
 		ql_link_on(qdev);
-- 
1.6.0.2

