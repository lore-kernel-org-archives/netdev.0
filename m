From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 05/11] net/mlx5e: Disallow TC offloading of unsupported match/action combinations
Date: Thu, 28 Sep 2017 07:41:26 +0300
Message-ID: <20170928044132.30940-6-saeedm@mellanox.com>
References: <20170928044132.30940-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54386 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751356AbdI1EmF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 00:42:05 -0400
In-Reply-To: <20170928044132.30940-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

When offloading header re-write, the HW may need to adjust checksums along
the packet. For IP traffic, and a case where we are asked to modify fields in
the IP header, current HW supports that only for TCP and UDP. Enforce it, in
this case fail the offloading attempt for non TCP/UDP packets.

Fixes: d7e75a325cb2 ('net/mlx5e: Add offloading of E-Switch TC pedit (header re-write) actions')
Fixes: 2f4fe4cab073 ('net/mlx5e: Add offloading of NIC TC pedit (header re-write) actions')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 70 +++++++++++++++++++++++++
 1 file changed, 70 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 4e2fc016bdd6..d3786005fba7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1317,6 +1317,69 @@ static bool csum_offload_supported(struct mlx5e_priv *priv, u32 action, u32 upda
 	return true;
 }
 
+static bool modify_header_match_supported(struct mlx5_flow_spec *spec,
+					  struct tcf_exts *exts)
+{
+	const struct tc_action *a;
+	bool modify_ip_header;
+	LIST_HEAD(actions);
+	u8 htype, ip_proto;
+	void *headers_v;
+	u16 ethertype;
+	int nkeys, i;
+
+	headers_v = MLX5_ADDR_OF(fte_match_param, spec->match_value, outer_headers);
+	ethertype = MLX5_GET(fte_match_set_lyr_2_4, headers_v, ethertype);
+
+	/* for non-IP we only re-write MACs, so we're okay */
+	if (ethertype != ETH_P_IP && ethertype != ETH_P_IPV6)
+		goto out_ok;
+
+	modify_ip_header = false;
+	tcf_exts_to_list(exts, &actions);
+	list_for_each_entry(a, &actions, list) {
+		if (!is_tcf_pedit(a))
+			continue;
+
+		nkeys = tcf_pedit_nkeys(a);
+		for (i = 0; i < nkeys; i++) {
+			htype = tcf_pedit_htype(a, i);
+			if (htype == TCA_PEDIT_KEY_EX_HDR_TYPE_IP4 ||
+			    htype == TCA_PEDIT_KEY_EX_HDR_TYPE_IP6) {
+				modify_ip_header = true;
+				break;
+			}
+		}
+	}
+
+	ip_proto = MLX5_GET(fte_match_set_lyr_2_4, headers_v, ip_protocol);
+	if (modify_ip_header && ip_proto != IPPROTO_TCP && ip_proto != IPPROTO_UDP) {
+		pr_info("can't offload re-write of ip proto %d\n", ip_proto);
+		return false;
+	}
+
+out_ok:
+	return true;
+}
+
+static bool actions_match_supported(struct mlx5e_priv *priv,
+				    struct tcf_exts *exts,
+				    struct mlx5e_tc_flow_parse_attr *parse_attr,
+				    struct mlx5e_tc_flow *flow)
+{
+	u32 actions;
+
+	if (flow->flags & MLX5E_TC_FLOW_ESWITCH)
+		actions = flow->esw_attr->action;
+	else
+		actions = flow->nic_attr->action;
+
+	if (actions & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
+		return modify_header_match_supported(&parse_attr->spec, exts);
+
+	return true;
+}
+
 static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 				struct mlx5e_tc_flow_parse_attr *parse_attr,
 				struct mlx5e_tc_flow *flow)
@@ -1378,6 +1441,9 @@ static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 		return -EINVAL;
 	}
 
+	if (!actions_match_supported(priv, exts, parse_attr, flow))
+		return -EOPNOTSUPP;
+
 	return 0;
 }
 
@@ -1936,6 +2002,10 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 
 		return -EINVAL;
 	}
+
+	if (!actions_match_supported(priv, exts, parse_attr, flow))
+		return -EOPNOTSUPP;
+
 	return err;
 }
 
-- 
2.13.0
