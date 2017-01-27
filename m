From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 7/8] net/mlx5e: Fix update of hash function/key via ethtool
Date: Fri, 27 Jan 2017 22:38:42 +0200
Message-ID: <20170127203843.3206-8-saeedm@mellanox.com>
References: <20170127203843.3206-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:33320 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751358AbdA0VLL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 16:11:11 -0500
In-Reply-To: <20170127203843.3206-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Modifying TIR hash should change selected fields bitmask in addition to
the function and key.
Formerly, we would not set this field resulting in zeroing of its value,
which means no packet fields are used for RX RSS hash calculation thus
causing all traffic to arrive in RQ[0].

Fixes: bdfc028de1b3 ("net/mlx5e: Fix ethtool RX hash func configuration change")
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   3 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  13 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 198 ++++++++++-----------
 3 files changed, 109 insertions(+), 105 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 1619147a63e8..d5ecb8f53fd4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -791,7 +791,8 @@ void mlx5e_disable_vlan_filter(struct mlx5e_priv *priv);
 int mlx5e_modify_rqs_vsd(struct mlx5e_priv *priv, bool vsd);
 
 int mlx5e_redirect_rqt(struct mlx5e_priv *priv, u32 rqtn, int sz, int ix);
-void mlx5e_build_tir_ctx_hash(void *tirc, struct mlx5e_priv *priv);
+void mlx5e_build_indir_tir_ctx_hash(struct mlx5e_priv *priv, void *tirc,
+				    enum mlx5e_traffic_types tt);
 
 int mlx5e_open_locked(struct net_device *netdev);
 int mlx5e_close_locked(struct net_device *netdev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 6f4eb34259f0..bb67863aa361 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -980,15 +980,18 @@ static int mlx5e_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 
 static void mlx5e_modify_tirs_hash(struct mlx5e_priv *priv, void *in, int inlen)
 {
-	struct mlx5_core_dev *mdev = priv->mdev;
 	void *tirc = MLX5_ADDR_OF(modify_tir_in, in, ctx);
-	int i;
+	struct mlx5_core_dev *mdev = priv->mdev;
+	int ctxlen = MLX5_ST_SZ_BYTES(tirc);
+	int tt;
 
 	MLX5_SET(modify_tir_in, in, bitmask.hash, 1);
-	mlx5e_build_tir_ctx_hash(tirc, priv);
 
-	for (i = 0; i < MLX5E_NUM_INDIR_TIRS; i++)
-		mlx5_core_modify_tir(mdev, priv->indir_tir[i].tirn, in, inlen);
+	for (tt = 0; tt < MLX5E_NUM_INDIR_TIRS; tt++) {
+		memset(tirc, 0, ctxlen);
+		mlx5e_build_indir_tir_ctx_hash(priv, tirc, tt);
+		mlx5_core_modify_tir(mdev, priv->indir_tir[tt].tirn, in, inlen);
+	}
 }
 
 static int mlx5e_set_rxfh(struct net_device *dev, const u32 *indir,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 948351ae5bd2..f14ca3385fdd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2022,8 +2022,23 @@ static void mlx5e_build_tir_ctx_lro(void *tirc, struct mlx5e_priv *priv)
 	MLX5_SET(tirc, tirc, lro_timeout_period_usecs, priv->params.lro_timeout);
 }
 
-void mlx5e_build_tir_ctx_hash(void *tirc, struct mlx5e_priv *priv)
+void mlx5e_build_indir_tir_ctx_hash(struct mlx5e_priv *priv, void *tirc,
+				    enum mlx5e_traffic_types tt)
 {
+	void *hfso = MLX5_ADDR_OF(tirc, tirc, rx_hash_field_selector_outer);
+
+#define MLX5_HASH_IP            (MLX5_HASH_FIELD_SEL_SRC_IP   |\
+				 MLX5_HASH_FIELD_SEL_DST_IP)
+
+#define MLX5_HASH_IP_L4PORTS    (MLX5_HASH_FIELD_SEL_SRC_IP   |\
+				 MLX5_HASH_FIELD_SEL_DST_IP   |\
+				 MLX5_HASH_FIELD_SEL_L4_SPORT |\
+				 MLX5_HASH_FIELD_SEL_L4_DPORT)
+
+#define MLX5_HASH_IP_IPSEC_SPI  (MLX5_HASH_FIELD_SEL_SRC_IP   |\
+				 MLX5_HASH_FIELD_SEL_DST_IP   |\
+				 MLX5_HASH_FIELD_SEL_IPSEC_SPI)
+
 	MLX5_SET(tirc, tirc, rx_hash_fn,
 		 mlx5e_rx_hash_fn(priv->params.rss_hfunc));
 	if (priv->params.rss_hfunc == ETH_RSS_HASH_TOP) {
@@ -2035,6 +2050,88 @@ void mlx5e_build_tir_ctx_hash(void *tirc, struct mlx5e_priv *priv)
 		MLX5_SET(tirc, tirc, rx_hash_symmetric, 1);
 		memcpy(rss_key, priv->params.toeplitz_hash_key, len);
 	}
