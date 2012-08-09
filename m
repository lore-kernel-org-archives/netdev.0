From: kaber@trash.net
Subject: [PATCH 19/19] netfilter: ip6tables: add stateless IPv6-to-IPv6 Network Prefix Translation target
Date: Thu,  9 Aug 2012 22:09:03 +0200
Message-ID: <1344542943-11588-20-git-send-email-kaber@trash.net>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1344542943-11588-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter_ipv6/Kbuild     |    1 +
 include/linux/netfilter_ipv6/ip6t_NPT.h |   16 +++
 net/ipv6/netfilter/Kconfig              |    9 ++
 net/ipv6/netfilter/Makefile             |    1 +
 net/ipv6/netfilter/ip6t_NPT.c           |  165 +++++++++++++++++++++++++++++++
 5 files changed, 192 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter_ipv6/ip6t_NPT.h
 create mode 100644 net/ipv6/netfilter/ip6t_NPT.c

diff --git a/include/linux/netfilter_ipv6/Kbuild b/include/linux/netfilter_ipv6/Kbuild
index bd095bc..b88c005 100644
--- a/include/linux/netfilter_ipv6/Kbuild
+++ b/include/linux/netfilter_ipv6/Kbuild
@@ -1,6 +1,7 @@
 header-y += ip6_tables.h
 header-y += ip6t_HL.h
 header-y += ip6t_LOG.h
+header-y += ip6t_NPT.h
 header-y += ip6t_REJECT.h
 header-y += ip6t_ah.h
 header-y += ip6t_frag.h
diff --git a/include/linux/netfilter_ipv6/ip6t_NPT.h b/include/linux/netfilter_ipv6/ip6t_NPT.h
new file mode 100644
index 0000000..f763355
--- /dev/null
+++ b/include/linux/netfilter_ipv6/ip6t_NPT.h
@@ -0,0 +1,16 @@
+#ifndef __NETFILTER_IP6T_NPT
+#define __NETFILTER_IP6T_NPT
+
+#include <linux/types.h>
+#include <linux/netfilter.h>
+
+struct ip6t_npt_tginfo {
+	union nf_inet_addr	src_pfx;
+	union nf_inet_addr	dst_pfx;
+	__u8			src_pfx_len;
+	__u8			dst_pfx_len;
+	/* Used internally by the kernel */
+	__sum16			adjustment;
+};
+
+#endif /* __NETFILTER_IP6T_NPT */
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 7bdf73b..44ae1bf 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -177,6 +177,15 @@ config IP6_NF_TARGET_REDIRECT
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP6_NF_TARGET_NPT
+	tristate "NPT (Network Prefix translation) target support"
+	depends on NETFILTER_ADVANCED
+	help
+	  This option adda `SNPT' and `DNPT' target, which perform stateless
+	  IPv6-to-IPv6 Network Prefix Translation (RFC 6296).
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config IP6_NF_FILTER
 	tristate "Packet filtering"
 	default m if NETFILTER_ADVANCED=n
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 0864ce6..5752132 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -36,5 +36,6 @@ obj-$(CONFIG_IP6_NF_MATCH_RT) += ip6t_rt.o
 # targets
 obj-$(CONFIG_IP6_NF_TARGET_MASQUERADE) += ip6t_MASQUERADE.o
 obj-$(CONFIG_IP6_NF_TARGET_NETMAP) += ip6t_NETMAP.o
+obj-$(CONFIG_IP6_NF_TARGET_NPT) += ip6t_NPT.o
 obj-$(CONFIG_IP6_NF_TARGET_REDIRECT) += ip6t_REDIRECT.o
 obj-$(CONFIG_IP6_NF_TARGET_REJECT) += ip6t_REJECT.o
