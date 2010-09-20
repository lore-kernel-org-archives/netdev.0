From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH 3/3] sfc: Add support for NUMA affinity control
Date: Mon, 20 Sep 2010 13:48:24 +0100
Message-ID: <1284986904.2282.51.camel@achroite.uk.solarflarecom.com>
References: <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com>
	 <1283356463.2556.351.camel@edumazet-laptop>
	 <AANLkTinOfkr=+_61kb+bZf_0brcahQz8b_P6TWhUgFka@mail.gmail.com>
	 <20100901.183251.106803238.davem@davemloft.net>
	 <1284673961.2283.57.camel@achroite.uk.solarflarecom.com>
	 <20100919172451.GA12878@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	eric.dumazet@gmail.com, shemminger@vyatta.com,
	netdev <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:39145 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755395Ab0ITMs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 08:48:28 -0400
In-Reply-To: <20100919172451.GA12878@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow channel structures and hardware queues to be reallocated with
specific affinity.
---
The reallocation code is admittedly rather complicated and ugly.

Ben.

 drivers/net/sfc/efx.c        |  115 ++++++++++++++++++++++++++++++++++++------
 drivers/net/sfc/efx.h        |    4 +-
 drivers/net/sfc/ethtool.c    |   72 ++++++++++++++++++++++++++-
 drivers/net/sfc/net_driver.h |   12 ++++
 drivers/net/sfc/nic.c        |   47 ++++++++++++-----
 5 files changed, 220 insertions(+), 30 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index f702f1f..a116d2a 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -416,10 +416,74 @@ static void efx_remove_eventq(struct efx_channel *channel)
  *
  *************************************************************************/
 
+static struct efx_channel *
+efx_clone_channel_with_affinity(struct efx_nic *efx,
+				struct efx_channel *old_channel,
+				const struct ethtool_affinity *affin)
+{
+#ifdef CONFIG_NUMA
+	struct net_device *net_dev = efx->net_dev;
+	struct efx_channel *channel;
+	unsigned irq = (efx->interrupt_mode == EFX_INT_MODE_LEGACY ?
+			efx->legacy_irq : old_channel->irq);
+	int node_id;
+
+	node_id = ethtool_affinity_resolve(affin->handler_data_node,
+					   net_dev, irq);
+	if (node_id < NUMA_NO_NODE)
+		return ERR_PTR(node_id);
+			
+	channel = kmalloc_node(sizeof(*channel), GFP_KERNEL, node_id);
+	if (!channel)
+		return ERR_PTR(-ENOMEM);
+	*channel = *old_channel;
+	channel->channel_node = node_id;
+
+	if (efx_channel_get_rx_queue(old_channel)) {
+		node_id = ethtool_affinity_resolve(affin->rx_ring_node,
+						   net_dev, irq);
+		if (node_id < NUMA_NO_NODE)
+			goto fail;
+		channel->rxq_node = node_id;
+	} else {
+		if (affin->rx_ring_node != ETH_NUMA_NODE_N_A &&
+		    affin->rx_ring_node != ETH_NUMA_NODE_UNSET)
+			return ERR_PTR(-EINVAL);
+	}
+
+	if (efx_channel_get_tx_queue(old_channel, 0)) {
+		node_id = ethtool_affinity_resolve(affin->tx_ring_node,
+						   net_dev, irq);
+		if (node_id < NUMA_NO_NODE)
+			goto fail;
+		channel->txq_node = node_id;
+	} else {
+		if (affin->tx_ring_node != ETH_NUMA_NODE_N_A &&
+		    affin->tx_ring_node != ETH_NUMA_NODE_UNSET)
+			return ERR_PTR(-EINVAL);
+	}
+
+	node_id = ethtool_affinity_resolve(affin->event_ring_node,
+					   net_dev, irq);
+	if (node_id < NUMA_NO_NODE)
+		goto fail;
+	channel->evq_node = node_id;
+
+	return channel;
+
+fail:
+	kfree(channel);
+	return ERR_PTR(node_id);
+#else /* !CONFIG_NUMA */
+	return ERR_PTR(-EOPNOTSUPP);
+#endif /* CONFIG_NUMA */
+}
+
 /* Allocate and initialise a channel structure, optionally copying
  * parameters (but not resources) from an old channel structure. */
 static struct efx_channel *
