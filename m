From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v2 PATCH 1/2] NETFILTER module xt_hmark new target for HASH
 based fw
Date: Tue, 8 Nov 2011 11:51:10 +0100
Message-ID: <20111108105110.GA15798@1984>
References: <0hivdsb.f18682ec9367f08c76301d993553f1b8@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, kaber@trash.net,
	jengelh@medozas.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56699 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750892Ab1KHKvS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Nov 2011 05:51:18 -0500
Content-Disposition: inline
In-Reply-To: <0hivdsb.f18682ec9367f08c76301d993553f1b8@obelix.schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 08, 2011 at 12:29:53AM +0100, Hans Schillstrom wrote:
> >We prefer skb_header_pointer instead. If conntrack is enabled, we can
> >benefit from defragmention. 
> 
> In  our case conntrack will not be there

Yes, but if conntrack is there, we benefit from fragment reassembly if
you use skb_header_pointer.

> >Please, replace all pskb_may_pull by skb_header_pointer in this code.
> >
> >We can assume that the IP header is linear (not fragmented).
> 
> I ran in to this issue in IPv6 testing so I got a little bit "paranoid".
> Are you sure that the embedded IP and L4 header in the ICMP msg also is unfragmented.  
> Is this true for both IPv6 & IPv4 ?

No sorry. I was refering to normal IP header in one packet.

> From what I remember  when I was testing IPv6  icmp and digged into the original header (on a 2.6.32 kernel)  
> pskb_may_pull was needed.

Yes, it is indeed needed.

> [snip]
> 
> >> +/*
> >> + * Calc hash value, special casre is taken on icmp and fragmented messages
> >> + * i.e. fragmented messages don't use ports.
> >> + */
> >> +static __u32 get_hash(struct sk_buff *skb, struct xt_hmark_info *info)
> >
> >This function seems to big to me, please, split it into smaller
> >chunks, like get_hash_ipv4, get_hash_ipv6 and get_hash_ports.
> >
> 
> Good catch I'll do that,
> 
> >> +{
> >> +	int nhoff, hash = 0, poff, proto, frag = 0;
> >> +	struct iphdr *ip;
> >> +	u8 ip_proto;
> >> +	u32 addr1, addr2, ihl;
> >> +	u16 snatport = 0, dnatport = 0;
> >> +	union {
> >> +		u32 v32;
> >> +		u16 v16[2];
> >> +	} ports;
> >> +
> >> +	nhoff = skb_network_offset(skb);
> >> +	proto = skb->protocol;
> >> +
> >> +	if (!proto && skb->sk) {
> >> +		if (skb->sk->sk_family == AF_INET)
> >> +			proto = __constant_htons(ETH_P_IP);
> >> +		else if (skb->sk->sk_family == AF_INET6)
> >> +			proto = __constant_htons(ETH_P_IPV6);
> >
> >You already have the layer3 protocol number in xt_action_param. No
> >need to use the socket information then.
> 
> When splitting get_hash()  above  will  be removed,  xt_action_param ->family will be used for selection.
> 
> [snip]
> >> +
> >> +		if (!ct || !nf_ct_is_confirmed(ct))
> >
> >You seem to (ab)use nf_ct_is_confirmed to make sure you're not in the
> >original direction. Better use the direction that you get by means of
> >nf_ct_get.
> >
> I'm not sure I follow you here ?

OK, why are you using nf_ct_is_confirmed here? :-)

> >> +			break;
> >> +		otuple = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
> >> +		/* On the "return flow", to get the original address
> >> +		 * i,e, replace the source address.
> >> +		 */
> >> +		if (ct->status & IPS_DST_NAT &&
> >> +		    info->flags & XT_HMARK_USE_DNAT) {
> >> +			rtuple = &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
> >> +			addr1 = (__force u32) otuple->dst.u3.in.s_addr;
> >> +			dnatport = otuple->dst.u.udp.port;
> >> +		}
> >> +		/* On the "return flow", to get the original address
> >> +		 * i,e, replace the destination address.
> >> +		 */
> >> +		if (ct->status & IPS_SRC_NAT &&
> >> +		    info->flags & XT_HMARK_USE_SNAT) {
> >> +			rtuple = &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
> >> +			addr2 = (__force u32) otuple->src.u3.in.s_addr;
> >> +			snatport = otuple->src.u.udp.port;
> >> +		}
> >> +		break;
> >> +	}
> 
> [snip]
> 
> >> +			case NEXTHDR_NONE:
> >> +				nhoff += hdrlen;
> >> +				goto hdr_rdy;
> >> +			default:
> >> +				goto done;
> >
> >This goto doesn't make too much sense to me, better return 0.
> 
> hmmm 
> kind of left overs,  Actually all "goto done" can be replaced by return 0

no problem, just comestic change ;-)

> [snip]
> 
> >> +done:
> >> +	return 0;
> >> +}
> >
> >I'll try to find more time to look into this. Specifically, I want to
> >review the IPv6 bits more carefully.
> 
> The IPv6 header recursion is not obvious, and it's hard to test all cases :-)
> 
> I really appreciate you review

Welcome, let's see if we can get this into 3.3 since we cannot make it
for 3.2.

BTW, do you have some number of this running with and without
conntrack? It would be interesting to have.
