From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V2 5/5] net/mlx4: Add VST QinQ support
Date: Mon, 25 Jul 2016 14:15:36 +0300
Message-ID: <1469445336-21952-6-git-send-email-tariqt@mellanox.com>
References: <1469445336-21952-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Moshe Shemesh <moshe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36476 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751787AbcGYLQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 07:16:01 -0400
In-Reply-To: <1469445336-21952-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Shemesh <moshe@mellanox.com>

Move the vf to VST QinQ mode by setting vf vlan protocol to 802.1ad.
Read current vlan protocol as part of the vf configuration state.
Upon setting VST QinQ, we use a mechanism of handshake to verify that
both the vf and the pf driver version support it.

Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c       | 51 ++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  6 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c        | 91 ++++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |  1 +
 include/linux/mlx4/cmd.h                       |  3 +-
 5 files changed, 140 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 6ca4b2ce0875..76590f480c19 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1989,6 +1989,8 @@ static int mlx4_master_activate_admin_state(struct mlx4_priv *priv, int slave)
 	int port, err;
 	struct mlx4_vport_state *vp_admin;
 	struct mlx4_vport_oper_state *vp_oper;
+	struct mlx4_slave_state *slave_state =
+		&priv->mfunc.master.slave_state[slave];
 	struct mlx4_active_ports actv_ports = mlx4_get_active_ports(
 			&priv->dev, slave);
 	int min_port = find_first_bit(actv_ports.ports,
@@ -2003,7 +2005,19 @@ static int mlx4_master_activate_admin_state(struct mlx4_priv *priv, int slave)
 			priv->mfunc.master.vf_admin[slave].enable_smi[port];
 		vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
 		vp_admin = &priv->mfunc.master.vf_admin[slave].vport[port];
-		vp_oper->state = *vp_admin;
+		if (vp_admin->vlan_proto != htons(ETH_P_8021AD) ||
+		    slave_state->vst_qinq_supported) {
+			vp_oper->state.vlan_proto = vp_admin->vlan_proto;
+			vp_oper->state.default_vlan = vp_admin->default_vlan;
+			vp_oper->state.default_qos = vp_admin->default_qos;
+		}
+		vp_oper->state.link_state = vp_admin->link_state;
+		vp_oper->state.mac = vp_admin->mac;
+		vp_oper->state.spoofchk = vp_admin->spoofchk;
+		vp_oper->state.tx_rate = vp_admin->tx_rate;
+		vp_oper->state.qos_vport = vp_admin->qos_vport;
+		vp_oper->state.guid = vp_admin->guid;
+
 		if (MLX4_VGT != vp_admin->default_vlan) {
 			err = __mlx4_register_vlan(&priv->dev, port,
 						   vp_admin->default_vlan, &(vp_oper->vlan_idx));
@@ -2091,6 +2105,7 @@ static void mlx4_master_do_cmd(struct mlx4_dev *dev, int slave, u8 cmd,
 		mlx4_warn(dev, "Received reset from slave:%d\n", slave);
 		slave_state[slave].active = false;
 		slave_state[slave].old_vlan_api = false;
+		slave_state[slave].vst_qinq_supported = false;
 		mlx4_master_deactivate_admin_state(priv, slave);
 		for (i = 0; i < MLX4_EVENT_TYPES_NUM; ++i) {
 				slave_state[slave].event_eq[i].eqn = -1;
@@ -2358,6 +2373,7 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 			vf_oper = &priv->mfunc.master.vf_oper[i];
 			s_state = &priv->mfunc.master.slave_state[i];
 			s_state->last_cmd = MLX4_COMM_CMD_RESET;
+			s_state->vst_qinq_supported = false;
 			mutex_init(&priv->mfunc.master.gen_eqe_mutex[i]);
 			for (j = 0; j < MLX4_EVENT_TYPES_NUM; ++j)
 				s_state->event_eq[j].eqn = -1;
@@ -2944,10 +2960,13 @@ int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac)
 EXPORT_SYMBOL_GPL(mlx4_set_vf_mac);
 
 
-int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos)
+int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos,
+		     __be16 proto)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_vport_state *vf_admin;
+	struct mlx4_slave_state *slave_state;
+	struct mlx4_vport_oper_state *vf_oper;
 	int slave;
 
 	if ((!mlx4_is_master(dev)) ||
@@ -2957,12 +2976,31 @@ int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos)
 	if ((vlan > 4095) || (qos > 7))
 		return -EINVAL;
 
+	if (proto == htons(ETH_P_8021AD) &&
+	    !(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_SVLAN_BY_QP))
+		return -EPROTONOSUPPORT;
+
+	if (proto != htons(ETH_P_8021Q) &&
+	    proto != htons(ETH_P_8021AD))
+		return -EINVAL;
+
+	if ((proto == htons(ETH_P_8021AD)) &&
+	    ((vlan == 0) || (vlan == MLX4_VGT)))
+		return -EINVAL;
+
 	slave = mlx4_get_slave_indx(dev, vf);
 	if (slave < 0)
 		return -EINVAL;
 
+	slave_state = &priv->mfunc.master.slave_state[slave];
+	if ((proto == htons(ETH_P_8021AD)) && (slave_state->active) &&
+	    (!slave_state->vst_qinq_supported)) {
+		mlx4_err(dev, "vf %d does not support VST QinQ mode\n", vf);
+		return -EPROTONOSUPPORT;
+	}
 	port = mlx4_slaves_closest_port(dev, slave, port);
 	vf_admin = &priv->mfunc.master.vf_admin[slave].vport[port];
+	vf_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
 
 	if (!mlx4_valid_vf_state_change(dev, port, vf_admin, vlan, qos))
 		return -EPERM;
@@ -2972,6 +3010,7 @@ int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos)
 	else
 		vf_admin->default_vlan = vlan;
 	vf_admin->default_qos = qos;
