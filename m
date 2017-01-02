From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next V2 10/11] IB/mlx5: Add ODP atomics support
Date: Mon,  2 Jan 2017 11:37:47 +0200
Message-ID: <1483349868-11716-11-git-send-email-saeedm@mellanox.com>
References: <1483349868-11716-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Artemy Kovalyov <artemyko@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34485 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932575AbdABJiY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 04:38:24 -0500
In-Reply-To: <1483349868-11716-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Artemy Kovalyov <artemyko@mellanox.com>

Handle ODP atomic operations. When initiator of RDMA atomic
operation use ODP MR to provide source data handle pagefault properly.

Signed-off-by: Artemy Kovalyov <artemyko@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/odp.c | 88 +++++++++++++++++++++++-----------------
 include/linux/mlx5/mlx5_ifc.h    |  2 +-
 include/linux/mlx5/qp.h          | 18 ++++++++
 3 files changed, 69 insertions(+), 39 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/odp.c b/drivers/infiniband/hw/mlx5/odp.c
index 26f96c7..971b288 100644
--- a/drivers/infiniband/hw/mlx5/odp.c
+++ b/drivers/infiniband/hw/mlx5/odp.c
@@ -144,6 +144,9 @@ void mlx5_ib_internal_fill_odp_caps(struct mlx5_ib_dev *dev)
 	if (MLX5_CAP_ODP(dev->mdev, rc_odp_caps.read))
 		caps->per_transport_caps.rc_odp_caps |= IB_ODP_SUPPORT_READ;
 
+	if (MLX5_CAP_ODP(dev->mdev, rc_odp_caps.atomic))
+		caps->per_transport_caps.rc_odp_caps |= IB_ODP_SUPPORT_ATOMIC;
+
 	return;
 }
 
@@ -386,6 +389,17 @@ static int pagefault_data_segments(struct mlx5_ib_dev *dev,
 	return ret < 0 ? ret : npages;
 }
 
