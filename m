From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 05/13] ixgbe: Cleanup references to Tx and Rx rings
	to becommon across the driver
Date: Tue, 26 Aug 2008 04:27:08 -0700
Message-ID: <20080826112708.15787.40667.stgit@jtkirshe-mobile.jf.intel.com>
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
Received: from rv-out-0506.google.com ([209.85.198.232]:37405 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754603AbYHZL1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:27:08 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099738rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:27:08 -0700 (PDT)
In-Reply-To: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Cleanup all the different references to the Tx ring and Rx ring structures
and make them common across the driver.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |  158 +++++++++++++++++++---------------------
 1 files changed, 77 insertions(+), 81 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 50737cc..b5a9b9d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -290,38 +290,38 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 
 #ifdef CONFIG_DCA
 static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *rxr)
+				struct ixgbe_ring *rx_ring)
 {
 	u32 rxctrl;
 	int cpu = get_cpu();
-	int q = rxr - adapter->rx_ring;
+	int q = rx_ring - adapter->rx_ring;
 
-	if (rxr->cpu != cpu) {
+	if (rx_ring->cpu != cpu) {
 		rxctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_DCA_RXCTRL(q));
 		rxctrl &= ~IXGBE_DCA_RXCTRL_CPUID_MASK;
 		rxctrl |= dca_get_tag(cpu);
 		rxctrl |= IXGBE_DCA_RXCTRL_DESC_DCA_EN;
 		rxctrl |= IXGBE_DCA_RXCTRL_HEAD_DCA_EN;
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_RXCTRL(q), rxctrl);
-		rxr->cpu = cpu;
+		rx_ring->cpu = cpu;
 	}
 	put_cpu();
 }
 
 static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
-				struct ixgbe_ring *txr)
+				struct ixgbe_ring *tx_ring)
 {
 	u32 txctrl;
 	int cpu = get_cpu();
-	int q = txr - adapter->tx_ring;
+	int q = tx_ring - adapter->tx_ring;
 
-	if (txr->cpu != cpu) {
+	if (tx_ring->cpu != cpu) {
 		txctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_DCA_TXCTRL(q));
 		txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK;
 		txctrl |= dca_get_tag(cpu);
 		txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_TXCTRL(q), txctrl);
-		txr->cpu = cpu;
+		tx_ring->cpu = cpu;
 	}
 	put_cpu();
 }
@@ -459,31 +459,30 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc;
-	struct ixgbe_rx_buffer *rx_buffer_info;
-	struct sk_buff *skb;
+	struct ixgbe_rx_buffer *bi;
 	unsigned int i;
 	unsigned int bufsz = adapter->rx_buf_len + NET_IP_ALIGN;
 
 	i = rx_ring->next_to_use;
