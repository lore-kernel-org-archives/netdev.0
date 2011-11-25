From: Hans Schillstrom <hans@schillstrom.com>
Subject: [v4 PATCH 1/2] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Fri, 25 Nov 2011 10:36:26 +0100
Message-ID: <1322213787-25796-2-git-send-email-hans@schillstrom.com>
References: <1322213787-25796-1-git-send-email-hans@schillstrom.com>
Cc: hans.schillstrom@ericsson.com
To: kaber@trash.net, pablo@netfilter.org, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1322213787-25796-1-git-send-email-hans@schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

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

       --hmark-dnat
              Replace src addr/port with original dst addr/port before calc, hash

       --hmark-snat
              Replace dst addr/port with original src addr/port before calc, hash

       Final processing of the mark in order of execution.

       --hmark-mod value (must be > 0)
              The easiest way to describe this is:  hash = hash mod <value>

       --hmark-offs alue (must be > 0)
              The easiest way to describe this is:  hash = hash + <value>

       Examples:

       Default rule handles all TCP, UDP, SCTP, ESP & AH
Rev 4
      different targets for IPv4 and IPv6
      Changes based on review by Pablo.

Rev 3
      Support added to SCTP for IPv6
Rev 2
      IPv6 header scan changed to follow RFC 2640
      IPv4 icmp echo fragmented does now use proto as ipv6
      IPv6 pskb_may_pull() check is done in every time in header loop.
      IPv4 nat support added.
      default added in IPv6 loop and null check of hp

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/linux/netfilter/xt_hmark.h |   48 ++++++
 include/net/ipv6.h                 |    1 +
 net/netfilter/Kconfig              |   17 ++
 net/netfilter/Makefile             |    1 +
 net/netfilter/xt_hmark.c           |  327 ++++++++++++++++++++++++++++++++++++
 5 files changed, 394 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_hmark.h
 create mode 100644 net/netfilter/xt_hmark.c

diff --git a/include/linux/netfilter/xt_hmark.h b/include/linux/netfilter/xt_hmark.h
new file mode 100644
index 0000000..6c1436a
--- /dev/null
+++ b/include/linux/netfilter/xt_hmark.h
@@ -0,0 +1,48 @@
+#ifndef XT_HMARK_H_
+#define XT_HMARK_H_
+
+#include <linux/types.h>
+
+/*
+ * Flags must not start at 0, since it's used as none.
+ */
+enum {
+	XT_HMARK_SADR_AND = 1,	/* SNAT & DNAT are used by the kernel module */
+	XT_HMARK_DADR_AND,
+	XT_HMARK_SPI_AND,
+	XT_HMARK_SPI_OR,
+	XT_HMARK_SPORT_AND,
+	XT_HMARK_DPORT_AND,
+	XT_HMARK_SPORT_OR,
+	XT_HMARK_DPORT_OR,
+	XT_HMARK_PROTO_AND,
+	XT_HMARK_RND,
+	XT_HMARK_MODULUS,
+	XT_HMARK_OFFSET,
+	XT_HMARK_USE_SNAT,
+	XT_HMARK_USE_DNAT,
+};
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
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 3f0258d..9e4d4f9 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -39,6 +39,7 @@
 #define NEXTHDR_ICMP		58	/* ICMP for IPv6. */
 #define NEXTHDR_NONE		59	/* No next header */
 #define NEXTHDR_DEST		60	/* Destination options header. */
+#define NEXTHDR_SCTP		132	/* Stream Control Transport Protocol */
 #define NEXTHDR_MOBILITY	135	/* Mobility header. */
 
 #define NEXTHDR_MAX		255
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 8260b13..41bee43 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -471,6 +471,23 @@ config NETFILTER_XT_TARGET_HL
 	since you can easily create immortal packets that loop
 	forever on the network.
 
