From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 1/6] net_sched: act: fetch hinfo from a->ops->hinfo
Date: Fri, 17 Jan 2014 11:37:02 -0800
Message-ID: <1389987427-14085-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:40074 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbaAQThV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 14:37:21 -0500
Received: by mail-pa0-f47.google.com with SMTP id kp14so4520227pab.20
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 11:37:21 -0800 (PST)
In-Reply-To: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Every action ops has a pointer to hash info, so we don't need to
hard-code it in each module.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h   |  4 ++--
 net/sched/act_api.c     | 23 +++++++++++------------
 net/sched/act_csum.c    |  9 ++++-----
 net/sched/act_gact.c    | 11 +++++------
 net/sched/act_ipt.c     |  7 +++----
 net/sched/act_mirred.c  |  7 +++----
 net/sched/act_nat.c     |  9 ++++-----
 net/sched/act_pedit.c   |  9 ++++-----
 net/sched/act_police.c  | 18 ++++++++++--------
 net/sched/act_simple.c  |  7 +++----
 net/sched/act_skbedit.c |  9 ++++-----
 11 files changed, 53 insertions(+), 60 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index e171387..ca1dcf5 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -105,10 +105,10 @@ int tcf_hash_release(struct tcf_common *p, int bind,
 		     struct tcf_hashinfo *hinfo);
 u32 tcf_hash_new_index(struct tcf_hashinfo *hinfo);
 struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a,
-				  int bind, struct tcf_hashinfo *hinfo);
+				  int bind);
 struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est,
 				   struct tc_action *a, int size,
-				   int bind, struct tcf_hashinfo *hinfo);
+				   int bind);
 void tcf_hash_insert(struct tcf_common *p, struct tcf_hashinfo *hinfo);
 
 int tcf_register_action(struct tc_action_ops *a);
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 35f89e9..b948253 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -62,8 +62,9 @@ int tcf_hash_release(struct tcf_common *p, int bind,
 EXPORT_SYMBOL(tcf_hash_release);
 
 static int tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
-			   struct tc_action *a, struct tcf_hashinfo *hinfo)
+			   struct tc_action *a)
 {
+	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	struct hlist_head *head;
 	struct tcf_common *p;
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
@@ -109,9 +110,9 @@ nla_put_failure:
 	goto done;
 }
 
-static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a,
-			  struct tcf_hashinfo *hinfo)
+static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a)
 {
+	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	struct hlist_head *head;
 	struct hlist_node *n;
 	struct tcf_common *p;
@@ -145,12 +146,10 @@ nla_put_failure:
 static int tcf_generic_walker(struct sk_buff *skb, struct netlink_callback *cb,
 			      int type, struct tc_action *a)
 {
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
-
 	if (type == RTM_DELACTION) {
-		return tcf_del_walker(skb, a, hinfo);
+		return tcf_del_walker(skb, a);
 	} else if (type == RTM_GETACTION) {
-		return tcf_dump_walker(skb, cb, a, hinfo);
+		return tcf_dump_walker(skb, cb, a);
 	} else {
 		WARN(1, "tcf_generic_walker: unknown action %d\n", type);
 		return -EINVAL;
@@ -199,9 +198,9 @@ static int tcf_hash_search(struct tc_action *a, u32 index)
 	return 0;
 }
 
-struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a, int bind,
-				  struct tcf_hashinfo *hinfo)
+struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a, int bind)
 {
+	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	struct tcf_common *p = NULL;
 	if (index && (p = tcf_hash_lookup(index, hinfo)) != NULL) {
 		if (bind)
@@ -214,9 +213,9 @@ struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a, int bind,
 EXPORT_SYMBOL(tcf_hash_check);
 
 struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est,
-				   struct tc_action *a, int size, int bind,
-				   struct tcf_hashinfo *hinfo)
+				   struct tc_action *a, int size, int bind)
 {
+	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	struct tcf_common *p = kzalloc(size, GFP_KERNEL);
 
 	if (unlikely(!p))
@@ -495,6 +494,7 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 	if (a == NULL)
 		goto err_mod;
 
+	a->ops = a_o;
 	INIT_LIST_HEAD(&a->list);
 	/* backward compatibility for policer */
 	if (name == NULL)
@@ -510,7 +510,6 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 	 */
 	if (err != ACT_P_CREATED)
 		module_put(a_o->owner);
-	a->ops = a_o;
 
 	return a;
 
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index ee28e1c..a9a3185 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -63,17 +63,16 @@ static int tcf_csum_init(struct net *n, struct nlattr *nla, struct nlattr *est,
 		return -EINVAL;
 	parm = nla_data(tb[TCA_CSUM_PARMS]);
 
-	pc = tcf_hash_check(parm->index, a, bind, &csum_hash_info);
+	pc = tcf_hash_check(parm->index, a, bind);
 	if (!pc) {
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind,
-				     &csum_hash_info);
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
 	} else {
 		if (bind)/* dont override defaults */
 			return 0;
-		tcf_hash_release(pc, bind, &csum_hash_info);
+		tcf_hash_release(pc, bind, a->ops->hinfo);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -85,7 +84,7 @@ static int tcf_csum_init(struct net *n, struct nlattr *nla, struct nlattr *est,
 	spin_unlock_bh(&p->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, &csum_hash_info);
+		tcf_hash_insert(pc, a->ops->hinfo);
 
 	return ret;
 }
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 3133307..5f05ecf 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -86,17 +86,16 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 	}
 #endif
 
-	pc = tcf_hash_check(parm->index, a, bind, &gact_hash_info);
+	pc = tcf_hash_check(parm->index, a, bind);
 	if (!pc) {
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*gact),
-				     bind, &gact_hash_info);
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*gact), bind);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
 	} else {
 		if (bind)/* dont override defaults */
 			return 0;
-		tcf_hash_release(pc, bind, &gact_hash_info);
+		tcf_hash_release(pc, bind, a->ops->hinfo);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -114,7 +113,7 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 #endif
 	spin_unlock_bh(&gact->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, &gact_hash_info);
+		tcf_hash_insert(pc, a->ops->hinfo);
 	return ret;
 }
 
