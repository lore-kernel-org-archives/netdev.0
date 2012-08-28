From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 11/19] netfilter: ip6tables: add MASQUERADE target
Date: Tue, 28 Aug 2012 23:48:51 +0200
Message-ID: <1346190539-9963-12-git-send-email-kaber@trash.net>
References: <1346190539-9963-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59160 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500Ab2H1VtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 17:49:07 -0400
In-Reply-To: <1346190539-9963-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/addrconf.h               |    2 +-
 include/net/netfilter/nf_nat.h       |    4 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c  |    3 +-
 net/ipv6/addrconf.c                  |    2 +-
 net/ipv6/netfilter/Kconfig           |   12 +++
 net/ipv6/netfilter/Makefile          |    1 +
 net/ipv6/netfilter/ip6t_MASQUERADE.c |  135 ++++++++++++++++++++++++++++++++++
 7 files changed, 155 insertions(+), 4 deletions(-)
 create mode 100644 net/ipv6/netfilter/ip6t_MASQUERADE.c

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 089a09d..9e63e76 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -78,7 +78,7 @@ extern struct inet6_ifaddr      *ipv6_get_ifaddr(struct net *net,
 						 int strict);
 
 extern int			ipv6_dev_get_saddr(struct net *net,
-					       struct net_device *dev,
+					       const struct net_device *dev,
 					       const struct in6_addr *daddr,
 					       unsigned int srcprefs,
 					       struct in6_addr *saddr);
diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index 1752f13..bd8eea7 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -43,7 +43,9 @@ struct nf_conn_nat {
 	struct nf_conn *ct;
 	union nf_conntrack_nat_help help;
 #if defined(CONFIG_IP_NF_TARGET_MASQUERADE) || \
-    defined(CONFIG_IP_NF_TARGET_MASQUERADE_MODULE)
+    defined(CONFIG_IP_NF_TARGET_MASQUERADE_MODULE) || \
+    defined(CONFIG_IP6_NF_TARGET_MASQUERADE) || \
+    defined(CONFIG_IP6_NF_TARGET_MASQUERADE_MODULE)
 	int masq_index;
 #endif
 };
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 1c3aa28..5d5d4d1 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -99,7 +99,8 @@ device_cmp(struct nf_conn *i, void *ifindex)
 
 	if (!nat)
 		return 0;
-
+	if (nf_ct_l3num(i) != NFPROTO_IPV4)
+		return 0;
 	return nat->masq_index == (int)(long)ifindex;
 }
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e581009..19d4bff 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1093,7 +1093,7 @@ out:
 	return ret;
 }
 
