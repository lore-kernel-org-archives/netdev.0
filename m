From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 2/4] mlx4/mlx5: Use dma_wmb/rmb where appropriate
Date: Wed, 08 Apr 2015 18:49:36 -0700
Message-ID: <20150409014936.4434.49605.stgit@ahduyck-vm-fedora22>
References: <20150409014001.4434.85280.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Eli Cohen <eli@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44167 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753811AbbDIBtm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 21:49:42 -0400
In-Reply-To: <20150409014001.4434.85280.stgit@ahduyck-vm-fedora22>
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

v2: Reduced the replacments to just the spots where I could clearly
    identify the usage pattern.

Cc: Amir Vadai <amirv@mellanox.com>
Cc: Ido Shamay <idos@mellanox.com>
Cc: Eli Cohen <eli@mellanox.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   |   12 ++++++------
 drivers/net/ethernet/mellanox/mlx4/eq.c      |    4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/eq.c |    2 +-
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 79b1501e7951..4fdd3c37e47b 100644
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
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 55f9f5c5344e..1783705273d8 100644
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
index 6e70ffee8e87..190fd624bdfe 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -188,7 +188,7 @@ static void slave_event(struct mlx4_dev *dev, u8 slave, struct mlx4_eqe *eqe)
 	memcpy(s_eqe, eqe, dev->caps.eqe_size - 1);
 	s_eqe->slave_id = slave;
 	/* ensure all information is written before setting the ownersip bit */
-	wmb();
+	dma_wmb();
 	s_eqe->owner = !!(slave_eq->prod & SLAVE_EVENT_EQ_SIZE) ? 0x0 : 0x80;
 	++slave_eq->prod;
 
@@ -473,7 +473,7 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 		 * Make sure we read EQ entry contents after we've
 		 * checked the ownership bit.
 		 */
-		rmb();
+		dma_rmb();
 
 		switch (eqe->type) {
 		case MLX4_EVENT_TYPE_COMP:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index dbf190d9b9ad..58800e4f3958 100644
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
