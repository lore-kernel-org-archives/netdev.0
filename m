From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 12/25] mlx4_core: associate resources with specific functions
Date: Wed, 04 Nov 2009 17:31:21 +0200
Message-ID: <4AF19E49.3040401@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Resources are associated with functions by means of pds - the upper 7 msbs
specify the function id. Since cqs do not refer to a specific pd, the function
id is passed explicitly to hw in the cq context.
For uars, which are statically partitioned between slaves, we only need to adjust
their offsets with respect to the associated function bar.

Signed-off-by: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/cq.c |    4 +++-
 drivers/net/mlx4/eq.c |   13 ++++++++++++-
 drivers/net/mlx4/pd.c |   12 +++++++++---
 3 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mlx4/cq.c b/drivers/net/mlx4/cq.c
index 3fb9f7f..9f9f246 100644
--- a/drivers/net/mlx4/cq.c
+++ b/drivers/net/mlx4/cq.c
@@ -59,7 +59,8 @@ struct mlx4_cq_context {
 	__be32			solicit_producer_index;
 	__be32			consumer_index;
 	__be32			producer_index;
-	u32			reserved4[2];
+	__be32			pd; /* for sriov guest id */
+	u32			reserved4;
 	__be64			db_rec_addr;
 };
 
@@ -293,6 +294,7 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent, struct mlx4_mtt *mtt,
 	mtt_addr = mlx4_mtt_addr(dev, mtt);
 	cq_context->mtt_base_addr_h = mtt_addr >> 32;
 	cq_context->mtt_base_addr_l = cpu_to_be32(mtt_addr & 0xffffffff);
+	cq_context->pd = cpu_to_be32(dev->caps.pd_base << dev->caps.slave_pd_shift);
 	cq_context->db_rec_addr     = cpu_to_be64(db_rec);
 
 	err = mlx4_SW2HW_CQ(dev, mailbox, cq->cqn);
diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index a27e1c4..46064cc 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -486,9 +486,20 @@ static void __iomem *mlx4_get_eq_uar(struct mlx4_dev *dev, struct mlx4_eq *eq)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	int index;
+	int offset;
 
-	index = eq->eqn / 4 - dev->caps.reserved_eqs / 4;
+	/* CX1: slave EQ DBs are located in the comm channel page */
+	if (mlx4_is_slave(dev) || mlx4_is_master(dev)) {
+		if (eq->eqn - dev->caps.reserved_eqs >= MLX4_MFUNC_EQ_NUM) {
+			mlx4_err(dev, "eqn:%d doorbell out of range (reserved:%d)\n",
+				 eq->eqn, dev->caps.reserved_eqs);
+			return NULL;
+		}
+		offset = 0x800 + (eq->eqn - dev->caps.reserved_eqs) * 8;
+		return ((void *) priv->mfunc.comm) + offset;
+	}
 
+	index = eq->eqn / 4 - dev->caps.reserved_eqs / 4;
 	if (!priv->eq_table.uar_map[index]) {
 		priv->eq_table.uar_map[index] =
 			ioremap(pci_resource_start(dev->pdev, 2) +
diff --git a/drivers/net/mlx4/pd.c b/drivers/net/mlx4/pd.c
index c4988d6..08eaf08 100644
--- a/drivers/net/mlx4/pd.c
+++ b/drivers/net/mlx4/pd.c
@@ -45,7 +45,7 @@ int mlx4_pd_alloc(struct mlx4_dev *dev, u32 *pdn)
 	*pdn = mlx4_bitmap_alloc(&priv->pd_bitmap);
 	if (*pdn == -1)
 		return -ENOMEM;
-
+	*pdn |= dev->caps.pd_base << dev->caps.slave_pd_shift;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx4_pd_alloc);
@@ -72,12 +72,18 @@ void mlx4_cleanup_pd_table(struct mlx4_dev *dev)
 
 int mlx4_uar_alloc(struct mlx4_dev *dev, struct mlx4_uar *uar)
 {
+	int offset;
+
 	uar->index = mlx4_bitmap_alloc(&mlx4_priv(dev)->uar_table.bitmap);
 	if (uar->index == -1)
 		return -ENOMEM;
 
-	uar->pfn = (pci_resource_start(dev->pdev, 2) >> PAGE_SHIFT) + uar->index;
-
+	if (mlx4_is_slave(dev))
+		offset = uar->index % ((int) pci_resource_len(dev->pdev, 2) /
+				       dev->caps.uar_page_size);
+	else
+		offset = uar->index;
+	uar->pfn = (pci_resource_start(dev->pdev, 2) >> PAGE_SHIFT) + offset;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx4_uar_alloc);
-- 
1.6.1.3




--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
