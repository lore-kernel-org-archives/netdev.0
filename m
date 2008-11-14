From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 07/13] dmaengine: introduce dma_request_channel and private
	channels
Date: Fri, 14 Nov 2008 14:34:53 -0700
Message-ID: <20081114213453.32354.53002.stgit@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45718 "EHLO mga02.intel.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753452AbYKNVey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 16:34:54 -0500
In-Reply-To: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This interface is primarily for device-to-memory clients which need to
search for dma channels with platform-specific characteristics.  The
prototype is:

struct dma_chan *dma_request_channel(dma_cap_mask_t mask,
                                     dma_filter_fn filter_fn,
                                     void *filter_param);

When the optional 'filter_fn' parameter is set to NULL
dma_request_channel simply returns the first channel that satisfies the
capability mask.  Otherwise, when the mask parameter is insufficient for
specifying the necessary channel, the filter_fn routine can be used to
disposition the available channels in the system. The filter_fn routine
is called once for each free channel in the system.  Upon seeing a
suitable channel filter_fn returns DMA_ACK which flags that channel to
be the return value from dma_request_channel.  A channel allocated via
this interface is exclusive to the caller, until dma_release_channel()
is called.

To ensure that all channels are not consumed by the general-purpose
allocator the DMA_PRIVATE capability is provided to exclude a dma_device
from general-purpose (memory-to-memory) consideration.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 drivers/dma/dmaengine.c   |  161 ++++++++++++++++++++++++++++++++++++++++-----
 include/linux/dmaengine.h |   16 ++++
 2 files changed, 159 insertions(+), 18 deletions(-)

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index ec483cc..46fd5fa 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -190,7 +190,7 @@ static int dma_chan_get(struct dma_chan *chan)
 			chan->client_count = 0;
 			module_put(owner);
 			err = -ENOMEM;
-		} else
+		} else if (!dma_has_cap(DMA_PRIVATE, chan->device->cap_mask))
 			balance_ref_count(chan);
 	}
 
@@ -221,6 +221,8 @@ static void dma_client_chan_alloc(struct dma_client *client)
 
 	/* Find a channel */
 	list_for_each_entry(device, &dma_device_list, global_node) {
+		if (dma_has_cap(DMA_PRIVATE, device->cap_mask))
+			continue;
 		/* Does the client require a specific DMA controller? */
 		if (client->slave && client->slave->dma_dev
 				&& client->slave->dma_dev != device->dev)
@@ -313,6 +315,7 @@ static int __init dma_channel_table_init(void)
 	 * channel_table
 	 */
 	clear_bit(DMA_INTERRUPT, dma_cap_mask_all.bits);
+	clear_bit(DMA_PRIVATE, dma_cap_mask_all.bits);
 	clear_bit(DMA_SLAVE, dma_cap_mask_all.bits);
 
 	for_each_dma_cap_mask(cap, dma_cap_mask_all) {
@@ -366,10 +369,13 @@ void dma_issue_pending_all(void)
 		  "client called %s without a reference", __func__);
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(device, &dma_device_list, global_node)
+	list_for_each_entry_rcu(device, &dma_device_list, global_node) {
+		if (dma_has_cap(DMA_PRIVATE, device->cap_mask))
+			continue;
 		list_for_each_entry(chan, &device->channels, device_node)
 			if (chan->client_count)
 				device->device_issue_pending(chan);
+	}
 	rcu_read_unlock();
 }
 EXPORT_SYMBOL(dma_issue_pending_all);
@@ -390,7 +396,8 @@ static struct dma_chan *nth_chan(enum dma_transaction_type cap, int n)
 	struct dma_chan *min = NULL;
 
 	list_for_each_entry(device, &dma_device_list, global_node) {
-		if (!dma_has_cap(cap, device->cap_mask))
+		if (!dma_has_cap(cap, device->cap_mask) ||
+		    dma_has_cap(DMA_PRIVATE, device->cap_mask))
 			continue;
 		list_for_each_entry(chan, &device->channels, device_node) {
 			if (!chan->client_count)
@@ -439,9 +446,12 @@ static void dma_channel_rebalance(void)
 		for_each_possible_cpu(cpu)
 			per_cpu_ptr(channel_table[cap], cpu)->chan = NULL;
 
-	list_for_each_entry(device, &dma_device_list, global_node)
+	list_for_each_entry(device, &dma_device_list, global_node) {
+		if (dma_has_cap(DMA_PRIVATE, device->cap_mask))
+			continue;
 		list_for_each_entry(chan, &device->channels, device_node)
 			chan->table_count = 0;
+	}
 
 	/* don't populate the channel_table if no clients are available */
 	if (!dmaengine_ref_count)
@@ -460,6 +470,112 @@ static void dma_channel_rebalance(void)
 		}
 }
 
