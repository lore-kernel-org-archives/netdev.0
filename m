From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 3/6] net_sched: act: hide struct tcf_common from API
Date: Fri, 17 Jan 2014 11:37:04 -0800
Message-ID: <1389987427-14085-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:44226 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066AbaAQThY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 14:37:24 -0500
Received: by mail-pb0-f41.google.com with SMTP id up15so3986873pbc.28
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 11:37:23 -0800 (PST)
In-Reply-To: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now we can totally hide it from modules. tcf_hash_*() API's
will operate on struct tc_action, modules don't need to care about
the details.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h           | 16 +++++++---------
 include/net/tc_act/tc_csum.h    |  4 ++--
 include/net/tc_act/tc_defact.h  |  4 ++--
 include/net/tc_act/tc_gact.h    |  4 ++--
 include/net/tc_act/tc_ipt.h     |  4 ++--
 include/net/tc_act/tc_mirred.h  |  4 ++--
 include/net/tc_act/tc_nat.h     |  4 ++--
 include/net/tc_act/tc_pedit.h   |  4 ++--
 include/net/tc_act/tc_skbedit.h |  4 ++--
 net/sched/act_api.c             | 42 ++++++++++++++++++++++++++++-------------
 net/sched/act_csum.c            | 24 ++++++++---------------
 net/sched/act_gact.c            | 27 ++++++++------------------
 net/sched/act_ipt.c             | 39 ++++++++++++++------------------------
 net/sched/act_mirred.c          | 32 +++++++++++--------------------
 net/sched/act_nat.c             | 25 ++++++++----------------
 net/sched/act_pedit.c           | 25 ++++++++++--------------
 net/sched/act_simple.c          | 39 +++++++++++++-------------------------
 net/sched/act_skbedit.c         | 29 +++++++++-------------------
 18 files changed, 133 insertions(+), 197 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 3b76a30..f2b5cb3 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -100,16 +100,14 @@ struct tc_action_ops {
 };
 
 int tcf_hash_search(struct tc_action *a, u32 index);
-void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo);
-int tcf_hash_release(struct tcf_common *p, int bind,
-		     struct tcf_hashinfo *hinfo);
+void tcf_hash_destroy(struct tc_action *a);
+int tcf_hash_release(struct tc_action *a, int bind);
 u32 tcf_hash_new_index(struct tcf_hashinfo *hinfo);
-struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a,
-				  int bind);
-struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est,
-				   struct tc_action *a, int size,
-				   int bind);
-void tcf_hash_insert(struct tcf_common *p, struct tcf_hashinfo *hinfo);
+int tcf_hash_check(u32 index, struct tc_action *a, int bind);
+int tcf_hash_create(u32 index, struct nlattr *est, struct tc_action *a,
+		    int size, int bind);
+void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est);
+void tcf_hash_insert(struct tc_action *a);
 
 int tcf_register_action(struct tc_action_ops *a);
 int tcf_unregister_action(struct tc_action_ops *a);
diff --git a/include/net/tc_act/tc_csum.h b/include/net/tc_act/tc_csum.h
index 9e8710b..fa8f5fa 100644
--- a/include/net/tc_act/tc_csum.h
+++ b/include/net/tc_act/tc_csum.h
@@ -9,7 +9,7 @@ struct tcf_csum {
 
 	u32 update_flags;
 };
-#define to_tcf_csum(pc) \
-	container_of(pc,struct tcf_csum,common)
+#define to_tcf_csum(a) \
+	container_of(a->priv,struct tcf_csum,common)
 
 #endif /* __NET_TC_CSUM_H */
diff --git a/include/net/tc_act/tc_defact.h b/include/net/tc_act/tc_defact.h
index 65f024b..9763dcb 100644
--- a/include/net/tc_act/tc_defact.h
+++ b/include/net/tc_act/tc_defact.h
@@ -8,7 +8,7 @@ struct tcf_defact {
 	u32     		tcfd_datalen;
 	void    		*tcfd_defdata;
 };
