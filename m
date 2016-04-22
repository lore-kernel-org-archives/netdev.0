From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 05/12] net/mlx5e: Add link down events counter
Date: Fri, 22 Apr 2016 22:00:40 +0300
Message-ID: <1461351647-27412-6-git-send-email-saeedm@mellanox.com>
References: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36877 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751690AbcDVTCB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 15:02:01 -0400
In-Reply-To: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Expose link_down_events counter through ethtool -S.
This counter is read from PPort statistics, then proccessed and stored as
a special handling software counter.
This counter is stored along software counters since it is the only PPort
counter that it's size is not 64 bits.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   10 +++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |    5 +++++
 include/linux/mlx5/device.h                        |    1 +
 3 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index ef66ba6..61e261c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -135,6 +135,10 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 	s->tx_csum_offload = s->tx_packets - tx_offload_none - s->tx_csum_inner;
 	s->rx_csum_good    = s->rx_packets - s->rx_csum_none -
 			     s->rx_csum_sw;
+
+	s->link_down_events = MLX5_GET(ppcnt_reg,
+				priv->stats.pport.phy_counters,
+				counter_set.phys_layer_cntrs.link_down_events);
 }
 
 static void mlx5e_update_vport_counters(struct mlx5e_priv *priv)
@@ -183,6 +187,10 @@ static void mlx5e_update_pport_counters(struct mlx5e_priv *priv)
 	MLX5_SET(ppcnt_reg, in, grp, MLX5_RFC_2819_COUNTERS_GROUP);
 	mlx5_core_access_reg(mdev, in, sz, out, sz, MLX5_REG_PPCNT, 0, 0);
 
+	out = pstats->phy_counters;
+	MLX5_SET(ppcnt_reg, in, grp, MLX5_PHYSICAL_LAYER_COUNTERS_GROUP);
+	mlx5_core_access_reg(mdev, in, sz, out, sz, MLX5_REG_PPCNT, 0, 0);
+
 	MLX5_SET(ppcnt_reg, in, grp, MLX5_PER_PRIORITY_COUNTERS_GROUP);
 	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
 		out = pstats->per_prio_counters[prio];
@@ -208,10 +216,10 @@ static void mlx5e_update_q_counter(struct mlx5e_priv *priv)
 
 void mlx5e_update_stats(struct mlx5e_priv *priv)
 {
-	mlx5e_update_sw_counters(priv);
 	mlx5e_update_q_counter(priv);
 	mlx5e_update_vport_counters(priv);
 	mlx5e_update_pport_counters(priv);
+	mlx5e_update_sw_counters(priv);
 }
 
 static void mlx5e_update_stats_work(struct work_struct *work)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index de27eea..7cd8cb4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -71,6 +71,9 @@ struct mlx5e_sw_stats {
 	u64 rx_mpwqe_filler;
 	u64 rx_mpwqe_frag;
 	u64 rx_buff_alloc_err;
+
+	/* Special handling counters */
+	u64 link_down_events;
 };
 
 static const struct counter_desc sw_stats_desc[] = {
@@ -96,6 +99,7 @@ static const struct counter_desc sw_stats_desc[] = {
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_mpwqe_filler) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_mpwqe_frag) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_buff_alloc_err) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, link_down_events) },
 };
 
 struct mlx5e_qcounter_stats {
@@ -178,6 +182,7 @@ struct mlx5e_pport_stats {
 	__be64 RFC_2863_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
 	__be64 RFC_2819_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
 	__be64 per_prio_counters[NUM_PPORT_PRIO][MLX5_ST_SZ_QW(ppcnt_reg)];
+	__be64 phy_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
 };
 
 static const struct counter_desc pport_802_3_stats_desc[] = {
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 8be44ca..942bcca 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1369,6 +1369,7 @@ enum {
 	MLX5_ETHERNET_EXTENDED_COUNTERS_GROUP = 0x5,
 	MLX5_PER_PRIORITY_COUNTERS_GROUP      = 0x10,
 	MLX5_PER_TRAFFIC_CLASS_COUNTERS_GROUP = 0x11,
+	MLX5_PHYSICAL_LAYER_COUNTERS_GROUP    = 0x12,
 	MLX5_INFINIBAND_PORT_COUNTERS_GROUP   = 0x20,
 };
 
-- 
1.7.1
