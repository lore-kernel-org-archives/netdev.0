From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 2/4] net/mlx4: Add EQ pool
Date: Sun, 31 May 2015 09:30:16 +0300
Message-ID: <1433053818-30251-3-git-send-email-ogerlitz@mellanox.com>
References: <1433053818-30251-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35203 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758035AbbEaGbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 May 2015 02:31:10 -0400
In-Reply-To: <1433053818-30251-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Previously, mlx4_en allocated EQs and used them exclusively.
This affected RoCE performance, as applications which are
events sensitive were limited to use only the legacy EQs.

Change that by introducing an EQ pool. This pool is managed
by mlx4_core. EQs are assigned to ports (when there are limited
number of EQs, multiple ports could be assigned to the same EQs).

An exception to this rule is the ASYNC EQ which handles various events.

Legacy EQs are completely removed as all EQs could be shared.

When a consumer (mlx4_ib/mlx4_en) requests an EQ, it asks for
EQ serving on a specific port. The core driver calculates which
EQ should be assigned to that request.

Because IRQs are shared between IB and Ethernet modules, their
names only include the PCI device BDF address.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c              |   71 ++----
 drivers/infiniband/hw/mlx4/mlx4_ib.h           |    1 -
 drivers/net/ethernet/mellanox/mlx4/cq.c        |   10 +-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c     |   48 ++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    7 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |   13 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c        |  353 ++++++++++++++----------
 drivers/net/ethernet/mellanox/mlx4/main.c      |   74 ++++--
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |   11 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    2 +-
 include/linux/mlx4/device.h                    |   11 +-
 11 files changed, 342 insertions(+), 259 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 8c96c71..024b0f7 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -2041,77 +2041,52 @@ static void init_pkeys(struct mlx4_ib_dev *ibdev)
 
 static void mlx4_ib_alloc_eqs(struct mlx4_dev *dev, struct mlx4_ib_dev *ibdev)
 {
-	char name[80];
-	int eq_per_port = 0;
-	int added_eqs = 0;
-	int total_eqs = 0;
-	int i, j, eq;
-
-	/* Legacy mode or comp_pool is not large enough */
-	if (dev->caps.comp_pool == 0 ||
-	    dev->caps.num_ports > dev->caps.comp_pool)
-		return;
-
-	eq_per_port = dev->caps.comp_pool / dev->caps.num_ports;
-
-	/* Init eq table */
-	added_eqs = 0;
-	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_IB)
-		added_eqs += eq_per_port;
-
-	total_eqs = dev->caps.num_comp_vectors + added_eqs;
+	int i, j, eq = 0, total_eqs = 0;
 
-	ibdev->eq_table = kzalloc(total_eqs * sizeof(int), GFP_KERNEL);
+	ibdev->eq_table = kcalloc(dev->caps.num_comp_vectors,
+				  sizeof(ibdev->eq_table[0]), GFP_KERNEL);
 	if (!ibdev->eq_table)
 		return;
 
