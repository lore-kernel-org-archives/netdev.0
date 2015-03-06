From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: destroy proto tp when all filters are gone
Date: Fri,  6 Mar 2015 11:47:59 -0800
Message-ID: <1425671279-25399-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <cwang@twopensource.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:46369 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755916AbbCFTsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 14:48:15 -0500
Received: by pdev10 with SMTP id v10so17035988pde.13
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 11:48:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

Kernel automatically creates a tp for each
(kind, protocol, priority) tuple, which has handle 0,
when we add a new filter, but it still is left there
after we remove our own, unless we don't specify the
handle (literally means all the filters under
the tuple). For example this one is left:

  # tc filter show dev eth0
  filter parent 8001: protocol arp pref 49152 basic

The user-space is hard to clean up these for kernel
because filters like u32 are organized in a complex way.
So kernel is responsible to remove it after all filters
are gone.  Each type of filter has its own way to
store the filters, so each type has to provide its
way to check if all filters are gone.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h |  4 ++--
 net/sched/cls_api.c       | 14 ++++++++++----
 net/sched/cls_basic.c     |  6 +++++-
 net/sched/cls_bpf.c       |  6 +++++-
 net/sched/cls_cgroup.c    |  6 +++++-
 net/sched/cls_flow.c      |  6 +++++-
 net/sched/cls_fw.c        | 11 +++++++++--
 net/sched/cls_route.c     | 12 ++++++++++--
 net/sched/cls_rsvp.h      | 12 ++++++++++--
 net/sched/cls_tcindex.c   |  6 +++++-
 net/sched/cls_u32.c       | 25 ++++++++++++++++++++++++-
 net/sched/sch_api.c       | 14 +++++++++-----
 12 files changed, 99 insertions(+), 23 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index c605d30..6d778ef 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -213,7 +213,7 @@ struct tcf_proto_ops {
 					    const struct tcf_proto *,
 					    struct tcf_result *);
 	int			(*init)(struct tcf_proto*);
-	void			(*destroy)(struct tcf_proto*);
+	bool			(*destroy)(struct tcf_proto*, bool);
 
 	unsigned long		(*get)(struct tcf_proto*, u32 handle);
 	int			(*change)(struct net *net, struct sk_buff *,
@@ -399,7 +399,7 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 				const struct Qdisc_ops *ops, u32 parentid);
 void __qdisc_calculate_pkt_len(struct sk_buff *skb,
 			       const struct qdisc_size_table *stab);
-void tcf_destroy(struct tcf_proto *tp);
+bool tcf_destroy(struct tcf_proto *tp, bool force);
 void tcf_destroy_chain(struct tcf_proto __rcu **fl);
 
 /* Reset all TX qdiscs greater then index of a device.  */
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index baef987..8b0470e 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -286,7 +286,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 			RCU_INIT_POINTER(*back, next);
 
 			tfilter_notify(net, skb, n, tp, fh, RTM_DELTFILTER);
-			tcf_destroy(tp);
+			tcf_destroy(tp, true);
 			err = 0;
 			goto errout;
 		}
@@ -301,14 +301,20 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 			err = -EEXIST;
 			if (n->nlmsg_flags & NLM_F_EXCL) {
 				if (tp_created)
-					tcf_destroy(tp);
+					tcf_destroy(tp, true);
 				goto errout;
 			}
 			break;
 		case RTM_DELTFILTER:
 			err = tp->ops->delete(tp, fh);
-			if (err == 0)
+			if (err == 0) {
 				tfilter_notify(net, skb, n, tp, fh, RTM_DELTFILTER);
+				if (tcf_destroy(tp, false)) {
+					struct tcf_proto *next = rtnl_dereference(tp->next);
+
+					RCU_INIT_POINTER(*back, next);
+				}
+			}
 			goto errout;
 		case RTM_GETTFILTER:
 			err = tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER);
@@ -329,7 +335,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 		tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER);
 	} else {
 		if (tp_created)
-			tcf_destroy(tp);
+			tcf_destroy(tp, true);
 	}
 
 errout:
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index fc399db..0b8c3ac 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -96,11 +96,14 @@ static void basic_delete_filter(struct rcu_head *head)
 	kfree(f);
 }
 