diff --git a/net/ipv6/netfilter/ip6t_NPT.c b/net/ipv6/netfilter/ip6t_NPT.c
new file mode 100644
index 0000000..e948691
--- /dev/null
+++ b/net/ipv6/netfilter/ip6t_NPT.c
@@ -0,0 +1,165 @@
+/*
+ * Copyright (c) 2011, 2012 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ipv6.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6.h>
+#include <linux/netfilter_ipv6/ip6t_NPT.h>
+#include <linux/netfilter/x_tables.h>
+
+static __sum16 csum16_complement(__sum16 a)
+{
+	return (__force __sum16)(0xffff - (__force u16)a);
+}
+
+static __sum16 csum16_add(__sum16 a, __sum16 b)
+{
+	u16 sum;
+
+	sum = (__force u16)a + (__force u16)b;
+	sum += (__force u16)a < (__force u16)b;
+	return (__force __sum16)sum;
+}
+
+static __sum16 csum16_sub(__sum16 a, __sum16 b)
+{
+	return csum16_add(a, csum16_complement(b));
+}
+
+static int ip6t_npt_checkentry(const struct xt_tgchk_param *par)
+{
+	struct ip6t_npt_tginfo *npt = par->targinfo;
+	__sum16 src_sum = 0, dst_sum = 0;
+	unsigned int i;
+
+	if (npt->src_pfx_len > 64 || npt->dst_pfx_len > 64)
+		return -EINVAL;
+
+	for (i = 0; i < ARRAY_SIZE(npt->src_pfx.in6.s6_addr16); i++) {
+		src_sum = csum16_add(src_sum,
+				(__force __sum16)npt->src_pfx.in6.s6_addr16[i]);
+		dst_sum = csum16_add(dst_sum,
+				(__force __sum16)npt->dst_pfx.in6.s6_addr16[i]);
+	}
+
+	npt->adjustment = csum16_sub(src_sum, dst_sum);
+	return 0;
+}
+
+static bool ip6t_npt_map_pfx(const struct ip6t_npt_tginfo *npt,
+			     struct in6_addr *addr)
+{
+	unsigned int pfx_len;
+	unsigned int i, idx;
+	__be32 mask;
+	__sum16 sum;
+
+	pfx_len = max(npt->src_pfx_len, npt->dst_pfx_len);
+	for (i = 0; i < pfx_len; i += 32) {
+		if (pfx_len - i >= 32)
+			mask = 0;
+		else
+			mask = htonl(~((1 << (pfx_len - i)) - 1));
+
+		idx = i / 32;
+		addr->s6_addr32[idx] &= mask;
+		addr->s6_addr32[idx] |= npt->dst_pfx.in6.s6_addr32[idx];
+	}
+
+	if (pfx_len <= 48)
+		idx = 3;
+	else {
+		for (idx = 4; idx < ARRAY_SIZE(addr->s6_addr16); idx++) {
+			if ((__force __sum16)addr->s6_addr16[idx] !=
+			    CSUM_MANGLED_0)
+				break;
+		}
+		if (idx == ARRAY_SIZE(addr->s6_addr16))
+			return false;
+	}
+
+	sum = csum16_add((__force __sum16)addr->s6_addr16[idx],
+			 npt->adjustment);
+	if (sum == CSUM_MANGLED_0)
+		sum = 0;
+	*(__force __sum16 *)&addr->s6_addr16[idx] = sum;
+
+	return true;
+}
+
+static unsigned int
+ip6t_snpt_tg(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct ip6t_npt_tginfo *npt = par->targinfo;
+
+	if (!ip6t_npt_map_pfx(npt, &ipv6_hdr(skb)->saddr)) {
+		icmpv6_send(skb, ICMPV6_PARAMPROB, ICMPV6_HDR_FIELD,
+			    offsetof(struct ipv6hdr, saddr));
+		return NF_DROP;
+	}
+	return XT_CONTINUE;
+}
+
+static unsigned int
+ip6t_dnpt_tg(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct ip6t_npt_tginfo *npt = par->targinfo;
+
+	if (!ip6t_npt_map_pfx(npt, &ipv6_hdr(skb)->daddr)) {
+		icmpv6_send(skb, ICMPV6_PARAMPROB, ICMPV6_HDR_FIELD,
+			    offsetof(struct ipv6hdr, daddr));
+		return NF_DROP;
+	}
+	return XT_CONTINUE;
+}
+
+static struct xt_target ip6t_npt_target_reg[] __read_mostly = {
+	{
+		.name		= "SNPT",
+		.target		= ip6t_snpt_tg,
+		.targetsize	= sizeof(struct ip6t_npt_tginfo),
+		.checkentry	= ip6t_npt_checkentry,
+		.family		= NFPROTO_IPV6,
+		.hooks		= (1 << NF_INET_LOCAL_IN) |
+				  (1 << NF_INET_POST_ROUTING),
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "DNPT",
+		.target		= ip6t_dnpt_tg,
+		.targetsize	= sizeof(struct ip6t_npt_tginfo),
+		.checkentry	= ip6t_npt_checkentry,
+		.family		= NFPROTO_IPV6,
+		.hooks		= (1 << NF_INET_PRE_ROUTING) |
+				  (1 << NF_INET_LOCAL_OUT),
+		.me		= THIS_MODULE,
+	},
+};
+
+static int __init ip6t_npt_init(void)
+{
+	return xt_register_targets(ip6t_npt_target_reg,
+				   ARRAY_SIZE(ip6t_npt_target_reg));
+}
+
+static void __exit ip6t_npt_exit(void)
+{
+	xt_unregister_targets(ip6t_npt_target_reg,
+			      ARRAY_SIZE(ip6t_npt_target_reg));
+}
+
+module_init(ip6t_npt_init);
+module_exit(ip6t_npt_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("IPv6-to-IPv6 Network Prefix Translation (RFC 6296)");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_ALIAS("ip6t_SNPT");
+MODULE_ALIAS("ip6t_DNPT");
-- 
1.7.1

