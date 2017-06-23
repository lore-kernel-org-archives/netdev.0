From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 05/15] net/mlx5e: Offload TC matching on ip ttl
Date: Fri, 23 Jun 2017 17:26:12 +0300
Message-ID: <20170623142622.16565-6-saeedm@mellanox.com>
References: <20170623142622.16565-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54045 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753528AbdFWO1m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 10:27:42 -0400
In-Reply-To: <20170623142622.16565-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Enable offloading of TC matching on ip ttl / hop-limit

As matching on ttl is supported only by newer HW brands (ConnectX-5),
we should do capability check before attempting to offload that.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 11 ++++++++---
 include/linux/mlx5/mlx5_ifc.h                   |  5 +++--
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 633a91a71218..382dede903a3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -904,11 +904,16 @@ static int __parse_cls_flower(struct mlx5e_priv *priv,
 		MLX5_SET(fte_match_set_lyr_2_4, headers_c, ip_dscp, mask->tos >> 2);
 		MLX5_SET(fte_match_set_lyr_2_4, headers_v, ip_dscp, key->tos  >> 2);
 
-		if (mask->tos)
-			*min_inline = MLX5_INLINE_MODE_IP;
+		MLX5_SET(fte_match_set_lyr_2_4, headers_c, ttl_hoplimit, mask->ttl);
+		MLX5_SET(fte_match_set_lyr_2_4, headers_v, ttl_hoplimit, key->ttl);
 
-		if (mask->ttl) /* currently not supported */
+		if (mask->ttl &&
+		    !MLX5_CAP_ESW_FLOWTABLE_FDB(priv->mdev,
+						ft_field_support.outer_ipv4_ttl))
 			return -EOPNOTSUPP;
+
+		if (mask->tos || mask->ttl)
+			*min_inline = MLX5_INLINE_MODE_IP;
 	}
 
 	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_PORTS)) {
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index e86ef880a149..694f51d388d9 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -243,7 +243,7 @@ struct mlx5_ifc_flow_table_fields_supported_bits {
 	u8         outer_first_prio[0x1];
 	u8         outer_first_cfi[0x1];
 	u8         outer_first_vid[0x1];
-	u8         reserved_at_7[0x1];
+	u8         outer_ipv4_ttl[0x1];
 	u8         outer_second_prio[0x1];
 	u8         outer_second_cfi[0x1];
 	u8         outer_second_vid[0x1];
@@ -380,7 +380,8 @@ struct mlx5_ifc_fte_match_set_lyr_2_4_bits {
 	u8         tcp_sport[0x10];
 	u8         tcp_dport[0x10];
 
-	u8         reserved_at_c0[0x20];
+	u8         reserved_at_c0[0x18];
+	u8         ttl_hoplimit[0x8];
 
 	u8         udp_sport[0x10];
 	u8         udp_dport[0x10];
-- 
2.11.0
