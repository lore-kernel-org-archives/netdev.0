From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/9] mlxsw: spectrum: Add periodic ACL rule activity update
Date: Sat, 11 Mar 2017 09:42:56 +0100
Message-ID: <1489221779-3807-7-git-send-email-jiri@resnulli.us>
References: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, mlxsw@mellanox.com,
        idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33834 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751788AbdCKInK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 03:43:10 -0500
Received: by mail-wm0-f68.google.com with SMTP id u132so2247475wmg.1
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 00:43:08 -0800 (PST)
In-Reply-To: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Introduce periodic task for dumping the activity status for the ACL
rule TCAM entries. This is done in order to emulate last use statistics.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.comi>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c | 74 +++++++++++++++++++++-
 1 file changed, 73 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
index 1888092..d2f6cbb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
@@ -50,11 +50,17 @@
 #include "spectrum_acl_flex_keys.h"
 
 struct mlxsw_sp_acl {
+	struct mlxsw_sp *mlxsw_sp;
 	struct mlxsw_afk *afk;
 	struct mlxsw_afa *afa;
 	const struct mlxsw_sp_acl_ops *ops;
 	struct rhashtable ruleset_ht;
 	struct list_head rules;
+	struct {
+		struct delayed_work dw;
+		unsigned long interval;	/* ms */
+#define MLXSW_SP_ACL_RULE_ACTIVITY_UPDATE_PERIOD_MS 1000
+	} rule_activity_update;
 	unsigned long priv[0];
 	/* priv has to be always the last item */
 };
@@ -85,6 +91,7 @@ struct mlxsw_sp_acl_rule {
 	unsigned long cookie; /* HT key */
 	struct mlxsw_sp_acl_ruleset *ruleset;
 	struct mlxsw_sp_acl_rule_info *rulei;
+	u64 last_used;
 	unsigned long priv[0];
 	/* priv has to be always the last item */
 };
@@ -459,6 +466,64 @@ mlxsw_sp_acl_rule_rulei(struct mlxsw_sp_acl_rule *rule)
 	return rule->rulei;
 }
 
+static int mlxsw_sp_acl_rule_activity_update(struct mlxsw_sp *mlxsw_sp,
+					     struct mlxsw_sp_acl_rule *rule)
+{
+	struct mlxsw_sp_acl_ruleset *ruleset = rule->ruleset;
+	const struct mlxsw_sp_acl_profile_ops *ops = ruleset->ht_key.ops;
+	bool active;
+	int err;
+
+	err = ops->rule_activity_get(mlxsw_sp, rule->priv, &active);
+	if (err)
+		return err;
+	if (active)
+		rule->last_used = jiffies;
+	return 0;
+}
+
+static int mlxsw_sp_acl_rules_activity_update(struct mlxsw_sp_acl *acl)
+{
+	struct mlxsw_sp_acl_rule *rule;
+	int err;
+
+	/* Protect internal structures from changes */
+	rtnl_lock();
+	list_for_each_entry(rule, &acl->rules, list) {
+		err = mlxsw_sp_acl_rule_activity_update(acl->mlxsw_sp,
+							rule);
+		if (err)
+			goto err_rule_update;
+	}
+	rtnl_unlock();
+	return 0;
+
+err_rule_update:
+	rtnl_unlock();
+	return err;
+}
+
+static void mlxsw_sp_acl_rule_activity_work_schedule(struct mlxsw_sp_acl *acl)
+{
+	unsigned long interval = acl->rule_activity_update.interval;
+
+	mlxsw_core_schedule_dw(&acl->rule_activity_update.dw,
+			       msecs_to_jiffies(interval));
+}
+
+static void mlxsw_sp_acl_rul_activity_update_work(struct work_struct *work)
+{
+	struct mlxsw_sp_acl *acl = container_of(work, struct mlxsw_sp_acl,
+						rule_activity_update.dw.work);
+	int err;
+
+	err = mlxsw_sp_acl_rules_activity_update(acl);
+	if (err)
+		dev_err(acl->mlxsw_sp->bus_info->dev, "Could not update acl activity");
+
+	mlxsw_sp_acl_rule_activity_work_schedule(acl);
+}
+
 #define MLXSW_SP_KDVL_ACT_EXT_SIZE 1
 
 static int mlxsw_sp_act_kvdl_set_add(void *priv, u32 *p_kvdl_index,
@@ -551,7 +616,7 @@ int mlxsw_sp_acl_init(struct mlxsw_sp *mlxsw_sp)
 	if (!acl)
 		return -ENOMEM;
 	mlxsw_sp->acl = acl;
-
+	acl->mlxsw_sp = mlxsw_sp;
 	acl->afk = mlxsw_afk_create(MLXSW_CORE_RES_GET(mlxsw_sp->core,
 						       ACL_FLEX_KEYS),
 				    mlxsw_sp_afk_blocks,
@@ -580,6 +645,12 @@ int mlxsw_sp_acl_init(struct mlxsw_sp *mlxsw_sp)
 		goto err_acl_ops_init;
 
 	acl->ops = acl_ops;
+
+	/* Create the delayed work for the rule activity_update */
+	INIT_DELAYED_WORK(&acl->rule_activity_update.dw,
+			  mlxsw_sp_acl_rul_activity_update_work);
+	acl->rule_activity_update.interval = MLXSW_SP_ACL_RULE_ACTIVITY_UPDATE_PERIOD_MS;
+	mlxsw_core_schedule_dw(&acl->rule_activity_update.dw, 0);
 	return 0;
 
 err_acl_ops_init:
@@ -598,6 +669,7 @@ void mlxsw_sp_acl_fini(struct mlxsw_sp *mlxsw_sp)
 	struct mlxsw_sp_acl *acl = mlxsw_sp->acl;
 	const struct mlxsw_sp_acl_ops *acl_ops = acl->ops;
 
+	cancel_delayed_work_sync(&mlxsw_sp->acl->rule_activity_update.dw);
 	acl_ops->fini(mlxsw_sp, acl->priv);
 	WARN_ON(!list_empty(&acl->rules));
 	rhashtable_destroy(&acl->ruleset_ht);
-- 
2.7.4
