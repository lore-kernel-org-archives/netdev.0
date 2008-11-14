From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 03/13] dmaengine: up-level reference counting to the module
	level
Date: Fri, 14 Nov 2008 14:34:32 -0700
Message-ID: <20081114213432.32354.2427.stgit@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53355 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753535AbYKNVeg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 16:34:36 -0500
In-Reply-To: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simply, if a client wants any dmaengine channel then prevent all dmaengine
modules from being removed.  Once the clients are done re-enable module
removal.

Why?, beyond reducing complication:
1/ Tracking reference counts per-transaction in an efficient manner, as
   is currently done, requires a complicated scheme to avoid cache-line
   bouncing effects.
2/ Per-transaction ref-counting gives the false impression that a
   dma-driver can be gracefully removed ahead of its user (net, md, or
   dma-slave)
3/ None of the in-tree dma-drivers talk to hot pluggable hardware, but
   if such an engine were built one day we still would not need to notify
   clients of remove events.  The driver can simply return NULL to a
   ->prep() request, something that is much easier for a client to handle.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 crypto/async_tx/async_tx.c   |    4 -
 drivers/dma/dmaengine.c      |  190 +++++++++++++++++++++++++-----------------
 drivers/dma/dmatest.c        |    2 
 drivers/dma/dw_dmac.c        |    2 
 drivers/mmc/host/atmel-mci.c |    4 -
 include/linux/dmaengine.h    |   21 -----
 include/net/netdma.h         |    4 -
 net/ipv4/tcp.c               |    1 
 8 files changed, 118 insertions(+), 110 deletions(-)

