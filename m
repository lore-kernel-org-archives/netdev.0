From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 2/7] net/mlx5e: Support HW (offloaded) and SW counters for SRIOV switchdev mode
Date: Mon, 21 Nov 2016 15:05:56 +0200
Message-ID: <1479733561-26601-3-git-send-email-saeedm@mellanox.com>
References: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46980 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932327AbcKUNHV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 08:07:21 -0500
In-Reply-To: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Switchdev driver net-device port statistics should follow the model introduced
in commit a5ea31f57309 'Merge branch net-offloaded-stats'.

For VF reps we return the SRIOV eswitch vport stats as the usual ones and SW stats
if asked. For the PF, if we're in the switchdev mode, we return the uplink stats
and SW stats if asked, otherwise as before. The uplink stats are implemented using
the PPCNT 802_3 counters which are already being read/cached by the driver.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   9 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  31 +++---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   | 111 +++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |   1 +
 4 files changed, 128 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index ac09767..ebf5dbc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -874,6 +874,7 @@ int mlx5e_add_sqs_fwd_rules(struct mlx5e_priv *priv);
 void mlx5e_remove_sqs_fwd_rules(struct mlx5e_priv *priv);
 int mlx5e_attr_get(struct net_device *dev, struct switchdev_attr *attr);
 void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
+void mlx5e_update_hw_rep_counters(struct mlx5e_priv *priv);
 
 int mlx5e_create_direct_rqts(struct mlx5e_priv *priv);
 void mlx5e_destroy_rqt(struct mlx5e_priv *priv, struct mlx5e_rqt *rqt);
@@ -890,12 +891,16 @@ struct net_device *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
 void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *priv);
 int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev);
 void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev);
-struct rtnl_link_stats64 *
-mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats);
 u32 mlx5e_choose_lro_timeout(struct mlx5_core_dev *mdev, u32 wanted_timeout);
 void mlx5e_add_vxlan_port(struct net_device *netdev,
 			  struct udp_tunnel_info *ti);
 void mlx5e_del_vxlan_port(struct net_device *netdev,
 			  struct udp_tunnel_info *ti);
 
+int mlx5e_get_offload_stats(int attr_id, const struct net_device *dev,
+			    void *sp);
+bool mlx5e_has_offload_stats(const struct net_device *dev, int attr_id);
+
+bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv);
+bool mlx5e_is_vf_vport_rep(struct mlx5e_priv *priv);
 #endif /* __MLX5_EN_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index bd0732d..480875f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -470,16 +470,6 @@ static void mlx5e_rq_free_mpwqe_info(struct mlx5e_rq *rq)
 	kfree(rq->mpwqe.info);
 }
 
-static bool mlx5e_is_vf_vport_rep(struct mlx5e_priv *priv)
-{
-	struct mlx5_eswitch_rep *rep = (struct mlx5_eswitch_rep *)priv->ppriv;
-
-	if (rep && rep->vport != FDB_UPLINK_VPORT)
-		return true;
-
-	return false;
-}
-
 static int mlx5e_create_rq(struct mlx5e_channel *c,
 			   struct mlx5e_rq_param *param,
 			   struct mlx5e_rq *rq)
@@ -2659,7 +2649,7 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 	return mlx5e_setup_tc(dev, tc->tc);
 }
 
-struct rtnl_link_stats64 *
+static struct rtnl_link_stats64 *
 mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
@@ -2667,13 +2657,20 @@ mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	struct mlx5e_vport_stats *vstats = &priv->stats.vport;
 	struct mlx5e_pport_stats *pstats = &priv->stats.pport;
 
