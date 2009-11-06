From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 09/25 v2] mlx4_core: dispatch slave asynch events
Date: Fri, 06 Nov 2009 05:08:46 +0200
Message-ID: <4AF3933E.2010706@mellanox.co.il>
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

From: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>

Affiliated and unaffiliated asynch events are handled by a single EQ owned by
the master. A per-slave SW event queue is added to log and dispatch both slave-specific
events and events that apply to all slaves.

Signed-off-by: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/cmd.c  |   12 ++++++-
 drivers/net/mlx4/eq.c   |   92 +++++++++++++++++++++++++++++++++++++++++++---
 drivers/net/mlx4/mlx4.h |    8 ++++
 3 files changed, 105 insertions(+), 7 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index b0fd998..634e5c9 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -604,6 +604,14 @@ static struct mlx4_cmd_info {
 		.verify = NULL,
 		.wrapper = mlx4_RESOURCE_wrapper
 	},
+	{
+		.opcode = MLX4_CMD_GET_EVENT,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = true,
+		.verify = NULL,
+		.wrapper = mlx4_GET_EVENT_wrapper
+	},
 
 	{
 		.opcode = MLX4_CMD_SW2HW_MPT,
@@ -1150,8 +1158,10 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 		if (!priv->mfunc.master.slave_state)
 			goto err_comm;
 
-		for (i = 0; i < dev->num_slaves; ++i)
+		for (i = 0; i < dev->num_slaves; ++i) {
 			priv->mfunc.master.slave_state[i].last_cmd = MLX4_COMM_CMD_RESET;
+			spin_lock_init(&priv->mfunc.master.slave_state[i].lock);
+		}
 
 		INIT_DELAYED_WORK(&priv->mfunc.comm_work, mlx4_master_poll_comm);
 		priv->mfunc.comm_wq = create_singlethread_workqueue("mlx4_comm");
diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index 70c16d4..1e8b62d 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -160,6 +160,61 @@ static struct mlx4_eqe *next_eqe_sw(struct mlx4_eq *eq)
 	return !!(eqe->owner & 0x80) ^ !!(eq->cons_index & eq->nent) ? NULL : eqe;
 }
 
