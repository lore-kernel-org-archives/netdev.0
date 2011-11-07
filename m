From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v2 PATCH 1/2] NETFILTER module xt_hmark new target for HASH
 based fw
Date: Mon, 7 Nov 2011 01:52:37 +0100
Message-ID: <20111107005237.GA29665@1984>
References: <1317664003-28189-1-git-send-email-hans.schillstrom@ericsson.com>
 <1317664003-28189-2-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans@schillstrom.com
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60424 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751889Ab1KGAwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Nov 2011 19:52:43 -0500
Content-Disposition: inline
In-Reply-To: <1317664003-28189-2-git-send-email-hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hans,

On Mon, Oct 03, 2011 at 07:46:42PM +0200, Hans Schillstrom wrote:
> diff --git a/include/linux/netfilter/xt_hmark.h b/include/linux/netfilter/xt_hmark.h
> new file mode 100644
> index 0000000..6c1436a
> --- /dev/null
> +++ b/include/linux/netfilter/xt_hmark.h
> @@ -0,0 +1,48 @@
> +#ifndef XT_HMARK_H_
> +#define XT_HMARK_H_
> +
> +#include <linux/types.h>
> +
> +/*
> + * Flags must not start at 0, since it's used as none.
> + */
> +enum {
> +	XT_HMARK_SADR_AND = 1,	/* SNAT & DNAT are used by the kernel module */
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
> +	XT_HMARK_USE_SNAT,
> +	XT_HMARK_USE_DNAT,
> +};
> +
> +union ports {
> +	struct {
> +		__u16	src;
> +		__u16	dst;
> +	} p16;
> +	__u32	v32;
> +};
> +
> +struct xt_hmark_info {
> +	__u32		smask;		/* Source address mask */
> +	__u32		dmask;		/* Dest address mask */
> +	union ports	pmask;
> +	union ports	pset;
> +	__u32		spimask;
> +	__u32		spiset;
> +	__u16		flags;		/* Print out only */
> +	__u16		prmask;		/* L4 Proto mask */
> +	__u32		hashrnd;
> +	__u32		hmod;		/* Modulus */
> +	__u32		hoffs;		/* Offset */
> +};
> +
> +#endif /* XT_HMARK_H_ */
> diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
> index 32bff6d..3abd3a4 100644
> --- a/net/netfilter/Kconfig
> +++ b/net/netfilter/Kconfig
> @@ -483,6 +483,23 @@ config NETFILTER_XT_TARGET_IDLETIMER
>  
>  	  To compile it as a module, choose M here.  If unsure, say N.
>  
> +config NETFILTER_XT_TARGET_HMARK

New config option has to go in alphabetic order (this one should go
after NETFILTER_XT_TARGET_HL).

