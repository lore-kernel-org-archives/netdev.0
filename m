From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 04/12] net: sched: cls_cgroup use RCU
Date: Fri, 10 Jan 2014 01:38:35 -0800
Message-ID: <20140110093833.7193.88085.stgit@nitbit.x32>
References: <20140110092041.7193.5952.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:54521 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbaAJJi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 04:38:56 -0500
Received: by mail-ob0-f177.google.com with SMTP id vb8so4450638obc.8
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 01:38:56 -0800 (PST)
In-Reply-To: <20140110092041.7193.5952.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make cgroup classifier safe for RCU.

Also drops the calls in the classify routine that were doing a
rcu_read_lock()/rcu_read_unlock(). If the rcu_read_lock() isn't held
entering this routine we have issues with deleting the classifier
chain so remove the unnecessary rcu_read_lock()/rcu_read_unlock()
pair noting all paths AFAIK hold rcu_read_lock.

If there is a case where classify is called without the rcu read lock
then an rcu splat will occur and we can correct it.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_cgroup.c |   65 ++++++++++++++++++++++++++++++------------------
 1 file changed, 41 insertions(+), 24 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index f9d21258..7644912 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -118,17 +118,17 @@ struct cls_cgroup_head {
 	u32			handle;
 	struct tcf_exts		exts;
 	struct tcf_ematch_tree	ematches;
+	struct rcu_head		rcu;
+	struct tcf_proto	*tp;
 };
 
 static int cls_cgroup_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			       struct tcf_result *res)
 {
-	struct cls_cgroup_head *head = tp->root;
+	struct cls_cgroup_head *head = rcu_dereference_bh(tp->root);
 	u32 classid;
 
-	rcu_read_lock();
 	classid = task_cls_state(current)->classid;
-	rcu_read_unlock();
 
 	/*
 	 * Due to the nature of the classifier it is required to ignore all
@@ -176,13 +176,27 @@ static const struct nla_policy cgroup_policy[TCA_CGROUP_MAX + 1] = {
 	[TCA_CGROUP_EMATCHES]	= { .type = NLA_NESTED },
 };
 
+static void cls_cgroup_destroy_rcu(struct rcu_head *root)
+{
+	struct cls_cgroup_head *head = container_of(root,
+						    struct cls_cgroup_head,
+						    rcu);
+
+	if (head) {
+		tcf_exts_destroy(head->tp, &head->exts);
+		tcf_em_tree_destroy(head->tp, &head->ematches);
+		kfree(head);
+	}
+}
+
 static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 			     struct tcf_proto *tp, unsigned long base,
 			     u32 handle, struct nlattr **tca,
 			     unsigned long *arg)
 {
 	struct nlattr *tb[TCA_CGROUP_MAX + 1];
-	struct cls_cgroup_head *head = tp->root;
+	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
+	struct cls_cgroup_head *new;
 	struct tcf_ematch_tree t;
 	struct tcf_exts e;
 	int err;
@@ -190,25 +204,24 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (!tca[TCA_OPTIONS])
 		return -EINVAL;
 
-	if (head == NULL) {
-		if (!handle)
-			return -EINVAL;
+	if (!head && !handle)
+		return -EINVAL;
 
-		head = kzalloc(sizeof(*head), GFP_KERNEL);
-		if (head == NULL)
-			return -ENOBUFS;
+	if (head && handle != head->handle)
+		return -ENOENT;
 
-		tcf_exts_init(&head->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
-		head->handle = handle;
+	new = kzalloc(sizeof(*head), GFP_KERNEL);
+	if (!new)
+		return -ENOBUFS;
 
-		tcf_tree_lock(tp);
-		tp->root = head;
-		tcf_tree_unlock(tp);
+	if (head) {
+		new->handle = head->handle;
+	} else {
+		tcf_exts_init(&new->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
+		new->handle = handle;
 	}
 
-	if (handle != head->handle)
-		return -ENOENT;
-
+	new->tp = tp;
 	err = nla_parse_nested(tb, TCA_CGROUP_MAX, tca[TCA_OPTIONS],
 			       cgroup_policy);
 	if (err < 0)
@@ -223,20 +236,24 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
-	tcf_exts_change(tp, &head->exts, &e);
-	tcf_em_tree_change(tp, &head->ematches, &t);
+	tcf_exts_change(tp, &new->exts, &e);
+	tcf_em_tree_change(tp, &new->ematches, &t);
 
+	rcu_assign_pointer(tp->root, new);
+	if (head)
+		call_rcu(&head->rcu, cls_cgroup_destroy_rcu);
 	return 0;
 }
 
 static void cls_cgroup_destroy(struct tcf_proto *tp)
 {
-	struct cls_cgroup_head *head = tp->root;
+	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 
 	if (head) {
 		tcf_exts_destroy(tp, &head->exts);
 		tcf_em_tree_destroy(tp, &head->ematches);
-		kfree(head);
+		rcu_assign_pointer(tp->root, NULL);
+		kfree_rcu(head, rcu);
 	}
 }
 
@@ -247,7 +264,7 @@ static int cls_cgroup_delete(struct tcf_proto *tp, unsigned long arg)
 
 static void cls_cgroup_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
-	struct cls_cgroup_head *head = tp->root;
+	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 
 	if (arg->count < arg->skip)
 		goto skip;
@@ -263,7 +280,7 @@ skip:
 static int cls_cgroup_dump(struct tcf_proto *tp, unsigned long fh,
 			   struct sk_buff *skb, struct tcmsg *t)
 {
-	struct cls_cgroup_head *head = tp->root;
+	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 
