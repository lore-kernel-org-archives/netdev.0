From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 02/23 v3] mlx4_core: add multi-function communication channel
Date: Thu, 04 Feb 2010 17:54:34 +0200
Message-ID: <4B6AEDBA.6040403@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:46828 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932652Ab0BDPyh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:54:37 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The communication channel consists of 2 registers per vf (a slave function)
that are shared with the pf (the master function), as well as a new command for
inter-function memory copying (only exposed to the master).

The communication channel is used to establish a Virtual HCA Command Register
(vHCR) in each slave function, which allows it to pass FW commands to the master
function for execution.
The slave also uses the vHCR to pull slave-specific events from the master.

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/cmd.c      |  746 ++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/mlx4/en_port.h  |    5 -
 drivers/net/mlx4/eq.c       |   67 ++++
 drivers/net/mlx4/fw.c       |    8 +
 drivers/net/mlx4/mlx4.h     |   72 ++++-
 include/linux/mlx4/cmd.h    |   12 +-
 include/linux/mlx4/device.h |    3 +-
 7 files changed, 895 insertions(+), 18 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index 65ec77d..6c3d25c 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -140,6 +140,46 @@ static int mlx4_status_to_errno(u8 status)
 	return trans_table[status];
 }
 
+static int comm_pending(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	u32 status = readl(&priv->mfunc.comm->slave_read);
+
+	return (swab32(status) >> 30) != priv->cmd.comm_toggle;
+}
+
+int mlx4_comm_cmd(struct mlx4_dev *dev, u8 cmd, u16 param, unsigned long timeout)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	unsigned long end;
+	u32 val;
+
+	/* First, verify that the master reports correct status */
+	if (comm_pending(dev)) {
+		mlx4_warn(dev, "Communication channel is not idle\n");
+		return -EAGAIN;
+	}
+
+	/* Write command */
+	if (cmd == MLX4_COMM_CMD_RESET)
+		priv->cmd.comm_toggle = 0;
+	else if (++priv->cmd.comm_toggle > 2)
+		priv->cmd.comm_toggle = 1;
+	val = param | (cmd << 16) | (priv->cmd.comm_toggle << 30);
+	__raw_writel((__force u32) cpu_to_be32(val), &priv->mfunc.comm->slave_write);
+	wmb();
+
+	end = msecs_to_jiffies(timeout) + jiffies;
+	while (comm_pending(dev) && time_before(jiffies, end))
+		cond_resched();
+
+	if (comm_pending(dev)) {
+		mlx4_warn(dev, "Communication channel timed out\n");
+		return -ETIMEDOUT;
+	}
+	return 0;
+}
+
 static int cmd_pending(struct mlx4_dev *dev)
 {
 	u32 status = readl(mlx4_priv(dev)->cmd.hcr + HCR_STATUS_OFFSET);
@@ -207,6 +247,33 @@ out:
 	return ret;
 }
 
+static int mlx4_slave_cmd_poll(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
+			 int out_is_imm, u32 in_modifier, u8 op_modifier,
+			 u16 op, unsigned long timeout)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_vhcr *vhcr = priv->mfunc.vhcr;
+	int ret;
+
+	down(&priv->cmd.poll_sem);
+	vhcr->in_param = in_param;
+	vhcr->out_param = out_param ? *out_param : 0;
+	vhcr->in_modifier = in_modifier;
+	vhcr->timeout = timeout;
+	vhcr->op = op;
+	vhcr->token = CMD_POLL_TOKEN;
+	vhcr->op_modifier = op_modifier;
+	vhcr->errno = 0;
+	ret = mlx4_comm_cmd(dev, MLX4_COMM_CMD_VHCR_POST, 0, MLX4_COMM_TIME + timeout);
+	if (!ret) {
+		if (out_is_imm)
+			*out_param = vhcr->out_param;
+		ret = vhcr->errno;
+	}
+	up(&priv->cmd.poll_sem);
+	return ret;
+}
+
 static int mlx4_cmd_poll(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 			 int out_is_imm, u32 in_modifier, u8 op_modifier,
 			 u16 op, unsigned long timeout)
