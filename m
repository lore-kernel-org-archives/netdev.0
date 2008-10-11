From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 3/6] [NET-NEXT]qlge: Cleanup and consolidate rx buffer alloc/free.
Date: Sat, 11 Oct 2008 10:17:10 -0700
Message-ID: <1223745433-26440-3-git-send-email-ron.mercer@qlogic.com>
References: <20081011171614.GA26384@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:13301 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760559AbYJKRRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 13:17:16 -0400
In-Reply-To: <20081011171614.GA26384@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove separate path used to allocate rx buffers during the
open call.  Now we use the same path utilized at run time.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |   11 +-
 drivers/net/qlge/qlge_main.c |  314 ++++++++++++++++--------------------------
 2 files changed, 125 insertions(+), 200 deletions(-)
 mode change 100644 => 100755 drivers/net/qlge/qlge.h
 mode change 100644 => 100755 drivers/net/qlge/qlge_main.c

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
old mode 100644
new mode 100755
index cc246f8..d0454db
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -31,8 +31,9 @@
 #define QLGE_DEVICE_ID1    0x8012
 #define QLGE_DEVICE_ID   0x8000
 
-#define MAX_RX_RINGS 128
-#define MAX_TX_RINGS 128
+#define MAX_CPUS 8
+#define MAX_TX_RINGS MAX_CPUS
+#define MAX_RX_RINGS ((MAX_CPUS * 2) + 1)
 
 #define NUM_TX_RING_ENTRIES	256
 #define NUM_RX_RING_ENTRIES	256
@@ -1412,10 +1413,10 @@ struct ql_adapter {
 	int rx_ring_count;
 	int ring_mem_size;
 	void *ring_mem;
-	struct rx_ring *rx_ring;
-	int rx_csum;
-	struct tx_ring *tx_ring;
+	struct rx_ring rx_ring[MAX_RX_RINGS];
+	struct tx_ring tx_ring[MAX_TX_RINGS];
 	u32 default_rx_queue;
+	int rx_csum;
 
 	u16 rx_coalesce_usecs;	/* cqicb->int_delay */
 	u16 rx_max_coalesced_frames;	/* cqicb->pkt_int_delay */
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
old mode 100644
new mode 100755
index 1cce8dc..c257546
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -59,7 +59,7 @@ static const u32 default_msg =
     NETIF_MSG_RX_ERR |
     NETIF_MSG_TX_ERR |
     NETIF_MSG_TX_QUEUED |
-    NETIF_MSG_INTR | NETIF_MSG_TX_DONE | 
+    NETIF_MSG_INTR | NETIF_MSG_TX_DONE |
 /* NETIF_MSG_RX_STATUS | */
 /* NETIF_MSG_PKTDATA | */
     NETIF_MSG_HW | NETIF_MSG_WOL | 0;
@@ -584,14 +584,14 @@ u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
 	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr)) {
 		ql_write32(qdev, INTR_EN,
 			   qdev->intr_context[intr].intr_en_mask);
-       	var = ql_read32(qdev, STS);
+		var = ql_read32(qdev, STS);
 	} else {
-		unsigned long hw_flags=0;
+		unsigned long hw_flags = 0;
 		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 		if (atomic_dec_and_test(&qdev->intr_context[intr].irq_cnt)) {
 			ql_write32(qdev, INTR_EN,
 				   qdev->intr_context[intr].intr_en_mask);
-       		var = ql_read32(qdev, STS);
+			var = ql_read32(qdev, STS);
 		}
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 	}
@@ -607,12 +607,12 @@ static u32 ql_disable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
 	else {
 		unsigned long hw_flags = 0;
 		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
-              if (!atomic_read(&qdev->intr_context[intr].irq_cnt)) {
+		if (!atomic_read(&qdev->intr_context[intr].irq_cnt)) {
 		       ql_write32(qdev, INTR_EN,
-			          qdev->intr_context[intr].intr_dis_mask);
-       		var = ql_read32(qdev, STS);
+				qdev->intr_context[intr].intr_dis_mask);
+			var = ql_read32(qdev, STS);
 	       }
-       	atomic_inc(&qdev->intr_context[intr].irq_cnt);
+		atomic_inc(&qdev->intr_context[intr].irq_cnt);
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
        }
 exit:
@@ -627,7 +627,7 @@ static void ql_enable_all_completion_interrupts(struct ql_adapter *qdev)
 		 * and enables only if the result is zero.
 		 * So we precharge it here.
 		 */
