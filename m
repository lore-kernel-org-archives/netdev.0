From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 09/10] net: sched: push tp down to action init
Date: Tue, 16 May 2017 19:28:01 +0200
Message-ID: <20170516172802.1317-10-jiri@resnulli.us>
References: <20170516172802.1317-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36479 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753394AbdEPR2S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:28:18 -0400
Received: by mail-wr0-f196.google.com with SMTP id v42so14890422wrc.3
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:28:18 -0700 (PDT)
In-Reply-To: <20170516172802.1317-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Tp pointer will be needed by the next patch in order to get the chain.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/act_api.h | 12 ++++++------
 net/sched/act_api.c   | 15 ++++++++-------
 net/sched/cls_api.c   |  9 +++++----
 3 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index cfa2ae3..b22c6f3 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
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
index a90e8f3..e389eb4 100644
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
@@ -680,8 +680,9 @@ static void cleanup_a(struct list_head *actions, int ovr)
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
@@ -693,7 +694,7 @@ int tcf_action_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 		return err;
 
 	for (i = 1; i <= TCA_ACT_MAX_PRIO && tb[i]; i++) {
-		act = tcf_action_init_1(net, tb[i], est, name, ovr, bind);
+		act = tcf_action_init_1(net, tp, tb[i], est, name, ovr, bind);
 		if (IS_ERR(act)) {
 			err = PTR_ERR(act);
 			goto err;
@@ -1020,7 +1021,7 @@ static int tcf_action_add(struct net *net, struct nlattr *nla,
 	int ret = 0;
 	LIST_HEAD(actions);
 
-	ret = tcf_action_init(net, nla, NULL, NULL, ovr, 0, &actions);
+	ret = tcf_action_init(net, NULL, nla, NULL, NULL, ovr, 0, &actions);
 	if (ret)
 		return ret;
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 9dcb5c5..1112a2b 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -826,8 +826,9 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 		struct tc_action *act;
 
 		if (exts->police && tb[exts->police]) {
-			act = tcf_action_init_1(net, tb[exts->police], rate_tlv,
-						"police", ovr, TCA_ACT_BIND);
+			act = tcf_action_init_1(net, tp, tb[exts->police],
+						rate_tlv, "police", ovr,
+						TCA_ACT_BIND);
 			if (IS_ERR(act))
 				return PTR_ERR(act);
 
@@ -838,8 +839,8 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
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
2.9.3
