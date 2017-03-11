From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/9] mlxsw: spectrum_acl_tcam: Add support for retrieving TCAM entry activity
Date: Sat, 11 Mar 2017 09:42:54 +0100
Message-ID: <1489221779-3807-5-git-send-email-jiri@resnulli.us>
References: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, mlxsw@mellanox.com,
        idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33588 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752722AbdCKInI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 03:43:08 -0500
Received: by mail-wr0-f196.google.com with SMTP id g10so14059125wrg.0
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 00:43:07 -0800 (PST)
In-Reply-To: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for retrieving TCAM entry activity. In order to support ACL
rule activity corresponding TCAM entry should be queried.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  2 ++
 .../ethernet/mellanox/mlxsw/spectrum_acl_tcam.c    | 42 ++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index b0500b8..26718b1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -607,6 +607,8 @@ struct mlxsw_sp_acl_profile_ops {
 			void *ruleset_priv, void *rule_priv,
 			struct mlxsw_sp_acl_rule_info *rulei);
 	void (*rule_del)(struct mlxsw_sp *mlxsw_sp, void *rule_priv);
+	int (*rule_activity_get)(struct mlxsw_sp *mlxsw_sp, void *rule_priv,
+				 bool *activity);
 };
 
 struct mlxsw_sp_acl_ops {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
index 6858439..3a24289 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
@@ -561,6 +561,24 @@ mlxsw_sp_acl_tcam_region_entry_remove(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ptce2), ptce2_pl);
 }
 
+static int
+mlxsw_sp_acl_tcam_region_entry_activity_get(struct mlxsw_sp *mlxsw_sp,
+					    struct mlxsw_sp_acl_tcam_region *region,
+					    unsigned int offset,
+					    bool *activity)
+{
+	char ptce2_pl[MLXSW_REG_PTCE2_LEN];
+	int err;
+
+	mlxsw_reg_ptce2_pack(ptce2_pl, true, MLXSW_REG_PTCE2_OP_QUERY_CLEAR_ON_READ,
+			     region->tcam_region_info, offset);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ptce2), ptce2_pl);
+	if (err)
+		return err;
+	*activity = mlxsw_reg_ptce2_a_get(ptce2_pl);
+	return 0;
+}
+
 #define MLXSW_SP_ACL_TCAM_CATCHALL_PRIO (~0U)
 
 static int
@@ -940,6 +958,19 @@ static void mlxsw_sp_acl_tcam_entry_del(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_acl_tcam_chunk_put(mlxsw_sp, chunk);
 }
 
+static int
+mlxsw_sp_acl_tcam_entry_activity_get(struct mlxsw_sp *mlxsw_sp,
+				     struct mlxsw_sp_acl_tcam_entry *entry,
+				     bool *activity)
+{
+	struct mlxsw_sp_acl_tcam_chunk *chunk = entry->chunk;
+	struct mlxsw_sp_acl_tcam_region *region = chunk->region;
+
+	return mlxsw_sp_acl_tcam_region_entry_activity_get(mlxsw_sp, region,
+							   entry->parman_item.index,
+							   activity);
+}
+
 static const enum mlxsw_afk_element mlxsw_sp_acl_tcam_pattern_ipv4[] = {
 	MLXSW_AFK_ELEMENT_SRC_SYS_PORT,
 	MLXSW_AFK_ELEMENT_DMAC,
@@ -1048,6 +1079,16 @@ mlxsw_sp_acl_tcam_flower_rule_del(struct mlxsw_sp *mlxsw_sp, void *rule_priv)
 	mlxsw_sp_acl_tcam_entry_del(mlxsw_sp, &rule->entry);
 }
 
+static int
+mlxsw_sp_acl_tcam_flower_rule_activity_get(struct mlxsw_sp *mlxsw_sp,
+					   void *rule_priv, bool *activity)
+{
+	struct mlxsw_sp_acl_tcam_flower_rule *rule = rule_priv;
+
+	return mlxsw_sp_acl_tcam_entry_activity_get(mlxsw_sp, &rule->entry,
+						    activity);
+}
+
 static const struct mlxsw_sp_acl_profile_ops mlxsw_sp_acl_tcam_flower_ops = {
 	.ruleset_priv_size	= sizeof(struct mlxsw_sp_acl_tcam_flower_ruleset),
 	.ruleset_add		= mlxsw_sp_acl_tcam_flower_ruleset_add,
@@ -1057,6 +1098,7 @@ static const struct mlxsw_sp_acl_profile_ops mlxsw_sp_acl_tcam_flower_ops = {
 	.rule_priv_size		= sizeof(struct mlxsw_sp_acl_tcam_flower_rule),
 	.rule_add		= mlxsw_sp_acl_tcam_flower_rule_add,
 	.rule_del		= mlxsw_sp_acl_tcam_flower_rule_del,
+	.rule_activity_get	= mlxsw_sp_acl_tcam_flower_rule_activity_get,
 };
 
 static const struct mlxsw_sp_acl_profile_ops *
-- 
2.7.4
