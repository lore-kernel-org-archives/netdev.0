From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 07/13] ixgbe: Implement Tx Head Writeback
Date: Tue, 26 Aug 2008 04:27:13 -0700
Message-ID: <20080826112713.15787.19453.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:39276 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754434AbYHZL1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:27:14 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099820rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:27:13 -0700 (PDT)
In-Reply-To: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Enable Tx Head Writeback in the hardware.  This helps performance by
removing adapter writebacks to descriptors on transmit completion.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |  198 +++++++++++++++++++++++-----------------
 1 files changed, 113 insertions(+), 85 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index cba7a38..95d0041 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -148,8 +148,7 @@ static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
 					     *tx_buffer_info)
 {
 	if (tx_buffer_info->dma) {
-		pci_unmap_page(adapter->pdev,
-			       tx_buffer_info->dma,
+		pci_unmap_page(adapter->pdev, tx_buffer_info->dma,
 			       tx_buffer_info->length, PCI_DMA_TODEVICE);
 		tx_buffer_info->dma = 0;
 	}
@@ -162,32 +161,35 @@ static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
 
 static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
 				       struct ixgbe_ring *tx_ring,
-				       unsigned int eop,
-				       union ixgbe_adv_tx_desc *eop_desc)
+				       unsigned int eop)
 {
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 head, tail;
+
 	/* Detect a transmit hang in hardware, this serializes the
-	 * check with the clearing of time_stamp and movement of i */
+	 * check with the clearing of time_stamp and movement of eop */
+	head = IXGBE_READ_REG(hw, tx_ring->head);
+	tail = IXGBE_READ_REG(hw, tx_ring->tail);
 	adapter->detect_tx_hung = false;
-	if (tx_ring->tx_buffer_info[eop].dma &&
+	if ((head != tail) &&
+	    tx_ring->tx_buffer_info[eop].time_stamp &&
 	    time_after(jiffies, tx_ring->tx_buffer_info[eop].time_stamp + HZ) &&
 	    !(IXGBE_READ_REG(&adapter->hw, IXGBE_TFCS) & IXGBE_TFCS_TXOFF)) {
 		/* detected Tx unit hang */
+		union ixgbe_adv_tx_desc *tx_desc;
+		tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
 		DPRINTK(DRV, ERR, "Detected Tx Unit Hang\n"
-			"  TDH                  <%x>\n"
-			"  TDT                  <%x>\n"
+			"  Tx Queue             <%d>\n"
+			"  TDH, TDT             <%x>, <%x>\n"
 			"  next_to_use          <%x>\n"
 			"  next_to_clean        <%x>\n"
 			"tx_buffer_info[next_to_clean]\n"
 			"  time_stamp           <%lx>\n"
-			"  next_to_watch        <%x>\n"
-			"  jiffies              <%lx>\n"
-			"  next_to_watch.status <%x>\n",
-			readl(adapter->hw.hw_addr + tx_ring->head),
-			readl(adapter->hw.hw_addr + tx_ring->tail),
-			tx_ring->next_to_use,
-			tx_ring->next_to_clean,
-			tx_ring->tx_buffer_info[eop].time_stamp,
-			eop, jiffies, eop_desc->wb.status);
+			"  jiffies              <%lx>\n",
+			tx_ring->queue_index,
+			head, tail,
+			tx_ring->next_to_use, eop,
+			tx_ring->tx_buffer_info[eop].time_stamp, jiffies);
 		return true;
 	}
 
@@ -203,65 +205,75 @@ static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
 #define DESC_NEEDED (TXD_USE_COUNT(IXGBE_MAX_DATA_PER_TXD) /* skb->data */ + \
 	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1)	/* for context */
 
+#define GET_TX_HEAD_FROM_RING(ring) (\
+	*(volatile u32 *) \
+	((union ixgbe_adv_tx_desc *)(ring)->desc + (ring)->count))
+static void ixgbe_tx_timeout(struct net_device *netdev);
+
 /**
  * ixgbe_clean_tx_irq - Reclaim resources after transmit completes
  * @adapter: board private structure
+ * @tx_ring: tx ring to clean
  **/
 static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
