From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 08/13] net/mlx5: E-Switch, Use the correct error check on returned pointers
Date: Fri, 10 Jun 2016 00:07:35 +0300
Message-ID: <1465506460-1854-9-git-send-email-saeedm@mellanox.com>
References: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34500 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751887AbcFIVJb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 17:09:31 -0400
In-Reply-To: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The mlx5 flow-steering API (mlx5_create_flow_table/group/rule) never
returns null pointer on error. Even if it was doing that, checking
for IS_ERR_OR_NULL(p) and then returning PTR_ERR(p) would have cause
bugs, since PTR_ERR(NULL) --> success, crash.

To make things more robust and protect against related future bugs,
convert all IS_ERR_OR_NULL checks on returned values to IS_ERR.

Fixes: 5742df0f7dbe ('net/mlx5: E-Switch, Introduce VST vport ingress/egress ACLs')
Fixes: 86d722ad2c3b ('net/mlx5: Use flow steering infrastructure for mlx5_en')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 34 +++++++++++------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 5374796..a350af2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -383,7 +383,7 @@ __esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u32 vport, bool rx_rule,
 				   match_v,
 				   MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
 				   0, &dest);
-	if (IS_ERR_OR_NULL(flow_rule)) {
+	if (IS_ERR(flow_rule)) {
 		pr_warn(
 			"FDB: Failed to add flow rule: dmac_v(%pM) dmac_c(%pM) -> vport(%d), err(%ld)\n",
 			 dmac_v, dmac_c, vport, PTR_ERR(flow_rule));
@@ -457,7 +457,7 @@ static int esw_create_fdb_table(struct mlx5_eswitch *esw, int nvports)
 
 	table_size = BIT(MLX5_CAP_ESW_FLOWTABLE_FDB(dev, log_max_ft_size));
 	fdb = mlx5_create_flow_table(root_ns, 0, table_size, 0);
-	if (IS_ERR_OR_NULL(fdb)) {
+	if (IS_ERR(fdb)) {
 		err = PTR_ERR(fdb);
 		esw_warn(dev, "Failed to create FDB Table err %d\n", err);
 		goto out;
@@ -474,7 +474,7 @@ static int esw_create_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, table_size - 3);
 	eth_broadcast_addr(dmac);
 	g = mlx5_create_flow_group(fdb, flow_group_in);
-	if (IS_ERR_OR_NULL(g)) {
+	if (IS_ERR(g)) {
 		err = PTR_ERR(g);
 		esw_warn(dev, "Failed to create flow group err(%d)\n", err);
 		goto out;
@@ -489,7 +489,7 @@ static int esw_create_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	eth_zero_addr(dmac);
 	dmac[0] = 0x01;
 	g = mlx5_create_flow_group(fdb, flow_group_in);
-	if (IS_ERR_OR_NULL(g)) {
+	if (IS_ERR(g)) {
 		err = PTR_ERR(g);
 		esw_warn(dev, "Failed to create allmulti flow group err(%d)\n", err);
 		goto out;
@@ -506,7 +506,7 @@ static int esw_create_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, table_size - 1);
 	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, table_size - 1);
 	g = mlx5_create_flow_group(fdb, flow_group_in);
-	if (IS_ERR_OR_NULL(g)) {
+	if (IS_ERR(g)) {
 		err = PTR_ERR(g);
 		esw_warn(dev, "Failed to create promisc flow group err(%d)\n", err);
 		goto out;
@@ -1060,7 +1060,7 @@ static void esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 		return;
 
 	acl = mlx5_create_vport_flow_table(root_ns, 0, table_size, 0, vport->vport);
-	if (IS_ERR_OR_NULL(acl)) {
+	if (IS_ERR(acl)) {
 		err = PTR_ERR(acl);
 		esw_warn(dev, "Failed to create E-Switch vport[%d] egress flow Table, err(%d)\n",
 			 vport->vport, err);
@@ -1075,7 +1075,7 @@ static void esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 0);
 
 	vlan_grp = mlx5_create_flow_group(acl, flow_group_in);
-	if (IS_ERR_OR_NULL(vlan_grp)) {
+	if (IS_ERR(vlan_grp)) {
 		err = PTR_ERR(vlan_grp);
 		esw_warn(dev, "Failed to create E-Switch vport[%d] egress allowed vlans flow group, err(%d)\n",
 			 vport->vport, err);
@@ -1086,7 +1086,7 @@ static void esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, 1);
 	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 1);
 	drop_grp = mlx5_create_flow_group(acl, flow_group_in);
-	if (IS_ERR_OR_NULL(drop_grp)) {
+	if (IS_ERR(drop_grp)) {
 		err = PTR_ERR(drop_grp);
 		esw_warn(dev, "Failed to create E-Switch vport[%d] egress drop flow group, err(%d)\n",
 			 vport->vport, err);
@@ -1174,7 +1174,7 @@ static void esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 		return;
 
 	acl = mlx5_create_vport_flow_table(root_ns, 0, table_size, 0, vport->vport);
-	if (IS_ERR_OR_NULL(acl)) {
+	if (IS_ERR(acl)) {
 		err = PTR_ERR(acl);
 		esw_warn(dev, "Failed to create E-Switch vport[%d] ingress flow Table, err(%d)\n",
 			 vport->vport, err);
@@ -1192,7 +1192,7 @@ static void esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 0);
 
 	g = mlx5_create_flow_group(acl, flow_group_in);
-	if (IS_ERR_OR_NULL(g)) {
+	if (IS_ERR(g)) {
 		err = PTR_ERR(g);
 		esw_warn(dev, "Failed to create E-Switch vport[%d] ingress untagged spoofchk flow group, err(%d)\n",
 			 vport->vport, err);
@@ -1207,7 +1207,7 @@ static void esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 1);
 
 	g = mlx5_create_flow_group(acl, flow_group_in);
-	if (IS_ERR_OR_NULL(g)) {
+	if (IS_ERR(g)) {
 		err = PTR_ERR(g);
 		esw_warn(dev, "Failed to create E-Switch vport[%d] ingress untagged flow group, err(%d)\n",
 			 vport->vport, err);
@@ -1223,7 +1223,7 @@ static void esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 2);
 
 	g = mlx5_create_flow_group(acl, flow_group_in);
-	if (IS_ERR_OR_NULL(g)) {
+	if (IS_ERR(g)) {
 		err = PTR_ERR(g);
 		esw_warn(dev, "Failed to create E-Switch vport[%d] ingress spoofchk flow group, err(%d)\n",
 			 vport->vport, err);
@@ -1236,7 +1236,7 @@ static void esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, 3);
 
 	g = mlx5_create_flow_group(acl, flow_group_in);
-	if (IS_ERR_OR_NULL(g)) {
+	if (IS_ERR(g)) {
 		err = PTR_ERR(g);
 		esw_warn(dev, "Failed to create E-Switch vport[%d] ingress drop flow group, err(%d)\n",
 			 vport->vport, err);
@@ -1363,7 +1363,7 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 				   match_v,
 				   MLX5_FLOW_CONTEXT_ACTION_ALLOW,
 				   0, NULL);
-	if (IS_ERR_OR_NULL(vport->ingress.allow_rule)) {
+	if (IS_ERR(vport->ingress.allow_rule)) {
 		err = PTR_ERR(vport->ingress.allow_rule);
 		pr_warn("vport[%d] configure ingress allow rule, err(%d)\n",
 			vport->vport, err);
@@ -1380,7 +1380,7 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 				   match_v,
 				   MLX5_FLOW_CONTEXT_ACTION_DROP,
 				   0, NULL);
-	if (IS_ERR_OR_NULL(vport->ingress.drop_rule)) {
+	if (IS_ERR(vport->ingress.drop_rule)) {
 		err = PTR_ERR(vport->ingress.drop_rule);
 		pr_warn("vport[%d] configure ingress drop rule, err(%d)\n",
 			vport->vport, err);
@@ -1439,7 +1439,7 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 				   match_v,
 				   MLX5_FLOW_CONTEXT_ACTION_ALLOW,
 				   0, NULL);
-	if (IS_ERR_OR_NULL(vport->egress.allowed_vlan)) {
+	if (IS_ERR(vport->egress.allowed_vlan)) {
 		err = PTR_ERR(vport->egress.allowed_vlan);
 		pr_warn("vport[%d] configure egress allowed vlan rule failed, err(%d)\n",
 			vport->vport, err);
@@ -1457,7 +1457,7 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 				   match_v,
 				   MLX5_FLOW_CONTEXT_ACTION_DROP,
 				   0, NULL);
-	if (IS_ERR_OR_NULL(vport->egress.drop_rule)) {
+	if (IS_ERR(vport->egress.drop_rule)) {
 		err = PTR_ERR(vport->egress.drop_rule);
 		pr_warn("vport[%d] configure egress drop rule failed, err(%d)\n",
 			vport->vport, err);
-- 
2.8.0
