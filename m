From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET_NEXT PATCH 2/2] pkt_action: add new action skbedit
Date: Wed, 27 Aug 2008 18:12:57 -0700
Message-ID: <20080828011257.7909.78529.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080828011253.7909.5172.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:44018 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753278AbYH1BM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 21:12:59 -0400
Received: by rv-out-0506.google.com with SMTP id k40so130630rvb.1
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 18:12:59 -0700 (PDT)
In-Reply-To: <20080828011253.7909.5172.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This new action will have the ability to change the priority and/or
queue_mapping fields on an sk_buff.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/tc_act/tc_skbedit.h |   23 ++++
 include/net/tc_act/tc_skbedit.h   |   15 +++
 net/sched/Kconfig                 |   11 ++
 net/sched/Makefile                |    1 
 net/sched/act_skbedit.c           |  199 +++++++++++++++++++++++++++++++++++++
 5 files changed, 249 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/tc_act/tc_skbedit.h
 create mode 100644 include/net/tc_act/tc_skbedit.h
 create mode 100644 net/sched/act_skbedit.c

diff --git a/include/linux/tc_act/tc_skbedit.h b/include/linux/tc_act/tc_skbedit.h
new file mode 100644
index 0000000..3965636
--- /dev/null
+++ b/include/linux/tc_act/tc_skbedit.h
@@ -0,0 +1,23 @@
+#ifndef __LINUX_TC_SKBEDIT_H
+#define __LINUX_TC_SKBEDIT_H
+
+#include <linux/pkt_cls.h>
+
+#define SKBEDIT_F_PRIORITY		0x1
+#define SKBEDIT_F_QUEUE_MAPPING		0x2
+
+struct tc_skbedit {
+	tc_gen;
+};
+
+enum {
+	TCA_SKBEDIT_UNSPEC,
+	TCA_SKBEDIT_TM,
+	TCA_SKBEDIT_PARMS,
+	TCA_SKBEDIT_PRIORITY,
+	TCA_SKBEDIT_QUEUE_MAPPING,
+	__TCA_SKBEDIT_MAX
+};
+#define TCA_SKBEDIT_MAX (__TCA_SKBEDIT_MAX - 1)
+
+#endif
diff --git a/include/net/tc_act/tc_skbedit.h b/include/net/tc_act/tc_skbedit.h
new file mode 100644
index 0000000..cf4fd9f
--- /dev/null
+++ b/include/net/tc_act/tc_skbedit.h
@@ -0,0 +1,15 @@
+#ifndef __NET_TC_SKBEDIT_H
+#define __NET_TC_SKBEDIT_H
+
+#include <net/act_api.h>
+
+struct tcf_skbedit {
+	struct tcf_common	common;
+	u32			flags;
+	u32     		priority;
+	u16			queue_mapping;
+};
+#define to_skbedit(pc) \
+	container_of(pc, struct tcf_skbedit, common)
+
+#endif /* __NET_TC_SKBEDIT_H */
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index efaa7a7..613823b 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -485,6 +485,17 @@ config NET_ACT_SIMP
 	  To compile this code as a module, choose M here: the
 	  module will be called simple.
 
+config NET_ACT_SKBEDIT
+        tristate "SKB Editing"
+        depends on NET_CLS_ACT
+        ---help---
+	  Say Y here to change skb priority or queue_mapping settings.
+
+	  If unsure, say N.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called simple.
+
 config NET_CLS_IND
 	bool "Incoming device classification"
 	depends on NET_CLS_U32 || NET_CLS_FW
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 3d9b953..e60c992 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -14,6 +14,7 @@ obj-$(CONFIG_NET_ACT_IPT)	+= act_ipt.o
 obj-$(CONFIG_NET_ACT_NAT)	+= act_nat.o
 obj-$(CONFIG_NET_ACT_PEDIT)	+= act_pedit.o
 obj-$(CONFIG_NET_ACT_SIMP)	+= act_simple.o
