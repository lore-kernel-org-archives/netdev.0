From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 3/3] net/mlx4_en: Add QCN parameters and statistics handling
Date: Thu,  5 Mar 2015 20:16:13 +0200
Message-ID: <1425579373-25899-4-git-send-email-ogerlitz@mellanox.com>
References: <1425579373-25899-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:33910 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758658AbbCESQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 13:16:30 -0500
In-Reply-To: <1425579373-25899-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shani Michaeli <shanim@mellanox.com>

Implement the IEEE DCB handlers for set/get QCN parameters and
statistics reading per TC.

Signed-off-by: Shani Michaeli <shanim@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |  218 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    1 +
 2 files changed, 219 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index c95ca25..cde14fa 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -36,6 +36,49 @@
 
 #include "mlx4_en.h"
 
+/* Definitions for QCN
+ */
+
+struct mlx4_congestion_control_mb_prio_802_1_qau_params {
+	__be32 modify_enable_high;
+	__be32 modify_enable_low;
+	__be32 reserved1;
+	__be32 extended_enable;
+	__be32 rppp_max_rps;
+	__be32 rpg_time_reset;
+	__be32 rpg_byte_reset;
+	__be32 rpg_threshold;
+	__be32 rpg_max_rate;
+	__be32 rpg_ai_rate;
+	__be32 rpg_hai_rate;
+	__be32 rpg_gd;
+	__be32 rpg_min_dec_fac;
+	__be32 rpg_min_rate;
+	__be32 max_time_rise;
+	__be32 max_byte_rise;
+	__be32 max_qdelta;
+	__be32 min_qoffset;
+	__be32 gd_coefficient;
+	__be32 reserved2[5];
+	__be32 cp_sample_base;
+	__be32 reserved3[39];
+};
+
+struct mlx4_congestion_control_mb_prio_802_1_qau_statistics {
+	__be64 rppp_rp_centiseconds;
+	__be32 reserved1;
+	__be32 ignored_cnm;
+	__be32 rppp_created_rps;
+	__be32 estimated_total_rate;
+	__be32 max_active_rate_limiter_index;
+	__be32 dropped_cnms_busy_fw;
+	__be32 reserved2;
+	__be32 cnms_handled_successfully;
+	__be32 min_total_limiters_rate;
+	__be32 max_total_limiters_rate;
+	__be32 reserved3[4];
+};
+
 static int mlx4_en_dcbnl_ieee_getets(struct net_device *dev,
 				   struct ieee_ets *ets)
 {
@@ -242,6 +285,178 @@ static int mlx4_en_dcbnl_ieee_setmaxrate(struct net_device *dev,
 	return 0;
 }
 
+#define RPG_ENABLE_BIT	31
+#define CN_TAG_BIT	30
+
+static int mlx4_en_dcbnl_ieee_getqcn(struct net_device *dev,
+				     struct ieee_qcn *qcn)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_congestion_control_mb_prio_802_1_qau_params *hw_qcn;
+	struct mlx4_cmd_mailbox *mailbox_out = NULL;
+	u64 mailbox_in_dma = 0;
+	u32 inmod = 0;
+	int i, err;
+
+	if (!(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_QCN))
+		return -EOPNOTSUPP;
+
+	mailbox_out = mlx4_alloc_cmd_mailbox(priv->mdev->dev);
+	if (IS_ERR(mailbox_out))
+		return -ENOMEM;
+	hw_qcn =
+	(struct mlx4_congestion_control_mb_prio_802_1_qau_params *)
+	mailbox_out->buf;
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		inmod = priv->port | ((1 << i) << 8) |
+			 (MLX4_CTRL_ALGO_802_1_QAU_REACTION_POINT << 16);
+		err = mlx4_cmd_box(priv->mdev->dev, mailbox_in_dma,
+				   mailbox_out->dma,
+				   inmod, MLX4_CONGESTION_CONTROL_GET_PARAMS,
+				   MLX4_CMD_CONGESTION_CTRL_OPCODE,
+				   MLX4_CMD_TIME_CLASS_C,
+				   MLX4_CMD_NATIVE);
+		if (err) {
+			mlx4_free_cmd_mailbox(priv->mdev->dev, mailbox_out);
+			return err;
+		}
+
+		qcn->rpg_enable[i] =
+			be32_to_cpu(hw_qcn->extended_enable) >> RPG_ENABLE_BIT;
+		qcn->rppp_max_rps[i] =
+			be32_to_cpu(hw_qcn->rppp_max_rps);
+		qcn->rpg_time_reset[i] =
+			be32_to_cpu(hw_qcn->rpg_time_reset);
+		qcn->rpg_byte_reset[i] =
+			be32_to_cpu(hw_qcn->rpg_byte_reset);
+		qcn->rpg_threshold[i] =
+			be32_to_cpu(hw_qcn->rpg_threshold);
+		qcn->rpg_max_rate[i] =
+			be32_to_cpu(hw_qcn->rpg_max_rate);
+		qcn->rpg_ai_rate[i] =
+			be32_to_cpu(hw_qcn->rpg_ai_rate);
+		qcn->rpg_hai_rate[i] =
+			be32_to_cpu(hw_qcn->rpg_hai_rate);
+		qcn->rpg_gd[i] =
+			be32_to_cpu(hw_qcn->rpg_gd);
+		qcn->rpg_min_dec_fac[i] =
+			be32_to_cpu(hw_qcn->rpg_min_dec_fac);
+		qcn->rpg_min_rate[i] =
+			be32_to_cpu(hw_qcn->rpg_min_rate);
+		qcn->cndd_state_machine[i] =
+			priv->cndd_state[i];
+	}
+	mlx4_free_cmd_mailbox(priv->mdev->dev, mailbox_out);
+	return 0;
+}
+
+static int mlx4_en_dcbnl_ieee_setqcn(struct net_device *dev,
+				     struct ieee_qcn *qcn)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_congestion_control_mb_prio_802_1_qau_params *hw_qcn;
+	struct mlx4_cmd_mailbox *mailbox_in = NULL;
+	u64 mailbox_in_dma = 0;
+	u32 inmod = 0;
+	int i, err;
+#define MODIFY_ENABLE_HIGH_MASK 0xc0000000
+#define MODIFY_ENABLE_LOW_MASK 0xffc00000
+
+	if (!(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_QCN))
+		return -EOPNOTSUPP;
+
+	mailbox_in = mlx4_alloc_cmd_mailbox(priv->mdev->dev);
+	if (IS_ERR(mailbox_in))
+		return -ENOMEM;
+
+	mailbox_in_dma = mailbox_in->dma;
+	hw_qcn =
+	(struct mlx4_congestion_control_mb_prio_802_1_qau_params *)mailbox_in->buf;
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		inmod = priv->port | ((1 << i) << 8) |
+			 (MLX4_CTRL_ALGO_802_1_QAU_REACTION_POINT << 16);
+
+		/* Before updating QCN parameter,
+		 * need to set it's modify enable bit to 1
+		 */
+
+		hw_qcn->modify_enable_high = cpu_to_be32(
+						MODIFY_ENABLE_HIGH_MASK);
+		hw_qcn->modify_enable_low = cpu_to_be32(MODIFY_ENABLE_LOW_MASK);
+
+		hw_qcn->extended_enable = cpu_to_be32(qcn->rpg_enable[i] << RPG_ENABLE_BIT);
+		hw_qcn->rppp_max_rps = cpu_to_be32(qcn->rppp_max_rps[i]);
+		hw_qcn->rpg_time_reset = cpu_to_be32(qcn->rpg_time_reset[i]);
+		hw_qcn->rpg_byte_reset = cpu_to_be32(qcn->rpg_byte_reset[i]);
+		hw_qcn->rpg_threshold = cpu_to_be32(qcn->rpg_threshold[i]);
+		hw_qcn->rpg_max_rate = cpu_to_be32(qcn->rpg_max_rate[i]);
+		hw_qcn->rpg_ai_rate = cpu_to_be32(qcn->rpg_ai_rate[i]);
+		hw_qcn->rpg_hai_rate = cpu_to_be32(qcn->rpg_hai_rate[i]);
+		hw_qcn->rpg_gd = cpu_to_be32(qcn->rpg_gd[i]);
+		hw_qcn->rpg_min_dec_fac = cpu_to_be32(qcn->rpg_min_dec_fac[i]);
+		hw_qcn->rpg_min_rate = cpu_to_be32(qcn->rpg_min_rate[i]);
+		priv->cndd_state[i] = qcn->cndd_state_machine[i];
+		if (qcn->cndd_state_machine[i] == DCB_CNDD_INTERIOR_READY)
+			hw_qcn->extended_enable |= cpu_to_be32(1 << CN_TAG_BIT);
+
+		err = mlx4_cmd(priv->mdev->dev, mailbox_in_dma, inmod,
+			       MLX4_CONGESTION_CONTROL_SET_PARAMS,
+			       MLX4_CMD_CONGESTION_CTRL_OPCODE,
+			       MLX4_CMD_TIME_CLASS_C,
+			       MLX4_CMD_NATIVE);
+		if (err) {
+			mlx4_free_cmd_mailbox(priv->mdev->dev, mailbox_in);
+			return err;
+		}
+	}
+	mlx4_free_cmd_mailbox(priv->mdev->dev, mailbox_in);
+	return 0;
+}
+
+static int mlx4_en_dcbnl_ieee_getqcnstats(struct net_device *dev,
+					  struct ieee_qcn_stats *qcn_stats)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_congestion_control_mb_prio_802_1_qau_statistics *hw_qcn_stats;
+	struct mlx4_cmd_mailbox *mailbox_out = NULL;
+	u64 mailbox_in_dma = 0;
+	u32 inmod = 0;
+	int i, err;
+
+	if (!(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_QCN))
+		return -EOPNOTSUPP;
+
+	mailbox_out = mlx4_alloc_cmd_mailbox(priv->mdev->dev);
+	if (IS_ERR(mailbox_out))
+		return -ENOMEM;
+
+	hw_qcn_stats =
+	(struct mlx4_congestion_control_mb_prio_802_1_qau_statistics *)
+	mailbox_out->buf;
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		inmod = priv->port | ((1 << i) << 8) |
+			 (MLX4_CTRL_ALGO_802_1_QAU_REACTION_POINT << 16);
+		err = mlx4_cmd_box(priv->mdev->dev, mailbox_in_dma,
+				   mailbox_out->dma, inmod,
+				   MLX4_CONGESTION_CONTROL_GET_STATISTICS,
+				   MLX4_CMD_CONGESTION_CTRL_OPCODE,
+				   MLX4_CMD_TIME_CLASS_C,
+				   MLX4_CMD_NATIVE);
+		if (err) {
+			mlx4_free_cmd_mailbox(priv->mdev->dev, mailbox_out);
+			return err;
+		}
+		qcn_stats->rppp_rp_centiseconds[i] =
+			be64_to_cpu(hw_qcn_stats->rppp_rp_centiseconds);
+		qcn_stats->rppp_created_rps[i] =
+			be32_to_cpu(hw_qcn_stats->rppp_created_rps);
+	}
+	mlx4_free_cmd_mailbox(priv->mdev->dev, mailbox_out);
+	return 0;
+}
+
 const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops = {
 	.ieee_getets	= mlx4_en_dcbnl_ieee_getets,
 	.ieee_setets	= mlx4_en_dcbnl_ieee_setets,
@@ -252,6 +467,9 @@ const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops = {
 
 	.getdcbx	= mlx4_en_dcbnl_getdcbx,
 	.setdcbx	= mlx4_en_dcbnl_setdcbx,
+	.ieee_getqcn	= mlx4_en_dcbnl_ieee_getqcn,
+	.ieee_setqcn	= mlx4_en_dcbnl_ieee_setqcn,
+	.ieee_getqcnstats = mlx4_en_dcbnl_ieee_getqcnstats,
 };
 
 const struct dcbnl_rtnl_ops mlx4_en_dcbnl_pfc_ops = {
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 2a8268e..94553b5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -608,6 +608,7 @@ struct mlx4_en_priv {
 #ifdef CONFIG_MLX4_EN_DCB
 	struct ieee_ets ets;
 	u16 maxrate[IEEE_8021QAZ_MAX_TCS];
+	enum dcbnl_cndd_states cndd_state[IEEE_8021QAZ_MAX_TCS];
 #endif
 #ifdef CONFIG_RFS_ACCEL
 	spinlock_t filters_lock;
-- 
1.7.1
