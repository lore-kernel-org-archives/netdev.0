From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 1/2] ipv6: avoid blackhole and prohibited entries upon
 prefix purge [v3]
Date: Wed, 09 Jan 2013 16:11:43 +0100
Message-ID: <50ED88AF.3040705@6wind.com>
References: <0CC79564-4AF2-42F9-8D06-1BCC912A1AF7@ipflavors.com> <1357415941.1678.4163.camel@edumazet-glaptop> <2A507F9D-3D53-475F-8FA9-9E6CFEE9C97A@ipflavors.com> <50EAA28B.1080300@6wind.com> <3EF640F8-5242-486E-B7A3-9DA2A88F5A4F@ipflavors.com> <50EAED10.90904@6wind.com> <08F52788-0BD9-4907-8FC3-E9DF530AB042@ipflavors.com> <50EC47AD.8000801@6wind.com> <50EC54E3.9080606@linux-ipv6.org> <6A08EDC1-08A0-411D-90CF-6DB1CB7FA3A0@ipflavors.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net
To: Romain KUNTZ <r.kuntz@ipflavors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:50781 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757739Ab3AIPLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 10:11:48 -0500
Received: by mail-bk0-f51.google.com with SMTP id ik5so970529bkc.24
        for <netdev@vger.kernel.org>; Wed, 09 Jan 2013 07:11:46 -0800 (PST)
