From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [BUG] net/ipv4: inconsistent routing table
Date: Thu, 06 Aug 2015 12:43:04 -0700
Message-ID: <55C3B8C8.9030507@redhat.com>
References: <CAOrge3qi=7YPRO+VeCDvHsm_7SFC4Y=+JpwQtwAV3zk_q4fEAw@mail.gmail.com> <55C1D207.3040905@iogearbox.net> <55C24BAE.7090702@gmail.com> <CAOrge3ps456Zw8nnnVitU3t6sEQ=Z=6QzO5Zsp4s17MhhZxyKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>
To: Zang MingJie <zealot0630@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOrge3ps456Zw8nnnVitU3t6sEQ=Z=6QzO5Zsp4s17MhhZxyKQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2015 03:13 AM, Zang MingJie wrote:
> On Thu, Aug 6, 2015 at 1:45 AM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On 08/05/2015 02:06 AM, Daniel Borkmann wrote:
>>>
>>> [ please cc netdev ]
>>>
>>> On 08/05/2015 10:56 AM, Zang MingJie wrote:
>>>>
>>>> Hi:
>>>>
>>>> I found a bug when remove an ip address which is referenced by a routing
>>>> entry.
>>>>
>>>> step to reproduce:
>>>>
>>>> ip li add type dummy
>>>> ip li set dummy0 up
>>>> ip ad add 10.0.0.1/24 dev dummy0
>>>> ip ad add 10.0.0.2/24 dev dummy0
>>
>>
>> Okay, so up to this point you have 2 addresses on the same subnet that are
>> now on dummy0.
>>
>>>> ip ro add default via 10.0.0.2/24
>>
>>
>> This makes the default route go through 10.0.0.2.
>>
>>>> ip ad del 10.0.0.2/24 dev dummy0
>>
>>
>> Then you remove 10.0.0.2 from the local system, however since 10.0.0.1 is on
>> the same subnet dummy0 would still be the correct interface to access
>> 10.0.0.2 it is just no longer local to the system.
>>
>>>> after deleting the secondary ip address, the routing entry still
>>>> pointing to 10.0.0.2
>>
>>
>> You didn't delete the default routing entry so why would you expect it to
>> change?  All you did is remove 10.0.0.2 from the local system.  I believe
>> the assumption is that 10.0.0.2 is still out there somewhere, it just isn't
>> on the local system anymore.
>
> Yes, 10.0.0.2 is migrated to somewhere else

The address might have migrated, but the interface is still up and 
10.0.0.1 is still present on the same subnet.  Because you made a local 
address the default gateway the assumption is any routes not 
specifically called out on other interfaces are directly accessible to 
this interface.

The bug indicates that the kernel is doing something to make the table 
inconsistent, but a default route that is a local interface address does 
essentially the same thing.

>>
>>>> # ip ro
>>>> default via 10.0.0.2 dev dummy0
>>>> 10.0.0.0/24 dev dummy0  proto kernel  scope link  src 10.0.0.1
>>
>>
>> This matches up with what I would expect.  10.0.0.2 is the default gateway
>> and it is accessible from dummy0 since 10.0.0.0/24 is accessible from
>> dummy0.
>
> This means 0.0.0.0/0 is accessible via 10.0.0.2 on the network of dummy0

Yes, but at the time you specified it 10.0.0.2 was a local address which 
belonged to dummy0.  This means that dummy0 can access anything not 
specified elsewhere via pretty much any address it wants.  So it is 
perfectly valid if it wants to use a source address of 10.0.0.1 to send 
packets to 1.1.1.1 over dummy0.

>>
>>>> but actually, kernel considers the default route is directly connected.
>>>>
>>>> # ip ro get 1.1.1.1
>>>> 1.1.1.1 dev dummy0  src 10.0.0.1
>>>>       cache
>>
>>
>> I'm not sure how you came to the "directly connected" conclusion. It is
>> still routing things out through 10.0.0.2 from 10.0.0.1.
>>
>> Maybe your example would work better if you used 10.0.0.1 and 10.0.1.1
>> instead.  Then I think you might be able to better see that when you delete
>> the second address the route would be broken.
>
> No, it isn't. when ping 1.1.1.1, kernel will directly send arp request
> braodcast to 1.1.1.1, this is not what I expect. it should send arp
> request to 10.0.0.2, following should be the correct routing entry:
>
> # ip ro get 1.1.1.1
> 1.1.1.1 via 10.0.0.2 dev dummy0  src 10.0.0.1
>      cache

I see what you are trying to say, but the example provided is a bit 
lacking.  Assuming you could ping 1.1.1.1 via dummy0 before with 
10.0.0.2 as your default gateway, that shouldn't change if 10.0.0.2 is 
migrated to another address.  That is, unless there is an issue on the 
system 10.0.0.2 was migrated to.

Now if I move away from using dummy interface and instead using a real 
network interface things can get a bit more interesting.  So if we 
follow your example and use 2 different subnets on the two systems then 
pings continue to work after we remove the addresses.  However if we 
flip things a bit and add the default route, and then the local address 
for the gateway they don't.  So something like below:
	ip li set eth0 up
	ip ad add 10.0.0.1/24 dev eth0
	ip ro add default via 10.0.0.2
	ip ad add 10.0.0.2/24 dev eth0

What you end up with is eth0 sending arp requests looking for 10.0.0.2 
even though it is a local address on the system.

My question would be what is the correct behavior for this?  If a local 
address is removed or added that is being used as a gateway address 
should we delete the route, or update the scope of the next hop?

- Alex
