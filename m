From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH v2 3/4] I/OAT: tcp_dma_copybreak default value dependant on
	I/OAT version
Date: Fri, 18 Jul 2008 17:29:10 +0200
Message-ID: <20080718152838.21235.78883.stgit@linux.site>
References: <20080718152541.21235.85961.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: shannon.nelson@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22435 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751753AbYGRPi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 11:38:59 -0400
In-Reply-To: <20080718152541.21235.85961.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I/OAT DMA performance tuning showed different optimal values 
of tcp_dma_copybreak for different I/OAT versions
(4096 for 1.2 and 2048 for 2.0).
This patch lets ioatdma driver set tcp_dma_copybreak value 
according to these results.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
---

 drivers/dma/ioat_dma.c |   25 +++++++++++++++++++++++++
 net/core/user_dma.c    |    1 +
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat_dma.c
index 2fe3aac..b5ce5be 100644
--- a/drivers/dma/ioat_dma.c
+++ b/drivers/dma/ioat_dma.c
@@ -37,6 +37,10 @@ #include "ioatdma.h"
 #include "ioatdma_registers.h"
 #include "ioatdma_hw.h"
 
+#ifdef CONFIG_NET_DMA
+#include <net/tcp.h>
+#endif
+
 #define to_ioat_chan(chan) container_of(chan, struct ioat_dma_chan, common)
 #define to_ioatdma_device(dev) container_of(dev, struct ioatdma_device, common)
 #define to_ioat_desc(lh) container_of(lh, struct ioat_desc_sw, node)
@@ -53,6 +57,14 @@ #define WATCHDOG_DELAY  round_jiffies(ms
 static void ioat_dma_chan_reset_part2(struct work_struct *work);
 static void ioat_dma_chan_watchdog(struct work_struct *work);
 
+#ifdef CONFIG_NET_DMA
+/*
+ * default tcp_dma_copybreak values for different IOAT versions
+ */
+#define IOAT1_DEFAULT_TCP_DMA_COPYBREAK 4096
+#define IOAT2_DEFAULT_TCP_DMA_COPYBREAK 2048
+#endif
+
 /* internal functions */
 static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat_chan);
 static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan);
@@ -1582,6 +1594,19 @@ struct ioatdma_device *ioat_dma_probe(st
 	if (err)
 		goto err_self_test;
 
+#ifdef CONFIG_NET_DMA
+	switch (device->version) {
+	case IOAT_VER_1_2:
+		sysctl_tcp_dma_copybreak =
+			IOAT1_DEFAULT_TCP_DMA_COPYBREAK;
+		break;
+	case IOAT_VER_2_0:
+		sysctl_tcp_dma_copybreak =
+			IOAT2_DEFAULT_TCP_DMA_COPYBREAK;
+		break;
+	}
+#endif
+
 	dma_async_device_register(&device->common);
 
 	INIT_DELAYED_WORK(&device->work, ioat_dma_chan_watchdog);
diff --git a/net/core/user_dma.c b/net/core/user_dma.c
index c77aff9..8c6b706 100644
--- a/net/core/user_dma.c
+++ b/net/core/user_dma.c
@@ -34,6 +34,7 @@ #include <net/netdma.h>
 #define NET_DMA_DEFAULT_COPYBREAK 4096
 
 int sysctl_tcp_dma_copybreak = NET_DMA_DEFAULT_COPYBREAK;
+EXPORT_SYMBOL(sysctl_tcp_dma_copybreak);
 
 /**
  *	dma_skb_copy_datagram_iovec - Copy a datagram to an iovec.

