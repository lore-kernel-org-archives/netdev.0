From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net V2 4/8] net/mlx5: E-Switch, Re-enable RoCE on mode change only after FDB destroy
Date: Sun, 29 Jan 2017 23:46:22 +0200
Message-ID: <20170129214626.21977-5-saeedm@mellanox.com>
References: <20170129214626.21977-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41593 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750836AbdA2Vqn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 16:46:43 -0500
In-Reply-To: <20170129214626.21977-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

We must re-enable RoCE on the e-switch management port (PF) only after destroying
the FDB in its switchdev/offloaded mode. Otherwise, when encapsulation is supported,
this re-enablement will fail.

Also, it's more natural and symmetric to disable RoCE on the PF before we create
the FDB under switchdev mode, so do that as well and revert if getting into error
during the mode change later.

Fixes: 9da34cd34e85 ('net/mlx5: Disable RoCE on the e-switch management [..]')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 29 ++++++++++++++--------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index c61bca138e65..595f7c7383b3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -675,9 +675,14 @@ int esw_offloads_init(struct mlx5_eswitch *esw, int nvports)
 	int vport;
 	int err;
 
+	/* disable PF RoCE so missed packets don't go through RoCE steering */
+	mlx5_dev_list_lock();
+	mlx5_remove_dev_by_protocol(esw->dev, MLX5_INTERFACE_PROTOCOL_IB);
+	mlx5_dev_list_unlock();
+
 	err = esw_create_offloads_fdb_table(esw, nvports);
 	if (err)
-		return err;
+		goto create_fdb_err;
 
 	err = esw_create_offloads_table(esw);
 	if (err)
@@ -697,11 +702,6 @@ int esw_offloads_init(struct mlx5_eswitch *esw, int nvports)
 			goto err_reps;
 	}
 
-	/* disable PF RoCE so missed packets don't go through RoCE steering */
-	mlx5_dev_list_lock();
-	mlx5_remove_dev_by_protocol(esw->dev, MLX5_INTERFACE_PROTOCOL_IB);
-	mlx5_dev_list_unlock();
-
 	return 0;
 
 err_reps:
@@ -718,6 +718,13 @@ int esw_offloads_init(struct mlx5_eswitch *esw, int nvports)
 
 create_ft_err:
 	esw_destroy_offloads_fdb_table(esw);
+
+create_fdb_err:
+	/* enable back PF RoCE */
+	mlx5_dev_list_lock();
+	mlx5_add_dev_by_protocol(esw->dev, MLX5_INTERFACE_PROTOCOL_IB);
+	mlx5_dev_list_unlock();
+
 	return err;
 }
 
@@ -725,11 +732,6 @@ static int esw_offloads_stop(struct mlx5_eswitch *esw)
 {
 	int err, err1, num_vfs = esw->dev->priv.sriov.num_vfs;
 
-	/* enable back PF RoCE */
-	mlx5_dev_list_lock();
-	mlx5_add_dev_by_protocol(esw->dev, MLX5_INTERFACE_PROTOCOL_IB);
-	mlx5_dev_list_unlock();
-
 	mlx5_eswitch_disable_sriov(esw);
 	err = mlx5_eswitch_enable_sriov(esw, num_vfs, SRIOV_LEGACY);
 	if (err) {
@@ -739,6 +741,11 @@ static int esw_offloads_stop(struct mlx5_eswitch *esw)
 			esw_warn(esw->dev, "Failed setting eswitch back to offloads, err %d\n", err);
 	}
 
+	/* enable back PF RoCE */
+	mlx5_dev_list_lock();
+	mlx5_add_dev_by_protocol(esw->dev, MLX5_INTERFACE_PROTOCOL_IB);
+	mlx5_dev_list_unlock();
+
 	return err;
 }
 
-- 
2.11.0
