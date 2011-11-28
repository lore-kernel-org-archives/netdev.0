From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [v4 PATCH 1/2] NETFILTER module xt_hmark, new target
	for HASH based fwmark
Date: Mon, 28 Nov 2011 10:36:51 +0100 (CET)
Message-ID: <hr62jai.42522fc2b4c8846204d05566f5c6b926@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans.schillstrom@ericsson.com
To: "Pablo Neira Ayuso" <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
>On Fri, Nov 25, 2011 at 10:36:26AM +0100, Hans Schillstrom wrote:
>> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
>> index 3f0258d..9e4d4f9 100644
>> --- a/include/net/ipv6.h
>> +++ b/include/net/ipv6.h
>> @@ -39,6 +39,7 @@
>>  #define NEXTHDR_ICMP		58	/* ICMP for IPv6. */
>>  #define NEXTHDR_NONE		59	/* No next header */
>>  #define NEXTHDR_DEST		60	/* Destination options header. */
>> +#define NEXTHDR_SCTP		132	/* Stream Control Transport Protocol */
>>  #define NEXTHDR_MOBILITY	135	/* Mobility header. */
>>  
>>  #define NEXTHDR_MAX		255
>
>This has to go in a separated patch. Please, send it to netdev. I
>think davem can pick that for 3.2-rc

I will send this tiny one to Dave

[snip]

