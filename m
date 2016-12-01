From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression: [PATCH] mlx4: give precise rx/tx bytes/packets
 counters
Date: Thu, 01 Dec 2016 08:08:37 -0800
Message-ID: <1480608517.18162.313.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161130150839.5203ece0@redhat.com>
         <1480521514.18162.191.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8pcuNo4uD3+dVms1gHT9=WfZAM1DDp_J10NgBZ7YZnEA@mail.gmail.com>
         <1480527321.18162.196.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG_aT1O1ergGRu8Z0u4nszKYao5RbPfb=1USptwFY1d7PQ@mail.gmail.com>
         <1480539652.18162.205.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8O28ZBS3sdqLpohPZtpLbLs228K4aO6hYd4URsA3yefA@mail.gmail.com>
         <1480607729.18162.311.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34635 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932655AbcLAQJm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:09:42 -0500
Received: by mail-pg0-f65.google.com with SMTP id e9so5007248pgc.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 08:09:42 -0800 (PST)
In-Reply-To: <1480607729.18162.311.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-01 at 07:55 -0800, Eric Dumazet wrote:

> So removing the spinlock is doable, but needs to add a new parameter
> to mlx4_en_fold_software_stats() and call netdev_stats_to_stats64()
> before mlx4_en_fold_software_stats(dev)

Untested patch would be :

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    2 -
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |   10 +----
 drivers/net/ethernet/mellanox/mlx4/en_port.c    |   24 +++++++++-----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    3 +
 4 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index d9c9f86a30df953fa555934c5406057dcaf28960..676050e352703cebe7fcaa5202a06496f7a5a0df 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -367,7 +367,7 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 
 	spin_lock_bh(&priv->stats_lock);
 
-	mlx4_en_fold_software_stats(dev);
+	mlx4_en_fold_software_stats(dev, NULL);
 
 	for (i = 0; i < NUM_MAIN_STATS; i++, bitmap_iterator_inc(&it))
 		if (bitmap_iterator_test(&it))
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 091b904262bc7932d3edf99cf850affb23b9ce6e..6ee9e31e59c392cb88faedf9c541b3bc6d195228 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1321,13 +1321,9 @@ static void mlx4_en_tx_timeout(struct net_device *dev)
 static struct rtnl_link_stats64 *
 mlx4_en_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
-	struct mlx4_en_priv *priv = netdev_priv(dev);
-
-	spin_lock_bh(&priv->stats_lock);
-	mlx4_en_fold_software_stats(dev);
 	netdev_stats_to_stats64(stats, &dev->stats);
-	spin_unlock_bh(&priv->stats_lock);
-
+	/* Must be called after netdev_stats_to_stats64() */
+	mlx4_en_fold_software_stats(dev, stats);
 	return stats;
 }
 
@@ -1810,7 +1806,7 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 	netif_tx_disable(dev);
 
 	spin_lock_bh(&priv->stats_lock);
-	mlx4_en_fold_software_stats(dev);
+	mlx4_en_fold_software_stats(dev, NULL);
 	/* Set port as not active */
 	priv->port_up = false;
 	spin_unlock_bh(&priv->stats_lock);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 9166d90e732858610b1407fe85cbf6cbe27f5e0b..eea042a18e3cfba62745ece4ca673c2db967b9aa 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -147,7 +147,8 @@ static unsigned long en_stats_adder(__be64 *start, __be64 *next, int num)
 	return ret;
 }
 
-void mlx4_en_fold_software_stats(struct net_device *dev)
+void mlx4_en_fold_software_stats(struct net_device *dev,
+				 struct rtnl_link_stats64 *stats)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
@@ -165,9 +166,13 @@ void mlx4_en_fold_software_stats(struct net_device *dev)
 		packets += READ_ONCE(ring->packets);
 		bytes   += READ_ONCE(ring->bytes);
 	}
-	dev->stats.rx_packets = packets;
-	dev->stats.rx_bytes = bytes;
-
+	if (stats) {
+		stats->rx_packets = packets;
+		stats->rx_bytes = bytes;
+	} else {
+		dev->stats.rx_packets = packets;
+		dev->stats.rx_bytes = bytes;
+	}
 	packets = 0;
 	bytes = 0;
 	for (i = 0; i < priv->tx_ring_num[TX]; i++) {
@@ -176,8 +181,13 @@ void mlx4_en_fold_software_stats(struct net_device *dev)
 		packets += READ_ONCE(ring->packets);
 		bytes   += READ_ONCE(ring->bytes);
 	}
-	dev->stats.tx_packets = packets;
-	dev->stats.tx_bytes = bytes;
+	if (stats) {
+		stats->tx_packets = packets;
+		stats->tx_bytes = bytes;
+	} else {
+		dev->stats.tx_packets = packets;
+		dev->stats.tx_bytes = bytes;
+	}
 }
 
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
@@ -208,7 +218,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 
 	spin_lock_bh(&priv->stats_lock);
 
-	mlx4_en_fold_software_stats(dev);
+	mlx4_en_fold_software_stats(dev, NULL);
 
 	priv->port_stats.rx_chksum_good = 0;
 	priv->port_stats.rx_chksum_none = 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 20a936428f4a44c8ca0a7161855da310f9166b50..92dbb41f425b282e9ab7c8d534f091da0ba661c3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -755,7 +755,8 @@ void mlx4_en_rx_irq(struct mlx4_cq *mcq);
 int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port, u64 mac, u64 clear, u8 mode);
 int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, struct mlx4_en_priv *priv);
 
-void mlx4_en_fold_software_stats(struct net_device *dev);
+void mlx4_en_fold_software_stats(struct net_device *dev,
+				 struct rtnl_link_stats64 *stats);
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset);
 int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port);
 
