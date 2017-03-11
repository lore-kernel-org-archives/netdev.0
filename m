From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 7/9] mlxsw: spectrum: Add support for Policing and Counting action block
Date: Sat, 11 Mar 2017 09:42:57 +0100
Message-ID: <1489221779-3807-8-git-send-email-jiri@resnulli.us>
References: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, mlxsw@mellanox.com,
        idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36230 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755338AbdCKInL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 03:43:11 -0500
Received: by mail-wr0-f194.google.com with SMTP id l37so14006865wrc.3
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 00:43:10 -0800 (PST)
In-Reply-To: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for Policing and Counting action block. This action block
will be used to bind counter to TCAM entries.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../mellanox/mlxsw/core_acl_flex_actions.c         | 51 ++++++++++++++++++++++
 .../mellanox/mlxsw/core_acl_flex_actions.h         |  2 +
 2 files changed, 53 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
index fe3c6ea1..a984c36 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
@@ -760,3 +760,54 @@ int mlxsw_afa_block_append_fwd(struct mlxsw_afa_block *block,
 	return err;
 }
 EXPORT_SYMBOL(mlxsw_afa_block_append_fwd);
+
+/* Policing and Counting Action
+ * ----------------------------
+ * Policing and Counting action is used for binding policer and counter
+ * to ACL rules.
+ */
+
+#define MLXSW_AFA_POLCNT_CODE 0x08
+#define MLXSW_AFA_POLCNT_SIZE 1
+
+enum mlxsw_afa_polcnt_counter_set_type {
+	/* No count */
+	MLXSW_AFA_POLCNT_COUNTER_SET_TYPE_NO_COUNT = 0x00,
+	/* Count packets and bytes */
+	MLXSW_AFA_POLCNT_COUNTER_SET_TYPE_PACKETS_BYTES = 0x03,
+	/* Count only packets */
+	MLXSW_AFA_POLCNT_COUNTER_SET_TYPE_PACKETS = 0x05,
+};
+
+/* afa_polcnt_counter_set_type
+ * Counter set type for flow counters.
+ */
+MLXSW_ITEM32(afa, polcnt, counter_set_type, 0x04, 24, 8);
+
+/* afa_polcnt_counter_index
+ * Counter index for flow counters.
+ */
+MLXSW_ITEM32(afa, polcnt, counter_index, 0x04, 0, 24);
+
+static inline void
+mlxsw_afa_polcnt_pack(char *payload,
+		      enum mlxsw_afa_polcnt_counter_set_type set_type,
+		      u32 counter_index)
+{
+	mlxsw_afa_polcnt_counter_set_type_set(payload, set_type);
+	mlxsw_afa_polcnt_counter_index_set(payload, counter_index);
+}
+
+int mlxsw_afa_block_append_counter(struct mlxsw_afa_block *block,
+				   u32 counter_index)
+{
+	char *act = mlxsw_afa_block_append_action(block,
+						  MLXSW_AFA_POLCNT_CODE,
+						  MLXSW_AFA_POLCNT_SIZE);
+	if (!act)
+		return -ENOBUFS;
+	mlxsw_afa_polcnt_pack(act, MLXSW_AFA_POLCNT_COUNTER_SET_TYPE_PACKETS_BYTES,
+			      counter_index);
+	return 0;
+}
+EXPORT_SYMBOL(mlxsw_afa_block_append_counter);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
index 6e103ac..a03362c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
@@ -64,5 +64,7 @@ int mlxsw_afa_block_append_fwd(struct mlxsw_afa_block *block,
 			       u8 local_port, bool in_port);
 int mlxsw_afa_block_append_vlan_modify(struct mlxsw_afa_block *block,
 				       u16 vid, u8 pcp, u8 et);
+int mlxsw_afa_block_append_counter(struct mlxsw_afa_block *block,
+				   u32 counter_index);
 
 #endif
-- 
2.7.4
