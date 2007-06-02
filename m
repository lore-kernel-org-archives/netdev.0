From: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC PATCH 2/2] dmaengine: move channel management to the client
Date: Fri, 01 Jun 2007 17:17:59 -0700
Message-ID: <20070602001759.1707.35870.stgit@dwillia2-linux.ch.intel.com>
References: <20070602001527.1707.58092.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	christopher.leech@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50710 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761430AbXFBASA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2007 20:18:00 -0400
In-Reply-To: <20070602001527.1707.58092.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This effectively makes channels a shared resource rather than tying them
to a specific client.  dmaengine now assumes that clients will internally
track how many channels they need and dmaengine will learn if the client cares about
a channel at dma_event_callback time.  This also enables a client to ignore
a channel if it does not meet extra client specific constraints beyond
simple base capabilities.

This patch also fixes up the NET_DMA client to use the new mechanism.

Changelog:
* removed DMA_TX_ARRAY_INIT, no longer needed
* dma_client_chan_free -> dma_chan_release: switch to global reference
  counting only at device unregistration time, before it was also happening
  at client unregistration time
* clients now return dma_state_client to dmaengine (ack, dup, nak)

Cc: Chris Leech <christopher.leech@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 drivers/dma/dmaengine.c   |  213 +++++++++++++++++++++++----------------------
 drivers/dma/ioatdma.c     |    1 
 drivers/dma/ioatdma.h     |    3 -
 include/linux/dmaengine.h |   75 ++++++++--------
 net/core/dev.c            |  111 ++++++++++++++++-------
 5 files changed, 220 insertions(+), 183 deletions(-)

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index 8a49103..927a8ac 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -37,11 +37,11 @@
  * Each device has a channels list, which runs unlocked but is never modified
  * once the device is registered, it's just setup by the driver.
  *
- * Each client has a channels list, it's only modified under the client->lock
- * and in an RCU callback, so it's safe to read under rcu_read_lock().
+ * Each client is responsible for keeping track of the channels it uses.  See
+ * the definition of dma_event_callback in dmaengine.h.
  *
  * Each device has a kref, which is initialized to 1 when the device is
- * registered. A kref_put is done for each class_device registered.  When the
+ * registered. A kref_get is done for each class_device registered.  When the
  * class_device is released, the coresponding kref_put is done in the release
  * method. Every time one of the device's channels is allocated to a client,
  * a kref_get occurs.  When the channel is freed, the coresponding kref_put
@@ -51,10 +51,12 @@
  * references to finish.
  *
  * Each channel has an open-coded implementation of Rusty Russell's "bigref,"
- * with a kref and a per_cpu local_t.  A single reference is set when on an
- * ADDED event, and removed with a REMOVE event.  Net DMA client takes an
- * extra reference per outstanding transaction.  The relase function does a
- * kref_put on the device. -ChrisL
+ * with a kref and a per_cpu local_t.  A dma_chan_get is called when a client
+ * signals that it wants to use a channel, and dma_chan_put is called when
+ * a channel is removed or a client using it is unregesitered.  A client can
+ * take extra references per outstanding transaction, as is the case with
+ * the NET DMA client.  The release function does a kref_put on the device.
+ *	-ChrisL, DanW
  */
 
 #include <linux/init.h>
