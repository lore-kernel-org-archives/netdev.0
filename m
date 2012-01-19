From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net V1 3/6] mlx4_en: eth statistics modification
Date: Thu, 19 Jan 2012 21:45:05 +0200
Message-ID: <4F1872C1.1040906@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:40011 "HELO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932675Ab2ASTpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 14:45:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

In native mode display all available staticstics.
In SRIOV mode on VF display only SW counters statistics,
in SRIOV mode on hypervisor display SW counters and errors (got from FW)
statistics.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Reviewed-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   66 +++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    2 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    1 +
 drivers/net/ethernet/mellanox/mlx4/port.c       |   21 +++++++
 include/linux/mlx4/device.h                     |    1 +
 5 files changed, 75 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 53c6686..70346fd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -183,10 +183,11 @@ static int mlx4_en_set_wol(struct net_device *netdev,
 static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
+	int bit_count = hweight64(priv->stats_bitmap);
 
 	switch (sset) {
 	case ETH_SS_STATS:
-		return NUM_ALL_STATS +
+		return (priv->stats_bitmap ? bit_count : NUM_ALL_STATS) +
 			(priv->tx_ring_num + priv->rx_ring_num) * 2;
 	case ETH_SS_TEST:
 		return MLX4_EN_NUM_SELF_TEST - !(priv->mdev->dev->caps.flags
@@ -201,14 +202,34 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	int index = 0;
-	int i;
+	int i, j = 0;
 
 	spin_lock_bh(&priv->stats_lock);
 
-	for (i = 0; i < NUM_MAIN_STATS; i++)
-		data[index++] = ((unsigned long *) &priv->stats)[i];
-	for (i = 0; i < NUM_PORT_STATS; i++)
-		data[index++] = ((unsigned long *) &priv->port_stats)[i];
+	if (!(priv->stats_bitmap)) {
+		for (i = 0; i < NUM_MAIN_STATS; i++)
+			data[index++] =
+				((unsigned long *) &priv->stats)[i];
+		for (i = 0; i < NUM_PORT_STATS; i++)
+			data[index++] =
+				((unsigned long *) &priv->port_stats)[i];
+		for (i = 0; i < NUM_PKT_STATS; i++)
+			data[index++] =
+				((unsigned long *) &priv->pkstats)[i];
+	} else {
+		for (i = 0; i < NUM_MAIN_STATS; i++) {
+			if ((priv->stats_bitmap >> j) & 1)
+				data[index++] =
+				((unsigned long *) &priv->stats)[i];
+			j++;
+		}
+		for (i = 0; i < NUM_PORT_STATS; i++) {
+			if ((priv->stats_bitmap >> j) & 1)
+				data[index++] =
+				((unsigned long *) &priv->port_stats)[i];
+			j++;
+		}
+	}
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		data[index++] = priv->tx_ring[i].packets;
 		data[index++] = priv->tx_ring[i].bytes;
@@ -217,8 +238,6 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 		data[index++] = priv->rx_ring[i].packets;
 		data[index++] = priv->rx_ring[i].bytes;
 	}
-	for (i = 0; i < NUM_PKT_STATS; i++)
-		data[index++] = ((unsigned long *) &priv->pkstats)[i];
 	spin_unlock_bh(&priv->stats_lock);
 
 }
@@ -247,11 +266,29 @@ static void mlx4_en_get_strings(struct net_device *dev,
 
 	case ETH_SS_STATS:
 		/* Add main counters */
-		for (i = 0; i < NUM_MAIN_STATS; i++)
-			strcpy(data + (index++) * ETH_GSTRING_LEN, main_strings[i]);
-		for (i = 0; i< NUM_PORT_STATS; i++)
-			strcpy(data + (index++) * ETH_GSTRING_LEN,
-			main_strings[i + NUM_MAIN_STATS]);
+		if (!priv->stats_bitmap) {
+			for (i = 0; i < NUM_MAIN_STATS; i++)
+				strcpy(data + (index++) * ETH_GSTRING_LEN,
+					main_strings[i]);
+			for (i = 0; i < NUM_PORT_STATS; i++)
+				strcpy(data + (index++) * ETH_GSTRING_LEN,
+					main_strings[i +
+					NUM_MAIN_STATS]);
+			for (i = 0; i < NUM_PKT_STATS; i++)
+				strcpy(data + (index++) * ETH_GSTRING_LEN,
+					main_strings[i +
+					NUM_MAIN_STATS +
+					NUM_PORT_STATS]);
+		} else
+			for (i = 0; i < NUM_MAIN_STATS + NUM_PORT_STATS; i++) {
+				if ((priv->stats_bitmap >> i) & 1) {
+					strcpy(data +
+					       (index++) * ETH_GSTRING_LEN,
+					       main_strings[i]);
+				}
+				if (!(priv->stats_bitmap >> i))
+					break;
+			}
 		for (i = 0; i < priv->tx_ring_num; i++) {
 			sprintf(data + (index++) * ETH_GSTRING_LEN,
 				"tx%d_packets", i);
@@ -264,9 +301,6 @@ static void mlx4_en_get_strings(struct net_device *dev,
 			sprintf(data + (index++) * ETH_GSTRING_LEN,
 				"rx%d_bytes", i);
 		}
-		for (i = 0; i< NUM_PKT_STATS; i++)
-			strcpy(data + (index++) * ETH_GSTRING_LEN,
-			main_strings[i + NUM_MAIN_STATS + NUM_PORT_STATS]);
 		break;
 	}
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index be3f415..467ae58 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -702,6 +702,8 @@ int mlx4_en_start_port(struct net_device *dev)
 	/* Schedule multicast task to populate multicast list */
 	queue_work(mdev->workqueue, &priv->mcast_task);
 
+	mlx4_set_stats_bitmap(mdev->dev, &priv->stats_bitmap);
+
 	priv->port_up = true;
 	netif_tx_start_all_queues(dev);
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index f4d189a..35f0884 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -476,6 +476,7 @@ struct mlx4_en_priv {
 	struct mlx4_en_perf_stats pstats;
 	struct mlx4_en_pkt_stats pkstats;
 	struct mlx4_en_port_stats port_stats;
+	u64 stats_bitmap;
 	char *mc_addrs;
 	int mc_addrs_cnt;
 	struct mlx4_en_stat_out_mbox hw_stats;
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 1a551d6..f44ae55 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -44,6 +44,11 @@
 #define MLX4_VLAN_VALID		(1u << 31)
 #define MLX4_VLAN_MASK		0xfff
 
+#define MLX4_STATS_TRAFFIC_COUNTERS_MASK	0xfULL
+#define MLX4_STATS_TRAFFIC_DROPS_MASK		0xc0ULL
+#define MLX4_STATS_ERROR_COUNTERS_MASK		0x1ffc30ULL
+#define MLX4_STATS_PORT_COUNTERS_MASK		0x1fe00000ULL
+
 void mlx4_init_mac_table(struct mlx4_dev *dev, struct mlx4_mac_table *table)
 {
 	int i;
@@ -903,3 +908,19 @@ int mlx4_DUMP_ETH_STATS_wrapper(struct mlx4_dev *dev, int slave,
 	return mlx4_common_dump_eth_stats(dev, slave,
 					  vhcr->in_modifier, outbox);
 }
+
+void mlx4_set_stats_bitmap(struct mlx4_dev *dev, u64 *stats_bitmap)
+{
+	if (!mlx4_is_mfunc(dev)) {
+		*stats_bitmap = 0;
+		return;
+	}
+
+	*stats_bitmap = (MLX4_STATS_TRAFFIC_COUNTERS_MASK |
+			 MLX4_STATS_TRAFFIC_DROPS_MASK |
+			 MLX4_STATS_PORT_COUNTERS_MASK);
+
+	if (mlx4_is_master(dev))
+		*stats_bitmap |= MLX4_STATS_ERROR_COUNTERS_MASK;
+}
+EXPORT_SYMBOL(mlx4_set_stats_bitmap);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 5c4fe8e..aea6190 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -621,6 +621,7 @@ void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, u64 mac);
 int mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac);
 int mlx4_get_eth_qp(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn);
 void mlx4_put_eth_qp(struct mlx4_dev *dev, u8 port, u64 mac, int qpn);
+void mlx4_set_stats_bitmap(struct mlx4_dev *dev, u64 *stats_bitmap);
 
 int mlx4_find_cached_vlan(struct mlx4_dev *dev, u8 port, u16 vid, int *idx);
 int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index);
-- 
1.5.4.3