-	ibdev->eq_added = added_eqs;
-
-	eq = 0;
-	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_IB) {
-		for (j = 0; j < eq_per_port; j++) {
-			snprintf(name, sizeof(name), "mlx4-ib-%d-%d@%s",
-				 i, j, dev->persist->pdev->bus->name);
-			/* Set IRQ for specific name (per ring) */
-			if (mlx4_assign_eq(dev, name, NULL,
-					   &ibdev->eq_table[eq])) {
-				/* Use legacy (same as mlx4_en driver) */
-				pr_warn("Can't allocate EQ %d; reverting to legacy\n", eq);
-				ibdev->eq_table[eq] =
-					(eq % dev->caps.num_comp_vectors);
-			}
-			eq++;
+	for (i = 1; i <= dev->caps.num_ports; i++) {
+		for (j = 0; j < mlx4_get_eqs_per_port(dev, i);
+		     j++, total_eqs++) {
+			if (i > 1 &&  mlx4_is_eq_shared(dev, total_eqs))
+				continue;
+			ibdev->eq_table[eq] = total_eqs;
+			if (!mlx4_assign_eq(dev, i,
+					    &ibdev->eq_table[eq]))
+				eq++;
+			else
+				ibdev->eq_table[eq] = -1;
 		}
 	}
 
-	/* Fill the reset of the vector with legacy EQ */
-	for (i = 0, eq = added_eqs; i < dev->caps.num_comp_vectors; i++)
-		ibdev->eq_table[eq++] = i;
+	for (i = eq; i < dev->caps.num_comp_vectors;
+	     ibdev->eq_table[i++] = -1)
+		;
 
 	/* Advertise the new number of EQs to clients */
-	ibdev->ib_dev.num_comp_vectors = total_eqs;
+	ibdev->ib_dev.num_comp_vectors = eq;
 }
 
 static void mlx4_ib_free_eqs(struct mlx4_dev *dev, struct mlx4_ib_dev *ibdev)
 {
 	int i;
+	int total_eqs = ibdev->ib_dev.num_comp_vectors;
 
-	/* no additional eqs were added */
+	/* no eqs were allocated */
 	if (!ibdev->eq_table)
 		return;
 
 	/* Reset the advertised EQ number */
-	ibdev->ib_dev.num_comp_vectors = dev->caps.num_comp_vectors;
+	ibdev->ib_dev.num_comp_vectors = 0;
 
-	/* Free only the added eqs */
-	for (i = 0; i < ibdev->eq_added; i++) {
-		/* Don't free legacy eqs if used */
-		if (ibdev->eq_table[i] <= dev->caps.num_comp_vectors)
-			continue;
+	for (i = 0; i < total_eqs; i++)
 		mlx4_release_eq(dev, ibdev->eq_table[i]);
-	}
 
 	kfree(ibdev->eq_table);
+	ibdev->eq_table = NULL;
 }
 
 static void *mlx4_ib_add(struct mlx4_dev *dev)
diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index fce3934..ef80e6c 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -523,7 +523,6 @@ struct mlx4_ib_dev {
 	struct mlx4_ib_iboe	iboe;
 	int			counters[MLX4_MAX_PORTS];
 	int		       *eq_table;
-	int			eq_added;
 	struct kobject	       *iov_parent;
 	struct kobject	       *ports_parent;
 	struct kobject	       *dev_ports_parent[MLX4_MFUNC_MAX];
diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index e71f313..7431cd4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -292,7 +292,7 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent,
 	u64 mtt_addr;
 	int err;
 
-	if (vector > dev->caps.num_comp_vectors + dev->caps.comp_pool)
+	if (vector >= dev->caps.num_comp_vectors)
 		return -EINVAL;
 
 	cq->vector = vector;
@@ -319,7 +319,7 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent,
 		cq_context->flags  |= cpu_to_be32(1 << 19);
 
 	cq_context->logsize_usrpage = cpu_to_be32((ilog2(nent) << 24) | uar->index);
-	cq_context->comp_eqn	    = priv->eq_table.eq[vector].eqn;
+	cq_context->comp_eqn	    = priv->eq_table.eq[MLX4_CQ_TO_EQ_VECTOR(vector)].eqn;
 	cq_context->log_page_size   = mtt->page_shift - MLX4_ICM_PAGE_SHIFT;
 
 	mtt_addr = mlx4_mtt_addr(dev, mtt);
@@ -339,11 +339,11 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent,
 	init_completion(&cq->free);
 	cq->comp = mlx4_add_cq_to_tasklet;
 	cq->tasklet_ctx.priv =
-		&priv->eq_table.eq[cq->vector].tasklet_ctx;
+		&priv->eq_table.eq[MLX4_CQ_TO_EQ_VECTOR(vector)].tasklet_ctx;
 	INIT_LIST_HEAD(&cq->tasklet_ctx.list);
 
 
-	cq->irq = priv->eq_table.eq[cq->vector].irq;
+	cq->irq = priv->eq_table.eq[MLX4_CQ_TO_EQ_VECTOR(vector)].irq;
 	return 0;
 
 err_radix:
@@ -368,7 +368,7 @@ void mlx4_cq_free(struct mlx4_dev *dev, struct mlx4_cq *cq)
 	if (err)
 		mlx4_warn(dev, "HW2SW_CQ failed (%d) for CQN %06x\n", err, cq->cqn);
 
-	synchronize_irq(priv->eq_table.eq[cq->vector].irq);
+	synchronize_irq(priv->eq_table.eq[MLX4_CQ_TO_EQ_VECTOR(cq->vector)].irq);
 
 	spin_lock_irq(&cq_table->lock);
 	radix_tree_delete(&cq_table->tree, cq->cqn);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 22da4d0..d71c567 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -66,6 +66,7 @@ int mlx4_en_create_cq(struct mlx4_en_priv *priv,
 
 	cq->ring = ring;
 	cq->is_tx = mode;
+	cq->vector = mdev->dev->caps.num_comp_vectors;
 
 	/* Allocate HW buffers on provided NUMA node.
 	 * dev->numa_node is used in mtt range allocation flow.
@@ -101,12 +102,7 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 	int err = 0;
 	char name[25];
 	int timestamp_en = 0;
-	struct cpu_rmap *rmap =
-#ifdef CONFIG_RFS_ACCEL
-		priv->dev->rx_cpu_rmap;
-#else
-		NULL;
-#endif
+	bool assigned_eq = false;
 
 	cq->dev = mdev->pndev[priv->port];
 	cq->mcq.set_ci_db  = cq->wqres.db.db;
@@ -116,23 +112,19 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 	memset(cq->buf, 0, cq->buf_size);
 
 	if (cq->is_tx == RX) {
-		if (mdev->dev->caps.comp_pool) {
-			if (!cq->vector) {
-				sprintf(name, "%s-%d", priv->dev->name,
-					cq->ring);
-				/* Set IRQ for specific name (per ring) */
-				if (mlx4_assign_eq(mdev->dev, name, rmap,
-						   &cq->vector)) {
-					cq->vector = (cq->ring + 1 + priv->port)
-					    % mdev->dev->caps.num_comp_vectors;
-					mlx4_warn(mdev, "Failed assigning an EQ to %s, falling back to legacy EQ's\n",
-						  name);
-				}
-
+		if (!mlx4_is_eq_vector_valid(mdev->dev, priv->port,
+					     cq->vector)) {
+			cq->vector = cq_idx;
+
+			err = mlx4_assign_eq(mdev->dev, priv->port,
+					     &cq->vector);
+			if (err) {
+				mlx4_err(mdev, "Failed assigning an EQ to %s\n",
+					 name);
+				goto free_eq;
 			}
-		} else {
-			cq->vector = (cq->ring + 1 + priv->port) %
-				mdev->dev->caps.num_comp_vectors;
+
+			assigned_eq = true;
 		}
 
 		cq->irq_desc =
@@ -159,7 +151,7 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 			    &mdev->priv_uar, cq->wqres.db.dma, &cq->mcq,
 			    cq->vector, 0, timestamp_en);
 	if (err)
-		return err;
+		goto free_eq;
 
 	cq->mcq.comp  = cq->is_tx ? mlx4_en_tx_irq : mlx4_en_rx_irq;
 	cq->mcq.event = mlx4_en_cq_event;
@@ -182,6 +174,12 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 	napi_enable(&cq->napi);
 
 	return 0;
+
+free_eq:
+	if (assigned_eq)
+		mlx4_release_eq(mdev->dev, cq->vector);
+	cq->vector = mdev->dev->caps.num_comp_vectors;
+	return err;
 }
 
 void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq)
