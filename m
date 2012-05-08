From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [v12 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Tue, 8 May 2012 09:37:35 +0200
Message-ID: <201205080937.36853.hans.schillstrom@ericsson.com>
References: <1335188128-23645-1-git-send-email-hans.schillstrom@ericsson.com> <201205071409.47945.hans.schillstrom@ericsson.com> <20120507122232.GA32146@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary-00=_A1MqPZvDhAqO1ON"
Cc: "kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120507122232.GA32146@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_A1MqPZvDhAqO1ON
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Monday 07 May 2012 14:22:32 Pablo Neira Ayuso wrote:
> On Mon, May 07, 2012 at 02:09:46PM +0200, Hans Schillstrom wrote:
> > On Monday 07 May 2012 13:56:12 Pablo Neira Ayuso wrote:
> > > On Mon, May 07, 2012 at 11:14:34AM +0200, Hans Schillstrom wrote:
> > > > > > We have plenty of rules where just source port mask is zero.
> > > > > > and the dest-port-mask is 0xfffc (or 0xffff)
> > > > > 
> > > > > 0xffff and 0x0000 means on/off respectively.
> > > > > 
> > > > > Still curious, how can 0xfffc be useful?
> > > > 
> > > > That's a special case where an appl is using 4 ports.
> > > > But in general, have not seen other than "on/off" except for above.
> > > 
> > > I see. Well I'm fine with this way to switch on/off things, just
> > > wanted some clafication.
> > > 
> > > Still one final thing I'd like to remove before inclusion:
> > > 
> > > +       union hmark_ports       port_mask;
> > > +       union hmark_ports       port_set;
> > > +       __u32                   spi_mask;
> > > +       __u32                   spi_set;
> > > 
> > > the spi_mask seems redundant. The port_mask already provides u32 for
> > > it.
> > 
> > No problems, I'll remove it.
> 

Done,

> OK. As a nice side-effect, this will lead to removing the branch that
> tests ESP/AH in hmark_set_tuple_ports.

Yes,

[snip]
> remove all trailing _OR
> rename all _AND by _MASK.
Done

[snip]
> iptables can stop this by spotting a warning message from user-space.
Done.


-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>

--Boundary-00=_A1MqPZvDhAqO1ON
Content-Type: text/x-patch; charset="ISO-8859-1";
	name="0001-netfilter-add-xt_hmark-target-for-hash-based-skb-mar.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0001-netfilter-add-xt_hmark-target-for-hash-based-skb-mar.patch"

=46rom d5065af3988cc7561a02f30bae8342e1a89126a4 Mon Sep 17 00:00:00 2001
=46rom: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date: Wed, 2 May 2012 07:49:47 +0000
Subject: netfilter: add xt_hmark target for hash-based skb
 marking

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
 include/linux/netfilter/xt_HMARK.h |   48 +++++
 net/netfilter/Kconfig              |   15 ++
 net/netfilter/Makefile             |    1 +
 net/netfilter/xt_HMARK.c           |  358 ++++++++++++++++++++++++++++++++=
++++
 4 files changed, 422 insertions(+)
 create mode 100644 include/linux/netfilter/xt_HMARK.h
 create mode 100644 net/netfilter/xt_HMARK.c

diff --git a/include/linux/netfilter/xt_HMARK.h b/include/linux/netfilter/x=
t_HMARK.h
new file mode 100644
index 0000000..05e43ba
=2D-- /dev/null
+++ b/include/linux/netfilter/xt_HMARK.h
@@ -0,0 +1,46 @@
+#ifndef XT_HMARK_H_
+#define XT_HMARK_H_
+
+#include <linux/types.h>
+
+enum {
+	XT_HMARK_NONE,
+	XT_HMARK_SADR_MASK,
+	XT_HMARK_DADR_MASK,
+	XT_HMARK_SPI_MASK,
+	XT_HMARK_SPI,
+	XT_HMARK_SPORT_MASK,
+	XT_HMARK_DPORT_MASK,
+	XT_HMARK_SPORT,
+	XT_HMARK_DPORT,
+	XT_HMARK_PROTO_MASK,
+	XT_HMARK_RND,
+	XT_HMARK_MODULUS,
+	XT_HMARK_OFFSET,
+	XT_HMARK_CT,
+	XT_HMARK_METHOD_L3,
+	XT_HMARK_METHOD_L3_4,
+};
+#define XT_HMARK_FLAG(flag)	(1 << flag)
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
index 0000000..b4aa912
=2D-- /dev/null
+++ b/net/netfilter/xt_HMARK.c
@@ -0,0 +1,362 @@
+/*
+ * xt_HMARK - Netfilter module to set mark by means of hashing
+ *
+ * (C) 2012 by Hans Schillstrom <hans.schillstrom@ericsson.com>
+ * (C) 2012 by Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as publishe=
d by
+ * the Free Software Foundation.
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
+static inline u32 hmark_addr6_mask(const __u32 *addr32, const __u32 *mask)
+{
+	return (addr32[0] & mask[0]) ^
+	       (addr32[1] & mask[1]) ^
+	       (addr32[2] & mask[2]) ^
+	       (addr32[3] & mask[3]);
+}
+
+static inline u32
+hmark_addr_mask(int l3num, const __u32 *addr32, const __u32 *mask)
+{
+	switch (l3num) {
+	case AF_INET:
+		return *addr32 & *mask;
+	case AF_INET6:
+		return hmark_addr6_mask(addr32, mask);
+	}
+	return 0;
+}
+
+static int
+hmark_ct_set_htuple(const struct sk_buff *skb, struct hmark_tuple *t,
+		    const struct xt_hmark_info *info)
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
+	t->src =3D hmark_addr_mask(otuple->src.l3num, otuple->src.u3.all,
+				 info->src_mask.all);
+	t->dst =3D hmark_addr_mask(otuple->src.l3num, rtuple->src.u3.all,
+				 info->dst_mask.all);
+
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3))
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
+	t->uports.v32 =3D (t->uports.v32 & info->port_mask.v32) |
+			info->port_set.v32;
+
+	if (t->uports.p16.dst < t->uports.p16.src)
+		swap(t->uports.p16.dst, t->uports.p16.src);
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
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3))
+		return 0;
+
+	t->proto =3D nexthdr;
+	if (t->proto =3D=3D IPPROTO_ICMPV6)
+		return 0;
+
+	if (flag & IP6T_FH_F_FRAG)
+		return 0;
+
+	hmark_set_tuple_ports(skb, nhoff, t, info);
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
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_CT)) {
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
+#endif
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
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3))
+		return 0;
+
+	t->proto =3D ip->protocol;
+
+	/* ICMP has no ports, skip */
+	if (t->proto =3D=3D IPPROTO_ICMP)
+		return 0;
+
+	/* follow-up fragments don't contain ports, skip all fragments */
+	if (ip->frag_off & htons(IP_MF | IP_OFFSET))
+		return 0;
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
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_CT)) {
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
+	if (info->proto_mask &&
+	    (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3))) {
+		pr_info("xt_HMARK: proto mask must be zero with L3 mode\n");
+		return -EINVAL;
+	}
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_SPI_MASK) &&
+	    (info->flags & (XT_HMARK_FLAG(XT_HMARK_SPORT_MASK) |
+			     XT_HMARK_FLAG(XT_HMARK_DPORT_MASK)))) {
+		pr_info("xt_HMARK: spi-mask and port-mask can't be combined\n");
+		return -EINVAL;
+	}
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_SPI) &&
+	    (info->flags & (XT_HMARK_FLAG(XT_HMARK_SPORT) |
+			     XT_HMARK_FLAG(XT_HMARK_DPORT)))) {
+		pr_info("xt_HMARK: spi-set and port-set can't be combined\n");
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
1.7.9.5


--Boundary-00=_A1MqPZvDhAqO1ON
Content-Type: text/x-patch; charset="ISO-8859-1";
	name="0001-netfilter-userspace-part-for-target-HMARK.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0001-netfilter-userspace-part-for-target-HMARK.patch"

=46rom 6e59e43e0e275918ae2c307e46a5581d5587459b Mon Sep 17 00:00:00 2001
=46rom: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date: Tue, 8 May 2012 09:15:12 +0200
Subject: [PATCH] netfilter: userspace part for target HMARK

    The target allows you to create rules in the "raw" and "mangle" tables
    which alter the netfilter mark (nfmark) field within a given range.
    First a 32 bit hash value is generated then modulus by <limit> and
    finally an offset is added before it's written to nfmark.
    Prior to routing, the nfmark can influence the routing method (see
    "Use netfilter MARK value as routing key") and can also be used by
    other subsystems to change their behaviour.

    The mark match can also be used to match nfmark produced by this module.

Ver 13
    Name change of defines and spi / port check due to removal ov spi data.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
=2D--
 extensions/libxt_HMARK.c   |  522 ++++++++++++++++++++++++++++++++++++++++=
++++
 extensions/libxt_HMARK.man |   84 +++++++
 2 files changed, 606 insertions(+), 0 deletions(-)
 create mode 100644 extensions/libxt_HMARK.c
 create mode 100644 extensions/libxt_HMARK.man

diff --git a/extensions/libxt_HMARK.c b/extensions/libxt_HMARK.c
new file mode 100644
index 0000000..2442f05
=2D-- /dev/null
+++ b/extensions/libxt_HMARK.c
@@ -0,0 +1,522 @@
+/*
+ * Shared library add-on to iptables to add HMARK target support.
+ *
+ * The kernel module calculates a hash value that can be modified by modul=
us
+ * and an offset. The hash value is based on a direction independent
+ * five tuple: src & dst addr src & dst ports and protocol.
+ * However src & dst port can be masked and are not used for fragmented
+ * packets, ESP and AH don't have ports so SPI will be used instead.
+ * For ICMP error messages the hash mark values will be calculated on
+ * the source packet i.e. the packet caused the error (If sufficient
+ * amount of data exists).
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <stdbool.h>
+#include <stdio.h>
+#include <string.h>
+
+#include "xtables.h"
+#include <linux/netfilter/xt_HMARK.h>
+
+
+#define DEF_HRAND 0xc175a3b8	/* Default "random" value to jhash */
+
+#define XT_F_HMARK_L4_OPTS \
+		(XT_HMARK_FLAG(XT_HMARK_SPI_MASK) |\
+		 XT_HMARK_FLAG(XT_HMARK_SPI) |\
+		 XT_HMARK_FLAG(XT_HMARK_SPORT_MASK) |\
+		 XT_HMARK_FLAG(XT_HMARK_SPORT) |\
+		 XT_HMARK_FLAG(XT_HMARK_DPORT_MASK) |\
+		 XT_HMARK_FLAG(XT_HMARK_DPORT) |\
+		 XT_HMARK_FLAG(XT_HMARK_PROTO_MASK))
+
+static void HMARK_help(void)
+{
+	printf(
+"HMARK target options, i.e. modify hash calculation by:\n"
+"  --hmark-method <method>          Overall L3/L4 and fragment behavior\n"
+"                 L3                Fragment safe, do not use ports or pro=
to\n"
+"                                   i.e. Fragments don't need special care=
=2E\n"
+"                 L3-4 (Default)    Fragment unsafe, use ports and proto\n"
+"                                   if defrag off in conntrack\n"
+"                                      no hmark on any part of a fragment\=
n"
+"  Limit/modify the calculated hash mark by:\n"
+"  --hmark-mod value                nfmark modulus value\n"
+"  --hmark-offset value             Last action add value to nfmark\n\n"
+" Fine tuning of what will be included in hash calculation\n"
+"  --hmark-src-mask length          Source address mask length\n"
+"  --hmark-dst-mask length          Dest address mask length\n"
+"  --hmark-sport-mask value         Mask src port with value\n"
+"  --hmark-dport-mask value         Mask dst port with value\n"
+"  --hmark-spi-mask value           For esp and ah AND spi with value\n"
+"  --hmark-sport-set value          OR src port with value\n"
+"  --hmark-dport-set value          OR dst port with value\n"
+"  --hmark-spi-set value            For esp and ah OR spi with value\n"
+"  --hmark-proto-mask value         Mask Protocol with value\n"
+"  --hmark-rnd                      Initial Random value to hash cacl.\n"
+" For NAT in IPv4: src part from original/reply tuple will always be used\=
n"
+" i.e. orig src part will be used as src address/port.\n"
+"     reply src part will be used as dst address/port\n"
+" Make sure to qualify the rule in a proper way when using NAT flag\n"
+" When --ct is used only tracked connections will match\n"
+"  --hmark-ct                       Force conntrack orig and rely tuples a=
s\n"
+"                                   source and destination.\n\n"
+" In many cases hmark can be omitted i.e. --src-mask can be used\n");
+}
+
+#define hi struct xt_hmark_info
+
+static const struct xt_option_entry HMARK_opts[] =3D {
+	{ .name  =3D "hmark-method",
+	  .type  =3D XTTYPE_STRING,
+	  .id    =3D XT_HMARK_METHOD_L3
+	},
+	{ .name  =3D "hmark-src-mask",
+	  .type  =3D XTTYPE_PLENMASK,
+	  .id    =3D XT_HMARK_SADR_MASK,
+	  .flags =3D XTOPT_PUT, XTOPT_POINTER(hi, src_mask)
+	},
+	{ .name  =3D "hmark-dst-mask",
+	  .type  =3D XTTYPE_PLENMASK,
+	  .id    =3D XT_HMARK_DADR_MASK,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, dst_mask)
+	},
+	{ .name  =3D "hmark-sport-mask",
+	  .type  =3D XTTYPE_UINT16,
+	  .id    =3D XT_HMARK_SPORT_MASK,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_mask.p16.src)
+	},
+	{ .name  =3D "hmark-dport-mask",
+	  .type  =3D XTTYPE_UINT16,
+	  .id    =3D XT_HMARK_DPORT_MASK,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_mask.p16.dst)
+	},
+	{ .name  =3D "hmark-spi-mask",
+	  .type  =3D XTTYPE_UINT32,
+	  .id    =3D XT_HMARK_SPI_MASK,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_mask.v32)
+	},
+	{ .name  =3D "hmark-sport-set",
+	  .type  =3D XTTYPE_UINT16,
+	  .id    =3D XT_HMARK_SPORT,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_set.p16.src)
+	},
+	{ .name  =3D "hmark-dport-set",
+	  .type  =3D XTTYPE_UINT16,
+	  .id    =3D XT_HMARK_DPORT,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_set.p16.dst)
+	},
+	{ .name  =3D "hmark-spi-set",
+	  .type  =3D XTTYPE_UINT32,
+	  .id    =3D XT_HMARK_SPI,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_set.v32)
+	},
+	{ .name  =3D "hmark-proto-mask",
+	  .type  =3D XTTYPE_UINT16,
+	  .id    =3D XT_HMARK_PROTO_MASK,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, proto_mask)
+	},
+	{ .name  =3D "hmark-rnd",
+	  .type  =3D XTTYPE_UINT32,
+	  .id    =3D XT_HMARK_RND,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, hashrnd)
+	},
+	{ .name =3D "hmark-mod",
+	  .type =3D XTTYPE_UINT32,
+	  .id =3D XT_HMARK_MODULUS,
+	  .min =3D 1,
+	  .flags =3D XTOPT_PUT | XTOPT_MAND,
+	  XTOPT_POINTER(hi, hmodulus)
+	},
+	{ .name  =3D "hmark-offset",
+	  .type  =3D XTTYPE_UINT32,
+	  .id    =3D XT_HMARK_OFFSET,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, hoffset)
+	},
+	{ .name  =3D "hmark-ct",
+	  .type  =3D XTTYPE_NONE,
+	  .id    =3D XT_HMARK_CT
+	},
+
+	{ .name  =3D "method",
+	  .type  =3D XTTYPE_STRING,
+	  .id    =3D XT_HMARK_METHOD_L3
+	},
+	{ .name  =3D "src-mask",
+	  .type  =3D XTTYPE_PLENMASK,
+	  .id    =3D XT_HMARK_SADR_MASK,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, src_mask)
+	},
+	{ .name  =3D "dst-mask",
+	  .type  =3D XTTYPE_PLENMASK,
+	  .id    =3D XT_HMARK_DADR_MASK,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, dst_mask)
+	},
+	{ .name  =3D "sport-mask",
+	  .type  =3D XTTYPE_UINT16,
+	  .id    =3D XT_HMARK_SPORT_MASK,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_mask.p16.src)
+	},
+	{ .name  =3D "dport-mask", .type =3D XTTYPE_UINT16,
+	  .id =3D XT_HMARK_DPORT_MASK,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_mask.p16.dst)
+	},
+	{ .name  =3D "spi-mask",
+	  .type  =3D XTTYPE_UINT32,
+	  .id    =3D XT_HMARK_SPI_MASK,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_mask.v32)
+	},
+	{ .name  =3D "sport-set",
+	  .type  =3D XTTYPE_UINT16,
+	  .id    =3D XT_HMARK_SPORT,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_set.p16.src)
+	},
+	{ .name  =3D "dport-set",
+	  .type  =3D XTTYPE_UINT16,
+	  .id    =3D XT_HMARK_DPORT,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_set.p16.dst)
+	},
+	{ .name  =3D "spi-set",
+	  .type  =3D XTTYPE_UINT32,
+	  .id    =3D XT_HMARK_SPI,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_set.v32)
+	},
+	{ .name  =3D "proto-mask",
+	  .type  =3D XTTYPE_UINT16,
+	  .id    =3D XT_HMARK_PROTO_MASK,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, proto_mask)
+	},
+	{ .name  =3D "rnd",
+	  .type  =3D XTTYPE_UINT32,
+	  .id    =3D XT_HMARK_RND,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, hashrnd)
+	},
+	{ .name  =3D "mod",
+	  .type  =3D XTTYPE_UINT32,
+	  .id    =3D XT_HMARK_MODULUS,
+	  .min   =3D 1,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_MAND, XTOPT_POINTER(hi, hmodulus)
+	},
+	{ .name  =3D "offset",
+	  .type  =3D XTTYPE_UINT32,
+	  .id    =3D XT_HMARK_OFFSET,
+	  .flags =3D XTOPT_PUT,
+	  XTOPT_POINTER(hi, hoffset)
+	},
+	{ .name  =3D "ct",
+	  .type  =3D XTTYPE_NONE,
+	  .id    =3D XT_HMARK_CT
+	},
+	XTOPT_TABLEEND,
+};
+
+static void HMARK_parse(struct xt_option_call *cb, int plen)
+{
+	struct xt_hmark_info *info =3D cb->data;
+
+	if (!cb->xflags) {
+		memset(info, 0xff, sizeof(struct xt_hmark_info));
+		info->port_set.v32 =3D 0;
+		info->flags =3D 0;
+		info->hoffset =3D 0;
+		info->hashrnd =3D DEF_HRAND;
+	}
+	xtables_option_parse(cb);
+
+	switch (cb->entry->id) {
+	case XT_HMARK_SADR_MASK:
+		if (cb->val.hlen =3D=3D plen)
+			cb->xflags &=3D ~XT_HMARK_FLAG(XT_HMARK_SADR_MASK);
+		break;
+	case XT_HMARK_DADR_MASK:
+		if (cb->val.hlen =3D=3D plen)
+			cb->xflags &=3D ~XT_HMARK_FLAG(XT_HMARK_DADR_MASK);
+		break;
+	case XT_HMARK_SPI_MASK:
+		info->port_mask.v32 =3D htonl(cb->val.u32);
+		if (cb->val.u32 =3D=3D 0xffffffff)
+			cb->xflags &=3D ~XT_HMARK_FLAG(XT_HMARK_SPI_MASK);
+		break;
+	case XT_HMARK_SPI:
+		info->port_set.v32 =3D htonl(cb->val.u32);
+		if (cb->val.u32 =3D=3D 0)
+			cb->xflags &=3D ~XT_HMARK_FLAG(XT_HMARK_SPI);
+		break;
+	case XT_HMARK_SPORT_MASK:
+		info->port_mask.p16.src =3D htons(cb->val.u16);
+		if (cb->val.u16 =3D=3D 0xffff)
+			cb->xflags &=3D ~XT_HMARK_FLAG(XT_HMARK_SPORT_MASK);
+		break;
+	case XT_HMARK_DPORT_MASK:
+		info->port_mask.p16.dst =3D htons(cb->val.u16);
+		if (cb->val.u16 =3D=3D 0xffff)
+			cb->xflags &=3D ~XT_HMARK_FLAG(XT_HMARK_DPORT_MASK);
+		break;
+	case XT_HMARK_SPORT:
+		info->port_set.p16.src =3D htons(cb->val.u16);
+		if (cb->val.u16 =3D=3D 0)
+			cb->xflags &=3D ~XT_HMARK_FLAG(XT_HMARK_SPORT);
+		break;
+	case XT_HMARK_DPORT:
+		info->port_set.p16.dst =3D htons(cb->val.u16);
+		if (cb->val.u16 =3D=3D 0)
+			cb->xflags &=3D ~XT_HMARK_FLAG(XT_HMARK_DPORT);
+		break;
+	case XT_HMARK_PROTO_MASK:
+		if (cb->val.u16 =3D=3D 0xffff)
+			cb->xflags &=3D ~XT_HMARK_FLAG(XT_HMARK_PROTO_MASK);
+		break;
+	case XT_HMARK_MODULUS:
+		if (info->hmodulus =3D=3D 0) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "xxx modulus 0 ? "
+				      "thats a div by 0");
+			info->hmodulus =3D 0xffffffff;
+		}
+		break;
+	case XT_HMARK_METHOD_L3:
+		if (strcmp(cb->arg, "L3") =3D=3D 0) {
+			info->proto_mask =3D 0;
+			cb->xflags &=3D ~XT_HMARK_FLAG(XT_HMARK_METHOD_L3_4);
+		} else if (strcmp(cb->arg, "L3-4") =3D=3D 0) {
+			cb->xflags &=3D ~XT_HMARK_FLAG(XT_HMARK_METHOD_L3);
+			cb->xflags |=3D XT_HMARK_FLAG(XT_HMARK_METHOD_L3_4);
+		}
+		break;
+	}
+	info->flags =3D cb->xflags;
+}
+
+static void HMARK_ip4_parse(struct xt_option_call *cb)
+{
+	HMARK_parse(cb, 32);
+}
+static void HMARK_ip6_parse(struct xt_option_call *cb)
+{
+	HMARK_parse(cb, 128);
+}
+
+static void HMARK_check(struct xt_fcheck_call *cb)
+{
+	if (!(cb->xflags & XT_HMARK_FLAG(XT_HMARK_MODULUS)))
+		xtables_error(PARAMETER_PROBLEM, "HMARK: the --hmark-mod, "
+			      "is not set, or zero wich is a div by zero");
+	/* Check for invalid options */
+	if (cb->xflags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3) &&
+	   (cb->xflags & XT_F_HMARK_L4_OPTS))
+		xtables_error(PARAMETER_PROBLEM, "HMARK: --hmark-method L3, "
+			      "can not be combined by an Layer 4 options: "
+			      "port, spi or proto ");
+	/* Check invalid mix of spi and ports since thye share data */
+	if (cb->xflags & XT_HMARK_FLAG(XT_HMARK_SPI_MASK) &&
+	    (cb->xflags & (XT_HMARK_FLAG(XT_HMARK_SPORT_MASK) |
+			   XT_HMARK_FLAG(XT_HMARK_DPORT_MASK))))
+		xtables_error(PARAMETER_PROBLEM, "HMARK: --hmark-spi-mask, "
+			      "can not be combined with port mask options ");
+
+	if (cb->xflags & XT_HMARK_FLAG(XT_HMARK_SPI) &&
+	    (cb->xflags & (XT_HMARK_FLAG(XT_HMARK_SPORT) |
+			   XT_HMARK_FLAG(XT_HMARK_DPORT))))
+		xtables_error(PARAMETER_PROBLEM, "HMARK: --hmark-spi-set, "
+			      "can not be combined with port set options ");
+}
+/*
+ * Common print for IPv4 & IPv6
+ */
+static void HMARK_print(const struct xt_hmark_info *info)
+{
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3)) {
+		printf("method L3 ");
+	} else {
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3_4))
+			printf("method L3-4 ");
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_SPORT_MASK))
+			printf("sport-mask 0x%x ",
+			       htons(info->port_mask.p16.src));
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_DPORT_MASK))
+			printf("dport-mask 0x%x ",
+			       htons(info->port_mask.p16.dst));
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_SPI_MASK))
+			printf("spi-mask 0x%x ", htonl(info->port_mask.v32));
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_SPORT))
+			printf("sport-set 0x%x ",
+			       htons(info->port_set.p16.src));
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_DPORT))
+			printf("dport-set 0x%x ",
+			       htons(info->port_set.p16.dst));
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_SPI))
+			printf("spi-set 0x%x ", htonl(info->port_set.v32));
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_PROTO_MASK))
+			printf("proto-mask 0x%x ", info->proto_mask);
+	}
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_RND))
+		printf("rnd 0x%x ", info->hashrnd);
+
+}
+
+static void HMARK_ip6_print(const void *ip,
+			    const struct xt_entry_target *target, int numeric)
+{
+	const struct xt_hmark_info *info =3D
+			(const struct xt_hmark_info *)target->data;
+
+	printf(" HMARK ");
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_MODULUS))
+		printf("%% 0x%x ", info->hmodulus);
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_OFFSET))
+		printf("+ 0x%x ", info->hoffset);
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_CT))
+		printf("ct, ");
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_SADR_MASK))
+		printf("src-mask %s ",
+		       xtables_ip6mask_to_numeric(&info->src_mask.in6) + 1);
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_DADR_MASK))
+		printf("dst-mask %s ",
+		       xtables_ip6mask_to_numeric(&info->dst_mask.in6) + 1);
+	HMARK_print(info);
+}
+static void HMARK_ip4_print(const void *ip,
+			    const struct xt_entry_target *target, int numeric)
+{
+	const struct xt_hmark_info *info =3D
+		(const struct xt_hmark_info *)target->data;
+
+	printf(" HMARK ");
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_MODULUS))
+		printf("%% 0x%x ", info->hmodulus);
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_OFFSET))
+		printf("+ 0x%x ", info->hoffset);
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_CT))
+		printf("ct, ");
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_SADR_MASK))
+		printf("src-mask %s ",
+		       xtables_ipmask_to_numeric(&info->src_mask.in) + 1);
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_DADR_MASK))
+		printf("dst-mask %s ",
+		       xtables_ipmask_to_numeric(&info->dst_mask.in) + 1);
+	HMARK_print(info);
+}
+static void HMARK_save(const struct xt_hmark_info *info)
+{
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3)) {
+		printf(" --hmark-method L3");
+	} else {
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3_4))
+			printf(" --hmark-method L3-4");
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_SPORT_MASK))
+			printf(" --hmark-sport-mask 0x%x",
+			       htons(info->port_mask.p16.src));
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_DPORT_MASK))
+			printf(" --hmark-dport-mask 0x%x",
+			       htons(info->port_mask.p16.dst));
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_SPI_MASK))
+			printf(" --hmark-spi-mask 0x%x",
+			       htonl(info->port_mask.v32));
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_SPORT))
+			printf(" --hmark-sport-set 0x%x",
+			       htons(info->port_set.p16.src));
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_DPORT))
+			printf(" --hmark-dport-set 0x%x",
+			       htons(info->port_set.p16.dst));
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_SPI))
+			printf(" --hmark-spi-set 0x%x",
+			       htonl(info->port_set.v32));
+		if (info->flags & XT_HMARK_FLAG(XT_HMARK_PROTO_MASK))
+			printf(" --hmark-proto-mask 0x%x", info->proto_mask);
+	}
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_RND))
+		printf(" --hmark-rnd 0x%x", info->hashrnd);
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_MODULUS))
+		printf(" --hmark-mod 0x%x", info->hmodulus);
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_OFFSET))
+		printf(" --hmark-offset 0x%x", info->hoffset);
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_CT))
+		printf(" --hmark-ct");
+}
+
+static void HMARK_ip6_save(const void *ip, const struct xt_entry_target *t=
arget)
+{
+	const struct xt_hmark_info *info =3D
+		(const struct xt_hmark_info *)target->data;
+
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_SADR_MASK))
+		printf(" --hmark-src-mask %s",
+		       xtables_ip6mask_to_numeric(&info->src_mask.in6) + 1);
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_DADR_MASK))
+		printf(" --hmark-dst-mask %s",
+		       xtables_ip6mask_to_numeric(&info->dst_mask.in6) + 1);
+	HMARK_save(info);
+}
+
+static void HMARK_ip4_save(const void *ip, const struct xt_entry_target *t=
arget)
+{
+	const struct xt_hmark_info *info =3D
+		(const struct xt_hmark_info *)target->data;
+
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_SADR_MASK))
+		printf(" --hmark-src-mask %s",
+		       xtables_ipmask_to_numeric(&info->src_mask.in) + 1);
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_DADR_MASK))
+		printf(" --hmark-dst-mask %s",
+		       xtables_ipmask_to_numeric(&info->dst_mask.in) + 1);
+	HMARK_save(info);
+}
+
+static struct xtables_target mark_tg_reg[] =3D {
+	{
+		.family        =3D NFPROTO_IPV4,
+		.name          =3D "HMARK",
+		.version       =3D XTABLES_VERSION,
+		.revision      =3D 0,
+		.size          =3D XT_ALIGN(sizeof(struct xt_hmark_info)),
+		.userspacesize =3D XT_ALIGN(sizeof(struct xt_hmark_info)),
+		.help          =3D HMARK_help,
+		.print         =3D HMARK_ip4_print,
+		.save          =3D HMARK_ip4_save,
+		.x6_parse      =3D HMARK_ip4_parse,
+		.x6_fcheck     =3D HMARK_check,
+		.x6_options    =3D HMARK_opts,
+	},
+	{
+		.family        =3D NFPROTO_IPV6,
+		.name          =3D "HMARK",
+		.version       =3D XTABLES_VERSION,
+		.revision      =3D 0,
+		.size          =3D XT_ALIGN(sizeof(struct xt_hmark_info)),
+		.userspacesize =3D XT_ALIGN(sizeof(struct xt_hmark_info)),
+		.help          =3D HMARK_help,
+		.print         =3D HMARK_ip6_print,
+		.save          =3D HMARK_ip6_save,
+		.x6_parse      =3D HMARK_ip6_parse,
+		.x6_fcheck     =3D HMARK_check,
+		.x6_options    =3D HMARK_opts,
+	},
+};
+
+void _init(void)
+{
+	xtables_register_targets(mark_tg_reg, ARRAY_SIZE(mark_tg_reg));
+}
diff --git a/extensions/libxt_HMARK.man b/extensions/libxt_HMARK.man
new file mode 100644
index 0000000..92bd1ed
=2D-- /dev/null
+++ b/extensions/libxt_HMARK.man
@@ -0,0 +1,84 @@
+This module does the same as MARK, i.e. set an fwmark, but the mark is bas=
ed on a hash value.
+The hash is based on src-addr, dst-addr, sport, dport and proto. The same =
mark will be produced independent of direction if no masks is set or the sa=
me masks is used for src and dest.
+The hash mark could be adjusted by modulus and finally an offset could be =
added, i.e the final mark will be within a range.
+ICMP error will use the the original message for hash calculation not the =
icmp it self.
+
+Note: IPv4 packets with nf_defrag_ipv4 loaded will be defragmented before =
they reach hmark,
+      IPv6 nf_defrag is not implemented this way, hence fragmented ipv6 pa=
ckets will reach hmark.
+      Default behavior is to completely ignore any fragment if it reach hm=
ark.
+      --hmark-method L3 is fragment safe since neither ports or L4 protoco=
l field is used.
+      None of the parameters effect the packet it self only the calculated=
 hash value.
