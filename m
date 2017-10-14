From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 09/12] net/mlx5e: IPoIB, Add PKEY child interface nic profile
Date: Sat, 14 Oct 2017 11:48:24 -0700
Message-ID: <20171014184827.18491-10-saeedm@mellanox.com>
References: <20171014184827.18491-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Alex Vesker <valex@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43384 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751716AbdJNSs5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 14:48:57 -0400
In-Reply-To: <20171014184827.18491-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Vesker <valex@mellanox.com>

Child interface profile will be called to support child interface
specific behaviour. The child code is sparse compared to the parent
since the RX channels are shared between the interfaces.
Creating a septate profile for child and parent will make a smother
code with a better ability for future expansion.
The profile stuct is exposed to the parent using a getter function.

Signed-off-by: Alex Vesker <valex@mellanox.com>
Reviewed-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c  | 12 ++--
 .../net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h  | 13 ++++
 .../ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c | 83 ++++++++++++++++++++++
 3 files changed, 102 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
index c479fe54a6ca..196771cc599e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
@@ -70,10 +70,10 @@ static void mlx5i_build_nic_params(struct mlx5_core_dev *mdev,
 }
 
 /* Called directly after IPoIB netdevice was created to initialize SW structs */
-static void mlx5i_init(struct mlx5_core_dev *mdev,
-		       struct net_device *netdev,
-		       const struct mlx5e_profile *profile,
-		       void *ppriv)
+void mlx5i_init(struct mlx5_core_dev *mdev,
+		struct net_device *netdev,
+		const struct mlx5e_profile *profile,
+		void *ppriv)
 {
 	struct mlx5e_priv *priv  = mlx5i_epriv(netdev);
 
@@ -169,7 +169,7 @@ static void mlx5i_uninit_underlay_qp(struct mlx5e_priv *priv)
 
 #define MLX5_QP_ENHANCED_ULP_STATELESS_MODE 2
 
-static int mlx5i_create_underlay_qp(struct mlx5_core_dev *mdev, struct mlx5_core_qp *qp)
+int mlx5i_create_underlay_qp(struct mlx5_core_dev *mdev, struct mlx5_core_qp *qp)
 {
 	u32 *in = NULL;
 	void *addr_path;
@@ -203,7 +203,7 @@ static int mlx5i_create_underlay_qp(struct mlx5_core_dev *mdev, struct mlx5_core
 	return ret;
 }
 
-static void mlx5i_destroy_underlay_qp(struct mlx5_core_dev *mdev, struct mlx5_core_qp *qp)
+void mlx5i_destroy_underlay_qp(struct mlx5_core_dev *mdev, struct mlx5_core_qp *qp)
 {
 	mlx5_core_destroy_qp(mdev, qp);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
index e313f6d90729..c9895f7a2358 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
@@ -55,6 +55,10 @@ struct mlx5i_priv {
 	char  *mlx5e_priv[0];
 };
 
+/* Underlay QP create/destroy functions */
+int mlx5i_create_underlay_qp(struct mlx5_core_dev *mdev, struct mlx5_core_qp *qp);
+void mlx5i_destroy_underlay_qp(struct mlx5_core_dev *mdev, struct mlx5_core_qp *qp);
+
 /* Allocate/Free underlay QPN to net-device hash table */
 int mlx5i_pkey_qpn_ht_init(struct net_device *netdev);
 void mlx5i_pkey_qpn_ht_cleanup(struct net_device *netdev);
@@ -66,6 +70,15 @@ int mlx5i_pkey_del_qpn(struct net_device *netdev, u32 qpn);
 /* Get the net-device corresponding to the given underlay QPN */
 struct net_device *mlx5i_pkey_get_netdev(struct net_device *netdev, u32 qpn);
 
+/* Parent profile functions */
+void mlx5i_init(struct mlx5_core_dev *mdev,
+		struct net_device *netdev,
+		const struct mlx5e_profile *profile,
+		void *ppriv);
+
+/* Get child interface nic profile */
+const struct mlx5e_profile *mlx5i_pkey_get_profile(void);
+
 /* Extract mlx5e_priv from IPoIB netdev */
 #define mlx5i_epriv(netdev) ((void *)(((struct mlx5i_priv *)netdev_priv(netdev))->mlx5e_priv))
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c
index e4d39aa1f552..17c508d98dbb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c
@@ -134,3 +134,86 @@ struct net_device *mlx5i_pkey_get_netdev(struct net_device *netdev, u32 qpn)
 
 	return node->netdev;
 }
+
+/* Called directly after IPoIB netdevice was created to initialize SW structs */
+static void mlx5i_pkey_init(struct mlx5_core_dev *mdev,
+			     struct net_device *netdev,
+			     const struct mlx5e_profile *profile,
+			     void *ppriv)
+{
+	struct mlx5e_priv *priv  = mlx5i_epriv(netdev);
+
+	mlx5i_init(mdev, netdev, profile, ppriv);
+
+	/* Override parent ndo */
+	netdev->netdev_ops = NULL;
+
+	/* Currently no ethtool support */
+	netdev->ethtool_ops = NULL;
+
+	/* Use dummy rqs */
+	priv->channels.params.log_rq_size = MLX5E_PARAMS_MINIMUM_LOG_RQ_SIZE;
+}
+
+/* Called directly before IPoIB netdevice is destroyed to cleanup SW structs */
+static void mlx5i_pkey_cleanup(struct mlx5e_priv *priv)
+{
+	/* Do nothing .. */
+}
+
+static int mlx5i_pkey_init_tx(struct mlx5e_priv *priv)
+{
+	struct mlx5i_priv *ipriv = priv->ppriv;
+	int err;
+
+	err = mlx5i_create_underlay_qp(priv->mdev, &ipriv->qp);
+	if (err) {
+		mlx5_core_warn(priv->mdev, "create child underlay QP failed, %d\n", err);
+		return err;
+	}
+
+	return 0;
+}
+
+static void mlx5i_pkey_cleanup_tx(struct mlx5e_priv *priv)
+{
+	struct mlx5i_priv *ipriv = priv->ppriv;
+
+	mlx5i_destroy_underlay_qp(priv->mdev, &ipriv->qp);
+}
+
+static int mlx5i_pkey_init_rx(struct mlx5e_priv *priv)
+{
+	/* Since the rx resources are shared between child and parent, the
+	 * parent interface is taking care of rx resource allocation and init
+	 */
+	return 0;
+}
+
+static void mlx5i_pkey_cleanup_rx(struct mlx5e_priv *priv)
+{
+	/* Since the rx resources are shared between child and parent, the
+	 * parent interface is taking care of rx resource free and de-init
+	 */
+}
+
+static const struct mlx5e_profile mlx5i_pkey_nic_profile = {
+	.init		   = mlx5i_pkey_init,
+	.cleanup	   = mlx5i_pkey_cleanup,
+	.init_tx	   = mlx5i_pkey_init_tx,
+	.cleanup_tx	   = mlx5i_pkey_cleanup_tx,
+	.init_rx	   = mlx5i_pkey_init_rx,
+	.cleanup_rx	   = mlx5i_pkey_cleanup_rx,
+	.enable		   = NULL,
+	.disable	   = NULL,
+	.update_stats	   = NULL,
+	.max_nch	   = mlx5e_get_max_num_channels,
+	.rx_handlers.handle_rx_cqe       = mlx5i_handle_rx_cqe,
+	.rx_handlers.handle_rx_cqe_mpwqe = NULL, /* Not supported */
+	.max_tc		   = MLX5I_MAX_NUM_TC,
+};
+
+const struct mlx5e_profile *mlx5i_pkey_get_profile(void)
+{
+	return &mlx5i_pkey_nic_profile;
+}
-- 
2.14.2
