From: Thomas Graf <tgraf@suug.ch>
Subject: [RESEND] pkt_sched: Control group classifier
Date: Thu, 30 Oct 2008 15:28:17 +0100
Message-ID: <20081030142817.GM20815@postel.suug.ch>
References: <20081027.123056.22851224.davem@davemloft.net> <20081027.170524.124746723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:55848 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753421AbYJ3O15 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2008 10:27:57 -0400
Content-Disposition: inline
In-Reply-To: <20081027.170524.124746723.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements a very basic cgroup subsystem which allows
assigning classids to cgroups. It also adds a trivial classifier
to filter packets based on that classid and map them to classes.

The classifier should cover the most common use case and will work
without any special configuration.

The principle of the classifier is to directly access the
task_struct via get_current(). In order for this to work,
classification requests from softirqs must be ignored. This is
not a problem because the vast majority of packets in softirq
context are not assigned to a task anyway. For this to work, a
mechanism is needed to trace softirq context. The only existing
way to do so is to use the TRACE_IRQFLAGS feature, unfortunately
this debug feature is heavy and depends on lockdep which is overkill.
Therefore the code required to trace soft/hard irqs was extracted
from TRACE_IRQFLAGS and made available under a new config option
TRACE_CONTEXT which can now be used from both the cgroup classifier
and lockdep. The consequence is that task_struct grows by 2 ints
and a counter is bumped/decreased for each soft/hard irq being fired
if the cgroup classifier is compiled in.

I've taken over the idea of inheriting the classid of cgroup parents
from the patchset posted by Ranjit Manomohan <ranjitm@google.com>.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6-next/include/linux/cgroup_subsys.h
===================================================================
--- net-2.6-next.orig/include/linux/cgroup_subsys.h	2008-10-30 12:45:39.000000000 +0100
+++ net-2.6-next/include/linux/cgroup_subsys.h	2008-10-30 13:07:29.000000000 +0100
@@ -54,3 +54,9 @@
 #endif
 
 /* */
+
+#ifdef CONFIG_NET_CLS_CGROUP
+SUBSYS(net_cls)
+#endif
+
+/* */
Index: net-2.6-next/include/linux/irqflags.h
===================================================================
--- net-2.6-next.orig/include/linux/irqflags.h	2008-10-30 12:45:39.000000000 +0100
+++ net-2.6-next/include/linux/irqflags.h	2008-10-30 13:07:29.000000000 +0100
@@ -13,33 +13,37 @@
 
 #include <linux/typecheck.h>
 
+#ifdef CONFIG_TRACE_CONTEXT
+# define trace_hardirq_context(p)	((p)->hardirq_context)
+# define trace_softirq_context(p)	((p)->softirq_context)
+# define trace_hardirq_enter()	do { current->hardirq_context++; } while (0)
+# define trace_hardirq_exit()	do { current->hardirq_context--; } while (0)
+# define trace_softirq_enter()	do { current->softirq_context++; } while (0)
+# define trace_softirq_exit()	do { current->softirq_context--; } while (0)
+#else
+# define trace_hardirq_context(p)	0
+# define trace_softirq_context(p)	0
+# define trace_hardirq_enter()		do { } while (0)
+# define trace_hardirq_exit()		do { } while (0)
+# define trace_softirq_enter()		do { } while (0)
+# define trace_softirq_exit()		do { } while (0)
+#endif
+
 #ifdef CONFIG_TRACE_IRQFLAGS
   extern void trace_softirqs_on(unsigned long ip);
   extern void trace_softirqs_off(unsigned long ip);
   extern void trace_hardirqs_on(void);
   extern void trace_hardirqs_off(void);
-# define trace_hardirq_context(p)	((p)->hardirq_context)
-# define trace_softirq_context(p)	((p)->softirq_context)
 # define trace_hardirqs_enabled(p)	((p)->hardirqs_enabled)
 # define trace_softirqs_enabled(p)	((p)->softirqs_enabled)
-# define trace_hardirq_enter()	do { current->hardirq_context++; } while (0)
-# define trace_hardirq_exit()	do { current->hardirq_context--; } while (0)
-# define trace_softirq_enter()	do { current->softirq_context++; } while (0)
-# define trace_softirq_exit()	do { current->softirq_context--; } while (0)
 # define INIT_TRACE_IRQFLAGS	.softirqs_enabled = 1,
 #else
 # define trace_hardirqs_on()		do { } while (0)
 # define trace_hardirqs_off()		do { } while (0)
 # define trace_softirqs_on(ip)		do { } while (0)
 # define trace_softirqs_off(ip)		do { } while (0)
-# define trace_hardirq_context(p)	0
-# define trace_softirq_context(p)	0
 # define trace_hardirqs_enabled(p)	0
 # define trace_softirqs_enabled(p)	0
