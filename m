From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 05/10] net/mlx5: E-Switch, Add API to configure rules for the offloaded mode
Date: Thu, 14 Jul 2016 10:32:41 +0300
Message-ID: <1468481566-29859-6-git-send-email-saeedm@mellanox.com>
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
Received: from mailp.voltaire.com ([193.47.165.129]:43330 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750947AbcGNHdM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 03:33:12 -0400
In-Reply-To: <1468481566-29859-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

This allows for upper levels in the driver, e.g the TC offload code to add
e-switch offloaded steering rules. The caller provides the rule spec for
matching, action, source and destination vports.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  6 +++
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 43 ++++++++++++++++++++++
 2 files changed, 49 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 035e536..c0b0560 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -222,6 +222,12 @@ int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
 				 int vport,
 				 struct ifla_vf_stats *vf_stats);
 
+struct mlx5_flow_spec;
+
+struct mlx5_flow_rule *
+mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
+				struct mlx5_flow_spec *spec,
+				u32 action, u32 src_vport, u32 dst_vport);
 struct mlx5_flow_rule *
 mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 27122c0..a357e8e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -43,6 +43,49 @@ enum {
 	FDB_SLOW_PATH
 };
 
+struct mlx5_flow_rule *
+mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
+				struct mlx5_flow_spec *spec,
+				u32 action, u32 src_vport, u32 dst_vport)
+{
+	struct mlx5_flow_destination dest = { 0 };
+	struct mlx5_fc *counter = NULL;
+	struct mlx5_flow_rule *rule;
+	void *misc;
+
+	if (esw->mode != SRIOV_OFFLOADS)
+		return ERR_PTR(-EOPNOTSUPP);
+
+	if (action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
+		dest.type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
+		dest.vport_num = dst_vport;
+		action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
+	} else if (action & MLX5_FLOW_CONTEXT_ACTION_COUNT) {
+		counter = mlx5_fc_create(esw->dev, true);
+		if (IS_ERR(counter))
+			return ERR_CAST(counter);
+		dest.type = MLX5_FLOW_DESTINATION_TYPE_COUNTER;
+		dest.counter = counter;
+	}
+
+	misc = MLX5_ADDR_OF(fte_match_param, spec->match_value, misc_parameters);
+	MLX5_SET(fte_match_set_misc, misc, source_port, src_vport);
+
+	misc = MLX5_ADDR_OF(fte_match_param, spec->match_criteria, misc_parameters);
+	MLX5_SET_TO_ONES(fte_match_set_misc, misc, source_port);
+
+	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS |
+				      MLX5_MATCH_MISC_PARAMETERS;
+
+	rule = mlx5_add_flow_rule((struct mlx5_flow_table *)esw->fdb_table.fdb,
+				  spec, action, 0, &dest);
+
+	if (IS_ERR(rule))
+		mlx5_fc_destroy(esw->dev, counter);
+
+	return rule;
+}
+
 static struct mlx5_flow_rule *
 mlx5_eswitch_add_send_to_vport_rule(struct mlx5_eswitch *esw, int vport, u32 sqn)
 {
-- 
2.8.0
