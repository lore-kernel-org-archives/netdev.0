From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 10/13] dmaengine: replace dma_async_client_register with
	dmaengine_get
Date: Fri, 14 Nov 2008 14:35:08 -0700
Message-ID: <20081114213508.32354.68557.stgit@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30395 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755149AbYKNVfO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 16:35:14 -0500
In-Reply-To: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that clients no longer need to be notified of channel arrival
dma_async_client_register can simply increment the dmaengine_ref_count.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 crypto/async_tx/async_tx.c |  115 +-------------------------------------------
 drivers/dma/dmaengine.c    |   23 ++-------
 include/linux/dmaengine.h  |    4 +-
 net/core/dev.c             |    3 -
 4 files changed, 11 insertions(+), 134 deletions(-)

diff --git a/crypto/async_tx/async_tx.c b/crypto/async_tx/async_tx.c
index 2cdf7a0..f21147f 100644
--- a/crypto/async_tx/async_tx.c
+++ b/crypto/async_tx/async_tx.c
@@ -28,120 +28,9 @@
 #include <linux/async_tx.h>
 
 #ifdef CONFIG_DMA_ENGINE
-static enum dma_state_client
-dma_channel_add_remove(struct dma_client *client,
-	struct dma_chan *chan, enum dma_state state);
-
-static struct dma_client async_tx_dma = {
-	.event_callback = dma_channel_add_remove,
-	/* .cap_mask == 0 defaults to all channels */
-};
-
-/**
- * async_tx_lock - protect modification of async_tx_master_list and serialize
- *	rebalance operations
- */
-static DEFINE_SPINLOCK(async_tx_lock);
-
-static LIST_HEAD(async_tx_master_list);
-
-static void
-free_dma_chan_ref(struct rcu_head *rcu)
-{
-	struct dma_chan_ref *ref;
-	ref = container_of(rcu, struct dma_chan_ref, rcu);
-	kfree(ref);
-}
-
-static void
-init_dma_chan_ref(struct dma_chan_ref *ref, struct dma_chan *chan)
-{
-	INIT_LIST_HEAD(&ref->node);
-	INIT_RCU_HEAD(&ref->rcu);
-	ref->chan = chan;
-	atomic_set(&ref->count, 0);
-}
-
-static enum dma_state_client
-dma_channel_add_remove(struct dma_client *client,
-	struct dma_chan *chan, enum dma_state state)
-{
-	unsigned long found, flags;
-	struct dma_chan_ref *master_ref, *ref;
-	enum dma_state_client ack = DMA_DUP; /* default: take no action */
-
-	switch (state) {
-	case DMA_RESOURCE_AVAILABLE:
-		found = 0;
-		rcu_read_lock();
-		list_for_each_entry_rcu(ref, &async_tx_master_list, node)
-			if (ref->chan == chan) {
-				found = 1;
-				break;
-			}
-		rcu_read_unlock();
-
-		pr_debug("async_tx: dma resource available [%s]\n",
-			found ? "old" : "new");
-
-		if (!found)
-			ack = DMA_ACK;
-		else
-			break;
-
-		/* add the channel to the generic management list */
-		master_ref = kmalloc(sizeof(*master_ref), GFP_KERNEL);
-		if (master_ref) {
-			init_dma_chan_ref(master_ref, chan);
-			spin_lock_irqsave(&async_tx_lock, flags);
-			list_add_tail_rcu(&master_ref->node,
-				&async_tx_master_list);
-			spin_unlock_irqrestore(&async_tx_lock,
-				flags);
-		} else {
-			printk(KERN_WARNING "async_tx: unable to create"
-				" new master entry in response to"
-				" a DMA_RESOURCE_ADDED event"
-				" (-ENOMEM)\n");
-			return 0;
-		}
-		break;
-	case DMA_RESOURCE_REMOVED:
-		found = 0;
-		spin_lock_irqsave(&async_tx_lock, flags);
-		list_for_each_entry(ref, &async_tx_master_list, node)
-			if (ref->chan == chan) {
-				list_del_rcu(&ref->node);
-				call_rcu(&ref->rcu, free_dma_chan_ref);
-				found = 1;
-				break;
-			}
-		spin_unlock_irqrestore(&async_tx_lock, flags);
-
-		pr_debug("async_tx: dma resource removed [%s]\n",
-			found ? "ours" : "not ours");
-
-		if (found)
-			ack = DMA_ACK;
-		else
-			break;
-		break;
-	case DMA_RESOURCE_SUSPEND:
-	case DMA_RESOURCE_RESUME:
-		printk(KERN_WARNING "async_tx: does not support dma channel"
-			" suspend/resume\n");
-		break;
-	default:
-		BUG();
-	}
-
-	return ack;
-}
-
 static int __init async_tx_init(void)
 {
-	dma_async_client_register(&async_tx_dma);
-	dma_async_client_chan_request(&async_tx_dma);
+	dmaengine_get();
 
 	printk(KERN_INFO "async_tx: api initialized (async)\n");
 
@@ -150,7 +39,7 @@ static int __init async_tx_init(void)
 
 static void __exit async_tx_exit(void)
 {
-	dma_async_client_unregister(&async_tx_dma);
+	dmaengine_put();
 }
 
 /**
diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index 1b694b8..78456f5 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -588,10 +588,9 @@ static void dma_clients_notify_available(void)
 }
 
 /**
- * dma_async_client_register - register a &dma_client
- * @client: ptr to a client structure with valid 'event_callback' and 'cap_mask'
+ * dmaengine_get - register interest in dma_channels
  */
-void dma_async_client_register(struct dma_client *client)
+void dmaengine_get(void)
 {
 	struct dma_device *device, *_d;
 	struct dma_chan *chan;
@@ -615,26 +614,18 @@ void dma_async_client_register(struct dma_client *client)
 				       dev_name(&chan->dev), err);
 		}
 	}
