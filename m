From: kaber@trash.net
Subject: [PATCH 36/37] netfilter: ipt_addrtype: rename to xt_addrtype
Date: Tue, 15 Mar 2011 20:44:16 +0100
Message-ID: <1300218257-26953-37-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fwestphal@astaro.com>

Followup patch will add ipv6 support.

ipt_addrtype.h is retained for compatibility reasons, but no longer used
by the kernel.

Signed-off-by: Florian Westphal <fwestphal@astaro.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 Documentation/feature-removal-schedule.txt |    8 ++
 include/linux/netfilter/Kbuild             |    1 +
 include/linux/netfilter/xt_addrtype.h      |   27 ++++++
 net/ipv4/netfilter/Kconfig                 |   10 --
 net/ipv4/netfilter/Makefile                |    1 -
 net/ipv4/netfilter/ipt_addrtype.c          |  134 ---------------------------
 net/netfilter/Kconfig                      |   10 ++
 net/netfilter/Makefile                     |    1 +
 net/netfilter/xt_addrtype.c                |  135 ++++++++++++++++++++++++++++
 9 files changed, 182 insertions(+), 145 deletions(-)
 create mode 100644 include/linux/netfilter/xt_addrtype.h
 delete mode 100644 net/ipv4/netfilter/ipt_addrtype.c
 create mode 100644 net/netfilter/xt_addrtype.c

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 05b248a..a7ee7cf 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -618,3 +618,11 @@ Who:	Jan Engelhardt <jengelh@medozas.de>
 Files:	net/netfilter/xt_connlimit.c
 
 ----------------------------
+
+What:	ipt_addrtype match include file
+When:	2012
+Why:	superseded by xt_addrtype
+Who:	Florian Westphal <fw@strlen.de>
+Files:	include/linux/netfilter_ipv4/ipt_addrtype.h
+
+----------------------------
diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index 15e83bf..a1b410c 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -29,6 +29,7 @@ header-y += xt_TCPMSS.h
 header-y += xt_TCPOPTSTRIP.h
 header-y += xt_TEE.h
 header-y += xt_TPROXY.h
+header-y += xt_addrtype.h
 header-y += xt_cluster.h
 header-y += xt_comment.h
 header-y += xt_connbytes.h
diff --git a/include/linux/netfilter/xt_addrtype.h b/include/linux/netfilter/xt_addrtype.h
new file mode 100644
index 0000000..b492fc8
--- /dev/null
+++ b/include/linux/netfilter/xt_addrtype.h
@@ -0,0 +1,27 @@
+#ifndef _XT_ADDRTYPE_H
+#define _XT_ADDRTYPE_H
+
+#include <linux/types.h>
+
+enum {
+	XT_ADDRTYPE_INVERT_SOURCE	= 0x0001,
+	XT_ADDRTYPE_INVERT_DEST		= 0x0002,
+	XT_ADDRTYPE_LIMIT_IFACE_IN	= 0x0004,
+	XT_ADDRTYPE_LIMIT_IFACE_OUT	= 0x0008,
+};
+
+struct xt_addrtype_info_v1 {
+	__u16	source;		/* source-type mask */
+	__u16	dest;		/* dest-type mask */
+	__u32	flags;
+};
+
+/* revision 0 */
+struct xt_addrtype_info {
+	__u16	source;		/* source-type mask */
+	__u16	dest;		/* dest-type mask */
+	__u32	invert_source;
+	__u32	invert_dest;
+};
+
+#endif
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index f926a31..1dfc18a 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -64,16 +64,6 @@ config IP_NF_IPTABLES
 if IP_NF_IPTABLES
 
 # The matches.