@@ -102,8 +104,18 @@ static ssize_t show_bytes_transferred(struct class_device *cd, char *buf)
 static ssize_t show_in_use(struct class_device *cd, char *buf)
 {
 	struct dma_chan *chan = container_of(cd, struct dma_chan, class_dev);
+	int in_use = 0;
+
+	if (unlikely(chan->slow_ref) && atomic_read(&chan->refcount.refcount) > 1)
+		in_use = 1;
+	else {
+		if (local_read(&(per_cpu_ptr(chan->local,
+			get_cpu())->refcount)) > 0)
+			in_use = 1;
+		put_cpu();
+	}
 
-	return sprintf(buf, "%d\n", (chan->client ? 1 : 0));
+	return sprintf(buf, "%d\n", in_use);
 }
 
 static struct class_device_attribute dma_class_attrs[] = {
@@ -129,42 +141,50 @@ static struct class dma_devclass = {
 
 /* --- client and device registration --- */
 
+#define dma_async_chan_satisfies_mask(chan, mask) __dma_async_chan_satisfies_mask((chan), &(mask))
+static int __dma_async_chan_satisfies_mask(struct dma_chan *chan, dma_cap_mask_t *want)
+{
+	dma_cap_mask_t has;
+
+	bitmap_and(has.bits, want->bits, chan->device->cap_mask.bits, DMA_TX_TYPE_END);
+	return bitmap_equal(want->bits, has.bits, DMA_TX_TYPE_END);
+}
+
 /**
- * dma_client_chan_alloc - try to allocate a channel to a client
+ * dma_client_chan_alloc - try to allocate channels to a client
  * @client: &dma_client
  *
  * Called with dma_list_mutex held.
  */
-static struct dma_chan *dma_client_chan_alloc(struct dma_client *client)
+static void dma_client_chan_alloc(struct dma_client *client)
 {
 	struct dma_device *device;
 	struct dma_chan *chan;
-	unsigned long flags;
 	int desc;	/* allocated descriptor count */
+	enum dma_state_client ack;
 
-	/* Find a channel, any DMA engine will do */
-	list_for_each_entry(device, &dma_device_list, global_node) {
+	/* Find a channel */
+	list_for_each_entry(device, &dma_device_list, global_node)
 		list_for_each_entry(chan, &device->channels, device_node) {
-			if (chan->client)
+			if (!dma_async_chan_satisfies_mask(chan, client->cap_mask))
 				continue;
 
 			desc = chan->device->device_alloc_chan_resources(chan);
 			if (desc >= 0) {
-				kref_get(&device->refcount);
-				kref_init(&chan->refcount);
-				chan->slow_ref = 0;
-				INIT_RCU_HEAD(&chan->rcu);
-				chan->client = client;
-				spin_lock_irqsave(&client->lock, flags);
-				list_add_tail_rcu(&chan->client_node,
-				                  &client->channels);
-				spin_unlock_irqrestore(&client->lock, flags);
-				return chan;
+				ack = client->event_callback(client,
+	                                       chan,
+	                                       DMA_RESOURCE_AVAILABLE);
+
+				/* we are done once this client rejects
+				 * an available resource
+				 */
+				if (ack == DMA_ACK) {
+					dma_chan_get(chan);
+					kref_get(&device->refcount);
+				} else if (ack == DMA_NAK)
+					return;
 			}
 		}
-	}
-
-	return NULL;
 }
 
 enum dma_status dma_sync_wait(struct dma_chan *chan, dma_cookie_t cookie)
@@ -193,7 +213,6 @@ void dma_chan_cleanup(struct kref *kref)
 {
 	struct dma_chan *chan = container_of(kref, struct dma_chan, refcount);
 	chan->device->device_free_chan_resources(chan);
-	chan->client = NULL;
 	kref_put(&chan->device->refcount, dma_async_device_cleanup);
 }
 EXPORT_SYMBOL(dma_chan_cleanup);
@@ -209,7 +228,7 @@ static void dma_chan_free_rcu(struct rcu_head *rcu)
 	kref_put(&chan->refcount, dma_chan_cleanup);
 }
 
-static void dma_client_chan_free(struct dma_chan *chan)
+static void dma_chan_release(struct dma_chan *chan)
 {
 	atomic_add(0x7FFFFFFF, &chan->refcount.refcount);
 	chan->slow_ref = 1;
@@ -217,70 +236,57 @@ static void dma_client_chan_free(struct dma_chan *chan)
 }
 
 /**
- * dma_chans_rebalance - reallocate channels to clients
- *
- * When the number of DMA channel in the system changes,
- * channels need to be rebalanced among clients.
+ * dma_chans_notify_available - broadcast available channels to the clients
  */
-static void dma_chans_rebalance(void)
+static void dma_clients_notify_available(void)
 {
 	struct dma_client *client;
-	struct dma_chan *chan;
-	unsigned long flags;
 
 	mutex_lock(&dma_list_mutex);
 
-	list_for_each_entry(client, &dma_client_list, global_node) {
-		while (client->chans_desired > client->chan_count) {
-			chan = dma_client_chan_alloc(client);
-			if (!chan)
-				break;
-			client->chan_count++;
-			client->event_callback(client,
-	                                       chan,
-	                                       DMA_RESOURCE_ADDED);
-		}
-		while (client->chans_desired < client->chan_count) {
-			spin_lock_irqsave(&client->lock, flags);
-			chan = list_entry(client->channels.next,
-			                  struct dma_chan,
-			                  client_node);
-			list_del_rcu(&chan->client_node);
-			spin_unlock_irqrestore(&client->lock, flags);
-			client->chan_count--;
-			client->event_callback(client,
-			                       chan,
-			                       DMA_RESOURCE_REMOVED);
-			dma_client_chan_free(chan);
-		}
-	}
+	list_for_each_entry(client, &dma_client_list, global_node)
+		dma_client_chan_alloc(client);
 
 	mutex_unlock(&dma_list_mutex);
 }
 
 /**
- * dma_async_client_register - allocate and register a &dma_client
- * @event_callback: callback for notification of channel addition/removal
+ * dma_chans_notify_available - tell the clients that a channel is going away
+ * @chan: channel on its way out
  */
-struct dma_client *dma_async_client_register(dma_event_callback event_callback)
+static void dma_clients_notify_removed(struct dma_chan *chan)
 {
 	struct dma_client *client;
+	enum dma_state_client ack;
 
-	client = kzalloc(sizeof(*client), GFP_KERNEL);
-	if (!client)
-		return NULL;
+	mutex_lock(&dma_list_mutex);
+
+	list_for_each_entry(client, &dma_client_list, global_node) {
+		ack = client->event_callback(client, chan,
+                                DMA_RESOURCE_REMOVED);
+
+		/* client was holding resources for this channel so
+		 * free it
+		 */
+		if (ack == DMA_ACK) {
+			dma_chan_put(chan);
+			kref_put(&chan->device->refcount,
+				dma_async_device_cleanup);
+		}
+	}
 
-	INIT_LIST_HEAD(&client->channels);
-	spin_lock_init(&client->lock);
-	client->chans_desired = 0;
-	client->chan_count = 0;
-	client->event_callback = event_callback;
+	mutex_unlock(&dma_list_mutex);
+}
 
+/**
+ * dma_async_client_register - register a &dma_client
+ * @client: ptr to a client structure with valid 'event_callback' and 'cap_mask'
+ */
+void dma_async_client_register(struct dma_client *client)
+{
 	mutex_lock(&dma_list_mutex);
 	list_add_tail(&client->global_node, &dma_client_list);
 	mutex_unlock(&dma_list_mutex);
-
-	return client;
 }
 EXPORT_SYMBOL(dma_async_client_register);
 
@@ -292,40 +298,42 @@ EXPORT_SYMBOL(dma_async_client_register);
  */
 void dma_async_client_unregister(struct dma_client *client)
 {
+	struct dma_device *device;
 	struct dma_chan *chan;
+	enum dma_state_client ack;
 
 	if (!client)
 		return;
 
-	rcu_read_lock();
-	list_for_each_entry_rcu(chan, &client->channels, client_node)
-		dma_client_chan_free(chan);
-	rcu_read_unlock();
-
 	mutex_lock(&dma_list_mutex);
+	/* free all channels the client is holding */
+	list_for_each_entry(device, &dma_device_list, global_node)
+		list_for_each_entry(chan, &device->channels, device_node) {
+			ack = client->event_callback(client, chan,
+	                                DMA_RESOURCE_REMOVED);
+
+			if (ack == DMA_ACK) {
+				dma_chan_put(chan);
+				kref_put(&chan->device->refcount,
+					dma_async_device_cleanup);
+			}
+		}
+
 	list_del(&client->global_node);
 	mutex_unlock(&dma_list_mutex);
-
-	kfree(client);
-	dma_chans_rebalance();
 }
 EXPORT_SYMBOL(dma_async_client_unregister);
 
 /**
- * dma_async_client_chan_request - request DMA channels
- * @client: &dma_client
- * @number: count of DMA channels requested
- *
- * Clients call dma_async_client_chan_request() to specify how many
- * DMA channels they need, 0 to free all currently allocated.
- * The resulting allocations/frees are indicated to the client via the
- * event callback.
+ * dma_async_client_chan_request - send all available channels to the
+ * client that satisfy the capability mask
+ * @client - requester
  */
-void dma_async_client_chan_request(struct dma_client *client,
-			unsigned int number)
+void dma_async_client_chan_request(struct dma_client *client)
 {
-	client->chans_desired = number;
-	dma_chans_rebalance();
+	mutex_lock(&dma_list_mutex);
+	dma_client_chan_alloc(client);
+	mutex_unlock(&dma_list_mutex);
 }
 EXPORT_SYMBOL(dma_async_client_chan_request);
 
@@ -381,6 +389,9 @@ int dma_async_device_register(struct dma_device *device)
 		         device->dev_id, chan->chan_id);
 
 		kref_get(&device->refcount);
