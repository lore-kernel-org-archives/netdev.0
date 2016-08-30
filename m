From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 2/6] net/mlx5e: Read ETS settings directly from firmware
Date: Tue, 30 Aug 2016 14:29:51 +0300
Message-ID: <1472556595-9286-3-git-send-email-saeedm@mellanox.com>
References: <1472556595-9286-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56745 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1758420AbcH3Lan (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 07:30:43 -0400
In-Reply-To: <1472556595-9286-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

Current implementation does not read the setting
directly from FW when ieee_getets is called.

Solution:
1. Read the ETS settings directly from firmware.
2. For tc_tsa:
   a. Initialize tc_tsa to vendor IEEE_8021QAZ_TSA_VENDOR at netdev
      creation.
   b. When reading ETS setting from FW, if the traffic class bandwidth
      is less than 100, set tc_tsa to IEEE_8021QAZ_TSA_ETS. This
      implementation solves the scenarios when the DCBX is in FW control
      and willing bit is on which means the ETS setting is dictated
      by remote switch.

Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  6 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 35 ++++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 26 ++++++++--------
 3 files changed, 46 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 6919e3c..0d41287 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -203,9 +203,6 @@ struct mlx5e_params {
 	u8  toeplitz_hash_key[40];
 	u32 indirection_rqt[MLX5E_INDIR_RQT_SIZE];
 	bool vlan_strip_disable;
-#ifdef CONFIG_MLX5_CORE_EN_DCB
-	struct ieee_ets ets;
-#endif
 	bool rx_am_enabled;
 };
 
@@ -226,6 +223,9 @@ enum {
 
 struct mlx5e_dcbx {
 	struct mlx5e_cee_config    cee_cfg; /* pending configuration */
+
+	/* The only setting that cannot be read from FW */
+	u8                         tc_tsa[IEEE_8021QAZ_MAX_TCS];
 };
 #endif
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index b161dd9..1c10f9c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -45,12 +45,31 @@ static int mlx5e_dcbnl_ieee_getets(struct net_device *netdev,
 				   struct ieee_ets *ets)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	int i;
+	int err = 0;
 
 	if (!MLX5_CAP_GEN(priv->mdev, ets))
 		return -ENOTSUPP;
 
-	memcpy(ets, &priv->params.ets, sizeof(*ets));
-	return 0;
+	ets->ets_cap = mlx5_max_tc(priv->mdev) + 1;
+	for (i = 0; i < ets->ets_cap; i++) {
+		err = mlx5_query_port_prio_tc(mdev, i, &ets->prio_tc[i]);
+		if (err)
+			return err;
+	}
+
+	for (i = 0; i < ets->ets_cap; i++) {
+		err = mlx5_query_port_tc_bw_alloc(mdev, i, &ets->tc_tx_bw[i]);
+		if (err)
+			return err;
+		if (ets->tc_tx_bw[i] < MLX5E_MAX_BW_ALLOC)
+			priv->dcbx.tc_tsa[i] = IEEE_8021QAZ_TSA_ETS;
+	}
+
+	memcpy(ets->tc_tsa, priv->dcbx.tc_tsa, sizeof(ets->tc_tsa));
+
+	return err;
 }
 
 enum {
@@ -127,7 +146,14 @@ int mlx5e_dcbnl_ieee_setets_core(struct mlx5e_priv *priv, struct ieee_ets *ets)
 	if (err)
 		return err;
 
-	return mlx5_set_port_tc_bw_alloc(mdev, tc_tx_bw);
+	err = mlx5_set_port_tc_bw_alloc(mdev, tc_tx_bw);
+
+	if (err)
+		return err;
+
+	memcpy(priv->dcbx.tc_tsa, ets->tc_tsa, sizeof(ets->tc_tsa));
+
+	return err;
 }
 
 static int mlx5e_dbcnl_validate_ets(struct net_device *netdev,
@@ -181,9 +207,6 @@ static int mlx5e_dcbnl_ieee_setets(struct net_device *netdev,
 	if (err)
 		return err;
 
-	memcpy(&priv->params.ets, ets, sizeof(*ets));
-	priv->params.ets.ets_cap = mlx5_max_tc(priv->mdev) + 1;
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 03586ee..8f17928 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2875,17 +2875,23 @@ u16 mlx5e_get_max_inline_cap(struct mlx5_core_dev *mdev)
 static void mlx5e_ets_init(struct mlx5e_priv *priv)
 {
 	int i;
+	struct ieee_ets ets;
 
-	priv->params.ets.ets_cap = mlx5_max_tc(priv->mdev) + 1;
-	for (i = 0; i < priv->params.ets.ets_cap; i++) {
-		priv->params.ets.tc_tx_bw[i] = MLX5E_MAX_BW_ALLOC;
-		priv->params.ets.tc_tsa[i] = IEEE_8021QAZ_TSA_VENDOR;
-		priv->params.ets.prio_tc[i] = i;
+	memset(&ets, 0, sizeof(ets));
+	ets.ets_cap = mlx5_max_tc(priv->mdev) + 1;
+	for (i = 0; i < ets.ets_cap; i++) {
+		ets.tc_tx_bw[i] = MLX5E_MAX_BW_ALLOC;
+		ets.tc_tsa[i] = IEEE_8021QAZ_TSA_VENDOR;
+		ets.prio_tc[i] = i;
 	}
 
+	memcpy(priv->dcbx.tc_tsa, ets.tc_tsa, sizeof(ets.tc_tsa));
+
 	/* tclass[prio=0]=1, tclass[prio=1]=0, tclass[prio=i]=i (for i>1) */
-	priv->params.ets.prio_tc[0] = 1;
-	priv->params.ets.prio_tc[1] = 0;
+	ets.prio_tc[0] = 1;
+	ets.prio_tc[1] = 0;
+
+	mlx5e_dcbnl_ieee_setets_core(priv, &ets);
 }
 #endif
 
@@ -3071,10 +3077,6 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 	priv->profile                      = profile;
 	priv->ppriv                        = ppriv;
 
-#ifdef CONFIG_MLX5_CORE_EN_DCB
-	mlx5e_ets_init(priv);
-#endif
-
 	mutex_init(&priv->state_lock);
 
 	INIT_WORK(&priv->update_carrier_work, mlx5e_update_carrier_work);
@@ -3347,7 +3349,7 @@ static int mlx5e_init_nic_tx(struct mlx5e_priv *priv)
 	}
 
 #ifdef CONFIG_MLX5_CORE_EN_DCB
-	mlx5e_dcbnl_ieee_setets_core(priv, &priv->params.ets);
+	mlx5e_ets_init(priv);
 #endif
 	return 0;
 }
-- 
2.7.4
