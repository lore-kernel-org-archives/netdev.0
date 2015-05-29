From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net 1/1] sfc: free multiple Rx buffers when required
Date: Fri, 29 May 2015 12:25:54 +0100
Message-ID: <55684CC2.2010202@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:40015 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755485AbbE2L0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 07:26:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

When Rx packet data must be dropped, all the buffers
associated with that Rx packet must be freed. Extend
and rename efx_free_rx_buffer() to efx_free_rx_buffers()
and loop through all the fragments.
By doing so this patch fixes a possible memory leak.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c | 42 +++++++++++++++++++++++++-----------------
 1 file changed, 25 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index c0ad95d..809ea461 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -224,12 +224,17 @@ static void efx_unmap_rx_buffer(struct efx_nic *efx,
 	}
 }
 
-static void efx_free_rx_buffer(struct efx_rx_buffer *rx_buf)
+static void efx_free_rx_buffers(struct efx_rx_queue *rx_queue,
+				struct efx_rx_buffer *rx_buf,
+				unsigned int num_bufs)
 {
-	if (rx_buf->page) {
-		put_page(rx_buf->page);
-		rx_buf->page = NULL;
-	}
+	do {
+		if (rx_buf->page) {
+			put_page(rx_buf->page);
+			rx_buf->page = NULL;
+		}
+		rx_buf = efx_rx_buf_next(rx_queue, rx_buf);
+	} while (--num_bufs);
 }
 
 /* Attempt to recycle the page if there is an RX recycle ring; the page can
@@ -278,7 +283,7 @@ static void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
 	/* If this is the last buffer in a page, unmap and free it. */
 	if (rx_buf->flags & EFX_RX_BUF_LAST_IN_PAGE) {
 		efx_unmap_rx_buffer(rx_queue->efx, rx_buf);
-		efx_free_rx_buffer(rx_buf);
+		efx_free_rx_buffers(rx_queue, rx_buf, 1);
 	}
 	rx_buf->page = NULL;
 }
@@ -304,10 +309,7 @@ static void efx_discard_rx_packet(struct efx_channel *channel,
 
 	efx_recycle_rx_pages(channel, rx_buf, n_frags);
 
-	do {
-		efx_free_rx_buffer(rx_buf);
-		rx_buf = efx_rx_buf_next(rx_queue, rx_buf);
-	} while (--n_frags);
+	efx_free_rx_buffers(rx_queue, rx_buf, n_frags);
 }
 
 /**
@@ -431,11 +433,10 @@ efx_rx_packet_gro(struct efx_channel *channel, struct efx_rx_buffer *rx_buf,
 
 	skb = napi_get_frags(napi);
 	if (unlikely(!skb)) {
-		while (n_frags--) {
-			put_page(rx_buf->page);
-			rx_buf->page = NULL;
-			rx_buf = efx_rx_buf_next(&channel->rx_queue, rx_buf);
-		}
+		struct efx_rx_queue *rx_queue;
+
+		rx_queue = efx_channel_get_rx_queue(channel);
+		efx_free_rx_buffers(rx_queue, rx_buf, n_frags);
 		return;
 	}
 
@@ -622,7 +623,10 @@ static void efx_rx_deliver(struct efx_channel *channel, u8 *eh,
 
 	skb = efx_rx_mk_skb(channel, rx_buf, n_frags, eh, hdr_len);
 	if (unlikely(skb == NULL)) {
-		efx_free_rx_buffer(rx_buf);
+		struct efx_rx_queue *rx_queue;
+
+		rx_queue = efx_channel_get_rx_queue(channel);
+		efx_free_rx_buffers(rx_queue, rx_buf, n_frags);
 		return;
 	}
 	skb_record_rx_queue(skb, channel->rx_queue.core_index);
@@ -661,8 +665,12 @@ void __efx_rx_packet(struct efx_channel *channel)
 	 * loopback layer, and free the rx_buf here
 	 */
 	if (unlikely(efx->loopback_selftest)) {
+		struct efx_rx_queue *rx_queue;
+
 		efx_loopback_rx_packet(efx, eh, rx_buf->len);
-		efx_free_rx_buffer(rx_buf);
+		rx_queue = efx_channel_get_rx_queue(channel);
+		efx_free_rx_buffers(rx_queue, rx_buf,
+				    channel->rx_pkt_n_frags);
 		goto out;
 	}
 
