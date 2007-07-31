From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm beet interfamily support
Date: Tue, 31 Jul 2007 13:39:39 +0300
Message-ID: <200707311339.39913.joakim.koskela@hiit.fi>
References: <200707161506.47915.joakim.koskela@hiit.fi> <200707191708.58863.joakim.koskela@hiit.fi> <469F7952.207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:53259 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750873AbXGaKik (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 06:38:40 -0400
In-Reply-To: <469F7952.207@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 19 July 2007 17:46:42 Patrick McHardy wrote:
> Joakim Koskela wrote:
> > +		skb_push(skb, hdrlen);
> > +		iphv6 = ipv6_hdr(skb);
> > +
> > +		skb_reset_network_header(skb);
> > +		top_iphv6 = ipv6_hdr(skb);
> > +
> > +		protocol = iphv6->nexthdr;
> > +		skb_pull(skb, delta);
> > +		skb_reset_network_header(skb);
> > +		top_iphv4 = ip_hdr(skb);
> > +		skb_set_transport_header(skb, hdrlen);
> > +		top_iphv4->ihl = (sizeof(struct iphdr) >> 2);
> > +		top_iphv4->version = 4;
> > +		top_iphv4->id = 0;
> > +		top_iphv4->frag_off = htons(IP_DF);
> > +		top_iphv4->ttl = dst_metric(dst->child, RTAX_HOPLIMIT);
> > +		top_iphv4->saddr = x->props.saddr.a4;
> > +		top_iphv4->daddr = x->id.daddr.a4;
> > +		skb->transport_header += top_iphv4->ihl*4;
> > +		top_iphv4->protocol = protocol;
> > +
> > +		skb->protocol = htons(ETH_P_IP);
> > +#endif
>
> The output function in the IPv6/IPv4 case is called from
> xfrm6_output_one, which loops until after a tunnel mode
> encapsulation is done and then returns to the outer loop
> in xfrm6_output_finish2, which passes the packet through
> the netfilter hooks and continues with the next transform.
>

I'm not sure I really got this. IPv6/IPv4 means IPv6 inner, IPv4 outer, right? 
Isn't that called from xfrm4_output_one and subsequently passed through the 
right filters as well (as it has a ipv4 header by then)?

> There are multiple problems resulting from the inter-family
> encapsulation. First of all, the inner loop continues after
> beet mode encapsulation, skipping the netfilter hooks in
> case there are more transforms. It should (as with decaps = 1
> on input) at least call netfilter hooks after an inter-family
> transform. If the beet transform is the last one, the IPv4
> skb will be passed through the IPv6 netfilter hooks, which is
> clearly wrong. To fix these problems some restructuring in
> xfrm[46]_output.c seems to be necessary.

Couldn't this be solved just by ending the inner loop in case of beet mode (as 
it is done for tunnel)?

br, j

