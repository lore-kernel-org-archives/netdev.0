From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 06/23 v3] mlx4_core: add port para-virtualization
Date: Thu, 04 Feb 2010 17:55:11 +0200
Message-ID: <4B6AEDDF.10803@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49642 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933079Ab0BDPzO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:55:14 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ports are a shared resource among functions, so special behavior is needed here:
- Bring up ports if at least one function has done so.
- Bring down ports if all functions have done so.
- Aggregate IB port capabilities
- Set max mtu among for Eth port
- Ensure steering is not broken for Eth ports.

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/cmd.c       |   58 +++++++++++
 drivers/net/mlx4/en_netdev.c |   32 +++---
 drivers/net/mlx4/en_port.c   |    1 +
 drivers/net/mlx4/en_port.h   |    9 +-
 drivers/net/mlx4/en_rx.c     |   11 +--
 drivers/net/mlx4/fw.c        |   79 ++++++++++++++-
 drivers/net/mlx4/main.c      |   22 +++--
 drivers/net/mlx4/mlx4.h      |   25 +++++-
 drivers/net/mlx4/port.c      |  220 +++++++++++++++++++++++++++++++++++++----
 include/linux/mlx4/cmd.h     |    2 +
 include/linux/mlx4/device.h  |    5 +-
 11 files changed, 397 insertions(+), 67 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index 5433f3b..c1f2905 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -505,6 +505,24 @@ static int mlx4_RESOURCE_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vh
 		} else
 			mlx4_free_mtt_range(dev, param1 /* first */, param2 /* order */);
 		break;
+	case RES_MAC:
+		switch (vhcr->op) {
+		case MLX4_CMD_ALLOC_RES:
+			ret = mlx4_register_mac(dev, vhcr->op_modifier,
+						vhcr->in_param, (int *) &vhcr->out_param);
+			vhcr->errno = ret;
+			break;
+		case MLX4_CMD_FREE_RES:
+			mlx4_unregister_mac(dev, vhcr->op_modifier, vhcr->in_param);
+			break;
+		case MLX4_CMD_REPLACE_RES:
+			ret = mlx4_replace_mac(dev, vhcr->op_modifier,
+					       vhcr->out_param, vhcr->in_param);
+			vhcr->errno = ret;
+			break;
+		default:
+			vhcr->errno = -EINVAL;
+		}
 	default:
 		vhcr->errno = -EINVAL;
 	}
@@ -540,6 +558,38 @@ static struct mlx4_cmd_info {
 	},
 
 	{
+		.opcode = MLX4_CMD_INIT_PORT,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL,
+		.wrapper = mlx4_INIT_PORT_wrapper},
+	{
+		.opcode = MLX4_CMD_CLOSE_PORT,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm  = false,
+		.verify = NULL,
+		.wrapper = mlx4_CLOSE_PORT_wrapper
+	},
+	{
+		.opcode = MLX4_CMD_QUERY_PORT,
+		.has_inbox = false,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.verify = NULL,
+		.wrapper = mlx4_QUERY_PORT_wrapper
+	},
+	{
+		.opcode = MLX4_CMD_SET_PORT,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL,
+		.wrapper = mlx4_SET_PORT_wrapper
+	},
+
+	{
 		.opcode = MLX4_CMD_SW2HW_EQ,
 		.has_inbox = true,
 		.has_outbox = false,
@@ -573,6 +623,14 @@ static struct mlx4_cmd_info {
 	},
 
 	{
+		.opcode = MLX4_CMD_REPLACE_RES,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = true,
+		.verify = NULL,
+		.wrapper = mlx4_RESOURCE_wrapper
+	},
+	{
 		.opcode = MLX4_CMD_SW2HW_MPT,
 		.has_inbox = true,
 		.has_outbox = false,
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index c48b0f4..fd96078 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -145,9 +145,8 @@ static void mlx4_en_do_set_mac(struct work_struct *work)
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		/* Remove old MAC and insert the new one */
-		mlx4_unregister_mac(mdev->dev, priv->port, priv->mac_index);
-		err = mlx4_register_mac(mdev->dev, priv->port,
-					priv->mac, &priv->mac_index);
+		err = mlx4_replace_mac(mdev->dev, priv->port,
+				       priv->base_qpn, priv->mac);
 		if (err)
 			en_err(priv, "Failed changing HW MAC address\n");
 	} else
@@ -596,10 +595,19 @@ int mlx4_en_start_port(struct net_device *dev)
 		++rx_index;
 	}
 
