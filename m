From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 2/2] net_sched: use void pointer for filter handle
Date: Fri,  4 Aug 2017 21:31:43 -0700
Message-ID: <20170805043143.13680-3-xiyou.wangcong@gmail.com>
References: <20170805043143.13680-1-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, jiri@resnulli.us,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33261 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751026AbdHEEb4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 00:31:56 -0400
Received: by mail-pf0-f193.google.com with SMTP id c65so3556480pfl.0
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 21:31:56 -0700 (PDT)
In-Reply-To: <20170805043143.13680-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now we use 'unsigned long fh' as a pointer in every place,
it is safe to convert it to a void pointer now. This gets
rid of many casts to pointer.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/pkt_cls.h     |  2 +-
 include/net/sch_generic.h |  8 ++++----
 net/sched/cls_api.c       | 17 ++++++++---------
 net/sched/cls_basic.c     | 22 ++++++++++------------
 net/sched/cls_bpf.c       | 27 ++++++++++++---------------
 net/sched/cls_cgroup.c    | 12 ++++++------
 net/sched/cls_flow.c      | 24 ++++++++++++------------
 net/sched/cls_flower.c    | 22 +++++++++++-----------
 net/sched/cls_fw.c        | 26 +++++++++++++-------------
 net/sched/cls_matchall.c  | 16 ++++++++--------
 net/sched/cls_route.c     | 26 +++++++++++++-------------
 net/sched/cls_rsvp.h      | 24 ++++++++++++------------
 net/sched/cls_tcindex.c   | 36 ++++++++++++++++--------------------
 net/sched/cls_u32.c       | 30 +++++++++++++++---------------
 14 files changed, 141 insertions(+), 151 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index e0c54f111467..4667e6173fd7 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -11,7 +11,7 @@ struct tcf_walker {
 	int	stop;
 	int	skip;
 	int	count;
-	int	(*fn)(struct tcf_proto *, unsigned long node, struct tcf_walker *);
+	int	(*fn)(struct tcf_proto *, void *node, struct tcf_walker *);
 };
 
 int register_tcf_proto_ops(struct tcf_proto_ops *ops);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 1c123e2b2415..e79f5ad1c5f3 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -213,16 +213,16 @@ struct tcf_proto_ops {
 	int			(*init)(struct tcf_proto*);
 	void			(*destroy)(struct tcf_proto*);
 
-	unsigned long		(*get)(struct tcf_proto*, u32 handle);
+	void*			(*get)(struct tcf_proto*, u32 handle);
 	int			(*change)(struct net *net, struct sk_buff *,
 					struct tcf_proto*, unsigned long,
 					u32 handle, struct nlattr **,
-					unsigned long *, bool);
-	int			(*delete)(struct tcf_proto*, unsigned long, bool*);
+					void **, bool);
+	int			(*delete)(struct tcf_proto*, void *, bool*);
 	void			(*walk)(struct tcf_proto*, struct tcf_walker *arg);
 
 	/* rtnetlink specific */
-	int			(*dump)(struct net*, struct tcf_proto*, unsigned long,
+	int			(*dump)(struct net*, struct tcf_proto*, void *,
 					struct sk_buff *skb, struct tcmsg*);
 
 	struct module		*owner;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index afd099727aea..668afb6e9885 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -102,11 +102,11 @@ EXPORT_SYMBOL(unregister_tcf_proto_ops);
 
 static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 			  struct nlmsghdr *n, struct tcf_proto *tp,
-			  unsigned long fh, int event, bool unicast);
+			  void *fh, int event, bool unicast);
 
 static int tfilter_del_notify(struct net *net, struct sk_buff *oskb,
 			      struct nlmsghdr *n, struct tcf_proto *tp,
-			      unsigned long fh, bool unicast, bool *last);
+			      void *fh, bool unicast, bool *last);
 
 static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
 				 struct nlmsghdr *n,
@@ -432,7 +432,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	struct tcf_proto *tp;
 	const struct Qdisc_class_ops *cops;
 	unsigned long cl;
-	unsigned long fh;
+	void *fh;
 	int err;
 	int tp_created;
 
@@ -571,7 +571,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 
 	fh = tp->ops->get(tp, t->tcm_handle);
 
