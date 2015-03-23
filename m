From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH] mlx4/mlx5: Use dma_wmb/rmb where appropriate
Date: Mon, 23 Mar 2015 10:23:29 -0700
Message-ID: <20150323171300.1117.85908.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52545 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753189AbbCWRXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 13:23:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch should help to improve the performance of the mlx4 and mlx5 on a
number of architectures.  For example, on x86 the dma_wmb/rmb equates out
to a barrer() call as the architecture is already strong ordered, and on
PowerPC the call works out to a lwsync which is significantly less expensive
than the sync call that was being used for wmb.

I placed the new barriers between any spots that seemed to be trying to
order memory/memory reads or writes, if there are any spots that involved
MMIO I left the existing wmb in place as the new barriers cannot order
transactions between coherent and non-coherent memories.

Cc: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---

I don't have any adapters supported by these drivers so I am unable to do
anything more than build test the changes.

 drivers/net/ethernet/mellanox/mlx4/en_rx.c   |    4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   |   18 +++++++++---------
 drivers/net/ethernet/mellanox/mlx4/eq.c      |    4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/eq.c |    2 +-
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 698d60d..84cbc68 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -771,7 +771,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		/*
 		 * make sure we read the CQE after we read the ownership bit
 		 */
-		rmb();
+		dma_rmb();
 
 		/* Drop packet on bad receive or bad checksum */
 		if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
@@ -985,7 +985,7 @@ next:
 out:
 	AVG_PERF_COUNTER(priv->pstats.rx_coal_avg, polled);
 	mlx4_cq_set_ci(&cq->mcq);
-	wmb(); /* ensure HW sees CQ consumer before we post new buffers */
+	dma_wmb(); /* ensure HW sees CQ consumer before we post new buffers */
 	ring->cons = cq->mcq.cons_index;
 	mlx4_en_refill_rx_buffers(priv, ring);
 	mlx4_en_update_rx_prod_db(ring);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 55f9f5c..4afaa50 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -416,7 +416,7 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 		 * make sure we read the CQE after we read the
 		 * ownership bit
 		 */
-		rmb();
+		dma_rmb();
 
 		if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
 			     MLX4_CQE_OPCODE_ERROR)) {
@@ -463,7 +463,7 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 	 */
 	mcq->cons_index = cons_index;
 	mlx4_cq_set_ci(mcq);
-	wmb();
+	dma_wmb();
 
 	/* we want to dirty this cache line once */
 	ACCESS_ONCE(ring->last_nr_txbb) = last_nr_txbb;
@@ -521,7 +521,7 @@ static struct mlx4_en_tx_desc *mlx4_en_bounce_to_desc(struct mlx4_en_priv *priv,
 
 	for (i = desc_size - copy - 4; i >= 0; i -= 4) {
 		if ((i & (TXBB_SIZE - 1)) == 0)
-			wmb();
+			dma_wmb();
 
 		*((u32 *) (ring->buf + i)) =
 			*((u32 *) (ring->bounce_buf + copy + i));
@@ -529,7 +529,7 @@ static struct mlx4_en_tx_desc *mlx4_en_bounce_to_desc(struct mlx4_en_priv *priv,
 
 	for (i = copy - 4; i >= 4 ; i -= 4) {
 		if ((i & (TXBB_SIZE - 1)) == 0)
-			wmb();
+			dma_wmb();
 
 		*((u32 *) (ring->buf + index * TXBB_SIZE + i)) =
 			*((u32 *) (ring->bounce_buf + i));
@@ -667,7 +667,7 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc,
 				       skb_frag_size(&shinfo->frags[0]));
 		}
 
-		wmb();
+		dma_wmb();
 		inl->byte_count = cpu_to_be32(1 << 31 | (skb->len - spc));
 	}
 }
@@ -804,7 +804,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 			data->addr = cpu_to_be64(dma);
 			data->lkey = ring->mr_key;
-			wmb();
+			dma_wmb();
 			data->byte_count = cpu_to_be32(byte_count);
 			--data;
 		}
@@ -821,7 +821,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 			data->addr = cpu_to_be64(dma);
 			data->lkey = ring->mr_key;
-			wmb();
+			dma_wmb();
 			data->byte_count = cpu_to_be32(byte_count);
 		}
 		/* tx completion can avoid cache line miss for common cases */
@@ -938,7 +938,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* Ensure new descriptor hits memory
 		 * before setting ownership of this descriptor to HW
 		 */
-		wmb();
+		dma_wmb();
 		tx_desc->ctrl.owner_opcode = op_own;
 
 		wmb();
@@ -958,7 +958,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* Ensure new descriptor hits memory
 		 * before setting ownership of this descriptor to HW
 		 */
-		wmb();
+		dma_wmb();
 		tx_desc->ctrl.owner_opcode = op_own;
 		if (send_doorbell) {
 			wmb();
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 264bc15..21ae65d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -190,7 +190,7 @@ static void slave_event(struct mlx4_dev *dev, u8 slave, struct mlx4_eqe *eqe)
 	memcpy(s_eqe, eqe, dev->caps.eqe_size - 1);
 	s_eqe->slave_id = slave;
 	/* ensure all information is written before setting the ownersip bit */
-	wmb();
+	dma_wmb();
 	s_eqe->owner = !!(slave_eq->prod & SLAVE_EVENT_EQ_SIZE) ? 0x0 : 0x80;
 	++slave_eq->prod;
 
@@ -477,7 +477,7 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 		 * Make sure we read EQ entry contents after we've
 		 * checked the ownership bit.
 		 */
-		rmb();
+		dma_rmb();
 
 		switch (eqe->type) {
 		case MLX4_EVENT_TYPE_COMP:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index da82991..4a4f0ca 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -208,7 +208,7 @@ static int mlx5_eq_int(struct mlx5_core_dev *dev, struct mlx5_eq *eq)
 		 * Make sure we read EQ entry contents after we've
 		 * checked the ownership bit.
 		 */
-		rmb();
+		dma_rmb();
 
 		mlx5_core_dbg(eq->dev, "eqn %d, eqe type %s\n",
 			      eq->eqn, eqe_type_str(eqe->type));
