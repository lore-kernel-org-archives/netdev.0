From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 6/7] net/mlx4_en: Add Flow control statistics display via ethtool
Date: Mon, 30 Mar 2015 17:45:25 +0300
Message-ID: <1427726726-27516-7-git-send-email-ogerlitz@mellanox.com>
References: <1427726726-27516-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Har-Zion <hadarh@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50835 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753709AbbC3OqS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 10:46:18 -0400
In-Reply-To: <1427726726-27516-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Flow control per priority and Global pause counters are now visible via
ethtool.  The counters shows statistics regarding pauses in the device.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Shani Michaeli <shanim@mellanox.com>
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c  |    4 +
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   74 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |   57 +++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_port.c    |   50 +++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.c         |   10 +++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |   13 ++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h |   52 ++++++++++++++++-
 include/linux/mlx4/device.h                     |    3 +-
 8 files changed, 255 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index cde14fa..8e3260c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -226,6 +226,10 @@ static int mlx4_en_dcbnl_ieee_setpfc(struct net_device *dev,
 				    prof->rx_ppp);
 	if (err)
 		en_err(priv, "Failed setting pause params\n");
+	else
+		mlx4_en_update_pfc_stats_bitmap(mdev->dev, &priv->stats_bitmap,
+						prof->rx_ppp, prof->rx_pause,
+						prof->tx_ppp, prof->tx_pause);
 
 	return err;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 3e7ed39..4fc7674 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -119,6 +119,48 @@ static const char main_strings[][ETH_GSTRING_LEN] = {
 	"queue_stopped", "wake_queue", "tx_timeout", "rx_alloc_failed",
 	"rx_csum_good", "rx_csum_none", "rx_csum_complete", "tx_chksum_offload",
 
+	/* priority flow control statistics rx */
+	"rx_pause_prio_0", "rx_pause_duration_prio_0",
+	"rx_pause_transition_prio_0",
+	"rx_pause_prio_1", "rx_pause_duration_prio_1",
+	"rx_pause_transition_prio_1",
+	"rx_pause_prio_2", "rx_pause_duration_prio_2",
+	"rx_pause_transition_prio_2",
+	"rx_pause_prio_3", "rx_pause_duration_prio_3",
+	"rx_pause_transition_prio_3",
+	"rx_pause_prio_4", "rx_pause_duration_prio_4",
+	"rx_pause_transition_prio_4",
+	"rx_pause_prio_5", "rx_pause_duration_prio_5",
+	"rx_pause_transition_prio_5",
+	"rx_pause_prio_6", "rx_pause_duration_prio_6",
+	"rx_pause_transition_prio_6",
+	"rx_pause_prio_7", "rx_pause_duration_prio_7",
+	"rx_pause_transition_prio_7",
+
+	/* flow control statistics rx */
+	"rx_pause", "rx_pause_duration", "rx_pause_transition",
+
+	/* priority flow control statistics tx */
+	"tx_pause_prio_0", "tx_pause_duration_prio_0",
+	"tx_pause_transition_prio_0",
+	"tx_pause_prio_1", "tx_pause_duration_prio_1",
+	"tx_pause_transition_prio_1",
+	"tx_pause_prio_2", "tx_pause_duration_prio_2",
+	"tx_pause_transition_prio_2",
+	"tx_pause_prio_3", "tx_pause_duration_prio_3",
+	"tx_pause_transition_prio_3",
+	"tx_pause_prio_4", "tx_pause_duration_prio_4",
+	"tx_pause_transition_prio_4",
+	"tx_pause_prio_5", "tx_pause_duration_prio_5",
+	"tx_pause_transition_prio_5",
+	"tx_pause_prio_6", "tx_pause_duration_prio_6",
+	"tx_pause_transition_prio_6",
+	"tx_pause_prio_7", "tx_pause_duration_prio_7",
+	"tx_pause_transition_prio_7",
+
+	/* flow control statistics tx */
+	"tx_pause", "tx_pause_duration", "tx_pause_transition",
+
 	/* packet statistics */
 	"broadcast", "rx_prio_0", "rx_prio_1", "rx_prio_2", "rx_prio_3",
 	"rx_prio_4", "rx_prio_5", "rx_prio_6", "rx_prio_7", "tx_prio_0",
@@ -304,6 +346,26 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 		if (bitmap_iterator_test(&it))
 			data[index++] = ((unsigned long *)&priv->port_stats)[i];
 
+	for (i = 0; i < NUM_FLOW_PRIORITY_STATS_RX;
+	     i++, bitmap_iterator_inc(&it))
+		if (bitmap_iterator_test(&it))
+			data[index++] =
+				((u64 *)&priv->rx_priority_flowstats)[i];
+
+	for (i = 0; i < NUM_FLOW_STATS_RX; i++, bitmap_iterator_inc(&it))
+		if (bitmap_iterator_test(&it))
+			data[index++] = ((u64 *)&priv->rx_flowstats)[i];
+
+	for (i = 0; i < NUM_FLOW_PRIORITY_STATS_TX;
+	     i++, bitmap_iterator_inc(&it))
+		if (bitmap_iterator_test(&it))
+			data[index++] =
+				((u64 *)&priv->tx_priority_flowstats)[i];
+
+	for (i = 0; i < NUM_FLOW_STATS_TX; i++, bitmap_iterator_inc(&it))
+		if (bitmap_iterator_test(&it))
+			data[index++] = ((u64 *)&priv->tx_flowstats)[i];
+
 	for (i = 0; i < NUM_PKT_STATS; i++, bitmap_iterator_inc(&it))
 		if (bitmap_iterator_test(&it))
 			data[index++] = ((unsigned long *)&priv->pkstats)[i];
@@ -364,6 +426,12 @@ static void mlx4_en_get_strings(struct net_device *dev,
 				strcpy(data + (index++) * ETH_GSTRING_LEN,
 				       main_strings[strings]);
 
+		for (i = 0; i < NUM_FLOW_STATS; i++, strings++,
+		     bitmap_iterator_inc(&it))
+			if (bitmap_iterator_test(&it))
+				strcpy(data + (index++) * ETH_GSTRING_LEN,
+				       main_strings[strings]);
+
 		for (i = 0; i < NUM_PKT_STATS; i++, strings++,
 		     bitmap_iterator_inc(&it))
 			if (bitmap_iterator_test(&it))
@@ -910,6 +978,12 @@ static int mlx4_en_set_pauseparam(struct net_device *dev,
 				    priv->prof->rx_ppp);
 	if (err)
 		en_err(priv, "Failed setting pause params\n");
+	else
+		mlx4_en_update_pfc_stats_bitmap(mdev->dev, &priv->stats_bitmap,
+						priv->prof->rx_ppp,
+						priv->prof->rx_pause,
+						priv->prof->tx_ppp,
+						priv->prof->tx_pause);
 
 	return err;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 4542bab..354e254 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1888,6 +1888,12 @@ static void mlx4_en_clear_stats(struct net_device *dev)
 	memset(&priv->pstats, 0, sizeof(priv->pstats));
 	memset(&priv->pkstats, 0, sizeof(priv->pkstats));
 	memset(&priv->port_stats, 0, sizeof(priv->port_stats));
+	memset(&priv->rx_flowstats, 0, sizeof(priv->rx_flowstats));
+	memset(&priv->tx_flowstats, 0, sizeof(priv->tx_flowstats));
+	memset(&priv->rx_priority_flowstats, 0,
+	       sizeof(priv->rx_priority_flowstats));
+	memset(&priv->tx_priority_flowstats, 0,
+	       sizeof(priv->tx_priority_flowstats));
 
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		priv->tx_ring[i]->bytes = 0;
@@ -2648,8 +2654,46 @@ int mlx4_en_netdev_event(struct notifier_block *this,
 	return NOTIFY_DONE;
 }
 
+void mlx4_en_update_pfc_stats_bitmap(struct mlx4_dev *dev,
+				     struct mlx4_en_stats_bitmap *stats_bitmap,
+				     u8 rx_ppp, u8 rx_pause,
+				     u8 tx_ppp, u8 tx_pause)
+{
+	int last_i = NUM_MAIN_STATS + NUM_PORT_STATS;
+
+	if (!mlx4_is_slave(dev) &&
+	    (dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_FLOWSTATS_EN)) {
+		mutex_lock(&stats_bitmap->mutex);
+		bitmap_clear(stats_bitmap->bitmap, last_i, NUM_FLOW_STATS);
+
+		if (rx_ppp)
+			bitmap_set(stats_bitmap->bitmap, last_i,
+				   NUM_FLOW_PRIORITY_STATS_RX);
+		last_i += NUM_FLOW_PRIORITY_STATS_RX;
+
+		if (rx_pause && !(rx_ppp))
+			bitmap_set(stats_bitmap->bitmap, last_i,
+				   NUM_FLOW_STATS_RX);
+		last_i += NUM_FLOW_STATS_RX;
+
+		if (tx_ppp)
+			bitmap_set(stats_bitmap->bitmap, last_i,
+				   NUM_FLOW_PRIORITY_STATS_TX);
+		last_i += NUM_FLOW_PRIORITY_STATS_TX;
+
+		if (tx_pause && !(tx_ppp))
+			bitmap_set(stats_bitmap->bitmap, last_i,
+				   NUM_FLOW_STATS_TX);
+		last_i += NUM_FLOW_STATS_TX;
+
+		mutex_unlock(&stats_bitmap->mutex);
+	}
+}
+
 void mlx4_en_set_stats_bitmap(struct mlx4_dev *dev,
-			      struct mlx4_en_stats_bitmap *stats_bitmap)
+			      struct mlx4_en_stats_bitmap *stats_bitmap,
+			      u8 rx_ppp, u8 rx_pause,
+			      u8 tx_ppp, u8 tx_pause)
 {
 	int last_i = 0;
 
@@ -2677,6 +2721,11 @@ void mlx4_en_set_stats_bitmap(struct mlx4_dev *dev,
 	bitmap_set(stats_bitmap->bitmap, last_i, NUM_PORT_STATS);
 	last_i += NUM_PORT_STATS;
 
+	mlx4_en_update_pfc_stats_bitmap(dev, stats_bitmap,
+					rx_ppp, rx_pause,
+					tx_ppp, tx_pause);
+	last_i += NUM_FLOW_STATS;
+
 	if (!mlx4_is_slave(dev))
 		bitmap_set(stats_bitmap->bitmap, last_i, NUM_PKT_STATS);
 }
@@ -2914,7 +2963,11 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		queue_delayed_work(mdev->workqueue, &priv->service_task,
 				   SERVICE_TASK_DELAY);
 
-	mlx4_en_set_stats_bitmap(mdev->dev, &priv->stats_bitmap);
+	mlx4_en_set_stats_bitmap(mdev->dev, &priv->stats_bitmap,
+				 mdev->profile.prof[priv->port].rx_ppp,
+				 mdev->profile.prof[priv->port].rx_pause,
+				 mdev->profile.prof[priv->port].tx_ppp,
+				 mdev->profile.prof[priv->port].tx_pause);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 6cb8007..821ae12 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -131,6 +131,7 @@ out:
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 {
 	struct mlx4_en_stat_out_mbox *mlx4_en_stats;
+	struct mlx4_en_stat_out_flow_control_mbox *flowstats;
 	struct mlx4_en_priv *priv = netdev_priv(mdev->pndev[port]);
 	struct net_device_stats *stats = &priv->stats;
 	struct mlx4_cmd_mailbox *mailbox;
@@ -239,6 +240,55 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	priv->pkstats.tx_prio[7] = be64_to_cpu(mlx4_en_stats->TTOT_prio_7);
 	spin_unlock_bh(&priv->stats_lock);
 
+	/* 0xffs indicates invalid value */
+	memset(mailbox->buf, 0xff, sizeof(*flowstats) * MLX4_NUM_PRIORITIES);
+
+	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_FLOWSTATS_EN) {
+		memset(mailbox->buf, 0,
+		       sizeof(*flowstats) * MLX4_NUM_PRIORITIES);
+		err = mlx4_cmd_box(mdev->dev, 0, mailbox->dma,
+				   in_mod | MLX4_DUMP_ETH_STATS_FLOW_CONTROL,
+				   0, MLX4_CMD_DUMP_ETH_STATS,
+				   MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
+		if (err)
+			goto out;
+	}
+
+	flowstats = mailbox->buf;
+
+	spin_lock_bh(&priv->stats_lock);
+
+	for (i = 0; i < MLX4_NUM_PRIORITIES; i++)	{
+		priv->rx_priority_flowstats[i].rx_pause =
+			be64_to_cpu(flowstats[i].rx_pause);
+		priv->rx_priority_flowstats[i].rx_pause_duration =
+			be64_to_cpu(flowstats[i].rx_pause_duration);
+		priv->rx_priority_flowstats[i].rx_pause_transition =
+			be64_to_cpu(flowstats[i].rx_pause_transition);
+		priv->tx_priority_flowstats[i].tx_pause =
+			be64_to_cpu(flowstats[i].tx_pause);
+		priv->tx_priority_flowstats[i].tx_pause_duration =
+			be64_to_cpu(flowstats[i].tx_pause_duration);
+		priv->tx_priority_flowstats[i].tx_pause_transition =
+			be64_to_cpu(flowstats[i].tx_pause_transition);
+	}
+
+	/* if pfc is not in use, all priorities counters have the same value */
+	priv->rx_flowstats.rx_pause =
+		be64_to_cpu(flowstats[0].rx_pause);
+	priv->rx_flowstats.rx_pause_duration =
+		be64_to_cpu(flowstats[0].rx_pause_duration);
+	priv->rx_flowstats.rx_pause_transition =
+		be64_to_cpu(flowstats[0].rx_pause_transition);
+	priv->tx_flowstats.tx_pause =
+		be64_to_cpu(flowstats[0].tx_pause);
+	priv->tx_flowstats.tx_pause_duration =
+		be64_to_cpu(flowstats[0].tx_pause_duration);
+	priv->tx_flowstats.tx_pause_transition =
+		be64_to_cpu(flowstats[0].tx_pause_transition);
+
+	spin_unlock_bh(&priv->stats_lock);
+
 out:
 	mlx4_free_cmd_mailbox(mdev->dev, mailbox);
 	return err;
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 4a471f5..209a617 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -145,7 +145,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[20] = "Recoverable error events support",
 		[21] = "Port Remap support",
 		[22] = "QCN support",
-		[23] = "QP rate limiting support"
+		[23] = "QP rate limiting support",
+		[24] = "Ethernet Flow control statistics support"
 	};
 	int i;
 
@@ -672,6 +673,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_RSVD_XRC_OFFSET		0x66
 #define QUERY_DEV_CAP_MAX_XRC_OFFSET		0x67
 #define QUERY_DEV_CAP_MAX_COUNTERS_OFFSET	0x68
+#define QUERY_DEV_CAP_PORT_FLOWSTATS_COUNTERS_OFFSET	0x70
 #define QUERY_DEV_CAP_EXT_2_FLAGS_OFFSET	0x70
 #define QUERY_DEV_CAP_FLOW_STEERING_IPOIB_OFFSET	0x74
 #define QUERY_DEV_CAP_FLOW_STEERING_RANGE_EN_OFFSET	0x76
@@ -773,6 +775,9 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_VL_PORT_OFFSET);
 	dev_cap->num_ports = field & 0xf;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_MSG_SZ_OFFSET);
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_PORT_FLOWSTATS_COUNTERS_OFFSET);
+	if (field & 0x10)
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_FLOWSTATS_EN;
 	dev_cap->max_msg_sz = 1 << (field & 0x1f);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_FLOW_STEERING_RANGE_EN_OFFSET);
 	if (field & 0x80)