-	if (fh == 0) {
+	if (!fh) {
 		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
 			tcf_chain_tp_remove(chain, &chain_info, tp);
 			tfilter_notify(net, skb, n, tp, fh,
@@ -641,7 +641,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 }
 
 static int tcf_fill_node(struct net *net, struct sk_buff *skb,
-			 struct tcf_proto *tp, unsigned long fh, u32 portid,
+			 struct tcf_proto *tp, void *fh, u32 portid,
 			 u32 seq, u16 flags, int event)
 {
 	struct tcmsg *tcm;
@@ -679,7 +679,7 @@ static int tcf_fill_node(struct net *net, struct sk_buff *skb,
 
 static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 			  struct nlmsghdr *n, struct tcf_proto *tp,
-			  unsigned long fh, int event, bool unicast)
+			  void *fh, int event, bool unicast)
 {
 	struct sk_buff *skb;
 	u32 portid = oskb ? NETLINK_CB(oskb).portid : 0;
@@ -703,7 +703,7 @@ static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 
 static int tfilter_del_notify(struct net *net, struct sk_buff *oskb,
 			      struct nlmsghdr *n, struct tcf_proto *tp,
-			      unsigned long fh, bool unicast, bool *last)
+			      void *fh, bool unicast, bool *last)
 {
 	struct sk_buff *skb;
 	u32 portid = oskb ? NETLINK_CB(oskb).portid : 0;
@@ -738,8 +738,7 @@ struct tcf_dump_args {
 	struct netlink_callback *cb;
 };
 
-static int tcf_node_dump(struct tcf_proto *tp, unsigned long n,
-			 struct tcf_walker *arg)
+static int tcf_node_dump(struct tcf_proto *tp, void *n, struct tcf_walker *arg)
 {
 	struct tcf_dump_args *a = (void *)arg;
 	struct net *net = sock_net(a->skb->sk);
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 7c7a82138f76..73cc7f167a38 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -56,20 +56,18 @@ static int basic_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	return -1;
 }
 
-static unsigned long basic_get(struct tcf_proto *tp, u32 handle)
+static void *basic_get(struct tcf_proto *tp, u32 handle)
 {
-	unsigned long l = 0UL;
 	struct basic_head *head = rtnl_dereference(tp->root);
 	struct basic_filter *f;
 
 	list_for_each_entry(f, &head->flist, link) {
 		if (f->handle == handle) {
-			l = (unsigned long) f;
-			break;
+			return f;
 		}
 	}
 
-	return l;
+	return NULL;
 }
 
 static int basic_init(struct tcf_proto *tp)
@@ -106,10 +104,10 @@ static void basic_destroy(struct tcf_proto *tp)
 	kfree_rcu(head, rcu);
 }
 
-static int basic_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
+static int basic_delete(struct tcf_proto *tp, void *arg, bool *last)
 {
 	struct basic_head *head = rtnl_dereference(tp->root);
-	struct basic_filter *f = (struct basic_filter *) arg;
+	struct basic_filter *f = arg;
 
 	list_del_rcu(&f->link);
 	tcf_unbind_filter(tp, &f->res);
@@ -149,7 +147,7 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 
 static int basic_change(struct net *net, struct sk_buff *in_skb,
 			struct tcf_proto *tp, unsigned long base, u32 handle,
-			struct nlattr **tca, unsigned long *arg, bool ovr)
+			struct nlattr **tca, void **arg, bool ovr)
 {
 	int err;
 	struct basic_head *head = rtnl_dereference(tp->root);
@@ -202,7 +200,7 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		goto errout;
 
-	*arg = (unsigned long)fnew;
+	*arg = fnew;
 
 	if (fold) {
 		list_replace_rcu(&fold->link, &fnew->link);
@@ -228,7 +226,7 @@ static void basic_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 		if (arg->count < arg->skip)
 			goto skip;
 
-		if (arg->fn(tp, (unsigned long) f, arg) < 0) {
+		if (arg->fn(tp, f, arg) < 0) {
 			arg->stop = 1;
 			break;
 		}
@@ -237,10 +235,10 @@ static void basic_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	}
 }
 
-static int basic_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
+static int basic_dump(struct net *net, struct tcf_proto *tp, void *fh,
 		      struct sk_buff *skb, struct tcmsg *t)
 {
-	struct basic_filter *f = (struct basic_filter *) fh;
+	struct basic_filter *f = fh;
 	struct nlattr *nest;
 
 	if (f == NULL)
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index cf248c3137ad..87554ec40e73 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -276,11 +276,11 @@ static void __cls_bpf_delete(struct tcf_proto *tp, struct cls_bpf_prog *prog)
 	call_rcu(&prog->rcu, cls_bpf_delete_prog_rcu);
 }
 
-static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
+static int cls_bpf_delete(struct tcf_proto *tp, void *arg, bool *last)
 {
 	struct cls_bpf_head *head = rtnl_dereference(tp->root);
 
-	__cls_bpf_delete(tp, (struct cls_bpf_prog *) arg);
+	__cls_bpf_delete(tp, arg);
 	*last = list_empty(&head->plist);
 	return 0;
 }
@@ -296,20 +296,17 @@ static void cls_bpf_destroy(struct tcf_proto *tp)
 	kfree_rcu(head, rcu);
 }
 
-static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
+static void *cls_bpf_get(struct tcf_proto *tp, u32 handle)
 {
 	struct cls_bpf_head *head = rtnl_dereference(tp->root);
 	struct cls_bpf_prog *prog;
-	unsigned long ret = 0UL;
 
 	list_for_each_entry(prog, &head->plist, link) {
-		if (prog->handle == handle) {
-			ret = (unsigned long) prog;
-			break;
-		}
+		if (prog->handle == handle)
+			return prog;
 	}
 
-	return ret;
+	return NULL;
 }
 
 static int cls_bpf_prog_from_ops(struct nlattr **tb, struct cls_bpf_prog *prog)
@@ -454,10 +451,10 @@ static u32 cls_bpf_grab_new_handle(struct tcf_proto *tp,
 static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 			  struct tcf_proto *tp, unsigned long base,
 			  u32 handle, struct nlattr **tca,
-			  unsigned long *arg, bool ovr)
+			  void **arg, bool ovr)
 {
 	struct cls_bpf_head *head = rtnl_dereference(tp->root);
-	struct cls_bpf_prog *oldprog = (struct cls_bpf_prog *) *arg;
+	struct cls_bpf_prog *oldprog = *arg;
 	struct nlattr *tb[TCA_BPF_MAX + 1];
 	struct cls_bpf_prog *prog;
 	int ret;
@@ -515,7 +512,7 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 		list_add_rcu(&prog->link, &head->plist);
 	}
 
-	*arg = (unsigned long) prog;
+	*arg = prog;
 	return 0;
 
 errout:
@@ -563,10 +560,10 @@ static int cls_bpf_dump_ebpf_info(const struct cls_bpf_prog *prog,
 	return 0;
 }
 
-static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
+static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, void *fh,
 			struct sk_buff *skb, struct tcmsg *tm)
 {
-	struct cls_bpf_prog *prog = (struct cls_bpf_prog *) fh;
+	struct cls_bpf_prog *prog = fh;
 	struct nlattr *nest;
 	u32 bpf_flags = 0;
 	int ret;
@@ -624,7 +621,7 @@ static void cls_bpf_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	list_for_each_entry(prog, &head->plist, link) {
 		if (arg->count < arg->skip)
 			goto skip;
-		if (arg->fn(tp, (unsigned long) prog, arg) < 0) {
+		if (arg->fn(tp, prog, arg) < 0) {
 			arg->stop = 1;
 			break;
 		}
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index df7a582775df..d48452f87975 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -43,9 +43,9 @@ static int cls_cgroup_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	return tcf_exts_exec(skb, &head->exts, res);
 }
 
-static unsigned long cls_cgroup_get(struct tcf_proto *tp, u32 handle)
+static void *cls_cgroup_get(struct tcf_proto *tp, u32 handle)
 {
-	return 0UL;
+	return NULL;
 }
 
 static int cls_cgroup_init(struct tcf_proto *tp)
@@ -71,7 +71,7 @@ static void cls_cgroup_destroy_rcu(struct rcu_head *root)
 static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 			     struct tcf_proto *tp, unsigned long base,
 			     u32 handle, struct nlattr **tca,
-			     unsigned long *arg, bool ovr)
+			     void **arg, bool ovr)
 {
 	struct nlattr *tb[TCA_CGROUP_MAX + 1];
 	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
@@ -128,7 +128,7 @@ static void cls_cgroup_destroy(struct tcf_proto *tp)
 		call_rcu(&head->rcu, cls_cgroup_destroy_rcu);
 }
 
