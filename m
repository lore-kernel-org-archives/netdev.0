From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 09/41: Combine ipt_ttl and ip6t_hl source
Date: Tue, 24 Mar 2009 15:03:19 +0100 (MET)
Message-ID: <20090324140314.31401.18686.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34743 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758131AbZCXODV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:21 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit cfac5ef7b92a2d504563989ecd0beb563920444b
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Feb 18 18:39:31 2009 +0100

    netfilter: Combine ipt_ttl and ip6t_hl source
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 3ad9f43..40ad41f 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -92,15 +92,6 @@ config IP_NF_MATCH_ECN
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
-config IP_NF_MATCH_TTL
-	tristate '"ttl" match support'
-	depends on NETFILTER_ADVANCED
-	help
-	  This adds CONFIG_IP_NF_MATCH_TTL option, which enabled the user
-	  to match packets by their TTL value.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 # `filter', generic and specific targets
 config IP_NF_FILTER
 	tristate "Packet filtering"
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 20b0c37..4811159 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -51,7 +51,6 @@ obj-$(CONFIG_IP_NF_SECURITY) += iptable_security.o
 obj-$(CONFIG_IP_NF_MATCH_ADDRTYPE) += ipt_addrtype.o
 obj-$(CONFIG_IP_NF_MATCH_AH) += ipt_ah.o
 obj-$(CONFIG_IP_NF_MATCH_ECN) += ipt_ecn.o
-obj-$(CONFIG_IP_NF_MATCH_TTL) += ipt_ttl.o
 
 # targets
 obj-$(CONFIG_IP_NF_TARGET_CLUSTERIP) += ipt_CLUSTERIP.o
