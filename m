From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 6/6] net/mlx4_en: Datapath structures are allocated per NUMA node
Date: Thu,  7 Nov 2013 12:19:54 +0200
Message-ID: <1383819594-24070-7-git-send-email-amirv@mellanox.com>
References: <1383819594-24070-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:44689 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754199Ab3KGKUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 05:20:19 -0500
In-Reply-To: <1383819594-24070-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

For each RX/TX ring and its CQ, allocation is done on a NUMA node that
corresponds to the core that the data structure should operate on.
The assumption is that the core number is reflected by the ring index.
The affected allocations are the ring/CQ data structures,
the TX/RX info and the shared HW/SW buffer.
For TX rings, each core has rings of all UPs.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c     | 17 ++++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 12 ++++++---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 23 +++++++++++------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 34 +++++++++++++++++---------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  6 ++---
 drivers/net/ethernet/mellanox/mlx4/pd.c        | 11 ++++++---
 include/linux/mlx4/device.h                    |  2 +-
 7 files changed, 71 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index d203f11..3a098cc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -45,16 +45,20 @@ static void mlx4_en_cq_event(struct mlx4_cq *cq, enum mlx4_event event)
 
 int mlx4_en_create_cq(struct mlx4_en_priv *priv,
 		      struct mlx4_en_cq **pcq,
-		      int entries, int ring, enum cq_type mode)
+		      int entries, int ring, enum cq_type mode,
+		      int node)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_cq *cq;
 	int err;
 
-	cq = kzalloc(sizeof(*cq), GFP_KERNEL);
+	cq = kzalloc_node(sizeof(*cq), GFP_KERNEL, node);
 	if (!cq) {
-		en_err(priv, "Failed to allocate CQ structure\n");
-		return -ENOMEM;
+		cq = kzalloc(sizeof(*cq), GFP_KERNEL);
+		if (!cq) {
+			en_err(priv, "Failed to allocate CQ structure\n");
+			return -ENOMEM;
+		}
 	}
 
 	cq->size = entries;
@@ -64,8 +68,13 @@ int mlx4_en_create_cq(struct mlx4_en_priv *priv,
 	cq->is_tx = mode;
 	spin_lock_init(&cq->lock);
 
+	/* Allocate HW buffers on provided NUMA node.
+	 * dev->numa_node is used in mtt range allocation flow.
+	 */
+	set_dev_node(&mdev->dev->pdev->dev, node);
 	err = mlx4_alloc_hwq_res(mdev->dev, &cq->wqres,
 				cq->buf_size, 2 * PAGE_SIZE);
+	set_dev_node(&mdev->dev->pdev->dev, mdev->dev->numa_node);
 	if (err)
 		goto err_cq;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index f430788..e72d8a1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1895,6 +1895,7 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 	struct mlx4_en_port_profile *prof = priv->prof;
 	int i;
 	int err;
+	int node;
 
 	err = mlx4_qp_reserve_range(priv->mdev->dev, priv->tx_ring_num, 256, &priv->base_tx_qpn);
 	if (err) {
@@ -1904,23 +1905,26 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 
 	/* Create tx Rings */
 	for (i = 0; i < priv->tx_ring_num; i++) {
+		node = cpu_to_node(i % num_online_cpus());
 		if (mlx4_en_create_cq(priv, &priv->tx_cq[i],
-				      prof->tx_ring_size, i, TX))
+				      prof->tx_ring_size, i, TX, node))
 			goto err;
 
 		if (mlx4_en_create_tx_ring(priv, &priv->tx_ring[i], priv->base_tx_qpn + i,
-					   prof->tx_ring_size, TXBB_SIZE))
+					   prof->tx_ring_size, TXBB_SIZE, node))
 			goto err;
 	}
 
 	/* Create rx Rings */
 	for (i = 0; i < priv->rx_ring_num; i++) {
+		node = cpu_to_node(i % num_online_cpus());
 		if (mlx4_en_create_cq(priv, &priv->rx_cq[i],
-				      prof->rx_ring_size, i, RX))
+				      prof->rx_ring_size, i, RX, node))
 			goto err;
 
 		if (mlx4_en_create_rx_ring(priv, &priv->rx_ring[i],
-					   prof->rx_ring_size, priv->stride))
+					   prof->rx_ring_size, priv->stride,
+					   node))
 			goto err;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 1c45f88..07a1d0f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -320,17 +320,20 @@ static void mlx4_en_free_rx_buf(struct mlx4_en_priv *priv,
 
 int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 			   struct mlx4_en_rx_ring **pring,
-			   u32 size, u16 stride)
+			   u32 size, u16 stride, int node)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_rx_ring *ring;
 	int err = -ENOMEM;
 	int tmp;
 
