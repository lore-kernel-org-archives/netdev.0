From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 6/8] net/mlx5_core: New init and exit flow for mlx5_core
Date: Fri, 25 Sep 2015 10:49:14 +0300
Message-ID: <1443167356-32095-7-git-send-email-ogerlitz@mellanox.com>
References: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, eli@labmailer.mlnx,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>, Eli Cohen <eli@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39340 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755367AbbIYHuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 03:50:14 -0400
In-Reply-To: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

In the new flow, we separate the pci initialization and teardown from the
initialization and teardown of the other resources.

init_one calls mlx5_pci_init that handles the pci resources initialization.
It then calls mlx5_load_one to initialize the remainder of the resources.

When removing a device, remove_one is invoked. However, now remove_one
calls mlx5_unload_one to free all the resources except the pci resources.
When mlx5_unload_one returns, mlx5_pci_close is called to free the pci
resources.

The above separation will allow us to implement the pci error handlers and
suspend and resume callbacks.


Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c  |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/cq.c   |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/eq.c   |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 341 ++++++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/mr.c   |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/qp.c   |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/srq.c  |   1 +
 7 files changed, 194 insertions(+), 153 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index c351659..84838c2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -1364,6 +1364,7 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
 	int err;
 	int i;
 
+	memset(cmd, 0, sizeof(*cmd));
 	cmd_if_rev = cmdif_rev(dev);
 	if (cmd_if_rev != CMD_IF_REV) {
 		dev_err(&dev->pdev->dev,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cq.c b/drivers/net/ethernet/mellanox/mlx5/core/cq.c
index 04ab7e4..b51e42d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cq.c
@@ -242,6 +242,7 @@ int mlx5_init_cq_table(struct mlx5_core_dev *dev)
 	struct mlx5_cq_table *table = &dev->priv.cq_table;
 	int err;
 
+	memset(table, 0, sizeof(*table));
 	spin_lock_init(&table->lock);
 	INIT_RADIX_TREE(&table->tree, GFP_ATOMIC);
 	err = mlx5_cq_debugfs_init(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index a40b96d..1f01fe8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -346,6 +346,7 @@ int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
 	int inlen;
 
 	eq->nent = roundup_pow_of_two(nent + MLX5_NUM_SPARE_EQE);
+	eq->cons_index = 0;
 	err = mlx5_buf_alloc(dev, eq->nent * MLX5_EQE_SIZE, &eq->buf);
 	if (err)
 		return err;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 03aabdd..7718f6a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -672,12 +672,126 @@ static void unmap_bf_area(struct mlx5_core_dev *dev)
 		io_mapping_free(dev->priv.bf_mapping);
 }
 
-static int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev)
+static void mlx5_add_device(struct mlx5_interface *intf, struct mlx5_priv *priv)
+{
+	struct mlx5_device_context *dev_ctx;
+	struct mlx5_core_dev *dev = container_of(priv, struct mlx5_core_dev, priv);
+
+	dev_ctx = kmalloc(sizeof(*dev_ctx), GFP_KERNEL);
+	if (!dev_ctx)
+		return;
+
+	dev_ctx->intf    = intf;
+	dev_ctx->context = intf->add(dev);
+
+	if (dev_ctx->context) {
+		spin_lock_irq(&priv->ctx_lock);
+		list_add_tail(&dev_ctx->list, &priv->ctx_list);
+		spin_unlock_irq(&priv->ctx_lock);
+	} else {
+		kfree(dev_ctx);
+	}
+}
+
+static void mlx5_remove_device(struct mlx5_interface *intf, struct mlx5_priv *priv)
+{
+	struct mlx5_device_context *dev_ctx;
+	struct mlx5_core_dev *dev = container_of(priv, struct mlx5_core_dev, priv);
+
+	list_for_each_entry(dev_ctx, &priv->ctx_list, list)
+		if (dev_ctx->intf == intf) {
+			spin_lock_irq(&priv->ctx_lock);
+			list_del(&dev_ctx->list);
+			spin_unlock_irq(&priv->ctx_lock);
+
+			intf->remove(dev, dev_ctx->context);
+			kfree(dev_ctx);
+			return;
+		}
+}
+
+static int mlx5_register_device(struct mlx5_core_dev *dev)
 {
 	struct mlx5_priv *priv = &dev->priv;
-	int err;
+	struct mlx5_interface *intf;
+
+	mutex_lock(&intf_mutex);
+	list_add_tail(&priv->dev_list, &dev_list);
+	list_for_each_entry(intf, &intf_list, list)
+		mlx5_add_device(intf, priv);
+	mutex_unlock(&intf_mutex);
+
+	return 0;
+}
+
+static void mlx5_unregister_device(struct mlx5_core_dev *dev)
+{
+	struct mlx5_priv *priv = &dev->priv;
+	struct mlx5_interface *intf;
+
+	mutex_lock(&intf_mutex);
+	list_for_each_entry(intf, &intf_list, list)
+		mlx5_remove_device(intf, priv);
+	list_del(&priv->dev_list);
+	mutex_unlock(&intf_mutex);
+}
+
+int mlx5_register_interface(struct mlx5_interface *intf)
+{
+	struct mlx5_priv *priv;
+
+	if (!intf->add || !intf->remove)
+		return -EINVAL;
+
+	mutex_lock(&intf_mutex);
+	list_add_tail(&intf->list, &intf_list);
+	list_for_each_entry(priv, &dev_list, dev_list)
+		mlx5_add_device(intf, priv);
+	mutex_unlock(&intf_mutex);
+
+	return 0;
+}
+EXPORT_SYMBOL(mlx5_register_interface);
+
+void mlx5_unregister_interface(struct mlx5_interface *intf)
+{
+	struct mlx5_priv *priv;
+
+	mutex_lock(&intf_mutex);
+	list_for_each_entry(priv, &dev_list, dev_list)
+		mlx5_remove_device(intf, priv);
+	list_del(&intf->list);
+	mutex_unlock(&intf_mutex);
+}
+EXPORT_SYMBOL(mlx5_unregister_interface);
+
+void *mlx5_get_protocol_dev(struct mlx5_core_dev *mdev, int protocol)
+{
+	struct mlx5_priv *priv = &mdev->priv;
+	struct mlx5_device_context *dev_ctx;
+	unsigned long flags;
+	void *result = NULL;
+
+	spin_lock_irqsave(&priv->ctx_lock, flags);
+
+	list_for_each_entry(dev_ctx, &mdev->priv.ctx_list, list)
+		if ((dev_ctx->intf->protocol == protocol) &&
+		    dev_ctx->intf->get_dev) {
+			result = dev_ctx->intf->get_dev(dev_ctx->context);
+			break;
+		}
+
+	spin_unlock_irqrestore(&priv->ctx_lock, flags);
+
+	return result;
+}
+EXPORT_SYMBOL(mlx5_get_protocol_dev);
+
+static int mlx5_pci_init(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
+{
+	struct pci_dev *pdev = dev->pdev;
+	int err = 0;
 
-	dev->pdev = pdev;
 	pci_set_drvdata(dev->pdev, dev);
 	strncpy(priv->name, dev_name(&pdev->dev), MLX5_MAX_NAME_LEN);
 	priv->name[MLX5_MAX_NAME_LEN - 1] = 0;
@@ -721,13 +835,42 @@ static int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev)
 		dev_err(&pdev->dev, "Failed mapping initialization segment, aborting\n");
 		goto err_clr_master;
 	}
+
+	return 0;
+
+err_clr_master:
+	pci_clear_master(dev->pdev);
+	release_bar(dev->pdev);
+err_disable:
+	pci_disable_device(dev->pdev);
+
+err_dbg:
+	debugfs_remove(priv->dbg_root);
+	return err;
+}
+
+static void mlx5_pci_close(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
+{
+	iounmap(dev->iseg);
+	pci_clear_master(dev->pdev);
+	release_bar(dev->pdev);
+	pci_disable_device(dev->pdev);
+	debugfs_remove(priv->dbg_root);
+}
+
+#define MLX5_IB_MOD "mlx5_ib"
+static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
+{
+	struct pci_dev *pdev = dev->pdev;
+	int err;
+
 	dev_info(&pdev->dev, "firmware version: %d.%d.%d\n", fw_rev_maj(dev),
 		 fw_rev_min(dev), fw_rev_sub(dev));
 
 	err = mlx5_cmd_init(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Failed initializing command interface, aborting\n");
-		goto err_unmap;
+		return err;
 	}
 
 	mlx5_pagealloc_init(dev);
@@ -842,8 +985,25 @@ static int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev)
 	mlx5_init_srq_table(dev);
 	mlx5_init_mr_table(dev);
 
+	err = mlx5_register_device(dev);
+	if (err) {
+		dev_err(&pdev->dev, "mlx5_register_device failed %d\n", err);
+		goto err_reg_dev;
+	}
+
+	err = request_module_nowait(MLX5_IB_MOD);
+	if (err)
+		pr_info("failed request module on %s\n", MLX5_IB_MOD);
+
 	return 0;
 
+err_reg_dev:
+	mlx5_cleanup_mr_table(dev);
+	mlx5_cleanup_srq_table(dev);
+	mlx5_cleanup_qp_table(dev);
+	mlx5_cleanup_cq_table(dev);
+	mlx5_irq_clear_affinity_hints(dev);
+
 err_unmap_bf_area:
 	unmap_bf_area(dev);
 
@@ -881,25 +1041,14 @@ err_pagealloc_cleanup:
 	mlx5_pagealloc_cleanup(dev);
 	mlx5_cmd_cleanup(dev);
 
-err_unmap:
-	iounmap(dev->iseg);
-
-err_clr_master:
-	pci_clear_master(dev->pdev);
-	release_bar(dev->pdev);
-
-err_disable:
-	pci_disable_device(dev->pdev);
-
-err_dbg:
-	debugfs_remove(priv->dbg_root);
 	return err;
 }
 
