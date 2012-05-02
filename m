From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [v12 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Wed, 2 May 2012 19:49:47 +0200
Message-ID: <201205021949.48741.hans.schillstrom@ericsson.com>
References: <1335188128-23645-1-git-send-email-hans.schillstrom@ericsson.com> <201205020955.01498.hans.schillstrom@ericsson.com> <20120502080944.GA17393@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary-00=_8OXoPcI8q1L/lNC"
Cc: "kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:51595 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755288Ab2EBRtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 13:49:52 -0400
In-Reply-To: <20120502080944.GA17393@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_8OXoPcI8q1L/lNC
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 02 May 2012 10:09:44 Pablo Neira Ayuso wrote:
> On Wed, May 02, 2012 at 09:55:00AM +0200, Hans Schillstrom wrote:
> > Hello Pablo
> > (Sorry for spamming some of you, kmail started to send HTML mail)
> > 
> > On Wednesday 02 May 2012 02:34:14 Pablo Neira Ayuso wrote:
> > > Hi Hans,
> > > 
> > > I have decided to take your patch and give it one spin today.
> > > 
> > > Please, find it attached. The main things I've done are:
> > > 
> > > * splitting the code into smaller functions, thus, it becomes more
> > >   maintainable.
> > > 
> > > * try to put common code into functions, eg. the layer 4 protocol
> > >   parsing to obtain the ports is the same for both IPv4 and IPv6.
> > > 
> > > * adding the hmark_tuple abstraction, cleaner than using several
> > >   variables to set the address, ports, and so on. Thus, we only pass
> > >   one single pointer to it.
> > > 
> > > * I have removed most of the comments, they bloat the file and most
> > >   information can be extracted by reading the code. I only left the
> > >   comments that clarify "strange" things.
> > > 
> > > Regarding ICMP traffic, I think we can use the ID field for the
> > > hashing as well. Thus, we handle ICMP like other protocols.
> > 
> > Yes why not, I can give it a try.
> > 

I think we wait with this one..

> > > 
> > > Please, I'd appreciate if you can test and spot issues after my
> > > rework. I have slightly tested here.
> > 
> > OK I found some minor things, I'll send an updated version back later today.
> > I will run all my tests it will take a couple of hours.
> 
> Please, go ahead.

Done, all my tests passed

[snip]
This is what I have done.

- I reduced the code size a little bit by combining the hmark_ct_set_htuple_ipvX into one func.
  by adding a hmark_addr6_mask() and hmark_addr_any_mask()
  Note that using "otuple->src.l3num" as param 1 in both src and dst is not a typo.
  (it's not set in the rtuple)
- Made the if (dst < src) swap() in the hmark_hash() since it should be used by every caller. 
- Moved the L3 check a little bit earlier.
- changed return values for fragments.
- Added nhoffs to: hmark_set_tuple_ports(skb, (ip->ihl * 4) + nhoff, t, info);
  to get icmp working


-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>

--Boundary-00=_8OXoPcI8q1L/lNC
Content-Type: text/x-patch; charset="ISO-8859-1";
	name="0001-netfilter-add-xt_hmark-target-for-hash-based-skb-mar.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0001-netfilter-add-xt_hmark-target-for-hash-based-skb-mar.patch"

=46rom 55b47c7a3f7ab6a9d0430c6b753ccf3cc3cac7b8 Mon Sep 17 00:00:00 2001
=46rom: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date: Wed, 2 May 2012 18:59:28 +0200
Subject: [PATCH 1/1] netfilter: add xt_hmark target for hash-based skb mark=
ing

The target allows you to create rules in the "raw" and "mangle" tables
which set the skbuff mark by means of hash calculation within a given
range. The nfmark can influence the routing method (see "Use netfilter
MARK value as routing key") and can also be used by other subsystems to
change their behaviour.

Some examples:

* Default rule handles all TCP, UDP, SCTP, ESP & AH

 iptables -t mangle -A PREROUTING -m state --state NEW,ESTABLISHED,RELATED \
	-j HMARK --hmark-offset 10000 --hmark-mod 10

* Handle SCTP and hash dest port only and produce a nfmark between 100-119.

 iptables -t mangle -A PREROUTING -p SCTP -j HMARK --src-mask 0 --dst-mask =
0 \
	--sp-mask 0 --offset 100 --mod 20

* Fragment safe Layer 3 only, that keep a class C network flow together

 iptables -t mangle -A PREROUTING -j HMARK --method L3 \
	--src-mask 24 --mod 20 --offset 100

[ A big part of this patch has been refactorized by Pablo Neira Ayuso ]

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
=2D--
 include/linux/netfilter/xt_HMARK.h |   62 ++++++
 net/netfilter/Kconfig              |   15 ++
 net/netfilter/Makefile             |    1 +
 net/netfilter/xt_HMARK.c           |  371 ++++++++++++++++++++++++++++++++=
++++
 4 files changed, 449 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_HMARK.h
 create mode 100644 net/netfilter/xt_HMARK.c

diff --git a/include/linux/netfilter/xt_HMARK.h b/include/linux/netfilter/x=
t_HMARK.h
new file mode 100644
index 0000000..cdf4a8f
=2D-- /dev/null
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
+	XT_F_HMARK_SADR_AND    =3D 1 << XT_HMARK_SADR_AND,
+	XT_F_HMARK_DADR_AND    =3D 1 << XT_HMARK_DADR_AND,
+	XT_F_HMARK_SPI_AND     =3D 1 << XT_HMARK_SPI_AND,
+	XT_F_HMARK_SPI_OR      =3D 1 << XT_HMARK_SPI_OR,
+	XT_F_HMARK_SPORT_AND   =3D 1 << XT_HMARK_SPORT_AND,
+	XT_F_HMARK_DPORT_AND   =3D 1 << XT_HMARK_DPORT_AND,
+	XT_F_HMARK_SPORT_OR    =3D 1 << XT_HMARK_SPORT_OR,
+	XT_F_HMARK_DPORT_OR    =3D 1 << XT_HMARK_DPORT_OR,
+	XT_F_HMARK_PROTO_AND   =3D 1 << XT_HMARK_PROTO_AND,
+	XT_F_HMARK_RND         =3D 1 << XT_HMARK_RND,
+	XT_F_HMARK_MODULUS     =3D 1 << XT_HMARK_MODULUS,
+	XT_F_HMARK_OFFSET      =3D 1 << XT_HMARK_OFFSET,
+	XT_F_HMARK_CT          =3D 1 << XT_HMARK_CT,
+	XT_F_HMARK_METHOD_L3   =3D 1 << XT_HMARK_METHOD_L3,
+	XT_F_HMARK_METHOD_L3_4 =3D 1 << XT_HMARK_METHOD_L3_4,
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
index 0c6f67e..209c1ed 100644
=2D-- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -509,6 +509,21 @@ config NETFILTER_XT_TARGET_HL
 	since you can easily create immortal packets that loop
 	forever on the network.
=20
+config NETFILTER_XT_TARGET_HMARK
+	tristate '"HMARK" target support'
+	depends on (IP6_NF_IPTABLES || IP6_NF_IPTABLES=3Dn)
+	depends on NETFILTER_ADVANCED
+	---help---
+	This option adds the "HMARK" target.
+
+	The target allows you to create rules in the "raw" and "mangle" tables
+	which set the skbuff mark by means of hash calculation within a given
+	range. The nfmark can influence the routing method (see "Use netfilter
+	MARK value as routing key") and can also be used by other subsystems to
+	change their behaviour.
+
+	To compile it as a module, choose M here. If unsure, say N.
+
 config NETFILTER_XT_TARGET_IDLETIMER
 	tristate  "IDLETIMER target support"
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index ca36765..4e7960c 100644
=2D-- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -59,6 +59,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) +=3D xt_CON=
NSECMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CT) +=3D xt_CT.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_DSCP) +=3D xt_DSCP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_HL) +=3D xt_HL.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_HMARK) +=3D xt_HMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_LED) +=3D xt_LED.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_LOG) +=3D xt_LOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) +=3D xt_NFLOG.o
diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
new file mode 100644
index 0000000..76a3fa7
=2D-- /dev/null
+++ b/net/netfilter/xt_HMARK.c
@@ -0,0 +1,371 @@
+/*
+ * xt_HMARK - Netfilter module to set mark as hash value
+ *
+ * (C) 2012 by Hans Schillstrom <hans.schillstrom@ericsson.com>
+ * (C) 2012 by Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as publishe=
d by
+ * the Free Software Foundation.
+ *
+ * Description:
+ *
+ * This module calculates a hash value that can be modified by modulus and=
 an
+ * offset, i.e. it is possible to produce a skb->mark within a range The h=
ash
+ * value is based on a direction independent five tuple: src & dst addr sr=
c &
+ * dst ports and protocol.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/icmp.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_HMARK.h>
+
+#include <net/ip.h>
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+#include <net/netfilter/nf_conntrack.h>
+#endif
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
+#include <net/ipv6.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#endif
+
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Hans Schillstrom <hans.schillstrom@ericsson.com>");
+MODULE_DESCRIPTION("Xtables: packet marking using hash calculation");
+MODULE_ALIAS("ipt_HMARK");
+MODULE_ALIAS("ip6t_HMARK");
+
+struct hmark_tuple {
+	u32			src;
+	u32			dst;
+	union hmark_ports	uports;
+	uint8_t			proto;
+};
+
+static int
+hmark_ct_set_htuple(const struct sk_buff *skb, struct hmark_tuple *t,
+			 const struct xt_hmark_info *info);
+static inline u32
+hmark_hash(struct hmark_tuple *t, const struct xt_hmark_info *info)
+{
+	u32 hash;
+
+	if (t->dst < t->src)
+		swap(t->src, t->dst);
+
+	hash =3D jhash_3words(t->src, t->dst, t->uports.v32, info->hashrnd);
+	hash =3D hash ^ (t->proto & info->proto_mask);
+
+	return (hash % info->hmodulus) + info->hoffset;
+}
+
+static void
+hmark_set_tuple_ports(const struct sk_buff *skb, unsigned int nhoff,
+		      struct hmark_tuple *t, const struct xt_hmark_info *info)
+{
+	int protoff;
+
+	protoff =3D proto_ports_offset(t->proto);
+	if (protoff < 0)
+		return;
+
+	nhoff +=3D protoff;
+	if (skb_copy_bits(skb, nhoff, &t->uports, sizeof(t->uports)) < 0)
+		return;
+
+	if (t->proto =3D=3D IPPROTO_ESP || t->proto =3D=3D IPPROTO_AH)
+		t->uports.v32 =3D (t->uports.v32 & info->spi_mask) |
+				info->spi_set;
+	else {
+		t->uports.v32 =3D (t->uports.v32 & info->port_mask.v32) |
+				info->port_set.v32;
+
+		if (t->uports.p16.dst < t->uports.p16.src)
+			swap(t->uports.p16.dst, t->uports.p16.src);
+	}
+}
+
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
+static int get_inner6_hdr(const struct sk_buff *skb, int *offset)
+{
+	struct icmp6hdr *icmp6h, _ih6;
+
+	icmp6h =3D skb_header_pointer(skb, *offset, sizeof(_ih6), &_ih6);
+	if (icmp6h =3D=3D NULL)
+		return 0;
+
+	if (icmp6h->icmp6_type && icmp6h->icmp6_type < 128) {
+		*offset +=3D sizeof(struct icmp6hdr);
+		return 1;
+	}
+	return 0;
+}
+
+static inline u32 hmark_addr6_mask(const __u32 *addr32, const __u32 *mask)
+{
+	return  (addr32[0] & mask[0]) ^
+		(addr32[1] & mask[1]) ^
+		(addr32[2] & mask[2]) ^
+		(addr32[3] & mask[3]);
+}
+
+static int
+hmark_pkt_set_htuple_ipv6(const struct sk_buff *skb, struct hmark_tuple *t,
+			  const struct xt_hmark_info *info)
+{
+	struct ipv6hdr *ip6, _ip6;
+	int flag =3D IP6T_FH_F_AUTH; /* Ports offset, find_hdr flags */
+	unsigned int nhoff =3D 0;
+	u16 fragoff =3D 0;
+	int nexthdr;
+
+	ip6 =3D (struct ipv6hdr *) (skb->data + skb_network_offset(skb));
+	nexthdr =3D ipv6_find_hdr(skb, &nhoff, -1, &fragoff, &flag);
+	if (nexthdr < 0)
+		return 0;
+	/* No need to check for icmp errors on fragments */
+	if ((flag & IP6T_FH_F_FRAG) || (nexthdr !=3D IPPROTO_ICMPV6))
+		goto noicmp;
+	/* if an icmp error, use the inner header */
+	if (get_inner6_hdr(skb, &nhoff)) {
+		ip6 =3D skb_header_pointer(skb, nhoff, sizeof(_ip6), &_ip6);
+		if (ip6 =3D=3D NULL)
+			return -1;
+		/* Treat AH as ESP, use SPI nothing else. */
+		flag =3D IP6T_FH_F_AUTH;
+		nexthdr =3D ipv6_find_hdr(skb, &nhoff, -1, &fragoff, &flag);
+		if (nexthdr < 0)
+			return -1;
+	}
+noicmp:
+	t->src =3D hmark_addr6_mask(ip6->saddr.s6_addr32, info->src_mask.all);
+	t->dst =3D hmark_addr6_mask(ip6->daddr.s6_addr32, info->dst_mask.all);
+
+	if (info->flags & XT_F_HMARK_METHOD_L3)
+		return 0;
+
+	t->proto =3D nexthdr;
+
+	if (t->proto =3D=3D IPPROTO_ICMPV6)
+		return 0;
+
+	if (flag & IP6T_FH_F_FRAG)
+		return -1;
+
+	hmark_set_tuple_ports(skb, nhoff, t, info);
+
+	return 0;
+}
+
+static unsigned int
+hmark_tg_v6(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct xt_hmark_info *info =3D par->targinfo;
+	struct hmark_tuple t;
+
+	memset(&t, 0, sizeof(struct hmark_tuple));
+
+	if (info->flags & XT_F_HMARK_CT) {
+		if (hmark_ct_set_htuple(skb, &t, info) < 0)
+			return XT_CONTINUE;
+	} else {
+		if (hmark_pkt_set_htuple_ipv6(skb, &t, info) < 0)
+			return XT_CONTINUE;
+	}
+
+	skb->mark =3D hmark_hash(&t, info);
+	return XT_CONTINUE;
+}
+
+static inline u32
+hmark_addr_any_mask(int l3num, const __u32 *addr32, const __u32 *mask)
+{
+	if (l3num =3D=3D AF_INET)
+		return *addr32 & *mask;
+
+	return hmark_addr6_mask(addr32, mask);
+}
+#else
+static inline u32
+hmark_addr_any_mask(int l3num, const __u32 *addr32, const __u32 *mask)
+{
+	return *addr32 & *mask;
+}
+
+#endif
+
+static int
+hmark_ct_set_htuple(const struct sk_buff *skb, struct hmark_tuple *t,
+			 const struct xt_hmark_info *info)
+{
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct =3D nf_ct_get(skb, &ctinfo);
+	struct nf_conntrack_tuple *otuple;
+	struct nf_conntrack_tuple *rtuple;
+
+	if (ct =3D=3D NULL || nf_ct_is_untracked(ct))
+		return -1;
+
+	otuple =3D &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
+	rtuple =3D &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
+
+	t->src =3D hmark_addr_any_mask(otuple->src.l3num, otuple->src.u3.all,
+				     info->src_mask.all);
+	t->dst =3D hmark_addr_any_mask(otuple->src.l3num, rtuple->src.u3.all,
+				     info->dst_mask.all);
+
+	if (info->flags & XT_F_HMARK_METHOD_L3)
+		return 0;
+
+	t->proto =3D nf_ct_protonum(ct);
+	if (t->proto !=3D IPPROTO_ICMP) {
+		t->uports.p16.src =3D otuple->src.u.all;
+		t->uports.p16.dst =3D rtuple->src.u.all;
+		t->uports.v32 =3D (t->uports.v32 & info->port_mask.v32) |
+				info->port_set.v32;
+		if (t->uports.p16.dst < t->uports.p16.src)
+			swap(t->uports.p16.dst, t->uports.p16.src);
+	}
+
+	return 0;
+#else
+	return -1;
+#endif
+}
+
+static int get_inner_hdr(const struct sk_buff *skb, int iphsz, int *nhoff)
+{
+	const struct icmphdr *icmph;
+	struct icmphdr _ih;
+
+	/* Not enough header? */
+	icmph =3D skb_header_pointer(skb, *nhoff + iphsz, sizeof(_ih), &_ih);
+	if (icmph =3D=3D NULL && icmph->type > NR_ICMP_TYPES)
+		return 0;
+
+	/* Error message? */
+	if (icmph->type !=3D ICMP_DEST_UNREACH &&
+	    icmph->type !=3D ICMP_SOURCE_QUENCH &&
+	    icmph->type !=3D ICMP_TIME_EXCEEDED &&
+	    icmph->type !=3D ICMP_PARAMETERPROB &&
+	    icmph->type !=3D ICMP_REDIRECT)
+		return 0;
+
+	*nhoff +=3D iphsz + sizeof(_ih);
+	return 1;
+}
+
+static int
+hmark_pkt_set_htuple_ipv4(const struct sk_buff *skb, struct hmark_tuple *t,
+			  const struct xt_hmark_info *info)
+{
+	struct iphdr *ip, _ip;
+	int nhoff =3D skb_network_offset(skb);
+
+	ip =3D (struct iphdr *) (skb->data + nhoff);
+	if (ip->protocol =3D=3D IPPROTO_ICMP) {
+		/* use inner header in case of ICMP errors */
+		if (get_inner_hdr(skb, ip->ihl * 4, &nhoff)) {
+			ip =3D skb_header_pointer(skb, nhoff, sizeof(_ip), &_ip);
+			if (ip =3D=3D NULL)
+				return -1;
+		}
+	}
+
+	t->src =3D (__force u32) ip->saddr;
+	t->dst =3D (__force u32) ip->daddr;
+
+	t->src &=3D info->src_mask.ip;
+	t->dst &=3D info->dst_mask.ip;
+
+	if (info->flags & XT_F_HMARK_METHOD_L3)
+		return 0;
+
+	t->proto =3D ip->protocol;
+
+	/* ICMP has no ports, skip */
+	if (t->proto =3D=3D IPPROTO_ICMP)
+		return 0;
+
+	/* follow-up fragments don't contain ports, skip */
+	if (ip->frag_off & htons(IP_MF | IP_OFFSET))
+		return -1;
+
+	hmark_set_tuple_ports(skb, (ip->ihl * 4) + nhoff, t, info);
+
+	return 0;
+}
+
+static unsigned int
+hmark_tg_v4(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct xt_hmark_info *info =3D par->targinfo;
+	struct hmark_tuple t;
+
+	memset(&t, 0, sizeof(struct hmark_tuple));
+
+	if (info->flags & XT_F_HMARK_CT) {
+		if (hmark_ct_set_htuple(skb, &t, info) < 0)
+			return XT_CONTINUE;
+	} else {
+		if (hmark_pkt_set_htuple_ipv4(skb, &t, info) < 0)
+			return XT_CONTINUE;
+	}
+
+	skb->mark =3D hmark_hash(&t, info);
+	return XT_CONTINUE;
+}
+
+static int hmark_tg_check(const struct xt_tgchk_param *par)
+{
+	const struct xt_hmark_info *info =3D par->targinfo;
+
+	if (!info->hmodulus) {
+		pr_info("xt_HMARK: hash modulus can't be zero\n");
+		return -EINVAL;
+	}
+	if (info->proto_mask && (info->flags & XT_F_HMARK_METHOD_L3)) {
+		pr_info("xt_HMARK: proto mask must be zero with L3 mode\n");
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static struct xt_target hmark_tg_reg[] __read_mostly =3D {
+	{
+		.name		=3D "HMARK",
+		.family		=3D NFPROTO_IPV4,
+		.target		=3D hmark_tg_v4,
+		.targetsize	=3D sizeof(struct xt_hmark_info),
+		.checkentry	=3D hmark_tg_check,
+		.me		=3D THIS_MODULE,
+	},
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
+	{
+		.name		=3D "HMARK",
+		.family		=3D NFPROTO_IPV6,
+		.target		=3D hmark_tg_v6,
+		.targetsize	=3D sizeof(struct xt_hmark_info),
+		.checkentry	=3D hmark_tg_check,
+		.me		=3D THIS_MODULE,
+	},
+#endif
+};
+
+static int __init hmark_tg_init(void)
+{
+	return xt_register_targets(hmark_tg_reg, ARRAY_SIZE(hmark_tg_reg));
+}
+
+static void __exit hmark_tg_exit(void)
+{
+	xt_unregister_targets(hmark_tg_reg, ARRAY_SIZE(hmark_tg_reg));
+}
+
+module_init(hmark_tg_init);
+module_exit(hmark_tg_exit);
=2D-=20
1.7.2.3


--Boundary-00=_8OXoPcI8q1L/lNC--
