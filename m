From: Florian Westphal <fw@strlen.de>
Subject: [RFC PATCH 5/5] netfilter: add ipv6 reverse path filter match
Date: Mon, 12 Sep 2011 21:42:32 +0200
Message-ID: <1315856552-1422-6-git-send-email-fw@strlen.de>
References: <1315856552-1422-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1315856552-1422-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Differs from the ipv4 version:
The oif is not used as input interface, instead this only
tests if the saddr of the packet is reachable via the
interface the packet arrived on.

This is not merged with the ipv4 match into xt_rpfilter.c
to avoid introduce module dependency issues.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/netfilter/Kconfig         |   10 +++
 net/ipv6/netfilter/Makefile        |    1 +
 net/ipv6/netfilter/ip6t_rpfilter.c |  124 ++++++++++++++++++++++++++++++++++++
 3 files changed, 135 insertions(+), 0 deletions(-)
 create mode 100644 net/ipv6/netfilter/ip6t_rpfilter.c

diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 4484648..49ec98b 100644
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
index 0000000..9fe84e4
--- /dev/null
+++ b/net/ipv6/netfilter/ip6t_rpfilter.c
@@ -0,0 +1,124 @@
+/*
+ *  Copyright (c) 2011 Florian Westphal <fw@strlen.de>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2 as
+ *  published by the Free Software Foundation.
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
+                ipv6_addr_copy(&fl6.saddr, &iph->daddr);
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
+
+	if (par->in->flags & IFF_LOOPBACK)
+		return true;
+
+	iph = ipv6_hdr(skb);
+	saddrtype = ipv6_addr_type(&iph->saddr);
+	if (unlikely(saddrtype == IPV6_ADDR_ANY))
+		return true; /* not routable: forward path will drop it */
+
+	return rpfilter_lookup_reverse6(skb, par->in, info->flags);
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
1.7.3.4

