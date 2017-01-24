From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 02/12] net/mlx5e: Add TC offloads matching on IPv6 encapsulation headers
Date: Tue, 24 Jan 2017 22:16:42 +0200
Message-ID: <20170124201652.2920-3-saeedm@mellanox.com>
References: <20170124201652.2920-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54285 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750975AbdAXURZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:17:25 -0500
In-Reply-To: <20170124201652.2920-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Enhance the parsing of offloaded TC rules to set HW matching on outer
IPv6 encapsulation headers. This effectively adds support for TC tunnel
key release action (decapsulation) of SRIOV offloads over IPv6 tunnels.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 30 ++++++++++++++++++++++---
 1 file changed, 27 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index d4af5507679f..e9f0854e9509 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -298,6 +298,32 @@ static int parse_tunnel_attr(struct mlx5e_priv *priv,
 
 		MLX5_SET_TO_ONES(fte_match_set_lyr_2_4, headers_c, ethertype);
 		MLX5_SET(fte_match_set_lyr_2_4, headers_v, ethertype, ETH_P_IP);
+	} else if (enc_control->addr_type == FLOW_DISSECTOR_KEY_IPV6_ADDRS) {
+		struct flow_dissector_key_ipv6_addrs *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS,
+						  f->key);
+		struct flow_dissector_key_ipv6_addrs *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS,
+						  f->mask);
+
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_c,
+				    src_ipv4_src_ipv6.ipv6_layout.ipv6),
+		       &mask->src, MLX5_FLD_SZ_BYTES(ipv6_layout, ipv6));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_v,
+				    src_ipv4_src_ipv6.ipv6_layout.ipv6),
+		       &key->src, MLX5_FLD_SZ_BYTES(ipv6_layout, ipv6));
+
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_c,
+				    dst_ipv4_dst_ipv6.ipv6_layout.ipv6),
+		       &mask->dst, MLX5_FLD_SZ_BYTES(ipv6_layout, ipv6));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_v,
+				    dst_ipv4_dst_ipv6.ipv6_layout.ipv6),
+		       &key->dst, MLX5_FLD_SZ_BYTES(ipv6_layout, ipv6));
+
+		MLX5_SET_TO_ONES(fte_match_set_lyr_2_4, headers_c, ethertype);
+		MLX5_SET(fte_match_set_lyr_2_4, headers_v, ethertype, ETH_P_IPV6);
 	}
 
 	/* Enforce DMAC when offloading incoming tunneled flows.
@@ -358,12 +384,10 @@ static int __parse_cls_flower(struct mlx5e_priv *priv,
 						  f->key);
 		switch (key->addr_type) {
 		case FLOW_DISSECTOR_KEY_IPV4_ADDRS:
+		case FLOW_DISSECTOR_KEY_IPV6_ADDRS:
 			if (parse_tunnel_attr(priv, spec, f))
 				return -EOPNOTSUPP;
 			break;
-		case FLOW_DISSECTOR_KEY_IPV6_ADDRS:
-			netdev_warn(priv->netdev,
-				    "IPv6 tunnel decap offload isn't supported\n");
 		default:
 			return -EOPNOTSUPP;
 		}
-- 
2.11.0
