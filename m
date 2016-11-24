From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: move the empty tp check from ->destroy() to ->delete()
Date: Wed, 23 Nov 2016 17:58:28 -0800
Message-ID: <1479952708-26763-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: roid@mellanox.com, jiri@mellanox.com,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36276 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751287AbcKXB6f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 20:58:35 -0500
Received: by mail-pf0-f180.google.com with SMTP id 189so6401196pfz.3
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 17:58:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roi reported we could have a race condition where in ->classify() path
we dereference tp->root and meanwhile a parallel ->destroy() makes it
a NULL.

This is possible because ->destroy() could be called when deleting
a filter to check if we are the last one in tp, this tp is still
linked and visible at that time.

The root cause of this problem is the semantic of ->destroy(), it
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

Fixes: 1e052be69d04 ("net_sched: destroy proto tp when all filters are gone")
Reported-by: Roi Dayan <roid@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h |  6 ++--
 net/sched/cls_api.c       | 18 +++++++-----
 net/sched/cls_basic.c     | 11 +++-----
 net/sched/cls_bpf.c       | 11 +++-----
 net/sched/cls_cgroup.c    | 12 ++------
 net/sched/cls_flow.c      | 11 +++-----
 net/sched/cls_flower.c    | 10 ++-----
 net/sched/cls_fw.c        | 30 +++++++++++---------
 net/sched/cls_matchall.c  | 10 ++-----
 net/sched/cls_route.c     | 30 ++++++++++----------
 net/sched/cls_rsvp.h      | 34 +++++++++++------------
 net/sched/cls_tcindex.c   | 15 +++++-----
 net/sched/cls_u32.c       | 71 +++++++++++++++++++++++++++--------------------
 net/sched/sch_api.c       | 14 ++++------
 14 files changed, 137 insertions(+), 146 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e6aa0a2..27cd1bd 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -203,14 +203,14 @@ struct tcf_proto_ops {
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
@@ -405,7 +405,7 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 				const struct Qdisc_ops *ops, u32 parentid);
 void __qdisc_calculate_pkt_len(struct sk_buff *skb,
 			       const struct qdisc_size_table *stab);
-bool tcf_destroy(struct tcf_proto *tp, bool force);
+void tcf_destroy(struct tcf_proto *tp);
 void tcf_destroy_chain(struct tcf_proto __rcu **fl);
 int skb_do_redirect(struct sk_buff *);
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 8e93d4a..f159aeb 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -321,7 +321,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 
 			tfilter_notify(net, skb, n, tp, fh,
 				       RTM_DELTFILTER, false);
-			tcf_destroy(tp, true);
+			tcf_destroy(tp);
 			err = 0;
 			goto errout;
 		}
@@ -331,25 +331,29 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 		    !(n->nlmsg_flags & NLM_F_CREATE))
 			goto errout;
 	} else {
+		bool last;
+
 		switch (n->nlmsg_type) {
 		case RTM_NEWTFILTER:
 			err = -EEXIST;
 			if (n->nlmsg_flags & NLM_F_EXCL) {
 				if (tp_created)
-					tcf_destroy(tp, true);
+					tcf_destroy(tp);
 				goto errout;
 			}
 			break;
 		case RTM_DELTFILTER:
-			err = tp->ops->delete(tp, fh);
+			err = tp->ops->delete(tp, fh, &last);
 			if (err == 0) {
-				struct tcf_proto *next = rtnl_dereference(tp->next);
-
 				tfilter_notify(net, skb, n, tp,
 					       t->tcm_handle,
 					       RTM_DELTFILTER, false);
-				if (tcf_destroy(tp, false))
+				if (last) {
+					struct tcf_proto *next = rtnl_dereference(tp->next);
+
 					RCU_INIT_POINTER(*back, next);
+					tcf_destroy(tp);
+				}
 			}
 			goto errout;
 		case RTM_GETTFILTER:
@@ -372,7 +376,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 		tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER, false);
 	} else {
 		if (tp_created)
-			tcf_destroy(tp, true);
+			tcf_destroy(tp);
 	}
 
 errout:
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index eb219b7..dd63230 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -96,31 +96,28 @@ static void basic_delete_filter(struct rcu_head *head)
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
-	RCU_INIT_POINTER(tp->root, NULL);
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
index 52dc85a..770984c0 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -265,26 +265,25 @@ static void __cls_bpf_delete_prog(struct rcu_head *rcu)
 	cls_bpf_delete_prog(prog->tp, prog);
 }
 
