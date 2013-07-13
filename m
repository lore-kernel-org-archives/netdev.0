From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [RFC PATCH] sctp: Don't lookup dst if transport dst is still
 valid
Date: Sat, 13 Jul 2013 08:21:38 -0400
Message-ID: <51E14652.7090001@gmail.com>
References: <1372747174-23580-1-git-send-email-fan.du@windriver.com> <51D2E3C8.5050100@gmail.com> <51D389F9.4030804@windriver.com> <51D425B7.20204@gmail.com> <51D4DEFF.8030305@windriver.com> <51D6D3A0.7050106@gmail.com> <51DC282C.9090007@gmail.com> <51DCF09B.106@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f50.google.com ([209.85.128.50]:37166 "EHLO
	mail-qe0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623Ab3GMMVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jul 2013 08:21:42 -0400
Received: by mail-qe0-f50.google.com with SMTP id f6so5574767qej.37
        for <netdev@vger.kernel.org>; Sat, 13 Jul 2013 05:21:42 -0700 (PDT)
In-Reply-To: <51DCF09B.106@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2013 01:26 AM, Fan Du wrote:
>
>
> On 2013=E5=B9=B407=E6=9C=8809=E6=97=A5 23:11, Vlad Yasevich wrote:
>> On 07/05/2013 10:09 AM, Vlad Yasevich wrote:
>>> On 07/03/2013 10:33 PM, Fan Du wrote:
>>>>
>>>>
>>>> On 2013=E5=B9=B407=E6=9C=8803=E6=97=A5 21:23, Vlad Yasevich wrote:
>>>>> On 07/02/2013 10:18 PM, Fan Du wrote:
>>>>>>
>>>>>>
>>>>>> On 2013=E5=B9=B407=E6=9C=8802=E6=97=A5 22:29, Vlad Yasevich wrot=
e:
>>>>>>> On 07/02/2013 02:39 AM, Fan Du wrote:
>>>>>>>> When sctp sits on IPv6, sctp_transport_dst_check pass cookie a=
s
>>>>>>>> ZERO,
>>>>>>>> as a result ip6_dst_check always fail out. This behaviour make=
s
>>>>>>>> transport->dst useless, because every sctp_packet_transmit mus=
t
>>>>>>>> look
>>>>>>>> for valid dst(Is this what supposed to be?)
>>>>>>>>
>>>>>>>> One aggressive way is to call rt_genid_bump which invalid all
>>>>>>>> dst to
>>>>>>>> make new dst for transport, apparently it also hurts others.
>>>>>>>> I'm sure this may not be the best for all, so any commnets?
>>>>>>>>
>>>>>>>> Signed-off-by: Fan Du <fan.du@windriver.com>
>>>>>>>> ---
>>>>>>>> include/net/sctp/sctp.h | 18 ++++++++++++------
>>>>>>>> net/sctp/ipv6.c | 2 ++
>>>>>>>> 2 files changed, 14 insertions(+), 6 deletions(-)
>>>>>>>>
>>>>>>>> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
>>>>>>>> index cd89510..f05af01 100644
>>>>>>>> --- a/include/net/sctp/sctp.h
>>>>>>>> +++ b/include/net/sctp/sctp.h
>>>>>>>> @@ -719,14 +719,20 @@ static inline void sctp_v4_map_v6(union
>>>>>>>> sctp_addr *addr)
>>>>>>>> addr->v6.sin6_addr.s6_addr32[2] =3D htonl(0x0000ffff);
>>>>>>>> }
>>>>>>>>
>>>>>>>> -/* The cookie is always 0 since this is how it's used in the
>>>>>>>> - * pmtu code.
>>>>>>>> - */
>>>>>>>> +/* Set cookie with the right one for IPv6 and zero for others=
 */
