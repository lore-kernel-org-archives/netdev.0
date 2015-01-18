From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH v3 1/1] net: sched: Introduce connmark action
Date: Sun, 18 Jan 2015 16:35:14 -0500
Message-ID: <1421616915-5377-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, nbd@openwrt.org, pablo@netfilter.org,
	fw@strlen.de, jiri@resnulli.us, cwang@twopensource.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:36216 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbbARVhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 16:37:32 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so8855180igb.3
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 13:37:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Fietkau <nbd@openwrt.org>

This tc action allows you to retrieve the connection tracking mark
This action has been used heavily by openwrt for a few years now.

There are known limitations currently:

doesn't work for initial packets, since we only query the ct table.
  Fine given use case is for returning packets

no implicit defrag.
  frags should be rare so fix later..

won't work for more complex tasks, e.g. lookup of other extensions
  since we have no means to store results

we still have a 2nd lookup later on via normal conntrack path.
This shouldn't break anything though since skb->nfct isn't altered.

V2:
remove unnecessary braces (Jiri)
change the action identifier to 14 (Jiri)
Fix some stylistic issues caught by checkpatch
V3:
Move module params to bottom (Cong)
Get rid of tcf_hashinfo_init and friends and conform to newer API (Cong)

Acked-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/tc_act/tc_connmark.h        |   14 +++
 include/uapi/linux/tc_act/tc_connmark.h |   22 ++++
 net/sched/Kconfig                       |   11 ++
 net/sched/Makefile                      |    1 +
 net/sched/act_connmark.c                |  192 +++++++++++++++++++++++++++++++
 5 files changed, 240 insertions(+)
 create mode 100644 include/net/tc_act/tc_connmark.h
 create mode 100644 include/uapi/linux/tc_act/tc_connmark.h
 create mode 100644 net/sched/act_connmark.c

diff --git a/include/net/tc_act/tc_connmark.h b/include/net/tc_act/tc_connmark.h
new file mode 100644
index 0000000..5c1104c
--- /dev/null
+++ b/include/net/tc_act/tc_connmark.h
@@ -0,0 +1,14 @@
+#ifndef __NET_TC_CONNMARK_H
+#define __NET_TC_CONNMARK_H
+
+#include <net/act_api.h>
+
+struct tcf_connmark_info {
+	struct tcf_common common;
+	u16 zone;
+};
+
+#define to_connmark(a) \
+	container_of(a->priv, struct tcf_connmark_info, common)
+
+#endif /* __NET_TC_CONNMARK_H */
diff --git a/include/uapi/linux/tc_act/tc_connmark.h b/include/uapi/linux/tc_act/tc_connmark.h
new file mode 100644
index 0000000..994b097
--- /dev/null
+++ b/include/uapi/linux/tc_act/tc_connmark.h
@@ -0,0 +1,22 @@
+#ifndef __UAPI_TC_CONNMARK_H
+#define __UAPI_TC_CONNMARK_H
+
+#include <linux/types.h>
+#include <linux/pkt_cls.h>
+
+#define TCA_ACT_CONNMARK 14
+
+struct tc_connmark {
+	tc_gen;
+	__u16 zone;
+};
+
+enum {
+	TCA_CONNMARK_UNSPEC,
+	TCA_CONNMARK_PARMS,
+	TCA_CONNMARK_TM,
+	__TCA_CONNMARK_MAX
+};
+#define TCA_CONNMARK_MAX (__TCA_CONNMARK_MAX - 1)
+
+#endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index c54c9d9..db20cae 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -698,6 +698,17 @@ config NET_ACT_VLAN
 	  To compile this code as a module, choose M here: the
 	  module will be called act_vlan.
 
+config NET_ACT_CONNMARK
+        tristate "Netfilter Connection Mark Retriever"
+        depends on NET_CLS_ACT && NETFILTER && IP_NF_IPTABLES
+        ---help---
+	  Say Y here to allow retrieving of conn mark
+
+	  If unsure, say N.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called act_connmark.
+
 config NET_CLS_IND
 	bool "Incoming device classification"
 	depends on NET_CLS_U32 || NET_CLS_FW
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 679f24a..47304cd 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -17,6 +17,7 @@ obj-$(CONFIG_NET_ACT_SIMP)	+= act_simple.o
 obj-$(CONFIG_NET_ACT_SKBEDIT)	+= act_skbedit.o
 obj-$(CONFIG_NET_ACT_CSUM)	+= act_csum.o
 obj-$(CONFIG_NET_ACT_VLAN)	+= act_vlan.o
