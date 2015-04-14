From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 02/12] net/mlx5_core: Set irq affinity hints
Date: Tue, 14 Apr 2015 11:20:25 +0300
Message-ID: <1428999635-15025-3-git-send-email-amirv@mellanox.com>
References: <1428999635-15025-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:41943 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751976AbbDNIVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 04:21:20 -0400
In-Reply-To: <1428999635-15025-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Preparation for upcoming ethernet driver.
- Move msix array from eq_table struct to priv since its not related to eq_table
- Intorduce irq_info struct to hold all irq information
- Move name from mlx5_eq to irq_info struct since it is irq property.
- Set IRQ affinity hints

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Rana Shahout <ranas@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c   |  16 ++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 111 ++++++++++++++++++++++---
 include/linux/mlx5/driver.h                    |  11 ++-
 3 files changed, 117 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index 3f511bd..516efc2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -339,7 +339,7 @@ static void init_eq_buf(struct mlx5_eq *eq)
 int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
 		       int nent, u64 mask, const char *name, struct mlx5_uar *uar)
 {
-	struct mlx5_eq_table *table = &dev->priv.eq_table;
+	struct mlx5_priv *priv = &dev->priv;
 	struct mlx5_create_eq_mbox_in *in;
 	struct mlx5_create_eq_mbox_out out;
 	int err;
@@ -377,14 +377,15 @@ int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
 		goto err_in;
 	}
 
