From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 06/13] ipv6: Fix nexthdr for reinjection
Date: Thu, 12 May 2016 23:23:04 +0300
Message-ID: <20160512232304.437eb3bc@halley>
References: <1462985253-2380625-1-git-send-email-tom@herbertland.com>
	<1462985253-2380625-7-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35590 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbcELUXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 16:23:13 -0400
Received: by mail-wm0-f67.google.com with SMTP id e201so17909895wme.2
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 13:23:12 -0700 (PDT)
In-Reply-To: <1462985253-2380625-7-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Wed, 11 May 2016 09:47:26 -0700 Tom Herbert <tom@herbertland.com> wrote:
> In ip6_input_finish the protocol handle returns a value greater than
> zero the packet needs to be resubmitted using the returned protocol.
> The returned protocol is being ignored and each time through resubmit
> nexthdr is taken from an offest in the packet. This patch fixes that
> so that nexthdr is taken from return value of the protocol handler.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  net/ipv6/ip6_input.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> index 6ed5601..2a0258a 100644
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
> @@ -222,13 +222,14 @@ static int ip6_input_finish(struct net *net, struct sock *sk, struct sk_buff *sk
>  	 */
>  
>  	rcu_read_lock();
> -resubmit:
> +
>  	idev = ip6_dst_idev(skb_dst(skb));
>  	if (!pskb_pull(skb, skb_transport_offset(skb)))
>  		goto discard;
>  	nhoff = IP6CB(skb)->nhoff;
>  	nexthdr = skb_network_header(skb)[nhoff];
>  
> +resubmit:

This has already been attempted in 0243508edd "ipv6: Fix protocol
resubmission" and reverted in 1b0ccfe54a.

It looks that in some genuine extension header handling cases of ipv6
(not related to encapsulation), the original resubmission code REALLY
requires one to re-read IP6CB(skb)->nhoff and refetch the nexthdr.

See ipv6_rthdr_rcv and ipv6_destopt_rcv for example:

Snip from ipv6_rthdr_rcv:

	struct inet6_skb_parm *opt = IP6CB(skb);

		opt->lastopt = opt->srcrt = skb_network_header_len(skb);
		skb->transport_header += (hdr->hdrlen + 1) << 3;
		opt->dst0 = opt->dst1;
		opt->dst1 = 0;
		opt->nhoff = (&hdr->nexthdr) - skb_network_header(skb);
		return 1;

Snip from ipv6_destopt_rcv:

		opt = IP6CB(skb);
#if IS_ENABLED(CONFIG_IPV6_MIP6)
		opt->nhoff = dstbuf;
#else
		opt->nhoff = opt->dst1;
#endif
		return 1;

I think there are two "resubmission" cases:
 1. original ipv6 extension header handling, which seem to require
    nexthdr re-read (after IP6CB(skb)->nhoff re-assigned), as seen above
 2. encapsulation resubmission (e.g. fou)

One suggestion: we may identify the encapsulation case by returning the
negative of the proto number.

Another suggestion: we can take your approach, but execute the nexthdr
re-read within ipv6_rthdr_rcv and ipv6_destopt_rcv (and similar
inet6_protocol.handler functions).

Regards,
Shmulik
