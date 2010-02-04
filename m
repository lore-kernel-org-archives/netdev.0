From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 08/23 v3] mlx4_core: track slave special qps
Date: Thu, 04 Feb 2010 17:55:26 +0200
Message-ID: <4B6AEDEE.80505@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49671 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933124Ab0BDPz3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:55:29 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A single function can own the actual Infiniband hw special qps.
This function demuxes inbound mads and protects outbound mads from spoofing.
To achieve this, it needs to know the special qps used by other functions.

This patch tracks special qp registration and notifies the owning function
on any changes.

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/cmd.c      |   16 +++++++++++++
 drivers/net/mlx4/eq.c       |   15 ++++++++++++
 drivers/net/mlx4/mlx4.h     |   11 +++++++++
 drivers/net/mlx4/qp.c       |   53 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/mlx4/cmd.h    |    1 +
 include/linux/mlx4/device.h |    3 ++
 6 files changed, 99 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index 6a75528..882b454 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -556,6 +556,14 @@ static struct mlx4_cmd_info {
 		.verify = NULL,
 		.wrapper = NULL
 	},
+	{
+		.opcode = MLX4_CMD_GET_SLAVE_SQP,
+		.has_inbox = false,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.verify = NULL,
+		.wrapper = mlx4_GET_SLAVE_SQP_wrapper
+	},
 
 	{
 		.opcode = MLX4_CMD_INIT_PORT,
@@ -880,6 +888,14 @@ static struct mlx4_cmd_info {
 		.wrapper = NULL
 	},
 	{
+		.opcode = MLX4_CMD_CONF_SPECIAL_QP,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL,
+		.wrapper = mlx4_CONF_SPECIAL_QP_wrapper
+	},
+	{
 		.opcode = MLX4_CMD_MAD_IFC,
 		.has_inbox = true,
 		.has_outbox = true,
diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index 1e8b62d..a27e1c4 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -358,6 +358,17 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 	return eqes_found;
 }
 
+static void mlx4_update_sqp(struct mlx4_dev *dev)
+{
+	if (!dev->caps.sqp_demux) {
+		mlx4_warn(dev, "unexpected update_sqp event\n");
+		return;
+	}
+	if (mlx4_GET_SLAVE_SQP(dev, mlx4_priv(dev)->mfunc.demux_sqp,
+			       dev->caps.sqp_demux))
+		mlx4_warn(dev, "couldn't update sqp\n");
+}
+
 void mlx4_slave_async_eq_poll(struct work_struct *work)
 {
 	struct delayed_work *delay = container_of(work, struct delayed_work, work);
@@ -402,6 +413,10 @@ void mlx4_slave_async_eq_poll(struct work_struct *work)
 			mlx4_warn(dev, "slave async EQ overrun\n");
 			break;
 
+		case MLX4_EVENT_TYPE_SQP_UPDATE:
+			mlx4_update_sqp(dev);
+			break;
+
 		default:
 			mlx4_warn(dev, "Unhandled event:%02x\n", eqe.type);
 		}
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index e7c0f42..800afe4 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -114,6 +114,7 @@ enum mlx4_alloc_mode {
 };
 
 enum {
+	MLX4_MFUNC_MAX		= 64,
 	MLX4_MFUNC_MAX_EQES     = 8,
 	MLX4_MFUNC_EQE_MASK     = (MLX4_MFUNC_MAX_EQES - 1)
 };
@@ -223,6 +224,7 @@ struct mlx4_slave_state {
 	struct mlx4_slave_eqe eq[MLX4_MFUNC_MAX_EQES];
 	u16 eq_pi;
 	u16 eq_ci;
+	int sqp_start;
 	spinlock_t lock;
 };
 
@@ -251,6 +253,7 @@ struct mlx4_mfunc {
 	dma_addr_t			vhcr_dma;
 
 	struct mlx4_mfunc_master_ctx	master;
+	u32				demux_sqp[MLX4_MFUNC_MAX];
 };
 
 struct mlx4_cmd {
@@ -534,6 +537,14 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *v
 							  struct mlx4_cmd_mailbox *outbox);
 int mlx4_get_port_ib_caps(struct mlx4_dev *dev, u8 port, __be32 *caps);
 
+int mlx4_CONF_SPECIAL_QP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+						       struct mlx4_cmd_mailbox *inbox,
+						       struct mlx4_cmd_mailbox *outbox);
+int mlx4_GET_SLAVE_SQP(struct mlx4_dev *dev, u32 *sqp, int num);
+int mlx4_GET_SLAVE_SQP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+							  struct mlx4_cmd_mailbox *inbox,
+							  struct mlx4_cmd_mailbox *outbox);
+
 int mlx4_MCAST_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
 						     struct mlx4_cmd_mailbox *inbox,
 						     struct mlx4_cmd_mailbox *outbox);
