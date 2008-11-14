From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 08/13] dmatest: convert to dma_request_channel
Date: Fri, 14 Nov 2008 14:34:58 -0700
Message-ID: <20081114213458.32354.58258.stgit@dwillia2-linux.ch.intel.com>
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
	id S1755847AbYKNVe7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 16:34:59 -0500
In-Reply-To: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the client registration infrastructure with a custom loop to
poll for channels.  Once dma_request_channel returns NULL stop asking
for channels.  A userspace side effect of this change if that loading
the dmatest module before loading a dma driver will result in no
channels being found, previously dmatest would get a callback.  To
facilitate testing in the built-in case dmatest_init is marked as a
late_initcall.  Another side effect is that channels under test can not
be used for any other purpose.

Cc: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 drivers/dma/dmatest.c     |  109 ++++++++++++++++-----------------------------
 include/linux/dmaengine.h |    6 ++
 2 files changed, 44 insertions(+), 71 deletions(-)

diff --git a/drivers/dma/dmatest.c b/drivers/dma/dmatest.c
index db40508..2a7724d 100644
--- a/drivers/dma/dmatest.c
+++ b/drivers/dma/dmatest.c
@@ -35,7 +35,7 @@ MODULE_PARM_DESC(threads_per_chan,
 
 static unsigned int max_channels;
 module_param(max_channels, uint, S_IRUGO);
-MODULE_PARM_DESC(nr_channels,
+MODULE_PARM_DESC(max_channels,
 		"Maximum number of channels to use (default: all)");
 
 /*
@@ -71,7 +71,7 @@ struct dmatest_chan {
 
 /*
  * These are protected by dma_list_mutex since they're only used by
- * the DMA client event callback
+ * the DMA filter function callback
  */
 static LIST_HEAD(dmatest_channels);
 static unsigned int nr_channels;
@@ -317,21 +317,16 @@ static void dmatest_cleanup_channel(struct dmatest_chan *dtc)
 	kfree(dtc);
 }
 
-static enum dma_state_client dmatest_add_channel(struct dma_chan *chan)
+static int dmatest_add_channel(struct dma_chan *chan)
 {
 	struct dmatest_chan	*dtc;
 	struct dmatest_thread	*thread;
 	unsigned int		i;
 
-	/* Have we already been told about this channel? */
-	list_for_each_entry(dtc, &dmatest_channels, node)
-		if (dtc->chan == chan)
-			return DMA_DUP;
-
 	dtc = kmalloc(sizeof(struct dmatest_chan), GFP_KERNEL);
 	if (!dtc) {
 		pr_warning("dmatest: No memory for %s\n", dev_name(&chan->dev));
-		return DMA_NAK;
+		return -ENOMEM;
 	}
 
 	dtc->chan = chan;
@@ -365,81 +360,53 @@ static enum dma_state_client dmatest_add_channel(struct dma_chan *chan)
 	list_add_tail(&dtc->node, &dmatest_channels);
 	nr_channels++;
 
-	return DMA_ACK;
-}
-
-static enum dma_state_client dmatest_remove_channel(struct dma_chan *chan)
-{
-	struct dmatest_chan	*dtc, *_dtc;
-
-	list_for_each_entry_safe(dtc, _dtc, &dmatest_channels, node) {
-		if (dtc->chan == chan) {
-			list_del(&dtc->node);
-			dmatest_cleanup_channel(dtc);
-			pr_debug("dmatest: lost channel %s\n",
-					dev_name(&chan->dev));
-			return DMA_ACK;
-		}
-	}
-
-	return DMA_DUP;
+	return 0;
 }
 
-/*
- * Start testing threads as new channels are assigned to us, and kill
- * them when the channels go away.
- *
- * When we unregister the client, all channels are removed so this
- * will also take care of cleaning things up when the module is
- * unloaded.
- */
-static enum dma_state_client
-dmatest_event(struct dma_client *client, struct dma_chan *chan,
-		enum dma_state state)
+static enum dma_state_client filter(struct dma_chan *chan, void *param)
 {
-	enum dma_state_client	ack = DMA_NAK;
-
-	switch (state) {
-	case DMA_RESOURCE_AVAILABLE:
-		if (!dmatest_match_channel(chan)
-				|| !dmatest_match_device(chan->device))
-			ack = DMA_DUP;
-		else if (max_channels && nr_channels >= max_channels)
-			ack = DMA_NAK;
-		else
-			ack = dmatest_add_channel(chan);
-		break;
-
-	case DMA_RESOURCE_REMOVED:
-		ack = dmatest_remove_channel(chan);
-		break;
-
-	default:
-		pr_info("dmatest: Unhandled event %u (%s)\n",
-				state, dev_name(&chan->dev));
-		break;
-	}
-
-	return ack;
+	if (!dmatest_match_channel(chan) || !dmatest_match_device(chan->device))
+		return DMA_DUP;
+	else
+		return DMA_ACK;
 }
 
-static struct dma_client dmatest_client = {
-	.event_callback	= dmatest_event,
-};
-
 static int __init dmatest_init(void)
 {
-	dma_cap_set(DMA_MEMCPY, dmatest_client.cap_mask);
-	dma_async_client_register(&dmatest_client);
-	dma_async_client_chan_request(&dmatest_client);
+	dma_cap_mask_t mask;
+	struct dma_chan *chan;
+
+	dma_cap_zero(mask);
+	dma_cap_set(DMA_MEMCPY, mask);
+	for (;;) {
+		chan = dma_request_channel(mask, filter, NULL);
+		if (chan) {
+			if (dmatest_add_channel(chan) == 0)
+				continue;
+			else
+				dma_release_channel(chan);
+		} else
+			break; /* no more channels available */
+		if (max_channels && nr_channels >= max_channels)
+			break; /* we have all we need */
+	}
 
 	return 0;
 }
-module_init(dmatest_init);
+/* when compiled-in wait for drivers to load first */
+late_initcall(dmatest_init);
 
 static void __exit dmatest_exit(void)
 {
-	dma_async_client_unregister(&dmatest_client);
+	struct dmatest_chan *dtc, *_dtc;
+
+	list_for_each_entry_safe(dtc, _dtc, &dmatest_channels, node) {
+		list_del(&dtc->node);
+		dmatest_cleanup_channel(dtc);
+		pr_debug("dmatest: dropped channel %s\n",
+			 dev_name(&dtc->chan->dev));
+		dma_release_channel(dtc->chan);
+	}
 }
 module_exit(dmatest_exit);
 
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index fe40bc0..6f2d070 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -400,6 +400,12 @@ __dma_cap_set(enum dma_transaction_type tx_type, dma_cap_mask_t *dstp)
 	set_bit(tx_type, dstp->bits);
 }
 
+#define dma_cap_zero(mask) __dma_cap_zero(&(mask))
+static inline void __dma_cap_zero(dma_cap_mask_t *dstp)
+{
+	bitmap_zero(dstp->bits, DMA_TX_TYPE_END);
+}
+
 #define dma_has_cap(tx, mask) __dma_has_cap((tx), &(mask))
 static inline int
 __dma_has_cap(enum dma_transaction_type tx_type, dma_cap_mask_t *srcp)