+	vf_admin->vlan_proto = proto;
 
 	/* If rate was configured prior to VST, we saved the configured rate
 	 * in vf_admin->rate and now, if priority supported we enforce the QoS
@@ -2980,7 +3019,12 @@ int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos)
 	    vf_admin->tx_rate)
 		vf_admin->qos_vport = slave;
 
-	if (mlx4_master_immediate_activate_vlan_qos(priv, slave, port))
+	/* Try to activate new vf state without restart,
+	 * this option is not supported while moving to VST QinQ mode.
+	 */
+	if ((proto == htons(ETH_P_8021AD) &&
+	     vf_oper->state.vlan_proto != proto) ||
+	    mlx4_master_immediate_activate_vlan_qos(priv, slave, port))
 		mlx4_info(dev,
 			  "updating vf %d port %d config will take effect on next VF restart\n",
 			  vf, port);
@@ -3124,6 +3168,7 @@ int mlx4_get_vf_config(struct mlx4_dev *dev, int port, int vf, struct ifla_vf_in
 
 	ivf->vlan		= s_info->default_vlan;
 	ivf->qos		= s_info->default_qos;
+	ivf->vlan_proto		= s_info->vlan_proto;
 
 	if (mlx4_is_vf_vst_and_prio_qos(dev, port, s_info))
 		ivf->max_tx_rate = s_info->tx_rate;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index e0f05e63237c..bd7cd07d11ca 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2405,10 +2405,8 @@ static int mlx4_en_set_vf_vlan(struct net_device *dev, int vf, u16 vlan, u8 qos,
 	struct mlx4_en_priv *en_priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = en_priv->mdev;
 
-	if (vlan_proto != htons(ETH_P_8021Q))
-		return -EPROTONOSUPPORT;
-
-	return mlx4_set_vf_vlan(mdev->dev, en_priv->port, vf, vlan, qos);
+	return mlx4_set_vf_vlan(mdev->dev, en_priv->port, vf, vlan, qos,
+				vlan_proto);
 }
 
 static int mlx4_en_set_vf_rate(struct net_device *dev, int vf, int min_tx_rate,
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 6a1012921710..1d37dc55f6bd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -249,6 +249,74 @@ out:
 	return err;
 }
 
+static int mlx4_activate_vst_qinq(struct mlx4_priv *priv, int slave, int port)
+{
+	struct mlx4_vport_oper_state *vp_oper;
+	struct mlx4_slave_state *slave_state;
+	struct mlx4_vport_state *vp_admin;
+	int err;
+
+	vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
+	vp_admin = &priv->mfunc.master.vf_admin[slave].vport[port];
+	slave_state = &priv->mfunc.master.slave_state[slave];
+
+	if (vp_admin->default_vlan != vp_oper->state.default_vlan) {
+		err = __mlx4_register_vlan(&priv->dev, port,
+					   vp_admin->default_vlan,
+					   &vp_oper->vlan_idx);
+		if (err) {
+			vp_oper->vlan_idx = NO_INDX;
+			mlx4_warn(&priv->dev,
+				  "No vlan resources slave %d, port %d\n",
+				  slave, port);
+			return err;
+		}
+		mlx4_dbg(&priv->dev, "alloc vlan %d idx  %d slave %d port %d\n",
+			 (int)(vp_oper->state.default_vlan),
+			 vp_oper->vlan_idx, slave, port);
+	}
+	vp_oper->state.vlan_proto = vp_admin->vlan_proto;
+	vp_oper->state.default_vlan = vp_admin->default_vlan;
+	vp_oper->state.default_qos = vp_admin->default_qos;
+
+	return 0;
+}
+
+static int mlx4_handle_vst_qinq(struct mlx4_priv *priv, int slave, int port)
+{
+	struct mlx4_vport_oper_state *vp_oper;
+	struct mlx4_slave_state *slave_state;
+	struct mlx4_vport_state *vp_admin;
+	int err;
+
+	vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
+	vp_admin = &priv->mfunc.master.vf_admin[slave].vport[port];
+	slave_state = &priv->mfunc.master.slave_state[slave];
+
+	if ((vp_admin->vlan_proto != htons(ETH_P_8021AD)) ||
+	    (!slave_state->active))
+		return 0;
+
+	if (vp_oper->state.vlan_proto == vp_admin->vlan_proto &&
+	    vp_oper->state.default_vlan == vp_admin->default_vlan &&
+	    vp_oper->state.default_qos == vp_admin->default_qos)
+		return 0;
+
+	if (!slave_state->vst_qinq_supported) {
+		/* Warn and revert the request to set vst QinQ mode */
+		vp_admin->vlan_proto = vp_oper->state.vlan_proto;
+		vp_admin->default_vlan = vp_oper->state.default_vlan;
+		vp_admin->default_qos = vp_oper->state.default_qos;
+
+		mlx4_warn(&priv->dev,
+			  "Slave %d does not support VST QinQ mode\n", slave);
+		return 0;
+	}
+
+	err = mlx4_activate_vst_qinq(priv, slave, port);
+	return err;
+}
+
 int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 				struct mlx4_vhcr *vhcr,
 				struct mlx4_cmd_mailbox *inbox,
@@ -312,17 +380,18 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 #define QUERY_FUNC_CAP_VF_ENABLE_QP0		0x08
 
 #define QUERY_FUNC_CAP_FLAGS0_FORCE_PHY_WQE_GID 0x80
-#define QUERY_FUNC_CAP_SUPPORTS_NON_POWER_OF_2_NUM_EQS (1 << 31)
 #define QUERY_FUNC_CAP_PHV_BIT			0x40
 #define QUERY_FUNC_CAP_VLAN_OFFLOAD_DISABLE	0x20
 
+#define QUERY_FUNC_CAP_SUPPORTS_VST_QINQ	BIT(30)
+#define QUERY_FUNC_CAP_SUPPORTS_NON_POWER_OF_2_NUM_EQS BIT(31)
+
 	if (vhcr->op_modifier == 1) {
 		struct mlx4_active_ports actv_ports =
 			mlx4_get_active_ports(dev, slave);
 		int converted_port = mlx4_slave_convert_port(
 				dev, slave, vhcr->in_modifier);
-		struct mlx4_vport_oper_state *vp_oper =
-			&priv->mfunc.master.vf_oper[slave].vport[vhcr->in_modifier];
+		struct mlx4_vport_oper_state *vp_oper;
 
 		if (converted_port < 0)
 			return -EINVAL;
@@ -361,6 +430,11 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 		MLX4_PUT(outbox->buf, dev->caps.phys_port_id[vhcr->in_modifier],
 			 QUERY_FUNC_CAP_PHYS_PORT_ID);
 
+		vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
+		err = mlx4_handle_vst_qinq(priv, slave, port);
+		if (err)
+			return err;
+
 		field = 0;
 		if (dev->caps.phv_bit[port])
 			field |= QUERY_FUNC_CAP_PHV_BIT;
@@ -371,6 +445,9 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	} else if (vhcr->op_modifier == 0) {
 		struct mlx4_active_ports actv_ports =
 			mlx4_get_active_ports(dev, slave);
+		struct mlx4_slave_state *slave_state =
+			&priv->mfunc.master.slave_state[slave];
+
 		/* enable rdma and ethernet interfaces, new quota locations,
 		 * and reserved lkey
 		 */
@@ -444,6 +521,10 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 
 		size = dev->caps.reserved_lkey + ((slave << 8) & 0xFF00);
 		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_QP_RESD_LKEY_OFFSET);
+
+		if (vhcr->in_modifier & QUERY_FUNC_CAP_SUPPORTS_VST_QINQ)
+			slave_state->vst_qinq_supported = true;
+
 	} else
 		err = -EINVAL;
 