+	/* Set port mac number */
+	en_dbg(DRV, priv, "Setting mac for port %d\n", priv->port);
+	err = mlx4_register_mac(mdev->dev, priv->port,
+				priv->mac, &priv->base_qpn);
+	if (err) {
+		en_err(priv, "Failed setting port mac\n");
+		goto cq_err;
+	}
+
 	err = mlx4_en_config_rss_steer(priv);
 	if (err) {
 		en_err(priv, "Failed configuring rss steering\n");
-		goto cq_err;
+		goto mac_err;
 	}
 
 	/* Configure tx cq's and rings */
@@ -652,21 +660,13 @@ int mlx4_en_start_port(struct net_device *dev)
 		en_err(priv, "Failed setting default qp numbers\n");
 		goto tx_err;
 	}
-	/* Set port mac number */
-	en_dbg(DRV, priv, "Setting mac for port %d\n", priv->port);
-	err = mlx4_register_mac(mdev->dev, priv->port,
-				priv->mac, &priv->mac_index);
-	if (err) {
-		en_err(priv, "Failed setting port mac\n");
-		goto tx_err;
-	}
 
 	/* Init port */
 	en_dbg(HW, priv, "Initializing port\n");
 	err = mlx4_INIT_PORT(mdev->dev, priv->port);
 	if (err) {
 		en_err(priv, "Failed Initializing port\n");
-		goto mac_err;
+		goto tx_err;
 	}
 
 	/* Schedule multicast task to populate multicast list */
@@ -676,8 +676,6 @@ int mlx4_en_start_port(struct net_device *dev)
 	netif_tx_start_all_queues(dev);
 	return 0;
 
-mac_err:
-	mlx4_unregister_mac(mdev->dev, priv->port, priv->mac_index);
 tx_err:
 	while (tx_index--) {
 		mlx4_en_deactivate_tx_ring(priv, &priv->tx_ring[tx_index]);
@@ -685,6 +683,8 @@ tx_err:
 	}
 
 	mlx4_en_release_rss_steer(priv);
+mac_err:
+	mlx4_unregister_mac(mdev->dev, priv->port, priv->base_qpn);
 cq_err:
 	while (rx_index--)
 		mlx4_en_deactivate_cq(priv, &priv->rx_cq[rx_index]);
@@ -716,7 +716,7 @@ void mlx4_en_stop_port(struct net_device *dev)
 	mlx4_CLOSE_PORT(mdev->dev, priv->port);
 
 	/* Unregister Mac address for the port */
-	mlx4_unregister_mac(mdev->dev, priv->port, priv->mac_index);
+	mlx4_unregister_mac(mdev->dev, priv->port, priv->base_qpn);
 
 	/* Free TX Rings */
 	for (i = 0; i < priv->tx_ring_num; i++) {
diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index a29abe8..c099cb4 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -127,6 +127,7 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 	memset(context, 0, sizeof *context);
 
 	context->base_qpn = cpu_to_be32(base_qpn);
+	context->n_mac = 0x7;
 	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_SHIFT | base_qpn);
 	context->mcast = cpu_to_be32(1 << SET_PORT_PROMISC_SHIFT | base_qpn);
 	context->intra_no_vlan = 0;