+
+.PP
+Parameters:
+Short hand methods
+.TP
+\fB\-\-hmark\-method\fP \fIL3\fP
+Do not use L4 protocol field, ports or spi, only Layer 3 addresses, mask l=
ength
+of L3 addresses can still be used. Fragment or not does not matter in
+this case since only L3 address can be used in calc. of hash value.
+.TP
+\fB\-\-hmark\-method\fP \fIL3-4\fP (Default)
+Include L4 in calculation. of hash value i.e. all masks below are valid.
+Fragments will be ignored. (i.e no hash value produced)
+.PP
+For all masks default is all "1:s", to disable a field use mask 0
+.TP
+\fB\-\-hmark\-src\-mask\fP \fIlength\fP
+The length of the mask to AND the source address with (saddr & value).
+.TP
+\fB\-\-hmark\-dst\-mask\fP \fIlength\fP
+The length of the mask to AND the dest. address with (daddr & value).
+.TP
+\fB\-\-hmark\-sport\-mask\fP \fIvalue\fP
+A 16 bit value to AND the src port with (sport & value).
+.TP
+\fB\-\-hmark\-dport\-mask\fP \fIvalue\fP
+A 16 bit value to AND the dest port with (dport & value).
+.TP
+\fB\-\-hmark\-sport\-set\fP \fIvalue\fP
+A 16 bit value to OR the src port with (sport | value).
+.TP
+\fB\-\-hmark\-dport\-set\fP \fIvalue\fP
+A 16 bit value to OR the dest port with (dport | value).
+.TP
+\fB\-\-hmark\-spi\-mask\fP \fIvalue\fP
+Value to AND the spi field with (spi & value) valid for proto esp or ah.
+.TP
+\fB\-\-hmark\-spi\-set\fP \fIvalue\fP
+Value to OR the spi field with (spi | value) valid for proto esp or ah.
+.TP
+\fB\-\-hmark\-proto\-mask\fP \fIvalue\fP
+An 8 bit value to AND the L4 proto field with (proto & value).
+.TP
+\fB\-\-hmark\-ct\fP
+When flag is set, conntrack data should be used. Useful when NAT internal =
addressed should be used in calculation.
+Be careful when using DNAT since mangle table is handled before nat table.=
 I.e it will not work as expected to put HMARK in table mangle and PREROUTI=
