From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 9/9] sched: introduce vlan action
Date: Wed, 19 Nov 2014 14:05:03 +0100
Message-ID: <1416402303-25341-10-git-send-email-jiri@resnulli.us>
References: <1416402303-25341-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:42530 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754979AbaKSNFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 08:05:15 -0500
Received: by mail-wg0-f45.google.com with SMTP id b13so790040wgh.18
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 05:05:14 -0800 (PST)
In-Reply-To: <1416402303-25341-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This tc action allows to work with vlan tagged skbs. Two supported
sub-actions are header pop and header push.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---

v1->v2:
- fixed protocol dumping in tcf_vlan_dump

 include/net/tc_act/tc_vlan.h        |  27 +++++
 include/uapi/linux/tc_act/tc_vlan.h |  35 ++++++
 net/sched/Kconfig                   |  11 ++
 net/sched/Makefile                  |   1 +
 net/sched/act_vlan.c                | 207 ++++++++++++++++++++++++++++++++++++
 5 files changed, 281 insertions(+)
 create mode 100644 include/net/tc_act/tc_vlan.h
 create mode 100644 include/uapi/linux/tc_act/tc_vlan.h
 create mode 100644 net/sched/act_vlan.c

diff --git a/include/net/tc_act/tc_vlan.h b/include/net/tc_act/tc_vlan.h
new file mode 100644
index 0000000..c809c1d
--- /dev/null
+++ b/include/net/tc_act/tc_vlan.h
@@ -0,0 +1,27 @@
+/*
+ * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __NET_TC_VLAN_H
+#define __NET_TC_VLAN_H
+
+#include <net/act_api.h>
+
+#define VLAN_F_POP		0x1
+#define VLAN_F_PUSH		0x2
+
+struct tcf_vlan {
+	struct tcf_common	common;
+	int			tcfv_action;
+	__be16			tcfv_push_vid;
+	__be16			tcfv_push_proto;
+};
+#define to_vlan(a) \
+	container_of(a->priv, struct tcf_vlan, common)
+
+#endif /* __NET_TC_VLAN_H */
diff --git a/include/uapi/linux/tc_act/tc_vlan.h b/include/uapi/linux/tc_act/tc_vlan.h
new file mode 100644
index 0000000..f7b8d44
--- /dev/null
+++ b/include/uapi/linux/tc_act/tc_vlan.h
@@ -0,0 +1,35 @@
+/*
+ * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __LINUX_TC_VLAN_H
+#define __LINUX_TC_VLAN_H
+
+#include <linux/pkt_cls.h>
+
+#define TCA_ACT_VLAN 12
+
+#define TCA_VLAN_ACT_POP	1
+#define TCA_VLAN_ACT_PUSH	2
+
+struct tc_vlan {
+	tc_gen;
+	int v_action;
+};
+
+enum {
+	TCA_VLAN_UNSPEC,
+	TCA_VLAN_TM,
+	TCA_VLAN_PARMS,
+	TCA_VLAN_PUSH_VLAN_ID,
+	TCA_VLAN_PUSH_VLAN_PROTOCOL,
+	__TCA_VLAN_MAX,
+};
+#define TCA_VLAN_MAX (__TCA_VLAN_MAX - 1)
+
+#endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index a1a8e29..88618f8 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -686,6 +686,17 @@ config NET_ACT_CSUM
 	  To compile this code as a module, choose M here: the
 	  module will be called act_csum.
 
+config NET_ACT_VLAN
+        tristate "Vlan manipulation"
+        depends on NET_CLS_ACT
+        ---help---
+	  Say Y here to push or pop vlan headers.
+
+	  If unsure, say N.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called act_vlan.
+
 config NET_CLS_IND
 	bool "Incoming device classification"
 	depends on NET_CLS_U32 || NET_CLS_FW
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 0a869a1..679f24a 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -16,6 +16,7 @@ obj-$(CONFIG_NET_ACT_PEDIT)	+= act_pedit.o
 obj-$(CONFIG_NET_ACT_SIMP)	+= act_simple.o
 obj-$(CONFIG_NET_ACT_SKBEDIT)	+= act_skbedit.o
 obj-$(CONFIG_NET_ACT_CSUM)	+= act_csum.o
+obj-$(CONFIG_NET_ACT_VLAN)	+= act_vlan.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
new file mode 100644
index 0000000..d735ecf
--- /dev/null
+++ b/net/sched/act_vlan.c
@@ -0,0 +1,207 @@
+/*
+ * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
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
+#include <linux/if_vlan.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+
+#include <linux/tc_act/tc_vlan.h>
+#include <net/tc_act/tc_vlan.h>
+
+#define VLAN_TAB_MASK     15
+
+static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
+		    struct tcf_result *res)
+{
+	struct tcf_vlan *v = a->priv;
+	int action;
+	int err;
+
+	spin_lock(&v->tcf_lock);
+	v->tcf_tm.lastuse = jiffies;
+	bstats_update(&v->tcf_bstats, skb);
+	action = v->tcf_action;
+
+	switch (v->tcfv_action) {
+	case TCA_VLAN_ACT_POP:
+		err = skb_vlan_pop(skb);
+		if (err)
+			goto drop;
+		break;
+	case TCA_VLAN_ACT_PUSH:
+		err = skb_vlan_push(skb, v->tcfv_push_proto, v->tcfv_push_vid);
+		if (err)
+			goto drop;
+		break;
+	default:
+		BUG();
+	}
+
+	goto unlock;
+
+drop:
+	action = TC_ACT_SHOT;
+	v->tcf_qstats.drops++;
+unlock:
+	spin_unlock(&v->tcf_lock);
+	return action;
+}
+
+static const struct nla_policy vlan_policy[TCA_VLAN_MAX + 1] = {
+	[TCA_VLAN_PARMS]		= { .len = sizeof(struct tc_vlan) },
+	[TCA_VLAN_PUSH_VLAN_ID]		= { .type = NLA_U16 },
+	[TCA_VLAN_PUSH_VLAN_PROTOCOL]	= { .type = NLA_U16 },
+};
+
+static int tcf_vlan_init(struct net *net, struct nlattr *nla,
+			 struct nlattr *est, struct tc_action *a,
+			 int ovr, int bind)
+{
+	struct nlattr *tb[TCA_VLAN_MAX + 1];
+	struct tc_vlan *parm;
+	struct tcf_vlan *v;
+	int action;
+	__be16 push_vid = 0;
+	__be16 push_proto = 0;
+	int ret = 0;
+	int err;
+
+	if (!nla)
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, TCA_VLAN_MAX, nla, vlan_policy);
+	if (err < 0)
+		return err;
+
+	if (!tb[TCA_VLAN_PARMS])
+		return -EINVAL;
+	parm = nla_data(tb[TCA_VLAN_PARMS]);
+	switch (parm->v_action) {
+	case TCA_VLAN_ACT_POP:
+		break;
+	case TCA_VLAN_ACT_PUSH:
+		if (!tb[TCA_VLAN_PUSH_VLAN_ID])
+			return -EINVAL;
+		push_vid = nla_get_u16(tb[TCA_VLAN_PUSH_VLAN_ID]);
+		if (push_vid >= VLAN_VID_MASK)
+			return -ERANGE;
+
+		if (tb[TCA_VLAN_PUSH_VLAN_PROTOCOL]) {
+			push_proto = nla_get_be16(tb[TCA_VLAN_PUSH_VLAN_PROTOCOL]);
+			switch (push_proto) {
+			case htons(ETH_P_8021Q):
+			case htons(ETH_P_8021AD):
+				break;
+			default:
+				return -EPROTONOSUPPORT;
+			}
+		} else {
+			push_proto = htons(ETH_P_8021Q);
+		}
+		break;
+	default:
+		return -EINVAL;
+	}
+	action = parm->v_action;
+
+	if (!tcf_hash_check(parm->index, a, bind)) {
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*v), bind);
+		if (ret)
+			return ret;
+
+		ret = ACT_P_CREATED;
+	} else {
+		if (bind)
+			return 0;
+		tcf_hash_release(a, bind);
+		if (!ovr)
+			return -EEXIST;
+	}
+
+	v = to_vlan(a);
+
+	spin_lock_bh(&v->tcf_lock);
+
+	v->tcfv_action = action;
+	v->tcfv_push_vid = push_vid;
+	v->tcfv_push_proto = push_proto;
+
+	v->tcf_action = parm->action;
+
+	spin_unlock_bh(&v->tcf_lock);
+
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(a);
+	return ret;
+}
+
+static int tcf_vlan_dump(struct sk_buff *skb, struct tc_action *a,
+			 int bind, int ref)
+{
+	unsigned char *b = skb_tail_pointer(skb);
+	struct tcf_vlan *v = a->priv;
+	struct tc_vlan opt = {
+		.index    = v->tcf_index,
+		.refcnt   = v->tcf_refcnt - ref,
+		.bindcnt  = v->tcf_bindcnt - bind,
+		.action   = v->tcf_action,
+		.v_action = v->tcfv_action,
+	};
+	struct tcf_t t;
+
+	if (nla_put(skb, TCA_VLAN_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
+
+	if (v->tcfv_action == TCA_VLAN_ACT_PUSH &&
+	    (nla_put_u16(skb, TCA_VLAN_PUSH_VLAN_ID, v->tcfv_push_vid) ||
+	     nla_put_be16(skb, TCA_VLAN_PUSH_VLAN_PROTOCOL, v->tcfv_push_proto)))
+		goto nla_put_failure;
+
+	t.install = jiffies_to_clock_t(jiffies - v->tcf_tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - v->tcf_tm.lastuse);
+	t.expires = jiffies_to_clock_t(v->tcf_tm.expires);
+	if (nla_put(skb, TCA_VLAN_TM, sizeof(t), &t))
+		goto nla_put_failure;
+	return skb->len;
+
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+static struct tc_action_ops act_vlan_ops = {
+	.kind		=	"vlan",
+	.type		=	TCA_ACT_VLAN,
+	.owner		=	THIS_MODULE,
+	.act		=	tcf_vlan,
+	.dump		=	tcf_vlan_dump,
+	.init		=	tcf_vlan_init,
+};
+
+static int __init vlan_init_module(void)
+{
+	return tcf_register_action(&act_vlan_ops, VLAN_TAB_MASK);
+}
+
+static void __exit vlan_cleanup_module(void)
+{
+	tcf_unregister_action(&act_vlan_ops);
+}
+
+module_init(vlan_init_module);
+module_exit(vlan_cleanup_module);
+
+MODULE_AUTHOR("Jiri Pirko <jiri@resnulli.us>");
+MODULE_DESCRIPTION("vlan manipulation actions");
+MODULE_LICENSE("GPL v2");
-- 
1.9.3
