From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 03/16] net/mlx5: E-Switch, Add miss rule for offloads mode
Date: Thu, 30 Jun 2016 18:23:22 +0300
Message-ID: <1467300215-14199-4-git-send-email-saeedm@mellanox.com>
References: <1467300215-14199-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:43139 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932161AbcF3PY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 11:24:56 -0400
In-Reply-To: <1467300215-14199-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

In the sriov offloads mode, packets that are not matched by any other
rule should be sent towards the e-switch manager for further processing.

Add such "miss" rule which matches ANY packet as the last rule in the
e-switch FDB and programs the HW to send the packet to vport 0 where
the e-switch manager runs.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  1 +
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 40 ++++++++++++++++++++++
 2 files changed, 41 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 2360180..8eed33f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -144,6 +144,7 @@ struct mlx5_eswitch_fdb {
 		struct offloads_fdb {
 			struct mlx5_flow_group *send_to_vport_grp;
 			struct mlx5_flow_group *miss_grp;
+			struct mlx5_flow_rule  *miss_rule;
 		} offloads;
 	};
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index c6b28df..e3d81ae 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -38,6 +38,39 @@
 #include "mlx5_core.h"
 #include "eswitch.h"
 
+static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
+{
+	struct mlx5_flow_destination dest;
+	struct mlx5_flow_rule *flow_rule = NULL;
+	u32 *match_v, *match_c;
+	int err = 0;
+
+	match_v = kzalloc(MLX5_ST_SZ_BYTES(fte_match_param), GFP_KERNEL);
+	match_c = kzalloc(MLX5_ST_SZ_BYTES(fte_match_param), GFP_KERNEL);
+	if (!match_v || !match_c) {
+		esw_warn(esw->dev, "FDB: Failed to alloc match parameters\n");
+		err = -ENOMEM;
+		goto out;
+	}
+
+	dest.type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
+	dest.vport_num = 0;
+
+	flow_rule = mlx5_add_flow_rule(esw->fdb_table.fdb, 0, match_c, match_v,
+				       MLX5_FLOW_CONTEXT_ACTION_FWD_DEST, 0, &dest);
+	if (IS_ERR(flow_rule)) {
+		err = PTR_ERR(flow_rule);
+		esw_warn(esw->dev,  "FDB: Failed to add miss flow rule err %d\n", err);
+		goto out;
+	}
+
+	esw->fdb_table.offloads.miss_rule = flow_rule;
+out:
+	kfree(match_v);
+	kfree(match_c);
+	return err;
+}
+
 #define MAX_PF_SQ 256
 
 int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
@@ -110,8 +143,14 @@ int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	}
 	esw->fdb_table.offloads.miss_grp = g;
 
+	err = esw_add_fdb_miss_rule(esw);
+	if (err)
+		goto miss_rule_err;
+
 	return 0;
 
+miss_rule_err:
+	mlx5_destroy_flow_group(esw->fdb_table.offloads.miss_grp);
 miss_err:
 	mlx5_destroy_flow_group(esw->fdb_table.offloads.send_to_vport_grp);
 send_vport_err:
@@ -128,6 +167,7 @@ void esw_destroy_offloads_fdb_table(struct mlx5_eswitch *esw)
 		return;
 
 	esw_debug(esw->dev, "Destroy offloads FDB Table\n");
+	mlx5_del_flow_rule(esw->fdb_table.offloads.miss_rule);
 	mlx5_destroy_flow_group(esw->fdb_table.offloads.send_to_vport_grp);
 	mlx5_destroy_flow_group(esw->fdb_table.offloads.miss_grp);
 
-- 
2.8.0
