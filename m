From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 09/12] sfc: Recycle discarded rx buffers back onto the queue
Date: Tue, 01 Jun 2010 22:20:34 +0100
Message-ID: <1275427234.2114.33.camel@achroite.uk.solarflarecom.com>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:50805 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206Ab0FAVUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 17:20:37 -0400
In-Reply-To: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

The cut-through design of the receive path means that packets that
fail to match the appropriate MAC filter are not discarded at the MAC
but are flagged in the completion event as 'to be discarded'.  On
networks with heavy multicast traffic, this can account for a
significant proportion of received packets, so it is worthwhile to
recycle the buffer immediately in this case rather than freeing it
and then reallocating it shortly after.

The only complication here is dealing with a page shared
between two receive buffers. In that case, we need to be
careful to free the dma mapping when both buffers have
been free'd by the kernel. This means that we can only
recycle such a page if both receive buffers are discarded.
Unfortunately, in an environment with 1500mtu,
rx_alloc_method=PAGE, and a mixture of discarded and
not-discarded frames hitting the same receive queue,
buffer recycling won't always be possible.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/rx.c |   90 +++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 79 insertions(+), 11 deletions(-)

diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 615a1fc..dfebd73 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -82,9 +82,10 @@ static unsigned int rx_refill_limit = 95;
  * RX maximum head room required.
  *
  * This must be at least 1 to prevent overflow and at least 2 to allow
- * pipelined receives.
+ * pipelined receives. Then a further 1 because efx_recycle_rx_buffer()
+ * might insert two buffers.
  */
-#define EFX_RXD_HEAD_ROOM 2
+#define EFX_RXD_HEAD_ROOM 3
 
 static inline unsigned int efx_rx_buf_offset(struct efx_rx_buffer *buf)
 {
@@ -250,6 +251,70 @@ static void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
 	efx_free_rx_buffer(rx_queue->efx, rx_buf);
 }
 
+/* Attempt to resurrect the other receive buffer that used to share this page,
+ * which had previously been passed up to the kernel and freed. */
+static void efx_resurrect_rx_buffer(struct efx_rx_queue *rx_queue,
+				    struct efx_rx_buffer *rx_buf)
+{
+	struct efx_rx_buffer *new_buf;
+	unsigned index;
+
+	/* We could have recycled the 1st half, then refilled
+	 * the queue, and now recycle the 2nd half.
+	 * EFX_RXD_HEAD_ROOM ensures that there is always room
+	 * to reinsert two buffers (once). */
+	get_page(rx_buf->page);
+
+	index = rx_queue->added_count & EFX_RXQ_MASK;
+	new_buf = efx_rx_buffer(rx_queue, index);
+	new_buf->dma_addr = rx_buf->dma_addr - (PAGE_SIZE >> 1);
+	new_buf->skb = NULL;
+	new_buf->page = rx_buf->page;
+	new_buf->data = rx_buf->data - (PAGE_SIZE >> 1);
+	new_buf->len = rx_buf->len;
+	++rx_queue->added_count;
+}
+
+/* Recycle the given rx buffer directly back into the rx_queue. There is
+ * always room to add this buffer, because we've just popped a buffer. */
+static void efx_recycle_rx_buffer(struct efx_channel *channel,
+				  struct efx_rx_buffer *rx_buf)
+{
+	struct efx_nic *efx = channel->efx;
+	struct efx_rx_queue *rx_queue = &efx->rx_queue[channel->channel];
+	struct efx_rx_buffer *new_buf;
+	unsigned index;
+
+	if (rx_buf->page != NULL && efx->rx_buffer_len < (PAGE_SIZE >> 1)) {
+		if (efx_rx_buf_offset(rx_buf) & (PAGE_SIZE >> 1)) {
+			/* This is the 2nd half of a page split between two
+			 * buffers, If page_count() is > 1 then the kernel
+			 * is holding onto the previous buffer */
+			if (page_count(rx_buf->page) != 1) {
+				efx_fini_rx_buffer(rx_queue, rx_buf);
+				return;
+			}
+
+			efx_resurrect_rx_buffer(rx_queue, rx_buf);
+		} else {
+			/* Free the 1st buffer's reference on the page. If the
+			 * 2nd buffer is also discarded, this buffer will be
+			 * resurrected above */
+			put_page(rx_buf->page);
+			rx_buf->page = NULL;
+			return;
+		}
+	}
+
+	index = rx_queue->added_count & EFX_RXQ_MASK;
+	new_buf = efx_rx_buffer(rx_queue, index);
+
+	memcpy(new_buf, rx_buf, sizeof(*new_buf));
+	rx_buf->page = NULL;
+	rx_buf->skb = NULL;
+	++rx_queue->added_count;
+}
+
 /**
  * efx_fast_push_rx_descriptors - push new RX descriptors quickly
  * @rx_queue:		RX descriptor queue
@@ -271,7 +336,7 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 	fill_level = (rx_queue->added_count - rx_queue->removed_count);
 	EFX_BUG_ON_PARANOID(fill_level > EFX_RXQ_SIZE);
 	if (fill_level >= rx_queue->fast_fill_trigger)
-		return;
+		goto out;
 
 	/* Record minimum fill level */
 	if (unlikely(fill_level < rx_queue->min_fill)) {
@@ -281,7 +346,7 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 
 	space = rx_queue->fast_fill_limit - fill_level;
 	if (space < EFX_RX_BATCH)
-		return;
+		goto out;
 
 	EFX_TRACE(rx_queue->efx, "RX queue %d fast-filling descriptor ring from"
 		  " level %d to level %d using %s allocation\n",
@@ -306,8 +371,8 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 		  rx_queue->added_count - rx_queue->removed_count);
 
  out:
-	/* Send write pointer to card. */
-	efx_nic_notify_rx_desc(rx_queue);
+	if (rx_queue->notified_count != rx_queue->added_count)
+		efx_nic_notify_rx_desc(rx_queue);
 }
 
 void efx_rx_slow_fill(unsigned long context)
@@ -418,6 +483,7 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 		   unsigned int len, bool checksummed, bool discard)
 {
 	struct efx_nic *efx = rx_queue->efx;
+	struct efx_channel *channel = rx_queue->channel;
 	struct efx_rx_buffer *rx_buf;
 	bool leak_packet = false;
 
@@ -445,12 +511,13 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	/* Discard packet, if instructed to do so */
 	if (unlikely(discard)) {
 		if (unlikely(leak_packet))
-			rx_queue->channel->n_skbuff_leaks++;
+			channel->n_skbuff_leaks++;
 		else
-			/* We haven't called efx_unmap_rx_buffer yet,
-			 * so fini the entire rx_buffer here */
-			efx_fini_rx_buffer(rx_queue, rx_buf);
-		return;
+			efx_recycle_rx_buffer(channel, rx_buf);
+
+		/* Don't hold off the previous receive */
+		rx_buf = NULL;
+		goto out;
 	}
 
 	/* Release card resources - assumes all RX buffers consumed in-order
@@ -467,6 +534,7 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	 * prefetched into cache.
 	 */
 	rx_buf->len = len;
+out:
 	if (rx_queue->channel->rx_pkt)
 		__efx_rx_packet(rx_queue->channel,
 				rx_queue->channel->rx_pkt,
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

