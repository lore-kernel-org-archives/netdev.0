From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/13] mlxsw: acl: Introduce mcrouter ACL action
Date: Tue, 19 Sep 2017 10:00:10 +0200
Message-ID: <20170919080020.5870-4-jiri@resnulli.us>
References: <20170919080020.5870-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:38039 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751586AbdISIA0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 04:00:26 -0400
Received: by mail-wm0-f68.google.com with SMTP id x17so3032790wmd.5
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 01:00:25 -0700 (PDT)
In-Reply-To: <20170919080020.5870-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The Spectrum multicast forwarding is done using an ACL action. Add the
mcrouter ACL action that will be used to offload the multicast router
logic.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../mellanox/mlxsw/core_acl_flex_actions.c         | 71 ++++++++++++++++++++++
 .../mellanox/mlxsw/core_acl_flex_actions.h         |  3 +
 2 files changed, 74 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
index 5ae1101..65a32d7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
@@ -891,3 +891,74 @@ int mlxsw_afa_block_append_fid_set(struct mlxsw_afa_block *block, u16 fid)
 	return 0;
 }
 EXPORT_SYMBOL(mlxsw_afa_block_append_fid_set);
+
+/* MC Routing Action
+ * -----------------
+ * The Multicast router action. Can be used by RMFT_V2 - Router Multicast
+ * Forwarding Table Version 2 Register.
+ */
+
+#define MLXSW_AFA_MCROUTER_CODE 0x10
+#define MLXSW_AFA_MCROUTER_SIZE 2
+
+enum mlxsw_afa_mcrouter_rpf_action {
+	MLXSW_AFA_MCROUTER_RPF_ACTION_NOP,
+	MLXSW_AFA_MCROUTER_RPF_ACTION_TRAP,
+	MLXSW_AFA_MCROUTER_RPF_ACTION_DISCARD_ERROR,
+};
+
+/* afa_mcrouter_rpf_action */
+MLXSW_ITEM32(afa, mcrouter, rpf_action, 0x00, 28, 3);
+
+/* afa_mcrouter_expected_irif */
+MLXSW_ITEM32(afa, mcrouter, expected_irif, 0x00, 0, 16);
+
+/* afa_mcrouter_min_mtu */
+MLXSW_ITEM32(afa, mcrouter, min_mtu, 0x08, 0, 16);
+
+enum mlxsw_afa_mrouter_vrmid {
+	MLXSW_AFA_MCROUTER_VRMID_INVALID,
+	MLXSW_AFA_MCROUTER_VRMID_VALID
+};
+
+/* afa_mcrouter_vrmid
+ * Valid RMID: rigr_rmid_index is used as RMID
+ */
+MLXSW_ITEM32(afa, mcrouter, vrmid, 0x0C, 31, 1);
+
+/* afa_mcrouter_rigr_rmid_index
+ * When the vrmid field is set to invalid, the field is used as pointer to
+ * Router Interface Group (RIGR) Table in the KVD linear.
+ * When the vrmid is set to valid, the field is used as RMID index, ranged
+ * from 0 to max_mid - 1. The index is to the Port Group Table.
+ */
+MLXSW_ITEM32(afa, mcrouter, rigr_rmid_index, 0x0C, 0, 24);
+
+static inline void
+mlxsw_afa_mcrouter_pack(char *payload,
+			enum mlxsw_afa_mcrouter_rpf_action rpf_action,
+			u16 expected_irif, u16 min_mtu,
+			enum mlxsw_afa_mrouter_vrmid vrmid, u32 rigr_rmid_index)
+
+{
+	mlxsw_afa_mcrouter_rpf_action_set(payload, rpf_action);
+	mlxsw_afa_mcrouter_expected_irif_set(payload, expected_irif);
+	mlxsw_afa_mcrouter_min_mtu_set(payload, min_mtu);
+	mlxsw_afa_mcrouter_vrmid_set(payload, vrmid);
+	mlxsw_afa_mcrouter_rigr_rmid_index_set(payload, rigr_rmid_index);
+}
+
+int mlxsw_afa_block_append_mcrouter(struct mlxsw_afa_block *block,
+				    u16 expected_irif, u16 min_mtu,
+				    bool rmid_valid, u32 kvdl_index)
+{
+	char *act = mlxsw_afa_block_append_action(block,
+						  MLXSW_AFA_MCROUTER_CODE,
+						  MLXSW_AFA_MCROUTER_SIZE);
+	if (!act)
+		return -ENOBUFS;
+	mlxsw_afa_mcrouter_pack(act, MLXSW_AFA_MCROUTER_RPF_ACTION_TRAP,
+				expected_irif, min_mtu, rmid_valid, kvdl_index);
+	return 0;
+}
+EXPORT_SYMBOL(mlxsw_afa_block_append_mcrouter);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
index f99c341..5dbb31f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
@@ -68,5 +68,8 @@ int mlxsw_afa_block_append_vlan_modify(struct mlxsw_afa_block *block,
 int mlxsw_afa_block_append_counter(struct mlxsw_afa_block *block,
 				   u32 counter_index);
 int mlxsw_afa_block_append_fid_set(struct mlxsw_afa_block *block, u16 fid);
+int mlxsw_afa_block_append_mcrouter(struct mlxsw_afa_block *block,
+				    u16 expected_irif, u16 min_mtu,
+				    bool rmid_valid, u32 kvdl_index);
 
 #endif
-- 
2.9.5
