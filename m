From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 2/4] net/mlx4: Preparation for VST QinQ
Date: Wed,  6 Jul 2016 15:29:04 +0300
Message-ID: <1467808146-29573-3-git-send-email-tariqt@mellanox.com>
References: <1467808146-29573-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Moshe Shemesh <moshe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33230 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751925AbcGFMaw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 08:30:52 -0400
In-Reply-To: <1467808146-29573-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Shemesh <moshe@mellanox.com>

Check device capability to support VST QinQ mode.
Add vport attribute vlan protocol.
Init vport vlan protocol by default to 802.1Q.
Add update QP support for VST QinQ.
Add func capability vlan_offload_disable to disable all
vlan HW acceleration on VF while the VF is set to VST QinQ mode.

Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |  7 ++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     | 18 ++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.c            | 37 ++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |  2 ++
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 40 ++++++++++++++++++----
 include/linux/mlx4/device.h                        |  3 ++
 include/linux/mlx4/qp.h                            |  2 ++
 7 files changed, 96 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index f04a423..6ca4b2c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1845,6 +1845,7 @@ static int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
 
 	if (vp_oper->state.default_vlan == vp_admin->default_vlan &&
 	    vp_oper->state.default_qos == vp_admin->default_qos &&
+	    vp_oper->state.vlan_proto == vp_admin->vlan_proto &&
 	    vp_oper->state.link_state == vp_admin->link_state &&
 	    vp_oper->state.qos_vport == vp_admin->qos_vport)
 		return 0;
@@ -1903,6 +1904,7 @@ static int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
 
 	vp_oper->state.default_vlan = vp_admin->default_vlan;
 	vp_oper->state.default_qos = vp_admin->default_qos;
+	vp_oper->state.vlan_proto = vp_admin->vlan_proto;
 	vp_oper->state.link_state = vp_admin->link_state;
 	vp_oper->state.qos_vport = vp_admin->qos_vport;
 
@@ -1916,6 +1918,7 @@ static int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
 	work->qos_vport = vp_oper->state.qos_vport;
 	work->vlan_id = vp_oper->state.default_vlan;
 	work->vlan_ix = vp_oper->vlan_idx;
+	work->vlan_proto = vp_oper->state.vlan_proto;
 	work->priv = priv;
 	INIT_WORK(&work->work, mlx4_vf_immed_vlan_work_handler);
 	queue_work(priv->mfunc.master.comm_wq, &work->work);
@@ -2006,6 +2009,8 @@ static int mlx4_master_activate_admin_state(struct mlx4_priv *priv, int slave)
 						   vp_admin->default_vlan, &(vp_oper->vlan_idx));
 			if (err) {
 				vp_oper->vlan_idx = NO_INDX;
+				vp_oper->state.default_vlan = MLX4_VGT;
+				vp_oper->state.vlan_proto = htons(ETH_P_8021Q);
 				mlx4_warn(&priv->dev,
 					  "No vlan resources slave %d, port %d\n",
 					  slave, port);
@@ -2382,6 +2387,8 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 				admin_vport->qos_vport =
 						MLX4_VPP_DEFAULT_VPORT;
 				oper_vport->qos_vport = MLX4_VPP_DEFAULT_VPORT;
+				admin_vport->vlan_proto = htons(ETH_P_8021Q);
+				oper_vport->vlan_proto = htons(ETH_P_8021Q);
 				vf_oper->vport[port].vlan_idx = NO_INDX;
 				vf_oper->vport[port].mac_idx = NO_INDX;
 				mlx4_set_random_admin_guid(dev, i, port);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 6083775..dfba89a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -3022,6 +3022,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	}
 
 	if (mlx4_is_slave(mdev->dev)) {
+		bool vlan_offload_disabled;
 		int phv;
 
 		err = get_phv_bit(mdev->dev, port, &phv);
@@ -3029,6 +3030,23 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 			dev->hw_features |= NETIF_F_HW_VLAN_STAG_TX;
 			priv->pflags |= MLX4_EN_PRIV_FLAGS_PHV;
 		}
