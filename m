From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 10/10] skbuff: remove skb_dma_map/unmap
Date: Wed, 02 Dec 2009 18:49:02 -0800
Message-ID: <20091203024901.2232.80292.stgit@localhost.localdomain>
References: <20091203024519.2232.6084.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:44823
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755454AbZLCCtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 21:49:13 -0500
In-Reply-To: <20091203024519.2232.6084.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The two functions skb_dma_map/unmap are unsafe to use as they cause
problems when packets are cloned and sent to multiple devices while a HW
IOMMU is enabled.  Due to this it is best to remove the code so it is not
used by any other network driver maintainters.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/skbuff.h |    8 ------
 net/core/Makefile      |    1 -
 net/core/skb_dma_map.c |   65 ------------------------------------------------
 3 files changed, 0 insertions(+), 74 deletions(-)
 delete mode 100644 net/core/skb_dma_map.c

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 89eed8c..ae836fd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -416,14 +416,6 @@ struct sk_buff {
 
 #include <asm/system.h>
 
-#ifdef CONFIG_HAS_DMA
-#include <linux/dma-mapping.h>
-extern int skb_dma_map(struct device *dev, struct sk_buff *skb,
-		       enum dma_data_direction dir);
-extern void skb_dma_unmap(struct device *dev, struct sk_buff *skb,
-			  enum dma_data_direction dir);
-#endif
-
 static inline struct dst_entry *skb_dst(const struct sk_buff *skb)
 {
 	return (struct dst_entry *)skb->_skb_dst;
diff --git a/net/core/Makefile b/net/core/Makefile
index 796f46e..08791ac 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -6,7 +6,6 @@ obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
 	 gen_stats.o gen_estimator.o net_namespace.o
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
-obj-$(CONFIG_HAS_DMA) += skb_dma_map.o
 
 obj-y		     += dev.o ethtool.o dev_mcast.o dst.o netevent.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o
diff --git a/net/core/skb_dma_map.c b/net/core/skb_dma_map.c
deleted file mode 100644
index 79687df..0000000
--- a/net/core/skb_dma_map.c
+++ /dev/null
@@ -1,65 +0,0 @@
-/* skb_dma_map.c: DMA mapping helpers for socket buffers.
- *
- * Copyright (C) David S. Miller <davem@davemloft.net>
- */
-
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/dma-mapping.h>
-#include <linux/skbuff.h>
-
-int skb_dma_map(struct device *dev, struct sk_buff *skb,
-		enum dma_data_direction dir)
-{
-	struct skb_shared_info *sp = skb_shinfo(skb);
-	dma_addr_t map;
-	int i;
-
-	map = dma_map_single(dev, skb->data,
-			     skb_headlen(skb), dir);
-	if (dma_mapping_error(dev, map))
-		goto out_err;
-
-	sp->dma_head = map;
-	for (i = 0; i < sp->nr_frags; i++) {
-		skb_frag_t *fp = &sp->frags[i];
-
-		map = dma_map_page(dev, fp->page, fp->page_offset,
-				   fp->size, dir);
-		if (dma_mapping_error(dev, map))
-			goto unwind;
-		sp->dma_maps[i] = map;
-	}
-
-	return 0;
-
-unwind:
-	while (--i >= 0) {
-		skb_frag_t *fp = &sp->frags[i];
-
-		dma_unmap_page(dev, sp->dma_maps[i],
-			       fp->size, dir);
-	}
-	dma_unmap_single(dev, sp->dma_head,
-			 skb_headlen(skb), dir);
-out_err:
-	return -ENOMEM;
-}
-EXPORT_SYMBOL(skb_dma_map);
-
-void skb_dma_unmap(struct device *dev, struct sk_buff *skb,
-		   enum dma_data_direction dir)
-{
-	struct skb_shared_info *sp = skb_shinfo(skb);
-	int i;
-
-	dma_unmap_single(dev, sp->dma_head,
-			 skb_headlen(skb), dir);
-	for (i = 0; i < sp->nr_frags; i++) {
-		skb_frag_t *fp = &sp->frags[i];
-
-		dma_unmap_page(dev, sp->dma_maps[i],
-			       fp->size, dir);
-	}
-}
-EXPORT_SYMBOL(skb_dma_unmap);

