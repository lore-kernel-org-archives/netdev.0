From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH] NETFILTER module xt_hmark new target for HASH MARK
Date: Thu, 3 Feb 2011 14:34:09 +0100
Message-ID: <1296740050-6311-2-git-send-email-hans.schillstrom@ericsson.com>
References: <1296740050-6311-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: <kaber@trash.net>, <jengelh@medozas.de>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:50427 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932112Ab1BCNeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 08:34:13 -0500
In-Reply-To: <1296740050-6311-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The target allows you to create rules in the "raw" and "mangle" tables
which alter the netfilter mark (nfmark) field within a given range.
First a 32 bit hash value is generated then modulus by <limit> and
finally an offset is added before it's written to nfmark.
Prior to routing, the nfmark can influence the routing method (see
"Use netfilter MARK value as routing key") and can also be used by
other subsystems to change their behavior.

man page
   HMARK
       This  module  does  the same as MARK, i.e. set an fwmark,
       but the mark is based on a hash value.  The hash is based on
       saddr, daddr, sport, dport and proto. The same mark will be produced
       independet of direction if no masks is set or the same masks is used for
       src and dest. The hash mark could be adjusted by modulus and finaly an
       offset could be added, i.e the final mark will be within a range.
       ICMP errors will have hash calc based on the original message.
       Note: None of the parameters effect the packet it self
       only the calculated hash value.

       Parameters: For all masks default is all "1:s", to disable a field
                   use mask 0. For IPv6 it's just the last 32 bits that
                   is included in the hash.

       --hmark-smask value
              The value to AND the source address with (saddr & value).

       --hmark-dmask value
              The value to AND the dest. address with (daddr & value).

       --hmark-sp-mask value
              A 16 bit value to AND the src port with (sport & value).

       --hmark-dp-mask value
              A 16 bit value to AND the dest port with (dport & value).

       --hmark-sp-set value
              A 16 bit value to OR the src port with (sport | value).

       --hmark-dp-set value
              A 16 bit value to OR the dest port with (dport | value).

       --hmark-spi-mask value
              Value to AND the spi field with (spi & value) valid for proto esp or ah.

       --hmark-spi-set value
              Value to OR the spi field with (spi | value) valid for proto esp or ah.

       --hmark-proto-mask value
              A 16 bit value to AND the L4 proto field with (proto & value).

       --hmark-rnd value
              A 32 bit intitial value for hash calc, default is 0xc175a3b8.

       Final processing of the mark in order of execution.

       --hmark-mod value (must be > 0)
              The easiest way to describe this is:  hash = hash mod <value>

       --hmark-offs alue (must be > 0)
              The easiest way to describe this is:  hash = hash + <value>

       Examples:

       Default rule handles all TCP, UDP, SCTP, ESP & AH

              iptables -t mangle -A PREROUTING \
               -j HMARK --hmark-offs 10000 --hmark-mod 10

       Handle SCTP and hash dest port only and produce a nfmark between 100-119.

              iptables -t mangle -A PREROUTING -p SCTP -j HMARK --smask 0 --dmask 0
               --sp-mask 0 --offs 100 --mod 20

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/linux/netfilter/xt_hmark.h |   28 ++++
 net/netfilter/Kconfig              |   18 +++
 net/netfilter/Makefile             |    1 +
 net/netfilter/xt_hmark.c           |  245 ++++++++++++++++++++++++++++++++++++
 4 files changed, 292 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_hmark.h
 create mode 100644 net/netfilter/xt_hmark.c

diff --git a/include/linux/netfilter/xt_hmark.h b/include/linux/netfilter/xt_hmark.h
new file mode 100644
index 0000000..3f7ecc6
--- /dev/null
+++ b/include/linux/netfilter/xt_hmark.h
@@ -0,0 +1,28 @@
+#ifndef XT_HMARK_H_
+#define XT_HMARK_H_
+
+#include <linux/types.h>
+
+union ports {
+	struct {
+		__u16	src;
+		__u16	dst;
+	} p16;
+	__u32	v32;
+};
+
+struct xt_hmark_info {
+	__u32		smask;		/* Source address mask */
+	__u32		dmask;		/* Dest address mask */
+	union ports	pmask;
+	union ports	pset;
+	__u32		spimask;
+	__u32		spiset;
+	__u16		flags;		/* Print out only */
+	__u16		prmask;		/* L4 Proto mask */
+	__u32		hashrnd;
+	__u32		hmod;		/* Modulus */
+	__u32		hoffs;		/* Offset */
+};
+
+#endif /* XT_HMARK_H_ */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 82a6e0d..2115079 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -471,6 +471,24 @@ config NETFILTER_XT_TARGET_HL
 	since you can easily create immortal packets that loop
 	forever on the network.
 
