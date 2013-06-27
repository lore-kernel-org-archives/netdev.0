From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx4_core: Add HW enforcement to VF link state
Date: Thu, 27 Jun 2013 19:05:22 +0300
Message-ID: <1372349122-23390-3-git-send-email-ogerlitz@mellanox.com>
References: <1372349122-23390-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, jackm@dev.mellanox.co.il,
	ronye@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46634 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752018Ab3F0QF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 12:05:59 -0400
In-Reply-To: <1372349122-23390-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rony Efraim <ronye@mellanox.com>

When the firmware supports the UPDATE_QP command, if the VF link is disabled,
block all QPs opened by the VF, by programming the UPDATE_QP command to drop
all RX & TX traffic to/from these QPs. Operates only in VST mode.

Signed-off-by: Rony Efraim <ronye@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   57 +++++++++++++-------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    1 +
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   22 +++++++-
 include/linux/mlx4/qp.h                            |    2 +
 4 files changed, 60 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 7b92789..9bf6ec1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1521,6 +1521,10 @@ out:
 	return ret;
 }
 
+static int calculate_transition(u16 oper_vlan, u16 admin_vlan)
+{
+	return (2 * (oper_vlan == MLX4_VGT) + (admin_vlan == MLX4_VGT));
+}
 
 int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
 					    int slave, int port)
@@ -1528,16 +1532,37 @@ int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
 	struct mlx4_vport_oper_state *vp_oper;
 	struct mlx4_vport_state *vp_admin;
 	struct mlx4_vf_immed_vlan_work *work;
+	struct mlx4_dev *dev = &(priv->dev);
 	int err;
 	int admin_vlan_ix = NO_INDX;
+	enum mlx4_vlan_transition vlan_trans;
 
 	vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
 	vp_admin = &priv->mfunc.master.vf_admin[slave].vport[port];
 
 	if (vp_oper->state.default_vlan == vp_admin->default_vlan &&
-	    vp_oper->state.default_qos == vp_admin->default_qos)
+	    vp_oper->state.default_qos == vp_admin->default_qos &&
+	    vp_oper->state.link_state == vp_admin->link_state)
 		return 0;
 
+	vlan_trans = calculate_transition(vp_oper->state.default_vlan,
+					  vp_admin->default_vlan);
+
+	if (!(priv->mfunc.master.slave_state[slave].active &&
+	      dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_UPDATE_QP &&
+	      vlan_trans == MLX4_VLAN_TRANSITION_VST_VST)) {
+		/* even if the UPDATE_QP command isn't supported, we still want
+ 		 * to set this VF link according to the admin directive
+ 		 */
+		vp_oper->state.link_state = vp_admin->link_state;
+		return -1;
+	}
+
+	mlx4_dbg(dev, "updating immediately admin params slave %d port %d\n",
+		 slave, port);
+	mlx4_dbg(dev, "vlan %d QoS %d link down %d\n", vp_admin->default_vlan,
+		 vp_admin->default_qos, vp_admin->link_state);
+
 	work = kzalloc(sizeof(*work), GFP_KERNEL);
 	if (!work)
 		return -ENOMEM;
@@ -1572,6 +1597,10 @@ int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
 
 	vp_oper->state.default_vlan = vp_admin->default_vlan;
 	vp_oper->state.default_qos = vp_admin->default_qos;
+	vp_oper->state.link_state = vp_admin->link_state;
+
+	if (vp_admin->link_state == IFLA_VF_LINK_STATE_DISABLE)
+		work->flags |= MLX4_VF_IMMED_VLAN_FLAG_LINK_DISABLE;
 
 	/* iterate over QPs owned by this slave, using UPDATE_QP */
 	work->port = port;
@@ -2201,10 +2230,6 @@ int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac)
 }
 EXPORT_SYMBOL_GPL(mlx4_set_vf_mac);
 
-static int calculate_transition(u16 oper_vlan, u16 admin_vlan)
-{
-	return (2 * (oper_vlan == MLX4_VGT) + (admin_vlan == MLX4_VGT));
-}
 
 int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos)
 {
@@ -2212,7 +2237,6 @@ int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos)
 	struct mlx4_vport_oper_state *vf_oper;
 	struct mlx4_vport_state *vf_admin;
 	int slave;
-	enum mlx4_vlan_transition vlan_trans;
 
 	if ((!mlx4_is_master(dev)) ||
 	    !(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_VLAN_CONTROL))
@@ -2234,16 +2258,10 @@ int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos)
 		vf_admin->default_vlan = vlan;
 	vf_admin->default_qos = qos;
 
-	vlan_trans = calculate_transition(vf_oper->state.default_vlan,
-					  vf_admin->default_vlan);
-
-	if (priv->mfunc.master.slave_state[slave].active &&
-	    dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_UPDATE_QP &&
-	    vlan_trans == MLX4_VLAN_TRANSITION_VST_VST) {
-		mlx4_info(dev, "updating vf %d port %d config params immediately\n",
+	if (mlx4_master_immediate_activate_vlan_qos(priv, slave, port))
+		mlx4_info(dev,
+			  "updating vf %d port %d config will take effect on next VF restart\n",
 			  vf, port);
-		mlx4_master_immediate_activate_vlan_qos(priv, slave, port);
-	}
 	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx4_set_vf_vlan);