> +	tristate '"HMARK" target support'
> +	depends on NETFILTER_ADVANCED
> +	---help---
> +	This option adds the "HMARK" target.
> +
> +	The target allows you to create rules in the "raw" and "mangle" tables
> +	which alter the netfilter mark (nfmark) field within a given range.
> +	First a 32 bit hash value is generated then modulus by <limit> and
> +	finally an offset is added before it's written to nfmark.
> +
> +	Prior to routing, the nfmark can influence the routing method (see
> +	"Use netfilter MARK value as routing key") and can also be used by
> +	other subsystems to change their behavior.
> +
> +	The mark match can also be used to match nfmark produced by this module.
> +
>  config NETFILTER_XT_TARGET_LED
>  	tristate '"LED" target support'
>  	depends on LEDS_CLASS && LEDS_TRIGGERS
> diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
> index 1a02853..359eeb6 100644
> --- a/net/netfilter/Makefile
> +++ b/net/netfilter/Makefile
> @@ -56,6 +56,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
>  obj-$(CONFIG_NETFILTER_XT_TARGET_CT) += xt_CT.o
>  obj-$(CONFIG_NETFILTER_XT_TARGET_DSCP) += xt_DSCP.o
>  obj-$(CONFIG_NETFILTER_XT_TARGET_HL) += xt_HL.o
> +obj-$(CONFIG_NETFILTER_XT_TARGET_HMARK) += xt_hmark.o
>  obj-$(CONFIG_NETFILTER_XT_TARGET_LED) += xt_LED.o
>  obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) += xt_NFLOG.o
>  obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) += xt_NFQUEUE.o
> diff --git a/net/netfilter/xt_hmark.c b/net/netfilter/xt_hmark.c
> new file mode 100644
> index 0000000..2f0aa93
> --- /dev/null
> +++ b/net/netfilter/xt_hmark.c
> @@ -0,0 +1,320 @@
> +/*
> + *	xt_hmark - Netfilter module to set mark as hash value
> + *
> + *	(C) 2010 Hans Schillstrom <hans.schillstrom@ericsson.com>
> + *
> + *	Description:
> + *	This module calculates a hash value that can be modified by modulus
> + *	and an offset. The hash value is based on a direction independent
> + *	five tuple: src & dst addr src & dst ports and protocol.
> + *	However src & dst port can be masked and are not used for fragmented
> + *	packets, ESP and AH don't have ports so SPI will be used instead.
> + *	For ICMP error messages the hash mark values will be calculated on
> + *	the source packet i.e. the packet caused the error (If sufficient
> + *	amount of data exists).
> + *
> + *	This program is free software; you can redistribute it and/or modify
> + *	it under the terms of the GNU General Public License version 2 as
> + *	published by the Free Software Foundation.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/skbuff.h>
> +#include <net/ip.h>
> +#include <linux/icmp.h>
> +
> +#include <linux/netfilter/xt_hmark.h>
> +#include <linux/netfilter/x_tables.h>
> +#include <net/netfilter/nf_nat.h>
> +
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +#	define WITH_IPV6 1
> +#include <net/ipv6.h>
> +#include <linux/netfilter_ipv6/ip6_tables.h>
> +#endif
> +
> +

extra space not required.

> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Hans Schillstrom <hans.schillstrom@ericsson.com>");
> +MODULE_DESCRIPTION("Xtables: packet range mark operations by hash value");
> +MODULE_ALIAS("ipt_HMARK");
> +MODULE_ALIAS("ip6t_HMARK");
> +
> +/*
> + * ICMP, get inner header so calc can be made on the source message
> + *       not the icmp header, i.e. same hash mark must be produced
> + *       on an icmp error message.
> + */
> +static int get_inner_hdr(struct sk_buff *skb, int iphsz, int nhoff)

This looks very similar to icmp_error in nf_conntrack_proto_icmp.c.
Yours lacks of checksumming validation btw.

I'm trying to find some place where we can put this function to make
it available for both nf_conntrack_ipv4 and your module (to avoid code
redundancy), but I didn't find any so far.

It would be nice to find some way to avoid duplicating code with
similar functionality.

> +{
> +	const struct icmphdr *icmph;
> +	struct icmphdr _ih;
> +	struct iphdr *iph = NULL;
> +
> +	/* Not enough header? */
> +	icmph = skb_header_pointer(skb, nhoff + iphsz, sizeof(_ih), &_ih);
> +	if (icmph == NULL)
> +		goto out;
> +
> +	if (icmph->type > NR_ICMP_TYPES)
> +		goto out;
> +
> +

extra space not required.

> +	/* Error message? */
> +	if (icmph->type != ICMP_DEST_UNREACH &&
> +	    icmph->type != ICMP_SOURCE_QUENCH &&
> +	    icmph->type != ICMP_TIME_EXCEEDED &&
> +	    icmph->type != ICMP_PARAMETERPROB &&
> +	    icmph->type != ICMP_REDIRECT)
> +		goto out;
> +	/* Checkin full IP header plus 8 bytes of protocol to
> +	 * avoid additional coding at protocol handlers.
> +	 */
> +	if (!pskb_may_pull(skb, nhoff + iphsz + sizeof(_ih) + 8))
> +		goto out;

We prefer skb_header_pointer instead. If conntrack is enabled, we can
benefit from defragmention. Please, replace all pskb_may_pull by
skb_header_pointer in this code.

We can assume that the IP header is linear (not fragmented).

> +	iph = (struct iphdr *)(skb->data + nhoff + iphsz + sizeof(_ih));
> +	return nhoff + iphsz + sizeof(_ih);
> +out:
> +	return nhoff;
> +}
> +/*
> + * ICMPv6
> + * Input nhoff Offset into network header
> + *       offset where ICMPv6 header starts
> + * Returns true if it's a icmp error and updates nhoff
> + */
> +#ifdef WITH_IPV6
> +static int get_inner6_hdr(struct sk_buff *skb, int *offset, int hdrlen)
> +{
> +	struct icmp6hdr *icmp6h;
> +	struct icmp6hdr _ih6;
> +
> +	icmp6h = skb_header_pointer(skb, *offset + hdrlen, sizeof(_ih6), &_ih6);
> +	if (icmp6h == NULL)
> +		goto out;
> +
> +	if (icmp6h->icmp6_type && icmp6h->icmp6_type < 128) {
> +		*offset += hdrlen + sizeof(_ih6);
> +		return 1;
> +	}
> +out:
> +	return 0;
> +}
> +#endif
> +
> +/*
> + * Calc hash value, special casre is taken on icmp and fragmented messages
> + * i.e. fragmented messages don't use ports.
> + */
> +static __u32 get_hash(struct sk_buff *skb, struct xt_hmark_info *info)

