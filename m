From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/2] net/mlx4_en: Use affinity hint
Date: Wed,  1 Jan 2014 15:05:36 +0200
Message-ID: <1388581537-4810-2-git-send-email-amirv@mellanox.com>
References: <1388581537-4810-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46611 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753608AbaAANGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jan 2014 08:06:09 -0500
In-Reply-To: <1388581537-4810-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Yuval Atias <yuvala@mellanox.com>

The =E2=80=9Caffinity hint=E2=80=9D mechanism is used by the user space
daemon, irqbalancer, to indicate a preferred CPU mask for irqs.
Irqbalancer can use this hint to balance the irqs between the
cpus indicated by the mask.

We wish the HCA to preferentially map the IRQs it uses to numa cores
close to it.
To accomplish this, we use affinity hint: first we map IRQs to =E2=80=9C=
close=E2=80=9D
numa cores.
If these are exhausted, the remaining IRQs are mapped to =E2=80=9Cfar=E2=
=80=9D numa
cores.

Signed-off-by: Yuval Atias <yuvala@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c              |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c     |  4 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 60 ++++++++++++++++++=
+++++++-
 drivers/net/ethernet/mellanox/mlx4/eq.c        | 12 +++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  1 +
 include/linux/mlx4/device.h                    |  2 +-
 6 files changed, 76 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/=
