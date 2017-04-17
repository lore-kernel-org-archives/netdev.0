From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v3] net_sched: move the empty tp check from ->destroy() to ->delete()
Date: Mon, 17 Apr 2017 11:30:40 -0700
Message-ID: <1492453840-15816-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34637 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754069AbdDQSas (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 14:30:48 -0400
Received: by mail-pg0-f67.google.com with SMTP id o123so28846321pga.1
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 11:30:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roi reported we could have a race condition where in ->classify() path
we dereference tp->root and meanwhile a parallel ->destroy() makes it
a NULL.

This is possible because ->destroy() could be called when deleting
a filter to check if we are the last one in tp, this tp is still
linked and visible at that time.

Daniel fixed this in commit d936377414fa
("net, sched: respect rcu grace period on cls destruction"), but
the root cause of this problem is the semantic of ->destroy(), it
does two things (for non-force case):

1) check if tp is empty
2) if tp is empty we could really destroy it

and its caller, if cares, needs to check its return value to see if
it is really destroyed. Therefore we can't unlink tp unless we know
it is empty.

As suggested by Daniel, we could actually move the test logic to ->delete()
so that we can safely unlink tp after ->delete() tells us the last one is
just deleted and before ->destroy().

What's more, even we unlink it before ->destroy(), it could still have
readers since we don't wait for a grace period here, we should not modify
tp->root in ->destroy() either.

Reported-by: Roi Dayan <roid@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h |  4 +--
 net/sched/cls_api.c       | 27 +++++++++---------
 net/sched/cls_basic.c     | 10 +++----
 net/sched/cls_bpf.c       | 11 ++++----
 net/sched/cls_cgroup.c    |  8 ++----
 net/sched/cls_flow.c      | 10 +++----
 net/sched/cls_flower.c    | 10 ++-----
 net/sched/cls_fw.c        | 30 +++++++++++---------
 net/sched/cls_matchall.c  |  7 ++---
 net/sched/cls_route.c     | 30 ++++++++++----------
 net/sched/cls_rsvp.h      | 34 +++++++++++------------
 net/sched/cls_tcindex.c   | 14 +++++-----
 net/sched/cls_u32.c       | 71 +++++++++++++++++++++++++++--------------------
 13 files changed, 134 insertions(+), 132 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 65d5026..22e5209 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -204,14 +204,14 @@ struct tcf_proto_ops {
 					    const struct tcf_proto *,
 					    struct tcf_result *);
 	int			(*init)(struct tcf_proto*);
-	bool			(*destroy)(struct tcf_proto*, bool);
+	void			(*destroy)(struct tcf_proto*);
 
 	unsigned long		(*get)(struct tcf_proto*, u32 handle);
 	int			(*change)(struct net *net, struct sk_buff *,
 					struct tcf_proto*, unsigned long,
 					u32 handle, struct nlattr **,
 					unsigned long *, bool);
-	int			(*delete)(struct tcf_proto*, unsigned long);
+	int			(*delete)(struct tcf_proto*, unsigned long, bool*);
 	void			(*walk)(struct tcf_proto*, struct tcf_walker *arg);
 
 	/* rtnetlink specific */
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index e2c68c3..55d7b4e7 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -178,14 +178,11 @@ static struct tcf_proto *tcf_proto_create(const char *kind, u32 protocol,
 	return ERR_PTR(err);
 }
 
-static bool tcf_proto_destroy(struct tcf_proto *tp, bool force)
+static void tcf_proto_destroy(struct tcf_proto *tp)
 {
-	if (tp->ops->destroy(tp, force)) {
-		module_put(tp->ops->owner);
-		kfree_rcu(tp, rcu);
-		return true;
-	}
-	return false;
+	tp->ops->destroy(tp);
+	module_put(tp->ops->owner);
+	kfree_rcu(tp, rcu);
 }
 
 void tcf_destroy_chain(struct tcf_proto __rcu **fl)
