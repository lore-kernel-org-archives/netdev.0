From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 4/7] net/mlx4_en: Support general selective view of ethtool statistics
Date: Mon, 30 Mar 2015 17:45:23 +0300
Message-ID: <1427726726-27516-5-git-send-email-ogerlitz@mellanox.com>
References: <1427726726-27516-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Har-Zion <hadarh@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50812 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753645AbbC3OqJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 10:46:09 -0400
In-Reply-To: <1427726726-27516-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

The driver uses a bitmask to indicate which statistics should be
displayed to the user in ethtool. The bitmask is u64, therefore we are
limited for a selective view of up to 64 statistics. Extend the bitmap
in order to show more than 64 statistics.

In addition, add packet statistics to the ethtool display for PF.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  123 ++++++++++++++---------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |   42 +++++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    5 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h |    4 +
 4 files changed, 109 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 310d798..1a29329 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -38,6 +38,7 @@
 #include <linux/mlx4/device.h>
 #include <linux/in.h>
 #include <net/ip.h>
+#include <linux/bitmap.h>
 
 #include "mlx4_en.h"
 #include "en_port.h"
@@ -104,6 +105,7 @@ static const char mlx4_en_priv_flags[][ETH_GSTRING_LEN] = {
 };
 
 static const char main_strings[][ETH_GSTRING_LEN] = {
+	/* main statistics */
 	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
 	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
 	"rx_length_errors", "rx_over_errors", "rx_crc_errors",
@@ -222,14 +224,50 @@ static int mlx4_en_set_wol(struct net_device *netdev,
 	return err;
 }
 
+struct bitmap_iterator {
+	unsigned long *stats_bitmap;
+	unsigned int count;
+	unsigned int iterator;
+	bool advance_array; /* if set, force no increments */
+};
+
+static inline void bitmap_iterator_init(struct bitmap_iterator *h,
+					unsigned long *stats_bitmap,
+					int count)
+{
+	h->iterator = 0;
+	h->advance_array = !bitmap_empty(stats_bitmap, count);
+	h->count = h->advance_array ? bitmap_weight(stats_bitmap, count)
+		: count;
+	h->stats_bitmap = stats_bitmap;
+}
+
+static inline int bitmap_iterator_test(struct bitmap_iterator *h)
+{
+	return !h->advance_array ? 1 : test_bit(h->iterator, h->stats_bitmap);
+}
+
+static inline int bitmap_iterator_inc(struct bitmap_iterator *h)
+{
+	return h->iterator++;
+}
+
+static inline unsigned int
+bitmap_iterator_count(struct bitmap_iterator *h)
+{
+	return h->count;
+}
+
 static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	int bit_count = hweight64(priv->stats_bitmap);
+	struct bitmap_iterator it;
+
+	bitmap_iterator_init(&it, priv->stats_bitmap, NUM_ALL_STATS);
 
 	switch (sset) {
 	case ETH_SS_STATS:
-		return (priv->stats_bitmap ? bit_count : NUM_ALL_STATS) +
+		return bitmap_iterator_count(&it) +
 			(priv->tx_ring_num * 2) +
 #ifdef CONFIG_NET_RX_BUSY_POLL
 			(priv->rx_ring_num * 5);
@@ -251,34 +289,25 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	int index = 0;
-	int i, j = 0;
+	int i;
+	struct bitmap_iterator it;
+
+	bitmap_iterator_init(&it, priv->stats_bitmap, NUM_ALL_STATS);
 
 	spin_lock_bh(&priv->stats_lock);
 
-	if (!(priv->stats_bitmap)) {
-		for (i = 0; i < NUM_MAIN_STATS; i++)
-			data[index++] =
-				((unsigned long *) &priv->stats)[i];
-		for (i = 0; i < NUM_PORT_STATS; i++)
-			data[index++] =
-				((unsigned long *) &priv->port_stats)[i];
-		for (i = 0; i < NUM_PKT_STATS; i++)
-			data[index++] =
-				((unsigned long *) &priv->pkstats)[i];
-	} else {
-		for (i = 0; i < NUM_MAIN_STATS; i++) {
-			if ((priv->stats_bitmap >> j) & 1)
-				data[index++] =
-				((unsigned long *) &priv->stats)[i];
-			j++;
-		}
-		for (i = 0; i < NUM_PORT_STATS; i++) {
-			if ((priv->stats_bitmap >> j) & 1)
-				data[index++] =
-				((unsigned long *) &priv->port_stats)[i];
-			j++;
-		}
-	}
+	for (i = 0; i < NUM_MAIN_STATS; i++, bitmap_iterator_inc(&it))
+		if (bitmap_iterator_test(&it))
+			data[index++] = ((unsigned long *)&priv->stats)[i];
+
+	for (i = 0; i < NUM_PORT_STATS; i++, bitmap_iterator_inc(&it))
+		if (bitmap_iterator_test(&it))
+			data[index++] = ((unsigned long *)&priv->port_stats)[i];
+
+	for (i = 0; i < NUM_PKT_STATS; i++, bitmap_iterator_inc(&it))
+		if (bitmap_iterator_test(&it))
+			data[index++] = ((unsigned long *)&priv->pkstats)[i];
+
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		data[index++] = priv->tx_ring[i]->packets;
 		data[index++] = priv->tx_ring[i]->bytes;
@@ -307,7 +336,10 @@ static void mlx4_en_get_strings(struct net_device *dev,
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	int index = 0;
-	int i;
+	int i, strings = 0;
+	struct bitmap_iterator it;
+
+	bitmap_iterator_init(&it, priv->stats_bitmap, NUM_ALL_STATS);
 
 	switch (stringset) {
 	case ETH_SS_TEST:
@@ -320,29 +352,24 @@ static void mlx4_en_get_strings(struct net_device *dev,
 
 	case ETH_SS_STATS:
 		/* Add main counters */
-		if (!priv->stats_bitmap) {
-			for (i = 0; i < NUM_MAIN_STATS; i++)
+		for (i = 0; i < NUM_MAIN_STATS; i++, strings++,
+		     bitmap_iterator_inc(&it))
+			if (bitmap_iterator_test(&it))
 				strcpy(data + (index++) * ETH_GSTRING_LEN,
-					main_strings[i]);
-			for (i = 0; i < NUM_PORT_STATS; i++)
+				       main_strings[strings]);
+
+		for (i = 0; i < NUM_PORT_STATS; i++, strings++,
+		     bitmap_iterator_inc(&it))
+			if (bitmap_iterator_test(&it))
 				strcpy(data + (index++) * ETH_GSTRING_LEN,
-					main_strings[i +
-					NUM_MAIN_STATS]);
-			for (i = 0; i < NUM_PKT_STATS; i++)
+				       main_strings[strings]);
+
+		for (i = 0; i < NUM_PKT_STATS; i++, strings++,
+		     bitmap_iterator_inc(&it))
+			if (bitmap_iterator_test(&it))
 				strcpy(data + (index++) * ETH_GSTRING_LEN,
-					main_strings[i +
-					NUM_MAIN_STATS +
-					NUM_PORT_STATS]);
-		} else
-			for (i = 0; i < NUM_MAIN_STATS + NUM_PORT_STATS; i++) {
-				if ((priv->stats_bitmap >> i) & 1) {
-					strcpy(data +
-					       (index++) * ETH_GSTRING_LEN,
-					       main_strings[i]);
-				}
-				if (!(priv->stats_bitmap >> i))
-					break;
-			}
+				       main_strings[strings]);
+
 		for (i = 0; i < priv->tx_ring_num; i++) {
 			sprintf(data + (index++) * ETH_GSTRING_LEN,
 				"tx%d_packets", i);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 9556230..b771032 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -49,11 +49,6 @@
 #include "mlx4_en.h"
 #include "en_port.h"
 
-#define MLX4_STATS_TRAFFIC_COUNTERS_MASK	0xfULL
-#define MLX4_STATS_TRAFFIC_DROPS_MASK		0xc0ULL
-#define MLX4_STATS_ERROR_COUNTERS_MASK		0x1ffc30ULL
-#define MLX4_STATS_PORT_COUNTERS_MASK		0x7fe00000ULL
-
 int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -2653,19 +2648,36 @@ int mlx4_en_netdev_event(struct notifier_block *this,
 	return NOTIFY_DONE;
 }
 
-void mlx4_en_set_stats_bitmap(struct mlx4_dev *dev, u64 *stats_bitmap)
+void mlx4_en_set_stats_bitmap(struct mlx4_dev *dev,
+			      unsigned long *stats_bitmap)
 {
-	if (!mlx4_is_mfunc(dev)) {
-		*stats_bitmap = 0;
-		return;
+	int last_i = 0;
+
+	bitmap_zero(stats_bitmap, NUM_ALL_STATS);
+
+	if (mlx4_is_slave(dev)) {
+		bitmap_set(stats_bitmap, last_i +
+					 MLX4_FIND_NETDEV_STAT(rx_packets), 1);
+		bitmap_set(stats_bitmap, last_i +
+					 MLX4_FIND_NETDEV_STAT(tx_packets), 1);
+		bitmap_set(stats_bitmap, last_i +
+					 MLX4_FIND_NETDEV_STAT(rx_bytes), 1);
+		bitmap_set(stats_bitmap, last_i +
+					 MLX4_FIND_NETDEV_STAT(tx_bytes), 1);
+		bitmap_set(stats_bitmap, last_i +
+					 MLX4_FIND_NETDEV_STAT(rx_dropped), 1);
+		bitmap_set(stats_bitmap, last_i +
+					 MLX4_FIND_NETDEV_STAT(tx_dropped), 1);
+	} else {
+		bitmap_set(stats_bitmap, last_i, NUM_MAIN_STATS);
 	}
+	last_i += NUM_MAIN_STATS;
 
-	*stats_bitmap = (MLX4_STATS_TRAFFIC_COUNTERS_MASK |
-			 MLX4_STATS_TRAFFIC_DROPS_MASK |
-			 MLX4_STATS_PORT_COUNTERS_MASK);
+	bitmap_set(stats_bitmap, last_i, NUM_PORT_STATS);
+	last_i += NUM_PORT_STATS;
 
-	if (mlx4_is_master(dev))
-		*stats_bitmap |= MLX4_STATS_ERROR_COUNTERS_MASK;
+	if (!mlx4_is_slave(dev))
+		bitmap_set(stats_bitmap, last_i, NUM_PKT_STATS);
 }
 
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
@@ -2901,7 +2913,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		queue_delayed_work(mdev->workqueue, &priv->service_task,
 				   SERVICE_TASK_DELAY);
 
-	mlx4_en_set_stats_bitmap(mdev->dev, &priv->stats_bitmap);
+	mlx4_en_set_stats_bitmap(mdev->dev, priv->stats_bitmap);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index af3d9b7..a612bfd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -561,7 +561,7 @@ struct mlx4_en_priv {
 	struct mlx4_en_perf_stats pstats;
 	struct mlx4_en_pkt_stats pkstats;
 	struct mlx4_en_port_stats port_stats;
-	u64 stats_bitmap;
+	DECLARE_BITMAP(stats_bitmap, NUM_ALL_STATS);
 	struct list_head mc_list;
 	struct list_head curr_list;
 	u64 broadcast_id;
@@ -730,7 +730,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 int mlx4_en_start_port(struct net_device *dev);
 void mlx4_en_stop_port(struct net_device *dev, int detach);
 
-void mlx4_en_set_stats_bitmap(struct mlx4_dev *dev, u64 *stats_bitmap);
+void mlx4_en_set_stats_bitmap(struct mlx4_dev *dev,
+			      unsigned long *stats_bitmap);
 
 void mlx4_en_free_resources(struct mlx4_en_priv *priv);
 int mlx4_en_alloc_resources(struct mlx4_en_priv *priv);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
index abea7a5..d7183e3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
@@ -44,4 +44,8 @@ struct mlx4_en_perf_stats {
 #define NUM_MAIN_STATS	21
 #define NUM_ALL_STATS	(NUM_MAIN_STATS + NUM_PORT_STATS + NUM_PKT_STATS + \
 			 NUM_PERF_STATS)
+
+#define MLX4_FIND_NETDEV_STAT(n) (offsetof(struct net_device_stats, n) / \
+				  sizeof(((struct net_device_stats *)0)->n))
+
 #endif
-- 
1.7.1
