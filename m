From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 07/10] sfc: Refactor channel and queue lookup
 and iteration
Date: Fri, 10 Sep 2010 17:41:47 +0100
Message-ID: <1284136907.2267.102.camel@achroite.uk.solarflarecom.com>
References: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25687 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755811Ab0IJQly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 12:41:54 -0400
In-Reply-To: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for changes to the way channels and queue structures
are allocated, revise the macros and functions used to look up and
iterator over them.

- Replace efx_for_each_tx_queue() with iteration over channels then TX
  queues
- Replace efx_for_each_rx_queue() with iteration over channels then RX
  queues (with one exception, shortly to be removed)
- Introduce efx_get_{channel,rx_queue,tx_queue}() functions to look up
  channels and queues by index
- Introduce efx_channel_get_{rx,tx}_queue() functions to look up a
  channel's queues

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   28 ++++++++------
 drivers/net/sfc/ethtool.c    |   15 ++++---
 drivers/net/sfc/net_driver.h |   43 ++++++++++++++++++---
 drivers/net/sfc/nic.c        |   85 ++++++++++++++++++++++++------------------
 drivers/net/sfc/rx.c         |    2 +-
 drivers/net/sfc/selftest.c   |    5 +-
 drivers/net/sfc/tx.c         |   22 +++++-----
 7 files changed, 125 insertions(+), 75 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index a576045..3dd71aa 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -248,7 +248,7 @@ static int efx_process_channel(struct efx_channel *channel, int budget)
 
 	efx_rx_strategy(channel);
 
-	efx_fast_push_rx_descriptors(&efx->rx_queue[channel->channel]);
+	efx_fast_push_rx_descriptors(efx_channel_get_rx_queue(channel));
 
 	return spent;
 }
@@ -1050,7 +1050,8 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 				efx->n_rx_channels = efx->n_channels;
 			}
 			for (i = 0; i < n_channels; i++)
