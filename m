From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6] sfc: Reduce size of efx_rx_buffer by
 unionising skb and page
Date: Tue, 01 Mar 2011 01:21:30 +0000
Message-ID: <1298942490.3069.180.camel@localhost>
References: <1298942169.3069.179.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:11919 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541Ab1CABVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 20:21:47 -0500
In-Reply-To: <1298942169.3069.179.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

[bwh: Forward-ported to net-next-2.6.]
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    8 +++-
 drivers/net/sfc/rx.c         |   96 +++++++++++++++++++----------------------
 2 files changed, 51 insertions(+), 53 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 15b9068..59ff32a 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -216,13 +216,17 @@ struct efx_tx_queue {
  *	If both this and skb are %NULL, the buffer slot is currently free.
  * @data: Pointer to ethernet header
  * @len: Buffer length, in bytes.
+ * @is_page: Indicates if @page is valid. If false, @skb is valid.
  */
 struct efx_rx_buffer {
 	dma_addr_t dma_addr;
-	struct sk_buff *skb;
-	struct page *page;
+	union {
+		struct sk_buff *skb;
+		struct page *page;
+	} u;
 	char *data;
 	unsigned int len;
+	bool is_page;
 };
 
 /**
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 3925fd6..bcbd2ec 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -129,6 +129,7 @@ static int efx_init_rx_buffers_skb(struct efx_rx_queue *rx_queue)
 	struct efx_nic *efx = rx_queue->efx;
 	struct net_device *net_dev = efx->net_dev;
 	struct efx_rx_buffer *rx_buf;
+	struct sk_buff *skb;
 	int skb_len = efx->rx_buffer_len;
 	unsigned index, count;
 
@@ -136,24 +137,24 @@ static int efx_init_rx_buffers_skb(struct efx_rx_queue *rx_queue)
 		index = rx_queue->added_count & rx_queue->ptr_mask;
 		rx_buf = efx_rx_buffer(rx_queue, index);
 
-		rx_buf->skb = netdev_alloc_skb(net_dev, skb_len);
-		if (unlikely(!rx_buf->skb))
+		rx_buf->u.skb = skb = netdev_alloc_skb(net_dev, skb_len);
+		if (unlikely(!skb))
 			return -ENOMEM;
-		rx_buf->page = NULL;
 
 		/* Adjust the SKB for padding and checksum */
-		skb_reserve(rx_buf->skb, NET_IP_ALIGN);
+		skb_reserve(skb, NET_IP_ALIGN);
+		rx_buf->data = (char *)skb->data;
 		rx_buf->len = skb_len - NET_IP_ALIGN;
-		rx_buf->data = (char *)rx_buf->skb->data;
-		rx_buf->skb->ip_summed = CHECKSUM_UNNECESSARY;
+		rx_buf->is_page = false;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 		rx_buf->dma_addr = pci_map_single(efx->pci_dev,
 						  rx_buf->data, rx_buf->len,
 						  PCI_DMA_FROMDEVICE);
 		if (unlikely(pci_dma_mapping_error(efx->pci_dev,
 						   rx_buf->dma_addr))) {
-			dev_kfree_skb_any(rx_buf->skb);
-			rx_buf->skb = NULL;
+			dev_kfree_skb_any(skb);
+			rx_buf->u.skb = NULL;
 			return -EIO;
 		}
 
@@ -211,10 +212,10 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 		index = rx_queue->added_count & rx_queue->ptr_mask;
 		rx_buf = efx_rx_buffer(rx_queue, index);
 		rx_buf->dma_addr = dma_addr + EFX_PAGE_IP_ALIGN;
-		rx_buf->skb = NULL;
-		rx_buf->page = page;
+		rx_buf->u.page = page;
 		rx_buf->data = page_addr + EFX_PAGE_IP_ALIGN;
 		rx_buf->len = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
+		rx_buf->is_page = true;
 		++rx_queue->added_count;
 		++rx_queue->alloc_page_count;
 		++state->refcnt;
@@ -235,19 +236,17 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 static void efx_unmap_rx_buffer(struct efx_nic *efx,
 				struct efx_rx_buffer *rx_buf)
 {
-	if (rx_buf->page) {
+	if (rx_buf->is_page && rx_buf->u.page) {
 		struct efx_rx_page_state *state;
 
-		EFX_BUG_ON_PARANOID(rx_buf->skb);
-
-		state = page_address(rx_buf->page);
+		state = page_address(rx_buf->u.page);
 		if (--state->refcnt == 0) {
 			pci_unmap_page(efx->pci_dev,
 				       state->dma_addr,
 				       efx_rx_buf_size(efx),
 				       PCI_DMA_FROMDEVICE);
 		}
-	} else if (likely(rx_buf->skb)) {
+	} else if (!rx_buf->is_page && rx_buf->u.skb) {
 		pci_unmap_single(efx->pci_dev, rx_buf->dma_addr,
 				 rx_buf->len, PCI_DMA_FROMDEVICE);
 	}
@@ -256,12 +255,12 @@ static void efx_unmap_rx_buffer(struct efx_nic *efx,
 static void efx_free_rx_buffer(struct efx_nic *efx,
 			       struct efx_rx_buffer *rx_buf)
 {
-	if (rx_buf->page) {
-		__free_pages(rx_buf->page, efx->rx_buffer_order);
-		rx_buf->page = NULL;
-	} else if (likely(rx_buf->skb)) {
-		dev_kfree_skb_any(rx_buf->skb);
-		rx_buf->skb = NULL;
+	if (rx_buf->is_page && rx_buf->u.page) {
+		__free_pages(rx_buf->u.page, efx->rx_buffer_order);
+		rx_buf->u.page = NULL;
+	} else if (!rx_buf->is_page && rx_buf->u.skb) {
+		dev_kfree_skb_any(rx_buf->u.skb);
+		rx_buf->u.skb = NULL;
 	}
 }
 
@@ -277,7 +276,7 @@ static void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
 static void efx_resurrect_rx_buffer(struct efx_rx_queue *rx_queue,
 				    struct efx_rx_buffer *rx_buf)
 {
-	struct efx_rx_page_state *state = page_address(rx_buf->page);
+	struct efx_rx_page_state *state = page_address(rx_buf->u.page);
 	struct efx_rx_buffer *new_buf;
 	unsigned fill_level, index;
 
@@ -292,16 +291,16 @@ static void efx_resurrect_rx_buffer(struct efx_rx_queue *rx_queue,
 	}
 
 	++state->refcnt;
-	get_page(rx_buf->page);
+	get_page(rx_buf->u.page);
 
 	index = rx_queue->added_count & rx_queue->ptr_mask;
 	new_buf = efx_rx_buffer(rx_queue, index);
 	new_buf->dma_addr = rx_buf->dma_addr ^ (PAGE_SIZE >> 1);
-	new_buf->skb = NULL;
-	new_buf->page = rx_buf->page;
+	new_buf->u.page = rx_buf->u.page;
 	new_buf->data = (void *)
 		((__force unsigned long)rx_buf->data ^ (PAGE_SIZE >> 1));
 	new_buf->len = rx_buf->len;
+	new_buf->is_page = true;
 	++rx_queue->added_count;
 }
 
@@ -315,16 +314,15 @@ static void efx_recycle_rx_buffer(struct efx_channel *channel,
 	struct efx_rx_buffer *new_buf;
 	unsigned index;
 
-	if (rx_buf->page != NULL && efx->rx_buffer_len <= EFX_RX_HALF_PAGE &&
-	    page_count(rx_buf->page) == 1)
+	if (rx_buf->is_page && efx->rx_buffer_len <= EFX_RX_HALF_PAGE &&
+	    page_count(rx_buf->u.page) == 1)
 		efx_resurrect_rx_buffer(rx_queue, rx_buf);
 
 	index = rx_queue->added_count & rx_queue->ptr_mask;
 	new_buf = efx_rx_buffer(rx_queue, index);
 
 	memcpy(new_buf, rx_buf, sizeof(*new_buf));
-	rx_buf->page = NULL;
-	rx_buf->skb = NULL;
+	rx_buf->u.page = NULL;
 	++rx_queue->added_count;
 }
 
@@ -428,7 +426,7 @@ static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
 		 * data at the end of the skb will be trashed. So
 		 * we have no choice but to leak the fragment.
 		 */
-		*leak_packet = (rx_buf->skb != NULL);
+		*leak_packet = !rx_buf->is_page;
 		efx_schedule_reset(efx, RESET_TYPE_RX_RECOVERY);
 	} else {
 		if (net_ratelimit())
@@ -454,13 +452,12 @@ static void efx_rx_packet_gro(struct efx_channel *channel,
 	gro_result_t gro_result;
 
 	/* Pass the skb/page into the GRO engine */
-	if (rx_buf->page) {
+	if (rx_buf->is_page) {
 		struct efx_nic *efx = channel->efx;
-		struct page *page = rx_buf->page;
+		struct page *page = rx_buf->u.page;
 		struct sk_buff *skb;
 
-		EFX_BUG_ON_PARANOID(rx_buf->skb);
-		rx_buf->page = NULL;
+		rx_buf->u.page = NULL;
 
 		skb = napi_get_frags(napi);
 		if (!skb) {
@@ -487,11 +484,10 @@ static void efx_rx_packet_gro(struct efx_channel *channel,
 
 		gro_result = napi_gro_frags(napi);
 	} else {
-		struct sk_buff *skb = rx_buf->skb;
+		struct sk_buff *skb = rx_buf->u.skb;
 
-		EFX_BUG_ON_PARANOID(!skb);
 		EFX_BUG_ON_PARANOID(!checksummed);
-		rx_buf->skb = NULL;
+		rx_buf->u.skb = NULL;
 
 		gro_result = napi_gro_receive(napi, skb);
 	}
@@ -514,8 +510,6 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 
 	rx_buf = efx_rx_buffer(rx_queue, index);
 	EFX_BUG_ON_PARANOID(!rx_buf->data);
-	EFX_BUG_ON_PARANOID(rx_buf->skb && rx_buf->page);
-	EFX_BUG_ON_PARANOID(!(rx_buf->skb || rx_buf->page));
 
 	/* This allows the refill path to post another buffer.
 	 * EFX_RXD_HEAD_ROOM ensures that the slot we are using
@@ -587,32 +581,32 @@ void __efx_rx_packet(struct efx_channel *channel,
 		return;
 	}
 
-	if (rx_buf->skb) {
-		prefetch(skb_shinfo(rx_buf->skb));
+	if (!rx_buf->is_page) {
+		skb = rx_buf->u.skb;
+
+		prefetch(skb_shinfo(skb));
 
-		skb_reserve(rx_buf->skb, efx->type->rx_buffer_hash_size);
-		skb_put(rx_buf->skb, rx_buf->len);
+		skb_reserve(skb, efx->type->rx_buffer_hash_size);
+		skb_put(skb, rx_buf->len);
 
 		if (efx->net_dev->features & NETIF_F_RXHASH)
-			rx_buf->skb->rxhash = efx_rx_buf_hash(rx_buf);
+			skb->rxhash = efx_rx_buf_hash(rx_buf);
 
 		/* Move past the ethernet header. rx_buf->data still points
 		 * at the ethernet header */
-		rx_buf->skb->protocol = eth_type_trans(rx_buf->skb,
-						       efx->net_dev);
+		skb->protocol = eth_type_trans(skb, efx->net_dev);
 
-		skb_record_rx_queue(rx_buf->skb, channel->channel);
+		skb_record_rx_queue(skb, channel->channel);
 	}
 
-	if (likely(checksummed || rx_buf->page)) {
+	if (likely(checksummed || rx_buf->is_page)) {
 		efx_rx_packet_gro(channel, rx_buf, checksummed);
 		return;
 	}
 
 	/* We now own the SKB */
-	skb = rx_buf->skb;
-	rx_buf->skb = NULL;
-	EFX_BUG_ON_PARANOID(!skb);
+	skb = rx_buf->u.skb;
+	rx_buf->u.skb = NULL;
 
 	/* Set the SKB flags */
 	skb_checksum_none_assert(skb);
-- 
1.5.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

