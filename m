From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V2 09/10] net/mlx5e: Support offload cls_flower with drop action
Date: Thu,  3 Mar 2016 16:55:59 +0200
Message-ID: <1457016960-27832-10-git-send-email-amir@vadai.me>
References: <1457016960-27832-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34385 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932070AbcCCOwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 09:52:22 -0500
Received: by mail-wm0-f67.google.com with SMTP id p65so4493516wmp.1
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 06:52:21 -0800 (PST)
In-Reply-To: <1457016960-27832-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parse tc_cls_flower_offload into device specific commands and program
the hardware to classify and act accordingly.

For example, to drop ICMP (ip_proto 1) packets from specific smac, dmac,
src_ip, src_ip, arriving to interface ens9:

 # tc qdisc add dev ens9 ingress

 # tc filter add dev ens9 protocol ip parent ffff: \
     flower ip_proto 1 \
     dst_mac 7c:fe:90:69:81:62 src_mac 7c:fe:90:69:81:56 \
     dst_ip 11.11.11.11 src_ip 11.11.11.12 indev ens9 \
     action drop

Signed-off-by: Amir Vadai <amir@vadai.me>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   7 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   | 297 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h   |   5 +
 3 files changed, 309 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 011c4f6..9aa9103 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1892,6 +1892,13 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 		goto mqprio;
 
 	switch (tc->type) {
+	case TC_SETUP_CLSFLOWER:
+		switch (tc->cls_flower->command) {
+		case TC_CLSFLOWER_REPLACE:
+			return mlx5e_configure_flower(priv, proto, tc->cls_flower);
+		case TC_CLSFLOWER_DESTROY:
+			return mlx5e_delete_flower(priv, tc->cls_flower);
+		}
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 9457173..3aea5da 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -30,6 +30,9 @@
  * SOFTWARE.
  */
 
+#include <net/flow_dissector.h>
+#include <net/pkt_cls.h>
+#include <net/tc_act/tc_gact.h>
 #include <linux/mlx5/fs.h>
 #include <linux/mlx5/device.h>
 #include <linux/rhashtable.h>
@@ -94,6 +97,300 @@ static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
 	}
 }
 
