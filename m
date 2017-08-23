From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/5] mlxsw: spectrum: Offload multichain TC rules
Date: Wed, 23 Aug 2017 10:08:18 +0200
Message-ID: <20170823080822.14898-1-jiri@resnulli.us>
References: <20170823080652.14847-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:37779 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753425AbdHWIIZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 04:08:25 -0400
Received: by mail-wr0-f193.google.com with SMTP id z91so586562wrc.4
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 01:08:24 -0700 (PDT)
In-Reply-To: <20170823080652.14847-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Reflect chain index coming down from TC core and create a ruleset per
chain. Note that only chain 0, being the implicit chain, is bound to the
device for processing. The rest of chains have to be "jumped-to" by
actions.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  3 ---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  4 ++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c | 28 +++++++++++++++-------
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |  5 ++--
 4 files changed, 25 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 90a95cd..6e641db 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1733,9 +1733,6 @@ mlxsw_sp_setup_tc_cls_flower(struct mlxsw_sp_port *mlxsw_sp_port,
 	else
 		return -EOPNOTSUPP;
 
-	if (f->common.chain_index)
-		return -EOPNOTSUPP;
-
 	switch (f->command) {
 	case TC_CLSFLOWER_REPLACE:
 		return mlxsw_sp_flower_replace(mlxsw_sp_port, ingress, f);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 8452d1d..de3aef9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -440,8 +440,8 @@ struct mlxsw_sp_acl_ruleset;
 /* spectrum_acl.c */
 struct mlxsw_afk *mlxsw_sp_acl_afk(struct mlxsw_sp_acl *acl);
 struct mlxsw_sp_acl_ruleset *
-mlxsw_sp_acl_ruleset_get(struct mlxsw_sp *mlxsw_sp,
-			 struct net_device *dev, bool ingress,
+mlxsw_sp_acl_ruleset_get(struct mlxsw_sp *mlxsw_sp, struct net_device *dev,
+			 bool ingress, u32 chain_index,
 			 enum mlxsw_sp_acl_profile profile);
 void mlxsw_sp_acl_ruleset_put(struct mlxsw_sp *mlxsw_sp,
 			      struct mlxsw_sp_acl_ruleset *ruleset);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
index 508b5fc..8ab331b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
@@ -74,6 +74,7 @@ struct mlxsw_afk *mlxsw_sp_acl_afk(struct mlxsw_sp_acl *acl)
 struct mlxsw_sp_acl_ruleset_ht_key {
 	struct net_device *dev; /* dev this ruleset is bound to */
 	bool ingress;
+	u32 chain_index;
 	const struct mlxsw_sp_acl_profile_ops *ops;
 };
 
@@ -163,7 +164,8 @@ static void mlxsw_sp_acl_ruleset_destroy(struct mlxsw_sp *mlxsw_sp,
 
 static int mlxsw_sp_acl_ruleset_bind(struct mlxsw_sp *mlxsw_sp,
 				     struct mlxsw_sp_acl_ruleset *ruleset,
-				     struct net_device *dev, bool ingress)
+				     struct net_device *dev, bool ingress,
+				     u32 chain_index)
 {
 	const struct mlxsw_sp_acl_profile_ops *ops = ruleset->ht_key.ops;
 	struct mlxsw_sp_acl *acl = mlxsw_sp->acl;
@@ -171,13 +173,20 @@ static int mlxsw_sp_acl_ruleset_bind(struct mlxsw_sp *mlxsw_sp,
 
 	ruleset->ht_key.dev = dev;
 	ruleset->ht_key.ingress = ingress;
+	ruleset->ht_key.chain_index = chain_index;
 	err = rhashtable_insert_fast(&acl->ruleset_ht, &ruleset->ht_node,
 				     mlxsw_sp_acl_ruleset_ht_params);
 	if (err)
 		return err;
-	err = ops->ruleset_bind(mlxsw_sp, ruleset->priv, dev, ingress);
-	if (err)
-		goto err_ops_ruleset_bind;
+	if (!ruleset->ht_key.chain_index) {
+		/* We only need ruleset with chain index 0, the implicit one,
+		 * to be directly bound to device. The rest of the rulesets
+		 * are bound by "Goto action set".
+		 */
+		err = ops->ruleset_bind(mlxsw_sp, ruleset->priv, dev, ingress);
+		if (err)
+			goto err_ops_ruleset_bind;
+	}
 	return 0;
 
 err_ops_ruleset_bind:
@@ -192,7 +201,8 @@ static void mlxsw_sp_acl_ruleset_unbind(struct mlxsw_sp *mlxsw_sp,
 	const struct mlxsw_sp_acl_profile_ops *ops = ruleset->ht_key.ops;
 	struct mlxsw_sp_acl *acl = mlxsw_sp->acl;
 
-	ops->ruleset_unbind(mlxsw_sp, ruleset->priv);
+	if (!ruleset->ht_key.chain_index)
+		ops->ruleset_unbind(mlxsw_sp, ruleset->priv);
 	rhashtable_remove_fast(&acl->ruleset_ht, &ruleset->ht_node,
 			       mlxsw_sp_acl_ruleset_ht_params);
 }
@@ -212,8 +222,8 @@ static void mlxsw_sp_acl_ruleset_ref_dec(struct mlxsw_sp *mlxsw_sp,
 }
 
 struct mlxsw_sp_acl_ruleset *
-mlxsw_sp_acl_ruleset_get(struct mlxsw_sp *mlxsw_sp,
-			 struct net_device *dev, bool ingress,
+mlxsw_sp_acl_ruleset_get(struct mlxsw_sp *mlxsw_sp, struct net_device *dev,
+			 bool ingress, u32 chain_index,
 			 enum mlxsw_sp_acl_profile profile)
 {
 	const struct mlxsw_sp_acl_profile_ops *ops;
@@ -229,6 +239,7 @@ mlxsw_sp_acl_ruleset_get(struct mlxsw_sp *mlxsw_sp,
 	memset(&ht_key, 0, sizeof(ht_key));
 	ht_key.dev = dev;
 	ht_key.ingress = ingress;
+	ht_key.chain_index = chain_index;
 	ht_key.ops = ops;
 	ruleset = rhashtable_lookup_fast(&acl->ruleset_ht, &ht_key,
 					 mlxsw_sp_acl_ruleset_ht_params);
@@ -239,7 +250,8 @@ mlxsw_sp_acl_ruleset_get(struct mlxsw_sp *mlxsw_sp,
 	ruleset = mlxsw_sp_acl_ruleset_create(mlxsw_sp, ops);
 	if (IS_ERR(ruleset))
 		return ruleset;
-	err = mlxsw_sp_acl_ruleset_bind(mlxsw_sp, ruleset, dev, ingress);
+	err = mlxsw_sp_acl_ruleset_bind(mlxsw_sp, ruleset, dev,
+					ingress, chain_index);
 	if (err)
 		goto err_ruleset_bind;
 	return ruleset;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index 95428b4..34872aa 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -378,6 +378,7 @@ int mlxsw_sp_flower_replace(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 	int err;
 
 	ruleset = mlxsw_sp_acl_ruleset_get(mlxsw_sp, dev, ingress,
+					   f->common.chain_index,
 					   MLXSW_SP_ACL_PROFILE_FLOWER);
 	if (IS_ERR(ruleset))
 		return PTR_ERR(ruleset);
@@ -421,7 +422,7 @@ void mlxsw_sp_flower_destroy(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 	struct mlxsw_sp_acl_rule *rule;
 
 	ruleset = mlxsw_sp_acl_ruleset_get(mlxsw_sp, mlxsw_sp_port->dev,
-					   ingress,
+					   ingress, f->common.chain_index,
 					   MLXSW_SP_ACL_PROFILE_FLOWER);
 	if (IS_ERR(ruleset))
 		return;
@@ -447,7 +448,7 @@ int mlxsw_sp_flower_stats(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 	int err;
 
 	ruleset = mlxsw_sp_acl_ruleset_get(mlxsw_sp, mlxsw_sp_port->dev,
-					   ingress,
+					   ingress, f->common.chain_index,
 					   MLXSW_SP_ACL_PROFILE_FLOWER);
 	if (WARN_ON(IS_ERR(ruleset)))
 		return -EINVAL;
-- 
2.9.3
