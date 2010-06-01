From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 10/12] sfc: Allow shared pages to be recycled
Date: Tue, 01 Jun 2010 22:20:53 +0100
Message-ID: <1275427253.2114.34.camel@achroite.uk.solarflarecom.com>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:50830 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155Ab0FAVU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 17:20:56 -0400
In-Reply-To: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Insert a structure at the start of the shared page that
tracks the dma mapping refcnt. DMA into the next cache
line of the (shared) page (plus EFX_PAGE_IP_ALIGN).

When recycling a page, check the page refcnt. If the
page is otherwise unused, then resurrect the other
receive buffer that previously referenced the page.
Be careful not to overflow the receive ring, since we
can now resurrect n receive buffers in a row.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    3 +-
 drivers/net/sfc/net_driver.h |   18 +++++++++
 drivers/net/sfc/rx.c         |   84 +++++++++++++++++++++---------------------
 3 files changed, 62 insertions(+), 43 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 5d9ef05..aae3347 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -469,7 +469,8 @@ static void efx_init_channels(struct efx_nic *efx)
 	efx->rx_buffer_len = (max(EFX_PAGE_IP_ALIGN, NET_IP_ALIGN) +
 			      EFX_MAX_FRAME_LEN(efx->net_dev->mtu) +
 			      efx->type->rx_buffer_padding);
