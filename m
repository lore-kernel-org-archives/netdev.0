From: Fan Du <fan.du@windriver.com>
Subject: Re: [RFC PATCH] sctp: Don't lookup dst if transport dst is still
 valid
Date: Tue, 16 Jul 2013 17:13:51 +0800
Message-ID: <51E50ECF.5070801@windriver.com>
References: <1372747174-23580-1-git-send-email-fan.du@windriver.com> <51D2E3C8.5050100@gmail.com> <51D389F9.4030804@windriver.com> <51D425B7.20204@gmail.com> <51D4DEFF.8030305@windriver.com> <51D6D3A0.7050106@gmail.com> <51DC282C.9090007@gmail.com> <51DCF09B.106@windriver.com> <20130712111909.GA5854@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vyasevich@gmail.com>, <nicolas.dichtel@6wind.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40036 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753905Ab3GPJON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 05:14:13 -0400
In-Reply-To: <20130712111909.GA5854@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013=E5=B9=B407=E6=9C=8812=E6=97=A5 19:19, Neil Horman wrote:
> On Wed, Jul 10, 2013 at 01:26:51PM +0800, Fan Du wrote:
>>
>>
>> On 2013=E5=B9=B407=E6=9C=8809=E6=97=A5 23:11, Vlad Yasevich wrote:
>>> On 07/05/2013 10:09 AM, Vlad Yasevich wrote:
>>>> On 07/03/2013 10:33 PM, Fan Du wrote:
>>>>>
>>>>>
>>>>> On 2013=E5=B9=B407=E6=9C=8803=E6=97=A5 21:23, Vlad Yasevich wrote=
:
>>>>>> On 07/02/2013 10:18 PM, Fan Du wrote:
>>>>>>>
>>>>>>>
>>>>>>> On 2013=E5=B9=B407=E6=9C=8802=E6=97=A5 22:29, Vlad Yasevich wro=
te:
>>>>>>>> On 07/02/2013 02:39 AM, Fan Du wrote:
>>>>>>>>> When sctp sits on IPv6, sctp_transport_dst_check pass cookie =
as ZERO,
>>>>>>>>> as a result ip6_dst_check always fail out. This behaviour mak=
es
>>>>>>>>> transport->dst useless, because every sctp_packet_transmit mu=
st look
>>>>>>>>> for valid dst(Is this what supposed to be?)
>>>>>>>>>
>>>>>>>>> One aggressive way is to call rt_genid_bump which invalid all=
 dst to
