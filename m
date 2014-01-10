From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 6/7] net_sched: cls: move allocation in ->init to generic layer
Date: Thu,  9 Jan 2014 16:14:04 -0800
Message-ID: <1389312845-10304-7-git-send-email-xiyou.wangcong@gmail.com>
References: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:62990 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756349AbaAJAOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 19:14:43 -0500
Received: by mail-pd0-f173.google.com with SMTP id p10so3828836pdj.18
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 16:14:43 -0800 (PST)
In-Reply-To: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of the filters need allocation of tp->root in ->init()
and free it in ->destroy(), make this generic.

Also we could reduce the use of tcf_tree_lock a bit.

Cc: Thomas Graf <tgraf@suug.ch>
Cc: David S. Miller <davem@davemloft.net>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h |  1 +
 net/sched/cls_api.c       |  7 +++++++
 net/sched/cls_basic.c     |  8 ++------
 net/sched/cls_bpf.c       | 11 ++---------
 net/sched/cls_cgroup.c    | 21 +++++++--------------
 net/sched/cls_flow.c      |  8 ++------
 net/sched/cls_fw.c        | 14 ++++----------
 net/sched/cls_route.c     | 15 ++-------------
 net/sched/cls_rsvp.h      | 10 ++--------
 net/sched/cls_tcindex.c   | 13 ++-----------
 net/sched/cls_u32.c       |  9 ++-------
 net/sched/sch_api.c       |  1 +
 12 files changed, 34 insertions(+), 84 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index d062f81..819dc1d 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -208,6 +208,7 @@ struct tcf_proto_ops {
 					struct sk_buff *skb, struct tcmsg*);
 
 	struct module		*owner;
+	size_t			root_size;
 };
 
 struct tcf_proto {
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 29a30a1..8460c75 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -262,6 +262,13 @@ replay:
 		tp->q = q;
 		tp->classify = tp_ops->classify;
 		tp->classid = parent;
+		tp->root = kzalloc(tp_ops->root_size, GFP_KERNEL);
+		if (!tp->root) {
+			err = -ENOBUFS;
+			module_put(tp_ops->owner);
+			kfree(tp);
+			goto errout;
+		}
 
 		err = tp_ops->init(tp);
 		if (err != 0) {
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index e98ca99..318f672 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -75,13 +75,9 @@ static void basic_put(struct tcf_proto *tp, unsigned long f)
 
 static int basic_init(struct tcf_proto *tp)
 {
-	struct basic_head *head;
+	struct basic_head *head = tp->root;
 
-	head = kzalloc(sizeof(*head), GFP_KERNEL);
-	if (head == NULL)
-		return -ENOBUFS;
 	INIT_LIST_HEAD(&head->flist);
-	tp->root = head;
 	return 0;
 }
 
@@ -102,7 +98,6 @@ static void basic_destroy(struct tcf_proto *tp)
 		list_del(&f->link);
 		basic_delete_filter(tp, f);
 	}
-	kfree(head);
 }
 
 static int basic_delete(struct tcf_proto *tp, unsigned long arg)
@@ -288,6 +283,7 @@ static struct tcf_proto_ops cls_basic_ops __read_mostly = {
 	.walk		=	basic_walk,
 	.dump		=	basic_dump,
 	.owner		=	THIS_MODULE,
+	.root_size	=	sizeof(struct basic_head),
 };
 
 static int __init init_basic(void)
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 8e3cf49..eedd296 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -75,15 +75,9 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 static int cls_bpf_init(struct tcf_proto *tp)
 {
-	struct cls_bpf_head *head;
-
-	head = kzalloc(sizeof(*head), GFP_KERNEL);
-	if (head == NULL)
-		return -ENOBUFS;
+	struct cls_bpf_head *head = tp->root;
 
 	INIT_LIST_HEAD(&head->plist);
-	tp->root = head;
-
 	return 0;
 }
 
@@ -126,8 +120,6 @@ static void cls_bpf_destroy(struct tcf_proto *tp)
 		list_del(&prog->link);
 		cls_bpf_delete_prog(tp, prog);
 	}
-
-	kfree(head);
 }
 
 static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