+config NETFILTER_XT_TARGET_HMARK
+	tristate '"HMARK" target support'
+	depends on NETFILTER_ADVANCED
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
index 1a02853..359eeb6 100644
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
index 0000000..ae33293
--- /dev/null
+++ b/net/netfilter/xt_hmark.c
@@ -0,0 +1,327 @@
+/*
+ *	xt_hmark - Netfilter module to set mark as hash value
+ *
+ *	(C) 2011 Hans Schillstrom <hans.schillstrom@ericsson.com>
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
+#include <net/netfilter/nf_nat.h>
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
+		return nhoff;
+
+	if (icmph->type > NR_ICMP_TYPES)
+		return nhoff;
+
+	/* Error message? */
+	if (icmph->type != ICMP_DEST_UNREACH &&
+	    icmph->type != ICMP_SOURCE_QUENCH &&
+	    icmph->type != ICMP_TIME_EXCEEDED &&
+	    icmph->type != ICMP_PARAMETERPROB &&
+	    icmph->type != ICMP_REDIRECT)
+		return nhoff;
+	/* Checkin full IP header plus 8 bytes of protocol to
+	 * avoid additional coding at protocol handlers.
+	 */
+	if (!pskb_may_pull(skb, nhoff + iphsz + sizeof(_ih) + 8))
+		return nhoff;
+
+	iph = (struct iphdr *)(skb->data + nhoff + iphsz + sizeof(_ih));
+	return nhoff + iphsz + sizeof(_ih);
+}
+/*
+ * ICMPv6
+ * Input nhoff Offset into network header
+ *       offset where ICMPv6 header starts
+ * Returns true if it's a icmp error and updates nhoff
+ */
+#ifdef WITH_IPV6
+static int get_inner6_hdr(struct sk_buff *skb, int *offset, int hdrlen)
+{
+	struct icmp6hdr *icmp6h;
+	struct icmp6hdr _ih6;
+
+	icmp6h = skb_header_pointer(skb, *offset + hdrlen, sizeof(_ih6), &_ih6);
+	if (icmp6h == NULL)
+		return 0;
+
+	if (icmp6h->icmp6_type && icmp6h->icmp6_type < 128) {
+		*offset += hdrlen + sizeof(_ih6);
+		return 1;
+	}
+	return 0;
+}
+/*
+ * Calc hash value, special casre is taken on icmp and fragmented messages
+ * i.e. fragmented messages don't use ports.
+ */
+__u32 hmark_v6(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	struct xt_hmark_info *info = (struct xt_hmark_info *)par->targinfo;
+	int nhoff, poff, hdrlen;
+	u32 addr1, addr2, hash;
+	struct ipv6hdr *ip6;
+	u8 nexthdr;
+	int frag = 0, ip6hdrlvl = 0;	/* Header level */
+	struct ipv6_opt_hdr _hdr, *hp;
+	union {
+		u32 v32;
+		u16 v16[2];
+	} ports;
+
+	ports.v32 = 0;
+	nhoff = skb_network_offset(skb);
+
+hdr_new:
+	/* Get header info */
+	ip6 = (struct ipv6hdr *) (skb->data + nhoff);
+	nexthdr = ip6->nexthdr;
+	hdrlen = sizeof(struct ipv6hdr);
+	hp = skb_header_pointer(skb, nhoff + hdrlen, sizeof(_hdr), &_hdr);
+
+	while (nexthdr) {
+		switch (nexthdr) {
+		case IPPROTO_ICMPV6:
+			/* ICMP Error then move ptr to inner header */
+			if (get_inner6_hdr(skb, &nhoff, hdrlen)) {
+				ip6hdrlvl++;
+				if (!pskb_may_pull(skb, sizeof(_hdr) + nhoff))
+					return XT_CONTINUE;
+				goto hdr_new;
+			}
+			nhoff += hdrlen;
+			goto hdr_rdy;
+
+		case NEXTHDR_FRAGMENT:
+			if (!ip6hdrlvl) /* Do not use ports if fragmented */
+				frag = 1;
+			break;
+
+		/* End of hdr traversing cont. with ports and hash calc. */
+		case NEXTHDR_IPV6:	/* Do not process tunnels */
+		case NEXTHDR_TCP:
+		case NEXTHDR_UDP:
+		case NEXTHDR_ESP:
+		case NEXTHDR_AUTH:
+		case NEXTHDR_SCTP:
+		case NEXTHDR_NONE:	/* Last hdr of something unknown */
+			nhoff += hdrlen;
+			goto hdr_rdy;
+		default:
+			return XT_CONTINUE;
+		}
+		if (!hp)
+			return XT_CONTINUE;
+		nhoff += hdrlen;	/* eat current header */
+		nexthdr =  hp->nexthdr;	/* Next header */
+		hdrlen = ipv6_optlen(hp);
+		hp = skb_header_pointer(skb, nhoff + hdrlen, sizeof(_hdr),
+					&_hdr);
+
+		if (!pskb_may_pull(skb, nhoff))
+			return XT_CONTINUE;
+	}
+hdr_rdy:
+
+	addr1 = (__force u32) ip6->saddr.s6_addr32[3];
+	addr2 = (__force u32) ip6->daddr.s6_addr32[3];
+	poff = proto_ports_offset(nexthdr);
+	nhoff += poff;
+	if (frag || poff < 0 || !pskb_may_pull(skb, nhoff + 4))
+		goto no6ports;
+
+	ports.v32 = * (__force u32 *) (skb->data + nhoff);
+	if (nexthdr == IPPROTO_ESP || nexthdr == IPPROTO_AH) {
+		ports.v32 = (ports.v32 & info->spimask) | info->spiset;
+	} else {
+		ports.v32 = (ports.v32 & info->pmask.v32) |
+				info->pset.v32;
+		/* get a consistent hash (same value on both flow directions) */
+		if (ports.v16[1] < ports.v16[0])
+			swap(ports.v16[0], ports.v16[1]);
+	}
+
+no6ports:
+	nexthdr &= info->prmask;
+	/* get a consistent hash (same value on both flow directions) */
+	if (addr2 < addr1)
+		swap(addr1, addr2);
+	hash = jhash_3words(addr1, addr2, ports.v32, info->hashrnd) ^ nexthdr;
+	if (info->hmod)
+		skb->mark = (hash % info->hmod) + info->hoffs;
+
+	return XT_CONTINUE;
+}
+#endif
+
+/*
+ * Calc hash value, special case is taken on icmp and fragmented messages
+ * i.e. fragmented messages don't use ports.
+ */
+unsigned int hmark_v4(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	struct xt_hmark_info *info = (struct xt_hmark_info *)par->targinfo;
+	int nhoff, poff, frag = 0;
+	struct iphdr *ip;
+	u8 ip_proto;
+	u32 addr1, addr2, hash;
+	u16 snatport = 0, dnatport = 0;
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+	union {
+		u32 v32;
+		u16 v16[2];
+	} ports;
+
+	nhoff = skb_network_offset(skb);
+	ports.v32 = 0;
+
+	ip = (struct iphdr *) (skb->data + nhoff);
+	if (ip->protocol == IPPROTO_ICMP) {
+		/* calc hash on inner header if right type */
+		nhoff = get_inner_hdr(skb, ip->ihl * 4, nhoff);
+		ip = (struct iphdr *) (skb->data + nhoff);
+	}
+
+	ip_proto = ip->protocol;
+	if (ip->frag_off & htons(IP_MF | IP_OFFSET))
+		frag = 1;
+
+	addr1 = (__force u32) ip->saddr & info->smask;
+	addr2 = (__force u32) ip->daddr & info->dmask;
+
+	if (ct && test_bit(IP_CT_IS_REPLY, &ct->status)) {
+		struct nf_conntrack_tuple *otuple;
+
+		otuple = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
+		/* On the "return flow", to get the original address
+		 * i,e, replace the source address. */
+		if ((ct->status & IPS_DST_NAT) &&
+			(info->flags & XT_HMARK_USE_DNAT)) {
+			addr1 = (__force u32) otuple->dst.u3.in.s_addr;
+			dnatport = otuple->dst.u.udp.port;
+		}
+		/* On the "return flow", to get the original address
+		 * i,e, replace the destination address. */
+		if ((ct->status & IPS_SRC_NAT) &&
+			(info->flags & XT_HMARK_USE_SNAT)) {
+			addr2 = (__force u32) otuple->src.u3.in.s_addr;
+			snatport = otuple->src.u.udp.port;
+		}
+	}
+
+	poff = proto_ports_offset(ip_proto);
+	nhoff += ip->ihl * 4 + poff;
+	if (frag || poff < 0 || !pskb_may_pull(skb, nhoff + 4))
+		goto noports;
+
+	ports.v32 = * (__force u32 *) (skb->data + nhoff);
+	if (ip_proto == IPPROTO_ESP || ip_proto == IPPROTO_AH) {
+		ports.v32 = (ports.v32 & info->spimask) | info->spiset;
+	} else {
+		if (snatport)	/* Replace nat'ed port(s) */
+			ports.v16[1] = snatport;
+		if (dnatport)
+			ports.v16[0] = dnatport;
+		ports.v32 = (ports.v32 & info->pmask.v32) |
+				info->pset.v32;
+		if (ports.v16[1] < ports.v16[0])
+			swap(ports.v16[0], ports.v16[1]);
+	}
+
+noports:
+	ip_proto &= info->prmask;
+	/* get a consistent hash (same value on both flow directions) */
+	if (addr2 < addr1)
+		swap(addr1, addr2);
+
+	hash = jhash_3words(addr1, addr2, ports.v32, info->hashrnd) ^ ip_proto;
+	if (info->hmod)
+		skb->mark = (hash % info->hmod) + info->hoffs;
+	return XT_CONTINUE;
+}
+
+static struct xt_target hmark_tg_reg[] __read_mostly = {
+	{
+		.name           = "HMARK",
+		.revision       = 0,
+		.family         = NFPROTO_IPV4,
+		.target         = hmark_v4,
+		.targetsize     = sizeof(struct xt_hmark_info),
+		.me             = THIS_MODULE,
+	},
+#ifdef WITH_IPV6
+	{
+		.name           = "HMARK",
+		.revision       = 0,
+		.family         = NFPROTO_IPV6,
+		.target         = hmark_v6,
+		.targetsize     = sizeof(struct xt_hmark_info),
+		.me             = THIS_MODULE,
+	},
+#endif
+};
+
+static int __init hmark_mt_init(void)
+{
+	int ret;
+
+	ret = xt_register_targets(hmark_tg_reg, ARRAY_SIZE(hmark_tg_reg));
+	if (ret < 0)
+		return ret;
+	return 0;
+}
+
+static void __exit hmark_mt_exit(void)
+{
+	xt_unregister_targets(hmark_tg_reg, ARRAY_SIZE(hmark_tg_reg));
+}
+
+module_init(hmark_mt_init);
+module_exit(hmark_mt_exit);
-- 
1.7.4.4

