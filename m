From: pablo@netfilter.org
Subject: [PATCH 04/16] netfilter: combine ipt_NETMAP and ip6t_NETMAP
Date: Mon, 24 Sep 2012 21:19:16 +0200
Message-ID: <1348514369-3272-5-git-send-email-pablo@netfilter.org>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@inai.de>

Combine more modules since the actual code is so small anyway that the
kmod metadata and the module in its loaded state totally outweighs the
combined actual code size.

IP_NF_TARGET_NETMAP becomes a compat option; IP6_NF_TARGET_NETMAP
is completely eliminated since it has not see a release yet.

Signed-off-by: Jan Engelhardt <jengelh@inai.de>
Acked-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/Kconfig       |   11 ++-
 net/ipv4/netfilter/Makefile      |    1 -
 net/ipv4/netfilter/ipt_NETMAP.c  |  101 -----------------------
 net/ipv6/netfilter/Kconfig       |    9 ---
 net/ipv6/netfilter/Makefile      |    1 -
 net/ipv6/netfilter/ip6t_NETMAP.c |   94 ----------------------
 net/netfilter/Kconfig            |   10 +++
 net/netfilter/Makefile           |    1 +
 net/netfilter/xt_NETMAP.c        |  165 ++++++++++++++++++++++++++++++++++++++
 9 files changed, 181 insertions(+), 212 deletions(-)
 delete mode 100644 net/ipv4/netfilter/ipt_NETMAP.c
 delete mode 100644 net/ipv6/netfilter/ip6t_NETMAP.c
 create mode 100644 net/netfilter/xt_NETMAP.c

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 131e537..6f14008 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -172,12 +172,11 @@ config IP_NF_TARGET_MASQUERADE
 config IP_NF_TARGET_NETMAP
 	tristate "NETMAP target support"
 	depends on NETFILTER_ADVANCED
-	help
-	  NETMAP is an implementation of static 1:1 NAT mapping of network
-	  addresses. It maps the network address part, while keeping the host
-	  address part intact.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
+	select NETFILTER_XT_TARGET_NETMAP
+	---help---
+	This is a backwards-compat option for the user's convenience
+	(e.g. when running oldconfig). It selects
+	CONFIG_NETFILTER_XT_TARGET_NETMAP.
 
 config IP_NF_TARGET_REDIRECT
 	tristate "REDIRECT target support"
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index b7dd189..f4446c5 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -45,7 +45,6 @@ obj-$(CONFIG_IP_NF_MATCH_RPFILTER) += ipt_rpfilter.o
 obj-$(CONFIG_IP_NF_TARGET_CLUSTERIP) += ipt_CLUSTERIP.o
 obj-$(CONFIG_IP_NF_TARGET_ECN) += ipt_ECN.o
 obj-$(CONFIG_IP_NF_TARGET_MASQUERADE) += ipt_MASQUERADE.o
-obj-$(CONFIG_IP_NF_TARGET_NETMAP) += ipt_NETMAP.o
 obj-$(CONFIG_IP_NF_TARGET_REDIRECT) += ipt_REDIRECT.o
 obj-$(CONFIG_IP_NF_TARGET_REJECT) += ipt_REJECT.o
 obj-$(CONFIG_IP_NF_TARGET_ULOG) += ipt_ULOG.o
