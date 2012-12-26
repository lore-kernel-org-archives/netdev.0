From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ndisc: Ensure to reserve header space for
 encapsulation.
Date: Wed, 26 Dec 2012 08:48:41 -0800
Message-ID: <1356540521.20133.20554.camel@edumazet-glaptop>
References: <50D9BAA4.7000207@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:63770 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753422Ab2LZQso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 11:48:44 -0500
Received: by mail-pa0-f44.google.com with SMTP id hz11so4999004pad.3
        for <netdev@vger.kernel.org>; Wed, 26 Dec 2012 08:48:44 -0800 (PST)
In-Reply-To: <50D9BAA4.7000207@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-25 at 23:39 +0900, YOSHIFUJI Hideaki wrote:
> We allocate sk_buff of MAX_HEADER + LL_RESERVED_SPACE(dev) + packet
> length + dev->needed_tailroom, but reserved LL_RESERVED_SPACE(dev)
> only.  This means that space for encapsulation was placed at the end
> of buffer.  This does not make sense.
> 
> Reserve the space correctly, like this:
> 
> head                       data                   tail       end
> +--------------------------------------------------------------+
> +                |           |                      |          |
> +--------------------------------------------------------------+
> |<--MAX_HEADER-->|<-hlen---->|<---ipv6 packet------>|<--tlen-->|
>                    =LL_
>                     RESERVED_
>                     SPACE(dev)
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  net/ipv6/ndisc.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 6574175..5f78ac2 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -404,7 +404,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
>  		return NULL;
>  	}
>  
> -	skb_reserve(skb, hlen);
> +	skb_reserve(skb, MAX_HEADER + hlen);
>  	ip6_nd_hdr(sk, skb, dev, saddr, daddr, IPPROTO_ICMPV6, len);
>  
>  	skb->transport_header = skb->tail;
> @@ -1449,7 +1449,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
>  		goto release;
>  	}
>  
> -	skb_reserve(buff, hlen);
> +	skb_reserve(buff, MAX_HEADER + hlen);
>  	ip6_nd_hdr(sk, buff, dev, &saddr_buf, &ipv6_hdr(skb)->saddr,
>  		   IPPROTO_ICMPV6, len);
>  

It looks like this MAX_HEADER reserve is not needed at all.

Space for encapsulation should already be in 
int hlen = LL_RESERVED_SPACE(dev);

arp_create() for example doesnt add this MAX_HEADER 

If extra encapsulation is needed (at head or at tail), it really should
be documented.
