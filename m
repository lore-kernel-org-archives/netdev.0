From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/4] {NET,IB}/mlx4: Add rmap support to mlx4_assign_eq
Date: Wed, 18 Jul 2012 17:19:21 +0300
Message-ID: <1342621162-18498-4-git-send-email-ogerlitz@mellanox.com>
References: <1342621162-18498-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, oren@mellanox.com,
	yevgenyp@mellanox.com, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:58666 "HELO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751276Ab2GROTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 10:19:31 -0400
In-Reply-To: <1342621162-18498-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>

Enable callers of mlx4_assign_eq to supply a pointer to cpu_rmap.
If supplied, the assigned IRQ is tracked using rmap infrastructure.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c          |    3 ++-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c |    3 ++-
 drivers/net/ethernet/mellanox/mlx4/eq.c    |   12 +++++++++++-
 include/linux/mlx4/device.h                |    4 +++-
 4 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 8a3a203..a07b774 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1159,7 +1159,8 @@ static void mlx4_ib_alloc_eqs(struct mlx4_dev *dev, struct mlx4_ib_dev *ibdev)
 			sprintf(name, "mlx4-ib-%d-%d@%s",
 				i, j, dev->pdev->bus->name);
 			/* Set IRQ for specific name (per ring) */
-			if (mlx4_assign_eq(dev, name, &ibdev->eq_table[eq])) {
+			if (mlx4_assign_eq(dev, name, NULL,
+					   &ibdev->eq_table[eq])) {
 				/* Use legacy (same as mlx4_en driver) */
 				pr_warn("Can't allocate EQ %d; reverting to legacy\n", eq);
 				ibdev->eq_table[eq] =
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 908a460..0ef6156 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -91,7 +91,8 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 				sprintf(name, "%s-%d", priv->dev->name,
 					cq->ring);
 				/* Set IRQ for specific name (per ring) */
-				if (mlx4_assign_eq(mdev->dev, name, &cq->vector)) {
+				if (mlx4_assign_eq(mdev->dev, name, NULL,
+						   &cq->vector)) {
 					cq->vector = (cq->ring + 1 + priv->port)
 					    % mdev->dev->caps.num_comp_vectors;
 					mlx4_warn(mdev, "Failed Assigning an EQ to "
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index bce98d9..12c3ed2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -39,6 +39,7 @@
 #include <linux/dma-mapping.h>
 
 #include <linux/mlx4/cmd.h>
+#include <linux/cpu_rmap.h>
 
 #include "mlx4.h"
 #include "fw.h"
@@ -1060,7 +1061,8 @@ int mlx4_test_interrupts(struct mlx4_dev *dev)
 }
 EXPORT_SYMBOL(mlx4_test_interrupts);
 
-int mlx4_assign_eq(struct mlx4_dev *dev, char* name, int * vector)
+int mlx4_assign_eq(struct mlx4_dev *dev, char *name, struct cpu_rmap *rmap,
+		   int *vector)
 {
 
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -1074,6 +1076,14 @@ int mlx4_assign_eq(struct mlx4_dev *dev, char* name, int * vector)
 			snprintf(priv->eq_table.irq_names +
 					vec * MLX4_IRQNAME_SIZE,
 					MLX4_IRQNAME_SIZE, "%s", name);
+#ifdef CONFIG_CPU_RMAP
+			if (rmap) {
+				err = irq_cpu_rmap_add(rmap,
+						       priv->eq_table.eq[vec].irq);
+				if (err)
+					mlx4_warn(dev, "Failed adding irq rmap\n");
+			}
+#endif
 			err = request_irq(priv->eq_table.eq[vec].irq,
 					  mlx4_msi_x_interrupt, 0,
 					  &priv->eq_table.irq_names[vec<<5],
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 6f0d133..4d7761f 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -36,6 +36,7 @@
 #include <linux/pci.h>
 #include <linux/completion.h>
 #include <linux/radix-tree.h>
+#include <linux/cpu_rmap.h>
 
 #include <linux/atomic.h>
 
@@ -784,7 +785,8 @@ void mlx4_fmr_unmap(struct mlx4_dev *dev, struct mlx4_fmr *fmr,
 int mlx4_fmr_free(struct mlx4_dev *dev, struct mlx4_fmr *fmr);
 int mlx4_SYNC_TPT(struct mlx4_dev *dev);
 int mlx4_test_interrupts(struct mlx4_dev *dev);
-int mlx4_assign_eq(struct mlx4_dev *dev, char* name , int* vector);
+int mlx4_assign_eq(struct mlx4_dev *dev, char *name, struct cpu_rmap *rmap,
+		   int *vector);
 void mlx4_release_eq(struct mlx4_dev *dev, int vec);
 
 int mlx4_wol_read(struct mlx4_dev *dev, u64 *config, int port);
-- 
1.7.1
