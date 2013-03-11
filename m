From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 21/22] sfc: Replace efx_rx_is_last_buffer() with a
 flag
Date: Mon, 11 Mar 2013 19:59:21 +0000
Message-ID: <1363031961.2608.58.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16880 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754481Ab3CKT7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:59:24 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This condition is brittle and we have lots of flags to spare.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    1 +
 drivers/net/ethernet/sfc/rx.c         |   17 ++++++-----------
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 370c5bc..e22e75c 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -228,6 +228,7 @@ struct efx_rx_buffer {
 	u16 len;
 	u16 flags;
 };
+#define EFX_RX_BUF_LAST_IN_PAGE	0x0001
 #define EFX_RX_PKT_CSUMMED	0x0002
 #define EFX_RX_PKT_DISCARD	0x0004
 
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index eea56f3..4cc2ba4 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -95,14 +95,6 @@ static inline void efx_sync_rx_buffer(struct efx_nic *efx,
 				DMA_FROM_DEVICE);
 }
 
-/* Return true if this is the last RX buffer using a page. */
-static inline bool efx_rx_is_last_buffer(struct efx_nic *efx,
-					 struct efx_rx_buffer *rx_buf)
-{
-	return (rx_buf->page_offset >= (PAGE_SIZE >> 1) ||
-		efx->rx_dma_len > EFX_RX_HALF_PAGE);
-}
-
 /* Check the RX page recycle ring for a page that can be reused. */
 static struct page *efx_reuse_page(struct efx_rx_queue *rx_queue)
 {
@@ -199,11 +191,14 @@ static int efx_init_rx_buffers(struct efx_rx_queue *rx_queue)
 		if ((~count & 1) && (efx->rx_dma_len <= EFX_RX_HALF_PAGE)) {
 			/* Use the second half of the page */
 			get_page(page);
+			rx_buf->flags = 0;
 			dma_addr += (PAGE_SIZE >> 1);
 			page_offset += (PAGE_SIZE >> 1);
 			++count;
 			goto split;
 		}
+
+		rx_buf->flags = EFX_RX_BUF_LAST_IN_PAGE;
 	}
 
 	return 0;
@@ -247,7 +242,7 @@ static void efx_recycle_rx_page(struct efx_channel *channel,
 	unsigned index;
 
 	/* Only recycle the page after processing the final buffer. */
-	if (!efx_rx_is_last_buffer(efx, rx_buf))
+	if (!(rx_buf->flags & EFX_RX_BUF_LAST_IN_PAGE))
 		return;
 
 	index = rx_queue->page_add & rx_queue->page_ptr_mask;
@@ -278,7 +273,7 @@ static void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
 		put_page(rx_buf->page);
 
 	/* If this is the last buffer in a page, unmap and free it. */
-	if (efx_rx_is_last_buffer(rx_queue->efx, rx_buf)) {
+	if (rx_buf->flags & EFX_RX_BUF_LAST_IN_PAGE) {
 		efx_unmap_rx_buffer(rx_queue->efx, rx_buf);
 		efx_free_rx_buffer(rx_buf);
 	}
@@ -507,7 +502,7 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	struct efx_rx_buffer *rx_buf;
 
 	rx_buf = efx_rx_buffer(rx_queue, index);
-	rx_buf->flags = flags;
+	rx_buf->flags |= flags;
 
 	/* Validate the number of fragments and completed length */
 	if (n_frags == 1) {
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