-	snprintf(eq->name, MLX5_MAX_EQ_NAME, "%s@pci:%s",
+	snprintf(priv->irq_info[vecidx].name, MLX5_MAX_IRQ_NAME, "%s@pci:%s",
 		 name, pci_name(dev->pdev));
+
 	eq->eqn = out.eq_number;
 	eq->irqn = vecidx;
 	eq->dev = dev;
 	eq->doorbell = uar->map + MLX5_EQ_DOORBEL_OFFSET;
-	err = request_irq(table->msix_arr[vecidx].vector, mlx5_msix_handler, 0,
-			  eq->name, eq);
+	err = request_irq(priv->msix_arr[vecidx].vector, mlx5_msix_handler, 0,
+			  priv->irq_info[vecidx].name, eq);
 	if (err)
 		goto err_eq;
 
@@ -400,7 +401,7 @@ int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
 	return 0;
 
 err_irq:
-	free_irq(table->msix_arr[vecidx].vector, eq);
+	free_irq(priv->msix_arr[vecidx].vector, eq);
 
 err_eq:
 	mlx5_cmd_destroy_eq(dev, eq->eqn);
@@ -416,16 +417,15 @@ EXPORT_SYMBOL_GPL(mlx5_create_map_eq);
 
 int mlx5_destroy_unmap_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq)
 {
-	struct mlx5_eq_table *table = &dev->priv.eq_table;
 	int err;
 
 	mlx5_debug_eq_remove(dev, eq);
-	free_irq(table->msix_arr[eq->irqn].vector, eq);
+	free_irq(dev->priv.msix_arr[eq->irqn].vector, eq);
 	err = mlx5_cmd_destroy_eq(dev, eq->eqn);
 	if (err)
 		mlx5_core_warn(dev, "failed to destroy a previously created eq: eqn %d\n",
 			       eq->eqn);
-	synchronize_irq(table->msix_arr[eq->irqn].vector);
+	synchronize_irq(dev->priv.msix_arr[eq->irqn].vector);
 	mlx5_buf_free(dev, &eq->buf);
 
 	return err;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 28425e5..55085b0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -38,6 +38,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/slab.h>
 #include <linux/io-mapping.h>
+#include <linux/interrupt.h>
 #include <linux/mlx5/driver.h>
 #include <linux/mlx5/cq.h>
 #include <linux/mlx5/qp.h>
@@ -208,7 +209,8 @@ static void release_bar(struct pci_dev *pdev)
 
 static int mlx5_enable_msix(struct mlx5_core_dev *dev)
 {
-	struct mlx5_eq_table *table = &dev->priv.eq_table;
+	struct mlx5_priv *priv = &dev->priv;
+	struct mlx5_eq_table *table = &priv->eq_table;
 	int num_eqs = 1 << dev->caps.gen.log_max_eq;
 	int nvec;
 	int i;
@@ -218,14 +220,16 @@ static int mlx5_enable_msix(struct mlx5_core_dev *dev)
 	if (nvec <= MLX5_EQ_VEC_COMP_BASE)
 		return -ENOMEM;
 
-	table->msix_arr = kzalloc(nvec * sizeof(*table->msix_arr), GFP_KERNEL);
-	if (!table->msix_arr)
-		return -ENOMEM;
+	priv->msix_arr = kcalloc(nvec, sizeof(*priv->msix_arr), GFP_KERNEL);
+
+	priv->irq_info = kcalloc(nvec, sizeof(*priv->irq_info), GFP_KERNEL);
+	if (!priv->msix_arr || !priv->irq_info)
+		goto err_free_msix;
 
 	for (i = 0; i < nvec; i++)
-		table->msix_arr[i].entry = i;
+		priv->msix_arr[i].entry = i;
 
-	nvec = pci_enable_msix_range(dev->pdev, table->msix_arr,
+	nvec = pci_enable_msix_range(dev->pdev, priv->msix_arr,
 				     MLX5_EQ_VEC_COMP_BASE + 1, nvec);
 	if (nvec < 0)
 		return nvec;
@@ -233,14 +237,20 @@ static int mlx5_enable_msix(struct mlx5_core_dev *dev)
 	table->num_comp_vectors = nvec - MLX5_EQ_VEC_COMP_BASE;
 
 	return 0;
+
+err_free_msix:
+	kfree(priv->irq_info);
+	kfree(priv->msix_arr);
+	return -ENOMEM;
 }
 
 static void mlx5_disable_msix(struct mlx5_core_dev *dev)
 {
-	struct mlx5_eq_table *table = &dev->priv.eq_table;
+	struct mlx5_priv *priv = &dev->priv;
 
 	pci_disable_msix(dev->pdev);
-	kfree(table->msix_arr);
+	kfree(priv->irq_info);
+	kfree(priv->msix_arr);
 }
 
 struct mlx5_reg_host_endianess {
@@ -507,6 +517,77 @@ static int mlx5_core_disable_hca(struct mlx5_core_dev *dev)
 	return 0;
 }
 
+static int mlx5_irq_set_affinity_hint(struct mlx5_core_dev *mdev, int i)
+{
+	struct mlx5_priv *priv  = &mdev->priv;
+	struct msix_entry *msix = priv->msix_arr;
+	int irq                 = msix[i + MLX5_EQ_VEC_COMP_BASE].vector;
+	int numa_node           = dev_to_node(&mdev->pdev->dev);
+	int err;
+
+	if (!zalloc_cpumask_var(&priv->irq_info[i].mask, GFP_KERNEL)) {
+		mlx5_core_warn(mdev, "zalloc_cpumask_var failed");
+		return -ENOMEM;
+	}
+
+	err = cpumask_set_cpu_local_first(i, numa_node, priv->irq_info[i].mask);
+	if (err) {
+		mlx5_core_warn(mdev, "cpumask_set_cpu_local_first failed");
+		goto err_clear_mask;
+	}
+
+	err = irq_set_affinity_hint(irq, priv->irq_info[i].mask);
+	if (err) {
+		mlx5_core_warn(mdev, "irq_set_affinity_hint failed,irq 0x%.4x",
+			       irq);
+		goto err_clear_mask;
+	}
+
+	return 0;
+
+err_clear_mask:
+	free_cpumask_var(priv->irq_info[i].mask);
+	return err;
+}
+
+static void mlx5_irq_clear_affinity_hint(struct mlx5_core_dev *mdev, int i)
+{
+	struct mlx5_priv *priv  = &mdev->priv;
+	struct msix_entry *msix = priv->msix_arr;
+	int irq                 = msix[i + MLX5_EQ_VEC_COMP_BASE].vector;
+
+	irq_set_affinity_hint(irq, NULL);
+	free_cpumask_var(priv->irq_info[i].mask);
+}
+
+static int mlx5_irq_set_affinity_hints(struct mlx5_core_dev *mdev)
+{
+	int err;
+	int i;
+
+	for (i = 0; i < mdev->priv.eq_table.num_comp_vectors; i++) {
+		err = mlx5_irq_set_affinity_hint(mdev, i);
+		if (err)
+			goto err_out;
+	}
+
+	return 0;
+
+err_out:
+	for (i--; i >= 0; i--)
+		mlx5_irq_clear_affinity_hint(mdev, i);
+
+	return err;
+}
+
+static void mlx5_irq_clear_affinity_hints(struct mlx5_core_dev *mdev)
+{
+	int i;
+
+	for (i = 0; i < mdev->priv.eq_table.num_comp_vectors; i++)
+		mlx5_irq_clear_affinity_hint(mdev, i);
+}
+
 int mlx5_vector2eqn(struct mlx5_core_dev *dev, int vector, int *eqn, int *irqn)
 {
 	struct mlx5_eq_table *table = &dev->priv.eq_table;
@@ -549,7 +630,7 @@ static void free_comp_eqs(struct mlx5_core_dev *dev)
 static int alloc_comp_eqs(struct mlx5_core_dev *dev)
 {
 	struct mlx5_eq_table *table = &dev->priv.eq_table;
-	char name[MLX5_MAX_EQ_NAME];
+	char name[MLX5_MAX_IRQ_NAME];
 	struct mlx5_eq *eq;
 	int ncomp_vec;
 	int nent;
@@ -566,7 +647,7 @@ static int alloc_comp_eqs(struct mlx5_core_dev *dev)
 			goto clean;
 		}
 
-		snprintf(name, MLX5_MAX_EQ_NAME, "mlx5_comp%d", i);
+		snprintf(name, MLX5_MAX_IRQ_NAME, "mlx5_comp%d", i);
 		err = mlx5_create_map_eq(dev, eq,
 					 i + MLX5_EQ_VEC_COMP_BASE, nent, 0,
 					 name, &dev->priv.uuari.uars[0]);
@@ -730,6 +811,12 @@ static int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev)
 		goto err_stop_eqs;
 	}
 
+	err = mlx5_irq_set_affinity_hints(dev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to alloc affinity hint cpumask\n");
+		goto err_free_comp_eqs;
+	}
+
 	MLX5_INIT_DOORBELL_LOCK(&priv->cq_uar_lock);
 
 	mlx5_init_cq_table(dev);
@@ -739,6 +826,9 @@ static int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev)
 
 	return 0;
 
