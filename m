From: pablo@netfilter.org
Subject: [PATCH 04/19] netfilter: add ipv6 reverse path filter match
Date: Sun, 25 Dec 2011 02:57:20 +0100
Message-ID: <1324778255-2830-5-git-send-email-pablo@netfilter.org>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55983 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756179Ab1LYB54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 20:57:56 -0500
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This is not merged with the ipv4 match into xt_rpfilter.c
to avoid ipv6 module dependency issues.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/Kconfig         |   10 +++
 net/ipv6/netfilter/Makefile        |    1 +
 net/ipv6/netfilter/ip6t_rpfilter.c |  133 ++++++++++++++++++++++++++++++++++++
 3 files changed, 144 insertions(+), 0 deletions(-)
 create mode 100644 net/ipv6/netfilter/ip6t_rpfilter.c

diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index f792b34..9a68fb5 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -125,6 +125,16 @@ config IP6_NF_MATCH_MH
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP6_NF_MATCH_RPFILTER
+	tristate '"rpfilter" reverse path filter match support'
+	depends on NETFILTER_ADVANCED
+	---help---
+	  This option allows you to match packets whose replies would
+	  go out via the interface the packet came in.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+	  The module will be called ip6t_rpfilter.
+
 config IP6_NF_MATCH_RT
 	tristate '"rt" Routing header match support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index abfee91..2eaed96 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -27,6 +27,7 @@ obj-$(CONFIG_IP6_NF_MATCH_FRAG) += ip6t_frag.o
 obj-$(CONFIG_IP6_NF_MATCH_IPV6HEADER) += ip6t_ipv6header.o
 obj-$(CONFIG_IP6_NF_MATCH_MH) += ip6t_mh.o
 obj-$(CONFIG_IP6_NF_MATCH_OPTS) += ip6t_hbh.o
+obj-$(CONFIG_IP6_NF_MATCH_RPFILTER) += ip6t_rpfilter.o
 obj-$(CONFIG_IP6_NF_MATCH_RT) += ip6t_rt.o
 
 # targets
diff --git a/net/ipv6/netfilter/ip6t_rpfilter.c b/net/ipv6/netfilter/ip6t_rpfilter.c
new file mode 100644
index 0000000..5d1d8b0
--- /dev/null
+++ b/net/ipv6/netfilter/ip6t_rpfilter.c
@@ -0,0 +1,133 @@
+/*
+ * Copyright (c) 2011 Florian Westphal <fw@strlen.de>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/route.h>
+#include <net/ip6_fib.h>
+#include <net/ip6_route.h>
+
+#include <linux/netfilter/xt_rpfilter.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Florian Westphal <fw@strlen.de>");
+MODULE_DESCRIPTION("Xtables: IPv6 reverse path filter match");
+
+static bool rpfilter_addr_unicast(const struct in6_addr *addr)
+{
+	int addr_type = ipv6_addr_type(addr);
+	return addr_type & IPV6_ADDR_UNICAST;
+}
+
+static bool rpfilter_lookup_reverse6(const struct sk_buff *skb,
+				     const struct net_device *dev, u8 flags)
+{
+	struct rt6_info *rt;
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	bool ret = false;
+	struct flowi6 fl6 = {
+		.flowlabel = (* (__be32 *) iph) & IPV6_FLOWINFO_MASK,
+		.flowi6_proto = iph->nexthdr,
+		.daddr = iph->saddr,
+	};
+	int lookup_flags;
+
+	if (rpfilter_addr_unicast(&iph->daddr)) {
+		memcpy(&fl6.saddr, &iph->daddr, sizeof(struct in6_addr));
+		lookup_flags = RT6_LOOKUP_F_HAS_SADDR;
+	} else {
+		lookup_flags = 0;
+	}
+
+	fl6.flowi6_mark = flags & XT_RPFILTER_VALID_MARK ? skb->mark : 0;
+	if ((flags & XT_RPFILTER_LOOSE) == 0) {
+		fl6.flowi6_oif = dev->ifindex;
+		lookup_flags |= RT6_LOOKUP_F_IFACE;
+	}
+
+	rt = (void *) ip6_route_lookup(dev_net(dev), &fl6, lookup_flags);
+	if (rt->dst.error)
+		goto out;
+
+	if (rt->rt6i_flags & (RTF_REJECT|RTF_ANYCAST))
+		goto out;
+
+	if (rt->rt6i_flags & RTF_LOCAL) {
+		ret = flags & XT_RPFILTER_ACCEPT_LOCAL;
+		goto out;
+	}
+
+	if (rt->rt6i_idev->dev == dev || (flags & XT_RPFILTER_LOOSE))
+		ret = true;
+ out:
+	dst_release(&rt->dst);
+	return ret;
+}
+
+static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_rpfilter_info *info = par->matchinfo;
+	int saddrtype;
+	struct ipv6hdr *iph;
+	bool invert = info->flags & XT_RPFILTER_INVERT;
+
+	if (par->in->flags & IFF_LOOPBACK)
+		return true ^ invert;
+
+	iph = ipv6_hdr(skb);
+	saddrtype = ipv6_addr_type(&iph->saddr);
+	if (unlikely(saddrtype == IPV6_ADDR_ANY))
+		return true ^ invert; /* not routable: forward path will drop it */
+
+	return rpfilter_lookup_reverse6(skb, par->in, info->flags) ^ invert;
+}
+
+static int rpfilter_check(const struct xt_mtchk_param *par)
+{
+	const struct xt_rpfilter_info *info = par->matchinfo;
+	unsigned int options = ~XT_RPFILTER_OPTION_MASK;
+
+	if (info->flags & options) {
+		pr_info("unknown options encountered");
+		return -EINVAL;
+	}
+
+	if (strcmp(par->table, "mangle") != 0 &&
+	    strcmp(par->table, "raw") != 0) {
+		pr_info("match only valid in the \'raw\' "
+			"or \'mangle\' tables, not \'%s\'.\n", par->table);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static struct xt_match rpfilter_mt_reg __read_mostly = {
+	.name		= "rpfilter",
+	.family		= NFPROTO_IPV6,
+	.checkentry	= rpfilter_check,
+	.match		= rpfilter_mt,
+	.matchsize	= sizeof(struct xt_rpfilter_info),
+	.hooks		= (1 << NF_INET_PRE_ROUTING),
+	.me		= THIS_MODULE
+};
+
+static int __init rpfilter_mt_init(void)
+{
+	return xt_register_match(&rpfilter_mt_reg);
+}
+
+static void __exit rpfilter_mt_exit(void)
+{
+	xt_unregister_match(&rpfilter_mt_reg);
+}
+
+module_init(rpfilter_mt_init);
+module_exit(rpfilter_mt_exit);
-- 
1.7.2.5
