From: Patrick McHardy <kaber@trash.net>
Subject: Re: [v4 PATCH 1/2] NETFILTER module xt_hmark, new target for HASH
 based fwmark
Date: Wed, 30 Nov 2011 16:51:35 +0100
Message-ID: <4ED65107.1040309@trash.net>
References: <1322213787-25796-1-git-send-email-hans@schillstrom.com> <1322213787-25796-2-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans.schillstrom@ericsson.com
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1322213787-25796-2-git-send-email-hans@schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/25/2011 10:36 AM, Hans Schillstrom wrote:
> +__u32 hmark_v6(struct sk_buff *skb, const struct xt_action_param *par)
> +{
> +	struct xt_hmark_info *info = (struct xt_hmark_info *)par->targinfo;
> +	int nhoff, poff, hdrlen;
> +	u32 addr1, addr2, hash;
> +	struct ipv6hdr *ip6;
> +	u8 nexthdr;
> +	int frag = 0, ip6hdrlvl = 0;	/* Header level */
> +	struct ipv6_opt_hdr _hdr, *hp;
> +	union {
> +		u32 v32;
> +		u16 v16[2];
> +	} ports;
> +
> +	ports.v32 = 0;
> +	nhoff = skb_network_offset(skb);
> +
> +hdr_new:
> +	/* Get header info */
> +	ip6 = (struct ipv6hdr *) (skb->data + nhoff);
> +	nexthdr = ip6->nexthdr;
> +	hdrlen = sizeof(struct ipv6hdr);
> +	hp = skb_header_pointer(skb, nhoff + hdrlen, sizeof(_hdr),&_hdr);
> +
> +	while (nexthdr) {
> +		switch (nexthdr) {
> +		case IPPROTO_ICMPV6:
> +			/* ICMP Error then move ptr to inner header */
> +			if (get_inner6_hdr(skb,&nhoff, hdrlen)) {

This doesn't look right. You assume the ICMPv6 header is following
the IPv6 header with any other headers in between. If there are
other headers, hdrlen will contain the length of the last header.

> +				ip6hdrlvl++;
> +				if (!pskb_may_pull(skb, sizeof(_hdr) + nhoff))
> +					return XT_CONTINUE;
> +				goto hdr_new;
> +			}
> +			nhoff += hdrlen;
> +			goto hdr_rdy;
> +
> +		case NEXTHDR_FRAGMENT:
> +			if (!ip6hdrlvl) /* Do not use ports if fragmented */
> +				frag = 1;

Shouldn't you also check for fragment offset == 0 here?
The fragment header also doesn't include the length, so
using ipv6_optlen() below is incorrect.
> +			break;
> +
> +		/* End of hdr traversing cont. with ports and hash calc. */
> +		case NEXTHDR_IPV6:	/* Do not process tunnels */

That comment looks misleading, you do seem to process them?

> +		case NEXTHDR_TCP:
> +		case NEXTHDR_UDP:
> +		case NEXTHDR_ESP:
> +		case NEXTHDR_AUTH:

Don't you want to use the port numbers if only authentication
without encryption is used?

> +		case NEXTHDR_SCTP:
> +		case NEXTHDR_NONE:	/* Last hdr of something unknown */
> +			nhoff += hdrlen;
> +			goto hdr_rdy;
> +		default:
> +			return XT_CONTINUE;
> +		}
> +		if (!hp)
> +			return XT_CONTINUE;
> +		nhoff += hdrlen;	/* eat current header */
> +		nexthdr =  hp->nexthdr;	/* Next header */
> +		hdrlen = ipv6_optlen(hp);
> +		hp = skb_header_pointer(skb, nhoff + hdrlen, sizeof(_hdr),
> +					&_hdr);
> +
> +		if (!pskb_may_pull(skb, nhoff))
> +			return XT_CONTINUE;
> +	}

And final question, why not simply use ipv6_skip_exthdr()?

> +hdr_rdy:
> +...


