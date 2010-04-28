From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 17/17] sfc: Create multiple TX queues
Date: Wed, 28 Apr 2010 20:30:43 +0100
Message-ID: <1272483043.2549.33.camel@achroite.uk.solarflarecom.com>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12707 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756854Ab0D1Tar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:30:47 -0400
In-Reply-To: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a core TX queue and 2 hardware TX queues for each channel.
If separate_tx_channels is set, create equal numbers of RX and TX
channels instead.

Rewrite the channel and queue iteration macros accordingly.
Eliminate efx_channel::used_flags as redundant.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |  113 ++++++++++++++++++++++-------------------
 drivers/net/sfc/efx.h        |    4 +-
 drivers/net/sfc/ethtool.c    |    4 +-
 drivers/net/sfc/net_driver.h |   61 ++++++++++------------
 drivers/net/sfc/nic.c        |   12 ++--
 drivers/net/sfc/selftest.c   |    4 +-
 drivers/net/sfc/selftest.h   |    4 +-
 drivers/net/sfc/tx.c         |   61 ++++++++++++++---------
 8 files changed, 140 insertions(+), 123 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 5e3f944..bc75ef6 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -288,7 +288,7 @@ static int efx_poll(struct napi_struct *napi, int budget)
 	if (spent < budget) {
 		struct efx_nic *efx = channel->efx;
 
-		if (channel->used_flags & EFX_USED_BY_RX &&
+		if (channel->channel < efx->n_rx_channels &&
 		    efx->irq_rx_adaptive &&
 		    unlikely(++channel->irq_count == 1000)) {
 			if (unlikely(channel->irq_mod_score <
@@ -333,7 +333,6 @@ void efx_process_channel_now(struct efx_channel *channel)
 {
 	struct efx_nic *efx = channel->efx;
 
-	BUG_ON(!channel->used_flags);
 	BUG_ON(!channel->enabled);
 
 	/* Disable interrupts and wait for ISRs to complete */
@@ -446,12 +445,12 @@ static void efx_set_channel_names(struct efx_nic *efx)
 
 	efx_for_each_channel(channel, efx) {
 		number = channel->channel;
-		if (efx->n_channels > efx->n_rx_queues) {
-			if (channel->channel < efx->n_rx_queues) {
+		if (efx->n_channels > efx->n_rx_channels) {
+			if (channel->channel < efx->n_rx_channels) {
 				type = "-rx";
 			} else {
 				type = "-tx";
-				number -= efx->n_rx_queues;
+				number -= efx->n_rx_channels;
 			}
 		}
 		snprintf(channel->name, sizeof(channel->name),
@@ -585,8 +584,6 @@ static void efx_remove_channel(struct efx_channel *channel)
 	efx_for_each_channel_tx_queue(tx_queue, channel)
 		efx_remove_tx_queue(tx_queue);
 	efx_remove_eventq(channel);
-
-	channel->used_flags = 0;
 }
 
 void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue, int delay)
@@ -956,10 +953,9 @@ static void efx_fini_io(struct efx_nic *efx)
 	pci_disable_device(efx->pci_dev);
 }
 
-/* Get number of RX queues wanted.  Return number of online CPU
- * packages in the expectation that an IRQ balancer will spread
- * interrupts across them. */
-static int efx_wanted_rx_queues(void)
+/* Get number of channels wanted.  Each channel will have its own IRQ,
+ * 1 RX queue and/or 2 TX queues. */
+static int efx_wanted_channels(void)
 {
 	cpumask_var_t core_mask;
 	int count;
@@ -995,34 +991,39 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 
 	if (efx->interrupt_mode == EFX_INT_MODE_MSIX) {
 		struct msix_entry xentries[EFX_MAX_CHANNELS];
-		int wanted_ints;
-		int rx_queues;
+		int n_channels;
 
-		/* We want one RX queue and interrupt per CPU package
-		 * (or as specified by the rss_cpus module parameter).
-		 * We will need one channel per interrupt.
-		 */
-		rx_queues = rss_cpus ? rss_cpus : efx_wanted_rx_queues();
-		wanted_ints = rx_queues + (separate_tx_channels ? 1 : 0);
-		wanted_ints = min(wanted_ints, max_channels);
+		n_channels = efx_wanted_channels();
+		if (separate_tx_channels)
+			n_channels *= 2;
+		n_channels = min(n_channels, max_channels);
 
-		for (i = 0; i < wanted_ints; i++)
+		for (i = 0; i < n_channels; i++)
 			xentries[i].entry = i;
-		rc = pci_enable_msix(efx->pci_dev, xentries, wanted_ints);
+		rc = pci_enable_msix(efx->pci_dev, xentries, n_channels);
 		if (rc > 0) {
 			EFX_ERR(efx, "WARNING: Insufficient MSI-X vectors"
-				" available (%d < %d).\n", rc, wanted_ints);
+				" available (%d < %d).\n", rc, n_channels);
 			EFX_ERR(efx, "WARNING: Performance may be reduced.\n");
-			EFX_BUG_ON_PARANOID(rc >= wanted_ints);
-			wanted_ints = rc;
+			EFX_BUG_ON_PARANOID(rc >= n_channels);
+			n_channels = rc;
 			rc = pci_enable_msix(efx->pci_dev, xentries,
-					     wanted_ints);
+					     n_channels);
 		}
 
 		if (rc == 0) {
-			efx->n_rx_queues = min(rx_queues, wanted_ints);
-			efx->n_channels = wanted_ints;
-			for (i = 0; i < wanted_ints; i++)
+			efx->n_channels = n_channels;
+			if (separate_tx_channels) {
+				efx->n_tx_channels =
+					max(efx->n_channels / 2, 1U);
+				efx->n_rx_channels =
+					max(efx->n_channels -
+					    efx->n_tx_channels, 1U);
+			} else {
+				efx->n_tx_channels = efx->n_channels;
+				efx->n_rx_channels = efx->n_channels;
+			}
+			for (i = 0; i < n_channels; i++)
 				efx->channel[i].irq = xentries[i].vector;
 		} else {
 			/* Fall back to single channel MSI */
@@ -1033,8 +1034,9 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 
 	/* Try single interrupt MSI */
 	if (efx->interrupt_mode == EFX_INT_MODE_MSI) {
-		efx->n_rx_queues = 1;
 		efx->n_channels = 1;
+		efx->n_rx_channels = 1;
+		efx->n_tx_channels = 1;
 		rc = pci_enable_msi(efx->pci_dev);
 		if (rc == 0) {
 			efx->channel[0].irq = efx->pci_dev->irq;
@@ -1046,8 +1048,9 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 
 	/* Assume legacy interrupts */
 	if (efx->interrupt_mode == EFX_INT_MODE_LEGACY) {
-		efx->n_rx_queues = 1;
 		efx->n_channels = 1 + (separate_tx_channels ? 1 : 0);
+		efx->n_rx_channels = 1;
+		efx->n_tx_channels = 1;
 		efx->legacy_irq = efx->pci_dev->irq;
 	}
 }
@@ -1068,21 +1071,24 @@ static void efx_remove_interrupts(struct efx_nic *efx)
 
 static void efx_set_channels(struct efx_nic *efx)
 {
+	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
+	unsigned tx_channel_offset =
+		separate_tx_channels ? efx->n_channels - efx->n_tx_channels : 0;
 
-	efx_for_each_tx_queue(tx_queue, efx) {
-		if (separate_tx_channels)
-			tx_queue->channel = &efx->channel[efx->n_channels-1];
-		else
-			tx_queue->channel = &efx->channel[0];
-		tx_queue->channel->used_flags |= EFX_USED_BY_TX;
+	efx_for_each_channel(channel, efx) {
+		if (channel->channel - tx_channel_offset < efx->n_tx_channels) {
+			channel->tx_queue = &efx->tx_queue[
+				(channel->channel - tx_channel_offset) *
+				EFX_TXQ_TYPES];
+			efx_for_each_channel_tx_queue(tx_queue, channel)
+				tx_queue->channel = channel;
+		}
 	}
 
-	efx_for_each_rx_queue(rx_queue, efx) {
+	efx_for_each_rx_queue(rx_queue, efx)
 		rx_queue->channel = &efx->channel[rx_queue->queue];
-		rx_queue->channel->used_flags |= EFX_USED_BY_RX;
-	}
 }
 
 static int efx_probe_nic(struct efx_nic *efx)
@@ -1096,11 +1102,12 @@ static int efx_probe_nic(struct efx_nic *efx)
 	if (rc)
 		return rc;
 
-	/* Determine the number of channels and RX queues by trying to hook
+	/* Determine the number of channels and queues by trying to hook
 	 * in MSI-X interrupts. */
 	efx_probe_interrupts(efx);
 
 	efx_set_channels(efx);
+	efx->net_dev->real_num_tx_queues = efx->n_tx_channels;
 
 	/* Initialise the interrupt moderation settings */
 	efx_init_irq_moderation(efx, tx_irq_mod_usec, rx_irq_mod_usec, true);
@@ -1187,11 +1194,12 @@ static void efx_start_all(struct efx_nic *efx)
 	/* Mark the port as enabled so port reconfigurations can start, then
 	 * restart the transmit interface early so the watchdog timer stops */
 	efx_start_port(efx);
-	if (efx_dev_registered(efx))
-		efx_wake_queue(efx);
 
-	efx_for_each_channel(channel, efx)
+	efx_for_each_channel(channel, efx) {
+		if (efx_dev_registered(efx))
+			efx_wake_queue(channel);
 		efx_start_channel(channel);
+	}
 
 	efx_nic_enable_interrupts(efx);
 
@@ -1282,7 +1290,9 @@ static void efx_stop_all(struct efx_nic *efx)
 	/* Stop the kernel transmit interface late, so the watchdog
 	 * timer isn't ticking over the flush */
 	if (efx_dev_registered(efx)) {
-		efx_stop_queue(efx);
+		struct efx_channel *channel;
+		efx_for_each_channel(channel, efx)
+			efx_stop_queue(channel);
 		netif_tx_lock_bh(efx->net_dev);
 		netif_tx_unlock_bh(efx->net_dev);
 	}
@@ -1537,9 +1547,8 @@ static void efx_watchdog(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
-	EFX_ERR(efx, "TX stuck with stop_count=%d port_enabled=%d:"
-		" resetting channels\n",
-		atomic_read(&efx->netif_stop_count), efx->port_enabled);
+	EFX_ERR(efx, "TX stuck with port_enabled=%d: resetting channels\n",
+		efx->port_enabled);
 
 	efx_schedule_reset(efx, RESET_TYPE_TX_WATCHDOG);
 }
@@ -2014,22 +2023,22 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 
 	efx->net_dev = net_dev;
 	efx->rx_checksum_enabled = true;
-	spin_lock_init(&efx->netif_stop_lock);
 	spin_lock_init(&efx->stats_lock);
 	mutex_init(&efx->mac_lock);
 	efx->mac_op = type->default_mac_ops;
 	efx->phy_op = &efx_dummy_phy_operations;
 	efx->mdio.dev = net_dev;
 	INIT_WORK(&efx->mac_work, efx_mac_work);
-	atomic_set(&efx->netif_stop_count, 1);
 
 	for (i = 0; i < EFX_MAX_CHANNELS; i++) {
 		channel = &efx->channel[i];
 		channel->efx = efx;
 		channel->channel = i;
 		channel->work_pending = false;
+		spin_lock_init(&channel->tx_stop_lock);
+		atomic_set(&channel->tx_stop_count, 1);
 	}
-	for (i = 0; i < EFX_TX_QUEUE_COUNT; i++) {
+	for (i = 0; i < EFX_MAX_TX_QUEUES; i++) {
 		tx_queue = &efx->tx_queue[i];
 		tx_queue->efx = efx;
 		tx_queue->queue = i;
@@ -2201,7 +2210,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	int i, rc;
 
 	/* Allocate and initialise a struct net_device and struct efx_nic */
-	net_dev = alloc_etherdev(sizeof(*efx));
+	net_dev = alloc_etherdev_mq(sizeof(*efx), EFX_MAX_CORE_TX_QUEUES);
 	if (!net_dev)
 		return -ENOMEM;
 	net_dev->features |= (type->offload_features | NETIF_F_SG |
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 7eff0a6..ffd708c 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -35,8 +35,8 @@ efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_dev);
 extern netdev_tx_t
 efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb);
 extern void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
-extern void efx_stop_queue(struct efx_nic *efx);
-extern void efx_wake_queue(struct efx_nic *efx);
+extern void efx_stop_queue(struct efx_channel *channel);
+extern void efx_wake_queue(struct efx_channel *channel);
 #define EFX_TXQ_SIZE 1024
 #define EFX_TXQ_MASK (EFX_TXQ_SIZE - 1)
 
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index cbe9319..22026bf 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -647,7 +647,7 @@ static int efx_ethtool_get_coalesce(struct net_device *net_dev,
 	efx_for_each_tx_queue(tx_queue, efx) {
 		channel = tx_queue->channel;
 		if (channel->irq_moderation < coalesce->tx_coalesce_usecs_irq) {
-			if (channel->used_flags != EFX_USED_BY_RX_TX)
+			if (channel->channel < efx->n_rx_channels)
 				coalesce->tx_coalesce_usecs_irq =
 					channel->irq_moderation;
 			else
@@ -690,7 +690,7 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 
 	/* If the channel is shared only allow RX parameters to be set */
 	efx_for_each_tx_queue(tx_queue, efx) {
-		if ((tx_queue->channel->used_flags == EFX_USED_BY_RX_TX) &&
+		if ((tx_queue->channel->channel < efx->n_rx_channels) &&
 		    tx_usecs) {
 			EFX_ERR(efx, "Channel is shared. "
 				"Only RX coalescing may be set\n");
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index d68331c..2e6fd89 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -85,9 +85,13 @@ do {if (net_ratelimit()) EFX_LOG(efx, fmt, ##args); } while (0)
 #define EFX_MAX_CHANNELS 32
 #define EFX_MAX_RX_QUEUES EFX_MAX_CHANNELS
 
-#define EFX_TX_QUEUE_OFFLOAD_CSUM	0
-#define EFX_TX_QUEUE_NO_CSUM		1
-#define EFX_TX_QUEUE_COUNT		2
+/* Checksum generation is a per-queue option in hardware, so each
+ * queue visible to the networking core is backed by two hardware TX
+ * queues. */
+#define EFX_MAX_CORE_TX_QUEUES	EFX_MAX_CHANNELS
+#define EFX_TXQ_TYPE_OFFLOAD	1
+#define EFX_TXQ_TYPES		2
+#define EFX_MAX_TX_QUEUES	(EFX_TXQ_TYPES * EFX_MAX_CORE_TX_QUEUES)
 
 /**
  * struct efx_special_buffer - An Efx special buffer
@@ -187,7 +191,7 @@ struct efx_tx_buffer {
 struct efx_tx_queue {
 	/* Members which don't change on the fast path */
 	struct efx_nic *efx ____cacheline_aligned_in_smp;
-	int queue;
+	unsigned queue;
 	struct efx_channel *channel;
 	struct efx_nic *nic;
 	struct efx_tx_buffer *buffer;
@@ -306,11 +310,6 @@ struct efx_buffer {
 };
 

-/* Flags for channel->used_flags */
-#define EFX_USED_BY_RX 1
-#define EFX_USED_BY_TX 2
-#define EFX_USED_BY_RX_TX (EFX_USED_BY_RX | EFX_USED_BY_TX)
-
 enum efx_rx_alloc_method {
 	RX_ALLOC_METHOD_AUTO = 0,
 	RX_ALLOC_METHOD_SKB = 1,
@@ -327,7 +326,6 @@ enum efx_rx_alloc_method {
  * @efx: Associated Efx NIC
  * @channel: Channel instance number
  * @name: Name for channel and IRQ
- * @used_flags: Channel is used by net driver
  * @enabled: Channel enabled indicator
  * @irq: IRQ number (MSI and MSI-X only)
  * @irq_moderation: IRQ moderation value (in hardware ticks)
@@ -352,12 +350,14 @@ enum efx_rx_alloc_method {
  * @n_rx_frm_trunc: Count of RX_FRM_TRUNC errors
  * @n_rx_overlength: Count of RX_OVERLENGTH errors
  * @n_skbuff_leaks: Count of skbuffs leaked due to RX overrun
+ * @tx_queue: Pointer to first TX queue, or %NULL if not used for TX
+ * @tx_stop_count: Core TX queue stop count
+ * @tx_stop_lock: Core TX queue stop lock
  */
 struct efx_channel {
 	struct efx_nic *efx;
 	int channel;
 	char name[IFNAMSIZ + 6];
-	int used_flags;
 	bool enabled;
 	int irq;
 	unsigned int irq_moderation;
@@ -389,6 +389,9 @@ struct efx_channel {
 	struct efx_rx_buffer *rx_pkt;
 	bool rx_pkt_csummed;
 
+	struct efx_tx_queue *tx_queue;
+	atomic_t tx_stop_count;
+	spinlock_t tx_stop_lock;
 };
 
 enum efx_led_mode {
@@ -661,8 +664,9 @@ union efx_multicast_hash {
  * @rx_queue: RX DMA queues
  * @channel: Channels
  * @next_buffer_table: First available buffer table id
- * @n_rx_queues: Number of RX queues
  * @n_channels: Number of channels in use
+ * @n_rx_channels: Number of channels used for RX (= number of RX queues)
+ * @n_tx_channels: Number of channels used for TX
  * @rx_buffer_len: RX buffer length
  * @rx_buffer_order: Order (log2) of number of pages for each RX buffer
  * @int_error_count: Number of internal errors seen recently
@@ -693,8 +697,6 @@ union efx_multicast_hash {
  * @port_initialized: Port initialized?
  * @net_dev: Operating system network device. Consider holding the rtnl lock
  * @rx_checksum_enabled: RX checksumming enabled
- * @netif_stop_count: Port stop count
- * @netif_stop_lock: Port stop lock
  * @mac_stats: MAC statistics. These include all statistics the MACs
  *	can provide.  Generic code converts these into a standard
  *	&struct net_device_stats.
@@ -742,13 +744,14 @@ struct efx_nic {
 	enum nic_state state;
 	enum reset_type reset_pending;
 
-	struct efx_tx_queue tx_queue[EFX_TX_QUEUE_COUNT];
+	struct efx_tx_queue tx_queue[EFX_MAX_TX_QUEUES];
 	struct efx_rx_queue rx_queue[EFX_MAX_RX_QUEUES];
 	struct efx_channel channel[EFX_MAX_CHANNELS];
 
 	unsigned next_buffer_table;
-	int n_rx_queues;
-	int n_channels;
+	unsigned n_channels;
+	unsigned n_rx_channels;
+	unsigned n_tx_channels;
 	unsigned int rx_buffer_len;
 	unsigned int rx_buffer_order;
 
@@ -780,9 +783,6 @@ struct efx_nic {
 	struct net_device *net_dev;
 	bool rx_checksum_enabled;
 
-	atomic_t netif_stop_count;
-	spinlock_t netif_stop_lock;
-
 	struct efx_mac_stats mac_stats;
 	struct efx_buffer stats_buffer;
 	spinlock_t stats_lock;
@@ -928,31 +928,26 @@ struct efx_nic_type {
 /* Iterate over all used channels */
 #define efx_for_each_channel(_channel, _efx)				\
 	for (_channel = &((_efx)->channel[0]);				\
-	     _channel < &((_efx)->channel[EFX_MAX_CHANNELS]);		\
-	     _channel++)						\
-		if (!_channel->used_flags)				\
-			continue;					\
-		else
+	     _channel < &((_efx)->channel[(efx)->n_channels]);		\
+	     _channel++)
 
 /* Iterate over all used TX queues */
 #define efx_for_each_tx_queue(_tx_queue, _efx)				\
 	for (_tx_queue = &((_efx)->tx_queue[0]);			\
-	     _tx_queue < &((_efx)->tx_queue[EFX_TX_QUEUE_COUNT]);	\
+	     _tx_queue < &((_efx)->tx_queue[EFX_TXQ_TYPES *		\
+					    (_efx)->n_tx_channels]);	\
 	     _tx_queue++)
 
 /* Iterate over all TX queues belonging to a channel */
 #define efx_for_each_channel_tx_queue(_tx_queue, _channel)		\
-	for (_tx_queue = &((_channel)->efx->tx_queue[0]);		\
-	     _tx_queue < &((_channel)->efx->tx_queue[EFX_TX_QUEUE_COUNT]); \
-	     _tx_queue++)						\
-		if (_tx_queue->channel != (_channel))			\
-			continue;					\
-		else
+	for (_tx_queue = (_channel)->tx_queue;				\
+	     _tx_queue && _tx_queue < (_channel)->tx_queue + EFX_TXQ_TYPES; \
+	     _tx_queue++)
 
 /* Iterate over all used RX queues */
 #define efx_for_each_rx_queue(_rx_queue, _efx)				\
 	for (_rx_queue = &((_efx)->rx_queue[0]);			\
-	     _rx_queue < &((_efx)->rx_queue[(_efx)->n_rx_queues]);	\
+	     _rx_queue < &((_efx)->rx_queue[(_efx)->n_rx_channels]);	\
 	     _rx_queue++)
 
 /* Iterate over all RX queues belonging to a channel */
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index f3226bb..5d3aaec 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -418,7 +418,7 @@ void efx_nic_init_tx(struct efx_tx_queue *tx_queue)
 			      FRF_BZ_TX_NON_IP_DROP_DIS, 1);
 
 	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
-		int csum = tx_queue->queue == EFX_TX_QUEUE_OFFLOAD_CSUM;
+		int csum = tx_queue->queue & EFX_TXQ_TYPE_OFFLOAD;
 		EFX_SET_OWORD_FIELD(tx_desc_ptr, FRF_BZ_TX_IP_CHKSM_DIS, !csum);
 		EFX_SET_OWORD_FIELD(tx_desc_ptr, FRF_BZ_TX_TCP_CHKSM_DIS,
 				    !csum);
@@ -431,10 +431,10 @@ void efx_nic_init_tx(struct efx_tx_queue *tx_queue)
 		efx_oword_t reg;
 
 		/* Only 128 bits in this register */
-		BUILD_BUG_ON(EFX_TX_QUEUE_COUNT >= 128);
+		BUILD_BUG_ON(EFX_MAX_TX_QUEUES > 128);
 
 		efx_reado(efx, &reg, FR_AA_TX_CHKSM_CFG);
-		if (tx_queue->queue == EFX_TX_QUEUE_OFFLOAD_CSUM)
+		if (tx_queue->queue & EFX_TXQ_TYPE_OFFLOAD)
 			clear_bit_le(tx_queue->queue, (void *)&reg);
 		else
 			set_bit_le(tx_queue->queue, (void *)&reg);
@@ -1132,7 +1132,7 @@ static void efx_poll_flush_events(struct efx_nic *efx)
 		    ev_sub_code == FSE_AZ_TX_DESCQ_FLS_DONE_EV) {
 			ev_queue = EFX_QWORD_FIELD(*event,
 						   FSF_AZ_DRIVER_EV_SUBDATA);
-			if (ev_queue < EFX_TX_QUEUE_COUNT) {
+			if (ev_queue < EFX_TXQ_TYPES * efx->n_tx_channels) {
 				tx_queue = efx->tx_queue + ev_queue;
 				tx_queue->flushed = FLUSH_DONE;
 			}
@@ -1142,7 +1142,7 @@ static void efx_poll_flush_events(struct efx_nic *efx)
 				*event, FSF_AZ_DRIVER_EV_RX_DESCQ_ID);
 			ev_failed = EFX_QWORD_FIELD(
 				*event, FSF_AZ_DRIVER_EV_RX_FLUSH_FAIL);
-			if (ev_queue < efx->n_rx_queues) {
+			if (ev_queue < efx->n_rx_channels) {
 				rx_queue = efx->rx_queue + ev_queue;
 				rx_queue->flushed =
 					ev_failed ? FLUSH_FAILED : FLUSH_DONE;
@@ -1441,7 +1441,7 @@ static void efx_setup_rss_indir_table(struct efx_nic *efx)
 	     offset < FR_BZ_RX_INDIRECTION_TBL + 0x800;
 	     offset += 0x10) {
 		EFX_POPULATE_DWORD_1(dword, FRF_BZ_IT_QUEUE,
-				     i % efx->n_rx_queues);
+				     i % efx->n_rx_channels);
 		efx_writed(efx, &dword, offset);
 		i++;
 	}
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 3a16e06..371e86c 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -618,8 +618,8 @@ static int efx_test_loopbacks(struct efx_nic *efx, struct efx_self_tests *tests,
 
 		/* Test both types of TX queue */
 		efx_for_each_channel_tx_queue(tx_queue, &efx->channel[0]) {
-			state->offload_csum = (tx_queue->queue ==
-					       EFX_TX_QUEUE_OFFLOAD_CSUM);
+			state->offload_csum = (tx_queue->queue &
+					       EFX_TXQ_TYPE_OFFLOAD);
 			rc = efx_test_loopback(tx_queue,
 					       &tests->loopback[mode]);
 			if (rc)
diff --git a/drivers/net/sfc/selftest.h b/drivers/net/sfc/selftest.h
index 643bef7..aed495a 100644
--- a/drivers/net/sfc/selftest.h
+++ b/drivers/net/sfc/selftest.h
@@ -18,8 +18,8 @@
  */
 
 struct efx_loopback_self_tests {
-	int tx_sent[EFX_TX_QUEUE_COUNT];
-	int tx_done[EFX_TX_QUEUE_COUNT];
+	int tx_sent[EFX_TXQ_TYPES];
+	int tx_done[EFX_TXQ_TYPES];
 	int rx_good;
 	int rx_bad;
 };
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index be0e110..6bb12a8 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -30,32 +30,46 @@
  */
 #define EFX_TXQ_THRESHOLD (EFX_TXQ_MASK / 2u)
 
-/* We want to be able to nest calls to netif_stop_queue(), since each
- * channel can have an individual stop on the queue.
- */
-void efx_stop_queue(struct efx_nic *efx)
+/* We need to be able to nest calls to netif_tx_stop_queue(), partly
+ * because of the 2 hardware queues associated with each core queue,
+ * but also so that we can inhibit TX for reasons other than a full
+ * hardware queue. */
+void efx_stop_queue(struct efx_channel *channel)
 {
-	spin_lock_bh(&efx->netif_stop_lock);
+	struct efx_nic *efx = channel->efx;
+
+	if (!channel->tx_queue)
+		return;
+
+	spin_lock_bh(&channel->tx_stop_lock);
 	EFX_TRACE(efx, "stop TX queue\n");
 
-	atomic_inc(&efx->netif_stop_count);
-	netif_stop_queue(efx->net_dev);
+	atomic_inc(&channel->tx_stop_count);
+	netif_tx_stop_queue(
+		netdev_get_tx_queue(
+			efx->net_dev,
+			channel->tx_queue->queue / EFX_TXQ_TYPES));
 
-	spin_unlock_bh(&efx->netif_stop_lock);
+	spin_unlock_bh(&channel->tx_stop_lock);
 }
 
-/* Wake netif's TX queue
- * We want to be able to nest calls to netif_stop_queue(), since each
- * channel can have an individual stop on the queue.
- */
-void efx_wake_queue(struct efx_nic *efx)
+/* Decrement core TX queue stop count and wake it if the count is 0 */
+void efx_wake_queue(struct efx_channel *channel)
 {
+	struct efx_nic *efx = channel->efx;
+
+	if (!channel->tx_queue)
+		return;
+
 	local_bh_disable();
-	if (atomic_dec_and_lock(&efx->netif_stop_count,
-				&efx->netif_stop_lock)) {
+	if (atomic_dec_and_lock(&channel->tx_stop_count,
+				&channel->tx_stop_lock)) {
 		EFX_TRACE(efx, "waking TX queue\n");
-		netif_wake_queue(efx->net_dev);
-		spin_unlock(&efx->netif_stop_lock);
+		netif_tx_wake_queue(
+			netdev_get_tx_queue(
+				efx->net_dev,
+				channel->tx_queue->queue / EFX_TXQ_TYPES));
+		spin_unlock(&channel->tx_stop_lock);
 	}
 	local_bh_enable();
 }
@@ -298,7 +312,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	rc = NETDEV_TX_BUSY;
 
 	if (tx_queue->stopped == 1)
-		efx_stop_queue(efx);
+		efx_stop_queue(tx_queue->channel);
 
  unwind:
 	/* Work backwards until we hit the original insert pointer value */
@@ -374,10 +388,9 @@ netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
 	if (unlikely(efx->port_inhibited))
 		return NETDEV_TX_BUSY;
 
+	tx_queue = &efx->tx_queue[EFX_TXQ_TYPES * skb_get_queue_mapping(skb)];
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL))
-		tx_queue = &efx->tx_queue[EFX_TX_QUEUE_OFFLOAD_CSUM];
-	else
-		tx_queue = &efx->tx_queue[EFX_TX_QUEUE_NO_CSUM];
+		tx_queue += EFX_TXQ_TYPE_OFFLOAD;
 
 	return efx_enqueue_skb(tx_queue, skb);
 }
@@ -405,7 +418,7 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 			netif_tx_lock(efx->net_dev);
 			if (tx_queue->stopped) {
 				tx_queue->stopped = 0;
-				efx_wake_queue(efx);
+				efx_wake_queue(tx_queue->channel);
 			}
 			netif_tx_unlock(efx->net_dev);
 		}
@@ -488,7 +501,7 @@ void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
 	/* Release queue's stop on port, if any */
 	if (tx_queue->stopped) {
 		tx_queue->stopped = 0;
-		efx_wake_queue(tx_queue->efx);
+		efx_wake_queue(tx_queue->channel);
 	}
 }
 
@@ -1120,7 +1133,7 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 
 	/* Stop the queue if it wasn't stopped before. */
 	if (tx_queue->stopped == 1)
-		efx_stop_queue(efx);
+		efx_stop_queue(tx_queue->channel);
 
  unwind:
 	/* Free the DMA mapping we were in the process of writing out */
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

