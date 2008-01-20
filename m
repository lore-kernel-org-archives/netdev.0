From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net classifier: style cleanup's
Date: Sun, 20 Jan 2008 14:06:13 -0800
Message-ID: <20080120140613.10a7d29b@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:39296 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755908AbYATWJW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2008 17:09:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Classifier code cleanup. Get rid of printk wrapper, and fix whitespace
and other style stuff reported by checkpatch

---
 net/sched/cls_api.c     |  100 +++++++++++++++++++++++-------------------------
 net/sched/cls_tcindex.c |   60 +++++++++++-----------------
 2 files changed, 73 insertions(+), 87 deletions(-)

--- a/net/sched/cls_api.c	2008-01-20 13:33:11.000000000 -0800
+++ b/net/sched/cls_api.c	2008-01-20 13:46:04.000000000 -0800
@@ -29,12 +29,6 @@
 #include <net/pkt_sched.h>
 #include <net/pkt_cls.h>
 
-#if 0 /* control */
-#define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
-#else
-#define DPRINTK(format,args...)
-#endif
-
 /* The list of all installed classifier types */
 
 static struct tcf_proto_ops *tcf_proto_base;
@@ -44,7 +38,7 @@ static DEFINE_RWLOCK(cls_mod_lock);
 
 /* Find classifier type by string name */
 
-static struct tcf_proto_ops * tcf_proto_lookup_ops(struct rtattr *kind)
+static struct tcf_proto_ops *tcf_proto_lookup_ops(struct rtattr *kind)
 {
 	struct tcf_proto_ops *t = NULL;
 
@@ -81,6 +75,7 @@ out:
 	write_unlock(&cls_mod_lock);
 	return rc;
 }
+EXPORT_SYMBOL(register_tcf_proto_ops);
 
 int unregister_tcf_proto_ops(struct tcf_proto_ops *ops)
 {
@@ -100,6 +95,7 @@ out:
 	write_unlock(&cls_mod_lock);
 	return rc;
 }
+EXPORT_SYMBOL(unregister_tcf_proto_ops);
 
 static int tfilter_notify(struct sk_buff *oskb, struct nlmsghdr *n,
 			  struct tcf_proto *tp, unsigned long fh, int event);
@@ -107,9 +103,9 @@ static int tfilter_notify(struct sk_buff
 
 /* Select new prio value from the range, managed by kernel. */
 
-static __inline__ u32 tcf_auto_prio(struct tcf_proto *tp)
+static inline u32 tcf_auto_prio(struct tcf_proto *tp)
 {
-	u32 first = TC_H_MAKE(0xC0000000U,0U);
+	u32 first = TC_H_MAKE(0xC0000000U, 0U);
 
 	if (tp)
 		first = tp->prio-1;
@@ -154,21 +150,25 @@ replay:
 		/* If no priority is given, user wants we allocated it. */
 		if (n->nlmsg_type != RTM_NEWTFILTER || !(n->nlmsg_flags&NLM_F_CREATE))
 			return -ENOENT;
-		prio = TC_H_MAKE(0x80000000U,0U);
+		prio = TC_H_MAKE(0x80000000U, 0U);
 	}
 
 	/* Find head of filter chain. */
 
 	/* Find link */
-	if ((dev = __dev_get_by_index(&init_net, t->tcm_ifindex)) == NULL)
+	dev = __dev_get_by_index(&init_net, t->tcm_ifindex);
+	if (dev == NULL)
 		return -ENODEV;
 
 	/* Find qdisc */
 	if (!parent) {
 		q = dev->qdisc_sleeping;
 		parent = q->handle;
-	} else if ((q = qdisc_lookup(dev, TC_H_MAJ(t->tcm_parent))) == NULL)
-		return -EINVAL;
+	} else {
+		q = qdisc_lookup(dev, TC_H_MAJ(t->tcm_parent));
+		if (q == NULL)
+			return -EINVAL;
+	}
 
 	/* Is it classful? */
 	if ((cops = q->ops->cl_ops) == NULL)
