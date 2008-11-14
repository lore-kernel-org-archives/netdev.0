From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 05/13] dmaengine: provide a common 'issue_pending_all'
	implementation
Date: Fri, 14 Nov 2008 14:34:42 -0700
Message-ID: <20081114213442.32354.73916.stgit@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:52014 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755014AbYKNVeo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 16:34:44 -0500
In-Reply-To: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

async_tx and net_dma each have open-coded versions of issue_pending_all,
so provide a common routine in dmaengine.

The implementation needs to walk the global device list, so implement
rcu to allow dma_issue_pending_all to run lockless.  Clients protect
themselves from channel removal events by holding a dmaengine reference.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 crypto/async_tx/async_tx.c |   12 ------------
 drivers/dma/dmaengine.c    |   27 ++++++++++++++++++++++++---
 include/linux/async_tx.h   |    2 +-
 include/linux/dmaengine.h  |    1 +
 net/core/dev.c             |    9 +--------
 5 files changed, 27 insertions(+), 24 deletions(-)

diff --git a/crypto/async_tx/async_tx.c b/crypto/async_tx/async_tx.c
index b88bb1f..2cdf7a0 100644
--- a/crypto/async_tx/async_tx.c
+++ b/crypto/async_tx/async_tx.c
@@ -45,18 +45,6 @@ static DEFINE_SPINLOCK(async_tx_lock);
 
 static LIST_HEAD(async_tx_master_list);
 
-/* async_tx_issue_pending_all - start all transactions on all channels */
-void async_tx_issue_pending_all(void)
-{
-	struct dma_chan_ref *ref;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(ref, &async_tx_master_list, node)
-		ref->chan->device->device_issue_pending(ref->chan);
-	rcu_read_unlock();
-}
-EXPORT_SYMBOL_GPL(async_tx_issue_pending_all);
-
 static void
 free_dma_chan_ref(struct rcu_head *rcu)
 {
diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index c3e6fbb..ec483cc 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -70,6 +70,7 @@
 #include <linux/rcupdate.h>
 #include <linux/mutex.h>
 #include <linux/jiffies.h>
+#include <linux/rculist.h>
 
 static DEFINE_MUTEX(dma_list_mutex);
 static LIST_HEAD(dma_device_list);
@@ -354,6 +355,26 @@ struct dma_chan *dma_find_channel(enum dma_transaction_type tx_type)
 EXPORT_SYMBOL(dma_find_channel);
 
 /**
+ * dma_issue_pending_all - flush all pending operations across all channels
+ */
+void dma_issue_pending_all(void)
+{
+	struct dma_device *device;
+	struct dma_chan *chan;
+
+	WARN_ONCE(dmaengine_ref_count == 0,
+		  "client called %s without a reference", __func__);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(device, &dma_device_list, global_node)
+		list_for_each_entry(chan, &device->channels, device_node)
+			if (chan->client_count)
+				device->device_issue_pending(chan);
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL(dma_issue_pending_all);
+
+/**
  * nth_chan - returns the nth channel of the given capability
  * @cap: capability to match
  * @n: nth channel desired
@@ -477,7 +498,7 @@ void dma_async_client_register(struct dma_client *client)
 			err = dma_chan_get(chan);
 			if (err == -ENODEV) {
 				/* module removed before we could use it */
-				list_del_init(&device->global_node);
+				list_del_rcu(&device->global_node);
 				break;
 			} else if (err)
 				pr_err("dmaengine: failed to get %s: (%d)",
@@ -612,7 +633,7 @@ int dma_async_device_register(struct dma_device *device)
 			goto err_out;
 		}
 	}
-	list_add_tail(&device->global_node, &dma_device_list);
+	list_add_tail_rcu(&device->global_node, &dma_device_list);
 	dma_channel_rebalance();
 	mutex_unlock(&dma_list_mutex);
 
@@ -654,7 +675,7 @@ void dma_async_device_unregister(struct dma_device *device)
 	struct dma_chan *chan;
 
 	mutex_lock(&dma_list_mutex);
-	list_del(&device->global_node);
+	list_del_rcu(&device->global_node);
 	dma_channel_rebalance();
 	mutex_unlock(&dma_list_mutex);
 
diff --git a/include/linux/async_tx.h b/include/linux/async_tx.h
index 1c81677..45f6297 100644
--- a/include/linux/async_tx.h
+++ b/include/linux/async_tx.h
@@ -59,7 +59,7 @@ enum async_tx_flags {
 };
 
 #ifdef CONFIG_DMA_ENGINE
-void async_tx_issue_pending_all(void);
+#define async_tx_issue_pending_all dma_issue_pending_all
 #ifdef CONFIG_ARCH_HAS_ASYNC_TX_FIND_CHANNEL
 #include <asm/async_tx.h>
 #else
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index b466f02..57a43ad 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -471,6 +471,7 @@ int dma_async_device_register(struct dma_device *device);
 void dma_async_device_unregister(struct dma_device *device);
 void dma_run_dependencies(struct dma_async_tx_descriptor *tx);
 struct dma_chan *dma_find_channel(enum dma_transaction_type tx_type);
+void dma_issue_pending_all(void);
 
 /* --- Helper iov-locking functions --- */
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 9174c77..301a449 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2442,14 +2442,7 @@ out:
 	 * There may not be any more sk_buffs coming right now, so push
 	 * any pending DMA copies to hardware
 	 */
-	if (!cpus_empty(net_dma.channel_mask)) {
-		int chan_idx;
-		for_each_cpu_mask_nr(chan_idx, net_dma.channel_mask) {
-			struct dma_chan *chan = net_dma.channels[chan_idx];
-			if (chan)
-				dma_async_memcpy_issue_pending(chan);
-		}
-	}
+	dma_issue_pending_all();
 #endif
 
 	return;