+static const u32 mlx5_ib_odp_opcode_cap[] = {
+	[MLX5_OPCODE_SEND]	       = IB_ODP_SUPPORT_SEND,
+	[MLX5_OPCODE_SEND_IMM]	       = IB_ODP_SUPPORT_SEND,
+	[MLX5_OPCODE_SEND_INVAL]       = IB_ODP_SUPPORT_SEND,
+	[MLX5_OPCODE_RDMA_WRITE]       = IB_ODP_SUPPORT_WRITE,
+	[MLX5_OPCODE_RDMA_WRITE_IMM]   = IB_ODP_SUPPORT_WRITE,
+	[MLX5_OPCODE_RDMA_READ]	       = IB_ODP_SUPPORT_READ,
+	[MLX5_OPCODE_ATOMIC_CS]	       = IB_ODP_SUPPORT_ATOMIC,
+	[MLX5_OPCODE_ATOMIC_FA]	       = IB_ODP_SUPPORT_ATOMIC,
+};
+
 /*
  * Parse initiator WQE. Advances the wqe pointer to point at the
  * scatter-gather list, and set wqe_end to the end of the WQE.
@@ -396,6 +410,8 @@ static int mlx5_ib_mr_initiator_pfault_handler(
 {
 	struct mlx5_wqe_ctrl_seg *ctrl = *wqe;
 	u16 wqe_index = pfault->wqe.wqe_index;
+	u32 transport_caps;
+	struct mlx5_base_av *av;
 	unsigned ds, opcode;
 #if defined(DEBUG)
 	u32 ctrl_wqe_index, ctrl_qpn;
@@ -441,53 +457,49 @@ static int mlx5_ib_mr_initiator_pfault_handler(
 
 	opcode = be32_to_cpu(ctrl->opmod_idx_opcode) &
 		 MLX5_WQE_CTRL_OPCODE_MASK;
+
 	switch (qp->ibqp.qp_type) {
 	case IB_QPT_RC:
-		switch (opcode) {
-		case MLX5_OPCODE_SEND:
-		case MLX5_OPCODE_SEND_IMM:
-		case MLX5_OPCODE_SEND_INVAL:
-			if (!(dev->odp_caps.per_transport_caps.rc_odp_caps &
-			      IB_ODP_SUPPORT_SEND))
-				goto invalid_transport_or_opcode;
-			break;
-		case MLX5_OPCODE_RDMA_WRITE:
-		case MLX5_OPCODE_RDMA_WRITE_IMM:
-			if (!(dev->odp_caps.per_transport_caps.rc_odp_caps &
-			      IB_ODP_SUPPORT_WRITE))
-				goto invalid_transport_or_opcode;
-			*wqe += sizeof(struct mlx5_wqe_raddr_seg);
-			break;
-		case MLX5_OPCODE_RDMA_READ:
-			if (!(dev->odp_caps.per_transport_caps.rc_odp_caps &
-			      IB_ODP_SUPPORT_READ))
-				goto invalid_transport_or_opcode;
-			*wqe += sizeof(struct mlx5_wqe_raddr_seg);
-			break;
-		default:
-			goto invalid_transport_or_opcode;
-		}
+		transport_caps = dev->odp_caps.per_transport_caps.rc_odp_caps;
 		break;
 	case IB_QPT_UD:
-		switch (opcode) {
-		case MLX5_OPCODE_SEND:
-		case MLX5_OPCODE_SEND_IMM:
-			if (!(dev->odp_caps.per_transport_caps.ud_odp_caps &
-			      IB_ODP_SUPPORT_SEND))
-				goto invalid_transport_or_opcode;
-			*wqe += sizeof(struct mlx5_wqe_datagram_seg);
-			break;
-		default:
-			goto invalid_transport_or_opcode;
-		}
+		transport_caps = dev->odp_caps.per_transport_caps.ud_odp_caps;
 		break;
 	default:
-invalid_transport_or_opcode:
-		mlx5_ib_err(dev, "ODP fault on QP of an unsupported opcode or transport. transport: 0x%x opcode: 0x%x.\n",
-			    qp->ibqp.qp_type, opcode);
+		mlx5_ib_err(dev, "ODP fault on QP of an unsupported transport 0x%x\n",
+			    qp->ibqp.qp_type);
+		return -EFAULT;
+	}
+
+	if (unlikely(opcode >= sizeof(mlx5_ib_odp_opcode_cap) /
+	    sizeof(mlx5_ib_odp_opcode_cap[0]) ||
+	    !(transport_caps & mlx5_ib_odp_opcode_cap[opcode]))) {
+		mlx5_ib_err(dev, "ODP fault on QP of an unsupported opcode 0x%x\n",
+			    opcode);
 		return -EFAULT;
 	}
 
+	if (qp->ibqp.qp_type != IB_QPT_RC) {
+		av = *wqe;
+		if (av->dqp_dct & be32_to_cpu(MLX5_WQE_AV_EXT))
+			*wqe += sizeof(struct mlx5_av);
+		else
+			*wqe += sizeof(struct mlx5_base_av);
+	}
+
+	switch (opcode) {
+	case MLX5_OPCODE_RDMA_WRITE:
+	case MLX5_OPCODE_RDMA_WRITE_IMM:
+	case MLX5_OPCODE_RDMA_READ:
+		*wqe += sizeof(struct mlx5_wqe_raddr_seg);
+		break;
+	case MLX5_OPCODE_ATOMIC_CS:
+	case MLX5_OPCODE_ATOMIC_FA:
+		*wqe += sizeof(struct mlx5_wqe_raddr_seg);
+		*wqe += sizeof(struct mlx5_wqe_atomic_seg);
+		break;
+	}
+
 	return 0;
 }
 
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 608dc98..15f8967 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -328,7 +328,7 @@ struct mlx5_ifc_odp_per_transport_service_cap_bits {
 	u8         receive[0x1];
 	u8         write[0x1];
 	u8         read[0x1];
-	u8         reserved_at_4[0x1];
+	u8         atomic[0x1];
 	u8         srq_receive[0x1];
 	u8         reserved_at_6[0x1a];
 };
diff --git a/include/linux/mlx5/qp.h b/include/linux/mlx5/qp.h
index 9ed775f..219c699 100644
--- a/include/linux/mlx5/qp.h
+++ b/include/linux/mlx5/qp.h
@@ -212,6 +212,7 @@ struct mlx5_wqe_ctrl_seg {
 #define MLX5_WQE_CTRL_OPCODE_MASK 0xff
 #define MLX5_WQE_CTRL_WQE_INDEX_MASK 0x00ffff00
 #define MLX5_WQE_CTRL_WQE_INDEX_SHIFT 8
+#define MLX5_WQE_AV_EXT 0x80000000
 
 enum {
 	MLX5_ETH_WQE_L3_INNER_CSUM      = 1 << 4,
@@ -242,6 +243,23 @@ struct mlx5_wqe_masked_atomic_seg {
 	__be64			compare_mask;
 };
 
+struct mlx5_base_av {
+	union {
+		struct {
+			__be32	qkey;
+			__be32	reserved;
+		} qkey;
+		__be64	dc_key;
+	} key;
+	__be32	dqp_dct;
+	u8	stat_rate_sl;
+	u8	fl_mlid;
+	union {
+		__be16	rlid;
+		__be16  udp_sport;
+	};
+};
+
 struct mlx5_av {
 	union {
 		struct {
-- 
2.7.4
