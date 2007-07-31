From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm beet interfamily support
Date: Tue, 31 Jul 2007 12:51:42 +0200
Message-ID: <46AF143E.9080709@trash.net>
References: <200707161506.47915.joakim.koskela@hiit.fi> <200707191708.58863.joakim.koskela@hiit.fi> <469F7952.207@trash.net> <200707311339.39913.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58597 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbXGaKwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 06:52:25 -0400
In-Reply-To: <200707311339.39913.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joakim Koskela wrote:
> On Thursday 19 July 2007 17:46:42 Patrick McHardy wrote:
> 
>>Joakim Koskela wrote:
>>
>>>+		skb_push(skb, hdrlen);
>>>+		iphv6 = ipv6_hdr(skb);
>>>+
>>>+		skb_reset_network_header(skb);
>>>+		top_iphv6 = ipv6_hdr(skb);
>>>+
>>>+		protocol = iphv6->nexthdr;
>>>+		skb_pull(skb, delta);
>>>+		skb_reset_network_header(skb);
>>>+		top_iphv4 = ip_hdr(skb);
>>>+		skb_set_transport_header(skb, hdrlen);
>>>+		top_iphv4->ihl = (sizeof(struct iphdr) >> 2);
>>>+		top_iphv4->version = 4;
>>>+		top_iphv4->id = 0;
>>>+		top_iphv4->frag_off = htons(IP_DF);
>>>+		top_iphv4->ttl = dst_metric(dst->child, RTAX_HOPLIMIT);
>>>+		top_iphv4->saddr = x->props.saddr.a4;
>>>+		top_iphv4->daddr = x->id.daddr.a4;
>>>+		skb->transport_header += top_iphv4->ihl*4;
>>>+		top_iphv4->protocol = protocol;
>>>+
>>>+		skb->protocol = htons(ETH_P_IP);
>>>+#endif
>>
>>The output function in the IPv6/IPv4 case is called from
>>xfrm6_output_one, which loops until after a tunnel mode
>>encapsulation is done and then returns to the outer loop
>>in xfrm6_output_finish2, which passes the packet through
>>the netfilter hooks and continues with the next transform.
>>
> 
> 
> I'm not sure I really got this. IPv6/IPv4 means IPv6 inner, IPv4 outer, right? 
> Isn't that called from xfrm4_output_one and subsequently passed through the 
> right filters as well (as it has a ipv4 header by then)?


I think you're right, it uses xfrm4_output. But there's a mismatch
in either case, in both cases (IPv4 and IPv6) we first call the
POSTROUTING hook for this family, than do the transform (changing
the family), then call the OUTPUT hook for the same family. So
either the POSTROUTING or the OUTPUT hook is called for the wrong
family.

>>There are multiple problems resulting from the inter-family
>>encapsulation. First of all, the inner loop continues after
>>beet mode encapsulation, skipping the netfilter hooks in
>>case there are more transforms. It should (as with decaps = 1
>>on input) at least call netfilter hooks after an inter-family
>>transform. If the beet transform is the last one, the IPv4
>>skb will be passed through the IPv6 netfilter hooks, which is
>>clearly wrong. To fix these problems some restructuring in
>>xfrm[46]_output.c seems to be necessary.
> 
> 
> Couldn't this be solved just by ending the inner loop in case of beet mode (as 
> it is done for tunnel)?


If the assumption that xfrm4_output is used for IPv6 in IPv4
encapsulation is correct and the problem mentioned above is
fixed, that should work fine.
