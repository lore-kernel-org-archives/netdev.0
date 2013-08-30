From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 09/16] sfc: Prepare for RX scatter on EF10
Date: Fri, 30 Aug 2013 04:41:19 +0100
Message-ID: <1377834079.2552.35.camel@deadeye.wl.decadent.org.uk>
References: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35013 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753584Ab3H3DlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:41:23 -0400
In-Reply-To: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

RX DMA scatter is always enabled on EF10.  Adjust the common RX
completion handling to allow for this.

RX completion events on EF10 include the length used from a single
descriptor, not the cumulative length used.  Add a field to struct
efx_rx_queue to hold the cumulative length.

[bwh: Also fix a related comment]
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |    4 ++--
 drivers/net/ethernet/sfc/net_driver.h |    8 ++++++--
 drivers/net/ethernet/sfc/rx.c         |    8 ++++----
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index aec6213..b483223 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -587,7 +587,7 @@ static void efx_start_datapath(struct efx_nic *efx)
 	rx_buf_len = (sizeof(struct efx_rx_page_state) +
 		      NET_IP_ALIGN + efx->rx_dma_len);
 	if (rx_buf_len <= PAGE_SIZE) {
-		efx->rx_scatter = false;
+		efx->rx_scatter = efx->type->always_rx_scatter;
 		efx->rx_buffer_order = 0;
 	} else if (efx->type->can_rx_scatter) {
 		BUILD_BUG_ON(EFX_RX_USR_BUF_SIZE % L1_CACHE_BYTES);
@@ -615,7 +615,7 @@ static void efx_start_datapath(struct efx_nic *efx)
 			  efx->rx_dma_len, efx->rx_page_buf_step,
 			  efx->rx_bufs_per_page, efx->rx_pages_per_batch);
 
-	/* RX filters also have scatter-enabled flags */
+	/* RX filters may also have scatter-enabled flags */
 	if (efx->rx_scatter != old_rx_scatter)
 		efx->type->filter_update_rx_scatter(efx);
 
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 89974f7..5341c76 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -297,7 +297,8 @@ struct efx_rx_page_state {
  * @added_count: Number of buffers added to the receive queue.
  * @notified_count: Number of buffers given to NIC (<= @added_count).
  * @removed_count: Number of buffers removed from the receive queue.
- * @scatter_n: Number of buffers used by current packet
+ * @scatter_n: Used by NIC specific receive code.
+ * @scatter_len: Used by NIC specific receive code.
  * @page_ring: The ring to store DMA mapped pages for reuse.
  * @page_add: Counter to calculate the write pointer for the recycle ring.
  * @page_remove: Counter to calculate the read pointer for the recycle ring.
@@ -329,6 +330,7 @@ struct efx_rx_queue {
 	unsigned int notified_count;
 	unsigned int removed_count;
 	unsigned int scatter_n;
+	unsigned int scatter_len;
 	struct page **page_ring;
 	unsigned int page_add;
 	unsigned int page_remove;
@@ -1023,7 +1025,8 @@ struct efx_mtd_partition {
  * @rx_prefix_size: Size of RX prefix before packet data
  * @rx_hash_offset: Offset of RX flow hash within prefix
  * @rx_buffer_padding: Size of padding at end of RX packet
- * @can_rx_scatter: NIC is able to scatter packet to multiple buffers
+ * @can_rx_scatter: NIC is able to scatter packets to multiple buffers
+ * @always_rx_scatter: NIC will always scatter packets to multiple buffers
  * @max_interrupt_mode: Highest capability interrupt mode supported
  *	from &enum efx_init_mode.
  * @timer_period_max: Maximum period of interrupt timer (in ticks)
@@ -1142,6 +1145,7 @@ struct efx_nic_type {
 	unsigned int rx_hash_offset;
 	unsigned int rx_buffer_padding;
 	bool can_rx_scatter;
+	bool always_rx_scatter;
 	unsigned int max_interrupt_mode;
 	unsigned int timer_period_max;
 	netdev_features_t offload_features;
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 81eab21..8c13dd8 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -529,8 +529,8 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 		if (!(flags & EFX_RX_PKT_PREFIX_LEN))
 			efx_rx_packet__check_len(rx_queue, rx_buf, len);
 	} else if (unlikely(n_frags > EFX_RX_MAX_FRAGS) ||
-		   unlikely(len <= (n_frags - 1) * EFX_RX_USR_BUF_SIZE) ||
-		   unlikely(len > n_frags * EFX_RX_USR_BUF_SIZE) ||
+		   unlikely(len <= (n_frags - 1) * efx->rx_dma_len) ||
+		   unlikely(len > n_frags * efx->rx_dma_len) ||
 		   unlikely(!efx->rx_scatter)) {
 		/* If this isn't an explicit discard request, either
 		 * the hardware or the driver is broken.
@@ -581,9 +581,9 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 			rx_buf = efx_rx_buf_next(rx_queue, rx_buf);
 			if (--tail_frags == 0)
 				break;
-			efx_sync_rx_buffer(efx, rx_buf, EFX_RX_USR_BUF_SIZE);
+			efx_sync_rx_buffer(efx, rx_buf, efx->rx_dma_len);
 		}
-		rx_buf->len = len - (n_frags - 1) * EFX_RX_USR_BUF_SIZE;
+		rx_buf->len = len - (n_frags - 1) * efx->rx_dma_len;
 		efx_sync_rx_buffer(efx, rx_buf, rx_buf->len);
 	}
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