+static struct dma_chan *private_candidate(dma_cap_mask_t *mask, struct dma_device *dev)
+{
+	struct dma_chan *chan;
+	struct dma_chan *ret = NULL;
+
+	/* devices with multiple channels need special handling as we need to
+	 * ensure that all channels are either private or public.
+	 */
+	if (dev->chancnt > 1 && !dma_has_cap(DMA_PRIVATE, dev->cap_mask))
+		list_for_each_entry(chan, &dev->channels, device_node) {
+			/* some channels are already publicly allocated */
+			if (chan->client_count)
+				return NULL;
+		}
+
+	list_for_each_entry(chan, &dev->channels, device_node) {
+		if (!__dma_chan_satisfies_mask(chan, mask)) {
+			pr_debug("%s: %s wrong capabilities\n",
+				 __func__, dev_name(&chan->dev));
+			continue;
+		}
+		if (chan->client_count) {
+			pr_debug("%s: %s busy\n",
+				 __func__, dev_name(&chan->dev));
+			continue;
+		}
+		ret = chan;
+		break;
+	}
+
+	return ret;
+}
+
+/**
+ * dma_request_channel - try to allocate an exclusive channel
+ * @mask: capabilities that the channel must satisfy
+ * @fn: optional callback to disposition available channels
+ * @fn_param: opaque parameter to pass to dma_filter_fn
+ */
+struct dma_chan *__dma_request_channel(dma_cap_mask_t *mask, dma_filter_fn fn, void *fn_param)
+{
+	struct dma_device *device, *_d;
+	struct dma_chan *chan = NULL;
+	enum dma_state_client ack;
+	int err;
+
+	/* Find a channel */
+	mutex_lock(&dma_list_mutex);
+	list_for_each_entry_safe(device, _d, &dma_device_list, global_node) {
+		chan = private_candidate(mask, device);
+		if (!chan)
+			continue;
+
+		if (fn)
+			ack = fn(chan, fn_param);
+		else
+			ack = DMA_ACK;
+
+		if (ack == DMA_ACK) {
+			/* Found a suitable channel, try to grab, prep, and
+			 * return it.  We first set DMA_PRIVATE to disable
+			 * balance_ref_count as this channel will not be
+			 * published in the general-purpose allocator
+			 */
+			dma_cap_set(DMA_PRIVATE, device->cap_mask);
+			err = dma_chan_get(chan);
+
+			if (err == -ENODEV) {
+				pr_debug("%s: %s module removed\n", __func__,
+					 dev_name(&chan->dev));
+				list_del_rcu(&device->global_node);
+			} else if (err)
+				pr_err("dmaengine: failed to get %s: (%d)",
+				       dev_name(&chan->dev), err);
+			else
+				break;
+		} else if (ack == DMA_DUP) {
+			pr_debug("%s: %s filter said DMA_DUP\n",
+				 __func__, dev_name(&chan->dev));
+		} else if (ack == DMA_NAK) {
+			pr_debug("%s: %s filter said DMA_NAK\n",
+				 __func__, dev_name(&chan->dev));
+			break;
+		} else
+			WARN_ONCE(1, "filter_fn: unknown response?\n");
+		chan = NULL;
+	}
+	mutex_unlock(&dma_list_mutex);
+
+	pr_debug("%s: %s (%s)\n", __func__, chan ? "success" : "fail",
+		 chan ? dev_name(&chan->dev) : NULL);
+
+	return chan;
+}
+EXPORT_SYMBOL_GPL(__dma_request_channel);
+
+void dma_release_channel(struct dma_chan *chan)
+{
+	mutex_lock(&dma_list_mutex);
+	WARN_ONCE(chan->client_count != 1,
+		  "chan reference count %d != 1\n", chan->client_count);
+	dma_chan_put(chan);
+	mutex_unlock(&dma_list_mutex);
+}
+EXPORT_SYMBOL_GPL(dma_release_channel);
+
 /**
  * dma_chans_notify_available - broadcast available channels to the clients
  */
@@ -493,7 +609,9 @@ void dma_async_client_register(struct dma_client *client)
 	dmaengine_ref_count++;
 
 	/* try to grab channels */