-int ipv6_dev_get_saddr(struct net *net, struct net_device *dst_dev,
+int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 		       const struct in6_addr *daddr, unsigned int prefs,
 		       struct in6_addr *saddr)
 {
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index b27e0ad..54a5032 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -144,6 +144,18 @@ config IP6_NF_TARGET_HL
 	(e.g. when running oldconfig). It selects
 	CONFIG_NETFILTER_XT_TARGET_HL.
 
+config IP6_NF_TARGET_MASQUERADE
+	tristate "MASQUERADE target support"
+	depends on NF_NAT_IPV6
+	help
+	  Masquerading is a special case of NAT: all outgoing connections are
+	  changed to seem to come from a particular interface's address, and
+	  if the interface goes down, those connections are lost.  This is
+	  only useful for dialup accounts with dynamic IP address (ie. your IP
+	  address will be different on next dialup).
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config IP6_NF_FILTER
 	tristate "Packet filtering"
 	default m if NETFILTER_ADVANCED=n
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 7677937..068bad1 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -34,4 +34,5 @@ obj-$(CONFIG_IP6_NF_MATCH_RPFILTER) += ip6t_rpfilter.o
 obj-$(CONFIG_IP6_NF_MATCH_RT) += ip6t_rt.o
 
 # targets
+obj-$(CONFIG_IP6_NF_TARGET_MASQUERADE) += ip6t_MASQUERADE.o
 obj-$(CONFIG_IP6_NF_TARGET_REJECT) += ip6t_REJECT.o
diff --git a/net/ipv6/netfilter/ip6t_MASQUERADE.c b/net/ipv6/netfilter/ip6t_MASQUERADE.c
new file mode 100644
index 0000000..60e9053
--- /dev/null
+++ b/net/ipv6/netfilter/ip6t_MASQUERADE.c
@@ -0,0 +1,135 @@
+/*
+ * Copyright (c) 2011 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Based on Rusty Russell's IPv6 MASQUERADE target. Development of IPv6
+ * NAT funded by Astaro.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/ipv6.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6.h>
+#include <linux/netfilter/x_tables.h>
+#include <net/netfilter/nf_nat.h>
+#include <net/addrconf.h>
+#include <net/ipv6.h>
+
+static unsigned int
+masquerade_tg6(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct nf_nat_range *range = par->targinfo;
+	enum ip_conntrack_info ctinfo;
+	struct in6_addr src;
+	struct nf_conn *ct;
+	struct nf_nat_range newrange;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED ||
+			    ctinfo == IP_CT_RELATED_REPLY));
+
+	if (ipv6_dev_get_saddr(dev_net(par->out), par->out,
+			       &ipv6_hdr(skb)->daddr, 0, &src) < 0)
+		return NF_DROP;
+
+	nfct_nat(ct)->masq_index = par->out->ifindex;
+
+	newrange.flags		= range->flags | NF_NAT_RANGE_MAP_IPS;
+	newrange.min_addr.in6	= src;
+	newrange.max_addr.in6	= src;
+	newrange.min_proto	= range->min_proto;
+	newrange.max_proto	= range->max_proto;
+
+	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_SRC);
+}
+
+static int masquerade_tg6_checkentry(const struct xt_tgchk_param *par)
+{
+	const struct nf_nat_range *range = par->targinfo;
+
+	if (range->flags & NF_NAT_RANGE_MAP_IPS)
+		return -EINVAL;
+	return 0;
+}
+
+static int device_cmp(struct nf_conn *ct, void *ifindex)
+{
+	const struct nf_conn_nat *nat = nfct_nat(ct);
+
+	if (!nat)
+		return 0;
+	if (nf_ct_l3num(ct) != NFPROTO_IPV6)
+		return 0;
+	return nat->masq_index == (int)(long)ifindex;
+}
+
+static int masq_device_event(struct notifier_block *this,
+			     unsigned long event, void *ptr)
+{
+	const struct net_device *dev = ptr;
+	struct net *net = dev_net(dev);
+
+	if (event == NETDEV_DOWN)
+		nf_ct_iterate_cleanup(net, device_cmp,
+				      (void *)(long)dev->ifindex);
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block masq_dev_notifier = {
+	.notifier_call	= masq_device_event,
+};
+
+static int masq_inet_event(struct notifier_block *this,
+			   unsigned long event, void *ptr)
+{
+	struct inet6_ifaddr *ifa = ptr;
+
+	return masq_device_event(this, event, ifa->idev->dev);
+}
+
+static struct notifier_block masq_inet_notifier = {
+	.notifier_call	= masq_inet_event,
+};
+
+static struct xt_target masquerade_tg6_reg __read_mostly = {
+	.name		= "MASQUERADE",
+	.family		= NFPROTO_IPV6,
+	.checkentry	= masquerade_tg6_checkentry,
+	.target		= masquerade_tg6,
+	.targetsize	= sizeof(struct nf_nat_range),
+	.table		= "nat",
+	.hooks		= 1 << NF_INET_POST_ROUTING,
+	.me		= THIS_MODULE,
+};
+
+static int __init masquerade_tg6_init(void)
+{
+	int err;
+
+	err = xt_register_target(&masquerade_tg6_reg);
+	if (err == 0) {
+		register_netdevice_notifier(&masq_dev_notifier);
+		register_inet6addr_notifier(&masq_inet_notifier);
+	}
+
+	return err;
+}
+static void __exit masquerade_tg6_exit(void)
+{
+	unregister_inet6addr_notifier(&masq_inet_notifier);
+	unregister_netdevice_notifier(&masq_dev_notifier);
+	xt_unregister_target(&masquerade_tg6_reg);
+}
+
+module_init(masquerade_tg6_init);
+module_exit(masquerade_tg6_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_DESCRIPTION("Xtables: automatic address SNAT");
-- 
1.7.1