@@ -123,7 +122,7 @@ static int tcf_gact_cleanup(struct tc_action *a, int bind)
 	struct tcf_gact *gact = a->priv;
 
 	if (gact)
-		return tcf_hash_release(&gact->common, bind, &gact_hash_info);
+		return tcf_hash_release(&gact->common, bind, a->ops->hinfo);
 	return 0;
 }
 
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index bc9f498..a22602b 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -125,10 +125,9 @@ static int tcf_ipt_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	if (tb[TCA_IPT_INDEX] != NULL)
 		index = nla_get_u32(tb[TCA_IPT_INDEX]);
 
-	pc = tcf_hash_check(index, a, bind, &ipt_hash_info);
+	pc = tcf_hash_check(index, a, bind);
 	if (!pc) {
-		pc = tcf_hash_create(index, est, a, sizeof(*ipt), bind,
-				     &ipt_hash_info);
+		pc = tcf_hash_create(index, est, a, sizeof(*ipt), bind);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
@@ -171,7 +170,7 @@ static int tcf_ipt_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	ipt->tcfi_hook  = hook;
 	spin_unlock_bh(&ipt->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, &ipt_hash_info);
+		tcf_hash_insert(pc, a->ops->hinfo);
 	return ret;
 
 err3:
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 5d05b57..f1fb5bc 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -101,12 +101,11 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		dev = NULL;
 	}
 
-	pc = tcf_hash_check(parm->index, a, bind, &mirred_hash_info);
+	pc = tcf_hash_check(parm->index, a, bind);
 	if (!pc) {
 		if (dev == NULL)
 			return -EINVAL;
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*m), bind,
-				     &mirred_hash_info);
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*m), bind);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
@@ -132,7 +131,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	spin_unlock_bh(&m->tcf_lock);
 	if (ret == ACT_P_CREATED) {
 		list_add(&m->tcfm_list, &mirred_list);
-		tcf_hash_insert(pc, &mirred_hash_info);
+		tcf_hash_insert(pc, a->ops->hinfo);
 	}
 
 	return ret;
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index a49fa23..5fc1364 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -57,17 +57,16 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 		return -EINVAL;
 	parm = nla_data(tb[TCA_NAT_PARMS]);
 
-	pc = tcf_hash_check(parm->index, a, bind, &nat_hash_info);
+	pc = tcf_hash_check(parm->index, a, bind);
 	if (!pc) {
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind,
-				     &nat_hash_info);
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
 	} else {
 		if (bind)
 			return 0;
-		tcf_hash_release(pc, bind, &nat_hash_info);
+		tcf_hash_release(pc, bind, a->ops->hinfo);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -83,7 +82,7 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	spin_unlock_bh(&p->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, &nat_hash_info);
+		tcf_hash_insert(pc, a->ops->hinfo);
 
 	return ret;
 }
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index f361e4e..142ff73 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -57,12 +57,11 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 	if (nla_len(tb[TCA_PEDIT_PARMS]) < sizeof(*parm) + ksize)
 		return -EINVAL;
 
