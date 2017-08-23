From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/5] mlxsw: spectrum_acl: Allow to get group_id value for a ruleset
Date: Wed, 23 Aug 2017 10:08:20 +0200
Message-ID: <20170823080822.14898-3-jiri@resnulli.us>
References: <20170823080652.14847-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34212 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753513AbdHWII2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 04:08:28 -0400
Received: by mail-wm0-f67.google.com with SMTP id r187so1517561wma.1
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 01:08:27 -0700 (PDT)
In-Reply-To: <20170823080652.14847-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

For goto_chain action we need to know group_id of a ruleset to jump to.
Provide infrastructure in order to get it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h          |  2 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c      |  7 +++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c | 15 +++++++++++++++
 3 files changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index de3aef9..1866f69 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -417,6 +417,7 @@ struct mlxsw_sp_acl_profile_ops {
 	int (*ruleset_bind)(struct mlxsw_sp *mlxsw_sp, void *ruleset_priv,
 			    struct net_device *dev, bool ingress);
 	void (*ruleset_unbind)(struct mlxsw_sp *mlxsw_sp, void *ruleset_priv);
+	u16 (*ruleset_group_id)(void *ruleset_priv);
 	size_t rule_priv_size;
 	int (*rule_add)(struct mlxsw_sp *mlxsw_sp,
 			void *ruleset_priv, void *rule_priv,
@@ -445,6 +446,7 @@ mlxsw_sp_acl_ruleset_get(struct mlxsw_sp *mlxsw_sp, struct net_device *dev,
 			 enum mlxsw_sp_acl_profile profile);
 void mlxsw_sp_acl_ruleset_put(struct mlxsw_sp *mlxsw_sp,
 			      struct mlxsw_sp_acl_ruleset *ruleset);
+u16 mlxsw_sp_acl_ruleset_group_id(struct mlxsw_sp_acl_ruleset *ruleset);
 
 struct mlxsw_sp_acl_rule_info *
 mlxsw_sp_acl_rulei_create(struct mlxsw_sp_acl *acl);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
index 8ab331b..ef86f04 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
@@ -267,6 +267,13 @@ void mlxsw_sp_acl_ruleset_put(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_acl_ruleset_ref_dec(mlxsw_sp, ruleset);
 }
 
+u16 mlxsw_sp_acl_ruleset_group_id(struct mlxsw_sp_acl_ruleset *ruleset)
+{
+	const struct mlxsw_sp_acl_profile_ops *ops = ruleset->ht_key.ops;
+
+	return ops->ruleset_group_id(ruleset->priv);
+}
+
 static int
 mlxsw_sp_acl_rulei_counter_alloc(struct mlxsw_sp *mlxsw_sp,
 				 struct mlxsw_sp_acl_rule_info *rulei)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
index bc5173f..50b40de 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
@@ -295,6 +295,12 @@ mlxsw_sp_acl_tcam_group_unbind(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ppbt), ppbt_pl);
 }
 
+static u16
+mlxsw_sp_acl_tcam_group_id(struct mlxsw_sp_acl_tcam_group *group)
+{
+	return group->id;
+}
+
 static unsigned int
 mlxsw_sp_acl_tcam_region_prio(struct mlxsw_sp_acl_tcam_region *region)
 {
@@ -1063,6 +1069,14 @@ mlxsw_sp_acl_tcam_flower_ruleset_unbind(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_acl_tcam_group_unbind(mlxsw_sp, &ruleset->group);
 }
 
+static u16
+mlxsw_sp_acl_tcam_flower_ruleset_group_id(void *ruleset_priv)
+{
+	struct mlxsw_sp_acl_tcam_flower_ruleset *ruleset = ruleset_priv;
+
+	return mlxsw_sp_acl_tcam_group_id(&ruleset->group);
+}
+
 static int
 mlxsw_sp_acl_tcam_flower_rule_add(struct mlxsw_sp *mlxsw_sp,
 				  void *ruleset_priv, void *rule_priv,
@@ -1099,6 +1113,7 @@ static const struct mlxsw_sp_acl_profile_ops mlxsw_sp_acl_tcam_flower_ops = {
 	.ruleset_del		= mlxsw_sp_acl_tcam_flower_ruleset_del,
 	.ruleset_bind		= mlxsw_sp_acl_tcam_flower_ruleset_bind,
 	.ruleset_unbind		= mlxsw_sp_acl_tcam_flower_ruleset_unbind,
+	.ruleset_group_id	= mlxsw_sp_acl_tcam_flower_ruleset_group_id,
 	.rule_priv_size		= sizeof(struct mlxsw_sp_acl_tcam_flower_rule),
 	.rule_add		= mlxsw_sp_acl_tcam_flower_rule_add,
 	.rule_del		= mlxsw_sp_acl_tcam_flower_rule_del,
-- 
2.9.3
