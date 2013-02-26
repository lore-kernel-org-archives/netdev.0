From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 2/3] sfc: Fix efx_rx_buf_offset() in the presence of
 swiotlb
Date: Tue, 26 Feb 2013 19:12:31 +0000
Message-ID: <1361905951.2996.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <1361905763.2996.9.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36016 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754090Ab3BZTMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 14:12:35 -0500
In-Reply-To: <1361905763.2996.9.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We assume that the mapping between DMA and virtual addresses is done
on whole pages, so we can find the page offset of an RX buffer using
the lower bits of the DMA address.  However, swiotlb maps in units of
2K, breaking this assumption.

Add an explicit page_offset field to struct efx_rx_buffer.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    4 +++-
 drivers/net/ethernet/sfc/rx.c         |   10 +++++-----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 2d756c1..0a90abd 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -210,6 +210,7 @@ struct efx_tx_queue {
  *	Will be %NULL if the buffer slot is currently free.
  * @page: The associated page buffer. Valif iff @flags & %EFX_RX_BUF_PAGE.
  *	Will be %NULL if the buffer slot is currently free.
+ * @page_offset: Offset within page. Valid iff @flags & %EFX_RX_BUF_PAGE.
  * @len: Buffer length, in bytes.
  * @flags: Flags for buffer and packet state.
  */
@@ -219,7 +220,8 @@ struct efx_rx_buffer {
 		struct sk_buff *skb;
 		struct page *page;
 	} u;
-	unsigned int len;
+	u16 page_offset;
+	u16 len;
 	u16 flags;
 };
 #define EFX_RX_BUF_PAGE		0x0001
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index a575491..879ff58 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -90,11 +90,7 @@ static unsigned int rx_refill_threshold;
 static inline unsigned int efx_rx_buf_offset(struct efx_nic *efx,
 					     struct efx_rx_buffer *buf)
 {
-	/* Offset is always within one page, so we don't need to consider
-	 * the page order.
-	 */
-	return ((unsigned int) buf->dma_addr & (PAGE_SIZE - 1)) +
-		efx->type->rx_buffer_hash_size;
+	return buf->page_offset + efx->type->rx_buffer_hash_size;
 }
 static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
 {
@@ -187,6 +183,7 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 	struct efx_nic *efx = rx_queue->efx;
 	struct efx_rx_buffer *rx_buf;
 	struct page *page;
+	unsigned int page_offset;
 	struct efx_rx_page_state *state;
 	dma_addr_t dma_addr;
 	unsigned index, count;
@@ -211,12 +208,14 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 		state->dma_addr = dma_addr;
 
 		dma_addr += sizeof(struct efx_rx_page_state);
+		page_offset = sizeof(struct efx_rx_page_state);
 
 	split:
 		index = rx_queue->added_count & rx_queue->ptr_mask;
 		rx_buf = efx_rx_buffer(rx_queue, index);
 		rx_buf->dma_addr = dma_addr + EFX_PAGE_IP_ALIGN;
 		rx_buf->u.page = page;
+		rx_buf->page_offset = page_offset;
 		rx_buf->len = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
 		rx_buf->flags = EFX_RX_BUF_PAGE;
 		++rx_queue->added_count;
@@ -227,6 +226,7 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 			/* Use the second half of the page */
 			get_page(page);
 			dma_addr += (PAGE_SIZE >> 1);
+			page_offset += (PAGE_SIZE >> 1);
 			++count;
 			goto split;
 		}
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
