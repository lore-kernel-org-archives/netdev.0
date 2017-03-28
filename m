From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 03/12] net/mlx5e: Add intermediate struct for TC flow parsing attributes
Date: Wed, 29 Mar 2017 02:27:04 +0300
Message-ID: <20170328232713.29894-4-saeedm@mellanox.com>
References: <20170328232713.29894-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42827 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932516AbdC1X2B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:28:01 -0400
In-Reply-To: <20170328232713.29894-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Add intermediate structure to store attributes parsed from TC filter
matching/actions parts which are soon to be configured into the HW.

Currently put there the flow matching spec after being parsed. More
content to be added in down-stream patch.

This patch doesn't change any functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 29 +++++++++++++++----------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 2a9df0a0b859..9f900afcd7ea 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -70,6 +70,10 @@ struct mlx5e_tc_flow {
 	};
 };
 
+struct mlx5e_tc_flow_parse_attr {
+	struct mlx5_flow_spec spec;
+};
+
 enum {
 	MLX5_HEADER_TYPE_VXLAN = 0x0,
 	MLX5_HEADER_TYPE_NVGRE = 0x1,
@@ -80,7 +84,7 @@ enum {
 
 static struct mlx5_flow_handle *
 mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
-		      struct mlx5_flow_spec *spec,
+		      struct mlx5e_tc_flow_parse_attr *parse_attr,
 		      struct mlx5_nic_flow_attr *attr)
 {
 	struct mlx5_core_dev *dev = priv->mdev;
@@ -123,8 +127,9 @@ mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 		table_created = true;
 	}
 
-	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
-	rule = mlx5_add_flow_rules(priv->fs.tc.t, spec, &flow_act, &dest, 1);
+	parse_attr->spec.match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	rule = mlx5_add_flow_rules(priv->fs.tc.t, &parse_attr->spec,
+				   &flow_act, &dest, 1);
 
 	if (IS_ERR(rule))
 		goto err_add_rule;
@@ -161,7 +166,7 @@ static void mlx5e_tc_del_nic_flow(struct mlx5e_priv *priv,
 
 static struct mlx5_flow_handle *
 mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
-		      struct mlx5_flow_spec *spec,
+		      struct mlx5e_tc_flow_parse_attr *parse_attr,
 		      struct mlx5_esw_flow_attr *attr)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
@@ -171,7 +176,7 @@ mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
 	if (err)
 		return ERR_PTR(err);
 
-	return mlx5_eswitch_add_offloaded_rule(esw, spec, attr);
+	return mlx5_eswitch_add_offloaded_rule(esw, &parse_attr->spec, attr);
 }
 
 static void mlx5e_detach_encap(struct mlx5e_priv *priv,
@@ -1173,8 +1178,8 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 			   struct tc_cls_flower_offload *f)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	struct mlx5e_tc_flow_parse_attr *parse_attr;
 	struct mlx5e_tc_table *tc = &priv->fs.tc;
-	struct mlx5_flow_spec *spec;
 	struct mlx5e_tc_flow *flow;
 	int attr_size, err = 0;
 	u8 flow_flags = 0;
@@ -1188,8 +1193,8 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	}
 
 	flow = kzalloc(sizeof(*flow) + attr_size, GFP_KERNEL);
-	spec = mlx5_vzalloc(sizeof(*spec));
-	if (!spec || !flow) {
+	parse_attr = mlx5_vzalloc(sizeof(*parse_attr));
+	if (!parse_attr || !flow) {
 		err = -ENOMEM;
 		goto err_free;
 	}
@@ -1197,7 +1202,7 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	flow->cookie = f->cookie;
 	flow->flags = flow_flags;
 
-	err = parse_cls_flower(priv, flow, spec, f);
+	err = parse_cls_flower(priv, flow, &parse_attr->spec, f);
 	if (err < 0)
 		goto err_free;
 
@@ -1205,12 +1210,12 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 		err = parse_tc_fdb_actions(priv, f->exts, flow);
 		if (err < 0)
 			goto err_free;
-		flow->rule = mlx5e_tc_add_fdb_flow(priv, spec, flow->esw_attr);
+		flow->rule = mlx5e_tc_add_fdb_flow(priv, parse_attr, flow->esw_attr);
 	} else {
 		err = parse_tc_nic_actions(priv, f->exts, flow->nic_attr);
 		if (err < 0)
 			goto err_free;
-		flow->rule = mlx5e_tc_add_nic_flow(priv, spec, flow->nic_attr);
+		flow->rule = mlx5e_tc_add_nic_flow(priv, parse_attr, flow->nic_attr);
 	}
 
 	if (IS_ERR(flow->rule)) {
@@ -1231,7 +1236,7 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 err_free:
 	kfree(flow);
 out:
-	kvfree(spec);
+	kvfree(parse_attr);
 	return err;
 }
 
-- 
2.11.0
