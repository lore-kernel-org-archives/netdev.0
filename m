From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH RFC net-next 2/4] net/mlx5e: NIC netdev init flow cleanup
Date: Thu,  8 Jun 2017 02:42:12 +0300
Message-ID: <20170607234214.24723-3-saeedm@mellanox.com>
References: <20170607234214.24723-1-saeedm@mellanox.com>
Cc: kernel-team@fb.com, Or Gerlitz <ogerlitz@mellanox.com>,
        Tzahi Oved <tzahio@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: netdev@vger.kernel.org, Jes Sorensen <jsorensen@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35133 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752995AbdFGXt3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 19:49:29 -0400
In-Reply-To: <20170607234214.24723-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove redundant mlx5_eswitch_unregister_vport_rep in mlx5e_add error
flow.

Hide mlx5e_rep_priv and eswitch internal structures from en_main.c in
preparation for downstream patches which allows compiling the driver
without en_rep and eswitch.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 20 ++++++--------------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 13 +++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.h  |  1 +
 3 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 931347b797c4..1514027a5c51 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -4357,32 +4357,28 @@ static void mlx5e_detach(struct mlx5_core_dev *mdev, void *vpriv)
 
 static void *mlx5e_add(struct mlx5_core_dev *mdev)
 {
-	struct mlx5_eswitch *esw = mdev->priv.eswitch;
-	int total_vfs = MLX5_TOTAL_VPORTS(mdev);
-	struct mlx5e_rep_priv *rpriv = NULL;
+	struct net_device *netdev;
+	void *rpriv = NULL;
 	void *priv;
-	int vport;
 	int err;
-	struct net_device *netdev;
 
 	err = mlx5e_check_required_hca_cap(mdev);
 	if (err)
 		return NULL;
 
 	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
-		rpriv = kzalloc(sizeof(*rpriv), GFP_KERNEL);
+		rpriv = mlx5e_alloc_nic_rep_priv(mdev);
 		if (!rpriv) {
-			mlx5_core_warn(mdev,
-				       "Not creating net device, Failed to alloc rep priv data\n");
+			mlx5_core_warn(mdev, "Failed to alloc NIC rep priv data\n");
 			return NULL;
 		}
-		rpriv->rep = &esw->offloads.vport_reps[0];
 	}
 
 	netdev = mlx5e_create_netdev(mdev, &mlx5e_nic_profile, rpriv);
 	if (!netdev) {
 		mlx5_core_err(mdev, "mlx5e_create_netdev failed\n");
-		goto err_unregister_reps;
+		kfree(rpriv);
+		return NULL;
 	}
 
 	priv = netdev_priv(netdev);
@@ -4407,10 +4403,6 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
 err_destroy_netdev:
 	mlx5e_destroy_netdev(priv);
 
-err_unregister_reps:
-	for (vport = 1; vport < total_vfs; vport++)
-		mlx5_eswitch_unregister_vport_rep(esw, vport);
-
 	kfree(rpriv);
 	return NULL;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 79462c0368a0..8d673d61cd11 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -1089,3 +1089,16 @@ void mlx5e_unregister_vport_reps(struct mlx5e_priv *priv)
 	mlx5e_rep_unregister_vf_vports(priv); /* VFs vports */
 	mlx5_eswitch_unregister_vport_rep(esw, 0); /* UPLINK PF*/
 }
+
+void* mlx5e_alloc_nic_rep_priv(struct mlx5_core_dev *mdev)
+{
+	struct mlx5_eswitch *esw = mdev->priv.eswitch;
+	struct mlx5e_rep_priv *rpriv;
+
+	rpriv = kzalloc(sizeof(*rpriv), GFP_KERNEL);
+	if (!rpriv)
+		return NULL;
+
+	rpriv->rep = &esw->offloads.vport_reps[0];
+	return rpriv;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
index a0a1a7a1d6c0..23e43bbf928d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
@@ -123,6 +123,7 @@ struct mlx5e_encap_entry {
 	int encap_size;
 };
 
+void *mlx5e_alloc_nic_rep_priv(struct mlx5_core_dev *mdev);
 void mlx5e_register_vport_reps(struct mlx5e_priv *priv);
 void mlx5e_unregister_vport_reps(struct mlx5e_priv *priv);
 bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv);
-- 
2.11.0
