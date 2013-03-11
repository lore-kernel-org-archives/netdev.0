From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 13/22] sfc: Properly distinguish RX buffer and DMA
 lengths
Date: Mon, 11 Mar 2013 19:56:05 +0000
Message-ID: <1363031765.2608.50.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16803 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754336Ab3CKT4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:56:08 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace efx_nic::rx_buffer_len with efx_nic::rx_dma_len, the maximum
RX DMA length.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |   11 +++++------
 drivers/net/ethernet/sfc/net_driver.h |    5 ++---
 drivers/net/ethernet/sfc/rx.c         |   19 ++++++++-----------
 3 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 5e1ddc5..34b56ec 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -639,12 +639,11 @@ static void efx_start_datapath(struct efx_nic *efx)
 	 * support the current MTU, including padding for header
 	 * alignment and overruns.
 	 */
-	efx->rx_buffer_len = (max(EFX_PAGE_IP_ALIGN, NET_IP_ALIGN) +
-			      EFX_MAX_FRAME_LEN(efx->net_dev->mtu) +
-			      efx->type->rx_buffer_hash_size +
-			      efx->type->rx_buffer_padding);
-	efx->rx_buffer_order = get_order(efx->rx_buffer_len +
-					 sizeof(struct efx_rx_page_state));
+	efx->rx_dma_len = (efx->type->rx_buffer_hash_size +
+			   EFX_MAX_FRAME_LEN(efx->net_dev->mtu) +
+			   efx->type->rx_buffer_padding);
+	efx->rx_buffer_order = get_order(sizeof(struct efx_rx_page_state) +
+					 EFX_PAGE_IP_ALIGN + efx->rx_dma_len);
 
 	/* We must keep at least one descriptor in a TX ring empty.
 	 * We could avoid this when the queue size does not exactly
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index f74411f..fc6770e 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -669,8 +669,7 @@ struct vfdi_status;
  * @n_channels: Number of channels in use
  * @n_rx_channels: Number of channels used for RX (= number of RX queues)
  * @n_tx_channels: Number of channels used for TX
- * @rx_buffer_len: RX buffer length, including start alignment but excluding
- *	any metadata
+ * @rx_dma_len: Current maximum RX DMA length
  * @rx_buffer_order: Order (log2) of number of pages for each RX buffer
  * @rx_hash_key: Toeplitz hash key for RSS
  * @rx_indir_table: Indirection table for RSS
@@ -786,7 +785,7 @@ struct efx_nic {
 	unsigned rss_spread;
 	unsigned tx_channel_offset;
 	unsigned n_tx_channels;
-	unsigned int rx_buffer_len;
+	unsigned int rx_dma_len;
 	unsigned int rx_buffer_order;
 	u8 rx_hash_key[40];
 	u32 rx_indir_table[128];
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index e7aa28e..31361db 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -27,8 +27,9 @@
 /* Number of RX descriptors pushed at once. */
 #define EFX_RX_BATCH  8
 
-/* Maximum size of a buffer sharing a page */
-#define EFX_RX_HALF_PAGE ((PAGE_SIZE >> 1) - sizeof(struct efx_rx_page_state))
+/* Maximum length for an RX descriptor sharing a page */
+#define EFX_RX_HALF_PAGE ((PAGE_SIZE >> 1) - sizeof(struct efx_rx_page_state) \
+			  - EFX_PAGE_IP_ALIGN)
 
 /* Size of buffer allocated for skb header area. */
 #define EFX_SKB_HEADERS  64u
@@ -52,10 +53,6 @@ static inline unsigned int efx_rx_buf_offset(struct efx_nic *efx,
 {
 	return buf->page_offset + efx->type->rx_buffer_hash_size;
 }
-static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
-{
-	return PAGE_SIZE << efx->rx_buffer_order;
-}
 
 static u8 *efx_rx_buf_eh(struct efx_nic *efx, struct efx_rx_buffer *buf)
 {
@@ -105,7 +102,7 @@ static int efx_init_rx_buffers(struct efx_rx_queue *rx_queue)
 		if (unlikely(page == NULL))
 			return -ENOMEM;
 		dma_addr = dma_map_page(&efx->pci_dev->dev, page, 0,
-					efx_rx_buf_size(efx),
+					PAGE_SIZE << efx->rx_buffer_order,
 					DMA_FROM_DEVICE);
 		if (unlikely(dma_mapping_error(&efx->pci_dev->dev, dma_addr))) {
 			__free_pages(page, efx->rx_buffer_order);
@@ -124,12 +121,12 @@ static int efx_init_rx_buffers(struct efx_rx_queue *rx_queue)
 		rx_buf->dma_addr = dma_addr + EFX_PAGE_IP_ALIGN;
 		rx_buf->page = page;
 		rx_buf->page_offset = page_offset + EFX_PAGE_IP_ALIGN;
-		rx_buf->len = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
+		rx_buf->len = efx->rx_dma_len;
 		rx_buf->flags = 0;
 		++rx_queue->added_count;
 		++state->refcnt;
 
-		if ((~count & 1) && (efx->rx_buffer_len <= EFX_RX_HALF_PAGE)) {
+		if ((~count & 1) && (efx->rx_dma_len <= EFX_RX_HALF_PAGE)) {
 			/* Use the second half of the page */
 			get_page(page);
 			dma_addr += (PAGE_SIZE >> 1);
@@ -153,7 +150,7 @@ static void efx_unmap_rx_buffer(struct efx_nic *efx,
 		if (--state->refcnt == 0) {
 			dma_unmap_page(&efx->pci_dev->dev,
 				       state->dma_addr,
-				       efx_rx_buf_size(efx),
+				       PAGE_SIZE << efx->rx_buffer_order,
 				       DMA_FROM_DEVICE);
 		} else if (used_len) {
 			dma_sync_single_for_cpu(&efx->pci_dev->dev,
@@ -221,7 +218,7 @@ static void efx_recycle_rx_buffer(struct efx_channel *channel,
 
 	rx_buf->flags = 0;
 
-	if (efx->rx_buffer_len <= EFX_RX_HALF_PAGE &&
+	if (efx->rx_dma_len <= EFX_RX_HALF_PAGE &&
 	    page_count(rx_buf->page) == 1)
 		efx_resurrect_rx_buffer(rx_queue, rx_buf);
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
