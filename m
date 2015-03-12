From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 2/3] net/mlx4_core: Add basic support for QP max-rate limiting
Date: Thu, 12 Mar 2015 10:53:24 +0200
Message-ID: <1426150405-7904-3-git-send-email-ogerlitz@mellanox.com>
References: <1426150405-7904-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:48005 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752561AbbCLIxi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 04:53:38 -0400
In-Reply-To: <1426150405-7904-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the low-level device commands and definitions used for QP max-rate limiting.

This is done through the following elements:

  - read rate-limit device caps in QUERY_DEV_CAP: number of different
    rates and the min/max rates in Kbs/Mbs/Gbs units

  - enhance the QP context struct to contain rate limit units and value

  - allow to do run time rate-limit setting to QPs through the
    update-qp firmware command

  - QP rate-limiting is disallowed for VFs

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c            |   33 +++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/fw.h            |    1 +
 drivers/net/ethernet/mellanox/mlx4/main.c          |    2 +
 drivers/net/ethernet/mellanox/mlx4/qp.c            |    5 +++
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    6 +++-
 include/linux/mlx4/device.h                        |   17 ++++++++++
 include/linux/mlx4/qp.h                            |   14 ++++++--
 7 files changed, 72 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 242bcee..4a471f5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -144,7 +144,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[19] = "Performance optimized for limited rule configuration flow steering support",
 		[20] = "Recoverable error events support",
 		[21] = "Port Remap support",
-		[22] = "QCN support"
+		[22] = "QCN support",
+		[23] = "QP rate limiting support"
 	};
 	int i;
 
@@ -697,6 +698,10 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_MAD_DEMUX_OFFSET		0xb0
 #define QUERY_DEV_CAP_DMFS_HIGH_RATE_QPN_BASE_OFFSET	0xa8
 #define QUERY_DEV_CAP_DMFS_HIGH_RATE_QPN_RANGE_OFFSET	0xac
+#define QUERY_DEV_CAP_QP_RATE_LIMIT_NUM_OFFSET	0xcc
+#define QUERY_DEV_CAP_QP_RATE_LIMIT_MAX_OFFSET	0xd0
+#define QUERY_DEV_CAP_QP_RATE_LIMIT_MIN_OFFSET	0xd2
+
 
 	dev_cap->flags2 = 0;
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
@@ -904,6 +909,18 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		 QUERY_DEV_CAP_DMFS_HIGH_RATE_QPN_RANGE_OFFSET);
 	dev_cap->dmfs_high_rate_qpn_range &= MGM_QPN_MASK;
 
+	MLX4_GET(size, outbox, QUERY_DEV_CAP_QP_RATE_LIMIT_NUM_OFFSET);
+	dev_cap->rl_caps.num_rates = size;
+	if (dev_cap->rl_caps.num_rates) {
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_QP_RATE_LIMIT;
+		MLX4_GET(size, outbox, QUERY_DEV_CAP_QP_RATE_LIMIT_MAX_OFFSET);
+		dev_cap->rl_caps.max_val  = size & 0xfff;
+		dev_cap->rl_caps.max_unit = size >> 14;
+		MLX4_GET(size, outbox, QUERY_DEV_CAP_QP_RATE_LIMIT_MIN_OFFSET);
+		dev_cap->rl_caps.min_val  = size & 0xfff;
+		dev_cap->rl_caps.min_unit = size >> 14;
+	}
+
 	MLX4_GET(field32, outbox, QUERY_DEV_CAP_EXT_2_FLAGS_OFFSET);
 	if (field32 & (1 << 16))
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_UPDATE_QP;
@@ -979,6 +996,15 @@ void mlx4_dev_cap_dump(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		 dev_cap->dmfs_high_rate_qpn_base);
 	mlx4_dbg(dev, "DMFS high rate steer QPn range: %d\n",
 		 dev_cap->dmfs_high_rate_qpn_range);
+
+	if (dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_QP_RATE_LIMIT) {
+		struct mlx4_rate_limit_caps *rl_caps = &dev_cap->rl_caps;
+
+		mlx4_dbg(dev, "QP Rate-Limit: #rates %d, unit/val max %d/%d, min %d/%d\n",
+			 rl_caps->num_rates, rl_caps->max_unit, rl_caps->max_val,
+			 rl_caps->min_unit, rl_caps->min_val);
+	}
+
 	dump_dev_cap_flags(dev, dev_cap->flags);
 	dump_dev_cap_flags2(dev, dev_cap->flags2);
 }
@@ -1075,6 +1101,7 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	u64	flags;
 	int	err = 0;
 	u8	field;
+	u16	field16;
 	u32	bmme_flags, field32;
 	int	real_port;
 	int	slave_port;
@@ -1158,6 +1185,10 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	field &= 0xfe;
 	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_ECN_QCN_VER_OFFSET);
 
+	/* turn off QP max-rate limiting for guests */
+	field16 = 0;
+	MLX4_PUT(outbox->buf, field16, QUERY_DEV_CAP_QP_RATE_LIMIT_NUM_OFFSET);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index f44f7f6..863655b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -127,6 +127,7 @@ struct mlx4_dev_cap {
 	u32 max_counters;
 	u32 dmfs_high_rate_qpn_base;
 	u32 dmfs_high_rate_qpn_range;
+	struct mlx4_rate_limit_caps rl_caps;
 	struct mlx4_port_cap port_cap[MLX4_MAX_PORTS + 1];
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 7e48722..43aa767 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -489,6 +489,8 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		dev->caps.dmfs_high_rate_qpn_range = MLX4_A0_STEERING_TABLE_SIZE;
 	}
 
