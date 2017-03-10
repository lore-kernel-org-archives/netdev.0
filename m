From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 4/5] net/mlx5e: Avoid wrong identification of rules on deletion
Date: Fri, 10 Mar 2017 14:33:04 +0200
Message-ID: <20170310123305.2185-5-saeedm@mellanox.com>
References: <20170310123305.2185-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38695 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S937258AbdCJMdc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 07:33:32 -0500
In-Reply-To: <20170310123305.2185-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

When deleting offloaded TC flows, we must correctly identify E-switch
rules. The current check could get us wrong w.r.t to rules set on the
PF. Since it's possible to set NIC rules on the PF, switch to SRIOV
offloads mode and then attempt to delete a NIC rule.

To solve that, we add a flags field to offloaded rules, set it on
creation time and use that over the code where currently needed.

Fixes: 8b32580df1cb ('net/mlx5e: Add TC vlan action for SRIOV offloads')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 33 ++++++++++++++-----------
 1 file changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 44406a5ec15d..79481f4cf264 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -48,9 +48,14 @@
 #include "eswitch.h"
 #include "vxlan.h"
 
+enum {
+	MLX5E_TC_FLOW_ESWITCH	= BIT(0),
+};
+
 struct mlx5e_tc_flow {
 	struct rhash_head	node;
 	u64			cookie;
+	u8			flags;
 	struct mlx5_flow_handle *rule;
 	struct list_head	encap; /* flows sharing the same encap */
 	struct mlx5_esw_flow_attr *attr;
@@ -177,7 +182,7 @@ static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
 		mlx5_fc_destroy(priv->mdev, counter);
 	}
 
-	if (esw && esw->mode == SRIOV_OFFLOADS) {
+	if (flow->flags & MLX5E_TC_FLOW_ESWITCH) {
 		mlx5_eswitch_del_vlan_action(esw, flow->attr);
 		if (flow->attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
 			mlx5e_detach_encap(priv, flow);
@@ -598,6 +603,7 @@ static int __parse_cls_flower(struct mlx5e_priv *priv,
 }
 
 static int parse_cls_flower(struct mlx5e_priv *priv,
+			    struct mlx5e_tc_flow *flow,
 			    struct mlx5_flow_spec *spec,
 			    struct tc_cls_flower_offload *f)
 {
@@ -609,7 +615,7 @@ static int parse_cls_flower(struct mlx5e_priv *priv,
 
 	err = __parse_cls_flower(priv, spec, f, &min_inline);
 
-	if (!err && esw->mode == SRIOV_OFFLOADS &&
+	if (!err && (flow->flags & MLX5E_TC_FLOW_ESWITCH) &&
 	    rep->vport != FDB_UPLINK_VPORT) {
 		if (min_inline > esw->offloads.inline_mode) {
 			netdev_warn(priv->netdev,
@@ -1132,23 +1138,19 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 			   struct tc_cls_flower_offload *f)
 {
 	struct mlx5e_tc_table *tc = &priv->fs.tc;
-	int err = 0;
-	bool fdb_flow = false;
+	int err, attr_size = 0;
 	u32 flow_tag, action;
 	struct mlx5e_tc_flow *flow;
 	struct mlx5_flow_spec *spec;
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	u8 flow_flags = 0;
 
-	if (esw && esw->mode == SRIOV_OFFLOADS)
-		fdb_flow = true;
-
-	if (fdb_flow)
-		flow = kzalloc(sizeof(*flow) +
-			       sizeof(struct mlx5_esw_flow_attr),
-			       GFP_KERNEL);
-	else
-		flow = kzalloc(sizeof(*flow), GFP_KERNEL);
+	if (esw && esw->mode == SRIOV_OFFLOADS) {
+		flow_flags = MLX5E_TC_FLOW_ESWITCH;
+		attr_size  = sizeof(struct mlx5_esw_flow_attr);
+	}
 
+	flow = kzalloc(sizeof(*flow) + attr_size, GFP_KERNEL);
 	spec = mlx5_vzalloc(sizeof(*spec));
 	if (!spec || !flow) {
 		err = -ENOMEM;
@@ -1156,12 +1158,13 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	}
 
 	flow->cookie = f->cookie;
+	flow->flags = flow_flags;
 
-	err = parse_cls_flower(priv, spec, f);
+	err = parse_cls_flower(priv, flow, spec, f);
 	if (err < 0)
 		goto err_free;
 
-	if (fdb_flow) {
+	if (flow->flags & MLX5E_TC_FLOW_ESWITCH) {
 		flow->attr  = (struct mlx5_esw_flow_attr *)(flow + 1);
 		err = parse_tc_fdb_actions(priv, f->exts, flow);
 		if (err < 0)
-- 
2.11.0
