From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 11/13] dmaengine: kill struct dma_client and supporting
	infrastructure
Date: Fri, 14 Nov 2008 14:35:13 -0700
Message-ID: <20081114213513.32354.58256.stgit@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24595 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755989AbYKNVfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 16:35:17 -0500
In-Reply-To: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All users have been converted to either the general-purpose allocator,
dma_find_channel, or dma_request_channel.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 drivers/dma/dmaengine.c      |   74 +-------------------------------
 drivers/dma/dw_dmac.c        |    3 -
 drivers/dma/fsldma.c         |    3 -
 drivers/dma/ioat_dma.c       |    5 +-
 drivers/dma/iop-adma.c       |    7 +--
 drivers/dma/mv_xor.c         |    7 +--
 drivers/mmc/host/atmel-mci.c |    1 
 include/linux/dmaengine.h    |   36 ---------------
 net/core/dev.c               |   98 +-----------------------------------------
 9 files changed, 17 insertions(+), 217 deletions(-)

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index 78456f5..26f862c 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -31,15 +31,12 @@
  *
  * LOCKING:
  *
- * The subsystem keeps two global lists, dma_device_list and dma_client_list.
- * Both of these are protected by a mutex, dma_list_mutex.
+ * The subsystem keeps a global list of dma_device structs it is protected by a
+ * mutex, dma_list_mutex.
  *
  * Each device has a channels list, which runs unlocked but is never modified
  * once the device is registered, it's just setup by the driver.
  *
- * Each client is responsible for keeping track of the channels it uses.  See
- * the definition of dma_event_callback in dmaengine.h.
- *
  * Each device has a kref, which is initialized to 1 when the device is
  * registered. A kref_get is done for each device registered.  When the
  * device is released, the corresponding kref_put is done in the release
@@ -74,7 +71,6 @@
 
 static DEFINE_MUTEX(dma_list_mutex);
 static LIST_HEAD(dma_device_list);
-static LIST_HEAD(dma_client_list);
 static long dmaengine_ref_count;
 
 /* --- sysfs implementation --- */
