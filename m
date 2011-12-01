From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [v4 PATCH 1/2] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Thu, 1 Dec 2011 01:25:29 +0100
Message-ID: <201112010125.29627.hans@schillstrom.com>
References: <1322213787-25796-1-git-send-email-hans@schillstrom.com> <1322213787-25796-2-git-send-email-hans@schillstrom.com> <4ED65107.1040309@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans.schillstrom@ericsson.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4ED65107.1040309@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, November 30, 2011 16:51:35 Patrick McHardy wrote:
> On 11/25/2011 10:36 AM, Hans Schillstrom wrote:
> > +__u32 hmark_v6(struct sk_buff *skb, const struct xt_action_param *par)
> > +{
> > +	struct xt_hmark_info *info = (struct xt_hmark_info *)par->targinfo;
> > +	int nhoff, poff, hdrlen;
> > +	u32 addr1, addr2, hash;
> > +	struct ipv6hdr *ip6;
> > +	u8 nexthdr;
> > +	int frag = 0, ip6hdrlvl = 0;	/* Header level */
> > +	struct ipv6_opt_hdr _hdr, *hp;
> > +	union {
> > +		u32 v32;
> > +		u16 v16[2];
> > +	} ports;
> > +
> > +	ports.v32 = 0;
> > +	nhoff = skb_network_offset(skb);
> > +
> > +hdr_new:
> > +	/* Get header info */
> > +	ip6 = (struct ipv6hdr *) (skb->data + nhoff);
> > +	nexthdr = ip6->nexthdr;
> > +	hdrlen = sizeof(struct ipv6hdr);
> > +	hp = skb_header_pointer(skb, nhoff + hdrlen, sizeof(_hdr),&_hdr);
> > +
> > +	while (nexthdr) {
> > +		switch (nexthdr) {
> > +		case IPPROTO_ICMPV6:
> > +			/* ICMP Error then move ptr to inner header */
> > +			if (get_inner6_hdr(skb,&nhoff, hdrlen)) {
> 
> This doesn't look right. You assume the ICMPv6 header is following
> the IPv6 header with any other headers in between. If there are
> other headers, hdrlen will contain the length of the last header.
 
RFC-4443  "Every ICMPv6 message is preceded by an IPv6 header and zero or more IPv6 extension headers."
hdrlen is actually previous header length in bytes, to be correct.
nhoff is the sum of processed headers.
So in case of an icmp the nhoff will be updated, and hdrlen preset to ipv6hdr size

> > +				ip6hdrlvl++;
> > +				if (!pskb_may_pull(skb, sizeof(_hdr) + nhoff))
> > +					return XT_CONTINUE;
> > +				goto hdr_new;
> > +			}
> > +			nhoff += hdrlen;
> > +			goto hdr_rdy;
> > +
> > +		case NEXTHDR_FRAGMENT:
> > +			if (!ip6hdrlvl) /* Do not use ports if fragmented */
> > +				frag = 1;
> 
> Shouldn't you also check for fragment offset == 0 here?

According to the RFC "Initialized to zero for transmission; ignored on reception"

> The fragment header also doesn't include the length, so
> using ipv6_optlen() below is incorrect.

True, it has a fixed size, of 8 octets
I'll fix that. 
(as long as it is zero it will work :-)

> > +			break;
> > +
> > +		/* End of hdr traversing cont. with ports and hash calc. */
> > +		case NEXTHDR_IPV6:	/* Do not process tunnels */
> 
> That comment looks misleading, you do seem to process them?

Ooops a "return XT_CONTINUE;" seems to be missing here.

> 
> > +		case NEXTHDR_TCP:
> > +		case NEXTHDR_UDP:
> > +		case NEXTHDR_ESP:
> > +		case NEXTHDR_AUTH:
> 
> Don't you want to use the port numbers if only authentication
> without encryption is used?

with esp or ah the SPI will be used instead of ports.
Useful or not I don't know since they are asymmetric in terms of a flow.

> 
> > +		case NEXTHDR_SCTP:
> > +		case NEXTHDR_NONE:	/* Last hdr of something unknown */
> > +			nhoff += hdrlen;
> > +			goto hdr_rdy;
> > +		default:
> > +			return XT_CONTINUE;
> > +		}
> > +		if (!hp)
> > +			return XT_CONTINUE;
> > +		nhoff += hdrlen;	/* eat current header */
> > +		nexthdr =  hp->nexthdr;	/* Next header */
> > +		hdrlen = ipv6_optlen(hp);
> > +		hp = skb_header_pointer(skb, nhoff + hdrlen, sizeof(_hdr),
> > +					&_hdr);
> > +
> > +		if (!pskb_may_pull(skb, nhoff))
> > +			return XT_CONTINUE;
> > +	}
> 
> And final question, why not simply use ipv6_skip_exthdr()?

problems with fragments...
But when looking into ipv6_skip_exthdr() again I realize that handling of 
NEXTHDR_HOP NEXTHDR_ROUTING, and NEXTHDR_DEST is wrong.

It think I need to rewrite this part a bit

just skip this headers;
	case NEXTHDR_HOP:
	case NEXTHDR_ROUTING:
	case NEXTHDR_DEST:
		break;

and exit on this:
	case NEXTHDR_IPV6:
	case	NEXTHDR_NONE:
	default:
		return XT_CONTINUE;	
> 
> > +hdr_rdy:
> > +...
> 
> 

Thanks
Hans
