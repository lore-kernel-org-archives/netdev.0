From: Erez Shitrit <erezsh@mellanox.com>
Subject: [RFC v1 for accelerated IPoIB 08/25] net/mlx5e: Refactor EN code to support IB link
Date: Mon, 13 Mar 2017 20:31:19 +0200
Message-ID: <1489429896-10781-9-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il, Erez Shitrit <erezsh@mellanox.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49723 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752806AbdCMScB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:32:01 -0400
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The idea is to use the same infrastructures for both ETH and IB link
types, so the first step is to refactor the ETH handling to be able to
use IB link as well.

1. Check requirments for ETH and for IB
2. Move code to common functions, where it will be used for both link
types.
3. Change init and cleanup flows not to be specific for ETH link.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 120 ++++++++++++++--------
 1 file changed, 80 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 041e0ac16096..88541f99d37b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3323,29 +3323,39 @@ static void mlx5e_netpoll(struct net_device *dev)
 	.ndo_get_offload_stats	 = mlx5e_get_offload_stats,
 };
 
-static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
-{
-	if (MLX5_CAP_GEN(mdev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
-		return -EOPNOTSUPP;
-	if (!MLX5_CAP_GEN(mdev, eth_net_offloads) ||
-	    !MLX5_CAP_GEN(mdev, nic_flow_table) ||
-	    !MLX5_CAP_ETH(mdev, csum_cap) ||
-	    !MLX5_CAP_ETH(mdev, max_lso_cap) ||
-	    !MLX5_CAP_ETH(mdev, vlan_cap) ||
-	    !MLX5_CAP_ETH(mdev, rss_ind_tbl_cap) ||
-	    MLX5_CAP_FLOWTABLE(mdev,
-			       flow_table_properties_nic_receive.max_ft_level)
-			       < 3) {
-		mlx5_core_warn(mdev,
-			       "Not creating net device, some required device capabilities are missing\n");
-		return -EOPNOTSUPP;
+static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev,
+					int link_type)
+{
+	if (link_type == MLX5_INTERFACE_PROTOCOL_ETH) {
+		if (!MLX5_CAP_GEN(mdev, eth_net_offloads) ||
+		    !MLX5_CAP_GEN(mdev, nic_flow_table) ||
+		    !MLX5_CAP_ETH(mdev, csum_cap) ||
+		    !MLX5_CAP_ETH(mdev, max_lso_cap) ||
+		    !MLX5_CAP_ETH(mdev, vlan_cap) ||
+		    !MLX5_CAP_ETH(mdev, rss_ind_tbl_cap) ||
+		    MLX5_CAP_FLOWTABLE(mdev,
+				       flow_table_properties_nic_receive.max_ft_level)
+				       < 3) {
+			mlx5_core_warn(mdev,
+				       "Not creating net device, some required device capabilities are missing\n");
+			return -ENOTSUPP;
+		}
+		if (!MLX5_CAP_ETH(mdev, self_lb_en_modifiable))
+			mlx5_core_warn(mdev, "Self loop back prevention is not supported\n");
+		if (!MLX5_CAP_GEN(mdev, cq_moderation))
+			mlx5_core_warn(mdev, "CQ modiration is not supported\n");
+
+		return 0;
+	} else if (link_type == MLX5_INTERFACE_PROTOCOL_IB) {
+		if (!MLX5_CAP_GEN(mdev, ipoib_enhanced_offloads)) {
+			pr_warn("Not creating net device (IB), some required device capabilities are missing\n");
+			return -ENOTSUPP;
+		}
+		return 0;
 	}
-	if (!MLX5_CAP_ETH(mdev, self_lb_en_modifiable))
-		mlx5_core_warn(mdev, "Self loop back prevention is not supported\n");
-	if (!MLX5_CAP_GEN(mdev, cq_moderation))
-		mlx5_core_warn(mdev, "CQ modiration is not supported\n");
 
-	return 0;
+	return -ENOTSUPP;
+
 }
 
 u16 mlx5e_get_max_inline_cap(struct mlx5_core_dev *mdev)
@@ -3455,12 +3465,12 @@ u32 mlx5e_choose_lro_timeout(struct mlx5_core_dev *mdev, u32 wanted_timeout)
 	return MLX5_CAP_ETH(mdev, lro_timer_supported_periods[i]);
 }
 
-static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
+void mlx5n_build_nic_netdev_priv_common(struct mlx5_core_dev *mdev,
 					struct net_device *netdev,
+					struct mlx5e_priv *priv,
 					const struct mlx5e_profile *profile,
 					void *ppriv)
 {
-	struct mlx5e_priv *priv = netdev_priv(netdev);
 	u32 link_speed = 0;
 	u32 pci_bw = 0;
 	u8 cq_period_mode = MLX5_CAP_GEN(mdev, cq_period_start_from_cqe) ?
@@ -3524,6 +3534,15 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS, priv->params.rx_cqe_compress_def);
 
 	mutex_init(&priv->state_lock);
+}
+
+static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
+					struct net_device *netdev,
+					struct mlx5e_priv *priv,
+					const struct mlx5e_profile *profile,
+					void *ppriv)
+{
+	mlx5n_build_nic_netdev_priv_common(mdev, netdev, priv, profile, ppriv);
 
 	INIT_WORK(&priv->update_carrier_work, mlx5e_update_carrier_work);
 	INIT_WORK(&priv->set_rx_mode_work, mlx5e_set_rx_mode_work);
@@ -3663,7 +3682,7 @@ static void mlx5e_nic_init(struct mlx5_core_dev *mdev,
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
-	mlx5e_build_nic_netdev_priv(mdev, netdev, profile, ppriv);
+	mlx5e_build_nic_netdev_priv(mdev, netdev, priv, profile, ppriv);
 	mlx5e_build_nic_netdev(netdev);
 	mlx5e_vxlan_init(priv);
 }
@@ -3676,7 +3695,8 @@ static void mlx5e_nic_cleanup(struct mlx5e_priv *priv)
 		bpf_prog_put(priv->xdp_prog);
 }
 