-# define trace_hardirq_enter()		do { } while (0)
-# define trace_hardirq_exit()		do { } while (0)
-# define trace_softirq_enter()		do { } while (0)
-# define trace_softirq_exit()		do { } while (0)
 # define INIT_TRACE_IRQFLAGS
 #endif
 
Index: net-2.6-next/include/linux/pkt_cls.h
===================================================================
--- net-2.6-next.orig/include/linux/pkt_cls.h	2008-10-30 12:45:39.000000000 +0100
+++ net-2.6-next/include/linux/pkt_cls.h	2008-10-30 13:07:29.000000000 +0100
@@ -394,6 +394,20 @@
 
 #define TCA_BASIC_MAX (__TCA_BASIC_MAX - 1)
 
+
+/* Cgroup classifier */
+
+enum
+{
+	TCA_CGROUP_UNSPEC,
+	TCA_CGROUP_ACT,
+	TCA_CGROUP_POLICE,
+	TCA_CGROUP_EMATCHES,
+	__TCA_CGROUP_MAX,
+};
+
+#define TCA_CGROUP_MAX (__TCA_CGROUP_MAX - 1)
+
 /* Extended Matches */
 
 struct tcf_ematch_tree_hdr
Index: net-2.6-next/include/linux/sched.h
===================================================================
--- net-2.6-next.orig/include/linux/sched.h	2008-10-30 12:45:39.000000000 +0100
+++ net-2.6-next/include/linux/sched.h	2008-10-30 13:07:29.000000000 +0100
@@ -1256,6 +1256,10 @@
 	/* mutex deadlock detection */
 	struct mutex_waiter *blocked_on;
 #endif
+#ifdef CONFIG_TRACE_CONTEXT
+	int hardirq_context;
+	int softirq_context;
+#endif
 #ifdef CONFIG_TRACE_IRQFLAGS
 	unsigned int irq_events;
 	int hardirqs_enabled;
@@ -1268,8 +1272,6 @@
 	unsigned int softirq_disable_event;
 	unsigned long softirq_enable_ip;
 	unsigned int softirq_enable_event;
-	int hardirq_context;
-	int softirq_context;
 #endif
 #ifdef CONFIG_LOCKDEP
 # define MAX_LOCK_DEPTH 48UL
Index: net-2.6-next/kernel/fork.c
===================================================================
--- net-2.6-next.orig/kernel/fork.c	2008-10-30 12:45:41.000000000 +0100
+++ net-2.6-next/kernel/fork.c	2008-10-30 13:07:29.000000000 +0100
@@ -1050,6 +1050,10 @@
  	}
 	mpol_fix_fork_child_flag(p);
 #endif
+#ifdef CONFIG_TRACE_CONTEXT
+	p->hardirq_context = 0;
+	p->softirq_context = 0;
+#endif
 #ifdef CONFIG_TRACE_IRQFLAGS
 	p->irq_events = 0;
 #ifdef __ARCH_WANT_INTERRUPTS_ON_CTXSW
@@ -1066,8 +1070,6 @@
 	p->softirq_enable_event = 0;
 	p->softirq_disable_ip = 0;
 	p->softirq_disable_event = 0;
-	p->hardirq_context = 0;
-	p->softirq_context = 0;
 #endif
 #ifdef CONFIG_LOCKDEP
 	p->lockdep_depth = 0; /* no locks held yet */
Index: net-2.6-next/lib/Kconfig
===================================================================
--- net-2.6-next.orig/lib/Kconfig	2008-10-30 12:45:41.000000000 +0100
+++ net-2.6-next/lib/Kconfig	2008-10-30 13:07:29.000000000 +0100
@@ -157,4 +157,10 @@
 config HAVE_LMB
 	boolean
 
+#
+# soft/hard irq tracing
+#
+config TRACE_CONTEXT
+	boolean
+
 endmenu
Index: net-2.6-next/lib/Kconfig.debug
===================================================================
--- net-2.6-next.orig/lib/Kconfig.debug	2008-10-30 12:45:41.000000000 +0100
+++ net-2.6-next/lib/Kconfig.debug	2008-10-30 13:07:29.000000000 +0100
@@ -423,6 +423,7 @@
 	depends on DEBUG_KERNEL
 	bool
 	default y
+	select TRACE_CONTEXT
 	depends on TRACE_IRQFLAGS_SUPPORT
 	depends on PROVE_LOCKING
 
Index: net-2.6-next/net/sched/Kconfig
===================================================================
--- net-2.6-next.orig/net/sched/Kconfig	2008-10-30 12:45:41.000000000 +0100
+++ net-2.6-next/net/sched/Kconfig	2008-10-30 13:08:10.000000000 +0100
@@ -316,6 +316,18 @@
 	  To compile this code as a module, choose M here: the
 	  module will be called cls_flow.
 
