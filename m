From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 06/10] IB/mlx5: Add extended atomic support
Date: Wed, 13 Aug 2014 14:39:07 +0300
Message-ID: <1407929951-16362-7-git-send-email-eli@mellanox.com>
References: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, rdma@vger.kernel.org, amirv@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: roland@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:46134 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbaHMLjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 07:39:48 -0400
Received: by mail-wi0-f173.google.com with SMTP id f8so7262218wiw.0
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 04:39:46 -0700 (PDT)
In-Reply-To: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the required functionality and publish capabilities.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c              | 44 +++++++++++++++++++-
 drivers/infiniband/hw/mlx5/qp.c                | 26 ++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/fw.c   | 51 ++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 21 +++-------
 include/linux/mlx5/device.h                    |  4 +-
 include/linux/mlx5/driver.h                    | 56 ++++++++++++++++++++++----
 6 files changed, 172 insertions(+), 30 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 362d024016ee..0cc07d521ab5 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -151,6 +151,47 @@ static void free_comp_eqs(struct mlx5_ib_dev *dev)
 	spin_unlock(&table->lock);
 }
 
+static void update_atomic_caps(struct mlx5_caps	*caps,
+			       struct ib_device_attr *props)
+{
+	struct mlx5_atomic_caps *atom = &caps->atom;
+	unsigned long last;
+	unsigned long arg;
+	int tmp;
+
+	tmp = MLX5_ATOMIC_OPS_CMP_SWAP | MLX5_ATOMIC_OPS_FETCH_ADD;
+	if (((atom->atomic_ops & tmp) == tmp) && (atom->atomic_sizes_qp & 8)) {
+		if (atom->requestor_endianess)
+			props->atomic_cap = IB_ATOMIC_HCA;
+		else
+			props->atomic_cap = IB_ATOMIC_HCA_REPLY_BE;
+	} else {
+		props->atomic_cap = IB_ATOMIC_NONE;
+	}
+
+	tmp = MLX5_ATOMIC_OPS_MASKED_CMP_SWAP | MLX5_ATOMIC_OPS_MASKED_FETCH_ADD;
+	if (((atom->atomic_ops & tmp) == tmp)) {
+		if (atom->requestor_endianess)
+			props->masked_atomic_cap = IB_ATOMIC_HCA;
+		else
+			props->masked_atomic_cap = IB_ATOMIC_HCA_REPLY_BE;
+	} else {
+		props->masked_atomic_cap = IB_ATOMIC_NONE;
+	}
+	if ((props->atomic_cap != IB_ATOMIC_NONE) ||
+	    (props->masked_atomic_cap != IB_ATOMIC_HCA)) {
+		props->log_atomic_arg_sizes = caps->atom.atomic_sizes_qp;
+		props->max_fa_bit_boundary = 64;
+		arg = (unsigned long)props->log_atomic_arg_sizes;
+		last = find_last_bit(&arg, sizeof(arg));
+		props->log_max_atomic_inline = min_t(unsigned long, last, 6);
+	} else {
+		props->log_atomic_arg_sizes = 0;
+		props->max_fa_bit_boundary = 0;
+		props->log_max_atomic_inline = 0;
+	}
+}
+
 static int query_device(struct ib_device *ibdev,
 			struct ib_device_attr *props)
 {
@@ -235,8 +276,7 @@ static int query_device(struct ib_device *ibdev,
 	props->max_srq_sge	   = max_rq_sg - 1;
 	props->max_fast_reg_page_list_len = (unsigned int)-1;
 	props->local_ca_ack_delay  = gen->local_ca_ack_delay;
-	props->atomic_cap	   = IB_ATOMIC_NONE;
-	props->masked_atomic_cap   = IB_ATOMIC_NONE;
+	update_atomic_caps(&dev->mdev->caps, props);
 	props->max_pkeys	   = be16_to_cpup((__be16 *)(out_mad->data + 28));
 	props->max_mcast_grp	   = 1 << gen->log_max_mcg;
 	props->max_mcast_qp_attach = gen->max_qp_mcg;
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index a5192336efd7..4a5a39766765 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -1244,7 +1244,27 @@ int mlx5_ib_destroy_qp(struct ib_qp *qp)
 	return 0;
 }
 
-static __be32 to_mlx5_access_flags(struct mlx5_ib_qp *qp, const struct ib_qp_attr *attr,
+static u32 atomic_mode_qp(struct mlx5_ib_dev *dev)
+{
+	struct mlx5_atomic_caps *acaps = &dev->mdev->caps.atom;
+	unsigned long mask;
+	unsigned long tmp;
+
+	mask = acaps->atomic_sizes_qp & acaps->atomic_sizes_dc;
+
+	tmp = find_last_bit(&mask, 8 * sizeof(mask));
+	if (tmp < 2)
+		return MLX5_ATOMIC_MODE_NONE;
+
+	if (tmp == 2)
+		return MLX5_ATOMIC_MODE_CX;
+
+	return tmp << MLX5_ATOMIC_MODE_OFF;
+}
+
+static __be32 to_mlx5_access_flags(struct mlx5_ib_dev *dev,
+				   struct mlx5_ib_qp *qp,
+				   const struct ib_qp_attr *attr,
 				   int attr_mask)
 {
 	u32 hw_access_flags = 0;
@@ -1267,7 +1287,7 @@ static __be32 to_mlx5_access_flags(struct mlx5_ib_qp *qp, const struct ib_qp_att
 	if (access_flags & IB_ACCESS_REMOTE_READ)
 		hw_access_flags |= MLX5_QP_BIT_RRE;
 	if (access_flags & IB_ACCESS_REMOTE_ATOMIC)
-		hw_access_flags |= (MLX5_QP_BIT_RAE | MLX5_ATOMIC_MODE_CX);
+		hw_access_flags |= (MLX5_QP_BIT_RAE | atomic_mode_qp(dev));
 	if (access_flags & IB_ACCESS_REMOTE_WRITE)
 		hw_access_flags |= MLX5_QP_BIT_RWE;
 
@@ -1610,7 +1630,7 @@ static int __mlx5_ib_modify_qp(struct ib_qp *ibqp,
 	}
 
 	if (attr_mask & (IB_QP_ACCESS_FLAGS | IB_QP_MAX_DEST_RD_ATOMIC))
-		context->params2 |= to_mlx5_access_flags(qp, attr, attr_mask);
+		context->params2 |= to_mlx5_access_flags(dev, qp, attr, attr_mask);
 
 	if (attr_mask & IB_QP_MIN_RNR_TIMER)
 		context->rnr_nextrecvpsn |= cpu_to_be32(attr->min_rnr_timer << 24);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fw.c b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
index 087c4c797deb..b1d2d7a44b6b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
@@ -33,6 +33,7 @@
 #include <linux/mlx5/driver.h>
 #include <linux/mlx5/cmd.h>
 #include <linux/module.h>
+#include <linux/mlx5/mlx5_ifc.h>
 #include "mlx5_core.h"
 
 int mlx5_cmd_query_adapter(struct mlx5_core_dev *dev)
@@ -64,9 +65,57 @@ out_out:
 	return err;
 }
 
+static int handle_atomic_caps(struct mlx5_core_dev *dev,
+			      struct mlx5_caps *caps)
+{
+	u16 opmod = HCA_CAP_OPMOD_ATOMIC | HCA_CAP_OPMOD_GET_CUR;
+	u8 in[MLX5_ST_SZ_BYTES(query_hca_cap_in)];
+	int out_sz = MLX5_ST_SZ_BYTES(query_hca_cap_out);
+	void *cap_ptr;
+	void *out;
+	int err;
+
+	memset(in, 0, sizeof(in));
+	out = kzalloc(out_sz, GFP_KERNEL);
+	if (!out)
+		return -ENOMEM;
+
+	MLX5_SET(query_hca_cap_in, in, opcode, MLX5_CMD_OP_QUERY_HCA_CAP);
+	MLX5_SET(query_hca_cap_in, in, op_mod, opmod);
+	err = mlx5_cmd_exec(dev, in, sizeof(in), out, out_sz);
+	if (err)
+		goto query_ex;
+
+	err = mlx5_cmd_status_to_err_v2(out);
+	if (err) {
+		mlx5_core_warn(dev, "query atomic caps failed, %d\n", err);
+		goto query_ex;
+	}
+	mlx5_core_dbg(dev, "%s\n", caps_opmod_str(opmod));
+	cap_ptr = MLX5_ADDR_OF(query_hca_cap_out, out, capability_struct);
+	caps->atom.requestor_endianess = MLX5_GET_PR(atomic_cap, cap_ptr, atomic_req_endianess);
+	caps->atom.atomic_ops = MLX5_GET_PR(atomic_cap, cap_ptr, atomic_operations);
+	caps->atom.atomic_sizes_qp = MLX5_GET_PR(atomic_cap, cap_ptr, atomic_size_qp);
+	caps->atom.atomic_sizes_dc = MLX5_GET_PR(atomic_cap, cap_ptr, atomic_size_dc);
+
+query_ex:
+	kfree(out);
+	return err;
+}
+
 int mlx5_cmd_query_hca_cap(struct mlx5_core_dev *dev, struct mlx5_caps *caps)
 {
-	return mlx5_core_get_caps(dev, caps, HCA_CAP_OPMOD_GET_CUR);
+	int err;
+
+	err = mlx5_core_get_caps(dev, caps,
+				 HCA_CAP_OPMOD_GET_CUR | HCA_CAP_OPMOD_GENERAL);
+	if (err)
+		return err;
+
+	if (caps->gen.flags & MLX5_DEV_CAP_FLAG_ATOMIC)
+		err = handle_atomic_caps(dev, caps);
+
+	return err;
 }
 
 int mlx5_cmd_init_hca(struct mlx5_core_dev *dev)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 6c9902c13c30..7c0cdc452c26 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -323,18 +323,6 @@ static void fw2drv_caps(struct mlx5_caps *caps, void *out)
 	gen->log_uar_page_sz = MLX5_GET_PR(cmd_hca_cap, out, log_uar_page_sz);
 }
 
-static const char *caps_opmod_str(u16 opmod)
-{
-	switch (opmod) {
-	case HCA_CAP_OPMOD_GET_MAX:
-		return "GET_MAX";
-	case HCA_CAP_OPMOD_GET_CUR:
-		return "GET_CUR";
-	default:
-		return "Invalid";
-	}
-}
-
 int mlx5_core_get_caps(struct mlx5_core_dev *dev, struct mlx5_caps *caps,
 		       u16 opmod)
 {
@@ -356,7 +344,8 @@ int mlx5_core_get_caps(struct mlx5_core_dev *dev, struct mlx5_caps *caps,
 
 	err = mlx5_cmd_status_to_err_v2(out);
 	if (err) {
-		mlx5_core_warn(dev, "query max hca cap failed, %d\n", err);
+		mlx5_core_warn(dev, "query %s hca caps failed, %d\n",
+			       caps_opmod_str(opmod), err);
 		goto query_ex;
 	}
 	mlx5_core_dbg(dev, "%s\n", caps_opmod_str(opmod));
@@ -405,11 +394,13 @@ static int handle_hca_cap(struct mlx5_core_dev *dev)
 	if (!cur_caps)
 		goto query_ex;
 
-	err = mlx5_core_get_caps(dev, max_caps, HCA_CAP_OPMOD_GET_MAX);
+	err = mlx5_core_get_caps(dev, max_caps,
+				 HCA_CAP_OPMOD_GET_MAX | HCA_CAP_OPMOD_GENERAL);
 	if (err)
 		goto query_ex;
 
-	err = mlx5_core_get_caps(dev, cur_caps, HCA_CAP_OPMOD_GET_CUR);
+	err = mlx5_core_get_caps(dev, cur_caps,
+				 HCA_CAP_OPMOD_GET_CUR | HCA_CAP_OPMOD_GENERAL);
 	if (err)
 		goto query_ex;
 
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index dfe0f761cb8d..c7b09757bead 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -254,12 +254,12 @@ enum {
 	MLX5_DEV_CAP_FLAG_BAD_PKEY_CNTR	= 1LL <<  8,
 	MLX5_DEV_CAP_FLAG_BAD_QKEY_CNTR	= 1LL <<  9,
 	MLX5_DEV_CAP_FLAG_APM		= 1LL << 17,
-	MLX5_DEV_CAP_FLAG_ATOMIC	= 1LL << 18,
 	MLX5_DEV_CAP_FLAG_BLOCK_MCAST	= 1LL << 23,
 	MLX5_DEV_CAP_FLAG_ON_DMND_PG	= 1LL << 24,
 	MLX5_DEV_CAP_FLAG_CQ_MODER	= 1LL << 29,
 	MLX5_DEV_CAP_FLAG_RESIZE_CQ	= 1LL << 30,
 	MLX5_DEV_CAP_FLAG_RESIZE_SRQ	= 1LL << 32,
+	MLX5_DEV_CAP_FLAG_ATOMIC	= 1LL << 33,
 	MLX5_DEV_CAP_FLAG_DCT		= 1LL << 37,
 	MLX5_DEV_CAP_FLAG_REMOTE_FENCE	= 1LL << 38,
 	MLX5_DEV_CAP_FLAG_TLP_HINTS	= 1LL << 39,
@@ -325,6 +325,8 @@ enum {
 enum {
 	HCA_CAP_OPMOD_GET_MAX	= 0,
 	HCA_CAP_OPMOD_GET_CUR	= 1,
+	HCA_CAP_OPMOD_GENERAL	= 0 << 1,
+	HCA_CAP_OPMOD_ATOMIC	= 3 << 1,
 };
 
 struct mlx5_inbox_hdr {
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 7f88f5e2e6e4..d735b45c18d7 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -88,14 +88,23 @@ enum {
 };
 
 enum {
-	MLX5_ATOMIC_MODE_IB_COMP	= 1 << 16,
-	MLX5_ATOMIC_MODE_CX		= 2 << 16,
-	MLX5_ATOMIC_MODE_8B		= 3 << 16,
-	MLX5_ATOMIC_MODE_16B		= 4 << 16,
-	MLX5_ATOMIC_MODE_32B		= 5 << 16,
-	MLX5_ATOMIC_MODE_64B		= 6 << 16,
-	MLX5_ATOMIC_MODE_128B		= 7 << 16,
-	MLX5_ATOMIC_MODE_256B		= 8 << 16,
+	MLX5_ATOMIC_MODE_OFF		= 16,
+	MLX5_ATOMIC_MODE_NONE		= 0 << MLX5_ATOMIC_MODE_OFF,
+	MLX5_ATOMIC_MODE_IB_COMP	= 1 << MLX5_ATOMIC_MODE_OFF,
+	MLX5_ATOMIC_MODE_CX		= 2 << MLX5_ATOMIC_MODE_OFF,
+	MLX5_ATOMIC_MODE_8B		= 3 << MLX5_ATOMIC_MODE_OFF,
+	MLX5_ATOMIC_MODE_16B		= 4 << MLX5_ATOMIC_MODE_OFF,
+	MLX5_ATOMIC_MODE_32B		= 5 << MLX5_ATOMIC_MODE_OFF,
+	MLX5_ATOMIC_MODE_64B		= 6 << MLX5_ATOMIC_MODE_OFF,
+	MLX5_ATOMIC_MODE_128B		= 7 << MLX5_ATOMIC_MODE_OFF,
+	MLX5_ATOMIC_MODE_256B		= 8 << MLX5_ATOMIC_MODE_OFF,
+};
+
+enum {
+	MLX5_ATOMIC_OPS_CMP_SWAP		= 1 << 0,
+	MLX5_ATOMIC_OPS_FETCH_ADD		= 1 << 1,
+	MLX5_ATOMIC_OPS_MASKED_CMP_SWAP		= 1 << 2,
+	MLX5_ATOMIC_OPS_MASKED_FETCH_ADD	= 1 << 3,
 };
 
 enum {
@@ -381,8 +390,16 @@ struct mlx5_general_caps {
 	u16	log_uar_page_sz;
 };
 
+struct mlx5_atomic_caps {
+	int	requestor_endianess;
+	u16	atomic_ops;
+	u16	atomic_sizes_qp;
+	u16	atomic_sizes_dc;
+};
+
 struct mlx5_caps {
 	struct mlx5_general_caps gen;
+	struct mlx5_atomic_caps atom;
 };
 
 struct mlx5_cmd_mailbox {
@@ -856,4 +873,27 @@ struct mlx5_profile {
 	} mr_cache[MAX_MR_CACHE_ENTRIES];
 };
 
+static const inline char *caps_opmod_str(u16 opmod)
+{
+	if (opmod & 1) {
+		switch (opmod & 0xfffe) {
+		case HCA_CAP_OPMOD_GENERAL:
+			return "CUR GENERAL";
+		case HCA_CAP_OPMOD_ATOMIC:
+			return "CUR ATOMIC";
+		default:
+			return "Invalid";
+		}
+	} else {
+		switch (opmod & 0xfffe) {
+		case HCA_CAP_OPMOD_GENERAL:
+			return "MAX GENERAL";
+		case HCA_CAP_OPMOD_ATOMIC:
+			return "MAX ATOMIC";
+		default:
+			return "Invalid";
+		}
+	}
+}
+
 #endif /* MLX5_DRIVER_H */
-- 
1.9.3
