From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 03/11] sfc: Use generic DMA API, not PCI-DMA API
Date: Thu, 12 Jul 2012 00:16:05 +0100
Message-ID: <1342048565.2613.62.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342048389.2613.59.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:18967 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751010Ab2GKXQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 19:16:08 -0400
In-Reply-To: <1342048389.2613.59.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |   10 ++--
 drivers/net/ethernet/sfc/net_driver.h |    2 +-
 drivers/net/ethernet/sfc/nic.c        |    8 ++--
 drivers/net/ethernet/sfc/rx.c         |   22 ++++----
 drivers/net/ethernet/sfc/tx.c         |   83 ++++++++++++++++-----------------
 5 files changed, 62 insertions(+), 63 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index b95f2e1..70554a1 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1103,8 +1103,8 @@ static int efx_init_io(struct efx_nic *efx)
 	 * masks event though they reject 46 bit masks.
 	 */
 	while (dma_mask > 0x7fffffffUL) {
-		if (pci_dma_supported(pci_dev, dma_mask)) {
-			rc = pci_set_dma_mask(pci_dev, dma_mask);
+		if (dma_supported(&pci_dev->dev, dma_mask)) {
+			rc = dma_set_mask(&pci_dev->dev, dma_mask);
 			if (rc == 0)
 				break;
 		}
@@ -1117,10 +1117,10 @@ static int efx_init_io(struct efx_nic *efx)
 	}
 	netif_dbg(efx, probe, efx->net_dev,
 		  "using DMA mask %llx\n", (unsigned long long) dma_mask);
-	rc = pci_set_consistent_dma_mask(pci_dev, dma_mask);
+	rc = dma_set_coherent_mask(&pci_dev->dev, dma_mask);
 	if (rc) {
-		/* pci_set_consistent_dma_mask() is not *allowed* to
-		 * fail with a mask that pci_set_dma_mask() accepted,
+		/* dma_set_coherent_mask() is not *allowed* to
+		 * fail with a mask that dma_set_mask() accepted,
 		 * but just in case...
 		 */
 		netif_err(efx, probe, efx->net_dev,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 0e57535..8a9f6d4 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -100,7 +100,7 @@ struct efx_special_buffer {
  * @len: Length of this fragment.
  *	This field is zero when the queue slot is empty.
  * @continuation: True if this fragment is not the end of a packet.
- * @unmap_single: True if pci_unmap_single should be used.
+ * @unmap_single: True if dma_unmap_single should be used.
  * @unmap_len: Length of this fragment to unmap
  */
 struct efx_tx_buffer {
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 4a9a5be..287738d 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -308,8 +308,8 @@ efx_free_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 int efx_nic_alloc_buffer(struct efx_nic *efx, struct efx_buffer *buffer,
 			 unsigned int len)
 {
-	buffer->addr = pci_alloc_consistent(efx->pci_dev, len,
-					    &buffer->dma_addr);
+	buffer->addr = dma_alloc_coherent(&efx->pci_dev->dev, len,
+					  &buffer->dma_addr, GFP_ATOMIC);
 	if (!buffer->addr)
 		return -ENOMEM;
 	buffer->len = len;
@@ -320,8 +320,8 @@ int efx_nic_alloc_buffer(struct efx_nic *efx, struct efx_buffer *buffer,
 void efx_nic_free_buffer(struct efx_nic *efx, struct efx_buffer *buffer)
 {
 	if (buffer->addr) {
-		pci_free_consistent(efx->pci_dev, buffer->len,
-				    buffer->addr, buffer->dma_addr);
+		dma_free_coherent(&efx->pci_dev->dev, buffer->len,
+				  buffer->addr, buffer->dma_addr);
 		buffer->addr = NULL;
 	}
 }
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 243e91f..6d1c6cf 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -155,11 +155,11 @@ static int efx_init_rx_buffers_skb(struct efx_rx_queue *rx_queue)
 		rx_buf->len = skb_len - NET_IP_ALIGN;
 		rx_buf->flags = 0;
 
-		rx_buf->dma_addr = pci_map_single(efx->pci_dev,
+		rx_buf->dma_addr = dma_map_single(&efx->pci_dev->dev,
 						  skb->data, rx_buf->len,
-						  PCI_DMA_FROMDEVICE);
-		if (unlikely(pci_dma_mapping_error(efx->pci_dev,
-						   rx_buf->dma_addr))) {
+						  DMA_FROM_DEVICE);
+		if (unlikely(dma_mapping_error(&efx->pci_dev->dev,
+					       rx_buf->dma_addr))) {
 			dev_kfree_skb_any(skb);
 			rx_buf->u.skb = NULL;
 			return -EIO;
@@ -200,10 +200,10 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 				   efx->rx_buffer_order);
 		if (unlikely(page == NULL))
 			return -ENOMEM;
-		dma_addr = pci_map_page(efx->pci_dev, page, 0,
+		dma_addr = dma_map_page(&efx->pci_dev->dev, page, 0,
 					efx_rx_buf_size(efx),
-					PCI_DMA_FROMDEVICE);
-		if (unlikely(pci_dma_mapping_error(efx->pci_dev, dma_addr))) {
+					DMA_FROM_DEVICE);
+		if (unlikely(dma_mapping_error(&efx->pci_dev->dev, dma_addr))) {
 			__free_pages(page, efx->rx_buffer_order);
 			return -EIO;
 		}
@@ -247,14 +247,14 @@ static void efx_unmap_rx_buffer(struct efx_nic *efx,
 
 		state = page_address(rx_buf->u.page);
 		if (--state->refcnt == 0) {
-			pci_unmap_page(efx->pci_dev,
+			dma_unmap_page(&efx->pci_dev->dev,
 				       state->dma_addr,
 				       efx_rx_buf_size(efx),
-				       PCI_DMA_FROMDEVICE);
+				       DMA_FROM_DEVICE);
 		}
 	} else if (!(rx_buf->flags & EFX_RX_BUF_PAGE) && rx_buf->u.skb) {
-		pci_unmap_single(efx->pci_dev, rx_buf->dma_addr,
-				 rx_buf->len, PCI_DMA_FROMDEVICE);
+		dma_unmap_single(&efx->pci_dev->dev, rx_buf->dma_addr,
+				 rx_buf->len, DMA_FROM_DEVICE);
 	}
 }
 
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 94d0365..18860f2 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -36,15 +36,15 @@ static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
 			       unsigned int *bytes_compl)
 {
 	if (buffer->unmap_len) {
-		struct pci_dev *pci_dev = tx_queue->efx->pci_dev;
+		struct device *dma_dev = &tx_queue->efx->pci_dev->dev;
 		dma_addr_t unmap_addr = (buffer->dma_addr + buffer->len -
 					 buffer->unmap_len);
 		if (buffer->unmap_single)
-			pci_unmap_single(pci_dev, unmap_addr, buffer->unmap_len,
-					 PCI_DMA_TODEVICE);
+			dma_unmap_single(dma_dev, unmap_addr, buffer->unmap_len,
+					 DMA_TO_DEVICE);
 		else
-			pci_unmap_page(pci_dev, unmap_addr, buffer->unmap_len,
-				       PCI_DMA_TODEVICE);
+			dma_unmap_page(dma_dev, unmap_addr, buffer->unmap_len,
+				       DMA_TO_DEVICE);
 		buffer->unmap_len = 0;
 		buffer->unmap_single = false;
 	}
@@ -138,7 +138,7 @@ efx_max_tx_len(struct efx_nic *efx, dma_addr_t dma_addr)
 netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 {
 	struct efx_nic *efx = tx_queue->efx;
-	struct pci_dev *pci_dev = efx->pci_dev;
+	struct device *dma_dev = &efx->pci_dev->dev;
 	struct efx_tx_buffer *buffer;
 	skb_frag_t *fragment;
 	unsigned int len, unmap_len = 0, fill_level, insert_ptr;
@@ -167,17 +167,17 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	fill_level = tx_queue->insert_count - tx_queue->old_read_count;
 	q_space = efx->txq_entries - 1 - fill_level;
 
-	/* Map for DMA.  Use pci_map_single rather than pci_map_page
+	/* Map for DMA.  Use dma_map_single rather than dma_map_page
 	 * since this is more efficient on machines with sparse
 	 * memory.
 	 */
 	unmap_single = true;
-	dma_addr = pci_map_single(pci_dev, skb->data, len, PCI_DMA_TODEVICE);
+	dma_addr = dma_map_single(dma_dev, skb->data, len, PCI_DMA_TODEVICE);
 
 	/* Process all fragments */
 	while (1) {
-		if (unlikely(pci_dma_mapping_error(pci_dev, dma_addr)))
-			goto pci_err;
+		if (unlikely(dma_mapping_error(dma_dev, dma_addr)))
+			goto dma_err;
 
 		/* Store fields for marking in the per-fragment final
 		 * descriptor */
@@ -246,7 +246,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 		i++;
 		/* Map for DMA */
 		unmap_single = false;
-		dma_addr = skb_frag_dma_map(&pci_dev->dev, fragment, 0, len,
+		dma_addr = skb_frag_dma_map(dma_dev, fragment, 0, len,
 					    DMA_TO_DEVICE);
 	}
 
@@ -261,7 +261,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 
 	return NETDEV_TX_OK;
 
- pci_err:
+ dma_err:
 	netif_err(efx, tx_err, efx->net_dev,
 		  " TX queue %d could not map skb with %d bytes %d "
 		  "fragments for DMA\n", tx_queue->queue, skb->len,
@@ -284,11 +284,11 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	/* Free the fragment we were mid-way through pushing */
 	if (unmap_len) {
 		if (unmap_single)
-			pci_unmap_single(pci_dev, unmap_addr, unmap_len,
-					 PCI_DMA_TODEVICE);
+			dma_unmap_single(dma_dev, unmap_addr, unmap_len,
+					 DMA_TO_DEVICE);
 		else
-			pci_unmap_page(pci_dev, unmap_addr, unmap_len,
-				       PCI_DMA_TODEVICE);
+			dma_unmap_page(dma_dev, unmap_addr, unmap_len,
+				       DMA_TO_DEVICE);
 	}
 
 	return rc;
@@ -684,20 +684,19 @@ static __be16 efx_tso_check_protocol(struct sk_buff *skb)
  */
 static int efx_tsoh_block_alloc(struct efx_tx_queue *tx_queue)
 {
-
-	struct pci_dev *pci_dev = tx_queue->efx->pci_dev;
+	struct device *dma_dev = &tx_queue->efx->pci_dev->dev;
 	struct efx_tso_header *tsoh;
 	dma_addr_t dma_addr;
 	u8 *base_kva, *kva;
 
-	base_kva = pci_alloc_consistent(pci_dev, PAGE_SIZE, &dma_addr);
+	base_kva = dma_alloc_coherent(dma_dev, PAGE_SIZE, &dma_addr, GFP_ATOMIC);
 	if (base_kva == NULL) {
 		netif_err(tx_queue->efx, tx_err, tx_queue->efx->net_dev,
 			  "Unable to allocate page for TSO headers\n");
 		return -ENOMEM;
 	}
 
-	/* pci_alloc_consistent() allocates pages. */
+	/* dma_alloc_coherent() allocates pages. */
 	EFX_BUG_ON_PARANOID(dma_addr & (PAGE_SIZE - 1u));
 
 	for (kva = base_kva; kva < base_kva + PAGE_SIZE; kva += TSOH_STD_SIZE) {
@@ -714,7 +713,7 @@ static int efx_tsoh_block_alloc(struct efx_tx_queue *tx_queue)
 /* Free up a TSO header, and all others in the same page. */
 static void efx_tsoh_block_free(struct efx_tx_queue *tx_queue,
 				struct efx_tso_header *tsoh,
-				struct pci_dev *pci_dev)
+				struct device *dma_dev)
 {
 	struct efx_tso_header **p;
 	unsigned long base_kva;
@@ -731,7 +730,7 @@ static void efx_tsoh_block_free(struct efx_tx_queue *tx_queue,
 			p = &(*p)->next;
 	}
 
-	pci_free_consistent(pci_dev, PAGE_SIZE, (void *)base_kva, base_dma);
+	dma_free_coherent(dma_dev, PAGE_SIZE, (void *)base_kva, base_dma);
 }
 
 static struct efx_tso_header *
@@ -743,11 +742,11 @@ efx_tsoh_heap_alloc(struct efx_tx_queue *tx_queue, size_t header_len)
 	if (unlikely(!tsoh))
 		return NULL;
 
-	tsoh->dma_addr = pci_map_single(tx_queue->efx->pci_dev,
+	tsoh->dma_addr = dma_map_single(&tx_queue->efx->pci_dev->dev,
 					TSOH_BUFFER(tsoh), header_len,
-					PCI_DMA_TODEVICE);
-	if (unlikely(pci_dma_mapping_error(tx_queue->efx->pci_dev,
-					   tsoh->dma_addr))) {
+					DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(&tx_queue->efx->pci_dev->dev,
+				       tsoh->dma_addr))) {
 		kfree(tsoh);
 		return NULL;
 	}
@@ -759,9 +758,9 @@ efx_tsoh_heap_alloc(struct efx_tx_queue *tx_queue, size_t header_len)
 static void
 efx_tsoh_heap_free(struct efx_tx_queue *tx_queue, struct efx_tso_header *tsoh)
 {
-	pci_unmap_single(tx_queue->efx->pci_dev,
+	dma_unmap_single(&tx_queue->efx->pci_dev->dev,
 			 tsoh->dma_addr, tsoh->unmap_len,
-			 PCI_DMA_TODEVICE);
+			 DMA_TO_DEVICE);
 	kfree(tsoh);
 }
 
@@ -892,13 +891,13 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 			unmap_addr = (buffer->dma_addr + buffer->len -
 				      buffer->unmap_len);
 			if (buffer->unmap_single)
-				pci_unmap_single(tx_queue->efx->pci_dev,
+				dma_unmap_single(&tx_queue->efx->pci_dev->dev,
 						 unmap_addr, buffer->unmap_len,
-						 PCI_DMA_TODEVICE);
+						 DMA_TO_DEVICE);
 			else
-				pci_unmap_page(tx_queue->efx->pci_dev,
+				dma_unmap_page(&tx_queue->efx->pci_dev->dev,
 					       unmap_addr, buffer->unmap_len,
-					       PCI_DMA_TODEVICE);
+					       DMA_TO_DEVICE);
 			buffer->unmap_len = 0;
 		}
 		buffer->len = 0;
@@ -954,9 +953,9 @@ static int tso_get_head_fragment(struct tso_state *st, struct efx_nic *efx,
 	int hl = st->header_len;
 	int len = skb_headlen(skb) - hl;
 
-	st->unmap_addr = pci_map_single(efx->pci_dev, skb->data + hl,
-					len, PCI_DMA_TODEVICE);
-	if (likely(!pci_dma_mapping_error(efx->pci_dev, st->unmap_addr))) {
+	st->unmap_addr = dma_map_single(&efx->pci_dev->dev, skb->data + hl,
+					len, DMA_TO_DEVICE);
+	if (likely(!dma_mapping_error(&efx->pci_dev->dev, st->unmap_addr))) {
 		st->unmap_single = true;
 		st->unmap_len = len;
 		st->in_len = len;
@@ -1008,7 +1007,7 @@ static int tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
 		buffer->continuation = !end_of_packet;
 
 		if (st->in_len == 0) {
-			/* Transfer ownership of the pci mapping */
+			/* Transfer ownership of the DMA mapping */
 			buffer->unmap_len = st->unmap_len;
 			buffer->unmap_single = st->unmap_single;
 			st->unmap_len = 0;
@@ -1181,18 +1180,18 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 
  mem_err:
 	netif_err(efx, tx_err, efx->net_dev,
-		  "Out of memory for TSO headers, or PCI mapping error\n");
+		  "Out of memory for TSO headers, or DMA mapping error\n");
 	dev_kfree_skb_any(skb);
 
  unwind:
 	/* Free the DMA mapping we were in the process of writing out */
 	if (state.unmap_len) {
 		if (state.unmap_single)
-			pci_unmap_single(efx->pci_dev, state.unmap_addr,
-					 state.unmap_len, PCI_DMA_TODEVICE);
+			dma_unmap_single(&efx->pci_dev->dev, state.unmap_addr,
+					 state.unmap_len, DMA_TO_DEVICE);
 		else
-			pci_unmap_page(efx->pci_dev, state.unmap_addr,
-				       state.unmap_len, PCI_DMA_TODEVICE);
+			dma_unmap_page(&efx->pci_dev->dev, state.unmap_addr,
+				       state.unmap_len, DMA_TO_DEVICE);
 	}
 
 	efx_enqueue_unwind(tx_queue);
@@ -1216,5 +1215,5 @@ static void efx_fini_tso(struct efx_tx_queue *tx_queue)
 
 	while (tx_queue->tso_headers_free != NULL)
 		efx_tsoh_block_free(tx_queue, tx_queue->tso_headers_free,
-				    tx_queue->efx->pci_dev);
+				    &tx_queue->efx->pci_dev->dev);
 }
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
