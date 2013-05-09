From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net 2/2] net/mlx4: Strengthen VLAN tags/priorities enforcement in VST mode
Date: Thu,  9 May 2013 11:22:35 +0300
Message-ID: <1368087755-3606-3-git-send-email-ogerlitz@mellanox.com>
References: <1368087755-3606-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ronye@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:55171 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751642Ab3EIIWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 04:22:22 -0400
In-Reply-To: <1368087755-3606-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rony Efraim <ronye@mellanox.com>

Make sure that the following steps are taken:

- drop packets sent by the VF with vlan tag
- block packets with vlan tag which are steered to the VF
- drop/block tagged packets when the policy is priority-tagged
- make sure VLAN stripping for received packets is set
- make sure force UP bit for the VF QP is set

Use enum values for all the above instead of numerical bit offsets.

Signed-off-by: Rony Efraim <ronye@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_resources.c  |    2 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   20 +++++++++++--
 include/linux/mlx4/qp.h                            |   29 ++++++++++++++++++-
 3 files changed, 45 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_resources.c b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
index 91f2b2c..d3f5086 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_resources.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
@@ -60,7 +60,7 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 	context->pri_path.sched_queue = 0x83 | (priv->port - 1) << 6;
 	if (user_prio >= 0) {
 		context->pri_path.sched_queue |= user_prio << 3;
-		context->pri_path.feup = 1 << 6;
+		context->pri_path.feup = MLX4_FEUP_FORCE_ETH_UP;
 	}
 	context->pri_path.counter_index = 0xff;
 	context->cqn_send = cpu_to_be32(cqn);
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index d4a9de6..1157f02 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -372,14 +372,28 @@ static int update_vport_qp_param(struct mlx4_dev *dev,
 		if (MLX4_QP_ST_RC == qp_type)
 			return -EINVAL;
 
+		/* force strip vlan by clear vsd */
+		qpc->param3 &= ~cpu_to_be32(MLX4_STRIP_VLAN);
+		if (0 != vp_oper->state.default_vlan) {
+			qpc->pri_path.vlan_control =
+				MLX4_VLAN_CTRL_ETH_TX_BLOCK_TAGGED |
+				MLX4_VLAN_CTRL_ETH_RX_BLOCK_PRIO_TAGGED |
+				MLX4_VLAN_CTRL_ETH_RX_BLOCK_UNTAGGED;
+		} else { /* priority tagged */
+			qpc->pri_path.vlan_control =
+				MLX4_VLAN_CTRL_ETH_TX_BLOCK_TAGGED |
+				MLX4_VLAN_CTRL_ETH_RX_BLOCK_TAGGED;
+		}
+
+		qpc->pri_path.fvl_rx |= MLX4_FVL_RX_FORCE_ETH_VLAN;
 		qpc->pri_path.vlan_index = vp_oper->vlan_idx;
-		qpc->pri_path.fl = (1 << 6) | (1 << 2); /* set cv bit and hide_cqe_vlan bit*/
-		qpc->pri_path.feup |= 1 << 3; /* set fvl bit */
+		qpc->pri_path.fl |= MLX4_FL_CV | MLX4_FL_ETH_HIDE_CQE_VLAN;
+		qpc->pri_path.feup |= MLX4_FEUP_FORCE_ETH_UP | MLX4_FVL_FORCE_ETH_VLAN;
 		qpc->pri_path.sched_queue &= 0xC7;
 		qpc->pri_path.sched_queue |= (vp_oper->state.default_qos) << 3;
 	}
 	if (vp_oper->state.spoofchk) {
-		qpc->pri_path.feup |= 1 << 5; /* set fsm bit */;
+		qpc->pri_path.feup |= MLX4_FSM_FORCE_ETH_SRC_MAC;
 		qpc->pri_path.grh_mylmc = (0x80 & qpc->pri_path.grh_mylmc) + vp_oper->mac_idx;
 	}
 	return 0;
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 67f46ad..352eec9 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -126,7 +126,7 @@ struct mlx4_rss_context {
 
 struct mlx4_qp_path {
 	u8			fl;
-	u8			reserved1[1];
+	u8			vlan_control;
 	u8			disable_pkey_check;
 	u8			pkey_index;
 	u8			counter_index;
@@ -141,11 +141,32 @@ struct mlx4_qp_path {
 	u8			sched_queue;
 	u8			vlan_index;
 	u8			feup;
-	u8			reserved3;
+	u8			fvl_rx;
 	u8			reserved4[2];
 	u8			dmac[6];
 };
 
+enum { /* fl */
+	MLX4_FL_CV      = 1 << 6,
+	MLX4_FL_ETH_HIDE_CQE_VLAN       = 1 << 2
+};
+enum { /* vlan_control */
+	MLX4_VLAN_CTRL_ETH_TX_BLOCK_TAGGED	= 1 << 6,
+	MLX4_VLAN_CTRL_ETH_RX_BLOCK_TAGGED	= 1 << 2,
+	MLX4_VLAN_CTRL_ETH_RX_BLOCK_PRIO_TAGGED	= 1 << 1, /* 802.1p priority tag */
+	MLX4_VLAN_CTRL_ETH_RX_BLOCK_UNTAGGED	= 1 << 0
+};
+
+enum { /* feup */
+	MLX4_FEUP_FORCE_ETH_UP          = 1 << 6, /* force Eth UP */
+	MLX4_FSM_FORCE_ETH_SRC_MAC      = 1 << 5, /* force Source MAC */
+	MLX4_FVL_FORCE_ETH_VLAN         = 1 << 3  /* force Eth vlan */
+};
+
+enum { /* fvl_rx */
+	MLX4_FVL_RX_FORCE_ETH_VLAN      = 1 << 0 /* enforce Eth rx vlan */
+};
+
 struct mlx4_qp_context {
 	__be32			flags;
 	__be32			pd;
@@ -185,6 +206,10 @@ struct mlx4_qp_context {
 	u32			reserved5[10];
 };
 
+enum { /* param3 */
+	MLX4_STRIP_VLAN = 1 << 30
+};
+
 /* Which firmware version adds support for NEC (NoErrorCompletion) bit */
 #define MLX4_FW_VER_WQE_CTRL_NEC mlx4_fw_ver(2, 2, 232)
 
-- 
1.7.1
