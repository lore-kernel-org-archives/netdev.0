From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH 2/9] drivers/dma: handle sysfs errors
Date: Fri, 02 Mar 2007 18:24:19 -0800
Message-ID: <20070303022419.31033.57887.stgit@gitlost.site>
References: <20070303022238.31033.84558.stgit@gitlost.site>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1465 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S2992911AbXCCCjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 21:39:12 -0500
In-Reply-To: <20070303022238.31033.84558.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>

Signed-off-by: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Chris Leech <christopher.leech@intel.com>
---

 drivers/dma/dmaengine.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index 1527804..dc65773 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -312,7 +312,7 @@ void dma_async_client_chan_request(struct dma_client *client,
 int dma_async_device_register(struct dma_device *device)
 {
 	static int id;
-	int chancnt = 0;
+	int chancnt = 0, rc;
 	struct dma_chan* chan;
 
 	if (!device)
@@ -334,8 +334,15 @@ int dma_async_device_register(struct dma_device *device)
 		snprintf(chan->class_dev.class_id, BUS_ID_SIZE, "dma%dchan%d",
 		         device->dev_id, chan->chan_id);
 
+		rc = class_device_register(&chan->class_dev);
+		if (rc) {
+			chancnt--;
+			free_percpu(chan->local);
+			chan->local = NULL;
+			goto err_out;
+		}
+
 		kref_get(&device->refcount);
-		class_device_register(&chan->class_dev);
 	}
 
 	mutex_lock(&dma_list_mutex);
@@ -345,6 +352,17 @@ int dma_async_device_register(struct dma_device *device)
 	dma_chans_rebalance();
 
 	return 0;
+
+err_out:
+	list_for_each_entry(chan, &device->channels, device_node) {
+		if (chan->local == NULL)
+			continue;
+		kref_put(&device->refcount, dma_async_device_cleanup);
+		class_device_unregister(&chan->class_dev);
+		chancnt--;
+		free_percpu(chan->local);
+	}
+	return rc;
 }
 
 /**