>> +static int get_inner_hdr(struct sk_buff *skb, int iphsz, int nhoff)
>> +{
>> +	const struct icmphdr *icmph;
>> +	struct icmphdr _ih;
>> +	struct iphdr *iph = NULL;
>> +
>> +	/* Not enough header? */
>> +	icmph = skb_header_pointer(skb, nhoff + iphsz, sizeof(_ih), &_ih);
>> +	if (icmph == NULL)
>> +		return nhoff;
>> +
>> +	if (icmph->type > NR_ICMP_TYPES)
>> +		return nhoff;
>> +
>> +	/* Error message? */
>> +	if (icmph->type != ICMP_DEST_UNREACH &&
>> +	    icmph->type != ICMP_SOURCE_QUENCH &&
>> +	    icmph->type != ICMP_TIME_EXCEEDED &&
>> +	    icmph->type != ICMP_PARAMETERPROB &&
>> +	    icmph->type != ICMP_REDIRECT)
>> +		return nhoff;
>> +	/* Checkin full IP header plus 8 bytes of protocol to
>> +	 * avoid additional coding at protocol handlers.
>> +	 */
>> +	if (!pskb_may_pull(skb, nhoff + iphsz + sizeof(_ih) + 8))
>> +		return nhoff;
>
>skb_header_pointer again here, if conntrack is enabled, we can benefit
>from handling fragments.
>
Yes, but I can't asume that conntrack is there.

[snip]

>> +/*
>> + * Calc hash value, special casre is taken on icmp and fragmented messages
>> + * i.e. fragmented messages don't use ports.
>> + */
>> +__u32 hmark_v6(struct sk_buff *skb, const struct xt_action_param *par)
>> +{
>> +	struct xt_hmark_info *info = (struct xt_hmark_info *)par->targinfo;
>> +	int nhoff, poff, hdrlen;
>> +	u32 addr1, addr2, hash;
>> +	struct ipv6hdr *ip6;
>> +	u8 nexthdr;
>> +	int frag = 0, ip6hdrlvl = 0;	/* Header level */
>> +	struct ipv6_opt_hdr _hdr, *hp;
>> +	union {
>> +		u32 v32;
>> +		u16 v16[2];
>> +	} ports;
>> +
>> +	ports.v32 = 0;
>> +	nhoff = skb_network_offset(skb);
>> +
>> +hdr_new:
>> +	/* Get header info */
>> +	ip6 = (struct ipv6hdr *) (skb->data + nhoff);
>> +	nexthdr = ip6->nexthdr;
>> +	hdrlen = sizeof(struct ipv6hdr);
>> +	hp = skb_header_pointer(skb, nhoff + hdrlen, sizeof(_hdr), &_hdr);
>
>you have to check return value of skb_header_pointer here.

This  is actually where next header will start if any, not the current one that is processed. 
It's not time for checking it now. The check is done before using it further down.

>
>> +	while (nexthdr) {
>> +		switch (nexthdr) {
>> +		case IPPROTO_ICMPV6:
>> +			/* ICMP Error then move ptr to inner header */
>> +			if (get_inner6_hdr(skb, &nhoff, hdrlen)) {
>> +				ip6hdrlvl++;
>> +				if (!pskb_may_pull(skb, sizeof(_hdr) + nhoff))
>> +					return XT_CONTINUE;
>> +				goto hdr_new;
>> +			}
>> +			nhoff += hdrlen;
>> +			goto hdr_rdy;
>> +
>> +		case NEXTHDR_FRAGMENT:
>> +			if (!ip6hdrlvl) /* Do not use ports if fragmented */
>> +				frag = 1;
>> +			break;
>> +
>> +		/* End of hdr traversing cont. with ports and hash calc. */
>> +		case NEXTHDR_IPV6:	/* Do not process tunnels */
>> +		case NEXTHDR_TCP:
>> +		case NEXTHDR_UDP:
>> +		case NEXTHDR_ESP:
>> +		case NEXTHDR_AUTH:
>> +		case NEXTHDR_SCTP:
>> +		case NEXTHDR_NONE:	/* Last hdr of something unknown */
>> +			nhoff += hdrlen;
>> +			goto hdr_rdy;
>> +		default:
>> +			return XT_CONTINUE;
>> +		}
>> +		if (!hp)
>> +			return XT_CONTINUE;
>> +		nhoff += hdrlen;	/* eat current header */
>> +		nexthdr =  hp->nexthdr;	/* Next header */
>> +		hdrlen = ipv6_optlen(hp);
>> +		hp = skb_header_pointer(skb, nhoff + hdrlen, sizeof(_hdr),
>> +					&_hdr);
>
>same here.
>
>> +		if (!pskb_may_pull(skb, nhoff))
>
>why this after skb_header_pointer?

hp is used for next turn, but you got a point here  I'll swap them 

>
>[... trimmed off ...]
>>       poff = proto_ports_offset(ip_proto);
>>       nhoff += ip->ihl * 4 + poff;
>>       if (frag || poff < 0 || !pskb_may_pull(skb, nhoff + 4))
>>               goto noports;
>>
>>       ports.v32 = * (__force u32 *) (skb->data + nhoff);
>>       if (ip_proto == IPPROTO_ESP || ip_proto == IPPROTO_AH) {
>>               ports.v32 = (ports.v32 & info->spimask) | nfo->spiset;
>>       } else {
>>               if (snatport)   /* Replace nat'ed port(s) */
>>                       ports.v16[1] = snatport;
>>               if (dnatport)
>>                       ports.v16[0] = dnatport;
>>               ports.v32 = (ports.v32 & info->pmask.v32) |
>>                               info->pset.v32;
>>               if (ports.v16[1] < ports.v16[0])
>>                       swap(ports.v16[0], ports.v16[1]);
>>       }
>>
>>noports:
>>       ip_proto &= info->prmask;
>>       /* get a consistent hash (same value on both flow directions)/
>>       if (addr2 < addr1)
>>               swap(addr1, addr2);
>>
>>       hash = jhash_3words(addr1, addr2, ports.v32, info->hashrnd) ^ p_proto;
>>       if (info->hmod)
>>               skb->mark = (hash % info->hmod) + info->hoffs;
>>       return XT_CONTINUE;
>> }
>
>Hm, I think the fragmentation handling is broken.
>
>Say that the first fragment contains the transport header
>header, then the mark is calculated based on the address and ports.
>Then, later on fragments will receive the mark based on the network
>header only. They may have different marks.

I think the documentation need improvments :-)
Fragments  never try to use ports.
"    if (frag)
         goto noports;"

>
>If you don't want to use conntrack in your setup and you want to handle
>fragments, then you have to configure HMARK to calculate the hashing
>based on the network addresses. If you want to fully support fragments,
>then enable conntrack and you can configure HMARK to calculate the
>hashing based on network address + transport bits.
>
>Fix this by removing the fragmentation handling, then assume that
>people can select between two hashing configuration for HMARK. One
>based for network address which is fragment-safe, one that uses the
>transport layer information, that requires conntrack. Otherwise, I
>don't see a sane way to handle this situation.

Correct me if I'm wrong here, 
If conntrack is enabled hmark don't see the packet until it is reassembled and 
in that case the fragmentation header is removed.

So, with conntrack HMARK will operate on full packets not fragments
without conntrack ports will not be used on any fragment.

>
>I think this has to be documented in the iptables manpage for HMARK.

The documentation needs update here, this is not crystal clear.

Thanks
Hans

