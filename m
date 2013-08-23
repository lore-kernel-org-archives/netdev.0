From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Problematic commits in the ipsec tree
Date: Fri, 23 Aug 2013 10:58:07 +0200
Message-ID: <20130823085807.GH26773@secunet.com>
References: <20130822104724.GD26773@secunet.com>
 <20130822135342.GC30722@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58875 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754947Ab3HWI6K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 04:58:10 -0400
Content-Disposition: inline
In-Reply-To: <20130822135342.GC30722@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 22, 2013 at 03:53:42PM +0200, Hannes Frederic Sowa wrote:
> On Thu, Aug 22, 2013 at 12:47:24PM +0200, Steffen Klassert wrote:
> > Hannes,
> > 
> > I have two problematic commits from you in the ipsec tree. The first one is:
> > 
> > commit 0ea9d5e3e (xfrm: introduce helper for safe determination of mtu)
> > 
> > This breakes pmtu discovery for IPv4 because now we use the device mtu
> > instead of the reduced IPsec mtu in xfrm4_tunnel_check_size() if a IPv4
> > socket is at the skb.
> 
> I am currently testing this following patch. It should restore old behavior
> for ipv4 sockets.
> 
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index ac5b025..65d3529 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -1730,8 +1730,6 @@ static inline int xfrm_skb_dst_mtu(struct sk_buff *skb)
>  
>  	if (sk && skb->protocol == htons(ETH_P_IPV6))
>  		return ip6_skb_dst_mtu(skb);
> -	else if (sk && skb->protocol == htons(ETH_P_IP))
> -		return ip_skb_dst_mtu(skb);
>  	return dst_mtu(skb_dst(skb));
>  }

This looks still fragile. xfrm_skb_dst_mtu() is called from
__xfrm6_output() and from xfrm4_tunnel_check_size().
We will have the same bug again as soon as somebody thinks that
it is save to call it from xfrm6_tunnel_check_size() too. So I
think it is better not to call it from xfrm4_tunnel_check_size().

Also, why do we need xfrm_skb_dst_mtu() at all? When it is called
from __xfrm6_output(), we know that this is IPv6. So we can call
ip6_skb_dst_mtu() directly as it was before your change.
