From: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [RFC v1 for accelerated IPoIB 17/25] net/mlx5e: Change mlx5e_open_locked and mlx5e_close_locked api
Date: Mon, 13 Mar 2017 20:31:28 +0200
Message-ID: <1489429896-10781-18-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Let the IB link to call it directly with the relevant priv.

Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  4 +--
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 24 ++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 31 +++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  4 +--
 4 files changed, 31 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index a10966df24f6..2f9242ae06f3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -797,8 +797,8 @@ int mlx5e_vlan_rx_kill_vid(struct net_device *dev, __always_unused __be16 proto,
 void mlx5e_build_indir_tir_ctx_hash(struct mlx5e_priv *priv, void *tirc,
 				    enum mlx5e_traffic_types tt);
 
-int mlx5e_open_locked(struct net_device *netdev);
-int mlx5e_close_locked(struct net_device *netdev);
+int mlx5e_open_locked(struct mlx5e_priv *priv);
+int mlx5e_close_locked(struct mlx5e_priv *priv);
 void mlx5e_build_default_indir_rqt(struct mlx5_core_dev *mdev,
 				   u32 *indirection_rqt, int len,
 				   int num_channels);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index bb67863aa361..0c8773718292 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -516,14 +516,14 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 
 	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
 	if (was_opened)
-		mlx5e_close_locked(dev);
+		mlx5e_close_locked(priv);
 
 	priv->params.log_rq_size = log_rq_size;
 	priv->params.log_sq_size = log_sq_size;
 	priv->params.min_rx_wqes = min_rx_wqes;
 
 	if (was_opened)
-		err = mlx5e_open_locked(dev);
+		err = mlx5e_open_locked(priv);
 
 	mutex_unlock(&priv->state_lock);
 
@@ -561,7 +561,7 @@ static int mlx5e_set_channels(struct net_device *dev,
 
 	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
 	if (was_opened)
-		mlx5e_close_locked(dev);
+		mlx5e_close_locked(priv);
 
 	arfs_enabled = dev->features & NETIF_F_NTUPLE;
 	if (arfs_enabled)
@@ -572,7 +572,7 @@ static int mlx5e_set_channels(struct net_device *dev,
 				      MLX5E_INDIR_RQT_SIZE, count);
 
 	if (was_opened)
-		err = mlx5e_open_locked(dev);
+		err = mlx5e_open_locked(priv);
 	if (err)
 		goto out;
 
@@ -626,7 +626,7 @@ static int mlx5e_set_coalesce(struct net_device *netdev,
 
 	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
 	if (was_opened && restart) {
-		mlx5e_close_locked(netdev);
+		mlx5e_close_locked(priv);
 		priv->params.rx_am_enabled = !!coal->use_adaptive_rx_coalesce;
 	}
 
@@ -655,7 +655,7 @@ static int mlx5e_set_coalesce(struct net_device *netdev,
 
 out:
 	if (was_opened && restart)
-		err = mlx5e_open_locked(netdev);
+		err = mlx5e_open_locked(priv);
 
 	mutex_unlock(&priv->state_lock);
 	return err;
@@ -1112,12 +1112,12 @@ static int mlx5e_set_tunable(struct net_device *dev,
 
 		was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
 		if (was_opened)
-			mlx5e_close_locked(dev);
+			mlx5e_close_locked(priv);
 
 		priv->params.tx_max_inline = val;
 
 		if (was_opened)
-			err = mlx5e_open_locked(dev);
+			err = mlx5e_open_locked(priv);
 
 		mutex_unlock(&priv->state_lock);
 		break;
@@ -1444,12 +1444,12 @@ static int set_pflag_rx_cqe_based_moder(struct net_device *netdev, bool enable)
 
 	reset = test_bit(MLX5E_STATE_OPENED, &priv->state);
 	if (reset)
-		mlx5e_close_locked(netdev);
+		mlx5e_close_locked(priv);
 
 	mlx5e_set_rx_cq_mode_params(&priv->params, rx_cq_period_mode);
 
 	if (reset)
-		err = mlx5e_open_locked(netdev);
+		err = mlx5e_open_locked(priv);
 
 	return err;
 }
@@ -1473,13 +1473,13 @@ static int set_pflag_rx_cqe_compress(struct net_device *netdev,
 	reset = test_bit(MLX5E_STATE_OPENED, &priv->state);
 
 	if (reset)
-		mlx5e_close_locked(netdev);
+		mlx5e_close_locked(priv);
 
 	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS, enable);
 	priv->params.rx_cqe_compress_def = enable;
 
 	if (reset)
-		err = mlx5e_open_locked(netdev);
+		err = mlx5e_open_locked(priv);
 	return err;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index b91bd7a179fc..ca1867cdce48 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -152,8 +152,8 @@ static void mlx5e_tx_timeout_work(struct work_struct *work)
 	mutex_lock(&priv->state_lock);
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
 		goto unlock;
-	mlx5e_close_locked(priv->netdev);
-	err = mlx5e_open_locked(priv->netdev);
+	mlx5e_close_locked(priv);
+	err = mlx5e_open_locked(priv);
 	if (err)
 		netdev_err(priv->netdev, "mlx5e_open_locked failed recovering from a tx_timeout, err(%d).\n",
 			   err);
@@ -2239,9 +2239,9 @@ static void mlx5e_netdev_set_tcs(struct net_device *netdev)
 		netdev_set_tc_queue(netdev, tc, nch, 0);
 }
 
-int mlx5e_open_locked(struct net_device *netdev)
+int mlx5e_open_locked(struct mlx5e_priv *priv)
 {
-	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct net_device *netdev = priv->netdev;
 	struct mlx5_core_dev *mdev = priv->mdev;
 	int num_txqs;
 	int err;
@@ -2297,15 +2297,14 @@ int mlx5e_open(struct net_device *netdev)
 	int err;
 
 	mutex_lock(&priv->state_lock);
-	err = mlx5e_open_locked(netdev);
+	err = mlx5e_open_locked(priv);
 	mutex_unlock(&priv->state_lock);
 
 	return err;
 }
 
-int mlx5e_close_locked(struct net_device *netdev)
+int mlx5e_close_locked(struct mlx5e_priv *priv)
 {
-	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 
 	/* May already be CLOSED in case a previous configuration operation
@@ -2336,7 +2335,7 @@ int mlx5e_close(struct net_device *netdev)
 		return -ENODEV;
 
 	mutex_lock(&priv->state_lock);
-	err = mlx5e_close_locked(netdev);
+	err = mlx5e_close_locked(priv);
 	mutex_unlock(&priv->state_lock);
 
 	return err;
@@ -2641,12 +2640,12 @@ static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
 
 	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
 	if (was_opened)
-		mlx5e_close_locked(priv->netdev);
+		mlx5e_close_locked(priv);
 
 	priv->params.num_tc = tc ? tc : 1;
 
 	if (was_opened)
-		err = mlx5e_open_locked(priv->netdev);
+		err = mlx5e_open_locked(priv);
 
 	mutex_unlock(&priv->state_lock);
 
@@ -2771,7 +2770,7 @@ static int set_feature_lro(struct net_device *netdev, bool enable)
 	mutex_lock(&priv->state_lock);
 
 	if (was_opened && (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST))
-		mlx5e_close_locked(priv->netdev);
+		mlx5e_close_locked(priv);
 
 	priv->params.lro_en = enable;
 	err = mlx5e_modify_tirs_lro(priv);
@@ -2781,7 +2780,7 @@ static int set_feature_lro(struct net_device *netdev, bool enable)
 	}
 
 	if (was_opened && (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST))
-		mlx5e_open_locked(priv->netdev);
+		mlx5e_open_locked(priv);
 
 	mutex_unlock(&priv->state_lock);
 
@@ -2915,13 +2914,13 @@ static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 
 	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
 	if (was_opened && reset)
-		mlx5e_close_locked(netdev);
+		mlx5e_close_locked(priv);
 
 	netdev->mtu = new_mtu;
 	mlx5e_set_dev_port_mtu(netdev);
 
 	if (was_opened && reset)
-		err = mlx5e_open_locked(netdev);
+		err = mlx5e_open_locked(priv);
 
 	mutex_unlock(&priv->state_lock);
 
@@ -3173,7 +3172,7 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 	reset = (!priv->xdp_prog || !prog);
 
 	if (was_opened && reset)
-		mlx5e_close_locked(netdev);
+		mlx5e_close_locked(priv);
 	if (was_opened && !reset) {
 		/* num_channels is invariant here, so we can take the
 		 * batched reference right upfront.
@@ -3196,7 +3195,7 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 		mlx5e_set_rq_priv_params(priv);
 
 	if (was_opened && reset)
-		mlx5e_open_locked(netdev);
+		mlx5e_open_locked(priv);
 
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state) || reset)
 		goto unlock;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 06d5e6fecb0a..ad08e64fee1a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -169,12 +169,12 @@ void mlx5e_modify_rx_cqe_compression(struct mlx5e_priv *priv, bool val)
 
 	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
 	if (was_opened)
-		mlx5e_close_locked(priv->netdev);
+		mlx5e_close_locked(priv);
 
 	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS, val);
 
 	if (was_opened)
-		mlx5e_open_locked(priv->netdev);
+		mlx5e_open_locked(priv);
 
 unlock:
 	mutex_unlock(&priv->state_lock);
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
