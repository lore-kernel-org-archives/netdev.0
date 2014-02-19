From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 1/3] net/mlx4_en: Use affinity hint
Date: Wed, 19 Feb 2014 14:58:02 +0200
Message-ID: <1392814684-2129-2-git-send-email-amirv@mellanox.com>
References: <1392814684-2129-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40933 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753468AbaBSM62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 07:58:28 -0500
In-Reply-To: <1392814684-2129-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Atias <yuvala@mellanox.com>

The affinity hint mechanism is used by the user space
daemon, irqbalancer, to indicate a preferred CPU mask for irqs.
Irqbalancer can use this hint to balance the irqs between the
cpus indicated by the mask.

We wish the HCA to preferentially map the IRQs it uses to numa cores
close to it.
To accomplish this, we use affinity hint: first we map IRQs to close
numa cores.
If these are exhausted, the remaining IRQs are mapped to far numa
cores.

CC: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Yuval Atias <yuvala@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>

---

Changes from V0:
Use numa bit mask to set affinity hint.
Move dynamic allocation to mlx4_en_start_port function.
Handle error when device numa node is not known.
Change rx_ring affinity_mask var type to cpumask_var_t.

 drivers/infiniband/hw/mlx4/main.c              |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c     |  5 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 88 ++++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |  7 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c        | 14 +++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  3 +-
 include/linux/mlx4/device.h                    |  2 +-
 7 files changed, 109 insertions(+), 12 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index c2702f5..a7dcfa7 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1763,7 +1763,7 @@ static void mlx4_ib_alloc_eqs(struct mlx4_dev *dev, struct mlx4_ib_dev *ibdev)
 				i, j, dev->pdev->bus->name);
 			/* Set IRQ for specific name (per ring) */
 			if (mlx4_assign_eq(dev, name, NULL,
-					   &ibdev->eq_table[eq])) {
+					   &ibdev->eq_table[eq], NULL)) {
 				/* Use legacy (same as mlx4_en driver) */
 				pr_warn("Can't allocate EQ %d; reverting to legacy\n", eq);
 				ibdev->eq_table[eq] =
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 70e9532..5ef3f7a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -96,7 +96,7 @@ err_cq:
 }
 
 int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
