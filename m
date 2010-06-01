From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 08/12] sfc: Support only two rx buffers per page
Date: Tue, 01 Jun 2010 22:33:17 +0100
Message-ID: <1275427997.2114.48.camel@achroite.uk.solarflarecom.com>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51726 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757314Ab0FAVdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 17:33:20 -0400
In-Reply-To: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

- Pull the loop handling into efx_init_rx_buffers_(skb|page)
- Remove rx_queue->buf_page, and associated clean up code
- Remove unmap_addr, since unmap_addr is trivially calculable

This will allow us to recycle discarded buffers directly
from efx_rx_packet(), since will never be in the middle of
splitting a page.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |   10 --
 drivers/net/sfc/rx.c         |  228 ++++++++++++++++++------------------------
 2 files changed, 96 insertions(+), 142 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 4539803..59c8ecc 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -222,7 +222,6 @@ struct efx_tx_queue {
  *	If both this and skb are %NULL, the buffer slot is currently free.
  * @data: Pointer to ethernet header
  * @len: Buffer length, in bytes.
- * @unmap_addr: DMA address to unmap
  */
 struct efx_rx_buffer {
 	dma_addr_t dma_addr;
@@ -230,7 +229,6 @@ struct efx_rx_buffer {
 	struct page *page;
 	char *data;
 	unsigned int len;
-	dma_addr_t unmap_addr;
 };
 
 /**
@@ -257,11 +255,6 @@ struct efx_rx_buffer {
  * @alloc_page_count: RX allocation strategy counter.
  * @alloc_skb_count: RX allocation strategy counter.
  * @slow_fill: Timer used to defer efx_nic_generate_fill_event().
- * @buf_page: Page for next RX buffer.
- *	We can use a single page for multiple RX buffers. This tracks
- *	the remaining space in the allocation.
- * @buf_dma_addr: Page's DMA address.
- * @buf_data: Page's host address.
  * @flushed: Use when handling queue flushing
  */
 struct efx_rx_queue {
@@ -284,9 +277,6 @@ struct efx_rx_queue {
 	struct timer_list slow_fill;
 	unsigned int slow_fill_count;
 
-	struct page *buf_page;
-	dma_addr_t buf_dma_addr;
-	char *buf_data;
 	enum efx_flush_state flushed;
 };
 
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index bf1e55e..615a1fc 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -98,155 +98,132 @@ static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
 	return PAGE_SIZE << efx->rx_buffer_order;
 }
 
-
 /**
- * efx_init_rx_buffer_skb - create new RX buffer using skb-based allocation
+ * efx_init_rx_buffers_skb - create EFX_RX_BATCH skb-based RX buffers
  *
  * @rx_queue:		Efx RX queue
- * @rx_buf:		RX buffer structure to populate
  *
- * This allocates memory for a new receive buffer, maps it for DMA,
- * and populates a struct efx_rx_buffer with the relevant
- * information.  Return a negative error code or 0 on success.
+ * This allocates EFX_RX_BATCH skbs, maps them for DMA, and populates a
+ * struct efx_rx_buffer for each one. Return a negative error code or 0
+ * on success. May fail having only inserted fewer than EFX_RX_BATCH
+ * buffers.
  */
-static int efx_init_rx_buffer_skb(struct efx_rx_queue *rx_queue,
-				  struct efx_rx_buffer *rx_buf)
+static int efx_init_rx_buffers_skb(struct efx_rx_queue *rx_queue)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	struct net_device *net_dev = efx->net_dev;
+	struct efx_rx_buffer *rx_buf;
 	int skb_len = efx->rx_buffer_len;
+	unsigned index, count;
 
-	rx_buf->skb = netdev_alloc_skb(net_dev, skb_len);
-	if (unlikely(!rx_buf->skb))
-		return -ENOMEM;
+	for (count = 0; count < EFX_RX_BATCH; ++count) {
+		index = rx_queue->added_count & EFX_RXQ_MASK;
+		rx_buf = efx_rx_buffer(rx_queue, index);
 
-	/* Adjust the SKB for padding and checksum */
-	skb_reserve(rx_buf->skb, NET_IP_ALIGN);
-	rx_buf->len = skb_len - NET_IP_ALIGN;
-	rx_buf->data = (char *)rx_buf->skb->data;
-	rx_buf->skb->ip_summed = CHECKSUM_UNNECESSARY;
+		rx_buf->skb = netdev_alloc_skb(net_dev, skb_len);
+		if (unlikely(!rx_buf->skb))
+			return -ENOMEM;
+		rx_buf->page = NULL;
 
-	rx_buf->dma_addr = pci_map_single(efx->pci_dev,
-					  rx_buf->data, rx_buf->len,
-					  PCI_DMA_FROMDEVICE);
+		/* Adjust the SKB for padding and checksum */
+		skb_reserve(rx_buf->skb, NET_IP_ALIGN);
+		rx_buf->len = skb_len - NET_IP_ALIGN;
+		rx_buf->data = (char *)rx_buf->skb->data;
+		rx_buf->skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+		rx_buf->dma_addr = pci_map_single(efx->pci_dev,
+						  rx_buf->data, rx_buf->len,
+						  PCI_DMA_FROMDEVICE);
+		if (unlikely(pci_dma_mapping_error(efx->pci_dev,
+						   rx_buf->dma_addr))) {
+			dev_kfree_skb_any(rx_buf->skb);
+			rx_buf->skb = NULL;
+			return -EIO;
+		}
 
-	if (unlikely(pci_dma_mapping_error(efx->pci_dev, rx_buf->dma_addr))) {
-		dev_kfree_skb_any(rx_buf->skb);
-		rx_buf->skb = NULL;
-		return -EIO;
+		++rx_queue->added_count;
+		++rx_queue->alloc_skb_count;
 	}
 
 	return 0;
 }
 
 /**
- * efx_init_rx_buffer_page - create new RX buffer using page-based allocation
+ * efx_init_rx_buffers_page - create EFX_RX_BATCH page-based RX buffers
  *
  * @rx_queue:		Efx RX queue
- * @rx_buf:		RX buffer structure to populate
  *
- * This allocates memory for a new receive buffer, maps it for DMA,
- * and populates a struct efx_rx_buffer with the relevant
- * information.  Return a negative error code or 0 on success.
+ * This allocates memory for EFX_RX_BATCH receive buffers, maps them for DMA,
+ * and populates struct efx_rx_buffers for each one. Return a negative error
+ * code or 0 on success. If a single page can be split between two buffers,
+ * then the page will either be inserted fully, or not at at all.
  */
-static int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queue,
-				   struct efx_rx_buffer *rx_buf)
+static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 {
 	struct efx_nic *efx = rx_queue->efx;
-	int bytes, space, offset;
-
-	bytes = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
-
-	/* If there is space left in the previously allocated page,
-	 * then use it. Otherwise allocate a new one */
-	rx_buf->page = rx_queue->buf_page;
-	if (rx_buf->page == NULL) {
-		dma_addr_t dma_addr;
-
-		rx_buf->page = alloc_pages(__GFP_COLD | __GFP_COMP | GFP_ATOMIC,
-					   efx->rx_buffer_order);
-		if (unlikely(rx_buf->page == NULL))
+	struct efx_rx_buffer *rx_buf;
+	struct page *page;
+	char *page_addr;
+	dma_addr_t dma_addr;
+	unsigned index, count;
+
+	/* We can split a page between two buffers */
+	BUILD_BUG_ON(EFX_RX_BATCH & 1);
+
+	for (count = 0; count < EFX_RX_BATCH; ++count) {
+		page = alloc_pages(__GFP_COLD | __GFP_COMP | GFP_ATOMIC,
+				   efx->rx_buffer_order);
+		if (unlikely(page == NULL))
 			return -ENOMEM;
-
-		dma_addr = pci_map_page(efx->pci_dev, rx_buf->page,
-					0, efx_rx_buf_size(efx),
+		dma_addr = pci_map_page(efx->pci_dev, page, 0,
+					efx_rx_buf_size(efx),
 					PCI_DMA_FROMDEVICE);
-
 		if (unlikely(pci_dma_mapping_error(efx->pci_dev, dma_addr))) {
-			__free_pages(rx_buf->page, efx->rx_buffer_order);
-			rx_buf->page = NULL;
+			__free_pages(page, efx->rx_buffer_order);
 			return -EIO;
 		}
-
-		rx_queue->buf_page = rx_buf->page;
-		rx_queue->buf_dma_addr = dma_addr;
-		rx_queue->buf_data = (page_address(rx_buf->page) +
-				      EFX_PAGE_IP_ALIGN);
-	}
-
-	rx_buf->len = bytes;
-	rx_buf->data = rx_queue->buf_data;
-	offset = efx_rx_buf_offset(rx_buf);
-	rx_buf->dma_addr = rx_queue->buf_dma_addr + offset;
-
-	/* Try to pack multiple buffers per page */
-	if (efx->rx_buffer_order == 0) {
-		/* The next buffer starts on the next 512 byte boundary */
-		rx_queue->buf_data += ((bytes + 0x1ff) & ~0x1ff);
-		offset += ((bytes + 0x1ff) & ~0x1ff);
-
-		space = efx_rx_buf_size(efx) - offset;
-		if (space >= bytes) {
-			/* Refs dropped on kernel releasing each skb */
-			get_page(rx_queue->buf_page);
-			goto out;
+		EFX_BUG_ON_PARANOID(dma_addr & (PAGE_SIZE - 1));
+		page_addr = page_address(page) + EFX_PAGE_IP_ALIGN;
+		dma_addr += EFX_PAGE_IP_ALIGN;
+
+	split:
+		index = rx_queue->added_count & EFX_RXQ_MASK;
+		rx_buf = efx_rx_buffer(rx_queue, index);
+		rx_buf->dma_addr = dma_addr;
+		rx_buf->skb = NULL;
+		rx_buf->page = page;
+		rx_buf->data = page_addr;
+		rx_buf->len = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
+		++rx_queue->added_count;
+		++rx_queue->alloc_page_count;
+
+		if ((~count & 1) && (efx->rx_buffer_len < (PAGE_SIZE >> 1))) {
+			/* Use the second half of the page */
+			get_page(page);
+			dma_addr += (PAGE_SIZE >> 1);
+			page_addr += (PAGE_SIZE >> 1);
+			++count;
+			goto split;
 		}
 	}
 
-	/* This is the final RX buffer for this page, so mark it for
-	 * unmapping */
-	rx_queue->buf_page = NULL;
-	rx_buf->unmap_addr = rx_queue->buf_dma_addr;
-
- out:
 	return 0;
 }
 
-/* This allocates memory for a new receive buffer, maps it for DMA,
- * and populates a struct efx_rx_buffer with the relevant
- * information.
- */
-static int efx_init_rx_buffer(struct efx_rx_queue *rx_queue,
-			      struct efx_rx_buffer *new_rx_buf)
-{
-	int rc = 0;
-
-	if (rx_queue->channel->rx_alloc_push_pages) {
-		new_rx_buf->skb = NULL;
-		rc = efx_init_rx_buffer_page(rx_queue, new_rx_buf);
-		rx_queue->alloc_page_count++;
-	} else {
-		new_rx_buf->page = NULL;
-		rc = efx_init_rx_buffer_skb(rx_queue, new_rx_buf);
-		rx_queue->alloc_skb_count++;
-	}
-
-	if (unlikely(rc < 0))
-		EFX_LOG_RL(rx_queue->efx, "%s RXQ[%d] =%d\n", __func__,
-			   rx_queue->queue, rc);
-	return rc;
-}
-
 static void efx_unmap_rx_buffer(struct efx_nic *efx,
 				struct efx_rx_buffer *rx_buf)
 {
 	if (rx_buf->page) {
 		EFX_BUG_ON_PARANOID(rx_buf->skb);
-		if (rx_buf->unmap_addr) {
-			pci_unmap_page(efx->pci_dev, rx_buf->unmap_addr,
+
+		/* Unmap the buffer if there's only one buffer per page(s),
+		 * or this is the second half of a two buffer page. */
+		if (efx->rx_buffer_order != 0 ||
+		    (efx_rx_buf_offset(rx_buf) & (PAGE_SIZE >> 1)) != 0) {
+			pci_unmap_page(efx->pci_dev,
+				       rx_buf->dma_addr & ~(PAGE_SIZE - 1),
 				       efx_rx_buf_size(efx),
 				       PCI_DMA_FROMDEVICE);
-			rx_buf->unmap_addr = 0;
 		}
 	} else if (likely(rx_buf->skb)) {
 		pci_unmap_single(efx->pci_dev, rx_buf->dma_addr,
@@ -286,9 +263,9 @@ static void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
  */
 void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 {
-	struct efx_rx_buffer *rx_buf;
-	unsigned fill_level, index;
-	int i, space, rc = 0;
+	struct efx_channel *channel = rx_queue->channel;
+	unsigned fill_level;
+	int space, rc = 0;
 
 	/* Calculate current fill level, and exit if we don't need to fill */
 	fill_level = (rx_queue->added_count - rx_queue->removed_count);
@@ -309,21 +286,18 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 	EFX_TRACE(rx_queue->efx, "RX queue %d fast-filling descriptor ring from"
 		  " level %d to level %d using %s allocation\n",
 		  rx_queue->queue, fill_level, rx_queue->fast_fill_limit,
-		  rx_queue->channel->rx_alloc_push_pages ? "page" : "skb");
+		  channel->rx_alloc_push_pages ? "page" : "skb");
 
 	do {
-		for (i = 0; i < EFX_RX_BATCH; ++i) {
-			index = rx_queue->added_count & EFX_RXQ_MASK;
-			rx_buf = efx_rx_buffer(rx_queue, index);
-			rc = efx_init_rx_buffer(rx_queue, rx_buf);
-			if (unlikely(rc)) {
-				/* Ensure that we don't leave the rx queue
-				 * empty */
-				if (rx_queue->added_count == rx_queue->removed_count)
-					efx_schedule_slow_fill(rx_queue);
-				goto out;
-			}
-			++rx_queue->added_count;
+		if (channel->rx_alloc_push_pages)
+			rc = efx_init_rx_buffers_page(rx_queue);
+		else
+			rc = efx_init_rx_buffers_skb(rx_queue);
+		if (unlikely(rc)) {
+			/* Ensure that we don't leave the rx queue empty */
+			if (rx_queue->added_count == rx_queue->removed_count)
+				efx_schedule_slow_fill(rx_queue);
+			goto out;
 		}
 	} while ((space -= EFX_RX_BATCH) >= EFX_RX_BATCH);
 
@@ -638,16 +612,6 @@ void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
 			efx_fini_rx_buffer(rx_queue, rx_buf);
 		}
 	}
-
-	/* For a page that is part-way through splitting into RX buffers */
-	if (rx_queue->buf_page != NULL) {
-		pci_unmap_page(rx_queue->efx->pci_dev, rx_queue->buf_dma_addr,
-			       efx_rx_buf_size(rx_queue->efx),
-			       PCI_DMA_FROMDEVICE);
-		__free_pages(rx_queue->buf_page,
-			     rx_queue->efx->rx_buffer_order);
-		rx_queue->buf_page = NULL;
-	}
 }
 
 void efx_remove_rx_queue(struct efx_rx_queue *rx_queue)
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

