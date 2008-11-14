From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 13/13] dmaengine: kill enum dma_state_client
Date: Fri, 14 Nov 2008 14:35:24 -0700
Message-ID: <20081114213524.32354.18358.stgit@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9079 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755169AbYKNVf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 16:35:27 -0500
In-Reply-To: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DMA_NAK is now useless.  We can just use a bool instead.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 drivers/dma/dmaengine.c      |   16 +++++-----------
 drivers/dma/dmatest.c        |    6 +++---
 drivers/mmc/host/atmel-mci.c |    6 +++---
 include/linux/dmaengine.h    |   17 +++--------------
 4 files changed, 14 insertions(+), 31 deletions(-)

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index a6c0d72..dae88f2 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -428,7 +428,7 @@ struct dma_chan *__dma_request_channel(dma_cap_mask_t *mask, dma_filter_fn fn, v
 {
 	struct dma_device *device, *_d;
 	struct dma_chan *chan = NULL;
-	enum dma_state_client ack;
+	bool ack;
 	int err;
 
 	/* Find a channel */
@@ -441,9 +441,9 @@ struct dma_chan *__dma_request_channel(dma_cap_mask_t *mask, dma_filter_fn fn, v
 		if (fn)
 			ack = fn(chan, fn_param);
 		else
-			ack = DMA_ACK;
+			ack = true;
 
-		if (ack == DMA_ACK) {
+		if (ack) {
 			/* Found a suitable channel, try to grab, prep, and
 			 * return it.  We first set DMA_PRIVATE to disable
 			 * balance_ref_count as this channel will not be
@@ -461,15 +461,9 @@ struct dma_chan *__dma_request_channel(dma_cap_mask_t *mask, dma_filter_fn fn, v
 				       dev_name(&chan->dev), err);
 			else
 				break;
-		} else if (ack == DMA_DUP) {
-			pr_debug("%s: %s filter said DMA_DUP\n",
-				 __func__, dev_name(&chan->dev));
-		} else if (ack == DMA_NAK) {
-			pr_debug("%s: %s filter said DMA_NAK\n",
-				 __func__, dev_name(&chan->dev));
-			break;
 		} else
-			WARN_ONCE(1, "filter_fn: unknown response?\n");
+			pr_debug("%s: %s filter said false\n",
+				 __func__, dev_name(&chan->dev));
 		chan = NULL;
 	}
 	mutex_unlock(&dma_list_mutex);
diff --git a/drivers/dma/dmatest.c b/drivers/dma/dmatest.c
index 2a7724d..e0f9139 100644
--- a/drivers/dma/dmatest.c
+++ b/drivers/dma/dmatest.c
@@ -363,12 +363,12 @@ static int dmatest_add_channel(struct dma_chan *chan)
 	return 0;
 }
 
-static enum dma_state_client filter(struct dma_chan *chan, void *param)
+static bool filter(struct dma_chan *chan, void *param)
 {
 	if (!dmatest_match_channel(chan) || !dmatest_match_device(chan->device))
-		return DMA_DUP;
+		return false;
 	else
-		return DMA_ACK;
+		return true;
 }
 
 static int __init dmatest_init(void)
diff --git a/drivers/mmc/host/atmel-mci.c b/drivers/mmc/host/atmel-mci.c
index 4b567a0..b0042d0 100644
--- a/drivers/mmc/host/atmel-mci.c
+++ b/drivers/mmc/host/atmel-mci.c
@@ -1544,14 +1544,14 @@ static void __exit atmci_cleanup_slot(struct atmel_mci_slot *slot,
 }
 
 #ifdef CONFIG_MMC_ATMELMCI_DMA
-static enum dma_state_client filter(struct dma_chan *chan, void *slave)
+static bool filter(struct dma_chan *chan, void *slave)
 {
 	struct dw_dma_slave *dws = slave;
 
 	if (dws->dma_dev == chan->device->dev)
-		return DMA_ACK;
+		return true;
 	else
-		return DMA_DUP;
+		return false;
 }
 #endif
 
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index 32edaf4..48112cb 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -43,18 +43,6 @@ enum dma_state {
 };
 
 /**
- * enum dma_state_client - state of the channel in the client
- * @DMA_ACK: client would like to use, or was using this channel
- * @DMA_DUP: client has already seen this channel, or is not using this channel
- * @DMA_NAK: client does not want to see any more channels
- */
-enum dma_state_client {
-	DMA_ACK,
-	DMA_DUP,
-	DMA_NAK,
-};
-
-/**
  * typedef dma_cookie_t - an opaque DMA cookie
  *
  * if dma_cookie_t is >0 it's a DMA request cookie, <0 it's an error code
@@ -174,9 +162,10 @@ void dma_chan_cleanup(struct kref *kref);
  * When this optional parameter is specified in a call to dma_request_channel a
  * suitable channel is passed to this routine for further dispositioning before
  * being returned.  Where 'suitable' indicates a non-busy channel that
- * satisfies the given capability mask.
+ * satisfies the given capability mask.  It returns 'true' to indicate that the
+ * channel is suitable.
  */
-typedef enum dma_state_client (*dma_filter_fn)(struct dma_chan *chan, void *filter_param);
+typedef bool (*dma_filter_fn)(struct dma_chan *chan, void *filter_param);
 
 typedef void (*dma_async_tx_callback)(void *dma_async_param);
 /**