+config NET_CLS_CGROUP
+	bool "Control Group Classifier"
+	select NET_CLS
+	select TRACE_CONTEXT
+	depends on CGROUPS
+	---help---
+	  Say Y here if you want to classify packets based on the control
+	  cgroup of their process.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called cls_cgroup.
+
 config NET_EMATCH
 	bool "Extended Matches"
 	select NET_CLS
Index: net-2.6-next/net/sched/Makefile
===================================================================
--- net-2.6-next.orig/net/sched/Makefile	2008-10-30 12:45:41.000000000 +0100
+++ net-2.6-next/net/sched/Makefile	2008-10-30 13:07:29.000000000 +0100
@@ -38,6 +38,7 @@
 obj-$(CONFIG_NET_CLS_RSVP6)	+= cls_rsvp6.o
 obj-$(CONFIG_NET_CLS_BASIC)	+= cls_basic.o
 obj-$(CONFIG_NET_CLS_FLOW)	+= cls_flow.o
+obj-$(CONFIG_NET_CLS_CGROUP)	+= cls_cgroup.o
 obj-$(CONFIG_NET_EMATCH)	+= ematch.o
 obj-$(CONFIG_NET_EMATCH_CMP)	+= em_cmp.o
 obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
Index: net-2.6-next/net/sched/cls_cgroup.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ net-2.6-next/net/sched/cls_cgroup.c	2008-10-30 13:07:29.000000000 +0100
@@ -0,0 +1,280 @@
+/*
+ * net/sched/cls_cgroup.c	Control Group Classifier
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Thomas Graf <tgraf@suug.ch>
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+#include <linux/cgroup.h>
+#include <net/rtnetlink.h>
+#include <net/pkt_cls.h>
+
+struct cgroup_cls_state
+{
+	struct cgroup_subsys_state css;
+	u32 classid;
+};
+
+static inline struct cgroup_cls_state *net_cls_state(struct cgroup *cgrp)
+{
+	return (struct cgroup_cls_state *)
+		cgroup_subsys_state(cgrp, net_cls_subsys_id);
+}
+
+static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
+						 struct cgroup *cgrp)
+{
+	struct cgroup_cls_state *cs;
+
+	if (!(cs = kzalloc(sizeof(*cs), GFP_KERNEL)))
+		return ERR_PTR(-ENOMEM);
+
+	if (cgrp->parent)
+		cs->classid = net_cls_state(cgrp->parent)->classid;
+
+	return &cs->css;
+}
+
+static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	kfree(ss);
+}
+
+static u64 read_classid(struct cgroup *cgrp, struct cftype *cft)
+{
+	return net_cls_state(cgrp)->classid;
+}
+
+static int write_classid(struct cgroup *cgrp, struct cftype *cft, u64 value)
+{
+	if (!cgroup_lock_live_group(cgrp))
+		return -ENODEV;
+
+	net_cls_state(cgrp)->classid = (u32) value;
+
+	cgroup_unlock();
+
+	return 0;
+}
+
+static struct cftype ss_files[] = {
+	{
+		.name = "classid",
+		.read_u64 = read_classid,
+		.write_u64 = write_classid,
+	},
+};
+
+static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	return cgroup_add_files(cgrp, ss, ss_files, ARRAY_SIZE(ss_files));
+}
+
+struct cgroup_subsys net_cls_subsys = {
+	.name		= "net_cls",
+	.create		= cgrp_create,
+	.destroy	= cgrp_destroy,
+	.populate	= cgrp_populate,
+	.subsys_id	= net_cls_subsys_id,
+};
+
+struct cls_cgroup_head
+{
+	u32			handle;
+	struct tcf_exts		exts;
+	struct tcf_ematch_tree	ematches;
+};
+
+static int cls_cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
+			       struct tcf_result *res)
+{
+	struct cls_cgroup_head *head = tp->root;
+	struct cgroup_cls_state *cs;
+	int ret = 0;
+
+	if (trace_softirq_context(current) > 0)
+		return -1;
+
+	rcu_read_lock();
+	cs = (struct cgroup_cls_state *) task_subsys_state(current,
+							   net_cls_subsys_id);
+	if (cs->classid && tcf_em_tree_match(skb, &head->ematches, NULL)) {
+		res->classid = cs->classid;
+		res->class = 0;
+		ret = tcf_exts_exec(skb, &head->exts, res);
+	} else
+		ret = -1;
+
+	rcu_read_unlock();
+
+	return ret;
+}
+
+static unsigned long cls_cgroup_get(struct tcf_proto *tp, u32 handle)
+{
+	return 0UL;
+}
+
+static void cls_cgroup_put(struct tcf_proto *tp, unsigned long f)
+{
+}
+
+static int cls_cgroup_init(struct tcf_proto *tp)
+{
+	return 0;
+}
+
+static const struct tcf_ext_map cgroup_ext_map = {
+	.action = TCA_CGROUP_ACT,
+	.police = TCA_CGROUP_POLICE,
+};
+
+static const struct nla_policy cgroup_policy[TCA_CGROUP_MAX + 1] = {
+	[TCA_CGROUP_EMATCHES]	= { .type = NLA_NESTED },
+};
+
+static int cls_cgroup_change(struct tcf_proto *tp, unsigned long base,
+			     u32 handle, struct nlattr **tca,
+			     unsigned long *arg)
+{
+	struct nlattr *tb[TCA_CGROUP_MAX+1];
+	struct cls_cgroup_head *head = tp->root;
+	struct tcf_ematch_tree t;
+	struct tcf_exts e;
+	int err;
+
+	if (head == NULL) {
+		if (!handle)
+			return -EINVAL;
+
+		head = kzalloc(sizeof(*head), GFP_KERNEL);
+		if (head == NULL)
+			return -ENOBUFS;
+
+		head->handle = handle;
+
+		tcf_tree_lock(tp);
+		tp->root = head;
+		tcf_tree_unlock(tp);
+	}
+
+	if (handle != head->handle)
+		return -ENOENT;
+
+	err = nla_parse_nested(tb, TCA_CGROUP_MAX, tca[TCA_OPTIONS],
+			       cgroup_policy);
+	if (err < 0)
+		return err;
+
+	err = tcf_exts_validate(tp, tb, tca[TCA_RATE], &e, &cgroup_ext_map);
+	if (err < 0)
+		return err;
+
+	err = tcf_em_tree_validate(tp, tb[TCA_CGROUP_EMATCHES], &t);
+	if (err < 0)
+		return err;
+
+	tcf_exts_change(tp, &head->exts, &e);
+	tcf_em_tree_change(tp, &head->ematches, &t);
+
+	return 0;
+}
+
+static void cls_cgroup_destroy(struct tcf_proto *tp)
+{
+	struct cls_cgroup_head *head;
+
+	head = (struct cls_cgroup_head *)xchg(&tp->root, NULL);
+
+	if (head) {
+		tcf_exts_destroy(tp, &head->exts);
+		tcf_em_tree_destroy(tp, &head->ematches);
+		kfree(head);
+	}
+}
+
+static int cls_cgroup_delete(struct tcf_proto *tp, unsigned long arg)
+{
+	return -EOPNOTSUPP;
+}
+
+static void cls_cgroup_walk(struct tcf_proto *tp, struct tcf_walker *arg)
+{
+	struct cls_cgroup_head *head = tp->root;
+
+	if (arg->count < arg->skip)
+		goto skip;
+
+	if (arg->fn(tp, (unsigned long) head, arg) < 0) {
+		arg->stop = 1;
+		return;
+	}
+skip:
+	arg->count++;
+}
+
+static int cls_cgroup_dump(struct tcf_proto *tp, unsigned long fh,
+			   struct sk_buff *skb, struct tcmsg *t)
+{
+	struct cls_cgroup_head *head = tp->root;
+	unsigned char *b = skb_tail_pointer(skb);
+	struct nlattr *nest;
+
+	t->tcm_handle = head->handle;
+
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
+
+	if (tcf_exts_dump(skb, &head->exts, &cgroup_ext_map) < 0 ||
+	    tcf_em_tree_dump(skb, &head->ematches, TCA_CGROUP_EMATCHES) < 0)
+		goto nla_put_failure;
+
+	nla_nest_end(skb, nest);
+
+	if (tcf_exts_dump_stats(skb, &head->exts, &cgroup_ext_map) < 0)
+		goto nla_put_failure;
+
+	return skb->len;
+
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+static struct tcf_proto_ops cls_cgroup_ops __read_mostly = {
+	.kind		=	"cgroup",
+	.init		=	cls_cgroup_init,
+	.change		=	cls_cgroup_change,
+	.classify	=	cls_cgroup_classify,
+	.destroy	=	cls_cgroup_destroy,
+	.get		=	cls_cgroup_get,
+	.put		=	cls_cgroup_put,
+	.delete		=	cls_cgroup_delete,
+	.walk		=	cls_cgroup_walk,
+	.dump		=	cls_cgroup_dump,
+	.owner		=	THIS_MODULE,
+};
+
+static int __init init_cgroup_cls(void)
+{
+	return register_tcf_proto_ops(&cls_cgroup_ops);
+}
+
+static void __exit exit_cgroup_cls(void)
+{
+	unregister_tcf_proto_ops(&cls_cgroup_ops);
+}
+
+module_init(init_cgroup_cls);
+module_exit(exit_cgroup_cls);
+MODULE_LICENSE("GPL");
