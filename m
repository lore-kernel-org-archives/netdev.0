From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 1/6] net/mlx5e: Use a spinlock to synchronize statistics
Date: Fri, 12 May 2017 14:56:45 +0300
Message-ID: <20170512115650.11635-2-saeedm@mellanox.com>
References: <20170512115650.11635-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        kernel-team@fb.com, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51200 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755599AbdELMCD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 08:02:03 -0400
In-Reply-To: <20170512115650.11635-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Add a spinlock to prevent races when querying statistics, for example
querying counters in the middle of a non atomic memcpy() operation in
mlx5e_update_stats().

This RW lock should be held when accessing priv->stats, to prevent other
reads/writes.

Fixes: 9218b44dcc05 ("net/mlx5e: Statistics handling refactoring")
Signed-off-by: Gal Pressman <galp@mellanox.com>
Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: kernel-team@fb.com
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  1 +
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 12 ++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 45 ++++++++++++++++------
 3 files changed, 44 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 0099a3e397bc..c41cf7e82795 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -756,6 +756,7 @@ struct mlx5e_priv {
 	struct mlx5_core_dev      *mdev;
 	struct net_device         *netdev;
 	struct mlx5e_stats         stats;
+	rwlock_t                   stats_lock;
 	struct mlx5e_tstamp        tstamp;
 	u16 q_counter;
 #ifdef CONFIG_MLX5_CORE_EN_DCB
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index ce7b09d72ff6..0a7734761ece 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -305,6 +305,7 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 	struct mlx5_priv *mlx5_priv;
 	int i, j, tc, prio, idx = 0;
 	unsigned long pfc_combined;
+	bool global_pause;
 
 	if (!data)
 		return;
@@ -313,8 +314,11 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
 		mlx5e_update_stats(priv);
 	channels = &priv->channels;
+	pfc_combined = mlx5e_query_pfc_combined(priv);
+	global_pause = mlx5e_query_global_pause_combined(priv);
 	mutex_unlock(&priv->state_lock);
 
+	read_lock(&priv->stats_lock);
 	for (i = 0; i < NUM_SW_COUNTERS; i++)
 		data[idx++] = MLX5E_READ_CTR64_CPU(&priv->stats.sw,
 						   sw_stats_desc, i);
@@ -353,7 +357,6 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 						 pport_per_prio_traffic_stats_desc, i);
 	}
 
-	pfc_combined = mlx5e_query_pfc_combined(priv);
 	for_each_set_bit(prio, &pfc_combined, NUM_PPORT_PRIO) {
 		for (i = 0; i < NUM_PPORT_PER_PRIO_PFC_COUNTERS; i++) {
 			data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.per_prio_counters[prio],
@@ -361,7 +364,7 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 		}
 	}
 
-	if (mlx5e_query_global_pause_combined(priv)) {
+	if (global_pause) {
 		for (i = 0; i < NUM_PPORT_PER_PRIO_PFC_COUNTERS; i++) {
 			data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.per_prio_counters[0],
 							  pport_per_prio_pfc_stats_desc, i);
@@ -379,7 +382,7 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 						   mlx5e_pme_error_desc, i);
 
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
-		return;
+		goto out;
 
 	/* per channel counters */
 	for (i = 0; i < channels->num; i++)
@@ -393,6 +396,9 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 			for (j = 0; j < NUM_SQ_STATS; j++)
 				data[idx++] = MLX5E_READ_CTR64_CPU(&channels->c[i]->sq[tc].stats,
 								   sq_stats_desc, j);
+
+out:
+	read_unlock(&priv->stats_lock);
 }
 
 static u32 mlx5e_rx_wqes_to_packets(struct mlx5e_priv *priv, int rq_wq_type,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index a61b71b6fff3..7ac6bcc0e227 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -166,6 +166,13 @@ static void mlx5e_tx_timeout_work(struct work_struct *work)
 	rtnl_unlock();
 }
 
