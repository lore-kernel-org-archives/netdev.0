From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 09/10] net/mlx5: Fix global UAR mapping
Date: Sun, 28 Feb 2016 17:09:10 +0200
Message-ID: <1456672151-11749-10-git-send-email-saeedm@mellanox.com>
References: <1456672151-11749-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Moshe Lazer <moshel@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:59859 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757979AbcB1PKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 10:10:55 -0500
In-Reply-To: <1456672151-11749-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Lazer <moshel@mellanox.com>

Remove the global WC mapping of the total UARs since
UAR mapping should be decided per UAR (e.g we want
different mappings for EQs, CQs vs QPs).

We use ARCH_HAS_IOREMAP_WC to know if the current arch supports WC
(Write combining) IO memory mapping, if it is not supported
"uar->bf_map" will be NULL, thus we will use NC (Non Cached) mapping
"uar->map".

Fixes: 88a85f99e51f ('TX latency optimization to save DMA reads')
Signed-off-by: Moshe Lazer <moshel@mellanox.com>
Reviewed-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c |   28 +-----------------------
 drivers/net/ethernet/mellanox/mlx5/core/uar.c  |   12 +++++-----
 include/linux/mlx5/driver.h                    |    2 -
 3 files changed, 7 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 1545a94..8b7133d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -767,22 +767,6 @@ static int mlx5_core_set_issi(struct mlx5_core_dev *dev)
 	return -ENOTSUPP;
 }
 
-static int map_bf_area(struct mlx5_core_dev *dev)
-{
-	resource_size_t bf_start = pci_resource_start(dev->pdev, 0);
-	resource_size_t bf_len = pci_resource_len(dev->pdev, 0);
-
-	dev->priv.bf_mapping = io_mapping_create_wc(bf_start, bf_len);
-
-	return dev->priv.bf_mapping ? 0 : -ENOMEM;
-}
-
-static void unmap_bf_area(struct mlx5_core_dev *dev)
-{
-	if (dev->priv.bf_mapping)
-		io_mapping_free(dev->priv.bf_mapping);
-}
-
 static void mlx5_add_device(struct mlx5_interface *intf, struct mlx5_priv *priv)
 {
 	struct mlx5_device_context *dev_ctx;
@@ -1103,14 +1087,9 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 		goto err_stop_eqs;
 	}
 
-	if (map_bf_area(dev))
-		dev_err(&pdev->dev, "Failed to map blue flame area\n");
-
 	err = mlx5_irq_set_affinity_hints(dev);
-	if (err) {
+	if (err)
 		dev_err(&pdev->dev, "Failed to alloc affinity hint cpumask\n");
-		goto err_unmap_bf_area;
-	}
 
 	MLX5_INIT_DOORBELL_LOCK(&priv->cq_uar_lock);
 
@@ -1169,10 +1148,6 @@ err_fs:
 	mlx5_cleanup_qp_table(dev);
 	mlx5_cleanup_cq_table(dev);
 	mlx5_irq_clear_affinity_hints(dev);
-
-err_unmap_bf_area:
-	unmap_bf_area(dev);
-
 	free_comp_eqs(dev);
 
 err_stop_eqs:
@@ -1242,7 +1217,6 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	mlx5_cleanup_qp_table(dev);
 	mlx5_cleanup_cq_table(dev);
 	mlx5_irq_clear_affinity_hints(dev);
-	unmap_bf_area(dev);
 	free_comp_eqs(dev);
 	mlx5_stop_eqs(dev);
 	mlx5_free_uuars(dev, &priv->uuari);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/uar.c b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
index eb05c84..d287bcb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/uar.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
@@ -246,11 +246,11 @@ int mlx5_alloc_map_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar)
 		err = -ENOMEM;
 		goto err_free_uar;
 	}
-
-	if (mdev->priv.bf_mapping)
-		uar->bf_map = io_mapping_map_wc(mdev->priv.bf_mapping,
-						uar->index << PAGE_SHIFT);
-
+#ifdef ARCH_HAS_IOREMAP_WC
+	uar->bf_map = ioremap_wc(pfn << PAGE_SHIFT, PAGE_SIZE);
+	if (!uar->bf_map)
+		mlx5_core_warn(mdev, "ioremap_wc() failed\n");
+#endif
 	return 0;
 
 err_free_uar:
@@ -262,7 +262,7 @@ EXPORT_SYMBOL(mlx5_alloc_map_uar);
 
 void mlx5_unmap_free_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar)
 {
-	io_mapping_unmap(uar->bf_map);
+	iounmap(uar->bf_map);
 	iounmap(uar->map);
 	mlx5_cmd_free_uar(mdev, uar->index);
 }
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 3388a43..335d43a 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -460,8 +460,6 @@ struct mlx5_priv {
 	struct mlx5_uuar_info	uuari;
 	MLX5_DECLARE_DOORBELL_LOCK(cq_uar_lock);
 
-	struct io_mapping	*bf_mapping;
-
 	/* pages stuff */
 	struct workqueue_struct *pg_wq;
 	struct rb_root		page_root;
-- 
1.7.1