-static int cls_cgroup_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
+static int cls_cgroup_delete(struct tcf_proto *tp, void *arg, bool *last)
 {
 	return -EOPNOTSUPP;
 }
@@ -140,7 +140,7 @@ static void cls_cgroup_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	if (arg->count < arg->skip)
 		goto skip;
 
-	if (arg->fn(tp, (unsigned long) head, arg) < 0) {
+	if (arg->fn(tp, head, arg) < 0) {
 		arg->stop = 1;
 		return;
 	}
@@ -148,7 +148,7 @@ static void cls_cgroup_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	arg->count++;
 }
 
-static int cls_cgroup_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
+static int cls_cgroup_dump(struct net *net, struct tcf_proto *tp, void *fh,
 			   struct sk_buff *skb, struct tcmsg *t)
 {
 	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 55e281b20140..2a3a60ec5b86 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -382,7 +382,7 @@ static void flow_destroy_filter(struct rcu_head *head)
 static int flow_change(struct net *net, struct sk_buff *in_skb,
 		       struct tcf_proto *tp, unsigned long base,
 		       u32 handle, struct nlattr **tca,
-		       unsigned long *arg, bool ovr)
+		       void **arg, bool ovr)
 {
 	struct flow_head *head = rtnl_dereference(tp->root);
 	struct flow_filter *fold, *fnew;
@@ -439,7 +439,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		goto err2;
 
-	fold = (struct flow_filter *)*arg;
+	fold = *arg;
 	if (fold) {
 		err = -EINVAL;
 		if (fold->handle != handle && handle)
@@ -532,12 +532,12 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	if (perturb_period)
 		mod_timer(&fnew->perturb_timer, jiffies + perturb_period);
 
-	if (*arg == 0)
+	if (!*arg)
 		list_add_tail_rcu(&fnew->list, &head->filters);
 	else
 		list_replace_rcu(&fold->list, &fnew->list);
 
-	*arg = (unsigned long)fnew;
+	*arg = fnew;
 
 	if (fold)
 		call_rcu(&fold->rcu, flow_destroy_filter);
@@ -551,10 +551,10 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	return err;
 }
 
-static int flow_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
+static int flow_delete(struct tcf_proto *tp, void *arg, bool *last)
 {
 	struct flow_head *head = rtnl_dereference(tp->root);
-	struct flow_filter *f = (struct flow_filter *)arg;
+	struct flow_filter *f = arg;
 
 	list_del_rcu(&f->list);
 	call_rcu(&f->rcu, flow_destroy_filter);
@@ -586,21 +586,21 @@ static void flow_destroy(struct tcf_proto *tp)
 	kfree_rcu(head, rcu);
 }
 
-static unsigned long flow_get(struct tcf_proto *tp, u32 handle)
+static void *flow_get(struct tcf_proto *tp, u32 handle)
 {
 	struct flow_head *head = rtnl_dereference(tp->root);
 	struct flow_filter *f;
 
 	list_for_each_entry(f, &head->filters, list)
 		if (f->handle == handle)
-			return (unsigned long)f;
-	return 0;
+			return f;
+	return NULL;
 }
 
-static int flow_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
+static int flow_dump(struct net *net, struct tcf_proto *tp, void *fh,
 		     struct sk_buff *skb, struct tcmsg *t)
 {
-	struct flow_filter *f = (struct flow_filter *)fh;
+	struct flow_filter *f = fh;
 	struct nlattr *nest;
 
 	if (f == NULL)
@@ -666,7 +666,7 @@ static void flow_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	list_for_each_entry(f, &head->filters, list) {
 		if (arg->count < arg->skip)
 			goto skip;
-		if (arg->fn(tp, (unsigned long)f, arg) < 0) {
+		if (arg->fn(tp, f, arg) < 0) {
 			arg->stop = 1;
 			break;
 		}
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 7ab524fc43f9..6c194b8f55d6 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -346,15 +346,15 @@ static void fl_destroy(struct tcf_proto *tp)
 	call_rcu(&head->rcu, fl_destroy_rcu);
 }
 
-static unsigned long fl_get(struct tcf_proto *tp, u32 handle)
+static void *fl_get(struct tcf_proto *tp, u32 handle)
 {
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
 	struct cls_fl_filter *f;
 
 	list_for_each_entry(f, &head->filters, list)
 		if (f->handle == handle)
-			return (unsigned long) f;
-	return 0;
+			return f;
+	return NULL;
 }
 
 static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
@@ -897,10 +897,10 @@ static u32 fl_grab_new_handle(struct tcf_proto *tp,
 static int fl_change(struct net *net, struct sk_buff *in_skb,
 		     struct tcf_proto *tp, unsigned long base,
 		     u32 handle, struct nlattr **tca,
-		     unsigned long *arg, bool ovr)
+		     void **arg, bool ovr)
 {
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
-	struct cls_fl_filter *fold = (struct cls_fl_filter *) *arg;
+	struct cls_fl_filter *fold = *arg;
 	struct cls_fl_filter *fnew;
 	struct nlattr **tb;
 	struct fl_flow_mask mask = {};
@@ -991,7 +991,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 			fl_hw_destroy_filter(tp, fold);
 	}
 
-	*arg = (unsigned long) fnew;
+	*arg = fnew;
 
 	if (fold) {
 		list_replace_rcu(&fold->list, &fnew->list);
@@ -1012,10 +1012,10 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	return err;
 }
 
-static int fl_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
+static int fl_delete(struct tcf_proto *tp, void *arg, bool *last)
 {
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
-	struct cls_fl_filter *f = (struct cls_fl_filter *) arg;
+	struct cls_fl_filter *f = arg;
 
 	if (!tc_skip_sw(f->flags))
 		rhashtable_remove_fast(&head->ht, &f->ht_node,
@@ -1033,7 +1033,7 @@ static void fl_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	list_for_each_entry_rcu(f, &head->filters, list) {
 		if (arg->count < arg->skip)
 			goto skip;
-		if (arg->fn(tp, (unsigned long) f, arg) < 0) {
+		if (arg->fn(tp, f, arg) < 0) {
 			arg->stop = 1;
 			break;
 		}
@@ -1168,11 +1168,11 @@ static int fl_dump_key_flags(struct sk_buff *skb, u32 flags_key, u32 flags_mask)
 	return nla_put(skb, TCA_FLOWER_KEY_FLAGS_MASK, 4, &_mask);
 }
 
-static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
+static int fl_dump(struct net *net, struct tcf_proto *tp, void *fh,
 		   struct sk_buff *skb, struct tcmsg *t)
 {
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
-	struct cls_fl_filter *f = (struct cls_fl_filter *) fh;
+	struct cls_fl_filter *f = fh;
 	struct nlattr *nest;
 	struct fl_flow_key *key, *mask;
 
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 11f178f1b2be..192255ec50bd 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -95,20 +95,20 @@ static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	return -1;
 }
 
-static unsigned long fw_get(struct tcf_proto *tp, u32 handle)
+static void *fw_get(struct tcf_proto *tp, u32 handle)
 {
 	struct fw_head *head = rtnl_dereference(tp->root);
 	struct fw_filter *f;
 
 	if (head == NULL)
-		return 0;
+		return NULL;
 
 	f = rtnl_dereference(head->ht[fw_hash(handle)]);
 	for (; f; f = rtnl_dereference(f->next)) {
 		if (f->id == handle)
-			return (unsigned long)f;
+			return f;
 	}
-	return 0;
+	return NULL;
 }
 
 static int fw_init(struct tcf_proto *tp)
@@ -147,10 +147,10 @@ static void fw_destroy(struct tcf_proto *tp)
 	kfree_rcu(head, rcu);
 }
 
-static int fw_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
+static int fw_delete(struct tcf_proto *tp, void *arg, bool *last)
 {
 	struct fw_head *head = rtnl_dereference(tp->root);
-	struct fw_filter *f = (struct fw_filter *)arg;
+	struct fw_filter *f = arg;
 	struct fw_filter __rcu **fp;
 	struct fw_filter *pfp;
 	int ret = -EINVAL;
@@ -230,11 +230,11 @@ static int fw_set_parms(struct net *net, struct tcf_proto *tp,
 
 static int fw_change(struct net *net, struct sk_buff *in_skb,
 		     struct tcf_proto *tp, unsigned long base,
-		     u32 handle, struct nlattr **tca, unsigned long *arg,
+		     u32 handle, struct nlattr **tca, void **arg,
 		     bool ovr)
 {
 	struct fw_head *head = rtnl_dereference(tp->root);
-	struct fw_filter *f = (struct fw_filter *) *arg;
+	struct fw_filter *f = *arg;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_FW_MAX + 1];
 	int err;
@@ -288,7 +288,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 		tcf_unbind_filter(tp, &f->res);
 		call_rcu(&f->rcu, fw_delete_filter);
 
-		*arg = (unsigned long)fnew;
+		*arg = fnew;
 		return err;
 	}
 
@@ -325,7 +325,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 	RCU_INIT_POINTER(f->next, head->ht[fw_hash(handle)]);
 	rcu_assign_pointer(head->ht[fw_hash(handle)], f);
 
-	*arg = (unsigned long)f;
+	*arg = f;
 	return 0;
 
 errout:
@@ -354,7 +354,7 @@ static void fw_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 				arg->count++;
 				continue;
 			}
-			if (arg->fn(tp, (unsigned long)f, arg) < 0) {
+			if (arg->fn(tp, f, arg) < 0) {
 				arg->stop = 1;
 				return;
 			}
@@ -363,11 +363,11 @@ static void fw_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	}
 }
 
-static int fw_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
+static int fw_dump(struct net *net, struct tcf_proto *tp, void *fh,
 		   struct sk_buff *skb, struct tcmsg *t)
 {
 	struct fw_head *head = rtnl_dereference(tp->root);
-	struct fw_filter *f = (struct fw_filter *)fh;
+	struct fw_filter *f = fh;
 	struct nlattr *nest;
 
 	if (f == NULL)
diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index f35177b48373..5bf47b03c190 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -105,9 +105,9 @@ static void mall_destroy(struct tcf_proto *tp)
 	call_rcu(&head->rcu, mall_destroy_rcu);
 }
 
-static unsigned long mall_get(struct tcf_proto *tp, u32 handle)
+static void *mall_get(struct tcf_proto *tp, u32 handle)
 {
-	return 0UL;
+	return NULL;
 }
 
 static const struct nla_policy mall_policy[TCA_MATCHALL_MAX + 1] = {
@@ -136,7 +136,7 @@ static int mall_set_parms(struct net *net, struct tcf_proto *tp,
 static int mall_change(struct net *net, struct sk_buff *in_skb,
 		       struct tcf_proto *tp, unsigned long base,
 		       u32 handle, struct nlattr **tca,
-		       unsigned long *arg, bool ovr)
+		       void **arg, bool ovr)
 {
 	struct cls_mall_head *head = rtnl_dereference(tp->root);
 	struct net_device *dev = tp->q->dev_queue->dev;
@@ -192,7 +192,7 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 	if (!tc_in_hw(new->flags))
 		new->flags |= TCA_CLS_FLAGS_NOT_IN_HW;
 
-	*arg = (unsigned long) head;
+	*arg = head;
 	rcu_assign_pointer(tp->root, new);
 	return 0;
 
@@ -204,7 +204,7 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 	return err;
 }
 
-static int mall_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
+static int mall_delete(struct tcf_proto *tp, void *arg, bool *last)
 {
 	return -EOPNOTSUPP;
 }
@@ -215,16 +215,16 @@ static void mall_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 
 	if (arg->count < arg->skip)
 		goto skip;
-	if (arg->fn(tp, (unsigned long) head, arg) < 0)
+	if (arg->fn(tp, head, arg) < 0)
 		arg->stop = 1;
 skip:
 	arg->count++;
 }
 
-static int mall_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
+static int mall_dump(struct net *net, struct tcf_proto *tp, void *fh,
 		     struct sk_buff *skb, struct tcmsg *t)
 {
-	struct cls_mall_head *head = (struct cls_mall_head *) fh;
+	struct cls_mall_head *head = fh;
 	struct nlattr *nest;
 
 	if (!head)
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index f1e7d7850b44..3b70982394ce 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -216,7 +216,7 @@ static inline u32 from_hash(u32 id)
 	return 16 + (id & 0xF);
 }
 
-static unsigned long route4_get(struct tcf_proto *tp, u32 handle)
+static void *route4_get(struct tcf_proto *tp, u32 handle)
 {
 	struct route4_head *head = rtnl_dereference(tp->root);
 	struct route4_bucket *b;
@@ -225,11 +225,11 @@ static unsigned long route4_get(struct tcf_proto *tp, u32 handle)
 
 	h1 = to_hash(handle);
 	if (h1 > 256)
-		return 0;
+		return NULL;
 
 	h2 = from_hash(handle >> 16);
 	if (h2 > 32)
-		return 0;
+		return NULL;
 
 	b = rtnl_dereference(head->table[h1]);
 	if (b) {
@@ -237,9 +237,9 @@ static unsigned long route4_get(struct tcf_proto *tp, u32 handle)
 		     f;
 		     f = rtnl_dereference(f->next))
 			if (f->handle == handle)
-				return (unsigned long)f;
+				return f;
 	}
-	return 0;
+	return NULL;
 }
 
 static int route4_init(struct tcf_proto *tp)
@@ -294,10 +294,10 @@ static void route4_destroy(struct tcf_proto *tp)
 	kfree_rcu(head, rcu);
 }
 
-static int route4_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
+static int route4_delete(struct tcf_proto *tp, void *arg, bool *last)
 {
 	struct route4_head *head = rtnl_dereference(tp->root);
-	struct route4_filter *f = (struct route4_filter *)arg;
+	struct route4_filter *f = arg;
 	struct route4_filter __rcu **fp;
 	struct route4_filter *nf;
 	struct route4_bucket *b;
@@ -448,7 +448,7 @@ static int route4_set_parms(struct net *net, struct tcf_proto *tp,
 
 static int route4_change(struct net *net, struct sk_buff *in_skb,
 			 struct tcf_proto *tp, unsigned long base, u32 handle,
-			 struct nlattr **tca, unsigned long *arg, bool ovr)
+			 struct nlattr **tca, void **arg, bool ovr)
 {
 	struct route4_head *head = rtnl_dereference(tp->root);
 	struct route4_filter __rcu **fp;
@@ -467,7 +467,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
-	fold = (struct route4_filter *)*arg;
+	fold = *arg;
 	if (fold && handle && fold->handle != handle)
 			return -EINVAL;
 
@@ -525,7 +525,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 	}
 
 	route4_reset_fastmap(head);
-	*arg = (unsigned long)f;
+	*arg = f;
 	if (fold) {
 		tcf_unbind_filter(tp, &fold->res);
 		call_rcu(&fold->rcu, route4_delete_filter);
@@ -564,7 +564,7 @@ static void route4_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 						arg->count++;
 						continue;
 					}
-					if (arg->fn(tp, (unsigned long)f, arg) < 0) {
+					if (arg->fn(tp, f, arg) < 0) {
 						arg->stop = 1;
 						return;
 					}
@@ -575,10 +575,10 @@ static void route4_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	}
 }
 
-static int route4_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
+static int route4_dump(struct net *net, struct tcf_proto *tp, void *fh,
 		       struct sk_buff *skb, struct tcmsg *t)
 {
-	struct route4_filter *f = (struct route4_filter *)fh;
+	struct route4_filter *f = fh;
 	struct nlattr *nest;
 	u32 id;
 
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 4adb67a73491..26203ff817f3 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -248,7 +248,7 @@ static void rsvp_replace(struct tcf_proto *tp, struct rsvp_filter *n, u32 h)
 	BUG_ON(1);
 }
 
-static unsigned long rsvp_get(struct tcf_proto *tp, u32 handle)
+static void *rsvp_get(struct tcf_proto *tp, u32 handle)
 {
 	struct rsvp_head *head = rtnl_dereference(tp->root);
 	struct rsvp_session *s;
@@ -257,17 +257,17 @@ static unsigned long rsvp_get(struct tcf_proto *tp, u32 handle)
 	unsigned int h2 = (handle >> 8) & 0xFF;
 
 	if (h2 > 16)
-		return 0;
+		return NULL;
 
 	for (s = rtnl_dereference(head->ht[h1]); s;
 	     s = rtnl_dereference(s->next)) {
 		for (f = rtnl_dereference(s->ht[h2]); f;
 		     f = rtnl_dereference(f->next)) {
 			if (f->handle == handle)
-				return (unsigned long)f;
+				return f;
 		}
 	}
-	return 0;
+	return NULL;
 }
 
 static int rsvp_init(struct tcf_proto *tp)
@@ -328,10 +328,10 @@ static void rsvp_destroy(struct tcf_proto *tp)
 	kfree_rcu(data, rcu);
 }
 
-static int rsvp_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
+static int rsvp_delete(struct tcf_proto *tp, void *arg, bool *last)
 {
 	struct rsvp_head *head = rtnl_dereference(tp->root);
-	struct rsvp_filter *nfp, *f = (struct rsvp_filter *)arg;
+	struct rsvp_filter *nfp, *f = arg;
 	struct rsvp_filter __rcu **fp;
 	unsigned int h = f->handle;
 	struct rsvp_session __rcu **sp;
@@ -464,7 +464,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 		       struct tcf_proto *tp, unsigned long base,
 		       u32 handle,
 		       struct nlattr **tca,
-		       unsigned long *arg, bool ovr)
+		       void **arg, bool ovr)
 {
 	struct rsvp_head *data = rtnl_dereference(tp->root);
 	struct rsvp_filter *f, *nfp;
@@ -493,7 +493,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		goto errout2;
 
-	f = (struct rsvp_filter *)*arg;
+	f = *arg;
 	if (f) {
 		/* Node exists: adjust only classid */
 		struct rsvp_filter *n;
@@ -604,7 +604,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 			RCU_INIT_POINTER(f->next, nfp);
 			rcu_assign_pointer(*fp, f);
 
-			*arg = (unsigned long)f;
+			*arg = f;
 			return 0;
 		}
 	}