+		kref_init(&chan->refcount);
+		chan->slow_ref = 0;
+		INIT_RCU_HEAD(&chan->rcu);
 		class_device_register(&chan->class_dev);
 	}
 
@@ -388,7 +399,7 @@ int dma_async_device_register(struct dma_device *device)
 	list_add_tail(&device->global_node, &dma_device_list);
 	mutex_unlock(&dma_list_mutex);
 
-	dma_chans_rebalance();
+	dma_clients_notify_available();
 
 	return 0;
 }
@@ -413,26 +424,16 @@ static void dma_async_device_cleanup(struct kref *kref)
 void dma_async_device_unregister(struct dma_device *device)
 {
 	struct dma_chan *chan;
-	unsigned long flags;
 
 	mutex_lock(&dma_list_mutex);
 	list_del(&device->global_node);
 	mutex_unlock(&dma_list_mutex);
 
 	list_for_each_entry(chan, &device->channels, device_node) {
-		if (chan->client) {
-			spin_lock_irqsave(&chan->client->lock, flags);
-			list_del(&chan->client_node);
-			chan->client->chan_count--;
-			spin_unlock_irqrestore(&chan->client->lock, flags);
-			chan->client->event_callback(chan->client,
-			                             chan,
-			                             DMA_RESOURCE_REMOVED);
-			dma_client_chan_free(chan);
-		}
+		dma_clients_notify_removed(chan);
 		class_device_unregister(&chan->class_dev);
+		dma_chan_release(chan);
 	}
-	dma_chans_rebalance();
 
 	kref_put(&device->refcount, dma_async_device_cleanup);
 	wait_for_completion(&device->done);
diff --git a/drivers/dma/ioatdma.c b/drivers/dma/ioatdma.c
index 343013d..56f8bb5 100644
--- a/drivers/dma/ioatdma.c
+++ b/drivers/dma/ioatdma.c
@@ -72,7 +72,6 @@ static int enumerate_dma_channels(struct ioat_device *device)
 		INIT_LIST_HEAD(&ioat_chan->used_desc);
 		/* This should be made common somewhere in dmaengine.c */
 		ioat_chan->common.device = &device->common;
-		ioat_chan->common.client = NULL;
 		list_add_tail(&ioat_chan->common.device_node,
 		              &device->common.channels);
 	}
