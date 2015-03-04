From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/3] net/mlx4_core: Add basic elements for QCN
Date: Wed,  4 Mar 2015 14:51:07 +0200
Message-ID: <1425473468-25969-3-git-send-email-ogerlitz@mellanox.com>
References: <1425473468-25969-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:53525 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758974AbbCDMvh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 07:51:37 -0500
In-Reply-To: <1425473468-25969-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shani Michaeli <shanim@mellanox.com>

Add device capability, firmware command opcode and etc prior elements
needed for QCN suppprt. Disable SRIOV VF view/access for QCN is disabled.

While here, remove a redundant offset definition into the
QUERY_DEV_CAP mailbox.

Signed-off-by: Shani Michaeli <shanim@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c |    9 +++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.c  |   13 +++++++++++--
 include/linux/mlx4/cmd.h                 |   13 +++++++++++++
 include/linux/mlx4/device.h              |    3 ++-
 4 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index a681d7c..20b3c7b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1499,6 +1499,15 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.verify = NULL,
 		.wrapper = mlx4_ACCESS_REG_wrapper,
 	},
+	{
+		.opcode = MLX4_CMD_CONGESTION_CTRL_OPCODE,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.encode_slave_id = false,
+		.verify = NULL,
+		.wrapper = mlx4_CMD_EPERM_wrapper,
+	},
 	/* Native multicast commands are not available for guests */
 	{
 		.opcode = MLX4_CMD_QP_ATTACH,
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 5a21e5d..242bcee 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -143,7 +143,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[18] = "More than 80 VFs support",
 		[19] = "Performance optimized for limited rule configuration flow steering support",
 		[20] = "Recoverable error events support",
-		[21] = "Port Remap support"
+		[21] = "Port Remap support",
+		[22] = "QCN support"
 	};
 	int i;
 
@@ -675,7 +676,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_FLOW_STEERING_RANGE_EN_OFFSET	0x76
 #define QUERY_DEV_CAP_FLOW_STEERING_MAX_QP_OFFSET	0x77
 #define QUERY_DEV_CAP_CQ_EQ_CACHE_LINE_STRIDE	0x7a
-#define QUERY_DEV_CAP_ETH_PROT_CTRL_OFFSET	0x7a
+#define QUERY_DEV_CAP_ECN_QCN_VER_OFFSET	0x7b
 #define QUERY_DEV_CAP_RDMARC_ENTRY_SZ_OFFSET	0x80
 #define QUERY_DEV_CAP_QPC_ENTRY_SZ_OFFSET	0x82
 #define QUERY_DEV_CAP_AUX_ENTRY_SZ_OFFSET	0x84
@@ -777,6 +778,9 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_DMFS_IPOIB;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_FLOW_STEERING_MAX_QP_OFFSET);
 	dev_cap->fs_max_num_qp_per_entry = field;
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_ECN_QCN_VER_OFFSET);
+	if (field & 0x1)
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_QCN;
 	MLX4_GET(stat_rate, outbox, QUERY_DEV_CAP_RATE_SUPPORT_OFFSET);
 	dev_cap->stat_rate_support = stat_rate;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_CQ_TS_SUPPORT_OFFSET);
@@ -1149,6 +1153,11 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 		     DEV_CAP_EXT_2_FLAG_FSM);
 	MLX4_PUT(outbox->buf, field32, QUERY_DEV_CAP_EXT_2_FLAGS_OFFSET);
 
+	/* turn off QCN for guests */
+	MLX4_GET(field, outbox->buf, QUERY_DEV_CAP_ECN_QCN_VER_OFFSET);
+	field &= 0xfe;
+	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_ECN_QCN_VER_OFFSET);
+
 	return 0;
 }
 
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 7b6d4e9..7299e95 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -163,6 +163,9 @@ enum {
 	MLX4_QP_FLOW_STEERING_ATTACH = 0x65,
 	MLX4_QP_FLOW_STEERING_DETACH = 0x66,
 	MLX4_FLOW_STEERING_IB_UC_QP_RANGE = 0x64,
+
+	/* Update and read QCN parameters */
+	MLX4_CMD_CONGESTION_CTRL_OPCODE = 0x68,
 };
 
 enum {
@@ -233,6 +236,16 @@ struct mlx4_config_dev_params {
 	u8	rx_csum_flags_port_2;
 };
 
+enum mlx4_en_congestion_control_algorithm {
+	MLX4_CTRL_ALGO_802_1_QAU_REACTION_POINT = 0,
+};
+
+enum mlx4_en_congestion_control_opmod {
+	MLX4_CONGESTION_CONTROL_GET_PARAMS,
+	MLX4_CONGESTION_CONTROL_GET_STATISTICS,
+	MLX4_CONGESTION_CONTROL_SET_PARAMS = 4,
+};
+
 struct mlx4_dev;
 
 struct mlx4_cmd_mailbox {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index e4ebff7..1cc5482 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -203,7 +203,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_80_VFS		= 1LL <<  18,
 	MLX4_DEV_CAP_FLAG2_FS_A0		= 1LL <<  19,
 	MLX4_DEV_CAP_FLAG2_RECOVERABLE_ERROR_EVENT = 1LL << 20,
-	MLX4_DEV_CAP_FLAG2_PORT_REMAP		= 1LL <<  21
+	MLX4_DEV_CAP_FLAG2_PORT_REMAP		= 1LL <<  21,
+	MLX4_DEV_CAP_FLAG2_QCN			= 1LL <<  22,
 };
 
 enum {
-- 
1.7.1