@@ -191,9 +189,9 @@ void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq)
 
 	mlx4_en_unmap_buffer(&cq->wqres.buf);
 	mlx4_free_hwq_res(mdev->dev, &cq->wqres, cq->buf_size);
-	if (priv->mdev->dev->caps.comp_pool && cq->vector) {
+	if (mlx4_is_eq_vector_valid(mdev->dev, priv->port, cq->vector) &&
+	    cq->is_tx == RX)
 		mlx4_release_eq(priv->mdev->dev, cq->vector);
-	}
 	cq->vector = 0;
 	cq->buf_size = 0;
 	cq->buf = NULL;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 32f5ec7..455ceca 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1958,7 +1958,6 @@ void mlx4_en_free_resources(struct mlx4_en_priv *priv)
 	int i;
 
 #ifdef CONFIG_RFS_ACCEL
-	free_irq_cpu_rmap(priv->dev->rx_cpu_rmap);
 	priv->dev->rx_cpu_rmap = NULL;
 #endif
 
@@ -2016,11 +2015,7 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 	}
 
 #ifdef CONFIG_RFS_ACCEL
-	if (priv->mdev->dev->caps.comp_pool) {
-		priv->dev->rx_cpu_rmap = alloc_irq_cpu_rmap(priv->mdev->dev->caps.comp_pool);
-		if (!priv->dev->rx_cpu_rmap)
-			goto err;
-	}
+	priv->dev->rx_cpu_rmap = mlx4_get_cpu_rmap(priv->mdev->dev, priv->port);
 #endif
 
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 2a77a6b..35f726c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -337,15 +337,10 @@ void mlx4_en_set_num_rx_rings(struct mlx4_en_dev *mdev)
 	struct mlx4_dev *dev = mdev->dev;
 
 	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
-		if (!dev->caps.comp_pool)
-			num_of_eqs = max_t(int, MIN_RX_RINGS,
-					   min_t(int,
-						 dev->caps.num_comp_vectors,
-						 DEF_RX_RINGS));
-		else
-			num_of_eqs = min_t(int, MAX_MSIX_P_PORT,
-					   dev->caps.comp_pool/
-					   dev->caps.num_ports) - 1;
+		num_of_eqs = max_t(int, MIN_RX_RINGS,
+				   min_t(int,
+					 mlx4_get_eqs_per_port(mdev->dev, i),
+					 DEF_RX_RINGS));
 
 		num_rx_rings = mlx4_low_memory_profile() ? MIN_RX_RINGS :
 			min_t(int, num_of_eqs,
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 80bcd64..2e6fc6a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -895,8 +895,8 @@ static int mlx4_num_eq_uar(struct mlx4_dev *dev)
 	 * we need to map, take the difference of highest index and
 	 * the lowest index we'll use and add 1.
 	 */
-	return (dev->caps.num_comp_vectors + 1 + dev->caps.reserved_eqs +
-		 dev->caps.comp_pool)/4 - dev->caps.reserved_eqs/4 + 1;
+	return (dev->caps.num_comp_vectors + 1 + dev->caps.reserved_eqs) / 4 -
+		dev->caps.reserved_eqs / 4 + 1;
 }
 
 static void __iomem *mlx4_get_eq_uar(struct mlx4_dev *dev, struct mlx4_eq *eq)
@@ -1085,8 +1085,7 @@ static void mlx4_free_eq(struct mlx4_dev *dev,
 static void mlx4_free_irqs(struct mlx4_dev *dev)
 {
 	struct mlx4_eq_table *eq_table = &mlx4_priv(dev)->eq_table;
-	struct mlx4_priv *priv = mlx4_priv(dev);
-	int	i, vec;
+	int	i;
 
 	if (eq_table->have_irq)
 		free_irq(dev->persist->pdev->irq, dev);
@@ -1097,20 +1096,6 @@ static void mlx4_free_irqs(struct mlx4_dev *dev)
 			eq_table->eq[i].have_irq = 0;
 		}
 
-	for (i = 0; i < dev->caps.comp_pool; i++) {
-		/*
-		 * Freeing the assigned irq's
-		 * all bits should be 0, but we need to validate
-		 */
-		if (priv->msix_ctl.pool_bm & 1ULL << i) {
-			/* NO need protecting*/
-			vec = dev->caps.num_comp_vectors + 1 + i;
-			free_irq(priv->eq_table.eq[vec].irq,
-				 &priv->eq_table.eq[vec]);
-		}
-	}
-
-
 	kfree(eq_table->irq_names);
 }
 
@@ -1191,76 +1176,73 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 	}
 
 	priv->eq_table.irq_names =
