From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 4/9] net/mlx4_en: Move queue stopped/waked counters to be per ring
Date: Fri, 28 Feb 2014 08:00:04 +0200
Message-ID: <1393567209-16358-5-git-send-email-amirv@mellanox.com>
References: <1393567209-16358-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43017 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750942AbaB1GA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 01:00:26 -0500
In-Reply-To: <1393567209-16358-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Give accurate counters and avoids cache misses when several rings
update the counters of stop/wake queue.


Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_port.c | 6 ++++++
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   | 6 +++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h | 2 ++
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index dae1a1f..c2cfb05 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -148,10 +148,16 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	stats->tx_packets = 0;
 	stats->tx_bytes = 0;
 	priv->port_stats.tx_chksum_offload = 0;
+	priv->port_stats.queue_stopped = 0;
+	priv->port_stats.wake_queue = 0;
+
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		stats->tx_packets += priv->tx_ring[i]->packets;
 		stats->tx_bytes += priv->tx_ring[i]->bytes;
 		priv->port_stats.tx_chksum_offload += priv->tx_ring[i]->tx_csum;
+		priv->port_stats.queue_stopped +=
+			priv->tx_ring[i]->queue_stopped;
+		priv->port_stats.wake_queue += priv->tx_ring[i]->wake_queue;
 	}
 
 	stats->rx_errors = be64_to_cpu(mlx4_en_stats->PCS) +
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 781ebca..56e8fbc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -445,7 +445,7 @@ static int mlx4_en_process_tx_cq(struct net_device *dev,
 	 */
 	if (netif_tx_queue_stopped(ring->tx_queue) && txbbs_skipped > 0) {
 		netif_tx_wake_queue(ring->tx_queue);
-		priv->port_stats.wake_queue++;
+		ring->wake_queue++;
 	}
 	return done;
 }
@@ -691,7 +691,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
 		/* every full Tx ring stops queue */
 		netif_tx_stop_queue(ring->tx_queue);
-		priv->port_stats.queue_stopped++;
+		ring->queue_stopped++;
 
 		/* If queue was emptied after the if, and before the
 		 * stop_queue - need to wake the queue, or else it will remain
@@ -704,7 +704,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (unlikely(((int)(ring->prod - ring->cons)) <=
 			     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
 			netif_tx_wake_queue(ring->tx_queue);
-			priv->port_stats.wake_queue++;
+			ring->wake_queue++;
 		} else {
 			return NETDEV_TX_BUSY;
 		}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 2610cc5..c59011d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -274,6 +274,8 @@ struct mlx4_en_tx_ring {
 	unsigned long bytes;
 	unsigned long packets;
 	unsigned long tx_csum;
+	unsigned long queue_stopped;
+	unsigned long wake_queue;
 	struct mlx4_bf bf;
 	bool bf_enabled;
 	struct netdev_queue *tx_queue;
-- 
1.8.3.4
