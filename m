From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v7 08/11] net/mlx4_en: break out tx_desc write into separate function
Date: Mon, 11 Jul 2016 14:29:55 -0700
Message-ID: <1468272598-21390-9-git-send-email-bblanco@plumgrid.com>
References: <1468272598-21390-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35498 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753356AbcGKVaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 17:30:18 -0400
Received: by mail-pf0-f173.google.com with SMTP id c2so40132751pfa.2
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 14:30:18 -0700 (PDT)
In-Reply-To: <1468272598-21390-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for writing the tx descriptor from multiple functions,
create a helper for both normal and blueflame access.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 drivers/infiniband/hw/mlx4/qp.c            |  11 +--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 127 +++++++++++++++++------------
 include/linux/mlx4/qp.h                    |  18 ++--
 3 files changed, 90 insertions(+), 66 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index 8db8405..768085f 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -232,7 +232,7 @@ static void stamp_send_wqe(struct mlx4_ib_qp *qp, int n, int size)
 		}
 	} else {
 		ctrl = buf = get_send_wqe(qp, n & (qp->sq.wqe_cnt - 1));
-		s = (ctrl->fence_size & 0x3f) << 4;
+		s = (ctrl->qpn_vlan.fence_size & 0x3f) << 4;
 		for (i = 64; i < s; i += 64) {
 			wqe = buf + i;
 			*wqe = cpu_to_be32(0xffffffff);
@@ -264,7 +264,7 @@ static void post_nop_wqe(struct mlx4_ib_qp *qp, int n, int size)
 		inl->byte_count = cpu_to_be32(1 << 31 | (size - s - sizeof *inl));
 	}
 	ctrl->srcrb_flags = 0;
-	ctrl->fence_size = size / 16;
+	ctrl->qpn_vlan.fence_size = size / 16;
 	/*
 	 * Make sure descriptor is fully written before setting ownership bit
 	 * (because HW can start executing as soon as we do).
@@ -1992,7 +1992,8 @@ static int __mlx4_ib_modify_qp(struct ib_qp *ibqp,
 			ctrl = get_send_wqe(qp, i);
 			ctrl->owner_opcode = cpu_to_be32(1 << 31);
 			if (qp->sq_max_wqes_per_wr == 1)
-				ctrl->fence_size = 1 << (qp->sq.wqe_shift - 4);
+				ctrl->qpn_vlan.fence_size =
+						1 << (qp->sq.wqe_shift - 4);
 
 			stamp_send_wqe(qp, i, 1 << qp->sq.wqe_shift);
 		}
@@ -3169,8 +3170,8 @@ int mlx4_ib_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 		wmb();
 		*lso_wqe = lso_hdr_sz;
 
-		ctrl->fence_size = (wr->send_flags & IB_SEND_FENCE ?
-				    MLX4_WQE_CTRL_FENCE : 0) | size;
+		ctrl->qpn_vlan.fence_size = (wr->send_flags & IB_SEND_FENCE ?
+					     MLX4_WQE_CTRL_FENCE : 0) | size;
 
 		/*
 		 * Make sure descriptor is fully written before
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 76aa4d2..c29191e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -700,10 +700,66 @@ static void mlx4_bf_copy(void __iomem *dst, const void *src,
 	__iowrite64_copy(dst, src, bytecnt / 8);
 }
 
+void mlx4_en_xmit_doorbell(struct mlx4_en_tx_ring *ring)
+{
+	wmb();
+	/* Since there is no iowrite*_native() that writes the
+	 * value as is, without byteswapping - using the one
+	 * the doesn't do byteswapping in the relevant arch
+	 * endianness.
+	 */
+#if defined(__LITTLE_ENDIAN)
+	iowrite32(
+#else
+	iowrite32be(
+#endif
+		  ring->doorbell_qpn,
+		  ring->bf.uar->map + MLX4_SEND_DOORBELL);
+}
+
+static void mlx4_en_tx_write_desc(struct mlx4_en_tx_ring *ring,
+				  struct mlx4_en_tx_desc *tx_desc,
+				  union mlx4_wqe_qpn_vlan qpn_vlan,
+				  int desc_size, int bf_index,
+				  __be32 op_own, bool bf_ok,
+				  bool send_doorbell)
+{
+	tx_desc->ctrl.qpn_vlan = qpn_vlan;
+
+	if (bf_ok) {
+		op_own |= htonl((bf_index & 0xffff) << 8);
+		/* Ensure new descriptor hits memory
+		 * before setting ownership of this descriptor to HW
+		 */
+		dma_wmb();
+		tx_desc->ctrl.owner_opcode = op_own;
+
+		wmb();
+
+		mlx4_bf_copy(ring->bf.reg + ring->bf.offset, &tx_desc->ctrl,
+			     desc_size);
+
+		wmb();
+
+		ring->bf.offset ^= ring->bf.buf_size;
+	} else {
+		/* Ensure new descriptor hits memory
+		 * before setting ownership of this descriptor to HW
+		 */
+		dma_wmb();
+		tx_desc->ctrl.owner_opcode = op_own;
+		if (send_doorbell)
+			mlx4_en_xmit_doorbell(ring);
+		else
+			ring->xmit_more++;
+	}
+}
+
 netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	struct mlx4_en_priv *priv = netdev_priv(dev);
+	union mlx4_wqe_qpn_vlan	qpn_vlan = {};
 	struct device *ddev = priv->ddev;
 	struct mlx4_en_tx_ring *ring;
 	struct mlx4_en_tx_desc *tx_desc;
@@ -725,6 +781,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	bool stop_queue;
 	bool inline_ok;
 	u32 ring_cons;
+	bool bf_ok;
 
 	tx_ind = skb_get_queue_mapping(skb);
 	ring = priv->tx_ring[tx_ind];
@@ -749,9 +806,17 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto tx_drop;
 	}
 