diff --git a/drivers/net/mlx4/en_port.h b/drivers/net/mlx4/en_port.h
index 3892896..fc49733 100644
--- a/drivers/net/mlx4/en_port.h
+++ b/drivers/net/mlx4/en_port.h
@@ -54,14 +54,17 @@ struct mlx4_set_port_general_context {
 
 struct mlx4_set_port_rqp_calc_context {
 	__be32 base_qpn;
-	__be32 flags;
-	u8 reserved[3];
+	u8 rererved;
+	u8 n_mac;
+	u8 n_vlan;
+	u8 n_prio;
+	u8 reserved2[3];
 	u8 mac_miss;
 	u8 intra_no_vlan;
 	u8 no_vlan;
 	u8 intra_vlan_miss;
 	u8 vlan_miss;
-	u8 reserved2[3];
+	u8 reserved3[3];
 	u8 no_vlan_prio;
 	__be32 promisc;
 	__be32 mcast;
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 829b9ec..cd0dc14 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -865,16 +865,10 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	}
 
 	/* Configure RSS indirection qp */
-	err = mlx4_qp_reserve_range(mdev->dev, 1, 1, &priv->base_qpn);
-	if (err) {
-		en_err(priv, "Failed to reserve range for RSS "
-			     "indirection qp\n");
-		goto rss_err;
-	}
 	err = mlx4_qp_alloc(mdev->dev, priv->base_qpn, &rss_map->indir_qp);
 	if (err) {
 		en_err(priv, "Failed to allocate RSS indirection QP\n");
-		goto reserve_err;
+		goto rss_err;
 	}
 	rss_map->indir_qp.event = mlx4_en_sqp_event;
 	mlx4_en_fill_qp_context(priv, 0, 0, 0, 1, priv->base_qpn,
@@ -900,8 +894,6 @@ indir_err:
 		       MLX4_QP_STATE_RST, NULL, 0, 0, &rss_map->indir_qp);
 	mlx4_qp_remove(mdev->dev, &rss_map->indir_qp);
 	mlx4_qp_free(mdev->dev, &rss_map->indir_qp);
-reserve_err:
-	mlx4_qp_release_range(mdev->dev, priv->base_qpn, 1);
 rss_err:
 	for (i = 0; i < good_qps; i++) {
 		mlx4_qp_modify(mdev->dev, NULL, rss_map->state[i],
@@ -923,7 +915,6 @@ void mlx4_en_release_rss_steer(struct mlx4_en_priv *priv)
 		       MLX4_QP_STATE_RST, NULL, 0, 0, &rss_map->indir_qp);
 	mlx4_qp_remove(mdev->dev, &rss_map->indir_qp);
 	mlx4_qp_free(mdev->dev, &rss_map->indir_qp);
-	mlx4_qp_release_range(mdev->dev, priv->base_qpn, 1);
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		mlx4_qp_modify(mdev->dev, NULL, rss_map->state[i],
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index eccac2a..09596c6 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -136,6 +136,14 @@ int mlx4_MOD_STAT_CFG(struct mlx4_dev *dev, struct mlx4_mod_stat_cfg *cfg)
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
@@ -810,6 +818,35 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 	return err;
 }
 
+static int mlx4_common_init_port(struct mlx4_dev *dev, int function, int port)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int err;
+
+	if (priv->mfunc.master.slave_state[function].init_port_mask & (1 << port))
+		return 0;
+
+	/* Enable port only if it was previously disabled */
+	if (!priv->mfunc.master.init_port_ref[port]) {
+		err = mlx4_cmd(dev, 0, port, 0, MLX4_CMD_INIT_PORT,
+			       MLX4_CMD_TIME_CLASS_A);
+		if (err)
+			return err;
+	}
+	++priv->mfunc.master.init_port_ref[port];
+	priv->mfunc.master.slave_state[function].init_port_mask |= (1 << port);
+	return 0;
+}
+
+int mlx4_INIT_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+							 struct mlx4_cmd_mailbox *inbox,
+							 struct mlx4_cmd_mailbox *outbox)
+{
+	int port = vhcr->in_modifier;
+
+	return mlx4_common_init_port(dev, slave, port);
+}
+
 int mlx4_INIT_PORT(struct mlx4_dev *dev, int port)
 {
 	struct mlx4_cmd_mailbox *mailbox;
@@ -856,17 +893,51 @@ int mlx4_INIT_PORT(struct mlx4_dev *dev, int port)
 			       MLX4_CMD_TIME_CLASS_A);
 
 		mlx4_free_cmd_mailbox(dev, mailbox);
-	} else
-		err = mlx4_cmd(dev, 0, port, 0, MLX4_CMD_INIT_PORT,
-			       MLX4_CMD_TIME_CLASS_A);
+	} else {
+		if (mlx4_is_master(dev))
+			err = mlx4_common_init_port(dev, 0, port);
+		else
+			err = mlx4_cmd(dev, 0, port, 0, MLX4_CMD_INIT_PORT,
+				       MLX4_CMD_TIME_CLASS_A);
+	}
 
 	return err;
 }
 EXPORT_SYMBOL_GPL(mlx4_INIT_PORT);
 