@@ -194,7 +191,7 @@ void tcf_destroy_chain(struct tcf_proto __rcu **fl)
 
 	while ((tp = rtnl_dereference(*fl)) != NULL) {
 		RCU_INIT_POINTER(*fl, tp->next);
-		tcf_proto_destroy(tp, true);
+		tcf_proto_destroy(tp);
 	}
 }
 EXPORT_SYMBOL(tcf_destroy_chain);
@@ -360,7 +357,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 			RCU_INIT_POINTER(*back, next);
 			tfilter_notify(net, skb, n, tp, fh,
 				       RTM_DELTFILTER, false);
-			tcf_proto_destroy(tp, true);
+			tcf_proto_destroy(tp);
 			err = 0;
 			goto errout;
 		}
@@ -371,24 +368,28 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 			goto errout;
 		}
 	} else {
+		bool last;
+
 		switch (n->nlmsg_type) {
 		case RTM_NEWTFILTER:
 			if (n->nlmsg_flags & NLM_F_EXCL) {
 				if (tp_created)
-					tcf_proto_destroy(tp, true);
+					tcf_proto_destroy(tp);
 				err = -EEXIST;
 				goto errout;
 			}
 			break;
 		case RTM_DELTFILTER:
-			err = tp->ops->delete(tp, fh);
+			err = tp->ops->delete(tp, fh, &last);
 			if (err)
 				goto errout;
 			next = rtnl_dereference(tp->next);
 			tfilter_notify(net, skb, n, tp, t->tcm_handle,
 				       RTM_DELTFILTER, false);
-			if (tcf_proto_destroy(tp, false))
+			if (last) {
 				RCU_INIT_POINTER(*back, next);
+				tcf_proto_destroy(tp);
+			}
 			goto errout;
 		case RTM_GETTFILTER:
 			err = tfilter_notify(net, skb, n, tp, fh,
@@ -410,7 +411,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 		tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER, false);
 	} else {
 		if (tp_created)
-			tcf_proto_destroy(tp, true);
+			tcf_proto_destroy(tp);
 	}
 
 errout:
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 422414f..c4fd63a 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -93,30 +93,28 @@ static void basic_delete_filter(struct rcu_head *head)
 	kfree(f);
 }
 
-static bool basic_destroy(struct tcf_proto *tp, bool force)
+static void basic_destroy(struct tcf_proto *tp)
 {
 	struct basic_head *head = rtnl_dereference(tp->root);
 	struct basic_filter *f, *n;
 
-	if (!force && !list_empty(&head->flist))
-		return false;
-
 	list_for_each_entry_safe(f, n, &head->flist, link) {
 		list_del_rcu(&f->link);
 		tcf_unbind_filter(tp, &f->res);
 		call_rcu(&f->rcu, basic_delete_filter);
 	}
 	kfree_rcu(head, rcu);
-	return true;
 }
 
-static int basic_delete(struct tcf_proto *tp, unsigned long arg)
+static int basic_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 {
+	struct basic_head *head = rtnl_dereference(tp->root);
 	struct basic_filter *f = (struct basic_filter *) arg;
 
 	list_del_rcu(&f->link);
 	tcf_unbind_filter(tp, &f->res);
 	call_rcu(&f->rcu, basic_delete_filter);
+	*last = list_empty(&head->flist);
 	return 0;
 }
 
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 7ddd08e..5ebeae9 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -274,25 +274,24 @@ static void __cls_bpf_delete(struct tcf_proto *tp, struct cls_bpf_prog *prog)
 	call_rcu(&prog->rcu, cls_bpf_delete_prog_rcu);
 }
 
-static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg)
+static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 {
+	struct cls_bpf_head *head = rtnl_dereference(tp->root);
+
 	__cls_bpf_delete(tp, (struct cls_bpf_prog *) arg);
+	*last = list_empty(&head->plist);
 	return 0;
 }
 
-static bool cls_bpf_destroy(struct tcf_proto *tp, bool force)
+static void cls_bpf_destroy(struct tcf_proto *tp)
 {
 	struct cls_bpf_head *head = rtnl_dereference(tp->root);
 	struct cls_bpf_prog *prog, *tmp;
 
-	if (!force && !list_empty(&head->plist))
-		return false;
-
 	list_for_each_entry_safe(prog, tmp, &head->plist, link)
 		__cls_bpf_delete(tp, prog);
 
 	kfree_rcu(head, rcu);
-	return true;
 }
 
 static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index b5e7c1b..12ce547 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -131,20 +131,16 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	return err;
 }
 
