From: pablo@netfilter.org
Subject: [PATCH 05/16] netfilter: combine ipt_REDIRECT and ip6t_REDIRECT
Date: Mon, 24 Sep 2012 21:19:17 +0200
Message-ID: <1348514369-3272-6-git-send-email-pablo@netfilter.org>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58146 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932119Ab2IXTVK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 15:21:10 -0400
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@inai.de>

Combine more modules since the actual code is so small anyway that the
kmod metadata and the module in its loaded state totally outweighs the
combined actual code size.

IP_NF_TARGET_REDIRECT becomes a compat option; IP6_NF_TARGET_REDIRECT
is completely eliminated since it has not see a release yet.

Signed-off-by: Jan Engelhardt <jengelh@inai.de>
Acked-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/Kconfig         |   12 +--
 net/ipv4/netfilter/Makefile        |    1 -
 net/ipv4/netfilter/ipt_REDIRECT.c  |  113 ---------------------
 net/ipv6/netfilter/Kconfig         |   10 --
 net/ipv6/netfilter/Makefile        |    1 -
 net/ipv6/netfilter/ip6t_REDIRECT.c |   98 -------------------
 net/netfilter/Kconfig              |   11 +++
 net/netfilter/Makefile             |    1 +
 net/netfilter/xt_REDIRECT.c        |  190 ++++++++++++++++++++++++++++++++++++
 9 files changed, 207 insertions(+), 230 deletions(-)
 delete mode 100644 net/ipv4/netfilter/ipt_REDIRECT.c
 delete mode 100644 net/ipv6/netfilter/ip6t_REDIRECT.c
 create mode 100644 net/netfilter/xt_REDIRECT.c

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 6f14008..d8d6f2a 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -181,13 +181,11 @@ config IP_NF_TARGET_NETMAP
 config IP_NF_TARGET_REDIRECT
 	tristate "REDIRECT target support"
 	depends on NETFILTER_ADVANCED
-	help
-	  REDIRECT is a special case of NAT: all incoming connections are
-	  mapped onto the incoming interface's address, causing the packets to
-	  come to the local machine instead of passing through.  This is
-	  useful for transparent proxies.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
+	select NETFILTER_XT_TARGET_REDIRECT
+	---help---
+	This is a backwards-compat option for the user's convenience
+	(e.g. when running oldconfig). It selects
+	CONFIG_NETFILTER_XT_TARGET_REDIRECT.
 
 endif
 
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index f4446c5..007b128 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -45,7 +45,6 @@ obj-$(CONFIG_IP_NF_MATCH_RPFILTER) += ipt_rpfilter.o
 obj-$(CONFIG_IP_NF_TARGET_CLUSTERIP) += ipt_CLUSTERIP.o
 obj-$(CONFIG_IP_NF_TARGET_ECN) += ipt_ECN.o
 obj-$(CONFIG_IP_NF_TARGET_MASQUERADE) += ipt_MASQUERADE.o
-obj-$(CONFIG_IP_NF_TARGET_REDIRECT) += ipt_REDIRECT.o
 obj-$(CONFIG_IP_NF_TARGET_REJECT) += ipt_REJECT.o
 obj-$(CONFIG_IP_NF_TARGET_ULOG) += ipt_ULOG.o
 
