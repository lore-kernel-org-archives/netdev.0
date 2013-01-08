From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 1/2] ipv6: avoid blackhole and prohibited entries upon
 prefix purge [v2]
Date: Tue, 08 Jan 2013 17:22:05 +0100
Message-ID: <50EC47AD.8000801@6wind.com>
References: <0CC79564-4AF2-42F9-8D06-1BCC912A1AF7@ipflavors.com> <1357415941.1678.4163.camel@edumazet-glaptop> <2A507F9D-3D53-475F-8FA9-9E6CFEE9C97A@ipflavors.com> <50EAA28B.1080300@6wind.com> <3EF640F8-5242-486E-B7A3-9DA2A88F5A4F@ipflavors.com> <50EAED10.90904@6wind.com> <08F52788-0BD9-4907-8FC3-E9DF530AB042@ipflavors.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
To: Romain KUNTZ <r.kuntz@ipflavors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f52.google.com ([209.85.214.52]:37439 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754213Ab3AHQWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 11:22:09 -0500
Received: by mail-bk0-f52.google.com with SMTP id w5so357001bku.39
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 08:22:08 -0800 (PST)
In-Reply-To: <08F52788-0BD9-4907-8FC3-E9DF530AB042@ipflavors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/01/2013 12:38, Romain KUNTZ a =E9crit :
> On Jan 7, 2013, at 16:43 , Nicolas Dichtel <nicolas.dichtel@6wind.com=
> wrote:
>> Le 07/01/2013 12:30, Romain KUNTZ a =E9crit :
>>> Hello Nicolas,
>>>
>>> On Jan 7, 2013, at 11:25 , Nicolas Dichtel <nicolas.dichtel@6wind.c=
om> wrote:
>>>
>>>> Le 05/01/2013 22:44, Romain KUNTZ a =E9crit :
>>>>> Mobile IPv6 provokes a kernel Oops since commit 64c6d08e (ipv6:
>>>>> del unreachable route when an addr is deleted on lo), because
>>>>> ip6_route_lookup() may also return blackhole and prohibited
>>>>> entry. However, these entries have a NULL rt6i_table argument,
>>>>> which provokes an Oops in __ip6_del_rt() when trying to lock
>>>>> rt6i_table->tb6_lock.
>>>>>
>>>>> Beside, when purging a prefix, blakhole and prohibited entries
>>>>> should not be selected because they are not what we are looking
>>>>> for.
>>>>>
>>>>> We fix this by adding two new lookup flags (RT6_LOOKUP_F_NO_BLK_H=
OLE
>>>>> and RT6_LOOKUP_F_NO_PROHIBIT) in order to ensure that such entrie=
s
>>>>> are skipped during lookup and that the correct entry is returned.
>>>>>
>>>>> [v2]: use 'goto out;' instead of 'goto again;' to avoid unnecessa=
ry
>>>>> oprations on rt (as suggested by Eric Dumazet).
>>>>>
>>>>> Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>
>>>>> ---
>>>>>   include/net/ip6_route.h |    2 ++
>>>>>   net/ipv6/addrconf.c     |    4 +++-
>>>>>   net/ipv6/fib6_rules.c   |    4 ++++
>>>>>   3 files changed, 9 insertions(+), 1 deletions(-)
>>>>>
>>>>> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
>>>>> index 27d8318..3c93743 100644
>>>>> --- a/include/net/ip6_route.h
>>>>> +++ b/include/net/ip6_route.h
>>>>> @@ -30,6 +30,8 @@ struct route_info {
>>>>>   #define RT6_LOOKUP_F_SRCPREF_TMP	0x00000008
>>>>>   #define RT6_LOOKUP_F_SRCPREF_PUBLIC	0x00000010
>>>>>   #define RT6_LOOKUP_F_SRCPREF_COA	0x00000020
>>>>> +#define RT6_LOOKUP_F_NO_BLK_HOLE	0x00000040
>>>>> +#define RT6_LOOKUP_F_NO_PROHIBIT	0x00000080
>>>>>
>>>>>   /*
>>>>>    * rt6_srcprefs2flags() and rt6_flags2srcprefs() translate
>>>>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>>>>> index 408cac4a..1891e23 100644
>>>>> --- a/net/ipv6/addrconf.c
>>>>> +++ b/net/ipv6/addrconf.c
>>>>> @@ -948,7 +948,9 @@ static void ipv6_del_addr(struct inet6_ifaddr=
 *ifp)
>>>>>   		fl6.flowi6_oif =3D ifp->idev->dev->ifindex;
>>>>>   		fl6.daddr =3D prefix;
>>>>>   		rt =3D (struct rt6_info *)ip6_route_lookup(net, &fl6,
>>>>> -							 RT6_LOOKUP_F_IFACE);
>>>>> +						RT6_LOOKUP_F_IFACE |
>>>>> +						RT6_LOOKUP_F_NO_BLK_HOLE |
>>>>> +						RT6_LOOKUP_F_NO_PROHIBIT);
>>>>>
>>>>>   		if (rt !=3D net->ipv6.ip6_null_entry &&
>>>> Is it not simpler to test the result here (net->ipv6.ip6_blk_hole_=
entry and
>>>> net->ipv6.ip6_prohibit_entry) like for the null_entry?
>>>> It will also avoid adding more flags.
>>>
>>> Your proposal would only solve part of the problem (the Oops in __i=
p6_del_rt()). Another problem here is that blackhole and prohibited rul=
es should not be selected when trying to purge a prefix (correct me if =
I'm wrong) because they are not what we are looking for. This can preve=
nt the targeted prefix from being purged.
>> In fact, I'm not sure to get the scenario. This part of the code jus=
t tries
>> to remove the connected prefix, added by the kernel when the address=
 was added.
>> Can you describe your scenario?
>
>
> I should have given more details from the beginning, my mistake. The =
scenario where this happens is quite simple:
>
> - install a blackhole rule (e.g. "from 2001:db8::1000 blackhole" - th=
e source address does not matter at all) with the FIB_RULE_FIND_SADDR f=
lag set (setting this flag is not possible with iproute2, but for test =
purpose you can use the enclosed patch against the latest iproute2 tree=
 and then use "./ip -6 rule add from 2001:db8::1000/128 blackhole prio =
1000").
>
> - try to delete an address from one of your interface (any address, i=
t can be different from the one you used for the blackhole rule): "ip -=
6 addr del <v6-addr>/64 dev eth<x>"
>
> and you get an Oops. When trying to remove the connected prefix, the =
fib6_rule_match() function will match the blackhole rule because RT6_LO=
OKUP_F_HAS_SADDR is not set and FIB_RULE_FIND_SADDR is set.
>
> With your proposal, the Oops is fixed but the connected prefix route =
is not deleted. With my initial patch, the Oops is fixed and the connec=
ted prefix route is also deleted.
Ok, I get it. I thin,there is two bugs: the oops and the wrong lookup.

Your proposal fix only a particular case. Try this (with your ip route2=
 patch):
ip -6 addr add 2002::1/64 dev eth0
ip -6 route add 2002::/64 table 257 dev eth0
ip -6 addr del 2002::1/64 dev eth0

The route deleted is not the connected prefix, but the route added in t=
able 257.
The connected prefix is still here in the main table. It's not what we =
want.
Maybe the lookup should be done directly into the right table, ie table=
=20
RT6_TABLE_PREFIX. What do you think?
