From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 07/25] mlx4_core: add port para-virtualization
Date: Wed, 04 Nov 2009 17:30:47 +0200
Message-ID: <4AF19E27.3060808@mellanox.co.il>
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

Ports are a shared resource among functions, so special behavior is needed here:
- Bring up ports if at least one function has done so.
- Bring down ports if all functions have done so.
- Aggregate IB port capabilities

Signed-off-by: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/cmd.c  |    5 +++
 drivers/net/mlx4/fw.c   |   55 ++++++++++++++++++++++++++++++++++
 drivers/net/mlx4/mlx4.h |   16 ++++++++++
 drivers/net/mlx4/port.c |   76 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 152 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index dd23aba..d2646d1 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -526,6 +526,11 @@ static struct mlx4_cmd_info {
 	{MLX4_CMD_QUERY_FW,        0, 1, 0, NULL, NULL},
 	{MLX4_CMD_QUERY_ADAPTER,   0, 1, 0, NULL, NULL},
 
+	{MLX4_CMD_INIT_PORT,       0, 0, 0, NULL, mlx4_INIT_PORT_wrapper},
+	{MLX4_CMD_CLOSE_PORT,      0, 0, 0, NULL, mlx4_CLOSE_PORT_wrapper},
+	{MLX4_CMD_QUERY_PORT,      0, 1, 0, NULL, mlx4_QUERY_PORT_wrapper},
+	{MLX4_CMD_SET_PORT,        1, 0, 0, NULL, mlx4_SET_PORT_wrapper},
+
 	{MLX4_CMD_SW2HW_EQ,        1, 0, 0, NULL, NULL}, /* need verifier */
 	{MLX4_CMD_NOP,             0, 0, 0, NULL, NULL},
 	{MLX4_CMD_ALLOC_RES,	   0, 0, 1, NULL, mlx4_RESOURCE_wrapper},
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 4ca8060..a63f84a 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -135,6 +135,14 @@ int mlx4_MOD_STAT_CFG(struct mlx4_dev *dev, struct mlx4_mod_stat_cfg *cfg)
 	return err;
 }
 
+int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+							  struct mlx4_cmd_mailbox *inbox,
+							  struct mlx4_cmd_mailbox *outbox)
+{
+	return mlx4_cmd_box(dev, 0, outbox->dma, vhcr->in_modifier, 0, MLX4_CMD_QUERY_PORT,
+					   MLX4_CMD_TIME_CLASS_B);
+}
+
 int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 {
 	struct mlx4_cmd_mailbox *mailbox;
@@ -809,6 +817,29 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 	return err;
 }
 
+int mlx4_INIT_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+							 struct mlx4_cmd_mailbox *inbox,
+							 struct mlx4_cmd_mailbox *outbox)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int port;
+	int err;
+
+	port = vhcr->in_modifier;
+	if (priv->mfunc.master.slave_state[slave].init_port_mask & (1 << port))
+		return 0;
+
+	/* Enable port only if it was previously disabled */
+	if (!priv->mfunc.master.init_port_ref[port]) {
+		err = mlx4_INIT_PORT(dev, port);
+		if (err)
+			return err;
+	}
+	++priv->mfunc.master.init_port_ref[port];
+	priv->mfunc.master.slave_state[slave].init_port_mask |= (1 << port);
+	return 0;
+}
+
 int mlx4_INIT_PORT(struct mlx4_dev *dev, int port)
 {
 	struct mlx4_cmd_mailbox *mailbox;
@@ -863,6 +894,30 @@ int mlx4_INIT_PORT(struct mlx4_dev *dev, int port)
 }
 EXPORT_SYMBOL_GPL(mlx4_INIT_PORT);
 
+int mlx4_CLOSE_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+							  struct mlx4_cmd_mailbox *inbox,
+							  struct mlx4_cmd_mailbox *outbox)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int port;
+	int err;
+
+	port = vhcr->in_modifier;
+	if (!(priv->mfunc.master.slave_state[slave].init_port_mask & (1 << port)))
+		return 0;
+
+	/* CX1: master doesn't have interfaces - close port if this slave is
+	 * the last user */
+	if (priv->mfunc.master.init_port_ref[port] == 1) {
+		err = mlx4_CLOSE_PORT(dev, port);
+		if (err)
+			return err;
+	}
+	--priv->mfunc.master.init_port_ref[port];
+	priv->mfunc.master.slave_state[slave].init_port_mask &= ~(1 << port);
+	return 0;
+}
+
 int mlx4_CLOSE_PORT(struct mlx4_dev *dev, int port)
 {
 	return mlx4_cmd(dev, 0, port, 0, MLX4_CMD_CLOSE_PORT, 1000);
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index fafa293..8a7a041 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -46,6 +46,7 @@
 #include <linux/mlx4/driver.h>
 #include <linux/mlx4/doorbell.h>
 #include <linux/mlx4/cmd.h>
+#include <rdma/ib_verbs.h>
 
 #define DRV_NAME	"mlx4_core"
 #define PFX		DRV_NAME ": "
@@ -212,11 +213,14 @@ struct mlx4_slave_eqe {
 struct mlx4_slave_state {
 	u8 comm_toggle;
 	u8 last_cmd;
+	u8 init_port_mask;
 	dma_addr_t vhcr_dma;
+	__be32 ib_cap_mask[MLX4_MAX_PORTS + 1];
 };
 
 struct mlx4_mfunc_master_ctx {
 	struct mlx4_slave_state *slave_state;
+	int			init_port_ref[MLX4_MAX_PORTS + 1];
 };
 
 struct mlx4_vhcr {
@@ -505,6 +509,18 @@ void mlx4_init_mac_table(struct mlx4_dev *dev, struct mlx4_mac_table *table);
 void mlx4_init_vlan_table(struct mlx4_dev *dev, struct mlx4_vlan_table *table);
 
 int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port);
+int mlx4_SET_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+							struct mlx4_cmd_mailbox *inbox,
+							struct mlx4_cmd_mailbox *outbox);
+int mlx4_INIT_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+							 struct mlx4_cmd_mailbox *inbox,
+							 struct mlx4_cmd_mailbox *outbox);
+int mlx4_CLOSE_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+							  struct mlx4_cmd_mailbox *inbox,
+							  struct mlx4_cmd_mailbox *outbox);
+int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+							  struct mlx4_cmd_mailbox *inbox,
+							  struct mlx4_cmd_mailbox *outbox);
 int mlx4_get_port_ib_caps(struct mlx4_dev *dev, u8 port, __be32 *caps);
 
 int mlx4_MCAST_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