-	pc = tcf_hash_check(parm->index, a, bind, &pedit_hash_info);
+	pc = tcf_hash_check(parm->index, a, bind);
 	if (!pc) {
 		if (!parm->nkeys)
 			return -EINVAL;
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind,
-				     &pedit_hash_info);
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 		p = to_pedit(pc);
@@ -77,7 +76,7 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 		ret = ACT_P_CREATED;
 	} else {
 		p = to_pedit(pc);
-		tcf_hash_release(pc, bind, &pedit_hash_info);
+		tcf_hash_release(pc, bind, a->ops->hinfo);
 		if (bind)
 			return 0;
 		if (!ovr)
@@ -101,7 +100,7 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 	memcpy(p->tcfp_keys, parm->keys, ksize);
 	spin_unlock_bh(&p->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, &pedit_hash_info);
+		tcf_hash_insert(pc, a->ops->hinfo);
 	return ret;
 }
 
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 5ba467b..30d4f4b 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -59,17 +59,18 @@ struct tc_police_compat {
 static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *cb,
 			      int type, struct tc_action *a)
 {
+	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	struct hlist_head *head;
 	struct tcf_common *p;
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
 	struct nlattr *nest;
 
-	spin_lock_bh(&police_hash_info.lock);
+	spin_lock_bh(&hinfo->lock);
 
 	s_i = cb->args[0];
 
 	for (i = 0; i < (POL_TAB_MASK + 1); i++) {
-		head = &police_hash_info.htab[tcf_hash(i, POL_TAB_MASK)];
+		head = &hinfo->htab[tcf_hash(i, POL_TAB_MASK)];
 
 		hlist_for_each_entry_rcu(p, head, tcfc_head) {
 			index++;
@@ -94,7 +95,7 @@ static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *c
 		}
 	}
 done:
-	spin_unlock_bh(&police_hash_info.lock);
+	spin_unlock_bh(&hinfo->lock);
 	if (n_i)
 		cb->args[0] += n_i;
 	return n_i;
@@ -121,6 +122,7 @@ static int tcf_act_police_locate(struct net *net, struct nlattr *nla,
 	struct tc_police *parm;
 	struct tcf_police *police;
 	struct qdisc_rate_table *R_tab = NULL, *P_tab = NULL;
+	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	int size;
 
 	if (nla == NULL)
@@ -140,7 +142,7 @@ static int tcf_act_police_locate(struct net *net, struct nlattr *nla,
 	if (parm->index) {
 		struct tcf_common *pc;
 
-		pc = tcf_hash_lookup(parm->index, &police_hash_info);
+		pc = tcf_hash_lookup(parm->index, hinfo);
 		if (pc != NULL) {
 			a->priv = pc;
 			police = to_police(pc);
@@ -236,11 +238,11 @@ override:
 
 	police->tcfp_t_c = ktime_to_ns(ktime_get());
 	police->tcf_index = parm->index ? parm->index :
-		tcf_hash_new_index(&police_hash_info);
+		tcf_hash_new_index(a->ops->hinfo);
 	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
-	spin_lock_bh(&police_hash_info.lock);
-	hlist_add_head(&police->tcf_head, &police_hash_info.htab[h]);
-	spin_unlock_bh(&police_hash_info.lock);
+	spin_lock_bh(&hinfo->lock);
+	hlist_add_head(&police->tcf_head, &hinfo->htab[h]);
+	spin_unlock_bh(&hinfo->lock);
 
 	a->priv = police;
 	return ret;
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index f7d5406..745d0d5 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -114,10 +114,9 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	parm = nla_data(tb[TCA_DEF_PARMS]);
 	defdata = nla_data(tb[TCA_DEF_DATA]);
 
-	pc = tcf_hash_check(parm->index, a, bind, &simp_hash_info);
+	pc = tcf_hash_check(parm->index, a, bind);
 	if (!pc) {
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind,
-				     &simp_hash_info);
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 
@@ -145,7 +144,7 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	}
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, &simp_hash_info);
+		tcf_hash_insert(pc, a->ops->hinfo);
 	return ret;
 }
 
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 74af461..bedbe5b 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -100,10 +100,9 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 
 	parm = nla_data(tb[TCA_SKBEDIT_PARMS]);
 
-	pc = tcf_hash_check(parm->index, a, bind, &skbedit_hash_info);
+	pc = tcf_hash_check(parm->index, a, bind);
 	if (!pc) {
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind,
-				     &skbedit_hash_info);
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 
@@ -113,7 +112,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		d = to_skbedit(pc);
 		if (bind)
 			return 0;
-		tcf_hash_release(pc, bind, &skbedit_hash_info);
+		tcf_hash_release(pc, bind, a->ops->hinfo);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -133,7 +132,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 	spin_unlock_bh(&d->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(pc, &skbedit_hash_info);
+		tcf_hash_insert(pc, a->ops->hinfo);
 	return ret;
 }
 
-- 
1.8.3.1