-efx_alloc_channel(struct efx_nic *efx, int i, struct efx_channel *old_channel)
+efx_alloc_channel(struct efx_nic *efx, int i, struct efx_channel *old_channel,
+		  const struct ethtool_affinity *new_affin)
 {
 	struct efx_channel *channel;
 	struct efx_rx_queue *rx_queue;
@@ -427,11 +491,18 @@ efx_alloc_channel(struct efx_nic *efx, int i, struct efx_channel *old_channel)
 	int j;
 
 	if (old_channel) {
-		channel = kmalloc(sizeof(*channel), GFP_KERNEL);
-		if (!channel)
-			return NULL;
-
-		*channel = *old_channel;
+		if (new_affin) {
+			channel = efx_clone_channel_with_affinity(
+				efx, old_channel, new_affin);
+			if (IS_ERR(channel))
+				return channel;
+		} else {
+			channel = kmalloc_node(sizeof(*channel), GFP_KERNEL,
+					       old_channel->channel_node);
+			if (!channel)
+				return ERR_PTR(-ENOMEM);
+			*channel = *old_channel;
+		}
 
 		memset(&channel->eventq, 0, sizeof(channel->eventq));
 
@@ -449,10 +520,13 @@ efx_alloc_channel(struct efx_nic *efx, int i, struct efx_channel *old_channel)
 	} else {
 		channel = kzalloc(sizeof(*channel), GFP_KERNEL);
 		if (!channel)
-			return NULL;
+			return ERR_PTR(-ENOMEM);
 
 		channel->efx = efx;
 		channel->channel = i;
+		channel->rxq_node = channel->txq_node =
+			dev_to_node(&efx->pci_dev->dev);
+		channel->evq_node = channel->channel_node = numa_node_id();
 
 		for (j = 0; j < EFX_TXQ_TYPES; j++) {
 			tx_queue = &channel->tx_queue[j];
@@ -707,7 +781,9 @@ static void efx_remove_channels(struct efx_nic *efx)
 }
 
 int
-efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries)
+efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries,
+		     struct efx_channel *affin_channel,
+		     const struct ethtool_affinity *affin)
 {
 	struct efx_channel *other_channel[EFX_MAX_CHANNELS], *channel;
 	u32 old_rxq_entries, old_txq_entries;
@@ -720,9 +796,13 @@ efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries)
 	/* Clone channels */
 	memset(other_channel, 0, sizeof(other_channel));
 	for (i = 0; i < efx->n_channels; i++) {
-		channel = efx_alloc_channel(efx, i, efx->channel[i]);
-		if (!channel) {
-			rc = -ENOMEM;
+		const struct ethtool_affinity *new_affin =
+			(affin_channel == NULL ||
+			 affin_channel == efx->channel[i]) ? affin : NULL;
+
+		channel = efx_alloc_channel(efx, i, efx->channel[i], new_affin);
+		if (IS_ERR(channel)) {
+			rc = PTR_ERR(channel);
 			goto out;
 		}
 		other_channel[i] = channel;
@@ -1281,13 +1361,16 @@ static void efx_set_channels(struct efx_nic *efx)
 	unsigned tx_channel_offset =
 		separate_tx_channels ? efx->n_channels - efx->n_tx_channels : 0;
 
-	/* Channel pointers were set in efx_init_struct() but we now
-	 * need to clear them for TX queues in any RX-only channels. */
+	/* Invalidate pointers and node IDs for unused RX and TX queue
+	 * structures */
 	efx_for_each_channel(channel, efx) {
+		if (channel->channel >= efx->n_rx_channels)
+			channel->rxq_node = ETH_NUMA_NODE_N_A;
 		if (channel->channel - tx_channel_offset >=
 		    efx->n_tx_channels) {
 			efx_for_each_channel_tx_queue(tx_queue, channel)
 				tx_queue->channel = NULL;
+			channel->txq_node = ETH_NUMA_NODE_N_A;
 		}
 	}
 }
@@ -2198,6 +2281,7 @@ static struct efx_phy_operations efx_dummy_phy_operations = {
 static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 			   struct pci_dev *pci_dev, struct net_device *net_dev)
 {
+	struct efx_channel *channel;
 	int i;
 
 	/* Initialise common structures */
@@ -2226,9 +2310,10 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	INIT_WORK(&efx->mac_work, efx_mac_work);
 
 	for (i = 0; i < EFX_MAX_CHANNELS; i++) {
-		efx->channel[i] = efx_alloc_channel(efx, i, NULL);
-		if (!efx->channel[i])
+		channel = efx_alloc_channel(efx, i, NULL, NULL);
+		if (IS_ERR(channel))
 			goto fail;
+		efx->channel[i] = channel;
 	}
 
 	efx->type = type;
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index e783c0f..8baad6f 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -67,7 +67,9 @@ extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue);
 /* Channels */
 extern void efx_process_channel_now(struct efx_channel *channel);
 extern int
-efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries);
+efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries,
+		     struct efx_channel *channel,
+		     const struct ethtool_affinity *affin);
 
 /* Ports */
 extern int efx_reconfigure_port(struct efx_nic *efx);
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 7f735d8..4029819 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -775,7 +775,8 @@ static int efx_ethtool_set_ringparam(struct net_device *net_dev,
 		return -EINVAL;
 	}
 