-				    struct ixgbe_ring *tx_ring)
+                               struct ixgbe_ring *tx_ring)
 {
-	struct net_device *netdev = adapter->netdev;
-	union ixgbe_adv_tx_desc *tx_desc, *eop_desc;
+	union ixgbe_adv_tx_desc *tx_desc;
 	struct ixgbe_tx_buffer *tx_buffer_info;
-	unsigned int i, eop;
-	bool cleaned = false;
-	unsigned int total_tx_bytes = 0, total_tx_packets = 0;
+	struct net_device *netdev = adapter->netdev;
+	struct sk_buff *skb;
+	unsigned int i;
+	u32 head, oldhead;
+	unsigned int count = 0;
+	unsigned int total_bytes = 0, total_packets = 0;
 
+	rmb();
+	head = GET_TX_HEAD_FROM_RING(tx_ring);
+	head = le32_to_cpu(head);
 	i = tx_ring->next_to_clean;
-	eop = tx_ring->tx_buffer_info[i].next_to_watch;
-	eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
-	while (eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)) {
-		cleaned = false;
-		while (!cleaned) {
+	while (1) {
+		while (i != head) {
 			tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
 			tx_buffer_info = &tx_ring->tx_buffer_info[i];
-			cleaned = (i == eop);
+			skb = tx_buffer_info->skb;
 
-			tx_ring->stats.bytes += tx_buffer_info->length;
-			if (cleaned) {
-				struct sk_buff *skb = tx_buffer_info->skb;
+			if (skb) {
 				unsigned int segs, bytecount;
+
+				/* gso_segs is currently only valid for tcp */
 				segs = skb_shinfo(skb)->gso_segs ?: 1;
 				/* multiply data chunks by size of headers */
 				bytecount = ((segs - 1) * skb_headlen(skb)) +
-					    skb->len;
-				total_tx_packets += segs;
-				total_tx_bytes += bytecount;
+				            skb->len;
+				total_packets += segs;
+				total_bytes += bytecount;
 			}
+
 			ixgbe_unmap_and_free_tx_resource(adapter,
-							 tx_buffer_info);
-			tx_desc->wb.status = 0;
+			                                 tx_buffer_info);
 
 			i++;
 			if (i == tx_ring->count)
 				i = 0;
-		}
-
-		tx_ring->stats.packets++;
-
-		eop = tx_ring->tx_buffer_info[i].next_to_watch;
-		eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
-
-		/* weight of a sort for tx, avoid endless transmit cleanup */
-		if (total_tx_packets >= tx_ring->work_limit)
-			break;
-	}
 
+			count++;
+			if (count == tx_ring->count)
+				goto done_cleaning;
+		}
+		oldhead = head;
+		rmb();
+		head = GET_TX_HEAD_FROM_RING(tx_ring);
+		head = le32_to_cpu(head);
+		if (head == oldhead)
+			goto done_cleaning;
+	} /* while (1) */
+
+done_cleaning:
 	tx_ring->next_to_clean = i;
 
 #define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
-	if (total_tx_packets && netif_carrier_ok(netdev) &&
-	    (IXGBE_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD)) {
+	if (unlikely(count && netif_carrier_ok(netdev) &&
+	             (IXGBE_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))) {
 		/* Make sure that anybody stopping the queue after this
 		 * sees the new next_to_clean.
 		 */
@@ -269,23 +281,32 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 		if (__netif_subqueue_stopped(netdev, tx_ring->queue_index) &&
 		    !test_bit(__IXGBE_DOWN, &adapter->state)) {
 			netif_wake_subqueue(netdev, tx_ring->queue_index);
-			adapter->restart_queue++;
+			++adapter->restart_queue;
 		}
 	}
 
-	if (adapter->detect_tx_hung)
-		if (ixgbe_check_tx_hang(adapter, tx_ring, eop, eop_desc))
-			netif_stop_subqueue(netdev, tx_ring->queue_index);
+	if (adapter->detect_tx_hung) {
+		if (ixgbe_check_tx_hang(adapter, tx_ring, i)) {
+			/* schedule immediate reset if we believe we hung */
+			DPRINTK(PROBE, INFO,
+			        "tx hang %d detected, resetting adapter\n",
+			        adapter->tx_timeout_count + 1);
+			ixgbe_tx_timeout(adapter->netdev);
+		}
+	}
 
-	if (total_tx_packets >= tx_ring->work_limit)
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, tx_ring->eims_value);
+	/* re-arm the interrupt */
+	if ((total_packets >= tx_ring->work_limit) ||
+	    (count == tx_ring->count))
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, tx_ring->v_idx);
 
-	tx_ring->total_bytes += total_tx_bytes;
-	tx_ring->total_packets += total_tx_packets;
-	adapter->net_stats.tx_bytes += total_tx_bytes;
-	adapter->net_stats.tx_packets += total_tx_packets;
-	cleaned = total_tx_packets ? true : false;
-	return cleaned;
+	tx_ring->total_bytes += total_bytes;
+	tx_ring->total_packets += total_packets;
+	tx_ring->stats.bytes += total_bytes;
+	tx_ring->stats.packets += total_packets;
+	adapter->net_stats.tx_bytes += total_bytes;
+	adapter->net_stats.tx_packets += total_packets;
+	return (total_packets ? true : false);
 }
 
 #ifdef CONFIG_DCA