+	dev->caps.rl_caps = dev_cap->rl_caps;
+
 	dev->caps.reserved_qps_cnt[MLX4_QP_REGION_RSS_RAW_ETH] =
 		dev->caps.dmfs_high_rate_qpn_range;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index eda29db..69e4462 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -442,6 +442,11 @@ int mlx4_update_qp(struct mlx4_dev *dev, u32 qpn,
 			cmd->qp_context.param3 |= cpu_to_be32(MLX4_STRIP_VLAN);
 	}
 
+	if (attr & MLX4_UPDATE_QP_RATE_LIMIT) {
+		qp_mask |= 1ULL << MLX4_UPD_QP_MASK_RATE_LIMIT;
+		cmd->qp_context.rate_limit_params = cpu_to_be16((params->rate_unit << 14) | params->rate_val);
+	}
+
 	cmd->primary_addr_path_mask = cpu_to_be64(pri_addr_path_mask);
 	cmd->qp_mask = cpu_to_be64(qp_mask);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index d43e259..c258f86 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2947,8 +2947,12 @@ static int verify_qp_parameters(struct mlx4_dev *dev,
 	qp_type	= (be32_to_cpu(qp_ctx->flags) >> 16) & 0xff;
 	optpar	= be32_to_cpu(*(__be32 *) inbox->buf);
 
-	if (slave != mlx4_master_func_num(dev))
+	if (slave != mlx4_master_func_num(dev)) {
 		qp_ctx->params2 &= ~MLX4_QP_BIT_FPP;
+		/* setting QP rate-limit is disallowed for VFs */
+		if (qp_ctx->rate_limit_params)
+			return -EPERM;
+	}
 
 	switch (qp_type) {
 	case MLX4_QP_ST_RC:
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 1cc5482..4550c67 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -205,6 +205,7 @@ enum {
 	MLX4_DEV_CAP_FLAG2_RECOVERABLE_ERROR_EVENT = 1LL << 20,
 	MLX4_DEV_CAP_FLAG2_PORT_REMAP		= 1LL <<  21,
 	MLX4_DEV_CAP_FLAG2_QCN			= 1LL <<  22,
+	MLX4_DEV_CAP_FLAG2_QP_RATE_LIMIT	= 1LL <<  23
 };
 
 enum {
@@ -450,6 +451,21 @@ enum mlx4_module_id {
 	MLX4_MODULE_ID_QSFP28           = 0x11,
 };
 
+enum { /* rl */
+	MLX4_QP_RATE_LIMIT_NONE		= 0,
+	MLX4_QP_RATE_LIMIT_KBS		= 1,
+	MLX4_QP_RATE_LIMIT_MBS		= 2,
+	MLX4_QP_RATE_LIMIT_GBS		= 3
+};
+
+struct mlx4_rate_limit_caps {
+	u16	num_rates; /* Number of different rates */
+	u8	min_unit;
+	u16	min_val;
+	u8	max_unit;
+	u16	max_val;
+};
+
 static inline u64 mlx4_fw_ver(u64 major, u64 minor, u64 subminor)
 {
 	return (major << 32) | (minor << 16) | subminor;
@@ -565,6 +581,7 @@ struct mlx4_caps {
 	u32			dmfs_high_rate_qpn_base;
 	u32			dmfs_high_rate_qpn_range;
 	u32			vf_caps;
+	struct mlx4_rate_limit_caps rl_caps;
 };
 
 struct mlx4_buf_list {
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 551f854..1023ebe 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -207,14 +207,16 @@ struct mlx4_qp_context {
 	__be32			msn;
 	__be16			rq_wqe_counter;
 	__be16			sq_wqe_counter;
-	u32			reserved3[2];
+	u32			reserved3;
+	__be16			rate_limit_params;
+	__be16			reserved4;
 	__be32			param3;
 	__be32			nummmcpeers_basemkey;
 	u8			log_page_size;
-	u8			reserved4[2];
+	u8			reserved5[2];
 	u8			mtt_base_addr_h;
 	__be32			mtt_base_addr_l;
-	u32			reserved5[10];
+	u32			reserved6[10];
 };
 
 struct mlx4_update_qp_context {
@@ -229,6 +231,7 @@ struct mlx4_update_qp_context {
 enum {
 	MLX4_UPD_QP_MASK_PM_STATE	= 32,
 	MLX4_UPD_QP_MASK_VSD		= 33,
+	MLX4_UPD_QP_MASK_RATE_LIMIT	= 35,
 };
 
 enum {
@@ -428,7 +431,8 @@ struct mlx4_wqe_inline_seg {
 enum mlx4_update_qp_attr {
 	MLX4_UPDATE_QP_SMAC		= 1 << 0,
 	MLX4_UPDATE_QP_VSD		= 1 << 1,
-	MLX4_UPDATE_QP_SUPPORTED_ATTRS	= (1 << 2) - 1
+	MLX4_UPDATE_QP_RATE_LIMIT	= 1 << 2,
+	MLX4_UPDATE_QP_SUPPORTED_ATTRS	= (1 << 3) - 1
 };
 
 enum mlx4_update_qp_params_flags {
@@ -438,6 +442,8 @@ enum mlx4_update_qp_params_flags {
 struct mlx4_update_qp_params {
 	u8	smac_index;
 	u32	flags;
+	u16	rate_unit;
+	u16	rate_val;
 };
 
 int mlx4_update_qp(struct mlx4_dev *dev, u32 qpn,
-- 
1.7.1
