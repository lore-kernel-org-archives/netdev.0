From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/8] mlxsw: spectrum: Implement action to set FID
Date: Tue, 18 Apr 2017 16:55:32 +0200
Message-ID: <1492527338-13298-3-git-send-email-jiri@resnulli.us>
References: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34585 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753401AbdDROzn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 10:55:43 -0400
Received: by mail-wm0-f66.google.com with SMTP id z129so12635628wmb.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 07:55:43 -0700 (PDT)
In-Reply-To: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Implement part of multipurpose Virtual Router and Forwarding Domain
Action that takes care of setting up FID. We need to use it to be able
to forward packets using ACL action when no FID is associated on RX.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 .../mellanox/mlxsw/core_acl_flex_actions.c         | 44 ++++++++++++++++++++++
 .../mellanox/mlxsw/core_acl_flex_actions.h         |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  3 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c |  7 ++++
 4 files changed, 55 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
index a984c36..46304ff 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
@@ -811,3 +811,47 @@ int mlxsw_afa_block_append_counter(struct mlxsw_afa_block *block,
 	return 0;
 }
 EXPORT_SYMBOL(mlxsw_afa_block_append_counter);
+
+/* Virtual Router and Forwarding Domain Action
+ * -------------------------------------------
+ * Virtual Switch action is used for manipulate the Virtual Router (VR),
+ * MPLS label space and the Forwarding Identifier (FID).
+ */
+
+#define MLXSW_AFA_VIRFWD_CODE 0x0E
+#define MLXSW_AFA_VIRFWD_SIZE 1
+
+enum mlxsw_afa_virfwd_fid_cmd {
+	/* Do nothing */
+	MLXSW_AFA_VIRFWD_FID_CMD_NOOP,
+	/* Set the Forwarding Identifier (FID) to fid */
+	MLXSW_AFA_VIRFWD_FID_CMD_SET,
+};
+
+/* afa_virfwd_fid_cmd */
+MLXSW_ITEM32(afa, virfwd, fid_cmd, 0x08, 29, 3);
+
+/* afa_virfwd_fid
+ * The FID value.
+ */
+MLXSW_ITEM32(afa, virfwd, fid, 0x08, 0, 16);
+
+static inline void mlxsw_afa_virfwd_pack(char *payload,
+					 enum mlxsw_afa_virfwd_fid_cmd fid_cmd,
+					 u16 fid)
+{
+	mlxsw_afa_virfwd_fid_cmd_set(payload, fid_cmd);
+	mlxsw_afa_virfwd_fid_set(payload, fid);
+}
+
+int mlxsw_afa_block_append_fid_set(struct mlxsw_afa_block *block, u16 fid)
+{
+	char *act = mlxsw_afa_block_append_action(block,
+						  MLXSW_AFA_VIRFWD_CODE,
+						  MLXSW_AFA_VIRFWD_SIZE);
+	if (!act)
+		return -ENOBUFS;
+	mlxsw_afa_virfwd_pack(act, MLXSW_AFA_VIRFWD_FID_CMD_SET, fid);
+	return 0;
+}
+EXPORT_SYMBOL(mlxsw_afa_block_append_fid_set);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
index a03362c..bd8b91d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
@@ -66,5 +66,6 @@ int mlxsw_afa_block_append_vlan_modify(struct mlxsw_afa_block *block,
 				       u16 vid, u8 pcp, u8 et);
 int mlxsw_afa_block_append_counter(struct mlxsw_afa_block *block,
 				   u32 counter_index);
+int mlxsw_afa_block_append_fid_set(struct mlxsw_afa_block *block, u16 fid);
 
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index c245e4c..3d32b15 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -661,6 +661,9 @@ int mlxsw_sp_acl_rulei_act_vlan(struct mlxsw_sp *mlxsw_sp,
 				u32 action, u16 vid, u16 proto, u8 prio);
 int mlxsw_sp_acl_rulei_act_count(struct mlxsw_sp *mlxsw_sp,
 				 struct mlxsw_sp_acl_rule_info *rulei);
+int mlxsw_sp_acl_rulei_act_fid_set(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_acl_rule_info *rulei,
+				   u16 fid);
 
 struct mlxsw_sp_acl_rule;
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
index d3b791f..317f7b1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
@@ -403,6 +403,13 @@ int mlxsw_sp_acl_rulei_act_count(struct mlxsw_sp *mlxsw_sp,
 					      rulei->counter_index);
 }
 
+int mlxsw_sp_acl_rulei_act_fid_set(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_acl_rule_info *rulei,
+				   u16 fid)
+{
+	return mlxsw_afa_block_append_fid_set(rulei->act_block, fid);
+}
+
 struct mlxsw_sp_acl_rule *
 mlxsw_sp_acl_rule_create(struct mlxsw_sp *mlxsw_sp,
 			 struct mlxsw_sp_acl_ruleset *ruleset,
-- 
2.7.4