This function seems to big to me, please, split it into smaller
chunks, like get_hash_ipv4, get_hash_ipv6 and get_hash_ports.

> +{
> +	int nhoff, hash = 0, poff, proto, frag = 0;
> +	struct iphdr *ip;
> +	u8 ip_proto;
> +	u32 addr1, addr2, ihl;
> +	u16 snatport = 0, dnatport = 0;
> +	union {
> +		u32 v32;
> +		u16 v16[2];
> +	} ports;
> +
> +	nhoff = skb_network_offset(skb);
> +	proto = skb->protocol;
> +
> +	if (!proto && skb->sk) {
> +		if (skb->sk->sk_family == AF_INET)
> +			proto = __constant_htons(ETH_P_IP);
> +		else if (skb->sk->sk_family == AF_INET6)
> +			proto = __constant_htons(ETH_P_IPV6);

You already have the layer3 protocol number in xt_action_param. No
need to use the socket information then.

> +	}
> +
> +	switch (proto) {
> +	case __constant_htons(ETH_P_IP):
> +	{
> +		enum ip_conntrack_info ctinfo;
> +		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
> +		struct nf_conntrack_tuple *otuple, *rtuple;
> +
> +		if (!pskb_may_pull(skb, sizeof(*ip) + nhoff))
> +			goto done;
> +
> +		ip = (struct iphdr *) (skb->data + nhoff);
> +		if (ip->protocol == IPPROTO_ICMP) {
> +			/* Switch hash calc to inner header ? */
> +			nhoff = get_inner_hdr(skb, ip->ihl * 4, nhoff);
> +			ip = (struct iphdr *) (skb->data + nhoff);
> +		}
> +
> +		if (ip->frag_off & htons(IP_MF | IP_OFFSET))
> +			frag = 1;
> +
> +		ip_proto = ip->protocol;
> +		ihl = ip->ihl;
> +		addr1 = (__force u32) ip->saddr & info->smask;
> +		addr2 = (__force u32) ip->daddr & info->dmask;
> +
> +		if (!ct || !nf_ct_is_confirmed(ct))

You seem to (ab)use nf_ct_is_confirmed to make sure you're not in the
original direction. Better use the direction that you get by means of
nf_ct_get.

> +			break;
> +		otuple = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
> +		/* On the "return flow", to get the original address
> +		 * i,e, replace the source address.
> +		 */
> +		if (ct->status & IPS_DST_NAT &&
> +		    info->flags & XT_HMARK_USE_DNAT) {
> +			rtuple = &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
> +			addr1 = (__force u32) otuple->dst.u3.in.s_addr;
> +			dnatport = otuple->dst.u.udp.port;
> +		}
> +		/* On the "return flow", to get the original address
> +		 * i,e, replace the destination address.
> +		 */
> +		if (ct->status & IPS_SRC_NAT &&
> +		    info->flags & XT_HMARK_USE_SNAT) {
> +			rtuple = &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
> +			addr2 = (__force u32) otuple->src.u3.in.s_addr;
> +			snatport = otuple->src.u.udp.port;
> +		}
> +		break;
> +	}
> +#ifdef WITH_IPV6
> +	case __constant_htons(ETH_P_IPV6):
> +	{
> +		struct ipv6hdr *ip6;	/* ip hdr */
> +		int hdrlen = 0;	/* In ip header */
> +		u8 nexthdr;
> +		int ip6hdrlvl = 0;	/* Header level */
> +		struct ipv6_opt_hdr _hdr, *hp;
> +
> +hdr_new:
> +		if (!pskb_may_pull(skb, sizeof(*ip6) + nhoff))
> +			goto done;
> +
> +		/* ip header */
> +		ip6 = (struct ipv6hdr *) (skb->data + nhoff);
> +		nexthdr = ip6->nexthdr;
> +		/* nhoff += sizeof(struct ipv6hdr);  Where hdr starts */
> +		hdrlen = sizeof(struct ipv6hdr);
> +		hp = skb_header_pointer(skb, nhoff + hdrlen, sizeof(_hdr),
> +					&_hdr);
> +		while (nexthdr) {
> +			switch (nexthdr) {
> +			case IPPROTO_ICMPV6:
> +				/* ICMP Error then move ptr to inner header */
> +				if (get_inner6_hdr(skb, &nhoff, hdrlen)) {
> +					ip6hdrlvl++;
> +					goto hdr_new;
> +				}
> +				nhoff += hdrlen;
> +				goto hdr_rdy;
> +
> +			case NEXTHDR_FRAGMENT:
> +				if (!ip6hdrlvl)
> +					frag = 1;
> +				break;
> +			/* End of hdr traversing */
> +			case NEXTHDR_IPV6:	/* Do not process tunnels */
> +			case NEXTHDR_TCP:
> +			case NEXTHDR_UDP:
> +			case NEXTHDR_ESP:
> +			case NEXTHDR_AUTH:
> +			case NEXTHDR_NONE:
> +				nhoff += hdrlen;
> +				goto hdr_rdy;
> +			default:
> +				goto done;

This goto doesn't make too much sense to me, better return 0.

> +			}
> +			if (!hp)
> +				goto done;
> +			nhoff += hdrlen;	/* eat current header */
> +			nexthdr =  hp->nexthdr;	/* Next header */
> +			hdrlen = ipv6_optlen(hp);
> +			hp = skb_header_pointer(skb, nhoff + hdrlen,
> +						sizeof(_hdr), &_hdr);
> +
> +			if (!pskb_may_pull(skb, nhoff))
> +				goto done;
> +		}
> +hdr_rdy:
> +		ip_proto = nexthdr;
> +
> +		addr1 = (__force u32) ip6->saddr.s6_addr32[3];
> +		addr2 = (__force u32) ip6->daddr.s6_addr32[3];
> +		ihl = 0; /* (40 >> 2); */
> +		break;
> +	}
> +#endif
> +	default:
> +		goto done;
> +	}
> +
> +	ports.v32 = 0;
> +	poff = proto_ports_offset(ip_proto);
> +	nhoff += ihl * 4 + poff;
> +	if (!frag && poff >= 0 && pskb_may_pull(skb, nhoff + 4)) {
> +		ports.v32 = * (__force u32 *) (skb->data + nhoff);
> +		if (ip_proto == IPPROTO_ESP || ip_proto == IPPROTO_AH) {
> +			ports.v32 = (ports.v32 & info->spimask) | info->spiset;
> +		} else { /* Handle endian */
> +			if (snatport)	/* Replace snated dst port (ret flow) */
> +				ports.v16[1] = snatport;
> +			if (dnatport)
> +				ports.v16[0] = dnatport;
> +			ports.v32 = (ports.v32 & info->pmask.v32) |
> +				    info->pset.v32;
> +			if (ports.v16[1] < ports.v16[0])
> +				swap(ports.v16[0], ports.v16[1]);
> +		}
> +	}
> +	ip_proto &= info->prmask;
> +	/* get a consistent hash (same value on both flow directions) */
> +	if (addr2 < addr1)
> +		swap(addr1, addr2);
> +
> +	hash = jhash_3words(addr1, addr2, ports.v32, info->hashrnd) ^ ip_proto;
> +	if (!hash)
> +		hash = 1;
> +
> +	return hash;
> +
> +done:
> +	return 0;
> +}

I'll try to find more time to look into this. Specifically, I want to
review the IPv6 bits more carefully.
