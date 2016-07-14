From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 06/10] net/mlx5e: Adjustments in the TC offload code towards reuse for SRIOV
Date: Thu, 14 Jul 2016 10:32:42 +0300
Message-ID: <1468481566-29859-7-git-send-email-saeedm@mellanox.com>
References: <1468481566-29859-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43354 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750980AbcGNHdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 03:33:15 -0400
In-Reply-To: <1468481566-29859-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Towards reusing the TC offloads code for an SRIOV use-case, change some of the
helper functions to have _nic in their names so it's clear what's NIC unique
and what's general. Also group together the NIC related helpers so we can easily
branch per the use-case in downstream patch.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 32 ++++++++++++-------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index cd58fc8..57b76f7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -49,9 +49,9 @@ struct mlx5e_tc_flow {
 #define MLX5E_TC_TABLE_NUM_ENTRIES 1024
 #define MLX5E_TC_TABLE_NUM_GROUPS 4
 
-static struct mlx5_flow_rule *mlx5e_tc_add_flow(struct mlx5e_priv *priv,
-						struct mlx5_flow_spec *spec,
-						u32 action, u32 flow_tag)
+static struct mlx5_flow_rule *mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
+						    struct mlx5_flow_spec *spec,
+						    u32 action, u32 flow_tag)
 {
 	struct mlx5_core_dev *dev = priv->mdev;
 	struct mlx5_flow_destination dest = { 0 };
@@ -120,7 +120,7 @@ static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
 
 	mlx5_fc_destroy(priv->mdev, counter);
 
-	if (!mlx5e_tc_num_filters(priv)) {
+	if (!mlx5e_tc_num_filters(priv) && (priv->fs.tc.t)) {
 		mlx5_destroy_flow_table(priv->fs.tc.t);
 		priv->fs.tc.t = NULL;
 	}
@@ -295,8 +295,8 @@ static int parse_cls_flower(struct mlx5e_priv *priv, struct mlx5_flow_spec *spec
 	return 0;
 }
 
-static int parse_tc_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
-			    u32 *action, u32 *flow_tag)
+static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
+				u32 *action, u32 *flow_tag)
 {
 	const struct tc_action *a;
 
@@ -369,28 +369,28 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	if (err < 0)
 		goto err_free;
 
-	err = parse_tc_actions(priv, f->exts, &action, &flow_tag);
+	err = parse_tc_nic_actions(priv, f->exts, &action, &flow_tag);
 	if (err < 0)
 		goto err_free;
 
-	err = rhashtable_insert_fast(&tc->ht, &flow->node,
-				     tc->ht_params);
-	if (err)
-		goto err_free;
-
-	flow->rule = mlx5e_tc_add_flow(priv, spec, action, flow_tag);
+	flow->rule = mlx5e_tc_add_nic_flow(priv, spec, action, flow_tag);
 	if (IS_ERR(flow->rule)) {
 		err = PTR_ERR(flow->rule);
-		goto err_hash_del;
+		goto err_free;
 	}
 
+	err = rhashtable_insert_fast(&tc->ht, &flow->node,
+				     tc->ht_params);
+	if (err)
+		goto err_del_rule;
+
 	if (old)
 		mlx5e_tc_del_flow(priv, old);
 
 	goto out;
 
-err_hash_del:
-	rhashtable_remove_fast(&tc->ht, &flow->node, tc->ht_params);
+err_del_rule:
+	mlx5_del_flow_rule(flow->rule);
 
 err_free:
 	if (!old)
-- 
2.8.0