+static int mlx4_common_close_port(struct mlx4_dev *dev, int function, int port)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int err;
+
+	if (!(priv->mfunc.master.slave_state[function].init_port_mask & (1 << port)))
+		return 0;
+
+	if (priv->mfunc.master.init_port_ref[port] == 1) {
+		err = mlx4_cmd(dev, 0, port, 0, MLX4_CMD_CLOSE_PORT, 1000);
+		if (err)
+			return err;
+	}
+	--priv->mfunc.master.init_port_ref[port];
+	priv->mfunc.master.slave_state[function].init_port_mask &= ~(1 << port);
+	return 0;
+}
+
+int mlx4_CLOSE_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+							  struct mlx4_cmd_mailbox *inbox,
+							  struct mlx4_cmd_mailbox *outbox)
+{
+	int port = vhcr->in_modifier;
+
+	return mlx4_common_close_port(dev, slave, port);
+}
+
 int mlx4_CLOSE_PORT(struct mlx4_dev *dev, int port)
 {
-	return mlx4_cmd(dev, 0, port, 0, MLX4_CMD_CLOSE_PORT, 1000);
+	if (mlx4_is_master(dev))
+		return mlx4_common_close_port(dev, 0, port);
+	else
+		return mlx4_cmd(dev, 0, port, 0, MLX4_CMD_CLOSE_PORT, 1000);
 }
 EXPORT_SYMBOL_GPL(mlx4_CLOSE_PORT);
 
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 3cf56d9..bb41450 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -87,7 +87,7 @@ static struct mlx4_profile default_profile = {
 	.num_mtt	= 1 << 20,
 };
 
-static int log_num_mac = 2;
+static int log_num_mac = 7;
 module_param_named(log_num_mac, log_num_mac, int, 0444);
 MODULE_PARM_DESC(log_num_mac, "Log2 max number of MACs per ETH port (1-7)");
 
