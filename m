From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/10] net: sched: push tp down to action init callback
Date: Thu, 27 Apr 2017 13:12:19 +0200
Message-ID: <1493291540-2119-10-git-send-email-jiri@resnulli.us>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, mlxsw@mellanox.com,
        simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35425 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936299AbdD0LMh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 07:12:37 -0400
Received: by mail-wm0-f67.google.com with SMTP id d79so3820944wmi.2
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 04:12:36 -0700 (PDT)
In-Reply-To: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Tp pointer will be needed by the next patch in order to get the chain.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/act_api.h      | 18 +++++++++---------
 net/sched/act_api.c        | 20 +++++++++++---------
 net/sched/act_bpf.c        |  6 +++---
 net/sched/act_connmark.c   |  6 +++---
 net/sched/act_csum.c       |  6 +++---
 net/sched/act_gact.c       |  6 +++---
 net/sched/act_ife.c        |  6 +++---
 net/sched/act_ipt.c        | 12 ++++++------
 net/sched/act_mirred.c     |  6 +++---
 net/sched/act_nat.c        |  3 ++-
 net/sched/act_pedit.c      |  6 +++---
 net/sched/act_police.c     |  6 +++---
 net/sched/act_sample.c     |  6 +++---
 net/sched/act_simple.c     |  6 +++---
 net/sched/act_skbedit.c    |  6 +++---
 net/sched/act_skbmod.c     |  6 +++---
 net/sched/act_tunnel_key.c |  6 +++---
 net/sched/act_vlan.c       |  6 +++---
 net/sched/cls_api.c        |  9 +++++----
 19 files changed, 75 insertions(+), 71 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index cfa2ae3..816c5f5 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -114,9 +114,9 @@ struct tc_action_ops {
 	int     (*dump)(struct sk_buff *, struct tc_action *, int, int);
 	void	(*cleanup)(struct tc_action *, int bind);
 	int     (*lookup)(struct net *, struct tc_action **, u32);
-	int     (*init)(struct net *net, struct nlattr *nla,
-			struct nlattr *est, struct tc_action **act, int ovr,
-			int bind);
+	int     (*init)(struct net *net, struct tcf_proto *tp,
+			struct nlattr *nla, struct nlattr *est,
+			struct tc_action **act, int ovr, int bind);
 	int     (*walk)(struct net *, struct sk_buff *,
 			struct netlink_callback *, int, const struct tc_action_ops *);
 	void	(*stats_update)(struct tc_action *, u64, u32, u64);
@@ -180,12 +180,12 @@ int tcf_unregister_action(struct tc_action_ops *a,
 int tcf_action_destroy(struct list_head *actions, int bind);
 int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
 		    int nr_actions, struct tcf_result *res);
-int tcf_action_init(struct net *net, struct nlattr *nla,
-				  struct nlattr *est, char *n, int ovr,
-				  int bind, struct list_head *);
-struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
-				    struct nlattr *est, char *n, int ovr,
-				    int bind);
+int tcf_action_init(struct net *net, struct tcf_proto *tp, struct nlattr *nla,
+		    struct nlattr *est, char *name, int ovr, int bind,
+		    struct list_head *actions);
+struct tc_action *tcf_action_init_1(struct net *net, struct tcf_proto *tp,
+				    struct nlattr *nla, struct nlattr *est,
+				    char *name, int ovr, int bind);
 int tcf_action_dump(struct sk_buff *skb, struct list_head *, int, int);
 int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
 int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 7f2cd70..5646046 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -570,9 +570,9 @@ static struct tc_cookie *nla_memdup_cookie(struct nlattr **tb)
 	return c;
 }
 
-struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
-				    struct nlattr *est, char *name, int ovr,
-				    int bind)
+struct tc_action *tcf_action_init_1(struct net *net, struct tcf_proto *tp,
+				    struct nlattr *nla, struct nlattr *est,
+				    char *name, int ovr, int bind)
 {
 	struct tc_action *a;
 	struct tc_action_ops *a_o;
@@ -636,9 +636,10 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 
 	/* backward compatibility for policer */
 	if (name == NULL)
-		err = a_o->init(net, tb[TCA_ACT_OPTIONS], est, &a, ovr, bind);
+		err = a_o->init(net, tp, tb[TCA_ACT_OPTIONS], est,
+				&a, ovr, bind);
 	else
-		err = a_o->init(net, nla, est, &a, ovr, bind);
+		err = a_o->init(net, tp, nla, est, &a, ovr, bind);
 	if (err < 0)
 		goto err_mod;
 
@@ -680,8 +681,9 @@ static void cleanup_a(struct list_head *actions, int ovr)
 		a->tcfa_refcnt--;
 }
 
