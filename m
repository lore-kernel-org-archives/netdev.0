From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 07/16] net/mlx5e: IPoIB, RSS flow steering tables
Date: Thu, 13 Apr 2017 06:36:57 +0300
Message-ID: <20170413033706.19016-8-saeedm@mellanox.com>
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

Like the mlx5e ethernet mode, on IPoIB mode we need to create RX steering
tables, but IPoIB do not require MAC and VLAN steering tables so the
only tables we create in here are:
1. TTC Table (Traffic Type Classifier table for RSS steering)
2. ARFS Table (for accelerated RFS support)

Creation of those tables is identical to mlx5e ethernet mode, hence the
use of mlx5e_create_ttc_table and mlx5e_arfs_create_tables.

Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h    |  4 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c |  7 ++--
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c | 46 +++++++++++++++++++++++++
 3 files changed, 54 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index e5518536d56f..c813eab5d764 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -999,6 +999,7 @@ int mlx5e_attr_get(struct net_device *dev, struct switchdev_attr *attr);
 void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
 void mlx5e_update_hw_rep_counters(struct mlx5e_priv *priv);
 
+/* common netdev helpers */
 int mlx5e_create_indirect_rqt(struct mlx5e_priv *priv);
 
 int mlx5e_create_indirect_tirs(struct mlx5e_priv *priv);
@@ -1010,6 +1011,9 @@ int mlx5e_create_direct_tirs(struct mlx5e_priv *priv);
 void mlx5e_destroy_direct_tirs(struct mlx5e_priv *priv);
 void mlx5e_destroy_rqt(struct mlx5e_priv *priv, struct mlx5e_rqt *rqt);
 
+int mlx5e_create_ttc_table(struct mlx5e_priv *priv, u32 underlay_qpn);
+void mlx5e_destroy_ttc_table(struct mlx5e_priv *priv);
+
 int mlx5e_create_tises(struct mlx5e_priv *priv);
 void mlx5e_cleanup_nic_tx(struct mlx5e_priv *priv);
 int mlx5e_close(struct net_device *netdev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index 729904c43801..576d6787b484 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -792,7 +792,7 @@ static int mlx5e_create_ttc_table_groups(struct mlx5e_ttc_table *ttc)
 	return err;
 }
 
-static void mlx5e_destroy_ttc_table(struct mlx5e_priv *priv)
+void mlx5e_destroy_ttc_table(struct mlx5e_priv *priv)
 {
 	struct mlx5e_ttc_table *ttc = &priv->fs.ttc;
 
@@ -800,7 +800,7 @@ static void mlx5e_destroy_ttc_table(struct mlx5e_priv *priv)
 	mlx5e_destroy_flow_table(&ttc->ft);
 }
 
-static int mlx5e_create_ttc_table(struct mlx5e_priv *priv)
+int mlx5e_create_ttc_table(struct mlx5e_priv *priv, u32 underlay_qpn)
 {
 	struct mlx5e_ttc_table *ttc = &priv->fs.ttc;
 	struct mlx5_flow_table_attr ft_attr = {};
@@ -810,6 +810,7 @@ static int mlx5e_create_ttc_table(struct mlx5e_priv *priv)
 	ft_attr.max_fte = MLX5E_TTC_TABLE_SIZE;
 	ft_attr.level = MLX5E_TTC_FT_LEVEL;
 	ft_attr.prio = MLX5E_NIC_PRIO;
+	ft_attr.underlay_qpn = underlay_qpn;
 
 	ft->t = mlx5_create_flow_table(priv->fs.ns, &ft_attr);
 	if (IS_ERR(ft->t)) {
@@ -1146,7 +1147,7 @@ int mlx5e_create_flow_steering(struct mlx5e_priv *priv)
 		priv->netdev->hw_features &= ~NETIF_F_NTUPLE;
 	}
 
-	err = mlx5e_create_ttc_table(priv);
+	err = mlx5e_create_ttc_table(priv, 0);
 	if (err) {
 		netdev_err(priv->netdev, "Failed to create ttc table, err=%d\n",
 			   err);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
index f0318920844e..e16e1c7b246e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
@@ -72,6 +72,45 @@ static void mlx5i_cleanup_tx(struct mlx5e_priv *priv)
 {
 }
 
+static int mlx5i_create_flow_steering(struct mlx5e_priv *priv)
+{
+	struct mlx5i_priv *ipriv = priv->ppriv;
+	int err;
+
+	priv->fs.ns = mlx5_get_flow_namespace(priv->mdev,
+					       MLX5_FLOW_NAMESPACE_KERNEL);
+
+	if (!priv->fs.ns)
+		return -EINVAL;
+
+	err = mlx5e_arfs_create_tables(priv);
+	if (err) {
+		netdev_err(priv->netdev, "Failed to create arfs tables, err=%d\n",
+			   err);
+		priv->netdev->hw_features &= ~NETIF_F_NTUPLE;
+	}
+
+	err = mlx5e_create_ttc_table(priv, ipriv->qp.qpn);
+	if (err) {
+		netdev_err(priv->netdev, "Failed to create ttc table, err=%d\n",
+			   err);
+		goto err_destroy_arfs_tables;
+	}
+
+	return 0;
+
+err_destroy_arfs_tables:
+	mlx5e_arfs_destroy_tables(priv);
+
+	return err;
+}
+
+static void mlx5i_destroy_flow_steering(struct mlx5e_priv *priv)
+{
+	mlx5e_destroy_ttc_table(priv);
+	mlx5e_arfs_destroy_tables(priv);
+}
+
 static int mlx5i_init_rx(struct mlx5e_priv *priv)
 {
 	int err;
@@ -92,8 +131,14 @@ static int mlx5i_init_rx(struct mlx5e_priv *priv)
 	if (err)
 		goto err_destroy_indirect_tirs;
 
+	err = mlx5i_create_flow_steering(priv);
+	if (err)
+		goto err_destroy_direct_tirs;
+
 	return 0;
 
+err_destroy_direct_tirs:
+	mlx5e_destroy_direct_tirs(priv);
 err_destroy_indirect_tirs:
 	mlx5e_destroy_indirect_tirs(priv);
 err_destroy_direct_rqts:
@@ -105,6 +150,7 @@ static int mlx5i_init_rx(struct mlx5e_priv *priv)
 
 static void mlx5i_cleanup_rx(struct mlx5e_priv *priv)
 {
+	mlx5i_destroy_flow_steering(priv);
 	mlx5e_destroy_direct_tirs(priv);
 	mlx5e_destroy_indirect_tirs(priv);
 	mlx5e_destroy_direct_rqts(priv);
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
