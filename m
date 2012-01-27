From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [v8 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Fri, 27 Jan 2012 15:41:42 +0100
Message-ID: <1327675303-9059-3-git-send-email-hans.schillstrom@ericsson.com>
References: <1327675303-9059-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: <kaber@trash.net>, <pablo@netfilter.org>, <jengelh@medozas.de>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:53096 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755313Ab2A0Olr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 09:41:47 -0500
In-Reply-To: <1327675303-9059-1-git-send-email-hans.schillstrom@ericsson.com>
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
       This  module  does  the  same  as MARK, i.e. set an fwmark, but the mark
       is based on a hash value.  The hash is based on saddr, daddr, sport,
       dport and proto. The same mark will be produced independent of direction
       if no masks is set or the same masks is used for src and dest.
       The hash mark could be adjusted by modulus and finally an offset could
       be added, i.e the final mark will be within a range. ICMP error will use
       the the original message for hash calculation not the icmp it self.

       Note: IPv4 packets with nf_defrag_ipv4 loaded will be defragmented before they reach hmark,
             IPv6 nf_defrag is not implemented this way, hence fragmented ipv6 packets will reach hmark.
             Default behavior is to completely ignore any fragment if it reach hmark.
             --hmark-method L3 is fragment safe since neither ports or L4 protocol field is used.
             None of the parameters effect the packet it self only the calculated hash value.

       Parameters: Short hand methods

       --hmark-method L3
              Do not use L4 protocol field, ports or spi, only Layer 3 addresses,
              mask length of L3 addresses can still be used. Fragment or not
              does not matter in this case since only L3 address can be used in
              calc. of hash value.

       --hmark-method L3-4 (Default)
              Include  L4  in  calculation. of hash value i.e. all masks below are valid.
              Fragments will be ignored. (i.e no hash value produced)

       For all masks default is all "1:s", to disable a field use mask 0

       --hmark-src-mask length
              The length of the mask to AND the source address with (saddr & value).

       --hmark-dst-mask length
              The length of the mask to AND the dest. address with (daddr & value).

       --hmark-sport-mask value
              A 16 bit value to AND the src port with (sport & value).

       --hmark-dport-mask value
              A 16 bit value to AND the dest port with (dport & value).

       --hmark-sport-set value
              A 16 bit value to OR the src port with (sport | value).

       --hmark-dport-set value
              A 16 bit value to OR the dest port with (dport | value).

       --hmark-spi-mask value
              Value to AND the spi field with (spi & value) valid for proto esp or ah.

       --hmark-spi-set value
              Value to OR the spi field with (spi | value) valid for proto esp or ah.

       --hmark-proto-mask value
              An 8 bit value to AND the L4 proto field with (proto & value).

       --hmark-rnd value
              A 32 bit initial value for hash calc, default is 0xc175a3b8.

       Final processing of the mark in order of execution.

       --hmark-mod value (must be > 0)
              The easiest way to describe this is:  hash = hash mod <value>

       --hmark-offset value
              The easiest way to describe this is:  hash = hash + <value>

       Examples:

       Default rule handles all TCP, UDP, SCTP, ESP & AH

              iptables -t mangle -A PREROUTING -m state --state NEW,ESTABLISHED,RELATED
               -j HMARK --hmark-offset 10000 --hmark-mod 10

       Handle SCTP and hash dest port only and produce a nfmark between 100-119.

              iptables -t mangle -A PREROUTING -p SCTP -j HMARK --src-mask 0 --dst-mask 0
               --sp-mask 0 --offset 100 --mod 20

       No defragment by conntrack, None Fragments will have fwmark 100-119 and Fragments will have fwmark 120-139 (based on saddr  and  daddr
       only)

              iptables -t mangle -A PREROUTING -j HMARK --method L3-4 --mod 20 --offset 100

              iptables -t mangle -A PREROUTING -m mark --mark 0 -j HMARK --method L3 --mod 20 --offset 120

       Fragment safe Layer 3 only that keep a class C netw flow together

              iptables -t mangle -A PREROUTING -j HMARK --method L3 --src-mask 24 --mod 20 --offset 100

Rev 8
      method L3 / L3-4 added i.e. Fragment handling changed to
      don't handle in "method L3-4"
      Syntax change in user mode more NF compatible.
      Most changes are base on Pablos review.

Rev 7
      IPv6 descending into icmp error hdr didn't work as expected
      with ipv6_find_hdr() Now it works as expected.

Rev 6
      Compile options with or without conntrack fixed.
      __ipv6_find_hdr() replaced by ipv6_find_hdr()

Rev 5
      IPv6 rewritten uses __ipv6_find_hdr() (P. Mc Hardy)
      Full mask and address used for IPv6 smask and dmask (J.Engelhart)
      Changes due to comments by Pablo Neira Ayuso  and Eric Dumazet
      i.e uses of skb_header_pointer() and Null check of info->hmod
      Man page changes

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
 include/linux/netfilter/xt_hmark.h |   71 ++++++++
 net/netfilter/Kconfig              |   17 ++
 net/netfilter/Makefile             |    1 +
 net/netfilter/xt_hmark.c           |  334 ++++++++++++++++++++++++++++++++++++
 4 files changed, 423 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_hmark.h
 create mode 100644 net/netfilter/xt_hmark.c

diff --git a/include/linux/netfilter/xt_hmark.h b/include/linux/netfilter/xt_hmark.h
new file mode 100644
index 0000000..f2ac47b
--- /dev/null
+++ b/include/linux/netfilter/xt_hmark.h
@@ -0,0 +1,71 @@
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
+	XT_HMARK_METHOD_L3,
+	XT_HMARK_METHOD_L3_4,
+	XT_F_HMARK_USE_SNAT = 1 << XT_HMARK_USE_SNAT,
+	XT_F_HMARK_USE_DNAT = 1 << XT_HMARK_USE_DNAT,
+	XT_F_HMARK_SADR_AND = 1 << XT_HMARK_SADR_AND,
+	XT_F_HMARK_DADR_AND = 1 << XT_HMARK_DADR_AND,
+	XT_F_HMARK_SPI_AND = 1 << XT_HMARK_SPI_AND,
+	XT_F_HMARK_SPI_OR = 1 << XT_HMARK_SPI_OR,
+	XT_F_HMARK_SPORT_AND = 1 << XT_HMARK_SPORT_AND,
+	XT_F_HMARK_DPORT_AND = 1 << XT_HMARK_DPORT_AND,
+	XT_F_HMARK_SPORT_OR = 1 << XT_HMARK_SPORT_OR,
+	XT_F_HMARK_DPORT_OR = 1 << XT_HMARK_DPORT_OR,
+	XT_F_HMARK_PROTO_AND = 1 << XT_HMARK_PROTO_AND,
+	XT_F_HMARK_RND = 1 << XT_HMARK_RND,
+	XT_F_HMARK_MODULUS = 1 << XT_HMARK_MODULUS,
+	XT_F_HMARK_OFFSET = 1 << XT_HMARK_OFFSET,
+	XT_F_HMARK_METHOD_L3 = 1 << XT_HMARK_METHOD_L3,
+	XT_F_HMARK_METHOD_L3_4 = 1 << XT_HMARK_METHOD_L3_4,
+};
+
+#define XT_F_HMARK_L4_OPTS  (XT_F_HMARK_SPI_AND | XT_F_HMARK_SPI_OR\
+			     | XT_F_HMARK_SPORT_AND | XT_F_HMARK_SPORT_OR\
+			     | XT_F_HMARK_DPORT_AND | XT_F_HMARK_DPORT_OR\
+			     | XT_F_HMARK_PROTO_AND)
+
+union hports {
+	struct {
+		__u16	src;
+		__u16	dst;
+	} p16;
+	__u32	v32;
+};
+
+struct xt_hmark_info {
+	union nf_inet_addr	smask;		/* Source address mask */
+	union nf_inet_addr	dmask;		/* Dest address mask */
+	union hports		pmask;
+	union hports		pset;
+	__u32			spimask;
+	__u32			spiset;
+	__u16			flags;		/* Print out only */
+	__u16			prmask;		/* L4 Proto mask */
+	__u32			hashrnd;
+	__u32			hmod;		/* Modulus */
+	__u32			hoffs;		/* Offset */
+};
+
+#endif /* XT_HMARK_H_ */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index f8ac4ef..dfe84e1 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -488,6 +488,23 @@ config NETFILTER_XT_TARGET_HL
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
index 40f4c3d..21bc5e8 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -57,6 +57,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CT) += xt_CT.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_DSCP) += xt_DSCP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_HL) += xt_HL.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_HMARK) += xt_hmark.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_LED) += xt_LED.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) += xt_NFLOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) += xt_NFQUEUE.o
diff --git a/net/netfilter/xt_hmark.c b/net/netfilter/xt_hmark.c
new file mode 100644
index 0000000..c9d6654
--- /dev/null
+++ b/net/netfilter/xt_hmark.c
@@ -0,0 +1,334 @@
+/*
+ * xt_hmark - Netfilter module to set mark as hash value
+ *
+ * (C) 2011 Hans Schillstrom <hans.schillstrom@ericsson.com>
+ *
+ *Description:
+ *	This module calculates a hash value that can be modified by modulus
+ *	and an offset, i.e. it is possible to produce a skb->mark within a range.
+ *	The hash value is based on a direction independent five tuple:
+ *	src & dst addr src & dst ports and protocol.
+ *	There is two distinct modes for hash calculation:
+ *
+ *	MODE_L3:
+ *	In this mode ONLY src & dst addresses can be used in hash calc.
+ *	src-mask & dst-mask is the only valid masks.
+ *	In this mode no special care for fragments is necessary.
+ *
+ *	MODE_L3_4:
+ *	All five fields L4-proto, ports and addresses can be used in calc.
+ *	ESP and AH don't have ports so SPI will be used instead.
+ *	AH will not use ports even if it might be possible.
+ *	Tunnels - only the outer saddr and daddr will be used,
+ *
+ *	For ICMP error messages the hash mark values will be calculated on
+ *	the source packet i.e. the packet caused the error (If sufficient
+ *	amount of data exists).
+ *
+ *	Fragments is not handled in this mode, (if they reach us)
+ *	i.e.  fw-mark will be updated.
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
+#if defined(CONFIG_NF_NAT)
+#include <net/netfilter/nf_nat.h>
+#endif
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#	define WITH_IPV6 1
+#include <net/ipv6.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#endif
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Hans Schillstrom <hans.schillstrom@ericsson.com>");
+MODULE_DESCRIPTION("Xtables: Packet range mark operations by Hash value");
+MODULE_ALIAS("ipt_HMARK");
+MODULE_ALIAS("ip6t_HMARK");
+
+/*
+ * ICMP, get header offset if icmp error
+ */
+static int get_inner_hdr(struct sk_buff *skb, int iphsz, int nhoff)
+{
+	const struct icmphdr *icmph;
+	struct icmphdr _ih;
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
+
+	return nhoff + iphsz + sizeof(_ih);
+}
+
+#ifdef WITH_IPV6
+/*
+ * Get ipv6 header offset if icmp error
+ */
+static int get_inner6_hdr(struct sk_buff *skb, int *offset)
+{
+	struct icmp6hdr *icmp6h, _ih6;
+
+	icmp6h = skb_header_pointer(skb, *offset, sizeof(_ih6), &_ih6);
+	if (icmp6h == NULL)
+		return 0;
+
+	if (icmp6h->icmp6_type && icmp6h->icmp6_type < 128) {
+		*offset +=  sizeof(struct icmp6hdr);
+		return 1;
+	}
+	return 0;
+}
+/*
+ * Calculate hash based fw-mark, on the five tuple if possible.
+ * special cases :
+ *  - Fragments do not use ports not even on the first fragment,
+ *    nf_defrag_ipv6.ko don't defrag for us like it do in ipv4.
+ *    This might be changed in the future.
+ *  - On ICMP errors the inner header will be used.
+ *  - Tunnels no ports
+ *  - ESP & AH uses SPI
+ * @returns XT_CONTINUE
+ */
+static unsigned int
+hmark_v6(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	struct xt_hmark_info *info = (struct xt_hmark_info *)par->targinfo;
+	struct ipv6hdr *ip6, _ip6;
+	int poff, flag = IP6T_FH_F_AUTH; /* Ports offset, find_hdr flags */
+	u32 addr1, addr2, hash, nhoffs = 0;
+	u8 nexthdr;
+	union hports uports = { .v32 = 0 };
+	unsigned short fragoff = 0;
+
+	ip6 = (struct ipv6hdr *) (skb->data + skb_network_offset(skb));
+
+	/* Try to get transport header */
+	nexthdr = ipv6_find_hdr(skb, &nhoffs, -1, &fragoff, &flag);
+	if (nexthdr < 0)
+		return XT_CONTINUE;
+	/* don't check for icmp on fragments */
+	if ((flag & IP6T_FH_F_FRAG) || (nexthdr != IPPROTO_ICMPV6))
+		goto noicmp;
+	/* ICMP: if an error then move ptr to inner header */
+	if (get_inner6_hdr(skb, &nhoffs)) {
+		/* Get IPv6 header ptr just to get the saddr & daddr later */
+		ip6 = skb_header_pointer(skb, nhoffs, sizeof(_ip6), &_ip6);
+		if (!ip6)
+			return XT_CONTINUE;
+		/* Treat AH as ESP */
+		flag = IP6T_FH_F_AUTH;
+		nexthdr = ipv6_find_hdr(skb, &nhoffs, -1, &fragoff, &flag);
+		if (nexthdr < 0)
+			return XT_CONTINUE;
+	}
+noicmp:
+	/* Mask of the address and xor it into a u32 */
+	addr1 = (__force u32)
+		(ip6->saddr.s6_addr32[0] & info->smask.in6.s6_addr32[0]) ^
+		(ip6->saddr.s6_addr32[1] & info->smask.in6.s6_addr32[1]) ^
+		(ip6->saddr.s6_addr32[2] & info->smask.in6.s6_addr32[2]) ^
+		(ip6->saddr.s6_addr32[3] & info->smask.in6.s6_addr32[3]);
+	addr2 = (__force u32)
+		(ip6->daddr.s6_addr32[0] & info->dmask.in6.s6_addr32[0]) ^
+		(ip6->daddr.s6_addr32[1] & info->dmask.in6.s6_addr32[1]) ^
+		(ip6->daddr.s6_addr32[2] & info->dmask.in6.s6_addr32[2]) ^
+		(ip6->daddr.s6_addr32[3] & info->dmask.in6.s6_addr32[3]);
+
+	/* user space tool ensures that prmask is zero when method is L3*/
+	if ((info->flags & XT_F_HMARK_METHOD_L3) ||
+	    (nexthdr == IPPROTO_ICMPV6))
+		goto no6ports;
+
+	/* Is next header valid for port or SPI calculation ? */
+	poff = proto_ports_offset(nexthdr);
+	if ((flag & IP6T_FH_F_FRAG) || poff < 0)
+		return XT_CONTINUE;
+
+	nhoffs += poff;
+	/* Since uports is modified, skb_header_pointer() can't be used */
+	if (!pskb_may_pull(skb, nhoffs + 4))
+		return XT_CONTINUE;
+	uports.v32 = * (__force u32 *) (skb->data + nhoffs);
+
+	if ((nexthdr == IPPROTO_ESP) || (nexthdr == IPPROTO_AH))
+		uports.v32 = (uports.v32 & info->spimask) | info->spiset;
+	else {
+		uports.v32 = (uports.v32 & info->pmask.v32) | info->pset.v32;
+		/* get a consistent hash (same value on both flow directions) */
+		if (uports.p16.dst < uports.p16.src)
+			swap(uports.p16.dst, uports.p16.src);
+	}
+
+no6ports:
+	nexthdr &= info->prmask;
+	/* get a consistent hash (same value on both flow directions) */
+	if (addr2 < addr1)
+		swap(addr1, addr2);
+
+	hash = jhash_3words(addr1, addr2, uports.v32, info->hashrnd) ^ nexthdr;
+	skb->mark = (hash % info->hmod) + info->hoffs;
+	return XT_CONTINUE;
+}
+#endif
+/*
+ * Calculate hash based fw-mark, on the five tuple if possible.
+ * special cases :
+ *  - Fragments do not use ports not even on the first fragment,
+ *    unless nf_defrag_xx.ko is used.
+ *  - On ICMP errors the inner header will be used.
+ *  - Tunnels no ports
+ *  - ESP & AH uses SPI
+ * @returns XT_CONTINUE
+ */
+static unsigned int
+hmark_v4(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	struct xt_hmark_info *info = (struct xt_hmark_info *)par->targinfo;
+	int nhoff, poff, frag = 0;
+	struct iphdr *ip, _ip;
+	u8 ip_proto;
+	u32 addr1, addr2, hash;
+	u16 snatport = 0, dnatport = 0;
+	union hports uports;
+#if defined(CONFIG_NF_NAT)
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+#endif
+
+	nhoff = skb_network_offset(skb);
+	uports.v32 = 0;
+
+	ip = (struct iphdr *) (skb->data + nhoff);
+	if (ip->protocol == IPPROTO_ICMP) {
+		/* calc hash on inner header if an icmp error */
+		nhoff = get_inner_hdr(skb, ip->ihl * 4, nhoff);
+		ip = skb_header_pointer(skb, nhoff, sizeof(_ip), &_ip);
+		if (!ip)
+			return XT_CONTINUE;
+	}
+
+	ip_proto = ip->protocol;
+	if (ip->frag_off & htons(IP_MF | IP_OFFSET))
+		frag = 1;
+
+	addr1 = (__force u32) ip->saddr & info->smask.ip;
+	addr2 = (__force u32) ip->daddr & info->dmask.ip;
+
+#if defined(CONFIG_NF_NAT)
+	if (ct && test_bit(IP_CT_IS_REPLY, &ct->status)) {
+		struct nf_conntrack_tuple *otuple;
+
+		otuple = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
+		/*
+		 * On the "return flow", to get the original address
+		 */
+		if ((ct->status & IPS_DST_NAT) &&
+			(info->flags & XT_HMARK_USE_DNAT)) {
+			addr1 = (__force u32) otuple->dst.u3.in.s_addr;
+			dnatport = otuple->dst.u.udp.port;
+		}
+		if ((ct->status & IPS_SRC_NAT) &&
+			(info->flags & XT_HMARK_USE_SNAT)) {
+			addr2 = (__force u32) otuple->src.u3.in.s_addr;
+			snatport = otuple->src.u.udp.port;
+		}
+	}
+#endif
+	/* user space tool ensures that prmask is zero when method is L3*/
+	if ((info->flags & XT_F_HMARK_METHOD_L3) || (ip_proto == IPPROTO_ICMP))
+		goto noports;
+	/* Check if ports can be used in hash calculation. */
+	poff = proto_ports_offset(ip_proto);
+	if (frag || poff < 0)
+		return XT_CONTINUE;
+
+	nhoff += (ip->ihl * 4) + poff;
+	if (!pskb_may_pull(skb, nhoff + 4))
+		return XT_CONTINUE;
+
+	uports.v32 = * (__force u32 *) (skb->data + nhoff);
+	if (ip_proto == IPPROTO_ESP || ip_proto == IPPROTO_AH)
+		uports.v32 = (uports.v32 & info->spimask) | info->spiset;
+	else {
+		if (snatport)	/* Replace nat'ed port(s) */
+			uports.p16.dst = snatport;
+		if (dnatport)
+			uports.p16.src = dnatport;
+		uports.v32 = (uports.v32 & info->pmask.v32) |
+				info->pset.v32;
+		/* get a consistent hash (same value on both flow directions) */
+		if (uports.p16.dst < uports.p16.src)
+			swap(uports.p16.src, uports.p16.dst);
+	}
+
+noports:
+	ip_proto &= info->prmask;
+	/* get a consistent hash (same value on both flow directions) */
+	if (addr2 < addr1)
+		swap(addr1, addr2);
+
+	hash = jhash_3words(addr1, addr2, uports.v32, info->hashrnd) ^ ip_proto;
+	skb->mark = (hash % info->hmod) + info->hoffs;
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
1.7.2.3
