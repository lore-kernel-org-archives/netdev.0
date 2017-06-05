From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/6] acl: Introduce ACL trap action
Date: Mon,  5 Jun 2017 16:38:31 +0200
Message-ID: <20170605143832.7025-6-jiri@resnulli.us>
References: <20170605143832.7025-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, alexander.h.duyck@intel.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36133 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751272AbdFEOis (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 10:38:48 -0400
Received: by mail-wr0-f196.google.com with SMTP id e23so6494670wre.3
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 07:38:42 -0700 (PDT)
In-Reply-To: <20170605143832.7025-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Use trap/discard flex action to implement trap.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Yotam Gigi <yotamg@mellanox.com>
---
 .../mellanox/mlxsw/core_acl_flex_actions.c         | 40 ++++++++++++++++++++--
 .../mellanox/mlxsw/core_acl_flex_actions.h         |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c |  5 +++
 4 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
index 46304ff..5ae1101 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
@@ -40,6 +40,7 @@
 #include <linux/list.h>
 
 #include "item.h"
+#include "trap.h"
 #include "core_acl_flex_actions.h"
 
 enum mlxsw_afa_set_type {
@@ -662,6 +663,16 @@ EXPORT_SYMBOL(mlxsw_afa_block_append_vlan_modify);
 #define MLXSW_AFA_TRAPDISC_CODE 0x03
 #define MLXSW_AFA_TRAPDISC_SIZE 1
 
+enum mlxsw_afa_trapdisc_trap_action {
+	MLXSW_AFA_TRAPDISC_TRAP_ACTION_NOP = 0,
+	MLXSW_AFA_TRAPDISC_TRAP_ACTION_TRAP = 2,
+};
+
+/* afa_trapdisc_trap_action
+ * Trap Action.
+ */
+MLXSW_ITEM32(afa, trapdisc, trap_action, 0x00, 24, 4);
+
 enum mlxsw_afa_trapdisc_forward_action {
 	MLXSW_AFA_TRAPDISC_FORWARD_ACTION_DISCARD = 3,
 };
@@ -671,11 +682,20 @@ enum mlxsw_afa_trapdisc_forward_action {
  */
 MLXSW_ITEM32(afa, trapdisc, forward_action, 0x00, 0, 4);
 
+/* afa_trapdisc_trap_id
+ * Trap ID to configure.
+ */
+MLXSW_ITEM32(afa, trapdisc, trap_id, 0x04, 0, 9);
+
 static inline void
 mlxsw_afa_trapdisc_pack(char *payload,
-			enum mlxsw_afa_trapdisc_forward_action forward_action)
+			enum mlxsw_afa_trapdisc_trap_action trap_action,
+			enum mlxsw_afa_trapdisc_forward_action forward_action,
+			u16 trap_id)
 {
+	mlxsw_afa_trapdisc_trap_action_set(payload, trap_action);
 	mlxsw_afa_trapdisc_forward_action_set(payload, forward_action);
+	mlxsw_afa_trapdisc_trap_id_set(payload, trap_id);
 }
 
 int mlxsw_afa_block_append_drop(struct mlxsw_afa_block *block)
@@ -686,11 +706,27 @@ int mlxsw_afa_block_append_drop(struct mlxsw_afa_block *block)
 
 	if (!act)
 		return -ENOBUFS;
-	mlxsw_afa_trapdisc_pack(act, MLXSW_AFA_TRAPDISC_FORWARD_ACTION_DISCARD);
+	mlxsw_afa_trapdisc_pack(act, MLXSW_AFA_TRAPDISC_TRAP_ACTION_NOP,
+				MLXSW_AFA_TRAPDISC_FORWARD_ACTION_DISCARD, 0);
 	return 0;
 }
 EXPORT_SYMBOL(mlxsw_afa_block_append_drop);
 
+int mlxsw_afa_block_append_trap(struct mlxsw_afa_block *block)
+{
+	char *act = mlxsw_afa_block_append_action(block,
+						  MLXSW_AFA_TRAPDISC_CODE,
+						  MLXSW_AFA_TRAPDISC_SIZE);
+
+	if (!act)
+		return -ENOBUFS;
+	mlxsw_afa_trapdisc_pack(act, MLXSW_AFA_TRAPDISC_TRAP_ACTION_TRAP,
+				MLXSW_AFA_TRAPDISC_FORWARD_ACTION_DISCARD,
+				MLXSW_TRAP_ID_ACL0);
+	return 0;
+}
+EXPORT_SYMBOL(mlxsw_afa_block_append_trap);
+
 /* Forwarding Action
  * -----------------
  * Forwarding Action can be used to implement Policy Based Switching (PBS)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
index bd8b91d..f99c341 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
@@ -60,6 +60,7 @@ u32 mlxsw_afa_block_first_set_kvdl_index(struct mlxsw_afa_block *block);
 void mlxsw_afa_block_continue(struct mlxsw_afa_block *block);
 void mlxsw_afa_block_jump(struct mlxsw_afa_block *block, u16 group_id);
 int mlxsw_afa_block_append_drop(struct mlxsw_afa_block *block);
+int mlxsw_afa_block_append_trap(struct mlxsw_afa_block *block);
 int mlxsw_afa_block_append_fwd(struct mlxsw_afa_block *block,
 			       u8 local_port, bool in_port);
 int mlxsw_afa_block_append_vlan_modify(struct mlxsw_afa_block *block,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 99760fd..4a7a39a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -460,6 +460,7 @@ void mlxsw_sp_acl_rulei_act_continue(struct mlxsw_sp_acl_rule_info *rulei);
 void mlxsw_sp_acl_rulei_act_jump(struct mlxsw_sp_acl_rule_info *rulei,
 				 u16 group_id);
 int mlxsw_sp_acl_rulei_act_drop(struct mlxsw_sp_acl_rule_info *rulei);
+int mlxsw_sp_acl_rulei_act_trap(struct mlxsw_sp_acl_rule_info *rulei);
 int mlxsw_sp_acl_rulei_act_fwd(struct mlxsw_sp *mlxsw_sp,
 			       struct mlxsw_sp_acl_rule_info *rulei,
 			       struct net_device *out_dev);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
index 1da889a..01a1501 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
@@ -347,6 +347,11 @@ int mlxsw_sp_acl_rulei_act_drop(struct mlxsw_sp_acl_rule_info *rulei)
 	return mlxsw_afa_block_append_drop(rulei->act_block);
 }
 
+int mlxsw_sp_acl_rulei_act_trap(struct mlxsw_sp_acl_rule_info *rulei)
+{
+	return mlxsw_afa_block_append_trap(rulei->act_block);
+}
+
 int mlxsw_sp_acl_rulei_act_fwd(struct mlxsw_sp *mlxsw_sp,
 			       struct mlxsw_sp_acl_rule_info *rulei,
 			       struct net_device *out_dev)
-- 
2.9.3
