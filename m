From: "Ilya V. Matveychikov" <i.matveychikov@securitycode.ru>
Subject: Re: question: update_pmtu doesn't update dst mtu
Date: Tue, 8 Apr 2014 13:03:43 +0400
Message-ID: <5343BB6F.2090601@securitycode.ru>
References: <533D47FD.9020904@securitycode.ru> <20140403115809.GA13354@order.stressinduktion.org> <533D4EF9.60608@securitycode.ru> <20140403121410.GC13354@order.stressinduktion.org> <533D5398.7080209@securitycode.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from itna.infosec.ru ([82.198.190.199]:51758 "EHLO itna.infosec.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755935AbaDHJDG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2014 05:03:06 -0400
In-Reply-To: <533D5398.7080209@securitycode.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03.04.2014 16:27, Ilya V. Matveychikov wrote:
> On 03.04.2014 16:14, Hannes Frederic Sowa wrote:
>> On Thu, Apr 03, 2014 at 04:07:21PM +0400, Ilya V. Matveychikov wrote:
>>> On 03.04.2014 15:58, Hannes Frederic Sowa wrote:
>>>> On Thu, Apr 03, 2014 at 03:37:33PM +0400, Ilya V. Matveychikov wrote:
>>>>> Looking through the code gives me that rt_pmtu is always 0 for the skb->dst
>>>>> entry and ipv4_mtu that called via the dst->ops->mtu() uses dev->mtu :(
>>>>
>>>> At this point you have to drop skb_dst and have to relookup the route. During
>>>> that a new dst will be created which gets the mtu value from the next hop
>>>> exception, which got created by update_pmtu.
>>>>
>>>> Normally routes are checked with dst_check if they are still valid
>>>> and a relookup should happen. In your example just do the relookup
>>>> unconditionally.
>>>>
>>>
>>> Does it mean that the next packet must have an updated route without any
>>> problems? I meant that if the first packet xmitting leads to updating the route
>>> PMTU via the exception creating (or updating) so the next packets must have an
>>> updated route? Am I right?
>>
>> In case the next packet causes a lookup in the routing table, yes. Or
>> if it does cache the routing lookup in some structure and checks the
>> route with dst_check and conditionally does a relookup (which kernel
>> implementation should already do) then you should also get the updated
>> mtu value.
>>
> 
> OK, seems that I understand the logic. Thanks a lot.

Just another related question that gets me into trouble. Imagine that there is
an SKB that wants to be transmitted via that tunnel. Let's say that when it
comes to the TUNNEL device it has an MTU1 value. Now, someone updates the PMTU
for the route and mtu decreasing from MTU1 to MTU2, so MTU2 < MTU1.

Given that, I suppose that our SKB must be (re)fragmented with ip_fragment as
it's size might be slightly bigger then the path can pass. The problem is that
ip_fragment uses dst_mtu(skb_dst(skb)) to determine the fragment size but it
still has MTU1 value as even update_pmtu(MTU2) was called as it doesn't leads to
real dst MTU updating.

So the question is do I need to relookup the route or can I use the following
hack before ip_fragment:

	// dst_mtu(dst) shows MTU1
	dst->ops->update_pmtu(dst, ..., MTU2)
	...
	skb_rtable(skb)->rt_pmtu = MTU2;
	dst_set_expires(dst, 1);
	...
	// now, ip_fragment knows about real MTU value
	ip_fragment(skb, output...)
