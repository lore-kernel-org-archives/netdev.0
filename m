From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/1] net: sched: add ipset ematch
Date: Wed, 11 Jul 2012 22:56:57 +0200
Message-ID: <1342040217-5637-1-git-send-email-fw@strlen.de>
Cc: kadlec@blackhole.kfki.hu, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:45303 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030233Ab2GKU6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 16:58:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can be used to match packets against netfilter ip sets created via ipset(8).
skb->sk_iif is used as 'incoming interface', skb->dev is 'outgoing interface'.

Since ipset is usually called from netfilter, the ematch
initializes a fake xt_action_param, pulls the ip header into the
linear area and also sets skb->data to the IP header (otherwise
matching Layer 4 set types doesn't work).

Tested-by: Mr Dash Four <mr.dash.four@googlemail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/pkt_cls.h |    3 +-
 net/sched/Kconfig       |   10 ++++
 net/sched/Makefile      |    1 +
 net/sched/em_ipset.c    |  135 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 148 insertions(+), 1 deletions(-)
 create mode 100644 net/sched/em_ipset.c

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 38fbd4b..082eafa 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -453,7 +453,8 @@ enum {
 #define	TCF_EM_TEXT		5
 #define	TCF_EM_VLAN		6
 #define	TCF_EM_CANID		7
-#define	TCF_EM_MAX		7
+#define	TCF_EM_IPSET		8
+#define	TCF_EM_MAX		8
 
 enum {
 	TCF_EM_PROG_TC
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 4a5d2bd..62fb51f 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -517,6 +517,16 @@ config NET_EMATCH_CANID
 	  To compile this code as a module, choose M here: the
 	  module will be called em_canid.
 
+config NET_EMATCH_IPSET
+	tristate "IPset"
+	depends on NET_EMATCH && IP_SET
+	---help---
+	  Say Y here if you want to be able to classify packets based on
+	  ipset membership.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called em_ipset.
+
 config NET_CLS_ACT
 	bool "Actions"
 	---help---
diff --git a/net/sched/Makefile b/net/sched/Makefile
index bcada75..978cbf0 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -56,3 +56,4 @@ obj-$(CONFIG_NET_EMATCH_U32)	+= em_u32.o
 obj-$(CONFIG_NET_EMATCH_META)	+= em_meta.o
 obj-$(CONFIG_NET_EMATCH_TEXT)	+= em_text.o
 obj-$(CONFIG_NET_EMATCH_CANID)	+= em_canid.o
+obj-$(CONFIG_NET_EMATCH_IPSET)	+= em_ipset.o
diff --git a/net/sched/em_ipset.c b/net/sched/em_ipset.c
new file mode 100644
index 0000000..3130320
--- /dev/null
+++ b/net/sched/em_ipset.c
@@ -0,0 +1,135 @@
+/*
+ * net/sched/em_ipset.c	ipset ematch
+ *
+ * Copyright (c) 2012 Florian Westphal <fw@strlen.de>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ */
+
+#include <linux/gfp.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter/xt_set.h>
+#include <linux/ipv6.h>
+#include <net/ip.h>
+#include <net/pkt_cls.h>
+
+static int em_ipset_change(struct tcf_proto *tp, void *data, int data_len,
+			   struct tcf_ematch *em)
+{
+	struct xt_set_info *set = data;
+	ip_set_id_t index;
+
+	if (data_len != sizeof(*set))
+		return -EINVAL;
+
+	index = ip_set_nfnl_get_byindex(set->index);
+	if (index == IPSET_INVALID_ID)
+		return -ENOENT;
+
+	em->datalen = sizeof(*set);
+	em->data = (unsigned long)kmemdup(data, em->datalen, GFP_KERNEL);
+	if (em->data)
+		return 0;
+
+	ip_set_nfnl_put(index);
+	return -ENOMEM;
+}
+
+static void em_ipset_destroy(struct tcf_proto *p, struct tcf_ematch *em)
+{
+	const struct xt_set_info *set = (const void *) em->data;
+	if (set) {
+		ip_set_nfnl_put(set->index);
+		kfree((void *) em->data);
+	}
+}
+
+static int em_ipset_match(struct sk_buff *skb, struct tcf_ematch *em,
+			  struct tcf_pkt_info *info)
+{
+	struct ip_set_adt_opt opt;
+	struct xt_action_param acpar;
+	const struct xt_set_info *set = (const void *) em->data;
+	struct net_device *dev, *indev = NULL;
+	int ret, network_offset;
+
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		acpar.family = NFPROTO_IPV4;
+		if (!pskb_network_may_pull(skb, sizeof(struct iphdr)))
+			return 0;
+		acpar.thoff = ip_hdrlen(skb);
+		break;
+	case htons(ETH_P_IPV6):
+		acpar.family = NFPROTO_IPV6;
+		if (!pskb_network_may_pull(skb, sizeof(struct ipv6hdr)))
+			return 0;
+		/* doesn't call ipv6_find_hdr() because ipset doesn't use thoff, yet */
+		acpar.thoff = sizeof(struct ipv6hdr);
+		break;
+	default:
+		return 0;
+	}
+
+	acpar.hooknum = 0;
+
+	opt.family = acpar.family;
+	opt.dim = set->dim;
+	opt.flags = set->flags;
+	opt.cmdflags = 0;
+	opt.timeout = ~0u;
+
+	network_offset = skb_network_offset(skb);
+	skb_pull(skb, network_offset);
+
+	dev = skb->dev;
+
+	rcu_read_lock();
+
+	if (dev && skb->skb_iif)
+		indev = dev_get_by_index_rcu(dev_net(dev), skb->skb_iif);
+
+	acpar.in      = indev ? indev : dev;
+	acpar.out     = dev;
+
+	ret = ip_set_test(set->index, skb, &acpar, &opt);
+
+	rcu_read_unlock();
+
+	skb_push(skb, network_offset);
+	return ret;
+}
+
+static struct tcf_ematch_ops em_ipset_ops = {
+	.kind	  = TCF_EM_IPSET,
+	.change	  = em_ipset_change,
+	.destroy  = em_ipset_destroy,
+	.match	  = em_ipset_match,
+	.owner	  = THIS_MODULE,
+	.link	  = LIST_HEAD_INIT(em_ipset_ops.link)
+};
+
+static int __init init_em_ipset(void)
+{
+	return tcf_em_register(&em_ipset_ops);
+}
+
+static void __exit exit_em_ipset(void)
+{
+	tcf_em_unregister(&em_ipset_ops);
+}
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Florian Westphal <fw@strlen.de>");
+MODULE_DESCRIPTION("TC extended match for IP sets");
+
+module_init(init_em_ipset);
+module_exit(exit_em_ipset);
+
+MODULE_ALIAS_TCF_EMATCH(TCF_EM_IPSET);
-- 
1.7.3.4
