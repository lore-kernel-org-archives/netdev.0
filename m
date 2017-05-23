From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 8/8] net/mlx5: Tolerate irq_set_affinity_hint() failures
Date: Tue, 23 May 2017 17:16:10 +0300
Message-ID: <20170523141610.27833-9-saeedm@mellanox.com>
References: <20170523141610.27833-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        kernel-team@fb.com, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44686 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S966455AbdEWOQl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 10:16:41 -0400
In-Reply-To: <20170523141610.27833-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Add tolerance to failures of irq_set_affinity_hint().
Its role is to give hints that optimizes performance,
and should not block the driver load.

In non-SMP systems, functionality is not available as
there is a single core, and all these calls definitely
fail.  Hence, do not call the function and avoid the
warning prints.

Fixes: db058a186f98 ("net/mlx5_core: Set irq affinity hints")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Cc: kernel-team@fb.com
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 0c123d571b4c..fe5546bb4153 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -612,7 +612,6 @@ static int mlx5_irq_set_affinity_hint(struct mlx5_core_dev *mdev, int i)
 	struct mlx5_priv *priv  = &mdev->priv;
 	struct msix_entry *msix = priv->msix_arr;
 	int irq                 = msix[i + MLX5_EQ_VEC_COMP_BASE].vector;
-	int err;
 
 	if (!zalloc_cpumask_var(&priv->irq_info[i].mask, GFP_KERNEL)) {
 		mlx5_core_warn(mdev, "zalloc_cpumask_var failed");
@@ -622,18 +621,12 @@ static int mlx5_irq_set_affinity_hint(struct mlx5_core_dev *mdev, int i)
 	cpumask_set_cpu(cpumask_local_spread(i, priv->numa_node),
 			priv->irq_info[i].mask);
 
-	err = irq_set_affinity_hint(irq, priv->irq_info[i].mask);
-	if (err) {
-		mlx5_core_warn(mdev, "irq_set_affinity_hint failed,irq 0x%.4x",
-			       irq);
-		goto err_clear_mask;
-	}
+#ifdef CONFIG_SMP
+	if (irq_set_affinity_hint(irq, priv->irq_info[i].mask))
+		mlx5_core_warn(mdev, "irq_set_affinity_hint failed, irq 0x%.4x", irq);
+#endif
 
 	return 0;
-
-err_clear_mask:
-	free_cpumask_var(priv->irq_info[i].mask);
-	return err;
 }
 
 static void mlx5_irq_clear_affinity_hint(struct mlx5_core_dev *mdev, int i)
-- 
2.11.0