-#define to_defact(pc) \
-	container_of(pc, struct tcf_defact, common)
+#define to_defact(a) \
+	container_of(a->priv, struct tcf_defact, common)
 
 #endif /* __NET_TC_DEF_H */
diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
index 9e3f676..9fc9b57 100644
--- a/include/net/tc_act/tc_gact.h
+++ b/include/net/tc_act/tc_gact.h
@@ -11,7 +11,7 @@ struct tcf_gact {
         int			tcfg_paction;
 #endif
 };
-#define to_gact(pc) \
-	container_of(pc, struct tcf_gact, common)
+#define to_gact(a) \
+	container_of(a->priv, struct tcf_gact, common)
 
 #endif /* __NET_TC_GACT_H */
diff --git a/include/net/tc_act/tc_ipt.h b/include/net/tc_act/tc_ipt.h
index f7d25df..c0f4193 100644
--- a/include/net/tc_act/tc_ipt.h
+++ b/include/net/tc_act/tc_ipt.h
@@ -11,7 +11,7 @@ struct tcf_ipt {
 	char			*tcfi_tname;
 	struct xt_entry_target	*tcfi_t;
 };
-#define to_ipt(pc) \
-	container_of(pc, struct tcf_ipt, common)
+#define to_ipt(a) \
+	container_of(a->priv, struct tcf_ipt, common)
 
 #endif /* __NET_TC_IPT_H */
diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index cfe2943..4dd77a1 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -11,7 +11,7 @@ struct tcf_mirred {
 	struct net_device	*tcfm_dev;
 	struct list_head	tcfm_list;
 };
-#define to_mirred(pc) \
-	container_of(pc, struct tcf_mirred, common)
+#define to_mirred(a) \
+	container_of(a->priv, struct tcf_mirred, common)
 
 #endif /* __NET_TC_MIR_H */
diff --git a/include/net/tc_act/tc_nat.h b/include/net/tc_act/tc_nat.h
index 4a691f3..63d8e9c 100644
--- a/include/net/tc_act/tc_nat.h
+++ b/include/net/tc_act/tc_nat.h
@@ -13,9 +13,9 @@ struct tcf_nat {
 	u32 flags;
 };
 
-static inline struct tcf_nat *to_tcf_nat(struct tcf_common *pc)
+static inline struct tcf_nat *to_tcf_nat(struct tc_action *a)
 {
-	return container_of(pc, struct tcf_nat, common);
+	return container_of(a->priv, struct tcf_nat, common);
 }
 
 #endif /* __NET_TC_NAT_H */
diff --git a/include/net/tc_act/tc_pedit.h b/include/net/tc_act/tc_pedit.h
index e6f6e15..5b80998 100644
--- a/include/net/tc_act/tc_pedit.h
+++ b/include/net/tc_act/tc_pedit.h
@@ -9,7 +9,7 @@ struct tcf_pedit {
 	unsigned char		tcfp_flags;
 	struct tc_pedit_key	*tcfp_keys;
 };
-#define to_pedit(pc) \
-	container_of(pc, struct tcf_pedit, common)
+#define to_pedit(a) \
+	container_of(a->priv, struct tcf_pedit, common)
 
 #endif /* __NET_TC_PED_H */
diff --git a/include/net/tc_act/tc_skbedit.h b/include/net/tc_act/tc_skbedit.h
index dd5d86f..0df9a0d 100644
--- a/include/net/tc_act/tc_skbedit.h
+++ b/include/net/tc_act/tc_skbedit.h
@@ -29,7 +29,7 @@ struct tcf_skbedit {
 	u16			queue_mapping;
 	/* XXX: 16-bit pad here? */
 };
-#define to_skbedit(pc) \
-	container_of(pc, struct tcf_skbedit, common)
+#define to_skbedit(a) \
+	container_of(a->priv, struct tcf_skbedit, common)
 
 #endif /* __NET_TC_SKBEDIT_H */
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 72bdc71..91b489e 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -27,8 +27,11 @@
 #include <net/act_api.h>
 #include <net/netlink.h>
 