+obj-$(CONFIG_NET_ACT_SKBEDIT)	+= act_skbedit.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
new file mode 100644
index 0000000..54eeb27
--- /dev/null
+++ b/net/sched/act_skbedit.c
@@ -0,0 +1,199 @@
+/*
+ * net/sched/act_skbedit.c	SKB Editing
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors: Alexander Duyck <alexander.h.duyck@intel.com>
+ *
+ * Original Authors:	Jamal Hadi Salim (2005-8) (act_simple)
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+
+#define TCA_ACT_SKBEDIT 11
+
+#include <linux/tc_act/tc_skbedit.h>
+#include <net/tc_act/tc_skbedit.h>
+
+#define SKBEDIT_TAB_MASK     15
+static struct tcf_common *tcf_skbedit_ht[SKBEDIT_TAB_MASK + 1];
+static u32 skbedit_idx_gen;
+static DEFINE_RWLOCK(skbedit_lock);
+
+static struct tcf_hashinfo skbedit_hash_info = {
+	.htab	=	tcf_skbedit_ht,
+	.hmask	=	SKBEDIT_TAB_MASK,
+	.lock	=	&skbedit_lock,
+};
+
+static int tcf_skbedit(struct sk_buff *skb, struct tc_action *a,
+		       struct tcf_result *res)
+{
+	struct tcf_skbedit *d = a->priv;
+
+	spin_lock(&d->tcf_lock);
+	d->tcf_tm.lastuse = jiffies;
+	d->tcf_bstats.bytes += qdisc_pkt_len(skb);
+	d->tcf_bstats.packets++;
+
+	if (d->flags & SKBEDIT_F_PRIORITY)
+		skb->priority = d->priority;
+	if (d->flags & SKBEDIT_F_QUEUE_MAPPING)
+		skb_set_queue_mapping(skb, d->queue_mapping);
+
+	spin_unlock(&d->tcf_lock);
+	return d->tcf_action;
+}
+
+static const struct nla_policy skbedit_policy[TCA_SKBEDIT_MAX + 1] = {
+	[TCA_SKBEDIT_PARMS]		= { .len = sizeof(struct tc_skbedit) },
+	[TCA_SKBEDIT_PRIORITY]		= { .len = sizeof(u32) },
+	[TCA_SKBEDIT_QUEUE_MAPPING]	= { .len = sizeof(u16) },
+};
+
+static int tcf_skbedit_init(struct nlattr *nla, struct nlattr *est,
+			 struct tc_action *a, int ovr, int bind)
+{
+	struct nlattr *tb[TCA_SKBEDIT_MAX + 1];
+	struct tc_skbedit *parm;
+	struct tcf_skbedit *d;
+	struct tcf_common *pc;
+	u32 flags = 0, *priority = NULL;
+	u16 *queue_mapping = NULL;
+	int ret = 0, err;
+
+	if (nla == NULL)
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, TCA_SKBEDIT_MAX, nla, skbedit_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[TCA_SKBEDIT_PARMS] == NULL)
+		return -EINVAL;
+
+	if (tb[TCA_SKBEDIT_PRIORITY] != NULL) {
+		flags |= SKBEDIT_F_PRIORITY;
+		priority = nla_data(tb[TCA_SKBEDIT_PRIORITY]);
+	}
+
+	if (tb[TCA_SKBEDIT_QUEUE_MAPPING] != NULL) {
+		flags |= SKBEDIT_F_QUEUE_MAPPING;
+		queue_mapping = nla_data(tb[TCA_SKBEDIT_QUEUE_MAPPING]);
+	}
+	if (!flags)
+		return -EINVAL;
+
+	parm = nla_data(tb[TCA_SKBEDIT_PARMS]);
+
+	pc = tcf_hash_check(parm->index, a, bind, &skbedit_hash_info);
+	if (!pc) {
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind,
+				     &skbedit_idx_gen, &skbedit_hash_info);
+		if (unlikely(!pc))
+			return -ENOMEM;
+
+		d = to_skbedit(pc);
+		ret = ACT_P_CREATED;
+	} else {
+		d = to_skbedit(pc);
+		if (!ovr) {
+			tcf_hash_release(pc, bind, &skbedit_hash_info);
+			return -EEXIST;
+		}
+	}
+
+	spin_lock_bh(&d->tcf_lock);
+
+	d->flags = flags;
+	if (flags & SKBEDIT_F_PRIORITY)
+		d->priority = *priority;
+	if (flags & SKBEDIT_F_QUEUE_MAPPING)
+		d->queue_mapping = *queue_mapping;
+	d->tcf_action = parm->action;
+
+	spin_unlock_bh(&d->tcf_lock);
+
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(pc, &skbedit_hash_info);
+	return ret;
+}
+
+static inline int tcf_skbedit_cleanup(struct tc_action *a, int bind)
+{
+	struct tcf_skbedit *d = a->priv;
+
+	if (d)
+		return tcf_hash_release(&d->common, bind, &skbedit_hash_info);
+	return 0;
+}
+
+static inline int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
+				int bind, int ref)
+{
+	unsigned char *b = skb_tail_pointer(skb);
+	struct tcf_skbedit *d = a->priv;
+	struct tc_skbedit opt;
+	struct tcf_t t;
+
+	opt.index = d->tcf_index;
+	opt.refcnt = d->tcf_refcnt - ref;
+	opt.bindcnt = d->tcf_bindcnt - bind;
+	opt.action = d->tcf_action;
+	NLA_PUT(skb, TCA_SKBEDIT_PARMS, sizeof(opt), &opt);
+	if (d->flags & SKBEDIT_F_PRIORITY)
+		NLA_PUT(skb, TCA_SKBEDIT_PRIORITY, sizeof(d->priority),
+			&d->priority);
+	if (d->flags & SKBEDIT_F_QUEUE_MAPPING)
+		NLA_PUT(skb, TCA_SKBEDIT_QUEUE_MAPPING,
+			sizeof(d->queue_mapping), &d->queue_mapping);
+	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
+	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);
+	NLA_PUT(skb, TCA_SKBEDIT_TM, sizeof(t), &t);
+	return skb->len;
+
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+static struct tc_action_ops act_skbedit_ops = {
+	.kind		=	"skbedit",
+	.hinfo		=	&skbedit_hash_info,
+	.type		=	TCA_ACT_SKBEDIT,
+	.capab		=	TCA_CAP_NONE,
+	.owner		=	THIS_MODULE,
+	.act		=	tcf_skbedit,
+	.dump		=	tcf_skbedit_dump,
+	.cleanup	=	tcf_skbedit_cleanup,
+	.init		=	tcf_skbedit_init,
+	.walk		=	tcf_generic_walker,
+};
+
+MODULE_AUTHOR("Alexander Duyck(2008)");
+MODULE_DESCRIPTION("SKB Editing");
+MODULE_LICENSE("GPL");
+
+static int __init skbedit_init_module(void)
+{
+	return tcf_register_action(&act_skbedit_ops);
+}
+
+static void __exit skbedit_cleanup_module(void)
+{
+	tcf_unregister_action(&act_skbedit_ops);
+}
+
+module_init(skbedit_init_module);
+module_exit(skbedit_cleanup_module);