-static int mlx5e_init_nic_rx(struct mlx5e_priv *priv)
+/* used for ETH && IB link layer */
+static int mlx5n_init_nic_rx_common(struct mlx5e_priv *priv)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
 	int err;
@@ -3706,20 +3726,12 @@ static int mlx5e_init_nic_rx(struct mlx5e_priv *priv)
 		goto err_destroy_indirect_tirs;
 	}
 
-	err = mlx5e_create_flow_steering(priv);
-	if (err) {
-		mlx5_core_warn(mdev, "create flow steering failed, %d\n", err);
-		goto err_destroy_direct_tirs;
-	}
-
 	err = mlx5e_tc_init(priv);
 	if (err)
-		goto err_destroy_flow_steering;
+		goto err_destroy_direct_tirs;
 
 	return 0;
 
-err_destroy_flow_steering:
-	mlx5e_destroy_flow_steering(priv);
 err_destroy_direct_tirs:
 	mlx5e_destroy_direct_tirs(priv);
 err_destroy_indirect_tirs:
@@ -3732,12 +3744,31 @@ static int mlx5e_init_nic_rx(struct mlx5e_priv *priv)
 	return err;
 }
 
-static void mlx5e_cleanup_nic_rx(struct mlx5e_priv *priv)
+static int mlx5e_init_nic_rx(struct mlx5e_priv *priv)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	int err;
+
+	err = mlx5n_init_nic_rx_common(priv);
+	if (err) {
+		mlx5_core_warn(mdev, "failed create nic rx res, %d\n", err);
+		return err;
+	}
+
+	err = mlx5e_create_flow_steering(priv);
+	if (err) {
+		mlx5_core_warn(mdev, "create flow steering failed, %d\n", err);
+		return err;
+	}
+
+	return 0;
+}
+
+static void mlx5n_cleanup_nic_rx_common(struct mlx5e_priv *priv)
 {
 	int i;
 
 	mlx5e_tc_cleanup(priv);
-	mlx5e_destroy_flow_steering(priv);
 	mlx5e_destroy_direct_tirs(priv);
 	mlx5e_destroy_indirect_tirs(priv);
 	for (i = 0; i < priv->profile->max_nch(priv->mdev); i++)
@@ -3745,6 +3776,12 @@ static void mlx5e_cleanup_nic_rx(struct mlx5e_priv *priv)
 	mlx5e_destroy_rqt(priv, &priv->indir_rqt);
 }
 
+static void mlx5e_cleanup_nic_rx(struct mlx5e_priv *priv)
+{
+	mlx5e_destroy_flow_steering(priv);
+	mlx5n_cleanup_nic_rx_common(priv);
+}
+
 static int mlx5e_init_nic_tx(struct mlx5e_priv *priv)
 {
 	int err;
@@ -3836,7 +3873,8 @@ struct net_device *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
 		return NULL;
 	}
 
-	profile->init(mdev, netdev, profile, ppriv);
+	if (profile->init)
+		profile->init(mdev, netdev, profile, ppriv);
 
 	netif_carrier_off(netdev);
 
@@ -3849,7 +3887,9 @@ struct net_device *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
 	return netdev;
 
 err_cleanup_nic:
-	profile->cleanup(priv);
+	if (profile->cleanup)
+		profile->cleanup(priv);
+
 	free_netdev(netdev);
 
 	return NULL;
@@ -3881,7 +3921,7 @@ int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
 		goto err_close_drop_rq;
 
 	mlx5e_create_q_counter(priv);
-
+	//TBD do i need to change that?
 	mlx5e_init_l2_addr(priv);
 
 	/* MTU range: 68 - hw-specific max */
@@ -4006,7 +4046,7 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
 	int err;
 	struct net_device *netdev;
 
-	err = mlx5e_check_required_hca_cap(mdev);
+	err = mlx5e_check_required_hca_cap(mdev, MLX5_INTERFACE_PROTOCOL_ETH);
 	if (err)
 		return NULL;
 
-- 
1.8.3.1
