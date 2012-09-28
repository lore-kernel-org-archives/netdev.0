From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next 2/3] net: add gro_cells infrastructure
Date: Fri, 28 Sep 2012 07:29:05 +0200
Message-ID: <1348810145.5093.1887.camel@edumazet-glaptop>
References: <1348750077.5093.1224.camel@edumazet-glaptop>
	 <1348788457.10741.39.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:44578 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab2I1F3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 01:29:10 -0400
Received: by weyt9 with SMTP id t9so1067868wey.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 22:29:09 -0700 (PDT)
In-Reply-To: <1348788457.10741.39.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This adds a new include file (include/net/gro_cells.h), to bring GRO
(Generic Receive Offload) capability to tunnels, in a modular way.

Because tunnels receive path is lockless, and GRO adds a serialization
using a napi_struct, I chose to add an array of up to
DEFAULT_MAX_NUM_RSS_QUEUES cells, so that multi queue devices wont be
slowed down because of GRO layer.

skb_get_rx_queue() is used as selector.

In the future, we might add optional fanout capabilities, using rxhash
for example.

With help from Ben Hutchings who reminded me
netif_get_num_default_rss_queues() function.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
---
v2: change the 8 value by call to netif_get_num_default_rss_queues()
    as Ben pointed out. (Thanks Ben !)

 include/net/gro_cells.h |  103 ++++++++++++++++++++++++++++++++++++++
 net/core/dev.c          |    2 
 2 files changed, 105 insertions(+)

diff --git a/include/net/gro_cells.h b/include/net/gro_cells.h
new file mode 100644
index 0000000..ba93b1b
--- /dev/null
+++ b/include/net/gro_cells.h
@@ -0,0 +1,103 @@
+#ifndef _NET_GRO_CELLS_H
+#define _NET_GRO_CELLS_H
+
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/netdevice.h>
+
+struct gro_cell {
+	struct sk_buff_head	napi_skbs;
+	struct napi_struct	napi;
+} ____cacheline_aligned_in_smp;
+
+struct gro_cells {
+	unsigned int		gro_cells_mask;
+	struct gro_cell		*cells;
+};
+
+static inline void gro_cells_receive(struct gro_cells *gcells, struct sk_buff *skb)
+{
+	unsigned long flags;
+	struct gro_cell *cell = gcells->cells;
+	struct net_device *dev = skb->dev;
+
+	if (!cell || skb_cloned(skb) || !(dev->features & NETIF_F_GRO)) {
+		netif_rx(skb);
+		return;
+	}
+
+	if (skb_rx_queue_recorded(skb))
+		cell += skb_get_rx_queue(skb) & gcells->gro_cells_mask;
+
+	if (skb_queue_len(&cell->napi_skbs) > netdev_max_backlog) {
+		atomic_long_inc(&dev->rx_dropped);
+		kfree_skb(skb);
+		return;
+	}
+
+	spin_lock_irqsave(&cell->napi_skbs.lock, flags);
+
+	__skb_queue_tail(&cell->napi_skbs, skb);
+	if (skb_queue_len(&cell->napi_skbs) == 1)
+		napi_schedule(&cell->napi);
+
+	spin_unlock_irqrestore(&cell->napi_skbs.lock, flags);
+}
+
+static inline int gro_cell_poll(struct napi_struct *napi, int budget)
+{
+	struct gro_cell *cell = container_of(napi, struct gro_cell, napi);
+	struct sk_buff *skb;
+	int work_done = 0;
+
+	while (work_done < budget) {
+		skb = skb_dequeue(&cell->napi_skbs);
+		if (!skb)
+			break;
+
+		napi_gro_receive(napi, skb);
+		work_done++;
+	}
+
+	if (work_done < budget)
+		napi_complete(napi);
+	return work_done;
+}
+
+static inline int gro_cells_init(struct gro_cells *gcells, struct net_device *dev)
+{
+	int i;
+
+	gcells->gro_cells_mask = roundup_pow_of_two(netif_get_num_default_rss_queues()) - 1;
+	gcells->cells = kcalloc(sizeof(struct gro_cell),
+				gcells->gro_cells_mask + 1,
+				GFP_KERNEL);
+	if (!gcells->cells)
+		return -ENOMEM;
+
+	for (i = 0; i <= gcells->gro_cells_mask; i++) {
+		struct gro_cell *cell = gcells->cells + i;
+
+		skb_queue_head_init(&cell->napi_skbs);
+		netif_napi_add(dev, &cell->napi, gro_cell_poll, 64);
+		napi_enable(&cell->napi);
+	}
+	return 0;
+}
+
+static inline void gro_cells_destroy(struct gro_cells *gcells)
+{
+	struct gro_cell *cell = gcells->cells;
+	int i;
+
+	if (!cell)
+		return;
+	for (i = 0; i <= gcells->gro_cells_mask; i++,cell++) {
+		netif_napi_del(&cell->napi);	
+		skb_queue_purge(&cell->napi_skbs);
+	}
+	kfree(gcells->cells);
+	gcells->cells = NULL;
+}
+
+#endif
diff --git a/net/core/dev.c b/net/core/dev.c
index 707b124..9f63660 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2644,6 +2644,8 @@ EXPORT_SYMBOL(dev_queue_xmit);
   =======================================================================*/
 
 int netdev_max_backlog __read_mostly = 1000;
+EXPORT_SYMBOL(netdev_max_backlog);
+
 int netdev_tstamp_prequeue __read_mostly = 1;
 int netdev_budget __read_mostly = 300;
 int weight_p __read_mostly = 64;            /* old backlog weight */