-		kmalloc(MLX4_IRQNAME_SIZE * (dev->caps.num_comp_vectors + 1 +
-					     dev->caps.comp_pool),
+		kmalloc(MLX4_IRQNAME_SIZE * (dev->caps.num_comp_vectors + 1),
 			GFP_KERNEL);
 	if (!priv->eq_table.irq_names) {
 		err = -ENOMEM;
-		goto err_out_bitmap;
+		goto err_out_clr_int;
 	}
 
-	for (i = 0; i < dev->caps.num_comp_vectors; ++i) {
-		err = mlx4_create_eq(dev, dev->caps.num_cqs -
-					  dev->caps.reserved_cqs +
-					  MLX4_NUM_SPARE_EQE,
-				     (dev->flags & MLX4_FLAG_MSI_X) ? i : 0,
-				     &priv->eq_table.eq[i]);
-		if (err) {
-			--i;
-			goto err_out_unmap;
-		}
-	}
-
-	err = mlx4_create_eq(dev, MLX4_NUM_ASYNC_EQE + MLX4_NUM_SPARE_EQE,
-			     (dev->flags & MLX4_FLAG_MSI_X) ? dev->caps.num_comp_vectors : 0,
-			     &priv->eq_table.eq[dev->caps.num_comp_vectors]);
-	if (err)
-		goto err_out_comp;
-
-	/*if additional completion vectors poolsize is 0 this loop will not run*/
-	for (i = dev->caps.num_comp_vectors + 1;
-	      i < dev->caps.num_comp_vectors + dev->caps.comp_pool + 1; ++i) {
+	for (i = 0; i < dev->caps.num_comp_vectors + 1; ++i) {
+		if (i == MLX4_EQ_ASYNC) {
+			err = mlx4_create_eq(dev,
+					     MLX4_NUM_ASYNC_EQE + MLX4_NUM_SPARE_EQE,
+					     0, &priv->eq_table.eq[MLX4_EQ_ASYNC]);
+		} else {
+#ifdef CONFIG_RFS_ACCEL
+			struct mlx4_eq	*eq = &priv->eq_table.eq[i];
+			int port = find_first_bit(eq->actv_ports.ports,
+						  dev->caps.num_ports) + 1;
+
+			if (port <= dev->caps.num_ports) {
+				struct mlx4_port_info *info =
+					&mlx4_priv(dev)->port[port];
+
+				if (!info->rmap) {
+					info->rmap = alloc_irq_cpu_rmap(
+						mlx4_get_eqs_per_port(dev, port));
+					if (!info->rmap) {
+						mlx4_warn(dev, "Failed to allocate cpu rmap\n");
+						err = -ENOMEM;
+						goto err_out_unmap;
+					}
+				}
 
-		err = mlx4_create_eq(dev, dev->caps.num_cqs -
-					  dev->caps.reserved_cqs +
-					  MLX4_NUM_SPARE_EQE,
-				     (dev->flags & MLX4_FLAG_MSI_X) ? i : 0,
-				     &priv->eq_table.eq[i]);
-		if (err) {
-			--i;
-			goto err_out_unmap;
+				err = irq_cpu_rmap_add(
+					info->rmap, eq->irq);
+				if (err)
+					mlx4_warn(dev, "Failed adding irq rmap\n");
+			}
+#endif
+			err = mlx4_create_eq(dev, dev->caps.num_cqs -
+						  dev->caps.reserved_cqs +
+						  MLX4_NUM_SPARE_EQE,
+					     (dev->flags & MLX4_FLAG_MSI_X) ?
+					     i + 1 - !!(i > MLX4_EQ_ASYNC) : 0,
+					     eq);
 		}
+		if (err)
+			goto err_out_unmap;
 	}
 
-
 	if (dev->flags & MLX4_FLAG_MSI_X) {
 		const char *eq_name;
 
-		for (i = 0; i < dev->caps.num_comp_vectors + 1; ++i) {
-			if (i < dev->caps.num_comp_vectors) {
-				snprintf(priv->eq_table.irq_names +
-					 i * MLX4_IRQNAME_SIZE,
-					 MLX4_IRQNAME_SIZE,
-					 "mlx4-comp-%d@pci:%s", i,
-					 pci_name(dev->persist->pdev));
-			} else {
-				snprintf(priv->eq_table.irq_names +
-					 i * MLX4_IRQNAME_SIZE,
-					 MLX4_IRQNAME_SIZE,
-					 "mlx4-async@pci:%s",
-					 pci_name(dev->persist->pdev));
-			}
+		snprintf(priv->eq_table.irq_names +
+			 MLX4_EQ_ASYNC * MLX4_IRQNAME_SIZE,
+			 MLX4_IRQNAME_SIZE,
+			 "mlx4-async@pci:%s",
+			 pci_name(dev->persist->pdev));
+		eq_name = priv->eq_table.irq_names +
+			MLX4_EQ_ASYNC * MLX4_IRQNAME_SIZE;
 
-			eq_name = priv->eq_table.irq_names +
-				  i * MLX4_IRQNAME_SIZE;
-			err = request_irq(priv->eq_table.eq[i].irq,
-					  mlx4_msi_x_interrupt, 0, eq_name,
-					  priv->eq_table.eq + i);
-			if (err)
-				goto err_out_async;
+		err = request_irq(priv->eq_table.eq[MLX4_EQ_ASYNC].irq,
+				  mlx4_msi_x_interrupt, 0, eq_name,
+				  priv->eq_table.eq + MLX4_EQ_ASYNC);
+		if (err)
+			goto err_out_unmap;
 
-			priv->eq_table.eq[i].have_irq = 1;
-		}
+		priv->eq_table.eq[MLX4_EQ_ASYNC].have_irq = 1;
 	} else {
 		snprintf(priv->eq_table.irq_names,
 			 MLX4_IRQNAME_SIZE,
@@ -1269,36 +1251,38 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 		err = request_irq(dev->persist->pdev->irq, mlx4_interrupt,
 				  IRQF_SHARED, priv->eq_table.irq_names, dev);
 		if (err)
-			goto err_out_async;
+			goto err_out_unmap;
 
 		priv->eq_table.have_irq = 1;
 	}
 
 	err = mlx4_MAP_EQ(dev, get_async_ev_mask(dev), 0,
-			  priv->eq_table.eq[dev->caps.num_comp_vectors].eqn);
+			  priv->eq_table.eq[MLX4_EQ_ASYNC].eqn);
 	if (err)
 		mlx4_warn(dev, "MAP_EQ for async EQ %d failed (%d)\n",
-			   priv->eq_table.eq[dev->caps.num_comp_vectors].eqn, err);
+			   priv->eq_table.eq[MLX4_EQ_ASYNC].eqn, err);
 
-	for (i = 0; i < dev->caps.num_comp_vectors + 1; ++i)
-		eq_set_ci(&priv->eq_table.eq[i], 1);
+	/* arm ASYNC eq */
+	eq_set_ci(&priv->eq_table.eq[MLX4_EQ_ASYNC], 1);
 
 	return 0;
 
-err_out_async:
-	mlx4_free_eq(dev, &priv->eq_table.eq[dev->caps.num_comp_vectors]);
-
-err_out_comp:
-	i = dev->caps.num_comp_vectors - 1;
-
 err_out_unmap:
-	while (i >= 0) {
-		mlx4_free_eq(dev, &priv->eq_table.eq[i]);
-		--i;
+	while (i >= 0)
+		mlx4_free_eq(dev, &priv->eq_table.eq[i--]);
+#ifdef CONFIG_RFS_ACCEL
+	for (i = 1; i <= dev->caps.num_ports; i++) {
+		if (mlx4_priv(dev)->port[i].rmap) {
+			free_irq_cpu_rmap(mlx4_priv(dev)->port[i].rmap);
+			mlx4_priv(dev)->port[i].rmap = NULL;
+		}
 	}
+#endif
+	mlx4_free_irqs(dev);
+
+err_out_clr_int:
 	if (!mlx4_is_slave(dev))
 		mlx4_unmap_clr_int(dev);
-	mlx4_free_irqs(dev);
 
 err_out_bitmap:
 	mlx4_unmap_uar(dev);
@@ -1316,11 +1300,19 @@ void mlx4_cleanup_eq_table(struct mlx4_dev *dev)
 	int i;
 
 	mlx4_MAP_EQ(dev, get_async_ev_mask(dev), 1,
-		    priv->eq_table.eq[dev->caps.num_comp_vectors].eqn);
+		    priv->eq_table.eq[MLX4_EQ_ASYNC].eqn);
 
+#ifdef CONFIG_RFS_ACCEL
+	for (i = 1; i <= dev->caps.num_ports; i++) {
+		if (mlx4_priv(dev)->port[i].rmap) {
+			free_irq_cpu_rmap(mlx4_priv(dev)->port[i].rmap);
+			mlx4_priv(dev)->port[i].rmap = NULL;
+		}
+	}
+#endif
 	mlx4_free_irqs(dev);
 
-	for (i = 0; i < dev->caps.num_comp_vectors + dev->caps.comp_pool + 1; ++i)
+	for (i = 0; i < dev->caps.num_comp_vectors + 1; ++i)
 		mlx4_free_eq(dev, &priv->eq_table.eq[i]);
 
 	if (!mlx4_is_slave(dev))
@@ -1371,87 +1363,166 @@ int mlx4_test_interrupts(struct mlx4_dev *dev)
 
 	/* Return to default */
 	mlx4_MAP_EQ(dev, get_async_ev_mask(dev), 0,
-		    priv->eq_table.eq[dev->caps.num_comp_vectors].eqn);
+		    priv->eq_table.eq[MLX4_EQ_ASYNC].eqn);
 	return err;
 }
 EXPORT_SYMBOL(mlx4_test_interrupts);
 
