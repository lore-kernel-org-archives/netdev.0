From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH v2 05/16] mlx4: Changing interrupt scheme
Date: Wed, 23 Mar 2011 10:37:47 +0200
Message-ID: <4D89B15B.1070201@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<markuze@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:58051 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755621Ab1CWIht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 04:37:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Adding a pool of MSI-X vectors and EQs that can be used explicitly by mlx4_core
customers (mlx4_ib, mlx4_en). The consumers will assign their own names to the
interrupt vectors. Those vectors are not opened at mlx4 device initialization,
opened by demand.
Changed the max number of possible EQs according to the new scheme, no longer relies on
on number of cores.
The new functionality is exposed through mlx4_assign_eq() and mlx4_release_eq().
Customers that do not use the new API will get completion vectors as before.

Signed-off-by: Markuze Alex <markuze@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/cq.c       |    2 +-
 drivers/net/mlx4/eq.c       |  107 ++++++++++++++++++++++++++++++++++++++++--
 drivers/net/mlx4/main.c     |   20 +++++++-
 drivers/net/mlx4/mlx4.h     |    6 ++
 drivers/net/mlx4/profile.c  |    4 +-
 include/linux/mlx4/device.h |    8 +++
 6 files changed, 134 insertions(+), 13 deletions(-)

diff --git a/drivers/net/mlx4/cq.c b/drivers/net/mlx4/cq.c
index 7cd34e9..bd8ef9f 100644
--- a/drivers/net/mlx4/cq.c
+++ b/drivers/net/mlx4/cq.c
@@ -198,7 +198,7 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent, struct mlx4_mtt *mtt,
 	u64 mtt_addr;
 	int err;
 
-	if (vector >= dev->caps.num_comp_vectors)
+	if (vector > dev->caps.num_comp_vectors + dev->caps.comp_pool)
 		return -EINVAL;
 
 	cq->vector = vector;
diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index 552d0fc..506cfd0 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -42,7 +42,7 @@
 #include "fw.h"
 
 enum {
-	MLX4_IRQNAME_SIZE	= 64
+	MLX4_IRQNAME_SIZE	= 32
 };
 
 enum {
@@ -317,8 +317,8 @@ static int mlx4_num_eq_uar(struct mlx4_dev *dev)
 	 * we need to map, take the difference of highest index and
 	 * the lowest index we'll use and add 1.
 	 */
-	return (dev->caps.num_comp_vectors + 1 + dev->caps.reserved_eqs) / 4 -
-		dev->caps.reserved_eqs / 4 + 1;
+	return (dev->caps.num_comp_vectors + 1 + dev->caps.reserved_eqs +
+		 dev->caps.comp_pool)/4 - dev->caps.reserved_eqs/4 + 1;
 }
 
 static void __iomem *mlx4_get_eq_uar(struct mlx4_dev *dev, struct mlx4_eq *eq)