-static void mlx5_dev_cleanup(struct mlx5_core_dev *dev)
+static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 {
-	struct mlx5_priv *priv = &dev->priv;
 
+	mlx5_unregister_device(dev);
+	mlx5_cleanup_mr_table(dev);
 	mlx5_cleanup_srq_table(dev);
 	mlx5_cleanup_qp_table(dev);
 	mlx5_cleanup_cq_table(dev);
@@ -913,134 +1062,16 @@ static void mlx5_dev_cleanup(struct mlx5_core_dev *dev)
 	mlx5_stop_health_poll(dev);
 	if (mlx5_cmd_teardown_hca(dev)) {
 		dev_err(&dev->pdev->dev, "tear_down_hca failed, skip cleanup\n");
-		return;
+		return 1;
 	}
 	mlx5_pagealloc_stop(dev);
 	mlx5_reclaim_startup_pages(dev);
 	mlx5_core_disable_hca(dev);
 	mlx5_pagealloc_cleanup(dev);
 	mlx5_cmd_cleanup(dev);
-	iounmap(dev->iseg);
-	pci_clear_master(dev->pdev);
-	release_bar(dev->pdev);
-	pci_disable_device(dev->pdev);
-	debugfs_remove(priv->dbg_root);
-}
-
-static void mlx5_add_device(struct mlx5_interface *intf, struct mlx5_priv *priv)
-{
-	struct mlx5_device_context *dev_ctx;
-	struct mlx5_core_dev *dev = container_of(priv, struct mlx5_core_dev, priv);
-
-	dev_ctx = kmalloc(sizeof(*dev_ctx), GFP_KERNEL);
-	if (!dev_ctx) {
-		pr_warn("mlx5_add_device: alloc context failed\n");
-		return;
-	}
-
-	dev_ctx->intf    = intf;
-	dev_ctx->context = intf->add(dev);
-
-	if (dev_ctx->context) {
-		spin_lock_irq(&priv->ctx_lock);
-		list_add_tail(&dev_ctx->list, &priv->ctx_list);
-		spin_unlock_irq(&priv->ctx_lock);
-	} else {
-		kfree(dev_ctx);
-	}
-}
-
-static void mlx5_remove_device(struct mlx5_interface *intf, struct mlx5_priv *priv)
-{
-	struct mlx5_device_context *dev_ctx;
-	struct mlx5_core_dev *dev = container_of(priv, struct mlx5_core_dev, priv);
-
-	list_for_each_entry(dev_ctx, &priv->ctx_list, list)
-		if (dev_ctx->intf == intf) {
-			spin_lock_irq(&priv->ctx_lock);
-			list_del(&dev_ctx->list);
-			spin_unlock_irq(&priv->ctx_lock);
-
-			intf->remove(dev, dev_ctx->context);
-			kfree(dev_ctx);
-			return;
-		}
-}
-static int mlx5_register_device(struct mlx5_core_dev *dev)
-{
-	struct mlx5_priv *priv = &dev->priv;
-	struct mlx5_interface *intf;
-
-	mutex_lock(&intf_mutex);
-	list_add_tail(&priv->dev_list, &dev_list);
-	list_for_each_entry(intf, &intf_list, list)
-		mlx5_add_device(intf, priv);
-	mutex_unlock(&intf_mutex);
 
 	return 0;
 }
