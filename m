From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net 1/3] net/mlx4_en: Don't use irq_affinity_notifier to track changes in IRQ affinity map
Date: Mon, 23 Jun 2014 17:41:56 +0300
Message-ID: <1403534518-20898-2-git-send-email-amirv@mellanox.com>
References: <1403534518-20898-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:36867 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754269AbaFWOmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 10:42:11 -0400
In-Reply-To: <1403534518-20898-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IRQ affinity notifier can only have a single notifier - cpu_rmap
notifier. Can't use it to track changes in IRQ affinity map.
Detect IRQ affinity changes by comparing CPU to current IRQ affinity map
during NAPI poll thread.

Fixes: 2eacc23 ("net/mlx4_core: Enforce irq affinity changes immediatly")
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cq.c      |  2 -
 drivers/net/ethernet/mellanox/mlx4/en_cq.c   |  4 ++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 15 ++++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   |  6 ---
 drivers/net/ethernet/mellanox/mlx4/eq.c      | 69 ++++------------------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  1 +
 include/linux/mlx4/device.h                  |  4 +-
 7 files changed, 27 insertions(+), 74 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index 80f7252..56022d6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -294,8 +294,6 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent,
 	init_completion(&cq->free);
 
 	cq->irq = priv->eq_table.eq[cq->vector].irq;
-	cq->irq_affinity_change = false;
-
 	return 0;
 
 err_radix:
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 4b21307..1213cc7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -128,6 +128,10 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 					mlx4_warn(mdev, "Failed assigning an EQ to %s, falling back to legacy EQ's\n",
 						  name);
 				}
