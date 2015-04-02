From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 14/16] net/mlx5_core: Move completion eqs from mlx5_ib to mlx5_core
Date: Thu,  2 Apr 2015 17:07:32 +0300
Message-ID: <1427983654-971-15-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37146 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753173AbbDBOIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:08:14 -0400
Received: by wiaa2 with SMTP id a2so106731851wia.0
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:08:13 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Preparation for ethernet driver.
These functions will be used in drivers other than mlx5_ib.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/hw/mlx5/cq.c                |   2 +-
 drivers/infiniband/hw/mlx5/main.c              | 104 +------------------------
 drivers/infiniband/hw/mlx5/mlx5_ib.h           |   3 -
 drivers/net/ethernet/mellanox/mlx5/core/main.c |  91 ++++++++++++++++++++++
 include/linux/mlx5/driver.h                    |   3 +-
 5 files changed, 98 insertions(+), 105 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
index 6efd9f73ff60..c94e2651820d 100644
--- a/drivers/infiniband/hw/mlx5/cq.c
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -780,7 +780,7 @@ struct ib_cq *mlx5_ib_create_cq(struct ib_device *ibdev, int entries,
 	cq->cqe_size = cqe_size;
 	cqb->ctx.cqe_sz_flags = cqe_sz_to_mlx_sz(cqe_size) << 5;
 	cqb->ctx.log_sz_usr_page = cpu_to_be32((ilog2(entries) << 24) | index);
-	err = mlx5_vector2eqn(dev, vector, &eqn, &irqn);
+	err = mlx5_vector2eqn(dev->mdev, vector, &eqn, &irqn);
 	if (err)
 		goto err_cqb;
 
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 45816b10af5e..e59e2a1f8726 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -62,95 +62,6 @@ static char mlx5_version[] =
 	DRIVER_NAME ": Mellanox Connect-IB Infiniband driver v"
 	DRIVER_VERSION " (" DRIVER_RELDATE ")\n";
 
-int mlx5_vector2eqn(struct mlx5_ib_dev *dev, int vector, int *eqn, int *irqn)
-{
-	struct mlx5_eq_table *table = &dev->mdev->priv.eq_table;
-	struct mlx5_eq *eq, *n;
-	int err = -ENOENT;
-
-	spin_lock(&table->lock);
-	list_for_each_entry_safe(eq, n, &dev->eqs_list, list) {
-		if (eq->index == vector) {
-			*eqn = eq->eqn;
-			*irqn = eq->irqn;
-			err = 0;
-			break;
-		}
-	}
-	spin_unlock(&table->lock);
-
-	return err;
-}
-
-static int alloc_comp_eqs(struct mlx5_ib_dev *dev)
-{
-	struct mlx5_eq_table *table = &dev->mdev->priv.eq_table;
-	char name[MLX5_MAX_EQ_NAME];
-	struct mlx5_eq *eq, *n;
-	int ncomp_vec;
-	int nent;
-	int err;
-	int i;
-
-	INIT_LIST_HEAD(&dev->eqs_list);
-	ncomp_vec = table->num_comp_vectors;
-	nent = MLX5_COMP_EQ_SIZE;
-	for (i = 0; i < ncomp_vec; i++) {
-		eq = kzalloc(sizeof(*eq), GFP_KERNEL);
-		if (!eq) {
-			err = -ENOMEM;
-			goto clean;
-		}
-
-		snprintf(name, MLX5_MAX_EQ_NAME, "mlx5_comp%d", i);
-		err = mlx5_create_map_eq(dev->mdev, eq,
-					 i + MLX5_EQ_VEC_COMP_BASE, nent, 0,
-					 name, &dev->mdev->priv.uuari.uars[0]);
-		if (err) {
-			kfree(eq);
-			goto clean;
-		}
-		mlx5_ib_dbg(dev, "allocated completion EQN %d\n", eq->eqn);
-		eq->index = i;
-		spin_lock(&table->lock);
-		list_add_tail(&eq->list, &dev->eqs_list);
-		spin_unlock(&table->lock);
-	}
-
-	dev->num_comp_vectors = ncomp_vec;
-	return 0;
-
-clean:
-	spin_lock(&table->lock);
-	list_for_each_entry_safe(eq, n, &dev->eqs_list, list) {
-		list_del(&eq->list);
-		spin_unlock(&table->lock);
-		if (mlx5_destroy_unmap_eq(dev->mdev, eq))
-			mlx5_ib_warn(dev, "failed to destroy EQ 0x%x\n", eq->eqn);
-		kfree(eq);
-		spin_lock(&table->lock);
-	}
-	spin_unlock(&table->lock);
-	return err;
-}
-
-static void free_comp_eqs(struct mlx5_ib_dev *dev)
-{
-	struct mlx5_eq_table *table = &dev->mdev->priv.eq_table;
-	struct mlx5_eq *eq, *n;
-
-	spin_lock(&table->lock);
-	list_for_each_entry_safe(eq, n, &dev->eqs_list, list) {
-		list_del(&eq->list);
-		spin_unlock(&table->lock);
-		if (mlx5_destroy_unmap_eq(dev->mdev, eq))
-			mlx5_ib_warn(dev, "failed to destroy EQ 0x%x\n", eq->eqn);
-		kfree(eq);
-		spin_lock(&table->lock);
-	}
-	spin_unlock(&table->lock);
-}
-
 static int mlx5_ib_query_device(struct ib_device *ibdev,
 				struct ib_device_attr *props)
 {
@@ -1291,10 +1202,6 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 
 	get_ext_port_caps(dev);
 
-	err = alloc_comp_eqs(dev);
-	if (err)
-		goto err_dealloc;
-
 	MLX5_INIT_DOORBELL_LOCK(&dev->uar_lock);
 
 	strlcpy(dev->ib_dev.name, "mlx5_%d", IB_DEVICE_NAME_MAX);
@@ -1303,7 +1210,8 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	dev->ib_dev.local_dma_lkey	= mdev->caps.gen.reserved_lkey;
 	dev->num_ports		= mdev->caps.gen.num_ports;
 	dev->ib_dev.phys_port_cnt     = dev->num_ports;
-	dev->ib_dev.num_comp_vectors	= dev->num_comp_vectors;
+	dev->ib_dev.num_comp_vectors    =
+		dev->mdev->priv.eq_table.num_comp_vectors;
 	dev->ib_dev.dma_device	= &mdev->pdev->dev;
 
 	dev->ib_dev.uverbs_abi_ver	= MLX5_IB_UVERBS_ABI_VERSION;
@@ -1390,13 +1298,13 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 
 	err = init_node_data(dev);
 	if (err)
-		goto err_eqs;
+		goto err_dealloc;
 
 	mutex_init(&dev->cap_mask_mutex);
 
 	err = create_dev_resources(&dev->devr);
 	if (err)
-		goto err_eqs;
+		goto err_dealloc;
 
 	err = mlx5_ib_odp_init_one(dev);
 	if (err)
@@ -1433,9 +1341,6 @@ err_odp:
 err_rsrc:
 	destroy_dev_resources(&dev->devr);
 
-err_eqs:
-	free_comp_eqs(dev);
-
 err_dealloc:
 	ib_dealloc_device((struct ib_device *)dev);
 
@@ -1450,7 +1355,6 @@ static void mlx5_ib_remove(struct mlx5_core_dev *mdev, void *context)
 	destroy_umrc_res(dev);
 	mlx5_ib_odp_remove_one(dev);
 	destroy_dev_resources(&dev->devr);
-	free_comp_eqs(dev);
 	ib_dealloc_device(&dev->ib_dev);
 }
 
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index 8f94f69fbea5..dff1cfcdf476 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -421,9 +421,7 @@ struct mlx5_ib_dev {
 	struct ib_device		ib_dev;
 	struct mlx5_core_dev		*mdev;
 	MLX5_DECLARE_DOORBELL_LOCK(uar_lock);
-	struct list_head		eqs_list;
 	int				num_ports;
-	int				num_comp_vectors;
 	/* serialize update of capability mask
 	 */
 	struct mutex			cap_mask_mutex;
@@ -594,7 +592,6 @@ struct ib_xrcd *mlx5_ib_alloc_xrcd(struct ib_device *ibdev,
 					  struct ib_ucontext *context,
 					  struct ib_udata *udata);
 int mlx5_ib_dealloc_xrcd(struct ib_xrcd *xrcd);
-int mlx5_vector2eqn(struct mlx5_ib_dev *dev, int vector, int *eqn, int *irqn);
 int mlx5_ib_get_buf_offset(u64 addr, int page_shift, u32 *offset);
 int mlx5_query_ext_port_caps(struct mlx5_ib_dev *dev, u8 port);
 int mlx5_ib_query_port(struct ib_device *ibdev, u8 port,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index fe41a7c2c629..cfc29027f07a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -507,6 +507,87 @@ static int mlx5_core_disable_hca(struct mlx5_core_dev *dev)
 	return 0;
 }
 
+int mlx5_vector2eqn(struct mlx5_core_dev *dev, int vector, int *eqn, int *irqn)
+{
+	struct mlx5_eq_table *table = &dev->priv.eq_table;
+	struct mlx5_eq *eq, *n;
+	int err = -ENOENT;
+
+	spin_lock(&table->lock);
+	list_for_each_entry_safe(eq, n, &table->comp_eqs_list, list) {
+		if (eq->index == vector) {
+			*eqn = eq->eqn;
+			*irqn = eq->irqn;
+			err = 0;
+			break;
+		}
+	}
+	spin_unlock(&table->lock);
+
+	return err;
+}
+EXPORT_SYMBOL(mlx5_vector2eqn);
+
+static void free_comp_eqs(struct mlx5_core_dev *dev)
+{
+	struct mlx5_eq_table *table = &dev->priv.eq_table;
+	struct mlx5_eq *eq, *n;
+
+	spin_lock(&table->lock);
+	list_for_each_entry_safe(eq, n, &table->comp_eqs_list, list) {
+		list_del(&eq->list);
+		spin_unlock(&table->lock);
+		if (mlx5_destroy_unmap_eq(dev, eq))
+			mlx5_core_warn(dev, "failed to destroy EQ 0x%x\n",
+				       eq->eqn);
+		kfree(eq);
+		spin_lock(&table->lock);
+	}
+	spin_unlock(&table->lock);
+}
+
+static int alloc_comp_eqs(struct mlx5_core_dev *dev)
+{
+	struct mlx5_eq_table *table = &dev->priv.eq_table;
+	char name[MLX5_MAX_EQ_NAME];
+	struct mlx5_eq *eq;
+	int ncomp_vec;
+	int nent;
+	int err;
+	int i;
+
+	INIT_LIST_HEAD(&table->comp_eqs_list);
+	ncomp_vec = table->num_comp_vectors;
+	nent = MLX5_COMP_EQ_SIZE;
+	for (i = 0; i < ncomp_vec; i++) {
+		eq = kzalloc(sizeof(*eq), GFP_KERNEL);
+		if (!eq) {
+			err = -ENOMEM;
+			goto clean;
+		}
+
+		snprintf(name, MLX5_MAX_EQ_NAME, "mlx5_comp%d", i);
+		err = mlx5_create_map_eq(dev, eq,
+					 i + MLX5_EQ_VEC_COMP_BASE, nent, 0,
+					 name, &dev->priv.uuari.uars[0]);
+		if (err) {
+			kfree(eq);
+			goto clean;
+		}
+		mlx5_core_dbg(dev, "allocated completion EQN %d\n", eq->eqn);
+		eq->index = i;
+		spin_lock(&table->lock);
+		list_add_tail(&eq->list, &table->comp_eqs_list);
+		spin_unlock(&table->lock);
+	}
+
+	return 0;
+
+clean:
+	free_comp_eqs(dev);
+	return err;
+}
+
 static int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev)
 {
 	struct mlx5_priv *priv = &dev->priv;
@@ -643,6 +724,12 @@ static int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev)
 		goto err_free_uar;
 	}
 
