From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 06/18] net/mlx4: Add mlx4_ALLOCATE_VPP implementation
Date: Thu,  2 Apr 2015 16:31:11 +0300
Message-ID: <1427981483-19317-7-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45729 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752804AbbDBNcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:32:04 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Implements device ALLOCATE_VPP command, to be used for granular QoS
configuration of VFs by the PF device. Defines and queries the amount
of VPPs assigned to each port, and the amount of VPPs assigned to each
priority of each port. Once the total VPPs are split between the priorities
of a port, they may be assigned with a share of the BW or a rate limit.

Split into two functions (get/set) whoch are supplied with
mlx4_alloc_vpp_context and physical port number.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c    |    9 +++
 drivers/net/ethernet/mellanox/mlx4/fw_qos.c |   75 +++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw_qos.h |   28 ++++++++++
 include/linux/mlx4/cmd.h                    |    1 +
 4 files changed, 113 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 52bf0b5..e1a191d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1455,6 +1455,15 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.wrapper = mlx4_CMD_EPERM_wrapper,
 	},
 	{
+		.opcode = MLX4_CMD_ALLOCATE_VPP,
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
index 0f5af7c..5ce3440 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw_qos.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw_qos.c
@@ -34,6 +34,13 @@
 
 #include <linux/export.h>
 #include "fw_qos.h"
+#include "fw.h"
+
+enum {
+	/* allocate vpp opcode modifiers */
+	MLX4_ALLOCATE_VPP_ALLOCATE	= 0x0,
+	MLX4_ALLOCATE_VPP_QUERY		= 0x1
+};
 
 struct mlx4_set_port_prio2tc_context {
 	u8 prio2tc[4];
@@ -50,6 +57,12 @@ struct mlx4_set_port_scheduler_context {
 	struct mlx4_port_scheduler_tc_cfg_be tc[MLX4_NUM_TC];
 };
 
+/* Granular Qos (per VF) section */
+struct mlx4_alloc_vpp_param {
+	__be32 availible_vpp;
+	__be32 vpp_p_up[MLX4_NUM_UP];
+};
+
 int mlx4_SET_PORT_PRIO2TC(struct mlx4_dev *dev, u8 port, u8 *prio2tc)
 {
 	struct mlx4_cmd_mailbox *mailbox;
@@ -123,3 +136,65 @@ int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
 	return err;
 }
 EXPORT_SYMBOL(mlx4_SET_PORT_SCHEDULER);
+
+int mlx4_ALLOCATE_VPP_get(struct mlx4_dev *dev, u8 port,
+			  u16 *availible_vpp, u8 *vpp_p_up)
+{
+	int i;
+	int err;
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_alloc_vpp_param *out_param;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	out_param = mailbox->buf;
+
+	err = mlx4_cmd_box(dev, 0, mailbox->dma, port,
+			   MLX4_ALLOCATE_VPP_QUERY,
+			   MLX4_CMD_ALLOCATE_VPP,
+			   MLX4_CMD_TIME_CLASS_A,
+			   MLX4_CMD_NATIVE);
+	if (err)
+		goto out;
+
+	/* Total number of supported VPPs */
+	*availible_vpp = (u16)be32_to_cpu(out_param->availible_vpp);
+
+	for (i = 0; i < MLX4_NUM_UP; i++)
+		vpp_p_up[i] = (u8)be32_to_cpu(out_param->vpp_p_up[i]);
+
+out:
+	mlx4_free_cmd_mailbox(dev, mailbox);
+
+	return err;
+}
+EXPORT_SYMBOL(mlx4_ALLOCATE_VPP_get);
+
+int mlx4_ALLOCATE_VPP_set(struct mlx4_dev *dev, u8 port, u8 *vpp_p_up)
+{
+	int i;
+	int err;
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_alloc_vpp_param *in_param;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	in_param = mailbox->buf;
+
+	for (i = 0; i < MLX4_NUM_UP; i++)
+		in_param->vpp_p_up[i] = cpu_to_be32(vpp_p_up[i]);
+
+	err = mlx4_cmd(dev, mailbox->dma, port,
+		       MLX4_ALLOCATE_VPP_ALLOCATE,
+		       MLX4_CMD_ALLOCATE_VPP,
+		       MLX4_CMD_TIME_CLASS_A,
+		       MLX4_CMD_NATIVE);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_ALLOCATE_VPP_set);
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw_qos.h b/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
index ab9be0f..be79951 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
@@ -71,5 +71,33 @@ int mlx4_SET_PORT_PRIO2TC(struct mlx4_dev *dev, u8 port, u8 *prio2tc);
  **/
 int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
 			    u8 *pg, u16 *ratelimit);
+/**
+ * mlx4_ALLOCATE_VPP_get - Query port VPP availible resources and allocation.
+ * Before distribution of VPPs to priorities, only availible_vpp is returned.
+ * After initialization it returns the distribution of VPPs among priorities.
+ *
+ * @dev: mlx4_dev.
+ * @port: Physical port number.
+ * @availible_vpp: Pointer to variable where number of availible VPPs is stored
+ * @vpp_p_up: Distribution of VPPs to priorities is stored in this array
+ *
+ * Returns 0 on success or a negative mlx4_core errno code.
+ **/
+int mlx4_ALLOCATE_VPP_get(struct mlx4_dev *dev, u8 port,
+			  u16 *availible_vpp, u8 *vpp_p_up);
+/**
+ * mlx4_ALLOCATE_VPP_set - Distribution of VPPs among differnt priorities.
+ * The total number of VPPs assigned to all for a port must not exceed
+ * the value reported by availible_vpp in mlx4_ALLOCATE_VPP_get.
+ * VPP allocation is allowed only after the port type has been set,
+ * and while no QPs are open for this port.
+ *
+ * @dev: mlx4_dev.
+ * @port: Physical port number.
+ * @vpp_p_up: Allocation of VPPs to different priorities.
+ *
+ * Returns 0 on success or a negative mlx4_core errno code.
+ **/
+int mlx4_ALLOCATE_VPP_set(struct mlx4_dev *dev, u8 port, u8 *vpp_p_up);
 
 #endif /* MLX4_FW_QOS_H */
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 7299e95..e0f88a0 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -68,6 +68,7 @@ enum {
 	MLX4_CMD_UNMAP_ICM_AUX	 = 0xffb,
 	MLX4_CMD_SET_ICM_SIZE	 = 0xffd,
 	MLX4_CMD_ACCESS_REG	 = 0x3b,
+	MLX4_CMD_ALLOCATE_VPP	 = 0x80,
 
 	/*master notify fw on finish for slave's flr*/
 	MLX4_CMD_INFORM_FLR_DONE = 0x5b,
-- 
1.7.1