@@ -366,6 +358,7 @@ static struct tcf_proto_ops cls_bpf_ops __read_mostly = {
 	.delete		=	cls_bpf_delete,
 	.walk		=	cls_bpf_walk,
 	.dump		=	cls_bpf_dump,
+	.root_size	=	sizeof(struct cls_bpf_head),
 };
 
 static int __init cls_bpf_init_mod(void)
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 8e2158a..4b7e083 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -22,6 +22,7 @@ struct cls_cgroup_head {
 	u32			handle;
 	struct tcf_exts		exts;
 	struct tcf_ematch_tree	ematches;
+	bool			init;
 };
 
 static int cls_cgroup_classify(struct sk_buff *skb, const struct tcf_proto *tp,
@@ -73,6 +74,9 @@ static void cls_cgroup_put(struct tcf_proto *tp, unsigned long f)
 
 static int cls_cgroup_init(struct tcf_proto *tp)
 {
+	struct cls_cgroup_head *head = tp->root;
+
+	tcf_exts_init(&head->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
 	return 0;
 }
 
@@ -94,20 +98,9 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (!tca[TCA_OPTIONS])
 		return -EINVAL;
 
-	if (head == NULL) {
-		if (!handle)
-			return -EINVAL;
-
-		head = kzalloc(sizeof(*head), GFP_KERNEL);
-		if (head == NULL)
-			return -ENOBUFS;
-
-		tcf_exts_init(&head->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
+	if (!head->init) {
 		head->handle = handle;
-
-		tcf_tree_lock(tp);
-		tp->root = head;
-		tcf_tree_unlock(tp);
+		head->init = true;
 	}
 
 	if (handle != head->handle)
@@ -140,7 +133,6 @@ static void cls_cgroup_destroy(struct tcf_proto *tp)
 	if (head) {
 		tcf_exts_destroy(tp, &head->exts);
 		tcf_em_tree_destroy(tp, &head->ematches);
-		kfree(head);
 	}
 }
 
@@ -205,6 +197,7 @@ static struct tcf_proto_ops cls_cgroup_ops __read_mostly = {
 	.walk		=	cls_cgroup_walk,
 	.dump		=	cls_cgroup_dump,
 	.owner		=	THIS_MODULE,
+	.root_size	=	sizeof(struct cls_cgroup_head),
 };
 
 static int __init init_cgroup_cls(void)
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 257029c..b39080a 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -526,13 +526,9 @@ static int flow_delete(struct tcf_proto *tp, unsigned long arg)
 
 static int flow_init(struct tcf_proto *tp)
 {
-	struct flow_head *head;
+	struct flow_head *head = tp->root;
 
-	head = kzalloc(sizeof(*head), GFP_KERNEL);
-	if (head == NULL)
-		return -ENOBUFS;
 	INIT_LIST_HEAD(&head->filters);
-	tp->root = head;
 	return 0;
 }
 
@@ -545,7 +541,6 @@ static void flow_destroy(struct tcf_proto *tp)
 		list_del(&f->list);
 		flow_destroy_filter(tp, f);
 	}
-	kfree(head);
 }
 
 static unsigned long flow_get(struct tcf_proto *tp, u32 handle)
@@ -653,6 +648,7 @@ static struct tcf_proto_ops cls_flow_ops __read_mostly = {
 	.dump		= flow_dump,
 	.walk		= flow_walk,
 	.owner		= THIS_MODULE,
+	.root_size	= sizeof(struct flow_head),
 };
 
 static int __init cls_flow_init(void)
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index ed00e8c..73cd277 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -34,6 +34,7 @@
 struct fw_head {
 	struct fw_filter *ht[HTSIZE];
 	u32 mask;
+	bool init;
 };
 
 struct fw_filter {
@@ -155,7 +156,6 @@ static void fw_destroy(struct tcf_proto *tp)
 			fw_delete_filter(tp, f);
 		}
 	}
-	kfree(head);
 }
 
 static int fw_delete(struct tcf_proto *tp, unsigned long arg)
@@ -259,19 +259,12 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 	if (!handle)
 		return -EINVAL;
 
-	if (head == NULL) {
+	if (!head->init) {
 		u32 mask = 0xFFFFFFFF;
 		if (tb[TCA_FW_MASK])
 			mask = nla_get_u32(tb[TCA_FW_MASK]);
-
-		head = kzalloc(sizeof(struct fw_head), GFP_KERNEL);
-		if (head == NULL)
-			return -ENOBUFS;
 		head->mask = mask;
-
-		tcf_tree_lock(tp);
-		tp->root = head;
-		tcf_tree_unlock(tp);
+		head->init = true;
 	}
 
 	f = kzalloc(sizeof(struct fw_filter), GFP_KERNEL);
@@ -388,6 +381,7 @@ static struct tcf_proto_ops cls_fw_ops __read_mostly = {
 	.walk		=	fw_walk,
 	.dump		=	fw_dump,
 	.owner		=	THIS_MODULE,
+	.root_size	= 	sizeof(struct fw_head),
 };
 
 static int __init init_fw(void)
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 1ad3068..038f35f 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -279,7 +279,6 @@ static void route4_destroy(struct tcf_proto *tp)
 			kfree(b);
 		}
 	}
-	kfree(head);
 }
 
 static int route4_delete(struct tcf_proto *tp, unsigned long arg)
@@ -462,20 +461,9 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 		goto reinsert;
 	}
 
-	err = -ENOBUFS;
-	if (head == NULL) {
-		head = kzalloc(sizeof(struct route4_head), GFP_KERNEL);
-		if (head == NULL)
-			goto errout;
-
-		tcf_tree_lock(tp);
-		tp->root = head;
-		tcf_tree_unlock(tp);
-	}
-
 	f = kzalloc(sizeof(struct route4_filter), GFP_KERNEL);
 	if (f == NULL)
