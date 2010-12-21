From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/2] sfc: Remove ancient support for nesting
 of TX stop
Date: Tue, 21 Dec 2010 14:49:31 +0000
Message-ID: <1292942971.3256.4.camel@bwh-desktop>
References: <1292942817.3256.2.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59390 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374Ab0LUOtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 09:49:35 -0500
In-Reply-To: <1292942817.3256.2.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Long before this driver went into mainline, it had support for
multiple TX queues per port, with lockless TX enabled.  Since Linux
did not know anything of this, filling up any hardware TX queue would
stop the core TX queue and multiple hardware TX queues could fill up
before the scheduler reacted.  Thus it was necessary to keep a count
of how many TX queues were stopped and to wake the core TX queue only
when all had free space again.

The driver also previously (ab)used the per-hardware-queue stopped
flag as a counter to deal with various things that can inhibit TX, but
it no longer does that.

Remove the per-channel tx_stop_count, tx_stop_lock and
per-hardware-queue stopped count and just use the networking core
queue state directly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   24 +++++----
 drivers/net/sfc/efx.h        |    2 -
 drivers/net/sfc/net_driver.h |   11 +---
 drivers/net/sfc/tx.c         |  111 +++++++----------------------------------
 4 files changed, 35 insertions(+), 113 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 2166c1d..711449c 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -461,9 +461,6 @@ efx_alloc_channel(struct efx_nic *efx, int i, struct efx_channel *old_channel)
 		}
 	}
 
-	spin_lock_init(&channel->tx_stop_lock);
-	atomic_set(&channel->tx_stop_count, 1);
-
 	rx_queue = &channel->rx_queue;
 	rx_queue->efx = efx;
 	setup_timer(&rx_queue->slow_fill, efx_rx_slow_fill,
@@ -1406,11 +1403,11 @@ static void efx_start_all(struct efx_nic *efx)
 	 * restart the transmit interface early so the watchdog timer stops */
 	efx_start_port(efx);
 
-	efx_for_each_channel(channel, efx) {
-		if (efx_dev_registered(efx))
-			efx_wake_queue(channel);
+	if (efx_dev_registered(efx))
+		netif_tx_wake_all_queues(efx->net_dev);
+
+	efx_for_each_channel(channel, efx)
 		efx_start_channel(channel);
-	}
 
 	if (efx->legacy_irq)
 		efx->legacy_irq_enabled = true;
@@ -1498,9 +1495,7 @@ static void efx_stop_all(struct efx_nic *efx)
 	/* Stop the kernel transmit interface late, so the watchdog
 	 * timer isn't ticking over the flush */
 	if (efx_dev_registered(efx)) {
-		struct efx_channel *channel;
-		efx_for_each_channel(channel, efx)
-			efx_stop_queue(channel);
+		netif_tx_stop_all_queues(efx->net_dev);
 		netif_tx_lock_bh(efx->net_dev);
 		netif_tx_unlock_bh(efx->net_dev);
 	}
@@ -1896,6 +1891,7 @@ static DEVICE_ATTR(phy_type, 0644, show_phy_type, NULL);
 static int efx_register_netdev(struct efx_nic *efx)
 {
 	struct net_device *net_dev = efx->net_dev;
+	struct efx_channel *channel;
 	int rc;
 
 	net_dev->watchdog_timeo = 5 * HZ;
@@ -1918,6 +1914,14 @@ static int efx_register_netdev(struct efx_nic *efx)
 	if (rc)
 		goto fail_locked;
 
+	efx_for_each_channel(channel, efx) {
+		struct efx_tx_queue *tx_queue;
+		efx_for_each_channel_tx_queue(tx_queue, channel) {
+			tx_queue->core_txq = netdev_get_tx_queue(
+				efx->net_dev, tx_queue->queue / EFX_TXQ_TYPES);
+		}
+	}
+
 	/* Always start with carrier off; PHY events will detect the link */
 	netif_carrier_off(efx->net_dev);
 
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 003fdb3..d43a7e5 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -36,8 +36,6 @@ efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_dev);
 extern netdev_tx_t
 efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb);
 extern void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
