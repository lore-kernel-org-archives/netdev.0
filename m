From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 3.4-stable 2/2] net/mlx4_core: Preserve pci_dev_data after __mlx4_remove_one()
Date: Sun,  1 Jun 2014 15:25:20 +0800
Message-ID: <1401607520-8471-2-git-send-email-weiyang@linux.vnet.ibm.com>
References: <1401607520-8471-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:32924 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755399AbaFAHZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 03:25:39 -0400
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Sun, 1 Jun 2014 17:25:38 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 393162CE8040
	for <netdev@vger.kernel.org>; Sun,  1 Jun 2014 17:25:35 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5173tJw66650140
	for <netdev@vger.kernel.org>; Sun, 1 Jun 2014 17:03:55 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s517PYpw012629
	for <netdev@vger.kernel.org>; Sun, 1 Jun 2014 17:25:34 +1000
In-Reply-To: <1401607520-8471-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch wrap up a helper function __mlx4_remove_one() which does the tear
down function but preserve the drv_data. Functions like
mlx4_pci_err_detected() and mlx4_restart_one() will call this one with out
releasing drvdata.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |  147 ++++++++++++++++-------------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |    1 +
 2 files changed, 84 insertions(+), 64 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 746b367..1de7982 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1805,15 +1805,8 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 	/* Allow large DMA segments, up to the firmware limit of 1 GB */
 	dma_set_max_seg_size(&pdev->dev, 1024 * 1024 * 1024);
 
-	priv = kzalloc(sizeof *priv, GFP_KERNEL);
-	if (!priv) {
-		dev_err(&pdev->dev, "Device struct alloc failed, "
-			"aborting.\n");
-		err = -ENOMEM;
-		goto err_release_regions;
-	}
-
-	dev       = &priv->dev;
+	dev       = pci_get_drvdata(pdev);
+	priv      = mlx4_priv(dev);
 	dev->pdev = pdev;
 	INIT_LIST_HEAD(&priv->ctx_list);
 	spin_lock_init(&priv->ctx_lock);
@@ -1974,8 +1967,7 @@ slave_start:
 	mlx4_sense_init(dev);
 	mlx4_start_sense(dev);
 
-	priv->pci_dev_data = pci_dev_data;
-	pci_set_drvdata(pdev, dev);
+	priv->removed = 0;
 
 	return 0;
 
@@ -2042,73 +2034,100 @@ err_disable_pdev:
 static int __devinit mlx4_init_one(struct pci_dev *pdev,
 				   const struct pci_device_id *id)
 {
+	struct mlx4_priv *priv;
+	struct mlx4_dev *dev;
+
 	printk_once(KERN_INFO "%s", mlx4_version);
 
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	dev       = &priv->dev;
+	pci_set_drvdata(pdev, dev);
+	priv->pci_dev_data = id->driver_data;
+
 	return __mlx4_init_one(pdev, id->driver_data);
 }
 
