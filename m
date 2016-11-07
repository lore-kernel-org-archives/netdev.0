From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 11/13] net/mlx5e: Add TC tunnel release action for SRIOV offloads
Date: Mon,  7 Nov 2016 15:14:46 +0200
Message-ID: <1478524488-1377-12-git-send-email-saeedm@mellanox.com>
References: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39587 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753434AbcKGNPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:15:07 -0500
In-Reply-To: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Enhance the parsing of offloaded TC rules to set HW matching on outer
(encapsulation) headers.
Parse TC tunnel release action and set it as mlx5 decap action when the
required capabilities are supported.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 156 ++++++++++++++++++++-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |   9 +-
 2 files changed, 163 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 35e38d1..8946653 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -40,9 +40,11 @@
 #include <net/switchdev.h>
 #include <net/tc_act/tc_mirred.h>
 #include <net/tc_act/tc_vlan.h>
+#include <net/tc_act/tc_tunnel_key.h>
 #include "en.h"
 #include "en_tc.h"
 #include "eswitch.h"
+#include "vxlan.h"
 
 struct mlx5e_tc_flow {
 	struct rhash_head	node;
@@ -155,6 +157,121 @@ static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
 	}
 }
 
+static void parse_vxlan_attr(struct mlx5_flow_spec *spec,
+			     struct tc_cls_flower_offload *f)
+{
+	void *headers_c = MLX5_ADDR_OF(fte_match_param, spec->match_criteria,
+				       outer_headers);
+	void *headers_v = MLX5_ADDR_OF(fte_match_param, spec->match_value,
+				       outer_headers);
+	void *misc_c = MLX5_ADDR_OF(fte_match_param, spec->match_criteria,
+				    misc_parameters);
+	void *misc_v = MLX5_ADDR_OF(fte_match_param, spec->match_value,
+				    misc_parameters);
+
+	MLX5_SET_TO_ONES(fte_match_set_lyr_2_4, headers_c, ip_protocol);
+	MLX5_SET(fte_match_set_lyr_2_4, headers_v, ip_protocol, IPPROTO_UDP);
+
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ENC_KEYID)) {
+		struct flow_dissector_key_keyid *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_ENC_KEYID,
+						  f->key);
+		struct flow_dissector_key_keyid *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_ENC_KEYID,
+						  f->mask);
+		MLX5_SET(fte_match_set_misc, misc_c, vxlan_vni,
+			 be32_to_cpu(mask->keyid));
+		MLX5_SET(fte_match_set_misc, misc_v, vxlan_vni,
+			 be32_to_cpu(key->keyid));
+	}
+}
+
+static int parse_tunnel_attr(struct mlx5e_priv *priv,
+			     struct mlx5_flow_spec *spec,
+			     struct tc_cls_flower_offload *f)
+{
+	void *headers_c = MLX5_ADDR_OF(fte_match_param, spec->match_criteria,
+				       outer_headers);
+	void *headers_v = MLX5_ADDR_OF(fte_match_param, spec->match_value,
+				       outer_headers);
+
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ENC_PORTS)) {
+		struct flow_dissector_key_ports *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_ENC_PORTS,
+						  f->key);
+		struct flow_dissector_key_ports *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_ENC_PORTS,
+						  f->mask);
+
+		/* Full udp dst port must be given */
+		if (memchr_inv(&mask->dst, 0xff, sizeof(mask->dst)))
+			return -EOPNOTSUPP;
+
+		/* udp src port isn't supported */
+		if (memchr_inv(&mask->src, 0, sizeof(mask->src)))
+			return -EOPNOTSUPP;
+
+		if (mlx5e_vxlan_lookup_port(priv, be16_to_cpu(key->dst)) &&
+		    MLX5_CAP_ESW(priv->mdev, vxlan_encap_decap))
+			parse_vxlan_attr(spec, f);
+		else
+			return -EOPNOTSUPP;
+
+		MLX5_SET(fte_match_set_lyr_2_4, headers_c,
+			 udp_dport, ntohs(mask->dst));
+		MLX5_SET(fte_match_set_lyr_2_4, headers_v,
+			 udp_dport, ntohs(key->dst));
+
+	} else { /* udp dst port must be given */
+			return -EOPNOTSUPP;
+	}
+
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS)) {
+		struct flow_dissector_key_ipv4_addrs *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS,
+						  f->key);
+		struct flow_dissector_key_ipv4_addrs *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS,
+						  f->mask);
+		MLX5_SET(fte_match_set_lyr_2_4, headers_c,
+			 src_ipv4_src_ipv6.ipv4_layout.ipv4,
+			 ntohl(mask->src));
+		MLX5_SET(fte_match_set_lyr_2_4, headers_v,
+			 src_ipv4_src_ipv6.ipv4_layout.ipv4,
+			 ntohl(key->src));
+
+		MLX5_SET(fte_match_set_lyr_2_4, headers_c,
+			 dst_ipv4_dst_ipv6.ipv4_layout.ipv4,
+			 ntohl(mask->dst));
+		MLX5_SET(fte_match_set_lyr_2_4, headers_v,
+			 dst_ipv4_dst_ipv6.ipv4_layout.ipv4,
+			 ntohl(key->dst));
+	}
+
+	MLX5_SET_TO_ONES(fte_match_set_lyr_2_4, headers_c, ethertype);
+	MLX5_SET(fte_match_set_lyr_2_4, headers_v, ethertype, ETH_P_IP);
+
+	/* Enforce DMAC when offloading incoming tunneled flows.
+	 * Flow counters require a match on the DMAC.
+	 */
+	MLX5_SET_TO_ONES(fte_match_set_lyr_2_4, headers_c, dmac_47_16);
+	MLX5_SET_TO_ONES(fte_match_set_lyr_2_4, headers_c, dmac_15_0);
+	ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_v,
+				     dmac_47_16), priv->netdev->dev_addr);
+
+	/* let software handle IP fragments */
+	MLX5_SET(fte_match_set_lyr_2_4, headers_c, frag, 1);
+	MLX5_SET(fte_match_set_lyr_2_4, headers_v, frag, 0);
+
+	return 0;
+}
+
 static int parse_cls_flower(struct mlx5e_priv *priv, struct mlx5_flow_spec *spec,
 			    struct tc_cls_flower_offload *f)
 {
@@ -172,12 +289,44 @@ static int parse_cls_flower(struct mlx5e_priv *priv, struct mlx5_flow_spec *spec
 	      BIT(FLOW_DISSECTOR_KEY_VLAN) |
 	      BIT(FLOW_DISSECTOR_KEY_IPV4_ADDRS) |
 	      BIT(FLOW_DISSECTOR_KEY_IPV6_ADDRS) |
-	      BIT(FLOW_DISSECTOR_KEY_PORTS))) {
+	      BIT(FLOW_DISSECTOR_KEY_PORTS) |
+	      BIT(FLOW_DISSECTOR_KEY_ENC_KEYID) |
+	      BIT(FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS) |
+	      BIT(FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS) |
+	      BIT(FLOW_DISSECTOR_KEY_ENC_PORTS)	|
+	      BIT(FLOW_DISSECTOR_KEY_ENC_CONTROL))) {
 		netdev_warn(priv->netdev, "Unsupported key used: 0x%x\n",
 			    f->dissector->used_keys);
 		return -EOPNOTSUPP;
 	}
 