+
+	switch (tt) {
+	case MLX5E_TT_IPV4_TCP:
+		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
+			 MLX5_L3_PROT_TYPE_IPV4);
+		MLX5_SET(rx_hash_field_select, hfso, l4_prot_type,
+			 MLX5_L4_PROT_TYPE_TCP);
+		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
+			 MLX5_HASH_IP_L4PORTS);
+		break;
+
+	case MLX5E_TT_IPV6_TCP:
+		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
+			 MLX5_L3_PROT_TYPE_IPV6);
+		MLX5_SET(rx_hash_field_select, hfso, l4_prot_type,
+			 MLX5_L4_PROT_TYPE_TCP);
+		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
+			 MLX5_HASH_IP_L4PORTS);
+		break;
+
+	case MLX5E_TT_IPV4_UDP:
+		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
+			 MLX5_L3_PROT_TYPE_IPV4);
+		MLX5_SET(rx_hash_field_select, hfso, l4_prot_type,
+			 MLX5_L4_PROT_TYPE_UDP);
+		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
+			 MLX5_HASH_IP_L4PORTS);
+		break;
+
+	case MLX5E_TT_IPV6_UDP:
+		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
+			 MLX5_L3_PROT_TYPE_IPV6);
+		MLX5_SET(rx_hash_field_select, hfso, l4_prot_type,
+			 MLX5_L4_PROT_TYPE_UDP);
+		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
+			 MLX5_HASH_IP_L4PORTS);
+		break;
+
+	case MLX5E_TT_IPV4_IPSEC_AH:
+		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
+			 MLX5_L3_PROT_TYPE_IPV4);
+		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
+			 MLX5_HASH_IP_IPSEC_SPI);
+		break;
+
+	case MLX5E_TT_IPV6_IPSEC_AH:
+		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
+			 MLX5_L3_PROT_TYPE_IPV6);
+		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
+			 MLX5_HASH_IP_IPSEC_SPI);
+		break;
+
+	case MLX5E_TT_IPV4_IPSEC_ESP:
+		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
+			 MLX5_L3_PROT_TYPE_IPV4);
+		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
+			 MLX5_HASH_IP_IPSEC_SPI);
+		break;
+
+	case MLX5E_TT_IPV6_IPSEC_ESP:
+		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
+			 MLX5_L3_PROT_TYPE_IPV6);
+		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
+			 MLX5_HASH_IP_IPSEC_SPI);
+		break;
+
+	case MLX5E_TT_IPV4:
+		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
+			 MLX5_L3_PROT_TYPE_IPV4);
+		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
+			 MLX5_HASH_IP);
+		break;
+
+	case MLX5E_TT_IPV6:
+		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
+			 MLX5_L3_PROT_TYPE_IPV6);
+		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
+			 MLX5_HASH_IP);
+		break;
+	default:
+		WARN_ONCE(true, "%s: bad traffic type!\n", __func__);
+	}
 }
 
 static int mlx5e_modify_tirs_lro(struct mlx5e_priv *priv)
