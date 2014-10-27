From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 03/13] net/mlx4_core: Introduce ACCESS_REG CMD and eth_prot_ctrl dev cap
Date: Mon, 27 Oct 2014 11:37:37 +0200
Message-ID: <1414402667-8841-4-git-send-email-amirv@mellanox.com>
References: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:34952 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752227AbaJ0Jia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 05:38:30 -0400
In-Reply-To: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Adding ACCESS REG mlx4 command and use it to implement Query method for
PTYS (Port Type and Speed Register).
Query and store eth_prot_ctrl dev cap.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c |   9 +++
 drivers/net/ethernet/mellanox/mlx4/fw.c  | 118 ++++++++++++++++++++++++++++++-
 include/linux/mlx4/cmd.h                 |   2 +
 include/linux/mlx4/device.h              |  40 ++++++++++-
 4 files changed, 166 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index b16e1b9..916459e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1338,6 +1338,15 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.verify = NULL,
 		.wrapper = mlx4_QUERY_IF_STAT_wrapper
 	},
+	{
+		.opcode = MLX4_CMD_ACCESS_REG,
+		.has_inbox = true,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.encode_slave_id = false,
+		.verify = NULL,
+		.wrapper = NULL,
+	},
 	/* Native multicast commands are not available for guests */
 	{
 		.opcode = MLX4_CMD_QP_ATTACH,
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 2e88a23..6fd9b85 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -139,7 +139,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[10] = "TCP/IP offloads/flow-steering for VXLAN support",
 		[11] = "MAD DEMUX (Secure-Host) support",
 		[12] = "Large cache line (>64B) CQE stride support",
-		[13] = "Large cache line (>64B) EQE stride support"
+		[13] = "Large cache line (>64B) EQE stride support",
+		[14] = "Ethernet protocol control support"
 	};
 	int i;
 
@@ -560,6 +561,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_FLOW_STEERING_RANGE_EN_OFFSET	0x76
 #define QUERY_DEV_CAP_FLOW_STEERING_MAX_QP_OFFSET	0x77
 #define QUERY_DEV_CAP_CQ_EQ_CACHE_LINE_STRIDE	0x7a
+#define QUERY_DEV_CAP_ETH_PROT_CTRL_OFFSET	0x7a
 #define QUERY_DEV_CAP_RDMARC_ENTRY_SZ_OFFSET	0x80
 #define QUERY_DEV_CAP_QPC_ENTRY_SZ_OFFSET	0x82
 #define QUERY_DEV_CAP_AUX_ENTRY_SZ_OFFSET	0x84
@@ -737,11 +739,12 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	MLX4_GET(size, outbox, QUERY_DEV_CAP_MAX_DESC_SZ_RQ_OFFSET);
 	dev_cap->max_rq_desc_sz = size;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_CQ_EQ_CACHE_LINE_STRIDE);
+	if (field & (1 << 5))
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_ETH_PROT_CTRL;
 	if (field & (1 << 6))
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_CQE_STRIDE;
 	if (field & (1 << 7))
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_EQE_STRIDE;
-
 	MLX4_GET(dev_cap->bmme_flags, outbox,
 		 QUERY_DEV_CAP_BMME_FLAGS_OFFSET);
 	MLX4_GET(dev_cap->reserved_lkey, outbox,
@@ -2144,3 +2147,114 @@ out:
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
 }