-int mlx4_assign_eq(struct mlx4_dev *dev, char *name, struct cpu_rmap *rmap,
-		   int *vector)
+bool mlx4_is_eq_vector_valid(struct mlx4_dev *dev, u8 port, int vector)
 {
+	struct mlx4_priv *priv = mlx4_priv(dev);
 
+	vector = MLX4_CQ_TO_EQ_VECTOR(vector);
+	if (vector < 0 || (vector >= dev->caps.num_comp_vectors + 1) ||
+	    (vector == MLX4_EQ_ASYNC))
+		return false;
+
+	return test_bit(port - 1, priv->eq_table.eq[vector].actv_ports.ports);
+}
+EXPORT_SYMBOL(mlx4_is_eq_vector_valid);
+
+u32 mlx4_get_eqs_per_port(struct mlx4_dev *dev, u8 port)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	unsigned int i;
+	unsigned int sum = 0;
+
+	for (i = 0; i < dev->caps.num_comp_vectors + 1; i++)
+		sum += !!test_bit(port - 1,
+				  priv->eq_table.eq[i].actv_ports.ports);
+
+	return sum;
+}
+EXPORT_SYMBOL(mlx4_get_eqs_per_port);
+
+int mlx4_is_eq_shared(struct mlx4_dev *dev, int vector)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	vector = MLX4_CQ_TO_EQ_VECTOR(vector);
+	if (vector <= 0 || (vector >= dev->caps.num_comp_vectors + 1))
+		return -EINVAL;
+
+	return !!(bitmap_weight(priv->eq_table.eq[vector].actv_ports.ports,
+				dev->caps.num_ports) > 1);
+}
+EXPORT_SYMBOL(mlx4_is_eq_shared);
+
+struct cpu_rmap *mlx4_get_cpu_rmap(struct mlx4_dev *dev, int port)
+{
+	return mlx4_priv(dev)->port[port].rmap;
+}
+EXPORT_SYMBOL(mlx4_get_cpu_rmap);
+
+int mlx4_assign_eq(struct mlx4_dev *dev, u8 port, int *vector)
+{
 	struct mlx4_priv *priv = mlx4_priv(dev);
-	int vec = 0, err = 0, i;
+	int err = 0, i = 0;
+	u32 min_ref_count_val = (u32)-1;
+	int requested_vector = MLX4_CQ_TO_EQ_VECTOR(*vector);
+	int *prequested_vector = NULL;
+
 
 	mutex_lock(&priv->msix_ctl.pool_lock);
-	for (i = 0; !vec && i < dev->caps.comp_pool; i++) {
-		if (~priv->msix_ctl.pool_bm & 1ULL << i) {
-			priv->msix_ctl.pool_bm |= 1ULL << i;
-			vec = dev->caps.num_comp_vectors + 1 + i;
-			snprintf(priv->eq_table.irq_names +
-					vec * MLX4_IRQNAME_SIZE,
-					MLX4_IRQNAME_SIZE, "%s", name);
-#ifdef CONFIG_RFS_ACCEL
-			if (rmap) {
-				err = irq_cpu_rmap_add(rmap,
-						       priv->eq_table.eq[vec].irq);
-				if (err)
-					mlx4_warn(dev, "Failed adding irq rmap\n");
+	if (requested_vector < (dev->caps.num_comp_vectors + 1) &&
+	    (requested_vector >= 0) &&
+	    (requested_vector != MLX4_EQ_ASYNC)) {
+		if (test_bit(port - 1,
+			     priv->eq_table.eq[requested_vector].actv_ports.ports)) {
+			prequested_vector = &requested_vector;
+		} else {
+			struct mlx4_eq *eq;
+
+			for (i = 1; i < port;
+			     requested_vector += mlx4_get_eqs_per_port(dev, i++))
+				;
+
+			eq = &priv->eq_table.eq[requested_vector];
+			if (requested_vector < dev->caps.num_comp_vectors + 1 &&
+			    test_bit(port - 1, eq->actv_ports.ports)) {
+				prequested_vector = &requested_vector;
 			}
-#endif
-			err = request_irq(priv->eq_table.eq[vec].irq,
-					  mlx4_msi_x_interrupt, 0,
-					  &priv->eq_table.irq_names[vec<<5],
-					  priv->eq_table.eq + vec);
-			if (err) {
-				/*zero out bit by fliping it*/
-				priv->msix_ctl.pool_bm ^= 1 << i;
-				vec = 0;
-				continue;
-				/*we dont want to break here*/
+		}
+	}
+
+	if  (!prequested_vector) {
+		requested_vector = -1;
+		for (i = 0; min_ref_count_val && i < dev->caps.num_comp_vectors + 1;
+		     i++) {
+			struct mlx4_eq *eq = &priv->eq_table.eq[i];
+
+			if (min_ref_count_val > eq->ref_count &&
+			    test_bit(port - 1, eq->actv_ports.ports)) {
+				min_ref_count_val = eq->ref_count;
+				requested_vector = i;
 			}
+		}
 
-			eq_set_ci(&priv->eq_table.eq[vec], 1);
+		if (requested_vector < 0) {
+			err = -ENOSPC;
+			goto err_unlock;
 		}
+
+		prequested_vector = &requested_vector;
 	}
+
+	if (!test_bit(*prequested_vector, priv->msix_ctl.pool_bm) &&
+	    dev->flags & MLX4_FLAG_MSI_X) {
+		set_bit(*prequested_vector, priv->msix_ctl.pool_bm);
+		snprintf(priv->eq_table.irq_names +
+			 *prequested_vector * MLX4_IRQNAME_SIZE,
+			 MLX4_IRQNAME_SIZE, "mlx4-%d@%s",
+			 *prequested_vector, dev_name(&dev->persist->pdev->dev));
+
+		err = request_irq(priv->eq_table.eq[*prequested_vector].irq,
+				  mlx4_msi_x_interrupt, 0,
+				  &priv->eq_table.irq_names[*prequested_vector << 5],
+				  priv->eq_table.eq + *prequested_vector);
+
+		if (err) {
+			clear_bit(*prequested_vector, priv->msix_ctl.pool_bm);
+			*prequested_vector = -1;
+		} else {
+			eq_set_ci(&priv->eq_table.eq[*prequested_vector], 1);
+			priv->eq_table.eq[*prequested_vector].have_irq = 1;
+		}
+	}
+
+	if (!err && *prequested_vector >= 0)
+		priv->eq_table.eq[*prequested_vector].ref_count++;
+
+err_unlock:
 	mutex_unlock(&priv->msix_ctl.pool_lock);
 
-	if (vec) {
-		*vector = vec;
-	} else {
+	if (!err && *prequested_vector >= 0)
+		*vector = MLX4_EQ_TO_CQ_VECTOR(*prequested_vector);
+	else
 		*vector = 0;
-		err = (i == dev->caps.comp_pool) ? -ENOSPC : err;
-	}
+
 	return err;
 }
 EXPORT_SYMBOL(mlx4_assign_eq);
 
-int mlx4_eq_get_irq(struct mlx4_dev *dev, int vec)
+int mlx4_eq_get_irq(struct mlx4_dev *dev, int cq_vec)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
-	return priv->eq_table.eq[vec].irq;
+	return priv->eq_table.eq[MLX4_CQ_TO_EQ_VECTOR(cq_vec)].irq;
 }
 EXPORT_SYMBOL(mlx4_eq_get_irq);
 
 void mlx4_release_eq(struct mlx4_dev *dev, int vec)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
-	/*bm index*/
-	int i = vec - dev->caps.num_comp_vectors - 1;
-
-	if (likely(i >= 0)) {
-		/*sanity check , making sure were not trying to free irq's
-		  Belonging to a legacy EQ*/
-		mutex_lock(&priv->msix_ctl.pool_lock);
-		if (priv->msix_ctl.pool_bm & 1ULL << i) {
-			free_irq(priv->eq_table.eq[vec].irq,
-				 &priv->eq_table.eq[vec]);
-			priv->msix_ctl.pool_bm &= ~(1ULL << i);
-		}
-		mutex_unlock(&priv->msix_ctl.pool_lock);
-	}
+	int eq_vec = MLX4_CQ_TO_EQ_VECTOR(vec);
+
+	mutex_lock(&priv->msix_ctl.pool_lock);
+	priv->eq_table.eq[eq_vec].ref_count--;
 
+	/* once we allocated EQ, we don't release it because it might be binded
+	 * to cpu_rmap.
+	 */
+	mutex_unlock(&priv->msix_ctl.pool_lock);
 }
 EXPORT_SYMBOL(mlx4_release_eq);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 70d33f6..3ec5113 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2364,11 +2364,11 @@ static int mlx4_setup_hca(struct mlx4_dev *dev)
 	if (err) {
 		if (dev->flags & MLX4_FLAG_MSI_X) {
 			mlx4_warn(dev, "NOP command failed to generate MSI-X interrupt IRQ %d)\n",
-				  priv->eq_table.eq[dev->caps.num_comp_vectors].irq);
+				  priv->eq_table.eq[MLX4_EQ_ASYNC].irq);
 			mlx4_warn(dev, "Trying again without MSI-X\n");
 		} else {
 			mlx4_err(dev, "NOP command failed to generate interrupt (IRQ %d), aborting\n",
-				 priv->eq_table.eq[dev->caps.num_comp_vectors].irq);
+				 priv->eq_table.eq[MLX4_EQ_ASYNC].irq);
 			mlx4_err(dev, "BIOS or ACPI interrupt routing problem?\n");
 		}
 
@@ -2486,9 +2486,10 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct msix_entry *entries;
 	int i;
+	int port = 0;
 
 	if (msi_x) {
-		int nreq = dev->caps.num_ports * num_online_cpus() + MSIX_LEGACY_SZ;
+		int nreq = dev->caps.num_ports * num_online_cpus() + 1;
 
 		nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
 			     nreq);
@@ -2503,20 +2504,49 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 		nreq = pci_enable_msix_range(dev->persist->pdev, entries, 2,
 					     nreq);
 
-		if (nreq < 0) {
+		if (nreq < 0 || nreq < MLX4_EQ_ASYNC) {
 			kfree(entries);
 			goto no_msi;
-		} else if (nreq < MSIX_LEGACY_SZ +
-			   dev->caps.num_ports * MIN_MSIX_P_PORT) {
-			/*Working in legacy mode , all EQ's shared*/
-			dev->caps.comp_pool           = 0;
-			dev->caps.num_comp_vectors = nreq - 1;
-		} else {
-			dev->caps.comp_pool           = nreq - MSIX_LEGACY_SZ;
-			dev->caps.num_comp_vectors = MSIX_LEGACY_SZ - 1;
 		}
-		for (i = 0; i < nreq; ++i)
-			priv->eq_table.eq[i].irq = entries[i].vector;
+		/* 1 is reserved for events (asyncrounous EQ) */
+		dev->caps.num_comp_vectors = nreq - 1;
+
+		priv->eq_table.eq[MLX4_EQ_ASYNC].irq = entries[0].vector;
+		bitmap_zero(priv->eq_table.eq[MLX4_EQ_ASYNC].actv_ports.ports,
+			    dev->caps.num_ports);
+
+		for (i = 0; i < dev->caps.num_comp_vectors + 1; i++) {
+			if (i == MLX4_EQ_ASYNC)
+				continue;
+
+			priv->eq_table.eq[i].irq =
+				entries[i + 1 - !!(i > MLX4_EQ_ASYNC)].vector;
+
+			if (MLX4_IS_LEGACY_EQ_MODE(dev->caps)) {
+				bitmap_fill(priv->eq_table.eq[i].actv_ports.ports,
+					    dev->caps.num_ports);
+			} else {
+				set_bit(port,
+					priv->eq_table.eq[i].actv_ports.ports);
+			}
+			/* We divide the Eqs evenly between the two ports.
+			 * (dev->caps.num_comp_vectors / dev->caps.num_ports)
+			 * refers to the number of Eqs per port
+			 * (i.e eqs_per_port). Theoretically, we would like to
+			 * write something like (i + 1) % eqs_per_port == 0.
+			 * However, since there's an asynchronous Eq, we have
+			 * to skip over it by comparing this condition to
+			 * !!((i + 1) > MLX4_EQ_ASYNC).
+			 */
+			if ((dev->caps.num_comp_vectors > dev->caps.num_ports) &&
+			    ((i + 1) %
+			     (dev->caps.num_comp_vectors / dev->caps.num_ports)) ==
+			    !!((i + 1) > MLX4_EQ_ASYNC))
+				/* If dev->caps.num_comp_vectors < dev->caps.num_ports,
+				 * everything is shared anyway.
+				 */
+				port++;
+		}
 
 		dev->flags |= MLX4_FLAG_MSI_X;
 
@@ -2526,10 +2556,15 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 
 no_msi:
 	dev->caps.num_comp_vectors = 1;
-	dev->caps.comp_pool	   = 0;
 
-	for (i = 0; i < 2; ++i)
+	BUG_ON(MLX4_EQ_ASYNC >= 2);
+	for (i = 0; i < 2; ++i) {
 		priv->eq_table.eq[i].irq = dev->persist->pdev->irq;
+		if (i != MLX4_EQ_ASYNC) {
+			bitmap_fill(priv->eq_table.eq[i].actv_ports.ports,
+				    dev->caps.num_ports);
+		}
+	}
 }
 
 static int mlx4_init_port_info(struct mlx4_dev *dev, int port)
@@ -2594,6 +2629,10 @@ static void mlx4_cleanup_port_info(struct mlx4_port_info *info)
 	device_remove_file(&info->dev->persist->pdev->dev, &info->port_attr);
 	device_remove_file(&info->dev->persist->pdev->dev,
 			   &info->port_mtu_attr);
+#ifdef CONFIG_RFS_ACCEL
+	free_irq_cpu_rmap(info->rmap);
+	info->rmap = NULL;
+#endif
 }
 
 static int mlx4_init_steering(struct mlx4_dev *dev)
