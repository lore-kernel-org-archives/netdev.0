From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/3] mlxsw: spectrum_acl: Propagate errors from mlxsw_afa_block_jump/continue
Date: Mon, 25 Sep 2017 10:58:20 +0200
Message-ID: <20170925085822.1358-2-jiri@resnulli.us>
References: <20170925085822.1358-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36713 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932342AbdIYI6Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 04:58:25 -0400
Received: by mail-wm0-f65.google.com with SMTP id r136so6536792wmf.3
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 01:58:24 -0700 (PDT)
In-Reply-To: <20170925085822.1358-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Propagate error instead of doing WARN_ON right away.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c    | 14 ++++++++------
 .../net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h    |  4 ++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h             |  6 +++---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c         | 10 +++++-----
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c    |  6 +++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c      |  4 +++-
 6 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
index ab3ffe7a..bc55d0e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
@@ -399,23 +399,25 @@ u32 mlxsw_afa_block_first_set_kvdl_index(struct mlxsw_afa_block *block)
 }
 EXPORT_SYMBOL(mlxsw_afa_block_first_set_kvdl_index);
 
-void mlxsw_afa_block_continue(struct mlxsw_afa_block *block)
+int mlxsw_afa_block_continue(struct mlxsw_afa_block *block)
 {
-	if (WARN_ON(block->finished))
-		return;
+	if (block->finished)
+		return -EINVAL;
 	mlxsw_afa_set_goto_set(block->cur_set,
 			       MLXSW_AFA_SET_GOTO_BINDING_CMD_NONE, 0);
 	block->finished = true;
+	return 0;
 }
 EXPORT_SYMBOL(mlxsw_afa_block_continue);
 
-void mlxsw_afa_block_jump(struct mlxsw_afa_block *block, u16 group_id)
+int mlxsw_afa_block_jump(struct mlxsw_afa_block *block, u16 group_id)
 {
-	if (WARN_ON(block->finished))
-		return;
+	if (block->finished)
+		return -EINVAL;
 	mlxsw_afa_set_goto_set(block->cur_set,
 			       MLXSW_AFA_SET_GOTO_BINDING_CMD_JUMP, group_id);
 	block->finished = true;
+	return 0;
 }
 EXPORT_SYMBOL(mlxsw_afa_block_jump);
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
index 501819c..06b0be4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
@@ -57,8 +57,8 @@ void mlxsw_afa_block_destroy(struct mlxsw_afa_block *block);
 int mlxsw_afa_block_commit(struct mlxsw_afa_block *block);
 char *mlxsw_afa_block_first_set(struct mlxsw_afa_block *block);
 u32 mlxsw_afa_block_first_set_kvdl_index(struct mlxsw_afa_block *block);
-void mlxsw_afa_block_continue(struct mlxsw_afa_block *block);
-void mlxsw_afa_block_jump(struct mlxsw_afa_block *block, u16 group_id);
+int mlxsw_afa_block_continue(struct mlxsw_afa_block *block);
+int mlxsw_afa_block_jump(struct mlxsw_afa_block *block, u16 group_id);
 int mlxsw_afa_block_append_drop(struct mlxsw_afa_block *block);
 int mlxsw_afa_block_append_trap(struct mlxsw_afa_block *block, u16 trap_id);
 int mlxsw_afa_block_append_fwd(struct mlxsw_afa_block *block,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index d06f7fe..ae67e60 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -470,9 +470,9 @@ void mlxsw_sp_acl_rulei_keymask_buf(struct mlxsw_sp_acl_rule_info *rulei,
 				    enum mlxsw_afk_element element,
 				    const char *key_value,
 				    const char *mask_value, unsigned int len);
-void mlxsw_sp_acl_rulei_act_continue(struct mlxsw_sp_acl_rule_info *rulei);
-void mlxsw_sp_acl_rulei_act_jump(struct mlxsw_sp_acl_rule_info *rulei,
-				 u16 group_id);
+int mlxsw_sp_acl_rulei_act_continue(struct mlxsw_sp_acl_rule_info *rulei);
+int mlxsw_sp_acl_rulei_act_jump(struct mlxsw_sp_acl_rule_info *rulei,
+				u16 group_id);
 int mlxsw_sp_acl_rulei_act_drop(struct mlxsw_sp_acl_rule_info *rulei);
 int mlxsw_sp_acl_rulei_act_trap(struct mlxsw_sp_acl_rule_info *rulei);
 int mlxsw_sp_acl_rulei_act_fwd(struct mlxsw_sp *mlxsw_sp,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
index eede75f..93dcd31 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
@@ -378,15 +378,15 @@ void mlxsw_sp_acl_rulei_keymask_buf(struct mlxsw_sp_acl_rule_info *rulei,
 				 key_value, mask_value, len);
 }
 
-void mlxsw_sp_acl_rulei_act_continue(struct mlxsw_sp_acl_rule_info *rulei)
+int mlxsw_sp_acl_rulei_act_continue(struct mlxsw_sp_acl_rule_info *rulei)
 {
-	mlxsw_afa_block_continue(rulei->act_block);
+	return mlxsw_afa_block_continue(rulei->act_block);
 }
 
-void mlxsw_sp_acl_rulei_act_jump(struct mlxsw_sp_acl_rule_info *rulei,
-				 u16 group_id)
+int mlxsw_sp_acl_rulei_act_jump(struct mlxsw_sp_acl_rule_info *rulei,
+				u16 group_id)
 {
-	mlxsw_afa_block_jump(rulei->act_block, group_id);
+	return mlxsw_afa_block_jump(rulei->act_block, group_id);
 }
 
 int mlxsw_sp_acl_rulei_act_drop(struct mlxsw_sp_acl_rule_info *rulei)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
index 50b40de..7e8284b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
@@ -608,7 +608,10 @@ mlxsw_sp_acl_tcam_region_catchall_add(struct mlxsw_sp *mlxsw_sp,
 		goto err_rulei_create;
 	}
 
-	mlxsw_sp_acl_rulei_act_continue(rulei);
+	err = mlxsw_sp_acl_rulei_act_continue(rulei);
+	if (WARN_ON(err))
+		goto err_rulei_act_continue;
+
 	err = mlxsw_sp_acl_rulei_commit(rulei);
 	if (err)
 		goto err_rulei_commit;
@@ -623,6 +626,7 @@ mlxsw_sp_acl_tcam_region_catchall_add(struct mlxsw_sp *mlxsw_sp,
 
 err_rule_insert:
 err_rulei_commit:
+err_rulei_act_continue:
 	mlxsw_sp_acl_rulei_destroy(rulei);
 err_rulei_create:
 	parman_item_remove(region->parman, parman_prio, parman_item);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index 8aace9a..f1cedcc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -84,7 +84,9 @@ static int mlxsw_sp_flower_parse_actions(struct mlxsw_sp *mlxsw_sp,
 				return PTR_ERR(ruleset);
 
 			group_id = mlxsw_sp_acl_ruleset_group_id(ruleset);
-			mlxsw_sp_acl_rulei_act_jump(rulei, group_id);
+			err = mlxsw_sp_acl_rulei_act_jump(rulei, group_id);
+			if (err)
+				return err;
 		} else if (is_tcf_mirred_egress_redirect(a)) {
 			int ifindex = tcf_mirred_ifindex(a);
 			struct net_device *out_dev;
-- 
2.9.5
