From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 6/6] net/mlx5e: Input IPSEC.SPI into the RX RSS hash function
Date: Thu, 23 Jul 2015 23:36:01 +0300
Message-ID: <1437683761-28052-7-git-send-email-amirv@mellanox.com>
References: <1437683761-28052-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39670 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754061AbbGWUgx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 16:36:53 -0400
In-Reply-To: <1437683761-28052-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

In addition to the source/destination IP which are already hashed.
Only for unicast traffic for now.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  4 +
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    | 92 +++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 32 ++++++++
 3 files changed, 127 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 39294f2..b710e9b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -334,6 +334,10 @@ enum mlx5e_traffic_types {
 	MLX5E_TT_IPV6_TCP,
 	MLX5E_TT_IPV4_UDP,
 	MLX5E_TT_IPV6_UDP,
+	MLX5E_TT_IPV4_IPSEC_AH,
+	MLX5E_TT_IPV6_IPSEC_AH,
+	MLX5E_TT_IPV4_IPSEC_ESP,
+	MLX5E_TT_IPV6_IPSEC_ESP,
 	MLX5E_TT_IPV4,
 	MLX5E_TT_IPV6,
 	MLX5E_TT_ANY,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
index cca34f6..70ec31b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
@@ -105,6 +105,22 @@ static void mlx5e_del_eth_addr_from_flow_table(struct mlx5e_priv *priv,
 {
 	void *ft = priv->ft.main;
 
+	if (ai->tt_vec & BIT(MLX5E_TT_IPV6_IPSEC_ESP))
+		mlx5_del_flow_table_entry(ft,
+					  ai->ft_ix[MLX5E_TT_IPV6_IPSEC_ESP]);
+
+	if (ai->tt_vec & BIT(MLX5E_TT_IPV4_IPSEC_ESP))
+		mlx5_del_flow_table_entry(ft,
+					  ai->ft_ix[MLX5E_TT_IPV4_IPSEC_ESP]);
+
+	if (ai->tt_vec & BIT(MLX5E_TT_IPV6_IPSEC_AH))
+		mlx5_del_flow_table_entry(ft,
+					  ai->ft_ix[MLX5E_TT_IPV6_IPSEC_AH]);
+
+	if (ai->tt_vec & BIT(MLX5E_TT_IPV4_IPSEC_AH))
+		mlx5_del_flow_table_entry(ft,
+					  ai->ft_ix[MLX5E_TT_IPV4_IPSEC_AH]);
+
 	if (ai->tt_vec & BIT(MLX5E_TT_IPV6_TCP))
 		mlx5_del_flow_table_entry(ft, ai->ft_ix[MLX5E_TT_IPV6_TCP]);
 
@@ -160,6 +176,10 @@ static u32 mlx5e_get_tt_vec(struct mlx5e_eth_addr_info *ai, int type)
 				BIT(MLX5E_TT_IPV6_TCP)       |
 				BIT(MLX5E_TT_IPV4_UDP)       |
 				BIT(MLX5E_TT_IPV6_UDP)       |
+				BIT(MLX5E_TT_IPV4_IPSEC_AH)  |
+				BIT(MLX5E_TT_IPV6_IPSEC_AH)  |
+				BIT(MLX5E_TT_IPV4_IPSEC_ESP) |
+				BIT(MLX5E_TT_IPV6_IPSEC_ESP) |
 				BIT(MLX5E_TT_IPV4)           |
 				BIT(MLX5E_TT_IPV6)           |
 				BIT(MLX5E_TT_ANY)            |
@@ -205,6 +225,10 @@ static u32 mlx5e_get_tt_vec(struct mlx5e_eth_addr_info *ai, int type)
 			BIT(MLX5E_TT_IPV6_TCP)       |
 			BIT(MLX5E_TT_IPV4_UDP)       |
 			BIT(MLX5E_TT_IPV6_UDP)       |
+			BIT(MLX5E_TT_IPV4_IPSEC_AH)  |
+			BIT(MLX5E_TT_IPV6_IPSEC_AH)  |
+			BIT(MLX5E_TT_IPV4_IPSEC_ESP) |
+			BIT(MLX5E_TT_IPV6_IPSEC_ESP) |
 			BIT(MLX5E_TT_IPV4)           |
 			BIT(MLX5E_TT_IPV6)           |
 			BIT(MLX5E_TT_ANY)            |
@@ -377,6 +401,72 @@ static int __mlx5e_add_eth_addr_rule(struct mlx5e_priv *priv,
 		ai->tt_vec |= BIT(MLX5E_TT_IPV6_TCP);
 	}
 
+	MLX5_SET(fte_match_param, match_value, outer_headers.ip_protocol,
+		 IPPROTO_AH);
+
+	ft_ix = &ai->ft_ix[MLX5E_TT_IPV4_IPSEC_AH];
+	if (tt_vec & BIT(MLX5E_TT_IPV4_IPSEC_AH)) {
+		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
+			 ETH_P_IP);
+		MLX5_SET(dest_format_struct, dest, destination_id,
+			 tirn[MLX5E_TT_IPV4_IPSEC_AH]);
+		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
+						match_criteria, flow_context,
+						ft_ix);
+		if (err)
+			goto err_del_ai;
+
+		ai->tt_vec |= BIT(MLX5E_TT_IPV4_IPSEC_AH);
+	}
+
+	ft_ix = &ai->ft_ix[MLX5E_TT_IPV6_IPSEC_AH];
+	if (tt_vec & BIT(MLX5E_TT_IPV6_IPSEC_AH)) {
+		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
+			 ETH_P_IPV6);
+		MLX5_SET(dest_format_struct, dest, destination_id,
+			 tirn[MLX5E_TT_IPV6_IPSEC_AH]);
+		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
+						match_criteria, flow_context,
+						ft_ix);
+		if (err)
+			goto err_del_ai;
+
+		ai->tt_vec |= BIT(MLX5E_TT_IPV6_IPSEC_AH);
+	}
+
+	MLX5_SET(fte_match_param, match_value, outer_headers.ip_protocol,
+		 IPPROTO_ESP);
+
+	ft_ix = &ai->ft_ix[MLX5E_TT_IPV4_IPSEC_ESP];
+	if (tt_vec & BIT(MLX5E_TT_IPV4_IPSEC_ESP)) {
+		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
+			 ETH_P_IP);
+		MLX5_SET(dest_format_struct, dest, destination_id,
+			 tirn[MLX5E_TT_IPV4_IPSEC_ESP]);
+		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
+						match_criteria, flow_context,
+						ft_ix);
+		if (err)
+			goto err_del_ai;
+
+		ai->tt_vec |= BIT(MLX5E_TT_IPV4_IPSEC_ESP);
+	}
+
+	ft_ix = &ai->ft_ix[MLX5E_TT_IPV6_IPSEC_ESP];
+	if (tt_vec & BIT(MLX5E_TT_IPV6_IPSEC_ESP)) {
+		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
+			 ETH_P_IPV6);
+		MLX5_SET(dest_format_struct, dest, destination_id,
+			 tirn[MLX5E_TT_IPV6_IPSEC_ESP]);
+		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
+						match_criteria, flow_context,
+						ft_ix);
+		if (err)
+			goto err_del_ai;
+
+		ai->tt_vec |= BIT(MLX5E_TT_IPV6_IPSEC_ESP);
+	}
+
 	return 0;
 
 err_del_ai:
