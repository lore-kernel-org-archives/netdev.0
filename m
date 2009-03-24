From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 08/41: Combine ipt_TTL and ip6t_HL source
Date: Tue, 24 Mar 2009 15:03:17 +0100 (MET)
Message-ID: <20090324140313.31401.53692.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34741 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756975AbZCXODT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:19 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 563d36eb3fb22dd04da9aa6f12e1b9ba0ac115f3
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Feb 18 18:38:40 2009 +0100

    netfilter: Combine ipt_TTL and ip6t_HL source
    
    Suggested by: James King <t.james.king@gmail.com>
    
    Similarly to commit c9fd49680954714473d6cbd2546d6ff120f96840, merge
    TTL and HL. Since HL does not depend on any IPv6-specific function,
    no new module dependencies would arise.
    
    With slight adjustments to the Kconfig help text.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 3816e1d..3ad9f43 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -322,21 +322,6 @@ config IP_NF_TARGET_ECN
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
-config IP_NF_TARGET_TTL
-	tristate  'TTL target support'
-	depends on IP_NF_MANGLE
-	depends on NETFILTER_ADVANCED
-	help
-	  This option adds a `TTL' target, which enables the user to modify
-	  the TTL value of the IP header.
-
-	  While it is safe to decrement/lower the TTL, this target also enables
-	  functionality to increment and set the TTL value of the IP header to
-	  arbitrary values.  This is EXTREMELY DANGEROUS since you can easily
-	  create immortal packets that loop forever on the network.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 # raw + specific targets
 config IP_NF_RAW
 	tristate  'raw table support (required for NOTRACK/TRACE)'
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 5f9b650..20b0c37 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -61,7 +61,6 @@ obj-$(CONFIG_IP_NF_TARGET_MASQUERADE) += ipt_MASQUERADE.o
 obj-$(CONFIG_IP_NF_TARGET_NETMAP) += ipt_NETMAP.o
 obj-$(CONFIG_IP_NF_TARGET_REDIRECT) += ipt_REDIRECT.o
 obj-$(CONFIG_IP_NF_TARGET_REJECT) += ipt_REJECT.o
-obj-$(CONFIG_IP_NF_TARGET_TTL) += ipt_TTL.o
 obj-$(CONFIG_IP_NF_TARGET_ULOG) += ipt_ULOG.o
 
 # generic ARP tables
diff --git a/net/ipv4/netfilter/ipt_TTL.c b/net/ipv4/netfilter/ipt_TTL.c
deleted file mode 100644
index 6d76aae..0000000
--- a/net/ipv4/netfilter/ipt_TTL.c
+++ /dev/null
@@ -1,97 +0,0 @@
-/* TTL modification target for IP tables
- * (C) 2000,2005 by Harald Welte <laforge@netfilter.org>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/ip.h>
-#include <net/checksum.h>
-
-#include <linux/netfilter/x_tables.h>
-#include <linux/netfilter_ipv4/ipt_TTL.h>
-
-MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
-MODULE_DESCRIPTION("Xtables: IPv4 TTL field modification target");
-MODULE_LICENSE("GPL");
-
-static unsigned int
-ttl_tg(struct sk_buff *skb, const struct xt_target_param *par)
-{
-	struct iphdr *iph;
-	const struct ipt_TTL_info *info = par->targinfo;
-	int new_ttl;
-
-	if (!skb_make_writable(skb, skb->len))
-		return NF_DROP;
-
-	iph = ip_hdr(skb);
-
-	switch (info->mode) {
-		case IPT_TTL_SET:
-			new_ttl = info->ttl;
-			break;
-		case IPT_TTL_INC:
-			new_ttl = iph->ttl + info->ttl;
-			if (new_ttl > 255)
-				new_ttl = 255;
-			break;
-		case IPT_TTL_DEC:
-			new_ttl = iph->ttl - info->ttl;
-			if (new_ttl < 0)
-				new_ttl = 0;
-			break;
-		default:
-			new_ttl = iph->ttl;
-			break;
-	}
-
-	if (new_ttl != iph->ttl) {
-		csum_replace2(&iph->check, htons(iph->ttl << 8),
-					   htons(new_ttl << 8));
-		iph->ttl = new_ttl;
-	}
-
-	return XT_CONTINUE;
-}
-
-static bool ttl_tg_check(const struct xt_tgchk_param *par)
-{
-	const struct ipt_TTL_info *info = par->targinfo;
-
-	if (info->mode > IPT_TTL_MAXMODE) {
-		printk(KERN_WARNING "ipt_TTL: invalid or unknown Mode %u\n",
-			info->mode);
-		return false;
-	}
-	if (info->mode != IPT_TTL_SET && info->ttl == 0)
-		return false;
-	return true;
-}
-
-static struct xt_target ttl_tg_reg __read_mostly = {
-	.name 		= "TTL",
-	.family		= NFPROTO_IPV4,
-	.target 	= ttl_tg,
-	.targetsize	= sizeof(struct ipt_TTL_info),
-	.table		= "mangle",
-	.checkentry 	= ttl_tg_check,
-	.me 		= THIS_MODULE,
-};
-
-static int __init ttl_tg_init(void)
-{
-	return xt_register_target(&ttl_tg_reg);
-}
-
-static void __exit ttl_tg_exit(void)
-{
-	xt_unregister_target(&ttl_tg_reg);
-}
-
-module_init(ttl_tg_init);
-module_exit(ttl_tg_exit);
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 53ea512..6a42a96 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -170,23 +170,6 @@ config IP6_NF_MANGLE
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
-config IP6_NF_TARGET_HL
-	tristate  'HL (hoplimit) target support'
-	depends on IP6_NF_MANGLE
-	depends on NETFILTER_ADVANCED
-	help
-	  This option adds a `HL' target, which enables the user to decrement
-	  the hoplimit value of the IPv6 header or set it to a given (lower)
-	  value.
-
-	  While it is safe to decrement the hoplimit value, this option also
-	  enables functionality to increment and set the hoplimit value of the
-	  IPv6 header to arbitrary values.  This is EXTREMELY DANGEROUS since
-	  you can easily create immortal packets that loop forever on the
-	  network.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP6_NF_RAW
 	tristate  'raw table support (required for TRACE)'
 	depends on NETFILTER_ADVANCED
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 3f17c94..61a4570 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -27,6 +27,5 @@ obj-$(CONFIG_IP6_NF_MATCH_OPTS) += ip6t_hbh.o
 obj-$(CONFIG_IP6_NF_MATCH_RT) += ip6t_rt.o
 
 # targets