+#define MLX5E_STATS_WRITE(priv, name, s)                            \
+	do {                                                        \
+		write_lock(&(priv)->stats_lock);                    \
+		memcpy(&(priv)->stats.name, (s), sizeof(*(s)));     \
+		write_unlock(&(priv)->stats_lock);                  \
+	} while (0)
+
 static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 {
 	struct mlx5e_sw_stats temp, *s = &temp;
@@ -222,17 +229,21 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 	s->tx_csum_partial = s->tx_packets - tx_offload_none - s->tx_csum_partial_inner;
 	s->rx_csum_unnecessary = s->rx_packets - s->rx_csum_none - s->rx_csum_complete;
 
+	read_lock(&priv->stats_lock);
 	s->link_down_events_phy = MLX5_GET(ppcnt_reg,
 				priv->stats.pport.phy_counters,
 				counter_set.phys_layer_cntrs.link_down_events);
-	memcpy(&priv->stats.sw, s, sizeof(*s));
+	read_unlock(&priv->stats_lock);
+
+	MLX5E_STATS_WRITE(priv, sw, s);
 }
 
 static void mlx5e_update_vport_counters(struct mlx5e_priv *priv)
 {
 	int outlen = MLX5_ST_SZ_BYTES(query_vport_counter_out);
-	u32 *out = (u32 *)priv->stats.vport.query_vport_out;
 	u32 in[MLX5_ST_SZ_DW(query_vport_counter_in)] = {0};
+	struct mlx5e_vport_stats          vstats;
+	u32 *out = (u32 *)vstats.query_vport_out;
 	struct mlx5_core_dev *mdev = priv->mdev;
 
 	MLX5_SET(query_vport_counter_in, in, opcode,
@@ -241,19 +252,22 @@ static void mlx5e_update_vport_counters(struct mlx5e_priv *priv)
 	MLX5_SET(query_vport_counter_in, in, other_vport, 0);
 
 	mlx5_cmd_exec(mdev, in, sizeof(in), out, outlen);
+
+	MLX5E_STATS_WRITE(priv, vport, &vstats);
 }
 
 static void mlx5e_update_pport_counters(struct mlx5e_priv *priv)
 {
-	struct mlx5e_pport_stats *pstats = &priv->stats.pport;
 	struct mlx5_core_dev *mdev = priv->mdev;
 	int sz = MLX5_ST_SZ_BYTES(ppcnt_reg);
-	int prio;
+	struct mlx5e_pport_stats *pstats;
 	void *out;
+	int prio;
 	u32 *in;
 
-	in = mlx5_vzalloc(sz);
-	if (!in)
+	in     = mlx5_vzalloc(sz);
+	pstats = mlx5_vzalloc(sizeof(*pstats));
+	if (!in || !pstats)
 		goto free_out;
 
 	MLX5_SET(ppcnt_reg, in, local_port, 1);
@@ -288,26 +302,31 @@ static void mlx5e_update_pport_counters(struct mlx5e_priv *priv)
 				     MLX5_REG_PPCNT, 0, 0);
 	}
 
+	MLX5E_STATS_WRITE(priv, pport, pstats);
+
 free_out:
 	kvfree(in);
+	kvfree(pstats);
 }
 
 static void mlx5e_update_q_counter(struct mlx5e_priv *priv)
 {
-	struct mlx5e_qcounter_stats *qcnt = &priv->stats.qcnt;
+	struct mlx5e_qcounter_stats qcnt;
 
 	if (!priv->q_counter)
 		return;
 
 	mlx5_core_query_out_of_buffer(priv->mdev, priv->q_counter,
-				      &qcnt->rx_out_of_buffer);
+				      &qcnt.rx_out_of_buffer);
+
+	MLX5E_STATS_WRITE(priv, qcnt, &qcnt);
 }
 
 static void mlx5e_update_pcie_counters(struct mlx5e_priv *priv)
 {
-	struct mlx5e_pcie_stats *pcie_stats = &priv->stats.pcie;
 	struct mlx5_core_dev *mdev = priv->mdev;
 	int sz = MLX5_ST_SZ_BYTES(mpcnt_reg);
+	struct mlx5e_pcie_stats pcie_stats;
 	void *out;
 	u32 *in;
 
@@ -318,10 +337,12 @@ static void mlx5e_update_pcie_counters(struct mlx5e_priv *priv)
 	if (!in)
 		return;
 
-	out = pcie_stats->pcie_perf_counters;
+	out = pcie_stats.pcie_perf_counters;
 	MLX5_SET(mpcnt_reg, in, grp, MLX5_PCIE_PERFORMANCE_COUNTERS_GROUP);
 	mlx5_core_access_reg(mdev, in, sz, out, sz, MLX5_REG_MPCNT, 0, 0);
 
+	MLX5E_STATS_WRITE(priv, pcie, &pcie_stats);
+
 	kvfree(in);
 }
 
@@ -3030,6 +3051,7 @@ mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	struct mlx5e_vport_stats *vstats = &priv->stats.vport;
 	struct mlx5e_pport_stats *pstats = &priv->stats.pport;
 
+	read_lock(&priv->stats_lock);
 	if (mlx5e_is_uplink_rep(priv)) {
 		stats->rx_packets = PPORT_802_3_GET(pstats, a_frames_received_ok);
 		stats->rx_bytes   = PPORT_802_3_GET(pstats, a_octets_received_ok);
@@ -3064,7 +3086,7 @@ mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	 */
 	stats->multicast =
 		VPORT_COUNTER_GET(vstats, received_eth_multicast.packets);
-
+	read_unlock(&priv->stats_lock);
 }
 
 static void mlx5e_set_rx_mode(struct net_device *dev)
@@ -3901,6 +3923,7 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 	mlx5e_build_nic_params(mdev, &priv->channels.params, profile->max_nch(mdev));
 
 	mutex_init(&priv->state_lock);
+	rwlock_init(&priv->stats_lock);
 
 	INIT_WORK(&priv->update_carrier_work, mlx5e_update_carrier_work);
 	INIT_WORK(&priv->set_rx_mode_work, mlx5e_set_rx_mode_work);
-- 
2.11.0