diff --git a/drivers/dma/ioatdma.h b/drivers/dma/ioatdma.h
index fed259a..44d771d 100644
--- a/drivers/dma/ioatdma.h
+++ b/drivers/dma/ioatdma.h
@@ -30,9 +30,6 @@
 
 #define IOAT_LOW_COMPLETION_MASK	0xffffffc0
 
-extern struct list_head dma_device_list;
-extern struct list_head dma_client_list;
-
 /**
  * struct ioat_device - internal representation of a IOAT device
  * @pdev: PCI-Express device
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index c62d63d..f655a6e 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -29,20 +29,32 @@
 #include <linux/dma-mapping.h>
 
 /**
- * enum dma_event - resource PNP/power managment events
+ * enum dma_state - resource PNP/power managment state
  * @DMA_RESOURCE_SUSPEND: DMA device going into low power state
  * @DMA_RESOURCE_RESUME: DMA device returning to full power
- * @DMA_RESOURCE_ADDED: DMA device added to the system
+ * @DMA_RESOURCE_AVAILABLE: DMA device available to the system
  * @DMA_RESOURCE_REMOVED: DMA device removed from the system
  */
-enum dma_event {
+enum dma_state {
 	DMA_RESOURCE_SUSPEND,
 	DMA_RESOURCE_RESUME,
-	DMA_RESOURCE_ADDED,
+	DMA_RESOURCE_AVAILABLE,
 	DMA_RESOURCE_REMOVED,
 };
 
 /**
+ * enum dma_state_client - state of the channel in the client
+ * @DMA_ACK: client would like to use, or was using this channel
+ * @DMA_DUP: client has already seen this channel, or is not using this channel
+ * @DMA_NAK: client does not want to see any more channels
+ */
+enum dma_state_client {
+	DMA_ACK,
+	DMA_DUP,
+	DMA_NAK,
+};
+
+/**
  * typedef dma_cookie_t - an opaque DMA cookie
  *
  * if dma_cookie_t is >0 it's a DMA request cookie, <0 it's an error code
@@ -76,27 +88,12 @@ enum dma_transaction_type {
 	DMA_PQ_ZERO_SUM,
 	DMA_MEMSET,
 	DMA_MEMCPY_CRC32C,
-	DMA_INTERRUPT, /* when updating, make this the last entry and 
-			* update the DMA_TX_ARRAY_INIT macro
-			*/
+	DMA_INTERRUPT, /* when updating, make this the last entry */
 };
 
 /* last transaction type for creation of the capabilities mask */
 #define DMA_TX_TYPE_END (DMA_INTERRUPT + 1)
 
