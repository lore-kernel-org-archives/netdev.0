From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled
 with CONFIG_IPV6_ROUTER_PREF
Date: Wed, 10 Jul 2013 16:30:35 +0200
Message-ID: <51DD700B.4060504@6wind.com>
References: <20130707173031.GC9625@order.stressinduktion.org> <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com> <20130710111504.GA15411@order.stressinduktion.org> <51DD4ECA.1080506@6wind.com> <20130710131741.GC15411@order.stressinduktion.org> <20130710134951.GE15411@order.stressinduktion.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:45800 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051Ab3GJOai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 10:30:38 -0400
Received: by mail-we0-f179.google.com with SMTP id w59so5888219wes.38
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 07:30:37 -0700 (PDT)
In-Reply-To: <20130710134951.GE15411@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/07/2013 15:49, Hannes Frederic Sowa a =C3=A9crit :
> On Wed, Jul 10, 2013 at 03:17:41PM +0200, Hannes Frederic Sowa wrote:
>> On Wed, Jul 10, 2013 at 02:08:42PM +0200, Nicolas Dichtel wrote:
>>> Le 10/07/2013 13:15, Hannes Frederic Sowa a =C3=A9crit :
>>>> On Wed, Jul 10, 2013 at 09:54:58AM +0200, Nicolas Dichtel wrote:
>>>>> Le 09/07/2013 23:57, Hannes Frederic Sowa a =C3=A9crit :
>>>>>> Are we sure we decrement all sibling's rt6i_nsiblings? Shouldn't=
 we
>>>>>> start iterating from fn->leaf? But this does not seem to cause i=
t,
>>>>>> because my trace does not report any calls to fib6_del_route.
>>>>> Note sure to follow you, but all siblings are listed in rt6i_sibl=
ings, so
>>>>> it must be enough.
>>>>
>>>> My hunch was to iterate over fn->leaf->rt_next and compare the met=
rics
>>>> like we
>>>> do when adding a new route. Then take that rt6_info->rt6i_siblings
>>>> list_head
>>>> to iterate over the remaining siblings. But I did not review that =
part
>>>> carefully, need to check later.
>>>>
>>>>>> You could try reproduce it by having an interface autoconfigured=
 with
