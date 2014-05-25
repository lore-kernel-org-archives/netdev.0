From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V6 2/2] net/mlx4_en: Use affinity hint
Date: Sun, 25 May 2014 17:47:27 +0300
Message-ID: <1401029247-15196-3-git-send-email-amirv@mellanox.com>
References: <1401029247-15196-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401029247-15196-1-git-send-email-amirv@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Yuval Atias <yuvala@mellanox.com>

The =E2=80=9Caffinity hint=E2=80=9D mechanism is used by the user space
daemon, irqbalancer, to indicate a preferred CPU mask for irqs.
Irqbalancer can use this hint to balance the irqs between the
cpus indicated by the mask.

We wish the HCA to preferentially map the IRQs it uses to numa cores
close to it.  To accomplish this, we use cpumask_set_cpu_local_first(),=
 that
sets the affinity hint according the following policy:
=46irst it maps IRQs to =E2=80=9Cclose=E2=80=9D numa cores.  If these a=
re exhausted, the
remaining IRQs are mapped to =E2=80=9Cfar=E2=80=9D numa cores.

Signed-off-by: Yuval Atias <yuvala@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c              |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c     |  6 +++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 30 ++++++++++++++++++=
++++++++
 drivers/net/ethernet/mellanox/mlx4/eq.c        | 13 ++++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  1 +
 include/linux/mlx4/device.h                    |  2 +-
 6 files changed, 50 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/=
