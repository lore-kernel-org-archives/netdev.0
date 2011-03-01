From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/8] sfc: Reduce size of efx_rx_buffer further
 by removing data member
Date: Tue, 01 Mar 2011 01:22:16 +0000
Message-ID: <1298942536.3069.181.camel@localhost>
References: <1298942169.3069.179.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:11996 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541Ab1CABWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 20:22:21 -0500
In-Reply-To: <1298942169.3069.179.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Instead calculate the KVA of receive data. It's not like it's a hard sum.

[bwh: Fixed to work with GRO.]
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    2 -
 drivers/net/sfc/rx.c         |   50 +++++++++++++++++++++++------------------
 2 files changed, 28 insertions(+), 24 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 59ff32a..5b001c1 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -214,7 +214,6 @@ struct efx_tx_queue {
  *	If both this and page are %NULL, the buffer slot is currently free.
  * @page: The associated page buffer, if any.
  *	If both this and skb are %NULL, the buffer slot is currently free.
- * @data: Pointer to ethernet header
  * @len: Buffer length, in bytes.
  * @is_page: Indicates if @page is valid. If false, @skb is valid.
  */
@@ -224,7 +223,6 @@ struct efx_rx_buffer {
 		struct sk_buff *skb;
 		struct page *page;
 	} u;
-	char *data;
 	unsigned int len;
 	bool is_page;
 };
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index bcbd2ec..81bec87 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -89,24 +89,37 @@ static unsigned int rx_refill_limit = 95;
  */
 #define EFX_RXD_HEAD_ROOM 2
 
-static inline unsigned int efx_rx_buf_offset(struct efx_rx_buffer *buf)
+/* Offset of ethernet header within page */
+static inline unsigned int efx_rx_buf_offset(struct efx_nic *efx,
+					     struct efx_rx_buffer *buf)
 {
 	/* Offset is always within one page, so we don't need to consider
 	 * the page order.
 	 */
-	return (__force unsigned long) buf->data & (PAGE_SIZE - 1);
+	return (((__force unsigned long) buf->dma_addr & (PAGE_SIZE - 1)) +
+		efx->type->rx_buffer_hash_size);
 }
 static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
 {
 	return PAGE_SIZE << efx->rx_buffer_order;
 }
 
