From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/9] mlxsw: spectrum: Add support for direct rule access
Date: Sat, 11 Mar 2017 09:42:55 +0100
Message-ID: <1489221779-3807-6-git-send-email-jiri@resnulli.us>
References: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, mlxsw@mellanox.com,
        idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35076 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752741AbdCKInI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 03:43:08 -0500
Received: by mail-wm0-f65.google.com with SMTP id z63so2238495wmg.2
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 00:43:07 -0800 (PST)
In-Reply-To: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Currently the ACL rules can be accessed only by hashing. In order to
dump the activity the rules are also placed in a list.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
index 3c5ea7e..1888092 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
@@ -54,6 +54,7 @@ struct mlxsw_sp_acl {
 	struct mlxsw_afa *afa;
 	const struct mlxsw_sp_acl_ops *ops;
 	struct rhashtable ruleset_ht;
+	struct list_head rules;
 	unsigned long priv[0];
 	/* priv has to be always the last item */
 };
@@ -80,6 +81,7 @@ struct mlxsw_sp_acl_ruleset {
 
 struct mlxsw_sp_acl_rule {
 	struct rhash_head ht_node; /* Member of rule HT */
+	struct list_head list;
 	unsigned long cookie; /* HT key */
 	struct mlxsw_sp_acl_ruleset *ruleset;
 	struct mlxsw_sp_acl_rule_info *rulei;
@@ -422,6 +424,7 @@ int mlxsw_sp_acl_rule_add(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		goto err_rhashtable_insert;
 
+	list_add_tail(&rule->list, &mlxsw_sp->acl->rules);
 	return 0;
 
 err_rhashtable_insert:
@@ -435,6 +438,7 @@ void mlxsw_sp_acl_rule_del(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_acl_ruleset *ruleset = rule->ruleset;
 	const struct mlxsw_sp_acl_profile_ops *ops = ruleset->ht_key.ops;
 
+	list_del(&rule->list);
 	rhashtable_remove_fast(&ruleset->rule_ht, &rule->ht_node,
 			       mlxsw_sp_acl_rule_ht_params);
 	ops->rule_del(mlxsw_sp, rule->priv);
@@ -570,6 +574,7 @@ int mlxsw_sp_acl_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		goto err_rhashtable_init;
 
+	INIT_LIST_HEAD(&acl->rules);
 	err = acl_ops->init(mlxsw_sp, acl->priv);
 	if (err)
 		goto err_acl_ops_init;
@@ -594,6 +599,7 @@ void mlxsw_sp_acl_fini(struct mlxsw_sp *mlxsw_sp)
 	const struct mlxsw_sp_acl_ops *acl_ops = acl->ops;
 
 	acl_ops->fini(mlxsw_sp, acl->priv);
+	WARN_ON(!list_empty(&acl->rules));
 	rhashtable_destroy(&acl->ruleset_ht);
 	mlxsw_afa_destroy(acl->afa);
 	mlxsw_afk_destroy(acl->afk);
-- 
2.7.4
