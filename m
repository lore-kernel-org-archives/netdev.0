From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 12/13] dmaengine: remove 'bigref' infrastructure
Date: Fri, 14 Nov 2008 14:35:19 -0700
Message-ID: <20081114213518.32354.20458.stgit@dwillia2-linux.ch.intel.com>
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
	id S1755895AbYKNVfU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 16:35:20 -0500
In-Reply-To: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reference counting is done at the module level so clients need not worry
that a channel will leave while they are actively using dmaengine.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 drivers/dma/dmaengine.c   |   86 +++++----------------------------------------
 drivers/dma/iop-adma.c    |    1 -
 drivers/dma/mv_xor.c      |    1 -
 include/linux/dmaengine.h |    7 ----
 4 files changed, 9 insertions(+), 86 deletions(-)

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index 26f862c..a6c0d72 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -34,26 +34,15 @@
  * The subsystem keeps a global list of dma_device structs it is protected by a
  * mutex, dma_list_mutex.
  *
+ * A subsystem can get access to a channel by calling dmaengine_get() followed
+ * by dma_find_channel(), or if it has need for an exclusive channel it can call
+ * dma_request_channel().  Once a channel is allocated a reference is taken
+ * against its corresponding driver to disable removal.
+ *
  * Each device has a channels list, which runs unlocked but is never modified
  * once the device is registered, it's just setup by the driver.
  *
- * Each device has a kref, which is initialized to 1 when the device is
- * registered. A kref_get is done for each device registered.  When the
- * device is released, the corresponding kref_put is done in the release
- * method. Every time one of the device's channels is allocated to a client,
- * a kref_get occurs.  When the channel is freed, the corresponding kref_put
- * happens. The device's release function does a completion, so
- * unregister_device does a remove event, device_unregister, a kref_put
- * for the first reference, then waits on the completion for all other
- * references to finish.
- *
- * Each channel has an open-coded implementation of Rusty Russell's "bigref,"
- * with a kref and a per_cpu local_t.  A dma_chan_get is called when a client
- * signals that it wants to use a channel, and dma_chan_put is called when
- * a channel is removed or a client using it is unregistered.  A client can
- * take extra references per outstanding transaction, as is the case with
- * the NET DMA client.  The release function does a kref_put on the device.
- *	-ChrisL, DanW
+ * See Documentation/dmaengine.txt for more details
  */
 
 #include <linux/init.h>
@@ -114,18 +103,9 @@ static struct device_attribute dma_attrs[] = {
 	__ATTR_NULL
 };
 
-static void dma_async_device_cleanup(struct kref *kref);
-
-static void dma_dev_release(struct device *dev)
-{
-	struct dma_chan *chan = to_dma_chan(dev);
-	kref_put(&chan->device->refcount, dma_async_device_cleanup);
-}
-
 static struct class dma_devclass = {
 	.name		= "dma",
 	.dev_attrs	= dma_attrs,
-	.dev_release	= dma_dev_release,
 };
 
 /* --- client and device registration --- */
@@ -222,29 +202,6 @@ enum dma_status dma_sync_wait(struct dma_chan *chan, dma_cookie_t cookie)
 EXPORT_SYMBOL(dma_sync_wait);
 
 /**
- * dma_chan_cleanup - release a DMA channel's resources
- * @kref: kernel reference structure that contains the DMA channel device
- */
-void dma_chan_cleanup(struct kref *kref)
-{
-	struct dma_chan *chan = container_of(kref, struct dma_chan, refcount);
-	kref_put(&chan->device->refcount, dma_async_device_cleanup);
-}
-EXPORT_SYMBOL(dma_chan_cleanup);
-
-static void dma_chan_free_rcu(struct rcu_head *rcu)
-{
-	struct dma_chan *chan = container_of(rcu, struct dma_chan, rcu);
-
-	kref_put(&chan->refcount, dma_chan_cleanup);
-}
-
-static void dma_chan_release(struct dma_chan *chan)
-{
-	call_rcu(&chan->rcu, dma_chan_free_rcu);
-}
-
-/**
  * dma_cap_mask_all - enable iteration over all operation types
  */
 static dma_cap_mask_t dma_cap_mask_all;
@@ -622,8 +579,6 @@ int dma_async_device_register(struct dma_device *device)
 	BUG_ON(!device->device_issue_pending);
 	BUG_ON(!device->dev);
 