-/* helper macro for clients defining transaction arrays */
-#define DMA_TX_ARRAY_INIT(x)	\
-	[DMA_MEMCPY] = x,	\
-	[DMA_XOR] = x,		\
-	[DMA_PQ_XOR] = x,	\
-	[DMA_DUAL_XOR] = x,	\
-	[DMA_PQ_UPDATE] = x,	\
-	[DMA_ZERO_SUM] = x,	\
-	[DMA_PQ_ZERO_SUM] = x,	\
-	[DMA_MEMSET] = x,	\
-	[DMA_MEMCPY_CRC32C] = x,\
-	[DMA_INTERRUPT] = x,
-
 /**
  * dma_cap_mask_t - capabilities bitmap modeled after cpumask_t.
  * See linux/cpumask.h
@@ -119,7 +116,6 @@ struct dma_chan_percpu {
 
 /**
  * struct dma_chan - devices supply DMA channels, clients use them
- * @client: ptr to the client user of this chan, will be %NULL when unused
  * @device: ptr to the dma device who supplies this channel, always !%NULL
  * @cookie: last cookie value returned to client
  * @chan_id: channel ID for sysfs
@@ -127,12 +123,10 @@ struct dma_chan_percpu {
  * @refcount: kref, used in "bigref" slow-mode
  * @slow_ref: indicates that the DMA channel is free
  * @rcu: the DMA channel's RCU head
- * @client_node: used to add this to the client chan list
  * @device_node: used to add this to the device chan list
  * @local: per-cpu pointer to a struct dma_chan_percpu
  */
 struct dma_chan {
-	struct dma_client *client;
 	struct dma_device *device;
 	dma_cookie_t cookie;
 
@@ -144,11 +138,11 @@ struct dma_chan {
 	int slow_ref;
 	struct rcu_head rcu;
 
-	struct list_head client_node;
 	struct list_head device_node;
 	struct dma_chan_percpu *local;
 };
 
+
 void dma_chan_cleanup(struct kref *kref);
 
 static inline void dma_chan_get(struct dma_chan *chan)
@@ -173,26 +167,31 @@ static inline void dma_chan_put(struct dma_chan *chan)
 
 /*
  * typedef dma_event_callback - function pointer to a DMA event callback
+ * For each channel added to the system this routine is called for each client.
+ * If the client would like to use the channel it returns '1' to signal (ack)
+ * the dmaengine core to take out a reference on the channel and its
+ * corresponding device.  A client must not 'ack' an available channel more
+ * than once.  When a channel is removed all clients are notified.  If a client
+ * is using the channel it must 'ack' the removal.  A client must not 'ack' a
+ * removed channel more than once.
+ * @client - 'this' pointer for the client context
+ * @chan - channel to be acted upon
+ * @state - available or removed
  */
-typedef void (*dma_event_callback) (struct dma_client *client,
-		struct dma_chan *chan, enum dma_event event);
+struct dma_client;
+typedef enum dma_state_client (*dma_event_callback) (struct dma_client *client,
+		struct dma_chan *chan, enum dma_state state);
 
 /**
  * struct dma_client - info on the entity making use of DMA services
  * @event_callback: func ptr to call when something happens
- * @chan_count: number of chans allocated
- * @chans_desired: number of chans requested. Can be +/- chan_count
- * @lock: protects access to the channels list
- * @channels: the list of DMA channels allocated
+ * @cap_mask: only return channels that satisfy the requested capabilities
+ *  a value of zero corresponds to any capability
  * @global_node: list_head for global dma_client_list
  */
 struct dma_client {
 	dma_event_callback	event_callback;
-	unsigned int		chan_count;
-	unsigned int		chans_desired;
-
-	spinlock_t		lock;
-	struct list_head	channels;
+	dma_cap_mask_t		cap_mask;
 	struct list_head	global_node;
 };
 
@@ -295,10 +294,9 @@ struct dma_device {
 
 /* --- public DMA engine API --- */
 
-struct dma_client *dma_async_client_register(dma_event_callback event_callback);
+void dma_async_client_register(struct dma_client *client);
 void dma_async_client_unregister(struct dma_client *client);
-void dma_async_client_chan_request(struct dma_client *client,
-		unsigned int number);
+void dma_async_client_chan_request(struct dma_client *client);
 dma_cookie_t dma_async_memcpy_buf_to_buf(struct dma_chan *chan,
         void *dest, void *src, size_t len);
 dma_cookie_t dma_async_memcpy_buf_to_pg(struct dma_chan *chan,
@@ -309,7 +307,6 @@ dma_cookie_t dma_async_memcpy_pg_to_pg(struct dma_chan *chan,
 void dma_async_tx_descriptor_init(struct dma_async_tx_descriptor *tx,
 	struct dma_chan *chan);
 
-
 static inline void
 async_tx_ack(struct dma_async_tx_descriptor *tx)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 5a7f20f..41bcbce 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -151,9 +151,22 @@ static struct list_head ptype_base[16] __read_mostly;	/* 16 way hashed list */
 static struct list_head ptype_all __read_mostly;	/* Taps */
 
 #ifdef CONFIG_NET_DMA
-static struct dma_client *net_dma_client;
-static unsigned int net_dma_count;
-static spinlock_t net_dma_event_lock;
+struct net_dma {
+	struct dma_client client;
+	spinlock_t lock;
+	cpumask_t channel_mask;
+	struct dma_chan *channels[NR_CPUS];
+};
+
+static enum dma_state_client
+netdev_dma_event(struct dma_client *client, struct dma_chan *chan,
+	enum dma_state state);
+
+static struct net_dma net_dma = {
+	.client = {
+		.event_callback = netdev_dma_event,
+	},
+};
 #endif
 
 /*
@@ -2014,12 +2027,13 @@ out:
 	 * There may not be any more sk_buffs coming right now, so push
 	 * any pending DMA copies to hardware
 	 */
-	if (net_dma_client) {
-		struct dma_chan *chan;
-		rcu_read_lock();
-		list_for_each_entry_rcu(chan, &net_dma_client->channels, client_node)
-			dma_async_memcpy_issue_pending(chan);
-		rcu_read_unlock();
+	if (!cpus_empty(net_dma.channel_mask)) {
+		int chan_idx;
+		for_each_cpu_mask(chan_idx, net_dma.channel_mask) {
+			struct dma_chan *chan = net_dma.channels[chan_idx];
+			if (chan)
+				dma_async_memcpy_issue_pending(chan);
+		}
 	}
 #endif
 	local_irq_enable();
@@ -3561,12 +3575,13 @@ static int dev_cpu_callback(struct notifier_block *nfb,
  * This is called when the number of channels allocated to the net_dma_client
  * changes.  The net_dma_client tries to have one DMA channel per CPU.
  */
-static void net_dma_rebalance(void)
+
+static void net_dma_rebalance(struct net_dma *net_dma)
 {
-	unsigned int cpu, i, n;
+	unsigned int cpu, i, n, chan_idx;
 	struct dma_chan *chan;
 
-	if (net_dma_count == 0) {
+	if (cpus_empty(net_dma->channel_mask)) {
 		for_each_online_cpu(cpu)
 			rcu_assign_pointer(per_cpu(softnet_data, cpu).net_dma, NULL);
 		return;
@@ -3574,11 +3589,12 @@ static void net_dma_rebalance(void)
 
 	i = 0;
 	cpu = first_cpu(cpu_online_map);
+	
+	for_each_cpu_mask(chan_idx, net_dma->channel_mask) {
+		chan = net_dma->channels[chan_idx];
 
-	rcu_read_lock();
-	list_for_each_entry(chan, &net_dma_client->channels, client_node) {
-		n = ((num_online_cpus() / net_dma_count)
-		   + (i < (num_online_cpus() % net_dma_count) ? 1 : 0));
+		n = ((num_online_cpus() / cpus_weight(net_dma->channel_mask))
+		   + (i < (num_online_cpus() % cpus_weight(net_dma->channel_mask)) ? 1 : 0));
 
 		while(n) {
 			per_cpu(softnet_data, cpu).net_dma = chan;
@@ -3587,7 +3603,6 @@ static void net_dma_rebalance(void)
 		}
 		i++;
 	}
-	rcu_read_unlock();
 }
 
 /**
@@ -3596,23 +3611,53 @@ static void net_dma_rebalance(void)
  * @chan: DMA channel for the event
  * @event: event type
  */
-static void netdev_dma_event(struct dma_client *client, struct dma_chan *chan,
-	enum dma_event event)
-{
-	spin_lock(&net_dma_event_lock);
-	switch (event) {
-	case DMA_RESOURCE_ADDED:
-		net_dma_count++;
-		net_dma_rebalance();
+static enum dma_state_client
+netdev_dma_event(struct dma_client *client, struct dma_chan *chan,
+	enum dma_state state)
+{
+	int i, found = 0, pos = -1;
+	struct net_dma *net_dma =
+		container_of(client, struct net_dma, client);
+	enum dma_state_client ack = DMA_DUP; /* default: take no action */
+
+	spin_lock(&net_dma->lock);
+	switch (state) {
+	case DMA_RESOURCE_AVAILABLE:
+		for (i = 0; i < NR_CPUS; i++)
+			if (net_dma->channels[i] == chan) {
+				found = 1;
+				break;
+			} else if (net_dma->channels[i] == NULL && pos < 0)
+				pos = i;
+
+		if (!found && pos >= 0) {
+			ack = DMA_ACK;
+			net_dma->channels[pos] = chan;
+			cpu_set(pos, net_dma->channel_mask);
+			net_dma_rebalance(net_dma);
+		}
 		break;
 	case DMA_RESOURCE_REMOVED:
-		net_dma_count--;
-		net_dma_rebalance();
+		for (i = 0; i < NR_CPUS; i++)
+			if (net_dma->channels[i] == chan) {
+				found = 1;
+				pos = i;
+				break;
+			}
+
+		if (found) {
+			ack = DMA_ACK;
+			cpu_clear(pos, net_dma->channel_mask);
+			net_dma->channels[i] = NULL;
+			net_dma_rebalance(net_dma);
+		}
 		break;
 	default:
 		break;
 	}
-	spin_unlock(&net_dma_event_lock);
+	spin_unlock(&net_dma->lock);
+
+	return ack;
 }
 
 /**
@@ -3620,12 +3665,10 @@ static void netdev_dma_event(struct dma_client *client, struct dma_chan *chan,
  */
 static int __init netdev_dma_register(void)
 {
-	spin_lock_init(&net_dma_event_lock);
-	net_dma_client = dma_async_client_register(netdev_dma_event);
-	if (net_dma_client == NULL)
-		return -ENOMEM;
-
-	dma_async_client_chan_request(net_dma_client, num_online_cpus());
+	spin_lock_init(&net_dma.lock);
+	dma_cap_set(DMA_MEMCPY, net_dma.client.cap_mask);
+	dma_async_client_register(&net_dma.client);
+	dma_async_client_chan_request(&net_dma.client);
 	return 0;
 }
 
