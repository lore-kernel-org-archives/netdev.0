From: kaber@trash.net
Subject: [PATCH 13/17] netfilter: ip6tables: add MASQUERADE target
Date: Mon, 21 Nov 2011 06:46:05 +0100
Message-ID: <1321854369-3432-14-git-send-email-kaber@trash.net>
References: <1321854369-3432-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61109 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474Ab1KUFrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 00:47:49 -0500
In-Reply-To: <1321854369-3432-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/addrconf.h               |    2 +-
 net/ipv6/addrconf.c                  |    2 +-
 net/ipv6/netfilter/Kconfig           |   13 ++++
 net/ipv6/netfilter/Makefile          |    1 +
 net/ipv6/netfilter/ip6t_MASQUERADE.c |  133 ++++++++++++++++++++++++++++++++++
 5 files changed, 149 insertions(+), 2 deletions(-)
 create mode 100644 net/ipv6/netfilter/ip6t_MASQUERADE.c

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 582e4ae..d9166bd 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -77,7 +77,7 @@ extern struct inet6_ifaddr      *ipv6_get_ifaddr(struct net *net,
 						 int strict);
 
 extern int			ipv6_dev_get_saddr(struct net *net,
-					       struct net_device *dev,
+					       const struct net_device *dev,
 					       const struct in6_addr *daddr,
 					       unsigned int srcprefs,
 					       struct in6_addr *saddr);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 12368c5..0eaac50 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1106,7 +1106,7 @@ out:
 	return ret;
 }
 
-int ipv6_dev_get_saddr(struct net *net, struct net_device *dst_dev,
+int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 		       const struct in6_addr *daddr, unsigned int prefs,
 		       struct in6_addr *saddr)
 {
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index ef15839..7215c7f 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -37,6 +37,19 @@ config NF_NAT_IPV6
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP6_NF_TARGET_MASQUERADE
+	tristate "MASQUERADE target support"
+	depends on NF_NAT_IPV6
+	default m if NETFILTER_ADVANCED=n
+	help
+	  Masquerading is a special case of NAT: all outgoing connections are
+	  changed to seem to come from a particular interface's address, and
+	  if the interface goes down, those connections are lost.  This is
+	  only useful for dialup accounts with dynamic IP address (ie. your IP
+	  address will be different on next dialup).
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config IP6_NF_QUEUE
 	tristate "IP6 Userspace queueing via NETLINK (OBSOLETE)"
 	depends on INET && IPV6 && NETFILTER
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index c709dae..4a04c4b 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -35,4 +35,5 @@ obj-$(CONFIG_IP6_NF_MATCH_RT) += ip6t_rt.o
 
 # targets
 obj-$(CONFIG_IP6_NF_TARGET_LOG) += ip6t_LOG.o
+obj-$(CONFIG_IP6_NF_TARGET_MASQUERADE) += ip6t_MASQUERADE.o
 obj-$(CONFIG_IP6_NF_TARGET_REJECT) += ip6t_REJECT.o
diff --git a/net/ipv6/netfilter/ip6t_MASQUERADE.c b/net/ipv6/netfilter/ip6t_MASQUERADE.c
new file mode 100644
index 0000000..321366a
--- /dev/null
+++ b/net/ipv6/netfilter/ip6t_MASQUERADE.c
@@ -0,0 +1,133 @@
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
