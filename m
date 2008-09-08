From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] Control Group Classifier
Date: Mon, 8 Sep 2008 13:51:01 +0200
Message-ID: <20080908115101.GE20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:36474 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751502AbYIHLun (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 07:50:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements a very basic cgroup subsystem which allows
assigning classids to cgroups. It also adds a trivial classifier
to filter packets based on that classid and map them to classes.

The classifier should cover the most common use case and will work
without any configuration.  Additionaly it might make sense to add
a cgroup meta ematch to allow  for more sophisticated setups.

I've taken over the idea of inheriting the classid of cgroup parents
from the patchset posted by Ranjit Manomohan <ranjitm@google.com>.

Comments welcome.

Index: net-2.6-next/include/linux/cgroup_subsys.h
===================================================================
--- net-2.6-next.orig/include/linux/cgroup_subsys.h	2008-09-08 13:38:07.000000000 +0200
+++ net-2.6-next/include/linux/cgroup_subsys.h	2008-09-08 13:38:47.000000000 +0200
@@ -48,3 +48,9 @@
 #endif
 
 /* */
+
+#ifdef CONFIG_NET_CLS_CGROUP
+SUBSYS(net_cls)
+#endif
+
+/* */
Index: net-2.6-next/include/linux/pkt_cls.h
===================================================================
--- net-2.6-next.orig/include/linux/pkt_cls.h	2008-09-08 13:38:07.000000000 +0200
+++ net-2.6-next/include/linux/pkt_cls.h	2008-09-08 13:38:47.000000000 +0200
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
Index: net-2.6-next/net/sched/Kconfig
===================================================================
--- net-2.6-next.orig/net/sched/Kconfig	2008-09-08 13:38:07.000000000 +0200
+++ net-2.6-next/net/sched/Kconfig	2008-09-08 13:38:47.000000000 +0200
@@ -307,6 +307,17 @@
 	  To compile this code as a module, choose M here: the
 	  module will be called cls_flow.
 
+config NET_CLS_CGROUP
+	tristate "Control Group Classifier"
+	select NET_CLS
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
--- net-2.6-next.orig/net/sched/Makefile	2008-09-08 13:38:07.000000000 +0200
+++ net-2.6-next/net/sched/Makefile	2008-09-08 13:38:47.000000000 +0200
@@ -36,6 +36,7 @@
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
+++ net-2.6-next/net/sched/cls_cgroup.c	2008-09-08 13:39:32.000000000 +0200
@@ -0,0 +1,278 @@
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
+		cs->classid = net_cls_state(cgrp)->classid;
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
+	rcu_read_lock();
+
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
