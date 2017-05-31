From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/9] sched: add helper for updating statistics on all actions
Date: Wed, 31 May 2017 08:06:43 -0700
Message-ID: <20170531150651.16873-2-jakub.kicinski@netronome.com>
References: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:33606 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751187AbdEaPLs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 11:11:48 -0400
Received: by mail-pg0-f48.google.com with SMTP id u187so9295187pgb.0
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 08:11:47 -0700 (PDT)
In-Reply-To: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forgetting to disable preemption around tcf_action_stats_update()
seems to be a common mistake.  Add a helper function for updating
stats on all actions of a filter.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
CC: Jiri Pirko <jiri@mellanox.com>
CC: Jamal Hadi Salim <jhs@mojatatu.com>
CC: Cong Wang <xiyou.wangcong@gmail.com>
CC: Saeed Mahameed <saeedm@mellanox.com>
CC: Or Gerlitz <ogerlitz@mellanox.com>

 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c       | 10 +---------
 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c | 10 +---------
 drivers/net/ethernet/netronome/nfp/nfp_net_offload.c  | 11 ++---------
 include/net/pkt_cls.h                                 | 19 +++++++++++++++++++
 4 files changed, 23 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index d2f90ba2dbc4..7914a32a3036 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1863,9 +1863,7 @@ int mlx5e_stats_flower(struct mlx5e_priv *priv,
 {
 	struct mlx5e_tc_table *tc = &priv->fs.tc;
 	struct mlx5e_tc_flow *flow;
-	struct tc_action *a;
 	struct mlx5_fc *counter;
-	LIST_HEAD(actions);
 	u64 bytes;
 	u64 packets;
 	u64 lastuse;
@@ -1884,13 +1882,7 @@ int mlx5e_stats_flower(struct mlx5e_priv *priv,
 
 	mlx5_fc_query_cached(counter, &bytes, &packets, &lastuse);
 
-	preempt_disable();
-
-	tcf_exts_to_list(f->exts, &actions);
-	list_for_each_entry(a, &actions, list)
-		tcf_action_stats_update(a, bytes, packets, lastuse);
-
-	preempt_enable();
+	tcf_exts_stats_update(f->exts, bytes, packets, lastuse);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index ed75c6a85bc3..13af8e358847 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -397,8 +397,6 @@ int mlxsw_sp_flower_stats(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_acl_ruleset *ruleset;
 	struct mlxsw_sp_acl_rule *rule;
-	struct tc_action *a;
-	LIST_HEAD(actions);
 	u64 packets;
 	u64 lastuse;
 	u64 bytes;
@@ -419,13 +417,7 @@ int mlxsw_sp_flower_stats(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 	if (err)
 		goto err_rule_get_stats;
 
-	preempt_disable();
-
-	tcf_exts_to_list(f->exts, &actions);
-	list_for_each_entry(a, &actions, list)
-		tcf_action_stats_update(a, bytes, packets, lastuse);
-
-	preempt_enable();
+	tcf_exts_stats_update(f->exts, bytes, packets, lastuse);
 
 	mlxsw_sp_acl_ruleset_put(mlxsw_sp, ruleset);
 	return 0;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
index cc823df12c8a..2fa7b67d0c6f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
@@ -84,8 +84,6 @@ static void nfp_net_bpf_stats_reset(struct nfp_net *nn)
 static int
 nfp_net_bpf_stats_update(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 {
-	struct tc_action *a;
-	LIST_HEAD(actions);
 	u64 bytes, pkts;
 
 	pkts = nn->rx_filter.pkts - nn->rx_filter_prev.pkts;
@@ -94,13 +92,8 @@ nfp_net_bpf_stats_update(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 
 	nn->rx_filter_prev = nn->rx_filter;
 
-	preempt_disable();
-
-	tcf_exts_to_list(cls_bpf->exts, &actions);
-	list_for_each_entry(a, &actions, list)
-		tcf_action_stats_update(a, bytes, pkts, nn->rx_filter_change);
-
-	preempt_enable();
+	tcf_exts_stats_update(cls_bpf->exts,
+			      bytes, pkts, nn->rx_filter_change);
 
 	return 0;
 }
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index f7762295b7b8..537d0a0ad4c4 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -157,6 +157,25 @@ static inline void tcf_exts_to_list(const struct tcf_exts *exts,
 #endif
 }
 
+static inline void
+tcf_exts_stats_update(const struct tcf_exts *exts,
+		      u64 bytes, u64 packets, u64 lastuse)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	int i;
+
+	preempt_disable();
+
+	for (i = 0; i < exts->nr_actions; i++) {
+		struct tc_action *a = exts->actions[i];
+
+		tcf_action_stats_update(a, bytes, packets, lastuse);
+	}
+
+	preempt_enable();
+#endif
+}
+
 /**
  * tcf_exts_exec - execute tc filter extensions
  * @skb: socket buffer
-- 
2.11.0
