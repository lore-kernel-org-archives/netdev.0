From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [v10 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Mon, 12 Mar 2012 17:31:39 +0100
Message-ID: <1331569900-2032-3-git-send-email-hans.schillstrom@ericsson.com>
References: <1331569900-2032-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: hans@schillstrom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: kaber@trash.net, pablo@netfilter.org, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:44002 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526Ab2CLQbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 12:31:46 -0400
In-Reply-To: <1331569900-2032-1-git-send-email-hans.schillstrom@ericsson.com>
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

       --hmark-ct
              When flag is set, conntrack data should be used. Useful when NAT internal
              addressed should be used in calculation.  Be careful when using DNAT
              since mangle table is handled before nat table. I.e it will not work as
              expected to put HMARK in table mangle and PREROUTING chain. The  initial
              packet will have it's hash based on the original address,
              while the rest of the flow will use the NAT:ed address.

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

       Fragment safe Layer 3 only, that keep a class C network flow together

              iptables -t mangle -A PREROUTING -j HMARK --method L3 --src-mask 24 --mod 20 --offset 100

Rev 10
     Even more simplified NAT handling just one switch --hmark-ct
     some renaming and some minor changes.
     Changes are based on Pablos review.

Rev 9
      Simplified NAT selections, cleanup of comments, added checkentry()
      change of #ifdef to #if IS_ENABLED and dependency.
      Some minor formating.
      Most changes are based on Pablos review.

Rev 8
      method L3 / L3-4 added i.e. Fragment handling changed to
      don't handle in "method L3-4"
      Syntax change in user mode more NF compatible.
      Most changes are based on Pablos review.

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
 include/linux/netfilter/xt_HMARK.h |   62 +++++++
 net/netfilter/Kconfig              |   18 ++
 net/netfilter/Makefile             |    1 +
 net/netfilter/xt_HMARK.c           |  319 ++++++++++++++++++++++++++++++++++++
 4 files changed, 400 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_HMARK.h
 create mode 100644 net/netfilter/xt_HMARK.c

diff --git a/include/linux/netfilter/xt_HMARK.h b/include/linux/netfilter/xt_HMARK.h
new file mode 100644
index 0000000..cdf4a8f
--- /dev/null
+++ b/include/linux/netfilter/xt_HMARK.h
@@ -0,0 +1,62 @@
+#ifndef XT_HMARK_H_
+#define XT_HMARK_H_
+
+#include <linux/types.h>
+
+enum {
+	XT_HMARK_NONE,
+	XT_HMARK_SADR_AND,
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
+	XT_HMARK_CT,
+	XT_HMARK_METHOD_L3,
+	XT_HMARK_METHOD_L3_4,
+	XT_F_HMARK_SADR_AND    = 1 << XT_HMARK_SADR_AND,
+	XT_F_HMARK_DADR_AND    = 1 << XT_HMARK_DADR_AND,
+	XT_F_HMARK_SPI_AND     = 1 << XT_HMARK_SPI_AND,
+	XT_F_HMARK_SPI_OR      = 1 << XT_HMARK_SPI_OR,
+	XT_F_HMARK_SPORT_AND   = 1 << XT_HMARK_SPORT_AND,
+	XT_F_HMARK_DPORT_AND   = 1 << XT_HMARK_DPORT_AND,
+	XT_F_HMARK_SPORT_OR    = 1 << XT_HMARK_SPORT_OR,
+	XT_F_HMARK_DPORT_OR    = 1 << XT_HMARK_DPORT_OR,
+	XT_F_HMARK_PROTO_AND   = 1 << XT_HMARK_PROTO_AND,
+	XT_F_HMARK_RND         = 1 << XT_HMARK_RND,
+	XT_F_HMARK_MODULUS     = 1 << XT_HMARK_MODULUS,
+	XT_F_HMARK_OFFSET      = 1 << XT_HMARK_OFFSET,
+	XT_F_HMARK_CT          = 1 << XT_HMARK_CT,
+	XT_F_HMARK_METHOD_L3   = 1 << XT_HMARK_METHOD_L3,
+	XT_F_HMARK_METHOD_L3_4 = 1 << XT_HMARK_METHOD_L3_4,
+};
+
+union hmark_ports {
+	struct {
+		__u16	src;
+		__u16	dst;
+	} p16;
+	__u32	v32;
+};
+
+struct xt_hmark_info {
+	union nf_inet_addr	src_mask;	/* Source address mask */
+	union nf_inet_addr	dst_mask;	/* Dest address mask */
+	union hmark_ports	port_mask;
+	union hmark_ports	port_set;
+	__u32			spi_mask;
+	__u32			spi_set;
+	__u32			flags;		/* Print out only */
+	__u16			proto_mask;	/* L4 Proto mask */
+	__u32			hashrnd;
+	__u32			hmodulus;	/* Modulus */
+	__u32			hoffset;	/* Offset */
+};
+
+#endif /* XT_HMARK_H_ */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index f8ac4ef..a775804 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -488,6 +488,24 @@ config NETFILTER_XT_TARGET_HL
 	since you can easily create immortal packets that loop
 	forever on the network.
 
+config NETFILTER_XT_TARGET_HMARK
+	tristate '"HMARK" target support'
+	depends on (IP6_NF_IPTABLES || IP6_NF_IPTABLES=n)
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
index 40f4c3d..2712ba0 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -57,6 +57,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CT) += xt_CT.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_DSCP) += xt_DSCP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_HL) += xt_HL.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_HMARK) += xt_HMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_LED) += xt_LED.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) += xt_NFLOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) += xt_NFQUEUE.o
diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
new file mode 100644
index 0000000..d90549d
--- /dev/null
+++ b/net/netfilter/xt_HMARK.c
@@ -0,0 +1,319 @@
+/*
+ * xt_hmark - Netfilter module to set mark as hash value
+ *
+ * (C) 2012 Hans Schillstrom <hans.schillstrom@ericsson.com>
+ *
+ *Description:
+ *	This module calculates a hash value that can be modified by modulus
+ *	and an offset, i.e. it is possible to produce a skb->mark within a range
+ *	The hash value is based on a direction independent five tuple:
+ *	src & dst addr src & dst ports and protocol.
+ *	There is two distinct modes for hash calculation:
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
+#include <linux/netfilter/xt_HMARK.h>
+#include <linux/netfilter/x_tables.h>
+#include <net/netfilter/nf_conntrack.h>
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
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
+static int get_inner_hdr(struct sk_buff *skb, int iphsz, int *nhoff)
+{
+	const struct icmphdr *icmph;
+	struct icmphdr _ih;
+
+	/* Not enough header? */
+	icmph = skb_header_pointer(skb, *nhoff + iphsz, sizeof(_ih), &_ih);
+	if (icmph == NULL && icmph->type > NR_ICMP_TYPES)
+		return 0;
+
+	/* Error message? */
+	if (icmph->type != ICMP_DEST_UNREACH &&
+	    icmph->type != ICMP_SOURCE_QUENCH &&
+	    icmph->type != ICMP_TIME_EXCEEDED &&
+	    icmph->type != ICMP_PARAMETERPROB &&
+	    icmph->type != ICMP_REDIRECT)
+		return 0;
+
+	*nhoff += iphsz + sizeof(_ih);
+	return 1;
+}
+
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
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
+		*offset += sizeof(struct icmp6hdr);
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
+	const struct xt_hmark_info *info = par->targinfo;
+	struct ipv6hdr *ip6, _ip6;
+	int poff, flag = IP6T_FH_F_AUTH; /* Ports offset, find_hdr flags */
+	union hmark_ports uports;
+	u32 addr_src, addr_dst, hash, nhoffs = 0;
+	u16 fragoff = 0;
+	u8 nexthdr;
+
+	ip6 = (struct ipv6hdr *) (skb->data + skb_network_offset(skb));
+	nexthdr = ipv6_find_hdr(skb, &nhoffs, -1, &fragoff, &flag);
+	if (nexthdr < 0)
+		return XT_CONTINUE;
+	/* No need to check for icmp errors on fragments */
+	if ((flag & IP6T_FH_F_FRAG) || (nexthdr != IPPROTO_ICMPV6))
+		goto noicmp;
+	/* if an icmp error, use the inner header */
+	if (get_inner6_hdr(skb, &nhoffs)) {
+		ip6 = skb_header_pointer(skb, nhoffs, sizeof(_ip6), &_ip6);
+		if (!ip6)
+			return XT_CONTINUE;
+		/* Treat AH as ESP, use SPI nothing else. */
+		flag = IP6T_FH_F_AUTH;
+		nexthdr = ipv6_find_hdr(skb, &nhoffs, -1, &fragoff, &flag);
+		if (nexthdr < 0)
+			return XT_CONTINUE;
+	}
+noicmp:
+	addr_src = (__force u32)
+		(ip6->saddr.s6_addr32[0] & info->src_mask.in6.s6_addr32[0]) ^
+		(ip6->saddr.s6_addr32[1] & info->src_mask.in6.s6_addr32[1]) ^
+		(ip6->saddr.s6_addr32[2] & info->src_mask.in6.s6_addr32[2]) ^
+		(ip6->saddr.s6_addr32[3] & info->src_mask.in6.s6_addr32[3]);
+	addr_dst = (__force u32)
+		(ip6->daddr.s6_addr32[0] & info->dst_mask.in6.s6_addr32[0]) ^
+		(ip6->daddr.s6_addr32[1] & info->dst_mask.in6.s6_addr32[1]) ^
+		(ip6->daddr.s6_addr32[2] & info->dst_mask.in6.s6_addr32[2]) ^
+		(ip6->daddr.s6_addr32[3] & info->dst_mask.in6.s6_addr32[3]);
+
+	uports.v32 = 0;
+	if ((info->flags & XT_F_HMARK_METHOD_L3) ||
+	    (nexthdr == IPPROTO_ICMPV6))
+		goto no_ports;
+	/* Is next header valid for port or SPI calculation ? */
+	poff = proto_ports_offset(nexthdr);
+	if ((flag & IP6T_FH_F_FRAG) || poff < 0)
+		return XT_CONTINUE;
+
+	nhoffs += poff;
+	if (skb_copy_bits(skb, nhoffs, &uports, sizeof(uports)) < 0)
+		return XT_CONTINUE;
+
+	if ((nexthdr == IPPROTO_ESP) || (nexthdr == IPPROTO_AH))
+		uports.v32 = (uports.v32 & info->spi_mask) | info->spi_set;
+	else {
+		uports.v32 = (uports.v32 & info->port_mask.v32) |
+			      info->port_set.v32;
+		/* get a consistent hash (same value in any flow dirs.) */
+		if (uports.p16.dst < uports.p16.src)
+			swap(uports.p16.dst, uports.p16.src);
+	}
+
+no_ports:
+	nexthdr &= info->proto_mask;
+	/* get a consistent hash (same value in any flow direction) */
+	if (addr_dst < addr_src)
+		swap(addr_src, addr_dst);
+
+	hash = jhash_3words(addr_src, addr_dst, uports.v32, info->hashrnd) ^ nexthdr;
+	skb->mark = (hash % info->hmodulus) + info->hoffset;
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
+	const struct xt_hmark_info *info = par->targinfo;
+	struct iphdr *ip, _ip;
+	int nhoff, poff, frag = 0;
+	union hmark_ports uports;
+	u32 addr_src, addr_dst, hash;
+	u8 ip_proto;
+
+	nhoff = skb_network_offset(skb);
+	ip = (struct iphdr *) (skb->data + nhoff);
+	if (ip->protocol == IPPROTO_ICMP) {
+		/* if an icmp error, calc hash on inner header */
+		if (get_inner_hdr(skb, ip->ihl * 4, &nhoff)) {
+			ip = skb_header_pointer(skb, nhoff, sizeof(_ip), &_ip);
+			if (!ip)
+				return XT_CONTINUE;
+		}
+	}
+
+	ip_proto = ip->protocol;
+	if (ip->frag_off & htons(IP_MF | IP_OFFSET))
+		frag = 1;
+
+	addr_src = (__force u32) ip->saddr;
+	addr_dst = (__force u32) ip->daddr;
+	uports.v32 = 0;
+/* todo: Check conntrack ICMP relation */
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+	if (info->flags & XT_F_HMARK_CT) {
+		struct nf_conntrack_tuple *otuple;
+		struct nf_conntrack_tuple *rtuple;
+		enum ip_conntrack_info ctinfo;
+		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
+
+		if (!ct || nf_ct_is_untracked(ct))
+			return XT_CONTINUE;
+
+		otuple = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
+		rtuple = &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
+
+		addr_src       = (__force u32)otuple->src.u3.in.s_addr;
+		uports.p16.src = otuple->src.u.udp.port;
+		addr_dst       = (__force u32)rtuple->src.u3.in.s_addr;
+		uports.p16.dst = rtuple->src.u.udp.port;
+	}
+#endif
+	addr_src &= info->src_mask.ip;
+	addr_dst &= info->dst_mask.ip;
+
+	if ((info->flags & XT_F_HMARK_METHOD_L3) ||
+	    (ip_proto == IPPROTO_ICMP)) {
+		uports.v32 = 0;
+		goto noports;
+	}
+	/* Check if ports can be used in hash calculation. */
+	poff = proto_ports_offset(ip_proto);
+	if (frag || poff < 0)
+		return XT_CONTINUE;
+
+	/* if no ports from conntrack try to get ports from skb */
+	if (!uports.v32) {
+		nhoff += (ip->ihl * 4) + poff;
+		if (skb_copy_bits(skb, nhoff, &uports, sizeof(uports)) < 0)
+			return XT_CONTINUE;
+	}
+
+	if (ip_proto == IPPROTO_ESP || ip_proto == IPPROTO_AH)
+		uports.v32 = (uports.v32 & info->spi_mask) | info->spi_set;
+	else {
+		uports.v32 = (uports.v32 & info->port_mask.v32) |
+				info->port_set.v32;
+		/* get a consistent hash (same value in any flow dirs.) */
+		if (uports.p16.dst < uports.p16.src)
+			swap(uports.p16.src, uports.p16.dst);
+	}
+
+noports:
+	/* get a consistent hash (same value in any flow direction) */
+	if (addr_dst < addr_src)
+		swap(addr_src, addr_dst);
+
+	hash = jhash_3words(addr_src, addr_dst, uports.v32, info->hashrnd);
+	hash = hash ^ (ip_proto & info->proto_mask);
+	skb->mark = (hash % info->hmodulus) + info->hoffset;
+	return XT_CONTINUE;
+}
+
+static int hmark_check(const struct xt_tgchk_param *par)
+{
+	const struct xt_hmark_info *info = par->targinfo;
+
+	if (!info->hmodulus) {
+		pr_info("HMARK: hmark-mod can't be zero\n");
+		return -EINVAL;
+	}
+	if (info->proto_mask && (info->flags & XT_F_HMARK_METHOD_L3)) {
+		pr_info("HMARK: When method L3 proto mask must be zero\n");
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static struct xt_target hmark_tg_reg[] __read_mostly = {
+	{
+		.name           = "HMARK",
+		.revision       = 0,
+		.family         = NFPROTO_IPV4,
+		.target         = hmark_v4,
+		.targetsize     = sizeof(struct xt_hmark_info),
+		.checkentry     = hmark_check,
+		.me             = THIS_MODULE,
+	},
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
+	{
+		.name           = "HMARK",
+		.revision       = 0,
+		.family         = NFPROTO_IPV6,
+		.target         = hmark_v6,
+		.targetsize     = sizeof(struct xt_hmark_info),
+		.checkentry     = hmark_check,
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
