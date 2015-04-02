From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 07/18] net/mlx4: Add mlx4_SET_VPORT_QOS implementation
Date: Thu,  2 Apr 2015 16:31:12 +0300
Message-ID: <1427981483-19317-8-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45770 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753055AbbDBNcY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:32:24 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Add the SET_VPORT_QOS device command, which is ntended for virtual
granular QoS configuration per VF in SRIOV mode. The SET_VPORT_QOS
command sets and queries QoS parameters of a VPort. Each priority
allowed for a VPort is assigned with a share of the BW, and a BW
limitation. QoS parameters can be modified at any time, but must be
initialized before any QP is associated with the VPort.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c    |    9 +++
 drivers/net/ethernet/mellanox/mlx4/fw_qos.c |   89 +++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw_qos.h |   36 +++++++++++
 include/linux/mlx4/cmd.h                    |    1 +
 4 files changed, 135 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index e1a191d..23dc98e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1464,6 +1464,15 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.wrapper = mlx4_CMD_EPERM_wrapper,
 	},
 	{
+		.opcode = MLX4_CMD_SET_VPORT_QOS,
+		.has_inbox = false,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.encode_slave_id = false,
+		.verify = NULL,
+		.wrapper = mlx4_CMD_EPERM_wrapper,
+	},
+	{
 		.opcode = MLX4_CMD_CONF_SPECIAL_QP,
 		.has_inbox = false,
 		.has_outbox = false,
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw_qos.c b/drivers/net/ethernet/mellanox/mlx4/fw_qos.c
index 5ce3440..8f2fde0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw_qos.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw_qos.c
@@ -42,6 +42,12 @@ enum {
 	MLX4_ALLOCATE_VPP_QUERY		= 0x1
 };
 
+enum {
+	/* set vport qos opcode modifiers */
+	MLX4_SET_VPORT_QOS_SET		= 0x0,
+	MLX4_SET_VPORT_QOS_QUERY	= 0x1
+};
+
 struct mlx4_set_port_prio2tc_context {
 	u8 prio2tc[4];
 };
@@ -63,6 +69,19 @@ struct mlx4_alloc_vpp_param {
 	__be32 vpp_p_up[MLX4_NUM_UP];
 };
 
+struct mlx4_prio_qos_param {
+	__be32 bw_share;
+	__be32 max_avg_bw;
+	__be32 reserved;
+	__be32 enable;
+	__be32 reserved1[4];
+};
+
+struct mlx4_set_vport_context {
+	__be32 reserved[8];
+	struct mlx4_prio_qos_param qos_p_up[MLX4_NUM_UP];
+};
+
 int mlx4_SET_PORT_PRIO2TC(struct mlx4_dev *dev, u8 port, u8 *prio2tc)
 {
 	struct mlx4_cmd_mailbox *mailbox;
@@ -198,3 +217,73 @@ int mlx4_ALLOCATE_VPP_set(struct mlx4_dev *dev, u8 port, u8 *vpp_p_up)
 	return err;
 }
 EXPORT_SYMBOL(mlx4_ALLOCATE_VPP_set);
+
+int mlx4_SET_VPORT_QOS_get(struct mlx4_dev *dev, u8 port, u8 vport,
+			   struct mlx4_vport_qos_param *out_param)
+{
+	int i;
+	int err;
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_set_vport_context *ctx;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	ctx = mailbox->buf;
+
+	err = mlx4_cmd_box(dev, 0, mailbox->dma, (vport << 8) | port,
+			   MLX4_SET_VPORT_QOS_QUERY,
+			   MLX4_CMD_SET_VPORT_QOS,
+			   MLX4_CMD_TIME_CLASS_A,
+			   MLX4_CMD_NATIVE);
+	if (err)
+		goto out;
+
+	for (i = 0; i < MLX4_NUM_UP; i++) {
+		out_param[i].bw_share = be32_to_cpu(ctx->qos_p_up[i].bw_share);
+		out_param[i].max_avg_bw =
+			be32_to_cpu(ctx->qos_p_up[i].max_avg_bw);
+		out_param[i].enable =
+			!!(be32_to_cpu(ctx->qos_p_up[i].enable) & 31);
+	}
+
+out:
+	mlx4_free_cmd_mailbox(dev, mailbox);
+
+	return err;
+}
+EXPORT_SYMBOL(mlx4_SET_VPORT_QOS_get);
+
+int mlx4_SET_VPORT_QOS_set(struct mlx4_dev *dev, u8 port, u8 vport,
+			   struct mlx4_vport_qos_param *in_param)
+{
+	int i;
+	int err;
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_set_vport_context *ctx;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	ctx = mailbox->buf;
+
+	for (i = 0; i < MLX4_NUM_UP; i++) {
+		ctx->qos_p_up[i].bw_share = cpu_to_be32(in_param[i].bw_share);
+		ctx->qos_p_up[i].max_avg_bw =
+				cpu_to_be32(in_param[i].max_avg_bw);
+		ctx->qos_p_up[i].enable =
+				cpu_to_be32(in_param[i].enable << 31);
+	}
+
+	err = mlx4_cmd(dev, mailbox->dma, (vport << 8) | port,
+		       MLX4_SET_VPORT_QOS_SET,
+		       MLX4_CMD_SET_VPORT_QOS,
+		       MLX4_CMD_TIME_CLASS_A,
+		       MLX4_CMD_NATIVE);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_SET_VPORT_QOS_set);
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw_qos.h b/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
index be79951..b3fffaf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
@@ -41,6 +41,12 @@
 #define MLX4_NUM_UP 8
 #define MLX4_NUM_TC 8
 
+struct mlx4_vport_qos_param {
+	u32 bw_share;
+	u32 max_avg_bw;
+	u8 enable;
+};
+
 /**
  * mlx4_SET_PORT_PRIO2TC - This routine maps user priorities to traffic
  * classes of a given port and device.
@@ -100,4 +106,34 @@ int mlx4_ALLOCATE_VPP_get(struct mlx4_dev *dev, u8 port,
  **/
 int mlx4_ALLOCATE_VPP_set(struct mlx4_dev *dev, u8 port, u8 *vpp_p_up);
 
+/**
+ * mlx4_SET_VPORT_QOS_get - Query QoS proporties of a Vport.
+ * Each priority allowed for the Vport is assigned with a share of the BW,
+ * and a BW limitation. This commands query the current QoS values.
+ *
+ * @dev: mlx4_dev.
+ * @port: Physical port number.
+ * @vport: Vport id.
+ * @out_param: Array of mlx4_vport_qos_param that will contain the values.
+ *
+ * Returns 0 on success or a negative mlx4_core errno code.
+ **/
+int mlx4_SET_VPORT_QOS_get(struct mlx4_dev *dev, u8 port, u8 vport,
+			   struct mlx4_vport_qos_param *out_param);
+
+/**
+ * mlx4_SET_VPORT_QOS_set - Set QoS proporties of a Vport.
+ * QoS parameters can be modified at any time, but must be initialized
+ * before any QP is associated with the VPort.
+ *
+ * @dev: mlx4_dev.
+ * @port: Physical port number.
+ * @vport: Vport id.
+ * @out_param: Array of mlx4_vport_qos_param which holds the requested values.
+ *
+ * Returns 0 on success or a negative mlx4_core errno code.
+ **/
+int mlx4_SET_VPORT_QOS_set(struct mlx4_dev *dev, u8 port, u8 vport,
+			   struct mlx4_vport_qos_param *in_param);
+
 #endif /* MLX4_FW_QOS_H */
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index e0f88a0..88326ed 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -69,6 +69,7 @@ enum {
 	MLX4_CMD_SET_ICM_SIZE	 = 0xffd,
 	MLX4_CMD_ACCESS_REG	 = 0x3b,
 	MLX4_CMD_ALLOCATE_VPP	 = 0x80,
+	MLX4_CMD_SET_VPORT_QOS	 = 0x81,
 
 	/*master notify fw on finish for slave's flr*/
 	MLX4_CMD_INFORM_FLR_DONE = 0x5b,
-- 
1.7.1