-			int cq_idx)
+			int cq_idx, cpumask_var_t affinity_mask)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int err = 0;
@@ -123,7 +123,8 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 					cq->ring);
 				/* Set IRQ for specific name (per ring) */
 				if (mlx4_assign_eq(mdev->dev, name, rmap,
-						   &cq->vector)) {
+						   &cq->vector,
+						   affinity_mask)) {
 					cq->vector = (cq->ring + 1 + priv->port)
 					    % mdev->dev->caps.num_comp_vectors;
 					mlx4_warn(mdev, "Failed Assigning an EQ to "
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index fad4531..88f16c0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1533,6 +1533,55 @@ static void mlx4_en_linkstate(struct work_struct *work)
 	mutex_unlock(&mdev->state_lock);
 }
 
+static int mlx4_en_rings_affinity_hint(struct mlx4_en_priv *priv,
+				cpumask_var_t non_numa_cores_mask,
+				cpumask_var_t numa_cores_mask,
+				const struct cpumask **p_affinity_numa_mask,
+				int *affinity_cpu)
+{
+	if (priv->mdev->dev->numa_node == -1)
+		goto err;
+	*p_affinity_numa_mask = cpumask_of_node(priv->mdev->dev->numa_node);
+	if (!*p_affinity_numa_mask)
+		goto err;
+	cpumask_copy(numa_cores_mask, *p_affinity_numa_mask);
+	if (!cpumask_and(numa_cores_mask,
+			 cpu_online_mask, numa_cores_mask)) {
+		en_warn(priv, "Failed to find online cores for numa\n");
+		goto err;
+	}
+	cpumask_xor(non_numa_cores_mask, cpu_online_mask,
+		    numa_cores_mask);
+	*p_affinity_numa_mask = numa_cores_mask;
+	*affinity_cpu = cpumask_first(*p_affinity_numa_mask);
+
+	return 0;
+
+err:
+	*affinity_cpu = -1;
+	return -EINVAL;
+}
+
+static int mlx4_en_set_affinity_hint(struct mlx4_en_priv *priv,
+			      cpumask_var_t non_numa_cores_mask,
+			      cpumask_var_t numa_cores_mask,
+			      const struct cpumask **p_affinity_numa_mask,
+			      int *affinity_cpu, int ring)
+{
+	if (*affinity_cpu == -1)
+		return -EINVAL;
+	cpumask_set_cpu(*affinity_cpu,
+			priv->rx_ring[ring]->affinity_mask);
+	*affinity_cpu = cpumask_next(*affinity_cpu, *p_affinity_numa_mask);
+	if (*affinity_cpu >= nr_cpu_ids) {
+		*p_affinity_numa_mask =
+			*p_affinity_numa_mask == numa_cores_mask ?
+			non_numa_cores_mask : numa_cores_mask;
+		*affinity_cpu = cpumask_first(*p_affinity_numa_mask);
+	}
+
+	return 0;
+}
 
 int mlx4_en_start_port(struct net_device *dev)
 {
@@ -1540,6 +1589,10 @@ int mlx4_en_start_port(struct net_device *dev)
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_cq *cq;
 	struct mlx4_en_tx_ring *tx_ring;
+	const struct cpumask *affinity_numa_mask;
+	cpumask_var_t numa_cores_mask = NULL;
+	cpumask_var_t non_numa_cores_mask = NULL;
+	int affinity_cpu;
 	int rx_index = 0;
 	int tx_index = 0;
 	int err = 0;
@@ -1551,7 +1604,12 @@ int mlx4_en_start_port(struct net_device *dev)
 		en_dbg(DRV, priv, "start port called while port already up\n");
 		return 0;
 	}
-
+	if (!zalloc_cpumask_var(&numa_cores_mask, GFP_KERNEL) ||
+	    !zalloc_cpumask_var(&non_numa_cores_mask, GFP_KERNEL)) {
+		en_err(priv, "Failed to allocating core mask\n");
+		err = -EINVAL;
+		goto affinity_err;
+	}
 	INIT_LIST_HEAD(&priv->mc_list);
 	INIT_LIST_HEAD(&priv->curr_list);
 	INIT_LIST_HEAD(&priv->ethtool_list);
@@ -1569,12 +1627,28 @@ int mlx4_en_start_port(struct net_device *dev)
 		en_err(priv, "Failed to activate RX rings\n");
 		return err;
 	}
+	err = mlx4_en_rings_affinity_hint(priv,
+					  non_numa_cores_mask,
+					  numa_cores_mask,
+					  &affinity_numa_mask,
+					  &affinity_cpu);
+	if (err)
+		en_err(priv, "Failed to set affinity hints\n");
+
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		cq = priv->rx_cq[i];
 
 		mlx4_en_cq_init_lock(cq);
-
-		err = mlx4_en_activate_cq(priv, cq, i);
+		err = mlx4_en_set_affinity_hint(priv,
+						non_numa_cores_mask,
+						numa_cores_mask,
+						&affinity_numa_mask,
+						&affinity_cpu, i);
+		if (err)
+			en_err(priv, "Failed setting affinity hint\n");
+		err = mlx4_en_activate_cq(priv, cq, i,
+				affinity_cpu == -1 ? NULL :
+				priv->rx_ring[i]->affinity_mask);
 		if (err) {
 			en_err(priv, "Failed activating Rx CQ\n");
 			goto cq_err;
@@ -1615,7 +1689,7 @@ int mlx4_en_start_port(struct net_device *dev)
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		/* Configure cq */
 		cq = priv->tx_cq[i];
-		err = mlx4_en_activate_cq(priv, cq, i);
+		err = mlx4_en_activate_cq(priv, cq, i, NULL);
 		if (err) {
 			en_err(priv, "Failed allocating Tx CQ\n");
 			goto tx_err;
@@ -1704,7 +1778,8 @@ int mlx4_en_start_port(struct net_device *dev)
 	priv->port_up = true;
 	netif_tx_start_all_queues(dev);
 	netif_device_attach(dev);
-
+	free_cpumask_var(non_numa_cores_mask);
+	free_cpumask_var(numa_cores_mask);
 	return 0;
 
 tx_err:
@@ -1722,6 +1797,9 @@ cq_err:
 		mlx4_en_deactivate_cq(priv, priv->rx_cq[rx_index]);
 	for (i = 0; i < priv->rx_ring_num; i++)
 		mlx4_en_deactivate_rx_ring(priv, priv->rx_ring[i]);
+affinity_err:
+	free_cpumask_var(non_numa_cores_mask);
+	free_cpumask_var(numa_cores_mask);
 
 	return err; /* need to close devices */
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 890922c..b0eba6d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -335,7 +335,11 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 			return -ENOMEM;
 		}
 	}
