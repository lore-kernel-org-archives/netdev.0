From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 4/4] net/mlx4_en: get rid of private net_device_stats
Date: Wed, 25 May 2016 09:50:39 -0700
Message-ID: <1464195039-5098-5-git-send-email-edumazet@google.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36010 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755927AbcEYQuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 12:50:55 -0400
Received: by mail-pf0-f180.google.com with SMTP id f144so6930808pfa.3
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 09:50:55 -0700 (PDT)
In-Reply-To: <1464195039-5098-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We simply can use the standard net_device stats.

We do not need to clear fields that are already 0.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Eugenia Emantayev <eugenia@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  3 +--
 drivers/net/ethernet/mellanox/mlx4/en_port.c    | 14 +++-----------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  1 -
 4 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index c761194bb323..fc95affaf76b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -362,7 +362,7 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 
 	for (i = 0; i < NUM_MAIN_STATS; i++, bitmap_iterator_inc(&it))
 		if (bitmap_iterator_test(&it))
-			data[index++] = ((unsigned long *)&priv->stats)[i];
+			data[index++] = ((unsigned long *)&dev->stats)[i];
 
 	for (i = 0; i < NUM_PORT_STATS; i++, bitmap_iterator_inc(&it))
 		if (bitmap_iterator_test(&it))
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index a4fc6e966505..19ceced6736c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1302,7 +1302,7 @@ mlx4_en_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
 	spin_lock_bh(&priv->stats_lock);
-	netdev_stats_to_stats64(stats, &priv->stats);
+	netdev_stats_to_stats64(stats, &dev->stats);
 	spin_unlock_bh(&priv->stats_lock);
 
 	return stats;
@@ -1877,7 +1877,6 @@ static void mlx4_en_clear_stats(struct net_device *dev)
 	if (mlx4_en_DUMP_ETH_STATS(mdev, priv->port, 1))
 		en_dbg(HW, priv, "Failed dumping statistics\n");
 
-	memset(&priv->stats, 0, sizeof(priv->stats));
 	memset(&priv->pstats, 0, sizeof(priv->pstats));
 	memset(&priv->pkstats, 0, sizeof(priv->pkstats));
 	memset(&priv->port_stats, 0, sizeof(priv->port_stats));
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 3df8690154b1..5aa8b751f417 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -152,8 +152,9 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	struct mlx4_counter tmp_counter_stats;
 	struct mlx4_en_stat_out_mbox *mlx4_en_stats;
 	struct mlx4_en_stat_out_flow_control_mbox *flowstats;
-	struct mlx4_en_priv *priv = netdev_priv(mdev->pndev[port]);
-	struct net_device_stats *stats = &priv->stats;
+	struct net_device *dev = mdev->pndev[port];
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
 	struct mlx4_cmd_mailbox *mailbox;
 	u64 in_mod = reset << 8 | port;
 	int err;
@@ -239,20 +240,11 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	stats->multicast = en_stats_adder(&mlx4_en_stats->MCAST_prio_0,
 					  &mlx4_en_stats->MCAST_prio_1,
 					  NUM_PRIORITIES);
-	stats->collisions = 0;
 	stats->rx_dropped = be32_to_cpu(mlx4_en_stats->RDROP) +
 			    sw_rx_dropped;
 	stats->rx_length_errors = be32_to_cpu(mlx4_en_stats->RdropLength);
-	stats->rx_over_errors = 0;
 	stats->rx_crc_errors = be32_to_cpu(mlx4_en_stats->RCRC);
-	stats->rx_frame_errors = 0;
 	stats->rx_fifo_errors = be32_to_cpu(mlx4_en_stats->RdropOvflw);
-	stats->rx_missed_errors = 0;
-	stats->tx_aborted_errors = 0;
-	stats->tx_carrier_errors = 0;
-	stats->tx_fifo_errors = 0;
-	stats->tx_heartbeat_errors = 0;
-	stats->tx_window_errors = 0;
 	stats->tx_dropped += be32_to_cpu(mlx4_en_stats->TDROP);
 
 	/* RX stats */
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index bfda84df8aae..467d47ed2c39 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -483,7 +483,6 @@ struct mlx4_en_priv {
 	struct mlx4_en_port_profile *prof;
 	struct net_device *dev;
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
-	struct net_device_stats stats;
 	struct mlx4_en_port_state port_state;
 	spinlock_t stats_lock;
 	struct ethtool_flow_id ethtool_rules[MAX_NUM_OF_FS_RULES];
-- 
2.8.0.rc3.226.g39d4020
