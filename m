From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 9/9] mlxsw: spectrum: Add support for TC flower offload statistics
Date: Sat, 11 Mar 2017 09:42:59 +0100
Message-ID: <1489221779-3807-10-git-send-email-jiri@resnulli.us>
References: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, mlxsw@mellanox.com,
        idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33885 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755493AbdCKInN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 03:43:13 -0500
Received: by mail-wm0-f68.google.com with SMTP id u132so2247773wmg.1
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 00:43:12 -0800 (PST)
In-Reply-To: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for TC flower offload statistics including number of packets,
bytes and last use timestamp. Currently the statistics are gathered on a
per-rule basis.

Signed-off-by: Arkadi Sharshvesky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  3 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c | 28 +++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  | 49 ++++++++++++++++++++++
 4 files changed, 82 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index af43048..475499b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1434,6 +1434,9 @@ static int mlxsw_sp_setup_tc(struct net_device *dev, u32 handle,
 			mlxsw_sp_flower_destroy(mlxsw_sp_port, ingress,
 						tc->cls_flower);
 			return 0;
+		case TC_CLSFLOWER_STATS:
+			return mlxsw_sp_flower_stats(mlxsw_sp_port, ingress,
+						     tc->cls_flower);
 		default:
 			return -EOPNOTSUPP;
 		}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index b4f32a6..5502232 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -688,6 +688,8 @@ int mlxsw_sp_flower_replace(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 			    __be16 protocol, struct tc_cls_flower_offload *f);
 void mlxsw_sp_flower_destroy(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 			     struct tc_cls_flower_offload *f);
+int mlxsw_sp_flower_stats(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
+			  struct tc_cls_flower_offload *f);
 int mlxsw_sp_flow_counter_get(struct mlxsw_sp *mlxsw_sp,
 			      unsigned int counter_index, u64 *packets,
 			      u64 *bytes);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
index 87d0111..4d6920d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
@@ -92,6 +92,8 @@ struct mlxsw_sp_acl_rule {
 	struct mlxsw_sp_acl_ruleset *ruleset;
 	struct mlxsw_sp_acl_rule_info *rulei;
 	u64 last_used;
+	u64 last_packets;
+	u64 last_bytes;
 	unsigned long priv[0];
 	/* priv has to be always the last item */
 };
@@ -559,6 +561,32 @@ static void mlxsw_sp_acl_rul_activity_update_work(struct work_struct *work)
 	mlxsw_sp_acl_rule_activity_work_schedule(acl);
 }
 
+int mlxsw_sp_acl_rule_get_stats(struct mlxsw_sp *mlxsw_sp,
+				struct mlxsw_sp_acl_rule *rule,
+				u64 *packets, u64 *bytes, u64 *last_use)
+
+{
+	struct mlxsw_sp_acl_rule_info *rulei;
+	u64 current_packets;
+	u64 current_bytes;
+	int err;
+
+	rulei = mlxsw_sp_acl_rule_rulei(rule);
+	err = mlxsw_sp_flow_counter_get(mlxsw_sp, rulei->counter_index,
+					&current_packets, &current_bytes);
+	if (err)
+		return err;
+
+	*packets = current_packets - rule->last_packets;
+	*bytes = current_bytes - rule->last_bytes;
+	*last_use = rule->last_used;
+
+	rule->last_bytes = current_bytes;
+	rule->last_packets = current_packets;
+
+	return 0;
+}
+
 #define MLXSW_SP_KDVL_ACT_EXT_SIZE 1
 
 static int mlxsw_sp_act_kvdl_set_add(void *priv, u32 *p_kvdl_index,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index f2ed0b3..28bc989 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -56,6 +56,11 @@ static int mlxsw_sp_flower_parse_actions(struct mlxsw_sp *mlxsw_sp,
 	if (tc_no_actions(exts))
 		return 0;
 
+	/* Count action is inserted first */
+	err = mlxsw_sp_acl_rulei_act_count(mlxsw_sp, rulei);
+	if (err)
+		return err;
+
 	tcf_exts_to_list(exts, &actions);
 	list_for_each_entry(a, &actions, list) {
 		if (is_tcf_gact_shot(a)) {
@@ -346,3 +351,47 @@ void mlxsw_sp_flower_destroy(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 
 	mlxsw_sp_acl_ruleset_put(mlxsw_sp, ruleset);
 }
+
+int mlxsw_sp_flower_stats(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
+			  struct tc_cls_flower_offload *f)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct mlxsw_sp_acl_ruleset *ruleset;
+	struct mlxsw_sp_acl_rule *rule;
+	struct tc_action *a;
+	LIST_HEAD(actions);
+	u64 packets;
+	u64 lastuse;
+	u64 bytes;
+	int err;
+
+	ruleset = mlxsw_sp_acl_ruleset_get(mlxsw_sp, mlxsw_sp_port->dev,
+					   ingress,
+					   MLXSW_SP_ACL_PROFILE_FLOWER);
+	if (WARN_ON(IS_ERR(ruleset)))
+		return -EINVAL;
+
+	rule = mlxsw_sp_acl_rule_lookup(mlxsw_sp, ruleset, f->cookie);
+	if (!rule)
+		return -EINVAL;
+
+	err = mlxsw_sp_acl_rule_get_stats(mlxsw_sp, rule, &bytes, &packets,
+					  &lastuse);
+	if (err)
+		goto err_rule_get_stats;
+
+	preempt_disable();
+
+	tcf_exts_to_list(f->exts, &actions);
+	list_for_each_entry(a, &actions, list)
+		tcf_action_stats_update(a, bytes, packets, lastuse);
+
+	preempt_enable();
+
+	mlxsw_sp_acl_ruleset_put(mlxsw_sp, ruleset);
+	return 0;
+
+err_rule_get_stats:
+	mlxsw_sp_acl_ruleset_put(mlxsw_sp, ruleset);
+	return err;
+}
-- 
2.7.4