+obj-$(CONFIG_NET_ACT_CONNMARK)	+= act_connmark.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
new file mode 100644
index 0000000..8e47251
--- /dev/null
+++ b/net/sched/act_connmark.c
@@ -0,0 +1,192 @@
+/*
+ * net/sched/act_connmark.c  netfilter connmark retriever action
+ * skb mark is over-written
+ *
+ * Copyright (c) 2011 Felix Fietkau <nbd@openwrt.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+*/
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <linux/pkt_cls.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+#include <net/act_api.h>
+#include <uapi/linux/tc_act/tc_connmark.h>
+#include <net/tc_act/tc_connmark.h>
+
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_zones.h>
+
+#define CONNMARK_TAB_MASK     3
+
+static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
+			struct tcf_result *res)
+{
+	const struct nf_conntrack_tuple_hash *thash;
+	struct nf_conntrack_tuple tuple;
+	enum ip_conntrack_info ctinfo;
+	struct tcf_connmark_info *ca = a->priv;
+	struct nf_conn *c;
+	int proto;
+
+	spin_lock(&ca->tcf_lock);
+	ca->tcf_tm.lastuse = jiffies;
+	bstats_update(&ca->tcf_bstats, skb);
+
+	if (skb->protocol == htons(ETH_P_IP)) {
+		if (skb->len < sizeof(struct iphdr))
+			goto out;
+
+		proto = NFPROTO_IPV4;
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		if (skb->len < sizeof(struct ipv6hdr))
+			goto out;
+
+		proto = NFPROTO_IPV6;
+	} else {
+		goto out;
+	}
+
+	c = nf_ct_get(skb, &ctinfo);
+	if (c) {
+		skb->mark = c->mark;
+		/* using overlimits stats to count how many packets marked */
+		ca->tcf_qstats.overlimits++;
+		nf_ct_put(c);
+		goto out;
+	}
+
+	if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb),
+			       proto, &tuple))
+		goto out;
+
+	thash = nf_conntrack_find_get(dev_net(skb->dev), ca->zone, &tuple);
+	if (!thash)
+		goto out;
+
+	c = nf_ct_tuplehash_to_ctrack(thash);
+	/* using overlimits stats to count how many packets marked */
+	ca->tcf_qstats.overlimits++;
+	skb->mark = c->mark;
+	nf_ct_put(c);
+
+out:
+	skb->nfct = NULL;
+	spin_unlock(&ca->tcf_lock);
+	return ca->tcf_action;
+}
+
+static const struct nla_policy connmark_policy[TCA_CONNMARK_MAX + 1] = {
+	[TCA_CONNMARK_PARMS] = { .len = sizeof(struct tc_connmark) },
+};
+
+static int tcf_connmark_init(struct net *net, struct nlattr *nla,
+			     struct nlattr *est, struct tc_action *a,
+			     int ovr, int bind)
+{
+	struct nlattr *tb[TCA_CONNMARK_MAX + 1];
+	struct tcf_connmark_info *ci;
+	struct tc_connmark *parm;
+	int ret = 0;
+
+	if (!nla)
+		return -EINVAL;
+
+	ret = nla_parse_nested(tb, TCA_CONNMARK_MAX, nla, connmark_policy);
+	if (ret < 0)
+		return ret;
+
+	parm = nla_data(tb[TCA_CONNMARK_PARMS]);
+
+	if (!tcf_hash_check(parm->index, a, bind)) {
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*ci), bind);
+		if (ret)
+			return ret;
+
+		ci = to_connmark(a);
+		ci->tcf_action = parm->action;
+		ci->zone = parm->zone;
+
+		tcf_hash_insert(a);
+		ret = ACT_P_CREATED;
+	} else {
+		ci = to_connmark(a);
+		if (bind)
+			return 0;
+		tcf_hash_release(a, bind);
+		if (!ovr)
+			return -EEXIST;
+		/* replacing action and zone */
+		ci->tcf_action = parm->action;
+		ci->zone = parm->zone;
+	}
+
+	return ret;
+}
+
+static inline int tcf_connmark_dump(struct sk_buff *skb, struct tc_action *a,
+				    int bind, int ref)
+{
+	unsigned char *b = skb_tail_pointer(skb);
+	struct tcf_connmark_info *ci = a->priv;
+
+	struct tc_connmark opt = {
+		.index   = ci->tcf_index,
+		.refcnt  = ci->tcf_refcnt - ref,
+		.bindcnt = ci->tcf_bindcnt - bind,
+		.action  = ci->tcf_action,
+		.zone   = ci->zone,
+	};
+	struct tcf_t t;
+
+	if (nla_put(skb, TCA_CONNMARK_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
+
+	t.install = jiffies_to_clock_t(jiffies - ci->tcf_tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - ci->tcf_tm.lastuse);
+	t.expires = jiffies_to_clock_t(ci->tcf_tm.expires);
+	if (nla_put(skb, TCA_CONNMARK_TM, sizeof(t), &t))
+		goto nla_put_failure;
+
+	return skb->len;
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+static struct tc_action_ops act_connmark_ops = {
+	.kind		=	"connmark",
+	.type		=	TCA_ACT_CONNMARK,
+	.owner		=	THIS_MODULE,
+	.act		=	tcf_connmark,
+	.dump		=	tcf_connmark_dump,
+	.init		=	tcf_connmark_init,
+};
+
+static int __init connmark_init_module(void)
+{
+	return tcf_register_action(&act_connmark_ops, CONNMARK_TAB_MASK);
+}
+
+static void __exit connmark_cleanup_module(void)
+{
+	tcf_unregister_action(&act_connmark_ops);
+}
+
+module_init(connmark_init_module);
+module_exit(connmark_cleanup_module);
+MODULE_AUTHOR("Felix Fietkau <nbd@openwrt.org>");
+MODULE_DESCRIPTION("Connection tracking mark restoring");
+MODULE_LICENSE("GPL");
+
-- 
1.7.9.5