@@ -1088,6 +1093,7 @@ out:
 	return err;
 }
 
+#define DEV_CAP_EXT_2_FLAG_PFC_COUNTERS	(1 << 28)
 #define DEV_CAP_EXT_2_FLAG_VLAN_CONTROL (1 << 26)
 #define DEV_CAP_EXT_2_FLAG_80_VFS	(1 << 21)
 #define DEV_CAP_EXT_2_FLAG_FSM		(1 << 20)
@@ -1177,7 +1183,7 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	/* turn off host side virt features (VST, FSM, etc) for guests */
 	MLX4_GET(field32, outbox->buf, QUERY_DEV_CAP_EXT_2_FLAGS_OFFSET);
 	field32 &= ~(DEV_CAP_EXT_2_FLAG_VLAN_CONTROL | DEV_CAP_EXT_2_FLAG_80_VFS |
-		     DEV_CAP_EXT_2_FLAG_FSM);
+		     DEV_CAP_EXT_2_FLAG_FSM | DEV_CAP_EXT_2_FLAG_PFC_COUNTERS);
 	MLX4_PUT(outbox->buf, field32, QUERY_DEV_CAP_EXT_2_FLAGS_OFFSET);
 
 	/* turn off QCN for guests */
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index d5d971a..67eeea2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -565,6 +565,10 @@ struct mlx4_en_priv {
 #endif
 	struct mlx4_en_perf_stats pstats;
 	struct mlx4_en_pkt_stats pkstats;
+	struct mlx4_en_flow_stats_rx rx_priority_flowstats[MLX4_NUM_PRIORITIES];
+	struct mlx4_en_flow_stats_tx tx_priority_flowstats[MLX4_NUM_PRIORITIES];
+	struct mlx4_en_flow_stats_rx rx_flowstats;
+	struct mlx4_en_flow_stats_tx tx_flowstats;
 	struct mlx4_en_port_stats port_stats;
 	struct mlx4_en_stats_bitmap stats_bitmap;
 	struct list_head mc_list;
@@ -736,7 +740,9 @@ int mlx4_en_start_port(struct net_device *dev);
 void mlx4_en_stop_port(struct net_device *dev, int detach);
 
 void mlx4_en_set_stats_bitmap(struct mlx4_dev *dev,
-			      struct mlx4_en_stats_bitmap *stats_bitmap);
+			      struct mlx4_en_stats_bitmap *stats_bitmap,
+			      u8 rx_ppp, u8 rx_pause,
+			      u8 tx_ppp, u8 tx_pause);
 
 void mlx4_en_free_resources(struct mlx4_en_priv *priv);
 int mlx4_en_alloc_resources(struct mlx4_en_priv *priv);
