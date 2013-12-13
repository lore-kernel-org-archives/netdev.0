From: Fan Du <fan.du@windriver.com>
Subject: [PATCH 2/2] netfilter: add IPv6 IPComp extension match support
Date: Fri, 13 Dec 2013 20:18:02 +0800
Message-ID: <1386937082-30412-3-git-send-email-fan.du@windriver.com>
References: <1386937082-30412-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <steffen.klassert@secunet.com>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43122 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286Ab3LMMSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 07:18:17 -0500
In-Reply-To: <1386937082-30412-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this plugin, user could specify IPComp tagged with certain
CPI that host not interested will be DROPped or any other action.

For example:
ip6tables -A INPUT -p 108 -m ipcomp --ipcompspi 0x87 -j DROP

Then input IPComp packet with CPI equates 0x87 will not reach
upper layer anymore.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/uapi/linux/netfilter_ipv6/ip6t_comp.h |   18 ++++
 net/ipv6/netfilter/Kconfig                    |    8 ++
 net/ipv6/netfilter/Makefile                   |    1 +
 net/ipv6/netfilter/ip6t_comp.c                |  110 +++++++++++++++++++++++++
 4 files changed, 137 insertions(+)
 create mode 100644 include/uapi/linux/netfilter_ipv6/ip6t_comp.h
 create mode 100644 net/ipv6/netfilter/ip6t_comp.c

diff --git a/include/uapi/linux/netfilter_ipv6/ip6t_comp.h b/include/uapi/linux/netfilter_ipv6/ip6t_comp.h
new file mode 100644
index 0000000..f2eecdd
--- /dev/null
+++ b/include/uapi/linux/netfilter_ipv6/ip6t_comp.h
@@ -0,0 +1,18 @@
+#ifndef _IP6T_COMP_H
+#define _IP6T_COMP_H
+
+#include <linux/types.h>
+
+struct ip6t_comp {
+	__u32 spis[2];			/* Security Parameter Index */
+	__u8  hdrres;			/* Test of the Reserved Filed */
+	__u8  invflags;			/* Inverse flags */
+};
+
+#define IP6T_IPCOMP_SPI 0x01
+#define IP6T_IPCOMP_RES 0x02
+
+#define IP6T_IPCOMP_INV_SPI	0x01	/* Invert the sense of spi. */
+#define IP6T_IPCOMP_INV_MASK	0x03	/* All possible flags. */
+
+#endif /*_IP6T_COMP_H*/
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 7702f9e..3f5e603 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -62,6 +62,14 @@ config IP6_NF_MATCH_AH
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP6_NF_MATCH_IPCOMP
+	tristate '"ipcomp" match support'
+	depends on NETFILTER_ADVANCED
+	help
+	  This module allows one to match IPcomp packets.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config IP6_NF_MATCH_EUI64
 	tristate '"eui64" address check'
 	depends on NETFILTER_ADVANCED
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index d1b4928..602ab70 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -30,6 +30,7 @@ obj-$(CONFIG_NFT_CHAIN_NAT_IPV6) += nft_chain_nat_ipv6.o
 
 # matches
 obj-$(CONFIG_IP6_NF_MATCH_AH) += ip6t_ah.o
+obj-$(CONFIG_IP6_NF_MATCH_IPCOMP) += ip6t_comp.o
 obj-$(CONFIG_IP6_NF_MATCH_EUI64) += ip6t_eui64.o
 obj-$(CONFIG_IP6_NF_MATCH_FRAG) += ip6t_frag.o
 obj-$(CONFIG_IP6_NF_MATCH_IPV6HEADER) += ip6t_ipv6header.o
diff --git a/net/ipv6/netfilter/ip6t_comp.c b/net/ipv6/netfilter/ip6t_comp.c
new file mode 100644
index 0000000..bd4a0ae
--- /dev/null
+++ b/net/ipv6/netfilter/ip6t_comp.c
@@ -0,0 +1,110 @@
+/*  Kernel module to match IPComp parameters
+ *
+ *  Copyright (C) 2013 WindRiver
+ *
+ *  Author:
+ *  Fan Du <fan.du@windriver.com>
+ *
+ *  Based on:
+ *  net/ipv6/netfilter/ip6t_ah.c
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License
+ *  as published by the Free Software Foundation; either version
+ *  2 of the License, or (at your option) any later version.
+ */
+
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/types.h>
+#include <net/checksum.h>
+#include <net/ipv6.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#include <linux/netfilter_ipv6/ip6t_comp.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Fan Du <fan.du@windriver.com>");
+MODULE_DESCRIPTION("Xtables: IPv6 IPsec-IPComp SPI match");
+
+
+/* Returns 1 if the spi is matched by the range, 0 otherwise */
+static inline bool
+spi_match(u_int32_t min, u_int32_t max, u_int32_t spi, bool invert)
+{
+	bool r;
+
+	pr_debug("spi_match:%c 0x%x <= 0x%x <= 0x%x\n",
+		 invert ? '!' : ' ', min, spi, max);
+	r = (spi >= min && spi <= max) ^ invert;
+	pr_debug(" result %s\n", r ? "PASS" : "FAILED");
+	return r;
+}
+
+static bool comp_mt6(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	struct ip_comp_hdr _comp;
+	const struct ip_comp_hdr *comp;
+	const struct ip6t_comp *compinfo = par->matchinfo;
+
+	comp = skb_header_pointer(skb, par->thoff, sizeof(_comp), &_comp);
+	if (comp == NULL) {
+		par->hotdrop = true;
+		return false;
+	}
+
+	pr_debug("IPv6 IPcomp SPI %u %04X ", ntohs(comp->cpi), ntohs(comp->cpi));
+	pr_debug("RES %02X \n", comp->flags);
+
+	pr_debug("IPv6 IPcomp spi %02X ",
+		 spi_match(compinfo->spis[0], compinfo->spis[1],
+			   ntohs(comp->cpi),
+			   !!(compinfo->invflags & IP6T_IPCOMP_INV_SPI)));
+	pr_debug("res %02X %04X %02X\n",
+		 compinfo->hdrres, comp->flags,
+		 !(compinfo->hdrres && comp->flags));
+
+	return (comp != NULL) &&
+		spi_match(compinfo->spis[0], compinfo->spis[1],
+			  ntohs(comp->cpi),
+			  !!(compinfo->invflags & IP6T_IPCOMP_INV_SPI)) &&
+			  !(compinfo->hdrres && comp->flags);
+}
+
+static int comp_mt6_check(const struct xt_mtchk_param *par)
+{
+	const struct ip6t_comp *compinfo = par->matchinfo;
+
+	if (compinfo->invflags & ~IP6T_IPCOMP_INV_MASK) {
+		pr_debug("unknown flags %X\n", compinfo->invflags);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static struct xt_match comp_mt6_reg __read_mostly = {
+	.name		= "ipcomp",
+	.family		= NFPROTO_IPV6,
+	.match		= comp_mt6,
+	.matchsize	= sizeof(struct ip6t_comp),
+	.checkentry	= comp_mt6_check,
+	.me		= THIS_MODULE,
+};
+
+static int __init comp_mt6_init(void)
+{
+	return xt_register_match(&comp_mt6_reg);
+}
+
+static void __exit comp_mt6_exit(void)
+{
+	xt_unregister_match(&comp_mt6_reg);
+}
+
+module_init(comp_mt6_init);
+module_exit(comp_mt6_exit);
-- 
1.7.9.5
