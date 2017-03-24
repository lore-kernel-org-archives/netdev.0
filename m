From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 03/12] net/mlx5e: Single bfreg (UAR) for all mlx5e SQs and netdevs
Date: Sat, 25 Mar 2017 00:52:05 +0300
Message-ID: <20170324215214.25711-4-saeedm@mellanox.com>
References: <20170324215214.25711-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35746 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S936475AbdCXVw3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:52:29 -0400
In-Reply-To: <20170324215214.25711-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One is sufficient since Blue Flame is not supported anymore.
This will also come in handy for switchdev mode to save resources, since
VF representors will use same single UAR as well for their own SQs.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h        |  1 -
 drivers/net/ethernet/mellanox/mlx5/core/en_common.c |  9 +++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c   | 17 +++--------------
 include/linux/mlx5/driver.h                         |  1 +
 4 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 85261e9ccf4a..22e4bad03f05 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -483,7 +483,6 @@ struct mlx5e_sq {
 
 	/* control path */
 	struct mlx5_wq_ctrl        wq_ctrl;
-	struct mlx5_sq_bfreg	   bfreg;
 	struct mlx5e_channel      *channel;
 	int                        tc;
 	u32                        rate_limit;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
index bd898d8deda0..20bdbe685795 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
@@ -107,10 +107,18 @@ int mlx5e_create_mdev_resources(struct mlx5_core_dev *mdev)
 		goto err_dealloc_transport_domain;
 	}
 
+	err = mlx5_alloc_bfreg(mdev, &res->bfreg, false, false);
+	if (err) {
+		mlx5_core_err(mdev, "alloc bfreg failed, %d\n", err);
+		goto err_destroy_mkey;
+	}
+
 	INIT_LIST_HEAD(&mdev->mlx5e_res.td.tirs_list);
 
 	return 0;
 
+err_destroy_mkey:
+	mlx5_core_destroy_mkey(mdev, &res->mkey);
 err_dealloc_transport_domain:
 	mlx5_core_dealloc_transport_domain(mdev, res->td.tdn);
 err_dealloc_pd:
@@ -122,6 +130,7 @@ void mlx5e_destroy_mdev_resources(struct mlx5_core_dev *mdev)
 {
 	struct mlx5e_resources *res = &mdev->mlx5e_res;
 
+	mlx5_free_bfreg(mdev, &res->bfreg);
 	mlx5_core_destroy_mkey(mdev, &res->mkey);
 	mlx5_core_dealloc_transport_domain(mdev, res->td.tdn);
 	mlx5_core_dealloc_pd(mdev, res->pdn);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index f9bcbd277adb..49c1769d13b9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1016,18 +1016,14 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	sq->mkey_be   = c->mkey_be;
 	sq->channel   = c;
 	sq->tc        = tc;
+	sq->uar_map   = mdev->mlx5e_res.bfreg.map;
 
-	err = mlx5_alloc_bfreg(mdev, &sq->bfreg, false, false);
-	if (err)
-		return err;
-
-	sq->uar_map = sq->bfreg.map;
 	param->wq.db_numa_node = cpu_to_node(c->cpu);
 
 	err = mlx5_wq_cyc_create(mdev, &param->wq, sqc_wq, &sq->wq,
 				 &sq->wq_ctrl);
 	if (err)
-		goto err_unmap_free_uar;
+		return err;
 
 	sq->wq.db       = &sq->wq.db[MLX5_SND_DBR];
 
@@ -1053,20 +1049,13 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 err_sq_wq_destroy:
 	mlx5_wq_destroy(&sq->wq_ctrl);
 
-err_unmap_free_uar:
-	mlx5_free_bfreg(mdev, &sq->bfreg);
-
 	return err;
 }
 
 static void mlx5e_destroy_sq(struct mlx5e_sq *sq)
 {
-	struct mlx5e_channel *c = sq->channel;
-	struct mlx5e_priv *priv = c->priv;
-
 	mlx5e_free_sq_db(sq);
 	mlx5_wq_destroy(&sq->wq_ctrl);
-	mlx5_free_bfreg(priv->mdev, &sq->bfreg);
 }
 
 static int mlx5e_enable_sq(struct mlx5e_sq *sq, struct mlx5e_sq_param *param)
@@ -1103,7 +1092,7 @@ static int mlx5e_enable_sq(struct mlx5e_sq *sq, struct mlx5e_sq_param *param)
 	MLX5_SET(sqc,  sqc, tis_lst_sz, param->type == MLX5E_SQ_ICO ? 0 : 1);
 
 	MLX5_SET(wq,   wq, wq_type,       MLX5_WQ_TYPE_CYCLIC);
-	MLX5_SET(wq,   wq, uar_page,      sq->bfreg.index);
+	MLX5_SET(wq,   wq, uar_page,      mdev->mlx5e_res.bfreg.index);
 	MLX5_SET(wq,   wq, log_wq_pg_sz,  sq->wq_ctrl.buf.page_shift -
 					  MLX5_ADAPTER_PAGE_SHIFT);
 	MLX5_SET64(wq, wq, dbr_addr,      sq->wq_ctrl.db.dma);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 2fcff6b4503f..f50864626230 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -728,6 +728,7 @@ struct mlx5e_resources {
 	u32                        pdn;
 	struct mlx5_td             td;
 	struct mlx5_core_mkey      mkey;
+	struct mlx5_sq_bfreg       bfreg;
 };
 
 struct mlx5_core_dev {
-- 
2.11.0
