From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [patch net] ipv6: do not create neighbor entries for local delivery
Date: Thu, 08 Aug 2013 17:45:21 -0300
Message-ID: <52040361.5020200@redhat.com>
References: <20130130082608.GA1604@minipsycho.orion> <CAATkVEzJgb+J-TAkTZCUbxLPj=b=wbOmsKbgNNimEfNaC8d0Aw@mail.gmail.com> <20130808194702.GH14001@order.stressinduktion.org> <20130808201627.GI14001@order.stressinduktion.org>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Debabrata Banerjee <dbavatar@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Banerjee, Debabrata" <dbanerje@akamai.com>,
	Joshua Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966477Ab3HHUqE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 16:46:04 -0400
In-Reply-To: <20130808201627.GI14001@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 08-08-2013 17:16, Hannes Frederic Sowa escreveu:
> On Thu, Aug 08, 2013 at 09:47:02PM +0200, Hannes Frederic Sowa wrote:
>> On Thu, Aug 08, 2013 at 02:45:40PM -0400, Debabrata Banerjee wrote:
>>> On Wed, Jan 30, 2013 at 3:26 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> From: Marcelo Ricardo Leitner <mleitner@redhat.com>
>>>>
>>>> They will be created at output, if ever needed. This avoids creating
>>>> empty neighbor entries when TPROXYing/Forwarding packets for addresses
>>>> that are not even directly reachable.
>>>>
>>>> Note that IPv4 already handles it this way. No neighbor entries are
>>>> created for local input.
>>>>
>>>> Tested by myself and customer.
>>>>
>>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>>> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
>>>> ---
>>>>   net/ipv6/route.c | 2 +-
>>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>>>> index e229a3b..363d8b7 100644
>>>> --- a/net/ipv6/route.c
>>>> +++ b/net/ipv6/route.c
>>>> @@ -928,7 +928,7 @@ restart:
>>>>          dst_hold(&rt->dst);
>>>>          read_unlock_bh(&table->tb6_lock);
>>>>
>>>> -       if (!rt->n && !(rt->rt6i_flags & RTF_NONEXTHOP))
>>>> +       if (!rt->n && !(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_LOCAL)))
>>>>                  nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
>>>>          else if (!(rt->dst.flags & DST_HOST))
>>>>                  nrt = rt6_alloc_clone(rt, &fl6->daddr);
>>>
>>>
>>>
>>> I'm not sure this patch is doing the right thing. It seems to break
>>> IPv6 loopback functionality, it is no longer equivalent to IPv4, as
>>> stated above. It doesn't just stop neighbor creation but it stops
>>> cached route creation. Seems like a scary change for a stable tree.
>>> See below:
>>>
>>> $ ip -4 route show local
>>> local 127.0.0.0/8 dev lo  proto kernel  scope host  src 127.0.0.1
>>>
>>> This local route enables us to use the whole loopback network, any
>>> address inside 127.0.0.0/8 will work.
>>>
>>> $ ping -c1 127.0.0.9
>>> PING 127.0.0.9 (127.0.0.9) 56(84) bytes of data.
>>> 64 bytes from 127.0.0.9: icmp_seq=1 ttl=64 time=0.012 ms
>>>
>>> --- 127.0.0.9 ping statistics ---
>>> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
>>> rtt min/avg/max/mdev = 0.012/0.012/0.012/0.000 ms
>>>
>>> This also used to work equivalently for IPv6 local loopback routes:
>>>
>>> $ ip -6 route add local 2001:::/64 dev lo
>>> $ ping6 -c1 2001::9
>>> PING 2001::9(2001::9) 56 data bytes
>>> 64 bytes from 2001::9: icmp_seq=1 ttl=64 time=0.010 ms
>>>
>>> --- 2001::9 ping statistics ---
>>> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
>>> rtt min/avg/max/mdev = 0.010/0.010/0.010/0.000 ms
>>>
>>> However with this patch, this is very broken:
>>>
>>> $ ip -6 route add local 2001::/64 dev lo
>>> $ ping6 -c1 2001::9
>>> PING 2001::9(2001::9) 56 data bytes
>>> ping: sendmsg: Invalid argument
>>
>> I do think that the patch above is fine. I wonder why you get a blackhole
>> route back here. Maybe backtracking in ip6_pol_route or in fib6_lookup_1 was
>> way too aggressive?
>
> Ah sorry, before rt->n removal everything worked a bit
> different. rt6_alloc_cow did fill rt->n back then. To fix both things
> we would have to bind a neighbour towards the loopback interface into
> the non-cloned rt6_info if it feeds packets towards lo. Pretty big change for
> old stable kernels, I guess. :/
>
> Marcelo, any idea how to deal with this? My guess would be a revert, but I
> don't know the impact on the tproxy issue.

Good question :) Nothing so far, sorry.

The impact would be returning to the previous state, that a tproxy server is 
limited to neighbor cache size. And just making it larger is not a good option 
as it will introduce big latency spikes during cleanup.

I'll have to rebuild the tproxy environment I had to test this out again, it 
will take a while. Keep you posted.

Cheers,
Marcelo
