From: kaber@trash.net
Subject: [PATCH 62/79] netfilter: audit target to record accepted/dropped packets
Date: Wed, 19 Jan 2011 20:15:02 +0100
Message-ID: <1295464519-21763-63-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51979 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753466Ab1ASTPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:40 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>

This patch adds a new netfilter target which creates audit records
for packets traversing a certain chain.

It can be used to record packets which are rejected administraively
as follows:

  -N AUDIT_DROP
  -A AUDIT_DROP -j AUDIT --type DROP
  -A AUDIT_DROP -j DROP

a rule which would typically drop or reject a packet would then
invoke the new chain to record packets before dropping them.

  -j AUDIT_DROP

The module is protocol independant and works for iptables, ip6tables
and ebtables.

The following information is logged:
 - netfilter hook
 - packet length
 - incomming/outgoing interface
 - MAC src/dst/proto for ethernet packets
 - src/dst/protocol address for IPv4/IPv6
 - src/dst port for TCP/UDP/UDPLITE
 - icmp type/code

Cc: Patrick McHardy <kaber@trash.net>
Cc: Eric Paris <eparis@parisplace.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Thomas Graf <tgraf@redhat.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/audit.h              |    1 +
 include/linux/netfilter/Kbuild     |    1 +
 include/linux/netfilter/xt_AUDIT.h |   30 ++++++
 net/netfilter/Kconfig              |   10 ++
 net/netfilter/Makefile             |    1 +
 net/netfilter/xt_AUDIT.c           |  204 ++++++++++++++++++++++++++++++++++++
 6 files changed, 247 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_AUDIT.h
 create mode 100644 net/netfilter/xt_AUDIT.c

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 8b5c062..ae227df 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -103,6 +103,7 @@
 #define AUDIT_BPRM_FCAPS	1321	/* Information about fcaps increasing perms */
 #define AUDIT_CAPSET		1322	/* Record showing argument to sys_capset */
 #define AUDIT_MMAP		1323	/* Record showing descriptor and flags in mmap */
+#define AUDIT_NETFILTER_PKT	1324	/* Packets traversing netfilter chains */
 
 #define AUDIT_AVC		1400	/* SE Linux avc denial or grant */
 #define AUDIT_SELINUX_ERR	1401	/* Internal SE Linux Errors */
diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index 9d40eff..9f11fbc 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -9,6 +9,7 @@ header-y += nfnetlink_conntrack.h
 header-y += nfnetlink_log.h
 header-y += nfnetlink_queue.h
 header-y += x_tables.h
+header-y += xt_AUDIT.h
 header-y += xt_CHECKSUM.h
 header-y += xt_CLASSIFY.h
 header-y += xt_CONNMARK.h
diff --git a/include/linux/netfilter/xt_AUDIT.h b/include/linux/netfilter/xt_AUDIT.h
new file mode 100644
index 0000000..38751d2
--- /dev/null
+++ b/include/linux/netfilter/xt_AUDIT.h
@@ -0,0 +1,30 @@
+/*
+ * Header file for iptables xt_AUDIT target
+ *
+ * (C) 2010-2011 Thomas Graf <tgraf@redhat.com>
+ * (C) 2010-2011 Red Hat, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _XT_AUDIT_TARGET_H
+#define _XT_AUDIT_TARGET_H
+
+#include <linux/types.h>
+
+enum {
+	XT_AUDIT_TYPE_ACCEPT = 0,
+	XT_AUDIT_TYPE_DROP,
+	XT_AUDIT_TYPE_REJECT,
+	__XT_AUDIT_TYPE_MAX,
+};
+
+#define XT_AUDIT_TYPE_MAX (__XT_AUDIT_TYPE_MAX - 1)
+
+struct xt_audit_info {
+	__u8 type; /* XT_AUDIT_TYPE_* */
+};
+
+#endif /* _XT_AUDIT_TARGET_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 1b79353..93918f0 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -326,6 +326,16 @@ config NETFILTER_XT_CONNMARK
 
 comment "Xtables targets"
 