@@ -663,7 +663,7 @@ static void rsvp_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 						arg->count++;
 						continue;
 					}
-					if (arg->fn(tp, (unsigned long)f, arg) < 0) {
+					if (arg->fn(tp, f, arg) < 0) {
 						arg->stop = 1;
 						return;
 					}
@@ -674,10 +674,10 @@ static void rsvp_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	}
 }
 
-static int rsvp_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
+static int rsvp_dump(struct net *net, struct tcf_proto *tp, void *fh,
 		     struct sk_buff *skb, struct tcmsg *t)
 {
-	struct rsvp_filter *f = (struct rsvp_filter *)fh;
+	struct rsvp_filter *f = fh;
 	struct rsvp_session *s;
 	struct nlattr *nest;
 	struct tc_rsvp_pinfo pinfo;
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index d69f828f3fed..fb281b9b2c52 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -104,16 +104,16 @@ static int tcindex_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 }
 
 
-static unsigned long tcindex_get(struct tcf_proto *tp, u32 handle)
+static void *tcindex_get(struct tcf_proto *tp, u32 handle)
 {
 	struct tcindex_data *p = rtnl_dereference(tp->root);
 	struct tcindex_filter_result *r;
 
 	pr_debug("tcindex_get(tp %p,handle 0x%08x)\n", tp, handle);
 	if (p->perfect && handle >= p->alloc_hash)
-		return 0;
+		return NULL;
 	r = tcindex_lookup(p, handle);
-	return r && tcindex_filter_is_set(r) ? (unsigned long) r : 0UL;
+	return r && tcindex_filter_is_set(r) ? r : NULL;
 }
 
 static int tcindex_init(struct tcf_proto *tp)
