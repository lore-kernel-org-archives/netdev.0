From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/3]: net: Add SKB DMA mapping helper functions.
Date: Thu, 11 Sep 2008 05:03:09 -0700 (PDT)
Message-ID: <20080911.050309.26316918.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56517
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752627AbYIKMDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 08:03:16 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id EE56FC8C181
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 05:03:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net: Add SKB DMA mapping helper functions.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |    8 ++++++
 net/core/Makefile      |    1 +
 net/core/skb_dma_map.c |   66 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 75 insertions(+), 0 deletions(-)
 create mode 100644 net/core/skb_dma_map.c

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4b2be23..aa80ad9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -359,6 +359,14 @@ struct sk_buff {
 
 #include <asm/system.h>
 
+#ifdef CONFIG_HAS_DMA
+#include <linux/dma-mapping.h>
+extern int skb_dma_map(struct device *dev, struct sk_buff *skb,
+		       enum dma_data_direction dir);
+extern void skb_dma_unmap(struct device *dev, struct sk_buff *skb,
+			  enum dma_data_direction dir);
+#endif
+
 extern void kfree_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
diff --git a/net/core/Makefile b/net/core/Makefile
index b1332f6..26a37cb 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -6,6 +6,7 @@ obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
 	 gen_stats.o gen_estimator.o net_namespace.o
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
+obj-$(CONFIG_HAS_DMA) += skb_dma_map.o
 
 obj-y		     += dev.o ethtool.o dev_mcast.o dst.o netevent.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o
diff --git a/net/core/skb_dma_map.c b/net/core/skb_dma_map.c
new file mode 100644
index 0000000..1f49afc
--- /dev/null
+++ b/net/core/skb_dma_map.c
@@ -0,0 +1,66 @@
+/* skb_dma_map.c: DMA mapping helpers for socket buffers.
+ *
+ * Copyright (C) David S. Miller <davem@davemloft.net>
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/dma-mapping.h>
+#include <linux/skbuff.h>
+
+int skb_dma_map(struct device *dev, struct sk_buff *skb,
+		enum dma_data_direction dir)
+{
+	struct skb_shared_info *sp = skb_shinfo(skb);
+	dma_addr_t map;
+	int i;
+
+	map = dma_map_single(dev, skb->data,
+			     skb_headlen(skb), dir);
+	if (dma_mapping_error(dev, map))
+		goto out_err;
+
+	sp->dma_maps[0] = map;
+	for (i = 0; i < sp->nr_frags; i++) {
+		skb_frag_t *fp = &sp->frags[i];
+
+		map = dma_map_page(dev, fp->page, fp->page_offset,
+				   fp->size, dir);
+		if (dma_mapping_error(dev, map))
+			goto unwind;
+		sp->dma_maps[i + 1] = map;
+	}
+	sp->num_dma_maps = i + 1;
+
+	return 0;
+
+unwind:
+	while (i-- >= 0) {
+		skb_frag_t *fp = &sp->frags[i];
+
+		dma_unmap_page(dev, sp->dma_maps[i + 1],
+			       fp->size, dir);
+	}
+	dma_unmap_single(dev, sp->dma_maps[0],
+			 skb_headlen(skb), dir);
+out_err:
+	return -ENOMEM;
+}
+EXPORT_SYMBOL(skb_dma_map);
+
+void skb_dma_unmap(struct device *dev, struct sk_buff *skb,
+		   enum dma_data_direction dir)
+{
+	struct skb_shared_info *sp = skb_shinfo(skb);
+	int i;
+
+	dma_unmap_single(dev, sp->dma_maps[0],
+			 skb_headlen(skb), dir);
+	for (i = 0; i < sp->nr_frags; i++) {
+		skb_frag_t *fp = &sp->frags[i];
+
+		dma_unmap_page(dev, sp->dma_maps[i + 1],
+			       fp->size, dir);
+	}
+}
+EXPORT_SYMBOL(skb_dma_unmap);
-- 
1.5.6.5.GIT