-static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg)
+static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 {
 	struct cls_bpf_prog *prog = (struct cls_bpf_prog *) arg;
+	struct cls_bpf_head *head = rtnl_dereference(tp->root);
 
 	cls_bpf_stop_offload(tp, prog);
 	list_del_rcu(&prog->link);
 	tcf_unbind_filter(tp, &prog->res);
 	call_rcu(&prog->rcu, __cls_bpf_delete_prog);
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
 	list_for_each_entry_safe(prog, tmp, &head->plist, link) {
 		cls_bpf_stop_offload(tp, prog);
 		list_del_rcu(&prog->link);
@@ -292,9 +291,7 @@ static bool cls_bpf_destroy(struct tcf_proto *tp, bool force)
 		call_rcu(&prog->rcu, __cls_bpf_delete_prog);
 	}
 
-	RCU_INIT_POINTER(tp->root, NULL);
 	kfree_rcu(head, rcu);
-	return true;
 }
 
 static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 85233c47..fa9405e 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -131,21 +131,15 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	return err;
 }
 
-static bool cls_cgroup_destroy(struct tcf_proto *tp, bool force)
+static void cls_cgroup_destroy(struct tcf_proto *tp)
 {
 	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 
-	if (!force)
-		return false;
-
-	if (head) {
-		RCU_INIT_POINTER(tp->root, NULL);
+	if (head)
 		call_rcu(&head->rcu, cls_cgroup_destroy_rcu);
-	}
-	return true;
 }
 
-static int cls_cgroup_delete(struct tcf_proto *tp, unsigned long arg)
+static int cls_cgroup_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index e396723..ea2be75 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -563,12 +563,14 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
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
 
@@ -584,21 +586,16 @@ static int flow_init(struct tcf_proto *tp)
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
-	RCU_INIT_POINTER(tp->root, NULL);
 	kfree_rcu(head, rcu);
-	return true;
 }
 
 static unsigned long flow_get(struct tcf_proto *tp, u32 handle)
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index e8dd09a..495d63224 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -280,21 +280,16 @@ static void __fl_delete(struct tcf_proto *tp, struct cls_fl_filter *f)
 	call_rcu(&f->rcu, fl_destroy_filter);
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
-	RCU_INIT_POINTER(tp->root, NULL);
 	if (head->mask_assigned)
 		rhashtable_destroy(&head->ht);
 	kfree_rcu(head, rcu);
-	return true;
 }
 
 static unsigned long fl_get(struct tcf_proto *tp, u32 handle)
@@ -777,7 +772,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	return err;
 }
 
-static int fl_delete(struct tcf_proto *tp, unsigned long arg)
+static int fl_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 {
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
 	struct cls_fl_filter *f = (struct cls_fl_filter *) arg;
@@ -785,6 +780,7 @@ static int fl_delete(struct tcf_proto *tp, unsigned long arg)
 	rhashtable_remove_fast(&head->ht, &f->ht_node,
 			       head->ht_params);
 	__fl_delete(tp, f);
+	*last = list_empty(&head->filters);
 	return 0;
 }
 
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 9dc63d5..bc8ceb7 100644
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
index 25927b6..7d54805 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -99,24 +99,19 @@ static void mall_destroy_hw_filter(struct tcf_proto *tp,
 					     &offload);
 }
 
