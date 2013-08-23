From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Problematic commits in the ipsec tree
Date: Fri, 23 Aug 2013 13:34:35 +0200
Message-ID: <20130823113435.GC808@order.stressinduktion.org>
References: <20130822104724.GD26773@secunet.com> <20130822135342.GC30722@order.stressinduktion.org> <20130823085807.GH26773@secunet.com> <20130823110323.GB808@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41975 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755349Ab3HWLeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 07:34:37 -0400
Content-Disposition: inline
In-Reply-To: <20130823110323.GB808@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 23, 2013 at 01:03:23PM +0200, Hannes Frederic Sowa wrote:
> Hello!
> 
> On Fri, Aug 23, 2013 at 10:58:07AM +0200, Steffen Klassert wrote:
> > On Thu, Aug 22, 2013 at 03:53:42PM +0200, Hannes Frederic Sowa wrote:
> > > On Thu, Aug 22, 2013 at 12:47:24PM +0200, Steffen Klassert wrote:
> > > > Hannes,
> > > > 
> > > > I have two problematic commits from you in the ipsec tree. The first one is:
> > > > 
> > > > commit 0ea9d5e3e (xfrm: introduce helper for safe determination of mtu)
> > > > 
> > > > This breakes pmtu discovery for IPv4 because now we use the device mtu
> > > > instead of the reduced IPsec mtu in xfrm4_tunnel_check_size() if a IPv4
> > > > socket is at the skb.
> > > 
> > > I am currently testing this following patch. It should restore old behavior
> > > for ipv4 sockets.
> > > 
> > > diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> > > index ac5b025..65d3529 100644
> > > --- a/include/net/xfrm.h
> > > +++ b/include/net/xfrm.h
> > > @@ -1730,8 +1730,6 @@ static inline int xfrm_skb_dst_mtu(struct sk_buff *skb)
> > >  
> > >  	if (sk && skb->protocol == htons(ETH_P_IPV6))
> > >  		return ip6_skb_dst_mtu(skb);
> > > -	else if (sk && skb->protocol == htons(ETH_P_IP))
> > > -		return ip_skb_dst_mtu(skb);
> > >  	return dst_mtu(skb_dst(skb));
> > >  }
> > 
> > This looks still fragile. xfrm_skb_dst_mtu() is called from
> > __xfrm6_output() and from xfrm4_tunnel_check_size().
> > We will have the same bug again as soon as somebody thinks that
> > it is save to call it from xfrm6_tunnel_check_size() too. So I
> > think it is better not to call it from xfrm4_tunnel_check_size().
> 
> Hm, I don't think I can follow you completly here. I searched for allocations
> of ipv6 skbs (where they originated from a socket) and checked these
> allocations also initialize the skb->protocol field (the second patch).
> 
> I wonder if ip6_skb_dst_mtu was correct all along and if we should just
> switch to dst_mtu(skb_dst(skb)) in all cases?

Ok, I got it.

How about just checking in __xfrm6_output if we actually have a packet
originated from an IPv6 socket so that we only replace the original call to
ip6_skb_dst_mtu(skb)?

> 
> > Also, why do we need xfrm_skb_dst_mtu() at all? When it is called
> > from __xfrm6_output(), we know that this is IPv6. So we can call
> > ip6_skb_dst_mtu() directly as it was before your change.
> 
> The problem was that ip6_skb_dst_mtu dereferences the ipv6_pinfo socket to
> check for IPV6_PMTUDISC_PROBE. If IPv4 is encapsulated in IPv6 and the packet
> originated from the same host (sk != NULL) we call down to ip6_skb_dst_mtu.
> This function checks that ipv6_pinfo is not NULL, so it worked by accident
> currently.
> 
> My plan would be to check that all IPv4 skb allocations use the correct
> skb->protocol, too, or if we can use the skb->inner_protocol field to mark
> packets in the tunnel drivers from which protocol they originated.

Btw. this also let's us refer to the wrong mtu in case of an v4-mapped v6
socket transmitting over a address family changing tunnel over ipsec.

Greetings,

  Hannes
