From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 1/3] sfc: Properly sync RX DMA buffer when it is not the
 last in the page
Date: Tue, 26 Feb 2013 19:12:21 +0000
Message-ID: <1361905941.2996.10.camel@bwh-desktop.uk.solarflarecom.com>
References: <1361905763.2996.9.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36001 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754090Ab3BZTMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 14:12:24 -0500
In-Reply-To: <1361905763.2996.9.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We may currently allocate two RX DMA buffers to a page, and only unmap
the page when the second is completed.  We do not sync the first RX
buffer to be completed; this can result in packet loss or corruption
if the last RX buffer completed in a NAPI poll is the first in a page
and is not DMA-coherent.  (In the middle of a NAPI poll, we will
handle the following RX completion and unmap the page *before* looking
at the content of the first buffer.)

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index d780a0d..a575491 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -236,7 +236,8 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 }
 
 static void efx_unmap_rx_buffer(struct efx_nic *efx,
-				struct efx_rx_buffer *rx_buf)
+				struct efx_rx_buffer *rx_buf,
+				unsigned int used_len)
 {
 	if ((rx_buf->flags & EFX_RX_BUF_PAGE) && rx_buf->u.page) {
 		struct efx_rx_page_state *state;
@@ -247,6 +248,10 @@ static void efx_unmap_rx_buffer(struct efx_nic *efx,
 				       state->dma_addr,
 				       efx_rx_buf_size(efx),
 				       DMA_FROM_DEVICE);
+		} else if (used_len) {
+			dma_sync_single_for_cpu(&efx->pci_dev->dev,
+						rx_buf->dma_addr, used_len,
+						DMA_FROM_DEVICE);
 		}
 	} else if (!(rx_buf->flags & EFX_RX_BUF_PAGE) && rx_buf->u.skb) {
 		dma_unmap_single(&efx->pci_dev->dev, rx_buf->dma_addr,
@@ -269,7 +274,7 @@ static void efx_free_rx_buffer(struct efx_nic *efx,
 static void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
 			       struct efx_rx_buffer *rx_buf)
 {
-	efx_unmap_rx_buffer(rx_queue->efx, rx_buf);
+	efx_unmap_rx_buffer(rx_queue->efx, rx_buf, 0);
 	efx_free_rx_buffer(rx_queue->efx, rx_buf);
 }
 
@@ -535,10 +540,10 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 		goto out;
 	}
 
-	/* Release card resources - assumes all RX buffers consumed in-order
-	 * per RX queue
+	/* Release and/or sync DMA mapping - assumes all RX buffers
+	 * consumed in-order per RX queue
 	 */
-	efx_unmap_rx_buffer(efx, rx_buf);
+	efx_unmap_rx_buffer(efx, rx_buf, len);
 
 	/* Prefetch nice and early so data will (hopefully) be in cache by
 	 * the time we look at it.
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