@@ -184,7 +180,7 @@ static int dma_chan_get(struct dma_chan *chan)
 
 	/* allocate upon first client reference */
 	if (chan->client_count == 1 && err == 0) {
-		int desc = chan->device->device_alloc_chan_resources(chan, NULL);
+		int desc = chan->device->device_alloc_chan_resources(chan);
 
 		if (desc < 0) {
 			chan->client_count = 0;
@@ -207,40 +203,6 @@ static void dma_chan_put(struct dma_chan *chan)
 		chan->device->device_free_chan_resources(chan);
 }
 
-/**
- * dma_client_chan_alloc - try to allocate channels to a client
- * @client: &dma_client
- *
- * Called with dma_list_mutex held.
- */
-static void dma_client_chan_alloc(struct dma_client *client)
-{
-	struct dma_device *device;
-	struct dma_chan *chan;
-	enum dma_state_client ack;
-
-	/* Find a channel */
-	list_for_each_entry(device, &dma_device_list, global_node) {
-		if (dma_has_cap(DMA_PRIVATE, device->cap_mask))
-			continue;
-
-		list_for_each_entry(chan, &device->channels, device_node) {
-			if (!dma_chan_satisfies_mask(chan, client->cap_mask))
-				continue;
-			if (!chan->client_count)
-				continue;
-			ack = client->event_callback(client, chan,
-						     DMA_RESOURCE_AVAILABLE);
-
-			/* we are done once this client rejects
-			 * an available resource
-			 */
-			if (ack == DMA_NAK)
-				return;
-		}
-	}
-}
-
 enum dma_status dma_sync_wait(struct dma_chan *chan, dma_cookie_t cookie)
 {
 	enum dma_status status;
@@ -573,21 +535,6 @@ void dma_release_channel(struct dma_chan *chan)
 EXPORT_SYMBOL_GPL(dma_release_channel);
 
 /**
- * dma_chans_notify_available - broadcast available channels to the clients
- */
-static void dma_clients_notify_available(void)
-{
-	struct dma_client *client;
-
-	mutex_lock(&dma_list_mutex);
-
-	list_for_each_entry(client, &dma_client_list, global_node)
-		dma_client_chan_alloc(client);
-
-	mutex_unlock(&dma_list_mutex);
-}
-
-/**
  * dmaengine_get - register interest in dma_channels
  */
 void dmaengine_get(void)
@@ -641,19 +588,6 @@ void dmaengine_put(void)
 EXPORT_SYMBOL(dmaengine_put);
 
 /**
- * dma_async_client_chan_request - send all available channels to the
- * client that satisfy the capability mask
- * @client - requester
- */
-void dma_async_client_chan_request(struct dma_client *client)
-{
-	mutex_lock(&dma_list_mutex);
-	dma_client_chan_alloc(client);
-	mutex_unlock(&dma_list_mutex);
-}
-EXPORT_SYMBOL(dma_async_client_chan_request);
-
-/**
  * dma_async_device_register - registers DMA devices found
  * @device: &dma_device
  */
@@ -743,8 +677,6 @@ int dma_async_device_register(struct dma_device *device)
 	dma_channel_rebalance();
 	mutex_unlock(&dma_list_mutex);
 
-	dma_clients_notify_available();
-
 	return 0;
 
 err_out:
diff --git a/drivers/dma/dw_dmac.c b/drivers/dma/dw_dmac.c
index dbd5080..a29dda8 100644
--- a/drivers/dma/dw_dmac.c
+++ b/drivers/dma/dw_dmac.c
@@ -758,8 +758,7 @@ static void dwc_issue_pending(struct dma_chan *chan)
 	spin_unlock_bh(&dwc->lock);
 }
 
-static int dwc_alloc_chan_resources(struct dma_chan *chan,
-		struct dma_client *client)
+static int dwc_alloc_chan_resources(struct dma_chan *chan)
 {
 	struct dw_dma_chan	*dwc = to_dw_dma_chan(chan);
 	struct dw_dma		*dw = to_dw_dma(chan->device);
diff --git a/drivers/dma/fsldma.c b/drivers/dma/fsldma.c
index 0b95dcc..46e0128 100644
--- a/drivers/dma/fsldma.c
+++ b/drivers/dma/fsldma.c
@@ -366,8 +366,7 @@ static struct fsl_desc_sw *fsl_dma_alloc_descriptor(
  *
  * Return - The number of descriptors allocated.
  */
-static int fsl_dma_alloc_chan_resources(struct dma_chan *chan,
-					struct dma_client *client)
+static int fsl_dma_alloc_chan_resources(struct dma_chan *chan)
 {
 	struct fsl_dma_chan *fsl_chan = to_fsl_chan(chan);
 
diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat_dma.c
index ecd743f..c746fb7 100644
--- a/drivers/dma/ioat_dma.c
+++ b/drivers/dma/ioat_dma.c
@@ -734,8 +734,7 @@ static void ioat2_dma_massage_chan_desc(struct ioat_dma_chan *ioat_chan)
  * ioat_dma_alloc_chan_resources - returns the number of allocated descriptors
  * @chan: the channel to be filled out
  */
-static int ioat_dma_alloc_chan_resources(struct dma_chan *chan,
-					 struct dma_client *client)
+static int ioat_dma_alloc_chan_resources(struct dma_chan *chan)
 {
 	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
 	struct ioat_desc_sw *desc;
@@ -1379,7 +1378,7 @@ static int ioat_dma_self_test(struct ioatdma_device *device)
 	dma_chan = container_of(device->common.channels.next,
 				struct dma_chan,
 				device_node);
-	if (device->common.device_alloc_chan_resources(dma_chan, NULL) < 1) {
+	if (device->common.device_alloc_chan_resources(dma_chan) < 1) {
 		dev_err(&device->pdev->dev,
 			"selftest cannot allocate chan resource\n");
 		err = -ENODEV;
diff --git a/drivers/dma/iop-adma.c b/drivers/dma/iop-adma.c
index f008ab2..44c483e 100644
--- a/drivers/dma/iop-adma.c
+++ b/drivers/dma/iop-adma.c
@@ -460,8 +460,7 @@ static void iop_chan_start_null_xor(struct iop_adma_chan *iop_chan);
  * greater than 2x the number slots needed to satisfy a device->max_xor
  * request.
  * */
-static int iop_adma_alloc_chan_resources(struct dma_chan *chan,
-					 struct dma_client *client)
+static int iop_adma_alloc_chan_resources(struct dma_chan *chan)
 {
 	char *hw_desc;
 	int idx;
@@ -855,7 +854,7 @@ static int __devinit iop_adma_memcpy_self_test(struct iop_adma_device *device)
 	dma_chan = container_of(device->common.channels.next,
 				struct dma_chan,
 				device_node);
-	if (iop_adma_alloc_chan_resources(dma_chan, NULL) < 1) {
+	if (iop_adma_alloc_chan_resources(dma_chan) < 1) {
 		err = -ENODEV;
 		goto out;
 	}
@@ -953,7 +952,7 @@ iop_adma_xor_zero_sum_self_test(struct iop_adma_device *device)
 	dma_chan = container_of(device->common.channels.next,
 				struct dma_chan,
 				device_node);
-	if (iop_adma_alloc_chan_resources(dma_chan, NULL) < 1) {
+	if (iop_adma_alloc_chan_resources(dma_chan) < 1) {
 		err = -ENODEV;
 		goto out;
 	}
diff --git a/drivers/dma/mv_xor.c b/drivers/dma/mv_xor.c
index c3fcaa8..dabdc36 100644
--- a/drivers/dma/mv_xor.c
+++ b/drivers/dma/mv_xor.c
@@ -597,8 +597,7 @@ submit_done:
 }
 
 /* returns the number of allocated descriptors */
-static int mv_xor_alloc_chan_resources(struct dma_chan *chan,
-				       struct dma_client *client)
+static int mv_xor_alloc_chan_resources(struct dma_chan *chan)
 {
 	char *hw_desc;
 	int idx;
@@ -948,7 +947,7 @@ static int __devinit mv_xor_memcpy_self_test(struct mv_xor_device *device)
 	dma_chan = container_of(device->common.channels.next,
 				struct dma_chan,
 				device_node);
-	if (mv_xor_alloc_chan_resources(dma_chan, NULL) < 1) {
+	if (mv_xor_alloc_chan_resources(dma_chan) < 1) {
 		err = -ENODEV;
 		goto out;
 	}
@@ -1043,7 +1042,7 @@ mv_xor_xor_self_test(struct mv_xor_device *device)
 	dma_chan = container_of(device->common.channels.next,
 				struct dma_chan,
 				device_node);
-	if (mv_xor_alloc_chan_resources(dma_chan, NULL) < 1) {
+	if (mv_xor_alloc_chan_resources(dma_chan) < 1) {
 		err = -ENODEV;
 		goto out;
 	}
diff --git a/drivers/mmc/host/atmel-mci.c b/drivers/mmc/host/atmel-mci.c
index 7a34118..4b567a0 100644
--- a/drivers/mmc/host/atmel-mci.c
+++ b/drivers/mmc/host/atmel-mci.c
@@ -55,7 +55,6 @@ enum atmel_mci_state {
 
 struct atmel_mci_dma {
 #ifdef CONFIG_MMC_ATMELMCI_DMA
-	struct dma_client		client;
 	struct dma_chan			*chan;
 	struct dma_async_tx_descriptor	*data_desc;
 #endif
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index 37d95db..ad9fd55 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -170,23 +170,6 @@ struct dma_chan {
 
 void dma_chan_cleanup(struct kref *kref);
 
-/*
- * typedef dma_event_callback - function pointer to a DMA event callback
- * For each channel added to the system this routine is called for each client.
- * If the client would like to use the channel it returns '1' to signal (ack)
- * the dmaengine core to take out a reference on the channel and its
- * corresponding device.  A client must not 'ack' an available channel more
- * than once.  When a channel is removed all clients are notified.  If a client
- * is using the channel it must 'ack' the removal.  A client must not 'ack' a
- * removed channel more than once.
- * @client - 'this' pointer for the client context
- * @chan - channel to be acted upon
- * @state - available or removed
- */
-struct dma_client;
-typedef enum dma_state_client (*dma_event_callback) (struct dma_client *client,
-		struct dma_chan *chan, enum dma_state state);
-
 /**
  * typedef dma_filter_fn - callback filter for dma_request_channel
  * @chan: channel to be reviewed
@@ -199,21 +182,6 @@ typedef enum dma_state_client (*dma_event_callback) (struct dma_client *client,
  */
 typedef enum dma_state_client (*dma_filter_fn)(struct dma_chan *chan, void *filter_param);
 
-/**
- * struct dma_client - info on the entity making use of DMA services
- * @event_callback: func ptr to call when something happens
- * @cap_mask: only return channels that satisfy the requested capabilities
- *  a value of zero corresponds to any capability
- * @slave: data for preparing slave transfer. Must be non-NULL iff the
- *  DMA_SLAVE capability is requested.
- * @global_node: list_head for global dma_client_list
- */
-struct dma_client {
-	dma_event_callback	event_callback;
-	dma_cap_mask_t		cap_mask;
-	struct list_head	global_node;
-};
-
 typedef void (*dma_async_tx_callback)(void *dma_async_param);
 /**
  * struct dma_async_tx_descriptor - async transaction descriptor
@@ -285,8 +253,7 @@ struct dma_device {
 	int dev_id;
 	struct device *dev;
 
-	int (*device_alloc_chan_resources)(struct dma_chan *chan,
-			struct dma_client *client);
+	int (*device_alloc_chan_resources)(struct dma_chan *chan);
 	void (*device_free_chan_resources)(struct dma_chan *chan);
 
 	struct dma_async_tx_descriptor *(*device_prep_dma_memcpy)(
@@ -320,7 +287,6 @@ struct dma_device {
 
 void dmaengine_get(void);
 void dmaengine_put(void);
-void dma_async_client_chan_request(struct dma_client *client);
 dma_cookie_t dma_async_memcpy_buf_to_buf(struct dma_chan *chan,
 	void *dest, void *src, size_t len);
 dma_cookie_t dma_async_memcpy_buf_to_pg(struct dma_chan *chan,
diff --git a/net/core/dev.c b/net/core/dev.c
index 4b3b7d3..cf1abd1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -165,25 +165,6 @@ static DEFINE_SPINLOCK(ptype_lock);
 static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
 static struct list_head ptype_all __read_mostly;	/* Taps */
 
-#ifdef CONFIG_NET_DMA
-struct net_dma {
-	struct dma_client client;
-	spinlock_t lock;
-	cpumask_t channel_mask;
-	struct dma_chan **channels;
-};
-
-static enum dma_state_client
-netdev_dma_event(struct dma_client *client, struct dma_chan *chan,
-	enum dma_state state);
-
-static struct net_dma net_dma = {
-	.client = {
-		.event_callback = netdev_dma_event,
-	},
-};
-#endif
-
 /*
  * The @dev_base_head list is protected by @dev_base_lock and the rtnl
  * semaphore.
@@ -4589,81 +4570,6 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	return NOTIFY_OK;
 }
 
-#ifdef CONFIG_NET_DMA
-/**
- * netdev_dma_event - event callback for the net_dma_client
- * @client: should always be net_dma_client
- * @chan: DMA channel for the event
- * @state: DMA state to be handled
- */
-static enum dma_state_client
-netdev_dma_event(struct dma_client *client, struct dma_chan *chan,
-	enum dma_state state)
-{
-	int i, found = 0, pos = -1;
-	struct net_dma *net_dma =
-		container_of(client, struct net_dma, client);
-	enum dma_state_client ack = DMA_DUP; /* default: take no action */
-
-	spin_lock(&net_dma->lock);
-	switch (state) {
-	case DMA_RESOURCE_AVAILABLE:
-		for (i = 0; i < nr_cpu_ids; i++)
-			if (net_dma->channels[i] == chan) {
-				found = 1;
-				break;
-			} else if (net_dma->channels[i] == NULL && pos < 0)
-				pos = i;
-
-		if (!found && pos >= 0) {
-			ack = DMA_ACK;
-			net_dma->channels[pos] = chan;
-			cpu_set(pos, net_dma->channel_mask);
-		}
-		break;
-	case DMA_RESOURCE_REMOVED:
-		for (i = 0; i < nr_cpu_ids; i++)
-			if (net_dma->channels[i] == chan) {
-				found = 1;
-				pos = i;
-				break;
-			}
-
-		if (found) {
-			ack = DMA_ACK;
-			cpu_clear(pos, net_dma->channel_mask);
-			net_dma->channels[i] = NULL;
-		}
-		break;
-	default:
-		break;
-	}
-	spin_unlock(&net_dma->lock);
-
-	return ack;
-}
-
-/**
- * netdev_dma_register - register the networking subsystem as a DMA client
- */
-static int __init netdev_dma_register(void)
-{
-	net_dma.channels = kzalloc(nr_cpu_ids * sizeof(struct net_dma),
-								GFP_KERNEL);
-	if (unlikely(!net_dma.channels)) {
-		printk(KERN_NOTICE
-				"netdev_dma: no memory for net_dma.channels\n");
-		return -ENOMEM;
-	}
-	spin_lock_init(&net_dma.lock);
-	dma_cap_set(DMA_MEMCPY, net_dma.client.cap_mask);
-	dmaengine_get();
-	return 0;
-}
-
-#else
-static int __init netdev_dma_register(void) { return -ENODEV; }
-#endif /* CONFIG_NET_DMA */
 
 /**
  *	netdev_increment_features - increment feature set by one
@@ -4860,7 +4766,9 @@ static int __init net_dev_init(void)
 		queue->backlog.weight = weight_p;
 	}
 
-	netdev_dma_register();
+	#ifdef CONFIG_NET_DMA
+	dmaengine_get();
+	#endif
 
 	dev_boot_phase = 0;
 

