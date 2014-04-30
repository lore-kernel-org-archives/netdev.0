From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 04/15] net: sched: cls_cgroup use RCU
Date: Wed, 30 Apr 2014 09:36:26 -0700
Message-ID: <20140430163624.9021.65383.stgit@nitbit.x32>
References: <20140430163250.9021.21199.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:37130 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964900AbaD3Qgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 12:36:41 -0400
Received: by mail-ob0-f172.google.com with SMTP id wo20so2298321obc.31
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 09:36:41 -0700 (PDT)
In-Reply-To: <20140430163250.9021.21199.stgit@nitbit.x32>
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
 net/sched/cls_cgroup.c |   63 ++++++++++++++++++++++++++++++------------------
 1 file changed, 39 insertions(+), 24 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 8e2158a..b8db7ff 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -22,17 +22,17 @@ struct cls_cgroup_head {
 	u32			handle;
 	struct tcf_exts		exts;
 	struct tcf_ematch_tree	ematches;
+	struct tcf_proto	*tp;
+	struct rcu_head		rcu;
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
@@ -80,13 +80,25 @@ static const struct nla_policy cgroup_policy[TCA_CGROUP_MAX + 1] = {
 	[TCA_CGROUP_EMATCHES]	= { .type = NLA_NESTED },
 };
 
+static void cls_cgroup_destroy_rcu(struct rcu_head *root)
+{
+	struct cls_cgroup_head *head = container_of(root,
+						    struct cls_cgroup_head,
+						    rcu);
+
+	tcf_exts_destroy(head->tp, &head->exts);
+	tcf_em_tree_destroy(head->tp, &head->ematches);
+	kfree(head);
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
@@ -94,25 +106,24 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
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
@@ -127,20 +138,24 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
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
+		RCU_INIT_POINTER(tp->root, NULL);
+		kfree_rcu(head, rcu);
 	}
 }
 
@@ -151,7 +166,7 @@ static int cls_cgroup_delete(struct tcf_proto *tp, unsigned long arg)
 
 static void cls_cgroup_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
-	struct cls_cgroup_head *head = tp->root;
+	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 
 	if (arg->count < arg->skip)
 		goto skip;
@@ -167,7 +182,7 @@ skip:
 static int cls_cgroup_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			   struct sk_buff *skb, struct tcmsg *t)
 {
-	struct cls_cgroup_head *head = tp->root;
+	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 