mlx4/main.c
index 1958c5c..3607a3d 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1486,7 +1486,7 @@ static void mlx4_ib_alloc_eqs(struct mlx4_dev *de=
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
index 70e9532..52396d1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -123,7 +123,9 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, =
struct mlx4_en_cq *cq,
 					cq->ring);
 				/* Set IRQ for specific name (per ring) */
 				if (mlx4_assign_eq(mdev->dev, name, rmap,
-						   &cq->vector)) {
+						   &cq->vector,
+						   &priv->rx_ring[cq_idx]
+							->affinity_mask)){
 					cq->vector =3D (cq->ring + 1 + priv->port)
 					    % mdev->dev->caps.num_comp_vectors;
 					mlx4_warn(mdev, "Failed Assigning an EQ to "
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/n=
et/ethernet/mellanox/mlx4/en_netdev.c
index b68dde0..e6ff67c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1532,6 +1532,45 @@ static void mlx4_en_linkstate(struct work_struct=
 *work)
 	mutex_unlock(&mdev->state_lock);
 }
=20
+static int mlx4_en_rings_affinity_hint(struct mlx4_en_priv *priv ,
+				      int *affinity_hint_mapping)
+{
+	int cpu;
+	int cores_arr_index =3D 0;
+	cpumask_t *numa_cores_mask;
+	cpumask_t *non_numa_cores_mask;
+
+	if (!zalloc_cpumask_var(&non_numa_cores_mask, GFP_KERNEL)) {
+		en_err(priv, "Failed allocating cores mask\n");
+		return -EINVAL;
+	}
+	numa_cores_mask =3D (cpumask_t *)cpumask_of_node(
+					priv->mdev->dev->numa_node);
+	if (!cpumask_and(numa_cores_mask, cpu_online_mask, numa_cores_mask))
+		en_warn(priv, "Failed to find online cores for local numa\n");
+	cpumask_xor(non_numa_cores_mask, cpu_online_mask, numa_cores_mask);
+
+	for_each_cpu(cpu, numa_cores_mask) {
+		affinity_hint_mapping[cores_arr_index] =3D cpu;
+		cores_arr_index++;
+	}
+	for_each_cpu(cpu, non_numa_cores_mask) {
+		affinity_hint_mapping[cores_arr_index] =3D cpu;
+		cores_arr_index++;
+	}
+
+	free_cpumask_var(non_numa_cores_mask);
+
+	return 0;
+}
+
+static int mlx4_en_set_affinity_hint(struct mlx4_en_priv *priv , int r=
ing,
+				     int *affinity_hint_mapping)
+{
+	cpumask_set_cpu(affinity_hint_mapping[ring % num_online_cpus()],
+			&priv->rx_ring[ring]->affinity_mask);
+	return 0;
+}
=20
 int mlx4_en_start_port(struct net_device *dev)
 {
@@ -1545,7 +1584,7 @@ int mlx4_en_start_port(struct net_device *dev)
 	int i;
 	int j;
 	u8 mc_list[16] =3D {0};
-
+	int *affinity_hint_mapping =3D NULL;
 	if (priv->port_up) {
 		en_dbg(DRV, priv, "start port called while port already up\n");
 		return 0;
@@ -1557,6 +1596,9 @@ int mlx4_en_start_port(struct net_device *dev)
 	memset(&priv->ethtool_rules[0], 0,
 	       sizeof(struct ethtool_flow_id) * MAX_NUM_OF_FS_RULES);
=20
+	affinity_hint_mapping =3D kzalloc(num_online_cpus() * sizeof(int),
+					GFP_KERNEL);
+
 	/* Calculate Rx buf size */
 	dev->mtu =3D min(dev->mtu, priv->max_mtu);
 	mlx4_en_calc_rx_buf(dev);
@@ -1568,11 +1610,22 @@ int mlx4_en_start_port(struct net_device *dev)
 		en_err(priv, "Failed to activate RX rings\n");
 		return err;
 	}
+
+	err =3D mlx4_en_rings_affinity_hint(priv, affinity_hint_mapping);
+	if (err) {
+		en_err(priv, "Failed setting affinity hint irq mapping\n");
+	}
+
 	for (i =3D 0; i < priv->rx_ring_num; i++) {
 		cq =3D priv->rx_cq[i];
=20
 		mlx4_en_cq_init_lock(cq);
=20
+		err =3D mlx4_en_set_affinity_hint(priv , i,
+						affinity_hint_mapping);
+		if (err)
+			en_err(priv, "Failed setting affinity hint");
+
 		err =3D mlx4_en_activate_cq(priv, cq, i);
 		if (err) {
 			en_err(priv, "Failed activating Rx CQ\n");
@@ -1580,6 +1633,7 @@ int mlx4_en_start_port(struct net_device *dev)
 		}
 		for (j =3D 0; j < cq->size; j++)
 			cq->buf[j].owner_sr_opcode =3D MLX4_CQE_OWNER_MASK;
+
 		err =3D mlx4_en_set_cq_moder(priv, cq);
 		if (err) {
 			en_err(priv, "Failed setting cq moderation parameters");
@@ -1703,6 +1757,8 @@ int mlx4_en_start_port(struct net_device *dev)
 	priv->port_up =3D true;
 	netif_tx_start_all_queues(dev);
 	netif_device_attach(dev);
+	kfree(affinity_hint_mapping);
+	affinity_hint_mapping =3D NULL;
=20
 	return 0;
=20
@@ -1721,6 +1777,8 @@ cq_err:
 		mlx4_en_deactivate_cq(priv, priv->rx_cq[rx_index]);
 	for (i =3D 0; i < priv->rx_ring_num; i++)
 		mlx4_en_deactivate_rx_ring(priv, priv->rx_ring[i]);
+	kfree(affinity_hint_mapping);
+	affinity_hint_mapping =3D NULL;
=20
 	return err; /* need to close devices */
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethe=
rnet/mellanox/mlx4/eq.c
index ae5212f..8c19741 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -1312,7 +1312,7 @@ int mlx4_test_interrupts(struct mlx4_dev *dev)
 EXPORT_SYMBOL(mlx4_test_interrupts);
=20
 int mlx4_assign_eq(struct mlx4_dev *dev, char *name, struct cpu_rmap *=
rmap,
-		   int *vector)
+		   int *vector, cpumask_t *cpu_hint_mask)
 {
=20
 	struct mlx4_priv *priv =3D mlx4_priv(dev);
@@ -1345,6 +1345,16 @@ int mlx4_assign_eq(struct mlx4_dev *dev, char *n=
ame, struct cpu_rmap *rmap,
 				continue;
 				/*we dont want to break here*/
 			}
+			if (cpu_hint_mask) {
+				err =3D irq_set_affinity_hint(
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
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net=
/ethernet/mellanox/mlx4/mlx4_en.h
index 766691c..1202ed6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -302,6 +302,7 @@ struct mlx4_en_rx_ring {
 	unsigned long csum_ok;
 	unsigned long csum_none;
 	int hwtstamp_rx_filter;
+	cpumask_t affinity_mask;
 };
=20
 struct mlx4_en_cq {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index c99ecf6..4aa2122 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1146,7 +1146,7 @@ int mlx4_fmr_free(struct mlx4_dev *dev, struct ml=
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