@@ -459,10 +540,12 @@ int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u8 gen_or_port,
 	u32			size, qkey;
 	int			err = 0, quotas = 0;
 	u32                     in_modifier;
+	u32			slave_caps;
 
 	op_modifier = !!gen_or_port; /* 0 = general, 1 = logical port */
-	in_modifier = op_modifier ? gen_or_port :
+	slave_caps = QUERY_FUNC_CAP_SUPPORTS_VST_QINQ |
 		QUERY_FUNC_CAP_SUPPORTS_NON_POWER_OF_2_NUM_EQS;
+	in_modifier = op_modifier ? gen_or_port : slave_caps;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 74e58ef136bb..adfe38b2f639 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -482,6 +482,7 @@ struct mlx4_slave_state {
 	u8 init_port_mask;
 	bool active;
 	bool old_vlan_api;
+	bool vst_qinq_supported;
 	u8 function;
 	dma_addr_t vhcr_dma;
 	u16 mtu[MLX4_MAX_PORTS + 1];
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 116b284bc4ce..1f3568694a57 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -309,7 +309,8 @@ int mlx4_get_vf_stats(struct mlx4_dev *dev, int port, int vf_idx,
 		      struct ifla_vf_stats *vf_stats);
 u32 mlx4_comm_get_version(void);
 int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac);
-int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos);
+int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan,
+		     u8 qos, __be16 proto);
 int mlx4_set_vf_rate(struct mlx4_dev *dev, int port, int vf, int min_tx_rate,
 		     int max_tx_rate);
 int mlx4_set_vf_spoofchk(struct mlx4_dev *dev, int port, int vf, bool setting);
-- 
1.8.3.1
