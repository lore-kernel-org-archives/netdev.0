From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 10/10] sfc: Allow changing the DMA ring sizes
 dynamically via ethtool
Date: Fri, 10 Sep 2010 17:42:33 +0100
Message-ID: <1284136953.2267.105.camel@achroite.uk.solarflarecom.com>
References: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25815 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755811Ab0IJQmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 12:42:37 -0400
In-Reply-To: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This requires some reorganisation of channel setup and teardown to
ensure that we can always roll-back a failed change.

Based on work by Steve Hodgson <shodgson@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |  218 +++++++++++++++++++++++++++++++++---------
 drivers/net/sfc/efx.h        |    7 ++
 drivers/net/sfc/ethtool.c    |   38 +++++++
 drivers/net/sfc/net_driver.h |    4 +-
 drivers/net/sfc/nic.c        |    9 +-
 5 files changed, 224 insertions(+), 52 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 6166e22..f702f1f 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -201,10 +201,13 @@ MODULE_PARM_DESC(debug, "Bitmapped debugging message enable value");
  * Utility functions and prototypes
  *
  *************************************************************************/
-static void efx_remove_channel(struct efx_channel *channel);
+
+static void efx_remove_channels(struct efx_nic *efx);
 static void efx_remove_port(struct efx_nic *efx);
 static void efx_fini_napi(struct efx_nic *efx);
-static void efx_fini_channels(struct efx_nic *efx);
+static void efx_fini_struct(struct efx_nic *efx);
+static void efx_start_all(struct efx_nic *efx);
+static void efx_stop_all(struct efx_nic *efx);
 
 #define EFX_ASSERT_RESET_SERIALISED(efx)		\
 	do {						\
@@ -413,6 +416,63 @@ static void efx_remove_eventq(struct efx_channel *channel)
  *
  *************************************************************************/
 
+/* Allocate and initialise a channel structure, optionally copying
+ * parameters (but not resources) from an old channel structure. */
+static struct efx_channel *
+efx_alloc_channel(struct efx_nic *efx, int i, struct efx_channel *old_channel)
+{
+	struct efx_channel *channel;
+	struct efx_rx_queue *rx_queue;
+	struct efx_tx_queue *tx_queue;
+	int j;
+
+	if (old_channel) {
+		channel = kmalloc(sizeof(*channel), GFP_KERNEL);
+		if (!channel)
+			return NULL;
+
+		*channel = *old_channel;
+
+		memset(&channel->eventq, 0, sizeof(channel->eventq));
+
+		rx_queue = &channel->rx_queue;
+		rx_queue->buffer = NULL;
+		memset(&rx_queue->rxd, 0, sizeof(rx_queue->rxd));
+
+		for (j = 0; j < EFX_TXQ_TYPES; j++) {
+			tx_queue = &channel->tx_queue[j];
+			if (tx_queue->channel)
+				tx_queue->channel = channel;
+			tx_queue->buffer = NULL;
+			memset(&tx_queue->txd, 0, sizeof(tx_queue->txd));
+		}
+	} else {
+		channel = kzalloc(sizeof(*channel), GFP_KERNEL);
+		if (!channel)
+			return NULL;
+
+		channel->efx = efx;
+		channel->channel = i;
+
+		for (j = 0; j < EFX_TXQ_TYPES; j++) {
+			tx_queue = &channel->tx_queue[j];
+			tx_queue->efx = efx;
+			tx_queue->queue = i * EFX_TXQ_TYPES + j;
+			tx_queue->channel = channel;
+		}
+	}
+
+	spin_lock_init(&channel->tx_stop_lock);
+	atomic_set(&channel->tx_stop_count, 1);
+
+	rx_queue = &channel->rx_queue;
+	rx_queue->efx = efx;
+	setup_timer(&rx_queue->slow_fill, efx_rx_slow_fill,
+		    (unsigned long)rx_queue);
+
+	return channel;
+}
+
 static int efx_probe_channel(struct efx_channel *channel)
 {
 	struct efx_tx_queue *tx_queue;
@@ -469,11 +529,38 @@ static void efx_set_channel_names(struct efx_nic *efx)
 				number -= efx->n_rx_channels;
 			}
 		}
-		snprintf(channel->name, sizeof(channel->name),
+		snprintf(efx->channel_name[channel->channel],
+			 sizeof(efx->channel_name[0]),
 			 "%s%s-%d", efx->name, type, number);
 	}
 }
 
