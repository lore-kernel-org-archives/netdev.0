From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 5/6] ipv6: Call xfrm6_xlat_addr from ipv6_rcv
Date: Wed, 30 Sep 2015 11:06:17 +0200
Message-ID: <20150930090617.GF7701@secunet.com>
References: <1443565043-1287886-1-git-send-email-tom@herbertland.com>
 <1443565043-1287886-6-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44603 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752646AbbI3JG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 05:06:27 -0400
Content-Disposition: inline
In-Reply-To: <1443565043-1287886-6-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 29, 2015 at 03:17:22PM -0700, Tom Herbert wrote:
> Call before performing NF_HOOK and routing in order to perform address
> translation in the receive path.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  net/ipv6/ip6_input.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> index 9075acf..06dac55 100644
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
> @@ -183,6 +183,9 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
>  	/* Must drop socket now because of tproxy. */
>  	skb_orphan(skb);
>  
> +	/* Translate destination address before routing */
> +	xfrm6_xlat_addr(skb);
> +

This shows that xfrm is not the right place to add this. The existing
xfrm hooks are located at the same place as your current LWT hooks are.

You could use the existing xfrm hooks similar to xfrm tunnel modes.
This reinserts the transformed packet back into layer2, but I guess
this is not what you want.

I'm currently paying with a GRO codepath for IPsec to get the
packets transformed early. If you can do your address translation
that early, it could be an option too. This clearly depends on
enabled GRO at the receiving device, but you would still have
the LWT hook as a fallback.

>  	return NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING,
>  		       net, NULL, skb, dev, NULL,
>  		       ip6_rcv_finish);

Or, try to use the netfilter hook that seems to be at the right
place at least.