diff --git a/crypto/async_tx/async_tx.c b/crypto/async_tx/async_tx.c
index 8cfac18..43fe4cb 100644
--- a/crypto/async_tx/async_tx.c
+++ b/crypto/async_tx/async_tx.c
@@ -198,8 +198,6 @@ dma_channel_add_remove(struct dma_client *client,
 		/* add the channel to the generic management list */
 		master_ref = kmalloc(sizeof(*master_ref), GFP_KERNEL);
 		if (master_ref) {
-			/* keep a reference until async_tx is unloaded */
-			dma_chan_get(chan);
 			init_dma_chan_ref(master_ref, chan);
 			spin_lock_irqsave(&async_tx_lock, flags);
 			list_add_tail_rcu(&master_ref->node,
@@ -221,8 +219,6 @@ dma_channel_add_remove(struct dma_client *client,
 		spin_lock_irqsave(&async_tx_lock, flags);
 		list_for_each_entry(ref, &async_tx_master_list, node)
 			if (ref->chan == chan) {
-				/* permit backing devices to go away */
-				dma_chan_put(ref->chan);
 				list_del_rcu(&ref->node);
 				call_rcu(&ref->rcu, free_dma_chan_ref);
 				found = 1;
diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index 5410c04..df37073 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -74,6 +74,7 @@
 static DEFINE_MUTEX(dma_list_mutex);
 static LIST_HEAD(dma_device_list);
 static LIST_HEAD(dma_client_list);
+static long dmaengine_ref_count;
 
 /* --- sysfs implementation --- */
 
@@ -105,19 +106,8 @@ static ssize_t show_bytes_transferred(struct device *dev, struct device_attribut
 static ssize_t show_in_use(struct device *dev, struct device_attribute *attr, char *buf)
 {
 	struct dma_chan *chan = to_dma_chan(dev);
-	int in_use = 0;
-
-	if (unlikely(chan->slow_ref) &&
-		atomic_read(&chan->refcount.refcount) > 1)
-		in_use = 1;
-	else {
-		if (local_read(&(per_cpu_ptr(chan->local,
-			get_cpu())->refcount)) > 0)
-			in_use = 1;
-		put_cpu();
-	}
 
-	return sprintf(buf, "%d\n", in_use);
+	return sprintf(buf, "%d\n", chan->client_count);
 }
 
 static struct device_attribute dma_attrs[] = {
@@ -155,6 +145,67 @@ __dma_chan_satisfies_mask(struct dma_chan *chan, dma_cap_mask_t *want)
 	return bitmap_equal(want->bits, has.bits, DMA_TX_TYPE_END);
 }
 
+static struct module *dma_chan_to_owner(struct dma_chan *chan)
+{
+	return chan->device->dev->driver->owner;
+}
+
+/**
+ * balance_ref_count - catch up the channel reference count
+ */
+static void balance_ref_count(struct dma_chan *chan)
+{
+	struct module *owner = dma_chan_to_owner(chan);
+
+	while (chan->client_count < dmaengine_ref_count) {
+		__module_get(owner);
+		chan->client_count++;
+	}
+}
+
+/**
+ * dma_chan_get - try to grab a dma channel's parent driver module
+ * @chan - channel to grab
+ */
+static int dma_chan_get(struct dma_chan *chan)
+{
+	int err = -ENODEV;
+	struct module *owner = dma_chan_to_owner(chan);
+
+	if (chan->client_count) {
+		__module_get(owner);
+		err = 0;
+	} else if (try_module_get(owner))
+		err = 0;
+
+	if (err == 0)
+		chan->client_count++;
+
+	/* allocate upon first client reference */
+	if (chan->client_count == 1 && err == 0) {
+		int desc = chan->device->device_alloc_chan_resources(chan, NULL);
+
+		if (desc < 0) {
+			chan->client_count = 0;
+			module_put(owner);
+			err = -ENOMEM;
+		} else
+			balance_ref_count(chan);
+	}
+
+	return err;
+}
+
+static void dma_chan_put(struct dma_chan *chan)
+{
+	if (!chan->client_count)
+		return; /* this channel failed alloc_chan_resources */
+	chan->client_count--;
+	module_put(dma_chan_to_owner(chan));
+	if (chan->client_count == 0)
+		chan->device->device_free_chan_resources(chan);
+}
+
 /**
  * dma_client_chan_alloc - try to allocate channels to a client
  * @client: &dma_client
@@ -165,7 +216,6 @@ static void dma_client_chan_alloc(struct dma_client *client)
 {
 	struct dma_device *device;
 	struct dma_chan *chan;
-	int desc;	/* allocated descriptor count */
 	enum dma_state_client ack;
 
 	/* Find a channel */
@@ -178,23 +228,16 @@ static void dma_client_chan_alloc(struct dma_client *client)
 		list_for_each_entry(chan, &device->channels, device_node) {
 			if (!dma_chan_satisfies_mask(chan, client->cap_mask))
 				continue;
+			if (!chan->client_count)
+				continue;
+			ack = client->event_callback(client, chan,
+						     DMA_RESOURCE_AVAILABLE);
 
-			desc = chan->device->device_alloc_chan_resources(
-					chan, client);
-			if (desc >= 0) {
-				ack = client->event_callback(client,
-						chan,
-						DMA_RESOURCE_AVAILABLE);
-
-				/* we are done once this client rejects
-				 * an available resource
-				 */
-				if (ack == DMA_ACK) {
-					dma_chan_get(chan);
-					chan->client_count++;
-				} else if (ack == DMA_NAK)
-					return;
-			}
+			/* we are done once this client rejects
+			 * an available resource
+			 */
+			if (ack == DMA_NAK)
+				return;
 		}
 	}
 }
@@ -224,7 +267,6 @@ EXPORT_SYMBOL(dma_sync_wait);
 void dma_chan_cleanup(struct kref *kref)
 {
 	struct dma_chan *chan = container_of(kref, struct dma_chan, refcount);
-	chan->device->device_free_chan_resources(chan);
 	kref_put(&chan->device->refcount, dma_async_device_cleanup);
 }
 EXPORT_SYMBOL(dma_chan_cleanup);
@@ -232,18 +274,12 @@ EXPORT_SYMBOL(dma_chan_cleanup);
 static void dma_chan_free_rcu(struct rcu_head *rcu)
 {
 	struct dma_chan *chan = container_of(rcu, struct dma_chan, rcu);
-	int bias = 0x7FFFFFFF;
-	int i;
-	for_each_possible_cpu(i)
-		bias -= local_read(&per_cpu_ptr(chan->local, i)->refcount);
-	atomic_sub(bias, &chan->refcount.refcount);
+
 	kref_put(&chan->refcount, dma_chan_cleanup);
 }
 
 static void dma_chan_release(struct dma_chan *chan)
 {
-	atomic_add(0x7FFFFFFF, &chan->refcount.refcount);
-	chan->slow_ref = 1;
 	call_rcu(&chan->rcu, dma_chan_free_rcu);
 }
 
@@ -263,43 +299,36 @@ static void dma_clients_notify_available(void)
 }
 
 /**
- * dma_chans_notify_available - tell the clients that a channel is going away
- * @chan: channel on its way out
- */
-static void dma_clients_notify_removed(struct dma_chan *chan)
-{
-	struct dma_client *client;
-	enum dma_state_client ack;
-
-	mutex_lock(&dma_list_mutex);
-
-	list_for_each_entry(client, &dma_client_list, global_node) {
-		ack = client->event_callback(client, chan,
-				DMA_RESOURCE_REMOVED);
-
-		/* client was holding resources for this channel so
-		 * free it
-		 */
-		if (ack == DMA_ACK) {
-			dma_chan_put(chan);
-			chan->client_count--;
-		}
-	}
-
-	mutex_unlock(&dma_list_mutex);
-}
-
-/**
  * dma_async_client_register - register a &dma_client
  * @client: ptr to a client structure with valid 'event_callback' and 'cap_mask'
  */
 void dma_async_client_register(struct dma_client *client)
 {
+	struct dma_device *device, *_d;
+	struct dma_chan *chan;
+	int err;
+
 	/* validate client data */
 	BUG_ON(dma_has_cap(DMA_SLAVE, client->cap_mask) &&
 		!client->slave);
 
 	mutex_lock(&dma_list_mutex);
+	dmaengine_ref_count++;
+
+	/* try to grab channels */
+	list_for_each_entry_safe(device, _d, &dma_device_list, global_node)
+		list_for_each_entry(chan, &device->channels, device_node) {
+			err = dma_chan_get(chan);
+			if (err == -ENODEV) {
+				/* module removed before we could use it */
+				list_del_init(&device->global_node);
+				break;
+			} else if (err)
+				pr_err("dmaengine: failed to get %s: (%d)",
+				       dev_name(&chan->dev), err);
+		}
+
+
 	list_add_tail(&client->global_node, &dma_client_list);
 	mutex_unlock(&dma_list_mutex);
 }
@@ -315,23 +344,17 @@ void dma_async_client_unregister(struct dma_client *client)
 {
 	struct dma_device *device;
 	struct dma_chan *chan;
-	enum dma_state_client ack;
 
 	if (!client)
 		return;
 
 	mutex_lock(&dma_list_mutex);
-	/* free all channels the client is holding */
+	dmaengine_ref_count--;
+	BUG_ON(dmaengine_ref_count < 0);
+	/* drop channel references */
 	list_for_each_entry(device, &dma_device_list, global_node)
-		list_for_each_entry(chan, &device->channels, device_node) {
-			ack = client->event_callback(client, chan,
-				DMA_RESOURCE_REMOVED);
-
-			if (ack == DMA_ACK) {
-				dma_chan_put(chan);
-				chan->client_count--;
-			}
-		}
+		list_for_each_entry(chan, &device->channels, device_node)
+			dma_chan_put(chan);
 
 	list_del(&client->global_node);
 	mutex_unlock(&dma_list_mutex);
@@ -420,6 +443,19 @@ int dma_async_device_register(struct dma_device *device)
 	}
 
 	mutex_lock(&dma_list_mutex);
+	list_for_each_entry(chan, &device->channels, device_node) {
+		/* if clients are already waiting for channels we need to
+		 * take references on their behalf
+		 */
+		if (dmaengine_ref_count && dma_chan_get(chan) == -ENODEV) {
+			/* note we can only get here for the first
+			 * channel as the remaining channels are
+			 * guaranteed to get a reference
+			 */
+			rc = -ENODEV;
+			goto err_out;
+		}
+	}
 	list_add_tail(&device->global_node, &dma_device_list);
 	mutex_unlock(&dma_list_mutex);
 
@@ -465,7 +501,9 @@ void dma_async_device_unregister(struct dma_device *device)
 	mutex_unlock(&dma_list_mutex);
 
 	list_for_each_entry(chan, &device->channels, device_node) {
-		dma_clients_notify_removed(chan);
+		WARN_ONCE(chan->client_count,
+			  "%s called while %d clients hold a reference\n",
+			  __func__, chan->client_count);
 		device_unregister(&chan->dev);
 		dma_chan_release(chan);
 	}
diff --git a/drivers/dma/dmatest.c b/drivers/dma/dmatest.c
index ed9636b..db40508 100644
--- a/drivers/dma/dmatest.c
+++ b/drivers/dma/dmatest.c
@@ -215,7 +215,6 @@ static int dmatest_func(void *data)
 
 	smp_rmb();
 	chan = thread->chan;
-	dma_chan_get(chan);
 
 	while (!kthread_should_stop()) {
 		total_tests++;
@@ -293,7 +292,6 @@ static int dmatest_func(void *data)
 	}
 
 	ret = 0;
-	dma_chan_put(chan);
 	kfree(thread->dstbuf);
 err_dstbuf:
 	kfree(thread->srcbuf);
diff --git a/drivers/dma/dw_dmac.c b/drivers/dma/dw_dmac.c
index 0778d99..377dafa 100644
--- a/drivers/dma/dw_dmac.c
+++ b/drivers/dma/dw_dmac.c
@@ -773,7 +773,7 @@ static int dwc_alloc_chan_resources(struct dma_chan *chan,
 	dev_vdbg(&chan->dev, "alloc_chan_resources\n");
 
 	/* Channels doing slave DMA can only handle one client. */
-	if (dwc->dws || client->slave) {
+	if (dwc->dws || (client && client->slave)) {
 		if (chan->client_count)
 			return -EBUSY;
 	}
diff --git a/drivers/mmc/host/atmel-mci.c b/drivers/mmc/host/atmel-mci.c
index 7a3f243..6c11f4d 100644
--- a/drivers/mmc/host/atmel-mci.c
+++ b/drivers/mmc/host/atmel-mci.c
@@ -593,10 +593,8 @@ atmci_submit_data_dma(struct atmel_mci *host, struct mmc_data *data)
 
 	/* If we don't have a channel, we can't do DMA */
 	chan = host->dma.chan;
-	if (chan) {
-		dma_chan_get(chan);
+	if (chan)
 		host->data_chan = chan;
-	}
 
 	if (!chan)
 		return -ENODEV;
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index e4ec7e7..d18d37d 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -165,7 +165,6 @@ struct dma_slave {
  */
 
 struct dma_chan_percpu {
-	local_t refcount;
 	/* stats */
 	unsigned long memcpy_count;
 	unsigned long bytes_transferred;
@@ -205,26 +204,6 @@ struct dma_chan {
 
 void dma_chan_cleanup(struct kref *kref);
 
-static inline void dma_chan_get(struct dma_chan *chan)
-{
-	if (unlikely(chan->slow_ref))
-		kref_get(&chan->refcount);
-	else {
-		local_inc(&(per_cpu_ptr(chan->local, get_cpu())->refcount));
-		put_cpu();
-	}
-}
-
-static inline void dma_chan_put(struct dma_chan *chan)
-{
-	if (unlikely(chan->slow_ref))
-		kref_put(&chan->refcount, dma_chan_cleanup);
-	else {
-		local_dec(&(per_cpu_ptr(chan->local, get_cpu())->refcount));
-		put_cpu();
-	}
-}
-
 /*
  * typedef dma_event_callback - function pointer to a DMA event callback
  * For each channel added to the system this routine is called for each client.
diff --git a/include/net/netdma.h b/include/net/netdma.h
index f28c6e0..cbe2737 100644
--- a/include/net/netdma.h
+++ b/include/net/netdma.h
@@ -27,11 +27,11 @@
 static inline struct dma_chan *get_softnet_dma(void)
 {
 	struct dma_chan *chan;
+
 	rcu_read_lock();
 	chan = rcu_dereference(__get_cpu_var(softnet_data).net_dma);
-	if (chan)
-		dma_chan_get(chan);
 	rcu_read_unlock();
+
 	return chan;
 }
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c5aca0b..40ec69f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1630,7 +1630,6 @@ skip_copy:
 
 		/* Safe to free early-copied skbs now */
 		__skb_queue_purge(&sk->sk_async_wait_queue);
-		dma_chan_put(tp->ucopy.dma_chan);
 		tp->ucopy.dma_chan = NULL;
 	}
 	if (tp->ucopy.pinned_list) {