@@ -3024,7 +3063,7 @@ slave_start:
 	if (err)
 		goto err_master_mfunc;
 
-	priv->msix_ctl.pool_bm = 0;
+	bitmap_zero(priv->msix_ctl.pool_bm, MAX_MSIX);
 	mutex_init(&priv->msix_ctl.pool_lock);
 
 	mlx4_enable_msi_x(dev);
@@ -3046,7 +3085,6 @@ slave_start:
 	    !mlx4_is_mfunc(dev)) {
 		dev->flags &= ~MLX4_FLAG_MSI_X;
 		dev->caps.num_comp_vectors = 1;
-		dev->caps.comp_pool	   = 0;
 		pci_disable_msix(pdev);
 		err = mlx4_setup_hca(dev);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 502d3dd..ff40098 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -287,6 +287,12 @@ struct mlx4_icm_table {
 #define MLX4_CQE_SIZE_MASK_STRIDE	0x3
 #define MLX4_EQE_SIZE_MASK_STRIDE	0x30
 
+#define MLX4_EQ_ASYNC			0
+#define MLX4_EQ_TO_CQ_VECTOR(vector)	((vector) - \
+					 !!((int)(vector) >= MLX4_EQ_ASYNC))
+#define MLX4_CQ_TO_EQ_VECTOR(vector)	((vector) + \
+					 !!((int)(vector) >= MLX4_EQ_ASYNC))
+
 /*
  * Must be packed because mtt_seg is 64 bits but only aligned to 32 bits.
  */