diff --git a/drivers/net/mlx4/port.c b/drivers/net/mlx4/port.c
index 606aa58..67f0751 100644
--- a/drivers/net/mlx4/port.c
+++ b/drivers/net/mlx4/port.c
@@ -294,6 +294,82 @@ int mlx4_get_port_ib_caps(struct mlx4_dev *dev, u8 port, __be32 *caps)
 	return err;
 }
 
+int mlx4_SET_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+							struct mlx4_cmd_mailbox *inbox,
+							struct mlx4_cmd_mailbox *outbox)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int reset_qkey_viols;
+	int port;
+	int is_eth;
+	int err;
+	int i;
+	__be32 agg_cap_mask;
+	__be32 slave_cap_mask;
+	__be32 new_cap_mask;
+
+	port = vhcr->in_modifier & 0xff;
+	is_eth = vhcr->op_modifier;
+
+	/* For Ethernet, we currently support only slave0.
+	 * TODO: add multi-vf support */
+	if (is_eth) {
+		if (slave)
+			return -EINVAL;
+		return mlx4_cmd(dev, inbox->dma, vhcr->in_modifier,
+						 vhcr->op_modifier,
+						 MLX4_CMD_SET_PORT,
+						 MLX4_CMD_TIME_CLASS_B);
+	}
+
+	/* For IB, we only consider:
+	 * - The capability mask, which is set to the aggregate of all slave frunction
+	 *   capabilities
+	 * - The QKey violatin counter - reset according to each request.
+	 */
+
+	if (dev->flags & MLX4_FLAG_OLD_PORT_CMDS) {
+		reset_qkey_viols = (*(u8 *) inbox->buf) & 0x40;
+		new_cap_mask = ((__be32 *) inbox->buf)[2];
+	} else {
+		reset_qkey_viols = ((u8 *) inbox->buf)[3] & 0x1;
+		new_cap_mask = ((__be32 *) inbox->buf)[1];
+	}
+
+	/* CX1: only slave0 has access to qp0 */
+	if (slave && (new_cap_mask & cpu_to_be32(IB_PORT_SM))) {
+		mlx4_warn(dev, "denying sm port capability for slave:%d\n", slave);
+		return -EINVAL;
+	}
+
+	agg_cap_mask = 0;
+	slave_cap_mask = priv->mfunc.master.slave_state[slave].ib_cap_mask[port];
+	priv->mfunc.master.slave_state[slave].ib_cap_mask[port] = new_cap_mask;
+	for (i = 0; i < dev->num_slaves; i++)
+		agg_cap_mask |= priv->mfunc.master.slave_state[slave].ib_cap_mask[port];
+
+#if 0
+	mlx4_warn(dev, "old_slave_cap:0x%x slave_cap:0x%x cap:0x%x qkey_reset:%d\n",
+			slave_cap_mask, priv->mfunc.master.slave_state[slave].ib_cap_mask[port],
+			agg_cap_mask, reset_qkey_viols);
+#endif
+
+	memset(inbox->buf, 0, 256);
+	if (dev->flags & MLX4_FLAG_OLD_PORT_CMDS) {
+		*(u8 *) inbox->buf	   = !!reset_qkey_viols << 6;
+		((__be32 *) inbox->buf)[2] = agg_cap_mask;
+	} else {
+		((u8 *) inbox->buf)[3]     = !!reset_qkey_viols;
+		((__be32 *) inbox->buf)[1] = agg_cap_mask;
+	}
+
+	err = mlx4_cmd(dev, inbox->dma, port, is_eth, MLX4_CMD_SET_PORT,
+		       MLX4_CMD_TIME_CLASS_B);
+	if (err)
+		priv->mfunc.master.slave_state[slave].ib_cap_mask[port] = slave_cap_mask;
+	return err;
+}
+
 int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port)
 {
 	struct mlx4_cmd_mailbox *mailbox;
-- 
1.6.1.3




--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
