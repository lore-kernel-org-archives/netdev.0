From: kaber@trash.net
Subject: [PATCH 14/18] netfilter: ip6tables: add MASQUERADE target
Date: Thu, 24 Nov 2011 17:57:25 +0100
Message-ID: <1322153850-10533-15-git-send-email-kaber@trash.net>
References: <1322153850-10533-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47985 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756714Ab1KXQ5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 11:57:39 -0500
In-Reply-To: <1322153850-10533-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/addrconf.h               |    2 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c  |    3 +-
 net/ipv6/addrconf.c                  |    2 +-
 net/ipv6/netfilter/Kconfig           |   13 +++
 net/ipv6/netfilter/Makefile          |    1 +
 net/ipv6/netfilter/ip6t_MASQUERADE.c |  135 ++++++++++++++++++++++++++++++++++
 6 files changed, 153 insertions(+), 3 deletions(-)
 create mode 100644 net/ipv6/netfilter/ip6t_MASQUERADE.c

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index cbc6bb0..291be6c 100644
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
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 1b96b50..9ab96d9 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -98,7 +98,8 @@ device_cmp(struct nf_conn *i, void *ifindex)
 
 	if (!nat)
 		return 0;
-
+	if (nf_ct_l3num(i) != NFPROTO_IPV4)
+		return 0;
 	return nat->masq_index == (int)(long)ifindex;
 }
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cf88df8..619af79 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1107,7 +1107,7 @@ out:
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