diff --git a/net/ipv4/netfilter/ipt_REDIRECT.c b/net/ipv4/netfilter/ipt_REDIRECT.c
deleted file mode 100644
index 11407d7..0000000
--- a/net/ipv4/netfilter/ipt_REDIRECT.c
+++ /dev/null
@@ -1,113 +0,0 @@
-/* Redirect.  Simple mapping which alters dst to a local IP address. */
-/* (C) 1999-2001 Paul `Rusty' Russell
- * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
-#include <linux/types.h>
-#include <linux/ip.h>
-#include <linux/timer.h>
-#include <linux/module.h>
-#include <linux/netfilter.h>
-#include <linux/netdevice.h>
-#include <linux/if.h>
-#include <linux/inetdevice.h>
-#include <net/protocol.h>
-#include <net/checksum.h>
-#include <linux/netfilter_ipv4.h>
-#include <linux/netfilter/x_tables.h>
-#include <net/netfilter/nf_nat.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
-MODULE_DESCRIPTION("Xtables: Connection redirection to localhost");
-
-/* FIXME: Take multiple ranges --RR */
-static int redirect_tg_check(const struct xt_tgchk_param *par)
-{
-	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
-
-	if (mr->range[0].flags & NF_NAT_RANGE_MAP_IPS) {
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
-redirect_tg(struct sk_buff *skb, const struct xt_action_param *par)
-{
-	struct nf_conn *ct;
-	enum ip_conntrack_info ctinfo;
-	__be32 newdst;
-	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
-	struct nf_nat_range newrange;
-
-	NF_CT_ASSERT(par->hooknum == NF_INET_PRE_ROUTING ||
-		     par->hooknum == NF_INET_LOCAL_OUT);
-
-	ct = nf_ct_get(skb, &ctinfo);
-	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED));
-
-	/* Local packets: make them go to loopback */
-	if (par->hooknum == NF_INET_LOCAL_OUT)
-		newdst = htonl(0x7F000001);
-	else {
-		struct in_device *indev;
-		struct in_ifaddr *ifa;
-
-		newdst = 0;
-
-		rcu_read_lock();
-		indev = __in_dev_get_rcu(skb->dev);
-		if (indev && (ifa = indev->ifa_list))
-			newdst = ifa->ifa_local;
-		rcu_read_unlock();
-
-		if (!newdst)
-			return NF_DROP;
-	}
-
-	/* Transfer from original range. */
-	memset(&newrange.min_addr, 0, sizeof(newrange.min_addr));
-	memset(&newrange.max_addr, 0, sizeof(newrange.max_addr));
-	newrange.flags	     = mr->range[0].flags | NF_NAT_RANGE_MAP_IPS;
-	newrange.min_addr.ip = newdst;
-	newrange.max_addr.ip = newdst;
-	newrange.min_proto   = mr->range[0].min;
-	newrange.max_proto   = mr->range[0].max;
-
-	/* Hand modified range to generic setup. */
-	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_DST);
-}
-
-static struct xt_target redirect_tg_reg __read_mostly = {
-	.name		= "REDIRECT",
-	.family		= NFPROTO_IPV4,
-	.target		= redirect_tg,
-	.targetsize	= sizeof(struct nf_nat_ipv4_multi_range_compat),
-	.table		= "nat",
-	.hooks		= (1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_OUT),
-	.checkentry	= redirect_tg_check,
-	.me		= THIS_MODULE,
-};
-
-static int __init redirect_tg_init(void)
-{
-	return xt_register_target(&redirect_tg_reg);
-}
-
-static void __exit redirect_tg_exit(void)
-{
-	xt_unregister_target(&redirect_tg_reg);
-}
-
-module_init(redirect_tg_init);
-module_exit(redirect_tg_exit);
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 007bb45..c72532a 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -209,16 +209,6 @@ config IP6_NF_TARGET_MASQUERADE
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
-config IP6_NF_TARGET_REDIRECT
-	tristate "REDIRECT target support"
-	help
-	  REDIRECT is a special case of NAT: all incoming connections are
-	  mapped onto the incoming interface's address, causing the packets to
-	  come to the local machine instead of passing through.  This is
-	  useful for transparent proxies.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP6_NF_TARGET_NPT
 	tristate "NPT (Network Prefix translation) target support"
 	help
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index de8e0d1..2d11fcc 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -36,5 +36,4 @@ obj-$(CONFIG_IP6_NF_MATCH_RT) += ip6t_rt.o
 # targets
 obj-$(CONFIG_IP6_NF_TARGET_MASQUERADE) += ip6t_MASQUERADE.o
 obj-$(CONFIG_IP6_NF_TARGET_NPT) += ip6t_NPT.o
-obj-$(CONFIG_IP6_NF_TARGET_REDIRECT) += ip6t_REDIRECT.o
 obj-$(CONFIG_IP6_NF_TARGET_REJECT) += ip6t_REJECT.o