-void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo)
+void tcf_hash_destroy(struct tc_action *a)
 {
+	struct tcf_common *p = a->priv;
+	struct tcf_hashinfo *hinfo = a->ops->hinfo;
+
 	spin_lock_bh(&hinfo->lock);
 	hlist_del(&p->tcfc_head);
 	spin_unlock_bh(&hinfo->lock);
@@ -42,9 +45,9 @@ void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo)
 }
 EXPORT_SYMBOL(tcf_hash_destroy);
 
-int tcf_hash_release(struct tcf_common *p, int bind,
-		     struct tcf_hashinfo *hinfo)
+int tcf_hash_release(struct tc_action *a, int bind)
 {
+	struct tcf_common *p = a->priv;
 	int ret = 0;
 
 	if (p) {
@@ -53,7 +56,7 @@ int tcf_hash_release(struct tcf_common *p, int bind,
 
 		p->tcfc_refcnt--;
 		if (p->tcfc_bindcnt <= 0 && p->tcfc_refcnt <= 0) {
-			tcf_hash_destroy(p, hinfo);
+			tcf_hash_destroy(a);
 			ret = 1;
 		}
 	}
@@ -127,7 +130,7 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a)
 	for (i = 0; i < (hinfo->hmask + 1); i++) {
 		head = &hinfo->htab[tcf_hash(i, hinfo->hmask)];
 		hlist_for_each_entry_safe(p, n, head, tcfc_head) {
-			if (ACT_P_DELETED == tcf_hash_release(p, 0, hinfo)) {
+			if (ACT_P_DELETED == tcf_hash_release(a, 0)) {
 				module_put(a->ops->owner);
 				n_i++;
 			}
@@ -198,7 +201,7 @@ int tcf_hash_search(struct tc_action *a, u32 index)
 }
 EXPORT_SYMBOL(tcf_hash_search);
 
-struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a, int bind)
+int tcf_hash_check(u32 index, struct tc_action *a, int bind)
 {
 	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	struct tcf_common *p = NULL;
@@ -207,19 +210,30 @@ struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a, int bind)
 			p->tcfc_bindcnt++;
 		p->tcfc_refcnt++;
 		a->priv = p;
+		return 1;
 	}
-	return p;
+	return 0;
 }
 EXPORT_SYMBOL(tcf_hash_check);
 
-struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est,
-				   struct tc_action *a, int size, int bind)
+void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est)
+{
+	struct tcf_common *pc = a->priv;
+	if (est)
+		gen_kill_estimator(&pc->tcfc_bstats,
+				   &pc->tcfc_rate_est);
+	kfree_rcu(pc, tcfc_rcu);
+}
+EXPORT_SYMBOL(tcf_hash_cleanup);
+
+int tcf_hash_create(u32 index, struct nlattr *est, struct tc_action *a,
+		    int size, int bind)
 {
 	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	struct tcf_common *p = kzalloc(size, GFP_KERNEL);
 
 	if (unlikely(!p))
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 	p->tcfc_refcnt = 1;
 	if (bind)
 		p->tcfc_bindcnt = 1;
@@ -234,17 +248,19 @@ struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est,
 					    &p->tcfc_lock, est);
 		if (err) {
 			kfree(p);
-			return ERR_PTR(err);
+			return err;
 		}
 	}
 
 	a->priv = (void *) p;
-	return p;
+	return 0;
 }
 EXPORT_SYMBOL(tcf_hash_create);
 