@@ -2404,110 +2501,13 @@ void mlx5e_cleanup_nic_tx(struct mlx5e_priv *priv)
 static void mlx5e_build_indir_tir_ctx(struct mlx5e_priv *priv, u32 *tirc,
 				      enum mlx5e_traffic_types tt)
 {
-	void *hfso = MLX5_ADDR_OF(tirc, tirc, rx_hash_field_selector_outer);
-
 	MLX5_SET(tirc, tirc, transport_domain, priv->mdev->mlx5e_res.td.tdn);
 
-#define MLX5_HASH_IP            (MLX5_HASH_FIELD_SEL_SRC_IP   |\
-				 MLX5_HASH_FIELD_SEL_DST_IP)
-
-#define MLX5_HASH_IP_L4PORTS    (MLX5_HASH_FIELD_SEL_SRC_IP   |\
-				 MLX5_HASH_FIELD_SEL_DST_IP   |\
-				 MLX5_HASH_FIELD_SEL_L4_SPORT |\
-				 MLX5_HASH_FIELD_SEL_L4_DPORT)
-
-#define MLX5_HASH_IP_IPSEC_SPI  (MLX5_HASH_FIELD_SEL_SRC_IP   |\
-				 MLX5_HASH_FIELD_SEL_DST_IP   |\
-				 MLX5_HASH_FIELD_SEL_IPSEC_SPI)
-
 	mlx5e_build_tir_ctx_lro(tirc, priv);
 
 	MLX5_SET(tirc, tirc, disp_type, MLX5_TIRC_DISP_TYPE_INDIRECT);
 	MLX5_SET(tirc, tirc, indirect_table, priv->indir_rqt.rqtn);
-	mlx5e_build_tir_ctx_hash(tirc, priv);
-
-	switch (tt) {
-	case MLX5E_TT_IPV4_TCP:
-		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
-			 MLX5_L3_PROT_TYPE_IPV4);
-		MLX5_SET(rx_hash_field_select, hfso, l4_prot_type,
-			 MLX5_L4_PROT_TYPE_TCP);
-		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
-			 MLX5_HASH_IP_L4PORTS);
-		break;
-
-	case MLX5E_TT_IPV6_TCP:
-		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
-			 MLX5_L3_PROT_TYPE_IPV6);
-		MLX5_SET(rx_hash_field_select, hfso, l4_prot_type,
-			 MLX5_L4_PROT_TYPE_TCP);
-		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
-			 MLX5_HASH_IP_L4PORTS);
-		break;
-
-	case MLX5E_TT_IPV4_UDP:
-		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
-			 MLX5_L3_PROT_TYPE_IPV4);
-		MLX5_SET(rx_hash_field_select, hfso, l4_prot_type,
-			 MLX5_L4_PROT_TYPE_UDP);
-		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
-			 MLX5_HASH_IP_L4PORTS);
-		break;
-
-	case MLX5E_TT_IPV6_UDP:
-		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
-			 MLX5_L3_PROT_TYPE_IPV6);
-		MLX5_SET(rx_hash_field_select, hfso, l4_prot_type,
-			 MLX5_L4_PROT_TYPE_UDP);
-		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
-			 MLX5_HASH_IP_L4PORTS);
-		break;
-
-	case MLX5E_TT_IPV4_IPSEC_AH:
-		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
-			 MLX5_L3_PROT_TYPE_IPV4);
-		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
-			 MLX5_HASH_IP_IPSEC_SPI);
-		break;
-
-	case MLX5E_TT_IPV6_IPSEC_AH:
-		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
-			 MLX5_L3_PROT_TYPE_IPV6);
-		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
-			 MLX5_HASH_IP_IPSEC_SPI);
-		break;
-
-	case MLX5E_TT_IPV4_IPSEC_ESP:
-		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
-			 MLX5_L3_PROT_TYPE_IPV4);
-		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
-			 MLX5_HASH_IP_IPSEC_SPI);
-		break;
-
-	case MLX5E_TT_IPV6_IPSEC_ESP:
-		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
-			 MLX5_L3_PROT_TYPE_IPV6);
-		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
-			 MLX5_HASH_IP_IPSEC_SPI);
-		break;
-
-	case MLX5E_TT_IPV4:
-		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
-			 MLX5_L3_PROT_TYPE_IPV4);
-		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
-			 MLX5_HASH_IP);
-		break;
-
-	case MLX5E_TT_IPV6:
-		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
-			 MLX5_L3_PROT_TYPE_IPV6);
-		MLX5_SET(rx_hash_field_select, hfso, selected_fields,
-			 MLX5_HASH_IP);
-		break;
-	default:
-		WARN_ONCE(true,
-			  "mlx5e_build_indir_tir_ctx: bad traffic type!\n");
-	}
+	mlx5e_build_indir_tir_ctx_hash(priv, tirc, tt);
 }
 
 static void mlx5e_build_direct_tir_ctx(struct mlx5e_priv *priv, u32 *tirc,
-- 
2.11.0