-static void mlx5_unregister_device(struct mlx5_core_dev *dev)
-{
-	struct mlx5_priv *priv = &dev->priv;
-	struct mlx5_interface *intf;
-
-	mutex_lock(&intf_mutex);
-	list_for_each_entry(intf, &intf_list, list)
-		mlx5_remove_device(intf, priv);
-	list_del(&priv->dev_list);
-	mutex_unlock(&intf_mutex);
-}
-
-int mlx5_register_interface(struct mlx5_interface *intf)
-{
-	struct mlx5_priv *priv;
-
-	if (!intf->add || !intf->remove)
-		return -EINVAL;
-
-	mutex_lock(&intf_mutex);
-	list_add_tail(&intf->list, &intf_list);
-	list_for_each_entry(priv, &dev_list, dev_list)
-		mlx5_add_device(intf, priv);
-	mutex_unlock(&intf_mutex);
-
-	return 0;
-}
-EXPORT_SYMBOL(mlx5_register_interface);
-
-void mlx5_unregister_interface(struct mlx5_interface *intf)
-{
-	struct mlx5_priv *priv;
-
-	mutex_lock(&intf_mutex);
-	list_for_each_entry(priv, &dev_list, dev_list)
-	       mlx5_remove_device(intf, priv);
-	list_del(&intf->list);
-	mutex_unlock(&intf_mutex);
-}
-EXPORT_SYMBOL(mlx5_unregister_interface);
-
-void *mlx5_get_protocol_dev(struct mlx5_core_dev *mdev, int protocol)
-{
-	struct mlx5_priv *priv = &mdev->priv;
-	struct mlx5_device_context *dev_ctx;
-	unsigned long flags;
-	void *result = NULL;
-
-	spin_lock_irqsave(&priv->ctx_lock, flags);
-
-	list_for_each_entry(dev_ctx, &mdev->priv.ctx_list, list)
-		if ((dev_ctx->intf->protocol == protocol) &&
-		    dev_ctx->intf->get_dev) {
-			result = dev_ctx->intf->get_dev(dev_ctx->context);
-			break;
-		}
-
-	spin_unlock_irqrestore(&priv->ctx_lock, flags);
-
-	return result;
-}
-EXPORT_SYMBOL(mlx5_get_protocol_dev);
 
 static void mlx5_core_event(struct mlx5_core_dev *dev, enum mlx5_dev_event event,
 			    unsigned long param)
