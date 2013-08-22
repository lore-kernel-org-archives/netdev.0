From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 26/32] sfc: Refactor queue teardown sequence to
 allow for EF10 flush behaviour
Date: Thu, 22 Aug 2013 14:02:27 +0100
Message-ID: <1377176547.1703.32.camel@bwh-desktop.uk.level5networks.com>
References: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56324 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752255Ab3HVNCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 09:02:31 -0400
In-Reply-To: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently efx_stop_datapath() will try to flush our DMA queues (if DMA
is enabled), then finalise software and hardware state for each queue.
However, for EF10 we must ask the MC to finalise each queue, which
implicitly starts flushing it, and then wait for the flush events.
We therefore need to delegate more of this to the NIC type.

Combine all the hardware operations into a new NIC-type operation
efx_nic_type::fini_dmaq, and call this before tearing down the
software state and buffers for all the DMA queues.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        | 40 +++++++++++++++++------------------
 drivers/net/ethernet/sfc/efx.h        |  1 -
 drivers/net/ethernet/sfc/falcon.c     |  2 ++
 drivers/net/ethernet/sfc/net_driver.h |  6 +++++-
 drivers/net/ethernet/sfc/nic.c        | 31 +++++++++++++++++++++++----
 drivers/net/ethernet/sfc/nic.h        |  4 +---
 drivers/net/ethernet/sfc/rx.c         |  1 -
 drivers/net/ethernet/sfc/siena.c      |  1 +
 drivers/net/ethernet/sfc/tx.c         | 21 ++++--------------
 9 files changed, 59 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 0c3c0c1..9c6555c 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -640,7 +640,6 @@ static void efx_stop_datapath(struct efx_nic *efx)
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
-	struct pci_dev *dev = efx->pci_dev;
 	int rc;
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
@@ -652,26 +651,6 @@ static void efx_stop_datapath(struct efx_nic *efx)
 			rx_queue->refill_enabled = false;
 	}
 
-	/* Only perform flush if dma is enabled */
-	if (dev->is_busmaster && efx->state != STATE_RECOVERY) {
-		rc = efx_nic_flush_queues(efx);
-
-		if (rc && EFX_WORKAROUND_7803(efx)) {
-			/* Schedule a reset to recover from the flush failure. The
-			 * descriptor caches reference memory we're about to free,
-			 * but falcon_reconfigure_mac_wrapper() won't reconnect
-			 * the MACs because of the pending reset. */
-			netif_err(efx, drv, efx->net_dev,
-				  "Resetting to recover from flush failure\n");
-			efx_schedule_reset(efx, RESET_TYPE_ALL);
-		} else if (rc) {
-			netif_err(efx, drv, efx->net_dev, "failed to flush queues\n");
-		} else {
-			netif_dbg(efx, drv, efx->net_dev,
-				  "successfully flushed all queues\n");
-		}
-	}
-
 	efx_for_each_channel(channel, efx) {
 		/* RX packet processing is pipelined, so wait for the
 		 * NAPI handler to complete.  At least event queue 0
@@ -683,7 +662,26 @@ static void efx_stop_datapath(struct efx_nic *efx)
 			efx_stop_eventq(channel);
 			efx_start_eventq(channel);
 		}
+	}
 
+	rc = efx->type->fini_dmaq(efx);
+	if (rc && EFX_WORKAROUND_7803(efx)) {
+		/* Schedule a reset to recover from the flush failure. The
+		 * descriptor caches reference memory we're about to free,
+		 * but falcon_reconfigure_mac_wrapper() won't reconnect
+		 * the MACs because of the pending reset.
+		 */
+		netif_err(efx, drv, efx->net_dev,
+			  "Resetting to recover from flush failure\n");
+		efx_schedule_reset(efx, RESET_TYPE_ALL);
+	} else if (rc) {
+		netif_err(efx, drv, efx->net_dev, "failed to flush queues\n");
+	} else {
+		netif_dbg(efx, drv, efx->net_dev,
+			  "successfully flushed all queues\n");
+	}
+
+	efx_for_each_channel(channel, efx) {
 		efx_for_each_channel_rx_queue(rx_queue, channel)
 			efx_fini_rx_queue(rx_queue);
 		efx_for_each_possible_channel_tx_queue(tx_queue, channel)
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 09e633a..45de5b9 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -23,7 +23,6 @@ extern void efx_remove_tx_queue(struct efx_tx_queue *tx_queue);
 extern void efx_init_tx_queue(struct efx_tx_queue *tx_queue);
 extern void efx_init_tx_queue_core_txq(struct efx_tx_queue *tx_queue);
 extern void efx_fini_tx_queue(struct efx_tx_queue *tx_queue);
-extern void efx_release_tx_buffers(struct efx_tx_queue *tx_queue);
 extern netdev_tx_t
 efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_dev);
 extern netdev_tx_t
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 4492129..c8efcb0 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -2351,6 +2351,7 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.probe_port = falcon_probe_port,
 	.remove_port = falcon_remove_port,
 	.handle_global_event = falcon_handle_global_event,