-	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
+	ring = kzalloc_node(sizeof(*ring), GFP_KERNEL, node);
 	if (!ring) {
-		en_err(priv, "Failed to allocate RX ring structure\n");
-		return -ENOMEM;
+		ring = kzalloc(sizeof(*ring), GFP_KERNEL);
+		if (!ring) {
+			en_err(priv, "Failed to allocate RX ring structure\n");
+			return -ENOMEM;
+		}
 	}
 
 	ring->prod = 0;
@@ -343,17 +346,23 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 
 	tmp = size * roundup_pow_of_two(MLX4_EN_MAX_RX_FRAGS *
 					sizeof(struct mlx4_en_rx_alloc));
-	ring->rx_info = vmalloc(tmp);
+	ring->rx_info = vmalloc_node(tmp, node);
 	if (!ring->rx_info) {
-		err = -ENOMEM;
-		goto err_ring;
+		ring->rx_info = vmalloc(tmp);
+		if (!ring->rx_info) {
+			err = -ENOMEM;
+			goto err_ring;
+		}
 	}
 
 	en_dbg(DRV, priv, "Allocated rx_info ring at addr:%p size:%d\n",
 		 ring->rx_info, tmp);
 
+	/* Allocate HW buffers on provided NUMA node */
+	set_dev_node(&mdev->dev->pdev->dev, node);
 	err = mlx4_alloc_hwq_res(mdev->dev, &ring->wqres,
 				 ring->buf_size, 2 * PAGE_SIZE);
+	set_dev_node(&mdev->dev->pdev->dev, mdev->dev->numa_node);
 	if (err)
 		goto err_info;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index d4e4cf3..f54ebd5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -55,17 +55,20 @@ MODULE_PARM_DESC(inline_thold, "threshold for using inline data");
 
 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 			   struct mlx4_en_tx_ring **pring, int qpn, u32 size,
-			   u16 stride)
+			   u16 stride, int node)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_tx_ring *ring;
 	int tmp;
 	int err;
 
-	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
+	ring = kzalloc_node(sizeof(*ring), GFP_KERNEL, node);
 	if (!ring) {
-		en_err(priv, "Failed allocating TX ring\n");
-		return -ENOMEM;
+		ring = kzalloc(sizeof(*ring), GFP_KERNEL);
+		if (!ring) {
+			en_err(priv, "Failed allocating TX ring\n");
+			return -ENOMEM;
+		}
 	}
 
 	ring->size = size;
@@ -75,24 +78,33 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	inline_thold = min(inline_thold, MAX_INLINE);
 
 	tmp = size * sizeof(struct mlx4_en_tx_info);
-	ring->tx_info = vmalloc(tmp);
+	ring->tx_info = vmalloc_node(tmp, node);
 	if (!ring->tx_info) {
-		err = -ENOMEM;
-		goto err_ring;
+		ring->tx_info = vmalloc(tmp);
+		if (!ring->tx_info) {
+			err = -ENOMEM;
+			goto err_ring;
+		}
 	}
 
 	en_dbg(DRV, priv, "Allocated tx_info ring at addr:%p size:%d\n",
 		 ring->tx_info, tmp);
 
-	ring->bounce_buf = kmalloc(MAX_DESC_SIZE, GFP_KERNEL);
+	ring->bounce_buf = kmalloc_node(MAX_DESC_SIZE, GFP_KERNEL, node);
 	if (!ring->bounce_buf) {
-		err = -ENOMEM;
-		goto err_info;
+		ring->bounce_buf = kmalloc(MAX_DESC_SIZE, GFP_KERNEL);
+		if (!ring->bounce_buf) {
+			err = -ENOMEM;
+			goto err_info;
+		}
 	}
 	ring->buf_size = ALIGN(size * ring->stride, MLX4_EN_PAGE_SIZE);
 
