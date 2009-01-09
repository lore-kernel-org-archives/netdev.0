From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH] net_dma: acquire/release dma channels on ifup/ifdown
Date: Fri, 09 Jan 2009 16:57:53 -0700
Message-ID: <20090109235752.16379.98359.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maciej.sosnowski@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:27805 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751640AbZAIX5x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:57:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent dmaengine rework removed the capability to remove dma device
driver modules while net_dma is active.  Rather than notify
dmaengine-clients that channels are trying to be removed, we now rely on
clients to notify dmaengine when they no longer have a need for
channels.  Teach net_dma to release channels by taking dmaengine
references at netdevice open and dropping references at netdevice close.

Acked-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/dmaengine.h |   10 ++++++++++
 net/core/dev.c            |   13 ++++++++++---
 2 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index 64dea2a..c73f1e2 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -270,8 +270,18 @@ struct dma_device {
 
 /* --- public DMA engine API --- */
 
+#ifdef CONFIG_DMA_ENGINE
 void dmaengine_get(void);
 void dmaengine_put(void);
+#else
+static inline void dmaengine_get(void)
+{
+}
+static inline void dmaengine_put(void)
+{
+}
+#endif
+
 dma_cookie_t dma_async_memcpy_buf_to_buf(struct dma_chan *chan,
 	void *dest, void *src, size_t len);
 dma_cookie_t dma_async_memcpy_buf_to_pg(struct dma_chan *chan,
diff --git a/net/core/dev.c b/net/core/dev.c
index 5f736f1..b715a55 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1088,6 +1088,11 @@ int dev_open(struct net_device *dev)
 		dev->flags |= IFF_UP;
 
 		/*
+		 *	Enable NET_DMA
+		 */
+		dmaengine_get();
+
+		/*
 		 *	Initialize multicasting status
 		 */
 		dev_set_rx_mode(dev);
@@ -1164,6 +1169,11 @@ int dev_close(struct net_device *dev)
 	 */
 	call_netdevice_notifiers(NETDEV_DOWN, dev);
 
+	/*
+	 *	Shutdown NET_DMA
+	 */
+	dmaengine_put();
+
 	return 0;
 }
 
@@ -5151,9 +5161,6 @@ static int __init net_dev_init(void)
 	hotcpu_notifier(dev_cpu_callback, 0);
 	dst_init();
 	dev_mcast_init();
-	#ifdef CONFIG_NET_DMA
-	dmaengine_get();
-	#endif
 	rc = 0;
 out:
 	return rc;