diff --git a/net/ipv4/netfilter/ipt_NETMAP.c b/net/ipv4/netfilter/ipt_NETMAP.c
deleted file mode 100644
index 85028dc..0000000
--- a/net/ipv4/netfilter/ipt_NETMAP.c
+++ /dev/null
@@ -1,101 +0,0 @@
-/* NETMAP - static NAT mapping of IP network addresses (1:1).
- * The mapping can be applied to source (POSTROUTING),
- * destination (PREROUTING), or both (with separate rules).
- */
-
-/* (C) 2000-2001 Svenning Soerensen <svenning@post5.tele.dk>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
-#include <linux/ip.h>
-#include <linux/module.h>
-#include <linux/netdevice.h>
-#include <linux/netfilter.h>
-#include <linux/netfilter_ipv4.h>
-#include <linux/netfilter/x_tables.h>
-#include <net/netfilter/nf_nat.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Svenning Soerensen <svenning@post5.tele.dk>");
-MODULE_DESCRIPTION("Xtables: 1:1 NAT mapping of IPv4 subnets");
-
-static int netmap_tg_check(const struct xt_tgchk_param *par)
-{
-	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
-
-	if (!(mr->range[0].flags & NF_NAT_RANGE_MAP_IPS)) {
-		pr_debug("bad MAP_IPS.\n");
-		return -EINVAL;
-	}
-	if (mr->rangesize != 1) {
-		pr_debug("bad rangesize %u.\n", mr->rangesize);
-		return -EINVAL;
-	}
-	return 0;
-}
-
-static unsigned int
-netmap_tg(struct sk_buff *skb, const struct xt_action_param *par)
-{
-	struct nf_conn *ct;
-	enum ip_conntrack_info ctinfo;
-	__be32 new_ip, netmask;
-	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
-	struct nf_nat_range newrange;
-
-	NF_CT_ASSERT(par->hooknum == NF_INET_PRE_ROUTING ||
-		     par->hooknum == NF_INET_POST_ROUTING ||
-		     par->hooknum == NF_INET_LOCAL_OUT ||
-		     par->hooknum == NF_INET_LOCAL_IN);
-	ct = nf_ct_get(skb, &ctinfo);
-
-	netmask = ~(mr->range[0].min_ip ^ mr->range[0].max_ip);
-
-	if (par->hooknum == NF_INET_PRE_ROUTING ||
-	    par->hooknum == NF_INET_LOCAL_OUT)
-		new_ip = ip_hdr(skb)->daddr & ~netmask;
-	else
-		new_ip = ip_hdr(skb)->saddr & ~netmask;
-	new_ip |= mr->range[0].min_ip & netmask;
-
-	memset(&newrange.min_addr, 0, sizeof(newrange.min_addr));
-	memset(&newrange.max_addr, 0, sizeof(newrange.max_addr));
-	newrange.flags	     = mr->range[0].flags | NF_NAT_RANGE_MAP_IPS;
-	newrange.min_addr.ip = new_ip;
-	newrange.max_addr.ip = new_ip;
-	newrange.min_proto   = mr->range[0].min;
-	newrange.max_proto   = mr->range[0].max;
-
-	/* Hand modified range to generic setup. */
-	return nf_nat_setup_info(ct, &newrange, HOOK2MANIP(par->hooknum));
-}
-
-static struct xt_target netmap_tg_reg __read_mostly = {
-	.name 		= "NETMAP",
-	.family		= NFPROTO_IPV4,
-	.target 	= netmap_tg,
-	.targetsize	= sizeof(struct nf_nat_ipv4_multi_range_compat),
-	.table		= "nat",
-	.hooks		= (1 << NF_INET_PRE_ROUTING) |
-			  (1 << NF_INET_POST_ROUTING) |
-			  (1 << NF_INET_LOCAL_OUT) |
-			  (1 << NF_INET_LOCAL_IN),
-	.checkentry 	= netmap_tg_check,
-	.me 		= THIS_MODULE
-};
-
-static int __init netmap_tg_init(void)
-{
-	return xt_register_target(&netmap_tg_reg);
-}
-
-static void __exit netmap_tg_exit(void)
-{
-	xt_unregister_target(&netmap_tg_reg);
-}
-
-module_init(netmap_tg_init);
-module_exit(netmap_tg_exit);
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index d8f276b..007bb45 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -209,15 +209,6 @@ config IP6_NF_TARGET_MASQUERADE
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
-config IP6_NF_TARGET_NETMAP
-	tristate "NETMAP target support"
-	help
-	  NETMAP is an implementation of static 1:1 NAT mapping of network
-	  addresses. It maps the network address part, while keeping the host
-	  address part intact.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP6_NF_TARGET_REDIRECT
 	tristate "REDIRECT target support"
 	help
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 5752132..de8e0d1 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -35,7 +35,6 @@ obj-$(CONFIG_IP6_NF_MATCH_RT) += ip6t_rt.o
 
 # targets
 obj-$(CONFIG_IP6_NF_TARGET_MASQUERADE) += ip6t_MASQUERADE.o
-obj-$(CONFIG_IP6_NF_TARGET_NETMAP) += ip6t_NETMAP.o
 obj-$(CONFIG_IP6_NF_TARGET_NPT) += ip6t_NPT.o
 obj-$(CONFIG_IP6_NF_TARGET_REDIRECT) += ip6t_REDIRECT.o
 obj-$(CONFIG_IP6_NF_TARGET_REJECT) += ip6t_REJECT.o