+	/* Allocate HW buffers on provided NUMA node */
+	set_dev_node(&mdev->dev->pdev->dev, node);
 	err = mlx4_alloc_hwq_res(mdev->dev, &ring->wqres, ring->buf_size,
 				 2 * PAGE_SIZE);
+	set_dev_node(&mdev->dev->pdev->dev, mdev->dev->numa_node);
 	if (err) {
 		en_err(priv, "Failed allocating hwq resources\n");
 		goto err_bounce;
@@ -118,7 +130,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	}
 	ring->qp.event = mlx4_en_sqp_event;
 
-	err = mlx4_bf_alloc(mdev->dev, &ring->bf);
+	err = mlx4_bf_alloc(mdev->dev, &ring->bf, node);
 	if (err) {
 		en_dbg(DRV, priv, "working without blueflame (%d)", err);
 		ring->bf.uar = &mdev->priv_uar;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index b2547ae..f3758de 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -705,7 +705,7 @@ void mlx4_en_free_resources(struct mlx4_en_priv *priv);
 int mlx4_en_alloc_resources(struct mlx4_en_priv *priv);
 
 int mlx4_en_create_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq,
-		      int entries, int ring, enum cq_type mode);
+		      int entries, int ring, enum cq_type mode, int node);
 void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq);
 int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 			int cq_idx);
@@ -719,7 +719,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
 
 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 			   struct mlx4_en_tx_ring **pring,
-			   int qpn, u32 size, u16 stride);
+			   int qpn, u32 size, u16 stride, int node);
 void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_tx_ring **pring);
 int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
@@ -730,7 +730,7 @@ void mlx4_en_deactivate_tx_ring(struct mlx4_en_priv *priv,
 
 int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 			   struct mlx4_en_rx_ring **pring,
-			   u32 size, u16 stride);
+			   u32 size, u16 stride, int node);
 void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_rx_ring **pring,
 			     u32 size, u16 stride);
diff --git a/drivers/net/ethernet/mellanox/mlx4/pd.c b/drivers/net/ethernet/mellanox/mlx4/pd.c
index 00f223a..84cfb40 100644
--- a/drivers/net/ethernet/mellanox/mlx4/pd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/pd.c
@@ -168,7 +168,7 @@ void mlx4_uar_free(struct mlx4_dev *dev, struct mlx4_uar *uar)
 }
 EXPORT_SYMBOL_GPL(mlx4_uar_free);
 
-int mlx4_bf_alloc(struct mlx4_dev *dev, struct mlx4_bf *bf)
+int mlx4_bf_alloc(struct mlx4_dev *dev, struct mlx4_bf *bf, int node)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_uar *uar;
@@ -186,10 +186,13 @@ int mlx4_bf_alloc(struct mlx4_dev *dev, struct mlx4_bf *bf)
 			err = -ENOMEM;
 			goto out;
 		}
-		uar = kmalloc(sizeof *uar, GFP_KERNEL);
+		uar = kmalloc_node(sizeof(*uar), GFP_KERNEL, node);
 		if (!uar) {
-			err = -ENOMEM;
-			goto out;
+			uar = kmalloc(sizeof(*uar), GFP_KERNEL);
+			if (!uar) {
+				err = -ENOMEM;
+				goto out;
+			}
 		}
 		err = mlx4_uar_alloc(dev, uar);
 		if (err)
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 4cf0b01..7d3a523 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -835,7 +835,7 @@ void mlx4_xrcd_free(struct mlx4_dev *dev, u32 xrcdn);
 
 int mlx4_uar_alloc(struct mlx4_dev *dev, struct mlx4_uar *uar);
 void mlx4_uar_free(struct mlx4_dev *dev, struct mlx4_uar *uar);
-int mlx4_bf_alloc(struct mlx4_dev *dev, struct mlx4_bf *bf);
+int mlx4_bf_alloc(struct mlx4_dev *dev, struct mlx4_bf *bf, int node);
 void mlx4_bf_free(struct mlx4_dev *dev, struct mlx4_bf *bf);
 
 int mlx4_mtt_init(struct mlx4_dev *dev, int npages, int page_shift,
-- 
1.8.3.4