-		if (unlikely(!test_bit(QL_MSIX_ENABLED, &qdev->flags) || i==0))
+		if (unlikely(!test_bit(QL_MSIX_ENABLED, &qdev->flags) || i == 0))
 			atomic_set(&qdev->intr_context[i].irq_cnt, 1);
 		ql_enable_completion_interrupt(qdev, i);
 	}
@@ -864,9 +864,11 @@ static void ql_write_cq_idx(struct rx_ring *rx_ring)
 /* Process (refill) a large buffer queue. */
 static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
-	int clean_idx = rx_ring->lbq_clean_idx;
+	u32 clean_idx = rx_ring->lbq_clean_idx;
+	u32 start_idx = clean_idx;
 	struct bq_desc *lbq_desc;
 	struct bq_element *bq;
+	struct page *page;
 	u64 map;
 	int i;
 
@@ -881,14 +883,15 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 				QPRINTK(qdev, RX_STATUS, DEBUG,
 					"lbq: getting new page for index %d.\n",
 					lbq_desc->index);
-				lbq_desc->p.lbq_page = alloc_page(GFP_ATOMIC);
-				if (lbq_desc->p.lbq_page == NULL) {
+				page = alloc_page(GFP_ATOMIC);
+				if (page == NULL) {
 					QPRINTK(qdev, RX_STATUS, ERR,
 						"Couldn't get a page.\n");
 					return;
 				}
+				lbq_desc->p.lbq_page = page;
 				map = pci_map_page(qdev->pdev,
-						   lbq_desc->p.lbq_page,
+						   page,
 						   0, PAGE_SIZE,
 						   PCI_DMA_FROMDEVICE);
 				if (pci_dma_mapping_error(qdev->pdev, map)) {
@@ -898,10 +901,8 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 				}
 				pci_unmap_addr_set(lbq_desc, mapaddr, map);
 				pci_unmap_len_set(lbq_desc, maplen, PAGE_SIZE);
-				bq->addr_lo =	/*lbq_desc->addr_lo = */
-				    cpu_to_le32(map);
-				bq->addr_hi =	/*lbq_desc->addr_hi = */
-				    cpu_to_le32(map >> 32);
+				bq->addr_lo = cpu_to_le32(map);
+				bq->addr_hi =	cpu_to_le32(map >> 32);
 			}
 			clean_idx++;
 			if (clean_idx == rx_ring->lbq_len)
@@ -912,21 +913,26 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		rx_ring->lbq_prod_idx += 16;
 		if (rx_ring->lbq_prod_idx == rx_ring->lbq_len)
 			rx_ring->lbq_prod_idx = 0;
+		rx_ring->lbq_free_cnt -= 16;
+	}
+
+	if (start_idx != clean_idx) {
 		QPRINTK(qdev, RX_STATUS, DEBUG,
 			"lbq: updating prod idx = %d.\n",
 			rx_ring->lbq_prod_idx);
 		ql_write_db_reg(rx_ring->lbq_prod_idx,
 				rx_ring->lbq_prod_idx_db_reg);
-		rx_ring->lbq_free_cnt -= 16;
 	}
 }
 
 /* Process (refill) a small buffer queue. */
 static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
-	int clean_idx = rx_ring->sbq_clean_idx;
+	u32 clean_idx = rx_ring->sbq_clean_idx;
+	u32 start_idx = clean_idx;
 	struct bq_desc *sbq_desc;
 	struct bq_element *bq;
+	struct sk_buff *skb;
 	u64 map;
 	int i;
 
@@ -941,20 +947,26 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 				QPRINTK(qdev, RX_STATUS, DEBUG,
 					"sbq: getting new skb for index %d.\n",
 					sbq_desc->index);
-				sbq_desc->p.skb =
+				skb =
 				    netdev_alloc_skb(qdev->ndev,
 						     rx_ring->sbq_buf_size);
-				if (sbq_desc->p.skb == NULL) {
+				if (skb == NULL) {
 					QPRINTK(qdev, PROBE, ERR,
 						"Couldn't get an skb.\n");
 					rx_ring->sbq_clean_idx = clean_idx;
 					return;
 				}
-				skb_reserve(sbq_desc->p.skb, QLGE_SB_PAD);
+				sbq_desc->p.skb = skb;
+				skb_reserve(skb, QLGE_SB_PAD);
 				map = pci_map_single(qdev->pdev,
-						     sbq_desc->p.skb->data,
+						     skb->data,
 						     rx_ring->sbq_buf_size /
 						     2, PCI_DMA_FROMDEVICE);
+				if (pci_dma_mapping_error(qdev->pdev, map)) {
+					QPRINTK(qdev, IFUP, ERR, "PCI mapping failed.\n");
+					rx_ring->sbq_clean_idx = clean_idx;
+					return;
+				}
 				pci_unmap_addr_set(sbq_desc, mapaddr, map);
 				pci_unmap_len_set(sbq_desc, maplen,
 						  rx_ring->sbq_buf_size / 2);
@@ -970,13 +982,15 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		rx_ring->sbq_prod_idx += 16;
 		if (rx_ring->sbq_prod_idx == rx_ring->sbq_len)
 			rx_ring->sbq_prod_idx = 0;
+		rx_ring->sbq_free_cnt -= 16;
+	}
+
+	if (start_idx != clean_idx) {
 		QPRINTK(qdev, RX_STATUS, DEBUG,
 			"sbq: updating prod idx = %d.\n",
 			rx_ring->sbq_prod_idx);
 		ql_write_db_reg(rx_ring->sbq_prod_idx,
 				rx_ring->sbq_prod_idx_db_reg);
-
-		rx_ring->sbq_free_cnt -= 16;
 	}
 }
 