+		err = mlx4_get_is_vlan_offload_disabled(mdev->dev, port,
+							&vlan_offload_disabled);
+		if (!err && vlan_offload_disabled) {
+			dev->hw_features &= ~(NETIF_F_HW_VLAN_CTAG_TX |
+					      NETIF_F_HW_VLAN_CTAG_RX |
+					      NETIF_F_HW_VLAN_CTAG_FILTER |
+					      NETIF_F_HW_VLAN_STAG_FILTER |
+					      NETIF_F_HW_VLAN_STAG_TX |
+					      NETIF_F_HW_VLAN_STAG_RX);
+			dev->features &= ~(NETIF_F_HW_VLAN_CTAG_TX |
+					   NETIF_F_HW_VLAN_CTAG_RX |
+					   NETIF_F_HW_VLAN_CTAG_FILTER |
+					   NETIF_F_HW_VLAN_STAG_FILTER |
+					   NETIF_F_HW_VLAN_STAG_TX |
+					   NETIF_F_HW_VLAN_STAG_RX);
+		}
+
 	} else {
 		if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_PHV_EN &&
 		    !(mdev->dev->caps.flags2 &
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 355f05e..6a10129 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -158,7 +158,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[31] = "Modifying loopback source checks using UPDATE_QP support",
 		[32] = "Loopback source checks support",
 		[33] = "RoCEv2 support",
-		[34] = "DMFS Sniffer support (UC & MC)"
+		[34] = "DMFS Sniffer support (UC & MC)",
+		[35] = "QinQ VST mode support",
 	};
 	int i;
 
@@ -313,12 +314,15 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 #define QUERY_FUNC_CAP_FLAGS0_FORCE_PHY_WQE_GID 0x80
 #define QUERY_FUNC_CAP_SUPPORTS_NON_POWER_OF_2_NUM_EQS (1 << 31)
 #define QUERY_FUNC_CAP_PHV_BIT			0x40
+#define QUERY_FUNC_CAP_VLAN_OFFLOAD_DISABLE	0x20
 
 	if (vhcr->op_modifier == 1) {
 		struct mlx4_active_ports actv_ports =
 			mlx4_get_active_ports(dev, slave);
 		int converted_port = mlx4_slave_convert_port(
 				dev, slave, vhcr->in_modifier);
+		struct mlx4_vport_oper_state *vp_oper =
+			&priv->mfunc.master.vf_oper[slave].vport[vhcr->in_modifier];
 
 		if (converted_port < 0)
 			return -EINVAL;
@@ -357,11 +361,12 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 		MLX4_PUT(outbox->buf, dev->caps.phys_port_id[vhcr->in_modifier],
 			 QUERY_FUNC_CAP_PHYS_PORT_ID);
 
-		if (dev->caps.phv_bit[port]) {
-			field = QUERY_FUNC_CAP_PHV_BIT;
-			MLX4_PUT(outbox->buf, field,
-				 QUERY_FUNC_CAP_FLAGS0_OFFSET);
-		}
+		field = 0;
+		if (dev->caps.phv_bit[port])
+			field |= QUERY_FUNC_CAP_PHV_BIT;
+		if (vp_oper->state.vlan_proto == htons(ETH_P_8021AD))
+			field |= QUERY_FUNC_CAP_VLAN_OFFLOAD_DISABLE;
+		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_FLAGS0_OFFSET);
 
 	} else if (vhcr->op_modifier == 0) {
 		struct mlx4_active_ports actv_ports =
@@ -689,6 +694,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_MAX_DESC_SZ_SQ_OFFSET	0x52
 #define QUERY_DEV_CAP_MAX_SG_RQ_OFFSET		0x55
 #define QUERY_DEV_CAP_MAX_DESC_SZ_RQ_OFFSET	0x56
+#define QUERY_DEV_CAP_SVLAN_BY_QP_OFFSET	0x5D
 #define QUERY_DEV_CAP_MAX_QP_MCG_OFFSET		0x61
 #define QUERY_DEV_CAP_RSVD_MCG_OFFSET		0x62
 #define QUERY_DEV_CAP_MAX_MCG_OFFSET		0x63
@@ -855,6 +861,9 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	MLX4_GET(size, outbox, QUERY_DEV_CAP_MAX_DESC_SZ_SQ_OFFSET);
 	dev_cap->max_sq_desc_sz = size;
 
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_SVLAN_BY_QP_OFFSET);
+	if (field & 0x1)
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_SVLAN_BY_QP;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_QP_MCG_OFFSET);
 	dev_cap->max_qp_per_mcg = 1 << field;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_RSVD_MCG_OFFSET);
@@ -2897,6 +2906,22 @@ int set_phv_bit(struct mlx4_dev *dev, u8 port, int new_val)
 }
 EXPORT_SYMBOL(set_phv_bit);
 