-static bool cls_cgroup_destroy(struct tcf_proto *tp, bool force)
+static void cls_cgroup_destroy(struct tcf_proto *tp)
 {
 	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 
-	if (!force)
-		return false;
 	/* Head can still be NULL due to cls_cgroup_init(). */
 	if (head)
 		call_rcu(&head->rcu, cls_cgroup_destroy_rcu);
-
-	return true;
 }
 
-static int cls_cgroup_delete(struct tcf_proto *tp, unsigned long arg)
+static int cls_cgroup_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 008ba7e..3065752 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -562,12 +562,14 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	return err;
 }
 
-static int flow_delete(struct tcf_proto *tp, unsigned long arg)
+static int flow_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 {
+	struct flow_head *head = rtnl_dereference(tp->root);
 	struct flow_filter *f = (struct flow_filter *)arg;
 
 	list_del_rcu(&f->list);
 	call_rcu(&f->rcu, flow_destroy_filter);
+	*last = list_empty(&head->filters);
 	return 0;
 }
 
@@ -583,20 +585,16 @@ static int flow_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static bool flow_destroy(struct tcf_proto *tp, bool force)
+static void flow_destroy(struct tcf_proto *tp)
 {
 	struct flow_head *head = rtnl_dereference(tp->root);
 	struct flow_filter *f, *next;
 
-	if (!force && !list_empty(&head->filters))
-		return false;
-
 	list_for_each_entry_safe(f, next, &head->filters, list) {
 		list_del_rcu(&f->list);
 		call_rcu(&f->rcu, flow_destroy_filter);
 	}
 	kfree_rcu(head, rcu);
-	return true;
 }
 
 static unsigned long flow_get(struct tcf_proto *tp, u32 handle)
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 3e7bd78..31ee340 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -328,21 +328,16 @@ static void fl_destroy_rcu(struct rcu_head *rcu)
 	schedule_work(&head->work);
 }
 
-static bool fl_destroy(struct tcf_proto *tp, bool force)
+static void fl_destroy(struct tcf_proto *tp)
 {
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
 	struct cls_fl_filter *f, *next;
 
-	if (!force && !list_empty(&head->filters))
-		return false;
-
 	list_for_each_entry_safe(f, next, &head->filters, list)
 		__fl_delete(tp, f);
 
 	__module_get(THIS_MODULE);
 	call_rcu(&head->rcu, fl_destroy_rcu);
-
-	return true;
 }
 
 static unsigned long fl_get(struct tcf_proto *tp, u32 handle)
@@ -947,7 +942,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	return err;
 }
 
-static int fl_delete(struct tcf_proto *tp, unsigned long arg)
+static int fl_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 {
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
 	struct cls_fl_filter *f = (struct cls_fl_filter *) arg;
@@ -956,6 +951,7 @@ static int fl_delete(struct tcf_proto *tp, unsigned long arg)
 		rhashtable_remove_fast(&head->ht, &f->ht_node,
 				       head->ht_params);
 	__fl_delete(tp, f);
+	*last = list_empty(&head->filters);
 	return 0;
 }
 
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 9962090..d388536 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -127,20 +127,14 @@ static void fw_delete_filter(struct rcu_head *head)
 	kfree(f);
 }
 
-static bool fw_destroy(struct tcf_proto *tp, bool force)
+static void fw_destroy(struct tcf_proto *tp)
 {
 	struct fw_head *head = rtnl_dereference(tp->root);
 	struct fw_filter *f;
 	int h;
 
 	if (head == NULL)
-		return true;
-
-	if (!force) {
-		for (h = 0; h < HTSIZE; h++)
-			if (rcu_access_pointer(head->ht[h]))
-				return false;
-	}
+		return;
 
 	for (h = 0; h < HTSIZE; h++) {
 		while ((f = rtnl_dereference(head->ht[h])) != NULL) {
@@ -150,17 +144,17 @@ static bool fw_destroy(struct tcf_proto *tp, bool force)
 			call_rcu(&f->rcu, fw_delete_filter);
 		}
 	}
-	RCU_INIT_POINTER(tp->root, NULL);
 	kfree_rcu(head, rcu);
-	return true;
 }
 
