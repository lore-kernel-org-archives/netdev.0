From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 03/12] net: sched: cls_basic use RCU
Date: Fri, 10 Jan 2014 01:38:05 -0800
Message-ID: <20140110093803.7193.43649.stgit@nitbit.x32>
References: <20140110092041.7193.5952.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:58428 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755354AbaAJJi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 04:38:27 -0500
Received: by mail-oa0-f50.google.com with SMTP id l6so4730586oag.37
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 01:38:27 -0800 (PST)
In-Reply-To: <20140110092041.7193.5952.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable basic classifier for RCU.

Dereferencing tp->root may look a bit strange here but it is needed
by my accounting because it is allocated at init time and needs to
be kfree'd at destroy time. However because it may be referenced in
the classify() path we must wait an RCU grace period before free'ing
it. We use kfree_rcu() and rcu_ APIs to enforce this. This pattern
is used in all the classifiers.

Also the hgenerator can be incremented without concern because it
is always incremented under RTNL.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_basic.c |   82 ++++++++++++++++++++++++++++---------------------
 1 file changed, 47 insertions(+), 35 deletions(-)

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index b655203..47c1da2 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -24,6 +24,7 @@
 struct basic_head {
 	u32			hgenerator;
 	struct list_head	flist;
+	struct rcu_head		rcu;
 };
 
 struct basic_filter {
@@ -31,17 +32,20 @@ struct basic_filter {
 	struct tcf_exts		exts;
 	struct tcf_ematch_tree	ematches;
 	struct tcf_result	res;
+	struct tcf_proto	*tp;
 	struct list_head	link;
+	struct rcu_head		rcu;
 };
 
 static int basic_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			  struct tcf_result *res)
 {
 	int r;
-	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_head *head =
+			(struct basic_head *) rcu_dereference_bh(tp->root);
 	struct basic_filter *f;
 
-	list_for_each_entry(f, &head->flist, link) {
+	list_for_each_entry_rcu(f, &head->flist, link) {
 		if (!tcf_em_tree_match(skb, &f->ematches, NULL))
 			continue;
 		*res = f->res;
@@ -56,7 +60,8 @@ static int basic_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 static unsigned long basic_get(struct tcf_proto *tp, u32 handle)
 {
 	unsigned long l = 0UL;
-	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_head *head =
+			(struct basic_head *) rtnl_dereference(tp->root);
 	struct basic_filter *f;
 
 	if (head == NULL)
@@ -81,12 +86,15 @@ static int basic_init(struct tcf_proto *tp)
 	if (head == NULL)
 		return -ENOBUFS;
 	INIT_LIST_HEAD(&head->flist);
-	tp->root = head;
+	rcu_assign_pointer(tp->root, head);
 	return 0;
 }
 
-static void basic_delete_filter(struct tcf_proto *tp, struct basic_filter *f)
+static void basic_delete_filter(struct rcu_head *head)
 {
+	struct basic_filter *f = container_of(head, struct basic_filter, rcu);
+	struct tcf_proto *tp = f->tp;
+
 	tcf_unbind_filter(tp, &f->res);
 	tcf_exts_destroy(tp, &f->exts);
 	tcf_em_tree_destroy(tp, &f->ematches);
@@ -95,27 +103,26 @@ static void basic_delete_filter(struct tcf_proto *tp, struct basic_filter *f)
 
 static void basic_destroy(struct tcf_proto *tp)
 {
-	struct basic_head *head = tp->root;
+	struct basic_head *head = rtnl_dereference(tp->root);
 	struct basic_filter *f, *n;
 
 	list_for_each_entry_safe(f, n, &head->flist, link) {
-		list_del(&f->link);
-		basic_delete_filter(tp, f);
+		list_del_rcu(&f->link);
+		call_rcu(&f->rcu, basic_delete_filter);
 	}
-	kfree(head);
+	rcu_assign_pointer(tp->root, NULL);
+	kfree_rcu(head, rcu);
 }
 
 static int basic_delete(struct tcf_proto *tp, unsigned long arg)
 {
-	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_head *head = rtnl_dereference(tp->root);
 	struct basic_filter *t, *f = (struct basic_filter *) arg;
 
 	list_for_each_entry(t, &head->flist, link)
 		if (t == f) {
-			tcf_tree_lock(tp);
-			list_del(&t->link);
-			tcf_tree_unlock(tp);
-			basic_delete_filter(tp, t);
+			list_del_rcu(&t->link);
+			call_rcu(&t->rcu, basic_delete_filter);
 			return 0;
 		}
 
@@ -152,6 +159,7 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 
 	tcf_exts_change(tp, &f->exts, &e);
 	tcf_em_tree_change(tp, &f->ematches, &t);
+	f->tp = tp;
 
 	return 0;
 errout:
@@ -164,9 +172,10 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 			struct nlattr **tca, unsigned long *arg)
 {
 	int err;
-	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_head *head = rtnl_dereference(tp->root);
 	struct nlattr *tb[TCA_BASIC_MAX + 1];
-	struct basic_filter *f = (struct basic_filter *) *arg;
+	struct basic_filter *fold = (struct basic_filter *) *arg;
+	struct basic_filter *fnew;
 
 	if (tca[TCA_OPTIONS] == NULL)
 		return -EINVAL;
@@ -176,22 +185,23 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
-	if (f != NULL) {
-		if (handle && f->handle != handle)
+	if (fold != NULL) {
+		if (handle && fold->handle != handle)
 			return -EINVAL;
-		return basic_set_parms(net, tp, f, base, tb, tca[TCA_RATE]);
 	}
 
 	err = -ENOBUFS;
-	f = kzalloc(sizeof(*f), GFP_KERNEL);
-	if (f == NULL)
+	fnew = kzalloc(sizeof(*fnew), GFP_KERNEL);
+	if (fnew == NULL)
 		goto errout;
 
-	tcf_exts_init(&f->exts, TCA_BASIC_ACT, TCA_BASIC_POLICE);
+	tcf_exts_init(&fnew->exts, TCA_BASIC_ACT, TCA_BASIC_POLICE);
 	err = -EINVAL;
-	if (handle)
-		f->handle = handle;
-	else {
+	if (handle) {
+		fnew->handle = handle;
+	} else if (fold) {
+		fnew->handle = fold->handle;
+	} else {
 		unsigned int i = 0x80000000;
 		do {
 			if (++head->hgenerator == 0x7FFFFFFF)
@@ -203,29 +213,31 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 			goto errout;
 		}
 
-		f->handle = head->hgenerator;
+		fnew->handle = head->hgenerator;
 	}
 
-	err = basic_set_parms(net, tp, f, base, tb, tca[TCA_RATE]);
+	err = basic_set_parms(net, tp, fnew, base, tb, tca[TCA_RATE]);
 	if (err < 0)
 		goto errout;
 
-	tcf_tree_lock(tp);
-	list_add(&f->link, &head->flist);
-	tcf_tree_unlock(tp);
-	*arg = (unsigned long) f;
+	*arg = (unsigned long) fnew;
+
+	if (fold) {
+		list_replace_rcu(&fold->link, &fnew->link);
+		call_rcu(&fold->rcu, basic_delete_filter);
+	} else {
+		list_add_rcu(&fnew->link, &head->flist);
+	}
 
 	return 0;
 errout:
-	if (*arg == 0UL && f)
-		kfree(f);
-
+	kfree(fnew);
 	return err;
 }
 
 static void basic_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
-	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_head *head = rtnl_dereference(tp->root);
 	struct basic_filter *f;
 
 	list_for_each_entry(f, &head->flist, link) {
