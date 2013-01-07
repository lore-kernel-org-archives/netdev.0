From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 1/2] ipv6: avoid blackhole and prohibited entries upon
 prefix purge [v2]
Date: Mon, 07 Jan 2013 16:43:12 +0100
Message-ID: <50EAED10.90904@6wind.com>
References: <0CC79564-4AF2-42F9-8D06-1BCC912A1AF7@ipflavors.com> <1357415941.1678.4163.camel@edumazet-glaptop> <2A507F9D-3D53-475F-8FA9-9E6CFEE9C97A@ipflavors.com> <50EAA28B.1080300@6wind.com> <3EF640F8-5242-486E-B7A3-9DA2A88F5A4F@ipflavors.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
To: Romain KUNTZ <r.kuntz@ipflavors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f50.google.com ([209.85.214.50]:58684 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273Ab3AGPnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 10:43:17 -0500
Received: by mail-bk0-f50.google.com with SMTP id jf3so8590570bkc.37
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 07:43:16 -0800 (PST)
In-Reply-To: <3EF640F8-5242-486E-B7A3-9DA2A88F5A4F@ipflavors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/01/2013 12:30, Romain KUNTZ a =E9crit :
> Hello Nicolas,
>
> On Jan 7, 2013, at 11:25 , Nicolas Dichtel <nicolas.dichtel@6wind.com=
> wrote:
>
>> Le 05/01/2013 22:44, Romain KUNTZ a =E9crit :
>>> Mobile IPv6 provokes a kernel Oops since commit 64c6d08e (ipv6:
>>> del unreachable route when an addr is deleted on lo), because
>>> ip6_route_lookup() may also return blackhole and prohibited
>>> entry. However, these entries have a NULL rt6i_table argument,
>>> which provokes an Oops in __ip6_del_rt() when trying to lock
>>> rt6i_table->tb6_lock.
>>>
>>> Beside, when purging a prefix, blakhole and prohibited entries
>>> should not be selected because they are not what we are looking
>>> for.
>>>
>>> We fix this by adding two new lookup flags (RT6_LOOKUP_F_NO_BLK_HOL=
E
>>> and RT6_LOOKUP_F_NO_PROHIBIT) in order to ensure that such entries
>>> are skipped during lookup and that the correct entry is returned.
>>>
>>> [v2]: use 'goto out;' instead of 'goto again;' to avoid unnecessary
>>> oprations on rt (as suggested by Eric Dumazet).
>>>
>>> Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>
>>> ---
>>>   include/net/ip6_route.h |    2 ++
>>>   net/ipv6/addrconf.c     |    4 +++-
>>>   net/ipv6/fib6_rules.c   |    4 ++++
>>>   3 files changed, 9 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
>>> index 27d8318..3c93743 100644
>>> --- a/include/net/ip6_route.h
>>> +++ b/include/net/ip6_route.h
>>> @@ -30,6 +30,8 @@ struct route_info {
>>>   #define RT6_LOOKUP_F_SRCPREF_TMP	0x00000008
>>>   #define RT6_LOOKUP_F_SRCPREF_PUBLIC	0x00000010
>>>   #define RT6_LOOKUP_F_SRCPREF_COA	0x00000020
>>> +#define RT6_LOOKUP_F_NO_BLK_HOLE	0x00000040
>>> +#define RT6_LOOKUP_F_NO_PROHIBIT	0x00000080
>>>
>>>   /*
>>>    * rt6_srcprefs2flags() and rt6_flags2srcprefs() translate
>>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>>> index 408cac4a..1891e23 100644
>>> --- a/net/ipv6/addrconf.c
>>> +++ b/net/ipv6/addrconf.c
>>> @@ -948,7 +948,9 @@ static void ipv6_del_addr(struct inet6_ifaddr *=
ifp)
>>>   		fl6.flowi6_oif =3D ifp->idev->dev->ifindex;
>>>   		fl6.daddr =3D prefix;
>>>   		rt =3D (struct rt6_info *)ip6_route_lookup(net, &fl6,
>>> -							 RT6_LOOKUP_F_IFACE);
>>> +						RT6_LOOKUP_F_IFACE |
>>> +						RT6_LOOKUP_F_NO_BLK_HOLE |
>>> +						RT6_LOOKUP_F_NO_PROHIBIT);
>>>
>>>   		if (rt !=3D net->ipv6.ip6_null_entry &&
>> Is it not simpler to test the result here (net->ipv6.ip6_blk_hole_en=
try and
>> net->ipv6.ip6_prohibit_entry) like for the null_entry?
>> It will also avoid adding more flags.
>
> Your proposal would only solve part of the problem (the Oops in __ip6=
_del_rt()). Another problem here is that blackhole and prohibited rules=
 should not be selected when trying to purge a prefix (correct me if I'=
m wrong) because they are not what we are looking for. This can prevent=
 the targeted prefix from being purged.
In fact, I'm not sure to get the scenario. This part of the code just t=
ries
to remove the connected prefix, added by the kernel when the address wa=
s added.
Can you describe your scenario?