+	if ((dissector_uses_key(f->dissector,
+				FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS) ||
+	     dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ENC_KEYID) ||
+	     dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ENC_PORTS)) &&
+	    dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ENC_CONTROL)) {
+		struct flow_dissector_key_control *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_ENC_CONTROL,
+						  f->key);
+		switch (key->addr_type) {
+		case FLOW_DISSECTOR_KEY_IPV4_ADDRS:
+			if (parse_tunnel_attr(priv, spec, f))
+				return -EOPNOTSUPP;
+			break;
+		default:
+			return -EOPNOTSUPP;
+		}
+
+		/* In decap flow, header pointers should point to the inner
+		 * headers, outer header were already set by parse_tunnel_attr
+		 */
+		headers_c = MLX5_ADDR_OF(fte_match_param, spec->match_criteria,
+					 inner_headers);
+		headers_v = MLX5_ADDR_OF(fte_match_param, spec->match_value,
+					 inner_headers);
+	}
+
 	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_CONTROL)) {
 		struct flow_dissector_key_control *key =
 			skb_flow_dissector_target(f->dissector,
@@ -442,6 +591,11 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 			continue;
 		}
 
+		if (is_tcf_tunnel_release(a)) {
+			attr->action |= MLX5_FLOW_CONTEXT_ACTION_DECAP;
+			continue;
+		}
+
 		return -EINVAL;
 	}
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index a390117..c2dc470 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -82,6 +82,8 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 
 	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS |
 				      MLX5_MATCH_MISC_PARAMETERS;
+	if (flow_act.action & MLX5_FLOW_CONTEXT_ACTION_DECAP)
+		spec->match_criteria_enable |= MLX5_MATCH_INNER_HEADERS;
 
 	rule = mlx5_add_flow_rules((struct mlx5_flow_table *)esw->fdb_table.fdb,
 				   spec, &flow_act, dest, i);
@@ -409,6 +411,7 @@ static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	u32 *flow_group_in;
 	void *match_criteria;
 	int table_size, ix, err = 0;
+	u32 flags = 0;
 
 	flow_group_in = mlx5_vzalloc(inlen);
 	if (!flow_group_in)
@@ -423,10 +426,14 @@ static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	esw_debug(dev, "Create offloads FDB table, log_max_size(%d)\n",
 		  MLX5_CAP_ESW_FLOWTABLE_FDB(dev, log_max_ft_size));
 
+	if (MLX5_CAP_ESW_FLOWTABLE_FDB(dev, encap) &&
+	    MLX5_CAP_ESW_FLOWTABLE_FDB(dev, decap))
+		flags |= MLX5_FLOW_TABLE_TUNNEL_EN;
+
 	fdb = mlx5_create_auto_grouped_flow_table(root_ns, FDB_FAST_PATH,
 						  ESW_OFFLOADS_NUM_ENTRIES,
 						  ESW_OFFLOADS_NUM_GROUPS, 0,
-						  0);
+						  flags);
 	if (IS_ERR(fdb)) {
 		err = PTR_ERR(fdb);
 		esw_warn(dev, "Failed to create Fast path FDB Table err %d\n", err);
-- 
2.7.4