-obj-$(CONFIG_IP6_NF_TARGET_HL) += ip6t_HL.o
 obj-$(CONFIG_IP6_NF_TARGET_LOG) += ip6t_LOG.o
 obj-$(CONFIG_IP6_NF_TARGET_REJECT) += ip6t_REJECT.o
diff --git a/net/ipv6/netfilter/ip6t_HL.c b/net/ipv6/netfilter/ip6t_HL.c
deleted file mode 100644
index 27b5adf..0000000
--- a/net/ipv6/netfilter/ip6t_HL.c
+++ /dev/null
@@ -1,95 +0,0 @@
-/*
- * Hop Limit modification target for ip6tables
- * Maciej Soltysiak <solt@dns.toxicfilms.tv>
- * Based on HW's TTL module
- *
- * This software is distributed under the terms of GNU GPL
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/ip.h>
-#include <linux/ipv6.h>
-
-#include <linux/netfilter/x_tables.h>
-#include <linux/netfilter_ipv6/ip6t_HL.h>
-
-MODULE_AUTHOR("Maciej Soltysiak <solt@dns.toxicfilms.tv>");
-MODULE_DESCRIPTION("Xtables: IPv6 Hop Limit field modification target");
-MODULE_LICENSE("GPL");
-
-static unsigned int
-hl_tg6(struct sk_buff *skb, const struct xt_target_param *par)
-{
-	struct ipv6hdr *ip6h;
-	const struct ip6t_HL_info *info = par->targinfo;
-	int new_hl;
-
-	if (!skb_make_writable(skb, skb->len))
-		return NF_DROP;
-
-	ip6h = ipv6_hdr(skb);
-
-	switch (info->mode) {
-		case IP6T_HL_SET:
-			new_hl = info->hop_limit;
-			break;
-		case IP6T_HL_INC:
-			new_hl = ip6h->hop_limit + info->hop_limit;
-			if (new_hl > 255)
-				new_hl = 255;
-			break;
-		case IP6T_HL_DEC:
-			new_hl = ip6h->hop_limit - info->hop_limit;
-			if (new_hl < 0)
-				new_hl = 0;
-			break;
-		default:
-			new_hl = ip6h->hop_limit;
-			break;
-	}
-
-	ip6h->hop_limit = new_hl;
-
-	return XT_CONTINUE;
-}
-
-static bool hl_tg6_check(const struct xt_tgchk_param *par)
-{
-	const struct ip6t_HL_info *info = par->targinfo;
-
-	if (info->mode > IP6T_HL_MAXMODE) {
-		printk(KERN_WARNING "ip6t_HL: invalid or unknown Mode %u\n",
-			info->mode);
-		return false;
-	}
-	if (info->mode != IP6T_HL_SET && info->hop_limit == 0) {
-		printk(KERN_WARNING "ip6t_HL: increment/decrement doesn't "
-			"make sense with value 0\n");
-		return false;
-	}
-	return true;
-}
-
-static struct xt_target hl_tg6_reg __read_mostly = {
-	.name 		= "HL",
-	.family		= NFPROTO_IPV6,
-	.target		= hl_tg6,
-	.targetsize	= sizeof(struct ip6t_HL_info),
-	.table		= "mangle",
-	.checkentry	= hl_tg6_check,
-	.me		= THIS_MODULE
-};
-
-static int __init hl_tg6_init(void)
-{
-	return xt_register_target(&hl_tg6_reg);
-}
-
-static void __exit hl_tg6_exit(void)
-{
-	xt_unregister_target(&hl_tg6_reg);
-}
-
-module_init(hl_tg6_init);
-module_exit(hl_tg6_exit);
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index c2bac9c..d99f29b 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -357,6 +357,21 @@ config NETFILTER_XT_TARGET_DSCP
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NETFILTER_XT_TARGET_HL
+	tristate '"HL" hoplimit target support'
+	depends on IP_NF_MANGLE || IP6_NF_MANGLE
+	depends on NETFILTER_ADVANCED
+	---help---
+	This option adds the "HL" (for IPv6) and "TTL" (for IPv4)
+	targets, which enable the user to change the
+	hoplimit/time-to-live value of the IP header.
+
+	While it is safe to decrement the hoplimit/TTL value, the
+	modules also allow to increment and set the hoplimit value of
+	the header to arbitrary values. This is EXTREMELY DANGEROUS
+	since you can easily create immortal packets that loop
+	forever on the network.
+
 config NETFILTER_XT_TARGET_MARK
 	tristate '"MARK" target support'
 	default m if NETFILTER_ADVANCED=n
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index da3d909..6ebe048 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -45,6 +45,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_CLASSIFY) += xt_CLASSIFY.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CONNMARK) += xt_CONNMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_DSCP) += xt_DSCP.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_HL) += xt_HL.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_MARK) += xt_MARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) += xt_NFLOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) += xt_NFQUEUE.o
diff --git a/net/netfilter/xt_HL.c b/net/netfilter/xt_HL.c
new file mode 100644
index 0000000..10e789e
--- /dev/null
+++ b/net/netfilter/xt_HL.c
@@ -0,0 +1,171 @@
+/*
+ * TTL modification target for IP tables
+ * (C) 2000,2005 by Harald Welte <laforge@netfilter.org>
+ *
+ * Hop Limit modification target for ip6tables
+ * Maciej Soltysiak <solt@dns.toxicfilms.tv>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <net/checksum.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter_ipv4/ipt_TTL.h>
+#include <linux/netfilter_ipv6/ip6t_HL.h>
+
+MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
+MODULE_AUTHOR("Maciej Soltysiak <solt@dns.toxicfilms.tv>");
+MODULE_DESCRIPTION("Xtables: Hoplimit/TTL Limit field modification target");
+MODULE_LICENSE("GPL");
+
+static unsigned int
+ttl_tg(struct sk_buff *skb, const struct xt_target_param *par)
+{
+	struct iphdr *iph;
+	const struct ipt_TTL_info *info = par->targinfo;
+	int new_ttl;
+
+	if (!skb_make_writable(skb, skb->len))
+		return NF_DROP;
+
+	iph = ip_hdr(skb);
+
+	switch (info->mode) {
+		case IPT_TTL_SET:
+			new_ttl = info->ttl;
+			break;
+		case IPT_TTL_INC:
+			new_ttl = iph->ttl + info->ttl;
+			if (new_ttl > 255)
+				new_ttl = 255;
+			break;
+		case IPT_TTL_DEC:
+			new_ttl = iph->ttl - info->ttl;
+			if (new_ttl < 0)
+				new_ttl = 0;
+			break;
+		default:
+			new_ttl = iph->ttl;
+			break;
+	}
+
+	if (new_ttl != iph->ttl) {
+		csum_replace2(&iph->check, htons(iph->ttl << 8),
+					   htons(new_ttl << 8));
+		iph->ttl = new_ttl;
+	}
+
+	return XT_CONTINUE;
+}
+
+static unsigned int
+hl_tg6(struct sk_buff *skb, const struct xt_target_param *par)
+{
+	struct ipv6hdr *ip6h;
+	const struct ip6t_HL_info *info = par->targinfo;
+	int new_hl;
+
+	if (!skb_make_writable(skb, skb->len))
+		return NF_DROP;
+
+	ip6h = ipv6_hdr(skb);
+
+	switch (info->mode) {
+		case IP6T_HL_SET:
+			new_hl = info->hop_limit;
+			break;
+		case IP6T_HL_INC:
+			new_hl = ip6h->hop_limit + info->hop_limit;
+			if (new_hl > 255)
+				new_hl = 255;
+			break;
+		case IP6T_HL_DEC:
+			new_hl = ip6h->hop_limit - info->hop_limit;
+			if (new_hl < 0)
+				new_hl = 0;
+			break;
+		default:
+			new_hl = ip6h->hop_limit;
+			break;
+	}
+
+	ip6h->hop_limit = new_hl;
+
+	return XT_CONTINUE;
+}
+
+static bool ttl_tg_check(const struct xt_tgchk_param *par)
+{
+	const struct ipt_TTL_info *info = par->targinfo;
+
+	if (info->mode > IPT_TTL_MAXMODE) {
+		printk(KERN_WARNING "ipt_TTL: invalid or unknown Mode %u\n",
+			info->mode);
+		return false;
+	}
+	if (info->mode != IPT_TTL_SET && info->ttl == 0)
+		return false;
+	return true;
+}
+
+static bool hl_tg6_check(const struct xt_tgchk_param *par)
+{
+	const struct ip6t_HL_info *info = par->targinfo;
+
+	if (info->mode > IP6T_HL_MAXMODE) {
+		printk(KERN_WARNING "ip6t_HL: invalid or unknown Mode %u\n",
+			info->mode);
+		return false;
+	}
+	if (info->mode != IP6T_HL_SET && info->hop_limit == 0) {
+		printk(KERN_WARNING "ip6t_HL: increment/decrement doesn't "
+			"make sense with value 0\n");
+		return false;
+	}
+	return true;
+}
+
+static struct xt_target hl_tg_reg[] __read_mostly = {
+	{
+		.name       = "TTL",
+		.revision   = 0,
+		.family     = NFPROTO_IPV4,
+		.target     = ttl_tg,
+		.targetsize = sizeof(struct ipt_TTL_info),
+		.table      = "mangle",
+		.checkentry = ttl_tg_check,
+		.me         = THIS_MODULE,
+	},
+	{
+		.name       = "HL",
+		.revision   = 0,
+		.family     = NFPROTO_IPV6,
+		.target     = hl_tg6,
+		.targetsize = sizeof(struct ip6t_HL_info),
+		.table      = "mangle",
+		.checkentry = hl_tg6_check,
+		.me         = THIS_MODULE,
+	},
+};
+
+static int __init hl_tg_init(void)
+{
+	return xt_register_targets(hl_tg_reg, ARRAY_SIZE(hl_tg_reg));
+}
+
+static void __exit hl_tg_exit(void)
+{
+	xt_unregister_targets(hl_tg_reg, ARRAY_SIZE(hl_tg_reg));
+}
+
+module_init(hl_tg_init);
+module_exit(hl_tg_exit);
+MODULE_ALIAS("ipt_TTL");
+MODULE_ALIAS("ip6t_HL");