@@ -150,14 +150,14 @@ static void tcindex_destroy_fexts(struct rcu_head *head)
 	kfree(f);
 }
 
-static int tcindex_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
+static int tcindex_delete(struct tcf_proto *tp, void *arg, bool *last)
 {
 	struct tcindex_data *p = rtnl_dereference(tp->root);
-	struct tcindex_filter_result *r = (struct tcindex_filter_result *) arg;
+	struct tcindex_filter_result *r = arg;
 	struct tcindex_filter __rcu **walk;
 	struct tcindex_filter *f = NULL;
 
-	pr_debug("tcindex_delete(tp %p,arg 0x%lx),p %p\n", tp, arg, p);
+	pr_debug("tcindex_delete(tp %p,arg %p),p %p\n", tp, arg, p);
 	if (p->perfect) {
 		if (!r->res.class)
 			return -ENOENT;
@@ -192,8 +192,7 @@ static int tcindex_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
 }
 
 static int tcindex_destroy_element(struct tcf_proto *tp,
-				   unsigned long arg,
-				   struct tcf_walker *walker)
+				   void *arg, struct tcf_walker *walker)
 {
 	bool last;
 
@@ -471,17 +470,17 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 static int
 tcindex_change(struct net *net, struct sk_buff *in_skb,
 	       struct tcf_proto *tp, unsigned long base, u32 handle,
-	       struct nlattr **tca, unsigned long *arg, bool ovr)
+	       struct nlattr **tca, void **arg, bool ovr)
 {
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_TCINDEX_MAX + 1];
 	struct tcindex_data *p = rtnl_dereference(tp->root);
