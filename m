From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v12 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH
 based fwmark
Date: Mon, 7 May 2012 00:57:38 +0200
Message-ID: <20120506225738.GA23009@1984>
References: <1335188128-23645-1-git-send-email-hans.schillstrom@ericsson.com>
 <201205020955.01498.hans.schillstrom@ericsson.com>
 <20120502080944.GA17393@1984>
 <201205021949.48741.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="huq684BweRXVnRxX"
Cc: "kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201205021949.48741.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Hans,

[...]
> > > > Regarding ICMP traffic, I think we can use the ID field for the
> > > > hashing as well. Thus, we handle ICMP like other protocols.
> > > 
> > > Yes why not, I can give it a try.
> > > 
> 
> I think we wait with this one..

I see. This is easy to add for the conntrack side, but it will require
some extra code for the packet-based solution.

Not directly related to this but, I know that your intention is to
make this as flexible as possible. However, I still don't find how I
would use the port mask feature in any of my setups.  Basically, I
don't come up with any useful example for this situation.

I'm also telling this because I think that ICMP support will be
easier to add if port masking is removed.

[...]
> This is what I have done.
> 
> - I reduced the code size a little bit by combining the hmark_ct_set_htuple_ipvX into one func.
>   by adding a hmark_addr6_mask() and hmark_addr_any_mask()
>   Note that using "otuple->src.l3num" as param 1 in both src and dst is not a typo.
>   (it's not set in the rtuple)

Good one, this made the code even smaller.

> - Made the if (dst < src) swap() in the hmark_hash() since it should be used by every caller.

Not really, you don't need for the conntrack part. The original tuple
is always the same, not matter where the packet is coming from. I have
removed this again so it only affects packet-based hashing.

> - Moved the L3 check a little bit earlier.

good.

> - changed return values for fragments.

With this, you're giving up on trying to classify fragments. Do you
really want this?

>From my point of view, if your firewalls (assuming they are the HMARK
classification) are stateless, it still makes sense to me to classify
fragments using the XT_HMARK_METHOD_L3_4.

> - Added nhoffs to: hmark_set_tuple_ports(skb, (ip->ihl * 4) + nhoff, t, info);
>   to get icmp working

good catch.

Below, some minor changes that I made to your patch (you can find a
new version enclosed to this email).

[...]
> +#ifndef XT_HMARK_H_
> +#define XT_HMARK_H_
> +
> +#include <linux/types.h>
> +
> +enum {
> +	XT_HMARK_NONE,
> +	XT_HMARK_SADR_AND,
> +	XT_HMARK_DADR_AND,
> +	XT_HMARK_SPI_AND,
> +	XT_HMARK_SPI_OR,
> +	XT_HMARK_SPORT_AND,
> +	XT_HMARK_DPORT_AND,
> +	XT_HMARK_SPORT_OR,
> +	XT_HMARK_DPORT_OR,
> +	XT_HMARK_PROTO_AND,
> +	XT_HMARK_RND,
> +	XT_HMARK_MODULUS,
> +	XT_HMARK_OFFSET,
> +	XT_HMARK_CT,
> +	XT_HMARK_METHOD_L3,
> +	XT_HMARK_METHOD_L3_4,
> +	XT_F_HMARK_SADR_AND    = 1 << XT_HMARK_SADR_AND,
> +	XT_F_HMARK_DADR_AND    = 1 << XT_HMARK_DADR_AND,
> +	XT_F_HMARK_SPI_AND     = 1 << XT_HMARK_SPI_AND,
> +	XT_F_HMARK_SPI_OR      = 1 << XT_HMARK_SPI_OR,
> +	XT_F_HMARK_SPORT_AND   = 1 << XT_HMARK_SPORT_AND,
> +	XT_F_HMARK_DPORT_AND   = 1 << XT_HMARK_DPORT_AND,
> +	XT_F_HMARK_SPORT_OR    = 1 << XT_HMARK_SPORT_OR,
> +	XT_F_HMARK_DPORT_OR    = 1 << XT_HMARK_DPORT_OR,
> +	XT_F_HMARK_PROTO_AND   = 1 << XT_HMARK_PROTO_AND,
> +	XT_F_HMARK_RND         = 1 << XT_HMARK_RND,
> +	XT_F_HMARK_MODULUS     = 1 << XT_HMARK_MODULUS,
> +	XT_F_HMARK_OFFSET      = 1 << XT_HMARK_OFFSET,
> +	XT_F_HMARK_CT          = 1 << XT_HMARK_CT,
> +	XT_F_HMARK_METHOD_L3   = 1 << XT_HMARK_METHOD_L3,
> +	XT_F_HMARK_METHOD_L3_4 = 1 << XT_HMARK_METHOD_L3_4,

I've defined:

#define XT_HMARK_FLAG(flag) (1 << flag)

So we save all those extra _F_ defintions, they look redundant.

[...]
> diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
> new file mode 100644
> index 0000000..76a3fa7
> --- /dev/null
> +++ b/net/netfilter/xt_HMARK.c
> +/*
> + * xt_HMARK - Netfilter module to set mark as hash value
> + *
> + * (C) 2012 by Hans Schillstrom <hans.schillstrom@ericsson.com>
> + * (C) 2012 by Pablo Neira Ayuso <pablo@netfilter.org>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License version 2 as published by
> + * the Free Software Foundation.
> + *
> + * Description:
> + *
> + * This module calculates a hash value that can be modified by modulus and an
> + * offset, i.e. it is possible to produce a skb->mark within a range The hash
> + * value is based on a direction independent five tuple: src & dst addr src &
> + * dst ports and protocol.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/skbuff.h>
> +#include <linux/icmp.h>
> +
> +#include <linux/netfilter/x_tables.h>
> +#include <linux/netfilter/xt_HMARK.h>
> +
> +#include <net/ip.h>
> +#if IS_ENABLED(CONFIG_NF_CONNTRACK)
> +#include <net/netfilter/nf_conntrack.h>
> +#endif
> +#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
> +#include <net/ipv6.h>
> +#include <linux/netfilter_ipv6/ip6_tables.h>
> +#endif
> +
> +

I removed this extra blank line above.

> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Hans Schillstrom <hans.schillstrom@ericsson.com>");
> +MODULE_DESCRIPTION("Xtables: packet marking using hash calculation");
> +MODULE_ALIAS("ipt_HMARK");
> +MODULE_ALIAS("ip6t_HMARK");
> +
> +struct hmark_tuple {
> +	u32			src;
> +	u32			dst;
> +	union hmark_ports	uports;
> +	uint8_t			proto;
> +};
> +
> +static int
> +hmark_ct_set_htuple(const struct sk_buff *skb, struct hmark_tuple *t,
> +			 const struct xt_hmark_info *info);
> +static inline u32
> +hmark_hash(struct hmark_tuple *t, const struct xt_hmark_info *info)
> +{
> +	u32 hash;
> +
> +	if (t->dst < t->src)
> +		swap(t->src, t->dst);
> +
> +	hash = jhash_3words(t->src, t->dst, t->uports.v32, info->hashrnd);
> +	hash = hash ^ (t->proto & info->proto_mask);
> +
> +	return (hash % info->hmodulus) + info->hoffset;
> +}
> +
> +static void
> +hmark_set_tuple_ports(const struct sk_buff *skb, unsigned int nhoff,
> +		      struct hmark_tuple *t, const struct xt_hmark_info *info)
> +{
> +	int protoff;
> +
> +	protoff = proto_ports_offset(t->proto);
> +	if (protoff < 0)
> +		return;
> +
> +	nhoff += protoff;
> +	if (skb_copy_bits(skb, nhoff, &t->uports, sizeof(t->uports)) < 0)
> +		return;
> +
> +	if (t->proto == IPPROTO_ESP || t->proto == IPPROTO_AH)
> +		t->uports.v32 = (t->uports.v32 & info->spi_mask) |
> +				info->spi_set;
> +	else {
> +		t->uports.v32 = (t->uports.v32 & info->port_mask.v32) |
> +				info->port_set.v32;
> +
> +		if (t->uports.p16.dst < t->uports.p16.src)
> +			swap(t->uports.p16.dst, t->uports.p16.src);
> +	}
> +}
> +
> +#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
> +static int get_inner6_hdr(const struct sk_buff *skb, int *offset)
> +{
> +	struct icmp6hdr *icmp6h, _ih6;
> +
> +	icmp6h = skb_header_pointer(skb, *offset, sizeof(_ih6), &_ih6);
> +	if (icmp6h == NULL)
> +		return 0;
> +
> +	if (icmp6h->icmp6_type && icmp6h->icmp6_type < 128) {
> +		*offset += sizeof(struct icmp6hdr);
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +static inline u32 hmark_addr6_mask(const __u32 *addr32, const __u32 *mask)
> +{
> +	return  (addr32[0] & mask[0]) ^
> +		(addr32[1] & mask[1]) ^
> +		(addr32[2] & mask[2]) ^
> +		(addr32[3] & mask[3]);
> +}
> +
> +static int
> +hmark_pkt_set_htuple_ipv6(const struct sk_buff *skb, struct hmark_tuple *t,
> +			  const struct xt_hmark_info *info)
> +{
> +	struct ipv6hdr *ip6, _ip6;
> +	int flag = IP6T_FH_F_AUTH; /* Ports offset, find_hdr flags */
> +	unsigned int nhoff = 0;
> +	u16 fragoff = 0;
> +	int nexthdr;
> +
> +	ip6 = (struct ipv6hdr *) (skb->data + skb_network_offset(skb));
> +	nexthdr = ipv6_find_hdr(skb, &nhoff, -1, &fragoff, &flag);
> +	if (nexthdr < 0)
> +		return 0;
> +	/* No need to check for icmp errors on fragments */
> +	if ((flag & IP6T_FH_F_FRAG) || (nexthdr != IPPROTO_ICMPV6))
> +		goto noicmp;
> +	/* if an icmp error, use the inner header */
> +	if (get_inner6_hdr(skb, &nhoff)) {
> +		ip6 = skb_header_pointer(skb, nhoff, sizeof(_ip6), &_ip6);
> +		if (ip6 == NULL)
> +			return -1;
> +		/* Treat AH as ESP, use SPI nothing else. */
> +		flag = IP6T_FH_F_AUTH;
> +		nexthdr = ipv6_find_hdr(skb, &nhoff, -1, &fragoff, &flag);
> +		if (nexthdr < 0)
> +			return -1;
> +	}
> +noicmp:
> +	t->src = hmark_addr6_mask(ip6->saddr.s6_addr32, info->src_mask.all);
> +	t->dst = hmark_addr6_mask(ip6->daddr.s6_addr32, info->dst_mask.all);
> +
> +	if (info->flags & XT_F_HMARK_METHOD_L3)
> +		return 0;
> +
> +	t->proto = nexthdr;
> +
> +	if (t->proto == IPPROTO_ICMPV6)
> +		return 0;
> +
> +	if (flag & IP6T_FH_F_FRAG)
> +		return -1;
> +
> +	hmark_set_tuple_ports(skb, nhoff, t, info);
> +
> +	return 0;
> +}
> +
> +static unsigned int
> +hmark_tg_v6(struct sk_buff *skb, const struct xt_action_param *par)
> +{
> +	const struct xt_hmark_info *info = par->targinfo;
> +	struct hmark_tuple t;
> +
> +	memset(&t, 0, sizeof(struct hmark_tuple));
> +
> +	if (info->flags & XT_F_HMARK_CT) {
> +		if (hmark_ct_set_htuple(skb, &t, info) < 0)
> +			return XT_CONTINUE;
> +	} else {
> +		if (hmark_pkt_set_htuple_ipv6(skb, &t, info) < 0)
> +			return XT_CONTINUE;
> +	}
> +
> +	skb->mark = hmark_hash(&t, info);
> +	return XT_CONTINUE;
> +}
> +
> +static inline u32
> +hmark_addr_any_mask(int l3num, const __u32 *addr32, const __u32 *mask)
> +{
> +	if (l3num == AF_INET)
> +		return *addr32 & *mask;
> +
> +	return hmark_addr6_mask(addr32, mask);
> +}
> +#else
> +static inline u32
> +hmark_addr_any_mask(int l3num, const __u32 *addr32, const __u32 *mask)
> +{
> +	return *addr32 & *mask;
> +}
> +
> +#endif

This is ugly. I think you will not find any section of the Netfilter
code with something similar. I have declared this function out of the
#ifdef section, those are static inline, the compiler will put them
out if unused with no further complain.

Please, find a new takeover patch enclosed.

--huq684BweRXVnRxX
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-add-xt_hmark-target-for-hash-based-skb-mar.patch"

>From d5065af3988cc7561a02f30bae8342e1a89126a4 Mon Sep 17 00:00:00 2001
From: Hans Schillstrom <hans.schillstrom@ericsson.com>
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

 iptables -t mangle -A PREROUTING -p SCTP -j HMARK --src-mask 0 --dst-mask 0 \
	--sp-mask 0 --offset 100 --mod 20

* Fragment safe Layer 3 only, that keep a class C network flow together

 iptables -t mangle -A PREROUTING -j HMARK --method L3 \
	--src-mask 24 --mod 20 --offset 100

[ A big part of this patch has been refactorized by Pablo Neira Ayuso ]

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/linux/netfilter/xt_HMARK.h |   48 +++++
 net/netfilter/Kconfig              |   15 ++
 net/netfilter/Makefile             |    1 +
 net/netfilter/xt_HMARK.c           |  358 ++++++++++++++++++++++++++++++++++++
 4 files changed, 422 insertions(+)
 create mode 100644 include/linux/netfilter/xt_HMARK.h
 create mode 100644 net/netfilter/xt_HMARK.c

diff --git a/include/linux/netfilter/xt_HMARK.h b/include/linux/netfilter/xt_HMARK.h
new file mode 100644
index 0000000..05e43ba
--- /dev/null
+++ b/include/linux/netfilter/xt_HMARK.h
@@ -0,0 +1,48 @@
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
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -509,6 +509,21 @@ config NETFILTER_XT_TARGET_HL
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
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -59,6 +59,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CT) += xt_CT.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_DSCP) += xt_DSCP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_HL) += xt_HL.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_HMARK) += xt_HMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_LED) += xt_LED.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_LOG) += xt_LOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) += xt_NFLOG.o
diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
new file mode 100644
index 0000000..b4aa912
--- /dev/null
+++ b/net/netfilter/xt_HMARK.c
@@ -0,0 +1,358 @@
+/*
+ * xt_HMARK - Netfilter module to set mark by means of hashing
+ *
+ * (C) 2012 by Hans Schillstrom <hans.schillstrom@ericsson.com>
+ * (C) 2012 by Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
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
+	switch(l3num) {
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
+	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
+	struct nf_conntrack_tuple *otuple;
+	struct nf_conntrack_tuple *rtuple;
+
+	if (ct == NULL || nf_ct_is_untracked(ct))
+		return -1;
+
+	otuple = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
+	rtuple = &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
+
+	t->src = hmark_addr_mask(otuple->src.l3num, otuple->src.u3.all,
+				 info->src_mask.all);
+	t->dst = hmark_addr_mask(otuple->src.l3num, rtuple->src.u3.all,
+				 info->dst_mask.all);
+
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3))
+		return 0;
+
+	t->proto = nf_ct_protonum(ct);
+	if (t->proto != IPPROTO_ICMP) {
+		t->uports.p16.src = otuple->src.u.all;
+		t->uports.p16.dst = rtuple->src.u.all;
+		t->uports.v32 = (t->uports.v32 & info->port_mask.v32) |
+				info->port_set.v32;
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
+	hash = jhash_3words(t->src, t->dst, t->uports.v32, info->hashrnd);
+	hash = hash ^ (t->proto & info->proto_mask);
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
+	protoff = proto_ports_offset(t->proto);
+	if (protoff < 0)
+		return;
+
+	nhoff += protoff;
+	if (skb_copy_bits(skb, nhoff, &t->uports, sizeof(t->uports)) < 0)
+		return;
+
+	if (t->proto == IPPROTO_ESP || t->proto == IPPROTO_AH)
+		t->uports.v32 = (t->uports.v32 & info->spi_mask) |
+				info->spi_set;
+	else {
+		t->uports.v32 = (t->uports.v32 & info->port_mask.v32) |
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
+
+static int
+hmark_pkt_set_htuple_ipv6(const struct sk_buff *skb, struct hmark_tuple *t,
+			  const struct xt_hmark_info *info)
+{
+	struct ipv6hdr *ip6, _ip6;
+	int flag = IP6T_FH_F_AUTH; /* Ports offset, find_hdr flags */
+	unsigned int nhoff = 0;
+	u16 fragoff = 0;
+	int nexthdr;
+
+	ip6 = (struct ipv6hdr *) (skb->data + skb_network_offset(skb));
+	nexthdr = ipv6_find_hdr(skb, &nhoff, -1, &fragoff, &flag);
+	if (nexthdr < 0)
+		return 0;
+	/* No need to check for icmp errors on fragments */
+	if ((flag & IP6T_FH_F_FRAG) || (nexthdr != IPPROTO_ICMPV6))
+		goto noicmp;
+	/* if an icmp error, use the inner header */
+	if (get_inner6_hdr(skb, &nhoff)) {
+		ip6 = skb_header_pointer(skb, nhoff, sizeof(_ip6), &_ip6);
+		if (ip6 == NULL)
+			return -1;
+		/* Treat AH as ESP, use SPI nothing else. */
+		flag = IP6T_FH_F_AUTH;
+		nexthdr = ipv6_find_hdr(skb, &nhoff, -1, &fragoff, &flag);
+		if (nexthdr < 0)
+			return -1;
+	}
+noicmp:
+	t->src = hmark_addr6_mask(ip6->saddr.s6_addr32, info->src_mask.all);
+	t->dst = hmark_addr6_mask(ip6->daddr.s6_addr32, info->dst_mask.all);
+
+	if (t->dst < t->src)
+		swap(t->src, t->dst);
+
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3))
+		return 0;
+
+	t->proto = nexthdr;
+
+	if (t->proto == IPPROTO_ICMPV6)
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
+	const struct xt_hmark_info *info = par->targinfo;
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
+	skb->mark = hmark_hash(&t, info);
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
+static int
+hmark_pkt_set_htuple_ipv4(const struct sk_buff *skb, struct hmark_tuple *t,
+			  const struct xt_hmark_info *info)
+{
+	struct iphdr *ip, _ip;
+	int nhoff = skb_network_offset(skb);
+
+	ip = (struct iphdr *) (skb->data + nhoff);
+	if (ip->protocol == IPPROTO_ICMP) {
+		/* use inner header in case of ICMP errors */
+		if (get_inner_hdr(skb, ip->ihl * 4, &nhoff)) {
+			ip = skb_header_pointer(skb, nhoff, sizeof(_ip), &_ip);
+			if (ip == NULL)
+				return -1;
+		}
+	}
+
+	t->src = (__force u32) ip->saddr;
+	t->dst = (__force u32) ip->daddr;
+
+	t->src &= info->src_mask.ip;
+	t->dst &= info->dst_mask.ip;
+
+	if (t->dst < t->src)
+		swap(t->src, t->dst);
+
+	if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3))
+		return 0;
+
+	t->proto = ip->protocol;
+
+	/* ICMP has no ports, skip */
+	if (t->proto == IPPROTO_ICMP)
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
+	const struct xt_hmark_info *info = par->targinfo;
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
+	skb->mark = hmark_hash(&t, info);
+	return XT_CONTINUE;
+}
+
+static int hmark_tg_check(const struct xt_tgchk_param *par)
+{
+	const struct xt_hmark_info *info = par->targinfo;
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
+	return 0;
+}
+
+static struct xt_target hmark_tg_reg[] __read_mostly = {
+	{
+		.name		= "HMARK",
+		.family		= NFPROTO_IPV4,
+		.target		= hmark_tg_v4,
+		.targetsize	= sizeof(struct xt_hmark_info),
+		.checkentry	= hmark_tg_check,
+		.me		= THIS_MODULE,
+	},
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
+	{
+		.name		= "HMARK",
+		.family		= NFPROTO_IPV6,
+		.target		= hmark_tg_v6,
+		.targetsize	= sizeof(struct xt_hmark_info),
+		.checkentry	= hmark_tg_check,
+		.me		= THIS_MODULE,
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
-- 
1.7.9.5


--huq684BweRXVnRxX--