diff --git a/net/ipv6/netfilter/ip6t_NETMAP.c b/net/ipv6/netfilter/ip6t_NETMAP.c
deleted file mode 100644
index 4f3bf36..0000000
--- a/net/ipv6/netfilter/ip6t_NETMAP.c
+++ /dev/null
@@ -1,94 +0,0 @@
-/*
- * Copyright (c) 2011 Patrick McHardy <kaber@trash.net>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- * Based on Svenning Soerensen's IPv4 NETMAP target. Development of IPv6
- * NAT funded by Astaro.
- */
-
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/ipv6.h>
-#include <linux/netfilter.h>
-#include <linux/netfilter_ipv6.h>
-#include <linux/netfilter/x_tables.h>
-#include <net/netfilter/nf_nat.h>
-
-static unsigned int
-netmap_tg6(struct sk_buff *skb, const struct xt_action_param *par)
-{
-	const struct nf_nat_range *range = par->targinfo;
-	struct nf_nat_range newrange;
-	struct nf_conn *ct;
-	enum ip_conntrack_info ctinfo;
-	union nf_inet_addr new_addr, netmask;
-	unsigned int i;
-
-	ct = nf_ct_get(skb, &ctinfo);
-	for (i = 0; i < ARRAY_SIZE(range->min_addr.ip6); i++)
-		netmask.ip6[i] = ~(range->min_addr.ip6[i] ^
-				   range->max_addr.ip6[i]);
-
-	if (par->hooknum == NF_INET_PRE_ROUTING ||
-	    par->hooknum == NF_INET_LOCAL_OUT)
-		new_addr.in6 = ipv6_hdr(skb)->daddr;
-	else
-		new_addr.in6 = ipv6_hdr(skb)->saddr;
-
-	for (i = 0; i < ARRAY_SIZE(new_addr.ip6); i++) {
-		new_addr.ip6[i] &= ~netmask.ip6[i];
-		new_addr.ip6[i] |= range->min_addr.ip6[i] &
-				   netmask.ip6[i];
-	}
-
-	newrange.flags	= range->flags | NF_NAT_RANGE_MAP_IPS;
-	newrange.min_addr	= new_addr;
-	newrange.max_addr	= new_addr;
-	newrange.min_proto	= range->min_proto;
-	newrange.max_proto	= range->max_proto;
-
-	return nf_nat_setup_info(ct, &newrange, HOOK2MANIP(par->hooknum));
-}
-
-static int netmap_tg6_checkentry(const struct xt_tgchk_param *par)
-{
-	const struct nf_nat_range *range = par->targinfo;
-
-	if (!(range->flags & NF_NAT_RANGE_MAP_IPS))
-		return -EINVAL;
-	return 0;
-}
-
-static struct xt_target netmap_tg6_reg __read_mostly = {
-	.name		= "NETMAP",
-	.family		= NFPROTO_IPV6,
-	.target		= netmap_tg6,
-	.targetsize	= sizeof(struct nf_nat_range),
-	.table		= "nat",
-	.hooks		= (1 << NF_INET_PRE_ROUTING) |
-			  (1 << NF_INET_POST_ROUTING) |
-			  (1 << NF_INET_LOCAL_OUT) |
-			  (1 << NF_INET_LOCAL_IN),
-	.checkentry	= netmap_tg6_checkentry,
-	.me		= THIS_MODULE,
-};
-
-static int __init netmap_tg6_init(void)
-{
-	return xt_register_target(&netmap_tg6_reg);
-}
-
-static void netmap_tg6_exit(void)
-{
-	xt_unregister_target(&netmap_tg6_reg);
-}
-
-module_init(netmap_tg6_init);
-module_exit(netmap_tg6_exit);
-
-MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("Xtables: 1:1 NAT mapping of IPv6 subnets");
-MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 3f4b3b4..ad0e0da 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -648,6 +648,16 @@ config NETFILTER_XT_TARGET_MARK
 	(e.g. when running oldconfig). It selects
 	CONFIG_NETFILTER_XT_MARK (combined mark/MARK module).
 