@@ -823,7 +829,10 @@ void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev);
 int mlx4_en_reset_config(struct net_device *dev,
 			 struct hwtstamp_config ts_config,
 			 netdev_features_t new_features);
-
+void mlx4_en_update_pfc_stats_bitmap(struct mlx4_dev *dev,
+				     struct mlx4_en_stats_bitmap *stats_bitmap,
+				     u8 rx_ppp, u8 rx_pause,
+				     u8 tx_ppp, u8 tx_pause);
 int mlx4_en_netdev_event(struct notifier_block *this,
 			 unsigned long event, void *ptr);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
index d7183e3..e193680 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
@@ -42,8 +42,58 @@ struct mlx4_en_perf_stats {
 };
 
 #define NUM_MAIN_STATS	21
+
+#define MLX4_NUM_PRIORITIES	8
+
+struct mlx4_en_flow_stats_rx {
+	u64 rx_pause;
+	u64 rx_pause_duration;
+	u64 rx_pause_transition;
+#define NUM_FLOW_STATS_RX	3
+#define NUM_FLOW_PRIORITY_STATS_RX	(NUM_FLOW_STATS_RX * \
+					 MLX4_NUM_PRIORITIES)
+};
+
+struct mlx4_en_flow_stats_tx {
+	u64 tx_pause;
+	u64 tx_pause_duration;
+	u64 tx_pause_transition;
+#define NUM_FLOW_STATS_TX	3
+#define NUM_FLOW_PRIORITY_STATS_TX	(NUM_FLOW_STATS_TX * \
+					 MLX4_NUM_PRIORITIES)
+};
+
+#define NUM_FLOW_STATS (NUM_FLOW_STATS_RX + NUM_FLOW_STATS_TX + \
+			NUM_FLOW_PRIORITY_STATS_TX + \
+			NUM_FLOW_PRIORITY_STATS_RX)
+
+struct mlx4_en_stat_out_flow_control_mbox {
+	/* Total number of PAUSE frames received from the far-end port */
+	__be64 rx_pause;
+	/* Total number of microseconds that far-end port requested to pause
+	* transmission of packets
+	*/
+	__be64 rx_pause_duration;
+	/* Number of received transmission from XOFF state to XON state */
+	__be64 rx_pause_transition;
+	/* Total number of PAUSE frames sent from the far-end port */
+	__be64 tx_pause;
+	/* Total time in microseconds that transmission of packets has been
+	* paused
+	*/
+	__be64 tx_pause_duration;
+	/* Number of transmitter transitions from XOFF state to XON state */
+	__be64 tx_pause_transition;
+	/* Reserverd */
+	__be64 reserved[2];
+};
+
+enum {
+	MLX4_DUMP_ETH_STATS_FLOW_CONTROL = 1 << 12
+};
+
 #define NUM_ALL_STATS	(NUM_MAIN_STATS + NUM_PORT_STATS + NUM_PKT_STATS + \
-			 NUM_PERF_STATS)
+			 NUM_FLOW_STATS + NUM_PERF_STATS)
 
 #define MLX4_FIND_NETDEV_STAT(n) (offsetof(struct net_device_stats, n) / \
 				  sizeof(((struct net_device_stats *)0)->n))
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 49abbe2..ab7ebec 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -205,7 +205,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_RECOVERABLE_ERROR_EVENT = 1LL << 20,
 	MLX4_DEV_CAP_FLAG2_PORT_REMAP		= 1LL <<  21,
 	MLX4_DEV_CAP_FLAG2_QCN			= 1LL <<  22,
-	MLX4_DEV_CAP_FLAG2_QP_RATE_LIMIT	= 1LL <<  23
+	MLX4_DEV_CAP_FLAG2_QP_RATE_LIMIT	= 1LL <<  23,
+	MLX4_DEV_CAP_FLAG2_FLOWSTATS_EN         = 1LL <<  24
 };
 
 enum {
-- 
1.7.1