-extern void efx_stop_queue(struct efx_channel *channel);
-extern void efx_wake_queue(struct efx_channel *channel);
 
 /* RX */
 extern int efx_probe_rx_queue(struct efx_rx_queue *rx_queue);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 294379f..bdce66d 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -136,6 +136,7 @@ struct efx_tx_buffer {
  * @efx: The associated Efx NIC
  * @queue: DMA queue number
  * @channel: The associated channel
+ * @core_txq: The networking core TX queue structure
  * @buffer: The software buffer ring
  * @txd: The hardware descriptor ring
  * @ptr_mask: The size of the ring minus 1.
@@ -148,8 +149,6 @@ struct efx_tx_buffer {
  *	variable indicates that the queue is empty.  This is to
  *	avoid cache-line ping-pong between the xmit path and the
  *	completion path.
- * @stopped: Stopped count.
- *	Set if this TX queue is currently stopping its port.
  * @insert_count: Current insert pointer
  *	This is the number of buffers that have been added to the
  *	software ring.
@@ -179,6 +178,7 @@ struct efx_tx_queue {
 	struct efx_nic *efx ____cacheline_aligned_in_smp;
 	unsigned queue;
 	struct efx_channel *channel;
+	struct netdev_queue *core_txq;
 	struct efx_tx_buffer *buffer;
 	struct efx_special_buffer txd;
 	unsigned int ptr_mask;
@@ -187,7 +187,6 @@ struct efx_tx_queue {
 	/* Members used mainly on the completion path */
 	unsigned int read_count ____cacheline_aligned_in_smp;
 	unsigned int old_write_count;
-	int stopped;
 
 	/* Members used only on the xmit path */
 	unsigned int insert_count ____cacheline_aligned_in_smp;
@@ -340,8 +339,6 @@ enum efx_rx_alloc_method {
  * @n_rx_overlength: Count of RX_OVERLENGTH errors
  * @n_skbuff_leaks: Count of skbuffs leaked due to RX overrun
  * @rx_queue: RX queue for this channel
- * @tx_stop_count: Core TX queue stop count
- * @tx_stop_lock: Core TX queue stop lock
  * @tx_queue: TX queues for this channel
  */
 struct efx_channel {
@@ -380,10 +377,6 @@ struct efx_channel {
 	bool rx_pkt_csummed;
 
 	struct efx_rx_queue rx_queue;
-
-	atomic_t tx_stop_count;
-	spinlock_t tx_stop_lock;
-
 	struct efx_tx_queue tx_queue[2];
 };
 
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index bdb92b4..2f5e9da 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -30,50 +30,6 @@
  */
 #define EFX_TXQ_THRESHOLD(_efx) ((_efx)->txq_entries / 2u)
 
-/* We need to be able to nest calls to netif_tx_stop_queue(), partly
- * because of the 2 hardware queues associated with each core queue,
- * but also so that we can inhibit TX for reasons other than a full
- * hardware queue. */
-void efx_stop_queue(struct efx_channel *channel)
-{
-	struct efx_nic *efx = channel->efx;
-	struct efx_tx_queue *tx_queue = efx_channel_get_tx_queue(channel, 0);
-
-	if (!tx_queue)
-		return;
-
-	spin_lock_bh(&channel->tx_stop_lock);
-	netif_vdbg(efx, tx_queued, efx->net_dev, "stop TX queue\n");
-
-	atomic_inc(&channel->tx_stop_count);
-	netif_tx_stop_queue(
-		netdev_get_tx_queue(efx->net_dev,
-				    tx_queue->queue / EFX_TXQ_TYPES));
-
-	spin_unlock_bh(&channel->tx_stop_lock);
-}
-
-/* Decrement core TX queue stop count and wake it if the count is 0 */
-void efx_wake_queue(struct efx_channel *channel)
-{
-	struct efx_nic *efx = channel->efx;
-	struct efx_tx_queue *tx_queue = efx_channel_get_tx_queue(channel, 0);
-
-	if (!tx_queue)
-		return;
-
-	local_bh_disable();
-	if (atomic_dec_and_lock(&channel->tx_stop_count,
-				&channel->tx_stop_lock)) {
-		netif_vdbg(efx, tx_queued, efx->net_dev, "waking TX queue\n");
-		netif_tx_wake_queue(
-			netdev_get_tx_queue(efx->net_dev,
-					    tx_queue->queue / EFX_TXQ_TYPES));
-		spin_unlock(&channel->tx_stop_lock);
-	}
-	local_bh_enable();
-}
-
 static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
 			       struct efx_tx_buffer *buffer)
 {
@@ -234,9 +190,9 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 				 * checked.  Update the xmit path's
 				 * copy of read_count.
 				 */
-				++tx_queue->stopped;
+				netif_tx_stop_queue(tx_queue->core_txq);
 				/* This memory barrier protects the
-				 * change of stopped from the access
+				 * change of queue state from the access
 				 * of read_count. */
 				smp_mb();
 				tx_queue->old_read_count =
@@ -244,10 +200,12 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 				fill_level = (tx_queue->insert_count
 					      - tx_queue->old_read_count);
 				q_space = efx->txq_entries - 1 - fill_level;
-				if (unlikely(q_space-- <= 0))
-					goto stop;
+				if (unlikely(q_space-- <= 0)) {
+					rc = NETDEV_TX_BUSY;
+					goto unwind;
+				}
 				smp_mb();
-				--tx_queue->stopped;
+				netif_tx_start_queue(tx_queue->core_txq);
 			}
 
 			insert_ptr = tx_queue->insert_count & tx_queue->ptr_mask;
@@ -307,13 +265,6 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 
 	/* Mark the packet as transmitted, and free the SKB ourselves */
 	dev_kfree_skb_any(skb);
-	goto unwind;
-
- stop:
-	rc = NETDEV_TX_BUSY;
-
-	if (tx_queue->stopped == 1)
-		efx_stop_queue(tx_queue->channel);
 
  unwind:
 	/* Work backwards until we hit the original insert pointer value */
@@ -400,32 +351,21 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 {
 	unsigned fill_level;
 	struct efx_nic *efx = tx_queue->efx;
-	struct netdev_queue *queue;
 
 	EFX_BUG_ON_PARANOID(index > tx_queue->ptr_mask);
 
 	efx_dequeue_buffers(tx_queue, index);
 
 	/* See if we need to restart the netif queue.  This barrier
-	 * separates the update of read_count from the test of
-	 * stopped. */
+	 * separates the update of read_count from the test of the
+	 * queue state. */
 	smp_mb();
-	if (unlikely(tx_queue->stopped) && likely(efx->port_enabled)) {
+	if (unlikely(netif_tx_queue_stopped(tx_queue->core_txq)) &&
+	    likely(efx->port_enabled)) {
 		fill_level = tx_queue->insert_count - tx_queue->read_count;
 		if (fill_level < EFX_TXQ_THRESHOLD(efx)) {
 			EFX_BUG_ON_PARANOID(!efx_dev_registered(efx));
-
-			/* Do this under netif_tx_lock(), to avoid racing
-			 * with efx_xmit(). */
-			queue = netdev_get_tx_queue(
-				efx->net_dev,
-				tx_queue->queue / EFX_TXQ_TYPES);
-			__netif_tx_lock(queue, smp_processor_id());
-			if (tx_queue->stopped) {
-				tx_queue->stopped = 0;
-				efx_wake_queue(tx_queue->channel);
-			}
-			__netif_tx_unlock(queue);
+			netif_tx_wake_queue(tx_queue->core_txq);
 		}
 	}
 
@@ -487,7 +427,6 @@ void efx_init_tx_queue(struct efx_tx_queue *tx_queue)
 	tx_queue->read_count = 0;
 	tx_queue->old_read_count = 0;
 	tx_queue->empty_read_count = 0 | EFX_EMPTY_COUNT_VALID;
-	BUG_ON(tx_queue->stopped);
 
 	/* Set up TX descriptor ring */
 	efx_nic_init_tx(tx_queue);
@@ -523,12 +462,6 @@ void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
 
 	/* Free up TSO header cache */
 	efx_fini_tso(tx_queue);
-
-	/* Release queue's stop on port, if any */
-	if (tx_queue->stopped) {
-		tx_queue->stopped = 0;
-		efx_wake_queue(tx_queue->channel);
-	}
 }
 
 void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
@@ -770,9 +703,9 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 			 * since the xmit path last checked.  Update
 			 * the xmit path's copy of read_count.
 			 */
-			++tx_queue->stopped;
+			netif_tx_stop_queue(tx_queue->core_txq);
 			/* This memory barrier protects the change of
-			 * stopped from the access of read_count. */
+			 * queue state from the access of read_count. */
 			smp_mb();
 			tx_queue->old_read_count =
 				ACCESS_ONCE(tx_queue->read_count);
@@ -784,7 +717,7 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 				return 1;
 			}
 			smp_mb();
-			--tx_queue->stopped;
+			netif_tx_start_queue(tx_queue->core_txq);
 		}
 
 		insert_ptr = tx_queue->insert_count & tx_queue->ptr_mask;
@@ -1124,8 +1057,10 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 
 	while (1) {
 		rc = tso_fill_packet_with_fragment(tx_queue, skb, &state);
-		if (unlikely(rc))
-			goto stop;
+		if (unlikely(rc)) {
+			rc2 = NETDEV_TX_BUSY;
+			goto unwind;
+		}
 
 		/* Move onto the next fragment? */
 		if (state.in_len == 0) {
@@ -1154,14 +1089,6 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 	netif_err(efx, tx_err, efx->net_dev,
 		  "Out of memory for TSO headers, or PCI mapping error\n");
 	dev_kfree_skb_any(skb);
-	goto unwind;
-
- stop:
-	rc2 = NETDEV_TX_BUSY;
-
-	/* Stop the queue if it wasn't stopped before. */
-	if (tx_queue->stopped == 1)
-		efx_stop_queue(tx_queue->channel);
 
  unwind:
 	/* Free the DMA mapping we were in the process of writing out */
-- 
1.7.3.2


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

