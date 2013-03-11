From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 16/22] sfc: Replace efx_rx_buf_eh() with simpler
 efx_rx_buf_va()
Date: Mon, 11 Mar 2013 19:56:42 +0000
Message-ID: <1363031802.2608.53.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16833 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752835Ab3CKT4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:56:45 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_rx_buf_va() returns the virtual address of the current start of
the buffer.  The callers must add the hash prefix size themselves.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 60f4eb7..23d67d1 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -54,9 +54,9 @@ static inline unsigned int efx_rx_buf_offset(struct efx_nic *efx,
 	return buf->page_offset + efx->type->rx_buffer_hash_size;
 }
 
-static u8 *efx_rx_buf_eh(struct efx_nic *efx, struct efx_rx_buffer *buf)
+static inline u8 *efx_rx_buf_va(struct efx_rx_buffer *buf)
 {
-	return page_address(buf->page) + efx_rx_buf_offset(efx, buf);
+	return page_address(buf->page) + buf->page_offset;
 }
 
 static inline u32 efx_rx_buf_hash(const u8 *eh)
@@ -458,7 +458,7 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	/* Prefetch nice and early so data will (hopefully) be in cache by
 	 * the time we look at it.
 	 */
-	prefetch(efx_rx_buf_eh(efx, rx_buf));
+	prefetch(efx_rx_buf_va(rx_buf) + efx->type->rx_buffer_hash_size);
 
 	/* Pipeline receives so that we give time for packet headers to be
 	 * prefetched into cache.
@@ -497,7 +497,7 @@ static void efx_rx_deliver(struct efx_channel *channel, u8 *eh,
 void __efx_rx_packet(struct efx_channel *channel, struct efx_rx_buffer *rx_buf)
 {
 	struct efx_nic *efx = channel->efx;
-	u8 *eh = efx_rx_buf_eh(efx, rx_buf);
+	u8 *eh = efx_rx_buf_va(rx_buf) + efx->type->rx_buffer_hash_size;
 
 	/* If we're in loopback test, then pass the packet directly to the
 	 * loopback layer, and free the rx_buf here
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