-static inline u32 efx_rx_buf_hash(struct efx_rx_buffer *buf)
+static u8 *efx_rx_buf_eh(struct efx_nic *efx, struct efx_rx_buffer *buf)
 {
+	if (buf->is_page)
+		return page_address(buf->u.page) + efx_rx_buf_offset(efx, buf);
+	else
+		return ((u8 *)buf->u.skb->data +
+			efx->type->rx_buffer_hash_size);
+}
+
+static inline u32 efx_rx_buf_hash(const u8 *eh)
+{
+	/* The ethernet header is always directly after any hash. */
 #if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) || NET_IP_ALIGN % 4 == 0
-	return __le32_to_cpup((const __le32 *)(buf->data - 4));
+	return __le32_to_cpup((const __le32 *)(eh - 4));
 #else
-	const u8 *data = (const u8 *)(buf->data - 4);
+	const u8 *data = eh - 4;
 	return ((u32)data[0]       |
 		(u32)data[1] << 8  |
 		(u32)data[2] << 16 |
@@ -143,13 +156,12 @@ static int efx_init_rx_buffers_skb(struct efx_rx_queue *rx_queue)
 
 		/* Adjust the SKB for padding and checksum */
 		skb_reserve(skb, NET_IP_ALIGN);
-		rx_buf->data = (char *)skb->data;
 		rx_buf->len = skb_len - NET_IP_ALIGN;
 		rx_buf->is_page = false;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 		rx_buf->dma_addr = pci_map_single(efx->pci_dev,
-						  rx_buf->data, rx_buf->len,
+						  skb->data, rx_buf->len,
 						  PCI_DMA_FROMDEVICE);
 		if (unlikely(pci_dma_mapping_error(efx->pci_dev,
 						   rx_buf->dma_addr))) {
@@ -213,7 +225,6 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 		rx_buf = efx_rx_buffer(rx_queue, index);
 		rx_buf->dma_addr = dma_addr + EFX_PAGE_IP_ALIGN;
 		rx_buf->u.page = page;
-		rx_buf->data = page_addr + EFX_PAGE_IP_ALIGN;
 		rx_buf->len = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
 		rx_buf->is_page = true;
 		++rx_queue->added_count;
@@ -297,8 +308,6 @@ static void efx_resurrect_rx_buffer(struct efx_rx_queue *rx_queue,
 	new_buf = efx_rx_buffer(rx_queue, index);
 	new_buf->dma_addr = rx_buf->dma_addr ^ (PAGE_SIZE >> 1);
 	new_buf->u.page = rx_buf->u.page;
-	new_buf->data = (void *)
-		((__force unsigned long)rx_buf->data ^ (PAGE_SIZE >> 1));
 	new_buf->len = rx_buf->len;
 	new_buf->is_page = true;
 	++rx_queue->added_count;
@@ -446,7 +455,7 @@ static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
  */
 static void efx_rx_packet_gro(struct efx_channel *channel,
 			      struct efx_rx_buffer *rx_buf,
-			      bool checksummed)
+			      const u8 *eh, bool checksummed)
 {
 	struct napi_struct *napi = &channel->napi_str;
 	gro_result_t gro_result;
@@ -466,11 +475,11 @@ static void efx_rx_packet_gro(struct efx_channel *channel,
 		}
 
 		if (efx->net_dev->features & NETIF_F_RXHASH)
-			skb->rxhash = efx_rx_buf_hash(rx_buf);
+			skb->rxhash = efx_rx_buf_hash(eh);
 
 		skb_shinfo(skb)->frags[0].page = page;
 		skb_shinfo(skb)->frags[0].page_offset =
-			efx_rx_buf_offset(rx_buf);
+			efx_rx_buf_offset(efx, rx_buf);
 		skb_shinfo(skb)->frags[0].size = rx_buf->len;
 		skb_shinfo(skb)->nr_frags = 1;
 
@@ -509,7 +518,6 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	bool leak_packet = false;
 
 	rx_buf = efx_rx_buffer(rx_queue, index);
-	EFX_BUG_ON_PARANOID(!rx_buf->data);
 
 	/* This allows the refill path to post another buffer.
 	 * EFX_RXD_HEAD_ROOM ensures that the slot we are using
@@ -548,12 +556,12 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	/* Prefetch nice and early so data will (hopefully) be in cache by
 	 * the time we look at it.
 	 */
-	prefetch(rx_buf->data);
+	prefetch(efx_rx_buf_eh(efx, rx_buf));
 
 	/* Pipeline receives so that we give time for packet headers to be
 	 * prefetched into cache.
 	 */
-	rx_buf->len = len;
+	rx_buf->len = len - efx->type->rx_buffer_hash_size;
 out:
 	if (channel->rx_pkt)
 		__efx_rx_packet(channel,
@@ -568,15 +576,13 @@ void __efx_rx_packet(struct efx_channel *channel,
 {
 	struct efx_nic *efx = channel->efx;
 	struct sk_buff *skb;
-
-	rx_buf->data += efx->type->rx_buffer_hash_size;
-	rx_buf->len -= efx->type->rx_buffer_hash_size;
+	u8 *eh = efx_rx_buf_eh(efx, rx_buf);
 
 	/* If we're in loopback test, then pass the packet directly to the
 	 * loopback layer, and free the rx_buf here
 	 */
 	if (unlikely(efx->loopback_selftest)) {
-		efx_loopback_rx_packet(efx, rx_buf->data, rx_buf->len);
+		efx_loopback_rx_packet(efx, eh, rx_buf->len);
 		efx_free_rx_buffer(efx, rx_buf);
 		return;
 	}
@@ -590,7 +596,7 @@ void __efx_rx_packet(struct efx_channel *channel,
 		skb_put(skb, rx_buf->len);
 
 		if (efx->net_dev->features & NETIF_F_RXHASH)
-			skb->rxhash = efx_rx_buf_hash(rx_buf);
+			skb->rxhash = efx_rx_buf_hash(eh);
 
 		/* Move past the ethernet header. rx_buf->data still points
 		 * at the ethernet header */
@@ -600,7 +606,7 @@ void __efx_rx_packet(struct efx_channel *channel,
 	}
 
 	if (likely(checksummed || rx_buf->is_page)) {
-		efx_rx_packet_gro(channel, rx_buf, checksummed);
+		efx_rx_packet_gro(channel, rx_buf, eh, checksummed);
 		return;
 	}
 
-- 
1.5.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

