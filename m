From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Problematic commits in the ipsec tree
Date: Thu, 22 Aug 2013 15:53:42 +0200
Message-ID: <20130822135342.GC30722@order.stressinduktion.org>
References: <20130822104724.GD26773@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39799 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251Ab3HVNxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 09:53:44 -0400
Content-Disposition: inline
In-Reply-To: <20130822104724.GD26773@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 22, 2013 at 12:47:24PM +0200, Steffen Klassert wrote:
> Hannes,
> 
> I have two problematic commits from you in the ipsec tree. The first one is:
> 
> commit 0ea9d5e3e (xfrm: introduce helper for safe determination of mtu)
> 
> This breakes pmtu discovery for IPv4 because now we use the device mtu
> instead of the reduced IPsec mtu in xfrm4_tunnel_check_size() if a IPv4
> socket is at the skb.

I am currently testing this following patch. It should restore old behavior
for ipv4 sockets.

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ac5b025..65d3529 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1730,8 +1730,6 @@ static inline int xfrm_skb_dst_mtu(struct sk_buff *skb)
 
 	if (sk && skb->protocol == htons(ETH_P_IPV6))
 		return ip6_skb_dst_mtu(skb);
-	else if (sk && skb->protocol == htons(ETH_P_IP))
-		return ip_skb_dst_mtu(skb);
 	return dst_mtu(skb_dst(skb));
 }
 
Actually I would like to extend this check so that we only take the
dst_mtu(dst->path) in case of IP_PMTUDISC_PROBE. But that would be a
patch for ipsec-next. I was not sure if we always dispatch to xfrm_mtu
in this code-path.

> 
> The second is:
> 
> commit 844d48746 (xfrm: choose protocol family by skb protocol)
> 
> This breaks pmtu discovery for IPv6 too because skb->protocol can be null
> in __xfrm6_output().

I am currently checking if there are side-effects if we set skb->protocol in
raw sockets. This should solve this problem. Btw. this is also the case for
IPv4.

Hope to have tested patches later today.

Thanks,

  Hannes