+	err = alloc_comp_eqs(dev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to alloc completion EQs\n");
+		goto err_stop_eqs;
+	}
+
 	MLX5_INIT_DOORBELL_LOCK(&priv->cq_uar_lock);
 
 	mlx5_init_cq_table(dev);
@@ -652,6 +739,9 @@ static int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev)
 
 	return 0;
 
+err_stop_eqs:
+	mlx5_stop_eqs(dev);
+
 err_free_uar:
 	mlx5_free_uuars(dev, &priv->uuari);
 
@@ -703,6 +793,7 @@ static void mlx5_dev_cleanup(struct mlx5_core_dev *dev)
 	mlx5_cleanup_srq_table(dev);
 	mlx5_cleanup_qp_table(dev);
 	mlx5_cleanup_cq_table(dev);
+	free_comp_eqs(dev);
 	mlx5_stop_eqs(dev);
 	mlx5_free_uuars(dev, &priv->uuari);
 	mlx5_eq_cleanup(dev);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 8fedd39a9a60..f250f6580dad 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -410,7 +410,7 @@ struct mlx5_core_srq {
 struct mlx5_eq_table {
 	void __iomem	       *update_ci;
 	void __iomem	       *update_arm_ci;
-	struct list_head       *comp_eq_head;
+	struct list_head	comp_eqs_list;
 	struct mlx5_eq		pages_eq;
 	struct mlx5_eq		async_eq;
 	struct mlx5_eq		cmd_eq;
@@ -725,6 +725,7 @@ int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
 int mlx5_destroy_unmap_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
 int mlx5_start_eqs(struct mlx5_core_dev *dev);
 int mlx5_stop_eqs(struct mlx5_core_dev *dev);
+int mlx5_vector2eqn(struct mlx5_core_dev *dev, int vector, int *eqn, int *irqn);
 int mlx5_core_attach_mcg(struct mlx5_core_dev *dev, union ib_gid *mgid, u32 qpn);
 int mlx5_core_detach_mcg(struct mlx5_core_dev *dev, union ib_gid *mgid, u32 qpn);
 
-- 
2.3.1