-	stats->rx_packets = sstats->rx_packets;
-	stats->rx_bytes   = sstats->rx_bytes;
-	stats->tx_packets = sstats->tx_packets;
-	stats->tx_bytes   = sstats->tx_bytes;
+	if (mlx5e_is_uplink_rep(priv)) {
+		stats->rx_packets = PPORT_802_3_GET(pstats, a_frames_received_ok);
+		stats->rx_bytes   = PPORT_802_3_GET(pstats, a_octets_received_ok);
+		stats->tx_packets = PPORT_802_3_GET(pstats, a_frames_transmitted_ok);
+		stats->tx_bytes   = PPORT_802_3_GET(pstats, a_octets_transmitted_ok);
+	} else {
+		stats->rx_packets = sstats->rx_packets;
+		stats->rx_bytes   = sstats->rx_bytes;
+		stats->tx_packets = sstats->tx_packets;
+		stats->tx_bytes   = sstats->tx_bytes;
+		stats->tx_dropped = sstats->tx_queue_dropped;
+	}
 
 	stats->rx_dropped = priv->stats.qcnt.rx_out_of_buffer;
-	stats->tx_dropped = sstats->tx_queue_dropped;
 
 	stats->rx_length_errors =
 		PPORT_802_3_GET(pstats, a_in_range_length_errors) +
@@ -3276,6 +3273,8 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller     = mlx5e_netpoll,
 #endif
+	.ndo_has_offload_stats	 = mlx5e_has_offload_stats,
+	.ndo_get_offload_stats	 = mlx5e_get_offload_stats,
 };
 
 static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index a84825d..e0d1a56 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -72,7 +72,29 @@ static void mlx5e_rep_get_strings(struct net_device *dev,
 	}
 }
 
-static void mlx5e_update_sw_rep_counters(struct mlx5e_priv *priv)
+static void mlx5e_rep_update_hw_counters(struct mlx5e_priv *priv)
+{
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct rtnl_link_stats64 *vport_stats;
+	struct ifla_vf_stats vf_stats;
+	int err;
+
+	err = mlx5_eswitch_get_vport_stats(esw, rep->vport, &vf_stats);
+	if (err) {
+		pr_warn("vport %d error %d reading stats\n", rep->vport, err);
+		return;
+	}
+
+	vport_stats = &priv->stats.vf_vport;
+	/* flip tx/rx as we are reporting the counters for the switch vport */
+	vport_stats->rx_packets = vf_stats.tx_packets;
+	vport_stats->rx_bytes   = vf_stats.tx_bytes;
+	vport_stats->tx_packets = vf_stats.rx_packets;
+	vport_stats->tx_bytes   = vf_stats.rx_bytes;
+}
+
+static void mlx5e_rep_update_sw_counters(struct mlx5e_priv *priv)
 {
 	struct mlx5e_sw_stats *s = &priv->stats.sw;
 	struct mlx5e_rq_stats *rq_stats;
@@ -95,6 +117,12 @@ static void mlx5e_update_sw_rep_counters(struct mlx5e_priv *priv)
 	}
 }
 
