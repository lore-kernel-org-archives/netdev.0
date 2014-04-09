From: "Ilya V. Matveychikov" <i.matveychikov@securitycode.ru>
Subject: Re: question: update_pmtu doesn't update dst mtu
Date: Wed, 9 Apr 2014 12:17:33 +0400
Message-ID: <5345021D.30505@securitycode.ru>
References: <533D47FD.9020904@securitycode.ru> <20140403115809.GA13354@order.stressinduktion.org> <533D4EF9.60608@securitycode.ru> <20140403121410.GC13354@order.stressinduktion.org> <533D5398.7080209@securitycode.ru> <5343BB6F.2090601@securitycode.ru> <20140408145718.GC27255@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from itna.infosec.ru ([82.198.190.199]:47125 "EHLO itna.infosec.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752839AbaDIIQv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2014 04:16:51 -0400
In-Reply-To: <20140408145718.GC27255@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.04.2014 18:57, Hannes Frederic Sowa wrote:
> On Tue, Apr 08, 2014 at 01:03:43PM +0400, Ilya V. Matveychikov wrote:
>> Just another related question that gets me into trouble. Imagine that there is
>> an SKB that wants to be transmitted via that tunnel. Let's say that when it
>> comes to the TUNNEL device it has an MTU1 value. Now, someone updates the PMTU
>> for the route and mtu decreasing from MTU1 to MTU2, so MTU2 < MTU1.
>>
>> Given that, I suppose that our SKB must be (re)fragmented with ip_fragment as
>> it's size might be slightly bigger then the path can pass. The problem is that
>> ip_fragment uses dst_mtu(skb_dst(skb)) to determine the fragment size but it
>> still has MTU1 value as even update_pmtu(MTU2) was called as it doesn't leads to
>> real dst MTU updating.
>>
>> So the question is do I need to relookup the route or can I use the following
>> hack before ip_fragment:
>>
>> 	// dst_mtu(dst) shows MTU1
>> 	dst->ops->update_pmtu(dst, ..., MTU2)
>> 	...
>> 	skb_rtable(skb)->rt_pmtu = MTU2;
> 
> This might be a cached dst and you would alter the mtu for more nexthops than
> you intended.
> 
>> 	dst_set_expires(dst, 1);
> 
> With this you won't get around the time_after_eq check. You would have to
> tweak it manually to not retrieve dst_metrics value (this is what you
> intended?).
> 

Well, I missed it. Also, that was a hack and it's not the best solution...

>> 	...
>> 	// now, ip_fragment knows about real MTU value
>> 	ip_fragment(skb, output...)
> 
> Check if you can something do like
> skb_dst_drop(skb);
> new_dst = ip_route_output*(..., &fl4, ...);
> skb_dst_set(_noref)(skb, new_dst);
> 

Works fine, thanks! By the way, could you briefly explain why routes are
separated to input and output? What are the benefits?

> This should be a very unlikely path, I assume, so should not degrade
> performance that much.

Sure.

> 
> I wonder why you update the mtu in the output path.

Well, the problem is that I don't know how to properly handle packets whose DSTs
have changed while processing. The simple solution is to drop them. But I think
it's not the best case as we can re-fragment them if new MTU value is lesser
than the older one.