-	return efx_realloc_channels(efx, ring->rx_pending, ring->tx_pending);
+	return efx_realloc_channels(efx, ring->rx_pending, ring->tx_pending,
+				    NULL, NULL);
 }
 
 static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
@@ -993,6 +994,70 @@ static int efx_ethtool_set_rxfh_indir(struct net_device *net_dev,
 	return 0;
 }
 
+static int efx_ethtool_get_channels(struct net_device *net_dev,
+				    struct ethtool_channels *channels)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	channels->rx_count = efx->n_channels - efx->n_tx_channels;
+	channels->tx_count = efx->n_channels - efx->n_rx_channels;
+	channels->combined_count = (efx->n_channels - channels->rx_count -
+				    channels->tx_count);
+	channels->other_count = 0;
+	return 0;
+}
+
+#ifdef CONFIG_NUMA
+
+static struct efx_channel *
+efx_channel_from_id(struct efx_nic *efx, u32 channel_id)
+{
+	u32 channel_index = channel_id & ETH_CHAN_INDEX_MASK;
+
+	switch (channel_id & ETH_CHAN_TYPE_MASK) {
+	case ETH_CHAN_TYPE_RX:
+		return efx_get_channel(efx, channel_index);
+	case ETH_CHAN_TYPE_COMBINED:
+		return efx_get_channel(efx,
+				       efx->n_channels - efx->n_tx_channels +
+				       channel_index);
+	case ETH_CHAN_TYPE_TX:
+		return efx_get_channel(efx, efx->n_rx_channels + channel_index);
+	default:
+		BUG();
+	}
+}
+
+static int efx_ethtool_get_affinity(struct net_device *net_dev,
+				    struct ethtool_affinity *affin)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	struct efx_channel *channel =
+		efx_channel_from_id(efx, affin->channel_id);
+
+	affin->rx_ring_node = channel->rxq_node;
+	affin->tx_ring_node = channel->txq_node;
+	affin->event_ring_node = channel->evq_node;
+	affin->handler_data_node = channel->channel_node;
+	return 0;
+}
+
+static int efx_ethtool_set_affinity(struct net_device *net_dev,
+				    const struct ethtool_affinity *affin)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	struct efx_channel *channel;
+
+	if (affin->channel_id == ETH_CHAN_ALL)
+		channel = NULL;
+	else
+		channel = efx_channel_from_id(efx, affin->channel_id);
+	return efx_realloc_channels(efx, efx->rxq_entries, efx->txq_entries,
+				    channel, affin);
+}
+
+#endif /* CONFIG_NUMA */
+
 const struct ethtool_ops efx_ethtool_ops = {
 	.get_settings		= efx_ethtool_get_settings,
 	.set_settings		= efx_ethtool_set_settings,
@@ -1035,4 +1100,9 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.get_rxnfc		= efx_ethtool_get_rxnfc,
 	.get_rxfh_indir		= efx_ethtool_get_rxfh_indir,
 	.set_rxfh_indir		= efx_ethtool_set_rxfh_indir,
+	.get_channels		= efx_ethtool_get_channels,
+#ifdef CONFIG_NUMA
+	.get_affinity		= efx_ethtool_get_affinity,
+	.set_affinity		= efx_ethtool_set_affinity,
+#endif
 };
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 152342d..de69ac3 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -69,8 +69,10 @@
 
 /**
  * struct efx_special_buffer - An Efx special buffer
+ * @page: Page pointer, iff buffer was allocated with alloc_pages_node()
  * @addr: CPU base address of the buffer
  * @dma_addr: DMA base address of the buffer
+ * @dma_dir: Direction of DMA mapping
  * @len: Buffer length, in bytes
  * @index: Buffer index within controller;s buffer table
  * @entries: Number of buffer table entries
@@ -80,8 +82,10 @@
  * actual transmit and receive buffers.
  */
 struct efx_special_buffer {
+	struct page *page;
 	void *addr;
 	dma_addr_t dma_addr;
+	enum dma_data_direction dma_dir;
 	unsigned int len;
 	int index;
 	int entries;
@@ -299,6 +303,10 @@ enum efx_rx_alloc_method {
  *
  * @efx: Associated Efx NIC
  * @channel: Channel instance number
+ * @rxq_node: Hardware RX queue NUMA affinity
+ * @txq_node: Hardware TX queue NUMA affinity
+ * @evq_node: Hardware event queue NUMA affinity
+ * @channel_node: NUMA affinity for this structure
  * @enabled: Channel enabled indicator
  * @irq: IRQ number (MSI and MSI-X only)
  * @irq_moderation: IRQ moderation value (in hardware ticks)
@@ -332,6 +340,10 @@ enum efx_rx_alloc_method {
 struct efx_channel {
 	struct efx_nic *efx;
 	int channel;
+	int rxq_node;
+	int txq_node;
+	int evq_node;
+	int channel_node;
 	bool enabled;
 	int irq;
 	unsigned int irq_moderation;
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 6c5c0ce..799e881 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -259,17 +259,31 @@ efx_fini_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
  */
 static int efx_alloc_special_buffer(struct efx_nic *efx,
 				    struct efx_special_buffer *buffer,
-				    unsigned int len)
+				    unsigned int len,
+				    int node_id,
+				    enum dma_data_direction dma_dir)
 {
+	unsigned int order;
+
 	len = ALIGN(len, EFX_BUF_SIZE);
+	buffer->dma_dir = dma_dir;
 
-	buffer->addr = dma_alloc_coherent(&efx->pci_dev->dev, len,
-					  &buffer->dma_addr, GFP_KERNEL);
-	if (!buffer->addr)
+	order = order_base_2(DIV_ROUND_UP(len, PAGE_SIZE));
+	buffer->page = alloc_pages_node(node_id, GFP_KERNEL, order);
+	if (!buffer->page)
+		return -ENOMEM;
+
+	buffer->dma_addr = dma_map_page(&efx->pci_dev->dev, buffer->page, 0,
+					buffer->len, buffer->dma_dir);
+	if (unlikely(dma_mapping_error(&efx->pci_dev->dev, buffer->dma_addr))) {
+		__free_pages(buffer->page, order);
 		return -ENOMEM;
+	}
+	EFX_BUG_ON_PARANOID(buffer->dma_addr & (EFX_BUF_SIZE - 1));
+
+	buffer->addr = page_address(buffer->page);
 	buffer->len = len;
 	buffer->entries = len / EFX_BUF_SIZE;
-	BUG_ON(buffer->dma_addr & (EFX_BUF_SIZE - 1));
 
 	/* All zeros is a potentially valid event so memset to 0xff */
 	memset(buffer->addr, 0xff, len);
@@ -291,6 +305,8 @@ static int efx_alloc_special_buffer(struct efx_nic *efx,
 static void
 efx_free_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 {
+	unsigned int order;
+
 	if (!buffer->addr)
 		return;
 
@@ -301,8 +317,10 @@ efx_free_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 		  (u64)buffer->dma_addr, buffer->len,
 		  buffer->addr, (u64)virt_to_phys(buffer->addr));
 
-	dma_free_coherent(&efx->pci_dev->dev, buffer->len, buffer->addr,
-			  buffer->dma_addr);
+	order = order_base_2(DIV_ROUND_UP(buffer->len, PAGE_SIZE));
+	dma_unmap_page(&efx->pci_dev->dev, buffer->dma_addr,
+		       buffer->len, buffer->dma_dir);
+	__free_pages(buffer->page, order);
 	buffer->addr = NULL;
 	buffer->entries = 0;
 }
@@ -401,8 +419,9 @@ int efx_nic_probe_tx(struct efx_tx_queue *tx_queue)
 	unsigned entries;
 
 	entries = tx_queue->ptr_mask + 1;
-	return efx_alloc_special_buffer(efx, &tx_queue->txd,
-					entries * sizeof(efx_qword_t));
+	return efx_alloc_special_buffer(
+		efx, &tx_queue->txd, entries * sizeof(efx_qword_t),
+		tx_queue->channel->txq_node, DMA_TO_DEVICE);
 }
 
 void efx_nic_init_tx(struct efx_tx_queue *tx_queue)
@@ -551,8 +570,9 @@ int efx_nic_probe_rx(struct efx_rx_queue *rx_queue)
 	unsigned entries;
 
 	entries = rx_queue->ptr_mask + 1;
-	return efx_alloc_special_buffer(efx, &rx_queue->rxd,
-					entries * sizeof(efx_qword_t));
+	return efx_alloc_special_buffer(
+		efx, &rx_queue->rxd, entries * sizeof(efx_qword_t),
+		efx_rx_queue_channel(rx_queue)->rxq_node, DMA_TO_DEVICE);
 }
 
 void efx_nic_init_rx(struct efx_rx_queue *rx_queue)
@@ -1080,8 +1100,9 @@ int efx_nic_probe_eventq(struct efx_channel *channel)
 	unsigned entries;
 
 	entries = channel->eventq_mask + 1;
-	return efx_alloc_special_buffer(efx, &channel->eventq,
-					entries * sizeof(efx_qword_t));
+	return efx_alloc_special_buffer(
+		efx, &channel->eventq, entries * sizeof(efx_qword_t),
+		channel->evq_node, DMA_BIDIRECTIONAL);
 }
 
 void efx_nic_init_eventq(struct efx_channel *channel)
-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

