From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 04/10] net/mlx5e: Properly get address type of encapsulation IP headers
Date: Tue, 10 Jan 2017 22:33:33 +0200
Message-ID: <1484080419-24256-5-git-send-email-saeedm@mellanox.com>
References: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52043 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751125AbdAJUe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:34:27 -0500
In-Reply-To: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

As done elsewhere in our TC/flower offload code, the address type of
the encapsulation IP headers should be realized accroding to the
addr_type field of the encapsulation control dissector key, do that.

Fixes: bbd00f7e2349 ('net/mlx5e: Add TC tunnel release action for SRIOV offloads')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index b62f06f..9cfddd9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -225,6 +225,11 @@ static int parse_tunnel_attr(struct mlx5e_priv *priv,
 	void *headers_v = MLX5_ADDR_OF(fte_match_param, spec->match_value,
 				       outer_headers);
 
+	struct flow_dissector_key_control *enc_control =
+		skb_flow_dissector_target(f->dissector,
+					  FLOW_DISSECTOR_KEY_ENC_CONTROL,
+					  f->key);
+
 	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ENC_PORTS)) {
 		struct flow_dissector_key_ports *key =
 			skb_flow_dissector_target(f->dissector,
@@ -264,7 +269,7 @@ static int parse_tunnel_attr(struct mlx5e_priv *priv,
 		return -EOPNOTSUPP;
 	}
 
-	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS)) {
+	if (enc_control->addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS) {
 		struct flow_dissector_key_ipv4_addrs *key =
 			skb_flow_dissector_target(f->dissector,
 						  FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS,
@@ -286,10 +291,10 @@ static int parse_tunnel_attr(struct mlx5e_priv *priv,
 		MLX5_SET(fte_match_set_lyr_2_4, headers_v,
 			 dst_ipv4_dst_ipv6.ipv4_layout.ipv4,
 			 ntohl(key->dst));
-	}
 
-	MLX5_SET_TO_ONES(fte_match_set_lyr_2_4, headers_c, ethertype);
-	MLX5_SET(fte_match_set_lyr_2_4, headers_v, ethertype, ETH_P_IP);
+		MLX5_SET_TO_ONES(fte_match_set_lyr_2_4, headers_c, ethertype);
+		MLX5_SET(fte_match_set_lyr_2_4, headers_v, ethertype, ETH_P_IP);
+	}
 
 	/* Enforce DMAC when offloading incoming tunneled flows.
 	 * Flow counters require a match on the DMAC.
-- 
2.7.4