-
-	list_add_tail(&client->global_node, &dma_client_list);
 	mutex_unlock(&dma_list_mutex);
 }
-EXPORT_SYMBOL(dma_async_client_register);
+EXPORT_SYMBOL(dmaengine_get);
 
 /**
- * dma_async_client_unregister - unregister a client and free the &dma_client
- * @client: &dma_client to free
- *
- * Force frees any allocated DMA channels, frees the &dma_client memory
+ * dmaengine_put - let dma drivers be removed when ref_count == 0
  */
-void dma_async_client_unregister(struct dma_client *client)
+void dmaengine_put(void)
 {
 	struct dma_device *device;
 	struct dma_chan *chan;
 
-	if (!client)
-		return;
-
 	mutex_lock(&dma_list_mutex);
 	dmaengine_ref_count--;
 	BUG_ON(dmaengine_ref_count < 0);
@@ -645,11 +636,9 @@ void dma_async_client_unregister(struct dma_client *client)
 		list_for_each_entry(chan, &device->channels, device_node)
 			dma_chan_put(chan);
 	}
-
-	list_del(&client->global_node);
 	mutex_unlock(&dma_list_mutex);
 }
-EXPORT_SYMBOL(dma_async_client_unregister);
+EXPORT_SYMBOL(dmaengine_put);
 
 /**
  * dma_async_client_chan_request - send all available channels to the
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index d63544c..37d95db 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -318,8 +318,8 @@ struct dma_device {
 
 /* --- public DMA engine API --- */
 
-void dma_async_client_register(struct dma_client *client);
-void dma_async_client_unregister(struct dma_client *client);
+void dmaengine_get(void);
+void dmaengine_put(void);
 void dma_async_client_chan_request(struct dma_client *client);
 dma_cookie_t dma_async_memcpy_buf_to_buf(struct dma_chan *chan,
 	void *dest, void *src, size_t len);
diff --git a/net/core/dev.c b/net/core/dev.c
index 56e6965..4b3b7d3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4657,8 +4657,7 @@ static int __init netdev_dma_register(void)
 	}
 	spin_lock_init(&net_dma.lock);
 	dma_cap_set(DMA_MEMCPY, net_dma.client.cap_mask);
-	dma_async_client_register(&net_dma.client);
-	dma_async_client_chan_request(&net_dma.client);
+	dmaengine_get();
 	return 0;
 }
 