-				efx->channel[i].irq = xentries[i].vector;
+				efx_get_channel(efx, i)->irq =
+					xentries[i].vector;
 		} else {
 			/* Fall back to single channel MSI */
 			efx->interrupt_mode = EFX_INT_MODE_MSI;
@@ -1066,7 +1067,7 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 		efx->n_tx_channels = 1;
 		rc = pci_enable_msi(efx->pci_dev);
 		if (rc == 0) {
-			efx->channel[0].irq = efx->pci_dev->irq;
+			efx_get_channel(efx, 0)->irq = efx->pci_dev->irq;
 		} else {
 			netif_err(efx, drv, efx->net_dev,
 				  "could not enable MSI\n");
@@ -1355,20 +1356,20 @@ static unsigned irq_mod_ticks(int usecs, int resolution)
 void efx_init_irq_moderation(struct efx_nic *efx, int tx_usecs, int rx_usecs,
 			     bool rx_adaptive)
 {
-	struct efx_tx_queue *tx_queue;
-	struct efx_rx_queue *rx_queue;
+	struct efx_channel *channel;
 	unsigned tx_ticks = irq_mod_ticks(tx_usecs, EFX_IRQ_MOD_RESOLUTION);
 	unsigned rx_ticks = irq_mod_ticks(rx_usecs, EFX_IRQ_MOD_RESOLUTION);
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
-	efx_for_each_tx_queue(tx_queue, efx)
-		tx_queue->channel->irq_moderation = tx_ticks;
-
 	efx->irq_rx_adaptive = rx_adaptive;
 	efx->irq_rx_moderation = rx_ticks;
-	efx_for_each_rx_queue(rx_queue, efx)
-		rx_queue->channel->irq_moderation = rx_ticks;
+	efx_for_each_channel(channel, efx) {
+		if (efx_channel_get_rx_queue(channel))
+			channel->irq_moderation = rx_ticks;
+		else if (efx_channel_get_tx_queue(channel, 0))
+			channel->irq_moderation = tx_ticks;
+	}
 }
 
 /**************************************************************************
@@ -1767,6 +1768,7 @@ fail_registered:
 
 static void efx_unregister_netdev(struct efx_nic *efx)
 {
+	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 
 	if (!efx->net_dev)
@@ -1777,8 +1779,10 @@ static void efx_unregister_netdev(struct efx_nic *efx)
 	/* Free up any skbs still remaining. This has to happen before
 	 * we try to unregister the netdev as running their destructors
 	 * may be needed to get the device ref. count to 0. */
-	efx_for_each_tx_queue(tx_queue, efx)
-		efx_release_tx_buffers(tx_queue);
+	efx_for_each_channel(channel, efx) {
+		efx_for_each_channel_tx_queue(tx_queue, channel)
+			efx_release_tx_buffers(tx_queue);
+	}
 
 	if (efx_dev_registered(efx)) {
 		strlcpy(efx->name, pci_name(efx->pci_dev), sizeof(efx->name));
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index fd19d6a..b9291db 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -328,9 +328,10 @@ static int efx_fill_loopback_test(struct efx_nic *efx,
 				  unsigned int test_index,
 				  struct ethtool_string *strings, u64 *data)
 {
+	struct efx_channel *channel = efx_get_channel(efx, 0);
 	struct efx_tx_queue *tx_queue;
 
-	efx_for_each_channel_tx_queue(tx_queue, &efx->channel[0]) {
+	efx_for_each_channel_tx_queue(tx_queue, channel) {
 		efx_fill_test(test_index++, strings, data,
 			      &lb_tests->tx_sent[tx_queue->queue],
 			      EFX_TX_QUEUE_NAME(tx_queue),
@@ -673,15 +674,15 @@ static int efx_ethtool_get_coalesce(struct net_device *net_dev,
 				    struct ethtool_coalesce *coalesce)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	struct efx_tx_queue *tx_queue;
 	struct efx_channel *channel;
 
 	memset(coalesce, 0, sizeof(*coalesce));
 
 	/* Find lowest IRQ moderation across all used TX queues */
 	coalesce->tx_coalesce_usecs_irq = ~((u32) 0);
-	efx_for_each_tx_queue(tx_queue, efx) {
-		channel = tx_queue->channel;
+	efx_for_each_channel(channel, efx) {
+		if (!efx_channel_get_tx_queue(channel, 0))
+			continue;
 		if (channel->irq_moderation < coalesce->tx_coalesce_usecs_irq) {
 			if (channel->channel < efx->n_rx_channels)
 				coalesce->tx_coalesce_usecs_irq =
@@ -708,7 +709,6 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_channel *channel;
-	struct efx_tx_queue *tx_queue;
 	unsigned tx_usecs, rx_usecs, adaptive;
 
 	if (coalesce->use_adaptive_tx_coalesce)
@@ -725,8 +725,9 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 	adaptive = coalesce->use_adaptive_rx_coalesce;
 
 	/* If the channel is shared only allow RX parameters to be set */
-	efx_for_each_tx_queue(tx_queue, efx) {
-		if ((tx_queue->channel->channel < efx->n_rx_channels) &&
+	efx_for_each_channel(channel, efx) {
+		if (efx_channel_get_rx_queue(channel) &&
+		    efx_channel_get_tx_queue(channel, 0) &&
 		    tx_usecs) {
 			netif_err(efx, drv, efx->net_dev, "Channel is shared. "
 				  "Only RX coalescing may be set\n");
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 89c6e02..eb35375 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -909,18 +909,34 @@ struct efx_nic_type {
  *
  *************************************************************************/
 
+static inline struct efx_channel *
+efx_get_channel(struct efx_nic *efx, unsigned index)
+{
+	EFX_BUG_ON_PARANOID(index >= efx->n_channels);
+	return &efx->channel[index];
+}
+
 /* Iterate over all used channels */
 #define efx_for_each_channel(_channel, _efx)				\
 	for (_channel = &((_efx)->channel[0]);				\
 	     _channel < &((_efx)->channel[(efx)->n_channels]);		\
 	     _channel++)
 
-/* Iterate over all used TX queues */
-#define efx_for_each_tx_queue(_tx_queue, _efx)				\
-	for (_tx_queue = &((_efx)->tx_queue[0]);			\
-	     _tx_queue < &((_efx)->tx_queue[EFX_TXQ_TYPES *		\
-					    (_efx)->n_tx_channels]);	\
-	     _tx_queue++)
+static inline struct efx_tx_queue *
+efx_get_tx_queue(struct efx_nic *efx, unsigned index, unsigned type)
+{
+	EFX_BUG_ON_PARANOID(index >= efx->n_tx_channels ||
+			    type >= EFX_TXQ_TYPES);
+	return &efx->tx_queue[index * EFX_TXQ_TYPES + type];
+}
+
+static inline struct efx_tx_queue *
+efx_channel_get_tx_queue(struct efx_channel *channel, unsigned type)
+{
+	struct efx_tx_queue *tx_queue = channel->tx_queue;
+	EFX_BUG_ON_PARANOID(type >= EFX_TXQ_TYPES);
+	return tx_queue ? tx_queue + type : NULL;
+}
 
 /* Iterate over all TX queues belonging to a channel */
 #define efx_for_each_channel_tx_queue(_tx_queue, _channel)		\
@@ -928,12 +944,27 @@ struct efx_nic_type {
 	     _tx_queue && _tx_queue < (_channel)->tx_queue + EFX_TXQ_TYPES; \
 	     _tx_queue++)
 
+static inline struct efx_rx_queue *
+efx_get_rx_queue(struct efx_nic *efx, unsigned index)
+{
+	EFX_BUG_ON_PARANOID(index >= efx->n_rx_channels);
+	return &efx->rx_queue[index];
+}
+
 /* Iterate over all used RX queues */
 #define efx_for_each_rx_queue(_rx_queue, _efx)				\
 	for (_rx_queue = &((_efx)->rx_queue[0]);			\
 	     _rx_queue < &((_efx)->rx_queue[(_efx)->n_rx_channels]);	\
 	     _rx_queue++)
 
+static inline struct efx_rx_queue *
+efx_channel_get_rx_queue(struct efx_channel *channel)
+{
+	struct efx_rx_queue *rx_queue =
+		&channel->efx->rx_queue[channel->channel];
+	return rx_queue->channel == channel ? rx_queue : NULL;
+}
+
 /* Iterate over all RX queues belonging to a channel */
 #define efx_for_each_channel_rx_queue(_rx_queue, _channel)		\
 	for (_rx_queue = &((_channel)->efx->rx_queue[(_channel)->channel]); \
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index be4d552..9e35633 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -682,7 +682,8 @@ efx_handle_tx_event(struct efx_channel *channel, efx_qword_t *event)
 		/* Transmit completion */
 		tx_ev_desc_ptr = EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_DESC_PTR);
 		tx_ev_q_label = EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_Q_LABEL);
-		tx_queue = &efx->tx_queue[tx_ev_q_label];
+		tx_queue = efx_channel_get_tx_queue(
+			channel, tx_ev_q_label % EFX_TXQ_TYPES);
 		tx_packets = ((tx_ev_desc_ptr - tx_queue->read_count) &
 			      EFX_TXQ_MASK);
 		channel->irq_mod_score += tx_packets;
@@ -690,7 +691,8 @@ efx_handle_tx_event(struct efx_channel *channel, efx_qword_t *event)
 	} else if (EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_WQ_FF_FULL)) {
 		/* Rewrite the FIFO write pointer */
 		tx_ev_q_label = EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_Q_LABEL);
-		tx_queue = &efx->tx_queue[tx_ev_q_label];
+		tx_queue = efx_channel_get_tx_queue(
+			channel, tx_ev_q_label % EFX_TXQ_TYPES);
 
 		if (efx_dev_registered(efx))
 			netif_tx_lock(efx->net_dev);
@@ -830,7 +832,7 @@ efx_handle_rx_event(struct efx_channel *channel, const efx_qword_t *event)
 	WARN_ON(EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_Q_LABEL) !=
 		channel->channel);
 
-	rx_queue = &efx->rx_queue[channel->channel];
+	rx_queue = efx_channel_get_rx_queue(channel);
 
 	rx_ev_desc_ptr = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_DESC_PTR);
 	expected_ptr = rx_queue->removed_count & EFX_RXQ_MASK;
@@ -882,7 +884,7 @@ efx_handle_generated_event(struct efx_channel *channel, efx_qword_t *event)
 		/* The queue must be empty, so we won't receive any rx
 		 * events, so efx_process_channel() won't refill the
 		 * queue. Refill it here */
-		efx_fast_push_rx_descriptors(&efx->rx_queue[channel->channel]);
+		efx_fast_push_rx_descriptors(efx_channel_get_rx_queue(channel));
 	else
 		netif_dbg(efx, hw, efx->net_dev, "channel %d received "
 			  "generated event "EFX_QWORD_FMT"\n",
@@ -1166,7 +1168,7 @@ void efx_nic_generate_fill_event(struct efx_channel *channel)
 
 static void efx_poll_flush_events(struct efx_nic *efx)
 {
-	struct efx_channel *channel = &efx->channel[0];
+	struct efx_channel *channel = efx_get_channel(efx, 0);
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
 	unsigned int read_ptr = channel->eventq_read_ptr;
@@ -1188,7 +1190,9 @@ static void efx_poll_flush_events(struct efx_nic *efx)
 			ev_queue = EFX_QWORD_FIELD(*event,
 						   FSF_AZ_DRIVER_EV_SUBDATA);
 			if (ev_queue < EFX_TXQ_TYPES * efx->n_tx_channels) {
-				tx_queue = efx->tx_queue + ev_queue;
+				tx_queue = efx_get_tx_queue(
+					efx, ev_queue / EFX_TXQ_TYPES,
+					ev_queue % EFX_TXQ_TYPES);
 				tx_queue->flushed = FLUSH_DONE;
 			}
 		} else if (ev_code == FSE_AZ_EV_CODE_DRIVER_EV &&
@@ -1198,7 +1202,7 @@ static void efx_poll_flush_events(struct efx_nic *efx)
 			ev_failed = EFX_QWORD_FIELD(
 				*event, FSF_AZ_DRIVER_EV_RX_FLUSH_FAIL);
 			if (ev_queue < efx->n_rx_channels) {
-				rx_queue = efx->rx_queue + ev_queue;
+				rx_queue = efx_get_rx_queue(efx, ev_queue);
 				rx_queue->flushed =
 					ev_failed ? FLUSH_FAILED : FLUSH_DONE;
 			}
@@ -1219,6 +1223,7 @@ static void efx_poll_flush_events(struct efx_nic *efx)
  * serialise them */
 int efx_nic_flush_queues(struct efx_nic *efx)
 {
+	struct efx_channel *channel;
 	struct efx_rx_queue *rx_queue;
 	struct efx_tx_queue *tx_queue;
 	int i, tx_pending, rx_pending;
@@ -1227,29 +1232,35 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 	efx->type->prepare_flush(efx);
 
 	/* Flush all tx queues in parallel */
-	efx_for_each_tx_queue(tx_queue, efx)
-		efx_flush_tx_queue(tx_queue);
+	efx_for_each_channel(channel, efx) {
+		efx_for_each_channel_tx_queue(tx_queue, channel)
+			efx_flush_tx_queue(tx_queue);
+	}
 
 	/* The hardware supports four concurrent rx flushes, each of which may
 	 * need to be retried if there is an outstanding descriptor fetch */
 	for (i = 0; i < EFX_FLUSH_POLL_COUNT; ++i) {
 		rx_pending = tx_pending = 0;
-		efx_for_each_rx_queue(rx_queue, efx) {
-			if (rx_queue->flushed == FLUSH_PENDING)
-				++rx_pending;
-		}
-		efx_for_each_rx_queue(rx_queue, efx) {
-			if (rx_pending == EFX_RX_FLUSH_COUNT)
-				break;
-			if (rx_queue->flushed == FLUSH_FAILED ||
-			    rx_queue->flushed == FLUSH_NONE) {
-				efx_flush_rx_queue(rx_queue);
-				++rx_pending;
+		efx_for_each_channel(channel, efx) {
+			efx_for_each_channel_rx_queue(rx_queue, channel) {
+				if (rx_queue->flushed == FLUSH_PENDING)
+					++rx_pending;
 			}
 		}
-		efx_for_each_tx_queue(tx_queue, efx) {
-			if (tx_queue->flushed != FLUSH_DONE)
-				++tx_pending;
+		efx_for_each_channel(channel, efx) {
+			efx_for_each_channel_rx_queue(rx_queue, channel) {
+				if (rx_pending == EFX_RX_FLUSH_COUNT)
+					break;
+				if (rx_queue->flushed == FLUSH_FAILED ||
+				    rx_queue->flushed == FLUSH_NONE) {
+					efx_flush_rx_queue(rx_queue);
+					++rx_pending;
+				}
+			}
+			efx_for_each_channel_tx_queue(tx_queue, channel) {
+				if (tx_queue->flushed != FLUSH_DONE)
+					++tx_pending;
+			}
 		}
 
 		if (rx_pending == 0 && tx_pending == 0)
@@ -1261,19 +1272,21 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 
 	/* Mark the queues as all flushed. We're going to return failure
 	 * leading to a reset, or fake up success anyway */
-	efx_for_each_tx_queue(tx_queue, efx) {
-		if (tx_queue->flushed != FLUSH_DONE)
-			netif_err(efx, hw, efx->net_dev,
-				  "tx queue %d flush command timed out\n",
-				  tx_queue->queue);
-		tx_queue->flushed = FLUSH_DONE;
-	}
-	efx_for_each_rx_queue(rx_queue, efx) {
-		if (rx_queue->flushed != FLUSH_DONE)
-			netif_err(efx, hw, efx->net_dev,
-				  "rx queue %d flush command timed out\n",
-				  efx_rx_queue_index(rx_queue));
-		rx_queue->flushed = FLUSH_DONE;
+	efx_for_each_channel(channel, efx) {
+		efx_for_each_channel_tx_queue(tx_queue, channel) {
+			if (tx_queue->flushed != FLUSH_DONE)
+				netif_err(efx, hw, efx->net_dev,
+					  "tx queue %d flush command timed out\n",
+					  tx_queue->queue);
+			tx_queue->flushed = FLUSH_DONE;
+		}
+		efx_for_each_channel_rx_queue(rx_queue, channel) {
+			if (rx_queue->flushed != FLUSH_DONE)
+				netif_err(efx, hw, efx->net_dev,
+					  "rx queue %d flush command timed out\n",
+					  efx_rx_queue_index(rx_queue));
+			rx_queue->flushed = FLUSH_DONE;
+		}
 	}
 
 	return -ETIMEDOUT;
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 1e6c8cf..6651d93 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -311,7 +311,7 @@ static void efx_recycle_rx_buffer(struct efx_channel *channel,
 				  struct efx_rx_buffer *rx_buf)
 {
 	struct efx_nic *efx = channel->efx;
-	struct efx_rx_queue *rx_queue = &efx->rx_queue[channel->channel];
+	struct efx_rx_queue *rx_queue = efx_channel_get_rx_queue(channel);
 	struct efx_rx_buffer *new_buf;
 	unsigned index;
 
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 85f015f..11153d9 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -567,7 +567,7 @@ static int efx_wait_for_link(struct efx_nic *efx)
 			efx->type->monitor(efx);
 			mutex_unlock(&efx->mac_lock);
 		} else {
-			struct efx_channel *channel = &efx->channel[0];
+			struct efx_channel *channel = efx_get_channel(efx, 0);
 			if (channel->work_pending)
 				efx_process_channel_now(channel);
 		}
@@ -594,6 +594,7 @@ static int efx_test_loopbacks(struct efx_nic *efx, struct efx_self_tests *tests,
 {
 	enum efx_loopback_mode mode;
 	struct efx_loopback_state *state;
+	struct efx_channel *channel = efx_get_channel(efx, 0);
 	struct efx_tx_queue *tx_queue;
 	int rc = 0;
 
@@ -634,7 +635,7 @@ static int efx_test_loopbacks(struct efx_nic *efx, struct efx_self_tests *tests,
 		}
 
 		/* Test both types of TX queue */
-		efx_for_each_channel_tx_queue(tx_queue, &efx->channel[0]) {
+		efx_for_each_channel_tx_queue(tx_queue, channel) {
 			state->offload_csum = (tx_queue->queue &
 					       EFX_TXQ_TYPE_OFFLOAD);
 			rc = efx_test_loopback(tx_queue,
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index c6942da..6a6acc4 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -37,8 +37,9 @@
 void efx_stop_queue(struct efx_channel *channel)
 {
 	struct efx_nic *efx = channel->efx;
+	struct efx_tx_queue *tx_queue = efx_channel_get_tx_queue(channel, 0);
 
-	if (!channel->tx_queue)
+	if (!tx_queue)
 		return;
 
 	spin_lock_bh(&channel->tx_stop_lock);
@@ -46,9 +47,8 @@ void efx_stop_queue(struct efx_channel *channel)
 
 	atomic_inc(&channel->tx_stop_count);
 	netif_tx_stop_queue(
-		netdev_get_tx_queue(
-			efx->net_dev,
-			channel->tx_queue->queue / EFX_TXQ_TYPES));
+		netdev_get_tx_queue(efx->net_dev,
+				    tx_queue->queue / EFX_TXQ_TYPES));
 
 	spin_unlock_bh(&channel->tx_stop_lock);
 }
@@ -57,8 +57,9 @@ void efx_stop_queue(struct efx_channel *channel)
 void efx_wake_queue(struct efx_channel *channel)
 {
 	struct efx_nic *efx = channel->efx;
+	struct efx_tx_queue *tx_queue = efx_channel_get_tx_queue(channel, 0);
 
-	if (!channel->tx_queue)
+	if (!tx_queue)
 		return;
 
 	local_bh_disable();
@@ -66,9 +67,8 @@ void efx_wake_queue(struct efx_channel *channel)
 				&channel->tx_stop_lock)) {
 		netif_vdbg(efx, tx_queued, efx->net_dev, "waking TX queue\n");
 		netif_tx_wake_queue(
-			netdev_get_tx_queue(
-				efx->net_dev,
-				channel->tx_queue->queue / EFX_TXQ_TYPES));
+			netdev_get_tx_queue(efx->net_dev,
+					    tx_queue->queue / EFX_TXQ_TYPES));
 		spin_unlock(&channel->tx_stop_lock);
 	}
 	local_bh_enable();
@@ -390,9 +390,9 @@ netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
 	if (unlikely(efx->port_inhibited))
 		return NETDEV_TX_BUSY;
 
-	tx_queue = &efx->tx_queue[EFX_TXQ_TYPES * skb_get_queue_mapping(skb)];
-	if (likely(skb->ip_summed == CHECKSUM_PARTIAL))
-		tx_queue += EFX_TXQ_TYPE_OFFLOAD;
+	tx_queue = efx_get_tx_queue(efx, skb_get_queue_mapping(skb),
+				    skb->ip_summed == CHECKSUM_PARTIAL ?
+				    EFX_TXQ_TYPE_OFFLOAD : 0);
 
 	return efx_enqueue_skb(tx_queue, skb);
 }
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