+static int efx_probe_channels(struct efx_nic *efx)
+{
+	struct efx_channel *channel;
+	int rc;
+
+	/* Restart special buffer allocation */
+	efx->next_buffer_table = 0;
+
+	efx_for_each_channel(channel, efx) {
+		rc = efx_probe_channel(channel);
+		if (rc) {
+			netif_err(efx, probe, efx->net_dev,
+				  "failed to create channel %d\n",
+				  channel->channel);
+			goto fail;
+		}
+	}
+	efx_set_channel_names(efx);
+
+	return 0;
+
+fail:
+	efx_remove_channels(efx);
+	return rc;
+}
+
 /* Channels are shutdown and reinitialised whilst the NIC is running
  * to propagate configuration changes (mtu, checksum offload), or
  * to clear hardware error conditions
@@ -611,6 +698,75 @@ static void efx_remove_channel(struct efx_channel *channel)
 	efx_remove_eventq(channel);
 }
 
+static void efx_remove_channels(struct efx_nic *efx)
+{
+	struct efx_channel *channel;
+
+	efx_for_each_channel(channel, efx)
+		efx_remove_channel(channel);
+}
+
+int
+efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries)
+{
+	struct efx_channel *other_channel[EFX_MAX_CHANNELS], *channel;
+	u32 old_rxq_entries, old_txq_entries;
+	unsigned i;
+	int rc;
+
+	efx_stop_all(efx);
+	efx_fini_channels(efx);
+
+	/* Clone channels */
+	memset(other_channel, 0, sizeof(other_channel));
+	for (i = 0; i < efx->n_channels; i++) {
+		channel = efx_alloc_channel(efx, i, efx->channel[i]);
+		if (!channel) {
+			rc = -ENOMEM;
+			goto out;
+		}
+		other_channel[i] = channel;
+	}
+
+	/* Swap entry counts and channel pointers */
+	old_rxq_entries = efx->rxq_entries;
+	old_txq_entries = efx->txq_entries;
+	efx->rxq_entries = rxq_entries;
+	efx->txq_entries = txq_entries;
+	for (i = 0; i < efx->n_channels; i++) {
+		channel = efx->channel[i];
+		efx->channel[i] = other_channel[i];
+		other_channel[i] = channel;
+	}
+
+	rc = efx_probe_channels(efx);
+	if (rc)
+		goto rollback;
+
+	/* Destroy old channels */
+	for (i = 0; i < efx->n_channels; i++)
+		efx_remove_channel(other_channel[i]);
+out:
+	/* Free unused channel structures */
+	for (i = 0; i < efx->n_channels; i++)
+		kfree(other_channel[i]);
+
+	efx_init_channels(efx);
+	efx_start_all(efx);
+	return rc;
+
+rollback:
+	/* Swap back */
+	efx->rxq_entries = old_rxq_entries;
+	efx->txq_entries = old_txq_entries;
+	for (i = 0; i < efx->n_channels; i++) {
+		channel = efx->channel[i];
+		efx->channel[i] = other_channel[i];
+		other_channel[i] = channel;
+	}
+	goto out;
+}
+
 void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue)
 {
 	mod_timer(&rx_queue->slow_fill, jiffies + msecs_to_jiffies(100));
@@ -1182,41 +1338,28 @@ static void efx_remove_nic(struct efx_nic *efx)
 
 static int efx_probe_all(struct efx_nic *efx)
 {
-	struct efx_channel *channel;
 	int rc;
 
-	/* Create NIC */
 	rc = efx_probe_nic(efx);
 	if (rc) {
 		netif_err(efx, probe, efx->net_dev, "failed to create NIC\n");
 		goto fail1;
 	}
 
-	/* Create port */
 	rc = efx_probe_port(efx);
 	if (rc) {
 		netif_err(efx, probe, efx->net_dev, "failed to create port\n");
 		goto fail2;
 	}
 
-	/* Create channels */
 	efx->rxq_entries = efx->txq_entries = EFX_DEFAULT_DMAQ_SIZE;
-	efx_for_each_channel(channel, efx) {
-		rc = efx_probe_channel(channel);
-		if (rc) {
-			netif_err(efx, probe, efx->net_dev,
-				  "failed to create channel %d\n",
-				  channel->channel);
-			goto fail3;
-		}
-	}
-	efx_set_channel_names(efx);
+	rc = efx_probe_channels(efx);
+	if (rc)
+		goto fail3;
 
 	return 0;
 
  fail3:
-	efx_for_each_channel(channel, efx)
-		efx_remove_channel(channel);
 	efx_remove_port(efx);
  fail2:
 	efx_remove_nic(efx);
@@ -1346,10 +1489,7 @@ static void efx_stop_all(struct efx_nic *efx)
 
 static void efx_remove_all(struct efx_nic *efx)
 {
-	struct efx_channel *channel;
-
-	efx_for_each_channel(channel, efx)
-		efx_remove_channel(channel);
+	efx_remove_channels(efx);
 	efx_remove_port(efx);
 	efx_remove_nic(efx);
 }
@@ -2058,10 +2198,7 @@ static struct efx_phy_operations efx_dummy_phy_operations = {
 static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 			   struct pci_dev *pci_dev, struct net_device *net_dev)
 {
-	struct efx_channel *channel;
-	struct efx_tx_queue *tx_queue;
-	struct efx_rx_queue *rx_queue;
-	int i, j;
+	int i;
 
 	/* Initialise common structures */
 	memset(efx, 0, sizeof(*efx));
@@ -2089,24 +2226,9 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	INIT_WORK(&efx->mac_work, efx_mac_work);
 
 	for (i = 0; i < EFX_MAX_CHANNELS; i++) {
-		efx->channel[i] = kzalloc(sizeof(*channel), GFP_KERNEL);
-		channel = efx->channel[i];
-		channel->efx = efx;
-		channel->channel = i;
-		spin_lock_init(&channel->tx_stop_lock);
-		atomic_set(&channel->tx_stop_count, 1);
-
-		for (j = 0; j < EFX_TXQ_TYPES; j++) {
-			tx_queue = &channel->tx_queue[j];
-			tx_queue->efx = efx;
-			tx_queue->queue = i * EFX_TXQ_TYPES + j;
-			tx_queue->channel = channel;
-		}
-
-		rx_queue = &channel->rx_queue;
-		rx_queue->efx = efx;
-		setup_timer(&rx_queue->slow_fill, efx_rx_slow_fill,
-			    (unsigned long)rx_queue);
+		efx->channel[i] = efx_alloc_channel(efx, i, NULL);
+		if (!efx->channel[i])
+			goto fail;
 	}
 
 	efx->type = type;
@@ -2122,9 +2244,13 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 		 pci_name(pci_dev));
 	efx->workqueue = create_singlethread_workqueue(efx->workqueue_name);
 	if (!efx->workqueue)
-		return -ENOMEM;
+		goto fail;
 
 	return 0;
+
+fail:
+	efx_fini_struct(efx);
+	return -ENOMEM;
 }
 
 static void efx_fini_struct(struct efx_nic *efx)
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index c15a2d3..e783c0f 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -59,8 +59,15 @@ extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue);
 #define EFX_MAX_EVQ_SIZE 16384UL
 #define EFX_MIN_EVQ_SIZE 512UL
 