+	.fini_dmaq = efx_farch_fini_dmaq,
 	.prepare_flush = falcon_prepare_flush,
 	.finish_flush = efx_port_dummy_op_void,
 	.update_stats = falcon_update_nic_stats,
@@ -2396,6 +2397,7 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.probe_port = falcon_probe_port,
 	.remove_port = falcon_remove_port,
 	.handle_global_event = falcon_handle_global_event,
+	.fini_dmaq = efx_farch_fini_dmaq,
 	.prepare_flush = falcon_prepare_flush,
 	.finish_flush = efx_port_dummy_op_void,
 	.update_stats = falcon_update_nic_stats,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index c9f7989..b382895 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -953,8 +953,11 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @probe_port: Probe the MAC and PHY
  * @remove_port: Free resources allocated by probe_port()
  * @handle_global_event: Handle a "global" event (may be %NULL)
+ * @fini_dmaq: Flush and finalise DMA queues (RX and TX queues)
  * @prepare_flush: Prepare the hardware for flushing the DMA queues
- * @finish_flush: Clean up after flushing the DMA queues
+ *	(for Falcon architecture)
+ * @finish_flush: Clean up after flushing the DMA queues (for Falcon
+ *	architecture)
  * @update_stats: Update statistics not provided by event handling
  * @start_stats: Start the regular fetching of statistics
  * @stop_stats: Stop the regular fetching of statistics