+
+				cq->irq_desc =
+					irq_to_desc(mlx4_eq_get_irq(mdev->dev,
+								    cq->vector));
 			}
 		} else {
 			cq->vector = (cq->ring + 1 + priv->port) %
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index d2d4157..1e2c143 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -896,16 +896,25 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 
 	/* If we used up all the quota - we're probably not done yet... */
 	if (done == budget) {
+		int cpu_curr;
+		const struct cpumask *aff;
+
 		INC_PERF_COUNTER(priv->pstats.napi_quota);
-		if (unlikely(cq->mcq.irq_affinity_change)) {
-			cq->mcq.irq_affinity_change = false;
+
+		cpu_curr = smp_processor_id();
+		aff = cq->irq_desc->irq_data.affinity;
+
+		if (unlikely(!cpumask_test_cpu(cpu_curr, aff))) {
+			/* Current cpu is not according to smp_irq_affinity -
+			 * probably affinity changed. need to stop this NAPI
+			 * poll, and restart it on the right CPU
+			 */
 			napi_complete(napi);
 			mlx4_en_arm_cq(priv, cq);
 			return 0;
 		}
 	} else {
 		/* Done for now */
-		cq->mcq.irq_affinity_change = false;
 		napi_complete(napi);
 		mlx4_en_arm_cq(priv, cq);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 8be7483..ac3dead 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -474,15 +474,9 @@ int mlx4_en_poll_tx_cq(struct napi_struct *napi, int budget)
 	/* If we used up all the quota - we're probably not done yet... */
 	if (done < budget) {
 		/* Done for now */
-		cq->mcq.irq_affinity_change = false;
 		napi_complete(napi);
 		mlx4_en_arm_cq(priv, cq);
 		return done;
-	} else if (unlikely(cq->mcq.irq_affinity_change)) {
-		cq->mcq.irq_affinity_change = false;
-		napi_complete(napi);
-		mlx4_en_arm_cq(priv, cq);
-		return 0;
 	}
 	return budget;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index d954ec1..2a004b3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -53,11 +53,6 @@ enum {
 	MLX4_EQ_ENTRY_SIZE	= 0x20
 };
 
-struct mlx4_irq_notify {
-	void *arg;
-	struct irq_affinity_notify notify;
-};
-
 #define MLX4_EQ_STATUS_OK	   ( 0 << 28)
 #define MLX4_EQ_STATUS_WRITE_FAIL  (10 << 28)
 #define MLX4_EQ_OWNER_SW	   ( 0 << 24)
@@ -1088,57 +1083,6 @@ static void mlx4_unmap_clr_int(struct mlx4_dev *dev)
 	iounmap(priv->clr_base);
 }
 
-static void mlx4_irq_notifier_notify(struct irq_affinity_notify *notify,
-				     const cpumask_t *mask)
-{
-	struct mlx4_irq_notify *n = container_of(notify,
-						 struct mlx4_irq_notify,
-						 notify);
-	struct mlx4_priv *priv = (struct mlx4_priv *)n->arg;
-	struct radix_tree_iter iter;
-	void **slot;
-
-	radix_tree_for_each_slot(slot, &priv->cq_table.tree, &iter, 0) {
-		struct mlx4_cq *cq = (struct mlx4_cq *)(*slot);
-
-		if (cq->irq == notify->irq)
-			cq->irq_affinity_change = true;
-	}
-}
-
-static void mlx4_release_irq_notifier(struct kref *ref)
-{
-	struct mlx4_irq_notify *n = container_of(ref, struct mlx4_irq_notify,
-						 notify.kref);
-	kfree(n);
-}
-
-static void mlx4_assign_irq_notifier(struct mlx4_priv *priv,
-				     struct mlx4_dev *dev, int irq)
-{
-	struct mlx4_irq_notify *irq_notifier = NULL;
-	int err = 0;
-
-	irq_notifier = kzalloc(sizeof(*irq_notifier), GFP_KERNEL);
-	if (!irq_notifier) {
-		mlx4_warn(dev, "Failed to allocate irq notifier. irq %d\n",
-			  irq);
-		return;
-	}
-
-	irq_notifier->notify.irq = irq;
-	irq_notifier->notify.notify = mlx4_irq_notifier_notify;
-	irq_notifier->notify.release = mlx4_release_irq_notifier;
-	irq_notifier->arg = priv;
-	err = irq_set_affinity_notifier(irq, &irq_notifier->notify);
-	if (err) {
-		kfree(irq_notifier);
-		irq_notifier = NULL;
-		mlx4_warn(dev, "Failed to set irq notifier. irq %d\n", irq);
-	}
-}
-
-
 int mlx4_alloc_eq_table(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -1409,8 +1353,6 @@ int mlx4_assign_eq(struct mlx4_dev *dev, char *name, struct cpu_rmap *rmap,
 				continue;
 				/*we dont want to break here*/
 			}
-			mlx4_assign_irq_notifier(priv, dev,
-						 priv->eq_table.eq[vec].irq);
 
 			eq_set_ci(&priv->eq_table.eq[vec], 1);
 		}
@@ -1427,6 +1369,14 @@ int mlx4_assign_eq(struct mlx4_dev *dev, char *name, struct cpu_rmap *rmap,
 }
 EXPORT_SYMBOL(mlx4_assign_eq);
 
+int mlx4_eq_get_irq(struct mlx4_dev *dev, int vec)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	return priv->eq_table.eq[vec].irq;
+}
+EXPORT_SYMBOL(mlx4_eq_get_irq);
+
 void mlx4_release_eq(struct mlx4_dev *dev, int vec)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -1438,9 +1388,6 @@ void mlx4_release_eq(struct mlx4_dev *dev, int vec)
 		  Belonging to a legacy EQ*/
 		mutex_lock(&priv->msix_ctl.pool_lock);
 		if (priv->msix_ctl.pool_bm & 1ULL << i) {
-			irq_set_affinity_notifier(
-				priv->eq_table.eq[vec].irq,
-				NULL);
 			free_irq(priv->eq_table.eq[vec].irq,
 				 &priv->eq_table.eq[vec]);
 			priv->msix_ctl.pool_bm &= ~(1ULL << i);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 0e15295..624e193 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -343,6 +343,7 @@ struct mlx4_en_cq {
 #define CQ_USER_PEND (MLX4_EN_CQ_STATE_POLL | MLX4_EN_CQ_STATE_POLL_YIELD)
 	spinlock_t poll_lock; /* protects from LLS/napi conflicts */
 #endif  /* CONFIG_NET_RX_BUSY_POLL */
+	struct irq_desc *irq_desc;
 };
 
 struct mlx4_en_port_profile {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index b12f4bb..35b51e7 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -578,8 +578,6 @@ struct mlx4_cq {
 	u32			cons_index;
 
 	u16                     irq;
-	bool                    irq_affinity_change;
-
 	__be32		       *set_ci_db;
 	__be32		       *arm_db;
 	int			arm_sn;
@@ -1167,6 +1165,8 @@ int mlx4_assign_eq(struct mlx4_dev *dev, char *name, struct cpu_rmap *rmap,
 		   int *vector);
 void mlx4_release_eq(struct mlx4_dev *dev, int vec);
 
+int mlx4_eq_get_irq(struct mlx4_dev *dev, int vec);
+
 int mlx4_get_phys_port_id(struct mlx4_dev *dev);
 int mlx4_wol_read(struct mlx4_dev *dev, u64 *config, int port);
 int mlx4_wol_write(struct mlx4_dev *dev, u64 config, int port);
-- 
1.8.3.4
