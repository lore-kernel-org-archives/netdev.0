From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 2/9] net/mlx5: E-Switch, Set the vport when registering the uplink rep
Date: Thu, 22 Sep 2016 20:01:42 +0300
Message-ID: <1474563709-17943-3-git-send-email-saeedm@mellanox.com>
References: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirv@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49006 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S964996AbcIVRCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 13:02:16 -0400
In-Reply-To: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Set the vport value in the PF entry to be that of the uplink so
we can use it blindly over the tc / eswitch offload code without
translating it each time we deal with the uplink representor.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  6 ++---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 10 ++------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  3 ++-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 27 +++++++++++-----------
 4 files changed, 20 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index a9fc9d4..b309e7c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3726,9 +3726,9 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 		mlx5_query_nic_vport_mac_address(mdev, 0, rep.hw_id);
 		rep.load = mlx5e_nic_rep_load;
 		rep.unload = mlx5e_nic_rep_unload;
-		rep.vport = 0;
+		rep.vport = FDB_UPLINK_VPORT;
 		rep.priv_data = priv;
-		mlx5_eswitch_register_vport_rep(esw, &rep);
+		mlx5_eswitch_register_vport_rep(esw, 0, &rep);
 	}
 }
 
@@ -3867,7 +3867,7 @@ static void mlx5e_register_vport_rep(struct mlx5_core_dev *mdev)
 		rep.unload = mlx5e_vport_rep_unload;
 		rep.vport = vport;
 		ether_addr_copy(rep.hw_id, mac);
-		mlx5_eswitch_register_vport_rep(esw, &rep);
+		mlx5_eswitch_register_vport_rep(esw, vport, &rep);
 	}
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 22cfc4a..783e122 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -120,10 +120,7 @@ static struct mlx5_flow_rule *mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
 	struct mlx5_eswitch_rep *rep = priv->ppriv;
 	u32 src_vport;
 
-	if (rep->vport) /* set source vport for the flow */
-		src_vport = rep->vport;
-	else
-		src_vport = FDB_UPLINK_VPORT;
+	src_vport = rep->vport;
 
 	return mlx5_eswitch_add_offloaded_rule(esw, spec, action, src_vport, dst_vport);
 }
@@ -399,10 +396,7 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 
 			out_priv = netdev_priv(out_dev);
 			out_rep  = out_priv->ppriv;
-			if (out_rep->vport == 0)
-				*dest_vport = FDB_UPLINK_VPORT;
-			else
-				*dest_vport = out_rep->vport;
+			*dest_vport = out_rep->vport;
 			*action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
 			continue;
 		}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index b96e8c9..6d8c5a2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -254,9 +254,10 @@ void mlx5_eswitch_sqs2vport_stop(struct mlx5_eswitch *esw,
 int mlx5_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode);
 int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode);
 void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
+				     int vport_index,
 				     struct mlx5_eswitch_rep *rep);
 void mlx5_eswitch_unregister_vport_rep(struct mlx5_eswitch *esw,
-				       int vport);
+				       int vport_index);
 
 #define MLX5_DEBUG_ESWITCH_MASK BIT(3)
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 3dc83a9..a73721b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -144,16 +144,12 @@ int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
 {
 	struct mlx5_flow_rule *flow_rule;
 	struct mlx5_esw_sq *esw_sq;
-	int vport;
 	int err;
 	int i;
 
 	if (esw->mode != SRIOV_OFFLOADS)
 		return 0;
 
-	vport = rep->vport == 0 ?
-		FDB_UPLINK_VPORT : rep->vport;
-
 	for (i = 0; i < sqns_num; i++) {
 		esw_sq = kzalloc(sizeof(*esw_sq), GFP_KERNEL);
 		if (!esw_sq) {
@@ -163,7 +159,7 @@ int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
 
 		/* Add re-inject rule to the PF/representor sqs */
 		flow_rule = mlx5_eswitch_add_send_to_vport_rule(esw,
-								vport,
+								rep->vport,
 								sqns_array[i]);
 		if (IS_ERR(flow_rule)) {
 			err = PTR_ERR(flow_rule);
@@ -612,27 +608,30 @@ int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode)
 }
 
 void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
-				     struct mlx5_eswitch_rep *rep)
+				     int vport_index,
+				     struct mlx5_eswitch_rep *__rep)
 {
 	struct mlx5_esw_offload *offloads = &esw->offloads;
+	struct mlx5_eswitch_rep *rep;
+
+	rep = &offloads->vport_reps[vport_index];
 
-	memcpy(&offloads->vport_reps[rep->vport], rep,
-	       sizeof(struct mlx5_eswitch_rep));
+	memcpy(rep, __rep, sizeof(struct mlx5_eswitch_rep));
 
-	INIT_LIST_HEAD(&offloads->vport_reps[rep->vport].vport_sqs_list);
-	offloads->vport_reps[rep->vport].valid = true;
+	INIT_LIST_HEAD(&rep->vport_sqs_list);
+	rep->valid = true;
 }
 
 void mlx5_eswitch_unregister_vport_rep(struct mlx5_eswitch *esw,
-				       int vport)
+				       int vport_index)
 {
 	struct mlx5_esw_offload *offloads = &esw->offloads;
 	struct mlx5_eswitch_rep *rep;
 
-	rep = &offloads->vport_reps[vport];
+	rep = &offloads->vport_reps[vport_index];
 
-	if (esw->mode == SRIOV_OFFLOADS && esw->vports[vport].enabled)
+	if (esw->mode == SRIOV_OFFLOADS && esw->vports[vport_index].enabled)
 		rep->unload(esw, rep);
 
-	offloads->vport_reps[vport].valid = false;
+	rep->valid = false;
 }
-- 
2.7.4