diff --git a/drivers/net/mlx4/qp.c b/drivers/net/mlx4/qp.c
index 065c7fc..7ec59f0 100644
--- a/drivers/net/mlx4/qp.c
+++ b/drivers/net/mlx4/qp.c
@@ -145,6 +145,49 @@ int mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 }
 EXPORT_SYMBOL_GPL(mlx4_qp_modify);
 
+u32 mlx4_get_slave_sqp(struct mlx4_dev *dev, int slave)
+{
+	if (mlx4_is_master(dev) && slave < dev->num_slaves) {
+		return mlx4_priv(dev)->mfunc.master.slave_state[slave].sqp_start;
+	}
+	if (mlx4_is_slave(dev) && slave < dev->caps.sqp_demux) {
+		return mlx4_priv(dev)->mfunc.demux_sqp[slave];
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx4_get_slave_sqp);
+
+int mlx4_GET_SLAVE_SQP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+							  struct mlx4_cmd_mailbox *inbox,
+							  struct mlx4_cmd_mailbox *outbox)
+{
+	u32 *slave_sqp = outbox->buf;
+	int i;
+
+	for (i = 0; i < 64; i++)
+		slave_sqp[i] = mlx4_get_slave_sqp(dev, i);
+	return 0;
+}
+
+int mlx4_GET_SLAVE_SQP(struct mlx4_dev *dev, u32 *sqp, int num)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	int err;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	err = mlx4_cmd_box(dev, 0, mailbox->dma, 0, 0, MLX4_CMD_GET_SLAVE_SQP,
+			   MLX4_CMD_TIME_CLASS_A);
+	if (!err)
+		memcpy(sqp, mailbox->buf, sizeof (u32) * num);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx4_GET_SLAVE_SQP);
+
 int mlx4_qp_reserve_range(struct mlx4_dev *dev, int cnt, int align, int *base)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -331,6 +374,16 @@ static int mlx4_CONF_SPECIAL_QP(struct mlx4_dev *dev, u32 base_qpn)
 			MLX4_CMD_TIME_CLASS_B);
 }
 
+int mlx4_CONF_SPECIAL_QP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+						       struct mlx4_cmd_mailbox *inbox,
+						       struct mlx4_cmd_mailbox *outbox)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	priv->mfunc.master.slave_state[slave].sqp_start = vhcr->in_modifier & 0xffffff;
+	return 0;
+}
+
 int mlx4_init_qp_table(struct mlx4_dev *dev)
 {
 	struct mlx4_qp_table *qp_table = &mlx4_priv(dev)->qp_table;
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 26390ab..9e6395f 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -130,6 +130,7 @@ enum {
 	MLX4_CMD_REPLACE_RES	 = 0xf02,
 	MLX4_CMD_GET_EVENT	 = 0xf03,
 	MLX4_CMD_MCAST_ATTACH	 = 0xf05,
+	MLX4_CMD_GET_SLAVE_SQP	 = 0xf06,
 
 	/* debug commands */
 	MLX4_CMD_QUERY_DEBUG_MSG = 0x2a,
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index b557793..86e715c 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -100,6 +100,7 @@ enum mlx4_event {
 	MLX4_EVENT_TYPE_EQ_OVERFLOW	   = 0x0f,
 	MLX4_EVENT_TYPE_ECC_DETECT	   = 0x0e,
 	MLX4_EVENT_TYPE_CMD		   = 0x0a,
+	MLX4_EVENT_TYPE_SQP_UPDATE	   = 0xfe,
 	MLX4_EVENT_TYPE_NONE		   = 0xff,
 };
 
@@ -243,6 +244,7 @@ struct mlx4_caps {
 	int                     log_num_prios;
 	enum mlx4_port_type	port_type[MLX4_MAX_PORTS + 1];
 	u8			supported_type[MLX4_MAX_PORTS + 1];
+	u8                      sqp_demux;
 	u32			port_mask;
 	enum mlx4_port_type	possible_type[MLX4_MAX_PORTS + 1];
 };
@@ -471,6 +473,7 @@ void mlx4_qp_release_range(struct mlx4_dev *dev, int base_qpn, int cnt);
 
 int mlx4_qp_alloc(struct mlx4_dev *dev, int qpn, struct mlx4_qp *qp);
 void mlx4_qp_free(struct mlx4_dev *dev, struct mlx4_qp *qp);
+u32 mlx4_get_slave_sqp(struct mlx4_dev *dev, int vf);
 
 int mlx4_srq_alloc(struct mlx4_dev *dev, u32 pdn, struct mlx4_mtt *mtt,
 		   u64 db_rec, struct mlx4_srq *srq);
-- 
1.6.1.3