@@ -213,7 +213,8 @@ replay:
 		/* Create new proto tcf */
 
 		err = -ENOBUFS;
-		if ((tp = kzalloc(sizeof(*tp), GFP_KERNEL)) == NULL)
+		tp = kzalloc(sizeof(*tp), GFP_KERNEL);
+		if (tp == NULL)
 			goto errout;
 		err = -EINVAL;
 		tp_ops = tcf_proto_lookup_ops(tca[TCA_KIND-1]);
@@ -249,7 +250,9 @@ replay:
 		tp->q = q;
 		tp->classify = tp_ops->classify;
 		tp->classid = parent;
-		if ((err = tp_ops->init(tp)) != 0) {
+
+		err = tp_ops->init(tp);
+		if (err != 0) {
 			module_put(tp_ops->owner);
 			kfree(tp);
 			goto errout;
@@ -278,13 +281,14 @@ replay:
 		}
 
 		err = -ENOENT;
-		if (n->nlmsg_type != RTM_NEWTFILTER || !(n->nlmsg_flags&NLM_F_CREATE))
+		if (n->nlmsg_type != RTM_NEWTFILTER ||
+		    !(n->nlmsg_flags & NLM_F_CREATE))
 			goto errout;
 	} else {
 		switch (n->nlmsg_type) {
 		case RTM_NEWTFILTER:
 			err = -EEXIST;
-			if (n->nlmsg_flags&NLM_F_EXCL)
+			if (n->nlmsg_flags & NLM_F_EXCL)
 				goto errout;
 			break;
 		case RTM_DELTFILTER:
@@ -314,9 +318,8 @@ errout:
 	return err;
 }
 
-static int
-tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp, unsigned long fh,
-	      u32 pid, u32 seq, u16 flags, int event)
+static int tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp,
+			 unsigned long fh, u32 pid, u32 seq, u16 flags, int event)
 {
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
@@ -361,19 +364,20 @@ static int tfilter_notify(struct sk_buff
 		return -EINVAL;
 	}
 
-	return rtnetlink_send(skb, &init_net, pid, RTNLGRP_TC, n->nlmsg_flags&NLM_F_ECHO);
+	return rtnetlink_send(skb, &init_net, pid, RTNLGRP_TC,
+			      n->nlmsg_flags & NLM_F_ECHO);
 }
 
-struct tcf_dump_args
-{
+struct tcf_dump_args {
 	struct tcf_walker w;
 	struct sk_buff *skb;
 	struct netlink_callback *cb;
 };
 
-static int tcf_node_dump(struct tcf_proto *tp, unsigned long n, struct tcf_walker *arg)
+static int tcf_node_dump(struct tcf_proto *tp, unsigned long n,
+			 struct tcf_walker *arg)
 {
-	struct tcf_dump_args *a = (void*)arg;
+	struct tcf_dump_args *a = (void *)arg;
 
 	return tcf_fill_node(a->skb, tp, n, NETLINK_CB(a->cb->skb).pid,
 			     a->cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWTFILTER);
@@ -387,7 +391,7 @@ static int tc_dump_tfilter(struct sk_buf
 	struct net_device *dev;
 	struct Qdisc *q;
 	struct tcf_proto *tp, **chain;
-	struct tcmsg *tcm = (struct tcmsg*)NLMSG_DATA(cb->nlh);
+	struct tcmsg *tcm = (struct tcmsg *)NLMSG_DATA(cb->nlh);
 	unsigned long cl = 0;
 	const struct Qdisc_class_ops *cops;
 	struct tcf_dump_args arg;
@@ -431,9 +435,10 @@ static int tc_dump_tfilter(struct sk_buf
 			memset(&cb->args[1], 0, sizeof(cb->args)-sizeof(cb->args[0]));
 		if (cb->args[1] == 0) {
 			if (tcf_fill_node(skb, tp, 0, NETLINK_CB(cb->skb).pid,
-					  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWTFILTER) <= 0) {
+					  cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					  RTM_NEWTFILTER) <= 0)
 				break;
-			}
+
 			cb->args[1] = 1;
 		}
 		if (tp->ops->walk == NULL)
@@ -460,8 +465,7 @@ out:
 	return skb->len;
 }
 
-void
-tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts)
+void tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	if (exts->action) {
@@ -470,10 +474,9 @@ tcf_exts_destroy(struct tcf_proto *tp, s
 	}
 #endif
 }
