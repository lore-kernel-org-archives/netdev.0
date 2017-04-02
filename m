From: Sagi Grimberg <sagi@grimberg.me>
Subject: [PATCH rfc 2/6] mlx5: move affinity hints assignments to generic code
Date: Sun,  2 Apr 2017 16:41:28 +0300
Message-ID: <1491140492-25703-3-git-send-email-sagi@grimberg.me>
References: <1491140492-25703-1-git-send-email-sagi@grimberg.me>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Christoph Hellwig <hch@lst.de>
To: linux-rdma@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-block@vger.kernel.org
Return-path: <linux-block-owner@vger.kernel.org>
In-Reply-To: <1491140492-25703-1-git-send-email-sagi@grimberg.me>
Sender: linux-block-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

generic api takes care of spreading affinity similar to
what mlx5 open coded (and even handles better asymmetric
configurations). Ask the generic API to spread affinity
for us, and feed him pre_vectors that do not participate
in affinity settings (which is an improvement to what we
had before).

The affinity assignments should match what mlx5 tried to
do earlier but now we do not set affinity to async, cmd
and pages dedicated vectors.

Signed-off-by: Sagi Grimberg <sagi@grimberg.me>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  3 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c    | 81 ++---------------------
 include/linux/mlx5/driver.h                       |  1 -
 3 files changed, 6 insertions(+), 79 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index eec0d172761e..2bab0e1ceb94 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1375,7 +1375,8 @@ static void mlx5e_close_cq(struct mlx5e_cq *cq)
 
 static int mlx5e_get_cpu(struct mlx5e_priv *priv, int ix)
 {
-	return cpumask_first(priv->mdev->priv.irq_info[ix].mask);
+	return cpumask_first(pci_irq_get_affinity(priv->mdev->pdev,
+			MLX5_EQ_VEC_COMP_BASE + ix));
 }
 
 static int mlx5e_open_tx_cqs(struct mlx5e_channel *c,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 7c8672cbb369..8624a7451064 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -312,6 +312,7 @@ static int mlx5_alloc_irq_vectors(struct mlx5_core_dev *dev)
 {
 	struct mlx5_priv *priv = &dev->priv;
 	struct mlx5_eq_table *table = &priv->eq_table;
+	struct irq_affinity irqdesc = { .pre_vectors = MLX5_EQ_VEC_COMP_BASE, };
 	int num_eqs = 1 << MLX5_CAP_GEN(dev, log_max_eq);
 	int nvec;
 
@@ -325,9 +326,10 @@ static int mlx5_alloc_irq_vectors(struct mlx5_core_dev *dev)
 	if (!priv->irq_info)
 		goto err_free_msix;
 
-	nvec = pci_alloc_irq_vectors(dev->pdev,
+	nvec = pci_alloc_irq_vectors_affinity(dev->pdev,
 			MLX5_EQ_VEC_COMP_BASE + 1, nvec,
-			PCI_IRQ_MSIX);
+			PCI_IRQ_MSIX | PCI_IRQ_AFFINITY,
+			&irqdesc);
 	if (nvec < 0)
 		return nvec;
 
@@ -600,71 +602,6 @@ u64 mlx5_read_internal_timer(struct mlx5_core_dev *dev)
 	return (u64)timer_l | (u64)timer_h1 << 32;
 }
 
-static int mlx5_irq_set_affinity_hint(struct mlx5_core_dev *mdev, int i)
-{
-	struct mlx5_priv *priv  = &mdev->priv;
-	int irq = pci_irq_vector(mdev->pdev, MLX5_EQ_VEC_COMP_BASE + i);
-	int err;
-
-	if (!zalloc_cpumask_var(&priv->irq_info[i].mask, GFP_KERNEL)) {
-		mlx5_core_warn(mdev, "zalloc_cpumask_var failed");
-		return -ENOMEM;
-	}
-
-	cpumask_set_cpu(cpumask_local_spread(i, priv->numa_node),
-			priv->irq_info[i].mask);
-
-	err = irq_set_affinity_hint(irq, priv->irq_info[i].mask);
-	if (err) {
-		mlx5_core_warn(mdev, "irq_set_affinity_hint failed,irq 0x%.4x",
-			       irq);
-		goto err_clear_mask;
-	}
-
-	return 0;
-
-err_clear_mask:
-	free_cpumask_var(priv->irq_info[i].mask);
-	return err;
-}
-
-static void mlx5_irq_clear_affinity_hint(struct mlx5_core_dev *mdev, int i)
-{
-	struct mlx5_priv *priv  = &mdev->priv;
-	int irq = pci_irq_vector(mdev->pdev, MLX5_EQ_VEC_COMP_BASE + i);
-
-	irq_set_affinity_hint(irq, NULL);
-	free_cpumask_var(priv->irq_info[i].mask);
-}
-
-static int mlx5_irq_set_affinity_hints(struct mlx5_core_dev *mdev)
-{
-	int err;
-	int i;
-
-	for (i = 0; i < mdev->priv.eq_table.num_comp_vectors; i++) {
-		err = mlx5_irq_set_affinity_hint(mdev, i);
-		if (err)
-			goto err_out;
-	}
-
-	return 0;
-
-err_out:
-	for (i--; i >= 0; i--)
-		mlx5_irq_clear_affinity_hint(mdev, i);
-
-	return err;
-}
-
-static void mlx5_irq_clear_affinity_hints(struct mlx5_core_dev *mdev)
-{
-	int i;
-
-	for (i = 0; i < mdev->priv.eq_table.num_comp_vectors; i++)
-		mlx5_irq_clear_affinity_hint(mdev, i);
-}
-
 int mlx5_vector2eqn(struct mlx5_core_dev *dev, int vector, int *eqn,
 		    unsigned int *irqn)
 {
@@ -1116,12 +1053,6 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 		goto err_stop_eqs;
 	}
 
-	err = mlx5_irq_set_affinity_hints(dev);
-	if (err) {
-		dev_err(&pdev->dev, "Failed to alloc affinity hint cpumask\n");
-		goto err_affinity_hints;
-	}
-
 	err = mlx5_init_fs(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to init flow steering\n");
@@ -1165,9 +1096,6 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	mlx5_cleanup_fs(dev);
 
 err_fs:
-	mlx5_irq_clear_affinity_hints(dev);
-
-err_affinity_hints:
 	free_comp_eqs(dev);
 
 err_stop_eqs:
@@ -1234,7 +1162,6 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	mlx5_eswitch_detach(dev->priv.eswitch);
 #endif
 	mlx5_cleanup_fs(dev);
-	mlx5_irq_clear_affinity_hints(dev);
 	free_comp_eqs(dev);
 	mlx5_stop_eqs(dev);
 	mlx5_put_uars_page(dev, priv->uar);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index a9891df94ce0..4c7cf4dfb024 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -527,7 +527,6 @@ struct mlx5_core_sriov {
 };
 
 struct mlx5_irq_info {
-	cpumask_var_t mask;
 	char name[MLX5_MAX_IRQ_NAME];
 };
 
-- 
2.7.4