In-Reply-To: <6A08EDC1-08A0-411D-90CF-6DB1CB7FA3A0@ipflavors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/01/2013 15:37, Romain KUNTZ a =E9crit :
> On Jan 8, 2013, at 18:18 , YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org=
> wrote:
>> Nicolas Dichtel wrote:
>>> Le 08/01/2013 12:38, Romain KUNTZ a =E9crit :
>>>> On Jan 7, 2013, at 16:43 , Nicolas Dichtel <nicolas.dichtel@6wind.=
com> wrote:
>>>>> Le 07/01/2013 12:30, Romain KUNTZ a =E9crit :
>>>>>> Hello Nicolas,
>>>>>>
>>>>>> On Jan 7, 2013, at 11:25 , Nicolas Dichtel <nicolas.dichtel@6win=
d.com> wrote:
>>>>>>
>>>>>>> Le 05/01/2013 22:44, Romain KUNTZ a =E9crit :
>>>>>>>> Mobile IPv6 provokes a kernel Oops since commit 64c6d08e (ipv6=
:
>>>>>>>> del unreachable route when an addr is deleted on lo), because
>>>>>>>> ip6_route_lookup() may also return blackhole and prohibited
>>>>>>>> entry. However, these entries have a NULL rt6i_table argument,
>>>>>>>> which provokes an Oops in __ip6_del_rt() when trying to lock
>>>>>>>> rt6i_table->tb6_lock.
>>>>>>>>
>>>>>>>> Beside, when purging a prefix, blakhole and prohibited entries
>>>>>>>> should not be selected because they are not what we are lookin=
g
>>>>>>>> for.
>>>>>>>>
>>>>>>>> We fix this by adding two new lookup flags (RT6_LOOKUP_F_NO_BL=
K_HOLE
>>>>>>>> and RT6_LOOKUP_F_NO_PROHIBIT) in order to ensure that such ent=
ries
>>>>>>>> are skipped during lookup and that the correct entry is return=
ed.
>>>>>>>>
>>>>>>>> [v2]: use 'goto out;' instead of 'goto again;' to avoid unnece=
ssary
>>>>>>>> oprations on rt (as suggested by Eric Dumazet).
>>>>>>>>
>>>>>>>> Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>
>>>>>>>> ---
>>>>>>>>   include/net/ip6_route.h |    2 ++
>>>>>>>>   net/ipv6/addrconf.c     |    4 +++-
>>>>>>>>   net/ipv6/fib6_rules.c   |    4 ++++
>>>>>>>>   3 files changed, 9 insertions(+), 1 deletions(-)
>>>>>>>>
>>>>>>>> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
>>>>>>>> index 27d8318..3c93743 100644
>>>>>>>> --- a/include/net/ip6_route.h
>>>>>>>> +++ b/include/net/ip6_route.h
>>>>>>>> @@ -30,6 +30,8 @@ struct route_info {
>>>>>>>>   #define RT6_LOOKUP_F_SRCPREF_TMP    0x00000008
>>>>>>>>   #define RT6_LOOKUP_F_SRCPREF_PUBLIC    0x00000010
>>>>>>>>   #define RT6_LOOKUP_F_SRCPREF_COA    0x00000020
>>>>>>>> +#define RT6_LOOKUP_F_NO_BLK_HOLE    0x00000040
>>>>>>>> +#define RT6_LOOKUP_F_NO_PROHIBIT    0x00000080
>>>>>>>>
>>>>>>>>   /*
>>>>>>>>    * rt6_srcprefs2flags() and rt6_flags2srcprefs() translate
>>>>>>>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>>>>>>>> index 408cac4a..1891e23 100644
>>>>>>>> --- a/net/ipv6/addrconf.c
>>>>>>>> +++ b/net/ipv6/addrconf.c
>>>>>>>> @@ -948,7 +948,9 @@ static void ipv6_del_addr(struct inet6_ifa=
ddr *ifp)
>>>>>>>>           fl6.flowi6_oif =3D ifp->idev->dev->ifindex;
>>>>>>>>           fl6.daddr =3D prefix;
>>>>>>>>           rt =3D (struct rt6_info *)ip6_route_lookup(net, &fl6=
,
>>>>>>>> -                             RT6_LOOKUP_F_IFACE);
>>>>>>>> +                        RT6_LOOKUP_F_IFACE |
>>>>>>>> +                        RT6_LOOKUP_F_NO_BLK_HOLE |
>>>>>>>> +                        RT6_LOOKUP_F_NO_PROHIBIT);
>>>>>>>>
>>>>>>>>           if (rt !=3D net->ipv6.ip6_null_entry &&
>>>>>>> Is it not simpler to test the result here (net->ipv6.ip6_blk_ho=
le_entry and
>>>>>>> net->ipv6.ip6_prohibit_entry) like for the null_entry?
>>>>>>> It will also avoid adding more flags.
>>>>>>
>>>>>> Your proposal would only solve part of the problem (the Oops in =
__ip6_del_rt()). Another problem here is that blackhole and prohibited =
rules should not be selected when trying to purge a prefix (correct me =
if I'm wrong) because they are not what we are looking for. This can pr=
event the targeted prefix from being purged.
>>>>> In fact, I'm not sure to get the scenario. This part of the code =
just tries
>>>>> to remove the connected prefix, added by the kernel when the addr=
ess was added.
>>>>> Can you describe your scenario?
>>>>
>>>>
>>>> I should have given more details from the beginning, my mistake. T=
he scenario where this happens is quite simple:
>>>>
>>>> - install a blackhole rule (e.g. "from 2001:db8::1000 blackhole" -=
 the source address does not matter at all) with the FIB_RULE_FIND_SADD=
R flag set (setting this flag is not possible with iproute2, but for te=
st purpose you can use the enclosed patch against the latest iproute2 t=
ree and then use "./ip -6 rule add from 2001:db8::1000/128 blackhole pr=
io 1000").
>>>>
>>>> - try to delete an address from one of your interface (any address=
, it can be different from the one you used for the blackhole rule): "i=
p -6 addr del <v6-addr>/64 dev eth<x>"
>>>>
>>>> and you get an Oops. When trying to remove the connected prefix, t=
he fib6_rule_match() function will match the blackhole rule because RT6=
_LOOKUP_F_HAS_SADDR is not set and FIB_RULE_FIND_SADDR is set.
>>>>
>>>> With your proposal, the Oops is fixed but the connected prefix rou=
te is not deleted. With my initial patch, the Oops is fixed and the con=
nected prefix route is also deleted.
>>> Ok, I get it. I thin,there is two bugs: the oops and the wrong look=
up.
>>>
>>> Your proposal fix only a particular case. Try this (with your ip ro=
ute2 patch):
>>> ip -6 addr add 2002::1/64 dev eth0
>>> ip -6 route add 2002::/64 table 257 dev eth0
>
> (you also need to add a rule such as this one:)
> ip -6 rule to 2002::/64 table 257
>
>>> ip -6 addr del 2002::1/64 dev eth0
>>>
>>> The route deleted is not the connected prefix, but the route added =
in table 257.
>
> You are right.
>
>>> The connected prefix is still here in the main table. It's not what=
 we want.
>>> Maybe the lookup should be done directly into the right table, ie t=
able RT6_TABLE_PREFIX. What do you think?
>>
>> I agree.  I think we can use addrconf_get_prefix_route() here.
>
> Right, thanks for the hint! What about the below patch?
>
> Note that addrconf_get_prefix_route() also requires a fix (I believe =
it does not handle the 'noflags' parameter correctly), I have sent a pa=
tch in a separate mail (subject "ipv6: fix the noflags test in addrconf=
_get_prefix_route").
>
> Thanks,
> Romain
>
>
>
>  From 2a79f191042ee8d48119b095b2ef7527a89817fc Mon Sep 17 00:00:00 20=
01
> From: Romain Kuntz <r.kuntz@ipflavors.com>
> Date: Wed, 9 Jan 2013 15:11:08 +0100
> Subject: [PATCH 1/1] ipv6: use addrconf_get_prefix_route for prefix r=
oute lookup
>
> Replace ip6_route_lookup() with addrconf_get_prefix_route() when
> looking up for a prefix route. This ensures that the connected prefix
> is looked up in the main table, and avoids the selection of other
> matching route located in different tables.
>
> As a consequence, the function addrconf_is_prefix_route() is not
> used anymore and is removed.
Because this patch also fix an oops, I think it's interesting to tell i=
t in the=20
commit log and point the commit that introduce this oops.

>
> Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>
> ---
>   net/ipv6/addrconf.c |   24 ++++++++++--------------
>   1 files changed, 10 insertions(+), 14 deletions(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 29ba4ff..409dd47 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -154,6 +154,10 @@ static void addrconf_type_change(struct net_devi=
ce *dev,
>   				 unsigned long event);
>   static int addrconf_ifdown(struct net_device *dev, int how);
>
> +static struct rt6_info *addrconf_get_prefix_route(const struct in6_a=
ddr *pfx,
> +				int plen, const struct net_device *dev,
> +				u32 flags, u32 noflags);
These args should be aligned to the previous '('.

> +
>   static void addrconf_dad_start(struct inet6_ifaddr *ifp);
>   static void addrconf_dad_timer(unsigned long data);
>   static void addrconf_dad_completed(struct inet6_ifaddr *ifp);
> @@ -250,12 +254,6 @@ static inline bool addrconf_qdisc_ok(const struc=
t net_device *dev)
>   	return !qdisc_tx_is_noop(dev);
>   }
>
> -/* Check if a route is valid prefix route */
> -static inline int addrconf_is_prefix_route(const struct rt6_info *rt=
)
> -{
> -	return (rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) =3D=3D 0;
> -}
> -
>   static void addrconf_del_timer(struct inet6_ifaddr *ifp)
>   {
>   	if (del_timer(&ifp->timer))
> @@ -941,17 +939,15 @@ static void ipv6_del_addr(struct inet6_ifaddr *=
ifp)
>   	if ((ifp->flags & IFA_F_PERMANENT) && onlink < 1) {
>   		struct in6_addr prefix;
>   		struct rt6_info *rt;
> -		struct net *net =3D dev_net(ifp->idev->dev);
> -		struct flowi6 fl6 =3D {};
>
>   		ipv6_addr_prefix(&prefix, &ifp->addr, ifp->prefix_len);
> -		fl6.flowi6_oif =3D ifp->idev->dev->ifindex;
> -		fl6.daddr =3D prefix;
> -		rt =3D (struct rt6_info *)ip6_route_lookup(net, &fl6,
> -							 RT6_LOOKUP_F_IFACE);
>
> -		if (rt !=3D net->ipv6.ip6_null_entry &&
> -		    addrconf_is_prefix_route(rt)) {
> +		rt =3D addrconf_get_prefix_route(&prefix,
> +					ifp->prefix_len,
> +					ifp->idev->dev,
> +					0, RTF_GATEWAY | RTF_DEFAULT);
Same here.

> +
> +		if (rt) {
>   			if (onlink =3D=3D 0) {
>   				ip6_del_rt(rt);
>   				rt =3D NULL;
>
After, you can add my "Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind=
=2Ecom>" ;-)
