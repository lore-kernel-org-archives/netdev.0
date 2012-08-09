From: kaber@trash.net
Subject: [PATCH 14/19] netfilter: ip6tables: add REDIRECT target
Date: Thu,  9 Aug 2012 22:08:58 +0200
Message-ID: <1344542943-11588-15-git-send-email-kaber@trash.net>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65314 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754557Ab2HIUSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 16:18:37 -0400
In-Reply-To: <1344542943-11588-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter/Kconfig         |   11 ++++
 net/ipv6/netfilter/Makefile        |    1 +
 net/ipv6/netfilter/ip6t_REDIRECT.c |   98 ++++++++++++++++++++++++++++++++++++
 3 files changed, 110 insertions(+), 0 deletions(-)
 create mode 100644 net/ipv6/netfilter/ip6t_REDIRECT.c

diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 54a5032..585590f 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -156,6 +156,17 @@ config IP6_NF_TARGET_MASQUERADE
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP6_NF_TARGET_REDIRECT
+	tristate "REDIRECT target support"
+	depends on NF_NAT_IPV6
+	help
+	  REDIRECT is a special case of NAT: all incoming connections are
+	  mapped onto the incoming interface's address, causing the packets to
+	  come to the local machine instead of passing through.  This is
+	  useful for transparent proxies.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config IP6_NF_FILTER
 	tristate "Packet filtering"
 	default m if NETFILTER_ADVANCED=n
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 068bad1..e30a531 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -35,4 +35,5 @@ obj-$(CONFIG_IP6_NF_MATCH_RT) += ip6t_rt.o
 
 # targets
 obj-$(CONFIG_IP6_NF_TARGET_MASQUERADE) += ip6t_MASQUERADE.o
+obj-$(CONFIG_IP6_NF_TARGET_REDIRECT) += ip6t_REDIRECT.o
 obj-$(CONFIG_IP6_NF_TARGET_REJECT) += ip6t_REJECT.o
diff --git a/net/ipv6/netfilter/ip6t_REDIRECT.c b/net/ipv6/netfilter/ip6t_REDIRECT.c
new file mode 100644
index 0000000..60497a3
--- /dev/null
+++ b/net/ipv6/netfilter/ip6t_REDIRECT.c
@@ -0,0 +1,98 @@
+/*
+ * Copyright (c) 2011 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Based on Rusty Russell's IPv4 REDIRECT target. Development of IPv6
+ * NAT funded by Astaro.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6.h>
+#include <linux/netfilter/x_tables.h>
+#include <net/addrconf.h>
+#include <net/netfilter/nf_nat.h>
+
+static const struct in6_addr loopback_addr = IN6ADDR_LOOPBACK_INIT;
+
+static unsigned int
+redirect_tg6(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct nf_nat_range *range = par->targinfo;
+	struct nf_nat_range newrange;
+	struct in6_addr newdst;
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (par->hooknum == NF_INET_LOCAL_OUT)
+		newdst = loopback_addr;
+	else {
+		struct inet6_dev *idev;
+		struct inet6_ifaddr *ifa;
+		bool addr = false;
+
+		rcu_read_lock();
+		idev = __in6_dev_get(skb->dev);
+		if (idev != NULL) {
+			list_for_each_entry(ifa, &idev->addr_list, if_list) {
+				newdst = ifa->addr;
+				addr = true;
+				break;
+			}
+		}
+		rcu_read_unlock();
+
+		if (!addr)
+			return NF_DROP;
+	}
+
+	newrange.flags		= range->flags | NF_NAT_RANGE_MAP_IPS;
+	newrange.min_addr.in6	= newdst;
+	newrange.max_addr.in6	= newdst;
+	newrange.min_proto	= range->min_proto;
+	newrange.max_proto	= range->max_proto;
+
+	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_DST);
+}
+
+static int redirect_tg6_checkentry(const struct xt_tgchk_param *par)
+{
+	const struct nf_nat_range *range = par->targinfo;
+
+	if (range->flags & NF_NAT_RANGE_MAP_IPS)
+		return -EINVAL;
+	return 0;
+}
+
+static struct xt_target redirect_tg6_reg __read_mostly = {
+	.name		= "REDIRECT",
+	.family		= NFPROTO_IPV6,
+	.checkentry	= redirect_tg6_checkentry,
+	.target		= redirect_tg6,
+	.targetsize	= sizeof(struct nf_nat_range),
+	.table		= "nat",
+	.hooks		= (1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_OUT),
+	.me		= THIS_MODULE,
+};
+
+static int __init redirect_tg6_init(void)
+{
+	return xt_register_target(&redirect_tg6_reg);
+}
+
+static void __exit redirect_tg6_exit(void)
+{
+	xt_unregister_target(&redirect_tg6_reg);
+}
+
+module_init(redirect_tg6_init);
+module_exit(redirect_tg6_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_DESCRIPTION("Xtables: Connection redirection to localhost");
-- 
1.7.1
