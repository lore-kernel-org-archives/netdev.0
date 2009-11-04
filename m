From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 10/25] mlx4_core: track slave special qps
Date: Wed, 04 Nov 2009 17:31:01 +0200
Message-ID: <4AF19E35.5010907@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A single function can own the actual Infiniband hw special qps.
This function demuxes inbound mads and protects outbound mads from spoofing.
To achieve this, it needs to know the special qps used by other functions.

This patch tracks special qp registration and notifies the owning function
on any changes.

Signed-off-by: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/cmd.c      |    2 +
 drivers/net/mlx4/eq.c       |   15 +++++++++
 drivers/net/mlx4/mlx4.h     |   11 +++++++
 drivers/net/mlx4/qp.c       |   67 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/mlx4/cmd.h    |    1 +
 include/linux/mlx4/device.h |    3 ++
 6 files changed, 99 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index 0a7c9c0..29074a0 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -525,6 +525,7 @@ static struct mlx4_cmd_info {
 } cmd_info[] = {
 	{MLX4_CMD_QUERY_FW,        0, 1, 0, NULL, NULL},
 	{MLX4_CMD_QUERY_ADAPTER,   0, 1, 0, NULL, NULL},
+	{MLX4_CMD_GET_SLAVE_SQP,   0, 1, 0, NULL, mlx4_GET_SLAVE_SQP_wrapper},
 
 	{MLX4_CMD_INIT_PORT,       0, 0, 0, NULL, mlx4_INIT_PORT_wrapper},
 	{MLX4_CMD_CLOSE_PORT,      0, 0, 0, NULL, mlx4_CLOSE_PORT_wrapper},
@@ -568,6 +569,7 @@ static struct mlx4_cmd_info {
 	{MLX4_CMD_INIT2INIT_QP,    1, 0, 0, NULL, NULL}, /* need verifier */
 	{MLX4_CMD_SUSPEND_QP,      0, 0, 0, NULL, NULL}, /* need verifier */
 	{MLX4_CMD_UNSUSPEND_QP,    0, 0, 0, NULL, NULL}, /* need verifier */
+	{MLX4_CMD_CONF_SPECIAL_QP, 0, 0, 0, NULL, mlx4_CONF_SPECIAL_QP_wrapper},
 	{MLX4_CMD_MAD_IFC,         1, 1, 0, NULL, NULL}, /* need verifier */
 
 	/* Native multicast commands are not available for guests */
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
index fb1c6f0..b01820f 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -111,6 +111,7 @@ enum mlx4_alloc_mode {
 };
 
 enum {
+	MLX4_MFUNC_MAX		= 64,
 	MLX4_MFUNC_MAX_EQES     = 8,
 	MLX4_MFUNC_EQE_MASK     = (MLX4_MFUNC_MAX_EQES - 1)
 };
@@ -219,6 +220,7 @@ struct mlx4_slave_state {
 	struct mlx4_slave_eqe eq[MLX4_MFUNC_MAX_EQES];
 	u16 eq_pi;
 	u16 eq_ci;
+	int sqp_start;
 	spinlock_t lock;
 };
 
@@ -246,6 +248,7 @@ struct mlx4_mfunc {
 	dma_addr_t			vhcr_dma;
 
 	struct mlx4_mfunc_master_ctx	master;
+	u32				demux_sqp[MLX4_MFUNC_MAX];
 };
 
 struct mlx4_cmd {
@@ -531,6 +534,14 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *v
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
index 065c7fc..99b9ded 100644
--- a/drivers/net/mlx4/qp.c
+++ b/drivers/net/mlx4/qp.c
@@ -145,6 +145,54 @@ int mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
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
+	/* CX1: special qp demultiplexing is done by slave0 */
+	if (slave) {
+		mlx4_warn(dev, "Denying slave_sqp request from slave:%d\n", slave);
+		return -EINVAL;
+	}
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
@@ -331,6 +379,25 @@ static int mlx4_CONF_SPECIAL_QP(struct mlx4_dev *dev, u32 base_qpn)
 			MLX4_CMD_TIME_CLASS_B);
 }
 
+int mlx4_CONF_SPECIAL_QP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+						       struct mlx4_cmd_mailbox *inbox,
+						       struct mlx4_cmd_mailbox *outbox)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int ret;
+
+	priv->mfunc.master.slave_state[slave].sqp_start = vhcr->in_modifier & 0xffffff;
+	if (!slave) {
+		/* CX1: slave0 owns real special QPs */
+		ret = mlx4_CONF_SPECIAL_QP(dev, priv->mfunc.master.slave_state[slave].sqp_start);
+		if (ret)
+			return ret;
+	}
+	/* Notify slave0 that an SQP change occured */
+	mlx4_slave_event(dev, 0, MLX4_EVENT_TYPE_SQP_UPDATE, 0, 0);
+	return 0;
+}
+
 int mlx4_init_qp_table(struct mlx4_dev *dev)
 {
 	struct mlx4_qp_table *qp_table = &mlx4_priv(dev)->qp_table;
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 8265843..f1659f2 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -124,6 +124,7 @@ enum {
 	MLX4_CMD_FREE_RES	 = 0x51,
 	MLX4_CMD_GET_EVENT	 = 0x52,
 	MLX4_CMD_MCAST_ATTACH	 = 0x54,
+	MLX4_CMD_GET_SLAVE_SQP	 = 0x55,
 
 	/* debug commands */
 	MLX4_CMD_QUERY_DEBUG_MSG = 0x2a,
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 9735f40..b20c8d8 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -99,6 +99,7 @@ enum mlx4_event {
 	MLX4_EVENT_TYPE_EQ_OVERFLOW	   = 0x0f,
 	MLX4_EVENT_TYPE_ECC_DETECT	   = 0x0e,
 	MLX4_EVENT_TYPE_CMD		   = 0x0a,
+	MLX4_EVENT_TYPE_SQP_UPDATE	   = 0xfe,
 	MLX4_EVENT_TYPE_NONE		   = 0xff,
 };
 
@@ -242,6 +243,7 @@ struct mlx4_caps {
 	int                     log_num_prios;
 	enum mlx4_port_type	port_type[MLX4_MAX_PORTS + 1];
 	u8			supported_type[MLX4_MAX_PORTS + 1];
+	u8                      sqp_demux;
 	u32			port_mask;
 	enum mlx4_port_type	possible_type[MLX4_MAX_PORTS + 1];
 };
@@ -470,6 +472,7 @@ void mlx4_qp_release_range(struct mlx4_dev *dev, int base_qpn, int cnt);
 
 int mlx4_qp_alloc(struct mlx4_dev *dev, int qpn, struct mlx4_qp *qp);
 void mlx4_qp_free(struct mlx4_dev *dev, struct mlx4_qp *qp);
+u32 mlx4_get_slave_sqp(struct mlx4_dev *dev, int vf);
 
 int mlx4_srq_alloc(struct mlx4_dev *dev, u32 pdn, struct mlx4_mtt *mtt,
 		   u64 db_rec, struct mlx4_srq *srq);
-- 
1.6.1.3




--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
