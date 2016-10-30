From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next V2 15/15] net/mlx5e: Add tc support for FWD rule with counter
Date: Sun, 30 Oct 2016 23:22:08 +0200
Message-ID: <1477862528-4328-16-git-send-email-saeedm@mellanox.com>
References: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477862528-4328-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

When creating a FWD rule using tc create also a HW counter
for this rule.

Signed-off-by: Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c      |  3 ++-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c   | 20 +++++++++++---------
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 5d9ac0d..c2e4728 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -419,7 +419,8 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 				return -EINVAL;
 			}
 
-			attr->action |= MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
+			attr->action |= MLX5_FLOW_CONTEXT_ACTION_FWD_DEST |
+					MLX5_FLOW_CONTEXT_ACTION_COUNT;
 			out_priv = netdev_priv(out_dev);
 			attr->out_rep = out_priv->ppriv;
 			continue;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 8b2a383..53d9d6c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -48,11 +48,12 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 				struct mlx5_flow_spec *spec,
 				struct mlx5_esw_flow_attr *attr)
 {
-	struct mlx5_flow_destination dest = { 0 };
+	struct mlx5_flow_destination dest[2] = {};
 	struct mlx5_fc *counter = NULL;
 	struct mlx5_flow_handle *rule;
 	void *misc;
 	int action;
+	int i = 0;
 
 	if (esw->mode != SRIOV_OFFLOADS)
 		return ERR_PTR(-EOPNOTSUPP);
@@ -60,15 +61,17 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 	action = attr->action;
 
 	if (action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
-		dest.type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
-		dest.vport_num = attr->out_rep->vport;
-		action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
-	} else if (action & MLX5_FLOW_CONTEXT_ACTION_COUNT) {
+		dest[i].type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
+		dest[i].vport_num = attr->out_rep->vport;
+		i++;
+	}
+	if (action & MLX5_FLOW_CONTEXT_ACTION_COUNT) {
 		counter = mlx5_fc_create(esw->dev, true);
 		if (IS_ERR(counter))
 			return ERR_CAST(counter);
-		dest.type = MLX5_FLOW_DESTINATION_TYPE_COUNTER;
-		dest.counter = counter;
+		dest[i].type = MLX5_FLOW_DESTINATION_TYPE_COUNTER;
+		dest[i].counter = counter;
+		i++;
 	}
 
 	misc = MLX5_ADDR_OF(fte_match_param, spec->match_value, misc_parameters);
@@ -81,8 +84,7 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 				      MLX5_MATCH_MISC_PARAMETERS;
 
 	rule = mlx5_add_flow_rules((struct mlx5_flow_table *)esw->fdb_table.fdb,
-				   spec, action, 0, &dest, 1);
-
+				   spec, action, 0, dest, i);
 	if (IS_ERR(rule))
 		mlx5_fc_destroy(esw->dev, counter);
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
