From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 08/16] net/mlx5e: IPoIB, TX TIS creation
Date: Thu, 13 Apr 2017 06:36:58 +0300
Message-ID: <20170413033706.19016-9-saeedm@mellanox.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
Cc: linux-rdma@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Erez Shitrit <erezsh@mellanox.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Vishwanathapura Niranjana <niranjana.vishwanathapura@intel.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41707 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755754AbdDMDhn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 23:37:43 -0400
In-Reply-To: <20170413033706.19016-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modify mlx5e tis creation function to accept underlay qp number, which
will be needed by IPoIB.

Implement mlx5i (IPoIB) tx init/cleanup netdevice profile flows to
create one TIS with the IPoIB underlay qp, for IPoIB TX SQs.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  4 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 18 ++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c   | 14 ++++++++++++--
 3 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index c813eab5d764..5345d875b695 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -1014,6 +1014,10 @@ void mlx5e_destroy_rqt(struct mlx5e_priv *priv, struct mlx5e_rqt *rqt);
 int mlx5e_create_ttc_table(struct mlx5e_priv *priv, u32 underlay_qpn);
 void mlx5e_destroy_ttc_table(struct mlx5e_priv *priv);
 
+int mlx5e_create_tis(struct mlx5_core_dev *mdev, int tc,
+		     u32 underlay_qpn, u32 *tisn);
+void mlx5e_destroy_tis(struct mlx5_core_dev *mdev, u32 tisn);
+
 int mlx5e_create_tises(struct mlx5e_priv *priv);
 void mlx5e_cleanup_nic_tx(struct mlx5e_priv *priv);
 int mlx5e_close(struct net_device *netdev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 08b67aa24644..1fde4e2301a4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2759,24 +2759,25 @@ static void mlx5e_close_drop_rq(struct mlx5e_rq *drop_rq)
 	mlx5e_free_cq(&drop_rq->cq);
 }
 
-static int mlx5e_create_tis(struct mlx5e_priv *priv, int tc)
+int mlx5e_create_tis(struct mlx5_core_dev *mdev, int tc,
+		     u32 underlay_qpn, u32 *tisn)
 {
-	struct mlx5_core_dev *mdev = priv->mdev;
 	u32 in[MLX5_ST_SZ_DW(create_tis_in)] = {0};
 	void *tisc = MLX5_ADDR_OF(create_tis_in, in, ctx);
 
 	MLX5_SET(tisc, tisc, prio, tc << 1);
+	MLX5_SET(tisc, tisc, underlay_qpn, underlay_qpn);
 	MLX5_SET(tisc, tisc, transport_domain, mdev->mlx5e_res.td.tdn);
 
 	if (mlx5_lag_is_lacp_owner(mdev))
 		MLX5_SET(tisc, tisc, strict_lag_tx_port_affinity, 1);
 
-	return mlx5_core_create_tis(mdev, in, sizeof(in), &priv->tisn[tc]);
+	return mlx5_core_create_tis(mdev, in, sizeof(in), tisn);
 }
 
-static void mlx5e_destroy_tis(struct mlx5e_priv *priv, int tc)
+void mlx5e_destroy_tis(struct mlx5_core_dev *mdev, u32 tisn)
 {
-	mlx5_core_destroy_tis(priv->mdev, priv->tisn[tc]);
+	mlx5_core_destroy_tis(mdev, tisn);
 }
 
 int mlx5e_create_tises(struct mlx5e_priv *priv)
@@ -2785,7 +2786,7 @@ int mlx5e_create_tises(struct mlx5e_priv *priv)
 	int tc;
 
 	for (tc = 0; tc < priv->profile->max_tc; tc++) {
-		err = mlx5e_create_tis(priv, tc);
+		err = mlx5e_create_tis(priv->mdev, tc, 0, &priv->tisn[tc]);
 		if (err)
 			goto err_close_tises;
 	}
@@ -2794,7 +2795,7 @@ int mlx5e_create_tises(struct mlx5e_priv *priv)
 
 err_close_tises:
 	for (tc--; tc >= 0; tc--)
-		mlx5e_destroy_tis(priv, tc);
+		mlx5e_destroy_tis(priv->mdev, priv->tisn[tc]);
 
 	return err;
 }
@@ -2804,7 +2805,7 @@ void mlx5e_cleanup_nic_tx(struct mlx5e_priv *priv)
 	int tc;
 
 	for (tc = 0; tc < priv->profile->max_tc; tc++)
-		mlx5e_destroy_tis(priv, tc);
+		mlx5e_destroy_tis(priv->mdev, priv->tisn[tc]);
 }
 
 static void mlx5e_build_indir_tir_ctx(struct mlx5e_priv *priv,
@@ -3841,6 +3842,7 @@ void mlx5e_build_nic_params(struct mlx5_core_dev *mdev,
 	mlx5e_set_rq_params(mdev, params);
 
 	/* HW LRO */
+	/* TODO: && MLX5_CAP_ETH(mdev, lro_cap) */
 	if (params->rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ)
 		params->lro_en = true;
 	params->lro_timeout = mlx5e_choose_lro_timeout(mdev, MLX5E_DEFAULT_LRO_TIMEOUT);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
index e16e1c7b246e..d7d705c840ae 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
@@ -63,13 +63,23 @@ static void mlx5i_cleanup(struct mlx5e_priv *priv)
 
 static int mlx5i_init_tx(struct mlx5e_priv *priv)
 {
+	struct mlx5i_priv *ipriv = priv->ppriv;
+	int err;
+
 	/* TODO: Create IPoIB underlay QP */
-	/* TODO: create IPoIB TX HW TIS */
+
+	err = mlx5e_create_tis(priv->mdev, 0 /* tc */, ipriv->qp.qpn, &priv->tisn[0]);
+	if (err) {
+		mlx5_core_warn(priv->mdev, "create tis failed, %d\n", err);
+		return err;
+	}
+
 	return 0;
 }
 
-static void mlx5i_cleanup_tx(struct mlx5e_priv *priv)
+void mlx5i_cleanup_tx(struct mlx5e_priv *priv)
 {
+	mlx5e_destroy_tis(priv->mdev, priv->tisn[0]);
 }
 
 static int mlx5i_create_flow_steering(struct mlx5e_priv *priv)
-- 
2.11.0