-config IP_NF_MATCH_ADDRTYPE
-	tristate '"addrtype" address type match support'
-	depends on NETFILTER_ADVANCED
-	help
-	  This option allows you to match what routing thinks of an address,
-	  eg. UNICAST, LOCAL, BROADCAST, ...
-
-	  If you want to compile it as a module, say M here and read
-	  <file:Documentation/kbuild/modules.txt>.  If unsure, say `N'.
-
 config IP_NF_MATCH_AH
 	tristate '"ah" match support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 19eb59d..dca2082 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -48,7 +48,6 @@ obj-$(CONFIG_IP_NF_RAW) += iptable_raw.o
 obj-$(CONFIG_IP_NF_SECURITY) += iptable_security.o
 
 # matches
-obj-$(CONFIG_IP_NF_MATCH_ADDRTYPE) += ipt_addrtype.o
 obj-$(CONFIG_IP_NF_MATCH_AH) += ipt_ah.o
 obj-$(CONFIG_IP_NF_MATCH_ECN) += ipt_ecn.o
 
diff --git a/net/ipv4/netfilter/ipt_addrtype.c b/net/ipv4/netfilter/ipt_addrtype.c
deleted file mode 100644
index db8bff0..0000000
--- a/net/ipv4/netfilter/ipt_addrtype.c
+++ /dev/null
@@ -1,134 +0,0 @@
-/*
- *  iptables module to match inet_addr_type() of an ip.
- *
- *  Copyright (c) 2004 Patrick McHardy <kaber@trash.net>
- *  (C) 2007 Laszlo Attila Toth <panther@balabit.hu>
- *
- *  This program is free software; you can redistribute it and/or modify
- *  it under the terms of the GNU General Public License version 2 as
- *  published by the Free Software Foundation.
- */
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/netdevice.h>
-#include <linux/ip.h>
-#include <net/route.h>
-
-#include <linux/netfilter_ipv4/ipt_addrtype.h>
-#include <linux/netfilter/x_tables.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-MODULE_DESCRIPTION("Xtables: address type match for IPv4");
-
-static inline bool match_type(struct net *net, const struct net_device *dev,
-			      __be32 addr, u_int16_t mask)
-{
-	return !!(mask & (1 << inet_dev_addr_type(net, dev, addr)));
-}
-
-static bool
-addrtype_mt_v0(const struct sk_buff *skb, struct xt_action_param *par)
-{
-	struct net *net = dev_net(par->in ? par->in : par->out);
-	const struct ipt_addrtype_info *info = par->matchinfo;
-	const struct iphdr *iph = ip_hdr(skb);
-	bool ret = true;
-
-	if (info->source)
-		ret &= match_type(net, NULL, iph->saddr, info->source) ^
-		       info->invert_source;
-	if (info->dest)
-		ret &= match_type(net, NULL, iph->daddr, info->dest) ^
-		       info->invert_dest;
-
-	return ret;
-}
-
-static bool
-addrtype_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
-{
-	struct net *net = dev_net(par->in ? par->in : par->out);
-	const struct ipt_addrtype_info_v1 *info = par->matchinfo;
-	const struct iphdr *iph = ip_hdr(skb);
-	const struct net_device *dev = NULL;
-	bool ret = true;
-
-	if (info->flags & IPT_ADDRTYPE_LIMIT_IFACE_IN)
-		dev = par->in;
-	else if (info->flags & IPT_ADDRTYPE_LIMIT_IFACE_OUT)
-		dev = par->out;
-
-	if (info->source)
-		ret &= match_type(net, dev, iph->saddr, info->source) ^
-		       (info->flags & IPT_ADDRTYPE_INVERT_SOURCE);
-	if (ret && info->dest)
-		ret &= match_type(net, dev, iph->daddr, info->dest) ^
-		       !!(info->flags & IPT_ADDRTYPE_INVERT_DEST);
-	return ret;
-}
-
-static int addrtype_mt_checkentry_v1(const struct xt_mtchk_param *par)
-{
-	struct ipt_addrtype_info_v1 *info = par->matchinfo;
-
-	if (info->flags & IPT_ADDRTYPE_LIMIT_IFACE_IN &&
-	    info->flags & IPT_ADDRTYPE_LIMIT_IFACE_OUT) {
-		pr_info("both incoming and outgoing "
-			"interface limitation cannot be selected\n");
-		return -EINVAL;
-	}
-
-	if (par->hook_mask & ((1 << NF_INET_PRE_ROUTING) |
-	    (1 << NF_INET_LOCAL_IN)) &&
-	    info->flags & IPT_ADDRTYPE_LIMIT_IFACE_OUT) {
-		pr_info("output interface limitation "
-			"not valid in PREROUTING and INPUT\n");
-		return -EINVAL;
-	}
-
-	if (par->hook_mask & ((1 << NF_INET_POST_ROUTING) |
-	    (1 << NF_INET_LOCAL_OUT)) &&
-	    info->flags & IPT_ADDRTYPE_LIMIT_IFACE_IN) {
-		pr_info("input interface limitation "
-			"not valid in POSTROUTING and OUTPUT\n");
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-static struct xt_match addrtype_mt_reg[] __read_mostly = {
-	{
-		.name		= "addrtype",
-		.family		= NFPROTO_IPV4,
-		.match		= addrtype_mt_v0,
-		.matchsize	= sizeof(struct ipt_addrtype_info),
-		.me		= THIS_MODULE
-	},
-	{
-		.name		= "addrtype",
-		.family		= NFPROTO_IPV4,
-		.revision	= 1,
-		.match		= addrtype_mt_v1,
-		.checkentry	= addrtype_mt_checkentry_v1,
-		.matchsize	= sizeof(struct ipt_addrtype_info_v1),
-		.me		= THIS_MODULE
-	}
-};
-
-static int __init addrtype_mt_init(void)
-{
-	return xt_register_matches(addrtype_mt_reg,
-				   ARRAY_SIZE(addrtype_mt_reg));
-}
-
-static void __exit addrtype_mt_exit(void)
-{
-	xt_unregister_matches(addrtype_mt_reg, ARRAY_SIZE(addrtype_mt_reg));
-}
-
-module_init(addrtype_mt_init);
-module_exit(addrtype_mt_exit);
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 82a6e0d..32bff6d 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -649,6 +649,16 @@ config NETFILTER_XT_TARGET_TCPOPTSTRIP
 
 comment "Xtables matches"
 
+config NETFILTER_XT_MATCH_ADDRTYPE
+	tristate '"addrtype" address type match support'
+	depends on NETFILTER_ADVANCED
+	---help---
+	  This option allows you to match what routing thinks of an address,
+	  eg. UNICAST, LOCAL, BROADCAST, ...
+
+	  If you want to compile it as a module, say M here and read
+	  <file:Documentation/kbuild/modules.txt>.  If unsure, say `N'.
+
 config NETFILTER_XT_MATCH_CLUSTER
 	tristate '"cluster" match support'
 	depends on NF_CONNTRACK
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index d57a890..1a02853 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -70,6 +70,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_TRACE) += xt_TRACE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_IDLETIMER) += xt_IDLETIMER.o
 
 # matches