@@ -1014,6 +1017,7 @@ struct efx_nic_type {
 	int (*probe_port)(struct efx_nic *efx);
 	void (*remove_port)(struct efx_nic *efx);
 	bool (*handle_global_event)(struct efx_channel *channel, efx_qword_t *);
+	int (*fini_dmaq)(struct efx_nic *efx);
 	void (*prepare_flush)(struct efx_nic *efx);
 	void (*finish_flush)(struct efx_nic *efx);
 	void (*update_stats)(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index deb0ee04..7c52691 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -721,7 +721,7 @@ static bool efx_check_tx_flush_complete(struct efx_nic *efx)
 /* Flush all the transmit queues, and continue flushing receive queues until
  * they're all flushed. Wait for the DRAIN events to be recieved so that there
  * are no more RX and TX events left on any channel. */
-int efx_nic_flush_queues(struct efx_nic *efx)
+static int efx_farch_do_flush(struct efx_nic *efx)
 {
 	unsigned timeout = msecs_to_jiffies(5000); /* 5s for all flushes and drains */
 	struct efx_channel *channel;
@@ -729,8 +729,6 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 	struct efx_tx_queue *tx_queue;
 	int rc = 0;
 
-	efx->type->prepare_flush(efx);
-
 	efx_for_each_channel(channel, efx) {
 		efx_for_each_channel_tx_queue(tx_queue, channel) {
 			atomic_inc(&efx->drain_pending);
@@ -791,7 +789,32 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 		atomic_set(&efx->rxq_flush_outstanding, 0);
 	}
 
-	efx->type->finish_flush(efx);
+	return rc;
+}
+
+int efx_farch_fini_dmaq(struct efx_nic *efx)
+{
+	struct efx_channel *channel;
+	struct efx_tx_queue *tx_queue;
+	struct efx_rx_queue *rx_queue;
+	int rc = 0;
+
+	/* Do not attempt to write to the NIC during EEH recovery */
+	if (efx->state != STATE_RECOVERY) {
+		/* Only perform flush if DMA is enabled */
+		if (efx->pci_dev->is_busmaster) {
+			efx->type->prepare_flush(efx);
+			rc = efx_farch_do_flush(efx);
+			efx->type->finish_flush(efx);
+		}
+
+		efx_for_each_channel(channel, efx) {
+			efx_for_each_channel_rx_queue(rx_queue, channel)
+				efx_nic_fini_rx(rx_queue);
+			efx_for_each_channel_tx_queue(tx_queue, channel)
+				efx_nic_fini_tx(tx_queue);
+		}
+	}
 
 	return rc;
 }
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 33aa120..21f662c 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -260,14 +260,12 @@ extern int falcon_probe_board(struct efx_nic *efx, u16 revision_info);
 /* TX data path */
 extern int efx_nic_probe_tx(struct efx_tx_queue *tx_queue);
 extern void efx_nic_init_tx(struct efx_tx_queue *tx_queue);
-extern void efx_nic_fini_tx(struct efx_tx_queue *tx_queue);
 extern void efx_nic_remove_tx(struct efx_tx_queue *tx_queue);
 extern void efx_nic_push_buffers(struct efx_tx_queue *tx_queue);
 
 /* RX data path */
 extern int efx_nic_probe_rx(struct efx_rx_queue *rx_queue);
 extern void efx_nic_init_rx(struct efx_rx_queue *rx_queue);
-extern void efx_nic_fini_rx(struct efx_rx_queue *rx_queue);
 extern void efx_nic_remove_rx(struct efx_rx_queue *rx_queue);
 extern void efx_nic_notify_rx_desc(struct efx_rx_queue *rx_queue);
 extern void efx_nic_generate_fill_event(struct efx_rx_queue *rx_queue);
@@ -319,7 +317,7 @@ static inline int efx_nic_irq_test_irq_cpu(struct efx_nic *efx)
 }
 
 /* Global Resources */
-extern int efx_nic_flush_queues(struct efx_nic *efx);
+extern int efx_farch_fini_dmaq(struct efx_nic *efx);
 extern void siena_prepare_flush(struct efx_nic *efx);
 extern void siena_finish_flush(struct efx_nic *efx);
 extern void falcon_start_nic_stats(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 8b482de..f2b78cd 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -757,7 +757,6 @@ void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
 		  "shutting down RX queue %d\n", efx_rx_queue_index(rx_queue));
 
 	del_timer_sync(&rx_queue->slow_fill);
-	efx_nic_fini_rx(rx_queue);
 
 	/* Release RX buffers from the current read ptr to the write ptr */
 	if (rx_queue->buffer) {
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index d0eeb03..b4c1d43 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -685,6 +685,7 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.reset = efx_mcdi_reset,
 	.probe_port = efx_mcdi_port_probe,
 	.remove_port = efx_mcdi_port_remove,
+	.fini_dmaq = efx_farch_fini_dmaq,
 	.prepare_flush = siena_prepare_flush,
 	.finish_flush = siena_finish_flush,
 	.update_stats = siena_update_nic_stats,
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index c0d4040..4903c4f 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -543,10 +543,13 @@ void efx_init_tx_queue(struct efx_tx_queue *tx_queue)
 	tx_queue->initialised = true;
 }
 
-void efx_release_tx_buffers(struct efx_tx_queue *tx_queue)
+void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
 {
 	struct efx_tx_buffer *buffer;
 
+	netif_dbg(tx_queue->efx, drv, tx_queue->efx->net_dev,
+		  "shutting down TX queue %d\n", tx_queue->queue);
+
 	if (!tx_queue->buffer)
 		return;
 
@@ -561,22 +564,6 @@ void efx_release_tx_buffers(struct efx_tx_queue *tx_queue)
 	netdev_tx_reset_queue(tx_queue->core_txq);
 }
 
-void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
-{
-	if (!tx_queue->initialised)
-		return;
-
-	netif_dbg(tx_queue->efx, drv, tx_queue->efx->net_dev,
-		  "shutting down TX queue %d\n", tx_queue->queue);
-
-	tx_queue->initialised = false;
-
-	/* Flush TX queue, remove descriptor ring */
-	efx_nic_fini_tx(tx_queue);
-
-	efx_release_tx_buffers(tx_queue);
-}
-
 void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
 {
 	int i;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