+
+/* Access Reg commands */
+enum mlx4_access_reg_masks {
+	MLX4_ACCESS_REG_STATUS_MASK = 0x7f,
+	MLX4_ACCESS_REG_METHOD_MASK = 0x7f,
+	MLX4_ACCESS_REG_LEN_MASK = 0x7ff
+};
+
+struct mlx4_access_reg {
+	__be16 constant1;
+	u8 status;
+	u8 resrvd1;
+	__be16 reg_id;
+	u8 method;
+	u8 constant2;
+	__be32 resrvd2[2];
+	__be16 len_const;
+	__be16 resrvd3;
+#define MLX4_ACCESS_REG_HEADER_SIZE (20)
+	u8 reg_data[MLX4_MAILBOX_SIZE-MLX4_ACCESS_REG_HEADER_SIZE];
+} __attribute__((__packed__));
+
+/**
+ * mlx4_ACCESS_REG - Generic access reg command.
+ * @dev: mlx4_dev.
+ * @reg_id: register ID to access.
+ * @method: Access method Read/Write.
+ * @reg_len: register length to Read/Write in bytes.
+ * @reg_data: reg_data pointer to Read/Write From/To.
+ *
+ * Access ConnectX registers FW command.
+ * Returns 0 on success and copies outbox mlx4_access_reg data
+ * field into reg_data or a negative error code.
+ */
+static int mlx4_ACCESS_REG(struct mlx4_dev *dev, u16 reg_id,
+			   enum mlx4_access_reg_method method,
+			   u16 reg_len, void *reg_data)
+{
+	struct mlx4_cmd_mailbox *inbox, *outbox;
+	struct mlx4_access_reg *inbuf, *outbuf;
+	int err;
+
+	inbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(inbox))
+		return PTR_ERR(inbox);
+
+	outbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(outbox)) {
+		mlx4_free_cmd_mailbox(dev, inbox);
+		return PTR_ERR(outbox);
+	}
+
+	inbuf = inbox->buf;
+	outbuf = outbox->buf;
+
+	inbuf->constant1 = cpu_to_be16(0x1<<11 | 0x4);
+	inbuf->constant2 = 0x1;
+	inbuf->reg_id = cpu_to_be16(reg_id);
+	inbuf->method = method & MLX4_ACCESS_REG_METHOD_MASK;
+
+	reg_len = min(reg_len, (u16)(sizeof(inbuf->reg_data)));
+	inbuf->len_const =
+		cpu_to_be16(((reg_len/4 + 1) & MLX4_ACCESS_REG_LEN_MASK) |
+			    ((0x3) << 12));
+
+	memcpy(inbuf->reg_data, reg_data, reg_len);
+	err = mlx4_cmd_box(dev, inbox->dma, outbox->dma, 0, 0,
+			   MLX4_CMD_ACCESS_REG, MLX4_CMD_TIME_CLASS_C,
+			   MLX4_CMD_NATIVE);
+	if (err)
+		goto out;
+
+	if (outbuf->status & MLX4_ACCESS_REG_STATUS_MASK) {
+		err = outbuf->status & MLX4_ACCESS_REG_STATUS_MASK;
+		mlx4_err(dev,
+			 "MLX4_CMD_ACCESS_REG(%x) returned REG status (%x)\n",
+			 reg_id, err);
+		goto out;
+	}
+
+	memcpy(reg_data, outbuf->reg_data, reg_len);
+out:
+	mlx4_free_cmd_mailbox(dev, inbox);
+	mlx4_free_cmd_mailbox(dev, outbox);
+	return err;
+}
+
+/* ConnectX registers IDs */
+enum mlx4_reg_id {
+	MLX4_REG_ID_PTYS = 0x5004,
+};
+
+/**
+ * mlx4_ACCESS_PTYS_REG - Access PTYs (Port Type and Speed)
+ * register
+ * @dev: mlx4_dev.
+ * @method: Access method Read/Write.
+ * @ptys_reg: PTYS register data pointer.
+ *
+ * Access ConnectX PTYS register, to Read/Write Port Type/Speed
+ * configuration
+ * Returns 0 on success or a negative error code.
+ */
+int mlx4_ACCESS_PTYS_REG(struct mlx4_dev *dev,
+			 enum mlx4_access_reg_method method,
+			 struct mlx4_ptys_reg *ptys_reg)
+{
+	return mlx4_ACCESS_REG(dev, MLX4_REG_ID_PTYS,
+			       method, sizeof(*ptys_reg), ptys_reg);
+}
+EXPORT_SYMBOL_GPL(mlx4_ACCESS_PTYS_REG);
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 379c026..ff5f5de 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -67,6 +67,8 @@ enum {
 	MLX4_CMD_MAP_ICM_AUX	 = 0xffc,
 	MLX4_CMD_UNMAP_ICM_AUX	 = 0xffb,
 	MLX4_CMD_SET_ICM_SIZE	 = 0xffd,
+	MLX4_CMD_ACCESS_REG	 = 0x3b,
+
 	/*master notify fw on finish for slave's flr*/
 	MLX4_CMD_INFORM_FLR_DONE = 0x5b,
 	MLX4_CMD_GET_OP_REQ      = 0x59,
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 73910da..181cd9f 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -186,7 +186,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS	= 1LL <<  10,
 	MLX4_DEV_CAP_FLAG2_MAD_DEMUX		= 1LL <<  11,
 	MLX4_DEV_CAP_FLAG2_CQE_STRIDE		= 1LL <<  12,
-	MLX4_DEV_CAP_FLAG2_EQE_STRIDE		= 1LL <<  13
+	MLX4_DEV_CAP_FLAG2_EQE_STRIDE		= 1LL <<  13,
+	MLX4_DEV_CAP_FLAG2_ETH_PROT_CTRL        = 1LL <<  14
 };
 
 enum {
@@ -1319,4 +1320,41 @@ static inline bool mlx4_low_memory_profile(void)
 	return is_kdump_kernel();
 }
 
+/* ACCESS REG commands */
+enum mlx4_access_reg_method {
+	MLX4_ACCESS_REG_QUERY = 0x1,
+	MLX4_ACCESS_REG_WRITE = 0x2,
+};
+
+/* ACCESS PTYS Reg command */
+enum mlx4_ptys_proto {
+	MLX4_PTYS_IB = 1<<0,
+	MLX4_PTYS_EN = 1<<2,
+};
+
+struct mlx4_ptys_reg {
+	u8 resrvd1;
+	u8 local_port;
+	u8 resrvd2;
+	u8 proto_mask;
+	__be32 resrvd3[2];
+	__be32 eth_proto_cap;
+	__be16 ib_width_cap;
+	__be16 ib_speed_cap;
+	__be32 resrvd4;
+	__be32 eth_proto_admin;
+	__be16 ib_width_admin;
+	__be16 ib_speed_admin;
+	__be32 resrvd5;
+	__be32 eth_proto_oper;
+	__be16 ib_width_oper;
+	__be16 ib_speed_oper;
+	__be32 resrvd6;
+	__be32 eth_proto_lp_adv;
+} __packed;
+
+int mlx4_ACCESS_PTYS_REG(struct mlx4_dev *dev,
+			 enum mlx4_access_reg_method method,
+			 struct mlx4_ptys_reg *ptys_reg);
+
 #endif /* MLX4_DEVICE_H */
-- 
1.8.3.4
