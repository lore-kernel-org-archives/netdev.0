From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 08/14] net/mlx5e: Add field select to MTPPS register
Date: Thu, 27 Jul 2017 13:25:26 +0300
Message-ID: <20170727102532.2317-9-saeedm@mellanox.com>
References: <20170727102532.2317-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44961 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751113AbdG0K1N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 06:27:13 -0400
In-Reply-To: <20170727102532.2317-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

In order to mark relevant fields while setting the MTPPS register
add field select. Otherwise it can cause a misconfiguration in
firmware.

Fixes: ee7f12205abc ('net/mlx5e: Implement 1PPS support')
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c | 29 +++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  2 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  5 ++++
 include/linux/mlx5/mlx5_ifc.h                      | 10 +++++---
 4 files changed, 36 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index 66f432385dbb..ab07233e2faa 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -53,6 +53,15 @@ enum {
 	MLX5E_EVENT_MODE_ONCE_TILL_ARM	= 0x2,
 };
 
+enum {
+	MLX5E_MTPPS_FS_ENABLE			= BIT(0x0),
+	MLX5E_MTPPS_FS_PATTERN			= BIT(0x2),
+	MLX5E_MTPPS_FS_PIN_MODE			= BIT(0x3),
+	MLX5E_MTPPS_FS_TIME_STAMP		= BIT(0x4),
+	MLX5E_MTPPS_FS_OUT_PULSE_DURATION	= BIT(0x5),
+	MLX5E_MTPPS_FS_ENH_OUT_PER_ADJ		= BIT(0x7),
+};
+
 void mlx5e_fill_hwstamp(struct mlx5e_tstamp *tstamp, u64 timestamp,
 			struct skb_shared_hwtstamps *hwts)
 {
@@ -221,7 +230,10 @@ static int mlx5e_ptp_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 
 		/* For future use need to add a loop for finding all 1PPS out pins */
 		MLX5_SET(mtpps_reg, in, pin_mode, MLX5E_PIN_MODE_OUT);
-		MLX5_SET(mtpps_reg, in, out_periodic_adjustment, delta & 0xFFFF);
+		MLX5_SET(mtpps_reg, in, enhanced_out_periodic_adjustment, delta);
+		MLX5_SET(mtpps_reg, in, field_select,
+			 MLX5E_MTPPS_FS_PIN_MODE |
+			 MLX5E_MTPPS_FS_ENH_OUT_PER_ADJ);
 
 		mlx5_set_mtpps(priv->mdev, in, sizeof(in));
 	}
