From: Ranjit Manomohan <ranjitm@google.com>
Subject: [PATCH 2/2] Traffic control cgroups subsystem
Date: Fri, 18 Jul 2008 14:29:26 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0807181428180.18212@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: menage@google.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:24621 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753422AbYGRV3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 17:29:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements a filter that classifies packets based upon
the cgroup_classid of the packet.

Signed-off-by: Ranjit Manomohan <ranjitm@google.com>

---

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 99efbed..290da04 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -379,6 +379,18 @@ enum

  #define TCA_FLOW_MAX	(__TCA_FLOW_MAX - 1)

+/* Cgroups filter */
+
+enum {
+	TCA_CGROUP_UNSPEC,
+	TCA_CGROUP_CLASSID,
+	TCA_CGROUP_MASK,
+	TCA_CGROUP_VALUE,
+	__TCA_CGROUP_MAX
+};
+
+#define TCA_CGROUP_MAX	(__TCA_CGROUP_MAX - 1)
+
  /* Basic filter */

  enum
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 82adfe6..844837f 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -318,6 +318,16 @@ config NET_CLS_FLOW
  	  To compile this code as a module, choose M here: the
  	  module will be called cls_flow.

+config NET_CLS_CGROUP
+	tristate "Cgroups tc classifier"
+	select NET_CLS
+	---help---
+	  If you say Y here, you will be able to classify packets based on
+	  cgroup membership of the task originating the packet.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called cls_cgroup.
+
  config NET_EMATCH
  	bool "Extended Matches"
  	select NET_CLS
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 1d2b0f7..91e9ee0 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -36,6 +36,7 @@ obj-$(CONFIG_NET_CLS_TCINDEX)	+= cls_tcindex.o
  obj-$(CONFIG_NET_CLS_RSVP6)	+= cls_rsvp6.o
  obj-$(CONFIG_NET_CLS_BASIC)	+= cls_basic.o
  obj-$(CONFIG_NET_CLS_FLOW)	+= cls_flow.o
+obj-$(CONFIG_NET_CLS_CGROUP)	+= cls_cgroup.o
  obj-$(CONFIG_NET_EMATCH)	+= ematch.o
  obj-$(CONFIG_NET_EMATCH_CMP)	+= em_cmp.o
  obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
