From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH v2 15/16] mlx4_en: Using blue flame support
Date: Wed, 23 Mar 2011 10:38:52 +0200
Message-ID: <4D89B19C.3020305@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:35814 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755923Ab1CWIi6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 04:38:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Doorbell is used according to usage of BlueFlame.
For Blue Flame to work in Ethernet mode QP number should have 0
at bits 6,7.
Allocating range of QPs accordingly.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |   10 +++++-
 drivers/net/mlx4/en_tx.c     |   72 ++++++++++++++++++++++++++++++-----------
 drivers/net/mlx4/mlx4_en.h   |    4 ++-
 3 files changed, 64 insertions(+), 22 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 08e6801..5762ebd 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -931,6 +931,13 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 {
 	struct mlx4_en_port_profile *prof = priv->prof;
 	int i;
+	int base_tx_qpn, err;
+
+	err = mlx4_qp_reserve_range(priv->mdev->dev, priv->tx_ring_num, 256, &base_tx_qpn);
+	if (err) {
+		en_err(priv, "failed reserving range for TX rings\n");
+		return err;
+	}
 
 	/* Create tx Rings */
 	for (i = 0; i < priv->tx_ring_num; i++) {
@@ -938,7 +945,7 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 				      prof->tx_ring_size, i, TX))
 			goto err;
 
-		if (mlx4_en_create_tx_ring(priv, &priv->tx_ring[i],
+		if (mlx4_en_create_tx_ring(priv, &priv->tx_ring[i], base_tx_qpn + i,
 					   prof->tx_ring_size, TXBB_SIZE))
 			goto err;
 	}
@@ -958,6 +965,7 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 
 err:
 	en_err(priv, "Failed to allocate NIC resources\n");
+	mlx4_qp_release_range(priv->mdev->dev, base_tx_qpn, priv->tx_ring_num);
 	return -ENOMEM;
 }
 
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index a680cd4..01feb8f 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -44,6 +44,7 @@
 
 enum {
 	MAX_INLINE = 104, /* 128 - 16 - 4 - 4 */
+	MAX_BF = 256,
 };
 
 static int inline_thold __read_mostly = MAX_INLINE;
@@ -52,7 +53,7 @@ module_param_named(inline_thold, inline_thold, int, 0444);
 MODULE_PARM_DESC(inline_thold, "threshold for using inline data");
 
 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
-			   struct mlx4_en_tx_ring *ring, u32 size,
+			   struct mlx4_en_tx_ring *ring, int qpn, u32 size,
 			   u16 stride)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
@@ -103,23 +104,25 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	       "buf_size:%d dma:%llx\n", ring, ring->buf, ring->size,
 	       ring->buf_size, (unsigned long long) ring->wqres.buf.direct.map);
 
-	err = mlx4_qp_reserve_range(mdev->dev, 1, 1, &ring->qpn);
-	if (err) {
-		en_err(priv, "Failed reserving qp for tx ring.\n");
-		goto err_map;
-	}
-
+	ring->qpn = qpn;
 	err = mlx4_qp_alloc(mdev->dev, ring->qpn, &ring->qp);
 	if (err) {
 		en_err(priv, "Failed allocating qp %d\n", ring->qpn);
-		goto err_reserve;
+		goto err_map;
 	}
 	ring->qp.event = mlx4_en_sqp_event;
 
+	err = mlx4_bf_alloc(mdev->dev, &ring->bf);
+	if (err) {
+		en_dbg(DRV, priv, "working without blueflame (%d)", err);
+		ring->bf.uar = &mdev->priv_uar;
+		ring->bf.uar->map = mdev->uar_map;
+		ring->bf_enabled = false;
+	} else
+		ring->bf_enabled = true;
+
 	return 0;
 
-err_reserve:
-	mlx4_qp_release_range(mdev->dev, ring->qpn, 1);
 err_map:
 	mlx4_en_unmap_buffer(&ring->wqres.buf);
 err_hwq_res:
@@ -139,6 +142,8 @@ void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
 	struct mlx4_en_dev *mdev = priv->mdev;
 	en_dbg(DRV, priv, "Destroying tx ring, qpn: %d\n", ring->qpn);
 
+	if (ring->bf_enabled)
+		mlx4_bf_free(mdev->dev, &ring->bf);
 	mlx4_qp_remove(mdev->dev, &ring->qp);
 	mlx4_qp_free(mdev->dev, &ring->qp);
 	mlx4_qp_release_range(mdev->dev, ring->qpn, 1);