-	efx->rx_buffer_order = get_order(efx->rx_buffer_len);
+	efx->rx_buffer_order = get_order(efx->rx_buffer_len +
+					 sizeof(struct efx_rx_page_state));
 
 	/* Initialise the channels */
 	efx_for_each_channel(channel, efx) {
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 59c8ecc..40c0d93 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -232,6 +232,24 @@ struct efx_rx_buffer {
 };
 
 /**
+ * struct efx_rx_page_state - Page-based rx buffer state
+ *
+ * Inserted at the start of every page allocated for receive buffers.
+ * Used to facilitate sharing dma mappings between recycled rx buffers
+ * and those passed up to the kernel.
+ *
+ * @refcnt: Number of struct efx_rx_buffer's referencing this page.
+ *	When refcnt falls to zero, the page is unmapped for dma
+ * @dma_addr: The dma address of this page.
+ */
+struct efx_rx_page_state {
+	unsigned refcnt;
+	dma_addr_t dma_addr;
+
+	unsigned int __pad[0] ____cacheline_aligned;
+};
+
+/**
  * struct efx_rx_queue - An Efx RX queue
  * @efx: The associated Efx NIC
  * @queue: DMA queue number
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index dfebd73..9fb698e 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -25,6 +25,9 @@
 /* Number of RX descriptors pushed at once. */
 #define EFX_RX_BATCH  8
 
+/* Maximum size of a buffer sharing a page */
+#define EFX_RX_HALF_PAGE ((PAGE_SIZE >> 1) - sizeof(struct efx_rx_page_state))
+
 /* Size of buffer allocated for skb header area. */
 #define EFX_SKB_HEADERS  64u
 
@@ -82,10 +85,9 @@ static unsigned int rx_refill_limit = 95;
  * RX maximum head room required.
  *
  * This must be at least 1 to prevent overflow and at least 2 to allow
- * pipelined receives. Then a further 1 because efx_recycle_rx_buffer()
- * might insert two buffers.
+ * pipelined receives.
  */
-#define EFX_RXD_HEAD_ROOM 3
+#define EFX_RXD_HEAD_ROOM 2
 
 static inline unsigned int efx_rx_buf_offset(struct efx_rx_buffer *buf)
 {
@@ -164,7 +166,8 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 	struct efx_nic *efx = rx_queue->efx;
 	struct efx_rx_buffer *rx_buf;
 	struct page *page;
-	char *page_addr;
+	void *page_addr;
+	struct efx_rx_page_state *state;
 	dma_addr_t dma_addr;
 	unsigned index, count;
 
@@ -183,22 +186,27 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 			__free_pages(page, efx->rx_buffer_order);
 			return -EIO;
 		}
-		EFX_BUG_ON_PARANOID(dma_addr & (PAGE_SIZE - 1));
-		page_addr = page_address(page) + EFX_PAGE_IP_ALIGN;
-		dma_addr += EFX_PAGE_IP_ALIGN;
+		page_addr = page_address(page);
+		state = page_addr;
+		state->refcnt = 0;
+		state->dma_addr = dma_addr;
+
+		page_addr += sizeof(struct efx_rx_page_state);
+		dma_addr += sizeof(struct efx_rx_page_state);
 
 	split:
 		index = rx_queue->added_count & EFX_RXQ_MASK;
 		rx_buf = efx_rx_buffer(rx_queue, index);
-		rx_buf->dma_addr = dma_addr;
+		rx_buf->dma_addr = dma_addr + EFX_PAGE_IP_ALIGN;
 		rx_buf->skb = NULL;
 		rx_buf->page = page;
-		rx_buf->data = page_addr;
+		rx_buf->data = page_addr + EFX_PAGE_IP_ALIGN;
 		rx_buf->len = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
 		++rx_queue->added_count;
 		++rx_queue->alloc_page_count;
+		++state->refcnt;
 
-		if ((~count & 1) && (efx->rx_buffer_len < (PAGE_SIZE >> 1))) {
+		if ((~count & 1) && (efx->rx_buffer_len <= EFX_RX_HALF_PAGE)) {
 			/* Use the second half of the page */
 			get_page(page);
 			dma_addr += (PAGE_SIZE >> 1);
@@ -215,14 +223,14 @@ static void efx_unmap_rx_buffer(struct efx_nic *efx,
 				struct efx_rx_buffer *rx_buf)
 {
 	if (rx_buf->page) {
+		struct efx_rx_page_state *state;
+
 		EFX_BUG_ON_PARANOID(rx_buf->skb);
 
-		/* Unmap the buffer if there's only one buffer per page(s),
-		 * or this is the second half of a two buffer page. */
-		if (efx->rx_buffer_order != 0 ||
-		    (efx_rx_buf_offset(rx_buf) & (PAGE_SIZE >> 1)) != 0) {
+		state = page_address(rx_buf->page);
+		if (--state->refcnt == 0) {
 			pci_unmap_page(efx->pci_dev,
-				       rx_buf->dma_addr & ~(PAGE_SIZE - 1),
+				       state->dma_addr,
 				       efx_rx_buf_size(efx),
 				       PCI_DMA_FROMDEVICE);
 		}
@@ -256,21 +264,30 @@ static void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
 static void efx_resurrect_rx_buffer(struct efx_rx_queue *rx_queue,
 				    struct efx_rx_buffer *rx_buf)
 {
+	struct efx_rx_page_state *state = page_address(rx_buf->page);
 	struct efx_rx_buffer *new_buf;
-	unsigned index;
+	unsigned fill_level, index;
+
+	/* +1 because efx_rx_packet() incremented removed_count. +1 because
+	 * we'd like to insert an additional descriptor whilst leaving
+	 * EFX_RXD_HEAD_ROOM for the non-recycle path */
+	fill_level = (rx_queue->added_count - rx_queue->removed_count + 2);
+	if (unlikely(fill_level >= EFX_RXQ_SIZE - EFX_RXD_HEAD_ROOM)) {
+		/* We could place "state" on a list, and drain the list in
+		 * efx_fast_push_rx_descriptors(). For now, this will do. */
+		return;
+	}
 
-	/* We could have recycled the 1st half, then refilled
-	 * the queue, and now recycle the 2nd half.
-	 * EFX_RXD_HEAD_ROOM ensures that there is always room
-	 * to reinsert two buffers (once). */
+	++state->refcnt;
 	get_page(rx_buf->page);
 
 	index = rx_queue->added_count & EFX_RXQ_MASK;
 	new_buf = efx_rx_buffer(rx_queue, index);
-	new_buf->dma_addr = rx_buf->dma_addr - (PAGE_SIZE >> 1);
+	new_buf->dma_addr = rx_buf->dma_addr ^ (PAGE_SIZE >> 1);
 	new_buf->skb = NULL;
 	new_buf->page = rx_buf->page;
-	new_buf->data = rx_buf->data - (PAGE_SIZE >> 1);
+	new_buf->data = (void *)
+		((__force unsigned long)rx_buf->data ^ (PAGE_SIZE >> 1));
 	new_buf->len = rx_buf->len;
 	++rx_queue->added_count;
 }
@@ -285,26 +302,9 @@ static void efx_recycle_rx_buffer(struct efx_channel *channel,
 	struct efx_rx_buffer *new_buf;
 	unsigned index;
 
-	if (rx_buf->page != NULL && efx->rx_buffer_len < (PAGE_SIZE >> 1)) {
-		if (efx_rx_buf_offset(rx_buf) & (PAGE_SIZE >> 1)) {
-			/* This is the 2nd half of a page split between two
-			 * buffers, If page_count() is > 1 then the kernel
-			 * is holding onto the previous buffer */
-			if (page_count(rx_buf->page) != 1) {
-				efx_fini_rx_buffer(rx_queue, rx_buf);
-				return;
-			}
-
-			efx_resurrect_rx_buffer(rx_queue, rx_buf);
-		} else {
-			/* Free the 1st buffer's reference on the page. If the
-			 * 2nd buffer is also discarded, this buffer will be
-			 * resurrected above */
-			put_page(rx_buf->page);
-			rx_buf->page = NULL;
-			return;
-		}
-	}
+	if (rx_buf->page != NULL && efx->rx_buffer_len <= EFX_RX_HALF_PAGE &&
+	    page_count(rx_buf->page) == 1)
+		efx_resurrect_rx_buffer(rx_queue, rx_buf);
 
 	index = rx_queue->added_count & EFX_RXQ_MASK;
 	new_buf = efx_rx_buffer(rx_queue, index);
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

