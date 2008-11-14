From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 04/13] dmaengine: centralize channel allocation,
	introduce dma_find_channel
Date: Fri, 14 Nov 2008 14:34:37 -0700
Message-ID: <20081114213437.32354.66972.stgit@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45705 "EHLO mga02.intel.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754322AbYKNVel (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 16:34:41 -0500
In-Reply-To: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allowing multiple clients to each define their own channel allocation
scheme quickly leads to a pathological situation.  For memory-to-memory
offload all clients can share a central allocator.

This simply moves the existing async_tx allocator to dmaengine with
minimal fixups:
* async_tx.c:get_chan_ref_by_cap --> dmaengine.c:nth_chan
* async_tx.c:async_tx_rebalance --> dmaengine.c:dma_channel_rebalance
* split out common code from async_tx.c:__async_tx_find_channel -->
  dma_find_channel

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 crypto/async_tx/async_tx.c |  146 +---------------------------------------
 drivers/dma/dmaengine.c    |  159 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/dmaengine.h  |    3 +
 3 files changed, 166 insertions(+), 142 deletions(-)

diff --git a/crypto/async_tx/async_tx.c b/crypto/async_tx/async_tx.c
index 43fe4cb..b88bb1f 100644
--- a/crypto/async_tx/async_tx.c
+++ b/crypto/async_tx/async_tx.c
@@ -38,25 +38,10 @@ static struct dma_client async_tx_dma = {
 };
 
 /**
- * dma_cap_mask_all - enable iteration over all operation types
- */
-static dma_cap_mask_t dma_cap_mask_all;
-
-/**
- * chan_ref_percpu - tracks channel allocations per core/opertion
- */
-struct chan_ref_percpu {
-	struct dma_chan_ref *ref;
-};
-
-static int channel_table_initialized;
-static struct chan_ref_percpu *channel_table[DMA_TX_TYPE_END];
-
-/**
  * async_tx_lock - protect modification of async_tx_master_list and serialize
  *	rebalance operations
  */
-static spinlock_t async_tx_lock;
+static DEFINE_SPINLOCK(async_tx_lock);
 
 static LIST_HEAD(async_tx_master_list);
 
@@ -89,85 +74,6 @@ init_dma_chan_ref(struct dma_chan_ref *ref, struct dma_chan *chan)
 	atomic_set(&ref->count, 0);
 }
 
-/**
- * get_chan_ref_by_cap - returns the nth channel of the given capability
- * 	defaults to returning the channel with the desired capability and the
- * 	lowest reference count if the index can not be satisfied
- * @cap: capability to match
- * @index: nth channel desired, passing -1 has the effect of forcing the
- *  default return value
- */
-static struct dma_chan_ref *
-get_chan_ref_by_cap(enum dma_transaction_type cap, int index)
-{
-	struct dma_chan_ref *ret_ref = NULL, *min_ref = NULL, *ref;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(ref, &async_tx_master_list, node)
-		if (dma_has_cap(cap, ref->chan->device->cap_mask)) {
-			if (!min_ref)
-				min_ref = ref;
-			else if (atomic_read(&ref->count) <
-				atomic_read(&min_ref->count))
-				min_ref = ref;
-
-			if (index-- == 0) {
-				ret_ref = ref;
-				break;
-			}
-		}
-	rcu_read_unlock();
-
-	if (!ret_ref)
-		ret_ref = min_ref;
-
-	if (ret_ref)
-		atomic_inc(&ret_ref->count);
-
-	return ret_ref;
-}
-
-/**
- * async_tx_rebalance - redistribute the available channels, optimize
- * for cpu isolation in the SMP case, and opertaion isolation in the
- * uniprocessor case
- */
-static void async_tx_rebalance(void)
-{
-	int cpu, cap, cpu_idx = 0;
-	unsigned long flags;
-
-	if (!channel_table_initialized)
-		return;
-
-	spin_lock_irqsave(&async_tx_lock, flags);
-
-	/* undo the last distribution */
-	for_each_dma_cap_mask(cap, dma_cap_mask_all)
-		for_each_possible_cpu(cpu) {
-			struct dma_chan_ref *ref =
-				per_cpu_ptr(channel_table[cap], cpu)->ref;
-			if (ref) {
-				atomic_set(&ref->count, 0);
-				per_cpu_ptr(channel_table[cap], cpu)->ref =
-									NULL;
-			}
-		}
-
-	for_each_dma_cap_mask(cap, dma_cap_mask_all)
-		for_each_online_cpu(cpu) {
-			struct dma_chan_ref *new;
-			if (NR_CPUS > 1)
-				new = get_chan_ref_by_cap(cap, cpu_idx++);
-			else
-				new = get_chan_ref_by_cap(cap, -1);
-
-			per_cpu_ptr(channel_table[cap], cpu)->ref = new;
-		}
-
-	spin_unlock_irqrestore(&async_tx_lock, flags);
-}
-
 static enum dma_state_client
 dma_channel_add_remove(struct dma_client *client,
 	struct dma_chan *chan, enum dma_state state)
