From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: question: update_pmtu doesn't update dst mtu
Date: Tue, 8 Apr 2014 16:57:19 +0200
Message-ID: <20140408145718.GC27255@order.stressinduktion.org>
References: <533D47FD.9020904@securitycode.ru> <20140403115809.GA13354@order.stressinduktion.org> <533D4EF9.60608@securitycode.ru> <20140403121410.GC13354@order.stressinduktion.org> <533D5398.7080209@securitycode.ru> <5343BB6F.2090601@securitycode.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: "Ilya V. Matveychikov" <i.matveychikov@securitycode.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58303 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756859AbaDHO5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 10:57:20 -0400
Content-Disposition: inline
In-Reply-To: <5343BB6F.2090601@securitycode.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 08, 2014 at 01:03:43PM +0400, Ilya V. Matveychikov wrote:
> Just another related question that gets me into trouble. Imagine that there is
> an SKB that wants to be transmitted via that tunnel. Let's say that when it
> comes to the TUNNEL device it has an MTU1 value. Now, someone updates the PMTU
> for the route and mtu decreasing from MTU1 to MTU2, so MTU2 < MTU1.
> 
> Given that, I suppose that our SKB must be (re)fragmented with ip_fragment as
> it's size might be slightly bigger then the path can pass. The problem is that
> ip_fragment uses dst_mtu(skb_dst(skb)) to determine the fragment size but it
> still has MTU1 value as even update_pmtu(MTU2) was called as it doesn't leads to
> real dst MTU updating.
> 
> So the question is do I need to relookup the route or can I use the following
> hack before ip_fragment:
> 
> 	// dst_mtu(dst) shows MTU1
> 	dst->ops->update_pmtu(dst, ..., MTU2)
> 	...
> 	skb_rtable(skb)->rt_pmtu = MTU2;

This might be a cached dst and you would alter the mtu for more nexthops than
you intended.

> 	dst_set_expires(dst, 1);

With this you won't get around the time_after_eq check. You would have to
tweak it manually to not retrieve dst_metrics value (this is what you
intended?).

> 	...
> 	// now, ip_fragment knows about real MTU value
> 	ip_fragment(skb, output...)

Check if you can something do like
skb_dst_drop(skb);
new_dst = ip_route_output*(..., &fl4, ...);
skb_dst_set(_noref)(skb, new_dst);

This should be a very unlikely path, I assume, so should not degrade
performance that much.

I wonder why you update the mtu in the output path.

Bye,

  Hannes