-static void basic_destroy(struct tcf_proto *tp)
+static bool basic_destroy(struct tcf_proto *tp, bool force)
 {
 	struct basic_head *head = rtnl_dereference(tp->root);
 	struct basic_filter *f, *n;
 
+	if (!force && !list_empty(&head->flist))
+		return false;
+
 	list_for_each_entry_safe(f, n, &head->flist, link) {
 		list_del_rcu(&f->link);
 		tcf_unbind_filter(tp, &f->res);
@@ -108,6 +111,7 @@ static void basic_destroy(struct tcf_proto *tp)
 	}
 	RCU_INIT_POINTER(tp->root, NULL);
 	kfree_rcu(head, rcu);
+	return true;
 }
 
 static int basic_delete(struct tcf_proto *tp, unsigned long arg)
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 6f7ed8f..243c9f2 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -137,11 +137,14 @@ static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg)
 	return 0;
 }
 
-static void cls_bpf_destroy(struct tcf_proto *tp)
+static bool cls_bpf_destroy(struct tcf_proto *tp, bool force)
 {
 	struct cls_bpf_head *head = rtnl_dereference(tp->root);
 	struct cls_bpf_prog *prog, *tmp;
 
+	if (!force && !list_empty(&head->plist))
+		return false;
+
 	list_for_each_entry_safe(prog, tmp, &head->plist, link) {
 		list_del_rcu(&prog->link);
 		tcf_unbind_filter(tp, &prog->res);
@@ -150,6 +153,7 @@ static void cls_bpf_destroy(struct tcf_proto *tp)
 
 	RCU_INIT_POINTER(tp->root, NULL);
 	kfree_rcu(head, rcu);
+	return true;
 }
 
 static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 221697a..ea611b21 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -143,14 +143,18 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	return err;
 }
 
-static void cls_cgroup_destroy(struct tcf_proto *tp)
+static bool cls_cgroup_destroy(struct tcf_proto *tp, bool force)
 {
 	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 
+	if (!force)
+		return false;
+
 	if (head) {
 		RCU_INIT_POINTER(tp->root, NULL);
 		call_rcu(&head->rcu, cls_cgroup_destroy_rcu);
 	}
+	return true;
 }
 
 static int cls_cgroup_delete(struct tcf_proto *tp, unsigned long arg)
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 4614103..a620c4e 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -557,17 +557,21 @@ static int flow_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static void flow_destroy(struct tcf_proto *tp)
+static bool flow_destroy(struct tcf_proto *tp, bool force)
 {
 	struct flow_head *head = rtnl_dereference(tp->root);
 	struct flow_filter *f, *next;
 
+	if (!force && !list_empty(&head->filters))
+		return false;
+
 	list_for_each_entry_safe(f, next, &head->filters, list) {
 		list_del_rcu(&f->list);
 		call_rcu(&f->rcu, flow_destroy_filter);
 	}
 	RCU_INIT_POINTER(tp->root, NULL);
 	kfree_rcu(head, rcu);
+	return true;
 }
 
 static unsigned long flow_get(struct tcf_proto *tp, u32 handle)
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 9d9aa3e..715e01e 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -133,14 +133,20 @@ static void fw_delete_filter(struct rcu_head *head)
 	kfree(f);
 }
 
-static void fw_destroy(struct tcf_proto *tp)
+static bool fw_destroy(struct tcf_proto *tp, bool force)
 {
 	struct fw_head *head = rtnl_dereference(tp->root);
 	struct fw_filter *f;
 	int h;
 
 	if (head == NULL)
-		return;
+		return true;
+
+	if (!force) {
+		for (h = 0; h < HTSIZE; h++)
+			if (rcu_access_pointer(head->ht[h]))
+				return false;
+	}
 
 	for (h = 0; h < HTSIZE; h++) {
 		while ((f = rtnl_dereference(head->ht[h])) != NULL) {
@@ -152,6 +158,7 @@ static void fw_destroy(struct tcf_proto *tp)
 	}
 	RCU_INIT_POINTER(tp->root, NULL);
 	kfree_rcu(head, rcu);
+	return true;
 }
 
 static int fw_delete(struct tcf_proto *tp, unsigned long arg)
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index bb8a602..08a3b0a 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -277,13 +277,20 @@ route4_delete_filter(struct rcu_head *head)
 	kfree(f);
 }
 
-static void route4_destroy(struct tcf_proto *tp)
+static bool route4_destroy(struct tcf_proto *tp, bool force)
 {
 	struct route4_head *head = rtnl_dereference(tp->root);
 	int h1, h2;
 
 	if (head == NULL)
-		return;
+		return true;
+
+	if (!force) {
+		for (h1 = 0; h1 <= 256; h1++) {
+			if (rcu_access_pointer(head->table[h1]))
+				return false;
+		}
+	}
 
 	for (h1 = 0; h1 <= 256; h1++) {
 		struct route4_bucket *b;
@@ -308,6 +315,7 @@ static void route4_destroy(struct tcf_proto *tp)
 	}
 	RCU_INIT_POINTER(tp->root, NULL);
 	kfree_rcu(head, rcu);
+	return true;
 }
 
 static int route4_delete(struct tcf_proto *tp, unsigned long arg)
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index edd8ade..02fa827 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -291,13 +291,20 @@ rsvp_delete_filter(struct tcf_proto *tp, struct rsvp_filter *f)
 	kfree_rcu(f, rcu);
 }
 
