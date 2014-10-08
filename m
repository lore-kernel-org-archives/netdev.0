From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: add
 netdev_txq_bql_{enqueue,complete}_prefetchw() helpers
Date: Wed, 08 Oct 2014 08:19:27 -0700
Message-ID: <1412781567.11091.182.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+r1ZhiU6uzE-CQcTJoH2JxrS06H+5Paaofz+3Ugzon02mxD8Q@mail.gmail.com>
	 <1412779746.11091.176.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>, amirv@mellanox.com,
	netdev <netdev@vger.kernel.org>
To: Jim Davis <jim.epost@gmail.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:43759 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503AbaJHPT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 11:19:29 -0400
In-Reply-To: <1412779746.11091.176.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Add two helpers so that drivers do not have to care of BQL being
available or not.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Jim Davis <jim.epost@gmail.com>
Fixes: 29d40c903247 ("net/mlx4_en: Use prefetch in tx path")
---
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 8726a4aee5a7..34c137878545 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -392,7 +392,8 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 	if (!priv->port_up)
 		return true;
 
-	prefetchw(&ring->tx_queue->dql.limit);
+	netdev_txq_bql_complete_prefetchw(ring->tx_queue);
+
 	index = cons_index & size_mask;
 	cqe = mlx4_en_get_cqe(buf, index, priv->cqe_size) + factor;
 	last_nr_txbb = ACCESS_ONCE(ring->last_nr_txbb);
@@ -737,7 +738,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		vlan_tag = vlan_tx_tag_get(skb);
 
 
-	prefetchw(&ring->tx_queue->dql);
+	netdev_txq_bql_enqueue_prefetchw(ring->tx_queue);
 
 	/* Track current inflight packets for performance analysis */
 	AVG_PERF_COUNTER(priv->pstats.inflight_avg,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3a4315b39d20..afc0a9194de6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -30,6 +30,7 @@
 #include <linux/bug.h>
 #include <linux/delay.h>
 #include <linux/atomic.h>
+#include <linux/prefetch.h>
 #include <asm/cache.h>
 #include <asm/byteorder.h>
 
@@ -2480,6 +2481,34 @@ netif_xmit_frozen_or_drv_stopped(const struct netdev_queue *dev_queue)
 	return dev_queue->state & QUEUE_STATE_DRV_XOFF_OR_FROZEN;
 }
 
+/**
+ *	netdev_txq_bql_enqueue_prefetchw - prefetch bql data for write
+ *	@dev_queue: pointer to transmit queue
+ *
+ * BQL enabled drivers might use this helper in their ndo_start_xmit(),
+ * to give appropriate hint to the cpu.
+ */
+static inline void netdev_txq_bql_enqueue_prefetchw(struct netdev_queue *dev_queue)
+{
+#ifdef CONFIG_BQL
+	prefetchw(&dev_queue->dql.num_queued);
+#endif
+}
+
+/**
+ *	netdev_txq_bql_complete_prefetchw - prefetch bql data for write
+ *	@dev_queue: pointer to transmit queue
+ *
+ * BQL enabled drivers might use this helper in their TX completion path,
+ * to give appropriate hint to the cpu.
+ */
+static inline void netdev_txq_bql_complete_prefetchw(struct netdev_queue *dev_queue)
+{
+#ifdef CONFIG_BQL
+	prefetchw(&dev_queue->dql.limit);
+#endif
+}
+
 static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
 					unsigned int bytes)
 {
