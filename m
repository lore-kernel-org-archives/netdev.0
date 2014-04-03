From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: question: update_pmtu doesn't update dst mtu
Date: Thu, 3 Apr 2014 13:58:09 +0200
Message-ID: <20140403115809.GA13354@order.stressinduktion.org>
References: <533D47FD.9020904@securitycode.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: "Ilya V. Matveychikov" <i.matveychikov@securitycode.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48670 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbaDCL6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 07:58:11 -0400
Content-Disposition: inline
In-Reply-To: <533D47FD.9020904@securitycode.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 03, 2014 at 03:37:33PM +0400, Ilya V. Matveychikov wrote:
> Hello,
> 
> Is this a place where I can post questions not the patches? If so, can anybody
> explain me what the problem I have when trying to update dst PMTU value.
> 
> So, the scheme is the following:
> 
>                   skb->dst                   rt(pmtu)
> IN_DEV (MTU 1500) -------> TUNNEL (MTU 1440) -------> OUT_DEV (MTU 1500)
> 
> I have a simple tunnel_xmit function that handles all the packets that goes
> trough the tunnel. So, I have an skb with valid skb->dst value (filled earlier
> in ip_input_route_noref).
> 
> Next, when encapsulation is done, I needed to get an output route for the packet
> (rt at the scheme). At this point I know that the output route may have a PMTU
> value that is different from the OUT_DEV->mtu. So, I'm trying to update the
> input skb->dst route's PMTU with the update_pmtu function. It seems that all is
> OK, but when I trying to get the dst mtu value (using dst_mtu(skb_dst(skb))) I
> always get the value of 1440 (TUNNEL's MTU):
> 
> tunnel_xmit:
>     ...
>     pmtu = dst_mtu(&rt->dst) - OVERHEAD; // pmtu = 1300, for example
>     skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, pmtu);
>     // dst_mtu(skb_dst(skb)) still returns 1440
> 
> Looking through the code gives me that rt_pmtu is always 0 for the skb->dst
> entry and ipv4_mtu that called via the dst->ops->mtu() uses dev->mtu :(

At this point you have to drop skb_dst and have to relookup the route. During
that a new dst will be created which gets the mtu value from the next hop
exception, which got created by update_pmtu.

Normally routes are checked with dst_check if they are still valid
and a relookup should happen. In your example just do the relookup
unconditionally.

Greetings,

  Hannes