diff --git a/net/ipv6/netfilter/ip6t_REDIRECT.c b/net/ipv6/netfilter/ip6t_REDIRECT.c
deleted file mode 100644
index 60497a3..0000000
--- a/net/ipv6/netfilter/ip6t_REDIRECT.c
+++ /dev/null
@@ -1,98 +0,0 @@
-/*
- * Copyright (c) 2011 Patrick McHardy <kaber@trash.net>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- * Based on Rusty Russell's IPv4 REDIRECT target. Development of IPv6
- * NAT funded by Astaro.
- */
-
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/netfilter.h>
-#include <linux/netfilter_ipv6.h>
-#include <linux/netfilter/x_tables.h>
-#include <net/addrconf.h>
-#include <net/netfilter/nf_nat.h>
-
-static const struct in6_addr loopback_addr = IN6ADDR_LOOPBACK_INIT;
-
-static unsigned int
-redirect_tg6(struct sk_buff *skb, const struct xt_action_param *par)
-{
-	const struct nf_nat_range *range = par->targinfo;
-	struct nf_nat_range newrange;
-	struct in6_addr newdst;
-	enum ip_conntrack_info ctinfo;
-	struct nf_conn *ct;
-
-	ct = nf_ct_get(skb, &ctinfo);
-	if (par->hooknum == NF_INET_LOCAL_OUT)
-		newdst = loopback_addr;
-	else {
-		struct inet6_dev *idev;
-		struct inet6_ifaddr *ifa;
-		bool addr = false;
-
-		rcu_read_lock();
-		idev = __in6_dev_get(skb->dev);
-		if (idev != NULL) {
-			list_for_each_entry(ifa, &idev->addr_list, if_list) {
-				newdst = ifa->addr;
-				addr = true;
-				break;
-			}
-		}
-		rcu_read_unlock();
-
-		if (!addr)
-			return NF_DROP;
-	}
-
-	newrange.flags		= range->flags | NF_NAT_RANGE_MAP_IPS;
-	newrange.min_addr.in6	= newdst;
-	newrange.max_addr.in6	= newdst;
-	newrange.min_proto	= range->min_proto;
-	newrange.max_proto	= range->max_proto;
-
-	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_DST);
-}
-
-static int redirect_tg6_checkentry(const struct xt_tgchk_param *par)
-{
-	const struct nf_nat_range *range = par->targinfo;
-
-	if (range->flags & NF_NAT_RANGE_MAP_IPS)
-		return -EINVAL;
-	return 0;
-}
-
-static struct xt_target redirect_tg6_reg __read_mostly = {
-	.name		= "REDIRECT",
-	.family		= NFPROTO_IPV6,
-	.checkentry	= redirect_tg6_checkentry,
-	.target		= redirect_tg6,
-	.targetsize	= sizeof(struct nf_nat_range),
-	.table		= "nat",
-	.hooks		= (1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_OUT),
-	.me		= THIS_MODULE,
-};
-
-static int __init redirect_tg6_init(void)
-{
-	return xt_register_target(&redirect_tg6_reg);
-}
-
-static void __exit redirect_tg6_exit(void)
-{
-	xt_unregister_target(&redirect_tg6_reg);
-}
-
-module_init(redirect_tg6_init);
-module_exit(redirect_tg6_exit);
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-MODULE_DESCRIPTION("Xtables: Connection redirection to localhost");
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index ad0e0da..fefa514 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -690,6 +690,17 @@ config NETFILTER_XT_TARGET_RATEEST
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NETFILTER_XT_TARGET_REDIRECT
+	tristate "REDIRECT target support"
+	depends on NF_NAT
+	---help---
+	REDIRECT is a special case of NAT: all incoming connections are
+	mapped onto the incoming interface's address, causing the packets to
+	come to the local machine instead of passing through. This is
+	useful for transparent proxies.
+
+	To compile it as a module, choose M here. If unsure, say N.
+
 config NETFILTER_XT_TARGET_TEE
 	tristate '"TEE" - packet cloning to alternate destination'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 600d28b..3259697 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -87,6 +87,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_NETMAP) += xt_NETMAP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) += xt_NFLOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) += xt_NFQUEUE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_RATEEST) += xt_RATEEST.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_REDIRECT) += xt_REDIRECT.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_SECMARK) += xt_SECMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TPROXY) += xt_TPROXY.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TCPMSS) += xt_TCPMSS.o