@@ -391,6 +397,8 @@ struct mlx4_eq {
 	struct mlx4_buf_list   *page_list;
 	struct mlx4_mtt		mtt;
 	struct mlx4_eq_tasklet	tasklet_ctx;
+	struct mlx4_active_ports actv_ports;
+	u32			ref_count;
 };
 
 struct mlx4_slave_eqe {
@@ -808,6 +816,7 @@ struct mlx4_port_info {
 	struct mlx4_vlan_table	vlan_table;
 	struct mlx4_roce_gid_table gid_table;
 	int			base_qpn;
+	struct cpu_rmap		*rmap;
 };
 
 struct mlx4_sense {
@@ -818,7 +827,7 @@ struct mlx4_sense {
 };
 
 struct mlx4_msix_ctl {
-	u64		pool_bm;
+	DECLARE_BITMAP(pool_bm, MAX_MSIX);
 	struct mutex	pool_lock;
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index d021f07..edd8fd6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -338,7 +338,7 @@ struct mlx4_en_cq {
 	struct napi_struct	napi;
 	int size;
 	int buf_size;
-	unsigned vector;
+	int vector;
 	enum cq_type is_tx;
 	u16 moder_time;
 	u16 moder_cnt;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 83e80ab..ad31e47 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -46,8 +46,9 @@
 
 #define MAX_MSIX_P_PORT		17
 #define MAX_MSIX		64
-#define MSIX_LEGACY_SZ		4
 #define MIN_MSIX_P_PORT		5
+#define MLX4_IS_LEGACY_EQ_MODE(dev_cap) ((dev_cap).num_comp_vectors < \
+					 (dev_cap).num_ports * MIN_MSIX_P_PORT)
 
 #define MLX4_MAX_100M_UNITS_VAL		255	/*
 						 * work around: can't set values
@@ -528,7 +529,6 @@ struct mlx4_caps {
 	int			num_eqs;
 	int			reserved_eqs;
 	int			num_comp_vectors;
-	int			comp_pool;
 	int			num_mpts;
 	int			max_fmr_maps;
 	int			num_mtts;
@@ -1332,10 +1332,13 @@ void mlx4_fmr_unmap(struct mlx4_dev *dev, struct mlx4_fmr *fmr,
 int mlx4_fmr_free(struct mlx4_dev *dev, struct mlx4_fmr *fmr);
 int mlx4_SYNC_TPT(struct mlx4_dev *dev);
 int mlx4_test_interrupts(struct mlx4_dev *dev);
-int mlx4_assign_eq(struct mlx4_dev *dev, char *name, struct cpu_rmap *rmap,
-		   int *vector);
+u32 mlx4_get_eqs_per_port(struct mlx4_dev *dev, u8 port);
+bool mlx4_is_eq_vector_valid(struct mlx4_dev *dev, u8 port, int vector);
+struct cpu_rmap *mlx4_get_cpu_rmap(struct mlx4_dev *dev, int port);
+int mlx4_assign_eq(struct mlx4_dev *dev, u8 port, int *vector);
 void mlx4_release_eq(struct mlx4_dev *dev, int vec);
 
+int mlx4_is_eq_shared(struct mlx4_dev *dev, int vector);
 int mlx4_eq_get_irq(struct mlx4_dev *dev, int vec);
 
 int mlx4_get_phys_port_id(struct mlx4_dev *dev);
-- 
1.7.1