-
+	if (!zalloc_cpumask_var(&ring->affinity_mask, GFP_KERNEL)) {
+		en_err(priv, "Failed to allocating core mask\n");
+		err = -ENOMEM;
+		goto err_ring;
+	}
 	ring->prod = 0;
 	ring->cons = 0;
 	ring->size = size;
@@ -470,6 +474,7 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, size * stride + TXBB_SIZE);
 	vfree(ring->rx_info);
 	ring->rx_info = NULL;
+	free_cpumask_var(ring->affinity_mask);
 	kfree(ring);
 	*pring = NULL;
 #ifdef CONFIG_RFS_ACCEL
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 8992b38..a3d8502 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -1311,7 +1311,7 @@ int mlx4_test_interrupts(struct mlx4_dev *dev)
 EXPORT_SYMBOL(mlx4_test_interrupts);
 
 int mlx4_assign_eq(struct mlx4_dev *dev, char *name, struct cpu_rmap *rmap,
-		   int *vector)
+		   int *vector, cpumask_var_t cpu_hint_mask)
 {
 
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -1344,6 +1344,16 @@ int mlx4_assign_eq(struct mlx4_dev *dev, char *name, struct cpu_rmap *rmap,
 				continue;
 				/*we dont want to break here*/
 			}
+			if (cpu_hint_mask) {
+				err = irq_set_affinity_hint(
+						priv->eq_table.eq[vec].irq,
+						cpu_hint_mask);
+				if (err) {
+					mlx4_warn(dev, "Failed setting affinity hint\n");
+					/*we dont want to break here*/
+				}
+			}
+
 			eq_set_ci(&priv->eq_table.eq[vec], 1);
 		}
 	}
@@ -1370,6 +1380,8 @@ void mlx4_release_eq(struct mlx4_dev *dev, int vec)
 		  Belonging to a legacy EQ*/
 		mutex_lock(&priv->msix_ctl.pool_lock);
 		if (priv->msix_ctl.pool_bm & 1ULL << i) {
+			irq_set_affinity_hint(priv->eq_table.eq[vec].irq,
+					      NULL);
 			free_irq(priv->eq_table.eq[vec].irq,
 				 &priv->eq_table.eq[vec]);
 			priv->msix_ctl.pool_bm &= ~(1ULL << i);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 3af04c3..101d636 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -303,6 +303,7 @@ struct mlx4_en_rx_ring {
 	unsigned long csum_ok;
 	unsigned long csum_none;
 	int hwtstamp_rx_filter;
+	cpumask_var_t affinity_mask;
 };
 
 struct mlx4_en_cq {
@@ -716,7 +717,7 @@ int mlx4_en_create_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq,
 		      int entries, int ring, enum cq_type mode, int node);
 void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq);
 int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
-			int cq_idx);
+			int cq_idx, cpumask_var_t affinity_mask);
 void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
 int mlx4_en_set_cq_moder(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
 int mlx4_en_arm_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 5edd2c6..f8c253f 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1148,7 +1148,7 @@ int mlx4_fmr_free(struct mlx4_dev *dev, struct mlx4_fmr *fmr);
 int mlx4_SYNC_TPT(struct mlx4_dev *dev);
 int mlx4_test_interrupts(struct mlx4_dev *dev);
 int mlx4_assign_eq(struct mlx4_dev *dev, char *name, struct cpu_rmap *rmap,
-		   int *vector);
+		   int *vector, cpumask_t *cpu_hint_mask);
 void mlx4_release_eq(struct mlx4_dev *dev, int vec);
 
 int mlx4_get_phys_port_id(struct mlx4_dev *dev);
-- 
1.8.3.4