@@ -314,12 +381,646 @@ int __mlx4_cmd(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 	if (mlx4_priv(dev)->cmd.use_events)
 		return mlx4_cmd_wait(dev, in_param, out_param, out_is_imm,
 				     in_modifier, op_modifier, op, timeout);
+
+	if (mlx4_is_slave(dev))
+		return mlx4_slave_cmd_poll(dev, in_param, out_param, out_is_imm,
+				     in_modifier, op_modifier, op, timeout);
 	else
 		return mlx4_cmd_poll(dev, in_param, out_param, out_is_imm,
 				     in_modifier, op_modifier, op, timeout);
 }
 EXPORT_SYMBOL_GPL(__mlx4_cmd);
 
+static int mlx4_ACCESS_MEM(struct mlx4_dev *dev, u64 master_addr,
+			   int slave, u64 slave_addr,
+			   int size, int is_read)
+{
+	u64 in_param;
+	u64 out_param;
+
+	if ((slave_addr & 0xfff) | (master_addr & 0xfff) |
+	    (slave & ~0x7f) | (size & 0xff)) {
+		mlx4_err(dev, "Bad access mem params - slave_addr:0x%llx "
+			      "master_addr:0x%llx slave_id:%d size:%d\n",
+			      slave_addr, master_addr, slave, size);
+		return -EINVAL;
+	}
+
+	if (is_read) {
+		in_param = (u64) slave | slave_addr;
+		out_param = master_addr;
+	} else {
+		in_param = master_addr;
+		out_param = (u64) slave | slave_addr;
+	}
+
+	return mlx4_cmd_imm(dev, in_param, &out_param, size, 0,
+					   MLX4_CMD_ACCESS_MEM,
+					   MLX4_CMD_TIME_CLASS_A);
+}
+
+static struct mlx4_cmd_info {
+	u16 opcode;
+	bool has_inbox;
+	bool has_outbox;
+	bool out_is_imm;
+	int (*verify)(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+					    struct mlx4_cmd_mailbox *inbox);
+	int (*wrapper)(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+					     struct mlx4_cmd_mailbox *inbox,
+					     struct mlx4_cmd_mailbox *outbox);
+} cmd_info[] = {
+	{
+		.opcode = MLX4_CMD_QUERY_FW,
+		.has_inbox = false,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.verify = NULL,
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_QUERY_ADAPTER,
+		.has_inbox = false,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.verify = NULL,
+		.wrapper = NULL
+	},
+
+	{
+		.opcode = MLX4_CMD_SW2HW_EQ,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /*need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_NOP,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL,
+		.wrapper = NULL
+	},
+
+	{
+		.opcode = MLX4_CMD_SW2HW_MPT,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL,
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_QUERY_MPT,
+		.has_inbox = false,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_HW2SW_MPT,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_READ_MTT,
+		.has_inbox = false,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_SYNC_TPT,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+
+	{
+		.opcode = MLX4_CMD_HW2SW_EQ,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_QUERY_EQ,
+		.has_inbox = false,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_SW2HW_CQ,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_HW2SW_CQ,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_QUERY_CQ,
+		.has_inbox = false,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_MODIFY_CQ,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = true,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_SW2HW_SRQ,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_HW2SW_SRQ,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_QUERY_SRQ,
+		.has_inbox = false,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_ARM_SRQ,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_RST2INIT_QP,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_INIT2RTR_QP,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_RTR2RTS_QP,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_RTS2RTS_QP,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_SQERR2RTS_QP,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_2ERR_QP,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_RTS2SQD_QP,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_SQD2SQD_QP,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_SQD2RTS_QP,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_2RST_QP,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_QUERY_QP,
+		.has_inbox = false,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_INIT2INIT_QP,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_SUSPEND_QP,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_UNSUSPEND_QP,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+	{
+		.opcode = MLX4_CMD_MAD_IFC,
+		.has_inbox = true,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+
+	/* Native multicast commands are not available for guests */
+	{
+		.opcode = MLX4_CMD_DIAG_RPRT,
+		.has_inbox = false,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = NULL
+	},
+
+	/* Ethernet specific commands */
+	{
+		.opcode = MLX4_CMD_SET_VLAN_FLTR,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL,
+		.wrapper = NULL /* need wrapper*/
+	},
+	{
+		.opcode = MLX4_CMD_SET_MCAST_FLTR,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL,
+		.wrapper = NULL /* need wrapper*/
+	},
+	{
+		.opcode = MLX4_CMD_DUMP_ETH_STATS,
+		.has_inbox = false,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.verify = NULL,
+		.wrapper = NULL /* need wrapper*/
+	},
+};
+
+static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_cmd_info *cmd = NULL;
+	struct mlx4_vhcr *vhcr = priv->mfunc.vhcr;
+	struct mlx4_cmd_mailbox *inbox = NULL;
+	struct mlx4_cmd_mailbox *outbox = NULL;
+	u64 in_param;
+	u64 out_param;
+	int ret;
+	int i;
+
+	/* DMA in the vHCR */
+	ret = mlx4_ACCESS_MEM(dev, priv->mfunc.vhcr_dma, slave,
+			      priv->mfunc.master.slave_state[slave].vhcr_dma,
+			      ALIGN(sizeof(struct mlx4_vhcr),
+				    MLX4_ACCESS_MEM_ALIGN), 1);
+	if (ret) {
+		mlx4_err(dev, "Failed reading vhcr\n");
+		return ret;
+	}
+
+	/* Lookup command */
+	for (i = 0; i < ARRAY_SIZE(cmd_info); ++i) {
+		if (vhcr->op == cmd_info[i].opcode) {
+			cmd = &cmd_info[i];
+			break;
+		}
+	}
+	if (!cmd) {
+		mlx4_err(dev, "Unknown command:0x%x accepted from slave:%d\n",
+							      vhcr->op, slave);
+		vhcr->errno = -EINVAL;
+		goto out_status;
+	}
+
+	/* Read inbox */
+	if (cmd->has_inbox) {
+		inbox = mlx4_alloc_cmd_mailbox(dev);
+		if (IS_ERR(inbox)) {
+			ret = PTR_ERR(inbox);
+			inbox = NULL;
+			goto out;
+		}
+
+		/* FIXME: add mailbox size per-command */
+		ret = mlx4_ACCESS_MEM(dev, inbox->dma, slave,
+				      vhcr->in_param,
+				      MLX4_MAILBOX_SIZE, 1);
+		if (ret) {
+			mlx4_err(dev, "Failed reading inbox\n");
+			goto out;
+		}
+	}
+
+	/* Apply permission and bound checks if applicable */
+	if (cmd->verify && cmd->verify(dev, slave, vhcr, inbox)) {
+		mlx4_warn(dev, "Command:0x%x failed protection checks\n", vhcr->op);
+		vhcr->errno = -EPERM;
+		goto out_status;
+	}
+
+	/* Allocate outbox */
+	if (cmd->has_outbox) {
+		outbox = mlx4_alloc_cmd_mailbox(dev);
+		if (IS_ERR(outbox)) {
+			ret = PTR_ERR(outbox);
+			outbox = NULL;
+			goto out;
+		}
+	}
+
+	/* Execute the command! */
+	if (cmd->wrapper)
+		vhcr->errno = cmd->wrapper(dev, slave, vhcr, inbox, outbox);
+	else {
+		in_param = cmd->has_inbox ? (u64) inbox->dma : vhcr->in_param;
+		out_param = cmd->has_outbox ? (u64) outbox->dma : vhcr->out_param;
+		vhcr->errno = __mlx4_cmd(dev, in_param, &out_param,
+							cmd->out_is_imm,
+							vhcr->in_modifier,
+							vhcr->op_modifier,
+							vhcr->op,
+							vhcr->timeout);
+		if (cmd->out_is_imm)
+			vhcr->out_param = out_param;
+	}
+
+	/* Write outbox if command completed successfully */
+	if (cmd->has_outbox && !vhcr->errno) {
+		ret = mlx4_ACCESS_MEM(dev, outbox->dma, slave,
+				      vhcr->out_param,
+				      MLX4_MAILBOX_SIZE, 0);
+		if (ret) {
+			mlx4_err(dev, "Failed writing outbox\n");
+			goto out;
+		}
+	}
+
+out_status:
+	/* DMA back vhcr result */
+	ret = mlx4_ACCESS_MEM(dev, priv->mfunc.vhcr_dma, slave,
+			      priv->mfunc.master.slave_state[slave].vhcr_dma,
+			      ALIGN(sizeof(struct mlx4_vhcr),
+				    MLX4_ACCESS_MEM_ALIGN), 0);
+	if (ret)
+		mlx4_err(dev, "Failed writing vhcr result\n");
+
+	if (vhcr->errno)
+		mlx4_warn(dev, "vhcr command:0x%x slave:%d failed with error:%d\n",
+							vhcr->op, slave, vhcr->errno);
+	/* Fall through... */
+
+out:
+	mlx4_free_cmd_mailbox(dev, inbox);
+	mlx4_free_cmd_mailbox(dev, outbox);
+	return ret;
+}
+
+static void mlx4_master_do_cmd(struct mlx4_dev *dev, int slave, u8 cmd, u16 param, u8 toggle)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_slave_state *slave_state = priv->mfunc.master.slave_state;
+	u8 toggle_next;
+	u32 reply;
+
+	if (cmd == MLX4_COMM_CMD_RESET) {
+		mlx4_warn(dev, "Received reset from slave:%d\n", slave);
+		goto reset_slave;
+	}
+
+	/* Increment next toggle token */
+	toggle_next = slave_state[slave].comm_toggle + 1;
+	if (toggle_next > 2)
+		toggle_next = 1;
+	if (toggle != toggle_next) {
+		mlx4_warn(dev, "Incorrect token:%d from slave:%d expected:%d\n",
+							toggle, toggle_next, slave);
+		goto reset_slave;
+	}
+
+	switch (cmd) {
+	case MLX4_COMM_CMD_VHCR0:
+		if (slave_state[slave].last_cmd != MLX4_COMM_CMD_RESET)
+			goto reset_slave;
+		slave_state[slave].vhcr_dma = ((u64) param) << 48;
+		break;
+	case MLX4_COMM_CMD_VHCR1:
+		if (slave_state[slave].last_cmd != MLX4_COMM_CMD_VHCR0)
+			goto reset_slave;
+		slave_state[slave].vhcr_dma |= ((u64) param) << 32;
+		break;
+	case MLX4_COMM_CMD_VHCR2:
+		if (slave_state[slave].last_cmd != MLX4_COMM_CMD_VHCR1)
+			goto reset_slave;
+		slave_state[slave].vhcr_dma |= ((u64) param) << 16;
+		break;
+	case MLX4_COMM_CMD_VHCR_EN:
+		if (slave_state[slave].last_cmd != MLX4_COMM_CMD_VHCR2)
+			goto reset_slave;
+		slave_state[slave].vhcr_dma |= param;
+		break;
+	case MLX4_COMM_CMD_VHCR_POST:
+		if ((slave_state[slave].last_cmd != MLX4_COMM_CMD_VHCR_EN) &&
+		    (slave_state[slave].last_cmd != MLX4_COMM_CMD_VHCR_POST))
+			goto reset_slave;
+		if (mlx4_master_process_vhcr(dev, slave)) {
+			mlx4_err(dev, "Failed processing vhcr for slave:%d, reseting slave.\n", slave);
+			goto reset_slave;
+		}
+		break;
+	default:
+		mlx4_warn(dev, "Bad comm cmd:%d from slave:%d\n", cmd, slave);
+		goto reset_slave;
+	}
+
+	slave_state[slave].last_cmd = cmd;
+	slave_state[slave].comm_toggle = toggle_next;
+	reply = (u32) toggle_next << 30;
+	__raw_writel((__force u32) cpu_to_be32(reply),
+		     &priv->mfunc.comm[slave].slave_read);
+	wmb();
+	return;
+
+reset_slave:
+	/* FIXME: cleanup any slave resources */
+	slave_state[slave].last_cmd = MLX4_COMM_CMD_RESET;
+	slave_state[slave].comm_toggle = 0;
+	__raw_writel((__force u32) 0, &priv->mfunc.comm[slave].slave_write);
+	__raw_writel((__force u32) 0, &priv->mfunc.comm[slave].slave_read);
+	wmb();
+}
+
+/* master command processing */
+static void mlx4_master_poll_comm(struct work_struct *work)
+{
+	struct delayed_work *delay = container_of(work, struct delayed_work, work);
+	struct mlx4_mfunc *mfunc = container_of(delay, struct mlx4_mfunc, comm_work);
+	struct mlx4_priv *priv = container_of(mfunc, struct mlx4_priv, mfunc);
+	struct mlx4_dev *dev = &priv->dev;
+	u32 comm_cmd;
+	int polled = 0;
+	int i;
+
+	/* Give each slave a chance for one command */
+	for (i = 0; i < dev->num_slaves; i++) {
+		comm_cmd = swab32(readl(&priv->mfunc.comm[i].slave_write));
+		if (comm_cmd >> 30 != priv->mfunc.master.slave_state[i].comm_toggle) {
+			mlx4_master_do_cmd(dev, i, comm_cmd >> 16, comm_cmd, comm_cmd >> 30);
+			polled = 1;
+		}
+	}
+	queue_delayed_work(priv->mfunc.comm_wq, &priv->mfunc.comm_work,
+						polled ? 0 : HZ / 10);
+}
+
+int mlx4_multi_func_init(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int i;
+
+	priv->mfunc.vhcr = dma_alloc_coherent(&(dev->pdev->dev), PAGE_SIZE,
+					    &priv->mfunc.vhcr_dma,
+					    GFP_KERNEL);
+	if (!priv->mfunc.vhcr) {
+		mlx4_err(dev, "Couldn't allocate vhcr.\n");
+		return -ENOMEM;
+	}
+
+	if (mlx4_is_master(dev))
+		priv->mfunc.comm = ioremap(pci_resource_start(dev->pdev,
+							    priv->fw.comm_bar) +
+								priv->fw.comm_base,
+							    MLX4_COMM_PAGESIZE);
+	else
+		priv->mfunc.comm = ioremap(pci_resource_start(dev->pdev, 2) +
+							    MLX4_SLAVE_COMM_BASE,
+							    MLX4_COMM_PAGESIZE);
+	if (!priv->mfunc.comm) {
+		mlx4_err(dev, "Couldn't map communication vector.");
+		goto err_vhcr;
+	}
+
+	if (mlx4_is_master(dev)) {
+		priv->mfunc.master.slave_state = kzalloc(dev->num_slaves *
+					   sizeof(struct mlx4_slave_state),
+					   GFP_KERNEL);
+		if (!priv->mfunc.master.slave_state)
+			goto err_comm;
+
+		for (i = 0; i < dev->num_slaves; ++i)
+			priv->mfunc.master.slave_state[i].last_cmd = MLX4_COMM_CMD_RESET;
+
+		INIT_DELAYED_WORK(&priv->mfunc.comm_work, mlx4_master_poll_comm);
+		priv->mfunc.comm_wq = create_singlethread_workqueue("mlx4_comm");
+		if (!priv->mfunc.comm_wq) {
+			kfree(priv->mfunc.master.slave_state);
+			goto err_comm;
+		}
+	} else {
+		priv->cmd.comm_toggle = 0;
+		INIT_DELAYED_WORK(&priv->mfunc.comm_work, mlx4_slave_async_eq_poll);
+		priv->mfunc.comm_wq = create_singlethread_workqueue("mlx4_event");
+		if (!priv->mfunc.comm_wq)
+			goto err_comm;
+	}
+	return 0;
+
+err_comm:
+	iounmap(priv->mfunc.comm);
+err_vhcr:
+	dma_free_coherent(&(dev->pdev->dev), PAGE_SIZE,
+					     priv->mfunc.vhcr,
+					     priv->mfunc.vhcr_dma);
+	priv->mfunc.vhcr = NULL;
+	return -ENOMEM;
+}
+
 int mlx4_cmd_init(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -329,22 +1030,45 @@ int mlx4_cmd_init(struct mlx4_dev *dev)
 	priv->cmd.use_events = 0;
 	priv->cmd.toggle     = 1;
 
-	priv->cmd.hcr = ioremap(pci_resource_start(dev->pdev, 0) + MLX4_HCR_BASE,
-				MLX4_HCR_SIZE);
-	if (!priv->cmd.hcr) {
-		mlx4_err(dev, "Couldn't map command register.");
-		return -ENOMEM;
+	priv->cmd.hcr = NULL;
+	priv->mfunc.vhcr = NULL;
+
+	if (!mlx4_is_slave(dev)) {
+		priv->cmd.hcr = ioremap(pci_resource_start(dev->pdev, 0) +
+					MLX4_HCR_BASE, MLX4_HCR_SIZE);
+		if (!priv->cmd.hcr) {
+			mlx4_err(dev, "Couldn't map command register.");
+			return -ENOMEM;
+		}
 	}
 
 	priv->cmd.pool = pci_pool_create("mlx4_cmd", dev->pdev,
 					 MLX4_MAILBOX_SIZE,
 					 MLX4_MAILBOX_SIZE, 0);
-	if (!priv->cmd.pool) {
-		iounmap(priv->cmd.hcr);
-		return -ENOMEM;
-	}
+	if (!priv->cmd.pool)
+		goto err_hcr;
 
 	return 0;
+
+err_hcr:
+	if (!mlx4_is_slave(dev))
+		iounmap(priv->cmd.hcr);
+	return -ENOMEM;
+}
+
+void mlx4_multi_func_cleanup(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	if (priv->mfunc.vhcr) {
+		destroy_workqueue(priv->mfunc.comm_wq);
+		kfree(priv->mfunc.master.slave_state);
+		iounmap(priv->mfunc.comm);
+		dma_free_coherent(&(dev->pdev->dev), PAGE_SIZE,
+						     priv->mfunc.vhcr,
+						     priv->mfunc.vhcr_dma);
+		priv->mfunc.vhcr = NULL;
+	}
 }
 
 void mlx4_cmd_cleanup(struct mlx4_dev *dev)
@@ -352,7 +1076,9 @@ void mlx4_cmd_cleanup(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
 	pci_pool_destroy(priv->cmd.pool);
-	iounmap(priv->cmd.hcr);
+
+	if (!mlx4_is_slave(dev))
+		iounmap(priv->cmd.hcr);
 }
 
 /*
diff --git a/drivers/net/mlx4/en_port.h b/drivers/net/mlx4/en_port.h
index e6477f1..3892896 100644
--- a/drivers/net/mlx4/en_port.h
+++ b/drivers/net/mlx4/en_port.h
@@ -38,11 +38,6 @@
 #define SET_PORT_GEN_ALL_VALID	0x7
 #define SET_PORT_PROMISC_SHIFT	31
 
-enum {
-	MLX4_CMD_SET_VLAN_FLTR  = 0x47,
-	MLX4_CMD_SET_MCAST_FLTR = 0x48,
-	MLX4_CMD_DUMP_ETH_STATS = 0x49,
-};
 
 struct mlx4_set_port_general_context {
 	u8 reserved[3];
diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index bffb799..70c16d4 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -160,6 +160,22 @@ static struct mlx4_eqe *next_eqe_sw(struct mlx4_eq *eq)
 	return !!(eqe->owner & 0x80) ^ !!(eq->cons_index & eq->nent) ? NULL : eqe;
 }
 
+static int mlx4_GET_EVENT(struct mlx4_dev *dev, struct mlx4_slave_eqe *eqe)
+{
+	int ret;
+	u64 out_param;
+
+	ret = mlx4_cmd_imm(dev, 0, &out_param, 0, 0, MLX4_CMD_GET_EVENT,
+						     MLX4_CMD_TIME_CLASS_A);
+	if (!ret) {
+		eqe->type = out_param & 0xff;
+		eqe->port = (out_param >> 8) & 0xff;
+		eqe->param = out_param >> 32;
+	} else
+		mlx4_err(dev, "Failed retrieving event\n");
+	return ret;
+}
+
 static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 {
 	struct mlx4_eqe *eqe;
@@ -262,6 +278,57 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 	return eqes_found;
 }
 
+void mlx4_slave_async_eq_poll(struct work_struct *work)
+{
+	struct delayed_work *delay = container_of(work, struct delayed_work, work);
+	struct mlx4_mfunc *mfunc = container_of(delay, struct mlx4_mfunc, comm_work);
+	struct mlx4_priv *priv = container_of(mfunc, struct mlx4_priv, mfunc);
+	struct mlx4_dev *dev = &priv->dev;
+	struct mlx4_slave_eqe eqe;
+	int ret;
+	int i;
+
+	for (i = 0; i < MLX4_MFUNC_MAX_EQES; i++) {
+		ret = mlx4_GET_EVENT(dev, &eqe);
+		if (ret || eqe.type == MLX4_EVENT_TYPE_NONE)
+			break;
+
+		switch (eqe.type) {
+		case MLX4_EVENT_TYPE_PATH_MIG:
+		case MLX4_EVENT_TYPE_COMM_EST:
+		case MLX4_EVENT_TYPE_SQ_DRAINED:
+		case MLX4_EVENT_TYPE_SRQ_QP_LAST_WQE:
+		case MLX4_EVENT_TYPE_WQ_CATAS_ERROR:
+		case MLX4_EVENT_TYPE_PATH_MIG_FAILED:
+		case MLX4_EVENT_TYPE_WQ_INVAL_REQ_ERROR:
+		case MLX4_EVENT_TYPE_WQ_ACCESS_ERROR:
+			mlx4_qp_event(dev, eqe.param, eqe.type);
+			break;
+
+		case MLX4_EVENT_TYPE_SRQ_LIMIT:
+		case MLX4_EVENT_TYPE_SRQ_CATAS_ERROR:
+			mlx4_srq_event(dev, eqe.param, eqe.type);
+			break;
+
+		case MLX4_EVENT_TYPE_PORT_CHANGE:
+			mlx4_dispatch_event(dev, eqe.param, eqe.port);
+			break;
+
+		case MLX4_EVENT_TYPE_CQ_ERROR:
+			mlx4_cq_event(dev, eqe.param, eqe.type);
+			break;
+
+		case MLX4_EVENT_TYPE_EQ_OVERFLOW:
+			mlx4_warn(dev, "slave async EQ overrun\n");
+			break;
+
+		default:
+			mlx4_warn(dev, "Unhandled event:%02x\n", eqe.type);
+		}
+	}
+	queue_delayed_work(priv->mfunc.comm_wq, &priv->mfunc.comm_work, HZ);
+}
+
 static irqreturn_t mlx4_interrupt(int irq, void *dev_ptr)
 {
 	struct mlx4_dev *dev = dev_ptr;
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 04f42ae..eccac2a 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -555,6 +555,9 @@ int mlx4_QUERY_FW(struct mlx4_dev *dev)
 #define QUERY_FW_CLR_INT_BASE_OFFSET   0x20
 #define QUERY_FW_CLR_INT_BAR_OFFSET    0x28
 
+#define QUERY_FW_COMM_BASE_OFFSET      0x40
+#define QUERY_FW_COMM_BAR_OFFSET       0x48
+
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
@@ -615,6 +618,11 @@ int mlx4_QUERY_FW(struct mlx4_dev *dev)
 	MLX4_GET(fw->clr_int_bar,  outbox, QUERY_FW_CLR_INT_BAR_OFFSET);
 	fw->clr_int_bar = (fw->clr_int_bar >> 6) * 2;
 
+	MLX4_GET(fw->comm_base, outbox, QUERY_FW_COMM_BASE_OFFSET);
+	MLX4_GET(fw->comm_bar,  outbox, QUERY_FW_COMM_BAR_OFFSET);
+	fw->comm_bar = (fw->comm_bar >> 6) * 2;
+	mlx4_dbg(dev, "Communication vector bar:%d offset:0x%llx\n", fw->comm_bar,
+								     fw->comm_base);
 	mlx4_dbg(dev, "FW size %d KB\n", fw->fw_pages >> 2);
 
 	/*
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index bc72d6e..92d0682 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -53,8 +53,11 @@
 
 enum {
 	MLX4_HCR_BASE		= 0x80680,
+	MLX4_HCR_SRIOV_BASE	= 0x4080680, /* good for SRIOV FW ony */
 	MLX4_HCR_SIZE		= 0x0001c,
-	MLX4_CLR_INT_SIZE	= 0x00008
+	MLX4_CLR_INT_SIZE	= 0x00008,
+	MLX4_SLAVE_COMM_BASE	= 0x0,
+	MLX4_COMM_PAGESIZE	= 0x1000
 };
 
 enum {
@@ -80,6 +83,21 @@ enum {
 	MLX4_NUM_CMPTS		= MLX4_CMPT_NUM_TYPE << MLX4_CMPT_SHIFT
 };
 
+#define MLX4_COMM_TIME		10000
+enum {
+	MLX4_COMM_CMD_RESET,
+	MLX4_COMM_CMD_VHCR0,
+	MLX4_COMM_CMD_VHCR1,
+	MLX4_COMM_CMD_VHCR2,
+	MLX4_COMM_CMD_VHCR_EN,
+	MLX4_COMM_CMD_VHCR_POST
+};
+
+enum {
+	MLX4_MFUNC_MAX_EQES     = 8,
+	MLX4_MFUNC_EQE_MASK     = (MLX4_MFUNC_MAX_EQES - 1)
+};
+
 #ifdef CONFIG_MLX4_DEBUG
 extern int mlx4_debug_level;
 #else /* CONFIG_MLX4_DEBUG */
@@ -154,12 +172,56 @@ struct mlx4_profile {
 struct mlx4_fw {
 	u64			clr_int_base;
 	u64			catas_offset;
+	u64			comm_base;
 	struct mlx4_icm	       *fw_icm;
 	struct mlx4_icm	       *aux_icm;
 	u32			catas_size;
 	u16			fw_pages;
 	u8			clr_int_bar;
 	u8			catas_bar;
+	u8			comm_bar;
+};
+
+struct mlx4_comm {
+	u32			slave_write;
+	u32			slave_read;
+};
+
+struct mlx4_slave_eqe {
+	u8 type;
+	u8 port;
+	u32 param;
+};
+
+struct mlx4_slave_state {
+	u8 comm_toggle;
+	u8 last_cmd;
+	dma_addr_t vhcr_dma;
+};
+
+struct mlx4_mfunc_master_ctx {
+	struct mlx4_slave_state *slave_state;
+};
+
+struct mlx4_vhcr {
+	u64	in_param;
+	u64	out_param;
+	u32	in_modifier;
+	u32	timeout;
+	u16	op;
+	u16	token;
+	u8	op_modifier;
+	int	errno;
+};
+
+struct mlx4_mfunc {
+	struct mlx4_comm __iomem       *comm;
+	struct workqueue_struct	       *comm_wq;
+	struct delayed_work	        comm_work;
+	struct mlx4_vhcr	       *vhcr;
+	dma_addr_t			vhcr_dma;
+
+	struct mlx4_mfunc_master_ctx	master;
 };
 
 struct mlx4_cmd {
@@ -175,6 +237,7 @@ struct mlx4_cmd {
 	u16			token_mask;
 	u8			use_events;
 	u8			toggle;
+	u8			comm_toggle;
 };
 
 struct mlx4_uar_table {
@@ -294,6 +357,7 @@ struct mlx4_priv {
 
 	struct mlx4_fw		fw;
 	struct mlx4_cmd		cmd;
+	struct mlx4_mfunc	mfunc;
 
 	struct mlx4_bitmap	pd_bitmap;
 	struct mlx4_uar_table	uar_table;
@@ -370,13 +434,19 @@ u64 mlx4_make_profile(struct mlx4_dev *dev,
 		      struct mlx4_profile *request,
 		      struct mlx4_dev_cap *dev_cap,
 		      struct mlx4_init_hca_param *init_hca);
+void mlx4_slave_async_eq_poll(struct work_struct *work);
 
 int mlx4_cmd_init(struct mlx4_dev *dev);
 void mlx4_cmd_cleanup(struct mlx4_dev *dev);
+int mlx4_multi_func_init(struct mlx4_dev *dev);
+void mlx4_multi_func_cleanup(struct mlx4_dev *dev);
 void mlx4_cmd_event(struct mlx4_dev *dev, u16 token, u8 status, u64 out_param);
 int mlx4_cmd_use_events(struct mlx4_dev *dev);
 void mlx4_cmd_use_polling(struct mlx4_dev *dev);
 
+int mlx4_comm_cmd(struct mlx4_dev *dev, u8 cmd, u16 param, unsigned long timeout);
+
+
 void mlx4_cq_completion(struct mlx4_dev *dev, u32 cqn);
 void mlx4_cq_event(struct mlx4_dev *dev, u32 cqn, int event_type);
 
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 0f82293..b567e63 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -117,6 +117,15 @@ enum {
 	/* miscellaneous commands */
 	MLX4_CMD_DIAG_RPRT	 = 0x30,
 	MLX4_CMD_NOP		 = 0x31,
+	MLX4_CMD_ACCESS_MEM	 = 0x2e,
+
+	/* Ethernet specific commands */
+	MLX4_CMD_SET_VLAN_FLTR	 = 0x47,
+	MLX4_CMD_SET_MCAST_FLTR	 = 0x48,
+	MLX4_CMD_DUMP_ETH_STATS	 = 0x49,
+
+	/* virtual commands */
+	MLX4_CMD_GET_EVENT	 = 0xf03,
 
 	/* debug commands */
 	MLX4_CMD_QUERY_DEBUG_MSG = 0x2a,
@@ -130,7 +139,8 @@ enum {
 };
 
 enum {
-	MLX4_MAILBOX_SIZE	=  4096
+	MLX4_MAILBOX_SIZE	= 4096,
+	MLX4_ACCESS_MEM_ALIGN	= 256,
 };
 
 enum {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index f7f0508..f80b899 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -99,7 +99,8 @@ enum mlx4_event {
 	MLX4_EVENT_TYPE_PORT_CHANGE	   = 0x09,
 	MLX4_EVENT_TYPE_EQ_OVERFLOW	   = 0x0f,
 	MLX4_EVENT_TYPE_ECC_DETECT	   = 0x0e,
-	MLX4_EVENT_TYPE_CMD		   = 0x0a
+	MLX4_EVENT_TYPE_CMD		   = 0x0a,
+	MLX4_EVENT_TYPE_NONE		   = 0xff,
 };
 
 enum {
-- 
1.6.1.3


