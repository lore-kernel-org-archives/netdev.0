From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/3] net/mlx4_core: Enable CQE/EQE stride support
Date: Thu, 18 Sep 2014 11:50:59 +0300
Message-ID: <1411030261-12145-2-git-send-email-ogerlitz@mellanox.com>
References: <1411030261-12145-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:34931 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754819AbaIRIvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 04:51:08 -0400
In-Reply-To: <1411030261-12145-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

This feature is intended for archs having cache line larger then 64B.

Since our CQE/EQEs are generally 64B in those systems, HW will write
twice to the same cache line consecutively, causing pipe locks due to
he hazard prevention mechanism. For elements in a cyclic buffer, writes
are consecutive, so entries smaller than a cache line should be
avoided, especially if they are written at a high rate.

Reduce consecutive writes to same cache line in CQs/EQs, by allowing the
driver to increase the distance between entries so that each will reside
in a different cache line. Until the introduction of this feature, there
were two types of CQE/EQE:

1. 32B stride and context in the [0-31] segment
2. 64B stride and context in the [32-63] segment

This feature introduces two additional types:

3. 128B stride and context in the [0-31] segment (128B cache line)
4. 256B stride and context in the [0-31] segment (256B cache line)

Modify the mlx4_core driver to query the device for the CQE/EQE cache
line stride capability and to enable that capability when the host
cache line size is larger than 64 bytes (supported cache lines are
128B and 256B).

The mlx4 IB driver and libmlx4 need not be aware of this change. The PF
context behaviour is changed to require this change in VF drivers
running on such archs.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c   |   38 +++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/fw.h   |    2 +
 drivers/net/ethernet/mellanox/mlx4/main.c |   61 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |    3 +
 include/linux/mlx4/device.h               |   11 ++++-
 5 files changed, 108 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 494753e..13b2e4a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -137,7 +137,9 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[8] = "Dynamic QP updates support",
 		[9] = "Device managed flow steering IPoIB support",
 		[10] = "TCP/IP offloads/flow-steering for VXLAN support",
-		[11] = "MAD DEMUX (Secure-Host) support"
+		[11] = "MAD DEMUX (Secure-Host) support",
+		[12] = "Large cache line (>64B) CQE stride support",
+		[13] = "Large cache line (>64B) EQE stride support"
 	};
 	int i;
 
@@ -557,6 +559,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_FLOW_STEERING_IPOIB_OFFSET	0x74
 #define QUERY_DEV_CAP_FLOW_STEERING_RANGE_EN_OFFSET	0x76
 #define QUERY_DEV_CAP_FLOW_STEERING_MAX_QP_OFFSET	0x77
+#define QUERY_DEV_CAP_CQ_EQ_CACHE_LINE_STRIDE	0x7a
 #define QUERY_DEV_CAP_RDMARC_ENTRY_SZ_OFFSET	0x80
 #define QUERY_DEV_CAP_QPC_ENTRY_SZ_OFFSET	0x82
 #define QUERY_DEV_CAP_AUX_ENTRY_SZ_OFFSET	0x84
@@ -733,6 +736,11 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev_cap->max_rq_sg = field;
 	MLX4_GET(size, outbox, QUERY_DEV_CAP_MAX_DESC_SZ_RQ_OFFSET);
 	dev_cap->max_rq_desc_sz = size;
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_CQ_EQ_CACHE_LINE_STRIDE);
+	if (field & (1 << 6))
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_CQE_STRIDE;
+	if (field & (1 << 7))
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_EQE_STRIDE;
 
 	MLX4_GET(dev_cap->bmme_flags, outbox,
 		 QUERY_DEV_CAP_BMME_FLAGS_OFFSET);
@@ -1376,6 +1384,7 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 #define	 INIT_HCA_CQC_BASE_OFFSET	 (INIT_HCA_QPC_OFFSET + 0x30)
 #define	 INIT_HCA_LOG_CQ_OFFSET		 (INIT_HCA_QPC_OFFSET + 0x37)
 #define	 INIT_HCA_EQE_CQE_OFFSETS	 (INIT_HCA_QPC_OFFSET + 0x38)
+#define	 INIT_HCA_EQE_CQE_STRIDE_OFFSET  (INIT_HCA_QPC_OFFSET + 0x3b)
 #define	 INIT_HCA_ALTC_BASE_OFFSET	 (INIT_HCA_QPC_OFFSET + 0x40)
 #define	 INIT_HCA_AUXC_BASE_OFFSET	 (INIT_HCA_QPC_OFFSET + 0x50)
 #define	 INIT_HCA_EQC_BASE_OFFSET	 (INIT_HCA_QPC_OFFSET + 0x60)
@@ -1452,11 +1461,25 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_64B_CQE) {
 		*(inbox + INIT_HCA_EQE_CQE_OFFSETS / 4) |= cpu_to_be32(1 << 30);
 		dev->caps.cqe_size   = 64;
-		dev->caps.userspace_caps |= MLX4_USER_DEV_CAP_64B_CQE;
+		dev->caps.userspace_caps |= MLX4_USER_DEV_CAP_LARGE_CQE;
 	} else {
 		dev->caps.cqe_size   = 32;
 	}
 
