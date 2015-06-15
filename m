From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 11/13] net/mlx4_en: Show PF own statistics via ethtool
Date: Mon, 15 Jun 2015 17:59:06 +0300
Message-ID: <1434380348-19005-12-git-send-email-ogerlitz@mellanox.com>
References: <1434380348-19005-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45076 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755951AbbFOPA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 11:00:26 -0400
In-Reply-To: <1434380348-19005-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Allow the user to observe the PF own statistics using ethtool with pf_
prefixed counter names.

Those counters are the PF statistics out of the overall port statistics.
Every PF QP is attached to a counter and the summary of those counters
is the PF statistics.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   17 +++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    8 +++++++-
 drivers/net/ethernet/mellanox/mlx4/en_port.c    |   15 ++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    1 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h |   11 ++++++++++-
 5 files changed, 49 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index a2ddf3d..99ba1c5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -119,6 +119,12 @@ static const char main_strings[][ETH_GSTRING_LEN] = {
 	"queue_stopped", "wake_queue", "tx_timeout", "rx_alloc_failed",
 	"rx_csum_good", "rx_csum_none", "rx_csum_complete", "tx_chksum_offload",
 
+	/* pf statistics */
+	"pf_rx_packets",
+	"pf_rx_bytes",
+	"pf_tx_packets",
+	"pf_tx_bytes",
+
 	/* priority flow control statistics rx */
 	"rx_pause_prio_0", "rx_pause_duration_prio_0",
 	"rx_pause_transition_prio_0",
@@ -368,6 +374,11 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 		if (bitmap_iterator_test(&it))
 			data[index++] = ((unsigned long *)&priv->port_stats)[i];
 
+	for (i = 0; i < NUM_PF_STATS; i++, bitmap_iterator_inc(&it))
+		if (bitmap_iterator_test(&it))
+			data[index++] =
+				((unsigned long *)&priv->pf_stats)[i];
+
 	for (i = 0; i < NUM_FLOW_PRIORITY_STATS_RX;
 	     i++, bitmap_iterator_inc(&it))
 		if (bitmap_iterator_test(&it))
@@ -448,6 +459,12 @@ static void mlx4_en_get_strings(struct net_device *dev,
 				strcpy(data + (index++) * ETH_GSTRING_LEN,
 				       main_strings[strings]);
 
+		for (i = 0; i < NUM_PF_STATS; i++, strings++,
+		     bitmap_iterator_inc(&it))
+			if (bitmap_iterator_test(&it))
+				strcpy(data + (index++) * ETH_GSTRING_LEN,
+				       main_strings[strings]);
+
 		for (i = 0; i < NUM_FLOW_STATS; i++, strings++,
 		     bitmap_iterator_inc(&it))
 			if (bitmap_iterator_test(&it))
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 048fca0..f9142f2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1895,6 +1895,7 @@ static void mlx4_en_clear_stats(struct net_device *dev)
 	       sizeof(priv->rx_priority_flowstats));
 	memset(&priv->tx_priority_flowstats, 0,
 	       sizeof(priv->tx_priority_flowstats));
+	memset(&priv->pf_stats, 0, sizeof(priv->pf_stats));
 
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		priv->tx_ring[i]->bytes = 0;
@@ -2685,7 +2686,7 @@ void mlx4_en_update_pfc_stats_bitmap(struct mlx4_dev *dev,
 				     u8 rx_ppp, u8 rx_pause,
 				     u8 tx_ppp, u8 tx_pause)
 {
-	int last_i = NUM_MAIN_STATS + NUM_PORT_STATS;
+	int last_i = NUM_MAIN_STATS + NUM_PORT_STATS + NUM_PF_STATS;
 
 	if (!mlx4_is_slave(dev) &&
 	    (dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_FLOWSTATS_EN)) {
@@ -2747,6 +2748,11 @@ void mlx4_en_set_stats_bitmap(struct mlx4_dev *dev,
 	bitmap_set(stats_bitmap->bitmap, last_i, NUM_PORT_STATS);
 	last_i += NUM_PORT_STATS;
 
+	if (mlx4_is_master(dev))
+		bitmap_set(stats_bitmap->bitmap, last_i,
+			   NUM_PF_STATS);
+	last_i += NUM_PF_STATS;
+
 	mlx4_en_update_pfc_stats_bitmap(dev, stats_bitmap,
 					rx_ppp, rx_pause,
 					tx_ppp, tx_pause);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 0a56f01..73f6277 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -149,6 +149,7 @@ static unsigned long en_stats_adder(__be64 *start, __be64 *next, int num)
 
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 {
+	struct mlx4_counter tmp_counter_stats;
 	struct mlx4_en_stat_out_mbox *mlx4_en_stats;
 	struct mlx4_en_stat_out_flow_control_mbox *flowstats;
 	struct mlx4_en_priv *priv = netdev_priv(mdev->pndev[port]);
@@ -156,7 +157,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	struct mlx4_cmd_mailbox *mailbox;
 	u64 in_mod = reset << 8 | port;
 	int err;
-	int i;
+	int i, counter_index;
 
 	mailbox = mlx4_alloc_cmd_mailbox(mdev->dev);
 	if (IS_ERR(mailbox))
@@ -296,6 +297,11 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 
 	spin_unlock_bh(&priv->stats_lock);
 
+	memset(&tmp_counter_stats, 0, sizeof(tmp_counter_stats));
+	counter_index = mlx4_get_default_counter_index(mdev->dev, port);
+	err = mlx4_get_counter_stats(mdev->dev, counter_index,
+				     &tmp_counter_stats, reset);
+
 	/* 0xffs indicates invalid value */
 	memset(mailbox->buf, 0xff, sizeof(*flowstats) * MLX4_NUM_PRIORITIES);
 
@@ -314,6 +320,13 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 
 	spin_lock_bh(&priv->stats_lock);
 
+	if (tmp_counter_stats.counter_mode == 0) {
+		priv->pf_stats.rx_bytes   = be64_to_cpu(tmp_counter_stats.rx_bytes);
+		priv->pf_stats.tx_bytes   = be64_to_cpu(tmp_counter_stats.tx_bytes);
+		priv->pf_stats.rx_packets = be64_to_cpu(tmp_counter_stats.rx_frames);
+		priv->pf_stats.tx_packets = be64_to_cpu(tmp_counter_stats.tx_frames);
+	}
+
 	for (i = 0; i < MLX4_NUM_PRIORITIES; i++)	{
 		priv->rx_priority_flowstats[i].rx_pause =
 			be64_to_cpu(flowstats[i].rx_pause);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index f6c3e12..d5f9adb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -566,6 +566,7 @@ struct mlx4_en_priv {
 #endif
 	struct mlx4_en_perf_stats pstats;
 	struct mlx4_en_pkt_stats pkstats;
+	struct mlx4_en_counter_stats pf_stats;
 	struct mlx4_en_flow_stats_rx rx_priority_flowstats[MLX4_NUM_PRIORITIES];
 	struct mlx4_en_flow_stats_tx tx_priority_flowstats[MLX4_NUM_PRIORITIES];
 	struct mlx4_en_flow_stats_rx rx_flowstats;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
index 0055583..c5c1de9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
@@ -23,6 +23,14 @@ struct mlx4_en_pkt_stats {
 #define NUM_PKT_STATS		43
 };
 
+struct mlx4_en_counter_stats {
+	unsigned long rx_packets;
+	unsigned long rx_bytes;
+	unsigned long tx_packets;
+	unsigned long tx_bytes;
+#define NUM_PF_STATS      4
+};
+
 struct mlx4_en_port_stats {
 	unsigned long tso_packets;
 	unsigned long xmit_more;
@@ -71,7 +79,8 @@ struct mlx4_en_flow_stats_tx {
 
 #define NUM_FLOW_STATS (NUM_FLOW_STATS_RX + NUM_FLOW_STATS_TX + \
 			NUM_FLOW_PRIORITY_STATS_TX + \
-			NUM_FLOW_PRIORITY_STATS_RX)
+			NUM_FLOW_PRIORITY_STATS_RX + \
+			NUM_PF_STATS)
 
 struct mlx4_en_stat_out_flow_control_mbox {
 	/* Total number of PAUSE frames received from the far-end port */
-- 
1.7.1