-static int fw_delete(struct tcf_proto *tp, unsigned long arg)
+static int fw_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 {
 	struct fw_head *head = rtnl_dereference(tp->root);
 	struct fw_filter *f = (struct fw_filter *)arg;
 	struct fw_filter __rcu **fp;
 	struct fw_filter *pfp;
+	int ret = -EINVAL;
+	int h;
 
 	if (head == NULL || f == NULL)
 		goto out;
@@ -173,11 +167,21 @@ static int fw_delete(struct tcf_proto *tp, unsigned long arg)
 			RCU_INIT_POINTER(*fp, rtnl_dereference(f->next));
 			tcf_unbind_filter(tp, &f->res);
 			call_rcu(&f->rcu, fw_delete_filter);
-			return 0;
+			ret = 0;
+			break;
 		}
 	}
+
+	*last = true;
+	for (h = 0; h < HTSIZE; h++) {
+		if (rcu_access_pointer(head->ht[h])) {
+			*last = false;
+			break;
+		}
+	}
+
 out:
-	return -EINVAL;
+	return ret;
 }
 
 static const struct nla_policy fw_policy[TCA_FW_MAX + 1] = {
diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index 0dbcca6..2efb36c 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -90,19 +90,18 @@ static void mall_destroy_hw_filter(struct tcf_proto *tp,
 					     &offload);
 }
 
-static bool mall_destroy(struct tcf_proto *tp, bool force)
+static void mall_destroy(struct tcf_proto *tp)
 {
 	struct cls_mall_head *head = rtnl_dereference(tp->root);
 	struct net_device *dev = tp->q->dev_queue->dev;
 
 	if (!head)
-		return true;
+		return;
 
 	if (tc_should_offload(dev, tp, head->flags))
 		mall_destroy_hw_filter(tp, head, (unsigned long) head);
 
 	call_rcu(&head->rcu, mall_destroy_rcu);
-	return true;
 }
 
 static unsigned long mall_get(struct tcf_proto *tp, u32 handle)
@@ -216,7 +215,7 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 	return err;
 }
 
-static int mall_delete(struct tcf_proto *tp, unsigned long arg)
+static int mall_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index a371075..8e2baf8 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -276,20 +276,13 @@ static void route4_delete_filter(struct rcu_head *head)
 	kfree(f);
 }
 
-static bool route4_destroy(struct tcf_proto *tp, bool force)
+static void route4_destroy(struct tcf_proto *tp)
 {
 	struct route4_head *head = rtnl_dereference(tp->root);
 	int h1, h2;
 
 	if (head == NULL)
-		return true;
-
-	if (!force) {
-		for (h1 = 0; h1 <= 256; h1++) {
-			if (rcu_access_pointer(head->table[h1]))
-				return false;
-		}
-	}
+		return;
 
 	for (h1 = 0; h1 <= 256; h1++) {
 		struct route4_bucket *b;
@@ -312,12 +305,10 @@ static bool route4_destroy(struct tcf_proto *tp, bool force)
 			kfree_rcu(b, rcu);
 		}
 	}
-	RCU_INIT_POINTER(tp->root, NULL);
 	kfree_rcu(head, rcu);
-	return true;
 }
 
-static int route4_delete(struct tcf_proto *tp, unsigned long arg)
+static int route4_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 {
 	struct route4_head *head = rtnl_dereference(tp->root);
 	struct route4_filter *f = (struct route4_filter *)arg;
@@ -325,7 +316,7 @@ static int route4_delete(struct tcf_proto *tp, unsigned long arg)
 	struct route4_filter *nf;
 	struct route4_bucket *b;
 	unsigned int h = 0;
-	int i;
+	int i, h1;
 
 	if (!head || !f)
 		return -EINVAL;
@@ -356,16 +347,25 @@ static int route4_delete(struct tcf_proto *tp, unsigned long arg)
 
 				rt = rtnl_dereference(b->ht[i]);
 				if (rt)
-					return 0;
+					goto out;
 			}
 
 			/* OK, session has no flows */
 			RCU_INIT_POINTER(head->table[to_hash(h)], NULL);
 			kfree_rcu(b, rcu);
