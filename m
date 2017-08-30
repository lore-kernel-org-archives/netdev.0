From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: add reverse binding for tc class
Date: Wed, 30 Aug 2017 14:30:36 -0700
Message-ID: <20170830213036.24250-1-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33461 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdH3Var (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 17:30:47 -0400
Received: by mail-pg0-f67.google.com with SMTP id m15so5915596pgc.0
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 14:30:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TC filters when used as classifiers are bound to TC classes.
However, there is a hidden difference when adding them in different
orders:

1. If we add tc classes before its filters, everything is fine.
   Logically, the classes exist before we specify their ID's in
   filters, it is easy to bind them together, just as in the current
   code base.

2. If we add tc filters before the tc classes they bind, we have to
   do dynamic lookup in fast path. What's worse, this happens all
   the time not just once, because on fast path tcf_result is passed
   on stack, there is no way to propagate back to the one in tc filters.

This hidden difference hurts performance silently if we have many tc
classes in hierarchy.

This patch intends to close this gap by doing the reverse binding when
we create a new class, in this case we can actually search all the
filters in its parent, match and fixup by classid. And because
tcf_result is specific to each type of tc filter, we have to introduce
a new ops for each filter to tell how to bind the class.

Note, we still can NOT totally get rid of those class lookup in
->enqueue() because cgroup and flow filters have no way to determine
the classid at setup time, they still have to go through dynamic lookup.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h |  1 +
 net/sched/cls_basic.c     |  9 +++++++
 net/sched/cls_bpf.c       |  9 +++++++
 net/sched/cls_flower.c    |  9 +++++++
 net/sched/cls_fw.c        |  9 +++++++
 net/sched/cls_matchall.c  |  9 +++++++
 net/sched/cls_route.c     |  9 +++++++
 net/sched/cls_rsvp.h      |  9 +++++++
 net/sched/cls_tcindex.c   |  9 +++++++
 net/sched/cls_u32.c       |  9 +++++++
 net/sched/sch_api.c       | 68 +++++++++++++++++++++++++++++++++++++++++++++--
 11 files changed, 148 insertions(+), 2 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index c30b634c5f82..d6247a3c40df 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -217,6 +217,7 @@ struct tcf_proto_ops {
 					void **, bool);
 	int			(*delete)(struct tcf_proto*, void *, bool*);
 	void			(*walk)(struct tcf_proto*, struct tcf_walker *arg);
+	void			(*bind_class)(void *, u32, unsigned long);
 
 	/* rtnetlink specific */
 	int			(*dump)(struct net*, struct tcf_proto*, void *,
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 73cc7f167a38..d89ebafd2239 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -235,6 +235,14 @@ static void basic_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	}
 }
 
+static void basic_bind_class(void *fh, u32 classid, unsigned long cl)
+{
+	struct basic_filter *f = fh;
+
+	if (f && f->res.classid == classid)
+		f->res.class = cl;
+}
+
 static int basic_dump(struct net *net, struct tcf_proto *tp, void *fh,
 		      struct sk_buff *skb, struct tcmsg *t)
 {
@@ -280,6 +288,7 @@ static struct tcf_proto_ops cls_basic_ops __read_mostly = {
 	.delete		=	basic_delete,
 	.walk		=	basic_walk,
 	.dump		=	basic_dump,
+	.bind_class	=	basic_bind_class,
 	.owner		=	THIS_MODULE,
 };
 
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 6f2dffe30f25..520c5027646a 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -607,6 +607,14 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, void *fh,
 	return -1;
 }
 
+static void cls_bpf_bind_class(void *fh, u32 classid, unsigned long cl)
+{
+	struct cls_bpf_prog *prog = fh;
+
+	if (prog && prog->res.classid == classid)
+		prog->res.class = cl;
+}
+
 static void cls_bpf_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
 	struct cls_bpf_head *head = rtnl_dereference(tp->root);
@@ -635,6 +643,7 @@ static struct tcf_proto_ops cls_bpf_ops __read_mostly = {
 	.delete		=	cls_bpf_delete,
 	.walk		=	cls_bpf_walk,
 	.dump		=	cls_bpf_dump,
+	.bind_class	=	cls_bpf_bind_class,
 };
 
 static int __init cls_bpf_init_mod(void)
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index bd9dab41f8af..23832d8862c0 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -1360,6 +1360,14 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, void *fh,
 	return -1;
 }
 
