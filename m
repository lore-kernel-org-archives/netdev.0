From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 4/6] net_sched: act: refactor cleanup ops
Date: Fri, 17 Jan 2014 11:37:05 -0800
Message-ID: <1389987427-14085-5-git-send-email-xiyou.wangcong@gmail.com>
References: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:40474 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819AbaAQTh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 14:37:26 -0500
Received: by mail-pb0-f48.google.com with SMTP id rr13so4481752pbb.21
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 11:37:25 -0800 (PST)
In-Reply-To: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For bindcnt and refcnt etc., they are common for all actions,
not need to repeat such operations for their own, they can be unified
now. Actions just need to do its specific cleanup if needed.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h   |  2 +-
 net/sched/act_api.c     |  8 +++++---
 net/sched/act_csum.c    |  1 -
 net/sched/act_gact.c    |  1 -
 net/sched/act_ipt.c     | 21 +++++----------------
 net/sched/act_mirred.c  | 20 +++++---------------
 net/sched/act_nat.c     |  1 -
 net/sched/act_pedit.c   | 13 +++----------
 net/sched/act_police.c  |  9 ---------
 net/sched/act_simple.c  | 17 +++--------------
 net/sched/act_skbedit.c |  1 -
 11 files changed, 22 insertions(+), 72 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index f2b5cb3..9263ace 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -91,7 +91,7 @@ struct tc_action_ops {
 	struct module		*owner;
 	int     (*act)(struct sk_buff *, const struct tc_action *, struct tcf_result *);
 	int     (*dump)(struct sk_buff *, struct tc_action *, int, int);
-	int     (*cleanup)(struct tc_action *, int bind);
+	void	(*cleanup)(struct tc_action *, int bind);
 	int     (*lookup)(struct tc_action *, u32);
 	int     (*init)(struct net *net, struct nlattr *nla,
 			struct nlattr *est, struct tc_action *act, int ovr,
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 91b489e..453a47e 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -56,6 +56,8 @@ int tcf_hash_release(struct tc_action *a, int bind)
 
 		p->tcfc_refcnt--;
 		if (p->tcfc_bindcnt <= 0 && p->tcfc_refcnt <= 0) {
+			if (a->ops->cleanup)
+				a->ops->cleanup(a, bind);
 			tcf_hash_destroy(a);
 			ret = 1;
 		}
@@ -276,8 +278,8 @@ int tcf_register_action(struct tc_action_ops *act)
 {
 	struct tc_action_ops *a;
 
-	/* Must supply act, dump, cleanup and init */
-	if (!act->act || !act->dump || !act->cleanup || !act->init)
+	/* Must supply act, dump and init */
+	if (!act->act || !act->dump || !act->init)
 		return -EINVAL;
 
 	/* Supply defaults */
@@ -389,7 +391,7 @@ void tcf_action_destroy(struct list_head *actions, int bind)
 	struct tc_action *a, *tmp;
 
 	list_for_each_entry_safe(a, tmp, actions, list) {
-		if (a->ops->cleanup(a, bind) == ACT_P_DELETED)
+		if (tcf_hash_release(a, bind) == ACT_P_DELETED)
 			module_put(a->ops->owner);
 		list_del(&a->list);
 		kfree(a);
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 8e75a08..15e6515 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -567,7 +567,6 @@ static struct tc_action_ops act_csum_ops = {
 	.owner		= THIS_MODULE,
 	.act		= tcf_csum,
 	.dump		= tcf_csum_dump,
-	.cleanup	= tcf_hash_release,
 	.init		= tcf_csum_init,
 };
 
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 47148fa..e09b6e5 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -186,7 +186,6 @@ static struct tc_action_ops act_gact_ops = {
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_gact,
 	.dump		=	tcf_gact_dump,
-	.cleanup	=	tcf_hash_release,
 	.init		=	tcf_gact_init,
 };
 
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index f0545fb..6096310 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -69,23 +69,12 @@ static void ipt_destroy_target(struct xt_entry_target *t)
 	module_put(par.target->me);
 }
 
-static int tcf_ipt_release(struct tc_action *a, int bind)
+static void tcf_ipt_release(struct tc_action *a, int bind)
 {
 	struct tcf_ipt *ipt = to_ipt(a);
-	int ret = 0;
-	if (ipt) {
-		if (bind)
-			ipt->tcf_bindcnt--;
-		ipt->tcf_refcnt--;
-		if (ipt->tcf_bindcnt <= 0 && ipt->tcf_refcnt <= 0) {
-			ipt_destroy_target(ipt->tcfi_t);
-			kfree(ipt->tcfi_tname);
-			kfree(ipt->tcfi_t);
-			tcf_hash_destroy(a);
-			ret = ACT_P_DELETED;
-		}
-	}
-	return ret;
+	ipt_destroy_target(ipt->tcfi_t);
+	kfree(ipt->tcfi_tname);
+	kfree(ipt->tcfi_t);
 }
 
 static const struct nla_policy ipt_policy[TCA_IPT_MAX + 1] = {
@@ -133,7 +122,7 @@ static int tcf_ipt_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	} else {
 		if (bind)/* dont override defaults */
 			return 0;
-		tcf_ipt_release(a, bind);
+		tcf_hash_release(a, bind);
 
 		if (!ovr)
 			return -EEXIST;
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index f94a58f..93e5209 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -33,22 +33,12 @@
 static LIST_HEAD(mirred_list);
 static struct tcf_hashinfo mirred_hash_info;
 
-static int tcf_mirred_release(struct tc_action *a, int bind)
+static void tcf_mirred_release(struct tc_action *a, int bind)
 {
 	struct tcf_mirred *m = to_mirred(a);
-	if (m) {
-		if (bind)
-			m->tcf_bindcnt--;
-		m->tcf_refcnt--;
-		if (!m->tcf_bindcnt && m->tcf_refcnt <= 0) {
-			list_del(&m->tcfm_list);
-			if (m->tcfm_dev)
-				dev_put(m->tcfm_dev);
-			tcf_hash_destroy(a);
-			return 1;
-		}
-	}
-	return 0;
+	list_del(&m->tcfm_list);
+	if (m->tcfm_dev)
+		dev_put(m->tcfm_dev);
 }
 
 static const struct nla_policy mirred_policy[TCA_MIRRED_MAX + 1] = {
@@ -110,7 +100,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		ret = ACT_P_CREATED;
 	} else {
 		if (!ovr) {
-			tcf_mirred_release(a, bind);
+			tcf_hash_release(a, bind);
 			return -EEXIST;
 		}
 	}
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index c8d1843..e1ae2e5 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -290,7 +290,6 @@ static struct tc_action_ops act_nat_ops = {
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_nat,
 	.dump		=	tcf_nat_dump,
-	.cleanup	=	tcf_hash_release,
 	.init		=	tcf_nat_init,
 };
 
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 75f08e4..cd08b3b 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -99,18 +99,11 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 	return ret;
 }
 
-static int tcf_pedit_cleanup(struct tc_action *a, int bind)
+static void tcf_pedit_cleanup(struct tc_action *a, int bind)
 {
 	struct tcf_pedit *p = a->priv;
-
-	if (p) {
-		struct tc_pedit_key *keys = p->tcfp_keys;
-		if (tcf_hash_release(a, bind)) {
-			kfree(keys);
-			return 1;
-		}
-	}
-	return 0;
+	struct tc_pedit_key *keys = p->tcfp_keys;
+	kfree(keys);
 }
 
 static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index e51f7d9..143af47 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -253,14 +253,6 @@ failure:
 	return err;
 }
 
-static int tcf_act_police_cleanup(struct tc_action *a, int bind)
-{
-	struct tcf_police *p = a->priv;
-	if (p)
-		return tcf_hash_release(&p->common, bind, &police_hash_info);
-	return 0;
-}
-
 static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
 			  struct tcf_result *res)
 {
@@ -363,7 +355,6 @@ static struct tc_action_ops act_police_ops = {
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_act_police,
 	.dump		=	tcf_act_police_dump,
-	.cleanup	=	tcf_act_police_cleanup,
 	.init		=	tcf_act_police_locate,
 	.walk		=	tcf_act_police_walker
 };
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index e52ee06..fbdc6eb 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -47,21 +47,10 @@ static int tcf_simp(struct sk_buff *skb, const struct tc_action *a,
 	return d->tcf_action;
 }
 
-static int tcf_simp_release(struct tc_action *a, int bind)
+static void tcf_simp_release(struct tc_action *a, int bind)
 {
 	struct tcf_defact *d = to_defact(a);
-	int ret = 0;
-	if (d) {
-		if (bind)
-			d->tcf_bindcnt--;
-		d->tcf_refcnt--;
-		if (d->tcf_bindcnt <= 0 && d->tcf_refcnt <= 0) {
-			kfree(d->tcfd_defdata);
-			tcf_hash_destroy(a);
-			ret = 1;
-		}
-	}
-	return ret;
+	kfree(d->tcfd_defdata);
 }
 
 static int alloc_defdata(struct tcf_defact *d, char *defdata)
@@ -132,7 +121,7 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 
 		if (bind)
 			return 0;
-		tcf_simp_release(a, bind);
+		tcf_hash_release(a, bind);
 		if (!ovr)
 			return -EEXIST;
 
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 68ab57b..2965484 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -181,7 +181,6 @@ static struct tc_action_ops act_skbedit_ops = {
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_skbedit,
 	.dump		=	tcf_skbedit_dump,
-	.cleanup	=	tcf_hash_release,
 	.init		=	tcf_skbedit_init,
 };
 
-- 
1.8.3.1
