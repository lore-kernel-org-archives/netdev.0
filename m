From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 04/15] net/mlx5e: Relocate the TC match on ip tos offload code section
Date: Fri, 23 Jun 2017 17:26:11 +0300
Message-ID: <20170623142622.16565-5-saeedm@mellanox.com>
References: <20170623142622.16565-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54039 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753447AbdFWO1m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 10:27:42 -0400
In-Reply-To: <20170623142622.16565-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The code section for offloading matches on ip tos (L3) should come
before and not after the one that deals with tcp/udp (L4) matches.

Otherwise, we might come up with wrong min-inline requirement, when
one attempts to match on both L3 and L4.

Fixes: fd7da28b280d ('net/mlx5e: Offload TC matching on ip tos / traffic-class')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 46 ++++++++++++-------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index b9170c5e7a82..633a91a71218 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -888,6 +888,29 @@ static int __parse_cls_flower(struct mlx5e_priv *priv,
 			*min_inline = MLX5_INLINE_MODE_IP;
 	}
 
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_IP)) {
+		struct flow_dissector_key_ip *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_IP,
+						  f->key);
+		struct flow_dissector_key_ip *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_IP,
+						  f->mask);
+
+		MLX5_SET(fte_match_set_lyr_2_4, headers_c, ip_ecn, mask->tos & 0x3);
+		MLX5_SET(fte_match_set_lyr_2_4, headers_v, ip_ecn, key->tos & 0x3);
+
+		MLX5_SET(fte_match_set_lyr_2_4, headers_c, ip_dscp, mask->tos >> 2);
+		MLX5_SET(fte_match_set_lyr_2_4, headers_v, ip_dscp, key->tos  >> 2);
+
+		if (mask->tos)
+			*min_inline = MLX5_INLINE_MODE_IP;
+
+		if (mask->ttl) /* currently not supported */
+			return -EOPNOTSUPP;
+	}
+
 	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_PORTS)) {
 		struct flow_dissector_key_ports *key =
 			skb_flow_dissector_target(f->dissector,
@@ -931,29 +954,6 @@ static int __parse_cls_flower(struct mlx5e_priv *priv,
 			*min_inline = MLX5_INLINE_MODE_TCP_UDP;
 	}
 
-	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_IP)) {
-		struct flow_dissector_key_ip *key =
-			skb_flow_dissector_target(f->dissector,
-						  FLOW_DISSECTOR_KEY_IP,
-						  f->key);
-		struct flow_dissector_key_ip *mask =
-			skb_flow_dissector_target(f->dissector,
-						  FLOW_DISSECTOR_KEY_IP,
-						  f->mask);
-
-		MLX5_SET(fte_match_set_lyr_2_4, headers_c, ip_ecn, mask->tos & 0x3);
-		MLX5_SET(fte_match_set_lyr_2_4, headers_v, ip_ecn, key->tos & 0x3);
-
-		MLX5_SET(fte_match_set_lyr_2_4, headers_c, ip_dscp, mask->tos >> 2);
-		MLX5_SET(fte_match_set_lyr_2_4, headers_v, ip_dscp, key->tos  >> 2);
-
-		if (mask->tos)
-			*min_inline = MLX5_INLINE_MODE_IP;
-
-		if (mask->ttl) /* currently not supported */
-			return -EOPNOTSUPP;
-	}
-
 	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_TCP)) {
 		struct flow_dissector_key_tcp *key =
 			skb_flow_dissector_target(f->dissector,
-- 
2.11.0