>>>>>>>>> make new dst for transport, apparently it also hurts others.
>>>>>>>>> I'm sure this may not be the best for all, so any commnets?
>>>>>>>>>
>>>>>>>>> Signed-off-by: Fan Du<fan.du@windriver.com>
>>>>>>>>> ---
>>>>>>>>> include/net/sctp/sctp.h | 18 ++++++++++++------
>>>>>>>>> net/sctp/ipv6.c | 2 ++
>>>>>>>>> 2 files changed, 14 insertions(+), 6 deletions(-)
>>>>>>>>>
>>>>>>>>> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.=
h
>>>>>>>>> index cd89510..f05af01 100644
>>>>>>>>> --- a/include/net/sctp/sctp.h
>>>>>>>>> +++ b/include/net/sctp/sctp.h
>>>>>>>>> @@ -719,14 +719,20 @@ static inline void sctp_v4_map_v6(union
>>>>>>>>> sctp_addr *addr)
>>>>>>>>> addr->v6.sin6_addr.s6_addr32[2] =3D htonl(0x0000ffff);
>>>>>>>>> }
>>>>>>>>>
>>>>>>>>> -/* The cookie is always 0 since this is how it's used in the
>>>>>>>>> - * pmtu code.
>>>>>>>>> - */
>>>>>>>>> +/* Set cookie with the right one for IPv6 and zero for other=
s */
>>>>>>>>> static inline struct dst_entry *sctp_transport_dst_check(stru=
ct
>>>>>>>>> sctp_transport *t)
>>>>>>>>> {
>>>>>>>>> - if (t->dst&&  !dst_check(t->dst, 0)) {
>>>>>>>>> - dst_release(t->dst);
>>>>>>>>> - t->dst =3D NULL;
>>>>>>>>> +
>>>>>>>>> + if (t->dst) {
>>>>>>>>> + struct rt6_info *rt =3D (struct rt6_info *)t->dst;
>>>>>>>>> + u32 cookie =3D 0;
>>>>>>>>> +
>>>>>>>>> + if ((t->af_specific->sa_family =3D=3D AF_INET6)&&  rt->rt6i=
_node)
>>>>>>>>> + cookie =3D rt->rt6i_node->fn_sernum;
>>>>>>>>> + if (!dst_check(t->dst, cookie)) {
>>>>>>>>> + dst_release(t->dst);
>>>>>>>>> + t->dst =3D NULL;
>>>>>>>>> + }
>>>>>>>>> }
>>>>>>>>
>>>>>>>> I think it would be better if we stored the dst_cookie in the
>>>>>>>> transport structure and initialized it at lookup time. If you =
do that,
>>>>>>>> then if the route table changes, we'd correctly detect it with=
out
>>>>>>>> artificially bumping rt_genid (and hurting ipv4).
>>>>>>>
>>>>>>> Hi Vlad/Neil
>>>>>>>
>>>>>>> Is this what you mean?
>>>>>>
>>>>>> Yes, exactly.
>>>>>>
>>>>>
>>>>> Hi Vlad
>>>>>
>>>>> I thinks twice about below patch, this is actually a chicken-egg =
issue.
>>>>> Look below scenario:
>>>>> (1) The first time we push packet through a transport, dst_cookie=
 is 0,
>>>>> so sctp_transport_dst_check also pass cookie as 0, then return ds=
t
>>>>> as NULL.
>>>>> Then we lookup dst by sctp_transport_route, and in there we
>>>>> initiate dst_cookie
>>>>> with rt->rt6i_node->fn_sernum
>>>>>
>>>>> (2) Then the next time we push packet through this transport agai=
n,
>>>>> we pass dst_cookie(rt->rt6i_node->fn_sernum) to ip6_dst_check, an=
d
>>>>> return valid dst without bothering to lookup dst again.
>>>>
>>>> No, if the route was removed rt6i_node will be NULL, and NULL will=
 be
>>>> returned from ip6_dst_check(). If the route still exists then we'l=
l
>>>> compare the serial number with a cookie.
>>>>
>>>>>
>>>>> BUT, suppose when deleting the source address of this dst after
>>>>> transport->dst_cookie
>>>>> has been well initialized. transport->dst_cookie still holds
>>>>> rt->rt6i_node->fn_sernum,
>>>>> meaning ip6_dst_check will return valid dst, which it shouldn't i=
n this
>>>>> case, the
>>>>> result will be association ABORT.
>>>>
>>>> No, removing the address cause the route for that prefix to be rem=
oved
>>>> as well. This will set rt6i_node to NULL.
>>>>
>>>>>
>>>>> Other way is invalid all transport->dst which using the deleting =
address
>>>>> as source address
>>>>> without bumping gen_id, problem is the traverse times depends hea=
vily on
>>>>> transport number,
>>>>> and also need to take account locking issue it will introduce.
>>>>>
>>>>>>
>>>>>> No, you are not missing anything. IPv4 doesn't use the cookie an=
d
>>>>> always seems to pass it as 0.
>>>>>>
>>>>>> Yes, ipv4 will bump the gen_id thus invalidating all routes (the=
re
>>>>> has been disagreement about it).
>>>>>> IPv6 doesn't do that. In ipv6, when the addresses are added or
>>>>> removed, routes are also added or removed and
>>>>>> any time the route is added it will have a new serial number. So=
, you
>>>>> don't have to disturb ipv4 cache when ipv6 routing info changes.
>>>>>
>>>>> Thank you very much for your explanation!
>>>>>
>>>>> IPv6 don't bump gen_id, when adding/deleting address, and tag an =
serial
>>>>> number with each route.
>>>>> Doing this way loose the semantic of dst_check, because SCTP depe=
nds no
>>>>> dst_check fulfill its
>>>>> duty to actually check whether the holding dst is still valid, we=
ll most
>>>>> other Layer 4 protocol
>>>>> simply rely on ip6_route_output/ip6_dst_lookup_flow to grab dst e=
very
>>>>> time sending data out.
>>>>
>>>> Look at how other protocols (tcp, dccp) do this. It is sufficient =
to
>>>> cache the route serial number into the dst_cookie at the time the =
route
>>>> was lookup-up and cached. Then the cookie is passed to dst_check t=
o
>>>> validate the route.
>>>
>>>
>>> Hi Fan
>>>
>>> Have you tried the updated patch you sent? Based on what the tcp/ud=
p code is doing, the updated patch should work correctly. If it does, c=
an you re-post with attribution/sign-off
>>>
>>
>> Hello Vlad and Neil
>>
>> I don't know whether my test procedure has drawbacks or something el=
se.
>> It seems the updated patch does not works well, but my first patch i=
s ok under below configuration.
>>
>> Host A:
>> 	ifconfig eth1 inet6 add 2001::803/64
>> 	ifconfig eth1 inet6 add 2001::804/64
>> 	sctp_darn -H 2001::803 -B 2001::804 -P 5001 -l
>>
>> Host B:
>> 	ifconfig eth1 inet6 add 2001::805/64
>> 	ifconfig eth1 inet6 add 2001::806/64
>>          sctp_darn -H 2001::805 -B 2001::806 -P 5002 -h 2001::803 -p=
 5001 -s
>>
>> hbinterval set to 2 seconds, after setup the association, primary ad=
dress: 2001::804<-->  2001::806
>>
>>
>> Step 1:
>>
>> After adding in IPv6 address to an interface, we populate
>> struct inet6_ifaddr *ifp->rt->rt6i_node, this rt6i_node is stored in=
 a radix tree.
>>
>> addrconf_add_ifaddr
>>   ->inet6_addr_add
>>      ->ipv6_add_addr<-- Do DAD checking afterward.
>>      ->addrconf_prefix_route
>>        ->ip6_route_add
>>          ->__ip6_ins_rt
>>            ->fib6_add
>>              ->fib6_add_1<-- Create struct fib6_node *fn
>>                ->fib6_add_rt2node
>>                  ->rt->rt6i_node =3D fn; (*1*)
>>
>> Step 2:
>>
>> In host A ,for the packet destinate for 2001::806 using source addre=
ss 2001::804,
>> In sctp_v6_get_dst, let's print the rt, rt->rt6i_node, and rt->rt6i_=
node->fn_sernum
>> after ip6_dst_lookup_flow got valid dst. The problem is the transpor=
t->dst->rt6i_node
>> we have looked for is *not* the rt6i_node in (*1*), I'm not drunk he=
re.....
>> So in Step 3, let's be naughty: ifconfig eth1 inet6 del 2001::804/64
>>
> Wait, don't just skip past here.  As far as I know the dst_entry that=
 gets
> cached in transport->dst really needs to point at the same rt6_info a=
nd
> rt6i_node as the one created in step 1.  If it doesn't then that seco=
nd check in
> ip6_dst_check is pointless and will never work.  This really needs to=
 be the
> question here.  What is the result of your call to sctp_transport_rou=
te
> returning if not the route matching the one added for the source inte=
rface?

Hello Neil

=46irst, sorry for not respond quickly, busy with debugging=E3=80=82=E3=
=80=82=E3=80=82

 > Wait, don't just skip past here.  As far as I know the dst_entry tha=
t gets
 > cached in transport->dst really needs to point at the same rt6_info =
and
 > rt6i_node as the one created in step 1.

I'm afraid I can not agree with above statement.
Below is the IPv6 binary tree route table with small notes of which ste=
p generate which node.
Take a look at (4) when host respond with INIT_ACK, destination address=
 is 2001::806 with rt
different than that of rt in (1), that's because rt6_alloc_cow/rt6_allo=
c_clone may replicate
new rt for the node. And another point is this tree is created using de=
stination address,
which means if I delete node=EF=BC=881=EF=BC=89=EF=BC=8C node(4) is int=
act, and the source address is still 2001::804
there to reach 2001::806/128 for node(4).


     (1) 2001::804 DAD complete
     (2) 2001::803 DAD complete
     (3) 2001::806 -> 2001::803 SCTP_INIT
     (4) 2001::804 -> 2001::806 INIT_ACK
                                                       root:ffff8800379=
14560
                                                      /
                                                     /
                                      ffff88002103f000
                                     /                 \
                                    /                   \
        rt:ffff88002d47f600 (::1/128)                   (2001:/64)
                     ffff880037a0a4c0                   ffff88002103ffc=
0
                                                       /
                                                      /
                                       ffff88002103c380
                                     /                  \
                         (2) (3)    /                    \
rt:ffff880021091a80 (2001::803/128)                      ffff880037ac07=
c0
                    ffff88002103c240                     /             =
  \
                                                        /              =
   \
                                                       /               =
    \  (4)
                                                      /                =
    (2001::806/128)rt:ffff8800243ce900
                                            ffff880037ac0640           =
    ffff880037ac0480
                                            /             \
                                 (1)       /               \
        rt:ffff8800210af780 (2001::804/128)                (2001::805/1=
28) rt:ffff88002c980000
                           ffff88002103c080                ffff880037ac=
0f80


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
