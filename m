From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/5] mlxsw: spectrum_flower: Offload goto_chain termination action
Date: Wed, 23 Aug 2017 10:08:22 +0200
Message-ID: <20170823080822.14898-5-jiri@resnulli.us>
References: <20170823080652.14847-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35765 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753522AbdHWIIb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 04:08:31 -0400
Received: by mail-wr0-f194.google.com with SMTP id p8so602271wrf.2
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 01:08:30 -0700 (PDT)
In-Reply-To: <20170823080652.14847-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

If action is gact goto_chain, offload it to HW by jumping to another
ruleset.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  | 23 ++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index 34872aa..8aace9a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -45,7 +45,7 @@
 #include "core_acl_flex_keys.h"
 
 static int mlxsw_sp_flower_parse_actions(struct mlxsw_sp *mlxsw_sp,
-					 struct net_device *dev,
+					 struct net_device *dev, bool ingress,
 					 struct mlxsw_sp_acl_rule_info *rulei,
 					 struct tcf_exts *exts)
 {
@@ -71,6 +71,20 @@ static int mlxsw_sp_flower_parse_actions(struct mlxsw_sp *mlxsw_sp,
 			err = mlxsw_sp_acl_rulei_act_trap(rulei);
 			if (err)
 				return err;
+		} else if (is_tcf_gact_goto_chain(a)) {
+			u32 chain_index = tcf_gact_goto_chain_index(a);
+			struct mlxsw_sp_acl_ruleset *ruleset;
+			u16 group_id;
+
+			ruleset = mlxsw_sp_acl_ruleset_lookup(mlxsw_sp, dev,
+							      ingress,
+							      chain_index,
+							      MLXSW_SP_ACL_PROFILE_FLOWER);
+			if (IS_ERR(ruleset))
+				return PTR_ERR(ruleset);
+
+			group_id = mlxsw_sp_acl_ruleset_group_id(ruleset);
+			mlxsw_sp_acl_rulei_act_jump(rulei, group_id);
 		} else if (is_tcf_mirred_egress_redirect(a)) {
 			int ifindex = tcf_mirred_ifindex(a);
 			struct net_device *out_dev;
@@ -246,7 +260,7 @@ static int mlxsw_sp_flower_parse_ip(struct mlxsw_sp *mlxsw_sp,
 }
 
 static int mlxsw_sp_flower_parse(struct mlxsw_sp *mlxsw_sp,
-				 struct net_device *dev,
+				 struct net_device *dev, bool ingress,
 				 struct mlxsw_sp_acl_rule_info *rulei,
 				 struct tc_cls_flower_offload *f)
 {
@@ -364,7 +378,8 @@ static int mlxsw_sp_flower_parse(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		return err;
 
-	return mlxsw_sp_flower_parse_actions(mlxsw_sp, dev, rulei, f->exts);
+	return mlxsw_sp_flower_parse_actions(mlxsw_sp, dev, ingress,
+					     rulei, f->exts);
 }
 
 int mlxsw_sp_flower_replace(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
@@ -390,7 +405,7 @@ int mlxsw_sp_flower_replace(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 	}
 
 	rulei = mlxsw_sp_acl_rule_rulei(rule);
-	err = mlxsw_sp_flower_parse(mlxsw_sp, dev, rulei, f);
+	err = mlxsw_sp_flower_parse(mlxsw_sp, dev, ingress, rulei, f);
 	if (err)
 		goto err_flower_parse;
 
-- 
2.9.3
