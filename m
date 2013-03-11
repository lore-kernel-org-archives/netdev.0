From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 18/22] sfc: Update RX buffer address together with
 length
Date: Mon, 11 Mar 2013 19:57:26 +0000
Message-ID: <1363031846.2608.55.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16854 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754326Ab3CKT53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:57:29 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adjust rx_buf->page_offset when we eat the RX hash prefix.  Remove
efx_rx_buf_offset(), which is now redundant.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    3 ++-
 drivers/net/ethernet/sfc/rx.c         |   18 ++++++------------
 2 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 3fd6dbe..1bc911f 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -208,7 +208,8 @@ struct efx_tx_queue {
  * @dma_addr: DMA base address of the buffer
  * @page: The associated page buffer.
  *	Will be %NULL if the buffer slot is currently free.
- * @page_offset: Offset within page
+ * @page_offset: If pending: offset in @page of DMA base address.
+ *	If completed: offset in @page of Ethernet header.
  * @len: If pending: length for DMA descriptor.
  *	If completed: received length, excluding hash prefix.
  * @flags: Flags for buffer and packet state.
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 8e78a2f..0451872 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -47,13 +47,6 @@ static unsigned int rx_refill_threshold;
  */
 #define EFX_RXD_HEAD_ROOM 2
 
-/* Offset of ethernet header within page */
-static inline unsigned int efx_rx_buf_offset(struct efx_nic *efx,
-					     struct efx_rx_buffer *buf)
-{
-	return buf->page_offset + efx->type->rx_buffer_hash_size;
-}
-
 static inline u8 *efx_rx_buf_va(struct efx_rx_buffer *buf)
 {
 	return page_address(buf->page) + buf->page_offset;
@@ -356,8 +349,7 @@ static void efx_rx_packet_gro(struct efx_channel *channel,
 	if (efx->net_dev->features & NETIF_F_RXHASH)
 		skb->rxhash = efx_rx_buf_hash(eh);
 
-	skb_fill_page_desc(skb, 0, page,
-			   efx_rx_buf_offset(efx, rx_buf), rx_buf->len);
+	skb_fill_page_desc(skb, 0, page, rx_buf->page_offset, rx_buf->len);
 
 	skb->len = rx_buf->len;
 	skb->data_len = rx_buf->len;
@@ -399,7 +391,7 @@ static struct sk_buff *efx_rx_mk_skb(struct efx_channel *channel,
 	if (rx_buf->len > hdr_len) {
 		skb->data_len = skb->len - hdr_len;
 		skb_fill_page_desc(skb, 0, rx_buf->page,
-				   efx_rx_buf_offset(efx, rx_buf) + hdr_len,
+				   rx_buf->page_offset + hdr_len,
 				   skb->data_len);
 	} else {
 		__free_pages(rx_buf->page, efx->rx_buffer_order);
@@ -460,10 +452,12 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	 */
 	prefetch(efx_rx_buf_va(rx_buf));
 
+	rx_buf->page_offset += efx->type->rx_buffer_hash_size;
+	rx_buf->len = len - efx->type->rx_buffer_hash_size;
+
 	/* Pipeline receives so that we give time for packet headers to be
 	 * prefetched into cache.
 	 */
-	rx_buf->len = len - efx->type->rx_buffer_hash_size;
 out:
 	efx_rx_flush_packet(channel);
 	channel->rx_pkt = rx_buf;
@@ -497,7 +491,7 @@ static void efx_rx_deliver(struct efx_channel *channel, u8 *eh,
 void __efx_rx_packet(struct efx_channel *channel, struct efx_rx_buffer *rx_buf)
 {
 	struct efx_nic *efx = channel->efx;
-	u8 *eh = efx_rx_buf_va(rx_buf) + efx->type->rx_buffer_hash_size;
+	u8 *eh = efx_rx_buf_va(rx_buf);
 
 	/* If we're in loopback test, then pass the packet directly to the
 	 * loopback layer, and free the rx_buf here
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
