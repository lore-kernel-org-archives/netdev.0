From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 3/3] mlx4_en: Byte Queue Limit support
Date: Mon, 23 Apr 2012 15:18:50 +0300
Message-ID: <4F9548AA.4000100@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:38716 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753937Ab2DWMTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 08:19:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    4 ++++
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |   15 +++++++++++----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    2 ++
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 35ad097..eaa8fad 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -667,6 +667,7 @@ int mlx4_en_start_port(struct net_device *dev)
 			mlx4_en_deactivate_cq(priv, cq);
 			goto tx_err;
 		}
+		tx_ring->tx_queue = netdev_get_tx_queue(dev, i);
 
 		/* Arm CQ for TX completions */
 		mlx4_en_arm_cq(priv, cq);
@@ -812,12 +813,15 @@ static void mlx4_en_restart(struct work_struct *work)
 						 watchdog_task);
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct net_device *dev = priv->dev;
+	int i;
 
 	en_dbg(DRV, priv, "Watchdog task called for port %d\n", priv->port);
 
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		mlx4_en_stop_port(dev);
+		for (i = 0; i < priv->tx_ring_num; i++)
+			netdev_tx_reset_queue(priv->tx_ring[i].tx_queue);
 		if (mlx4_en_start_port(dev))
 			en_err(priv, "Failed restarting port %d\n", priv->port);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 2d49342..9a38483 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -315,6 +315,8 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 	int size = cq->size;
 	u32 size_mask = ring->size_mask;
 	struct mlx4_cqe *buf = cq->buf;
+	u32 packets = 0;
+	u32 bytes = 0;
 
 	if (!priv->port_up)
 		return;
@@ -343,6 +345,8 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 					priv, ring, ring_index,
 					!!((ring->cons + txbbs_skipped) &
 							ring->size));
+			packets++;
+			bytes += ring->tx_info[ring_index].nr_bytes;
 		} while (ring_index != new_index);
 
 		++cons_index;
@@ -359,13 +363,14 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 	mlx4_cq_set_ci(mcq);
 	wmb();
 	ring->cons += txbbs_skipped;
+	netdev_tx_completed_queue(ring->tx_queue, packets, bytes);
 
 	/* Wakeup Tx queue if this ring stopped it */
 	if (unlikely(ring->blocked)) {
 		if ((u32) (ring->prod - ring->cons) <=
 		     ring->size - HEADROOM - MAX_DESC_TXBBS) {
 			ring->blocked = 0;
-			netif_tx_wake_queue(netdev_get_tx_queue(dev, cq->ring));
+			netif_tx_wake_queue(ring->tx_queue);
 			priv->port_stats.wake_queue++;
 		}
 	}
@@ -583,7 +588,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(((int)(ring->prod - ring->cons)) >
 		     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
 		/* every full Tx ring stops queue */
-		netif_tx_stop_queue(netdev_get_tx_queue(dev, tx_ind));
+		netif_tx_stop_queue(ring->tx_queue);
 		ring->blocked = 1;
 		priv->port_stats.queue_stopped++;
 
@@ -649,7 +654,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		priv->port_stats.tso_packets++;
 		i = ((skb->len - lso_header_size) / skb_shinfo(skb)->gso_size) +
 			!!((skb->len - lso_header_size) % skb_shinfo(skb)->gso_size);
-		ring->bytes += skb->len + (i - 1) * lso_header_size;
+		tx_info->nr_bytes = skb->len + (i - 1) * lso_header_size;
 		ring->packets += i;
 	} else {
 		/* Normal (Non LSO) packet */
@@ -657,10 +662,12 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 			((ring->prod & ring->size) ?
 			 cpu_to_be32(MLX4_EN_BIT_DESC_OWN) : 0);
 		data = &tx_desc->data;
-		ring->bytes += max(skb->len, (unsigned int) ETH_ZLEN);
+		tx_info->nr_bytes = max_t(unsigned int, skb->len, ETH_ZLEN);
 		ring->packets++;
 
 	}
+	ring->bytes += tx_info->nr_bytes;
+	netdev_tx_sent_queue(ring->tx_queue, tx_info->nr_bytes);
 	AVG_PERF_COUNTER(priv->pstats.tx_pktsz_avg, skb->len);
 
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index ed8bdd9..14a18c6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -199,6 +199,7 @@ enum cq_type {
 struct mlx4_en_tx_info {
 	struct sk_buff *skb;
 	u32 nr_txbb;
+	u32 nr_bytes;
 	u8 linear;
 	u8 data_offset;
 	u8 inl;
@@ -256,6 +257,7 @@ struct mlx4_en_tx_ring {
 	unsigned long tx_csum;
 	struct mlx4_bf bf;
 	bool bf_enabled;
+	struct netdev_queue *tx_queue;
 };
 
 struct mlx4_en_rx_desc {
-- 
1.7.7