+config NETFILTER_XT_TARGET_NETMAP
+	tristate '"NETMAP" target support'
+	depends on NF_NAT
+	---help---
+	NETMAP is an implementation of static 1:1 NAT mapping of network
+	addresses. It maps the network address part, while keeping the host
+	address part intact.
+
+	To compile it as a module, choose M here. If unsure, say N.
+
 config NETFILTER_XT_TARGET_NFLOG
 	tristate '"NFLOG" target support'
 	default m if NETFILTER_ADVANCED=n
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 0baa3f1..600d28b 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -83,6 +83,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_HL) += xt_HL.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_HMARK) += xt_HMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_LED) += xt_LED.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_LOG) += xt_LOG.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_NETMAP) += xt_NETMAP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) += xt_NFLOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) += xt_NFQUEUE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_RATEEST) += xt_RATEEST.o
diff --git a/net/netfilter/xt_NETMAP.c b/net/netfilter/xt_NETMAP.c
new file mode 100644
index 0000000..b253e07
--- /dev/null
+++ b/net/netfilter/xt_NETMAP.c
@@ -0,0 +1,165 @@
+/*
+ * (C) 2000-2001 Svenning Soerensen <svenning@post5.tele.dk>
+ * Copyright (c) 2011 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/ip.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/ipv6.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
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
+	if (!(range->flags & NF_NAT_RANGE_MAP_IPS))
+		return -EINVAL;
+	return 0;
+}
+
+static unsigned int
+netmap_tg4(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	struct nf_conn *ct;
+	enum ip_conntrack_info ctinfo;
+	__be32 new_ip, netmask;
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
+	struct nf_nat_range newrange;
+
+	NF_CT_ASSERT(par->hooknum == NF_INET_PRE_ROUTING ||
+		     par->hooknum == NF_INET_POST_ROUTING ||
+		     par->hooknum == NF_INET_LOCAL_OUT ||
+		     par->hooknum == NF_INET_LOCAL_IN);
+	ct = nf_ct_get(skb, &ctinfo);
+
+	netmask = ~(mr->range[0].min_ip ^ mr->range[0].max_ip);
+
+	if (par->hooknum == NF_INET_PRE_ROUTING ||
+	    par->hooknum == NF_INET_LOCAL_OUT)
+		new_ip = ip_hdr(skb)->daddr & ~netmask;
+	else
+		new_ip = ip_hdr(skb)->saddr & ~netmask;
+	new_ip |= mr->range[0].min_ip & netmask;
+
+	memset(&newrange.min_addr, 0, sizeof(newrange.min_addr));
+	memset(&newrange.max_addr, 0, sizeof(newrange.max_addr));
+	newrange.flags	     = mr->range[0].flags | NF_NAT_RANGE_MAP_IPS;
+	newrange.min_addr.ip = new_ip;
+	newrange.max_addr.ip = new_ip;
+	newrange.min_proto   = mr->range[0].min;
+	newrange.max_proto   = mr->range[0].max;
+
+	/* Hand modified range to generic setup. */
+	return nf_nat_setup_info(ct, &newrange, HOOK2MANIP(par->hooknum));
+}
+
+static int netmap_tg4_check(const struct xt_tgchk_param *par)
+{
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
+
+	if (!(mr->range[0].flags & NF_NAT_RANGE_MAP_IPS)) {
+		pr_debug("bad MAP_IPS.\n");
+		return -EINVAL;
+	}
+	if (mr->rangesize != 1) {
+		pr_debug("bad rangesize %u.\n", mr->rangesize);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static struct xt_target netmap_tg_reg[] __read_mostly = {
+	{
+		.name       = "NETMAP",
+		.family     = NFPROTO_IPV6,
+		.revision   = 0,
+		.target     = netmap_tg6,
+		.targetsize = sizeof(struct nf_nat_range),
+		.table      = "nat",
+		.hooks      = (1 << NF_INET_PRE_ROUTING) |
+		              (1 << NF_INET_POST_ROUTING) |
+		              (1 << NF_INET_LOCAL_OUT) |
+		              (1 << NF_INET_LOCAL_IN),
+		.checkentry = netmap_tg6_checkentry,
+		.me         = THIS_MODULE,
+	},
+	{
+		.name       = "NETMAP",
+		.family     = NFPROTO_IPV4,
+		.revision   = 0,
+		.target     = netmap_tg4,
+		.targetsize = sizeof(struct nf_nat_ipv4_multi_range_compat),
+		.table      = "nat",
+		.hooks      = (1 << NF_INET_PRE_ROUTING) |
+		              (1 << NF_INET_POST_ROUTING) |
+		              (1 << NF_INET_LOCAL_OUT) |
+		              (1 << NF_INET_LOCAL_IN),
+		.checkentry = netmap_tg4_check,
+		.me         = THIS_MODULE,
+	},
+};
+
+static int __init netmap_tg_init(void)
+{
+	return xt_register_targets(netmap_tg_reg, ARRAY_SIZE(netmap_tg_reg));
+}
+
+static void netmap_tg_exit(void)
+{
+	xt_unregister_targets(netmap_tg_reg, ARRAY_SIZE(netmap_tg_reg));
+}
+
+module_init(netmap_tg_init);
+module_exit(netmap_tg_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Xtables: 1:1 NAT mapping of subnets");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_ALIAS("ip6t_NETMAP");
+MODULE_ALIAS("ipt_NETMAP");
-- 
1.7.10.4