@@ -2307,7 +2325,6 @@ int mlx4_set_vf_link_state(struct mlx4_dev *dev, int port, int vf, int link_stat
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_vport_state *s_info;
-	struct mlx4_vport_oper_state *vp_oper;
 	int slave;
 	u8 link_stat_event;
 
@@ -2337,14 +2354,16 @@ int mlx4_set_vf_link_state(struct mlx4_dev *dev, int port, int vf, int link_stat
 			  link_state, slave, port);
 		return -EINVAL;
 	};
-	/* update the admin & oper state on the link state */
 	s_info = &priv->mfunc.master.vf_admin[slave].vport[port];
-	vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
 	s_info->link_state = link_state;
-	vp_oper->state.link_state = link_state;
 
 	/* send event */
 	mlx4_gen_port_state_change_eqe(dev, slave, port, link_stat_event);
+
+	if (mlx4_master_immediate_activate_vlan_qos(priv, slave, port))
+		mlx4_dbg(dev,
+			 "updating vf %d port %d no link state HW enforcment\n",
+			 vf, port);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx4_set_vf_link_state);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 5abcb65..17d9277 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -574,6 +574,7 @@ struct mlx4_cmd {
 enum {
 	MLX4_VF_IMMED_VLAN_FLAG_VLAN = 1 << 0,
 	MLX4_VF_IMMED_VLAN_FLAG_QOS = 1 << 1,
+	MLX4_VF_IMMED_VLAN_FLAG_LINK_DISABLE = 1 << 2,
 };
 struct mlx4_vf_immed_vlan_work {
 	struct work_struct	work;
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 46323a2..f984a89 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -384,7 +384,17 @@ static int update_vport_qp_param(struct mlx4_dev *dev,
 
 		/* force strip vlan by clear vsd */
 		qpc->param3 &= ~cpu_to_be32(MLX4_STRIP_VLAN);
-		if (0 != vp_oper->state.default_vlan) {
+
+		if (vp_oper->state.link_state == IFLA_VF_LINK_STATE_DISABLE &&
+		    dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_UPDATE_QP) {
+			qpc->pri_path.vlan_control =
+				MLX4_VLAN_CTRL_ETH_TX_BLOCK_TAGGED |
+				MLX4_VLAN_CTRL_ETH_TX_BLOCK_PRIO_TAGGED |
+				MLX4_VLAN_CTRL_ETH_TX_BLOCK_UNTAGGED |
+				MLX4_VLAN_CTRL_ETH_RX_BLOCK_PRIO_TAGGED |
+				MLX4_VLAN_CTRL_ETH_RX_BLOCK_UNTAGGED |
+				MLX4_VLAN_CTRL_ETH_RX_BLOCK_TAGGED;
+		} else if (0 != vp_oper->state.default_vlan) {
 			qpc->pri_path.vlan_control =
 				MLX4_VLAN_CTRL_ETH_TX_BLOCK_TAGGED |
 				MLX4_VLAN_CTRL_ETH_RX_BLOCK_PRIO_TAGGED |
@@ -4002,8 +4012,14 @@ void mlx4_vf_immed_vlan_work_handler(struct work_struct *_work)
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
 		goto out;
-
-	if (!work->vlan_id)
+	if (work->flags & MLX4_VF_IMMED_VLAN_FLAG_LINK_DISABLE) /* block all */
+		vlan_control = MLX4_VLAN_CTRL_ETH_TX_BLOCK_TAGGED |
+			MLX4_VLAN_CTRL_ETH_TX_BLOCK_PRIO_TAGGED |
+			MLX4_VLAN_CTRL_ETH_TX_BLOCK_UNTAGGED |
+			MLX4_VLAN_CTRL_ETH_RX_BLOCK_PRIO_TAGGED |
+			MLX4_VLAN_CTRL_ETH_RX_BLOCK_UNTAGGED |
+			MLX4_VLAN_CTRL_ETH_RX_BLOCK_TAGGED;
+	else if (!work->vlan_id)
 		vlan_control = MLX4_VLAN_CTRL_ETH_TX_BLOCK_TAGGED |
 			MLX4_VLAN_CTRL_ETH_RX_BLOCK_TAGGED;
 	else
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index f43e32a..262deac 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -152,6 +152,8 @@ enum { /* fl */
 };
 enum { /* vlan_control */
 	MLX4_VLAN_CTRL_ETH_TX_BLOCK_TAGGED	= 1 << 6,
+	MLX4_VLAN_CTRL_ETH_TX_BLOCK_PRIO_TAGGED	= 1 << 5, /* 802.1p priority tag */
+	MLX4_VLAN_CTRL_ETH_TX_BLOCK_UNTAGGED	= 1 << 4,
 	MLX4_VLAN_CTRL_ETH_RX_BLOCK_TAGGED	= 1 << 2,
 	MLX4_VLAN_CTRL_ETH_RX_BLOCK_PRIO_TAGGED	= 1 << 1, /* 802.1p priority tag */
 	MLX4_VLAN_CTRL_ETH_RX_BLOCK_UNTAGGED	= 1 << 0
-- 
1.7.1