@@ -211,8 +117,6 @@ dma_channel_add_remove(struct dma_client *client,
 				" (-ENOMEM)\n");
 			return 0;
 		}
-
-		async_tx_rebalance();
 		break;
 	case DMA_RESOURCE_REMOVED:
 		found = 0;
@@ -233,8 +137,6 @@ dma_channel_add_remove(struct dma_client *client,
 			ack = DMA_ACK;
 		else
 			break;
-
-		async_tx_rebalance();
 		break;
 	case DMA_RESOURCE_SUSPEND:
 	case DMA_RESOURCE_RESUME:
@@ -248,51 +150,18 @@ dma_channel_add_remove(struct dma_client *client,
 	return ack;
 }
 
-static int __init
-async_tx_init(void)
+static int __init async_tx_init(void)
 {
-	enum dma_transaction_type cap;
-
-	spin_lock_init(&async_tx_lock);
-	bitmap_fill(dma_cap_mask_all.bits, DMA_TX_TYPE_END);
-
-	/* an interrupt will never be an explicit operation type.
-	 * clearing this bit prevents allocation to a slot in 'channel_table'
-	 */
-	clear_bit(DMA_INTERRUPT, dma_cap_mask_all.bits);
-
-	for_each_dma_cap_mask(cap, dma_cap_mask_all) {
-		channel_table[cap] = alloc_percpu(struct chan_ref_percpu);
-		if (!channel_table[cap])
-			goto err;
-	}
-
-	channel_table_initialized = 1;
 	dma_async_client_register(&async_tx_dma);
 	dma_async_client_chan_request(&async_tx_dma);
 
 	printk(KERN_INFO "async_tx: api initialized (async)\n");
 
 	return 0;
-err:
-	printk(KERN_ERR "async_tx: initialization failure\n");
-
-	while (--cap >= 0)
-		free_percpu(channel_table[cap]);
-
-	return 1;
 }
 
 static void __exit async_tx_exit(void)
 {
-	enum dma_transaction_type cap;
-
-	channel_table_initialized = 0;
-
-	for_each_dma_cap_mask(cap, dma_cap_mask_all)
-		if (channel_table[cap])
-			free_percpu(channel_table[cap]);
-
 	dma_async_client_unregister(&async_tx_dma);
 }
 
@@ -308,16 +177,9 @@ __async_tx_find_channel(struct dma_async_tx_descriptor *depend_tx,
 {
 	/* see if we can keep the chain on one channel */
 	if (depend_tx &&
-		dma_has_cap(tx_type, depend_tx->chan->device->cap_mask))
+	    dma_has_cap(tx_type, depend_tx->chan->device->cap_mask))
 		return depend_tx->chan;
-	else if (likely(channel_table_initialized)) {
-		struct dma_chan_ref *ref;
-		int cpu = get_cpu();
-		ref = per_cpu_ptr(channel_table[tx_type], cpu)->ref;
-		put_cpu();
-		return ref ? ref->chan : NULL;
-	} else
-		return NULL;
+	return dma_find_channel(tx_type);
 }
 EXPORT_SYMBOL_GPL(__async_tx_find_channel);
 #else
diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index df37073..c3e6fbb 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -284,6 +284,162 @@ static void dma_chan_release(struct dma_chan *chan)
 }
 
 /**
+ * dma_cap_mask_all - enable iteration over all operation types
+ */
+static dma_cap_mask_t dma_cap_mask_all;
+
+/**
+ * dma_chan_tbl_ent - tracks channel allocations per core/opertion
+ */
+struct dma_chan_tbl_ent {
+	struct dma_chan *chan;
+};
+
+/**
+ * channel_table - percpu lookup table for memory-to-memory offload providers
+ */
+static struct dma_chan_tbl_ent *channel_table[DMA_TX_TYPE_END];
+
+static int __init dma_channel_table_init(void)
+{
+	enum dma_transaction_type cap;
+	int err = 0;
+
+	bitmap_fill(dma_cap_mask_all.bits, DMA_TX_TYPE_END);
+
+	/* 'interrupt' and 'slave' are channel capabilities, but are not
+	 * associated with an operation so they do not need an entry in the
+	 * channel_table
+	 */
+	clear_bit(DMA_INTERRUPT, dma_cap_mask_all.bits);
+	clear_bit(DMA_SLAVE, dma_cap_mask_all.bits);
+
+	for_each_dma_cap_mask(cap, dma_cap_mask_all) {
+		channel_table[cap] = alloc_percpu(struct dma_chan_tbl_ent);
+		if (!channel_table[cap]) {
+			err = 1;
+			break;
+		}
+	}
+
+	if (err) {
+		pr_err("dmaengine: initialization failure\n");
+		for_each_dma_cap_mask(cap, dma_cap_mask_all)
+			if (channel_table[cap])
+				free_percpu(channel_table[cap]);
+	}
+
+	return err;
+}
+subsys_initcall(dma_channel_table_init);
+
+/**
+ * dma_find_channel - find a channel to carry out the operation
+ * @tx_type: transaction type
+ */
+struct dma_chan *dma_find_channel(enum dma_transaction_type tx_type)
+{
+	struct dma_chan *chan;
+	int cpu;
+
+	WARN_ONCE(dmaengine_ref_count == 0,
+		  "client called %s without a reference", __func__);
+
+	cpu = get_cpu();
+	chan = per_cpu_ptr(channel_table[tx_type], cpu)->chan;
+	put_cpu();
+
+	return chan;
+}
+EXPORT_SYMBOL(dma_find_channel);
+
+/**
+ * nth_chan - returns the nth channel of the given capability
+ * @cap: capability to match
+ * @n: nth channel desired
+ *
+ * Defaults to returning the channel with the desired capability and the
+ * lowest reference count when 'n' cannot be satisfied
+ */
+static struct dma_chan *nth_chan(enum dma_transaction_type cap, int n)
+{
+	struct dma_device *device;
+	struct dma_chan *chan;
+	struct dma_chan *ret = NULL;
+	struct dma_chan *min = NULL;
+
+	list_for_each_entry(device, &dma_device_list, global_node) {
+		if (!dma_has_cap(cap, device->cap_mask))
+			continue;
+		list_for_each_entry(chan, &device->channels, device_node) {
+			if (!chan->client_count)
+				continue;
+			if (!min)
+				min = chan;
+			else if (chan->table_count < min->table_count)
+				min = chan;
+
+			if (n-- == 0) {
+				ret = chan;
+				break; /* done */
+			}
+		}
+		if (ret)
+			break; /* done */
+	}
+
+	if (!ret)
+		ret = min;
+
+	if (ret)
+		ret->table_count++;
+
+	return ret;
+}
+
+/**
+ * dma_channel_rebalance - redistribute the available channels
+ *
+ * Optimize for cpu isolation (each cpu gets a dedicated channel for an
+ * operation type) in the SMP case,  and opertaion isolation (avoid
+ * multi-tasking channels) in the uniprocessor case.  Must be called
+ * under dma_list_mutex.
+ */
+static void dma_channel_rebalance(void)
+{
+	struct dma_chan *chan;
+	struct dma_device *device;
+	int cpu;
+	int cap;
+	int n;
+
+	/* undo the last distribution */
+	for_each_dma_cap_mask(cap, dma_cap_mask_all)
+		for_each_possible_cpu(cpu)
+			per_cpu_ptr(channel_table[cap], cpu)->chan = NULL;
+
+	list_for_each_entry(device, &dma_device_list, global_node)
+		list_for_each_entry(chan, &device->channels, device_node)
+			chan->table_count = 0;
+
+	/* don't populate the channel_table if no clients are available */
+	if (!dmaengine_ref_count)
+		return;
+
+	/* redistribute available channels */
+	n = 0;
+	for_each_dma_cap_mask(cap, dma_cap_mask_all)
+		for_each_online_cpu(cpu) {
+			if (num_possible_cpus() > 1)
+				chan = nth_chan(cap, n++);
+			else
+				chan = nth_chan(cap, -1);
+
+			per_cpu_ptr(channel_table[cap], cpu)->chan = chan;
+		}
+}
+
+/**
  * dma_chans_notify_available - broadcast available channels to the clients
  */
 static void dma_clients_notify_available(void)
