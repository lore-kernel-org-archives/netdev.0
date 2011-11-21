From: kaber@trash.net
Subject: [PATCH 15/17] netfilter: ip6tables: add NETMAP target
Date: Mon, 21 Nov 2011 06:46:07 +0100
Message-ID: <1321854369-3432-16-git-send-email-kaber@trash.net>
References: <1321854369-3432-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61169 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745Ab1KUFtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 00:49:16 -0500
In-Reply-To: <1321854369-3432-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter/Kconfig       |   11 ++++
 net/ipv6/netfilter/Makefile      |    1 +
 net/ipv6/netfilter/ip6t_NETMAP.c |   94 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 106 insertions(+), 0 deletions(-)
 create mode 100644 net/ipv6/netfilter/ip6t_NETMAP.c

diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 54c2e78..b14becc 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -50,6 +50,17 @@ config IP6_NF_TARGET_MASQUERADE
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP6_NF_TARGET_NETMAP
+	tristate "NETMAP target support"
+	depends on NF_NAT_IPV6
+	depends on NETFILTER_ADVANCED
+	help
+	  NETMAP is an implementation of static 1:1 NAT mapping of network
+	  addresses. It maps the network address part, while keeping the host
+	  address part intact.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config IP6_NF_TARGET_REDIRECT
 	tristate "REDIRECT target support"
 	depends on NF_NAT_IPV6
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 902c59b..107ab83 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -36,5 +36,6 @@ obj-$(CONFIG_IP6_NF_MATCH_RT) += ip6t_rt.o
 # targets
 obj-$(CONFIG_IP6_NF_TARGET_LOG) += ip6t_LOG.o
 obj-$(CONFIG_IP6_NF_TARGET_MASQUERADE) += ip6t_MASQUERADE.o
+obj-$(CONFIG_IP6_NF_TARGET_NETMAP) += ip6t_NETMAP.o
 obj-$(CONFIG_IP6_NF_TARGET_REDIRECT) += ip6t_REDIRECT.o
 obj-$(CONFIG_IP6_NF_TARGET_REJECT) += ip6t_REJECT.o
diff --git a/net/ipv6/netfilter/ip6t_NETMAP.c b/net/ipv6/netfilter/ip6t_NETMAP.c
new file mode 100644
index 0000000..33c4287
--- /dev/null
+++ b/net/ipv6/netfilter/ip6t_NETMAP.c
@@ -0,0 +1,94 @@
+/*
+ * Copyright (c) 2011 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Based on Svenning Soerensen's IPv4 NETMAP target. Development of IPv6
+ * NAT funded by Astaro.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/ipv6.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6.h>
+#include <linux/netfilter/x_tables.h>
+#include <net/netfilter/nf_nat.h>
+
+static unsigned int
+netmap_tg6(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct nf_nat_range *range = par->targinfo;
+	struct nf_nat_range newrange;
+	struct nf_conn *ct;
+	enum ip_conntrack_info ctinfo;
+	union nf_inet_addr new_addr, netmask;
+	unsigned int i;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	for (i = 0; i < ARRAY_SIZE(range->min_addr.ip6); i++)
+		netmask.ip6[i] = ~(range->min_addr.ip6[i] ^
+				   range->max_addr.ip6[i]);
+
+	if (par->hooknum == NF_INET_PRE_ROUTING ||
+	    par->hooknum == NF_INET_LOCAL_OUT)
+		new_addr.in6 = ipv6_hdr(skb)->daddr;
+	else
+		new_addr.in6 = ipv6_hdr(skb)->saddr;
+
+	for (i = 0; i < ARRAY_SIZE(new_addr.ip6); i++) {
+		new_addr.ip6[i] &= ~netmask.ip6[i];
+		new_addr.ip6[i] |= range->min_addr.ip6[i] &
+				   netmask.ip6[i];
+	}
+
+	newrange.flags	= range->flags | NF_NAT_RANGE_MAP_IPS;
+	newrange.min_addr	= new_addr;
+	newrange.max_addr	= new_addr;
+	newrange.min_proto	= range->min_proto;
+	newrange.max_proto	= range->max_proto;
+
+	return nf_nat_setup_info(ct, &newrange, HOOK2MANIP(par->hooknum));
+}
+
+static int netmap_tg6_checkentry(const struct xt_tgchk_param *par)
+{
+	const struct nf_nat_range *range = par->targinfo;
+
+	if (range->flags & NF_NAT_RANGE_MAP_IPS)
+		return -EINVAL;
+	return 0;
+}
+
+static struct xt_target netmap_tg6_reg __read_mostly = {
+	.name		= "NETMAP",
+	.family		= NFPROTO_IPV6,
+	.target		= netmap_tg6,
+	.targetsize	= sizeof(struct nf_nat_range),
+	.table		= "nat",
+	.hooks		= (1 << NF_INET_PRE_ROUTING) |
+			  (1 << NF_INET_POST_ROUTING) |
+			  (1 << NF_INET_LOCAL_OUT) |
+			  (1 << NF_INET_LOCAL_IN),
+	.checkentry	= netmap_tg6_checkentry,
+	.me		= THIS_MODULE,
+};
+
+static int __init netmap_tg6_init(void)
+{
+	return xt_register_target(&netmap_tg6_reg);
+}
+
+static void netmap_tg6_exit(void)
+{
+	xt_unregister_target(&netmap_tg6_reg);
+}
+
+module_init(netmap_tg6_init);
+module_exit(netmap_tg6_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Xtables: 1:1 NAT mapping of IPv6 subnets");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-- 
1.7.1
