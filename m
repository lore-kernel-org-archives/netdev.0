From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 5/6] net/mlx5e: ConnectX-4 firmware support for DCBX
Date: Tue,  6 Sep 2016 19:04:11 +0300
Message-ID: <1473177852-10711-6-git-send-email-saeedm@mellanox.com>
References: <1473177852-10711-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51621 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933337AbcIFQEn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 12:04:43 -0400
In-Reply-To: <1473177852-10711-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

DBCX by default is controlled by firmware. In this
mode, firmware is responsible for reading/sending the TLVs packets
from/to the remote partner. When the driver is loaded, the driver
can leave the DCBX in firmware controlled mode or
switch the DCBX back to host controlled mode.

This patch sets up the infrastructure to support changing
DCBX control mode.

Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   6 +
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 147 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  26 +---
 3 files changed, 154 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 0d41287..806f5e8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -222,6 +222,7 @@ enum {
 };
 
 struct mlx5e_dcbx {
+	enum mlx5_dcbx_oper_mode   mode;
 	struct mlx5e_cee_config    cee_cfg; /* pending configuration */
 
 	/* The only setting that cannot be read from FW */
@@ -810,6 +811,11 @@ extern const struct ethtool_ops mlx5e_ethtool_ops;
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 extern const struct dcbnl_rtnl_ops mlx5e_dcbnl_ops;
 int mlx5e_dcbnl_ieee_setets_core(struct mlx5e_priv *priv, struct ieee_ets *ets);
+int mlx5e_dcbnl_set_dcbx_mode(struct mlx5e_priv *priv,
+			      enum mlx5_dcbx_oper_mode mode);
+void mlx5e_dcbnl_query_dcbx_mode(struct mlx5e_priv *priv,
+				 enum mlx5_dcbx_oper_mode *mode);
+void mlx5e_dcbnl_initialize(struct mlx5e_priv *priv);
 #endif
 
 #ifndef CONFIG_RFS_ACCEL
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index 8f6b5a7..c33cdba 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -41,6 +41,26 @@
 #define MLX5E_CEE_STATE_UP    1
 #define MLX5E_CEE_STATE_DOWN  0
 
+/* If dcbx mode is non-host and qos_with_dcbx_by_fw is off, set the
+ * dcbx mode to host.
+ */
+static inline bool mlx5e_dcbnl_is_allowed(struct mlx5e_priv *priv)
+{
+	struct mlx5e_dcbx *dcbx = &priv->dcbx;
+
+	if (!MLX5_CAP_GEN(priv->mdev, dcbx))
+		return true;
+
+	if (dcbx->mode == MLX5E_DCBX_PARAM_VER_OPER_HOST)
+		return true;
+
+	if (mlx5e_dcbnl_set_dcbx_mode(priv, MLX5E_DCBX_PARAM_VER_OPER_HOST))
+		return false;
+
+	dcbx->mode = MLX5E_DCBX_PARAM_VER_OPER_HOST;
+	return true;
+}
+
 static int mlx5e_dcbnl_ieee_getets(struct net_device *netdev,
 				   struct ieee_ets *ets)
 {
@@ -52,6 +72,9 @@ static int mlx5e_dcbnl_ieee_getets(struct net_device *netdev,
 	if (!MLX5_CAP_GEN(priv->mdev, ets))
 		return -ENOTSUPP;
 
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return -EPERM;
+
 	ets->ets_cap = mlx5_max_tc(priv->mdev) + 1;
 	for (i = 0; i < ets->ets_cap; i++) {
 		err = mlx5_query_port_prio_tc(mdev, i, &ets->prio_tc[i]);
@@ -199,6 +222,12 @@ static int mlx5e_dcbnl_ieee_setets(struct net_device *netdev,
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	int err;
 
+	if (!MLX5_CAP_GEN(priv->mdev, ets))
+		return -ENOTSUPP;
+
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return -EPERM;
+
 	err = mlx5e_dbcnl_validate_ets(netdev, ets);
 	if (err)
 		return err;
@@ -218,6 +247,9 @@ static int mlx5e_dcbnl_ieee_getpfc(struct net_device *dev,
 	struct mlx5e_pport_stats *pstats = &priv->stats.pport;
 	int i;
 
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return -EPERM;
+
 	pfc->pfc_cap = mlx5_max_tc(mdev) + 1;
 	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
 		pfc->requests[i]    = PPORT_PER_PRIO_GET(pstats, i, tx_pause);
@@ -235,6 +267,9 @@ static int mlx5e_dcbnl_ieee_setpfc(struct net_device *dev,
 	u8 curr_pfc_en;
 	int ret;
 
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return -EPERM;
+
 	mlx5_query_port_pfc(mdev, &curr_pfc_en, NULL);
 
 	if (pfc->pfc_en == curr_pfc_en)
@@ -255,6 +290,9 @@ static u8 mlx5e_dcbnl_getdcbx(struct net_device *dev)
 
 static u8 mlx5e_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 {
+	if (!mlx5e_dcbnl_is_allowed(netdev_priv(dev)))
+		return 1;
+
 	if ((mode & DCB_CAP_DCBX_LLD_MANAGED) ||
 	    !(mode & DCB_CAP_DCBX_VER_CEE) ||
 	    !(mode & DCB_CAP_DCBX_VER_IEEE) ||
@@ -274,6 +312,9 @@ static int mlx5e_dcbnl_ieee_getmaxrate(struct net_device *netdev,
 	int err;
 	int i;
 
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return -EPERM;
+
 	err = mlx5_query_port_ets_rate_limit(mdev, max_bw_value, max_bw_unit);
 	if (err)
 		return err;
@@ -309,6 +350,9 @@ static int mlx5e_dcbnl_ieee_setmaxrate(struct net_device *netdev,
 	__u64 upper_limit_mbps = roundup(255 * MLX5E_100MB, MLX5E_1GB);
 	int i;
 
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return -EPERM;
+
 	memset(max_bw_value, 0, sizeof(max_bw_value));
 	memset(max_bw_unit, 0, sizeof(max_bw_unit));
 
@@ -342,6 +386,9 @@ static u8 mlx5e_dcbnl_setall(struct net_device *netdev)
 	int err;
 	int i;
 
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return MLX5_DCB_NO_CHG;
+
 	memset(&ets, 0, sizeof(ets));
 	memset(&pfc, 0, sizeof(pfc));
 
@@ -395,6 +442,9 @@ static void mlx5e_dcbnl_getpermhwaddr(struct net_device *netdev,
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return;
+
 	if (!perm_addr)
 		return;
 
@@ -408,6 +458,9 @@ static void mlx5e_dcbnl_setpgtccfgtx(struct net_device *netdev,
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5e_cee_config *cee_cfg = &priv->dcbx.cee_cfg;
 
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return;
+
 	if (priority >= CEE_DCBX_MAX_PRIO) {
 		netdev_err(netdev,
 			   "%s, priority is out of range\n", __func__);
@@ -429,6 +482,9 @@ static void mlx5e_dcbnl_setpgbwgcfgtx(struct net_device *netdev,
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5e_cee_config *cee_cfg = &priv->dcbx.cee_cfg;
 
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return;
+
 	if (pgid >= CEE_DCBX_MAX_PGS) {
 		netdev_err(netdev,
 			   "%s, priority group is out of range\n", __func__);
@@ -445,6 +501,9 @@ static void mlx5e_dcbnl_getpgtccfgtx(struct net_device *netdev,
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return;
+
 	if (priority >= CEE_DCBX_MAX_PRIO) {
 		netdev_err(netdev,
 			   "%s, priority is out of range\n", __func__);
@@ -465,6 +524,9 @@ static void mlx5e_dcbnl_getpgbwgcfgtx(struct net_device *netdev,
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return;
+
 	if (pgid >= CEE_DCBX_MAX_PGS) {
 		netdev_err(netdev,
 			   "%s, priority group is out of range\n", __func__);
@@ -481,6 +543,9 @@ static void mlx5e_dcbnl_setpfccfg(struct net_device *netdev,
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5e_cee_config *cee_cfg = &priv->dcbx.cee_cfg;
 
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return;
+
 	if (priority >= CEE_DCBX_MAX_PRIO) {
 		netdev_err(netdev,
 			   "%s, priority is out of range\n", __func__);
@@ -513,6 +578,9 @@ mlx5e_dcbnl_get_priority_pfc(struct net_device *netdev,
 static void mlx5e_dcbnl_getpfccfg(struct net_device *netdev,
 				  int priority, u8 *setting)
 {
+	if (!mlx5e_dcbnl_is_allowed(netdev_priv(netdev)))
+		return;
+
 	if (priority >= CEE_DCBX_MAX_PRIO) {
 		netdev_err(netdev,
 			   "%s, priority is out of range\n", __func__);
@@ -532,6 +600,9 @@ static u8 mlx5e_dcbnl_getcap(struct net_device *netdev,
 	struct mlx5_core_dev *mdev = priv->mdev;
 	u8 rval = 0;
 
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return 1;
+
 	switch (capid) {
 	case DCB_CAP_ATTR_PG:
 		*cap = true;
@@ -574,6 +645,9 @@ static int mlx5e_dcbnl_getnumtcs(struct net_device *netdev,
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return -EPERM;
+
 	switch (tcs_id) {
 	case DCB_NUMTCS_ATTR_PG:
 	case DCB_NUMTCS_ATTR_PFC:
@@ -590,6 +664,9 @@ static u8 mlx5e_dcbnl_getpfcstate(struct net_device *netdev)
 {
 	struct ieee_pfc pfc;
 
+	if (!mlx5e_dcbnl_is_allowed(netdev_priv(netdev)))
+		return MLX5E_CEE_STATE_DOWN;
+
 	if (mlx5e_dcbnl_ieee_getpfc(netdev, &pfc))
 		return MLX5E_CEE_STATE_DOWN;
 
@@ -601,6 +678,9 @@ static void mlx5e_dcbnl_setpfcstate(struct net_device *netdev, u8 state)
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5e_cee_config *cee_cfg = &priv->dcbx.cee_cfg;
 
+	if (!mlx5e_dcbnl_is_allowed(priv))
+		return;
+
 	if ((state != MLX5E_CEE_STATE_UP) && (state != MLX5E_CEE_STATE_DOWN))
 		return;
 
@@ -634,3 +714,70 @@ const struct dcbnl_rtnl_ops mlx5e_dcbnl_ops = {
 	.getpfcstate    = mlx5e_dcbnl_getpfcstate,
 	.setpfcstate    = mlx5e_dcbnl_setpfcstate,
 };
+
+void mlx5e_dcbnl_query_dcbx_mode(struct mlx5e_priv *priv,
+				 enum mlx5_dcbx_oper_mode *mode)
+{
+	u32 out[MLX5_ST_SZ_DW(dcbx_param)];
+
+	*mode = MLX5E_DCBX_PARAM_VER_OPER_HOST;
+
+	if (!mlx5_query_port_dcbx_param(priv->mdev, out))
+		*mode = MLX5_GET(dcbx_param, out, version_oper);
+
+	/* From driver's point of view, we only care if the mode
+	 * is host (HOST) or non-host (AUTO)
+	 */
+	if (*mode != MLX5E_DCBX_PARAM_VER_OPER_HOST)
+		*mode = MLX5E_DCBX_PARAM_VER_OPER_AUTO;
+}
+
+int mlx5e_dcbnl_set_dcbx_mode(struct mlx5e_priv *priv,
+			      enum mlx5_dcbx_oper_mode mode)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	u32 tmp[MLX5_ST_SZ_DW(dcbx_param)];
+	int err;
+
+	err = mlx5_query_port_dcbx_param(mdev, tmp);
+	if (err)
+		return err;
+
+	MLX5_SET(dcbx_param, tmp, version_admin, mode);
+	if (mode != MLX5E_DCBX_PARAM_VER_OPER_HOST)
+		MLX5_SET(dcbx_param, tmp, willing_admin, 1);
+
+	return mlx5_set_port_dcbx_param(mdev, tmp);
+}
+
+static void mlx5e_ets_init(struct mlx5e_priv *priv)
+{
+	int i;
+	struct ieee_ets ets;
+
+	memset(&ets, 0, sizeof(ets));
+	ets.ets_cap = mlx5_max_tc(priv->mdev) + 1;
+	for (i = 0; i < ets.ets_cap; i++) {
+		ets.tc_tx_bw[i] = MLX5E_MAX_BW_ALLOC;
+		ets.tc_tsa[i] = IEEE_8021QAZ_TSA_VENDOR;
+		ets.prio_tc[i] = i;
+	}
+
+	memcpy(priv->dcbx.tc_tsa, ets.tc_tsa, sizeof(ets.tc_tsa));
+
+	/* tclass[prio=0]=1, tclass[prio=1]=0, tclass[prio=i]=i (for i>1) */
+	ets.prio_tc[0] = 1;
+	ets.prio_tc[1] = 0;
+
+	mlx5e_dcbnl_ieee_setets_core(priv, &ets);
+}
+
+void mlx5e_dcbnl_initialize(struct mlx5e_priv *priv)
+{
+	struct mlx5e_dcbx *dcbx = &priv->dcbx;
+
+	if (MLX5_CAP_GEN(priv->mdev, dcbx))
+		mlx5e_dcbnl_query_dcbx_mode(priv, &dcbx->mode);
+
+	mlx5e_ets_init(priv);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index da70ef3..469456c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2871,30 +2871,6 @@ u16 mlx5e_get_max_inline_cap(struct mlx5_core_dev *mdev)
 	       2 /*sizeof(mlx5e_tx_wqe.inline_hdr_start)*/;
 }
 
-#ifdef CONFIG_MLX5_CORE_EN_DCB
-static void mlx5e_ets_init(struct mlx5e_priv *priv)
-{
-	int i;
-	struct ieee_ets ets;
-
-	memset(&ets, 0, sizeof(ets));
-	ets.ets_cap = mlx5_max_tc(priv->mdev) + 1;
-	for (i = 0; i < ets.ets_cap; i++) {
-		ets.tc_tx_bw[i] = MLX5E_MAX_BW_ALLOC;
-		ets.tc_tsa[i] = IEEE_8021QAZ_TSA_VENDOR;
-		ets.prio_tc[i] = i;
-	}
-
-	memcpy(priv->dcbx.tc_tsa, ets.tc_tsa, sizeof(ets.tc_tsa));
-
-	/* tclass[prio=0]=1, tclass[prio=1]=0, tclass[prio=i]=i (for i>1) */
-	ets.prio_tc[0] = 1;
-	ets.prio_tc[1] = 0;
-
-	mlx5e_dcbnl_ieee_setets_core(priv, &ets);
-}
-#endif
-
 void mlx5e_build_default_indir_rqt(struct mlx5_core_dev *mdev,
 				   u32 *indirection_rqt, int len,
 				   int num_channels)
@@ -3350,7 +3326,7 @@ static int mlx5e_init_nic_tx(struct mlx5e_priv *priv)
 	}
 
 #ifdef CONFIG_MLX5_CORE_EN_DCB
-	mlx5e_ets_init(priv);
+	mlx5e_dcbnl_initialize(priv);
 #endif
 	return 0;
 }
-- 
2.7.4
