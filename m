From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] mlxsw: spectrum: Add support for vlan modify TC action
Date: Thu,  9 Mar 2017 09:25:19 +0100
Message-ID: <1489047920-3557-2-git-send-email-jiri@resnulli.us>
References: <1489047920-3557-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35395 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753018AbdCIIZZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 03:25:25 -0500
Received: by mail-wm0-f68.google.com with SMTP id z63so9677001wmg.2
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 00:25:24 -0800 (PST)
In-Reply-To: <1489047920-3557-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Add VLAN action offloading. Invoke it from Spectrum flower handler for
"vlan modify" actions.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../mellanox/mlxsw/core_acl_flex_actions.c         | 83 ++++++++++++++++++++++
 .../mellanox/mlxsw/core_acl_flex_actions.h         |  2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  3 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c | 29 ++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  | 10 +++
 include/net/tc_act/tc_vlan.h                       |  5 ++
 6 files changed, 132 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
index 5f337715..fe3c6ea1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
@@ -567,6 +567,89 @@ static char *mlxsw_afa_block_append_action(struct mlxsw_afa_block *block,
 	return oneact + MLXSW_AFA_PAYLOAD_OFFSET;
 }
 
+/* VLAN Action
+ * -----------
+ * VLAN action is used for manipulating VLANs. It can be used to implement QinQ,
+ * VLAN translation, change of PCP bits of the VLAN tag, push, pop as swap VLANs
+ * and more.
+ */
+
+#define MLXSW_AFA_VLAN_CODE 0x02
+#define MLXSW_AFA_VLAN_SIZE 1
+
+enum mlxsw_afa_vlan_vlan_tag_cmd {
+	MLXSW_AFA_VLAN_VLAN_TAG_CMD_NOP,
+	MLXSW_AFA_VLAN_VLAN_TAG_CMD_PUSH_TAG,
+	MLXSW_AFA_VLAN_VLAN_TAG_CMD_POP_TAG,
+};
+
+enum mlxsw_afa_vlan_cmd {
+	MLXSW_AFA_VLAN_CMD_NOP,
+	MLXSW_AFA_VLAN_CMD_SET_OUTER,
+	MLXSW_AFA_VLAN_CMD_SET_INNER,
+	MLXSW_AFA_VLAN_CMD_COPY_OUTER_TO_INNER,
+	MLXSW_AFA_VLAN_CMD_COPY_INNER_TO_OUTER,
+	MLXSW_AFA_VLAN_CMD_SWAP,
+};
+
+/* afa_vlan_vlan_tag_cmd
+ * Tag command: push, pop, nop VLAN header.
+ */
+MLXSW_ITEM32(afa, vlan, vlan_tag_cmd, 0x00, 29, 3);
+
+/* afa_vlan_vid_cmd */
+MLXSW_ITEM32(afa, vlan, vid_cmd, 0x04, 29, 3);
+
+/* afa_vlan_vid */
+MLXSW_ITEM32(afa, vlan, vid, 0x04, 0, 12);
+
+/* afa_vlan_ethertype_cmd */
+MLXSW_ITEM32(afa, vlan, ethertype_cmd, 0x08, 29, 3);
+
+/* afa_vlan_ethertype
+ * Index to EtherTypes in Switch VLAN EtherType Register (SVER).
+ */
+MLXSW_ITEM32(afa, vlan, ethertype, 0x08, 24, 3);
+
+/* afa_vlan_pcp_cmd */
+MLXSW_ITEM32(afa, vlan, pcp_cmd, 0x08, 13, 3);
+
+/* afa_vlan_pcp */
+MLXSW_ITEM32(afa, vlan, pcp, 0x08, 8, 3);
+
+static inline void
+mlxsw_afa_vlan_pack(char *payload,
+		    enum mlxsw_afa_vlan_vlan_tag_cmd vlan_tag_cmd,
+		    enum mlxsw_afa_vlan_cmd vid_cmd, u16 vid,
+		    enum mlxsw_afa_vlan_cmd pcp_cmd, u8 pcp,
+		    enum mlxsw_afa_vlan_cmd ethertype_cmd, u8 ethertype)
+{
+	mlxsw_afa_vlan_vlan_tag_cmd_set(payload, vlan_tag_cmd);
+	mlxsw_afa_vlan_vid_cmd_set(payload, vid_cmd);
+	mlxsw_afa_vlan_vid_set(payload, vid);
+	mlxsw_afa_vlan_pcp_cmd_set(payload, pcp_cmd);
+	mlxsw_afa_vlan_pcp_set(payload, pcp);
+	mlxsw_afa_vlan_ethertype_cmd_set(payload, ethertype_cmd);
+	mlxsw_afa_vlan_ethertype_set(payload, ethertype);
+}
+
+int mlxsw_afa_block_append_vlan_modify(struct mlxsw_afa_block *block,
+				       u16 vid, u8 pcp, u8 et)
+{
+	char *act = mlxsw_afa_block_append_action(block,
+						  MLXSW_AFA_VLAN_CODE,
+						  MLXSW_AFA_VLAN_SIZE);
+
+	if (!act)
+		return -ENOBUFS;
+	mlxsw_afa_vlan_pack(act, MLXSW_AFA_VLAN_VLAN_TAG_CMD_NOP,
+			    MLXSW_AFA_VLAN_CMD_SET_OUTER, vid,
+			    MLXSW_AFA_VLAN_CMD_SET_OUTER, pcp,
+			    MLXSW_AFA_VLAN_CMD_SET_OUTER, et);
+	return 0;
+}
+EXPORT_SYMBOL(mlxsw_afa_block_append_vlan_modify);
+
 /* Trap / Discard Action
  * ---------------------
  * The Trap / Discard action enables trapping / mirroring packets to the CPU
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
index 43f78dc..6e103ac 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
@@ -62,5 +62,7 @@ void mlxsw_afa_block_jump(struct mlxsw_afa_block *block, u16 group_id);
 int mlxsw_afa_block_append_drop(struct mlxsw_afa_block *block);
 int mlxsw_afa_block_append_fwd(struct mlxsw_afa_block *block,
 			       u8 local_port, bool in_port);
+int mlxsw_afa_block_append_vlan_modify(struct mlxsw_afa_block *block,
+				       u16 vid, u8 pcp, u8 et);
 
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 13ec85e..ac445d8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -679,6 +679,9 @@ int mlxsw_sp_acl_rulei_act_drop(struct mlxsw_sp_acl_rule_info *rulei);
 int mlxsw_sp_acl_rulei_act_fwd(struct mlxsw_sp *mlxsw_sp,
 			       struct mlxsw_sp_acl_rule_info *rulei,
 			       struct net_device *out_dev);
+int mlxsw_sp_acl_rulei_act_vlan(struct mlxsw_sp *mlxsw_sp,
+				struct mlxsw_sp_acl_rule_info *rulei,
+				u32 action, u16 vid, u16 proto, u8 prio);
 
 struct mlxsw_sp_acl_rule;
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
index 8a18b3a..3c5ea7e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
@@ -39,6 +39,7 @@
 #include <linux/string.h>
 #include <linux/rhashtable.h>
 #include <linux/netdevice.h>
+#include <net/tc_act/tc_vlan.h>
 
 #include "reg.h"
 #include "core.h"
@@ -335,6 +336,34 @@ int mlxsw_sp_acl_rulei_act_fwd(struct mlxsw_sp *mlxsw_sp,
 					  local_port, in_port);
 }
 
+int mlxsw_sp_acl_rulei_act_vlan(struct mlxsw_sp *mlxsw_sp,
+				struct mlxsw_sp_acl_rule_info *rulei,
+				u32 action, u16 vid, u16 proto, u8 prio)
+{
+	u8 ethertype;
+
+	if (action == TCA_VLAN_ACT_MODIFY) {
+		switch (proto) {
+		case ETH_P_8021Q:
+			ethertype = 0;
+			break;
+		case ETH_P_8021AD:
+			ethertype = 1;
+			break;
+		default:
+			dev_err(mlxsw_sp->bus_info->dev, "Unsupported VLAN protocol %#04x\n",
+				proto);
+			return -EINVAL;
+		}
+
+		return mlxsw_afa_block_append_vlan_modify(rulei->act_block,
+							  vid, prio, ethertype);
+	} else {
+		dev_err(mlxsw_sp->bus_info->dev, "Unsupported VLAN action\n");
+		return -EINVAL;
+	}
+}
+
 struct mlxsw_sp_acl_rule *
 mlxsw_sp_acl_rule_create(struct mlxsw_sp *mlxsw_sp,
 			 struct mlxsw_sp_acl_ruleset *ruleset,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index 22ab429..d898407 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -39,6 +39,7 @@
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_gact.h>
 #include <net/tc_act/tc_mirred.h>
+#include <net/tc_act/tc_vlan.h>
 
 #include "spectrum.h"
 #include "core_acl_flex_keys.h"
@@ -73,6 +74,15 @@ static int mlxsw_sp_flower_parse_actions(struct mlxsw_sp *mlxsw_sp,
 							 out_dev);
 			if (err)
 				return err;
+		} else if (is_tcf_vlan(a)) {
+			u16 proto = be16_to_cpu(tcf_vlan_push_proto(a));
+			u32 action = tcf_vlan_action(a);
+			u8 prio = tcf_vlan_push_prio(a);
+			u16 vid = tcf_vlan_push_vid(a);
+
+			return mlxsw_sp_acl_rulei_act_vlan(mlxsw_sp, rulei,
+							   action, vid,
+							   proto, prio);
 		} else {
 			dev_err(mlxsw_sp->bus_info->dev, "Unsupported action\n");
 			return -EOPNOTSUPP;
diff --git a/include/net/tc_act/tc_vlan.h b/include/net/tc_act/tc_vlan.h
index 48cca32..9690c04 100644
--- a/include/net/tc_act/tc_vlan.h
+++ b/include/net/tc_act/tc_vlan.h
@@ -49,4 +49,9 @@ static inline __be16 tcf_vlan_push_proto(const struct tc_action *a)
 	return to_vlan(a)->tcfv_push_proto;
 }
 
+static inline u8 tcf_vlan_push_prio(const struct tc_action *a)
+{
+	return to_vlan(a)->tcfv_push_prio;
+}
+
 #endif /* __NET_TC_VLAN_H */
-- 
2.7.4
