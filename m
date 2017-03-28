From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 11/12] net/mlx5e: Add offloading of NIC TC pedit (header re-write) actions
Date: Wed, 29 Mar 2017 02:27:12 +0300
Message-ID: <20170328232713.29894-12-saeedm@mellanox.com>
References: <20170328232713.29894-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42859 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753379AbdC1X2Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:28:16 -0400
In-Reply-To: <20170328232713.29894-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

This includes calling the parsing code that translates from pedit
speak to the HW API, allocation (deallocation) of a modify header
context and setting the modify header id associated with this
context to the FTE of that flow.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 35 +++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 3a31195f0d9c..4045b4768294 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -52,6 +52,7 @@
 struct mlx5_nic_flow_attr {
 	u32 action;
 	u32 flow_tag;
+	u32 mod_hdr_id;
 };
 
 enum {
@@ -97,10 +98,12 @@ mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 		.action = attr->action,
 		.flow_tag = attr->flow_tag,
 		.encap_id = 0,
+		.modify_id = attr->mod_hdr_id,
 	};
 	struct mlx5_fc *counter = NULL;
 	struct mlx5_flow_handle *rule;
 	bool table_created = false;
+	int err;
 
 	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
 		dest.type = MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE;
@@ -114,6 +117,18 @@ mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 		dest.counter = counter;
 	}
 
+	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR) {
+		err = mlx5_modify_header_alloc(dev, MLX5_FLOW_NAMESPACE_KERNEL,
+					       parse_attr->num_mod_hdr_actions,
+					       parse_attr->mod_hdr_actions,
+					       &attr->mod_hdr_id);
+		kfree(parse_attr->mod_hdr_actions);
+		if (err) {
+			rule = ERR_PTR(err);
+			goto err_create_mod_hdr_id;
+		}
+	}
+
 	if (IS_ERR_OR_NULL(priv->fs.tc.t)) {
 		priv->fs.tc.t =
 			mlx5_create_auto_grouped_flow_table(priv->fs.ns,
@@ -146,6 +161,10 @@ mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 		priv->fs.tc.t = NULL;
 	}
 err_create_ft:
+	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
+		mlx5_modify_header_dealloc(priv->mdev,
+					   attr->mod_hdr_id);
+err_create_mod_hdr_id:
 	mlx5_fc_destroy(dev, counter);
 
 	return rule;
@@ -164,6 +183,10 @@ static void mlx5e_tc_del_nic_flow(struct mlx5e_priv *priv,
 		mlx5_destroy_flow_table(priv->fs.tc.t);
 		priv->fs.tc.t = NULL;
 	}
+
+	if (flow->nic_attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
+		mlx5_modify_header_dealloc(priv->mdev,
+					   flow->nic_attr->mod_hdr_id);
 }
 
 static void mlx5e_detach_encap(struct mlx5e_priv *priv,
@@ -955,6 +978,7 @@ static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 	struct mlx5_nic_flow_attr *attr = flow->nic_attr;
 	const struct tc_action *a;
 	LIST_HEAD(actions);
+	int err;
 
 	if (tc_no_actions(exts))
 		return -EINVAL;
@@ -976,6 +1000,17 @@ static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 			continue;
 		}
 
+		if (is_tcf_pedit(a)) {
+			err = parse_tc_pedit_action(priv, a, MLX5_FLOW_NAMESPACE_KERNEL,
+						    parse_attr);
+			if (err)
+				return err;
+
+			attr->action |= MLX5_FLOW_CONTEXT_ACTION_MOD_HDR |
+					MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
+			continue;
+		}
+
 		if (is_tcf_skbedit_mark(a)) {
 			u32 mark = tcf_skbedit_mark(a);
 
-- 
2.11.0