+err_free_comp_eqs:
+	free_comp_eqs(dev);
+
 err_stop_eqs:
 	mlx5_stop_eqs(dev);
 
@@ -793,6 +883,7 @@ static void mlx5_dev_cleanup(struct mlx5_core_dev *dev)
 	mlx5_cleanup_srq_table(dev);
 	mlx5_cleanup_qp_table(dev);
 	mlx5_cleanup_cq_table(dev);
+	mlx5_irq_clear_affinity_hints(dev);
 	free_comp_eqs(dev);
 	mlx5_stop_eqs(dev);
 	mlx5_free_uuars(dev, &priv->uuari);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index c4cf25f..9e89795 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -85,7 +85,7 @@ enum {
 };
 
 enum {
-	MLX5_MAX_EQ_NAME	= 32
+	MLX5_MAX_IRQ_NAME	= 32
 };
 
 enum {
@@ -349,7 +349,6 @@ struct mlx5_eq {
 	u8			eqn;
 	int			nent;
 	u64			mask;
-	char			name[MLX5_MAX_EQ_NAME];
 	struct list_head	list;
 	int			index;
 	struct mlx5_rsc_debug	*dbg;
@@ -412,7 +411,6 @@ struct mlx5_eq_table {
 	struct mlx5_eq		pages_eq;
 	struct mlx5_eq		async_eq;
 	struct mlx5_eq		cmd_eq;
-	struct msix_entry	*msix_arr;
 	int			num_comp_vectors;
 	/* protect EQs list
 	 */
@@ -465,9 +463,16 @@ struct mlx5_mr_table {
 	struct radix_tree_root	tree;
 };
 
+struct mlx5_irq_info {
+	cpumask_var_t mask;
+	char name[MLX5_MAX_IRQ_NAME];
+};
+
 struct mlx5_priv {
 	char			name[MLX5_MAX_NAME_LEN];
 	struct mlx5_eq_table	eq_table;
+	struct msix_entry	*msix_arr;
+	struct mlx5_irq_info	*irq_info;
 	struct mlx5_uuar_info	uuari;
 	MLX5_DECLARE_DOORBELL_LOCK(cq_uar_lock);
 
-- 
1.9.3