@@ -496,16 +496,32 @@ static void mlx4_free_eq(struct mlx4_dev *dev,
 static void mlx4_free_irqs(struct mlx4_dev *dev)
 {
 	struct mlx4_eq_table *eq_table = &mlx4_priv(dev)->eq_table;
-	int i;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int	i, vec;
 
 	if (eq_table->have_irq)
 		free_irq(dev->pdev->irq, dev);
+
 	for (i = 0; i < dev->caps.num_comp_vectors + 1; ++i)
 		if (eq_table->eq[i].have_irq) {
 			free_irq(eq_table->eq[i].irq, eq_table->eq + i);
 			eq_table->eq[i].have_irq = 0;
 		}
 
+	for (i = 0; i < dev->caps.comp_pool; i++) {
+		/*
+		 * Freeing the assigned irq's
+		 * all bits should be 0, but we need to validate
+		 */
+		if (priv->msix_ctl.pool_bm & 1ULL << i) {
+			/* NO need protecting*/
+			vec = dev->caps.num_comp_vectors + 1 + i;
+			free_irq(priv->eq_table.eq[vec].irq,
+				 &priv->eq_table.eq[vec]);
+		}
+	}
+
+
 	kfree(eq_table->irq_names);
 }
 
@@ -578,7 +594,8 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 		(priv->eq_table.inta_pin < 32 ? 4 : 0);
 
 	priv->eq_table.irq_names =
-		kmalloc(MLX4_IRQNAME_SIZE * (dev->caps.num_comp_vectors + 1),
+		kmalloc(MLX4_IRQNAME_SIZE * (dev->caps.num_comp_vectors + 1 +
+					     dev->caps.comp_pool),
 			GFP_KERNEL);
 	if (!priv->eq_table.irq_names) {
 		err = -ENOMEM;
@@ -601,6 +618,22 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 	if (err)
 		goto err_out_comp;
 
+	/*if additional completion vectors poolsize is 0 this loop will not run*/
+	for (i = dev->caps.num_comp_vectors + 1;
+	      i < dev->caps.num_comp_vectors + dev->caps.comp_pool + 1; ++i) {
+
+		err = mlx4_create_eq(dev, dev->caps.num_cqs -
+					  dev->caps.reserved_cqs +
+					  MLX4_NUM_SPARE_EQE,
+				     (dev->flags & MLX4_FLAG_MSI_X) ? i : 0,
+				     &priv->eq_table.eq[i]);
+		if (err) {
+			--i;
+			goto err_out_unmap;
+		}
+	}
+
+
 	if (dev->flags & MLX4_FLAG_MSI_X) {
 		const char *eq_name;
 
@@ -686,7 +719,7 @@ void mlx4_cleanup_eq_table(struct mlx4_dev *dev)
 
 	mlx4_free_irqs(dev);
 
-	for (i = 0; i < dev->caps.num_comp_vectors + 1; ++i)
+	for (i = 0; i < dev->caps.num_comp_vectors + dev->caps.comp_pool + 1; ++i)
 		mlx4_free_eq(dev, &priv->eq_table.eq[i]);
 
 	mlx4_unmap_clr_int(dev);
@@ -743,3 +776,65 @@ int mlx4_test_interrupts(struct mlx4_dev *dev)
 	return err;
 }
 EXPORT_SYMBOL(mlx4_test_interrupts);
+
+int mlx4_assign_eq(struct mlx4_dev *dev, char* name, int * vector)
+{
+
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int vec = 0, err = 0, i;
+
+	spin_lock(&priv->msix_ctl.pool_lock);
+	for (i = 0; !vec && i < dev->caps.comp_pool; i++) {
+		if (~priv->msix_ctl.pool_bm & 1ULL << i) {
+			priv->msix_ctl.pool_bm |= 1ULL << i;
+			vec = dev->caps.num_comp_vectors + 1 + i;
+			snprintf(priv->eq_table.irq_names +
+					vec * MLX4_IRQNAME_SIZE,
+					MLX4_IRQNAME_SIZE, "%s", name);
+			err = request_irq(priv->eq_table.eq[vec].irq,
+					  mlx4_msi_x_interrupt, 0,
+					  &priv->eq_table.irq_names[vec<<5],
+					  priv->eq_table.eq + vec);
+			if (err) {
+				/*zero out bit by fliping it*/
+				priv->msix_ctl.pool_bm ^= 1 << i;
+				vec = 0;
+				continue;
+				/*we dont want to break here*/
+			}
+			eq_set_ci(&priv->eq_table.eq[vec], 1);
+		}
+	}
+	spin_unlock(&priv->msix_ctl.pool_lock);
+
+	if (vec) {
+		*vector = vec;
+	} else {
+		*vector = 0;
+		err = (i == dev->caps.comp_pool) ? -ENOSPC : err;
+	}
+	return err;
+}
+EXPORT_SYMBOL(mlx4_assign_eq);
+
+void mlx4_release_eq(struct mlx4_dev *dev, int vec)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	/*bm index*/
+	int i = vec - dev->caps.num_comp_vectors - 1;
+
+	if (likely(i >= 0)) {
+		/*sanity check , making sure were not trying to free irq's
+		  Belonging to a legacy EQ*/
+		spin_lock(&priv->msix_ctl.pool_lock);
+		if (priv->msix_ctl.pool_bm & 1ULL << i) {
+			free_irq(priv->eq_table.eq[vec].irq,
+				 &priv->eq_table.eq[vec]);
+			priv->msix_ctl.pool_bm &= ~(1ULL << i);
+		}
+		spin_unlock(&priv->msix_ctl.pool_lock);
+	}
+
+}
+EXPORT_SYMBOL(mlx4_release_eq);
+
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 2765a3c..517ca34 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -969,13 +969,15 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct msix_entry *entries;
-	int nreq;
+	int nreq = min_t(int, dev->caps.num_ports *
+			 min_t(int, num_online_cpus() + 1, MAX_MSIX_P_PORT)
+				+ MSIX_LEGACY_SZ, MAX_MSIX);
 	int err;
 	int i;
 
 	if (msi_x) {
 		nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
-			     num_possible_cpus() + 1);
+			     nreq);
 		entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
 		if (!entries)
 			goto no_msi;
@@ -998,7 +1000,15 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 			goto no_msi;
 		}
 