+static void fl_bind_class(void *fh, u32 classid, unsigned long cl)
+{
+	struct cls_fl_filter *f = fh;
+
+	if (f && f->res.classid == classid)
+		f->res.class = cl;
+}
+
 static struct tcf_proto_ops cls_fl_ops __read_mostly = {
 	.kind		= "flower",
 	.classify	= fl_classify,
@@ -1370,6 +1378,7 @@ static struct tcf_proto_ops cls_fl_ops __read_mostly = {
 	.delete		= fl_delete,
 	.walk		= fl_walk,
 	.dump		= fl_dump,
+	.bind_class	= fl_bind_class,
 	.owner		= THIS_MODULE,
 };
 
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 192255ec50bd..941245ad07fd 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -412,6 +412,14 @@ static int fw_dump(struct net *net, struct tcf_proto *tp, void *fh,
 	return -1;
 }
 
+static void fw_bind_class(void *fh, u32 classid, unsigned long cl)
+{
+	struct fw_filter *f = fh;
+
+	if (f && f->res.classid == classid)
+		f->res.class = cl;
+}
+
 static struct tcf_proto_ops cls_fw_ops __read_mostly = {
 	.kind		=	"fw",
 	.classify	=	fw_classify,
@@ -422,6 +430,7 @@ static struct tcf_proto_ops cls_fw_ops __read_mostly = {
 	.delete		=	fw_delete,
 	.walk		=	fw_walk,
 	.dump		=	fw_dump,
+	.bind_class	=	fw_bind_class,
 	.owner		=	THIS_MODULE,
 };
 
diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index d4dc387f7a56..21cc45caf842 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -251,6 +251,14 @@ static int mall_dump(struct net *net, struct tcf_proto *tp, void *fh,
 	return -1;
 }
 
+static void mall_bind_class(void *fh, u32 classid, unsigned long cl)
+{
+	struct cls_mall_head *head = fh;
+
+	if (head && head->res.classid == classid)
+		head->res.class = cl;
+}
+
 static struct tcf_proto_ops cls_mall_ops __read_mostly = {
 	.kind		= "matchall",
 	.classify	= mall_classify,
@@ -261,6 +269,7 @@ static struct tcf_proto_ops cls_mall_ops __read_mostly = {
 	.delete		= mall_delete,
 	.walk		= mall_walk,
 	.dump		= mall_dump,
+	.bind_class	= mall_bind_class,
 	.owner		= THIS_MODULE,
 };
 
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 3b70982394ce..9ddde65915d2 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -624,6 +624,14 @@ static int route4_dump(struct net *net, struct tcf_proto *tp, void *fh,
 	return -1;
 }
 
+static void route4_bind_class(void *fh, u32 classid, unsigned long cl)
+{
+	struct route4_filter *f = fh;
+
+	if (f && f->res.classid == classid)
+		f->res.class = cl;
+}
+
 static struct tcf_proto_ops cls_route4_ops __read_mostly = {
 	.kind		=	"route",
 	.classify	=	route4_classify,
@@ -634,6 +642,7 @@ static struct tcf_proto_ops cls_route4_ops __read_mostly = {
 	.delete		=	route4_delete,
 	.walk		=	route4_walk,
 	.dump		=	route4_dump,
+	.bind_class	=	route4_bind_class,
 	.owner		=	THIS_MODULE,
 };
 
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 26203ff817f3..98c05db85bcb 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -723,6 +723,14 @@ static int rsvp_dump(struct net *net, struct tcf_proto *tp, void *fh,
 	return -1;
 }
 
+static void rsvp_bind_class(void *fh, u32 classid, unsigned long cl)
+{
+	struct rsvp_filter *f = fh;
+
+	if (f && f->res.classid == classid)
+		f->res.class = cl;
+}
+
 static struct tcf_proto_ops RSVP_OPS __read_mostly = {
 	.kind		=	RSVP_ID,
 	.classify	=	rsvp_classify,
@@ -733,6 +741,7 @@ static struct tcf_proto_ops RSVP_OPS __read_mostly = {
 	.delete		=	rsvp_delete,
 	.walk		=	rsvp_walk,
 	.dump		=	rsvp_dump,
+	.bind_class	=	rsvp_bind_class,
 	.owner		=	THIS_MODULE,
 };
 
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index fb281b9b2c52..14a7e08b2fa9 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -606,6 +606,14 @@ static int tcindex_dump(struct net *net, struct tcf_proto *tp, void *fh,
 	return -1;
 }
 
+static void tcindex_bind_class(void *fh, u32 classid, unsigned long cl)
+{
+	struct tcindex_filter_result *r = fh;
+
+	if (r && r->res.classid == classid)
+		r->res.class = cl;
+}
+
 static struct tcf_proto_ops cls_tcindex_ops __read_mostly = {
 	.kind		=	"tcindex",
 	.classify	=	tcindex_classify,
@@ -616,6 +624,7 @@ static struct tcf_proto_ops cls_tcindex_ops __read_mostly = {
 	.delete		=	tcindex_delete,
 	.walk		=	tcindex_walk,
 	.dump		=	tcindex_dump,
+	.bind_class	=	tcindex_bind_class,
 	.owner		=	THIS_MODULE,
 };
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 99ea4c74dd5b..10b8d851fc6b 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -1112,6 +1112,14 @@ static void u32_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	}
 }
 
+static void u32_bind_class(void *fh, u32 classid, unsigned long cl)
+{
+	struct tc_u_knode *n = fh;
+
+	if (n && n->res.classid == classid)
+		n->res.class = cl;
+}
+
 static int u32_dump(struct net *net, struct tcf_proto *tp, void *fh,
 		    struct sk_buff *skb, struct tcmsg *t)
 {
@@ -1242,6 +1250,7 @@ static struct tcf_proto_ops cls_u32_ops __read_mostly = {
 	.delete		=	u32_delete,
 	.walk		=	u32_walk,
 	.dump		=	u32_dump,
+	.bind_class	=	u32_bind_class,
 	.owner		=	THIS_MODULE,
 };
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index e7f8e4bfd4ec..929b024f41ba 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -35,6 +35,7 @@
 #include <net/sock.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/pkt_cls.h>
 
 /*
 
@@ -1648,6 +1649,64 @@ static int tclass_del_notify(struct net *net,
 			      n->nlmsg_flags & NLM_F_ECHO);
 }
 
+#ifdef CONFIG_NET_CLS
+
+struct tcf_bind_args {
+	struct tcf_walker w;
+	u32 classid;
+	unsigned long cl;
+};
+
+static int tcf_node_bind(struct tcf_proto *tp, void *n, struct tcf_walker *arg)
+{
+	struct tcf_bind_args *a = (void *)arg;
+
+	if (tp->ops->bind_class) {
+		tcf_tree_lock(tp);
+		tp->ops->bind_class(n, a->classid, a->cl);
+		tcf_tree_unlock(tp);
+	}
+	return 0;
+}
+
+static void tc_bind_tclass(struct Qdisc *q, u32 portid, u32 clid,
+			   unsigned long new_cl)
+{
+	const struct Qdisc_class_ops *cops = q->ops->cl_ops;
+	struct tcf_block *block;
+	struct tcf_chain *chain;
+	unsigned long cl;
+
+	cl = cops->find(q, portid);
+	if (!cl)
+		return;
+	block = cops->tcf_block(q, cl);
+	if (!block)
+		return;
+	list_for_each_entry(chain, &block->chain_list, list) {
+		struct tcf_proto *tp;
+
+		for (tp = rtnl_dereference(chain->filter_chain);
+		     tp; tp = rtnl_dereference(tp->next)) {
+			struct tcf_bind_args arg = {};
+
+			arg.w.fn = tcf_node_bind;
+			arg.classid = clid;
+			arg.cl = new_cl;
+			tp->ops->walk(tp, &arg.w);
+		}
+	}
+}
+
+#else
+
+static void tc_bind_tclass(struct Qdisc *q, u32 portid, u32 clid,
+			   unsigned long new_cl)
+{
+}
+
+#endif
+
 static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n,
 			 struct netlink_ext_ack *extack)
 {
@@ -1753,6 +1812,8 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n,
 			break;
 		case RTM_DELTCLASS:
 			err = tclass_del_notify(net, cops, skb, n, q, cl);
+			/* Unbind the class with flilters with 0 */
+			tc_bind_tclass(q, portid, clid, 0);
 			goto out;
 		case RTM_GETTCLASS:
 			err = tclass_notify(net, skb, n, q, cl, RTM_NEWTCLASS);
@@ -1767,9 +1828,12 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n,
 	err = -EOPNOTSUPP;
 	if (cops->change)
 		err = cops->change(q, clid, portid, tca, &new_cl);
-	if (err == 0)
+	if (err == 0) {
 		tclass_notify(net, skb, n, q, new_cl, RTM_NEWTCLASS);
-
+		/* We just create a new class, need to do reverse binding. */
+		if (cl != new_cl)
+			tc_bind_tclass(q, portid, clid, new_cl);
+	}
 out:
 	return err;
 }
-- 
2.13.0
