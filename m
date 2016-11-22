From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 7/7] net/mlx5e: Enforce min inline mode when offloading flows
Date: Tue, 22 Nov 2016 23:10:00 +0200
Message-ID: <1479849000-14902-8-git-send-email-saeedm@mellanox.com>
References: <1479849000-14902-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46189 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933060AbcKVVKN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 16:10:13 -0500
In-Reply-To: <1479849000-14902-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roi Dayan <roid@mellanox.com>

A flow should be offloaded only if the matches are
allowed according to min inline mode.

Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 46 +++++++++++++++++++++++--
 1 file changed, 44 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 4b99112..4d06fab 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -279,8 +279,10 @@ static int parse_tunnel_attr(struct mlx5e_priv *priv,
 	return 0;
 }
 
-static int parse_cls_flower(struct mlx5e_priv *priv, struct mlx5_flow_spec *spec,
-			    struct tc_cls_flower_offload *f)
+static int __parse_cls_flower(struct mlx5e_priv *priv,
+			      struct mlx5_flow_spec *spec,
+			      struct tc_cls_flower_offload *f,
+			      u8 *min_inline)
 {
 	void *headers_c = MLX5_ADDR_OF(fte_match_param, spec->match_criteria,
 				       outer_headers);
@@ -289,6 +291,8 @@ static int parse_cls_flower(struct mlx5e_priv *priv, struct mlx5_flow_spec *spec
 	u16 addr_type = 0;
 	u8 ip_proto = 0;
 
+	*min_inline = MLX5_INLINE_MODE_L2;
+
 	if (f->dissector->used_keys &
 	    ~(BIT(FLOW_DISSECTOR_KEY_CONTROL) |
 	      BIT(FLOW_DISSECTOR_KEY_BASIC) |
@@ -362,6 +366,9 @@ static int parse_cls_flower(struct mlx5e_priv *priv, struct mlx5_flow_spec *spec
 			 mask->ip_proto);
 		MLX5_SET(fte_match_set_lyr_2_4, headers_v, ip_protocol,
 			 key->ip_proto);
+
+		if (mask->ip_proto)
+			*min_inline = MLX5_INLINE_MODE_IP;
 	}
 
 	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ETH_ADDRS)) {
@@ -432,6 +439,9 @@ static int parse_cls_flower(struct mlx5e_priv *priv, struct mlx5_flow_spec *spec
 		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_v,
 				    dst_ipv4_dst_ipv6.ipv4_layout.ipv4),
 		       &key->dst, sizeof(key->dst));
+
+		if (mask->src || mask->dst)
+			*min_inline = MLX5_INLINE_MODE_IP;
 	}
 
 	if (addr_type == FLOW_DISSECTOR_KEY_IPV6_ADDRS) {
@@ -457,6 +467,10 @@ static int parse_cls_flower(struct mlx5e_priv *priv, struct mlx5_flow_spec *spec
 		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_v,
 				    dst_ipv4_dst_ipv6.ipv6_layout.ipv6),
 		       &key->dst, sizeof(key->dst));
+
+		if (ipv6_addr_type(&mask->src) != IPV6_ADDR_ANY ||
+		    ipv6_addr_type(&mask->dst) != IPV6_ADDR_ANY)
+			*min_inline = MLX5_INLINE_MODE_IP;
 	}
 
 	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_PORTS)) {
@@ -497,11 +511,39 @@ static int parse_cls_flower(struct mlx5e_priv *priv, struct mlx5_flow_spec *spec
 				   "Only UDP and TCP transport are supported\n");
 			return -EINVAL;
 		}
+
+		if (mask->src || mask->dst)
+			*min_inline = MLX5_INLINE_MODE_TCP_UDP;
 	}
 
 	return 0;
 }
 
+static int parse_cls_flower(struct mlx5e_priv *priv,
+			    struct mlx5_flow_spec *spec,
+			    struct tc_cls_flower_offload *f)
+{
+	struct mlx5_core_dev *dev = priv->mdev;
+	struct mlx5_eswitch *esw = dev->priv.eswitch;
+	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	u8 min_inline;
+	int err;
+
+	err = __parse_cls_flower(priv, spec, f, &min_inline);
+
+	if (!err && esw->mode == SRIOV_OFFLOADS &&
+	    rep->vport != FDB_UPLINK_VPORT) {
+		if (min_inline > esw->offloads.inline_mode) {
+			netdev_warn(priv->netdev,
+				    "Flow is not offloaded due to min inline setting, required %d actual %d\n",
+				    min_inline, esw->offloads.inline_mode);
+			return -EOPNOTSUPP;
+		}
+	}
+
+	return err;
+}
+
 static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 				u32 *action, u32 *flow_tag)
 {
-- 
2.7.4
