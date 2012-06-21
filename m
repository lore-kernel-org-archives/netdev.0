From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 4/4] net/mlx4_en: Use atomic counter to decide when queue is full
Date: Thu, 21 Jun 2012 12:19:17 +0300
Message-ID: <1340270358-19504-5-git-send-email-yevgenyp@mellanox.co.il>
References: <1340270358-19504-1-git-send-email-yevgenyp@mellanox.co.il>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:54121 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932375Ab2FUJTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 05:19:42 -0400
In-Reply-To: <1340270358-19504-1-git-send-email-yevgenyp@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Transmit and transmit completion flows execute from different contexts,
which are not synchronized. Hence naive reading the of consumer index might
give wrong value by the time it is being used, That could lead to a state of transmit timeout.
Fix that by using atomic variable to maintain that index.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   |   16 ++++++++--------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    1 +
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 019d856..f4b4703 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -165,6 +165,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 	ring->last_nr_txbb = 1;
 	ring->poll_cnt = 0;
 	ring->blocked = 0;
+	atomic_set(&ring->inflight, 0);
 	memset(ring->tx_info, 0, ring->size * sizeof(struct mlx4_en_tx_info));
 	memset(ring->buf, 0, ring->buf_size);
 
@@ -364,15 +365,13 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 	wmb();
 	ring->cons += txbbs_skipped;
 	netdev_tx_completed_queue(ring->tx_queue, packets, bytes);
+	atomic_sub(txbbs_skipped, &ring->inflight);
 
 	/* Wakeup Tx queue if this ring stopped it */
-	if (unlikely(ring->blocked)) {
-		if ((u32) (ring->prod - ring->cons) <=
-		     ring->size - HEADROOM - MAX_DESC_TXBBS) {
-			ring->blocked = 0;
-			netif_tx_wake_queue(ring->tx_queue);
-			priv->port_stats.wake_queue++;
-		}
+	if (unlikely(ring->blocked && txbbs_skipped > 0)) {
+		ring->blocked = 0;
+		netif_tx_wake_queue(ring->tx_queue);
+		priv->port_stats.wake_queue++;
 	}
 }
 
@@ -588,7 +587,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		vlan_tag = vlan_tx_tag_get(skb);
 
 	/* Check available TXBBs And 2K spare for prefetch */
-	if (unlikely(((int)(ring->prod - ring->cons)) >
+	if (unlikely(atomic_read(&ring->inflight) >
 		     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
 		/* every full Tx ring stops queue */
 		netif_tx_stop_queue(ring->tx_queue);
@@ -710,6 +709,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	ring->prod += nr_txbb;
+	atomic_add(nr_txbb, &ring->inflight);
 
 	/* If we used a bounce buffer then copy descriptor back into place */
 	if (bounce)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 225c20d..6a8a69d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -257,6 +257,7 @@ struct mlx4_en_tx_ring {
 	struct mlx4_bf bf;
 	bool bf_enabled;
 	struct netdev_queue *tx_queue;
+	atomic_t inflight;
 };
 
 struct mlx4_en_rx_desc {
-- 
1.7.1