-int tcf_action_init(struct net *net, struct nlattr *nla, struct nlattr *est,
-		    char *name, int ovr, int bind, struct list_head *actions)
+int tcf_action_init(struct net *net, struct tcf_proto *tp, struct nlattr *nla,
+		    struct nlattr *est, char *name, int ovr, int bind,
+		    struct list_head *actions)
 {
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
 	struct tc_action *act;
@@ -693,7 +695,7 @@ int tcf_action_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 		return err;
 
 	for (i = 1; i <= TCA_ACT_MAX_PRIO && tb[i]; i++) {
-		act = tcf_action_init_1(net, tb[i], est, name, ovr, bind);
+		act = tcf_action_init_1(net, tp, tb[i], est, name, ovr, bind);
 		if (IS_ERR(act)) {
 			err = PTR_ERR(act);
 			goto err;
@@ -1020,7 +1022,7 @@ static int tcf_action_add(struct net *net, struct nlattr *nla,
 	int ret = 0;
 	LIST_HEAD(actions);
 
-	ret = tcf_action_init(net, nla, NULL, NULL, ovr, 0, &actions);
+	ret = tcf_action_init(net, NULL, nla, NULL, NULL, ovr, 0, &actions);
 	if (ret)
 		return ret;
 
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index d33947d..64bb273 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -268,9 +268,9 @@ static void tcf_bpf_prog_fill_cfg(const struct tcf_bpf *prog,
 	cfg->bpf_name = prog->bpf_name;
 }
 
-static int tcf_bpf_init(struct net *net, struct nlattr *nla,
-			struct nlattr *est, struct tc_action **act,
-			int replace, int bind)
+static int tcf_bpf_init(struct net *net, struct tcf_proto *tp,
+			struct nlattr *nla, struct nlattr *est,
+			struct tc_action **act, int replace, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, bpf_net_id);
 	struct nlattr *tb[TCA_ACT_BPF_MAX + 1];
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index 2155bc6..2f0f3b5 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -96,9 +96,9 @@ static const struct nla_policy connmark_policy[TCA_CONNMARK_MAX + 1] = {
 	[TCA_CONNMARK_PARMS] = { .len = sizeof(struct tc_connmark) },
 };
 
-static int tcf_connmark_init(struct net *net, struct nlattr *nla,
-			     struct nlattr *est, struct tc_action **a,
-			     int ovr, int bind)
+static int tcf_connmark_init(struct net *net, struct tcf_proto *tp,
+			     struct nlattr *nla, struct nlattr *est,
+			     struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, connmark_net_id);
 	struct nlattr *tb[TCA_CONNMARK_MAX + 1];
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index ab6fdbd..ee3f339 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -46,9 +46,9 @@ static const struct nla_policy csum_policy[TCA_CSUM_MAX + 1] = {
 static unsigned int csum_net_id;
 static struct tc_action_ops act_csum_ops;
 
-static int tcf_csum_init(struct net *net, struct nlattr *nla,
-			 struct nlattr *est, struct tc_action **a, int ovr,
-			 int bind)
+static int tcf_csum_init(struct net *net, struct tcf_proto *tp,
+			 struct nlattr *nla, struct nlattr *est,
+			 struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, csum_net_id);
 	struct nlattr *tb[TCA_CSUM_MAX + 1];
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 99afe8b..c527c11 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -56,9 +56,9 @@ static const struct nla_policy gact_policy[TCA_GACT_MAX + 1] = {
 	[TCA_GACT_PROB]		= { .len = sizeof(struct tc_gact_p) },
 };
 
-static int tcf_gact_init(struct net *net, struct nlattr *nla,
-			 struct nlattr *est, struct tc_action **a,
-			 int ovr, int bind)
+static int tcf_gact_init(struct net *net, struct tcf_proto *tp,
+			 struct nlattr *nla, struct nlattr *est,
+			 struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, gact_net_id);
 	struct nlattr *tb[TCA_GACT_MAX + 1];
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index c5dec30..deea15c 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -427,9 +427,9 @@ static int populate_metalist(struct tcf_ife_info *ife, struct nlattr **tb,
 	return rc;
 }
 
-static int tcf_ife_init(struct net *net, struct nlattr *nla,
-			struct nlattr *est, struct tc_action **a,
-			int ovr, int bind)
+static int tcf_ife_init(struct net *net, struct tcf_proto *tp,
+			struct nlattr *nla, struct nlattr *est,
+			struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, ife_net_id);
 	struct nlattr *tb[TCA_IFE_MAX + 1];
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 36f0ced..011a1c6 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -189,18 +189,18 @@ static int __tcf_ipt_init(struct tc_action_net *tn, struct nlattr *nla,
 	return err;
 }
 
-static int tcf_ipt_init(struct net *net, struct nlattr *nla,
-			struct nlattr *est, struct tc_action **a, int ovr,
-			int bind)
+static int tcf_ipt_init(struct net *net, struct tcf_proto *tp,
+			struct nlattr *nla, struct nlattr *est,
+			struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, ipt_net_id);
 
 	return __tcf_ipt_init(tn, nla, est, a, &act_ipt_ops, ovr, bind);
 }
 
-static int tcf_xt_init(struct net *net, struct nlattr *nla,
-		       struct nlattr *est, struct tc_action **a, int ovr,
-		       int bind)
+static int tcf_xt_init(struct net *net, struct tcf_proto *tp,
+		       struct nlattr *nla, struct nlattr *est,
+		       struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, xt_net_id);
 
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 1b5549a..957711f 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -72,9 +72,9 @@ static const struct nla_policy mirred_policy[TCA_MIRRED_MAX + 1] = {
 static unsigned int mirred_net_id;
 static struct tc_action_ops act_mirred_ops;
 
-static int tcf_mirred_init(struct net *net, struct nlattr *nla,
-			   struct nlattr *est, struct tc_action **a, int ovr,
-			   int bind)
+static int tcf_mirred_init(struct net *net, struct tcf_proto *tp,
+			   struct nlattr *nla, struct nlattr *est,
+			   struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, mirred_net_id);
 	struct nlattr *tb[TCA_MIRRED_MAX + 1];
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 9016ab8..50e2fa6 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -38,7 +38,8 @@ static const struct nla_policy nat_policy[TCA_NAT_MAX + 1] = {
 	[TCA_NAT_PARMS]	= { .len = sizeof(struct tc_nat) },
 };
 
-static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
+static int tcf_nat_init(struct net *net, struct tcf_proto *tp,
+			struct nlattr *nla, struct nlattr *est,
 			struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, nat_net_id);
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 164b5ac..3445f96 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -130,9 +130,9 @@ static int tcf_pedit_key_ex_dump(struct sk_buff *skb,
 	return 0;
 }
 
-static int tcf_pedit_init(struct net *net, struct nlattr *nla,
-			  struct nlattr *est, struct tc_action **a,
-			  int ovr, int bind)
+static int tcf_pedit_init(struct net *net, struct tcf_proto *tp,
+			  struct nlattr *nla, struct nlattr *est,
+			  struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, pedit_net_id);
 	struct nlattr *tb[TCA_PEDIT_MAX + 1];
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index f42008b..f5aeba2 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -74,9 +74,9 @@ static const struct nla_policy police_policy[TCA_POLICE_MAX + 1] = {
 	[TCA_POLICE_RESULT]	= { .type = NLA_U32 },
 };
 
-static int tcf_act_police_init(struct net *net, struct nlattr *nla,
-			       struct nlattr *est, struct tc_action **a,
-			       int ovr, int bind)
+static int tcf_act_police_init(struct net *net, struct tcf_proto *tp,
+			       struct nlattr *nla, struct nlattr *est,
+			       struct tc_action **a, int ovr, int bind)
 {
 	int ret = 0, err;
 	struct nlattr *tb[TCA_POLICE_MAX + 1];
diff --git a/net/sched/act_sample.c b/net/sched/act_sample.c
index 59d6645..60080fb 100644
--- a/net/sched/act_sample.c
+++ b/net/sched/act_sample.c
@@ -36,9 +36,9 @@ static const struct nla_policy sample_policy[TCA_SAMPLE_MAX + 1] = {
 	[TCA_SAMPLE_PSAMPLE_GROUP]	= { .type = NLA_U32 },
 };
 
-static int tcf_sample_init(struct net *net, struct nlattr *nla,
-			   struct nlattr *est, struct tc_action **a, int ovr,
-			   int bind)
+static int tcf_sample_init(struct net *net, struct tcf_proto *tp,
+			   struct nlattr *nla, struct nlattr *est,
+			   struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, sample_net_id);
 	struct nlattr *tb[TCA_SAMPLE_MAX + 1];
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 43605e7..d4b5da4 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -79,9 +79,9 @@ static const struct nla_policy simple_policy[TCA_DEF_MAX + 1] = {
 	[TCA_DEF_DATA]	= { .type = NLA_STRING, .len = SIMP_MAX_DATA },
 };
 
-static int tcf_simp_init(struct net *net, struct nlattr *nla,
-			 struct nlattr *est, struct tc_action **a,
-			 int ovr, int bind)
+static int tcf_simp_init(struct net *net, struct tcf_proto *tp,
+			 struct nlattr *nla, struct nlattr *est,
+			 struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, simp_net_id);
 	struct nlattr *tb[TCA_DEF_MAX + 1];
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 6b3e65d..979d656 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -66,9 +66,9 @@ static const struct nla_policy skbedit_policy[TCA_SKBEDIT_MAX + 1] = {
 	[TCA_SKBEDIT_MASK]		= { .len = sizeof(u32) },
 };
 
-static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
-			    struct nlattr *est, struct tc_action **a,
-			    int ovr, int bind)
+static int tcf_skbedit_init(struct net *net, struct tcf_proto *tp,
+			    struct nlattr *nla, struct nlattr *est,
+			    struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, skbedit_net_id);
 	struct nlattr *tb[TCA_SKBEDIT_MAX + 1];
diff --git a/net/sched/act_skbmod.c b/net/sched/act_skbmod.c
index a73c4bb..56549b7 100644
--- a/net/sched/act_skbmod.c
+++ b/net/sched/act_skbmod.c
@@ -84,9 +84,9 @@ static const struct nla_policy skbmod_policy[TCA_SKBMOD_MAX + 1] = {
 	[TCA_SKBMOD_ETYPE]		= { .type = NLA_U16 },
 };
 
-static int tcf_skbmod_init(struct net *net, struct nlattr *nla,
-			   struct nlattr *est, struct tc_action **a,
-			   int ovr, int bind)
+static int tcf_skbmod_init(struct net *net, struct tcf_proto *tp,
+			   struct nlattr *nla, struct nlattr *est,
+			   struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, skbmod_net_id);
 	struct nlattr *tb[TCA_SKBMOD_MAX + 1];
diff --git a/net/sched/act_tunnel_key.c b/net/sched/act_tunnel_key.c
index b9a2f24..9d37909 100644
--- a/net/sched/act_tunnel_key.c
+++ b/net/sched/act_tunnel_key.c
@@ -69,9 +69,9 @@ static const struct nla_policy tunnel_key_policy[TCA_TUNNEL_KEY_MAX + 1] = {
 	[TCA_TUNNEL_KEY_ENC_DST_PORT] = {.type = NLA_U16},
 };
 
-static int tunnel_key_init(struct net *net, struct nlattr *nla,
-			   struct nlattr *est, struct tc_action **a,
-			   int ovr, int bind)
+static int tunnel_key_init(struct net *net, struct tcf_proto *tp,
+			   struct nlattr *nla, struct nlattr *est,
+			   struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, tunnel_key_net_id);
 	struct nlattr *tb[TCA_TUNNEL_KEY_MAX + 1];
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index 13ba3a8..525603f 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -103,9 +103,9 @@ static const struct nla_policy vlan_policy[TCA_VLAN_MAX + 1] = {
 	[TCA_VLAN_PUSH_VLAN_PRIORITY]	= { .type = NLA_U8 },
 };
 
-static int tcf_vlan_init(struct net *net, struct nlattr *nla,
-			 struct nlattr *est, struct tc_action **a,
-			 int ovr, int bind)
+static int tcf_vlan_init(struct net *net, struct tcf_proto *tp,
+			 struct nlattr *nla, struct nlattr *est,
+			 struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, vlan_net_id);
 	struct nlattr *tb[TCA_VLAN_MAX + 1];
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index a4fab8f..dbc1348 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -822,8 +822,9 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 		struct tc_action *act;
 
 		if (exts->police && tb[exts->police]) {
-			act = tcf_action_init_1(net, tb[exts->police], rate_tlv,
-						"police", ovr, TCA_ACT_BIND);
+			act = tcf_action_init_1(net, tp, tb[exts->police],
+						rate_tlv, "police", ovr,
+						TCA_ACT_BIND);
 			if (IS_ERR(act))
 				return PTR_ERR(act);
 
@@ -834,8 +835,8 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 			LIST_HEAD(actions);
 			int err, i = 0;
 
-			err = tcf_action_init(net, tb[exts->action], rate_tlv,
-					      NULL, ovr, TCA_ACT_BIND,
+			err = tcf_action_init(net, tp, tb[exts->action],
+					      rate_tlv, NULL, ovr, TCA_ACT_BIND,
 					      &actions);
 			if (err)
 				return err;
-- 
2.7.4