@@ -257,8 +269,7 @@ static int mlx5e_extts_configure(struct ptp_clock_info *ptp,
 	int pin = -1;
 	int err = 0;
 
-	if (!MLX5_CAP_GEN(priv->mdev, pps) ||
-	    !MLX5_CAP_GEN(priv->mdev, pps_modify))
+	if (!MLX5_PPS_CAP(priv->mdev))
 		return -EOPNOTSUPP;
 
 	if (rq->extts.index >= tstamp->ptp_info.n_pins)
@@ -277,6 +288,9 @@ static int mlx5e_extts_configure(struct ptp_clock_info *ptp,
 	MLX5_SET(mtpps_reg, in, pin_mode, MLX5E_PIN_MODE_IN);
 	MLX5_SET(mtpps_reg, in, pattern, pattern);
 	MLX5_SET(mtpps_reg, in, enable, on);
+	MLX5_SET(mtpps_reg, in, field_select, MLX5E_MTPPS_FS_PIN_MODE |
+					      MLX5E_MTPPS_FS_PATTERN |
+					      MLX5E_MTPPS_FS_ENABLE);
 
 	err = mlx5_set_mtpps(priv->mdev, in, sizeof(in));
 	if (err)
@@ -302,7 +316,7 @@ static int mlx5e_perout_configure(struct ptp_clock_info *ptp,
 	int pin = -1;
 	s64 ns;
 
-	if (!MLX5_CAP_GEN(priv->mdev, pps_modify))
+	if (!MLX5_PPS_CAP(priv->mdev))
 		return -EOPNOTSUPP;
 
 	if (rq->perout.index >= tstamp->ptp_info.n_pins)
@@ -337,7 +351,10 @@ static int mlx5e_perout_configure(struct ptp_clock_info *ptp,
 	MLX5_SET(mtpps_reg, in, pattern, MLX5E_OUT_PATTERN_PERIODIC);
 	MLX5_SET(mtpps_reg, in, enable, on);
 	MLX5_SET64(mtpps_reg, in, time_stamp, time_stamp);
-
+	MLX5_SET(mtpps_reg, in, field_select, MLX5E_MTPPS_FS_PIN_MODE |
+					      MLX5E_MTPPS_FS_PATTERN |
+					      MLX5E_MTPPS_FS_ENABLE |
+					      MLX5E_MTPPS_FS_TIME_STAMP);
 	return mlx5_set_mtpps(priv->mdev, in, sizeof(in));
 }
 
@@ -487,7 +504,7 @@ void mlx5e_timestamp_init(struct mlx5e_priv *priv)
 #define MAX_PIN_NUM	8
 	tstamp->pps_pin_caps = kzalloc(sizeof(u8) * MAX_PIN_NUM, GFP_KERNEL);
 	if (tstamp->pps_pin_caps) {
-		if (MLX5_CAP_GEN(priv->mdev, pps))
+		if (MLX5_PPS_CAP(priv->mdev))
 			mlx5e_get_pps_caps(priv, tstamp);
 		if (tstamp->ptp_info.n_pins)
 			mlx5e_init_pin_config(tstamp);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index af51a5d2b912..52b9a64cd3a2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -698,7 +698,7 @@ int mlx5_start_eqs(struct mlx5_core_dev *dev)
 	else
 		mlx5_core_dbg(dev, "port_module_event is not set\n");
 
-	if (MLX5_CAP_GEN(dev, pps))
+	if (MLX5_PPS_CAP(dev))
 		async_event_mask |= (1ull << MLX5_EVENT_TYPE_PPS_EVENT);
 
 	if (MLX5_CAP_GEN(dev, fpga))
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 6a3d6bef7dd4..6a263e8d883a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -154,6 +154,11 @@ int mlx5_set_mtpps(struct mlx5_core_dev *mdev, u32 *mtpps, u32 mtpps_size);
 int mlx5_query_mtppse(struct mlx5_core_dev *mdev, u8 pin, u8 *arm, u8 *mode);
 int mlx5_set_mtppse(struct mlx5_core_dev *mdev, u8 pin, u8 arm, u8 mode);
 
+#define MLX5_PPS_CAP(mdev) (MLX5_CAP_GEN((mdev), pps) &&		\
+			    MLX5_CAP_GEN((mdev), pps_modify) &&		\
+			    MLX5_CAP_MCAM_FEATURE((mdev), mtpps_fs) &&	\
+			    MLX5_CAP_MCAM_FEATURE((mdev), mtpps_enh_out_per_adj))
+
 int mlx5_firmware_flash(struct mlx5_core_dev *dev, const struct firmware *fw);
 
 void mlx5e_init(void);
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index fd98aef4545c..3030121b4746 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -7749,8 +7749,10 @@ struct mlx5_ifc_pcam_reg_bits {
 };
 
 struct mlx5_ifc_mcam_enhanced_features_bits {
-	u8         reserved_at_0[0x7f];
+	u8         reserved_at_0[0x7d];
 
+	u8         mtpps_enh_out_per_adj[0x1];
+	u8         mtpps_fs[0x1];
 	u8         pcie_performance_group[0x1];
 };
 
@@ -8159,7 +8161,8 @@ struct mlx5_ifc_mtpps_reg_bits {
 	u8         reserved_at_78[0x4];
 	u8         cap_pin_4_mode[0x4];
 
-	u8         reserved_at_80[0x80];
+	u8         field_select[0x20];
+	u8         reserved_at_a0[0x60];
 
 	u8         enable[0x1];
 	u8         reserved_at_101[0xb];
@@ -8174,8 +8177,9 @@ struct mlx5_ifc_mtpps_reg_bits {
 
 	u8         out_pulse_duration[0x10];
 	u8         out_periodic_adjustment[0x10];
+	u8         enhanced_out_periodic_adjustment[0x20];
 
-	u8         reserved_at_1a0[0x40];
+	u8         reserved_at_1c0[0x20];
 };
 
 struct mlx5_ifc_mtppse_reg_bits {
-- 
2.13.0
