From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 10/18] net/mlx4: Added qos_vport QP configuration in VST mode
Date: Thu,  2 Apr 2015 16:31:15 +0300
Message-ID: <1427981483-19317-11-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45749 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752540AbbDBNcO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:32:14 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Granular QoS per VF feature introduce a new QP field, qos_vport.

PF administrator can connect VF QPs to a certain QoS Vport, to
inherit its proporties. Connecting QPs to the default QoS Vport
(defined as 0) is always allowed, even when there are no allocated VPPs.
At this point, only the default vport is connected to QPs.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    9 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/fw_qos.h        |    3 +++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    2 ++
 drivers/net/ethernet/mellanox/mlx4/qp.c            |    5 +++++
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    6 ++++++
 include/linux/mlx4/qp.h                            |    8 ++++++--
 6 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 1e4a929..ea8947a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -48,6 +48,7 @@
 
 #include "mlx4.h"
 #include "fw.h"
+#include "fw_qos.h"
 
 #define CMD_POLL_TOKEN 0xffff
 #define INBOX_MASK	0xffffffffffffff00ULL
@@ -1808,7 +1809,8 @@ static int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
 
 	if (vp_oper->state.default_vlan == vp_admin->default_vlan &&
 	    vp_oper->state.default_qos == vp_admin->default_qos &&
-	    vp_oper->state.link_state == vp_admin->link_state)
+	    vp_oper->state.link_state == vp_admin->link_state &&
+	    vp_oper->state.qos_vport == vp_admin->qos_vport)
 		return 0;
 
 	if (!(priv->mfunc.master.slave_state[slave].active &&
@@ -1866,6 +1868,7 @@ static int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
 	vp_oper->state.default_vlan = vp_admin->default_vlan;
 	vp_oper->state.default_qos = vp_admin->default_qos;
 	vp_oper->state.link_state = vp_admin->link_state;
+	vp_oper->state.qos_vport = vp_admin->qos_vport;
 
 	if (vp_admin->link_state == IFLA_VF_LINK_STATE_DISABLE)
 		work->flags |= MLX4_VF_IMMED_VLAN_FLAG_LINK_DISABLE;
@@ -1874,6 +1877,7 @@ static int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
 	work->port = port;
 	work->slave = slave;
 	work->qos = vp_oper->state.default_qos;
+	work->qos_vport = vp_oper->state.qos_vport;
 	work->vlan_id = vp_oper->state.default_vlan;
 	work->vlan_ix = vp_oper->vlan_idx;
 	work->priv = priv;
@@ -2339,6 +2343,9 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 				INIT_LIST_HEAD(&s_state->mcast_filters[port]);
 				admin_vport->default_vlan = MLX4_VGT;
 				oper_vport->default_vlan = MLX4_VGT;
+				admin_vport->qos_vport =
+						MLX4_VPP_DEFAULT_VPORT;
+				oper_vport->qos_vport = MLX4_VPP_DEFAULT_VPORT;
 				vf_oper->vport[port].vlan_idx = NO_INDX;
 				vf_oper->vport[port].mac_idx = NO_INDX;
 			}
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw_qos.h b/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
index 4a5320f..ac1f331 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
@@ -44,6 +44,9 @@
 /* Default supported priorities for VPP allocation */
 #define MLX4_DEFAULT_QOS_PRIO (0)
 
+/* Derived from FW feature definition, 0 is the default vport fo all QPs */
+#define MLX4_VPP_DEFAULT_VPORT (0)
+
 struct mlx4_vport_qos_param {
 	u32 bw_share;
 	u32 max_avg_bw;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 1add698..32469c6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -498,6 +498,7 @@ struct mlx4_vport_state {
 	u32 tx_rate;
 	bool spoofchk;
 	u32 link_state;
+	u8 qos_vport;
 };
 
 struct mlx4_vf_admin_state {
@@ -636,6 +637,7 @@ struct mlx4_vf_immed_vlan_work {
 	int			orig_vlan_ix;
 	u8			port;
 	u8			qos;
+	u8                      qos_vport;
 	u16			vlan_id;
 	u16			orig_vlan_id;
 };
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 69e4462..b75214a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -447,6 +447,11 @@ int mlx4_update_qp(struct mlx4_dev *dev, u32 qpn,
 		cmd->qp_context.rate_limit_params = cpu_to_be16((params->rate_unit << 14) | params->rate_val);
 	}
 
+	if (attr & MLX4_UPDATE_QP_QOS_VPORT) {
+		qp_mask |= 1ULL << MLX4_UPD_QP_MASK_QOS_VPP;
+		cmd->qp_context.qos_vport = params->qos_vport;
+	}
+
 	cmd->primary_addr_path_mask = cpu_to_be64(pri_addr_path_mask);
 	cmd->qp_mask = cpu_to_be64(qp_mask);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 2076e98..c82df82 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -765,6 +765,7 @@ static int update_vport_qp_param(struct mlx4_dev *dev,
 		qpc->pri_path.feup |= MLX4_FEUP_FORCE_ETH_UP | MLX4_FVL_FORCE_ETH_VLAN;
 		qpc->pri_path.sched_queue &= 0xC7;
 		qpc->pri_path.sched_queue |= (vp_oper->state.default_qos) << 3;
+		qpc->qos_vport = vp_oper->state.qos_vport;
 	}
 	if (vp_oper->state.spoofchk) {
 		qpc->pri_path.feup |= MLX4_FSM_FORCE_ETH_SRC_MAC;
@@ -4911,6 +4912,11 @@ void mlx4_vf_immed_vlan_work_handler(struct work_struct *_work)
 					qp->sched_queue & 0xC7;
 				upd_context->qp_context.pri_path.sched_queue |=
 					((work->qos & 0x7) << 3);
+				upd_context->qp_mask |=
+					cpu_to_be64(1ULL <<
+						    MLX4_UPD_QP_MASK_QOS_VPP);
+				upd_context->qp_context.qos_vport =
+					work->qos_vport;
 			}
 
 			err = mlx4_cmd(dev, mailbox->dma,
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 1023ebe..6fed539 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -209,7 +209,8 @@ struct mlx4_qp_context {
 	__be16			sq_wqe_counter;
 	u32			reserved3;
 	__be16			rate_limit_params;
-	__be16			reserved4;
+	u8			reserved4;
+	u8			qos_vport;
 	__be32			param3;
 	__be32			nummmcpeers_basemkey;
 	u8			log_page_size;
@@ -231,6 +232,7 @@ struct mlx4_update_qp_context {
 enum {
 	MLX4_UPD_QP_MASK_PM_STATE	= 32,
 	MLX4_UPD_QP_MASK_VSD		= 33,
+	MLX4_UPD_QP_MASK_QOS_VPP	= 34,
 	MLX4_UPD_QP_MASK_RATE_LIMIT	= 35,
 };
 
@@ -432,7 +434,8 @@ enum mlx4_update_qp_attr {
 	MLX4_UPDATE_QP_SMAC		= 1 << 0,
 	MLX4_UPDATE_QP_VSD		= 1 << 1,
 	MLX4_UPDATE_QP_RATE_LIMIT	= 1 << 2,
-	MLX4_UPDATE_QP_SUPPORTED_ATTRS	= (1 << 3) - 1
+	MLX4_UPDATE_QP_QOS_VPORT	= 1 << 3,
+	MLX4_UPDATE_QP_SUPPORTED_ATTRS	= (1 << 4) - 1
 };
 
 enum mlx4_update_qp_params_flags {
@@ -441,6 +444,7 @@ enum mlx4_update_qp_params_flags {
 
 struct mlx4_update_qp_params {
 	u8	smac_index;
+	u8	qos_vport;
 	u32	flags;
 	u16	rate_unit;
 	u16	rate_val;
-- 
1.7.1
