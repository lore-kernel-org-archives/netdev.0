From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip_route_input panic fix
Date: Tue, 18 Apr 2006 16:54:48 +1000
Message-ID: <E1FVk6q-0000Tf-00@gondolin.me.apana.org.au>
References: <20060417171253.4e988afc@localhost.localdomain>
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:8708 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932244AbWDRGyx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 02:54:53 -0400
To: shemminger@osdl.org (Stephen Hemminger)
In-Reply-To: <20060417171253.4e988afc@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> --- linux-2.6.16.6.orig/net/ipv4/route.c
> +++ linux-2.6.16.6/net/ipv4/route.c
> @@ -2750,7 +2750,10 @@ int inet_rtm_getroute(struct sk_buff *in
>        /* Reserve room for dummy headers, this skb can pass
>           through good chunk of routing engine.
>         */
> -       skb->mac.raw = skb->data;
> +       skb->mac.raw = skb->nh.raw = skb->data;
> +
> +       /* Bugfix: need to give ip_route_input enough of an IP header to not gag. */
> +       skb->nh.iph->protocol = IPPROTO_ICMP;

Looking at this again, the root of this problem is the IGMPv3
patch which started using the skb->nh.iph->protocol as a key.

So what we really should do is make the protocol an explicit parameter
to the ip_route_input function.  This will make it clear to all the
users which include some pretty weird cases that the protocol is needed.

In fact I'm unsure as to whether all the other users of ip_route_input
is safe as it is regarding the protocol.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