+static int parse_cls_flower(struct mlx5e_priv *priv,
+			    u32 *match_c, u32 *match_v,
+			    struct tc_cls_flower_offload *f)
+{
+	void *headers_c = MLX5_ADDR_OF(fte_match_param, match_c, outer_headers);
+	void *headers_v = MLX5_ADDR_OF(fte_match_param, match_v, outer_headers);
+	u16 addr_type = 0;
+	u8 ip_proto = 0;
+
+	if (f->dissector->used_keys &
+	    ~(BIT(FLOW_DISSECTOR_KEY_CONTROL) |
+	      BIT(FLOW_DISSECTOR_KEY_BASIC) |
+	      BIT(FLOW_DISSECTOR_KEY_ETH_ADDRS) |
+	      BIT(FLOW_DISSECTOR_KEY_IPV4_ADDRS) |
+	      BIT(FLOW_DISSECTOR_KEY_IPV6_ADDRS) |
+	      BIT(FLOW_DISSECTOR_KEY_PORTS))) {
+		netdev_warn(priv->netdev, "Unsupported key used: 0x%x\n",
+			    f->dissector->used_keys);
+		return -EOPNOTSUPP;
+	}
+
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_CONTROL)) {
+		struct flow_dissector_key_control *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_BASIC,
+						  f->key);
+		addr_type = key->addr_type;
+	}
+
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_BASIC)) {
+		struct flow_dissector_key_basic *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_BASIC,
+						  f->key);
+		struct flow_dissector_key_basic *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_BASIC,
+						  f->mask);
+		ip_proto = key->ip_proto;
+
+		MLX5_SET(fte_match_set_lyr_2_4, headers_c, ethertype,
+			 ntohs(mask->n_proto));
+		MLX5_SET(fte_match_set_lyr_2_4, headers_v, ethertype,
+			 ntohs(key->n_proto));
+
+		MLX5_SET(fte_match_set_lyr_2_4, headers_c, ip_protocol,
+			 mask->ip_proto);
+		MLX5_SET(fte_match_set_lyr_2_4, headers_v, ip_protocol,
+			 key->ip_proto);
+	}
+
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ETH_ADDRS)) {
+		struct flow_dissector_key_eth_addrs *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_ETH_ADDRS,
+						  f->key);
+		struct flow_dissector_key_eth_addrs *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_ETH_ADDRS,
+						  f->mask);
+
+		ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_c,
+					     dmac_47_16),
+				mask->dst);
+		ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_v,
+					     dmac_47_16),
+				key->dst);
+
+		ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_c,
+					     smac_47_16),
+				mask->src);
+		ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_v,
+					     smac_47_16),
+				key->src);
+	}
+
+	if (addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS) {
+		struct flow_dissector_key_ipv4_addrs *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_IPV4_ADDRS,
+						  f->key);
+		struct flow_dissector_key_ipv4_addrs *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_IPV4_ADDRS,
+						  f->mask);
+
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_c,
+				    src_ipv4_src_ipv6.ipv4_layout.ipv4),
+		       &mask->src, sizeof(mask->src));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_v,
+				    src_ipv4_src_ipv6.ipv4_layout.ipv4),
+		       &key->src, sizeof(key->src));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_c,
+				    dst_ipv4_dst_ipv6.ipv4_layout.ipv4),
+		       &mask->dst, sizeof(mask->dst));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_v,
+				    dst_ipv4_dst_ipv6.ipv4_layout.ipv4),
+		       &key->dst, sizeof(key->dst));
+	}
+
+	if (addr_type == FLOW_DISSECTOR_KEY_IPV6_ADDRS) {
+		struct flow_dissector_key_ipv6_addrs *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_IPV6_ADDRS,
+						  f->key);
+		struct flow_dissector_key_ipv6_addrs *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_IPV6_ADDRS,
+						  f->mask);
+
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_c,
+				    src_ipv4_src_ipv6.ipv6_layout.ipv6),
+		       &mask->src, sizeof(mask->src));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_v,
+				    src_ipv4_src_ipv6.ipv6_layout.ipv6),
+		       &key->src, sizeof(key->src));
+
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_c,
+				    dst_ipv4_dst_ipv6.ipv6_layout.ipv6),
+		       &mask->dst, sizeof(mask->dst));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, headers_v,
+				    dst_ipv4_dst_ipv6.ipv6_layout.ipv6),
+		       &key->dst, sizeof(key->dst));
+	}
+
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_PORTS)) {
+		struct flow_dissector_key_ports *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_PORTS,
+						  f->key);
+		struct flow_dissector_key_ports *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_PORTS,
+						  f->mask);
+		switch (ip_proto) {
+		case IPPROTO_TCP:
+			MLX5_SET(fte_match_set_lyr_2_4, headers_c,
+				 tcp_sport, ntohs(mask->src));
+			MLX5_SET(fte_match_set_lyr_2_4, headers_v,
+				 tcp_sport, ntohs(key->src));
+
+			MLX5_SET(fte_match_set_lyr_2_4, headers_c,
+				 tcp_dport, ntohs(mask->dst));
+			MLX5_SET(fte_match_set_lyr_2_4, headers_v,
+				 tcp_dport, ntohs(key->dst));
+			break;
+
+		case IPPROTO_UDP:
+			MLX5_SET(fte_match_set_lyr_2_4, headers_c,
+				 udp_sport, ntohs(mask->src));
+			MLX5_SET(fte_match_set_lyr_2_4, headers_v,
+				 udp_sport, ntohs(key->src));
+
+			MLX5_SET(fte_match_set_lyr_2_4, headers_c,
+				 udp_dport, ntohs(mask->dst));
+			MLX5_SET(fte_match_set_lyr_2_4, headers_v,
+				 udp_dport, ntohs(key->dst));
+			break;
+		default:
+			netdev_err(priv->netdev,
+				   "Only UDP and TCP transport are supported\n");
+			return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
+static int parse_tc_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
+			    u32 *action, u32 *flow_tag)
+{
+	const struct tc_action *a;
+
+	if (tc_no_actions(exts))
+		return -EINVAL;
+
+	*flow_tag = MLX5_FS_DEFAULT_FLOW_TAG;
+	*action = 0;
+
+	tc_for_each_action(a, exts) {
+		/* Only support a single action per rule */
+		if (*action)
+			return -EINVAL;
+
+		if (is_tcf_gact_shot(a)) {
+			*action |= MLX5_FLOW_CONTEXT_ACTION_DROP;
+			continue;
+		}
+
+		if (is_tcf_skbedit_mark(a)) {
+			u32 mark = tcf_skbedit_mark(a);
+
+			if (mark & ~MLX5E_TC_FLOW_ID_MASK) {
+				netdev_warn(priv->netdev, "Bad flow mark - only 16 bit is supported: 0x%x\n",
+					    mark);
+				return -EINVAL;
+			}
+
+			*flow_tag = mark;
+			*action |= MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
+			continue;
+		}
+
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
+			   struct tc_cls_flower_offload *f)
+{
+	struct mlx5e_tc_flow_table *tc = &priv->fts.tc;
+	u32 *match_c;
+	u32 *match_v;
+	int err = 0;
+	u32 flow_tag;
+	u32 action;
+	struct mlx5e_tc_flow *flow;
+	struct mlx5_flow_rule *old = NULL;
+
+	flow = rhashtable_lookup_fast(&tc->ht, &f->cookie,
+				      tc->ht_params);
+	if (flow)
+		old = flow->rule;
+	else
+		flow = kzalloc(sizeof(*flow), GFP_KERNEL);
+
+	match_c = kzalloc(MLX5_ST_SZ_BYTES(fte_match_param), GFP_KERNEL);
+	match_v = kzalloc(MLX5_ST_SZ_BYTES(fte_match_param), GFP_KERNEL);
+	if (!match_c || !match_v || !flow) {
+		err = -ENOMEM;
+		goto err_free;
+	}
+
+	flow->cookie = f->cookie;
+
+	err = parse_cls_flower(priv, match_c, match_v, f);
+	if (err < 0)
+		goto err_free;
+
+	err = parse_tc_actions(priv, f->exts, &action, &flow_tag);
+	if (err < 0)
+		goto err_free;
+
+	err = rhashtable_insert_fast(&tc->ht, &flow->node,
+				     tc->ht_params);
+	if (err)
+		goto err_free;
+
+	flow->rule = mlx5e_tc_add_flow(priv, match_c, match_v, action,
+				       flow_tag);
+	if (IS_ERR(flow->rule)) {
+		err = PTR_ERR(flow->rule);
+		goto err_hash_del;
+	}
+
+	if (old)
+		mlx5e_tc_del_flow(priv, old);
+
+	goto out;
+
+err_hash_del:
+	rhashtable_remove_fast(&tc->ht, &flow->node, tc->ht_params);
+
+err_free:
+	if (!old)
+		kfree(flow);
+out:
+	kfree(match_c);
+	kfree(match_v);
+	return err;
+}
+
+int mlx5e_delete_flower(struct mlx5e_priv *priv,
+			struct tc_cls_flower_offload *f)
+{
+	struct mlx5e_tc_flow *flow;
+	struct mlx5e_tc_flow_table *tc = &priv->fts.tc;
+
+	flow = rhashtable_lookup_fast(&tc->ht, &f->cookie,
+				      tc->ht_params);
+	if (!flow)
+		return -EINVAL;
+
+	rhashtable_remove_fast(&tc->ht, &flow->node, tc->ht_params);
+
+	mlx5e_tc_del_flow(priv, flow->rule);
+
+	kfree(flow);
+
+	return 0;
+}
+
 static const struct rhashtable_params mlx5e_tc_flow_ht_params = {
 	.head_offset = offsetof(struct mlx5e_tc_flow, node),
 	.key_offset = offsetof(struct mlx5e_tc_flow, cookie),
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
index 46eacc5..70642f4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
@@ -36,6 +36,11 @@
 int mlx5e_tc_init(struct mlx5e_priv *priv);
 void mlx5e_tc_cleanup(struct mlx5e_priv *priv);
 
+int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
+			   struct tc_cls_flower_offload *f);
+int mlx5e_delete_flower(struct mlx5e_priv *priv,
+			struct tc_cls_flower_offload *f);
+
 static inline int mlx5e_tc_num_filters(struct mlx5e_priv *priv)
 {
 	return atomic_read(&priv->fts.tc.ht.nelems);
-- 
2.7.0
