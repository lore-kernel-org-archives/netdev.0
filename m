From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 09/10] net/mlx5e: Add TC HW support for FDB (SRIOV e-switch) offloads
Date: Thu, 14 Jul 2016 10:32:45 +0300
Message-ID: <1468481566-29859-10-git-send-email-saeedm@mellanox.com>
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
Received: from mailp.voltaire.com ([193.47.165.129]:43373 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751103AbcGNHdR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 03:33:17 -0400
In-Reply-To: <1468481566-29859-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Enhance the TC offload code such that when the eswitch exists and it's
mode being SRIOV offloads, we do TC actions parsing and setup targeted
for eswitch. Next, we add the offloaded flow to the HW e-switch (fdb).

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c |  5 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c  | 35 ++++++++++++++++++++----
 2 files changed, 34 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 5ef02f0..fdaf2fa 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -36,6 +36,7 @@
 
 #include "eswitch.h"
 #include "en.h"
+#include "en_tc.h"
 
 static const char mlx5e_rep_driver_name[] = "mlx5e_rep";
 
@@ -201,6 +202,10 @@ void mlx5e_nic_rep_unload(struct mlx5_eswitch *esw,
 
 	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
 		mlx5e_remove_sqs_fwd_rules(priv);
+
+	/* clean (and re-init) existing uplink offloaded TC rules */
+	mlx5e_tc_cleanup(priv);
+	mlx5e_tc_init(priv);
 }
 
 static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 9a66441..0f19b01 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -112,6 +112,22 @@ err_create_ft:
 	return rule;
 }
 
+static struct mlx5_flow_rule *mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
+						    struct mlx5_flow_spec *spec,
+						    u32 action, u32 dst_vport)
+{
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	u32 src_vport;
+
+	if (rep->vport) /* set source vport for the flow */
+		src_vport = rep->vport;
+	else
+		src_vport = FDB_UPLINK_VPORT;
+
+	return mlx5_eswitch_add_offloaded_rule(esw, spec, action, src_vport, dst_vport);
+}
+
 static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
 			      struct mlx5_flow_rule *rule)
 {
@@ -397,11 +413,11 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 {
 	struct mlx5e_tc_table *tc = &priv->fs.tc;
 	int err = 0;
-	u32 flow_tag;
-	u32 action;
+	u32 flow_tag, action, dest_vport = 0;
 	struct mlx5e_tc_flow *flow;
 	struct mlx5_flow_spec *spec;
 	struct mlx5_flow_rule *old = NULL;
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 
 	flow = rhashtable_lookup_fast(&tc->ht, &f->cookie,
 				      tc->ht_params);
@@ -422,11 +438,18 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	if (err < 0)
 		goto err_free;
 
-	err = parse_tc_nic_actions(priv, f->exts, &action, &flow_tag);
-	if (err < 0)
-		goto err_free;
+	if (esw && esw->mode == SRIOV_OFFLOADS) {
+		err = parse_tc_fdb_actions(priv, f->exts, &action, &dest_vport);
+		if (err < 0)
+			goto err_free;
+		flow->rule = mlx5e_tc_add_fdb_flow(priv, spec, action, dest_vport);
+	} else {
+		err = parse_tc_nic_actions(priv, f->exts, &action, &flow_tag);
+		if (err < 0)
+			goto err_free;
+		flow->rule = mlx5e_tc_add_nic_flow(priv, spec, action, flow_tag);
+	}
 
-	flow->rule = mlx5e_tc_add_nic_flow(priv, spec, action, flow_tag);
 	if (IS_ERR(flow->rule)) {
 		err = PTR_ERR(flow->rule);
 		goto err_free;
-- 
2.8.0