@@ -1064,7 +1095,6 @@ struct mlx5_core_event_handler {
 		      void *data);
 };
 
-#define MLX5_IB_MOD "mlx5_ib"
 
 static int init_one(struct pci_dev *pdev,
 		    const struct pci_device_id *id)
@@ -1088,40 +1118,45 @@ static int init_one(struct pci_dev *pdev,
 		prof_sel = MLX5_DEFAULT_PROF;
 	}
 	dev->profile = &profile[prof_sel];
+	dev->pdev = pdev;
 	dev->event = mlx5_core_event;
 
 	INIT_LIST_HEAD(&priv->ctx_list);
 	spin_lock_init(&priv->ctx_lock);
-	err = mlx5_dev_init(dev, pdev);
+	err = mlx5_pci_init(dev, priv);
 	if (err) {
-		dev_err(&pdev->dev, "mlx5_dev_init failed %d\n", err);
-		goto out;
+		dev_err(&pdev->dev, "mlx5_pci_init failed with error code %d\n", err);
+		goto clean_dev;
 	}
 
-	err = mlx5_register_device(dev);
+	err = mlx5_load_one(dev, priv);
 	if (err) {
-		dev_err(&pdev->dev, "mlx5_register_device failed %d\n", err);
-		goto out_init;
+		dev_err(&pdev->dev, "mlx5_load_one failed with error code %d\n", err);
+		goto close_pci;
 	}
 