-void tcf_hash_insert(struct tcf_common *p, struct tcf_hashinfo *hinfo)
+void tcf_hash_insert(struct tc_action *a)
 {
+	struct tcf_common *p = a->priv;
+	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	unsigned int h = tcf_hash(p->tcfc_index, hinfo->hmask);
 
 	spin_lock_bh(&hinfo->lock);
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index a9a3185..8e75a08 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -48,7 +48,6 @@ static int tcf_csum_init(struct net *n, struct nlattr *nla, struct nlattr *est,
 {
 	struct nlattr *tb[TCA_CSUM_MAX + 1];
 	struct tc_csum *parm;
-	struct tcf_common *pc;
 	struct tcf_csum *p;
 	int ret = 0, err;
 
@@ -63,38 +62,31 @@ static int tcf_csum_init(struct net *n, struct nlattr *nla, struct nlattr *est,
 		return -EINVAL;
 	parm = nla_data(tb[TCA_CSUM_PARMS]);
 
-	pc = tcf_hash_check(parm->index, a, bind);
-	if (!pc) {
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind);
-		if (IS_ERR(pc))
-			return PTR_ERR(pc);
+	if (!tcf_hash_check(parm->index, a, bind)) {
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*p), bind);
+		if (ret)
+			return ret;
 		ret = ACT_P_CREATED;
 	} else {
 		if (bind)/* dont override defaults */
 			return 0;
-		tcf_hash_release(pc, bind, a->ops->hinfo);
+		tcf_hash_release(a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
 
-	p = to_tcf_csum(pc);
+	p = to_tcf_csum(a);
 	spin_lock_bh(&p->tcf_lock);
 	p->tcf_action = parm->action;
 	p->update_flags = parm->update_flags;
 	spin_unlock_bh(&p->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, a->ops->hinfo);
+		tcf_hash_insert(a);
 
 	return ret;
 }
 
-static int tcf_csum_cleanup(struct tc_action *a, int bind)
-{
-	struct tcf_csum *p = a->priv;
-	return tcf_hash_release(&p->common, bind, &csum_hash_info);
-}
-
 /**
  * tcf_csum_skb_nextlayer - Get next layer pointer
  * @skb: sk_buff to use
@@ -575,7 +567,7 @@ static struct tc_action_ops act_csum_ops = {
 	.owner		= THIS_MODULE,
 	.act		= tcf_csum,
 	.dump		= tcf_csum_dump,
-	.cleanup	= tcf_csum_cleanup,
+	.cleanup	= tcf_hash_release,
 	.init		= tcf_csum_init,
 };
 
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 5f05ecf..47148fa 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -57,7 +57,6 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 	struct nlattr *tb[TCA_GACT_MAX + 1];
 	struct tc_gact *parm;
 	struct tcf_gact *gact;
-	struct tcf_common *pc;
 	int ret = 0;
 	int err;
 #ifdef CONFIG_GACT_PROB
@@ -86,21 +85,20 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 	}
 #endif
 
-	pc = tcf_hash_check(parm->index, a, bind);
-	if (!pc) {
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*gact), bind);
-		if (IS_ERR(pc))
-			return PTR_ERR(pc);
+	if (!tcf_hash_check(parm->index, a, bind)) {
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*gact), bind);
+		if (ret)
+			return ret;
 		ret = ACT_P_CREATED;
 	} else {
 		if (bind)/* dont override defaults */
 			return 0;
-		tcf_hash_release(pc, bind, a->ops->hinfo);
+		tcf_hash_release(a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
 
-	gact = to_gact(pc);
+	gact = to_gact(a);
 
 	spin_lock_bh(&gact->tcf_lock);
 	gact->tcf_action = parm->action;
@@ -113,19 +111,10 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 #endif
 	spin_unlock_bh(&gact->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, a->ops->hinfo);
+		tcf_hash_insert(a);
 	return ret;
 }
 
-static int tcf_gact_cleanup(struct tc_action *a, int bind)
-{
-	struct tcf_gact *gact = a->priv;
-
-	if (gact)
-		return tcf_hash_release(&gact->common, bind, a->ops->hinfo);
-	return 0;
-}
-
 static int tcf_gact(struct sk_buff *skb, const struct tc_action *a,
 		    struct tcf_result *res)
 {
@@ -197,7 +186,7 @@ static struct tc_action_ops act_gact_ops = {
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_gact,
 	.dump		=	tcf_gact_dump,
-	.cleanup	=	tcf_gact_cleanup,
+	.cleanup	=	tcf_hash_release,
 	.init		=	tcf_gact_init,
 };
 
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index a22602b..f0545fb 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -69,8 +69,9 @@ static void ipt_destroy_target(struct xt_entry_target *t)
 	module_put(par.target->me);
 }
 
-static int tcf_ipt_release(struct tcf_ipt *ipt, int bind)
+static int tcf_ipt_release(struct tc_action *a, int bind)
 {
+	struct tcf_ipt *ipt = to_ipt(a);
 	int ret = 0;
 	if (ipt) {
 		if (bind)
@@ -80,7 +81,7 @@ static int tcf_ipt_release(struct tcf_ipt *ipt, int bind)
 			ipt_destroy_target(ipt->tcfi_t);
 			kfree(ipt->tcfi_tname);
 			kfree(ipt->tcfi_t);
-			tcf_hash_destroy(&ipt->common, &ipt_hash_info);
+			tcf_hash_destroy(a);
 			ret = ACT_P_DELETED;
 		}
 	}
@@ -99,7 +100,6 @@ static int tcf_ipt_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 {
 	struct nlattr *tb[TCA_IPT_MAX + 1];
 	struct tcf_ipt *ipt;
-	struct tcf_common *pc;
 	struct xt_entry_target *td, *t;
 	char *tname;
 	int ret = 0, err;
@@ -125,21 +125,20 @@ static int tcf_ipt_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	if (tb[TCA_IPT_INDEX] != NULL)
 		index = nla_get_u32(tb[TCA_IPT_INDEX]);
 
-	pc = tcf_hash_check(index, a, bind);
-	if (!pc) {
-		pc = tcf_hash_create(index, est, a, sizeof(*ipt), bind);
-		if (IS_ERR(pc))
-			return PTR_ERR(pc);
+	if (!tcf_hash_check(index, a, bind) ) {
+		ret = tcf_hash_create(index, est, a, sizeof(*ipt), bind);
+		if (ret)
+			return ret;
 		ret = ACT_P_CREATED;
 	} else {
 		if (bind)/* dont override defaults */
 			return 0;
-		tcf_ipt_release(to_ipt(pc), bind);
+		tcf_ipt_release(a, bind);
 
 		if (!ovr)
 			return -EEXIST;
 	}
-	ipt = to_ipt(pc);
+	ipt = to_ipt(a);
 
 	hook = nla_get_u32(tb[TCA_IPT_HOOK]);
 
@@ -170,7 +169,7 @@ static int tcf_ipt_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	ipt->tcfi_hook  = hook;
 	spin_unlock_bh(&ipt->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, a->ops->hinfo);
+		tcf_hash_insert(a);
 	return ret;
 
 err3:
@@ -178,21 +177,11 @@ err3:
 err2:
 	kfree(tname);
 err1:
-	if (ret == ACT_P_CREATED) {
-		if (est)
-			gen_kill_estimator(&pc->tcfc_bstats,
-					   &pc->tcfc_rate_est);
-		kfree_rcu(pc, tcfc_rcu);
-	}
+	if (ret == ACT_P_CREATED)
+		tcf_hash_cleanup(a, est);
 	return err;
 }
 
-static int tcf_ipt_cleanup(struct tc_action *a, int bind)
-{
-	struct tcf_ipt *ipt = a->priv;
-	return tcf_ipt_release(ipt, bind);
-}
-
 static int tcf_ipt(struct sk_buff *skb, const struct tc_action *a,
 		   struct tcf_result *res)
 {
@@ -290,7 +279,7 @@ static struct tc_action_ops act_ipt_ops = {
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_ipt,
 	.dump		=	tcf_ipt_dump,
-	.cleanup	=	tcf_ipt_cleanup,
+	.cleanup	=	tcf_ipt_release,
 	.init		=	tcf_ipt_init,
 };
 
@@ -302,7 +291,7 @@ static struct tc_action_ops act_xt_ops = {
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_ipt,
 	.dump		=	tcf_ipt_dump,
-	.cleanup	=	tcf_ipt_cleanup,
+	.cleanup	=	tcf_ipt_release,
 	.init		=	tcf_ipt_init,
 };
 
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index f1fb5bc..f94a58f 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -33,8 +33,9 @@
 static LIST_HEAD(mirred_list);
 static struct tcf_hashinfo mirred_hash_info;
 
-static int tcf_mirred_release(struct tcf_mirred *m, int bind)
+static int tcf_mirred_release(struct tc_action *a, int bind)
 {
+	struct tcf_mirred *m = to_mirred(a);
 	if (m) {
 		if (bind)
 			m->tcf_bindcnt--;
@@ -43,7 +44,7 @@ static int tcf_mirred_release(struct tcf_mirred *m, int bind)
 			list_del(&m->tcfm_list);
 			if (m->tcfm_dev)
 				dev_put(m->tcfm_dev);
-			tcf_hash_destroy(&m->common, &mirred_hash_info);
+			tcf_hash_destroy(a);
 			return 1;
 		}
 	}
@@ -61,7 +62,6 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	struct nlattr *tb[TCA_MIRRED_MAX + 1];
 	struct tc_mirred *parm;
 	struct tcf_mirred *m;
-	struct tcf_common *pc;
 	struct net_device *dev;
 	int ret, ok_push = 0;
 
@@ -101,21 +101,20 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		dev = NULL;
 	}
 
-	pc = tcf_hash_check(parm->index, a, bind);
-	if (!pc) {
+	if (!tcf_hash_check(parm->index, a, bind)) {
 		if (dev == NULL)
 			return -EINVAL;
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*m), bind);
-		if (IS_ERR(pc))
-			return PTR_ERR(pc);
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*m), bind);
+		if (ret)
+			return ret;
 		ret = ACT_P_CREATED;
 	} else {
 		if (!ovr) {
-			tcf_mirred_release(to_mirred(pc), bind);
+			tcf_mirred_release(a, bind);
 			return -EEXIST;
 		}
 	}
-	m = to_mirred(pc);
+	m = to_mirred(a);
 
 	spin_lock_bh(&m->tcf_lock);
 	m->tcf_action = parm->action;
@@ -131,21 +130,12 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	spin_unlock_bh(&m->tcf_lock);
 	if (ret == ACT_P_CREATED) {
 		list_add(&m->tcfm_list, &mirred_list);
-		tcf_hash_insert(pc, a->ops->hinfo);
+		tcf_hash_insert(a);
 	}
 
 	return ret;
 }
 