-	list_for_each_entry_safe(device, _d, &dma_device_list, global_node)
+	list_for_each_entry_safe(device, _d, &dma_device_list, global_node) {
+		if (dma_has_cap(DMA_PRIVATE, device->cap_mask))
+			continue;
 		list_for_each_entry(chan, &device->channels, device_node) {
 			err = dma_chan_get(chan);
 			if (err == -ENODEV) {
@@ -504,7 +622,7 @@ void dma_async_client_register(struct dma_client *client)
 				pr_err("dmaengine: failed to get %s: (%d)",
 				       dev_name(&chan->dev), err);
 		}
-
+	}
 
 	list_add_tail(&client->global_node, &dma_client_list);
 	mutex_unlock(&dma_list_mutex);
@@ -529,9 +647,12 @@ void dma_async_client_unregister(struct dma_client *client)
 	dmaengine_ref_count--;
 	BUG_ON(dmaengine_ref_count < 0);
 	/* drop channel references */
-	list_for_each_entry(device, &dma_device_list, global_node)
+	list_for_each_entry(device, &dma_device_list, global_node) {
+		if (dma_has_cap(DMA_PRIVATE, device->cap_mask))
+			continue;
 		list_for_each_entry(chan, &device->channels, device_node)
 			dma_chan_put(chan);
+	}
 
 	list_del(&client->global_node);
 	mutex_unlock(&dma_list_mutex);
@@ -618,21 +739,25 @@ int dma_async_device_register(struct dma_device *device)
 		chan->slow_ref = 0;
 		INIT_RCU_HEAD(&chan->rcu);
 	}
+	device->chancnt = chancnt;
 
 	mutex_lock(&dma_list_mutex);
-	list_for_each_entry(chan, &device->channels, device_node) {
-		/* if clients are already waiting for channels we need to
-		 * take references on their behalf
-		 */
-		if (dmaengine_ref_count && dma_chan_get(chan) == -ENODEV) {
-			/* note we can only get here for the first
-			 * channel as the remaining channels are
-			 * guaranteed to get a reference
+	/* take references on public channels */
+	if (!dma_has_cap(DMA_PRIVATE, device->cap_mask))
+		list_for_each_entry(chan, &device->channels, device_node) {
+			/* if clients are already waiting for channels we need
+			 * to take references on their behalf
 			 */
-			rc = -ENODEV;
-			goto err_out;
+			if (dmaengine_ref_count &&
+			    dma_chan_get(chan) == -ENODEV) {
+				/* note we can only get here for the first
+				 * channel as the remaining channels are
+				 * guaranteed to get a reference
+				 */
+				rc = -ENODEV;
+				goto err_out;
+			}
 		}
-	}
 	list_add_tail_rcu(&device->global_node, &dma_device_list);
 	dma_channel_rebalance();
 	mutex_unlock(&dma_list_mutex);
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index 57a43ad..fe40bc0 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -89,6 +89,7 @@ enum dma_transaction_type {
 	DMA_MEMSET,
 	DMA_MEMCPY_CRC32C,
 	DMA_INTERRUPT,
+	DMA_PRIVATE,
 	DMA_SLAVE,
 };
 
@@ -224,6 +225,18 @@ typedef enum dma_state_client (*dma_event_callback) (struct dma_client *client,
 		struct dma_chan *chan, enum dma_state state);
 
 /**
+ * typedef dma_filter_fn - callback filter for dma_request_channel
+ * @chan: channel to be reviewed
+ * @filter_param: opaque parameter passed through dma_request_channel
+ *
+ * When this optional parameter is specified in a call to dma_request_channel a
+ * suitable channel is passed to this routine for further dispositioning before
+ * being returned.  Where 'suitable' indicates a non-busy channel that
+ * satisfies the given capability mask.
+ */
+typedef enum dma_state_client (*dma_filter_fn)(struct dma_chan *chan, void *filter_param);
+
+/**
  * struct dma_client - info on the entity making use of DMA services
  * @event_callback: func ptr to call when something happens
  * @cap_mask: only return channels that satisfy the requested capabilities
@@ -472,6 +485,9 @@ void dma_async_device_unregister(struct dma_device *device);
 void dma_run_dependencies(struct dma_async_tx_descriptor *tx);
 struct dma_chan *dma_find_channel(enum dma_transaction_type tx_type);
 void dma_issue_pending_all(void);
+#define dma_request_channel(mask, x, y) __dma_request_channel(&(mask), x, y)
+struct dma_chan *__dma_request_channel(dma_cap_mask_t *mask, dma_filter_fn fn, void *fn_param);
+void dma_release_channel(struct dma_chan *chan);
 
 /* --- Helper iov-locking functions --- */
 