-	init_completion(&device->done);
-	kref_init(&device->refcount);
 	device->dev_id = id++;
 
 	/* represent channels in sysfs. Probably want devs too */
@@ -640,19 +595,11 @@ int dma_async_device_register(struct dma_device *device)
 
 		rc = device_register(&chan->dev);
 		if (rc) {
-			chancnt--;
 			free_percpu(chan->local);
 			chan->local = NULL;
 			goto err_out;
 		}
-
-		/* One for the channel, one of the class device */
-		kref_get(&device->refcount);
-		kref_get(&device->refcount);
-		kref_init(&chan->refcount);
 		chan->client_count = 0;
-		chan->slow_ref = 0;
-		INIT_RCU_HEAD(&chan->rcu);
 	}
 	device->chancnt = chancnt;
 
@@ -683,9 +630,7 @@ err_out:
 	list_for_each_entry(chan, &device->channels, device_node) {
 		if (chan->local == NULL)
 			continue;
-		kref_put(&device->refcount, dma_async_device_cleanup);
 		device_unregister(&chan->dev);
-		chancnt--;
 		free_percpu(chan->local);
 	}
 	return rc;
@@ -693,20 +638,11 @@ err_out:
 EXPORT_SYMBOL(dma_async_device_register);
 
 /**
- * dma_async_device_cleanup - function called when all references are released
- * @kref: kernel reference object
- */
-static void dma_async_device_cleanup(struct kref *kref)
-{
-	struct dma_device *device;
-
-	device = container_of(kref, struct dma_device, refcount);
-	complete(&device->done);
-}
-
-/**
  * dma_async_device_unregister - unregisters DMA devices
  * @device: &dma_device
+ *
+ * This routine is called by dma driver exit routines, dmaengine holds module
+ * references to prevent it being called while channels are in use.
  */
 void dma_async_device_unregister(struct dma_device *device)
 {
@@ -722,11 +658,7 @@ void dma_async_device_unregister(struct dma_device *device)
 			  "%s called while %d clients hold a reference\n",
 			  __func__, chan->client_count);
 		device_unregister(&chan->dev);
-		dma_chan_release(chan);
 	}
-
-	kref_put(&device->refcount, dma_async_device_cleanup);
-	wait_for_completion(&device->done);
 }
 EXPORT_SYMBOL(dma_async_device_unregister);
 
diff --git a/drivers/dma/iop-adma.c b/drivers/dma/iop-adma.c
index 44c483e..6963400 100644
--- a/drivers/dma/iop-adma.c
+++ b/drivers/dma/iop-adma.c
@@ -1243,7 +1243,6 @@ static int __devinit iop_adma_probe(struct platform_device *pdev)
 	spin_lock_init(&iop_chan->lock);
 	INIT_LIST_HEAD(&iop_chan->chain);
 	INIT_LIST_HEAD(&iop_chan->all_slots);
-	INIT_RCU_HEAD(&iop_chan->common.rcu);
 	iop_chan->common.device = dma_dev;
 	list_add_tail(&iop_chan->common.device_node, &dma_dev->channels);
 
diff --git a/drivers/dma/mv_xor.c b/drivers/dma/mv_xor.c
index dabdc36..acb271d 100644
--- a/drivers/dma/mv_xor.c
+++ b/drivers/dma/mv_xor.c
@@ -1210,7 +1210,6 @@ static int __devinit mv_xor_probe(struct platform_device *pdev)
 	INIT_LIST_HEAD(&mv_chan->chain);
 	INIT_LIST_HEAD(&mv_chan->completed_slots);
 	INIT_LIST_HEAD(&mv_chan->all_slots);
-	INIT_RCU_HEAD(&mv_chan->common.rcu);
 	mv_chan->common.device = dma_dev;
 
 	list_add_tail(&mv_chan->common.device_node, &dma_dev->channels);
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index ad9fd55..32edaf4 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -156,10 +156,6 @@ struct dma_chan {
 	int chan_id;
 	struct device dev;
 
-	struct kref refcount;
-	int slow_ref;
-	struct rcu_head rcu;
-
 	struct list_head device_node;
 	struct dma_chan_percpu *local;
 	int client_count;
@@ -247,9 +243,6 @@ struct dma_device {
 	dma_cap_mask_t  cap_mask;
 	int max_xor;
 
-	struct kref refcount;
-	struct completion done;
-
 	int dev_id;
 	struct device *dev;
 