+int mlx4_get_is_vlan_offload_disabled(struct mlx4_dev *dev, u8 port,
+				      bool *vlan_offload_disabled)
+{
+	struct mlx4_func_cap func_cap;
+	int err;
+
+	memset(&func_cap, 0, sizeof(func_cap));
+	err = mlx4_QUERY_FUNC_CAP(dev, port, &func_cap);
+	if (!err)
+		*vlan_offload_disabled =
+			!!(func_cap.flags0 &
+			   QUERY_FUNC_CAP_VLAN_OFFLOAD_DISABLE);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_get_is_vlan_offload_disabled);
+
 void mlx4_replace_zero_macs(struct mlx4_dev *dev)
 {
 	int i;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index c9d7fc51..74e58ef 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -507,6 +507,7 @@ struct mlx4_vport_state {
 	u64 mac;
 	u16 default_vlan;
 	u8  default_qos;
+	__be16 vlan_proto;
 	u32 tx_rate;
 	bool spoofchk;
 	u32 link_state;
@@ -655,6 +656,7 @@ struct mlx4_vf_immed_vlan_work {
 	u8                      qos_vport;
 	u16			vlan_id;
 	u16			orig_vlan_id;
+	__be16			vlan_proto;
 };
 
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 8b81114..84d7857 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -790,10 +790,22 @@ static int update_vport_qp_param(struct mlx4_dev *dev,
 				MLX4_VLAN_CTRL_ETH_RX_BLOCK_UNTAGGED |
 				MLX4_VLAN_CTRL_ETH_RX_BLOCK_TAGGED;
 		} else if (0 != vp_oper->state.default_vlan) {
-			qpc->pri_path.vlan_control |=
-				MLX4_VLAN_CTRL_ETH_TX_BLOCK_TAGGED |
-				MLX4_VLAN_CTRL_ETH_RX_BLOCK_PRIO_TAGGED |
-				MLX4_VLAN_CTRL_ETH_RX_BLOCK_UNTAGGED;
+			if (vp_oper->state.vlan_proto == htons(ETH_P_8021AD)) {
+				/* vst QinQ should block untagged on TX,
+				 * but cvlan is in payload and phv is set so
+				 * hw see it as untagged. Block tagged instead.
+				 */
+				qpc->pri_path.vlan_control |=
+					MLX4_VLAN_CTRL_ETH_TX_BLOCK_PRIO_TAGGED |
+					MLX4_VLAN_CTRL_ETH_TX_BLOCK_TAGGED |
+					MLX4_VLAN_CTRL_ETH_RX_BLOCK_PRIO_TAGGED |
+					MLX4_VLAN_CTRL_ETH_RX_BLOCK_UNTAGGED;
+			} else { /* vst 802.1Q */
+				qpc->pri_path.vlan_control |=
+					MLX4_VLAN_CTRL_ETH_TX_BLOCK_TAGGED |
+					MLX4_VLAN_CTRL_ETH_RX_BLOCK_PRIO_TAGGED |
+					MLX4_VLAN_CTRL_ETH_RX_BLOCK_UNTAGGED;
+			}
 		} else { /* priority tagged */
 			qpc->pri_path.vlan_control |=
 				MLX4_VLAN_CTRL_ETH_TX_BLOCK_TAGGED |
@@ -802,7 +814,11 @@ static int update_vport_qp_param(struct mlx4_dev *dev,
 
 		qpc->pri_path.fvl_rx |= MLX4_FVL_RX_FORCE_ETH_VLAN;
 		qpc->pri_path.vlan_index = vp_oper->vlan_idx;
-		qpc->pri_path.fl |= MLX4_FL_CV | MLX4_FL_ETH_HIDE_CQE_VLAN;
+		qpc->pri_path.fl |= MLX4_FL_ETH_HIDE_CQE_VLAN;
+		if (vp_oper->state.vlan_proto == htons(ETH_P_8021AD))
+			qpc->pri_path.fl |= MLX4_FL_SV;
+		else
+			qpc->pri_path.fl |= MLX4_FL_CV;
 		qpc->pri_path.feup |= MLX4_FEUP_FORCE_ETH_UP | MLX4_FVL_FORCE_ETH_VLAN;
 		qpc->pri_path.sched_queue &= 0xC7;
 		qpc->pri_path.sched_queue |= (vp_oper->state.default_qos) << 3;
@@ -5238,6 +5254,7 @@ void mlx4_vf_immed_vlan_work_handler(struct work_struct *_work)
 	u64 qp_path_mask = ((1ULL << MLX4_UPD_QP_PATH_MASK_VLAN_INDEX) |
 		       (1ULL << MLX4_UPD_QP_PATH_MASK_FVL) |
 		       (1ULL << MLX4_UPD_QP_PATH_MASK_CV) |
+		       (1ULL << MLX4_UPD_QP_PATH_MASK_SV) |
 		       (1ULL << MLX4_UPD_QP_PATH_MASK_ETH_HIDE_CQE_VLAN) |
 		       (1ULL << MLX4_UPD_QP_PATH_MASK_FEUP) |
 		       (1ULL << MLX4_UPD_QP_PATH_MASK_FVL_RX) |
@@ -5266,7 +5283,12 @@ void mlx4_vf_immed_vlan_work_handler(struct work_struct *_work)
 	else if (!work->vlan_id)
 		vlan_control = MLX4_VLAN_CTRL_ETH_TX_BLOCK_TAGGED |
 			MLX4_VLAN_CTRL_ETH_RX_BLOCK_TAGGED;
-	else
+	else if (work->vlan_proto == htons(ETH_P_8021AD))
+		vlan_control = MLX4_VLAN_CTRL_ETH_TX_BLOCK_PRIO_TAGGED |
+			MLX4_VLAN_CTRL_ETH_TX_BLOCK_TAGGED |
+			MLX4_VLAN_CTRL_ETH_RX_BLOCK_PRIO_TAGGED |
+			MLX4_VLAN_CTRL_ETH_RX_BLOCK_UNTAGGED;
+	else  /* vst 802.1Q */
 		vlan_control = MLX4_VLAN_CTRL_ETH_TX_BLOCK_TAGGED |
 			MLX4_VLAN_CTRL_ETH_RX_BLOCK_PRIO_TAGGED |
 			MLX4_VLAN_CTRL_ETH_RX_BLOCK_UNTAGGED;
@@ -5311,7 +5333,11 @@ void mlx4_vf_immed_vlan_work_handler(struct work_struct *_work)
 				upd_context->qp_context.pri_path.fvl_rx =
 					qp->fvl_rx | MLX4_FVL_RX_FORCE_ETH_VLAN;
 				upd_context->qp_context.pri_path.fl =
-					qp->pri_path_fl | MLX4_FL_CV | MLX4_FL_ETH_HIDE_CQE_VLAN;
+					qp->pri_path_fl | MLX4_FL_ETH_HIDE_CQE_VLAN;
+				if (work->vlan_proto == htons(ETH_P_8021AD))
+					upd_context->qp_context.pri_path.fl |= MLX4_FL_SV;
+				else
+					upd_context->qp_context.pri_path.fl |= MLX4_FL_CV;
 				upd_context->qp_context.pri_path.feup =
 					qp->feup | MLX4_FEUP_FORCE_ETH_UP | MLX4_FVL_FORCE_ETH_VLAN;
 				upd_context->qp_context.pri_path.sched_queue =
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index e6f6910..09218d1 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -220,6 +220,7 @@ enum {
 	MLX4_DEV_CAP_FLAG2_LB_SRC_CHK           = 1ULL << 32,
 	MLX4_DEV_CAP_FLAG2_ROCE_V1_V2		= 1ULL <<  33,
 	MLX4_DEV_CAP_FLAG2_DMFS_UC_MC_SNIFFER   = 1ULL <<  34,
+	MLX4_DEV_CAP_FLAG2_SVLAN_BY_QP          = 1ULL <<  35,
 };
 
 enum {
@@ -1367,6 +1368,8 @@ int mlx4_SET_PORT_fcs_check(struct mlx4_dev *dev, u8 port,
 int mlx4_SET_PORT_VXLAN(struct mlx4_dev *dev, u8 port, u8 steering, int enable);
 int set_phv_bit(struct mlx4_dev *dev, u8 port, int new_val);
 int get_phv_bit(struct mlx4_dev *dev, u8 port, int *phv);
+int mlx4_get_is_vlan_offload_disabled(struct mlx4_dev *dev, u8 port,
+				      bool *vlan_offload_disabled);
 int mlx4_find_cached_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *idx);
 int mlx4_find_cached_vlan(struct mlx4_dev *dev, u8 port, u16 vid, int *idx);
 int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index);
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 587cdf9..15d5473 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -160,6 +160,7 @@ struct mlx4_qp_path {
 
 enum { /* fl */
 	MLX4_FL_CV	= 1 << 6,
+	MLX4_FL_SV	= 1 << 5,
 	MLX4_FL_ETH_HIDE_CQE_VLAN	= 1 << 2,
 	MLX4_FL_ETH_SRC_CHECK_MC_LB	= 1 << 1,
 	MLX4_FL_ETH_SRC_CHECK_UC_LB	= 1 << 0,
@@ -267,6 +268,7 @@ enum {
 	MLX4_UPD_QP_PATH_MASK_FVL_RX			= 16 + 32,
 	MLX4_UPD_QP_PATH_MASK_ETH_SRC_CHECK_UC_LB	= 18 + 32,
 	MLX4_UPD_QP_PATH_MASK_ETH_SRC_CHECK_MC_LB	= 19 + 32,
+	MLX4_UPD_QP_PATH_MASK_SV			= 22 + 32,
 };
 
 enum { /* param3 */
-- 
1.8.3.1