+/* The smallest [rt]xq_entries that the driver supports. Callers of
+ * efx_wake_queue() assume that they can subsequently send at least one
+ * skb. Falcon/A1 may require up to three descriptors per skb_frag. */
+#define EFX_MIN_RING_SIZE (roundup_pow_of_two(2 * 3 * MAX_SKB_FRAGS))
+
 /* Channels */
 extern void efx_process_channel_now(struct efx_channel *channel);
+extern int
+efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries);
 
 /* Ports */
 extern int efx_reconfigure_port(struct efx_nic *efx);
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index b9291db..7f735d8 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -742,6 +742,42 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 	return 0;
 }
 
+static void efx_ethtool_get_ringparam(struct net_device *net_dev,
+				      struct ethtool_ringparam *ring)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	ring->rx_max_pending = EFX_MAX_DMAQ_SIZE;
+	ring->tx_max_pending = EFX_MAX_DMAQ_SIZE;
+	ring->rx_mini_max_pending = 0;
+	ring->rx_jumbo_max_pending = 0;
+	ring->rx_pending = efx->rxq_entries;
+	ring->tx_pending = efx->txq_entries;
+	ring->rx_mini_pending = 0;
+	ring->rx_jumbo_pending = 0;
+}
+
+static int efx_ethtool_set_ringparam(struct net_device *net_dev,
+				     struct ethtool_ringparam *ring)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	if (ring->rx_mini_pending || ring->rx_jumbo_pending ||
+	    ring->rx_pending > EFX_MAX_DMAQ_SIZE ||
+	    ring->tx_pending > EFX_MAX_DMAQ_SIZE)
+		return -EINVAL;
+
+	if (ring->rx_pending < EFX_MIN_RING_SIZE ||
+	    ring->tx_pending < EFX_MIN_RING_SIZE) {
+		netif_err(efx, drv, efx->net_dev,
+			  "TX and RX queues cannot be smaller than %ld\n",
+			  EFX_MIN_RING_SIZE);
+		return -EINVAL;
+	}
+
+	return efx_realloc_channels(efx, ring->rx_pending, ring->tx_pending);
+}
+
 static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 				      struct ethtool_pauseparam *pause)
 {
@@ -972,6 +1008,8 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.set_eeprom		= efx_ethtool_set_eeprom,
 	.get_coalesce		= efx_ethtool_get_coalesce,
 	.set_coalesce		= efx_ethtool_set_coalesce,
+	.get_ringparam		= efx_ethtool_get_ringparam,
+	.set_ringparam		= efx_ethtool_set_ringparam,
 	.get_pauseparam         = efx_ethtool_get_pauseparam,
 	.set_pauseparam         = efx_ethtool_set_pauseparam,
 	.get_rx_csum		= efx_ethtool_get_rx_csum,
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index ac622ab..4b3f680 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -299,7 +299,6 @@ enum efx_rx_alloc_method {
  *
  * @efx: Associated Efx NIC
  * @channel: Channel instance number
- * @name: Name for channel and IRQ
  * @enabled: Channel enabled indicator
  * @irq: IRQ number (MSI and MSI-X only)
  * @irq_moderation: IRQ moderation value (in hardware ticks)
@@ -333,7 +332,6 @@ enum efx_rx_alloc_method {
 struct efx_channel {
 	struct efx_nic *efx;
 	int channel;
-	char name[IFNAMSIZ + 6];
 	bool enabled;
 	int irq;
 	unsigned int irq_moderation;
@@ -644,6 +642,7 @@ union efx_multicast_hash {
  * @tx_queue: TX DMA queues
  * @rx_queue: RX DMA queues
  * @channel: Channels
+ * @channel_name: Names for channels and their IRQs
  * @rxq_entries: Size of receive queues requested by user.
  * @txq_entries: Size of transmit queues requested by user.
  * @next_buffer_table: First available buffer table id
@@ -730,6 +729,7 @@ struct efx_nic {
 	enum reset_type reset_pending;
 
 	struct efx_channel *channel[EFX_MAX_CHANNELS];
+	char channel_name[IFNAMSIZ + 6][EFX_MAX_CHANNELS];
 
 	unsigned rxq_entries;
 	unsigned txq_entries;
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 0deb5c3..6c5c0ce 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1478,7 +1478,7 @@ static irqreturn_t efx_legacy_interrupt(int irq, void *dev_id)
  */
 static irqreturn_t efx_msi_interrupt(int irq, void *dev_id)
 {
-	struct efx_channel *channel = dev_id;
+	struct efx_channel *channel = *(struct efx_channel **)dev_id;
 	struct efx_nic *efx = channel->efx;
 	efx_oword_t *int_ker = efx->irq_status.addr;
 	int syserr;
@@ -1553,7 +1553,8 @@ int efx_nic_init_interrupt(struct efx_nic *efx)
 	efx_for_each_channel(channel, efx) {
 		rc = request_irq(channel->irq, efx_msi_interrupt,
 				 IRQF_PROBE_SHARED, /* Not shared */
-				 channel->name, channel);
+				 efx->channel_name[channel->channel],
+				 &efx->channel[channel->channel]);
 		if (rc) {
 			netif_err(efx, drv, efx->net_dev,
 				  "failed to hook IRQ %d\n", channel->irq);
@@ -1565,7 +1566,7 @@ int efx_nic_init_interrupt(struct efx_nic *efx)
 
  fail2:
 	efx_for_each_channel(channel, efx)
-		free_irq(channel->irq, channel);
+		free_irq(channel->irq, &efx->channel[channel->channel]);
  fail1:
 	return rc;
 }
@@ -1578,7 +1579,7 @@ void efx_nic_fini_interrupt(struct efx_nic *efx)
 	/* Disable MSI/MSI-X interrupts */
 	efx_for_each_channel(channel, efx) {
 		if (channel->irq)
-			free_irq(channel->irq, channel);
+			free_irq(channel->irq, &efx->channel[channel->channel]);
 	}
 
 	/* ACK legacy interrupt */
-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