+			break;
+		}
+	}
 
-			return 0;
+out:
+	*last = true;
+	for (h1 = 0; h1 <= 256; h1++) {
+		if (rcu_access_pointer(head->table[h1])) {
+			*last = false;
+			break;
 		}
 	}
+
 	return 0;
 }
 
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index d7f2923..9e3748b 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -302,22 +302,13 @@ static void rsvp_delete_filter(struct tcf_proto *tp, struct rsvp_filter *f)
 	call_rcu(&f->rcu, rsvp_delete_filter_rcu);
 }
 
-static bool rsvp_destroy(struct tcf_proto *tp, bool force)
+static void rsvp_destroy(struct tcf_proto *tp)
 {
 	struct rsvp_head *data = rtnl_dereference(tp->root);
 	int h1, h2;
 
 	if (data == NULL)
-		return true;
-
-	if (!force) {
-		for (h1 = 0; h1 < 256; h1++) {
-			if (rcu_access_pointer(data->ht[h1]))
-				return false;
-		}
-	}
-
-	RCU_INIT_POINTER(tp->root, NULL);
+		return;
 
 	for (h1 = 0; h1 < 256; h1++) {
 		struct rsvp_session *s;
@@ -337,10 +328,9 @@ static bool rsvp_destroy(struct tcf_proto *tp, bool force)
 		}
 	}
 	kfree_rcu(data, rcu);
-	return true;
 }
 
-static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
+static int rsvp_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 {
 	struct rsvp_head *head = rtnl_dereference(tp->root);
 	struct rsvp_filter *nfp, *f = (struct rsvp_filter *)arg;
@@ -348,7 +338,7 @@ static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
 	unsigned int h = f->handle;
 	struct rsvp_session __rcu **sp;
 	struct rsvp_session *nsp, *s = f->sess;
-	int i;
+	int i, h1;
 
 	fp = &s->ht[(h >> 8) & 0xFF];
 	for (nfp = rtnl_dereference(*fp); nfp;
@@ -361,7 +351,7 @@ static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
 
 			for (i = 0; i <= 16; i++)
 				if (s->ht[i])
-					return 0;
+					goto out;
 
 			/* OK, session has no flows */
 			sp = &head->ht[h & 0xFF];
@@ -370,13 +360,23 @@ static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
 				if (nsp == s) {
 					RCU_INIT_POINTER(*sp, s->next);
 					kfree_rcu(s, rcu);
-					return 0;
+					goto out;
 				}
 			}
 
-			return 0;
+			break;
 		}
 	}
+
+out:
+	*last = true;
+	for (h1 = 0; h1 < 256; h1++) {
+		if (rcu_access_pointer(head->ht[h1])) {
+			*last = false;
+			break;
+		}
+	}
+
 	return 0;
 }
 
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 2ab0013..8a8a583 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -150,7 +150,7 @@ static void tcindex_destroy_fexts(struct rcu_head *head)
 	kfree(f);
 }
 
-static int tcindex_delete(struct tcf_proto *tp, unsigned long arg)
+static int tcindex_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 {
 	struct tcindex_data *p = rtnl_dereference(tp->root);
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) arg;
@@ -186,6 +186,8 @@ static int tcindex_delete(struct tcf_proto *tp, unsigned long arg)
 		call_rcu(&f->rcu, tcindex_destroy_fexts);
 	else
 		call_rcu(&r->rcu, tcindex_destroy_rexts);
+
+	*last = false;
 	return 0;
 }
 
@@ -193,7 +195,9 @@ static int tcindex_destroy_element(struct tcf_proto *tp,
 				   unsigned long arg,
 				   struct tcf_walker *walker)
 {
-	return tcindex_delete(tp, arg);
+	bool last;
+
+	return tcindex_delete(tp, arg, &last);
 }
 
 static void __tcindex_destroy(struct rcu_head *head)