@@ -436,6 +436,7 @@ static int mlx4_init_cmpt_table(struct mlx4_dev *dev, u64 cmpt_base,
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	int err;
+	int num_eqs;
 
 	err = mlx4_init_icm_table(dev, &priv->qp_table.cmpt_table,
 				  cmpt_base +
@@ -465,12 +466,12 @@ static int mlx4_init_cmpt_table(struct mlx4_dev *dev, u64 cmpt_base,
 	if (err)
 		goto err_srq;
 
+	num_eqs = mlx4_is_master(dev) ? 512 : dev->caps.num_eqs;
 	err = mlx4_init_icm_table(dev, &priv->eq_table.cmpt_table,
 				  cmpt_base +
 				  ((u64) (MLX4_CMPT_TYPE_EQ *
 					  cmpt_entry_sz) << MLX4_CMPT_SHIFT),
-				  cmpt_entry_sz,
-				  dev->caps.num_eqs, dev->caps.num_eqs, 0, 0);
+				  cmpt_entry_sz, num_eqs, num_eqs, 0, 0);
 	if (err)
 		goto err_cq;
 
@@ -494,6 +495,7 @@ static int mlx4_init_icm(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap,
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	u64 aux_pages;
+	int num_eqs;
 	int err;
 
 	err = mlx4_SET_ICM_SIZE(dev, icm_size, &aux_pages);
@@ -525,10 +527,11 @@ static int mlx4_init_icm(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap,
 		goto err_unmap_aux;
 	}
 
+
+	num_eqs = mlx4_is_master(dev) ? 512 : dev->caps.num_eqs;
 	err = mlx4_init_icm_table(dev, &priv->eq_table.table,
 				  init_hca->eqc_base, dev_cap->eqc_entry_sz,
-				  dev->caps.num_eqs, dev->caps.num_eqs,
-				  0, 0);
+				  num_eqs, num_eqs, 0, 0);
 	if (err) {
 		mlx4_err(dev, "Failed to map EQ context memory, aborting.\n");
 		goto err_unmap_cmpt;
@@ -1015,9 +1018,12 @@ static int mlx4_init_port_info(struct mlx4_dev *dev, int port)
 
 	info->dev = dev;
 	info->port = port;
-	mlx4_init_mac_table(dev, &info->mac_table);
-	mlx4_init_vlan_table(dev, &info->vlan_table);
-
+	if (!mlx4_is_slave(dev)) {
+		mlx4_init_mac_table(dev, &info->mac_table);
+		mlx4_init_vlan_table(dev, &info->vlan_table);
+		info->base_qpn = dev->caps.reserved_qps_base[MLX4_QP_REGION_ETH_ADDR] +
+			(port - 1) * (1 << log_num_mac);
+	}
 	sprintf(info->dev_name, "mlx4_port%d", port);
 	info->port_attr.attr.name = info->dev_name;
 	info->port_attr.attr.mode = S_IRUGO | S_IWUSR;
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index a7dcad6..cffa31c 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -46,6 +46,7 @@
 #include <linux/mlx4/driver.h>
 #include <linux/mlx4/doorbell.h>
 #include <linux/mlx4/cmd.h>
+#include <rdma/ib_verbs.h>
 
 #define DRV_NAME	"mlx4_core"
 #define PFX		DRV_NAME ": "
@@ -99,7 +100,10 @@ enum mlx4_resource {
 	RES_CQ,
 	RES_SRQ,
 	RES_MPT,
-	RES_MTT
+	RES_MTT,
+	RES_MAC,
+	RES_VLAN,
+	RES_MCAST
 };
 
 enum mlx4_alloc_mode {
@@ -212,11 +216,16 @@ struct mlx4_slave_eqe {
 struct mlx4_slave_state {
 	u8 comm_toggle;
 	u8 last_cmd;
+	u8 init_port_mask;
 	dma_addr_t vhcr_dma;
+	u16 mtu[MLX4_MAX_PORTS + 1];
+	__be32 ib_cap_mask[MLX4_MAX_PORTS + 1];
 };
 
 struct mlx4_mfunc_master_ctx {
 	struct mlx4_slave_state *slave_state;
+	int			init_port_ref[MLX4_MAX_PORTS + 1];
+	u16			max_mtu[MLX4_MAX_PORTS + 1];
 };
 
 struct mlx4_vhcr {
@@ -327,7 +336,6 @@ struct mlx4_catas_err {
 
 struct mlx4_mac_table {
 	__be64			entries[MLX4_MAX_MAC_NUM];
-	int			refs[MLX4_MAX_MAC_NUM];
 	struct mutex		mutex;
 	int			total;
 	int			max;
@@ -352,6 +360,7 @@ struct mlx4_port_info {
 	enum mlx4_port_type	tmp_type;
 	struct mlx4_mac_table	mac_table;
 	struct mlx4_vlan_table	vlan_table;
+	int			base_qpn;
 };
 
 struct mlx4_sense {
@@ -503,6 +512,18 @@ void mlx4_init_mac_table(struct mlx4_dev *dev, struct mlx4_mac_table *table);
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
index 606aa58..dcbfd72 100644
--- a/drivers/net/mlx4/port.c
+++ b/drivers/net/mlx4/port.c
@@ -36,6 +36,7 @@
 #include <linux/mlx4/cmd.h>
 
 #include "mlx4.h"
+#include "en_port.h"
 
 #define MLX4_MAC_VALID		(1ull << 63)
 #define MLX4_MAC_MASK		0xffffffffffffULL
@@ -48,10 +49,8 @@ void mlx4_init_mac_table(struct mlx4_dev *dev, struct mlx4_mac_table *table)
 	int i;
 
 	mutex_init(&table->mutex);
-	for (i = 0; i < MLX4_MAX_MAC_NUM; i++) {
+	for (i = 0; i < MLX4_MAX_MAC_NUM; i++)
 		table->entries[i] = 0;
-		table->refs[i]	 = 0;
-	}
 	table->max   = 1 << dev->caps.log_num_macs;
 	table->total = 0;
 }
@@ -90,24 +89,33 @@ static int mlx4_set_port_mac_table(struct mlx4_dev *dev, u8 port,
 	return err;
 }
 
-int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *index)
+int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn)
 {
-	struct mlx4_mac_table *table = &mlx4_priv(dev)->port[port].mac_table;
+	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
+	struct mlx4_mac_table *table = &info->mac_table;
+	u64 out_param;
 	int i, err = 0;
 	int free = -1;
 
+	if (mlx4_is_slave(dev)) {
+		err = mlx4_cmd_imm(dev, mac, &out_param, RES_MAC, port,
+				   MLX4_CMD_ALLOC_RES, MLX4_CMD_TIME_CLASS_A);
+		if (!err)
+			*qpn = out_param;
+		return err;
+	}
+
 	mlx4_dbg(dev, "Registering MAC: 0x%llx\n", (unsigned long long) mac);
 	mutex_lock(&table->mutex);
 	for (i = 0; i < MLX4_MAX_MAC_NUM - 1; i++) {
-		if (free < 0 && !table->refs[i]) {
+		if (free < 0 && !table->entries[i]) {
 			free = i;
 			continue;
 		}
 
 		if (mac == (MLX4_MAC_MASK & be64_to_cpu(table->entries[i]))) {
-			/* MAC already registered, increase refernce count */
-			*index = i;
-			++table->refs[i];
+			/* MAC already registered, Must not have duplicates */
+			err = -EEXIST;
 			goto out;
 		}
 	}
@@ -120,18 +128,16 @@ int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *index)
 	}
 
 	/* Register new MAC */
-	table->refs[free] = 1;
 	table->entries[free] = cpu_to_be64(mac | MLX4_MAC_VALID);
 
 	err = mlx4_set_port_mac_table(dev, port, table->entries);
 	if (unlikely(err)) {
 		mlx4_err(dev, "Failed adding MAC: 0x%llx\n", (unsigned long long) mac);
-		table->refs[free] = 0;
 		table->entries[free] = 0;
 		goto out;
 	}
 
-	*index = free;
+	*qpn = info->base_qpn + free;
 	++table->total;
 out:
 	mutex_unlock(&table->mutex);
@@ -139,20 +145,35 @@ out:
 }
 EXPORT_SYMBOL_GPL(mlx4_register_mac);
 
-void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int index)
+static int validate_index(struct mlx4_dev *dev,
+			  struct mlx4_mac_table *table, int index)
 {
-	struct mlx4_mac_table *table = &mlx4_priv(dev)->port[port].mac_table;
+	int err = 0;
 
-	mutex_lock(&table->mutex);
-	if (!table->refs[index]) {
-		mlx4_warn(dev, "No MAC entry for index %d\n", index);
-		goto out;
+	if (index < 0 || index >= table->max || !table->entries[index]) {
+		mlx4_warn(dev, "No valid Mac entry for the given index\n");
+		err = -EINVAL;
 	}
-	if (--table->refs[index]) {
-		mlx4_warn(dev, "Have more references for index %d,"
-			  "no need to modify MAC table\n", index);
-		goto out;
+	return err;
+}
+
+void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int qpn)
+{
+	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
+	struct mlx4_mac_table *table = &info->mac_table;
+	int index = qpn - info->base_qpn;
+
+	if (mlx4_is_slave(dev)) {
+		mlx4_cmd(dev, qpn, RES_MAC, port,
+			 MLX4_CMD_FREE_RES, MLX4_CMD_TIME_CLASS_A);
+		return;
 	}
+
+	mutex_lock(&table->mutex);
+
+	if (validate_index(dev, table, index))
+		goto out;
+
 	table->entries[index] = 0;
 	mlx4_set_port_mac_table(dev, port, table->entries);
 	--table->total;
@@ -161,6 +182,38 @@ out:
 }
 EXPORT_SYMBOL_GPL(mlx4_unregister_mac);
 
+int mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac)
+{
+	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
+	struct mlx4_mac_table *table = &info->mac_table;
+	int index = qpn - info->base_qpn;
+	int err;
+
+	if (mlx4_is_slave(dev)) {
+		err = mlx4_cmd_imm(dev, new_mac, (u64 *) &qpn, RES_MAC, port,
+				   MLX4_CMD_REPLACE_RES, MLX4_CMD_TIME_CLASS_A);
+		return err;
+	}
+
+	mutex_lock(&table->mutex);
+
+	err = validate_index(dev, table, index);
+	if (err)
+		goto out;
+
+	table->entries[index] = cpu_to_be64(new_mac | MLX4_MAC_VALID);
+
+	err = mlx4_set_port_mac_table(dev, port, table->entries);
+	if (unlikely(err)) {
+		mlx4_err(dev, "Failed adding MAC: 0x%llx\n", (unsigned long long) new_mac);
+		table->entries[index] = 0;
+	}
+out:
+	mutex_unlock(&table->mutex);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx4_replace_mac);
+
 static int mlx4_set_port_vlan_table(struct mlx4_dev *dev, u8 port,
 				    __be32 *entries)
 {
@@ -294,6 +347,129 @@ int mlx4_get_port_ib_caps(struct mlx4_dev *dev, u8 port, __be32 *caps)
 	return err;
 }
 
+int mlx4_SET_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+							struct mlx4_cmd_mailbox *inbox,
+							struct mlx4_cmd_mailbox *outbox)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_port_info *port_info;
+	struct mlx4_mfunc_master_ctx *master = &priv->mfunc.master;
+	struct mlx4_slave_state *slave_st = &master->slave_state[slave];
+	struct mlx4_set_port_rqp_calc_context *qpn_context;
+	struct mlx4_set_port_general_context *gen_context;
+	int reset_qkey_viols;
+	int port;
+	int is_eth;
+	u32 in_modifier;
+	u32 promisc;
+	u16 mtu, prev_mtu;
+	int err;
+	int i;
+	__be32 agg_cap_mask;
+	__be32 slave_cap_mask;
+	__be32 new_cap_mask;
+
+	port = vhcr->in_modifier & 0xff;
+	in_modifier = vhcr->in_modifier >> 8;
+	is_eth = vhcr->op_modifier;
+	port_info = &priv->port[port];
+
+	/* All slaves can perform SET_PORT operations, just need to verify
+	 * we keep the mutual resources unchanged */
+	if (is_eth) {
+		switch (in_modifier) {
+		case MLX4_SET_PORT_RQP_CALC:
+			qpn_context = inbox->buf;
+			qpn_context->base_qpn = cpu_to_be32(port_info->base_qpn);
+			qpn_context->n_mac = 0x7;
+			promisc = be32_to_cpu(qpn_context->promisc) >>
+				SET_PORT_PROMISC_SHIFT;
+			qpn_context->promisc = cpu_to_be32(
+				promisc << SET_PORT_PROMISC_SHIFT |
+				port_info->base_qpn);
+			promisc = be32_to_cpu(qpn_context->mcast) >>
+				SET_PORT_PROMISC_SHIFT;
+			qpn_context->mcast = cpu_to_be32(
+				promisc << SET_PORT_PROMISC_SHIFT |
+				port_info->base_qpn);
+			break;
+		case MLX4_SET_PORT_GENERAL:
+			gen_context = inbox->buf;
+			/* Mtu is configured as the max MTU among all the
+			 * the functions on the port. */
+			mtu = be16_to_cpu(gen_context->mtu);
+			mtu = min_t(int, mtu, dev->caps.eth_mtu_cap[port]);
+			prev_mtu = slave_st->mtu[port];
+			slave_st->mtu[port] = mtu;
+			if (mtu > master->max_mtu[port])
+				master->max_mtu[port] = mtu;
+			if (mtu < prev_mtu && prev_mtu == master->max_mtu[port]) {
+				slave_st->mtu[port] = mtu;
+				master->max_mtu[port] = mtu;
+				for (i = 0; i < dev->num_slaves; i++) {
+					master->max_mtu[port] =
+						max(master->max_mtu[port],
+						    master->slave_state[i].mtu[port]);
+				}
+			}
+
+			gen_context->mtu = cpu_to_be16(master->max_mtu[port]);
+			break;
+		}
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
+	/* only master has access to qp0 */
+	if (new_cap_mask & cpu_to_be32(IB_PORT_SM)) {
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
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 27327f7..26390ab 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -127,6 +127,7 @@ enum {
 	/* virtual commands */
 	MLX4_CMD_ALLOC_RES	 = 0xf00,
 	MLX4_CMD_FREE_RES	 = 0xf01,
+	MLX4_CMD_REPLACE_RES	 = 0xf02,
 	MLX4_CMD_GET_EVENT	 = 0xf03,
 	MLX4_CMD_MCAST_ATTACH	 = 0xf05,
 
@@ -153,6 +154,7 @@ enum {
 	MLX4_SET_PORT_MAC_TABLE = 0x2,
 	MLX4_SET_PORT_VLAN_TABLE = 0x3,
 	MLX4_SET_PORT_PRIO_MAP  = 0x4,
+	MLX4_SET_PORT_MODIFIERS
 };
 
 struct mlx4_dev;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index f80b899..b557793 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -485,8 +485,9 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  int block_mcast_loopback);
 int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16]);
 
-int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *index);
-void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int index);
+int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn);
+void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int qpn);
+int mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac);
 
 int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index);
 void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index);
-- 
1.6.1.3


