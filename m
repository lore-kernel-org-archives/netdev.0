From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [BUG] net/ipv4: inconsistent routing table
Date: Fri, 07 Aug 2015 19:00:24 +0200
Message-ID: <878u9njaon.fsf@stressinduktion.org>
References: <CAOrge3qi=7YPRO+VeCDvHsm_7SFC4Y=+JpwQtwAV3zk_q4fEAw@mail.gmail.com> <55C1D207.3040905@iogearbox.net> <55C24BAE.7090702@gmail.com> <CAOrge3ps456Zw8nnnVitU3t6sEQ=Z=6QzO5Zsp4s17MhhZxyKQ@mail.gmail.com> <55C3B8C8.9030507@redhat.com> <CAOrge3oRWUfdMjDgH8PSY_5Y8=KKv2Cr9T3ZLXvuNx6_eq7g0Q@mail.gmail.com> <55C4D803.3090108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Zang MingJie <zealot0630@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55C4D803.3090108@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Alexander Duyck <alexander.h.duyck@redhat.com> writes:
> On 08/07/2015 01:23 AM, Zang MingJie wrote:
>> IMO, the routing decision is determined, given a specific routing
>> table and local network the result MUST be determined, independence of
>> how/what order the routing entry is added.
>>
>> Now there are two ways to configure the system resulting EXACTLY the
>> same routing table and local addresses, but the routing decision is
>> totally different.
>>
>> SAME routing table, DIFFERENT routing decision, there MUST be bugs in kernel
>
> I wasn't arguing that the behavior is undesirable, but the likelihood of 
> having a default route assigned to a local address should be pretty 
> low.  If the system is the default route of others then it should have a 
> different default gateway than itself.  For example an office router 
> would end up pointing to the ISP as the gateway, and the ISP would 
> either point to some other provider or run a BGP configuration.  So in 
> the case of the default route transitioning to us we should end up 
> having to delete and update the default route anyway.  This is likely 
> one of the reasons why there hasn't been any issues reported with this 
> behavior until now.
>
> I'm just wondering if the work involved to fix it is going to be worth 
> it.  We have to keep in mind that this will result in a change of 
> behavior for existing users and we don't know if anyone might be 
> expecting this type of behavior.
>
> We basically are looking at one of three options.  The first one is to 
> just delete the route if you add the gateway as a local address or 
> remove it.  That would be consistent with what you might see if the 
> address was the sole address on an interface of its own.  The second 
> option is to update the nh_scope which I believe should be transitioned 
> between RT_SCOPE_HOST to RT_SCOPE_LINK if I am understanding things 
> correctly.  The third option is we don't change the behavior and just 
> document it.  This would then require manually deleting and restoring 
> any routes that use a recently modified address as their gateway.
>
> Based on your feedback I'm assuming you would probably prefer the second 
> option.  I'm just waiting to see if there are any other opinions on the 
> matter before I act.

The semantics behind this are not easy and the result might well break
other people's system. I would leave the current resolution logic as-is
and merely change the way iproute presents those information.

Currently we resolve the nexthop during route setup time and install the
resulting information into the FIB. This is very common on other OS, too.

In case we would reevaluate the nexthop part of a route during local
address changes on one of the interfaces, we could get the system very
well in a situation where it would have to remove its default route
because the network would not be reachable via ip subnetting any more,
but neighboring information would still keep the machine connected. And
this could happen with setups where someone did not configure their
routes to their own addresses, which are much more widespread.

The change wouldn't be in contradiction with weak end system behavior,
but I very much don't want to make other people's machines unreachable
because of such a change.

If we could rewind time, we could make local nexthops -EINVAL.

Bye,
Hannes