-		dev->caps.num_comp_vectors = nreq - 1;
+		if (nreq <
+		    MSIX_LEGACY_SZ + dev->caps.num_ports * MIN_MSIX_P_PORT) {
+			/*Working in legacy mode , all EQ's shared*/
+			dev->caps.comp_pool           = 0;
+			dev->caps.num_comp_vectors = nreq - 1;
+		} else {
+			dev->caps.comp_pool           = nreq - MSIX_LEGACY_SZ;
+			dev->caps.num_comp_vectors = MSIX_LEGACY_SZ - 1;
+		}
 		for (i = 0; i < nreq; ++i)
 			priv->eq_table.eq[i].irq = entries[i].vector;
 
@@ -1010,6 +1020,7 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 
 no_msi:
 	dev->caps.num_comp_vectors = 1;
+	dev->caps.comp_pool	   = 0;
 
 	for (i = 0; i < 2; ++i)
 		priv->eq_table.eq[i].irq = dev->pdev->irq;
@@ -1151,6 +1162,9 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	if (err)
 		goto err_close;
 
+	priv->msix_ctl.pool_bm = 0;
+	spin_lock_init(&priv->msix_ctl.pool_lock);
+
 	mlx4_enable_msi_x(dev);
 
 	err = mlx4_setup_hca(dev);
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 0da5bb7..67ee8da 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -282,6 +282,11 @@ struct mlx4_sense {
 	struct delayed_work	sense_poll;
 };
 
+struct mlx4_msix_ctl {
+	u64		pool_bm;
+	spinlock_t	pool_lock;
+};
+
 struct mlx4_priv {
 	struct mlx4_dev		dev;
 
@@ -313,6 +318,7 @@ struct mlx4_priv {
 	struct mlx4_port_info	port[MLX4_MAX_PORTS + 1];
 	struct mlx4_sense       sense;
 	struct mutex		port_mutex;
+	struct mlx4_msix_ctl	msix_ctl;
 };
 
 static inline struct mlx4_priv *mlx4_priv(struct mlx4_dev *dev)
diff --git a/drivers/net/mlx4/profile.c b/drivers/net/mlx4/profile.c
index e749f82..b967647 100644
--- a/drivers/net/mlx4/profile.c
+++ b/drivers/net/mlx4/profile.c
@@ -107,9 +107,7 @@ u64 mlx4_make_profile(struct mlx4_dev *dev,
 	profile[MLX4_RES_AUXC].num    = request->num_qp;
 	profile[MLX4_RES_SRQ].num     = request->num_srq;
 	profile[MLX4_RES_CQ].num      = request->num_cq;
-	profile[MLX4_RES_EQ].num      = min_t(unsigned, dev_cap->max_eqs,
-					      dev_cap->reserved_eqs +
-					      num_possible_cpus() + 1);
+	profile[MLX4_RES_EQ].num      = min_t(unsigned, dev_cap->max_eqs, MAX_MSIX);
 	profile[MLX4_RES_DMPT].num    = request->num_mpt;
 	profile[MLX4_RES_CMPT].num    = MLX4_NUM_CMPTS;
 	profile[MLX4_RES_MTT].num     = request->num_mtt;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 0492146..7838082 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -39,6 +39,11 @@
 
 #include <asm/atomic.h>
 
+#define MAX_MSIX_P_PORT		17
+#define MAX_MSIX		64
+#define MSIX_LEGACY_SZ		4
+#define MIN_MSIX_P_PORT		5
+
 enum {
 	MLX4_FLAG_MSI_X		= 1 << 0,
 	MLX4_FLAG_OLD_PORT_CMDS	= 1 << 1,
@@ -223,6 +228,7 @@ struct mlx4_caps {
 	int			num_eqs;
 	int			reserved_eqs;
 	int			num_comp_vectors;
+	int			comp_pool;
 	int			num_mpts;
 	int			num_mtt_segs;
 	int			mtts_per_seg;
@@ -526,5 +532,7 @@ void mlx4_fmr_unmap(struct mlx4_dev *dev, struct mlx4_fmr *fmr,
 int mlx4_fmr_free(struct mlx4_dev *dev, struct mlx4_fmr *fmr);
 int mlx4_SYNC_TPT(struct mlx4_dev *dev);
 int mlx4_test_interrupts(struct mlx4_dev *dev);
+int mlx4_assign_eq(struct mlx4_dev *dev, char* name , int* vector);
+void mlx4_release_eq(struct mlx4_dev *dev, int vec);
 
 #endif /* MLX4_DEVICE_H */
-- 
1.6.0.2