+	/* CX3 is capable of extending CQEs\EQEs to strides larger than 64B */
+	if ((dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_EQE_STRIDE) &&
+	    (dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_CQE_STRIDE)) {
+		dev->caps.eqe_size = cache_line_size();
+		dev->caps.cqe_size = cache_line_size();
+		dev->caps.eqe_factor = 0;
+		MLX4_PUT(inbox, (u8)((ilog2(dev->caps.eqe_size) - 5) << 4 |
+				      (ilog2(dev->caps.eqe_size) - 5)),
+			 INIT_HCA_EQE_CQE_STRIDE_OFFSET);
+
+		/* User still need to know to support CQE > 32B */
+		dev->caps.userspace_caps |= MLX4_USER_DEV_CAP_LARGE_CQE;
+	}
+
 	/* QPC/EEC/CQC/EQC/RDMARC attributes */
 
 	MLX4_PUT(inbox, param->qpc_base,      INIT_HCA_QPC_BASE_OFFSET);
@@ -1616,6 +1639,17 @@ int mlx4_QUERY_HCA(struct mlx4_dev *dev,
 	if (byte_field & 0x40) /* 64-bytes cqe enabled */
 		param->dev_cap_enabled |= MLX4_DEV_CAP_64B_CQE_ENABLED;
 
+	/* CX3 is capable of extending CQEs\EQEs to strides larger than 64B */
+	MLX4_GET(byte_field, outbox, INIT_HCA_EQE_CQE_STRIDE_OFFSET);
+	if (byte_field) {
+		param->dev_cap_enabled |= MLX4_DEV_CAP_64B_EQE_ENABLED;
+		param->dev_cap_enabled |= MLX4_DEV_CAP_64B_CQE_ENABLED;
+		param->cqe_size = 1 << ((byte_field &
+					 MLX4_CQE_SIZE_MASK_STRIDE) + 5);
+		param->eqe_size = 1 << (((byte_field &
+					  MLX4_EQE_SIZE_MASK_STRIDE) >> 4) + 5);
+	}
+
 	/* TPT attributes */
 
 	MLX4_GET(param->dmpt_base,  outbox, INIT_HCA_DMPT_BASE_OFFSET);
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 1fce03e..9b835ae 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -178,6 +178,8 @@ struct mlx4_init_hca_param {
 	u8  uar_page_sz; /* log pg sz in 4k chunks */
 	u8  steering_mode; /* for QUERY_HCA */
 	u64 dev_cap_enabled;
+	u16 cqe_size; /* For use only when CQE stride feature enabled */
+	u16 eqe_size; /* For use only when EQE stride feature enabled */
 };
 
 struct mlx4_init_ib_param {
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 7e2d5d5..1f10023 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -104,7 +104,8 @@ module_param(enable_64b_cqe_eqe, bool, 0444);
 MODULE_PARM_DESC(enable_64b_cqe_eqe,
 		 "Enable 64 byte CQEs/EQEs when the FW supports this (default: True)");
 
-#define PF_CONTEXT_BEHAVIOUR_MASK	MLX4_FUNC_CAP_64B_EQE_CQE
+#define PF_CONTEXT_BEHAVIOUR_MASK	(MLX4_FUNC_CAP_64B_EQE_CQE | \
+					 MLX4_FUNC_CAP_EQE_CQE_STRIDE)
 
 static char mlx4_version[] =
 	DRV_NAME ": Mellanox ConnectX core driver v"
@@ -196,6 +197,40 @@ static void mlx4_set_port_mask(struct mlx4_dev *dev)
 		dev->caps.port_mask[i] = dev->caps.port_type[i];
 }
 
+static void mlx4_enable_cqe_eqe_stride(struct mlx4_dev *dev)
+{
+	struct mlx4_caps *dev_cap = &dev->caps;
+
+	/* FW not supporting or cancelled by user */
+	if (!(dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_EQE_STRIDE) ||
+	    !(dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_CQE_STRIDE))
+		return;
+
+	/* Must have 64B CQE_EQE enabled by FW to use bigger stride
+	 * When FW has NCSI it may decide not to report 64B CQE/EQEs
+	 */
+	if (!(dev_cap->flags & MLX4_DEV_CAP_FLAG_64B_EQE) ||
+	    !(dev_cap->flags & MLX4_DEV_CAP_FLAG_64B_CQE)) {
+		dev_cap->flags2 &= ~MLX4_DEV_CAP_FLAG2_CQE_STRIDE;
+		dev_cap->flags2 &= ~MLX4_DEV_CAP_FLAG2_EQE_STRIDE;
+		return;
+	}
+
+	if (cache_line_size() == 128 || cache_line_size() == 256) {
+		mlx4_dbg(dev, "Enabling CQE stride cacheLine supported\n");
+		/* Changing the real data inside CQE size to 32B */
+		dev_cap->flags &= ~MLX4_DEV_CAP_FLAG_64B_CQE;
+		dev_cap->flags &= ~MLX4_DEV_CAP_FLAG_64B_EQE;
+
+		if (mlx4_is_master(dev))
+			dev_cap->function_caps |= MLX4_FUNC_CAP_EQE_CQE_STRIDE;
+	} else {
+		mlx4_dbg(dev, "Disabling CQE stride cacheLine unsupported\n");
+		dev_cap->flags2 &= ~MLX4_DEV_CAP_FLAG2_CQE_STRIDE;
+		dev_cap->flags2 &= ~MLX4_DEV_CAP_FLAG2_EQE_STRIDE;
+	}
+}
+
 static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 {
 	int err;
@@ -390,6 +425,14 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 			dev->caps.flags &= ~MLX4_DEV_CAP_FLAG_64B_CQE;
 			dev->caps.flags &= ~MLX4_DEV_CAP_FLAG_64B_EQE;
 		}