@@ -731,7 +821,7 @@ static int mlx5e_create_main_flow_table(struct mlx5e_priv *priv)
 	if (!g)
 		return -ENOMEM;
 
-	g[0].log_sz = 2;
+	g[0].log_sz = 3;
 	g[0].match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
 	MLX5_SET_TO_ONES(fte_match_param, g[0].match_criteria,
 			 outer_headers.ethertype);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 8194c32..355a10a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1260,6 +1260,10 @@ static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 				 MLX5_HASH_FIELD_SEL_L4_SPORT |\
 				 MLX5_HASH_FIELD_SEL_L4_DPORT)
 
+#define MLX5_HASH_IP_IPSEC_SPI  (MLX5_HASH_FIELD_SEL_SRC_IP   |\
+				 MLX5_HASH_FIELD_SEL_DST_IP   |\
+				 MLX5_HASH_FIELD_SEL_IPSEC_SPI)
+
 	if (priv->params.lro_en) {
 		MLX5_SET(tirc, tirc, lro_enable_mask,
 			 MLX5_TIRC_LRO_ENABLE_MASK_IPV4_LRO |
@@ -1335,6 +1339,34 @@ static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 			 MLX5_HASH_IP_L4PORTS);
 		break;
 
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
 	case MLX5E_TT_IPV4:
 		MLX5_SET(rx_hash_field_select, hfso, l3_prot_type,
 			 MLX5_L3_PROT_TYPE_IPV4);
-- 
2.4.3.413.ga5fe668