-	err = request_module_nowait(MLX5_IB_MOD);
-	if (err)
-		pr_info("failed request module on %s\n", MLX5_IB_MOD);
-
 	return 0;
 
-out_init:
-	mlx5_dev_cleanup(dev);
-out:
+close_pci:
+	mlx5_pci_close(dev, priv);
+clean_dev:
+	pci_set_drvdata(pdev, NULL);
 	kfree(dev);
+
 	return err;
 }
+
 static void remove_one(struct pci_dev *pdev)
 {
 	struct mlx5_core_dev *dev  = pci_get_drvdata(pdev);
+	struct mlx5_priv *priv = &dev->priv;
 
-	mlx5_unregister_device(dev);
-	mlx5_dev_cleanup(dev);
+	if (mlx5_unload_one(dev, priv)) {
+		dev_err(&dev->pdev->dev, "mlx5_unload_one failed\n");
+		return;
+	}
+	mlx5_pci_close(dev, priv);
+	pci_set_drvdata(pdev, NULL);
 	kfree(dev);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mr.c b/drivers/net/ethernet/mellanox/mlx5/core/mr.c
index 1adb300..6fa22b5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mr.c
@@ -40,6 +40,7 @@ void mlx5_init_mr_table(struct mlx5_core_dev *dev)
 {
 	struct mlx5_mr_table *table = &dev->priv.mr_table;
 
+	memset(table, 0, sizeof(*table));
 	rwlock_init(&table->lock);
 	INIT_RADIX_TREE(&table->tree, GFP_ATOMIC);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/qp.c b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
index 8b494b5..30e2ba3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
@@ -345,6 +345,7 @@ void mlx5_init_qp_table(struct mlx5_core_dev *dev)
 {
 	struct mlx5_qp_table *table = &dev->priv.qp_table;
 
+	memset(table, 0, sizeof(*table));
 	spin_lock_init(&table->lock);
 	INIT_RADIX_TREE(&table->tree, GFP_ATOMIC);
 	mlx5_qp_debugfs_init(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/srq.c b/drivers/net/ethernet/mellanox/mlx5/core/srq.c
index c48f504..ffada80 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/srq.c
@@ -531,6 +531,7 @@ void mlx5_init_srq_table(struct mlx5_core_dev *dev)
 {
 	struct mlx5_srq_table *table = &dev->priv.srq_table;
 
+	memset(table, 0, sizeof(*table));
 	spin_lock_init(&table->lock);
 	INIT_RADIX_TREE(&table->tree, GFP_ATOMIC);
 }
-- 
2.3.7
