From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net] sfc: Fix memory leak when discarding scattered packets
Date: Thu, 4 Jul 2013 23:48:46 +0100
Message-ID: <1372978126.1853.11.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31711 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933443Ab3GDWsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 18:48:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2768935a4660 ('sfc: reuse pages to avoid DMA mapping/unmapping
costs') did not fully take account of DMA scattering which was
introduced immediately before.  If a received packet is invalid and
must be discarded, we only drop a reference to the first buffer's
page, but we need to drop a reference for each buffer the packet
used.

I think this bug was missed partly because efx_recycle_rx_buffers()
was not renamed and so no longer does what its name says.  It does not
change the state of buffers, but only prepares the underlying pages
for recycling.  Rename it accordingly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This bug fix needs to go into 3.10.y as well.

Ben.

 drivers/net/ethernet/sfc/rx.c | 27 ++++++++++++++++++++-------
 1 file changed, 20 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 65646cd..6af9cfd 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -282,9 +282,9 @@ static void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
 }
 
 /* Recycle the pages that are used by buffers that have just been received. */
-static void efx_recycle_rx_buffers(struct efx_channel *channel,
-				   struct efx_rx_buffer *rx_buf,
-				   unsigned int n_frags)
+static void efx_recycle_rx_pages(struct efx_channel *channel,
+				 struct efx_rx_buffer *rx_buf,
+				 unsigned int n_frags)
 {
 	struct efx_rx_queue *rx_queue = efx_channel_get_rx_queue(channel);
 
@@ -294,6 +294,20 @@ static void efx_recycle_rx_buffers(struct efx_channel *channel,
 	} while (--n_frags);
 }
 
+static void efx_discard_rx_packet(struct efx_channel *channel,
+				  struct efx_rx_buffer *rx_buf,
+				  unsigned int n_frags)
+{
+	struct efx_rx_queue *rx_queue = efx_channel_get_rx_queue(channel);
+
+	efx_recycle_rx_pages(channel, rx_buf, n_frags);
+
+	do {
+		efx_free_rx_buffer(rx_buf);
+		rx_buf = efx_rx_buf_next(rx_queue, rx_buf);
+	} while (--n_frags);
+}
+
 /**
  * efx_fast_push_rx_descriptors - push new RX descriptors quickly
  * @rx_queue:		RX descriptor queue
@@ -533,8 +547,7 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	 */
 	if (unlikely(rx_buf->flags & EFX_RX_PKT_DISCARD)) {
 		efx_rx_flush_packet(channel);
-		put_page(rx_buf->page);
-		efx_recycle_rx_buffers(channel, rx_buf, n_frags);
+		efx_discard_rx_packet(channel, rx_buf, n_frags);
 		return;
 	}
 
@@ -570,9 +583,9 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 		efx_sync_rx_buffer(efx, rx_buf, rx_buf->len);
 	}
 
-	/* All fragments have been DMA-synced, so recycle buffers and pages. */
+	/* All fragments have been DMA-synced, so recycle pages. */
 	rx_buf = efx_rx_buffer(rx_queue, index);
-	efx_recycle_rx_buffers(channel, rx_buf, n_frags);
+	efx_recycle_rx_pages(channel, rx_buf, n_frags);
 
 	/* Pipeline receives so that we give time for packet headers to be
 	 * prefetched into cache.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