diff --git a/net/ipv4/netfilter/ipt_ttl.c b/net/ipv4/netfilter/ipt_ttl.c
deleted file mode 100644
index 297f1cb..0000000
--- a/net/ipv4/netfilter/ipt_ttl.c
+++ /dev/null
@@ -1,63 +0,0 @@
-/* IP tables module for matching the value of the TTL
- *
- * (C) 2000,2001 by Harald Welte <laforge@netfilter.org>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/ip.h>
-#include <linux/module.h>
-#include <linux/skbuff.h>
-
-#include <linux/netfilter_ipv4/ipt_ttl.h>
-#include <linux/netfilter/x_tables.h>
-
-MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
-MODULE_DESCRIPTION("Xtables: IPv4 TTL field match");
-MODULE_LICENSE("GPL");
-
-static bool ttl_mt(const struct sk_buff *skb, const struct xt_match_param *par)
-{
-	const struct ipt_ttl_info *info = par->matchinfo;
-	const u8 ttl = ip_hdr(skb)->ttl;
-
-	switch (info->mode) {
-		case IPT_TTL_EQ:
-			return ttl == info->ttl;
-		case IPT_TTL_NE:
-			return ttl != info->ttl;
-		case IPT_TTL_LT:
-			return ttl < info->ttl;
-		case IPT_TTL_GT:
-			return ttl > info->ttl;
-		default:
-			printk(KERN_WARNING "ipt_ttl: unknown mode %d\n",
-				info->mode);
-			return false;
-	}
-
-	return false;
-}
-
-static struct xt_match ttl_mt_reg __read_mostly = {
-	.name		= "ttl",
-	.family		= NFPROTO_IPV4,
-	.match		= ttl_mt,
-	.matchsize	= sizeof(struct ipt_ttl_info),
-	.me		= THIS_MODULE,
-};
-
-static int __init ttl_mt_init(void)
-{
-	return xt_register_match(&ttl_mt_reg);
-}
-
-static void __exit ttl_mt_exit(void)
-{
-	xt_unregister_match(&ttl_mt_reg);
-}
-
-module_init(ttl_mt_init);
-module_exit(ttl_mt_exit);
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 6a42a96..4a8d7ec 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -94,15 +94,6 @@ config IP6_NF_MATCH_OPTS
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
-config IP6_NF_MATCH_HL
-	tristate '"hl" match support'
-	depends on NETFILTER_ADVANCED
-	help
-	  HL matching allows you to match packets based on the hop
-	  limit of the packet.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP6_NF_MATCH_IPV6HEADER
 	tristate '"ipv6header" IPv6 Extension Headers Match'
 	default m if NETFILTER_ADVANCED=n
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 61a4570..aafbba3 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -20,7 +20,6 @@ obj-$(CONFIG_NF_CONNTRACK_IPV6) += nf_conntrack_ipv6.o
 obj-$(CONFIG_IP6_NF_MATCH_AH) += ip6t_ah.o
 obj-$(CONFIG_IP6_NF_MATCH_EUI64) += ip6t_eui64.o
 obj-$(CONFIG_IP6_NF_MATCH_FRAG) += ip6t_frag.o
-obj-$(CONFIG_IP6_NF_MATCH_HL) += ip6t_hl.o
 obj-$(CONFIG_IP6_NF_MATCH_IPV6HEADER) += ip6t_ipv6header.o
 obj-$(CONFIG_IP6_NF_MATCH_MH) += ip6t_mh.o
 obj-$(CONFIG_IP6_NF_MATCH_OPTS) += ip6t_hbh.o
diff --git a/net/ipv6/netfilter/ip6t_hl.c b/net/ipv6/netfilter/ip6t_hl.c
deleted file mode 100644
index c964dca..0000000
--- a/net/ipv6/netfilter/ip6t_hl.c
+++ /dev/null
@@ -1,68 +0,0 @@
-/* Hop Limit matching module */
-
-/* (C) 2001-2002 Maciej Soltysiak <solt@dns.toxicfilms.tv>
- * Based on HW's ttl module
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/ipv6.h>
-#include <linux/module.h>
-#include <linux/skbuff.h>
-
-#include <linux/netfilter_ipv6/ip6t_hl.h>
-#include <linux/netfilter/x_tables.h>
-
-MODULE_AUTHOR("Maciej Soltysiak <solt@dns.toxicfilms.tv>");
-MODULE_DESCRIPTION("Xtables: IPv6 Hop Limit field match");
-MODULE_LICENSE("GPL");
-
-static bool hl_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
-{
-	const struct ip6t_hl_info *info = par->matchinfo;
-	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
-
-	switch (info->mode) {
-		case IP6T_HL_EQ:
-			return ip6h->hop_limit == info->hop_limit;
-			break;
-		case IP6T_HL_NE:
-			return ip6h->hop_limit != info->hop_limit;
-			break;
-		case IP6T_HL_LT:
-			return ip6h->hop_limit < info->hop_limit;
-			break;
-		case IP6T_HL_GT:
-			return ip6h->hop_limit > info->hop_limit;
-			break;
-		default:
-			printk(KERN_WARNING "ip6t_hl: unknown mode %d\n",
-				info->mode);
-			return false;
-	}
-
-	return false;
-}
-
-static struct xt_match hl_mt6_reg __read_mostly = {
-	.name		= "hl",
-	.family		= NFPROTO_IPV6,
-	.match		= hl_mt6,
-	.matchsize	= sizeof(struct ip6t_hl_info),
-	.me		= THIS_MODULE,
-};
-
-static int __init hl_mt6_init(void)
-{
-	return xt_register_match(&hl_mt6_reg);
-}
-
-static void __exit hl_mt6_exit(void)
-{
-	xt_unregister_match(&hl_mt6_reg);
-}
-
-module_init(hl_mt6_init);
-module_exit(hl_mt6_exit);
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index d99f29b..0eb98b4 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -620,6 +620,14 @@ config NETFILTER_XT_MATCH_HELPER
 
 	  To compile it as a module, choose M here.  If unsure, say Y.
 
+config NETFILTER_XT_MATCH_HL
+	tristate '"hl" hoplimit/TTL match support'
+	depends on NETFILTER_ADVANCED
+	---help---
+	HL matching allows you to match packets based on the hoplimit
+	in the IPv6 header, or the time-to-live field in the IPv4
+	header of the packet.
+
 config NETFILTER_XT_MATCH_IPRANGE
 	tristate '"iprange" address range match support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 6ebe048..da73ed2 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -68,6 +68,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_DSCP) += xt_dscp.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_ESP) += xt_esp.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_HASHLIMIT) += xt_hashlimit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_HELPER) += xt_helper.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_HL) += xt_hl.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_IPRANGE) += xt_iprange.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LENGTH) += xt_length.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LIMIT) += xt_limit.o
diff --git a/net/netfilter/xt_hl.c b/net/netfilter/xt_hl.c
new file mode 100644
index 0000000..7726154
--- /dev/null
+++ b/net/netfilter/xt_hl.c
@@ -0,0 +1,108 @@
+/*
+ * IP tables module for matching the value of the TTL
+ * (C) 2000,2001 by Harald Welte <laforge@netfilter.org>
+ *
+ * Hop Limit matching module
+ * (C) 2001-2002 Maciej Soltysiak <solt@dns.toxicfilms.tv>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter_ipv4/ipt_ttl.h>
+#include <linux/netfilter_ipv6/ip6t_hl.h>
+
+MODULE_AUTHOR("Maciej Soltysiak <solt@dns.toxicfilms.tv>");
+MODULE_DESCRIPTION("Xtables: Hoplimit/TTL field match");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_ttl");
+MODULE_ALIAS("ip6t_hl");
+
+static bool ttl_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+{
+	const struct ipt_ttl_info *info = par->matchinfo;
+	const u8 ttl = ip_hdr(skb)->ttl;
+
+	switch (info->mode) {
+		case IPT_TTL_EQ:
+			return ttl == info->ttl;
+		case IPT_TTL_NE:
+			return ttl != info->ttl;
+		case IPT_TTL_LT:
+			return ttl < info->ttl;
+		case IPT_TTL_GT:
+			return ttl > info->ttl;
+		default:
+			printk(KERN_WARNING "ipt_ttl: unknown mode %d\n",
+				info->mode);
+			return false;
+	}
+
+	return false;
+}
+
+static bool hl_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
+{
+	const struct ip6t_hl_info *info = par->matchinfo;
+	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
+
+	switch (info->mode) {
+		case IP6T_HL_EQ:
+			return ip6h->hop_limit == info->hop_limit;
+			break;
+		case IP6T_HL_NE:
+			return ip6h->hop_limit != info->hop_limit;
+			break;
+		case IP6T_HL_LT:
+			return ip6h->hop_limit < info->hop_limit;
+			break;
+		case IP6T_HL_GT:
+			return ip6h->hop_limit > info->hop_limit;
+			break;
+		default:
+			printk(KERN_WARNING "ip6t_hl: unknown mode %d\n",
+				info->mode);
+			return false;
+	}
+
+	return false;
+}
+
+static struct xt_match hl_mt_reg[] __read_mostly = {
+	{
+		.name       = "ttl",
+		.revision   = 0,
+		.family     = NFPROTO_IPV4,
+		.match      = ttl_mt,
+		.matchsize  = sizeof(struct ipt_ttl_info),
+		.me         = THIS_MODULE,
+	},
+	{
+		.name       = "hl",
+		.revision   = 0,
+		.family     = NFPROTO_IPV6,
+		.match      = hl_mt6,
+		.matchsize  = sizeof(struct ip6t_hl_info),
+		.me         = THIS_MODULE,
+	},
+};
+
+static int __init hl_mt_init(void)
+{
+	return xt_register_matches(hl_mt_reg, ARRAY_SIZE(hl_mt_reg));
+}
+
+static void __exit hl_mt_exit(void)
+{
+	xt_unregister_matches(hl_mt_reg, ARRAY_SIZE(hl_mt_reg));
+}
+
+module_init(hl_mt_init);
+module_exit(hl_mt_exit);
