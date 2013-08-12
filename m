From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [patch net] ipv6: do not create neighbor entries for local delivery
Date: Mon, 12 Aug 2013 15:09:19 -0300
Message-ID: <520924CF.6000805@redhat.com>
References: <20130130082608.GA1604@minipsycho.orion> <CAATkVEzJgb+J-TAkTZCUbxLPj=b=wbOmsKbgNNimEfNaC8d0Aw@mail.gmail.com> <20130808194702.GH14001@order.stressinduktion.org> <20130808201627.GI14001@order.stressinduktion.org>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000903070702050505010509"
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
Received: from mx1.redhat.com ([209.132.183.28]:11847 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750883Ab3HLSKS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Aug 2013 14:10:18 -0400
In-Reply-To: <20130808201627.GI14001@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000903070702050505010509
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

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

Hannes, would something like this be acceptable? I'm hoping it's not too 
ugly/hacky... as far as I could track back, input and output routines were 
merged mainly due code similarity.

TPROXY scenario needs to not create this neighbor entries on INPUT path, while 
Debabrata ping test needs it on OUTPUT path. This patch limits my previous 
patch to INPUT only then.

Initial testing here seems good, TPROXY seems to be working as expected and 
also the ping6 test.

What do you think?

Regards,
Marcelo


--------------000903070702050505010509
Content-Type: text/x-patch;
 name="ipv6-rt.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ipv6-rt.patch"

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 18ea73c..603f9d9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -791,7 +791,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort,
 }
 
 static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table, int oif,
-				      struct flowi6 *fl6, int flags)
+				      struct flowi6 *fl6, int flags, int output)
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt, *nrt;
@@ -799,8 +799,11 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 	int attempts = 3;
 	int err;
 	int reachable = net->ipv6.devconf_all->forwarding ? 0 : RT6_LOOKUP_F_REACHABLE;
+	int local = RTF_NONEXTHOP;
 
 	strict |= flags & RT6_LOOKUP_F_IFACE;
+	if (!output)
+			local |= RTF_LOCAL;
 
 relookup:
 	read_lock_bh(&table->tb6_lock);
@@ -820,7 +823,7 @@ restart:
 	read_unlock_bh(&table->tb6_lock);
 
 	if (!dst_get_neighbour_raw(&rt->dst)
-	    && !(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_LOCAL)))
+	    && !(rt->rt6i_flags & local))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
 	else if (!(rt->dst.flags & DST_HOST))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
@@ -864,7 +867,7 @@ out2:
 static struct rt6_info *ip6_pol_route_input(struct net *net, struct fib6_table *table,
 					    struct flowi6 *fl6, int flags)
 {
-	return ip6_pol_route(net, table, fl6->flowi6_iif, fl6, flags);
+	return ip6_pol_route(net, table, fl6->flowi6_iif, fl6, flags, 0);
 }
 
 void ip6_route_input(struct sk_buff *skb)
@@ -890,7 +893,7 @@ void ip6_route_input(struct sk_buff *skb)
 static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table *table,
 					     struct flowi6 *fl6, int flags)
 {
-	return ip6_pol_route(net, table, fl6->flowi6_oif, fl6, flags);
+	return ip6_pol_route(net, table, fl6->flowi6_oif, fl6, flags, 1);
 }
 
 struct dst_entry * ip6_route_output(struct net *net, const struct sock *sk,

--------------000903070702050505010509--