-static int tcf_mirred_cleanup(struct tc_action *a, int bind)
-{
-	struct tcf_mirred *m = a->priv;
-
-	if (m)
-		return tcf_mirred_release(m, bind);
-	return 0;
-}
-
 static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 		      struct tcf_result *res)
 {
@@ -260,7 +250,7 @@ static struct tc_action_ops act_mirred_ops = {
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_mirred,
 	.dump		=	tcf_mirred_dump,
-	.cleanup	=	tcf_mirred_cleanup,
+	.cleanup	=	tcf_mirred_release,
 	.init		=	tcf_mirred_init,
 };
 
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 5fc1364..c8d1843 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -44,7 +44,6 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	struct tc_nat *parm;
 	int ret = 0, err;
 	struct tcf_nat *p;
-	struct tcf_common *pc;
 
 	if (nla == NULL)
 		return -EINVAL;
@@ -57,20 +56,19 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 		return -EINVAL;
 	parm = nla_data(tb[TCA_NAT_PARMS]);
 
-	pc = tcf_hash_check(parm->index, a, bind);
-	if (!pc) {
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind);
-		if (IS_ERR(pc))
-			return PTR_ERR(pc);
+	if (!tcf_hash_check(parm->index, a, bind)) {
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*p), bind);
+		if (ret)
+			return ret;
 		ret = ACT_P_CREATED;
 	} else {
 		if (bind)
 			return 0;
-		tcf_hash_release(pc, bind, a->ops->hinfo);
+		tcf_hash_release(a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
-	p = to_tcf_nat(pc);
+	p = to_tcf_nat(a);
 
 	spin_lock_bh(&p->tcf_lock);
 	p->old_addr = parm->old_addr;
@@ -82,18 +80,11 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	spin_unlock_bh(&p->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, a->ops->hinfo);
+		tcf_hash_insert(a);
 
 	return ret;
 }
 
-static int tcf_nat_cleanup(struct tc_action *a, int bind)
-{
-	struct tcf_nat *p = a->priv;
-
-	return tcf_hash_release(&p->common, bind, &nat_hash_info);
-}
-
 static int tcf_nat(struct sk_buff *skb, const struct tc_action *a,
 		   struct tcf_result *res)
 {
@@ -299,7 +290,7 @@ static struct tc_action_ops act_nat_ops = {
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_nat,
 	.dump		=	tcf_nat_dump,
-	.cleanup	=	tcf_nat_cleanup,
+	.cleanup	=	tcf_hash_release,
 	.init		=	tcf_nat_init,
 };
 
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 142ff73..75f08e4 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -39,7 +39,6 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 	struct tc_pedit *parm;
 	int ret = 0, err;
 	struct tcf_pedit *p;
-	struct tcf_common *pc;
 	struct tc_pedit_key *keys = NULL;
 	int ksize;
 
@@ -57,26 +56,22 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 	if (nla_len(tb[TCA_PEDIT_PARMS]) < sizeof(*parm) + ksize)
 		return -EINVAL;
 
-	pc = tcf_hash_check(parm->index, a, bind);
-	if (!pc) {
+	if (!tcf_hash_check(parm->index, a, bind)) {
 		if (!parm->nkeys)
 			return -EINVAL;
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind);
-		if (IS_ERR(pc))
-			return PTR_ERR(pc);
-		p = to_pedit(pc);
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*p), bind);
+		if (ret)
+			return ret;
+		p = to_pedit(a);
 		keys = kmalloc(ksize, GFP_KERNEL);
 		if (keys == NULL) {
-			if (est)
-				gen_kill_estimator(&pc->tcfc_bstats,
-						   &pc->tcfc_rate_est);
-			kfree_rcu(pc, tcfc_rcu);
+			tcf_hash_cleanup(a, est);
 			return -ENOMEM;
 		}
 		ret = ACT_P_CREATED;
 	} else {
-		p = to_pedit(pc);
-		tcf_hash_release(pc, bind, a->ops->hinfo);
+		p = to_pedit(a);
+		tcf_hash_release(a, bind);
 		if (bind)
 			return 0;
 		if (!ovr)
@@ -100,7 +95,7 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 	memcpy(p->tcfp_keys, parm->keys, ksize);
 	spin_unlock_bh(&p->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, a->ops->hinfo);
+		tcf_hash_insert(a);
 	return ret;
 }
 
