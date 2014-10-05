From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 08/14] net/mlx4_en: mlx4_en_xmit() reads ring->cons once, and ahead of time to avoid stalls
Date: Sun,  5 Oct 2014 12:35:16 +0300
Message-ID: <1412501722-25092-9-git-send-email-amirv@mellanox.com>
References: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52731 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751637AbaJEJgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Oct 2014 05:36:11 -0400
In-Reply-To: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index d9aaeb2..99875c8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -691,10 +691,17 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	void *fragptr;
 	bool bounce = false;
 	bool send_doorbell;
+	u32 ring_cons;
 
 	if (!priv->port_up)
 		goto tx_drop;
 
+	tx_ind = skb_get_queue_mapping(skb);
+	ring = priv->tx_ring[tx_ind];
+
+	/* fetch ring->cons far ahead before needing it to avoid stall */
+	ring_cons = ACCESS_ONCE(ring->cons);
+
 	real_size = get_real_size(skb, dev, &lso_header_size);
 	if (unlikely(!real_size))
 		goto tx_drop;
@@ -708,13 +715,11 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto tx_drop;
 	}
 
-	tx_ind = skb->queue_mapping;
-	ring = priv->tx_ring[tx_ind];
 	if (vlan_tx_tag_present(skb))
 		vlan_tag = vlan_tx_tag_get(skb);
 
 	/* Check available TXBBs And 2K spare for prefetch */
-	if (unlikely(((int)(ring->prod - ring->cons)) >
+	if (unlikely(((int)(ring->prod - ring_cons)) >
 		     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
 		/* every full Tx ring stops queue */
 		netif_tx_stop_queue(ring->tx_queue);
@@ -728,7 +733,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		 */
 		wmb();
 
-		if (unlikely(((int)(ring->prod - ring->cons)) <=
+		ring_cons = ACCESS_ONCE(ring->cons);
+		if (unlikely(((int)(ring->prod - ring_cons)) <=
 			     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
 			netif_tx_wake_queue(ring->tx_queue);
 			ring->wake_queue++;
@@ -741,7 +747,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Track current inflight packets for performance analysis */
 	AVG_PERF_COUNTER(priv->pstats.inflight_avg,
-			 (u32) (ring->prod - ring->cons - 1));
+			 (u32)(ring->prod - ring_cons - 1));
 
 	/* Packet is good - grab an index and transmit it */
 	index = ring->prod & ring->size_mask;
-- 
1.8.3.4
