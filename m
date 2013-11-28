From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next] netfilter: add IPComp extension match support
Date: Thu, 28 Nov 2013 10:53:24 +0800
Message-ID: <1385607204-27650-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kaber@trash.net>, <netdev@vger.kernel.org>,
	<netfilter-devel@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With this plugin, user could specify IPComp tagged with certain 
CPI that host not interested will be DROPped or any other action.

For example:
iptables -A INPUT -p 108 -m ipcomp --ipcompspi 0x87 -j DROP

Then input IPComp packet with CPI equates 0x87 will not reach
upper layer anymore.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/uapi/linux/netfilter_ipv4/ipt_comp.h |   17 +++++
 net/ipv4/netfilter/Kconfig                   |    9 +++
 net/ipv4/netfilter/Makefile                  |    1 +
 net/ipv4/netfilter/ipt_comp.c                |  101 ++++++++++++++++++++++++++
 4 files changed, 128 insertions(+)
 create mode 100644 include/uapi/linux/netfilter_ipv4/ipt_comp.h
 create mode 100644 net/ipv4/netfilter/ipt_comp.c

diff --git a/include/uapi/linux/netfilter_ipv4/ipt_comp.h b/include/uapi/linux/netfilter_ipv4/ipt_comp.h
new file mode 100644
index 0000000..d072202
--- /dev/null
+++ b/include/uapi/linux/netfilter_ipv4/ipt_comp.h
@@ -0,0 +1,17 @@
+#ifndef _IPT_COMP_H
+#define _IPT_COMP_H
+
+#include <linux/types.h>
+
+struct ipt_comp {
+	__u32 spis[2];			/* Security Parameter Index */
+	__u8  invflags;			/* Inverse flags */
+};
+
+
+
+/* Values for "invflags" field in struct ipt_comp. */
+#define IPT_IPCOMP_INV_SPI		0x01	/* Invert the sense of spi. */
+#define IPT_IPCOMP_INV_MASK	0x01	/* All possible flags. */
+
+#endif /*_IPT_COMP_H*/
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 40d5607..f71cf7b 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -81,6 +81,15 @@ config IP_NF_MATCH_AH
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP_NF_MATCH_IPCOMP
+	tristate '"ipcomp" match support'
+	depends on NETFILTER_ADVANCED
+	help
+	  This match extension allows you to match a range of SPIs (Actually it's
+	  Compression Parameter Index(CPI) inside IPComp header of IPSec packets.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config IP_NF_MATCH_ECN
 	tristate '"ecn" match support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 19df72b..b67ecb8 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -45,6 +45,7 @@ obj-$(CONFIG_IP_NF_SECURITY) += iptable_security.o
 
 # matches
 obj-$(CONFIG_IP_NF_MATCH_AH) += ipt_ah.o
+obj-$(CONFIG_IP_NF_MATCH_IPCOMP) += ipt_comp.o
 obj-$(CONFIG_IP_NF_MATCH_RPFILTER) += ipt_rpfilter.o
 
 # targets
diff --git a/net/ipv4/netfilter/ipt_comp.c b/net/ipv4/netfilter/ipt_comp.c
new file mode 100644
index 0000000..7796e6e
--- /dev/null
+++ b/net/ipv4/netfilter/ipt_comp.c
@@ -0,0 +1,101 @@
+/*  Kernel module to match IPComp parameters
+ *
+ *  Copyright (C) 2013 WindRiver
+ *
+ *  Author:
+ *  Fan Du <fan.du@windriver.com>
+ *
+ *  Based on:
+ *  net/ipv4/netfilter/ipt_ah.c
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License
+ *  as published by the Free Software Foundation; either version
+ *  2 of the License, or (at your option) any later version.
+ */
+
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#include <linux/in.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+
+#include <linux/netfilter_ipv4/ipt_comp.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Fan Du <fan.du@windriver.com>");
+MODULE_DESCRIPTION("Xtables: IPv4 IPsec-IPComp SPI match");
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
+	const struct ipt_comp *compinfo = par->matchinfo;
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
+			 !!(compinfo->invflags & IPT_IPCOMP_INV_SPI));
+}
+
+static int comp_mt_check(const struct xt_mtchk_param *par)
+{
+	const struct ipt_comp *compinfo = par->matchinfo;
+
+	/* Must specify no unknown invflags */
+	if (compinfo->invflags & ~IPT_IPCOMP_INV_MASK) {
+		pr_debug("unknown flags %X\n", compinfo->invflags);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static struct xt_match comp_mt_reg __read_mostly = {
+	.name		= "ipcomp",
+	.family		= NFPROTO_IPV4,
+	.match		= comp_mt,
+	.matchsize	= sizeof(struct ipt_comp),
+	.proto		= IPPROTO_COMP,
+	.checkentry	= comp_mt_check,
+	.me		= THIS_MODULE,
+};
+
+static int __init comp_mt_init(void)
+{
+	return xt_register_match(&comp_mt_reg);
+}
+
+static void __exit comp_mt_exit(void)
+{
+	xt_unregister_match(&comp_mt_reg);
+}
+
+module_init(comp_mt_init);
+module_exit(comp_mt_exit);
-- 
1.7.9.5