@@ -110,7 +105,7 @@ static int tcf_pedit_cleanup(struct tc_action *a, int bind)
 
 	if (p) {
 		struct tc_pedit_key *keys = p->tcfp_keys;
-		if (tcf_hash_release(&p->common, bind, &pedit_hash_info)) {
+		if (tcf_hash_release(a, bind)) {
 			kfree(keys);
 			return 1;
 		}
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 745d0d5..e52ee06 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -47,8 +47,9 @@ static int tcf_simp(struct sk_buff *skb, const struct tc_action *a,
 	return d->tcf_action;
 }
 
-static int tcf_simp_release(struct tcf_defact *d, int bind)
+static int tcf_simp_release(struct tc_action *a, int bind)
 {
+	struct tcf_defact *d = to_defact(a);
 	int ret = 0;
 	if (d) {
 		if (bind)
@@ -56,7 +57,7 @@ static int tcf_simp_release(struct tcf_defact *d, int bind)
 		d->tcf_refcnt--;
 		if (d->tcf_bindcnt <= 0 && d->tcf_refcnt <= 0) {
 			kfree(d->tcfd_defdata);
-			tcf_hash_destroy(&d->common, &simp_hash_info);
+			tcf_hash_destroy(a);
 			ret = 1;
 		}
 	}
@@ -94,7 +95,6 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	struct nlattr *tb[TCA_DEF_MAX + 1];
 	struct tc_defact *parm;
 	struct tcf_defact *d;
-	struct tcf_common *pc;
 	char *defdata;
 	int ret = 0, err;
 
@@ -114,29 +114,25 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	parm = nla_data(tb[TCA_DEF_PARMS]);
 	defdata = nla_data(tb[TCA_DEF_DATA]);
 
-	pc = tcf_hash_check(parm->index, a, bind);
-	if (!pc) {
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind);
-		if (IS_ERR(pc))
-			return PTR_ERR(pc);
+	if (!tcf_hash_check(parm->index, a, bind)) {
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*d), bind);
+		if (ret)
+			return ret;
 
-		d = to_defact(pc);
+		d = to_defact(a);
 		ret = alloc_defdata(d, defdata);
 		if (ret < 0) {
-			if (est)
-				gen_kill_estimator(&pc->tcfc_bstats,
-						   &pc->tcfc_rate_est);
-			kfree_rcu(pc, tcfc_rcu);
+			tcf_hash_cleanup(a, est);
 			return ret;
 		}
 		d->tcf_action = parm->action;
 		ret = ACT_P_CREATED;
 	} else {
-		d = to_defact(pc);
+		d = to_defact(a);
 
 		if (bind)
 			return 0;
-		tcf_simp_release(d, bind);
+		tcf_simp_release(a, bind);
 		if (!ovr)
 			return -EEXIST;
 
@@ -144,19 +140,10 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	}
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, a->ops->hinfo);
+		tcf_hash_insert(a);
 	return ret;
 }
 