-	rx_buffer_info = &rx_ring->rx_buffer_info[i];
+	bi = &rx_ring->rx_buffer_info[i];
 
 	while (cleaned_count--) {
 		rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
 
-		if (!rx_buffer_info->page &&
-				(adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)) {
-			rx_buffer_info->page = alloc_page(GFP_ATOMIC);
-			if (!rx_buffer_info->page) {
+		if (!bi->page &&
+		    (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)) {
+			bi->page = alloc_page(GFP_ATOMIC);
+			if (!bi->page) {
 				adapter->alloc_rx_page_failed++;
 				goto no_buffers;
 			}
-			rx_buffer_info->page_dma =
-			    pci_map_page(pdev, rx_buffer_info->page,
-					 0, PAGE_SIZE, PCI_DMA_FROMDEVICE);
+			bi->page_dma = pci_map_page(pdev, bi->page, 0,
+			                            PAGE_SIZE,
+			                            PCI_DMA_FROMDEVICE);
 		}
 
-		if (!rx_buffer_info->skb) {
-			skb = netdev_alloc_skb(netdev, bufsz);
+		if (!bi->skb) {
+			struct sk_buff *skb = netdev_alloc_skb(netdev, bufsz);
 
 			if (!skb) {
 				adapter->alloc_rx_buff_failed++;
@@ -497,27 +496,23 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 			 */
 			skb_reserve(skb, NET_IP_ALIGN);
 
-			rx_buffer_info->skb = skb;
-			rx_buffer_info->dma = pci_map_single(pdev, skb->data,
-							  bufsz,
-							  PCI_DMA_FROMDEVICE);
+			bi->skb = skb;
+			bi->dma = pci_map_single(pdev, skb->data, bufsz,
+			                         PCI_DMA_FROMDEVICE);
 		}
 		/* Refresh the desc even if buffer_addrs didn't change because
 		 * each write-back erases this info. */
 		if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
-			rx_desc->read.pkt_addr =
-			    cpu_to_le64(rx_buffer_info->page_dma);
-			rx_desc->read.hdr_addr =
-					cpu_to_le64(rx_buffer_info->dma);
+			rx_desc->read.pkt_addr = cpu_to_le64(bi->page_dma);
+			rx_desc->read.hdr_addr = cpu_to_le64(bi->dma);
 		} else {
-			rx_desc->read.pkt_addr =
-					cpu_to_le64(rx_buffer_info->dma);
+			rx_desc->read.pkt_addr = cpu_to_le64(bi->dma);
 		}
 
 		i++;
 		if (i == rx_ring->count)
 			i = 0;
-		rx_buffer_info = &rx_ring->rx_buffer_info[i];
+		bi = &rx_ring->rx_buffer_info[i];
 	}
 no_buffers:
 	if (rx_ring->next_to_use != i) {
@@ -896,7 +891,7 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 {
 	struct ixgbe_q_vector *q_vector = data;
 	struct ixgbe_adapter  *adapter = q_vector->adapter;
-	struct ixgbe_ring     *txr;
+	struct ixgbe_ring     *tx_ring;
 	int i, r_idx;
 
 	if (!q_vector->txr_count)
@@ -904,14 +899,14 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
-		txr = &(adapter->tx_ring[r_idx]);
+		tx_ring = &(adapter->tx_ring[r_idx]);
 #ifdef CONFIG_DCA
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
-			ixgbe_update_tx_dca(adapter, txr);
+			ixgbe_update_tx_dca(adapter, tx_ring);
 #endif
-		txr->total_bytes = 0;
-		txr->total_packets = 0;
-		ixgbe_clean_tx_irq(adapter, txr);
+		tx_ring->total_bytes = 0;
+		tx_ring->total_packets = 0;
+		ixgbe_clean_tx_irq(adapter, tx_ring);
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
 				      r_idx + 1);
 	}
@@ -928,18 +923,18 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 {
 	struct ixgbe_q_vector *q_vector = data;
 	struct ixgbe_adapter  *adapter = q_vector->adapter;
-	struct ixgbe_ring  *rxr;
+	struct ixgbe_ring  *rx_ring;
 	int r_idx;
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	if (!q_vector->rxr_count)
 		return IRQ_HANDLED;
 
-	rxr = &(adapter->rx_ring[r_idx]);
+	rx_ring = &(adapter->rx_ring[r_idx]);
 	/* disable interrupts on this vector only */
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rxr->v_idx);
-	rxr->total_bytes = 0;
-	rxr->total_packets = 0;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rx_ring->v_idx);
+	rx_ring->total_bytes = 0;
+	rx_ring->total_packets = 0;
 	netif_rx_schedule(adapter->netdev, &q_vector->napi);
 
 	return IRQ_HANDLED;
@@ -964,18 +959,18 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 	struct ixgbe_q_vector *q_vector =
 			       container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	struct ixgbe_ring *rxr;
+	struct ixgbe_ring *rx_ring;
 	int work_done = 0;
 	long r_idx;
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
-	rxr = &(adapter->rx_ring[r_idx]);
+	rx_ring = &(adapter->rx_ring[r_idx]);
 #ifdef CONFIG_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
-		ixgbe_update_rx_dca(adapter, rxr);
+		ixgbe_update_rx_dca(adapter, rx_ring);
 #endif
 
-	ixgbe_clean_rx_irq(adapter, rxr, &work_done, budget);
+	ixgbe_clean_rx_irq(adapter, rx_ring, &work_done, budget);
 
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
@@ -983,7 +978,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 		if (adapter->rx_eitr < IXGBE_MIN_ITR_USECS)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, rxr->v_idx);
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, rx_ring->v_idx);
 	}
 
 	return work_done;
@@ -1342,7 +1337,7 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_configure_tx - Configure 8254x Transmit Unit after Reset
+ * ixgbe_configure_tx - Configure 8259x Transmit Unit after Reset
  * @adapter: board private structure
  *
  * Configure the Tx unit of the MAC after a reset.
@@ -1408,7 +1403,7 @@ static int ixgbe_get_skb_hdr(struct sk_buff *skb, void **iphdr, void **tcph,
 }
 
 /**
- * ixgbe_configure_rx - Configure 8254x Receive Unit after Reset
+ * ixgbe_configure_rx - Configure 8259x Receive Unit after Reset
  * @adapter: board private structure
  *
  * Configure the Rx unit of the MAC after a reset.
@@ -2483,40 +2478,41 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 /**
  * ixgbe_setup_tx_resources - allocate Tx resources (Descriptors)
  * @adapter: board private structure
- * @txdr:    tx descriptor ring (for a specific queue) to setup
+ * @tx_ring:    tx descriptor ring (for a specific queue) to setup
  *
  * Return 0 on success, negative on failure
  **/
 int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
-			     struct ixgbe_ring *txdr)
+			     struct ixgbe_ring *tx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int size;
 