+config NETFILTER_XT_TARGET_HMARK
+	tristate '"HMARK" target support'
+	depends on NETFILTER_ADVANCED
+	select IP6_NF_IPTABLES if IPV6
+	---help---
+	This option adds the "HMARK" target.
+
+	The target allows you to create rules in the "raw" and "mangle" tables
+	which alter the netfilter mark (nfmark) field within a given range.
+	First a 32 bit hash value is generated then modulus by <limit> and
+	finally an offset is added before it's written to nfmark.
+
+	Prior to routing, the nfmark can influence the routing method (see
+	"Use netfilter MARK value as routing key") and can also be used by
+	other subsystems to change their behavior.
+
+	The mark match can also be used to match nfmark produced by this module.
+
 config NETFILTER_XT_TARGET_IDLETIMER
 	tristate  "IDLETIMER target support"
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index d57a890..b24a5e6 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -56,6 +56,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CT) += xt_CT.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_DSCP) += xt_DSCP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_HL) += xt_HL.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_HMARK) += xt_hmark.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_LED) += xt_LED.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) += xt_NFLOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) += xt_NFQUEUE.o
diff --git a/net/netfilter/xt_hmark.c b/net/netfilter/xt_hmark.c
new file mode 100644
index 0000000..d4b8257
--- /dev/null
+++ b/net/netfilter/xt_hmark.c
@@ -0,0 +1,245 @@
+/*
+ *	xt_hmark - Netfilter module to set mark as hash value
+ *
+ *	(C) 2010 Hans Schillstrom <hans.schillstrom@ericsson.com>
+ *
+ *	Description:
+ *	This module calculates a hash value that can be modified by modulus
+ *	and an offset. The hash value is based on a direction independent
+ *	five tuple: src & dst addr src & dst ports and protocol.
+ *	However src & dst port can be masked and are not used for fragmented
+ *	packets, ESP and AH don't have ports so SPI will be used instead.
+ *	For ICMP error messages the hash mark values will be calculated on
+ *	the source packet i.e. the packet caused the error (If sufficient
+ *	amount of data exists).
+ *
+ *	This program is free software; you can redistribute it and/or modify
+ *	it under the terms of the GNU General Public License version 2 as
+ *	published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <net/ip.h>
+#include <linux/icmp.h>
+
+#include <linux/netfilter/xt_hmark.h>
+#include <linux/netfilter/x_tables.h>
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#	define WITH_IPV6 1
+#include <net/ipv6.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#endif
+
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Hans Schillstrom <hans.schillstrom@ericsson.com>");
+MODULE_DESCRIPTION("Xtables: packet range mark operations by hash value");
+MODULE_ALIAS("ipt_HMARK");
+MODULE_ALIAS("ip6t_HMARK");
+
+/*
+ * ICMP, get inner header so calc can be made on the source message
+ *       not the icmp header, i.e. same hash mark must be produced
+ *       on an icmp error message.
+ */
+static int get_inner_hdr(struct sk_buff *skb, int iphsz, int nhoff)
+{
+	const struct icmphdr *icmph;
+	struct icmphdr _ih;
+	struct iphdr *iph = NULL;
+
+	/* Not enough header? */
+	icmph = skb_header_pointer(skb, nhoff + iphsz, sizeof(_ih), &_ih);
+	if (icmph == NULL)
+		goto out;
+
+	if (icmph->type > NR_ICMP_TYPES)
+		goto out;
+
+
+	/* Error message? */
+	if (icmph->type != ICMP_DEST_UNREACH &&
+	    icmph->type != ICMP_SOURCE_QUENCH &&
+	    icmph->type != ICMP_TIME_EXCEEDED &&
+	    icmph->type != ICMP_PARAMETERPROB &&
+	    icmph->type != ICMP_REDIRECT)
+		goto out;
+	/* Checkin full IP header plus 8 bytes of protocol to
+	 * avoid additional coding at protocol handlers.
+	 */
+	if (!pskb_may_pull(skb, nhoff + iphsz + sizeof(_ih) + 8))
+		goto out;
+
+	iph = (struct iphdr *)(skb->data + nhoff + iphsz + sizeof(_ih));
+	return nhoff + iphsz + sizeof(_ih);
+out:
+	return nhoff;
+}
+/*
+ * ICMPv6
+ * Input nhoff Offset into network header
+ *       offset where ICMPv6 header starts
+ * Returns offset to icmp embedded msg or nhoff
+ */
+#ifdef WITH_IPV6
+static int get_inner6_hdr(struct sk_buff *skb, int nhoff, int offset)
+{
+	struct icmp6hdr *icmp6h;
+	struct icmp6hdr _ih6;
+
+	icmp6h = skb_header_pointer(skb, offset, sizeof(_ih6), &_ih6);
+	if (icmp6h == NULL)
+		goto out;
+
+	if (icmp6h->icmp6_type && icmp6h->icmp6_type < 128)
+		return offset + sizeof(_ih6);
+
+out:
+	return nhoff;
+}
+#endif
+/*
+ * Calc hash value, special casre is taken on icmp and fragmented messages
+ * i.e. fragmented messages don't use ports.
+ */
+static __u32 get_hash(struct sk_buff *skb, struct xt_hmark_info *info)
+{
+	int nhoff, hash = 0, poff, proto;
+	struct iphdr *ip;
+	u8 ip_proto;
+	u32 addr1, addr2, ihl;
+	union {
+		u32 v32;
+		u16 v16[2];
+	} ports;
+
+	nhoff = skb_network_offset(skb);
+	proto = skb->protocol;
+
+	if (!proto && skb->sk) {
+		if (skb->sk->sk_family == AF_INET)
+			proto = __constant_htons(ETH_P_IP);
+		else if (skb->sk->sk_family == AF_INET6)
+			proto = __constant_htons(ETH_P_IPV6);
+	}
+
+	switch (proto) {
+	case __constant_htons(ETH_P_IP):
+		if (!pskb_may_pull(skb, sizeof(*ip) + nhoff))
+			goto done;
+
+		ip = (struct iphdr *) (skb->data + nhoff);
+		if (ip->protocol == IPPROTO_ICMP) {
+			/* Switch hash calc to inner header ? */
+			nhoff = get_inner_hdr(skb, ip->ihl * 4, nhoff);
+			ip = (struct iphdr *) (skb->data + nhoff);
+		}
+
+		if (ip->frag_off & htons(IP_MF | IP_OFFSET))
+			ip_proto = 0;
+		else
+			ip_proto = ip->protocol;
+
+		addr1 = (__force u32) ip->saddr & info->smask;
+		addr2 = (__force u32) ip->daddr & info->dmask;
+		ihl = ip->ihl;
+		break;
+#ifdef WITH_IPV6
+	case __constant_htons(ETH_P_IPV6):
+	{
+		struct ipv6hdr *ip6;
+		int ptr;
+
+		if (!pskb_may_pull(skb, sizeof(*ip6) + nhoff))
+			goto done;
+
+		ip6 = (struct ipv6hdr *) (skb->data + nhoff);
+
+		/* if (ip6->nexthdr == IPPROTO_ICMPV6) { */
+		if (ipv6_find_hdr(skb, &ptr, IPPROTO_ICMPV6, NULL) >= 0) {
+			nhoff = get_inner6_hdr(skb, nhoff, ptr);
+			ip6 = (struct ipv6hdr *) (skb->data + nhoff);
+		}
+		if (ipv6_find_hdr(skb, &ptr, NEXTHDR_FRAGMENT, NULL) < 0)
+			ip_proto = ip6->nexthdr;
+		else
+			ip_proto = 0;	/* It's a fragment */
+
+		addr1 = (__force u32) ip6->saddr.s6_addr32[3];
+		addr2 = (__force u32) ip6->daddr.s6_addr32[3];
+		ihl = (40 >> 2);
+		break;
+	}
+#endif
+	default:
+		goto done;
+	}
+
+	ports.v32 = 0;
+	poff = proto_ports_offset(ip_proto);
+	nhoff += ihl * 4 + poff;
+	if (poff >= 0 && pskb_may_pull(skb, nhoff + 4)) {
+		ports.v32 = * (__force u32 *) (skb->data + nhoff);
+		if (ip_proto == IPPROTO_ESP || ip_proto == IPPROTO_AH) {
+			ports.v32 = (ports.v32 & info->spimask) | info->spiset;
+		} else {
+			ports.v32 = (ports.v32 & info->pmask.v32) |
+				    info->pset.v32;
+			if (ports.v16[1] < ports.v16[0])
+				swap(ports.v16[0], ports.v16[1]);
+		}
+	}
+	ip_proto &= info->prmask;
+	/* get a consistent hash (same value on both flow directions) */
+	if (addr2 < addr1)
+		swap(addr1, addr2);
+
+	hash = jhash_3words(addr1, addr2, ports.v32, info->hashrnd) ^ ip_proto;
+	if (!hash)
+		hash = 1;
+
+	return hash;
+
+done:
+	return 0;
+}
+
+static unsigned int
+hmark_tg(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	struct xt_hmark_info *info = (struct xt_hmark_info *)par->targinfo;
+	__u32 hash = get_hash(skb, info);
+
+	if (info->hmod && hash)
+		skb->mark = (hash % info->hmod) + info->hoffs;
+	return XT_CONTINUE;
+}
+
+static struct xt_target hmark_tg_reg __read_mostly = {
+	.name           = "HMARK",
+	.revision       = 0,
+	.family         = NFPROTO_UNSPEC,
+	.target         = hmark_tg,
+	.targetsize     = sizeof(struct xt_hmark_info),
+	.me             = THIS_MODULE,
+};
+
+static int __init hmark_mt_init(void)
+{
+	int ret;
+
+	ret = xt_register_target(&hmark_tg_reg);
+	if (ret < 0)
+		return ret;
+	return 0;
+}
+
+static void __exit hmark_mt_exit(void)
+{
+	xt_unregister_target(&hmark_tg_reg);
+}
+
+module_init(hmark_mt_init);
+module_exit(hmark_mt_exit);
-- 
1.7.2.3

