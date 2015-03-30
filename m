From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 5/7] net/mlx4_en: Protect access to the statistics bitmap
Date: Mon, 30 Mar 2015 17:45:24 +0300
Message-ID: <1427726726-27516-6-git-send-email-ogerlitz@mellanox.com>
References: <1427726726-27516-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Har-Zion <hadarh@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50822 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753665AbbC3OqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 10:46:12 -0400
In-Reply-To: <1427726726-27516-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

This will allow parallel access to the statistics bitmap.
A pre-step for adding PFC counters, where the statistics bitmap
can be dynamically changed when modifying the PFC setting.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    6 ++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |   25 ++++++++++++-----------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    9 ++++++-
 3 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 1a29329..3e7ed39 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -263,7 +263,7 @@ static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct bitmap_iterator it;
 
-	bitmap_iterator_init(&it, priv->stats_bitmap, NUM_ALL_STATS);
+	bitmap_iterator_init(&it, priv->stats_bitmap.bitmap, NUM_ALL_STATS);
 
 	switch (sset) {
 	case ETH_SS_STATS:
@@ -292,7 +292,7 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 	int i;
 	struct bitmap_iterator it;
 
-	bitmap_iterator_init(&it, priv->stats_bitmap, NUM_ALL_STATS);
+	bitmap_iterator_init(&it, priv->stats_bitmap.bitmap, NUM_ALL_STATS);
 
 	spin_lock_bh(&priv->stats_lock);
 
@@ -339,7 +339,7 @@ static void mlx4_en_get_strings(struct net_device *dev,
 	int i, strings = 0;
 	struct bitmap_iterator it;
 
-	bitmap_iterator_init(&it, priv->stats_bitmap, NUM_ALL_STATS);
+	bitmap_iterator_init(&it, priv->stats_bitmap.bitmap, NUM_ALL_STATS);
 
 	switch (stringset) {
 	case ETH_SS_TEST:
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b771032..4542bab 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2649,35 +2649,36 @@ int mlx4_en_netdev_event(struct notifier_block *this,
 }
 
 void mlx4_en_set_stats_bitmap(struct mlx4_dev *dev,
-			      unsigned long *stats_bitmap)
+			      struct mlx4_en_stats_bitmap *stats_bitmap)
 {
 	int last_i = 0;
 
-	bitmap_zero(stats_bitmap, NUM_ALL_STATS);
+	mutex_init(&stats_bitmap->mutex);
+	bitmap_zero(stats_bitmap->bitmap, NUM_ALL_STATS);
 
 	if (mlx4_is_slave(dev)) {
-		bitmap_set(stats_bitmap, last_i +
+		bitmap_set(stats_bitmap->bitmap, last_i +
 					 MLX4_FIND_NETDEV_STAT(rx_packets), 1);
-		bitmap_set(stats_bitmap, last_i +
+		bitmap_set(stats_bitmap->bitmap, last_i +
 					 MLX4_FIND_NETDEV_STAT(tx_packets), 1);
-		bitmap_set(stats_bitmap, last_i +
+		bitmap_set(stats_bitmap->bitmap, last_i +
 					 MLX4_FIND_NETDEV_STAT(rx_bytes), 1);
-		bitmap_set(stats_bitmap, last_i +
+		bitmap_set(stats_bitmap->bitmap, last_i +
 					 MLX4_FIND_NETDEV_STAT(tx_bytes), 1);
-		bitmap_set(stats_bitmap, last_i +
+		bitmap_set(stats_bitmap->bitmap, last_i +
 					 MLX4_FIND_NETDEV_STAT(rx_dropped), 1);
-		bitmap_set(stats_bitmap, last_i +
+		bitmap_set(stats_bitmap->bitmap, last_i +
 					 MLX4_FIND_NETDEV_STAT(tx_dropped), 1);
 	} else {
-		bitmap_set(stats_bitmap, last_i, NUM_MAIN_STATS);
+		bitmap_set(stats_bitmap->bitmap, last_i, NUM_MAIN_STATS);
 	}
 	last_i += NUM_MAIN_STATS;
 
-	bitmap_set(stats_bitmap, last_i, NUM_PORT_STATS);
+	bitmap_set(stats_bitmap->bitmap, last_i, NUM_PORT_STATS);
 	last_i += NUM_PORT_STATS;
 
 	if (!mlx4_is_slave(dev))
-		bitmap_set(stats_bitmap, last_i, NUM_PKT_STATS);
+		bitmap_set(stats_bitmap->bitmap, last_i, NUM_PKT_STATS);
 }
 
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
@@ -2913,7 +2914,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		queue_delayed_work(mdev->workqueue, &priv->service_task,
 				   SERVICE_TASK_DELAY);
 
-	mlx4_en_set_stats_bitmap(mdev->dev, priv->stats_bitmap);
+	mlx4_en_set_stats_bitmap(mdev->dev, &priv->stats_bitmap);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index a612bfd..d5d971a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -485,6 +485,11 @@ enum {
 #define MLX4_EN_MAC_HASH_SIZE (1 << BITS_PER_BYTE)
 #define MLX4_EN_MAC_HASH_IDX 5
 
+struct mlx4_en_stats_bitmap {
+	DECLARE_BITMAP(bitmap, NUM_ALL_STATS);
+	struct mutex mutex; /* for mutual access to stats bitmap */
+};
+
 struct mlx4_en_priv {
 	struct mlx4_en_dev *mdev;
 	struct mlx4_en_port_profile *prof;
@@ -561,7 +566,7 @@ struct mlx4_en_priv {
 	struct mlx4_en_perf_stats pstats;
 	struct mlx4_en_pkt_stats pkstats;
 	struct mlx4_en_port_stats port_stats;
-	DECLARE_BITMAP(stats_bitmap, NUM_ALL_STATS);
+	struct mlx4_en_stats_bitmap stats_bitmap;
 	struct list_head mc_list;
 	struct list_head curr_list;
 	u64 broadcast_id;
@@ -731,7 +736,7 @@ int mlx4_en_start_port(struct net_device *dev);
 void mlx4_en_stop_port(struct net_device *dev, int detach);
 
 void mlx4_en_set_stats_bitmap(struct mlx4_dev *dev,
-			      unsigned long *stats_bitmap);
+			      struct mlx4_en_stats_bitmap *stats_bitmap);
 
 void mlx4_en_free_resources(struct mlx4_en_priv *priv);
 int mlx4_en_alloc_resources(struct mlx4_en_priv *priv);
-- 
1.7.1