NG chain. The initial packet will have it's hash based on the original addr=
ess, while the rest of the flow will use the NAT:ed address.
+.TP
+\fB\-\-hmark\-rnd\fP \fIvalue\fP
+A 32 bit initial value for hash calc, default is 0xc175a3b8.
+.PP
+Final processing of the mark in order of execution.
+.TP
+\fB\-\-hmark\-mod\fP \fIvalue (must be > 0)\fP
+The easiest way to describe this is:  hash =3D hash mod <value>
+.TP
+\fB\-\-hmark\-offset\fP \fIvalue\fP
+The easiest way to describe this is:  hash =3D hash + <value>
+.PP
+\fIExamples:\fP
+.PP
+Default rule handles all TCP, UDP, SCTP, ESP & AH
+.IP
+iptables \-t mangle \-A PREROUTING \-m state \-\-state NEW,ESTABLISHED,REL=
ATED
+ \-j HMARK \-\-hmark-offs 10000 \-\-hmark-mod 10
+.PP
+Handle SCTP and hash dest port only and produce a nfmark between 100-119.
+.IP
+iptables \-t mangle \-A PREROUTING -p SCTP \-j HMARK \-\-src\-mask 0 \-\-d=
st\-mask 0
+ \-\-sp\-mask 0 \-\-offset 100 \-\-mod 20
+.PP
+Fragment safe Layer 3 only that keep a class C network flow together
+.IP
+iptables \-t mangle \-A PREROUTING \-j HMARK \-\-method L3 \-\-src\-mask 2=
4 \-\-mod 20 \-\-offset 100
+
=2D-=20
1.7.2.3


--Boundary-00=_A1MqPZvDhAqO1ON--