@@ -529,14 +533,11 @@ static void tcindex_walk(struct tcf_proto *tp, struct tcf_walker *walker)
 	}
 }
 
-static bool tcindex_destroy(struct tcf_proto *tp, bool force)
+static void tcindex_destroy(struct tcf_proto *tp)
 {
 	struct tcindex_data *p = rtnl_dereference(tp->root);
 	struct tcf_walker walker;
 
-	if (!force)
-		return false;
-
 	pr_debug("tcindex_destroy(tp %p),p %p\n", tp, p);
 	walker.count = 0;
 	walker.skip = 0;
@@ -544,7 +545,6 @@ static bool tcindex_destroy(struct tcf_proto *tp, bool force)
 	tcindex_walk(tp, &walker);
 
 	call_rcu(&p->rcu, __tcindex_destroy);
-	return true;
 }
 
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 9e2f330..d20e72a 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -585,37 +585,13 @@ static bool ht_empty(struct tc_u_hnode *ht)
 	return true;
 }
 
-static bool u32_destroy(struct tcf_proto *tp, bool force)
+static void u32_destroy(struct tcf_proto *tp)
 {
 	struct tc_u_common *tp_c = tp->data;
 	struct tc_u_hnode *root_ht = rtnl_dereference(tp->root);
 
 	WARN_ON(root_ht == NULL);
 
-	if (!force) {
-		if (root_ht) {
-			if (root_ht->refcnt > 1)
-				return false;
-			if (root_ht->refcnt == 1) {
-				if (!ht_empty(root_ht))
-					return false;
-			}
-		}
-
-		if (tp_c->refcnt > 1)
-			return false;
-
-		if (tp_c->refcnt == 1) {
-			struct tc_u_hnode *ht;
-
-			for (ht = rtnl_dereference(tp_c->hlist);
-			     ht;
-			     ht = rtnl_dereference(ht->next))
-				if (!ht_empty(ht))
-					return false;
-		}
-	}
-
 	if (root_ht && --root_ht->refcnt == 0)
 		u32_destroy_hnode(tp, root_ht);
 
@@ -640,20 +616,22 @@ static bool u32_destroy(struct tcf_proto *tp, bool force)
 	}
 
 	tp->data = NULL;
-	return true;
 }
 
-static int u32_delete(struct tcf_proto *tp, unsigned long arg)
+static int u32_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 {
 	struct tc_u_hnode *ht = (struct tc_u_hnode *)arg;
 	struct tc_u_hnode *root_ht = rtnl_dereference(tp->root);
+	struct tc_u_common *tp_c = tp->data;
+	int ret = 0;
 
 	if (ht == NULL)
-		return 0;
+		goto out;
 
 	if (TC_U32_KEY(ht->handle)) {
 		u32_remove_hw_knode(tp, ht->handle);
-		return u32_delete_key(tp, (struct tc_u_knode *)ht);
+		ret = u32_delete_key(tp, (struct tc_u_knode *)ht);
+		goto out;
 	}
 
 	if (root_ht == ht)
@@ -666,7 +644,40 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
 		return -EBUSY;
 	}
 
-	return 0;
+out:
+	*last = true;
+	if (root_ht) {
+		if (root_ht->refcnt > 1) {
+			*last = false;
+			goto ret;
+		}
+		if (root_ht->refcnt == 1) {
+			if (!ht_empty(root_ht)) {
+				*last = false;
+				goto ret;
+			}
+		}
+	}
+
+	if (tp_c->refcnt > 1) {
+		*last = false;
+		goto ret;
+	}
+
+	if (tp_c->refcnt == 1) {
+		struct tc_u_hnode *ht;
+
+		for (ht = rtnl_dereference(tp_c->hlist);
+		     ht;
+		     ht = rtnl_dereference(ht->next))
+			if (!ht_empty(ht)) {
+				*last = false;
+				break;
+			}
+	}
+
+ret:
+	return ret;
 }
 
 #define NR_U32_NODE (1<<12)
-- 
2.5.5