+static void mlx5e_rep_update_stats(struct mlx5e_priv *priv)
+{
+	mlx5e_rep_update_sw_counters(priv);
+	mlx5e_rep_update_hw_counters(priv);
+}
+
 static void mlx5e_rep_get_ethtool_stats(struct net_device *dev,
 					struct ethtool_stats *stats, u64 *data)
 {
@@ -106,7 +134,7 @@ static void mlx5e_rep_get_ethtool_stats(struct net_device *dev,
 
 	mutex_lock(&priv->state_lock);
 	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
-		mlx5e_update_sw_rep_counters(priv);
+		mlx5e_rep_update_sw_counters(priv);
 	mutex_unlock(&priv->state_lock);
 
 	for (i = 0; i < NUM_VPORT_REP_COUNTERS; i++)
@@ -245,6 +273,77 @@ static int mlx5e_rep_ndo_setup_tc(struct net_device *dev, u32 handle,
 	}
 }
 
+bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv)
+{
+	struct mlx5_eswitch_rep *rep = (struct mlx5_eswitch_rep *)priv->ppriv;
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+
+	if (rep && rep->vport == FDB_UPLINK_VPORT && esw->mode == SRIOV_OFFLOADS)
+		return true;
+
+	return false;
+}
+
+bool mlx5e_is_vf_vport_rep(struct mlx5e_priv *priv)
+{
+	struct mlx5_eswitch_rep *rep = (struct mlx5_eswitch_rep *)priv->ppriv;
+
+	if (rep && rep->vport != FDB_UPLINK_VPORT)
+		return true;
+
+	return false;
+}
+
+bool mlx5e_has_offload_stats(const struct net_device *dev, int attr_id)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	switch (attr_id) {
+	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
+		if (mlx5e_is_vf_vport_rep(priv) || mlx5e_is_uplink_rep(priv))
+			return true;
+	}
+
+	return false;
+}
+
+static int
+mlx5e_get_sw_stats64(const struct net_device *dev,
+		     struct rtnl_link_stats64 *stats)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5e_sw_stats *sstats = &priv->stats.sw;
+
+	stats->rx_packets = sstats->rx_packets;
+	stats->rx_bytes   = sstats->rx_bytes;
+	stats->tx_packets = sstats->tx_packets;
+	stats->tx_bytes   = sstats->tx_bytes;
+
+	stats->tx_dropped = sstats->tx_queue_dropped;
+
+	return 0;
+}
+
+int mlx5e_get_offload_stats(int attr_id, const struct net_device *dev,
+			    void *sp)
+{
+	switch (attr_id) {
+	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
+		return mlx5e_get_sw_stats64(dev, sp);
+	}
+
+	return -EINVAL;
+}
+
+static struct rtnl_link_stats64 *
+mlx5e_rep_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	memcpy(stats, &priv->stats.vf_vport, sizeof(*stats));
+	return stats;
+}
+
 static const struct switchdev_ops mlx5e_rep_switchdev_ops = {
 	.switchdev_port_attr_get	= mlx5e_attr_get,
 };
@@ -255,9 +354,9 @@ static const struct net_device_ops mlx5e_netdev_ops_rep = {
 	.ndo_start_xmit          = mlx5e_xmit,
 	.ndo_get_phys_port_name  = mlx5e_rep_get_phys_port_name,
 	.ndo_setup_tc            = mlx5e_rep_ndo_setup_tc,
-	.ndo_get_stats64         = mlx5e_get_stats,
-	.ndo_udp_tunnel_add	 = mlx5e_add_vxlan_port,
-	.ndo_udp_tunnel_del	 = mlx5e_del_vxlan_port,
+	.ndo_get_stats64         = mlx5e_rep_get_stats,
+	.ndo_has_offload_stats	 = mlx5e_has_offload_stats,
+	.ndo_get_offload_stats	 = mlx5e_get_offload_stats,
 };
 
 static void mlx5e_build_rep_netdev_priv(struct mlx5_core_dev *mdev,
@@ -407,7 +506,7 @@ static struct mlx5e_profile mlx5e_rep_profile = {
 	.cleanup_rx		= mlx5e_cleanup_rep_rx,
 	.init_tx		= mlx5e_init_rep_tx,
 	.cleanup_tx		= mlx5e_cleanup_nic_tx,
-	.update_stats           = mlx5e_update_sw_rep_counters,
+	.update_stats           = mlx5e_rep_update_stats,
 	.max_nch		= mlx5e_get_rep_max_num_channels,
 	.max_tc			= 1,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 5da6a1c..f202f87 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -407,6 +407,7 @@ struct mlx5e_stats {
 	struct mlx5e_vport_stats vport;
 	struct mlx5e_pport_stats pport;
 	struct mlx5e_pcie_stats pcie;
+	struct rtnl_link_stats64 vf_vport;
 };
 
 static const struct counter_desc mlx5e_pme_status_desc[] = {
-- 
2.7.4