diff --git a/net/netfilter/xt_REDIRECT.c b/net/netfilter/xt_REDIRECT.c
new file mode 100644
index 0000000..22a1030
--- /dev/null
+++ b/net/netfilter/xt_REDIRECT.c
@@ -0,0 +1,190 @@
+/*
+ * (C) 1999-2001 Paul `Rusty' Russell
+ * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
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
+#include <linux/if.h>
+#include <linux/inetdevice.h>
+#include <linux/ip.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/netfilter.h>
+#include <linux/types.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_ipv6.h>
+#include <linux/netfilter/x_tables.h>
+#include <net/addrconf.h>
+#include <net/checksum.h>
+#include <net/protocol.h>
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
+/* FIXME: Take multiple ranges --RR */
+static int redirect_tg4_check(const struct xt_tgchk_param *par)
+{
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
+
+	if (mr->range[0].flags & NF_NAT_RANGE_MAP_IPS) {
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
+static unsigned int
+redirect_tg4(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	struct nf_conn *ct;
+	enum ip_conntrack_info ctinfo;
+	__be32 newdst;
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
+	struct nf_nat_range newrange;
+
+	NF_CT_ASSERT(par->hooknum == NF_INET_PRE_ROUTING ||
+		     par->hooknum == NF_INET_LOCAL_OUT);
+
+	ct = nf_ct_get(skb, &ctinfo);
+	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED));
+
+	/* Local packets: make them go to loopback */
+	if (par->hooknum == NF_INET_LOCAL_OUT)
+		newdst = htonl(0x7F000001);
+	else {
+		struct in_device *indev;
+		struct in_ifaddr *ifa;
+
+		newdst = 0;
+
+		rcu_read_lock();
+		indev = __in_dev_get_rcu(skb->dev);
+		if (indev && (ifa = indev->ifa_list))
+			newdst = ifa->ifa_local;
+		rcu_read_unlock();
+
+		if (!newdst)
+			return NF_DROP;
+	}
+
+	/* Transfer from original range. */
+	memset(&newrange.min_addr, 0, sizeof(newrange.min_addr));
+	memset(&newrange.max_addr, 0, sizeof(newrange.max_addr));
+	newrange.flags	     = mr->range[0].flags | NF_NAT_RANGE_MAP_IPS;
+	newrange.min_addr.ip = newdst;
+	newrange.max_addr.ip = newdst;
+	newrange.min_proto   = mr->range[0].min;
+	newrange.max_proto   = mr->range[0].max;
+
+	/* Hand modified range to generic setup. */
+	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_DST);
+}
+
+static struct xt_target redirect_tg_reg[] __read_mostly = {
+	{
+		.name       = "REDIRECT",
+		.family     = NFPROTO_IPV6,
+		.revision   = 0,
+		.table      = "nat",
+		.checkentry = redirect_tg6_checkentry,
+		.target     = redirect_tg6,
+		.targetsize = sizeof(struct nf_nat_range),
+		.hooks      = (1 << NF_INET_PRE_ROUTING) |
+		              (1 << NF_INET_LOCAL_OUT),
+		.me         = THIS_MODULE,
+	},
+	{
+		.name       = "REDIRECT",
+		.family     = NFPROTO_IPV4,
+		.revision   = 0,
+		.table      = "nat",
+		.target     = redirect_tg4,
+		.checkentry = redirect_tg4_check,
+		.targetsize = sizeof(struct nf_nat_ipv4_multi_range_compat),
+		.hooks      = (1 << NF_INET_PRE_ROUTING) |
+		              (1 << NF_INET_LOCAL_OUT),
+		.me         = THIS_MODULE,
+	},
+};
+
+static int __init redirect_tg_init(void)
+{
+	return xt_register_targets(redirect_tg_reg,
+				   ARRAY_SIZE(redirect_tg_reg));
+}
+
+static void __exit redirect_tg_exit(void)
+{
+	xt_unregister_targets(redirect_tg_reg, ARRAY_SIZE(redirect_tg_reg));
+}
+
+module_init(redirect_tg_init);
+module_exit(redirect_tg_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_DESCRIPTION("Xtables: Connection redirection to localhost");
+MODULE_ALIAS("ip6t_REDIRECT");
+MODULE_ALIAS("ipt_REDIRECT");
-- 
1.7.10.4