+config NETFILTER_XT_TARGET_AUDIT
+	tristate "AUDIT target support"
+	depends on AUDIT
+	depends on NETFILTER_ADVANCED
+	---help---
+	  This option adds a 'AUDIT' target, which can be used to create
+	  audit records for packets dropped/accepted.
+
+	  To compileit as a module, choose M here. If unsure, say N.
+
 config NETFILTER_XT_TARGET_CHECKSUM
 	tristate "CHECKSUM target support"
 	depends on IP_NF_MANGLE || IP6_NF_MANGLE
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 441050f..401d574 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -45,6 +45,7 @@ obj-$(CONFIG_NETFILTER_XT_MARK) += xt_mark.o
 obj-$(CONFIG_NETFILTER_XT_CONNMARK) += xt_connmark.o
 
 # targets
+obj-$(CONFIG_NETFILTER_XT_TARGET_AUDIT) += xt_AUDIT.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CHECKSUM) += xt_CHECKSUM.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CLASSIFY) += xt_CLASSIFY.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
diff --git a/net/netfilter/xt_AUDIT.c b/net/netfilter/xt_AUDIT.c
new file mode 100644
index 0000000..81802d2
--- /dev/null
+++ b/net/netfilter/xt_AUDIT.c
@@ -0,0 +1,204 @@
+/*
+ * Creates audit record for dropped/accepted packets
+ *
+ * (C) 2010-2011 Thomas Graf <tgraf@redhat.com>
+ * (C) 2010-2011 Red Hat, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+*/
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/audit.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/if_arp.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_AUDIT.h>
+#include <net/ipv6.h>
+#include <net/ip.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Thomas Graf <tgraf@redhat.com>");
+MODULE_DESCRIPTION("Xtables: creates audit records for dropped/accepted packets");
+MODULE_ALIAS("ipt_AUDIT");
+MODULE_ALIAS("ip6t_AUDIT");
+MODULE_ALIAS("ebt_AUDIT");
+MODULE_ALIAS("arpt_AUDIT");
+
+static void audit_proto(struct audit_buffer *ab, struct sk_buff *skb,
+			unsigned int proto, unsigned int offset)
+{
+	switch (proto) {
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+	case IPPROTO_UDPLITE: {
+		const __be16 *pptr;
+		__be16 _ports[2];
+
+		pptr = skb_header_pointer(skb, offset, sizeof(_ports), _ports);
+		if (pptr == NULL) {
+			audit_log_format(ab, " truncated=1");
+			return;
+		}
+
+		audit_log_format(ab, " sport=%hu dport=%hu",
+				 ntohs(pptr[0]), ntohs(pptr[1]));
+		}
+		break;
+
+	case IPPROTO_ICMP:
+	case IPPROTO_ICMPV6: {
+		const u8 *iptr;
+		u8 _ih[2];
+
+		iptr = skb_header_pointer(skb, offset, sizeof(_ih), &_ih);
+		if (iptr == NULL) {
+			audit_log_format(ab, " truncated=1");
+			return;
+		}
+
+		audit_log_format(ab, " icmptype=%hhu icmpcode=%hhu",
+				 iptr[0], iptr[1]);
+
+		}
+		break;
+	}
+}
+
+static void audit_ip4(struct audit_buffer *ab, struct sk_buff *skb)
+{
+	struct iphdr _iph;
+	const struct iphdr *ih;
+
+	ih = skb_header_pointer(skb, 0, sizeof(_iph), &_iph);
+	if (!ih) {
+		audit_log_format(ab, " truncated=1");
+		return;
+	}
+
+	audit_log_format(ab, " saddr=%pI4 daddr=%pI4 ipid=%hu proto=%hhu",
+		&ih->saddr, &ih->daddr, ntohs(ih->id), ih->protocol);
+
+	if (ntohs(ih->frag_off) & IP_OFFSET) {
+		audit_log_format(ab, " frag=1");
+		return;
+	}
+
+	audit_proto(ab, skb, ih->protocol, ih->ihl * 4);
+}
+
+static void audit_ip6(struct audit_buffer *ab, struct sk_buff *skb)
+{
+	struct ipv6hdr _ip6h;
+	const struct ipv6hdr *ih;
+	u8 nexthdr;
+	int offset;
+
+	ih = skb_header_pointer(skb, skb_network_offset(skb), sizeof(_ip6h), &_ip6h);
+	if (!ih) {
+		audit_log_format(ab, " truncated=1");
+		return;
+	}
+
+	nexthdr = ih->nexthdr;
+	offset = ipv6_skip_exthdr(skb, skb_network_offset(skb) + sizeof(_ip6h),
+				  &nexthdr);
+
+	audit_log_format(ab, " saddr=%pI6c daddr=%pI6c proto=%hhu",
+			 &ih->saddr, &ih->daddr, nexthdr);
+
+	if (offset)
+		audit_proto(ab, skb, nexthdr, offset);
+}
+
+static unsigned int
+audit_tg(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct xt_audit_info *info = par->targinfo;
+	struct audit_buffer *ab;
+
+	ab = audit_log_start(NULL, GFP_ATOMIC, AUDIT_NETFILTER_PKT);
+	if (ab == NULL)
+		goto errout;
+
+	audit_log_format(ab, "action=%hhu hook=%u len=%u inif=%s outif=%s",
+			 info->type, par->hooknum, skb->len,
+			 par->in ? par->in->name : "?",
+			 par->out ? par->out->name : "?");
+
+	if (skb->mark)
+		audit_log_format(ab, " mark=%#x", skb->mark);
+
+	if (skb->dev && skb->dev->type == ARPHRD_ETHER) {
+		audit_log_format(ab, " smac=%pM dmac=%pM macproto=0x%04x",
+				 eth_hdr(skb)->h_source, eth_hdr(skb)->h_dest,
+				 ntohs(eth_hdr(skb)->h_proto));
+
+		if (par->family == NFPROTO_BRIDGE) {
+			switch (eth_hdr(skb)->h_proto) {
+			case __constant_htons(ETH_P_IP):
+				audit_ip4(ab, skb);
+				break;
+
+			case __constant_htons(ETH_P_IPV6):
+				audit_ip6(ab, skb);
+				break;
+			}
+		}
+	}
+
+	switch (par->family) {
+	case NFPROTO_IPV4:
+		audit_ip4(ab, skb);
+		break;
+
+	case NFPROTO_IPV6:
+		audit_ip6(ab, skb);
+		break;
+	}
+
+	audit_log_end(ab);
+
+errout:
+	return XT_CONTINUE;
+}
+
+static int audit_tg_check(const struct xt_tgchk_param *par)
+{
+	const struct xt_audit_info *info = par->targinfo;
+
+	if (info->type > XT_AUDIT_TYPE_MAX) {
+		pr_info("Audit type out of range (valid range: 0..%hhu)\n",
+			XT_AUDIT_TYPE_MAX);
+		return -ERANGE;
+	}
+
+	return 0;
+}
+
+static struct xt_target audit_tg_reg __read_mostly = {
+	.name		= "AUDIT",
+	.family		= NFPROTO_UNSPEC,
+	.target		= audit_tg,
+	.targetsize	= sizeof(struct xt_audit_info),
+	.checkentry	= audit_tg_check,
+	.me		= THIS_MODULE,
+};
+
+static int __init audit_tg_init(void)
+{
+	return xt_register_target(&audit_tg_reg);
+}
+
+static void __exit audit_tg_exit(void)
+{
+	xt_unregister_target(&audit_tg_reg);
+}
+
+module_init(audit_tg_init);
+module_exit(audit_tg_exit);
-- 
1.7.2.3

