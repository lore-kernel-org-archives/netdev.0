From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 05/12] net: sched: cls_flow use RCU
Date: Fri, 10 Jan 2014 01:39:05 -0800
Message-ID: <20140110093903.7193.29717.stgit@nitbit.x32>
References: <20140110092041.7193.5952.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:55095 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbaAJJja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 04:39:30 -0500
Received: by mail-oa0-f51.google.com with SMTP id m1so4737147oag.38
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 01:39:29 -0800 (PST)
In-Reply-To: <20140110092041.7193.5952.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_flow.c |  145 +++++++++++++++++++++++++++++---------------------
 1 file changed, 84 insertions(+), 61 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index dfd18a5..632bf48 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -34,12 +34,15 @@
 
 struct flow_head {
 	struct list_head	filters;
+	struct rcu_head		rcu;
 };
 
 struct flow_filter {
 	struct list_head	list;
+	struct rcu_head		rcu;
 	struct tcf_exts		exts;
 	struct tcf_ematch_tree	ematches;
+	struct tcf_proto	*tp;
 	struct timer_list	perturb_timer;
 	u32			perturb_period;
 	u32			handle;
@@ -276,14 +279,14 @@ static u32 flow_key_get(struct sk_buff *skb, int key, struct flow_keys *flow)
 static int flow_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			 struct tcf_result *res)
 {
-	struct flow_head *head = tp->root;
+	struct flow_head *head = rcu_dereference_bh(tp->root);
 	struct flow_filter *f;
 	u32 keymask;
 	u32 classid;
 	unsigned int n, key;
 	int r;
 
-	list_for_each_entry(f, &head->filters, list) {
+	list_for_each_entry_rcu(f, &head->filters, list) {
 		u32 keys[FLOW_KEY_MAX + 1];
 		struct flow_keys flow_keys;
 
@@ -346,13 +349,23 @@ static const struct nla_policy flow_policy[TCA_FLOW_MAX + 1] = {
 	[TCA_FLOW_PERTURB]	= { .type = NLA_U32 },
 };
 
+static void flow_destroy_filter(struct rcu_head *head)
+{
+	struct flow_filter *f = container_of(head, struct flow_filter, rcu);
+
+	del_timer_sync(&f->perturb_timer);
+	tcf_exts_destroy(f->tp, &f->exts);
+	tcf_em_tree_destroy(f->tp, &f->ematches);
+	kfree(f);
+}
+
 static int flow_change(struct net *net, struct sk_buff *in_skb,
 		       struct tcf_proto *tp, unsigned long base,
 		       u32 handle, struct nlattr **tca,
 		       unsigned long *arg)
 {
-	struct flow_head *head = tp->root;
-	struct flow_filter *f;
+	struct flow_head *head = rtnl_dereference(tp->root);
+	struct flow_filter *fold, *fnew;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_FLOW_MAX + 1];
 	struct tcf_exts e;
@@ -401,20 +414,42 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		goto err1;
 
-	f = (struct flow_filter *)*arg;
-	if (f != NULL) {
+	err = -ENOBUFS;
+	fnew = kzalloc(sizeof(*fnew), GFP_KERNEL);
+	if (!fnew)
+		goto err2;
+
+	fold = (struct flow_filter *)*arg;
+	if (fold) {
 		err = -EINVAL;
-		if (f->handle != handle && handle)
+		if (fold->handle != handle && handle)
 			goto err2;
 
-		mode = f->mode;
+		/* Copy fold into fnew */
+		fnew->handle = fold->handle;
+		fnew->keymask = fold->keymask;
+		fnew->tp = fold->tp;
+
+		fnew->handle = fold->handle;
+		fnew->nkeys = fold->nkeys;
+		fnew->keymask = fold->keymask;
+		fnew->mode = fold->mode;
+		fnew->mask = fold->mask;
+		fnew->xor = fold->xor;
+		fnew->rshift = fold->rshift;
+		fnew->addend = fold->addend;
+		fnew->divisor = fold->divisor;
+		fnew->baseclass = fold->baseclass;
+		fnew->hashrnd = fold->hashrnd;
+
+		mode = fold->mode;
 		if (tb[TCA_FLOW_MODE])
 			mode = nla_get_u32(tb[TCA_FLOW_MODE]);
 		if (mode != FLOW_MODE_HASH && nkeys > 1)
 			goto err2;
 
 		if (mode == FLOW_MODE_HASH)
-			perturb_period = f->perturb_period;
+			perturb_period = fold->perturb_period;
 		if (tb[TCA_FLOW_PERTURB]) {
 			if (mode != FLOW_MODE_HASH)
 				goto err2;
@@ -444,83 +479,70 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 		if (TC_H_MIN(baseclass) == 0)
 			baseclass = TC_H_MAKE(baseclass, 1);
 
-		err = -ENOBUFS;
-		f = kzalloc(sizeof(*f), GFP_KERNEL);
-		if (f == NULL)
-			goto err2;
-
-		f->handle = handle;
-		f->mask	  = ~0U;
-		tcf_exts_init(&f->exts, TCA_FLOW_ACT, TCA_FLOW_POLICE);
-
-		get_random_bytes(&f->hashrnd, 4);
-		f->perturb_timer.function = flow_perturbation;
-		f->perturb_timer.data = (unsigned long)f;
-		init_timer_deferrable(&f->perturb_timer);
+		fnew->handle = handle;
+		fnew->mask  = ~0U;
+		fnew->tp = tp;
+		get_random_bytes(&fnew->hashrnd, 4);
+		tcf_exts_init(&fnew->exts, TCA_FLOW_ACT, TCA_FLOW_POLICE);
 	}
 
-	tcf_exts_change(tp, &f->exts, &e);
-	tcf_em_tree_change(tp, &f->ematches, &t);
+	fnew->perturb_timer.function = flow_perturbation;
+	fnew->perturb_timer.data = (unsigned long)fnew;
+	init_timer_deferrable(&fnew->perturb_timer);
 
-	tcf_tree_lock(tp);
+	tcf_exts_change(tp, &fnew->exts, &e);
+	tcf_em_tree_change(tp, &fnew->ematches, &t);
 
 	if (tb[TCA_FLOW_KEYS]) {
-		f->keymask = keymask;
-		f->nkeys   = nkeys;
+		fnew->keymask = keymask;
+		fnew->nkeys   = nkeys;
 	}
 
-	f->mode = mode;
+	fnew->mode = mode;
 
 	if (tb[TCA_FLOW_MASK])
-		f->mask = nla_get_u32(tb[TCA_FLOW_MASK]);
+		fnew->mask = nla_get_u32(tb[TCA_FLOW_MASK]);
 	if (tb[TCA_FLOW_XOR])
-		f->xor = nla_get_u32(tb[TCA_FLOW_XOR]);
+		fnew->xor = nla_get_u32(tb[TCA_FLOW_XOR]);
 	if (tb[TCA_FLOW_RSHIFT])
-		f->rshift = nla_get_u32(tb[TCA_FLOW_RSHIFT]);
+		fnew->rshift = nla_get_u32(tb[TCA_FLOW_RSHIFT]);
 	if (tb[TCA_FLOW_ADDEND])
-		f->addend = nla_get_u32(tb[TCA_FLOW_ADDEND]);
+		fnew->addend = nla_get_u32(tb[TCA_FLOW_ADDEND]);
 
 	if (tb[TCA_FLOW_DIVISOR])
-		f->divisor = nla_get_u32(tb[TCA_FLOW_DIVISOR]);
+		fnew->divisor = nla_get_u32(tb[TCA_FLOW_DIVISOR]);
 	if (baseclass)
-		f->baseclass = baseclass;
+		fnew->baseclass = baseclass;
 
-	f->perturb_period = perturb_period;
-	del_timer(&f->perturb_timer);
+	fnew->perturb_period = perturb_period;
 	if (perturb_period)
-		mod_timer(&f->perturb_timer, jiffies + perturb_period);
+		mod_timer(&fnew->perturb_timer, jiffies + perturb_period);
 
 	if (*arg == 0)
-		list_add_tail(&f->list, &head->filters);
+		list_add_tail_rcu(&fnew->list, &head->filters);
+	else
+		list_replace_rcu(&fnew->list, &fold->list);
 
-	tcf_tree_unlock(tp);
+	*arg = (unsigned long)fnew;
 
-	*arg = (unsigned long)f;
+	if (fold)
+		call_rcu(&fold->rcu, flow_destroy_filter);
 	return 0;
 
 err2:
 	tcf_em_tree_destroy(tp, &t);
+	kfree(fnew);
 err1:
 	tcf_exts_destroy(tp, &e);
 	return err;
 }
 
-static void flow_destroy_filter(struct tcf_proto *tp, struct flow_filter *f)
-{
-	del_timer_sync(&f->perturb_timer);
-	tcf_exts_destroy(tp, &f->exts);
-	tcf_em_tree_destroy(tp, &f->ematches);
-	kfree(f);
-}
-
 static int flow_delete(struct tcf_proto *tp, unsigned long arg)
 {
 	struct flow_filter *f = (struct flow_filter *)arg;
 
-	tcf_tree_lock(tp);
-	list_del(&f->list);
-	tcf_tree_unlock(tp);
-	flow_destroy_filter(tp, f);
+	list_del_rcu(&f->list);
+	call_rcu(&f->rcu, flow_destroy_filter);
 	return 0;
 }
 
@@ -532,28 +554,29 @@ static int flow_init(struct tcf_proto *tp)
 	if (head == NULL)
 		return -ENOBUFS;
 	INIT_LIST_HEAD(&head->filters);
-	tp->root = head;
+	rcu_assign_pointer(tp->root, head);
 	return 0;
 }
 
 static void flow_destroy(struct tcf_proto *tp)
 {
-	struct flow_head *head = tp->root;
+	struct flow_head *head = rtnl_dereference(tp->root);
 	struct flow_filter *f, *next;
 
 	list_for_each_entry_safe(f, next, &head->filters, list) {
-		list_del(&f->list);
-		flow_destroy_filter(tp, f);
+		list_del_rcu(&f->list);
+		call_rcu(&f->rcu, flow_destroy_filter);
 	}
-	kfree(head);
+	rcu_assign_pointer(tp->root, NULL);
+	kfree_rcu(head, rcu);
 }
 
 static unsigned long flow_get(struct tcf_proto *tp, u32 handle)
 {
-	struct flow_head *head = tp->root;
+	struct flow_head *head = rtnl_dereference(tp->root);
 	struct flow_filter *f;
 
-	list_for_each_entry(f, &head->filters, list)
+	list_for_each_entry_rcu(f, &head->filters, list)
 		if (f->handle == handle)
 			return (unsigned long)f;
 	return 0;
@@ -626,10 +649,10 @@ nla_put_failure:
 
 static void flow_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
-	struct flow_head *head = tp->root;
+	struct flow_head *head = rtnl_dereference(tp->root);
 	struct flow_filter *f;
 
-	list_for_each_entry(f, &head->filters, list) {
+	list_for_each_entry_rcu(f, &head->filters, list) {
 		if (arg->count < arg->skip)
 			goto skip;
 		if (arg->fn(tp, (unsigned long)f, arg) < 0) {
