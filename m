From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 8/9] mlxsw: spectrum: Add support for counters on TCAM entries
Date: Sat, 11 Mar 2017 09:42:58 +0100
Message-ID: <1489221779-3807-9-git-send-email-jiri@resnulli.us>
References: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, mlxsw@mellanox.com,
        idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34823 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755475AbdCKInN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 03:43:13 -0500
Received: by mail-wr0-f196.google.com with SMTP id u108so14069852wrb.2
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 00:43:11 -0800 (PST)
In-Reply-To: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for packets and byte statistics on TCAM entries. The counters
are allocated from the generic flow counters pool.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  7 +++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c | 35 ++++++++++++++++++++++
 2 files changed, 42 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 26718b1..b4f32a6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -588,6 +588,8 @@ struct mlxsw_sp_acl_rule_info {
 	unsigned int priority;
 	struct mlxsw_afk_element_values values;
 	struct mlxsw_afa_block *act_block;
+	unsigned int counter_index;
+	bool counter_valid;
 };
 
 enum mlxsw_sp_acl_profile {
@@ -652,6 +654,8 @@ int mlxsw_sp_acl_rulei_act_fwd(struct mlxsw_sp *mlxsw_sp,
 int mlxsw_sp_acl_rulei_act_vlan(struct mlxsw_sp *mlxsw_sp,
 				struct mlxsw_sp_acl_rule_info *rulei,
 				u32 action, u16 vid, u16 proto, u8 prio);
+int mlxsw_sp_acl_rulei_act_count(struct mlxsw_sp *mlxsw_sp,
+				 struct mlxsw_sp_acl_rule_info *rulei);
 
 struct mlxsw_sp_acl_rule;
 
@@ -671,6 +675,9 @@ mlxsw_sp_acl_rule_lookup(struct mlxsw_sp *mlxsw_sp,
 			 unsigned long cookie);
 struct mlxsw_sp_acl_rule_info *
 mlxsw_sp_acl_rule_rulei(struct mlxsw_sp_acl_rule *rule);
+int mlxsw_sp_acl_rule_get_stats(struct mlxsw_sp *mlxsw_sp,
+				struct mlxsw_sp_acl_rule *rule,
+				u64 *packets, u64 *bytes, u64 *last_use);
 
 int mlxsw_sp_acl_init(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_acl_fini(struct mlxsw_sp *mlxsw_sp);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
index d2f6cbb..87d0111 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
@@ -247,6 +247,27 @@ void mlxsw_sp_acl_ruleset_put(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_acl_ruleset_ref_dec(mlxsw_sp, ruleset);
 }
 
+static int
+mlxsw_sp_acl_rulei_counter_alloc(struct mlxsw_sp *mlxsw_sp,
+				 struct mlxsw_sp_acl_rule_info *rulei)
+{
+	int err;
+
+	err = mlxsw_sp_flow_counter_alloc(mlxsw_sp, &rulei->counter_index);
+	if (err)
+		return err;
+	rulei->counter_valid = true;
+	return 0;
+}
+
+static void
+mlxsw_sp_acl_rulei_counter_free(struct mlxsw_sp *mlxsw_sp,
+				struct mlxsw_sp_acl_rule_info *rulei)
+{
+	rulei->counter_valid = false;
+	mlxsw_sp_flow_counter_free(mlxsw_sp, rulei->counter_index);
+}
+
 struct mlxsw_sp_acl_rule_info *
 mlxsw_sp_acl_rulei_create(struct mlxsw_sp_acl *acl)
 {
@@ -373,6 +394,13 @@ int mlxsw_sp_acl_rulei_act_vlan(struct mlxsw_sp *mlxsw_sp,
 	}
 }
 
+int mlxsw_sp_acl_rulei_act_count(struct mlxsw_sp *mlxsw_sp,
+				 struct mlxsw_sp_acl_rule_info *rulei)
+{
+	return mlxsw_afa_block_append_counter(rulei->act_block,
+					      rulei->counter_index);
+}
+
 struct mlxsw_sp_acl_rule *
 mlxsw_sp_acl_rule_create(struct mlxsw_sp *mlxsw_sp,
 			 struct mlxsw_sp_acl_ruleset *ruleset,
@@ -396,8 +424,14 @@ mlxsw_sp_acl_rule_create(struct mlxsw_sp *mlxsw_sp,
 		err = PTR_ERR(rule->rulei);
 		goto err_rulei_create;
 	}
+
+	err = mlxsw_sp_acl_rulei_counter_alloc(mlxsw_sp, rule->rulei);
+	if (err)
+		goto err_counter_alloc;
 	return rule;
 
+err_counter_alloc:
+	mlxsw_sp_acl_rulei_destroy(rule->rulei);
 err_rulei_create:
 	kfree(rule);
 err_alloc:
@@ -410,6 +444,7 @@ void mlxsw_sp_acl_rule_destroy(struct mlxsw_sp *mlxsw_sp,
 {
 	struct mlxsw_sp_acl_ruleset *ruleset = rule->ruleset;
 
+	mlxsw_sp_acl_rulei_counter_free(mlxsw_sp, rule->rulei);
 	mlxsw_sp_acl_rulei_destroy(rule->rulei);
 	kfree(rule);
 	mlxsw_sp_acl_ruleset_ref_dec(mlxsw_sp, ruleset);
-- 
2.7.4
