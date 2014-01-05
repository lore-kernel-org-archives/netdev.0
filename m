From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/12] netfilter: add IPv4/6 IPComp extension match support
Date: Mon,  6 Jan 2014 00:12:58 +0100
Message-ID: <1388963586-5049-5-git-send-email-pablo@netfilter.org>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56232 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752013AbaAEXNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 18:13:23 -0500
In-Reply-To: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "fan.du" <fan.du@windriver.com>

With this plugin, user could specify IPComp tagged with certain
CPI that host not interested will be DROPped or any other action.

For example:
iptables  -A INPUT -p 108 -m ipcomp --ipcompspi 0x87 -j DROP
ip6tables -A INPUT -p 108 -m ipcomp --ipcompspi 0x87 -j DROP

Then input IPComp packet with CPI equates 0x87 will not reach
upper layer anymore.

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/Kbuild      |    1 +
 include/uapi/linux/netfilter/xt_ipcomp.h |   16 +++++
 net/netfilter/Kconfig                    |    9 +++
 net/netfilter/Makefile                   |    1 +
 net/netfilter/xt_ipcomp.c                |  111 ++++++++++++++++++++++++++++++
 5 files changed, 138 insertions(+)
 create mode 100644 include/uapi/linux/netfilter/xt_ipcomp.h
 create mode 100644 net/netfilter/xt_ipcomp.c

diff --git a/include/uapi/linux/netfilter/Kbuild b/include/uapi/linux/netfilter/Kbuild
index 17c3af2..91be8ce 100644
--- a/include/uapi/linux/netfilter/Kbuild
+++ b/include/uapi/linux/netfilter/Kbuild
@@ -54,6 +54,7 @@ header-y += xt_ecn.h
 header-y += xt_esp.h
 header-y += xt_hashlimit.h
 header-y += xt_helper.h
+header-y += xt_ipcomp.h
 header-y += xt_iprange.h
 header-y += xt_ipvs.h
 header-y += xt_length.h
diff --git a/include/uapi/linux/netfilter/xt_ipcomp.h b/include/uapi/linux/netfilter/xt_ipcomp.h
new file mode 100644
index 0000000..45c7e40
--- /dev/null
+++ b/include/uapi/linux/netfilter/xt_ipcomp.h
@@ -0,0 +1,16 @@
+#ifndef _XT_IPCOMP_H
+#define _XT_IPCOMP_H
+
+#include <linux/types.h>
+
+struct xt_ipcomp {
+	__u32 spis[2];	/* Security Parameter Index */
+	__u8 invflags;	/* Inverse flags */
+	__u8 hdrres;	/* Test of the Reserved Filed */
+};
+
+/* Values for "invflags" field in struct xt_ipcomp. */
+#define XT_IPCOMP_INV_SPI	0x01	/* Invert the sense of spi. */
+#define XT_IPCOMP_INV_MASK	0x01	/* All possible flags. */
+
+#endif /*_XT_IPCOMP_H*/
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index c3398cd..6d8e48b 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -1035,6 +1035,15 @@ config NETFILTER_XT_MATCH_HL
 	in the IPv6 header, or the time-to-live field in the IPv4
 	header of the packet.
 
+config NETFILTER_XT_MATCH_IPCOMP
+	tristate '"ipcomp" match support'
+	depends on NETFILTER_ADVANCED
+	help
+	  This match extension allows you to match a range of CPIs(16 bits)
+	  inside IPComp header of IPSec packets.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_IPRANGE
 	tristate '"iprange" address range match support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 394483b..398cd70 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -133,6 +133,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_ESP) += xt_esp.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_HASHLIMIT) += xt_hashlimit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_HELPER) += xt_helper.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_HL) += xt_hl.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_IPCOMP) += xt_ipcomp.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_IPRANGE) += xt_iprange.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_IPVS) += xt_ipvs.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LENGTH) += xt_length.o
diff --git a/net/netfilter/xt_ipcomp.c b/net/netfilter/xt_ipcomp.c
new file mode 100644
index 0000000..a4c7561
--- /dev/null
+++ b/net/netfilter/xt_ipcomp.c
@@ -0,0 +1,111 @@
+/*  Kernel module to match IPComp parameters for IPv4 and IPv6
+ *
+ *  Copyright (C) 2013 WindRiver
+ *
+ *  Author:
+ *  Fan Du <fan.du@windriver.com>
+ *
+ *  Based on:
+ *  net/netfilter/xt_esp.c
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License
+ *  as published by the Free Software Foundation; either version
+ *  2 of the License, or (at your option) any later version.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#include <linux/in.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+
+#include <linux/netfilter/xt_ipcomp.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Fan Du <fan.du@windriver.com>");
+MODULE_DESCRIPTION("Xtables: IPv4/6 IPsec-IPComp SPI match");
+
+/* Returns 1 if the spi is matched by the range, 0 otherwise */
+static inline bool
+spi_match(u_int32_t min, u_int32_t max, u_int32_t spi, bool invert)
+{
+	bool r;
+	pr_debug("spi_match:%c 0x%x <= 0x%x <= 0x%x\n",
+		 invert ? '!' : ' ', min, spi, max);
+	r = (spi >= min && spi <= max) ^ invert;
+	pr_debug(" result %s\n", r ? "PASS" : "FAILED");
+	return r;
+}
+
+static bool comp_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	struct ip_comp_hdr _comphdr;
+	const struct ip_comp_hdr *chdr;
+	const struct xt_ipcomp *compinfo = par->matchinfo;
+
+	/* Must not be a fragment. */
+	if (par->fragoff != 0)
+		return false;
+
+	chdr = skb_header_pointer(skb, par->thoff, sizeof(_comphdr), &_comphdr);
+	if (chdr == NULL) {
+		/* We've been asked to examine this packet, and we
+		 * can't.  Hence, no choice but to drop.
+		 */
+		pr_debug("Dropping evil IPComp tinygram.\n");
+		par->hotdrop = true;
+		return 0;
+	}
+
+	return spi_match(compinfo->spis[0], compinfo->spis[1],
+			 ntohl(chdr->cpi << 16),
+			 !!(compinfo->invflags & XT_IPCOMP_INV_SPI));
+}
+
+static int comp_mt_check(const struct xt_mtchk_param *par)
+{
+	const struct xt_ipcomp *compinfo = par->matchinfo;
+
+	/* Must specify no unknown invflags */
+	if (compinfo->invflags & ~XT_IPCOMP_INV_MASK) {
+		pr_err("unknown flags %X\n", compinfo->invflags);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static struct xt_match comp_mt_reg[] __read_mostly = {
+	{
+		.name		= "ipcomp",
+		.family		= NFPROTO_IPV4,
+		.match		= comp_mt,
+		.matchsize	= sizeof(struct xt_ipcomp),
+		.proto		= IPPROTO_COMP,
+		.checkentry	= comp_mt_check,
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "ipcomp",
+		.family		= NFPROTO_IPV6,
+		.match		= comp_mt,
+		.matchsize	= sizeof(struct xt_ipcomp),
+		.proto		= IPPROTO_COMP,
+		.checkentry	= comp_mt_check,
+		.me		= THIS_MODULE,
+	},
+};
+
+static int __init comp_mt_init(void)
+{
+	return xt_register_matches(comp_mt_reg, ARRAY_SIZE(comp_mt_reg));
+}
+
+static void __exit comp_mt_exit(void)
+{
+	xt_unregister_matches(comp_mt_reg, ARRAY_SIZE(comp_mt_reg));
+}
+
+module_init(comp_mt_init);
+module_exit(comp_mt_exit);
-- 
1.7.10.4
