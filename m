From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/9] net/mlx4_core: Enforce irq affinity changes immediatly
Date: Mon, 12 May 2014 10:43:17 +0300
Message-ID: <1399880605-28772-2-git-send-email-amirv@mellanox.com>
References: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59181 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751753AbaELHnq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2014 03:43:46 -0400
In-Reply-To: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
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
 drivers/net/ethernet/mellanox/mlx4/cq.c    |  3 ++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 11 +++++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |  6 +++
 drivers/net/ethernet/mellanox/mlx4/eq.c    | 62 ++++++++++++++++++++++++++++++
 include/linux/mlx4/device.h                |  2 +
 5 files changed, 82 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index 0487121..ed08f76 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -293,6 +293,9 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent,
 	atomic_set(&cq->refcount, 1);
 	init_completion(&cq->free);
 
+	cq->irq = priv->eq_table.eq[cq->vector].irq;
+	cq->irq_affinity_change = 0;
+
 	return 0;
 
 err_radix:
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index a151245..265ac03 100644
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
+			cq->mcq.irq_affinity_change = 0;
+			napi_complete(napi);
+			mlx4_en_arm_cq(priv, cq);
+			return 0;
+		}
+	} else {
 		/* Done for now */
+		cq->mcq.irq_affinity_change = 0;
 		napi_complete(napi);
 		mlx4_en_arm_cq(priv, cq);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 89585c6..81b7571 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -474,9 +474,15 @@ int mlx4_en_poll_tx_cq(struct napi_struct *napi, int budget)
 	/* If we used up all the quota - we're probably not done yet... */
 	if (done < budget) {
 		/* Done for now */
+		cq->mcq.irq_affinity_change = 0;
 		napi_complete(napi);
 		mlx4_en_arm_cq(priv, cq);
 		return done;
+	} else if (unlikely(cq->mcq.irq_affinity_change)) {
+		cq->mcq.irq_affinity_change = 0;
+		napi_complete(napi);
+		mlx4_en_arm_cq(priv, cq);
+		return 0;
 	}
 	return budget;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 6c088bc..947364d 100644
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
+			cq->irq_affinity_change = 1;
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
index ba87bd2..74f5aa8 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -586,6 +586,8 @@ struct mlx4_cq {
 
 	atomic_t		refcount;
 	struct completion	free;
+	u16                     irq;
+	bool                    irq_affinity_change;
 };
 
 struct mlx4_qp {
-- 
1.8.3.4