-	struct tcindex_filter_result *r = (struct tcindex_filter_result *) *arg;
+	struct tcindex_filter_result *r = *arg;
 	int err;
 
 	pr_debug("tcindex_change(tp %p,handle 0x%08x,tca %p,arg %p),opt %p,"
-	    "p %p,r %p,*arg 0x%lx\n",
-	    tp, handle, tca, arg, opt, p, r, arg ? *arg : 0L);
+	    "p %p,r %p,*arg %p\n",
+	    tp, handle, tca, arg, opt, p, r, arg ? *arg : NULL);
 
 	if (!opt)
 		return 0;
@@ -506,9 +505,7 @@ static void tcindex_walk(struct tcf_proto *tp, struct tcf_walker *walker)
 			if (!p->perfect[i].res.class)
 				continue;
 			if (walker->count >= walker->skip) {
-				if (walker->fn(tp,
-				    (unsigned long) (p->perfect+i), walker)
-				     < 0) {
+				if (walker->fn(tp, p->perfect + i, walker) < 0) {
 					walker->stop = 1;
 					return;
 				}
@@ -522,8 +519,7 @@ static void tcindex_walk(struct tcf_proto *tp, struct tcf_walker *walker)
 		for (f = rtnl_dereference(p->h[i]); f; f = next) {
 			next = rtnl_dereference(f->next);
 			if (walker->count >= walker->skip) {
-				if (walker->fn(tp, (unsigned long) &f->result,
-				    walker) < 0) {
+				if (walker->fn(tp, &f->result, walker) < 0) {
 					walker->stop = 1;
 					return;
 				}
@@ -548,14 +544,14 @@ static void tcindex_destroy(struct tcf_proto *tp)
 }
 
 
-static int tcindex_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
+static int tcindex_dump(struct net *net, struct tcf_proto *tp, void *fh,
 			struct sk_buff *skb, struct tcmsg *t)
 {
 	struct tcindex_data *p = rtnl_dereference(tp->root);
-	struct tcindex_filter_result *r = (struct tcindex_filter_result *) fh;
+	struct tcindex_filter_result *r = fh;
 	struct nlattr *nest;
 
-	pr_debug("tcindex_dump(tp %p,fh 0x%lx,skb %p,t %p),p %p,r %p\n",
+	pr_debug("tcindex_dump(tp %p,fh %p,skb %p,t %p),p %p,r %p\n",
 		 tp, fh, skb, t, p, r);
 	pr_debug("p->perfect %p p->h %p\n", p->perfect, p->h);
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 9fd243799fe7..dd387bdf1b36 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -289,7 +289,7 @@ static struct tc_u_knode *u32_lookup_key(struct tc_u_hnode *ht, u32 handle)
 }
 
 
-static unsigned long u32_get(struct tcf_proto *tp, u32 handle)
+static void *u32_get(struct tcf_proto *tp, u32 handle)
 {
 	struct tc_u_hnode *ht;
 	struct tc_u_common *tp_c = tp->data;
@@ -300,12 +300,12 @@ static unsigned long u32_get(struct tcf_proto *tp, u32 handle)
 		ht = u32_lookup_ht(tp_c, TC_U32_HTID(handle));
 
 	if (!ht)
-		return 0;
+		return NULL;
 
 	if (TC_U32_KEY(handle) == 0)
-		return (unsigned long)ht;
+		return ht;
 
-	return (unsigned long)u32_lookup_key(ht, handle);
+	return u32_lookup_key(ht, handle);
 }
 
 static u32 gen_new_htid(struct tc_u_common *tp_c)
@@ -622,9 +622,9 @@ static void u32_destroy(struct tcf_proto *tp)
 	tp->data = NULL;
 }
 
-static int u32_delete(struct tcf_proto *tp, unsigned long arg, bool *last)
+static int u32_delete(struct tcf_proto *tp, void *arg, bool *last)
 {
-	struct tc_u_hnode *ht = (struct tc_u_hnode *)arg;
+	struct tc_u_hnode *ht = arg;
 	struct tc_u_hnode *root_ht = rtnl_dereference(tp->root);
 	struct tc_u_common *tp_c = tp->data;
 	int ret = 0;
@@ -848,7 +848,7 @@ static struct tc_u_knode *u32_init_knode(struct tcf_proto *tp,
 
 static int u32_change(struct net *net, struct sk_buff *in_skb,
 		      struct tcf_proto *tp, unsigned long base, u32 handle,
-		      struct nlattr **tca, unsigned long *arg, bool ovr)
+		      struct nlattr **tca, void **arg, bool ovr)
 {
 	struct tc_u_common *tp_c = tp->data;
 	struct tc_u_hnode *ht;
@@ -875,7 +875,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 			return -EINVAL;
 	}
 
-	n = (struct tc_u_knode *)*arg;
+	n = *arg;
 	if (n) {
 		struct tc_u_knode *new;
 
@@ -942,7 +942,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 
 		RCU_INIT_POINTER(ht->next, tp_c->hlist);
 		rcu_assign_pointer(tp_c->hlist, ht);
-		*arg = (unsigned long)ht;
+		*arg = ht;
 
 		return 0;
 	}
@@ -1037,7 +1037,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 
 		RCU_INIT_POINTER(n->next, pins);
 		rcu_assign_pointer(*ins, n);
-		*arg = (unsigned long)n;
+		*arg = n;
 		return 0;
 	}
 
@@ -1071,7 +1071,7 @@ static void u32_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 		if (ht->prio != tp->prio)
 			continue;
 		if (arg->count >= arg->skip) {
-			if (arg->fn(tp, (unsigned long)ht, arg) < 0) {
+			if (arg->fn(tp, ht, arg) < 0) {
 				arg->stop = 1;
 				return;
 			}
@@ -1085,7 +1085,7 @@ static void u32_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 					arg->count++;
 					continue;
 				}
-				if (arg->fn(tp, (unsigned long)n, arg) < 0) {
+				if (arg->fn(tp, n, arg) < 0) {
 					arg->stop = 1;
 					return;
 				}
@@ -1095,10 +1095,10 @@ static void u32_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	}
 }
 
-static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
+static int u32_dump(struct net *net, struct tcf_proto *tp, void *fh,
 		    struct sk_buff *skb, struct tcmsg *t)
 {
-	struct tc_u_knode *n = (struct tc_u_knode *)fh;
+	struct tc_u_knode *n = fh;
 	struct tc_u_hnode *ht_up, *ht_down;
 	struct nlattr *nest;
 
@@ -1112,7 +1112,7 @@ static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		goto nla_put_failure;
 
 	if (TC_U32_KEY(n->handle) == 0) {
-		struct tc_u_hnode *ht = (struct tc_u_hnode *)fh;
+		struct tc_u_hnode *ht = fh;
 		u32 divisor = ht->divisor + 1;
 
 		if (nla_put_u32(skb, TCA_U32_DIVISOR, divisor))
-- 
2.13.0