-static int tcf_simp_cleanup(struct tc_action *a, int bind)
-{
-	struct tcf_defact *d = a->priv;
-
-	if (d)
-		return tcf_simp_release(d, bind);
-	return 0;
-}
-
 static int tcf_simp_dump(struct sk_buff *skb, struct tc_action *a,
 			 int bind, int ref)
 {
@@ -193,7 +180,7 @@ static struct tc_action_ops act_simp_ops = {
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_simp,
 	.dump		=	tcf_simp_dump,
-	.cleanup	=	tcf_simp_cleanup,
+	.cleanup	=	tcf_simp_release,
 	.init		=	tcf_simp_init,
 };
 
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index bedbe5b..68ab57b 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -65,7 +65,6 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 	struct nlattr *tb[TCA_SKBEDIT_MAX + 1];
 	struct tc_skbedit *parm;
 	struct tcf_skbedit *d;
-	struct tcf_common *pc;
 	u32 flags = 0, *priority = NULL, *mark = NULL;
 	u16 *queue_mapping = NULL;
 	int ret = 0, err;
@@ -100,19 +99,18 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 
 	parm = nla_data(tb[TCA_SKBEDIT_PARMS]);
 
-	pc = tcf_hash_check(parm->index, a, bind);
-	if (!pc) {
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind);
-		if (IS_ERR(pc))
-			return PTR_ERR(pc);
+	if (!tcf_hash_check(parm->index, a, bind)) {
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*d), bind);
+		if (ret)
+			return ret;
 
-		d = to_skbedit(pc);
+		d = to_skbedit(a);
 		ret = ACT_P_CREATED;
 	} else {
-		d = to_skbedit(pc);
+		d = to_skbedit(a);
 		if (bind)
 			return 0;
-		tcf_hash_release(pc, bind, a->ops->hinfo);
+		tcf_hash_release(a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -132,19 +130,10 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 	spin_unlock_bh(&d->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, a->ops->hinfo);
+		tcf_hash_insert(a);
 	return ret;
 }
 
-static int tcf_skbedit_cleanup(struct tc_action *a, int bind)
-{
-	struct tcf_skbedit *d = a->priv;
-
-	if (d)
-		return tcf_hash_release(&d->common, bind, &skbedit_hash_info);
-	return 0;
-}
-
 static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 			    int bind, int ref)
 {
@@ -192,7 +181,7 @@ static struct tc_action_ops act_skbedit_ops = {
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_skbedit,
 	.dump		=	tcf_skbedit_dump,
-	.cleanup	=	tcf_skbedit_cleanup,
+	.cleanup	=	tcf_hash_release,
 	.init		=	tcf_skbedit_init,
 };
 
-- 
1.8.3.1