-	size = sizeof(struct ixgbe_tx_buffer) * txdr->count;
-	txdr->tx_buffer_info = vmalloc(size);
-	if (!txdr->tx_buffer_info) {
+	size = sizeof(struct ixgbe_tx_buffer) * tx_ring->count;
+	tx_ring->tx_buffer_info = vmalloc(size);
+	if (!tx_ring->tx_buffer_info) {
 		DPRINTK(PROBE, ERR,
 		"Unable to allocate memory for the transmit descriptor ring\n");
 		return -ENOMEM;
 	}
-	memset(txdr->tx_buffer_info, 0, size);
+	memset(tx_ring->tx_buffer_info, 0, size);
 
 	/* round up to nearest 4K */
-	txdr->size = txdr->count * sizeof(union ixgbe_adv_tx_desc);
-	txdr->size = ALIGN(txdr->size, 4096);
+	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc);
+	tx_ring->size = ALIGN(tx_ring->size, 4096);
 
-	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
-	if (!txdr->desc) {
-		vfree(txdr->tx_buffer_info);
+	tx_ring->desc = pci_alloc_consistent(pdev, tx_ring->size,
+	                                     &tx_ring->dma);
+	if (!tx_ring->desc) {
+		vfree(tx_ring->tx_buffer_info);
 		DPRINTK(PROBE, ERR,
 			"Memory allocation failed for the tx desc ring\n");
 		return -ENOMEM;
 	}
 
-	txdr->next_to_use = 0;
-	txdr->next_to_clean = 0;
-	txdr->work_limit = txdr->count;
+	tx_ring->next_to_use = 0;
+	tx_ring->next_to_clean = 0;
+	tx_ring->work_limit = tx_ring->count;
 
 	return 0;
 }
@@ -2524,52 +2520,52 @@ int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
 /**
  * ixgbe_setup_rx_resources - allocate Rx resources (Descriptors)
  * @adapter: board private structure
- * @rxdr:    rx descriptor ring (for a specific queue) to setup
+ * @rx_ring:    rx descriptor ring (for a specific queue) to setup
  *
  * Returns 0 on success, negative on failure
  **/
 int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
-			     struct ixgbe_ring *rxdr)
+			     struct ixgbe_ring *rx_ring)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int size;
 
 	size = sizeof(struct net_lro_desc) * IXGBE_MAX_LRO_DESCRIPTORS;
-	rxdr->lro_mgr.lro_arr = vmalloc(size);
-	if (!rxdr->lro_mgr.lro_arr)
+	rx_ring->lro_mgr.lro_arr = vmalloc(size);
+	if (!rx_ring->lro_mgr.lro_arr)
 		return -ENOMEM;
-	memset(rxdr->lro_mgr.lro_arr, 0, size);
+	memset(rx_ring->lro_mgr.lro_arr, 0, size);
 
-	size = sizeof(struct ixgbe_rx_buffer) * rxdr->count;
-	rxdr->rx_buffer_info = vmalloc(size);
-	if (!rxdr->rx_buffer_info) {
+	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
+	rx_ring->rx_buffer_info = vmalloc(size);
+	if (!rx_ring->rx_buffer_info) {
 		DPRINTK(PROBE, ERR,
 			"vmalloc allocation failed for the rx desc ring\n");
 		goto alloc_failed;
 	}
-	memset(rxdr->rx_buffer_info, 0, size);
+	memset(rx_ring->rx_buffer_info, 0, size);
 
 	/* Round up to nearest 4K */
-	rxdr->size = rxdr->count * sizeof(union ixgbe_adv_rx_desc);
-	rxdr->size = ALIGN(rxdr->size, 4096);
+	rx_ring->size = rx_ring->count * sizeof(union ixgbe_adv_rx_desc);
+	rx_ring->size = ALIGN(rx_ring->size, 4096);
 
-	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
+	rx_ring->desc = pci_alloc_consistent(pdev, rx_ring->size, &rx_ring->dma);
 
-	if (!rxdr->desc) {
+	if (!rx_ring->desc) {
 		DPRINTK(PROBE, ERR,
 			"Memory allocation failed for the rx desc ring\n");
-		vfree(rxdr->rx_buffer_info);
+		vfree(rx_ring->rx_buffer_info);
 		goto alloc_failed;
 	}
 
-	rxdr->next_to_clean = 0;
-	rxdr->next_to_use = 0;
+	rx_ring->next_to_clean = 0;
+	rx_ring->next_to_use = 0;
 
 	return 0;
 
 alloc_failed:
-	vfree(rxdr->lro_mgr.lro_arr);
-	rxdr->lro_mgr.lro_arr = NULL;
+	vfree(rx_ring->lro_mgr.lro_arr);
+	rx_ring->lro_mgr.lro_arr = NULL;
 	return -ENOMEM;
 }
 

