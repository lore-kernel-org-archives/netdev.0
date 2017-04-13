From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 09/16] net/mlx5e: IPoIB, Basic netdev ndos open/close
Date: Thu, 13 Apr 2017 06:36:59 +0300
Message-ID: <20170413033706.19016-10-saeedm@mellanox.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Vishwanathapura Niranjana <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170413033706.19016-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Implement open/close of IPoIB netdevice ndos using mlx5e's
channels API to manage data path resources (RQs/SQs/CQs).

Set IPoIB netdev address on dev_init ndo.

Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c   | 90 ++++++++++++++++++++++-
 3 files changed, 93 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 5345d875b695..23b92ec54e12 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -883,6 +883,8 @@ typedef int (*mlx5e_fp_hw_modify)(struct mlx5e_priv *priv);
 void mlx5e_switch_priv_channels(struct mlx5e_priv *priv,
 				struct mlx5e_channels *new_chs,
 				mlx5e_fp_hw_modify hw_modify);
+void mlx5e_activate_priv_channels(struct mlx5e_priv *priv);
+void mlx5e_deactivate_priv_channels(struct mlx5e_priv *priv);
 
 void mlx5e_build_default_indir_rqt(struct mlx5_core_dev *mdev,
 				   u32 *indirection_rqt, int len,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 1fde4e2301a4..eb657987e9b5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2547,7 +2547,7 @@ static void mlx5e_build_channels_tx_maps(struct mlx5e_priv *priv)
 	}
 }
 
-static void mlx5e_activate_priv_channels(struct mlx5e_priv *priv)
+void mlx5e_activate_priv_channels(struct mlx5e_priv *priv)
 {
 	int num_txqs = priv->channels.num * priv->channels.params.num_tc;
 	struct net_device *netdev = priv->netdev;
@@ -2567,7 +2567,7 @@ static void mlx5e_activate_priv_channels(struct mlx5e_priv *priv)
 	mlx5e_redirect_rqts_to_channels(priv, &priv->channels);
 }
 
-static void mlx5e_deactivate_priv_channels(struct mlx5e_priv *priv)
+void mlx5e_deactivate_priv_channels(struct mlx5e_priv *priv)
 {
 	mlx5e_redirect_rqts_to_drop(priv);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
index d7d705c840ae..e188d067bc97 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
@@ -34,6 +34,18 @@
 #include "en.h"
 #include "ipoib.h"
 
+static int mlx5i_open(struct net_device *netdev);
+static int mlx5i_close(struct net_device *netdev);
+static int  mlx5i_dev_init(struct net_device *dev);
+static void mlx5i_dev_cleanup(struct net_device *dev);
+
+static const struct net_device_ops mlx5i_netdev_ops = {
+	.ndo_open                = mlx5i_open,
+	.ndo_stop                = mlx5i_close,
+	.ndo_init                = mlx5i_dev_init,
+	.ndo_uninit              = mlx5i_dev_cleanup,
+};
+
 /* IPoIB mlx5 netdev profile */
 
 /* Called directly after IPoIB netdevice was created to initialize SW structs */
@@ -52,7 +64,17 @@ static void mlx5i_init(struct mlx5_core_dev *mdev,
 	mlx5e_build_nic_params(mdev, &priv->channels.params, profile->max_nch(mdev));
 
 	mutex_init(&priv->state_lock);
-	/* TODO : init netdev features here */
+
+	netdev->hw_features    |= NETIF_F_SG;
+	netdev->hw_features    |= NETIF_F_IP_CSUM;
+	netdev->hw_features    |= NETIF_F_IPV6_CSUM;
+	netdev->hw_features    |= NETIF_F_GRO;
+	netdev->hw_features    |= NETIF_F_TSO;
+	netdev->hw_features    |= NETIF_F_TSO6;
+	netdev->hw_features    |= NETIF_F_RXCSUM;
+	netdev->hw_features    |= NETIF_F_RXHASH;
+
+	netdev->netdev_ops = &mlx5i_netdev_ops;
 }
 
 /* Called directly before IPoIB netdevice is destroyed to cleanup SW structs */
@@ -181,6 +203,72 @@ static const struct mlx5e_profile mlx5i_nic_profile = {
 	.max_tc		   = MLX5I_MAX_NUM_TC,
 };
 
+/* mlx5i netdev NDos */
+
+static int mlx5i_dev_init(struct net_device *dev)
+{
+	struct mlx5e_priv    *priv   = mlx5i_epriv(dev);
+	struct mlx5i_priv    *ipriv  = priv->ppriv;
+
+	/* Set dev address using underlay QP */
+	dev->dev_addr[1] = (ipriv->qp.qpn >> 16) & 0xff;
+	dev->dev_addr[2] = (ipriv->qp.qpn >>  8) & 0xff;
+	dev->dev_addr[3] = (ipriv->qp.qpn) & 0xff;
+
+	return 0;
+}
+
+static void mlx5i_dev_cleanup(struct net_device *dev)
+{
+	/* TODO: detach underlay qp from flow-steering by reset it */
+}
+
+static int mlx5i_open(struct net_device *netdev)
+{
+	struct mlx5e_priv *priv = mlx5i_epriv(netdev);
+	int err;
+
+	mutex_lock(&priv->state_lock);
+
+	set_bit(MLX5E_STATE_OPENED, &priv->state);
+
+	err = mlx5e_open_channels(priv, &priv->channels);
+	if (err)
+		goto err_clear_state_opened_flag;
+
+	mlx5e_refresh_tirs(priv, false);
+	mlx5e_activate_priv_channels(priv);
+	mutex_unlock(&priv->state_lock);
+	return 0;
+
+err_clear_state_opened_flag:
+	clear_bit(MLX5E_STATE_OPENED, &priv->state);
+	mutex_unlock(&priv->state_lock);
+	return err;
+}
+
+static int mlx5i_close(struct net_device *netdev)
+{
+	struct mlx5e_priv *priv = mlx5i_epriv(netdev);
+
+	/* May already be CLOSED in case a previous configuration operation
+	 * (e.g RX/TX queue size change) that involves close&open failed.
+	 */
+	mutex_lock(&priv->state_lock);
+
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
+		goto unlock;
+
+	clear_bit(MLX5E_STATE_OPENED, &priv->state);
+
+	netif_carrier_off(priv->netdev);
+	mlx5e_deactivate_priv_channels(priv);
+	mlx5e_close_channels(&priv->channels);
+unlock:
+	mutex_unlock(&priv->state_lock);
+	return 0;
+}
+
 /* IPoIB RDMA netdev callbacks */
 
 static int mlx5i_check_required_hca_cap(struct mlx5_core_dev *mdev)
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
