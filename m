From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 1/8] net/mlx4_core: Enforce irq affinity changes immediatly
Date: Wed, 14 May 2014 12:15:10 +0300
Message-ID: <1400058917-26313-2-git-send-email-ogerlitz@mellanox.com>
References: <1400058917-26313-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, saeedm@mellanox.com,
	eyalpe@mellanox.com, Yuval Atias <yuvala@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:44552 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753656AbaENJYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 05:24:10 -0400
In-Reply-To: <1400058917-26313-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Atias <yuvala@mellanox.com>

During heavy traffic, napi is constatntly polling the complition queue
and no interrupt is fired. Because of that, changes to irq affinity are
ignored until traffic is stopped and resumed.

By registering to the irq notifier mechanism, and forcing interrupt when
affinity is changed, irq affinity changes will be immediatly enforced.

Signed-off-by: Yuval Atias <yuvala@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cq.c    |    3 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |   11 ++++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    6 +++
 drivers/net/ethernet/mellanox/mlx4/eq.c    |   62 ++++++++++++++++++++++++++++
 include/linux/mlx4/device.h                |    3 +
 5 files changed, 83 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index 0487121..8542030 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -293,6 +293,9 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent,
 	atomic_set(&cq->refcount, 1);
 	init_completion(&cq->free);
 
+	cq->irq = priv->eq_table.eq[cq->vector].irq;
+	cq->irq_affinity_change = false;
+
 	return 0;
 
 err_radix:
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index a151245..e8c0d2b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -895,10 +895,17 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 	mlx4_en_cq_unlock_napi(cq);
 
 	/* If we used up all the quota - we're probably not done yet... */
-	if (done == budget)
+	if (done == budget) {
 		INC_PERF_COUNTER(priv->pstats.napi_quota);
-	else {
+		if (unlikely(cq->mcq.irq_affinity_change)) {
+			cq->mcq.irq_affinity_change = false;
+			napi_complete(napi);
+			mlx4_en_arm_cq(priv, cq);
+			return 0;
+		}
+	} else {
 		/* Done for now */
+		cq->mcq.irq_affinity_change = false;
 		napi_complete(napi);
 		mlx4_en_arm_cq(priv, cq);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 89585c6..cb96405 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -474,9 +474,15 @@ int mlx4_en_poll_tx_cq(struct napi_struct *napi, int budget)
 	/* If we used up all the quota - we're probably not done yet... */
 	if (done < budget) {
 		/* Done for now */
+		cq->mcq.irq_affinity_change = false;
 		napi_complete(napi);
 		mlx4_en_arm_cq(priv, cq);
 		return done;
+	} else if (unlikely(cq->mcq.irq_affinity_change)) {
+		cq->mcq.irq_affinity_change = false;
+		napi_complete(napi);
+		mlx4_en_arm_cq(priv, cq);
+		return 0;
 	}
 	return budget;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 6c088bc..d954ec1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -53,6 +53,11 @@ enum {
 	MLX4_EQ_ENTRY_SIZE	= 0x20
 };
 
+struct mlx4_irq_notify {
+	void *arg;
+	struct irq_affinity_notify notify;
+};
+
 #define MLX4_EQ_STATUS_OK	   ( 0 << 28)
 #define MLX4_EQ_STATUS_WRITE_FAIL  (10 << 28)
 #define MLX4_EQ_OWNER_SW	   ( 0 << 24)
@@ -1083,6 +1088,57 @@ static void mlx4_unmap_clr_int(struct mlx4_dev *dev)
 	iounmap(priv->clr_base);
 }
 
+static void mlx4_irq_notifier_notify(struct irq_affinity_notify *notify,
+				     const cpumask_t *mask)
+{
+	struct mlx4_irq_notify *n = container_of(notify,
+						 struct mlx4_irq_notify,
+						 notify);
+	struct mlx4_priv *priv = (struct mlx4_priv *)n->arg;
+	struct radix_tree_iter iter;
+	void **slot;
+
+	radix_tree_for_each_slot(slot, &priv->cq_table.tree, &iter, 0) {
+		struct mlx4_cq *cq = (struct mlx4_cq *)(*slot);
+
+		if (cq->irq == notify->irq)
+			cq->irq_affinity_change = true;
+	}
+}
+
+static void mlx4_release_irq_notifier(struct kref *ref)
+{
+	struct mlx4_irq_notify *n = container_of(ref, struct mlx4_irq_notify,
+						 notify.kref);
+	kfree(n);
+}
+
+static void mlx4_assign_irq_notifier(struct mlx4_priv *priv,
+				     struct mlx4_dev *dev, int irq)
+{
+	struct mlx4_irq_notify *irq_notifier = NULL;
+	int err = 0;
+
+	irq_notifier = kzalloc(sizeof(*irq_notifier), GFP_KERNEL);
+	if (!irq_notifier) {
+		mlx4_warn(dev, "Failed to allocate irq notifier. irq %d\n",
+			  irq);
+		return;
+	}
+
+	irq_notifier->notify.irq = irq;
+	irq_notifier->notify.notify = mlx4_irq_notifier_notify;
+	irq_notifier->notify.release = mlx4_release_irq_notifier;
+	irq_notifier->arg = priv;
+	err = irq_set_affinity_notifier(irq, &irq_notifier->notify);
+	if (err) {
+		kfree(irq_notifier);
+		irq_notifier = NULL;
+		mlx4_warn(dev, "Failed to set irq notifier. irq %d\n", irq);
+	}
+}
+
+
 int mlx4_alloc_eq_table(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -1353,6 +1409,9 @@ int mlx4_assign_eq(struct mlx4_dev *dev, char *name, struct cpu_rmap *rmap,
 				continue;
 				/*we dont want to break here*/
 			}
+			mlx4_assign_irq_notifier(priv, dev,
+						 priv->eq_table.eq[vec].irq);
+
 			eq_set_ci(&priv->eq_table.eq[vec], 1);
 		}
 	}
@@ -1379,6 +1438,9 @@ void mlx4_release_eq(struct mlx4_dev *dev, int vec)
 		  Belonging to a legacy EQ*/
 		mutex_lock(&priv->msix_ctl.pool_lock);
 		if (priv->msix_ctl.pool_bm & 1ULL << i) {
+			irq_set_affinity_notifier(
+				priv->eq_table.eq[vec].irq,
+				NULL);
 			free_irq(priv->eq_table.eq[vec].irq,
 				 &priv->eq_table.eq[vec]);
 			priv->msix_ctl.pool_bm &= ~(1ULL << i);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index ba87bd2..c0468e6 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -577,6 +577,9 @@ struct mlx4_cq {
 
 	u32			cons_index;
 
+	u16                     irq;
+	bool                    irq_affinity_change;
+
 	__be32		       *set_ci_db;
 	__be32		       *arm_db;
 	int			arm_sn;
-- 
1.7.1
