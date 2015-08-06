From: Zang MingJie <zealot0630@gmail.com>
Subject: Re: [BUG] net/ipv4: inconsistent routing table
Date: Thu, 6 Aug 2015 18:13:01 +0800
Message-ID: <CAOrge3ps456Zw8nnnVitU3t6sEQ=Z=6QzO5Zsp4s17MhhZxyKQ@mail.gmail.com>
References: <CAOrge3qi=7YPRO+VeCDvHsm_7SFC4Y=+JpwQtwAV3zk_q4fEAw@mail.gmail.com>
 <55C1D207.3040905@iogearbox.net> <55C24BAE.7090702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55C24BAE.7090702@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 6, 2015 at 1:45 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On 08/05/2015 02:06 AM, Daniel Borkmann wrote:
>>
>> [ please cc netdev ]
>>
>> On 08/05/2015 10:56 AM, Zang MingJie wrote:
>>>
>>> Hi:
>>>
>>> I found a bug when remove an ip address which is referenced by a routing
>>> entry.
>>>
>>> step to reproduce:
>>>
>>> ip li add type dummy
>>> ip li set dummy0 up
>>> ip ad add 10.0.0.1/24 dev dummy0
>>> ip ad add 10.0.0.2/24 dev dummy0
>
>
> Okay, so up to this point you have 2 addresses on the same subnet that are
> now on dummy0.
>
>>> ip ro add default via 10.0.0.2/24
>
>
> This makes the default route go through 10.0.0.2.
>
>>> ip ad del 10.0.0.2/24 dev dummy0
>
>
> Then you remove 10.0.0.2 from the local system, however since 10.0.0.1 is on
> the same subnet dummy0 would still be the correct interface to access
> 10.0.0.2 it is just no longer local to the system.
>
>>> after deleting the secondary ip address, the routing entry still
>>> pointing to 10.0.0.2
>
>
> You didn't delete the default routing entry so why would you expect it to
> change?  All you did is remove 10.0.0.2 from the local system.  I believe
> the assumption is that 10.0.0.2 is still out there somewhere, it just isn't
> on the local system anymore.

Yes, 10.0.0.2 is migrated to somewhere else

>
>>> # ip ro
>>> default via 10.0.0.2 dev dummy0
>>> 10.0.0.0/24 dev dummy0  proto kernel  scope link  src 10.0.0.1
>
>
> This matches up with what I would expect.  10.0.0.2 is the default gateway
> and it is accessible from dummy0 since 10.0.0.0/24 is accessible from
> dummy0.

This means 0.0.0.0/0 is accessible via 10.0.0.2 on the network of dummy0

>
>>> but actually, kernel considers the default route is directly connected.
>>>
>>> # ip ro get 1.1.1.1
>>> 1.1.1.1 dev dummy0  src 10.0.0.1
>>>      cache
>
>
> I'm not sure how you came to the "directly connected" conclusion. It is
> still routing things out through 10.0.0.2 from 10.0.0.1.
>
> Maybe your example would work better if you used 10.0.0.1 and 10.0.1.1
> instead.  Then I think you might be able to better see that when you delete
> the second address the route would be broken.

No, it isn't. when ping 1.1.1.1, kernel will directly send arp request
braodcast to 1.1.1.1, this is not what I expect. it should send arp
request to 10.0.0.2, following should be the correct routing entry:

# ip ro get 1.1.1.1
1.1.1.1 via 10.0.0.2 dev dummy0  src 10.0.0.1
    cache


>
> - Alex