+void mlx4_slave_event(struct mlx4_dev *dev, int slave, u8 type, u8 port, u32 param)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_slave_state *ctx = &priv->mfunc.master.slave_state[slave];
+	unsigned long flags;
+
+	if (ctx->last_cmd != MLX4_COMM_CMD_VHCR_POST) {
+		mlx4_warn(dev, "received event for inactive slave:%d\n", slave);
+		return;
+	}
+
+	/* Unconditionally add the new event - during overflows, we drop the
+	 * oldest events */
+	spin_lock_irqsave(&ctx->lock, flags);
+	ctx->eq[ctx->eq_pi & MLX4_MFUNC_EQE_MASK].type = type;
+	ctx->eq[ctx->eq_pi & MLX4_MFUNC_EQE_MASK].port = port;
+	ctx->eq[ctx->eq_pi & MLX4_MFUNC_EQE_MASK].param = param;
+	++ctx->eq_pi;
+	spin_unlock_irqrestore(&ctx->lock, flags);
+}
+
+static void mlx4_slave_event_all(struct mlx4_dev *dev, u8 type, u8 port, u32 param)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int i;
+
+	for (i = 0; i < dev->num_slaves; ++i)
+		if (priv->mfunc.master.slave_state[i].last_cmd == MLX4_COMM_CMD_VHCR_POST)
+			mlx4_slave_event(dev, i, type, port, param);
+}
+
+int mlx4_GET_EVENT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+						 struct mlx4_cmd_mailbox *inbox,
+						 struct mlx4_cmd_mailbox *outbox)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_slave_state *ctx = &priv->mfunc.master.slave_state[slave];
+	unsigned long flags;
+
+	spin_lock_irqsave(&ctx->lock, flags);
+	if (ctx->eq_ci == ctx->eq_pi) {
+		vhcr->out_param = MLX4_EVENT_TYPE_NONE;
+	} else if ((u16) (ctx->eq_pi - ctx->eq_ci) > MLX4_MFUNC_MAX_EQES) {
+		ctx->eq_ci = ctx->eq_pi - MLX4_MFUNC_MAX_EQES;
+		vhcr->out_param = MLX4_EVENT_TYPE_EQ_OVERFLOW;
+	} else {
+		vhcr->out_param = ctx->eq[ctx->eq_ci & MLX4_MFUNC_EQE_MASK].type |
+				  ((u64) ctx->eq[ctx->eq_ci & MLX4_MFUNC_EQE_MASK].port << 8) |
+				  ((u64) ctx->eq[ctx->eq_ci & MLX4_MFUNC_EQE_MASK].param << 32);
+		++ctx->eq_ci;
+	}
+	spin_unlock_irqrestore(&ctx->lock, flags);
+	return 0;
+}
+
 static int mlx4_GET_EVENT(struct mlx4_dev *dev, struct mlx4_slave_eqe *eqe)
 {
 	int ret;
@@ -205,14 +260,26 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 		case MLX4_EVENT_TYPE_PATH_MIG_FAILED:
 		case MLX4_EVENT_TYPE_WQ_INVAL_REQ_ERROR:
 		case MLX4_EVENT_TYPE_WQ_ACCESS_ERROR:
-			mlx4_qp_event(dev, be32_to_cpu(eqe->event.qp.qpn) & 0xffffff,
-				      eqe->type);
+			if (mlx4_is_master(dev)) {
+				/* TODO: forward only to slave owning the QP */
+				mlx4_slave_event(dev, 0, eqe->type, 0,
+					      be32_to_cpu(eqe->event.qp.qpn) &
+					      0xffffff);
+			} else
+				mlx4_qp_event(dev, be32_to_cpu(eqe->event.qp.qpn) &
+						   0xffffff, eqe->type);
 			break;
 
 		case MLX4_EVENT_TYPE_SRQ_LIMIT:
 		case MLX4_EVENT_TYPE_SRQ_CATAS_ERROR:
-			mlx4_srq_event(dev, be32_to_cpu(eqe->event.srq.srqn) & 0xffffff,
-				      eqe->type);
+			if (mlx4_is_master(dev)) {
+				/* TODO: forward only to slave owning the SRQ */
+				mlx4_slave_event(dev, 0, eqe->type, 0,
+					      be32_to_cpu(eqe->event.srq.srqn) &
+					      0xffffff);
+			} else
+				mlx4_srq_event(dev, be32_to_cpu(eqe->event.srq.srqn) &
+						    0xffffff, eqe->type);
 			break;
 
 		case MLX4_EVENT_TYPE_CMD:
@@ -227,10 +294,18 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 			if (eqe->subtype == MLX4_PORT_CHANGE_SUBTYPE_DOWN) {
 				mlx4_dispatch_event(dev, MLX4_DEV_EVENT_PORT_DOWN,
 						    port);
+				if (mlx4_is_master(dev)) {
+					mlx4_slave_event_all(dev, MLX4_EVENT_TYPE_PORT_CHANGE,
+							     port, MLX4_DEV_EVENT_PORT_DOWN);
+				}
 				mlx4_priv(dev)->sense.do_sense_port[port] = 1;
 			} else {
 				mlx4_dispatch_event(dev, MLX4_DEV_EVENT_PORT_UP,
 						    port);
+				if (mlx4_is_master(dev)) {
+					mlx4_slave_event_all(dev, MLX4_EVENT_TYPE_PORT_CHANGE,
+							     port, MLX4_DEV_EVENT_PORT_UP);
+				}
 				mlx4_priv(dev)->sense.do_sense_port[port] = 0;
 			}
 			break;
@@ -240,8 +315,13 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 				  eqe->event.cq_err.syndrome == 1 ?
 				  "overrun" : "access violation",
 				  be32_to_cpu(eqe->event.cq_err.cqn) & 0xffffff);
-			mlx4_cq_event(dev, be32_to_cpu(eqe->event.cq_err.cqn),
-				      eqe->type);
+			if (mlx4_is_master(dev)) {
+				/* TODO: forward only to slave owning the CQ */
+				mlx4_slave_event(dev, 0, eqe->type, 0,
+					      be32_to_cpu(eqe->event.cq_err.cqn));
+			} else
+				mlx4_cq_event(dev, be32_to_cpu(eqe->event.cq_err.cqn),
+									   eqe->type);
 			break;
 
 		case MLX4_EVENT_TYPE_EQ_OVERFLOW:
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 8565be5..f680940 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -216,6 +216,10 @@ struct mlx4_slave_state {
 	u8 init_port_mask;
 	dma_addr_t vhcr_dma;
 	__be32 ib_cap_mask[MLX4_MAX_PORTS + 1];
+	struct mlx4_slave_eqe eq[MLX4_MFUNC_MAX_EQES];
+	u16 eq_pi;
+	u16 eq_ci;
+	spinlock_t lock;
 };
 
 struct mlx4_mfunc_master_ctx {
@@ -422,6 +426,10 @@ int mlx4_reset(struct mlx4_dev *dev);
 
 int mlx4_alloc_eq_table(struct mlx4_dev *dev);
 void mlx4_free_eq_table(struct mlx4_dev *dev);
+void mlx4_slave_event(struct mlx4_dev *dev, int slave, u8 type, u8 port, u32 param);
+int mlx4_GET_EVENT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+						 struct mlx4_cmd_mailbox *inbox,
+						 struct mlx4_cmd_mailbox *outbox);
 
 int mlx4_init_pd_table(struct mlx4_dev *dev);
 int mlx4_init_uar_table(struct mlx4_dev *dev);
-- 
1.5.3.7

From: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>





--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
