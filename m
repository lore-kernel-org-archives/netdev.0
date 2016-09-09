From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 07/11] net/mlx5: Align sriov/eswitch modules with the new load/unload flow.
Date: Fri,  9 Sep 2016 17:35:23 +0300
Message-ID: <1473431727-20150-8-git-send-email-saeedm@mellanox.com>
References: <1473431727-20150-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Moahamd Haj Yahia <mohamad@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35494 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752789AbcIIOg7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 10:36:59 -0400
In-Reply-To: <1473431727-20150-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Init/cleanup sriov/eswitch in the core software context init/cleanup
flows.
Attach/detach sriov/eswitch in the core load/unload flows.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c |  2 --
 drivers/net/ethernet/mellanox/mlx5/core/main.c    | 42 +++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c   |  4 +--
 3 files changed, 34 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 24058894..015f1bfe 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1654,7 +1654,6 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 	esw->enabled_vports = 0;
 	esw->mode = SRIOV_NONE;
 
-	mlx5_eswitch_attach(esw);
 	dev->priv.eswitch = esw;
 	return 0;
 abort:
@@ -1675,7 +1674,6 @@ void mlx5_eswitch_cleanup(struct mlx5_eswitch *esw)
 
 	esw_info(esw->dev, "cleanup\n");
 
-	mlx5_eswitch_detach(esw);
 	esw->dev->priv.eswitch = NULL;
 	destroy_workqueue(esw->work_queue);
 	kfree(esw->l2_table.bitmap);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 966647f..16660cf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1136,8 +1136,30 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 		goto err_tables_cleanup;
 	}
 
+#ifdef CONFIG_MLX5_CORE_EN
+	err = mlx5_eswitch_init(dev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to init eswitch %d\n", err);
+		goto err_rl_cleanup;
+	}
+#endif
+
+	err = mlx5_sriov_init(dev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to init sriov %d\n", err);
+		goto err_eswitch_cleanup;
+	}
+
 	return 0;
 
+err_eswitch_cleanup:
+#ifdef CONFIG_MLX5_CORE_EN
+	mlx5_eswitch_cleanup(dev->priv.eswitch);
+
+err_rl_cleanup:
+#endif
+	mlx5_cleanup_rl_table(dev);
+
 err_tables_cleanup:
 	mlx5_cleanup_mkey_table(dev);
 	mlx5_cleanup_srq_table(dev);
@@ -1153,6 +1175,10 @@ out:
 
 static void mlx5_cleanup_once(struct mlx5_core_dev *dev)
 {
+	mlx5_sriov_cleanup(dev);
+#ifdef CONFIG_MLX5_CORE_EN
+	mlx5_eswitch_cleanup(dev->priv.eswitch);
+#endif
 	mlx5_cleanup_rl_table(dev);
 	mlx5_cleanup_mkey_table(dev);
 	mlx5_cleanup_srq_table(dev);
@@ -1293,14 +1319,10 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	}
 
 #ifdef CONFIG_MLX5_CORE_EN
-	err = mlx5_eswitch_init(dev);
-	if (err) {
-		dev_err(&pdev->dev, "eswitch init failed %d\n", err);
-		goto err_reg_dev;
-	}
+	mlx5_eswitch_attach(dev->priv.eswitch);
 #endif
 
-	err = mlx5_sriov_init(dev);
+	err = mlx5_sriov_attach(dev);
 	if (err) {
 		dev_err(&pdev->dev, "sriov init failed %d\n", err);
 		goto err_sriov;
@@ -1324,11 +1346,11 @@ out:
 	return 0;
 
 err_reg_dev:
-	mlx5_sriov_cleanup(dev);
+	mlx5_sriov_detach(dev);
 
 err_sriov:
 #ifdef CONFIG_MLX5_CORE_EN
-	mlx5_eswitch_cleanup(dev->priv.eswitch);
+	mlx5_eswitch_detach(dev->priv.eswitch);
 #endif
 	mlx5_cleanup_fs(dev);
 
@@ -1394,9 +1416,9 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	if (mlx5_device_registered(dev))
 		mlx5_detach_device(dev);
 
-	mlx5_sriov_cleanup(dev);
+	mlx5_sriov_detach(dev);
 #ifdef CONFIG_MLX5_CORE_EN
-	mlx5_eswitch_cleanup(dev->priv.eswitch);
+	mlx5_eswitch_detach(dev->priv.eswitch);
 #endif
 	mlx5_cleanup_fs(dev);
 	mlx5_irq_clear_affinity_hints(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
index f4f02b6..e086277 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
@@ -222,7 +222,7 @@ int mlx5_sriov_init(struct mlx5_core_dev *dev)
 	if (!sriov->vfs_ctx)
 		return -ENOMEM;
 
-	return mlx5_sriov_attach(dev);
+	return 0;
 }
 
 void mlx5_sriov_cleanup(struct mlx5_core_dev *dev)
@@ -231,6 +231,6 @@ void mlx5_sriov_cleanup(struct mlx5_core_dev *dev)
 
 	if (!mlx5_core_is_pf(dev))
 		return;
-	mlx5_sriov_detach(dev);
+
 	kfree(sriov->vfs_ctx);
 }
-- 
2.7.4