+	bf_ok = ring->bf_enabled;
 	if (skb_vlan_tag_present(skb)) {
-		vlan_tag = skb_vlan_tag_get(skb);
+		qpn_vlan.vlan_tag = skb_vlan_tag_get(skb);
 		vlan_proto = be16_to_cpu(skb->vlan_proto);
+		if (vlan_proto == ETH_P_8021AD)
+			qpn_vlan.ins_vlan = MLX4_WQE_CTRL_INS_SVLAN;
+		else if (vlan_proto == ETH_P_8021Q)
+			qpn_vlan.ins_vlan = MLX4_WQE_CTRL_INS_CVLAN;
+		else
+			qpn_vlan.ins_vlan = 0;
+		bf_ok = false;
 	}
 
 	netdev_txq_bql_enqueue_prefetchw(ring->tx_queue);
@@ -771,6 +836,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	else {
 		tx_desc = (struct mlx4_en_tx_desc *) ring->bounce_buf;
 		bounce = true;
+		bf_ok = false;
 	}
 
 	/* Save skb in tx_info ring */
@@ -946,60 +1012,15 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	real_size = (real_size / 16) & 0x3f;
 
-	if (ring->bf_enabled && desc_size <= MAX_BF && !bounce &&
-	    !skb_vlan_tag_present(skb) && send_doorbell) {
-		tx_desc->ctrl.bf_qpn = ring->doorbell_qpn |
-				       cpu_to_be32(real_size);
-
-		op_own |= htonl((bf_index & 0xffff) << 8);
-		/* Ensure new descriptor hits memory
-		 * before setting ownership of this descriptor to HW
-		 */
-		dma_wmb();
-		tx_desc->ctrl.owner_opcode = op_own;
-
-		wmb();
-
-		mlx4_bf_copy(ring->bf.reg + ring->bf.offset, &tx_desc->ctrl,
-			     desc_size);
-
-		wmb();
-
-		ring->bf.offset ^= ring->bf.buf_size;
-	} else {
-		tx_desc->ctrl.vlan_tag = cpu_to_be16(vlan_tag);
-		if (vlan_proto == ETH_P_8021AD)
-			tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_SVLAN;
-		else if (vlan_proto == ETH_P_8021Q)
-			tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_CVLAN;
-		else
-			tx_desc->ctrl.ins_vlan = 0;
+	bf_ok &= desc_size <= MAX_BF && send_doorbell;
 
-		tx_desc->ctrl.fence_size = real_size;
+	if (bf_ok)
+		qpn_vlan.bf_qpn = ring->doorbell_qpn | cpu_to_be32(real_size);
+	else
+		qpn_vlan.fence_size = real_size;
 
-		/* Ensure new descriptor hits memory
-		 * before setting ownership of this descriptor to HW
-		 */
-		dma_wmb();
-		tx_desc->ctrl.owner_opcode = op_own;
-		if (send_doorbell) {
-			wmb();
-			/* Since there is no iowrite*_native() that writes the
-			 * value as is, without byteswapping - using the one
-			 * the doesn't do byteswapping in the relevant arch
-			 * endianness.
-			 */
-#if defined(__LITTLE_ENDIAN)
-			iowrite32(
-#else
-			iowrite32be(
-#endif
-				  ring->doorbell_qpn,
-				  ring->bf.uar->map + MLX4_SEND_DOORBELL);
-		} else {
-			ring->xmit_more++;
-		}
-	}
+	mlx4_en_tx_write_desc(ring, tx_desc, qpn_vlan, desc_size, bf_index,
+			      op_own, bf_ok, send_doorbell);
 
 	if (unlikely(stop_queue)) {
 		/* If queue was emptied after the if (stop_queue) , and before
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 587cdf9..deaa221 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -291,16 +291,18 @@ enum {
 	MLX4_WQE_CTRL_FORCE_LOOPBACK	= 1 << 0,
 };
 
+union mlx4_wqe_qpn_vlan {
+	struct {
+		__be16	vlan_tag;
+		u8	ins_vlan;
+		u8	fence_size;
+	};
+	__be32		bf_qpn;
+};
+
 struct mlx4_wqe_ctrl_seg {
 	__be32			owner_opcode;
-	union {
-		struct {
-			__be16			vlan_tag;
-			u8			ins_vlan;
-			u8			fence_size;
-		};
-		__be32			bf_qpn;
-	};
+	union mlx4_wqe_qpn_vlan	qpn_vlan;
 	/*
 	 * High 24 bits are SRC remote buffer; low 8 bits are flags:
 	 * [7]   SO (strong ordering)
-- 
2.8.2