>>>>>>>> static inline struct dst_entry *sctp_transport_dst_check(struc=
t
>>>>>>>> sctp_transport *t)
>>>>>>>> {
>>>>>>>> - if (t->dst && !dst_check(t->dst, 0)) {
>>>>>>>> - dst_release(t->dst);
>>>>>>>> - t->dst =3D NULL;
>>>>>>>> +
>>>>>>>> + if (t->dst) {
>>>>>>>> + struct rt6_info *rt =3D (struct rt6_info *)t->dst;
>>>>>>>> + u32 cookie =3D 0;
>>>>>>>> +
>>>>>>>> + if ((t->af_specific->sa_family =3D=3D AF_INET6) && rt->rt6i_=
node)
>>>>>>>> + cookie =3D rt->rt6i_node->fn_sernum;
>>>>>>>> + if (!dst_check(t->dst, cookie)) {
>>>>>>>> + dst_release(t->dst);
>>>>>>>> + t->dst =3D NULL;
>>>>>>>> + }
>>>>>>>> }
>>>>>>>
>>>>>>> I think it would be better if we stored the dst_cookie in the
>>>>>>> transport structure and initialized it at lookup time. If you d=
o
>>>>>>> that,
>>>>>>> then if the route table changes, we'd correctly detect it witho=
ut
>>>>>>> artificially bumping rt_genid (and hurting ipv4).
>>>>>>
>>>>>> Hi Vlad/Neil
>>>>>>
>>>>>> Is this what you mean?
>>>>>
>>>>> Yes, exactly.
>>>>>
>>>>
>>>> Hi Vlad
>>>>
>>>> I thinks twice about below patch, this is actually a chicken-egg i=
ssue.
>>>> Look below scenario:
>>>> (1) The first time we push packet through a transport, dst_cookie =
is 0,
>>>> so sctp_transport_dst_check also pass cookie as 0, then return dst
>>>> as NULL.
>>>> Then we lookup dst by sctp_transport_route, and in there we
>>>> initiate dst_cookie
>>>> with rt->rt6i_node->fn_sernum
>>>>
>>>> (2) Then the next time we push packet through this transport again=
,
>>>> we pass dst_cookie(rt->rt6i_node->fn_sernum) to ip6_dst_check, and
>>>> return valid dst without bothering to lookup dst again.
>>>
>>> No, if the route was removed rt6i_node will be NULL, and NULL will =
be
>>> returned from ip6_dst_check(). If the route still exists then we'll
>>> compare the serial number with a cookie.
>>>
>>>>
>>>> BUT, suppose when deleting the source address of this dst after
>>>> transport->dst_cookie
>>>> has been well initialized. transport->dst_cookie still holds
>>>> rt->rt6i_node->fn_sernum,
>>>> meaning ip6_dst_check will return valid dst, which it shouldn't in=
 this
>>>> case, the
>>>> result will be association ABORT.
>>>
>>> No, removing the address cause the route for that prefix to be remo=
ved
>>> as well. This will set rt6i_node to NULL.
>>>
>>>>
>>>> Other way is invalid all transport->dst which using the deleting
>>>> address
>>>> as source address
>>>> without bumping gen_id, problem is the traverse times depends
>>>> heavily on
>>>> transport number,
>>>> and also need to take account locking issue it will introduce.
>>>>
>>>> >
>>>> > No, you are not missing anything. IPv4 doesn't use the cookie an=
d
>>>> always seems to pass it as 0.
>>>> >
>>>> > Yes, ipv4 will bump the gen_id thus invalidating all routes (the=
re
>>>> has been disagreement about it).
>>>> > IPv6 doesn't do that. In ipv6, when the addresses are added or
>>>> removed, routes are also added or removed and
>>>> > any time the route is added it will have a new serial number. So=
, you
>>>> don't have to disturb ipv4 cache when ipv6 routing info changes.
>>>>
>>>> Thank you very much for your explanation!
>>>>
>>>> IPv6 don't bump gen_id, when adding/deleting address, and tag an s=
erial
>>>> number with each route.
>>>> Doing this way loose the semantic of dst_check, because SCTP depen=
ds no
>>>> dst_check fulfill its
>>>> duty to actually check whether the holding dst is still valid, wel=
l
>>>> most
>>>> other Layer 4 protocol
>>>> simply rely on ip6_route_output/ip6_dst_lookup_flow to grab dst ev=
ery
>>>> time sending data out.
>>>
>>> Look at how other protocols (tcp, dccp) do this. It is sufficient t=
o
>>> cache the route serial number into the dst_cookie at the time the r=
oute
>>> was lookup-up and cached. Then the cookie is passed to dst_check to
>>> validate the route.
>>
>>
>> Hi Fan
>>
>> Have you tried the updated patch you sent? Based on what the tcp/udp
>> code is doing, the updated patch should work correctly. If it does,
>> can you re-post with attribution/sign-off
>>
>
> Hello Vlad and Neil
>
> I don't know whether my test procedure has drawbacks or something els=
e.
> It seems the updated patch does not works well, but my first patch is=
 ok
> under below configuration.
>
> Host A:
>      ifconfig eth1 inet6 add 2001::803/64
>      ifconfig eth1 inet6 add 2001::804/64
>      sctp_darn -H 2001::803 -B 2001::804 -P 5001 -l
>
> Host B:
>      ifconfig eth1 inet6 add 2001::805/64
>      ifconfig eth1 inet6 add 2001::806/64
>          sctp_darn -H 2001::805 -B 2001::806 -P 5002 -h 2001::803 -p

Hi Fan

Could you try using different prefixes.  I think we are running into=20
some routing issue.

=46or example, configure 2001:1::803/64 and 2001:2::804/64.  I think=20
that's going to make this work (it seems to for me).

-vlad
> 5001 -s
>
> hbinterval set to 2 seconds, after setup the association, primary
> address: 2001::804 <--> 2001::806
>
>
> Step 1:
>
> After adding in IPv6 address to an interface, we populate
> struct inet6_ifaddr *ifp->rt->rt6i_node, this rt6i_node is stored in =
a
> radix tree.
>
> addrconf_add_ifaddr
>   ->inet6_addr_add
>      ->ipv6_add_addr  <-- Do DAD checking afterward.
>      ->addrconf_prefix_route
>        ->ip6_route_add
>          ->__ip6_ins_rt
>            ->fib6_add
>              ->fib6_add_1  <-- Create struct fib6_node *fn
>                ->fib6_add_rt2node
>                  ->rt->rt6i_node =3D fn; (*1*)
>
> Step 2:
>
> In host A ,for the packet destinate for 2001::806 using source addres=
s
> 2001::804,
> In sctp_v6_get_dst, let's print the rt, rt->rt6i_node, and
> rt->rt6i_node->fn_sernum
> after ip6_dst_lookup_flow got valid dst. The problem is the
> transport->dst->rt6i_node
> we have looked for is *not* the rt6i_node in (*1*), I'm not drunk her=
e.....
> So in Step 3, let's be naughty: ifconfig eth1 inet6 del 2001::804/64
>
>
> Step 3:
>
> Then we delete the IPv6 address, certainly this struct inet6_ifaddr
> *ifp->rt
> will be delete as well.
>
> addrconf_del_ifaddr
>    ->inet6_addr_del
>      ->ipv6_del_addr
>        ->ipv6_ifa_notify /RTM_DELADDR
>          ->ip6_del_rt
>            ->__ip6_del_rt
>              ->fib6_del
>                ->fib6_del_route
>                 -> rt->rt6i_node =3D NULL; (*2*) here we undo the
> operation in (*1*),
>                                                but rt6i_node in Step2=
 is
> untouched!
>
> Step 4:
> Then we do the dst checking, for sctp_tranport_dst_check it looks lik=
e
> nothing in Step3
> has consequence on it. So transport->dst is still valid, let's ship t=
he
> packet out
> using 2001::804. The real world test result is ASSOCIATION ABORT afte=
r a
> while.
> As far as I can tell, rt in Step 2 got deleted *after* the ASSOCIATIO=
N
> ABORT.
>
>     sctp_tranport_dst_check
>        ->dst_check
>          -> ip6_dst_check
>
>
> Root node
>     *
>    / \
>       * <-- fn node we are using.
>      / \
>         *
>        / \
>       *
>      / \
>         * <--- Add a new fn node, on the path from the root node down=
 to
> here, each fn
>                now has new fn_sernum, which force dst_check return NU=
LL
> for lookup again.
>                Then previously save fn_sernum will take effect now. B=
ut
> when delete address
>                only the ifp->rt->rt6i_node is set to NULL.
>
>
>> Thanks
>> -vlad
>>
>>>
>>> -vlad
>>>>
>>>> So please pronounce a final judgment.
>>>>
>>>>> -vlad
>>>>>
>>>>>>
>>>>>> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
>>>>>> index cd89510..0a646a5 100644
>>>>>> --- a/include/net/sctp/sctp.h
>>>>>> +++ b/include/net/sctp/sctp.h
>>>>>> @@ -724,7 +724,7 @@ static inline void sctp_v4_map_v6(union sctp=
_addr
>>>>>> *addr)
>>>>>> */
>>>>>> static inline struct dst_entry *sctp_transport_dst_check(struct
>>>>>> sctp_transport *t)
>>>>>> {
>>>>>> - if (t->dst && !dst_check(t->dst, 0)) {
>>>>>> + if (t->dst && !dst_check(t->dst, t->dst_cookie)) {
>>>>>> dst_release(t->dst);
>>>>>> t->dst =3D NULL;
>>>>>> }
>>>>>> diff --git a/include/net/sctp/structs.h b/include/net/sctp/struc=
ts.h
>>>>>> index 1bd4c41..cafdd19 100644
>>>>>> --- a/include/net/sctp/structs.h
>>>>>> +++ b/include/net/sctp/structs.h
>>>>>> @@ -946,6 +946,8 @@ struct sctp_transport {
>>>>>> __u64 hb_nonce;
>>>>>>
>>>>>> struct rcu_head rcu;
>>>>>> +
>>>>>> + u32 dst_cookie;
>>>>>> };
>>>>>>
>>>>>> struct sctp_transport *sctp_transport_new(struct net *, const un=
ion
>>>>>> sctp_addr *,
>>>>>> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
>>>>>> index 8ee553b..82a420f 100644
>>>>>> --- a/net/sctp/ipv6.c
>>>>>> +++ b/net/sctp/ipv6.c
>>>>>> @@ -350,6 +350,7 @@ out:
>>>>>> struct rt6_info *rt;
>>>>>> rt =3D (struct rt6_info *)dst;
>>>>>> t->dst =3D dst;
>>>>>> + t->dst_cookie =3D rt->rt6i_node ? rt->rt6i_node->fn_sernum
>>>>>> : 0;
>>>>>> SCTP_DEBUG_PRINTK("rt6_dst:%pI6 rt6_src:%pI6\n",
>>>>>> &rt->rt6i_dst.addr, &fl6->saddr);
>>>>>> } else {
>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>>>> -vlad
>>>>>>>
>>>>>>>>
>>>>>>>> return t->dst;
>>>>>>>> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
>>>>>>>> index 8ee553b..cfae77e 100644
>>>>>>>> --- a/net/sctp/ipv6.c
>>>>>>>> +++ b/net/sctp/ipv6.c
>>>>>>>> @@ -137,6 +137,8 @@ static int sctp_inet6addr_event(struct
>>>>>>>> notifier_block *this, unsigned long ev,
>>>>>>>> break;
>>>>>>>> }
>>>>>>>>
>>>>>>>> + /* invalid all transport dst forcing to look up new dst */
>>>>>>>> + rt_genid_bump(net);
>>>>>>>> return NOTIFY_DONE;
>>>>>>>> }
>>>>>>>>
>>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>
>>>>>
>>>>>
>>>>
>>>
>>
>>
>