-static void mlx4_remove_one(struct pci_dev *pdev)
+static void __mlx4_remove_one(struct pci_dev *pdev)
 {
 	struct mlx4_dev  *dev  = pci_get_drvdata(pdev);
 	struct mlx4_priv *priv = mlx4_priv(dev);
+	int               pci_dev_data;
 	int p;
 
-	if (dev) {
-		/* in SRIOV it is not allowed to unload the pf's
-		 * driver while there are alive vf's */
-		if (mlx4_is_master(dev)) {
-			if (mlx4_how_many_lives_vf(dev))
-				printk(KERN_ERR "Removing PF when there are assigned VF's !!!\n");
-		}
-		mlx4_stop_sense(dev);
-		mlx4_unregister_device(dev);
+	if (priv->removed)
+		return;
 
-		for (p = 1; p <= dev->caps.num_ports; p++) {
-			mlx4_cleanup_port_info(&priv->port[p]);
-			mlx4_CLOSE_PORT(dev, p);
-		}
+	pci_dev_data = priv->pci_dev_data;
 
-		mlx4_cleanup_counters_table(dev);
-		mlx4_cleanup_mcg_table(dev);
-		mlx4_cleanup_qp_table(dev);
-		mlx4_cleanup_srq_table(dev);
-		mlx4_cleanup_cq_table(dev);
-		mlx4_cmd_use_polling(dev);
-		mlx4_cleanup_eq_table(dev);
-		mlx4_cleanup_mr_table(dev);
-		mlx4_cleanup_xrcd_table(dev);
-		mlx4_cleanup_pd_table(dev);
+	/* in SRIOV it is not allowed to unload the pf's
+	 * driver while there are alive vf's */
+	if (mlx4_is_master(dev)) {
+		if (mlx4_how_many_lives_vf(dev))
+			printk(KERN_ERR "Removing PF when there are assigned VF's !!!\n");
+	}
+	mlx4_stop_sense(dev);
+	mlx4_unregister_device(dev);
 
-		if (mlx4_is_master(dev))
-			mlx4_free_resource_tracker(dev);
-
-		iounmap(priv->kar);
-		mlx4_uar_free(dev, &priv->driver_uar);
-		mlx4_cleanup_uar_table(dev);
-		if (!mlx4_is_slave(dev))
-			mlx4_clear_steering(dev);
-		mlx4_free_eq_table(dev);
-		if (mlx4_is_master(dev))
-			mlx4_multi_func_cleanup(dev);
-		mlx4_close_hca(dev);
-		if (mlx4_is_slave(dev))
-			mlx4_multi_func_cleanup(dev);
-		mlx4_cmd_cleanup(dev);
-
-		if (dev->flags & MLX4_FLAG_MSI_X)
-			pci_disable_msix(pdev);
-		if (num_vfs && (dev->flags & MLX4_FLAG_SRIOV)) {
-			mlx4_warn(dev, "Disabling sriov\n");
-			pci_disable_sriov(pdev);
-		}
+	for (p = 1; p <= dev->caps.num_ports; p++) {
+		mlx4_cleanup_port_info(&priv->port[p]);
+		mlx4_CLOSE_PORT(dev, p);
+	}
+
+	mlx4_cleanup_counters_table(dev);
+	mlx4_cleanup_mcg_table(dev);
+	mlx4_cleanup_qp_table(dev);
+	mlx4_cleanup_srq_table(dev);
+	mlx4_cleanup_cq_table(dev);
+	mlx4_cmd_use_polling(dev);
+	mlx4_cleanup_eq_table(dev);
+	mlx4_cleanup_mr_table(dev);
+	mlx4_cleanup_xrcd_table(dev);
+	mlx4_cleanup_pd_table(dev);
+
+	if (mlx4_is_master(dev))
+		mlx4_free_resource_tracker(dev);
+
+	iounmap(priv->kar);
+	mlx4_uar_free(dev, &priv->driver_uar);
+	mlx4_cleanup_uar_table(dev);
+	if (!mlx4_is_slave(dev))
+		mlx4_clear_steering(dev);
+	mlx4_free_eq_table(dev);
+	if (mlx4_is_master(dev))
+		mlx4_multi_func_cleanup(dev);
+	mlx4_close_hca(dev);
+	if (mlx4_is_slave(dev))
+		mlx4_multi_func_cleanup(dev);
+	mlx4_cmd_cleanup(dev);
 
-		if (!mlx4_is_slave(dev))
-			mlx4_free_ownership(dev);
-		kfree(priv);
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
+	if (dev->flags & MLX4_FLAG_MSI_X)
+		pci_disable_msix(pdev);
+	if (num_vfs && (dev->flags & MLX4_FLAG_SRIOV)) {
+		mlx4_warn(dev, "Disabling sriov\n");
+		pci_disable_sriov(pdev);
 	}
+
+	if (!mlx4_is_slave(dev))
+		mlx4_free_ownership(dev);
+
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	memset(priv, 0, sizeof(*priv));
+	priv->pci_dev_data = pci_dev_data;
+	priv->removed = 1;
+}
+
+static void mlx4_remove_one(struct pci_dev *pdev)
+{
+	struct mlx4_dev  *dev  = pci_get_drvdata(pdev);
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	__mlx4_remove_one(pdev);
+	kfree(priv);
+	pci_set_drvdata(pdev, NULL);
 }
 
 int mlx4_restart_one(struct pci_dev *pdev)
@@ -2118,7 +2137,7 @@ int mlx4_restart_one(struct pci_dev *pdev)
 	int		  pci_dev_data;
 
 	pci_dev_data = priv->pci_dev_data;
-	mlx4_remove_one(pdev);
+	__mlx4_remove_one(pdev);
 	return __mlx4_init_one(pdev, pci_dev_data);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 8eb8f8a..a3ef1df 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -723,6 +723,7 @@ struct mlx4_priv {
 	spinlock_t		ctx_lock;
 
 	int			pci_dev_data;
+	int                     removed;
 
 	struct list_head        pgdir_list;
 	struct mutex            pgdir_mutex;
-- 
1.7.9.5
