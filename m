From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 06/14] net/mlx4_en: Use prefetch in tx path
Date: Sun,  5 Oct 2014 12:35:14 +0300
Message-ID: <1412501722-25092-7-git-send-email-amirv@mellanox.com>
References: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52667 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751221AbaJEJfi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Oct 2014 05:35:38 -0400
In-Reply-To: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

mlx4_en_free_tx_desc() uses a prefetchw(&skb->users) to speed up
consume_skb()
prefetchw(&ring->tx_queue->dql) to speed up BQL update

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index edc4a88..b96627c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -37,6 +37,7 @@
 #include <linux/mlx4/qp.h>
 #include <linux/skbuff.h>
 #include <linux/if_vlan.h>
+#include <linux/prefetch.h>
 #include <linux/vmalloc.h>
 #include <linux/tcp.h>
 #include <linux/ip.h>
@@ -267,6 +268,11 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 	int nr_maps = tx_info->nr_maps;
 	int i;
 
+	/* We do not touch skb here, so prefetch skb->users location
+	 * to speedup consume_skb()
+	 */
+	prefetchw(&skb->users);
+
 	if (unlikely(timestamp)) {
 		struct skb_shared_hwtstamps hwts;
 
@@ -385,6 +391,7 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 	if (!priv->port_up)
 		return true;
 
+	prefetchw(&ring->tx_queue->dql.limit);
 	index = cons_index & size_mask;
 	cqe = mlx4_en_get_cqe(buf, index, priv->cqe_size) + factor;
 	ring_index = ring->cons & size_mask;
@@ -722,6 +729,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
+	prefetchw(&ring->tx_queue->dql);
+
 	/* Track current inflight packets for performance analysis */
 	AVG_PERF_COUNTER(priv->pstats.inflight_avg,
 			 (u32) (ring->prod - ring->cons - 1));
-- 
1.8.3.4
