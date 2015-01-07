From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] tc: add BPF based action
Date: Wed,  7 Jan 2015 17:43:55 +0100
Message-ID: <1420649035-9522-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38791 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717AbbAGQn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 11:43:59 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so2043714wiv.2
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 08:43:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This action provides a possibility to exec custom BPF code.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/tc_act/tc_bpf.h        |  25 +++++
 include/uapi/linux/tc_act/Kbuild   |   1 +
 include/uapi/linux/tc_act/tc_bpf.h |  31 ++++++
 net/sched/Kconfig                  |  11 +++
 net/sched/Makefile                 |   1 +
 net/sched/act_bpf.c                | 196 +++++++++++++++++++++++++++++++++++++
 6 files changed, 265 insertions(+)
 create mode 100644 include/net/tc_act/tc_bpf.h
 create mode 100644 include/uapi/linux/tc_act/tc_bpf.h
 create mode 100644 net/sched/act_bpf.c

diff --git a/include/net/tc_act/tc_bpf.h b/include/net/tc_act/tc_bpf.h
new file mode 100644
index 0000000..95e11da
--- /dev/null
+++ b/include/net/tc_act/tc_bpf.h
@@ -0,0 +1,25 @@
+/*
+ * Copyright (c) 2015 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __NET_TC_BPF_H
+#define __NET_TC_BPF_H
+
+#include <linux/filter.h>
+#include <net/act_api.h>
+
+struct tcf_bpf {
+	struct tcf_common	common;
+	struct bpf_prog		*filter;
+	struct sock_filter	*bpf_ops;
+	u16			bpf_len;
+};
+#define to_bpf(a) \
+	container_of(a->priv, struct tcf_bpf, common)
+
+#endif /* __NET_TC_BPF_H */
diff --git a/include/uapi/linux/tc_act/Kbuild b/include/uapi/linux/tc_act/Kbuild
index b057da2..19d5219 100644
--- a/include/uapi/linux/tc_act/Kbuild
+++ b/include/uapi/linux/tc_act/Kbuild
@@ -8,3 +8,4 @@ header-y += tc_nat.h
 header-y += tc_pedit.h
 header-y += tc_skbedit.h
 header-y += tc_vlan.h
