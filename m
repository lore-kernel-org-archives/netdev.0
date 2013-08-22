From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 24/32] sfc: Stop RX refill before flushing RX queues
Date: Thu, 22 Aug 2013 14:00:12 +0100
Message-ID: <1377176412.1703.29.camel@bwh-desktop.uk.level5networks.com>
References: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56258 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455Ab3HVNAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 09:00:15 -0400
In-Reply-To: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rx_queue::enabled guards refill, so rename it to reflect that.  Clear
it at the start of the queue teardown process rather than waiting for
the RX queue to be flushed.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        | 9 +++++++--
 drivers/net/ethernet/sfc/net_driver.h | 4 ++--
 drivers/net/ethernet/sfc/nic.c        | 1 -
 drivers/net/ethernet/sfc/rx.c         | 8 ++++----
 4 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index a7818d1..ee9242c 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -248,8 +248,7 @@ static int efx_process_channel(struct efx_channel *channel, int budget)
 			efx_channel_get_rx_queue(channel);
 
 		efx_rx_flush_packet(channel);
-		if (rx_queue->enabled)
-			efx_fast_push_rx_descriptors(rx_queue);
+		efx_fast_push_rx_descriptors(rx_queue);
 	}
 
 	return spent;
@@ -647,6 +646,12 @@ static void efx_stop_datapath(struct efx_nic *efx)
 	EFX_ASSERT_RESET_SERIALISED(efx);
 	BUG_ON(efx->port_enabled);
 
+	/* Stop RX refill */
+	efx_for_each_channel(channel, efx) {
+		efx_for_each_channel_rx_queue(rx_queue, channel)
+			rx_queue->refill_enabled = false;
+	}
+
 	/* Only perform flush if dma is enabled */
 	if (dev->is_busmaster && efx->state != STATE_RECOVERY) {
 		rc = efx_nic_flush_queues(efx);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 7c96372..c9f7989 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -286,7 +286,7 @@ struct efx_rx_page_state {
  * @buffer: The software buffer ring
  * @rxd: The hardware descriptor ring
  * @ptr_mask: The size of the ring minus 1.
- * @enabled: Receive queue enabled indicator.
+ * @refill_enabled: Enable refill whenever fill level is low
  * @flush_pending: Set when a RX flush is pending. Has the same lifetime as
  *	@rxq_flush_pending.
  * @added_count: Number of buffers added to the receive queue.
@@ -317,7 +317,7 @@ struct efx_rx_queue {
 	struct efx_rx_buffer *buffer;
 	struct efx_special_buffer rxd;
 	unsigned int ptr_mask;
-	bool enabled;
+	bool refill_enabled;
 	bool flush_pending;
 
 	unsigned int added_count;
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 2d0a584..deb0ee04 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -1204,7 +1204,6 @@ efx_handle_generated_event(struct efx_channel *channel, efx_qword_t *event)
 		 * queue. Refill it here */
 		efx_fast_push_rx_descriptors(rx_queue);
 	} else if (rx_queue && magic == EFX_CHANNEL_MAGIC_RX_DRAIN(rx_queue)) {
-		rx_queue->enabled = false;
 		efx_handle_drain_event(channel);
 	} else if (code == _EFX_CHANNEL_MAGIC_TX_DRAIN) {
 		efx_handle_drain_event(channel);
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 6af9cfd..8b482de 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -326,6 +326,9 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 	unsigned int fill_level, batch_size;
 	int space, rc = 0;
 
+	if (!rx_queue->refill_enabled)
+		return;
+
 	/* Calculate current fill level, and exit if we don't need to fill */
 	fill_level = (rx_queue->added_count - rx_queue->removed_count);
 	EFX_BUG_ON_PARANOID(fill_level > rx_queue->efx->rxq_entries);
@@ -738,9 +741,9 @@ void efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 
 	rx_queue->max_fill = max_fill;
 	rx_queue->fast_fill_trigger = trigger;
+	rx_queue->refill_enabled = true;
 
 	/* Set up RX descriptor ring */
-	rx_queue->enabled = true;
 	efx_nic_init_rx(rx_queue);
 }
 
@@ -753,9 +756,6 @@ void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
 	netif_dbg(rx_queue->efx, drv, rx_queue->efx->net_dev,
 		  "shutting down RX queue %d\n", efx_rx_queue_index(rx_queue));
 
-	/* A flush failure might have left rx_queue->enabled */
-	rx_queue->enabled = false;
-
 	del_timer_sync(&rx_queue->slow_fill);
 	efx_nic_fini_rx(rx_queue);
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