@@ -1745,7 +1759,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	int work_done = 0;
 
 	spin_lock(&qdev->hw_lock);
-	if(atomic_read(&qdev->intr_context[0].irq_cnt)) {
+	if (atomic_read(&qdev->intr_context[0].irq_cnt)) {
 		QPRINTK(qdev, INTR, DEBUG, "Shared Interrupt, Not ours!\n");
 		spin_unlock(&qdev->hw_lock);
 		return IRQ_NONE;
@@ -2036,7 +2050,7 @@ static void ql_free_tx_resources(struct ql_adapter *qdev,
 				    tx_ring->wq_base, tx_ring->wq_base_dma);
 		tx_ring->wq_base = NULL;
 	}
-	kfree(tx_ring->q);
+	vfree(tx_ring->q);
 	tx_ring->q = NULL;
 }
 
@@ -2053,7 +2067,7 @@ static int ql_alloc_tx_resources(struct ql_adapter *qdev,
 		return -ENOMEM;
 	}
 	tx_ring->q =
-	    kmalloc(tx_ring->wq_len * sizeof(struct tx_ring_desc), GFP_KERNEL);
+	    vmalloc(tx_ring->wq_len * sizeof(struct tx_ring_desc));
 	if (tx_ring->q == NULL)
 		goto err;
 
@@ -2071,7 +2085,7 @@ void ql_free_lbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 
 	for (i = 0; i < rx_ring->lbq_len; i++) {
 		lbq_desc = &rx_ring->lbq[i];
-		if (lbq_desc->p.lbq_page) {
+		if (lbq_desc && lbq_desc->p.lbq_page) {
 			pci_unmap_page(qdev->pdev,
 				       pci_unmap_addr(lbq_desc, mapaddr),
 				       pci_unmap_len(lbq_desc, maplen),
@@ -2080,53 +2094,9 @@ void ql_free_lbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 			put_page(lbq_desc->p.lbq_page);
 			lbq_desc->p.lbq_page = NULL;
 		}
-		lbq_desc->bq->addr_lo = 0;
-		lbq_desc->bq->addr_hi = 0;
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
-	struct bq_element *bq = rx_ring->lbq_base;
-
-	for (i = 0; i < rx_ring->lbq_len; i++) {
-		lbq_desc = &rx_ring->lbq[i];
-		memset(lbq_desc, 0, sizeof(lbq_desc));
-		lbq_desc->bq = bq;
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
-			bq->addr_lo = cpu_to_le32(map);
-			bq->addr_hi = cpu_to_le32(map >> 32);
-		}
-		bq++;
-	}
-	return 0;
-mem_error:
-	ql_free_lbq_buffers(qdev, rx_ring);
-	return -ENOMEM;
-}
-
 void ql_free_sbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
 	int i;
@@ -2134,11 +2104,7 @@ void ql_free_sbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 
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
@@ -2146,74 +2112,85 @@ void ql_free_sbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 			dev_kfree_skb(sbq_desc->p.skb);
 			sbq_desc->p.skb = NULL;
 		}
-		if (sbq_desc->bq == NULL) {
-			QPRINTK(qdev, IFUP, ERR, "sbq_desc->bq %d is NULL.\n",
-				i);
+	}
+}
+
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
+		if (qdev == NULL) {
+			printk(KERN_ERR"%s: Got NULL qdev pointer.\n", __func__);
+			return;
+		}
+		if (rx_ring == NULL) {
+			printk(KERN_ERR"%s: Got NULL pointer at index %d of %d!\n", __func__, i, qdev->rx_ring_count);
 			return;
 		}