>>>>>> a default router with NUD_VALID neighbour. I then added an unuse=
d vlan
>>>>>> interface (vid 100 in my case) and added the following ip addres=
ses:
>>>>>>
>>>>>> ip -6 a a 2001:ffff::1/64 dev eth0.100
>>>>>> ip -6 r a 2000::/3 nexthop via 2001:ffff::30 nexthop via 2001:ff=
ff::31
>>>>>> nexthop via 2001:ffff::32 nexthop via 2001:ffff::33
>>>>>>
>>>>>> (all nexthops should not be reachable)
>>>>>>
>>>>>> After starting a ping6 2000::1 the box should panic soon, after =
the
>>>>>> first nexthop entry times out.
>>>>>>
>>>>>> Perhaps you could give me a hint?
>>>>> I will run some tests with your patch. Will see.
>>>>>
>>>>> I assume you didn't reproduce this without your patch.
>>>>
>>>> Current kernel does not correctly select more specific routes, so =
these
>>>> routes
>>>> are not even tried and the logic should not be excercised.
>>>>
>>>> Ah, sorry, you should also compile your kernel without
>>>> CONFIG_IPV6_ROUTER_PREF, too, if you try to reproduce it.
>>> I've done this.
>>>
>>> My conf (eth1 autoconfigured, I use net-next + your patch):
>>> vconfig add eth1 100
>>> ifconfig eth1.100 up
>>> ip -6 a a 2001:ffff::1/64 dev eth1.100
>>> ip -6 r a 2000::/3 nexthop via 2001:ffff::30 nexthop via 2001:ffff:=
:31
>>> nexthop via 2001:ffff::32 nexthop via 2001:ffff::33
>>> ping6 2000::1
>>
>> Hm, I see. I suspect something with timing. I, too, use a net-next a=
nd have
>> one function dump_route added and sprinkeld it at some points.
>>
>> When I copy&pasted your calls I could not reproduce it. After a rebo=
ot when
>> just applying the commands from my history (which I did a lot faster=
), I got
>> the panic again.
>>
>> I'll remove the dump_routes and recheck later.
>
> This patch ontop
>
> --- a/net/ipv6/ip6_fib.c
> +++ b/net/ipv6/ip6_fib.c
> @@ -46,6 +46,16 @@
>   #define RT6_TRACE(x...) do { ; } while (0)
>   #endif
>
> +static void dump_route(struct rt6_info *rt, const char *prefix)
> +{
> +       u32 f =3D rt->rt6i_flags;
> +       struct rt6key *k =3D &rt->rt6i_dst;
> +       printk(KERN_INFO "%s: %p dst %pI6c plen %d gateway %pI6c, sib=
lings %d, metric %d, expires %d gateway %d idev6 %p dev %p\n", prefix,
> +              rt, &k->addr, k->plen, &rt->rt6i_gateway, rt->rt6i_nsi=
blings, rt->rt6i_metric, f&RTF_EXPIRES, f&RTF_GATEWAY, rt->rt6i_idev, r=
t->dst.dev);
> +}
> +
> +
> +
>   static struct kmem_cache * fib6_node_kmem __read_mostly;
>
>   enum fib_walk_state_t
> @@ -693,8 +703,11 @@ static int fib6_add_rt2node(struct fib6_node *fn=
, struct rt6_info *rt,
>                           */
>                          if (rt->rt6i_flags & RTF_GATEWAY &&
>                              !(rt->rt6i_flags & RTF_EXPIRES) &&
> -                           !(iter->rt6i_flags & RTF_EXPIRES))
> +                           !(iter->rt6i_flags & RTF_EXPIRES)) {
>                                  rt->rt6i_nsiblings++;
> +                               dump_route(rt, "(rt)");
> +                               dump_route(iter, "(iter)");
> +                       }
>                  }
>
>                  if (iter->rt6i_metric > rt->rt6i_metric)
> @@ -718,6 +731,7 @@ static int fib6_add_rt2node(struct fib6_node *fn,=
 struct rt6_info *rt,
>                          if (sibling->rt6i_metric =3D=3D rt->rt6i_met=
ric) {
>                                  list_add_tail(&rt->rt6i_siblings,
>                                                &sibling->rt6i_sibling=
s);
> +                               dump_route(sibling, "(sibling)");
>                                  break;
>                          }
>                          sibling =3D sibling->dst.rt6_next;
> @@ -730,6 +744,7 @@ static int fib6_add_rt2node(struct fib6_node *fn,=
 struct rt6_info *rt,
>                  list_for_each_entry_safe(sibling, temp_sibling,
>                                           &rt->rt6i_siblings, rt6i_si=
blings) {
>                          sibling->rt6i_nsiblings++;
> +                       dump_route(sibling, "(sibling increment)");
>                          BUG_ON(sibling->rt6i_nsiblings !=3D rt->rt6i=
_nsiblings);
>                          rt6i_nsiblings++;
>                  }
>
> produces this panic:
>
> [   59.234779] (rt): ffff880113242000 dst 2000::1 plen 128 gateway 20=
01:ffff::33, siblings 1, metric 0, expires 0 gateway 2 idev6 ffff880113=
1ab000 dev ffff88011816d000
> [   59.243794] (iter): ffff880117e7b680 dst 2000::1 plen 128 gateway =
2001:ffff::31, siblings 2, metric 0, expires 0 gateway 2 idev6 ffff8801=
131ab000 dev ffff88011816d000
> [   59.261383] (rt): ffff880113242000 dst 2000::1 plen 128 gateway 20=
01:ffff::33, siblings 2, metric 0, expires 0 gateway 2 idev6 ffff880113=
1ab000 dev ffff88011816d000
> [   59.270030] (iter): ffff880117e7bb00 dst 2000::1 plen 128 gateway =
2001:ffff::32, siblings 2, metric 0, expires 0 gateway 2 idev6 ffff8801=
131ab000 dev ffff88011816d000
> [   59.291933] (sibling): ffff880117e62480 dst 2000::1 plen 128 gatew=
ay 2001:ffff::30, siblings 2, metric 0, expires 4194304 gateway 2 idev6=
 ffff8801131ab000 dev ffff88011816d000
> [   59.306893] (sibling increment): ffff880117e62480 dst 2000::1 plen=
 128 gateway 2001:ffff::30, siblings 3, metric 0, expires 4194304 gatew=
ay 2 idev6 ffff8801131ab000 dev ffff88011816d000
I don't have the same output:
[   97.945170] (rt): f1a02d80 dst 2000:: plen 3 gateway 2001:660:1234:5=
678::31,=20
siblings 1, metric 1024, expires 0 gateway 2 idev6 f7507e00 dev f779300=
0
[   97.948117] (iter): f1a02e80 dst 2000:: plen 3 gateway=20
2001:660:1234:5678::30, siblings 0, metric 1024, expires 0 gateway 2 id=
ev6=20
f7507e00 dev f7793000
[   97.951207] (sibling): f1a02e80 dst 2000:: plen 3 gateway=20
2001:660:1234:5678::30, siblings 0, metric 1024, expires 0 gateway 2 id=
ev6=20
f7507e00 dev f7793000
[   97.954272] (sibling increment): f1a02e80 dst 2000:: plen 3 gateway=20
2001:660:1234:5678::30, siblings 1, metric 1024, expires 0 gateway 2 id=
ev6=20
f7507e00 dev f7793000
[   97.957545] (rt): f1a02c80 dst 2000:: plen 3 gateway 2001:660:1234:5=
678::32,=20
siblings 1, metric 1024, expires 0 gateway 2 idev6 f7507e00 dev f779300=
0
[   97.960376] (iter): f1a02e80 dst 2000:: plen 3 gateway=20
2001:660:1234:5678::30, siblings 1, metric 1024, expires 0 gateway 2 id=
ev6=20
f7507e00 dev f7793000
[   97.961902] (rt): f1a02c80 dst 2000:: plen 3 gateway 2001:660:1234:5=
678::32,=20
siblings 2, metric 1024, expires 0 gateway 2 idev6 f7507e00 dev f779300=
0
[   97.963095] (iter): f1a02d80 dst 2000:: plen 3 gateway=20
2001:660:1234:5678::31, siblings 1, metric 1024, expires 0 gateway 2 id=
ev6=20
f7507e00 dev f7793000
[   97.964354] (sibling): f1a02e80 dst 2000:: plen 3 gateway=20
2001:660:1234:5678::30, siblings 1, metric 1024, expires 0 gateway 2 id=
ev6=20
f7507e00 dev f7793000
[   97.965604] (sibling increment): f1a02e80 dst 2000:: plen 3 gateway=20
2001:660:1234:5678::30, siblings 2, metric 1024, expires 0 gateway 2 id=
ev6=20
f7507e00 dev f7793000
[   97.966916] (sibling increment): f1a02d80 dst 2000:: plen 3 gateway=20
2001:660:1234:5678::31, siblings 2, metric 1024, expires 0 gateway 2 id=
ev6=20
f7507e00 dev f7793000
[   97.968254] (rt): f1a02b80 dst 2000:: plen 3 gateway 2001:660:1234:5=
678::33,=20
siblings 1, metric 1024, expires 0 gateway 2 idev6 f7507e00 dev f779300=
0
[   97.969467] (iter): f1a02e80 dst 2000:: plen 3 gateway=20
2001:660:1234:5678::30, siblings 2, metric 1024, expires 0 gateway 2 id=
ev6=20
f7507e00 dev f7793000
[   97.970702] (rt): f1a02b80 dst 2000:: plen 3 gateway 2001:660:1234:5=
678::33,=20
siblings 2, metric 1024, expires 0 gateway 2 idev6 f7507e00 dev f779300=
0
[   97.971895] (iter): f1a02d80 dst 2000:: plen 3 gateway=20
2001:660:1234:5678::31, siblings 2, metric 1024, expires 0 gateway 2 id=
ev6=20
f7507e00 dev f7793000
[   97.973137] (rt): f1a02b80 dst 2000:: plen 3 gateway 2001:660:1234:5=
678::33,=20
siblings 3, metric 1024, expires 0 gateway 2 idev6 f7507e00 dev f779300=
0
[   97.974331] (iter): f1a02c80 dst 2000:: plen 3 gateway=20
2001:660:1234:5678::32, siblings 2, metric 1024, expires 0 gateway 2 id=
ev6=20
f7507e00 dev f7793000
[   97.975542] (sibling): f1a02e80 dst 2000:: plen 3 gateway=20
2001:660:1234:5678::30, siblings 2, metric 1024, expires 0 gateway 2 id=
ev6=20
f7507e00 dev f7793000
[   97.976808] (sibling increment): f1a02e80 dst 2000:: plen 3 gateway=20
2001:660:1234:5678::30, siblings 3, metric 1024, expires 0 gateway 2 id=
ev6=20
f7507e00 dev f7793000
[   97.978126] (sibling increment): f1a02d80 dst 2000:: plen 3 gateway=20
2001:660:1234:5678::31, siblings 3, metric 1024, expires 0 gateway 2 id=
ev6=20
f7507e00 dev f7793000
[   97.979453] (sibling increment): f1a02c80 dst 2000:: plen 3 gateway=20
2001:660:1234:5678::32, siblings 3, metric 1024, expires 0 gateway 2 id=
ev6=20
f7507e00 dev f7793000

Can you send me the output of:
ip -6 r
ip -6 a
