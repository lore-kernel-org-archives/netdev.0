From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 3/4] net/mlx4_core: Move affinity hints to mlx4_core ownership
Date: Sun, 31 May 2015 09:30:17 +0300
Message-ID: <1433053818-30251-4-git-send-email-ogerlitz@mellanox.com>
References: <1433053818-30251-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35215 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758044AbbEaGbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 May 2015 02:31:10 -0400
In-Reply-To: <1433053818-30251-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Now that EQs management is in the sole responsibility of mlx4_core,
the IRQ affinity hints configuration should be in its hands as well.
request_irq is called only once by the first consumer (maybe mlx4_ib),
so mlx4_en passes the affinity mask too late. We also need to request
vectors according to the cores we want to run on.

mlx4_core distribution of IRQs to cores is straight forward,
EQ(i)->IRQ will set affinity hint to core i.
Consumers need to request EQ vectors, according to their cores
considerations (NUMA).

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c |   10 +-------
 drivers/net/ethernet/mellanox/mlx4/eq.c    |   21 ++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/main.c  |   36 ++++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h  |    1 +
 4 files changed, 59 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index d71c567..63769df 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -114,7 +114,7 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 	if (cq->is_tx == RX) {
 		if (!mlx4_is_eq_vector_valid(mdev->dev, priv->port,
 					     cq->vector)) {
-			cq->vector = cq_idx;
+			cq->vector = cpumask_first(priv->rx_ring[cq->ring]->affinity_mask);
 
 			err = mlx4_assign_eq(mdev->dev, priv->port,
 					     &cq->vector);
@@ -160,13 +160,6 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 		netif_napi_add(cq->dev, &cq->napi, mlx4_en_poll_tx_cq,
 			       NAPI_POLL_WEIGHT);
 	} else {
-		struct mlx4_en_rx_ring *ring = priv->rx_ring[cq->ring];
-
-		err = irq_set_affinity_hint(cq->mcq.irq,
-					    ring->affinity_mask);
-		if (err)
-			mlx4_warn(mdev, "Failed setting affinity hint\n");
-
 		netif_napi_add(cq->dev, &cq->napi, mlx4_en_poll_rx_cq, 64);
 		napi_hash_add(&cq->napi);
 	}
@@ -205,7 +198,6 @@ void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 	if (!cq->is_tx) {
 		napi_hash_del(&cq->napi);
 		synchronize_rcu();
-		irq_set_affinity_hint(cq->mcq.irq, NULL);
 	}
 	netif_napi_del(&cq->napi);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 2e6fc6a..1116882 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -221,6 +221,20 @@ static void mlx4_slave_event(struct mlx4_dev *dev, int slave,
 	slave_event(dev, slave, eqe);
 }
 
+static void mlx4_set_eq_affinity_hint(struct mlx4_priv *priv, int vec)
+{
+	int hint_err;
+	struct mlx4_dev *dev = &priv->dev;
+	struct mlx4_eq *eq = &priv->eq_table.eq[vec];
+
+	if (!eq->affinity_mask || cpumask_empty(eq->affinity_mask))
+		return;
+
+	hint_err = irq_set_affinity_hint(eq->irq, eq->affinity_mask);
+	if (hint_err)
+		mlx4_warn(dev, "irq_set_affinity_hint failed, err %d\n", hint_err);
+}
+
 int mlx4_gen_pkey_eqe(struct mlx4_dev *dev, int slave, u8 port)
 {
 	struct mlx4_eqe eqe;
@@ -1092,6 +1106,10 @@ static void mlx4_free_irqs(struct mlx4_dev *dev)
 
 	for (i = 0; i < dev->caps.num_comp_vectors + 1; ++i)
 		if (eq_table->eq[i].have_irq) {
+			free_cpumask_var(eq_table->eq[i].affinity_mask);
+#if defined(CONFIG_SMP)
+			irq_set_affinity_hint(eq_table->eq[i].irq, NULL);
+#endif
 			free_irq(eq_table->eq[i].irq, eq_table->eq + i);
 			eq_table->eq[i].have_irq = 0;
 		}
@@ -1483,6 +1501,9 @@ int mlx4_assign_eq(struct mlx4_dev *dev, u8 port, int *vector)
 			clear_bit(*prequested_vector, priv->msix_ctl.pool_bm);
 			*prequested_vector = -1;
 		} else {
+#if defined(CONFIG_SMP)
+			mlx4_set_eq_affinity_hint(priv, *prequested_vector);
+#endif
 			eq_set_ci(&priv->eq_table.eq[*prequested_vector], 1);
 			priv->eq_table.eq[*prequested_vector].have_irq = 1;
 		}
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 3ec5113..0dbd704 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2481,6 +2481,36 @@ err_uar_table_free:
 	return err;
 }
 
+static int mlx4_init_affinity_hint(struct mlx4_dev *dev, int port, int eqn)
+{
+	int requested_cpu = 0;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_eq *eq;
+	int off = 0;
+	int i;
+
+	if (eqn > dev->caps.num_comp_vectors)
+		return -EINVAL;
+
+	for (i = 1; i < port; i++)
+		off += mlx4_get_eqs_per_port(dev, i);
+
+	requested_cpu = eqn - off - !!(eqn > MLX4_EQ_ASYNC);
+
+	/* Meaning EQs are shared, and this call comes from the second port */
+	if (requested_cpu < 0)
+		return 0;
+
+	eq = &priv->eq_table.eq[eqn];
+
+	if (!zalloc_cpumask_var(&eq->affinity_mask, GFP_KERNEL))
+		return -ENOMEM;
+
+	cpumask_set_cpu(requested_cpu, eq->affinity_mask);
+
+	return 0;
+}
+
 static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -2525,9 +2555,15 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 			if (MLX4_IS_LEGACY_EQ_MODE(dev->caps)) {
 				bitmap_fill(priv->eq_table.eq[i].actv_ports.ports,
 					    dev->caps.num_ports);
+				/* We don't set affinity hint when there
+				 * aren't enough EQs
+				 */
 			} else {
 				set_bit(port,
 					priv->eq_table.eq[i].actv_ports.ports);
+				if (mlx4_init_affinity_hint(dev, port + 1, i))
+					mlx4_warn(dev, "Couldn't init hint cpumask for EQ %d\n",
+						  i);
 			}
 			/* We divide the Eqs evenly between the two ports.
 			 * (dev->caps.num_comp_vectors / dev->caps.num_ports)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index ff40098..f424900 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -399,6 +399,7 @@ struct mlx4_eq {
 	struct mlx4_eq_tasklet	tasklet_ctx;
 	struct mlx4_active_ports actv_ports;
 	u32			ref_count;
+	cpumask_var_t		affinity_mask;
 };
 
 struct mlx4_slave_eqe {
-- 
1.7.1