+EXPORT_SYMBOL(tcf_exts_destroy);
 
-
-int
-tcf_exts_validate(struct tcf_proto *tp, struct rtattr **tb,
+int tcf_exts_validate(struct tcf_proto *tp, struct rtattr **tb,
 		  struct rtattr *rate_tlv, struct tcf_exts *exts,
 		  struct tcf_ext_map *map)
 {
@@ -485,8 +488,9 @@ tcf_exts_validate(struct tcf_proto *tp, 
 		struct tc_action *act;
 
 		if (map->police && tb[map->police-1]) {
-			act = tcf_action_init_1(tb[map->police-1], rate_tlv, "police",
-				TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
+			act = tcf_action_init_1(tb[map->police-1], rate_tlv,
+						"police", TCA_ACT_NOREPLACE,
+						TCA_ACT_BIND, &err);
 			if (act == NULL)
 				return err;
 
@@ -509,10 +513,10 @@ tcf_exts_validate(struct tcf_proto *tp, 
 
 	return 0;
 }
+EXPORT_SYMBOL(tcf_exts_validate);
 
-void
-tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
-		struct tcf_exts *src)
+void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
+		     struct tcf_exts *src)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	if (src->action) {
@@ -525,9 +529,9 @@ tcf_exts_change(struct tcf_proto *tp, st
 	}
 #endif
 }
+EXPORT_SYMBOL(tcf_exts_change);
 
-int
-tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts,
+int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts,
 	      struct tcf_ext_map *map)
 {
 #ifdef CONFIG_NET_CLS_ACT
@@ -556,10 +560,11 @@ tcf_exts_dump(struct sk_buff *skb, struc
 rtattr_failure: __attribute__ ((unused))
 	return -1;
 }
+EXPORT_SYMBOL(tcf_exts_dump);
 
-int
-tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
-		    struct tcf_ext_map *map)
+
+int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
+			struct tcf_ext_map *map)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	if (exts->action)
@@ -570,6 +575,7 @@ tcf_exts_dump_stats(struct sk_buff *skb,
 rtattr_failure: __attribute__ ((unused))
 	return -1;
 }
+EXPORT_SYMBOL(tcf_exts_dump_stats);
 
 static int __init tc_filter_init(void)
 {
@@ -582,11 +588,3 @@ static int __init tc_filter_init(void)
 }
 
 subsys_initcall(tc_filter_init);
-
-EXPORT_SYMBOL(register_tcf_proto_ops);
-EXPORT_SYMBOL(unregister_tcf_proto_ops);
-EXPORT_SYMBOL(tcf_exts_validate);
-EXPORT_SYMBOL(tcf_exts_destroy);
-EXPORT_SYMBOL(tcf_exts_change);
-EXPORT_SYMBOL(tcf_exts_dump);
-EXPORT_SYMBOL(tcf_exts_dump_stats);
--- a/net/sched/cls_tcindex.c	2008-01-20 13:33:47.000000000 -0800
+++ b/net/sched/cls_tcindex.c	2008-01-20 13:50:55.000000000 -0800
@@ -29,19 +29,6 @@
 #define DEFAULT_HASH_SIZE	64	/* optimized for diffserv */
 
 
-#if 1 /* control */
-#define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
-#else
-#define DPRINTK(format,args...)
-#endif
-
-#if 0 /* data */
-#define D2PRINTK(format,args...) printk(KERN_DEBUG format,##args)
-#else
-#define D2PRINTK(format,args...)
-#endif
-
-
 #define	PRIV(tp)	((struct tcindex_data *) (tp)->root)
 
 
@@ -104,7 +91,8 @@ static int tcindex_classify(struct sk_bu
 	struct tcindex_filter_result *f;
 	int key = (skb->tc_index & p->mask) >> p->shift;
 
-	D2PRINTK("tcindex_classify(skb %p,tp %p,res %p),p %p\n",skb,tp,res,p);
+	pr_debug("tcindex_classify(skb %p,tp %p,res %p),p %p\n",
+		 skb, tp, res, p);
 
 	f = tcindex_lookup(p, key);
 	if (!f) {
@@ -112,11 +100,11 @@ static int tcindex_classify(struct sk_bu
 			return -1;
 		res->classid = TC_H_MAKE(TC_H_MAJ(tp->q->handle), key);
 		res->class = 0;
-		D2PRINTK("alg 0x%x\n",res->classid);
+		pr_debug("alg 0x%x\n", res->classid);
 		return 0;
 	}
 	*res = f->res;
-	D2PRINTK("map 0x%x\n",res->classid);
+	pr_debug("map 0x%x\n", res->classid);
 
 	return tcf_exts_exec(skb, &f->exts, res);
 }
@@ -127,7 +115,7 @@ static unsigned long tcindex_get(struct 
 	struct tcindex_data *p = PRIV(tp);
 	struct tcindex_filter_result *r;
 
-	DPRINTK("tcindex_get(tp %p,handle 0x%08x)\n",tp,handle);
+	pr_debug("tcindex_get(tp %p,handle 0x%08x)\n", tp, handle);
 	if (p->perfect && handle >= p->alloc_hash)
 		return 0;
 	r = tcindex_lookup(p, handle);
@@ -137,7 +125,7 @@ static unsigned long tcindex_get(struct 
 
 static void tcindex_put(struct tcf_proto *tp, unsigned long f)
 {
-	DPRINTK("tcindex_put(tp %p,f 0x%lx)\n",tp,f);
+	pr_debug("tcindex_put(tp %p,f 0x%lx)\n", tp, f);
 }
 
 
@@ -145,8 +133,8 @@ static int tcindex_init(struct tcf_proto
 {
 	struct tcindex_data *p;
 
-	DPRINTK("tcindex_init(tp %p)\n",tp);
-	p = kzalloc(sizeof(struct tcindex_data),GFP_KERNEL);
+	pr_debug("tcindex_init(tp %p)\n", tp);
+	p = kzalloc(sizeof(struct tcindex_data), GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 
@@ -166,7 +154,7 @@ __tcindex_delete(struct tcf_proto *tp, u
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) arg;
 	struct tcindex_filter *f = NULL;
 
-	DPRINTK("tcindex_delete(tp %p,arg 0x%lx),p %p,f %p\n",tp,arg,p,f);
+	pr_debug("tcindex_delete(tp %p,arg 0x%lx),p %p,f %p\n", tp, arg, p, f);
 	if (p->perfect) {
 		if (!r->res.class)
 			return -ENOENT;
@@ -363,7 +351,7 @@ tcindex_change(struct tcf_proto *tp, uns
 	struct tcindex_data *p = PRIV(tp);
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) *arg;
 
-	DPRINTK("tcindex_change(tp %p,handle 0x%08x,tca %p,arg %p),opt %p,"
+	pr_debug("tcindex_change(tp %p,handle 0x%08x,tca %p,arg %p),opt %p,"
 	    "p %p,r %p,*arg 0x%lx\n",
 	    tp, handle, tca, arg, opt, p, r, arg ? *arg : 0L);
 
@@ -380,10 +368,10 @@ tcindex_change(struct tcf_proto *tp, uns
 static void tcindex_walk(struct tcf_proto *tp, struct tcf_walker *walker)
 {
 	struct tcindex_data *p = PRIV(tp);
-	struct tcindex_filter *f,*next;
+	struct tcindex_filter *f, *next;
 	int i;
 
-	DPRINTK("tcindex_walk(tp %p,walker %p),p %p\n",tp,walker,p);
+	pr_debug("tcindex_walk(tp %p,walker %p),p %p\n", tp, walker, p);
 	if (p->perfect) {
 		for (i = 0; i < p->hash; i++) {
 			if (!p->perfect[i].res.class)
@@ -405,7 +393,7 @@ static void tcindex_walk(struct tcf_prot
 		for (f = p->h[i]; f; f = next) {
 			next = f->next;
 			if (walker->count >= walker->skip) {
-				if (walker->fn(tp,(unsigned long) &f->result,
+				if (walker->fn(tp, (unsigned long) &f->result,
 				    walker) < 0) {
 					walker->stop = 1;
 					return;
@@ -429,11 +417,11 @@ static void tcindex_destroy(struct tcf_p
 	struct tcindex_data *p = PRIV(tp);
 	struct tcf_walker walker;
 
-	DPRINTK("tcindex_destroy(tp %p),p %p\n",tp,p);
+	pr_debug("tcindex_destroy(tp %p),p %p\n", tp, p);
 	walker.count = 0;
 	walker.skip = 0;
 	walker.fn = &tcindex_destroy_element;
-	tcindex_walk(tp,&walker);
+	tcindex_walk(tp, &walker);
 	kfree(p->perfect);
 	kfree(p->h);
 	kfree(p);
@@ -449,17 +437,17 @@ static int tcindex_dump(struct tcf_proto
 	unsigned char *b = skb_tail_pointer(skb);
 	struct rtattr *rta;
 
-	DPRINTK("tcindex_dump(tp %p,fh 0x%lx,skb %p,t %p),p %p,r %p,b %p\n",
-	    tp,fh,skb,t,p,r,b);
-	DPRINTK("p->perfect %p p->h %p\n",p->perfect,p->h);
+	pr_debug("tcindex_dump(tp %p,fh 0x%lx,skb %p,t %p),p %p,r %p,b %p\n",
+		 tp, fh, skb, t, p, r, b);
+	pr_debug("p->perfect %p p->h %p\n", p->perfect, p->h);
 	rta = (struct rtattr *) b;
-	RTA_PUT(skb,TCA_OPTIONS,0,NULL);
+	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
 	if (!fh) {
 		t->tcm_handle = ~0; /* whatever ... */
-		RTA_PUT(skb,TCA_TCINDEX_HASH,sizeof(p->hash),&p->hash);
-		RTA_PUT(skb,TCA_TCINDEX_MASK,sizeof(p->mask),&p->mask);
-		RTA_PUT(skb,TCA_TCINDEX_SHIFT,sizeof(p->shift),&p->shift);
-		RTA_PUT(skb,TCA_TCINDEX_FALL_THROUGH,sizeof(p->fall_through),
+		RTA_PUT(skb, TCA_TCINDEX_HASH, sizeof(p->hash), &p->hash);
+		RTA_PUT(skb, TCA_TCINDEX_MASK, sizeof(p->mask), &p->mask);
+		RTA_PUT(skb, TCA_TCINDEX_SHIFT, sizeof(p->shift), &p->shift);
+		RTA_PUT(skb, TCA_TCINDEX_FALL_THROUGH, sizeof(p->fall_through),
 		    &p->fall_through);
 		rta->rta_len = skb_tail_pointer(skb) - b;
 	} else {
@@ -478,7 +466,7 @@ static int tcindex_dump(struct tcf_proto
 				}
 			}
 		}
-		DPRINTK("handle = %d\n",t->tcm_handle);
+		pr_debug("handle = %d\n", t->tcm_handle);
 		if (r->res.class)
 			RTA_PUT(skb, TCA_TCINDEX_CLASSID, 4, &r->res.classid);
 