@@ -171,6 +176,8 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 
 	mlx4_en_fill_qp_context(priv, ring->size, ring->stride, 1, 0, ring->qpn,
 				ring->cqn, &ring->context);
+	if (ring->bf_enabled)
+		ring->context.usr_page = cpu_to_be32(ring->bf.uar->index);
 
 	err = mlx4_qp_to_ready(mdev->dev, &ring->wqres.mtt, &ring->context,
 			       &ring->qp, &ring->qp_state);
@@ -591,6 +598,11 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
 	return skb_tx_hash(dev, skb);
 }
 
+static void mlx4_bf_copy(unsigned long *dst, unsigned long *src, unsigned bytecnt)
+{
+	__iowrite64_copy(dst, src, bytecnt / 8);
+}
+
 netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -609,12 +621,13 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	int desc_size;
 	int real_size;
 	dma_addr_t dma;
-	u32 index;
+	u32 index, bf_index;
 	__be32 op_own;
 	u16 vlan_tag = 0;
 	int i;
 	int lso_header_size;
 	void *fragptr;
+	bool bounce = false;
 
 	if (!priv->port_up)
 		goto tx_drop;
@@ -657,13 +670,16 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Packet is good - grab an index and transmit it */
 	index = ring->prod & ring->size_mask;
+	bf_index = ring->prod;
 
 	/* See if we have enough space for whole descriptor TXBB for setting
 	 * SW ownership on next descriptor; if not, use a bounce buffer. */
 	if (likely(index + nr_txbb <= ring->size))
 		tx_desc = ring->buf + index * TXBB_SIZE;
-	else
+	else {
 		tx_desc = (struct mlx4_en_tx_desc *) ring->bounce_buf;
+		bounce = true;
+	}
 
 	/* Save skb in tx_info ring */
 	tx_info = &ring->tx_info[index];
@@ -768,21 +784,37 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	ring->prod += nr_txbb;
 
 	/* If we used a bounce buffer then copy descriptor back into place */
-	if (tx_desc == (struct mlx4_en_tx_desc *) ring->bounce_buf)
+	if (bounce)
 		tx_desc = mlx4_en_bounce_to_desc(priv, ring, index, desc_size);
 
 	/* Run destructor before passing skb to HW */
 	if (likely(!skb_shared(skb)))
 		skb_orphan(skb);
 
-	/* Ensure new descirptor hits memory
-	 * before setting ownership of this descriptor to HW */
-	wmb();
-	tx_desc->ctrl.owner_opcode = op_own;
+	if (ring->bf_enabled && desc_size <= MAX_BF && !bounce && !vlan_tag) {
+		*(u32 *) (&tx_desc->ctrl.vlan_tag) |= ring->doorbell_qpn;
+		op_own |= htonl((bf_index & 0xffff) << 8);
+		/* Ensure new descirptor hits memory
+		* before setting ownership of this descriptor to HW */
+		wmb();
+		tx_desc->ctrl.owner_opcode = op_own;
 
-	/* Ring doorbell! */
-	wmb();
-	writel(ring->doorbell_qpn, mdev->uar_map + MLX4_SEND_DOORBELL);
+		wmb();
+
+		mlx4_bf_copy(ring->bf.reg + ring->bf.offset, (unsigned long *) &tx_desc->ctrl,
+		     desc_size);
+
+		wmb();
+
+		ring->bf.offset ^= ring->bf.buf_size;
+	} else {
+		/* Ensure new descirptor hits memory
+		* before setting ownership of this descriptor to HW */
+		wmb();
+		tx_desc->ctrl.owner_opcode = op_own;
+		wmb();
+		writel(ring->doorbell_qpn, ring->bf.uar->map + MLX4_SEND_DOORBELL);
+	}
 
 	/* Poll CQ here */
 	mlx4_en_xmit_poll(priv, tx_ind);
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 5a2c560..edcb535 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -248,6 +248,8 @@ struct mlx4_en_tx_ring {
 	unsigned long bytes;
 	unsigned long packets;
 	spinlock_t comp_lock;
+	struct mlx4_bf bf;
+	bool bf_enabled;
 };
 
 struct mlx4_en_rx_desc {
@@ -518,7 +520,7 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb);
 netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
 
 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv, struct mlx4_en_tx_ring *ring,
-			   u32 size, u16 stride);
+			   int qpn, u32 size, u16 stride);
 void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv, struct mlx4_en_tx_ring *ring);
 int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_tx_ring *ring,
-- 
1.6.0.2