mlx4/main.c
index a9638ae..8c88960 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1837,7 +1837,7 @@ static void mlx4_ib_alloc_eqs(struct mlx4_dev *de=
v, struct mlx4_ib_dev *ibdev)
 				 i, j, dev->pdev->bus->name);
 			/* Set IRQ for specific name (per ring) */
 			if (mlx4_assign_eq(dev, name, NULL,
-					   &ibdev->eq_table[eq])) {
+					   &ibdev->eq_table[eq], NULL)) {
 				/* Use legacy (same as mlx4_en driver) */
 				pr_warn("Can't allocate EQ %d; reverting to legacy\n", eq);
 				ibdev->eq_table[eq] =3D
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/e=
thernet/mellanox/mlx4/en_cq.c
index 636963d..ea2cd72 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -118,11 +118,15 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv=
, struct mlx4_en_cq *cq,
 	if (cq->is_tx =3D=3D RX) {
 		if (mdev->dev->caps.comp_pool) {
 			if (!cq->vector) {
+				struct mlx4_en_rx_ring *ring =3D
+					priv->rx_ring[cq->ring];
+
 				sprintf(name, "%s-%d", priv->dev->name,
 					cq->ring);
 				/* Set IRQ for specific name (per ring) */
 				if (mlx4_assign_eq(mdev->dev, name, rmap,
-						   &cq->vector)) {
+						   &cq->vector,
+						   ring->affinity_mask)) {
 					cq->vector =3D (cq->ring + 1 + priv->port)
 					    % mdev->dev->caps.num_comp_vectors;
 					mlx4_warn(mdev, "Failed assigning an EQ to %s, falling back to le=
gacy EQ's\n",
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/n=
et/ethernet/mellanox/mlx4/en_netdev.c
index 5bb7eda..826d150 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1531,6 +1531,32 @@ static void mlx4_en_linkstate(struct work_struct=
 *work)
 	mutex_unlock(&mdev->state_lock);
 }
=20
+static void mlx4_en_init_affinity_hint(struct mlx4_en_priv *priv, int =
ring_idx)
+{
+	struct mlx4_en_rx_ring *ring =3D priv->rx_ring[ring_idx];
+	int numa_node =3D priv->mdev->dev->numa_node;
+
+	if (numa_node =3D=3D -1)
+		return;
+
+	if (!zalloc_cpumask_var(&ring->affinity_mask, GFP_KERNEL)) {
+		en_err(priv, "Failed to allocate core mask\n");
+		return;
+	}
+
+	if (cpumask_set_cpu_local_first(ring_idx, numa_node,
+					ring->affinity_mask)) {
+		en_err(priv, "Failed setting affinity hint\n");
+		free_cpumask_var(ring->affinity_mask);
+		ring->affinity_mask =3D NULL;
+	}
+}
+
+static void mlx4_en_free_affinity_hint(struct mlx4_en_priv *priv, int =
ring_idx)
+{
+	free_cpumask_var(priv->rx_ring[ring_idx]->affinity_mask);
+	priv->rx_ring[ring_idx]->affinity_mask =3D NULL;
+}
=20
 int mlx4_en_start_port(struct net_device *dev)
 {
@@ -1572,6 +1598,8 @@ int mlx4_en_start_port(struct net_device *dev)
=20
 		mlx4_en_cq_init_lock(cq);
=20
+		mlx4_en_init_affinity_hint(priv, i);
+
 		err =3D mlx4_en_activate_cq(priv, cq, i);
 		if (err) {
 			en_err(priv, "Failed activating Rx CQ\n");
@@ -1852,6 +1880,8 @@ void mlx4_en_stop_port(struct net_device *dev, in=
t detach)
 			msleep(1);
 		mlx4_en_deactivate_rx_ring(priv, priv->rx_ring[i]);
 		mlx4_en_deactivate_cq(priv, cq);
+
+		mlx4_en_free_affinity_hint(priv, i);
 	}
 }
=20
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethe=
rnet/mellanox/mlx4/eq.c
index 947364d..02cf97d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -1376,7 +1376,7 @@ int mlx4_test_interrupts(struct mlx4_dev *dev)
 EXPORT_SYMBOL(mlx4_test_interrupts);
=20
 int mlx4_assign_eq(struct mlx4_dev *dev, char *name, struct cpu_rmap *=
rmap,
-		   int *vector)
+		   int *vector, cpumask_var_t cpu_hint_mask)
 {
=20
 	struct mlx4_priv *priv =3D mlx4_priv(dev);
@@ -1411,6 +1411,15 @@ int mlx4_assign_eq(struct mlx4_dev *dev, char *n=
ame, struct cpu_rmap *rmap,
 			}
 			mlx4_assign_irq_notifier(priv, dev,
 						 priv->eq_table.eq[vec].irq);
+			if (cpu_hint_mask) {
+				err =3D irq_set_affinity_hint(
+						priv->eq_table.eq[vec].irq,
+						cpu_hint_mask);
+				if (err) {
+					mlx4_warn(dev, "Failed setting affinity hint\n");
+					/*we dont want to break here*/
+				}
+			}
=20
 			eq_set_ci(&priv->eq_table.eq[vec], 1);
 		}
@@ -1441,6 +1450,8 @@ void mlx4_release_eq(struct mlx4_dev *dev, int ve=
c)
 			irq_set_affinity_notifier(
 				priv->eq_table.eq[vec].irq,
 				NULL);
+			irq_set_affinity_hint(priv->eq_table.eq[vec].irq,
+					      NULL);
 			free_irq(priv->eq_table.eq[vec].irq,
 				 &priv->eq_table.eq[vec]);
 			priv->msix_ctl.pool_bm &=3D ~(1ULL << i);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net=
/ethernet/mellanox/mlx4/mlx4_en.h
index 88d5cf6..61d7c36 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -313,6 +313,7 @@ struct mlx4_en_rx_ring {
 	unsigned long csum_ok;
 	unsigned long csum_none;
 	int hwtstamp_rx_filter;
+	cpumask_var_t affinity_mask;
 };
=20
 struct mlx4_en_cq {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 74f5aa8..8b194aa 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1161,7 +1161,7 @@ int mlx4_fmr_free(struct mlx4_dev *dev, struct ml=
x4_fmr *fmr);
 int mlx4_SYNC_TPT(struct mlx4_dev *dev);
 int mlx4_test_interrupts(struct mlx4_dev *dev);
 int mlx4_assign_eq(struct mlx4_dev *dev, char *name, struct cpu_rmap *=
rmap,
-		   int *vector);
+		   int *vector, cpumask_t *cpu_hint_mask);
 void mlx4_release_eq(struct mlx4_dev *dev, int vec);
=20
 int mlx4_get_phys_port_id(struct mlx4_dev *dev);
--=20
1.8.3.4
