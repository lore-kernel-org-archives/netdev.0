From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 1/4] net/mlx4_en: fix tx_dropped bug
Date: Wed, 25 May 2016 09:50:36 -0700
Message-ID: <1464195039-5098-2-git-send-email-edumazet@google.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34222 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755900AbcEYQus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 12:50:48 -0400
Received: by mail-pf0-f177.google.com with SMTP id y69so20113612pfb.1
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 09:50:47 -0700 (PDT)
In-Reply-To: <1464195039-5098-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) mlx4_en_xmit() can increment priv->stats.tx_dropped, but this variable
is overwritten in mlx4_en_DUMP_ETH_STATS().

2) This increment was not SMP safe, as a port might have many TX queues.

Add a per TX ring tx_dropped to fix these issues.

This is u32 as mlx4_en_DUMP_ETH_STATS() will add a 32bit field.

So lets avoid bugs with SNMP agents having to cope with partial
overwraps. (One of these agents being bond_fold_stats())

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Willem de Bruijn <willemb@google.com>
Cc: Eugenia Emantayev <eugenia@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 1 +
 drivers/net/ethernet/mellanox/mlx4/en_port.c   | 4 +++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 8 ++++----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   | 1 +
 4 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 92e0624f4cf0..cfd50206f7c3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1892,6 +1892,7 @@ static void mlx4_en_clear_stats(struct net_device *dev)
 		priv->tx_ring[i]->bytes = 0;
 		priv->tx_ring[i]->packets = 0;
 		priv->tx_ring[i]->tx_csum = 0;
+		priv->tx_ring[i]->tx_dropped = 0;
 	}
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		priv->rx_ring[i]->bytes = 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 20b6c2e678b8..3df8690154b1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -188,6 +188,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	}
 	stats->tx_packets = 0;
 	stats->tx_bytes = 0;
+	stats->tx_dropped = 0;
 	priv->port_stats.tx_chksum_offload = 0;
 	priv->port_stats.queue_stopped = 0;
 	priv->port_stats.wake_queue = 0;
@@ -199,6 +200,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 
 		stats->tx_packets += ring->packets;
 		stats->tx_bytes += ring->bytes;
+		stats->tx_dropped += ring->tx_dropped;
 		priv->port_stats.tx_chksum_offload += ring->tx_csum;
 		priv->port_stats.queue_stopped     += ring->queue_stopped;
 		priv->port_stats.wake_queue        += ring->wake_queue;
@@ -251,7 +253,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	stats->tx_fifo_errors = 0;
 	stats->tx_heartbeat_errors = 0;
 	stats->tx_window_errors = 0;
-	stats->tx_dropped = be32_to_cpu(mlx4_en_stats->TDROP);
+	stats->tx_dropped += be32_to_cpu(mlx4_en_stats->TDROP);
 
 	/* RX stats */
 	priv->pkstats.rx_multicast_packets = stats->multicast;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index f6e61570cb2c..76aa4d27183c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -726,12 +726,12 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	bool inline_ok;
 	u32 ring_cons;
 
-	if (!priv->port_up)
-		goto tx_drop;
-
 	tx_ind = skb_get_queue_mapping(skb);
 	ring = priv->tx_ring[tx_ind];
 
+	if (!priv->port_up)
+		goto tx_drop;
+
 	/* fetch ring->cons far ahead before needing it to avoid stall */
 	ring_cons = ACCESS_ONCE(ring->cons);
 
@@ -1030,7 +1030,7 @@ tx_drop_unmap:
 
 tx_drop:
 	dev_kfree_skb_any(skb);
-	priv->stats.tx_dropped++;
+	ring->tx_dropped++;
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index cc84e09f324a..9a9124031fc7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -270,6 +270,7 @@ struct mlx4_en_tx_ring {
 	unsigned long		tx_csum;
 	unsigned long		tso_packets;
 	unsigned long		xmit_more;
+	unsigned int		tx_dropped;
 	struct mlx4_bf		bf;
 	unsigned long		queue_stopped;
 
-- 
2.8.0.rc3.226.g39d4020