@@ -1344,19 +1365,24 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
  **/
 static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 {
-	u64 tdba;
+	u64 tdba, tdwba;
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 i, j, tdlen, txctrl;
 
 	/* Setup the HW Tx Head and Tail descriptor pointers */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		j = adapter->tx_ring[i].reg_idx;
-		tdba = adapter->tx_ring[i].dma;
-		tdlen = adapter->tx_ring[i].count *
-			sizeof(union ixgbe_adv_tx_desc);
+		struct ixgbe_ring *ring = &adapter->tx_ring[i];
+		j = ring->reg_idx;
+		tdba = ring->dma;
+		tdlen = ring->count * sizeof(union ixgbe_adv_tx_desc);
 		IXGBE_WRITE_REG(hw, IXGBE_TDBAL(j),
-				(tdba & DMA_32BIT_MASK));
+		                (tdba & DMA_32BIT_MASK));
 		IXGBE_WRITE_REG(hw, IXGBE_TDBAH(j), (tdba >> 32));
+		tdwba = ring->dma +
+		        (ring->count * sizeof(union ixgbe_adv_tx_desc));
+		tdwba |= IXGBE_TDWBAL_HEAD_WB_ENABLE;
+		IXGBE_WRITE_REG(hw, IXGBE_TDWBAL(j), tdwba & DMA_32BIT_MASK);
+		IXGBE_WRITE_REG(hw, IXGBE_TDWBAH(j), (tdwba >> 32));
 		IXGBE_WRITE_REG(hw, IXGBE_TDLEN(j), tdlen);
 		IXGBE_WRITE_REG(hw, IXGBE_TDH(j), 0);
 		IXGBE_WRITE_REG(hw, IXGBE_TDT(j), 0);
@@ -1365,9 +1391,9 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 		/* Disable Tx Head Writeback RO bit, since this hoses
 		 * bookkeeping if things aren't delivered in order.
 		 */
-		txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
+		txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(j));
 		txctrl &= ~IXGBE_DCA_TXCTRL_TX_WB_RO_EN;
-		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), txctrl);
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(j), txctrl);
 	}
 }
 
@@ -1775,6 +1801,8 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		j = adapter->tx_ring[i].reg_idx;
 		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
+		/* enable WTHRESH=8 descriptors, to encourage burst writeback */
+		txdctl |= (8 << 16);
 		txdctl |= IXGBE_TXDCTL_ENABLE;
 		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j), txdctl);
 	}
@@ -2487,38 +2515,38 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
  * Return 0 on success, negative on failure
  **/
 int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
-			     struct ixgbe_ring *tx_ring)
+                             struct ixgbe_ring *tx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int size;
 
 	size = sizeof(struct ixgbe_tx_buffer) * tx_ring->count;
 	tx_ring->tx_buffer_info = vmalloc(size);
-	if (!tx_ring->tx_buffer_info) {
-		DPRINTK(PROBE, ERR,
-		"Unable to allocate memory for the transmit descriptor ring\n");
-		return -ENOMEM;
-	}
+	if (!tx_ring->tx_buffer_info)
+		goto err;
 	memset(tx_ring->tx_buffer_info, 0, size);
 
 	/* round up to nearest 4K */
-	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc);
+	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc) +
+	                sizeof(u32);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
 
 	tx_ring->desc = pci_alloc_consistent(pdev, tx_ring->size,
 	                                     &tx_ring->dma);
-	if (!tx_ring->desc) {
-		vfree(tx_ring->tx_buffer_info);
-		DPRINTK(PROBE, ERR,
-			"Memory allocation failed for the tx desc ring\n");
-		return -ENOMEM;
-	}
+	if (!tx_ring->desc)
+		goto err;
 
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
 	tx_ring->work_limit = tx_ring->count;
-
 	return 0;
+
+err:
+	vfree(tx_ring->tx_buffer_info);
+	tx_ring->tx_buffer_info = NULL;
+	DPRINTK(PROBE, ERR, "Unable to allocate memory for the transmit "
+	                    "descriptor ring\n");
+	return -ENOMEM;
 }
 
 /**
@@ -2581,7 +2609,7 @@ alloc_failed:
  * Free all transmit software resources
  **/
 static void ixgbe_free_tx_resources(struct ixgbe_adapter *adapter,
-				    struct ixgbe_ring *tx_ring)
+                                    struct ixgbe_ring *tx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 