-		goto errout;
+		return -ENOBUFS;
 
 	tcf_exts_init(&f->exts, TCA_ROUTE4_ACT, TCA_ROUTE4_POLICE);
 	err = route4_set_parms(net, tp, base, f, handle, head, tb,
@@ -613,6 +601,7 @@ static struct tcf_proto_ops cls_route4_ops __read_mostly = {
 	.walk		=	route4_walk,
 	.dump		=	route4_dump,
 	.owner		=	THIS_MODULE,
+	.root_size	=	sizeof(struct route4_head),
 };
 
 static int __init init_route4(void)
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 19f8e5d..47930bc 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -242,14 +242,7 @@ static void rsvp_put(struct tcf_proto *tp, unsigned long f)
 
 static int rsvp_init(struct tcf_proto *tp)
 {
-	struct rsvp_head *data;
-
-	data = kzalloc(sizeof(struct rsvp_head), GFP_KERNEL);
-	if (data) {
-		tp->root = data;
-		return 0;
-	}
-	return -ENOBUFS;
+	return 0;
 }
 
 static void
@@ -656,6 +649,7 @@ static struct tcf_proto_ops RSVP_OPS __read_mostly = {
 	.walk		=	rsvp_walk,
 	.dump		=	rsvp_dump,
 	.owner		=	THIS_MODULE,
+	.root_size	=	sizeof(struct rsvp_head),
 };
 
 static int __init init_rsvp(void)
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index eed8404..6454158 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -118,18 +118,11 @@ static void tcindex_put(struct tcf_proto *tp, unsigned long f)
 
 static int tcindex_init(struct tcf_proto *tp)
 {
-	struct tcindex_data *p;
-
-	pr_debug("tcindex_init(tp %p)\n", tp);
-	p = kzalloc(sizeof(struct tcindex_data), GFP_KERNEL);
-	if (!p)
-		return -ENOMEM;
+	struct tcindex_data *p = tp->root;
 
 	p->mask = 0xffff;
 	p->hash = DEFAULT_HASH_SIZE;
 	p->fall_through = 1;
-
-	tp->root = p;
 	return 0;
 }
 
@@ -407,15 +400,12 @@ static void tcindex_destroy(struct tcf_proto *tp)
 	struct tcindex_data *p = tp->root;
 	struct tcf_walker walker;
 
-	pr_debug("tcindex_destroy(tp %p),p %p\n", tp, p);
 	walker.count = 0;
 	walker.skip = 0;
 	walker.fn = &tcindex_destroy_element;
 	tcindex_walk(tp, &walker);
 	kfree(p->perfect);
 	kfree(p->h);
-	kfree(p);
-	tp->root = NULL;
 }
 
 
@@ -491,6 +481,7 @@ static struct tcf_proto_ops cls_tcindex_ops __read_mostly = {
 	.walk		=	tcindex_walk,
 	.dump		=	tcindex_dump,
 	.owner		=	THIS_MODULE,
+	.root_size	=	sizeof(struct tcindex_data),
 };
 
 static int __init init_tcindex(void)
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 84c28da..678c2d72 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -300,15 +300,11 @@ static u32 gen_new_htid(struct tc_u_common *tp_c)
 
 static int u32_init(struct tcf_proto *tp)
 {
-	struct tc_u_hnode *root_ht;
+	struct tc_u_hnode *root_ht = tp->root;
 	struct tc_u_common *tp_c;
 
 	tp_c = tp->q->u32_node;
 
-	root_ht = kzalloc(sizeof(*root_ht), GFP_KERNEL);
-	if (root_ht == NULL)
-		return -ENOBUFS;
-
 	root_ht->divisor = 0;
 	root_ht->refcnt++;
 	root_ht->handle = tp_c ? gen_new_htid(tp_c) : 0x80000000;
@@ -329,7 +325,6 @@ static int u32_init(struct tcf_proto *tp)
 	tp_c->hlist = root_ht;
 	root_ht->tp_c = tp_c;
 
-	tp->root = root_ht;
 	tp->data = tp_c;
 	return 0;
 }
@@ -394,7 +389,6 @@ static int u32_destroy_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 	for (hn = &tp_c->hlist; *hn; hn = &(*hn)->next) {
 		if (*hn == ht) {
 			*hn = ht->next;
-			kfree(ht);
 			return 0;
 		}
 	}
@@ -801,6 +795,7 @@ static struct tcf_proto_ops cls_u32_ops __read_mostly = {
 	.walk		=	u32_walk,
 	.dump		=	u32_dump,
 	.owner		=	THIS_MODULE,
+	.root_size	=	sizeof(struct tc_u_hnode),
 };
 
 static int __init init_u32(void)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 1313145..5fef7f4 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1829,6 +1829,7 @@ EXPORT_SYMBOL(tc_classify);
 void tcf_destroy(struct tcf_proto *tp)
 {
 	tp->ops->destroy(tp);
+	kfree(tp->root);
 	module_put(tp->ops->owner);
 	kfree(tp);
 }
-- 
1.8.3.1