new file mode 100644
index 0000000..78d494f
--- /dev/null
+++ b/net/sched/cls_cgroup.c
@@ -0,0 +1,277 @@
+/*
+ * net/sched/cls_cgroup.c	Simple packet classifier which can filter
+ * 				packets based on the cgroups they belong to.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+#include <net/pkt_cls.h>
+#include <net/netlink.h>
+
+struct cgroup_head {
+	struct list_head	flist;		/* Head of filter list */
+};
+
+struct cgroup_filter {
+	u32			handle;		/* Unique filter handle */
+	struct tcf_result	res;
+	struct list_head	link;
+	u32			mask;
+	u32			value;
+};
+
+/* This function is called from the qdisc to classify a particular packet
+ * contained in the skb to the appropriate sub-classes. It returns the
+ * classid of the target class. This filter will match if the cgroup_classid
+ * in the skb matches the value in the filter.
+ */
+static int cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
+			  struct tcf_result *res)
+{
+	struct cgroup_head *head = (struct cgroup_head *)tp->root;
+	struct cgroup_filter *f;
+
+	uint32_t cgroup_classid = skb->cgroup_classid;
+
+	list_for_each_entry(f, &head->flist, link) {
+		if ((cgroup_classid & f->mask) == f->value) {
+			*res = f->res;
+			return 0;
+		}
+	}
+	return -1;
+}
+
+/* Returns pointer to filter matching the handle passed into the function.*/
+static unsigned long cgroup_get(struct tcf_proto *tp, u32 handle)
+{
+	unsigned long l = 0UL;
+	struct cgroup_head *head = (struct cgroup_head *) tp->root;
+	struct cgroup_filter *f;
+
+	if (head == NULL)
+		return 0UL;
+
+	list_for_each_entry(f, &head->flist, link)
+		if (f->handle == handle)
+			l = (unsigned long) f;
+
+	return l;
+}
+
+/* Does not seem to be used for classifiers. */
+static void cgroup_put(struct tcf_proto *tp, unsigned long f)
+{
+}
+
+/* Initializer function called when tp is created. */
+static int cgroup_init(struct tcf_proto *tp)
+{
+	struct cgroup_head *head = kzalloc(sizeof(*head), GFP_KERNEL);
+	if (head == NULL)
+		return -ENOBUFS;
+
+	INIT_LIST_HEAD(&head->flist);
+	tp->root = head;
+	return 0;
+}
+
+/* Simple delete function called when filter is deleted */
+static inline void cgroup_delete_filter(struct tcf_proto *tp,
+				       struct cgroup_filter *f)
+{
+	kfree(f);
+}
+
+/* Destroy the entire tp structure.*/
+static void cgroup_destroy(struct tcf_proto *tp)
+{
+	struct cgroup_head *head = (struct cgroup_head *) xchg(&tp->root, NULL);
+	struct cgroup_filter *f, *n;
+
+	list_for_each_entry_safe(f, n, &head->flist, link) {
+		list_del(&f->link);
+		cgroup_delete_filter(tp, f);
+	}
+	kfree(head);
+}
+
+/* Delete one filter entry */
+static int cgroup_delete(struct tcf_proto *tp, unsigned long arg)
+{
+	struct cgroup_head *head = (struct cgroup_head *) tp->root;
+	struct cgroup_filter *t, *f = (struct cgroup_filter *) arg;
+
+	list_for_each_entry(t, &head->flist, link)
+		if (t == f) {
+			tcf_tree_lock(tp);
+			list_del(&t->link);
+			tcf_tree_unlock(tp);
+			cgroup_delete_filter(tp, t);
+			return 0;
+		}
+
+	return -ENOENT;
+}
+
+/* Set the mask and value parameters in the tp structure. */
+static inline int cgroup_set_parms(struct tcf_proto *tp,
+			unsigned long base,
+			struct cgroup_filter *f, struct nlattr **tb)
+{
+	int err = -EINVAL;
+
+	if (tb[TCA_CGROUP_MASK]) {
+		if (nla_len(tb[TCA_CGROUP_MASK]) < sizeof(u32))
+			return err;
+		f->mask =  nla_get_u32(tb[TCA_CGROUP_MASK]);
+	} else
+		f->mask = UINT_MAX;
+
+	if (tb[TCA_CGROUP_VALUE]) {
+		if (nla_len(tb[TCA_CGROUP_VALUE]) < sizeof(u32))
+			return err;
+		f->value = nla_get_u32(tb[TCA_CGROUP_VALUE]);
+	} else
+		return err;
+
+	if (tb[TCA_CGROUP_CLASSID]) {
+		if (nla_len(tb[TCA_CGROUP_CLASSID]) < sizeof(u32))
+			return err;
+		f->res.classid = nla_get_u32(tb[TCA_CGROUP_CLASSID]);
+		tcf_bind_filter(tp, &f->res, base);
+	} else
+		return err;
+
+	return 0;
+}
+
+/* Change the mask and value parameters in the current settings. */
+static int cgroup_change(struct tcf_proto *tp, unsigned long base, u32 handle,
+				struct nlattr **tca, unsigned long *arg)
+{
+	int err = -EINVAL;
+	struct cgroup_head *head = (struct cgroup_head *) tp->root;
+	struct nlattr *tb[TCA_CGROUP_MAX];
+	struct cgroup_filter *f = (struct cgroup_filter *) *arg;
+
+	if (tca[TCA_OPTIONS] == NULL)
+		return -EINVAL;
+
+	if (nla_parse_nested(tb, TCA_CGROUP_MAX, tca[TCA_OPTIONS], NULL) < 0)
+		return -EINVAL;
+
+	if (f != NULL) {
+		if (handle && f->handle != handle)
+			return -EINVAL;
+	} else {
+		if (!handle)
+			return -EINVAL;
+		f = kzalloc(sizeof(*f), GFP_KERNEL);
+		if (f == NULL)
+			return -ENOBUFS;
+		f->handle = handle;
+	}
+
+	err = cgroup_set_parms(tp, base, f, tb);
+	if (err < 0)
+		goto err;
+
+	if (*arg == 0) {
+		tcf_tree_lock(tp);
+		list_add(&f->link, &head->flist);
+		tcf_tree_unlock(tp);
+	}
+
+	*arg = (unsigned long)f;
+	return 0;
+
+err:
+	if (*arg == 0)
+		kfree(f);
+	return err;
+}
+
+/* Walk the filter list for things like displaying contents.*/
+static void cgroup_walk(struct tcf_proto *tp, struct tcf_walker *arg)
+{
+	struct cgroup_head *head = (struct cgroup_head *) tp->root;
+	struct cgroup_filter *f;
+
+	list_for_each_entry(f, &head->flist, link) {
+		if (arg->count < arg->skip)
+			goto skip;
+
+		if (arg->fn(tp, (unsigned long) f, arg) < 0) {
+			arg->stop = 1;
+			break;
+		}
+skip:
+		arg->count++;
+	}
+}
+
+/* Retreive current settings in the filter */
+static int cgroup_dump(struct tcf_proto *tp, unsigned long fh,
+		      struct sk_buff *skb, struct tcmsg *t)
+{
+	struct cgroup_filter *f = (struct cgroup_filter *) fh;
+	struct nlattr *nest;
+
+	if (f == NULL)
+		return skb->len;
+
+	t->tcm_handle = f->handle;
+
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
+
+	NLA_PUT_U32(skb, TCA_CGROUP_CLASSID, f->res.classid);
+	NLA_PUT_U32(skb, TCA_CGROUP_MASK, f->mask);
+	NLA_PUT_U32(skb, TCA_CGROUP_VALUE, f->value);
+
+	nla_nest_end(skb, nest);
+	return skb->len;
+
+nla_put_failure:
+	nla_nest_cancel(skb, nest);
+	return -1;
+}
+
+static struct tcf_proto_ops cls_cgroup_ops = {
+	.kind		=	"cgroup",
+	.classify	=	cgroup_classify,
+	.init		=	cgroup_init,
+	.destroy	=	cgroup_destroy,
+	.get		=	cgroup_get,
+	.put		=	cgroup_put,
+	.change		=	cgroup_change,
+	.delete		=	cgroup_delete,
+	.walk		=	cgroup_walk,
+	.dump		=	cgroup_dump,
+	.owner		=	THIS_MODULE,
+};
+
+static int __init init_cgroup(void)
+{
+	return register_tcf_proto_ops(&cls_cgroup_ops);
+}
+
+static void __exit exit_cgroup(void)
+{
+	unregister_tcf_proto_ops(&cls_cgroup_ops);
+}
+
+module_init(init_cgroup)
+module_exit(exit_cgroup)
+MODULE_LICENSE("GPL");
+