-		sbq_desc->bq->addr_lo = 0;
-		sbq_desc->bq->addr_hi = 0;
+		if (rx_ring->type != TX_Q) {
+			QL_DUMP_RX_RING(rx_ring);
+			ql_update_buffer_queues(qdev, rx_ring);
+		}
 	}
 }
 
-/* Allocate and map an skb for each element of the sbq. */
-static int ql_alloc_sbq_buffers(struct ql_adapter *qdev,
+static void ql_init_lbq_ring(struct ql_adapter *qdev,
+				struct rx_ring *rx_ring)
+{
+	int i;
+	struct bq_desc *sbq_desc;
+	struct bq_element *bq = rx_ring->lbq_base;
+
+	memset(rx_ring->lbq, 0, rx_ring->lbq_len * sizeof(struct bq_desc));
+	for (i = 0; i < rx_ring->lbq_len; i++) {
+		sbq_desc = &rx_ring->lbq[i];
+		memset(sbq_desc, 0, sizeof(sbq_desc));
+		sbq_desc->index = i;
+		sbq_desc->bq = bq;
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
 	struct bq_element *bq = rx_ring->sbq_base;
 
+	memset(rx_ring->sbq, 0, rx_ring->sbq_len * sizeof(struct bq_desc));
 	for (i = 0; i < rx_ring->sbq_len; i++) {
 		sbq_desc = &rx_ring->sbq[i];
 		memset(sbq_desc, 0, sizeof(sbq_desc));
 		sbq_desc->index = i;
 		sbq_desc->bq = bq;
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
-		bq->addr_lo =	/*sbq_desc->addr_lo = */
-		    cpu_to_le32(map);
-		bq->addr_hi =	/*sbq_desc->addr_hi = */
-		    cpu_to_le32(map >> 32);
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
+	if (rx_ring->sbq)
 		ql_free_sbq_buffers(qdev, rx_ring);
-	if (rx_ring->lbq_len)
+	if (rx_ring->lbq)
 		ql_free_lbq_buffers(qdev, rx_ring);
 
 	/* Free the small buffer queue. */
@@ -2225,7 +2202,7 @@ static void ql_free_rx_resources(struct ql_adapter *qdev,
 	}
 
 	/* Free the small buffer queue control blocks. */
-	kfree(rx_ring->sbq);
+	vfree(rx_ring->sbq);
 	rx_ring->sbq = NULL;
 
 	/* Free the large buffer queue. */
@@ -2237,7 +2214,7 @@ static void ql_free_rx_resources(struct ql_adapter *qdev,
 	}
 
 	/* Free the large buffer queue control blocks. */
-	kfree(rx_ring->lbq);
+	vfree(rx_ring->lbq);
 	rx_ring->lbq = NULL;
 
 	/* Free the rx queue. */
@@ -2285,19 +2262,13 @@ static int ql_alloc_rx_resources(struct ql_adapter *qdev,
 		 * Allocate small buffer queue control blocks.
 		 */
 		rx_ring->sbq =
-		    kmalloc(rx_ring->sbq_len * sizeof(struct bq_desc),
-			    GFP_KERNEL);
+		    vmalloc(rx_ring->sbq_len * sizeof(struct bq_desc));
 		if (rx_ring->sbq == NULL) {
 			QPRINTK(qdev, IFUP, ERR,
 				"Small buffer queue control block allocation failed.\n");
 			goto err_mem;
 		}
-
-		if (ql_alloc_sbq_buffers(qdev, rx_ring)) {
-			QPRINTK(qdev, IFUP, ERR,
-				"Small buffer allocation failed.\n");
-			goto err_mem;
-		}
+		ql_init_sbq_ring(qdev, rx_ring);
 	}
 
 	if (rx_ring->lbq_len) {
@@ -2317,22 +2288,13 @@ static int ql_alloc_rx_resources(struct ql_adapter *qdev,
 		 * Allocate large buffer queue control blocks.
 		 */
 		rx_ring->lbq =
-		    kmalloc(rx_ring->lbq_len * sizeof(struct bq_desc),
-			    GFP_KERNEL);
+		    vmalloc(rx_ring->lbq_len * sizeof(struct bq_desc));
 		if (rx_ring->lbq == NULL) {
 			QPRINTK(qdev, IFUP, ERR,
 				"Large buffer queue control block allocation failed.\n");
 			goto err_mem;
 		}
-
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
@@ -2342,7 +2304,7 @@ err_mem:
 	return -ENOMEM;
 }
 
-static void ql_tx_ring_clean(struct ql_adapter *qdev)
+static void ql_clean_tx_rings(struct ql_adapter *qdev)
 {
 	struct tx_ring *tx_ring;
 	struct tx_ring_desc *tx_ring_desc;
@@ -2370,28 +2332,6 @@ static void ql_tx_ring_clean(struct ql_adapter *qdev)
 	}
 }
 
-static void ql_free_ring_cb(struct ql_adapter *qdev)
-{
-	kfree(qdev->ring_mem);
-}
-
-static int ql_alloc_ring_cb(struct ql_adapter *qdev)
-{
-	/* Allocate space for tx/rx ring control blocks. */
-	qdev->ring_mem_size =
-	    (qdev->tx_ring_count * sizeof(struct tx_ring)) +
-	    (qdev->rx_ring_count * sizeof(struct rx_ring));
-	qdev->ring_mem = kmalloc(qdev->ring_mem_size, GFP_KERNEL);
-	if (qdev->ring_mem == NULL) {
-		return -ENOMEM;
-	} else {
-		qdev->rx_ring = qdev->ring_mem;
-		qdev->tx_ring = qdev->ring_mem +
-		    (qdev->rx_ring_count * sizeof(struct rx_ring));
-	}
-	return 0;
-}
-
 static void ql_free_mem_resources(struct ql_adapter *qdev)
 {
 	int i;
@@ -2503,10 +2443,10 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		cqicb->lbq_buf_size = cpu_to_le32(rx_ring->lbq_buf_size);
 		bq_len = (u16) rx_ring->lbq_len;
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
@@ -2519,10 +2459,10 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		    cpu_to_le16(((rx_ring->sbq_buf_size / 2) + 8) & 0xfffffff8);
 		bq_len = (u16) rx_ring->sbq_len;
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
@@ -2576,16 +2516,6 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		return err;
 	}
 	QPRINTK(qdev, IFUP, INFO, "Successfully loaded CQICB.\n");
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
 
@@ -3172,7 +3102,8 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 
 	ql_disable_interrupts(qdev);
 
-	ql_tx_ring_clean(qdev);
+	ql_clean_tx_rings(qdev);
+	ql_free_rx_buffers(qdev);
 
 	spin_lock(&qdev->hw_lock);
 	status = ql_adapter_reset(qdev);
@@ -3196,6 +3127,7 @@ static int ql_adapter_up(struct ql_adapter *qdev)
 	}
 	spin_unlock(&qdev->hw_lock);
 	set_bit(QL_ADAPTER_UP, &qdev->flags);
+	ql_alloc_rx_buffers(qdev);
 	ql_enable_interrupts(qdev);
 	ql_enable_all_completion_interrupts(qdev);
 	if ((ql_read32(qdev, STS) & qdev->port_init)) {
@@ -3266,11 +3198,10 @@ static int qlge_close(struct net_device *ndev)
 		msleep(1);
 	ql_adapter_down(qdev);
 	ql_release_adapter_resources(qdev);
-	ql_free_ring_cb(qdev);
 	return 0;
 }
 
-static int ql_configure_rings(struct ql_adapter *qdev)
+static void ql_configure_rings(struct ql_adapter *qdev)
 {
 	int i;
 	struct rx_ring *rx_ring;
@@ -3292,8 +3223,8 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 	 * This limitation can be removed when requested.
 	 */
 
-	if (cpu_cnt > 8)
-		cpu_cnt = 8;
+	if (cpu_cnt > MAX_CPUS)
+		cpu_cnt = MAX_CPUS;
 
 	/*
 	 * rx_ring[0] is always the default queue.
@@ -3312,8 +3243,6 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 	 * completion handler rx_rings.
 	 */
 	qdev->rx_ring_count = qdev->tx_ring_count + qdev->rss_ring_count + 1;
-	if (ql_alloc_ring_cb(qdev))
-		return -ENOMEM;
 
 	for (i = 0; i < qdev->tx_ring_count; i++) {
 		tx_ring = &qdev->tx_ring[i];
@@ -3387,7 +3316,6 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 			rx_ring->type = RX_Q;
 		}
 	}
-	return 0;
 }
 
 static int qlge_open(struct net_device *ndev)
@@ -3395,9 +3323,7 @@ static int qlge_open(struct net_device *ndev)
 	int err = 0;
 	struct ql_adapter *qdev = netdev_priv(ndev);
 
-	err = ql_configure_rings(qdev);
-	if (err)
-		return err;
+	ql_configure_rings(qdev);
 
 	err = ql_get_adapter_resources(qdev);
 	if (err)
@@ -3411,8 +3337,6 @@ static int qlge_open(struct net_device *ndev)
 
 error_up:
 	ql_release_adapter_resources(qdev);
-	ql_free_ring_cb(qdev);
-	QL_DUMP_ALL(qdev);
 	return err;
 }
 
-- 
1.6.0