-static bool mall_destroy(struct tcf_proto *tp, bool force)
+static void mall_destroy(struct tcf_proto *tp)
 {
 	struct cls_mall_head *head = rtnl_dereference(tp->root);
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct cls_mall_filter *f = head->filter;
 
-	if (!force && f)
-		return false;
-
 	if (f) {
 		if (tc_should_offload(dev, tp, f->flags))
 			mall_destroy_hw_filter(tp, f, (unsigned long) f);
 
 		call_rcu(&f->rcu, mall_destroy_filter);
 	}
-	RCU_INIT_POINTER(tp->root, NULL);
 	kfree_rcu(head, rcu);
-	return true;
 }
 
 static unsigned long mall_get(struct tcf_proto *tp, u32 handle)
@@ -225,7 +220,7 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 	return err;
 }
 
-static int mall_delete(struct tcf_proto *tp, unsigned long arg)
+static int mall_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 {
 	struct cls_mall_head *head = rtnl_dereference(tp->root);
 	struct cls_mall_filter *f = (struct cls_mall_filter *) arg;
@@ -237,6 +232,7 @@ static int mall_delete(struct tcf_proto *tp, unsigned long arg)
 	RCU_INIT_POINTER(head->filter, NULL);
 	tcf_unbind_filter(tp, &f->res);
 	call_rcu(&f->rcu, mall_destroy_filter);
+	*last = true;
 	return 0;
 }
 
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 455fc8f..1a38e41 100644
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
index 4f05a19..e8ba81a 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -301,22 +301,13 @@ static void rsvp_delete_filter(struct tcf_proto *tp, struct rsvp_filter *f)
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
@@ -336,10 +327,9 @@ static bool rsvp_destroy(struct tcf_proto *tp, bool force)
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
@@ -347,7 +337,7 @@ static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
 	unsigned int h = f->handle;
 	struct rsvp_session __rcu **sp;
 	struct rsvp_session *nsp, *s = f->sess;
-	int i;
+	int i, h1;
 
 	fp = &s->ht[(h >> 8) & 0xFF];
 	for (nfp = rtnl_dereference(*fp); nfp;
@@ -360,7 +350,7 @@ static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
 
 			for (i = 0; i <= 16; i++)
 				if (s->ht[i])
-					return 0;
+					goto out;
 
 			/* OK, session has no flows */
 			sp = &head->ht[h & 0xFF];
@@ -369,13 +359,23 @@ static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
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
index 96144bd..9149a03 100644
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
@@ -529,23 +533,18 @@ static void tcindex_walk(struct tcf_proto *tp, struct tcf_walker *walker)
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
 	walker.fn = tcindex_destroy_element;
 	tcindex_walk(tp, &walker);
 
-	RCU_INIT_POINTER(tp->root, NULL);
 	call_rcu(&p->rcu, __tcindex_destroy);
-	return true;
 }
 
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index ae83c3ae..787573b 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -582,37 +582,13 @@ static bool ht_empty(struct tc_u_hnode *ht)
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
 
@@ -637,20 +613,22 @@ static bool u32_destroy(struct tcf_proto *tp, bool force)
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
@@ -663,7 +641,40 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
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
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index f337f1b..7fc48b3 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1899,15 +1899,11 @@ int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 }
 EXPORT_SYMBOL(tc_classify);
 
-bool tcf_destroy(struct tcf_proto *tp, bool force)
+void tcf_destroy(struct tcf_proto *tp)
 {
-	if (tp->ops->destroy(tp, force)) {
-		module_put(tp->ops->owner);
-		kfree_rcu(tp, rcu);
-		return true;
-	}
-
-	return false;
+	tp->ops->destroy(tp);
+	module_put(tp->ops->owner);
+	kfree_rcu(tp, rcu);
 }
 
 void tcf_destroy_chain(struct tcf_proto __rcu **fl)
@@ -1916,7 +1912,7 @@ void tcf_destroy_chain(struct tcf_proto __rcu **fl)
 
 	while ((tp = rtnl_dereference(*fl)) != NULL) {
 		RCU_INIT_POINTER(*fl, tp->next);
-		tcf_destroy(tp, true);
+		tcf_destroy(tp);
 	}
 }
 EXPORT_SYMBOL(tcf_destroy_chain);
-- 
2.1.0