+header-y += tc_bpf.h
diff --git a/include/uapi/linux/tc_act/tc_bpf.h b/include/uapi/linux/tc_act/tc_bpf.h
new file mode 100644
index 0000000..5288bd77
--- /dev/null
+++ b/include/uapi/linux/tc_act/tc_bpf.h
@@ -0,0 +1,31 @@
+/*
+ * Copyright (c) 2015 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __LINUX_TC_BPF_H
+#define __LINUX_TC_BPF_H
+
+#include <linux/pkt_cls.h>
+
+#define TCA_ACT_BPF 13
+
+struct tc_act_bpf {
+	tc_gen;
+};
+
+enum {
+	TCA_ACT_BPF_UNSPEC,
+	TCA_ACT_BPF_TM,
+	TCA_ACT_BPF_PARMS,
+	TCA_ACT_BPF_OPS_LEN,
+	TCA_ACT_BPF_OPS,
+	__TCA_ACT_BPF_MAX,
+};
+#define TCA_ACT_BPF_MAX (__TCA_ACT_BPF_MAX - 1)
+
+#endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index c54c9d9..cc311e9 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -698,6 +698,17 @@ config NET_ACT_VLAN
 	  To compile this code as a module, choose M here: the
 	  module will be called act_vlan.
 
+config NET_ACT_BPF
+        tristate "BPF based action"
+        depends on NET_CLS_ACT
+        ---help---
+	  Say Y here to execute BFP code on packets.
+
+	  If unsure, say N.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called act_bpf.
+
 config NET_CLS_IND
 	bool "Incoming device classification"
 	depends on NET_CLS_U32 || NET_CLS_FW
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 679f24a..7ca2b4e 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -17,6 +17,7 @@ obj-$(CONFIG_NET_ACT_SIMP)	+= act_simple.o
 obj-$(CONFIG_NET_ACT_SKBEDIT)	+= act_skbedit.o
 obj-$(CONFIG_NET_ACT_CSUM)	+= act_csum.o
 obj-$(CONFIG_NET_ACT_VLAN)	+= act_vlan.o
+obj-$(CONFIG_NET_ACT_BPF)	+= act_bpf.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
new file mode 100644
index 0000000..43f5f9d
--- /dev/null
+++ b/net/sched/act_bpf.c
@@ -0,0 +1,196 @@
+/*
+ * Copyright (c) 2015 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <linux/filter.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+
+#include <linux/tc_act/tc_bpf.h>
+#include <net/tc_act/tc_bpf.h>
+
+#define BPF_TAB_MASK     15
+
+static int tcf_bpf(struct sk_buff *skb, const struct tc_action *a,
+		   struct tcf_result *res)
+{
+	struct tcf_bpf *b = a->priv;
+	int action;
+	int filter_res;
+
+	spin_lock(&b->tcf_lock);
+	b->tcf_tm.lastuse = jiffies;
+	bstats_update(&b->tcf_bstats, skb);
+	action = b->tcf_action;
+
+	filter_res = BPF_PROG_RUN(b->filter, skb);
+	if (filter_res == -1)
+		goto drop;
+
+	goto unlock;
+
+drop:
+	action = TC_ACT_SHOT;
+	b->tcf_qstats.drops++;
+unlock:
+	spin_unlock(&b->tcf_lock);
+	return action;
+}
+
+static const struct nla_policy act_bpf_policy[TCA_ACT_BPF_MAX + 1] = {
+	[TCA_ACT_BPF_PARMS]	= { .len = sizeof(struct tc_act_bpf) },
+	[TCA_ACT_BPF_OPS_LEN]	= { .type = NLA_U16 },
+	[TCA_ACT_BPF_OPS]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct sock_filter) * BPF_MAXINSNS },
+};
+
+static int tcf_bpf_init(struct net *net, struct nlattr *nla,
+			struct nlattr *est, struct tc_action *a,
+			int ovr, int bind)
+{
+	struct nlattr *tb[TCA_ACT_BPF_MAX + 1];
+	struct tc_act_bpf *parm;
+	struct tcf_bpf *b;
+	u16 bpf_size, bpf_len;
+	struct sock_filter *bpf_ops;
+	struct sock_fprog_kern tmp;
+	struct bpf_prog *fp;
+	int ret;
+
+	if (!nla)
+		return -EINVAL;
+
+	ret = nla_parse_nested(tb, TCA_ACT_BPF_MAX, nla, act_bpf_policy);
+	if (ret < 0)
+		return ret;
+
+	if (!tb[TCA_ACT_BPF_PARMS] ||
+	    !tb[TCA_ACT_BPF_OPS_LEN] || !tb[TCA_ACT_BPF_OPS])
+		return -EINVAL;
+	parm = nla_data(tb[TCA_ACT_BPF_PARMS]);
+
+	bpf_len = nla_get_u16(tb[TCA_ACT_BPF_OPS_LEN]);
+	if (bpf_len > BPF_MAXINSNS || bpf_len == 0)
+		return -EINVAL;
+
+	bpf_size = bpf_len * sizeof(*bpf_ops);
+	bpf_ops = kzalloc(bpf_size, GFP_KERNEL);
+	if (!bpf_ops)
+		return -ENOMEM;
+
+	memcpy(bpf_ops, nla_data(tb[TCA_ACT_BPF_OPS]), bpf_size);
+
+	tmp.len = bpf_len;
+	tmp.filter = bpf_ops;
+
+	ret = bpf_prog_create(&fp, &tmp);
+	if (ret)
+		goto free_bpf_ops;
+
+	if (!tcf_hash_check(parm->index, a, bind)) {
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*b), bind);
+		if (ret)
+			goto free_bpf_ops;
+
+		ret = ACT_P_CREATED;
+	} else {
+		if (bind)
+			goto free_bpf_ops;
+		tcf_hash_release(a, bind);
+		if (!ovr) {
+			ret = -EEXIST;
+			goto free_bpf_ops;
+		}
+	}
+
+	b = to_bpf(a);
+	spin_lock_bh(&b->tcf_lock);
+	b->tcf_action = parm->action;
+	b->bpf_len = bpf_len;
+	b->bpf_ops = bpf_ops;
+	b->filter = fp;
+	spin_unlock_bh(&b->tcf_lock);
+
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(a);
+	return ret;
+
+free_bpf_ops:
+	kfree(bpf_ops);
+	return ret;
+}
+
+static int tcf_bpf_dump(struct sk_buff *skb, struct tc_action *a,
+			int bind, int ref)
+{
+	unsigned char *tp = skb_tail_pointer(skb);
+	struct tcf_bpf *b = a->priv;
+	struct tc_act_bpf opt = {
+		.index    = b->tcf_index,
+		.refcnt   = b->tcf_refcnt - ref,
+		.bindcnt  = b->tcf_bindcnt - bind,
+		.action   = b->tcf_action,
+	};
+	struct tcf_t t;
+	struct nlattr *nla;
+
+	if (nla_put(skb, TCA_ACT_BPF_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
+
+	if (nla_put_u16(skb, TCA_ACT_BPF_OPS_LEN, b->bpf_len))
+		goto nla_put_failure;
+
+	nla = nla_reserve(skb, TCA_ACT_BPF_OPS, b->bpf_len *
+			  sizeof(struct sock_filter));
+	if (!nla)
+		goto nla_put_failure;
+
+	memcpy(nla_data(nla), b->bpf_ops, nla_len(nla));
+
+	t.install = jiffies_to_clock_t(jiffies - b->tcf_tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - b->tcf_tm.lastuse);
+	t.expires = jiffies_to_clock_t(b->tcf_tm.expires);
+	if (nla_put(skb, TCA_ACT_BPF_TM, sizeof(t), &t))
+		goto nla_put_failure;
+	return skb->len;
+
+nla_put_failure:
+	nlmsg_trim(skb, tp);
+	return -1;
+}
+
+static struct tc_action_ops act_bpf_ops = {
+	.kind		=	"bpf",
+	.type		=	TCA_ACT_BPF,
+	.owner		=	THIS_MODULE,
+	.act		=	tcf_bpf,
+	.dump		=	tcf_bpf_dump,
+	.init		=	tcf_bpf_init,
+};
+
+static int __init bpf_init_module(void)
+{
+	return tcf_register_action(&act_bpf_ops, BPF_TAB_MASK);
+}
+
+static void __exit bpf_cleanup_module(void)
+{
+	tcf_unregister_action(&act_bpf_ops);
+}
+
+module_init(bpf_init_module);
+module_exit(bpf_cleanup_module);
+
+MODULE_AUTHOR("Jiri Pirko <jiri@resnulli.us>");
+MODULE_DESCRIPTION("TC BPF based action");
+MODULE_LICENSE("GPL v2");
-- 
1.9.3