-static void rsvp_destroy(struct tcf_proto *tp)
+static bool rsvp_destroy(struct tcf_proto *tp, bool force)
 {
 	struct rsvp_head *data = rtnl_dereference(tp->root);
 	int h1, h2;
 
 	if (data == NULL)
-		return;
+		return true;
+
+	if (!force) {
+		for (h1 = 0; h1 < 256; h1++) {
+			if (rcu_access_pointer(data->ht[h1]))
+				return false;
+		}
+	}
 
 	RCU_INIT_POINTER(tp->root, NULL);
 
@@ -319,6 +326,7 @@ static void rsvp_destroy(struct tcf_proto *tp)
 		}
 	}
 	kfree_rcu(data, rcu);
+	return true;
 }
 
 static int rsvp_delete(struct tcf_proto *tp, unsigned long arg)
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index bd49bf5..a557dba 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -468,11 +468,14 @@ static void tcindex_walk(struct tcf_proto *tp, struct tcf_walker *walker)
 	}
 }
 
-static void tcindex_destroy(struct tcf_proto *tp)
+static bool tcindex_destroy(struct tcf_proto *tp, bool force)
 {
 	struct tcindex_data *p = rtnl_dereference(tp->root);
 	struct tcf_walker walker;
 
+	if (!force)
+		return false;
+
 	pr_debug("tcindex_destroy(tp %p),p %p\n", tp, p);
 	walker.count = 0;
 	walker.skip = 0;
@@ -481,6 +484,7 @@ static void tcindex_destroy(struct tcf_proto *tp)
 
 	RCU_INIT_POINTER(tp->root, NULL);
 	call_rcu(&p->rcu, __tcindex_destroy);
+	return true;
 }
 
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 09487af..375e51b 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -460,13 +460,35 @@ static int u32_destroy_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 	return -ENOENT;
 }
 
-static void u32_destroy(struct tcf_proto *tp)
+static bool ht_empty(struct tc_u_hnode *ht)
+{
+	unsigned int h;
+
+	for (h = 0; h <= ht->divisor; h++)
+		if (rcu_access_pointer(ht->ht[h]))
+			return false;
+
+	return true;
+}
+
+static bool u32_destroy(struct tcf_proto *tp, bool force)
 {
 	struct tc_u_common *tp_c = tp->data;
 	struct tc_u_hnode *root_ht = rtnl_dereference(tp->root);
 
 	WARN_ON(root_ht == NULL);
 
+	if (!force) {
+		if (root_ht) {
+			if (root_ht->refcnt > 1)
+				return false;
+			if (root_ht->refcnt == 1) {
+				if (!ht_empty(root_ht))
+					return false;
+			}
+		}
+	}
+
 	if (root_ht && --root_ht->refcnt == 0)
 		u32_destroy_hnode(tp, root_ht);
 
@@ -491,6 +513,7 @@ static void u32_destroy(struct tcf_proto *tp)
 	}
 
 	tp->data = NULL;
+	return true;
 }
 
 static int u32_delete(struct tcf_proto *tp, unsigned long arg)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 243b7d1..ad9eed7 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1858,11 +1858,15 @@ int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 }
 EXPORT_SYMBOL(tc_classify);
 
-void tcf_destroy(struct tcf_proto *tp)
+bool tcf_destroy(struct tcf_proto *tp, bool force)
 {
-	tp->ops->destroy(tp);
-	module_put(tp->ops->owner);
-	kfree_rcu(tp, rcu);
+	if (tp->ops->destroy(tp, force)) {
+		module_put(tp->ops->owner);
+		kfree_rcu(tp, rcu);
+		return true;
+	}
+
+	return false;
 }
 
 void tcf_destroy_chain(struct tcf_proto __rcu **fl)
@@ -1871,7 +1875,7 @@ void tcf_destroy_chain(struct tcf_proto __rcu **fl)
 
 	while ((tp = rtnl_dereference(*fl)) != NULL) {
 		RCU_INIT_POINTER(*fl, tp->next);
-		tcf_destroy(tp);
+		tcf_destroy(tp, true);
 	}
 }
 EXPORT_SYMBOL(tcf_destroy_chain);
-- 
1.8.3.1