+obj-$(CONFIG_NETFILTER_XT_MATCH_ADDRTYPE) += xt_addrtype.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CLUSTER) += xt_cluster.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_COMMENT) += xt_comment.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNBYTES) += xt_connbytes.o
diff --git a/net/netfilter/xt_addrtype.c b/net/netfilter/xt_addrtype.c
new file mode 100644
index 0000000..e89c0b8
--- /dev/null
+++ b/net/netfilter/xt_addrtype.c
@@ -0,0 +1,135 @@
+/*
+ *  iptables module to match inet_addr_type() of an ip.
+ *
+ *  Copyright (c) 2004 Patrick McHardy <kaber@trash.net>
+ *  (C) 2007 Laszlo Attila Toth <panther@balabit.hu>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2 as
+ *  published by the Free Software Foundation.
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/ip.h>
+#include <net/route.h>
+
+#include <linux/netfilter/xt_addrtype.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_DESCRIPTION("Xtables: address type match");
+MODULE_ALIAS("ipt_addrtype");
+
+static inline bool match_type(struct net *net, const struct net_device *dev,
+			      __be32 addr, u_int16_t mask)
+{
+	return !!(mask & (1 << inet_dev_addr_type(net, dev, addr)));
+}
+
+static bool
+addrtype_mt_v0(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	struct net *net = dev_net(par->in ? par->in : par->out);
+	const struct xt_addrtype_info *info = par->matchinfo;
+	const struct iphdr *iph = ip_hdr(skb);
+	bool ret = true;
+
+	if (info->source)
+		ret &= match_type(net, NULL, iph->saddr, info->source) ^
+		       info->invert_source;
+	if (info->dest)
+		ret &= match_type(net, NULL, iph->daddr, info->dest) ^
+		       info->invert_dest;
+
+	return ret;
+}
+
+static bool
+addrtype_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	struct net *net = dev_net(par->in ? par->in : par->out);
+	const struct xt_addrtype_info_v1 *info = par->matchinfo;
+	const struct iphdr *iph = ip_hdr(skb);
+	const struct net_device *dev = NULL;
+	bool ret = true;
+
+	if (info->flags & XT_ADDRTYPE_LIMIT_IFACE_IN)
+		dev = par->in;
+	else if (info->flags & XT_ADDRTYPE_LIMIT_IFACE_OUT)
+		dev = par->out;
+
+	if (info->source)
+		ret &= match_type(net, dev, iph->saddr, info->source) ^
+		       (info->flags & XT_ADDRTYPE_INVERT_SOURCE);
+	if (ret && info->dest)
+		ret &= match_type(net, dev, iph->daddr, info->dest) ^
+		       !!(info->flags & XT_ADDRTYPE_INVERT_DEST);
+	return ret;
+}
+
+static int addrtype_mt_checkentry_v1(const struct xt_mtchk_param *par)
+{
+	struct xt_addrtype_info_v1 *info = par->matchinfo;
+
+	if (info->flags & XT_ADDRTYPE_LIMIT_IFACE_IN &&
+	    info->flags & XT_ADDRTYPE_LIMIT_IFACE_OUT) {
+		pr_info("both incoming and outgoing "
+			"interface limitation cannot be selected\n");
+		return -EINVAL;
+	}
+
+	if (par->hook_mask & ((1 << NF_INET_PRE_ROUTING) |
+	    (1 << NF_INET_LOCAL_IN)) &&
+	    info->flags & XT_ADDRTYPE_LIMIT_IFACE_OUT) {
+		pr_info("output interface limitation "
+			"not valid in PREROUTING and INPUT\n");
+		return -EINVAL;
+	}
+
+	if (par->hook_mask & ((1 << NF_INET_POST_ROUTING) |
+	    (1 << NF_INET_LOCAL_OUT)) &&
+	    info->flags & XT_ADDRTYPE_LIMIT_IFACE_IN) {
+		pr_info("input interface limitation "
+			"not valid in POSTROUTING and OUTPUT\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static struct xt_match addrtype_mt_reg[] __read_mostly = {
+	{
+		.name		= "addrtype",
+		.family		= NFPROTO_IPV4,
+		.match		= addrtype_mt_v0,
+		.matchsize	= sizeof(struct xt_addrtype_info),
+		.me		= THIS_MODULE
+	},
+	{
+		.name		= "addrtype",
+		.family		= NFPROTO_IPV4,
+		.revision	= 1,
+		.match		= addrtype_mt_v1,
+		.checkentry	= addrtype_mt_checkentry_v1,
+		.matchsize	= sizeof(struct xt_addrtype_info_v1),
+		.me		= THIS_MODULE
+	}
+};
+
+static int __init addrtype_mt_init(void)
+{
+	return xt_register_matches(addrtype_mt_reg,
+				   ARRAY_SIZE(addrtype_mt_reg));
+}
+
+static void __exit addrtype_mt_exit(void)
+{
+	xt_unregister_matches(addrtype_mt_reg, ARRAY_SIZE(addrtype_mt_reg));
+}
+
+module_init(addrtype_mt_init);
+module_exit(addrtype_mt_exit);
-- 
1.7.2.3