+
+		if (dev_cap->flags2 &
+		    (MLX4_DEV_CAP_FLAG2_CQE_STRIDE |
+		     MLX4_DEV_CAP_FLAG2_EQE_STRIDE)) {
+			mlx4_warn(dev, "Disabling EQE/CQE stride per user request\n");
+			dev_cap->flags2 &= ~MLX4_DEV_CAP_FLAG2_CQE_STRIDE;
+			dev_cap->flags2 &= ~MLX4_DEV_CAP_FLAG2_EQE_STRIDE;
+		}
 	}
 
 	if ((dev->caps.flags &
@@ -397,6 +440,9 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	    mlx4_is_master(dev))
 		dev->caps.function_caps |= MLX4_FUNC_CAP_64B_EQE_CQE;
 
+	if (!mlx4_is_slave(dev))
+		mlx4_enable_cqe_eqe_stride(dev);
+
 	return 0;
 }
 
@@ -724,11 +770,22 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 
 	if (hca_param.dev_cap_enabled & MLX4_DEV_CAP_64B_CQE_ENABLED) {
 		dev->caps.cqe_size   = 64;
-		dev->caps.userspace_caps |= MLX4_USER_DEV_CAP_64B_CQE;
+		dev->caps.userspace_caps |= MLX4_USER_DEV_CAP_LARGE_CQE;
 	} else {
 		dev->caps.cqe_size   = 32;
 	}
 
+	if (hca_param.dev_cap_enabled & MLX4_DEV_CAP_EQE_STRIDE_ENABLED) {
+		dev->caps.eqe_size = hca_param.eqe_size;
+		dev->caps.eqe_factor = 0;
+	}
+
+	if (hca_param.dev_cap_enabled & MLX4_DEV_CAP_CQE_STRIDE_ENABLED) {
+		dev->caps.cqe_size = hca_param.cqe_size;
+		/* User still need to know when CQE > 32B */
+		dev->caps.userspace_caps |= MLX4_USER_DEV_CAP_LARGE_CQE;
+	}
+
 	dev->caps.flags2 &= ~MLX4_DEV_CAP_FLAG2_TS;
 	mlx4_warn(dev, "Timestamping is not supported in slave mode\n");
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index b508c78..de10dbb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -285,6 +285,9 @@ struct mlx4_icm_table {
 #define MLX4_MPT_STATUS_SW		0xF0
 #define MLX4_MPT_STATUS_HW		0x00
 
+#define MLX4_CQE_SIZE_MASK_STRIDE	0x3
+#define MLX4_EQE_SIZE_MASK_STRIDE	0x30
+
 /*
  * Must be packed because mtt_seg is 64 bits but only aligned to 32 bits.
  */
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 1befd8d..7bcefe7 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -185,19 +185,24 @@ enum {
 	MLX4_DEV_CAP_FLAG2_DMFS_IPOIB		= 1LL <<  9,
 	MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS	= 1LL <<  10,
 	MLX4_DEV_CAP_FLAG2_MAD_DEMUX		= 1LL <<  11,
+	MLX4_DEV_CAP_FLAG2_CQE_STRIDE		= 1LL <<  12,
+	MLX4_DEV_CAP_FLAG2_EQE_STRIDE		= 1LL <<  13
 };
 
 enum {
 	MLX4_DEV_CAP_64B_EQE_ENABLED	= 1LL << 0,
-	MLX4_DEV_CAP_64B_CQE_ENABLED	= 1LL << 1
+	MLX4_DEV_CAP_64B_CQE_ENABLED	= 1LL << 1,
+	MLX4_DEV_CAP_CQE_STRIDE_ENABLED	= 1LL << 2,
+	MLX4_DEV_CAP_EQE_STRIDE_ENABLED	= 1LL << 3
 };
 
 enum {
-	MLX4_USER_DEV_CAP_64B_CQE	= 1L << 0
+	MLX4_USER_DEV_CAP_LARGE_CQE	= 1L << 0
 };
 
 enum {
-	MLX4_FUNC_CAP_64B_EQE_CQE	= 1L << 0
+	MLX4_FUNC_CAP_64B_EQE_CQE	= 1L << 0,
+	MLX4_FUNC_CAP_EQE_CQE_STRIDE	= 1L << 1
 };
 
 
-- 
1.7.1