@@ -457,6 +613,7 @@ int dma_async_device_register(struct dma_device *device)
 		}
 	}
 	list_add_tail(&device->global_node, &dma_device_list);
+	dma_channel_rebalance();
 	mutex_unlock(&dma_list_mutex);
 
 	dma_clients_notify_available();
@@ -498,6 +655,7 @@ void dma_async_device_unregister(struct dma_device *device)
 
 	mutex_lock(&dma_list_mutex);
 	list_del(&device->global_node);
+	dma_channel_rebalance();
 	mutex_unlock(&dma_list_mutex);
 
 	list_for_each_entry(chan, &device->channels, device_node) {
@@ -743,3 +901,4 @@ static int __init dma_bus_init(void)
 }
 subsys_initcall(dma_bus_init);
 
+
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index d18d37d..b466f02 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -182,6 +182,7 @@ struct dma_chan_percpu {
  * @device_node: used to add this to the device chan list
  * @local: per-cpu pointer to a struct dma_chan_percpu
  * @client-count: how many clients are using this channel
+ * @table_count: number of appearances in the mem-to-mem allocation table
  */
 struct dma_chan {
 	struct dma_device *device;
@@ -198,6 +199,7 @@ struct dma_chan {
 	struct list_head device_node;
 	struct dma_chan_percpu *local;
 	int client_count;
+	int table_count;
 };
 
 #define to_dma_chan(p) container_of(p, struct dma_chan, dev)
@@ -468,6 +470,7 @@ static inline enum dma_status dma_wait_for_async_tx(struct dma_async_tx_descript
 int dma_async_device_register(struct dma_device *device);
 void dma_async_device_unregister(struct dma_device *device);
 void dma_run_dependencies(struct dma_async_tx_descriptor *tx);
+struct dma_chan *dma_find_channel(enum dma_transaction_type tx_type);
 
 /* --- Helper iov-locking functions --- */
 

