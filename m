From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 4/7] net/mlx5e: Remove redundant hashtable lookup in configure flower
Date: Wed, 30 Nov 2016 00:19:29 +0200
Message-ID: <1480457972-31286-5-git-send-email-saeedm@mellanox.com>
References: <1480457972-31286-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45851 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755237AbcK2WT4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 17:19:56 -0500
In-Reply-To: <1480457972-31286-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roi Dayan <roid@mellanox.com>

We will never find a flow with the same cookie as cls_flower always
allocates a new flow and the cookie is the allocated memory address.

Fixes: e3a2b7ed018e ("net/mlx5e: Support offload cls_flower with drop action")
Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 26 +++++++------------------
 1 file changed, 7 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 4d06fab..dd6d954 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -915,25 +915,17 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	u32 flow_tag, action;
 	struct mlx5e_tc_flow *flow;
 	struct mlx5_flow_spec *spec;
-	struct mlx5_flow_handle *old = NULL;
-	struct mlx5_esw_flow_attr *old_attr = NULL;
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 
 	if (esw && esw->mode == SRIOV_OFFLOADS)
 		fdb_flow = true;
 
-	flow = rhashtable_lookup_fast(&tc->ht, &f->cookie,
-				      tc->ht_params);
-	if (flow) {
-		old = flow->rule;
-		old_attr = flow->attr;
-	} else {
-		if (fdb_flow)
-			flow = kzalloc(sizeof(*flow) + sizeof(struct mlx5_esw_flow_attr),
-				       GFP_KERNEL);
-		else
-			flow = kzalloc(sizeof(*flow), GFP_KERNEL);
-	}
+	if (fdb_flow)
+		flow = kzalloc(sizeof(*flow) +
+			       sizeof(struct mlx5_esw_flow_attr),
+			       GFP_KERNEL);
+	else
+		flow = kzalloc(sizeof(*flow), GFP_KERNEL);
 
 	spec = mlx5_vzalloc(sizeof(*spec));
 	if (!spec || !flow) {
@@ -970,17 +962,13 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	if (err)
 		goto err_del_rule;
 
-	if (old)
-		mlx5e_tc_del_flow(priv, old, old_attr);
-
 	goto out;
 
 err_del_rule:
 	mlx5_del_flow_rules(flow->rule);
 
 err_free:
-	if (!old)
-		kfree(flow);
+	kfree(flow);
 out:
 	kvfree(spec);
 	return err;
-- 
2.7.4
