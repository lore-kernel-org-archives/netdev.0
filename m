From: Romain KUNTZ <r.kuntz@ipflavors.com>
Subject: Re: [PATCH 1/2] ipv6: avoid blackhole and prohibited entries upon prefix purge [v2]
Date: Tue, 8 Jan 2013 12:38:08 +0100
Message-ID: <08F52788-0BD9-4907-8FC3-E9DF530AB042@ipflavors.com>
References: <0CC79564-4AF2-42F9-8D06-1BCC912A1AF7@ipflavors.com> <1357415941.1678.4163.camel@edumazet-glaptop> <2A507F9D-3D53-475F-8FA9-9E6CFEE9C97A@ipflavors.com> <50EAA28B.1080300@6wind.com> <3EF640F8-5242-486E-B7A3-9DA2A88F5A4F@ipflavors.com> <50EAED10.90904@6wind.com>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: multipart/mixed; boundary="Apple-Mail=_999E9536-685C-4970-A175-2AA4F7F91AC3"
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:48249 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab3AHLpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 06:45:30 -0500
Received: by mail-bk0-f49.google.com with SMTP id jm19so175706bkc.22
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 03:45:29 -0800 (PST)
In-Reply-To: <50EAED10.90904@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail=_999E9536-685C-4970-A175-2AA4F7F91AC3
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=iso-8859-1

On Jan 7, 2013, at 16:43 , Nicolas Dichtel <nicolas.dichtel@6wind.com> =
wrote:
> Le 07/01/2013 12:30, Romain KUNTZ a =E9crit :
>> Hello Nicolas,
>>=20
>> On Jan 7, 2013, at 11:25 , Nicolas Dichtel =
<nicolas.dichtel@6wind.com> wrote:
>>=20
>>> Le 05/01/2013 22:44, Romain KUNTZ a =E9crit :
>>>> Mobile IPv6 provokes a kernel Oops since commit 64c6d08e (ipv6:
>>>> del unreachable route when an addr is deleted on lo), because
>>>> ip6_route_lookup() may also return blackhole and prohibited
>>>> entry. However, these entries have a NULL rt6i_table argument,
>>>> which provokes an Oops in __ip6_del_rt() when trying to lock
>>>> rt6i_table->tb6_lock.
>>>>=20
>>>> Beside, when purging a prefix, blakhole and prohibited entries
>>>> should not be selected because they are not what we are looking
>>>> for.
>>>>=20
>>>> We fix this by adding two new lookup flags =
(RT6_LOOKUP_F_NO_BLK_HOLE
>>>> and RT6_LOOKUP_F_NO_PROHIBIT) in order to ensure that such entries
>>>> are skipped during lookup and that the correct entry is returned.
>>>>=20
>>>> [v2]: use 'goto out;' instead of 'goto again;' to avoid unnecessary
>>>> oprations on rt (as suggested by Eric Dumazet).
>>>>=20
>>>> Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>
>>>> ---
>>>>  include/net/ip6_route.h |    2 ++
>>>>  net/ipv6/addrconf.c     |    4 +++-
>>>>  net/ipv6/fib6_rules.c   |    4 ++++
>>>>  3 files changed, 9 insertions(+), 1 deletions(-)
>>>>=20
>>>> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
>>>> index 27d8318..3c93743 100644
>>>> --- a/include/net/ip6_route.h
>>>> +++ b/include/net/ip6_route.h
>>>> @@ -30,6 +30,8 @@ struct route_info {
>>>>  #define RT6_LOOKUP_F_SRCPREF_TMP	0x00000008
>>>>  #define RT6_LOOKUP_F_SRCPREF_PUBLIC	0x00000010
>>>>  #define RT6_LOOKUP_F_SRCPREF_COA	0x00000020
>>>> +#define RT6_LOOKUP_F_NO_BLK_HOLE	0x00000040
>>>> +#define RT6_LOOKUP_F_NO_PROHIBIT	0x00000080
>>>>=20
>>>>  /*
>>>>   * rt6_srcprefs2flags() and rt6_flags2srcprefs() translate
>>>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>>>> index 408cac4a..1891e23 100644
>>>> --- a/net/ipv6/addrconf.c
>>>> +++ b/net/ipv6/addrconf.c
>>>> @@ -948,7 +948,9 @@ static void ipv6_del_addr(struct inet6_ifaddr =
*ifp)
>>>>  		fl6.flowi6_oif =3D ifp->idev->dev->ifindex;
>>>>  		fl6.daddr =3D prefix;
>>>>  		rt =3D (struct rt6_info *)ip6_route_lookup(net, &fl6,
>>>> -							 =
RT6_LOOKUP_F_IFACE);
>>>> +						RT6_LOOKUP_F_IFACE |
>>>> +						RT6_LOOKUP_F_NO_BLK_HOLE =
|
>>>> +						=
RT6_LOOKUP_F_NO_PROHIBIT);
>>>>=20
>>>>  		if (rt !=3D net->ipv6.ip6_null_entry &&
>>> Is it not simpler to test the result here =
(net->ipv6.ip6_blk_hole_entry and
>>> net->ipv6.ip6_prohibit_entry) like for the null_entry?
>>> It will also avoid adding more flags.
>>=20
>> Your proposal would only solve part of the problem (the Oops in =
__ip6_del_rt()). Another problem here is that blackhole and prohibited =
rules should not be selected when trying to purge a prefix (correct me =
if I'm wrong) because they are not what we are looking for. This can =
prevent the targeted prefix from being purged.
> In fact, I'm not sure to get the scenario. This part of the code just =
tries
> to remove the connected prefix, added by the kernel when the address =
was added.
> Can you describe your scenario?


I should have given more details from the beginning, my mistake. The =
scenario where this happens is quite simple:

- install a blackhole rule (e.g. "from 2001:db8::1000 blackhole" - the =
source address does not matter at all) with the FIB_RULE_FIND_SADDR flag =
set (setting this flag is not possible with iproute2, but for test =
purpose you can use the enclosed patch against the latest iproute2 tree =
and then use "./ip -6 rule add from 2001:db8::1000/128 blackhole prio =
1000").

- try to delete an address from one of your interface (any address, it =
can be different from the one you used for the blackhole rule): "ip -6 =
addr del <v6-addr>/64 dev eth<x>"

and you get an Oops. When trying to remove the connected prefix, the =
fib6_rule_match() function will match the blackhole rule because =
RT6_LOOKUP_F_HAS_SADDR is not set and FIB_RULE_FIND_SADDR is set.

With your proposal, the Oops is fixed but the connected prefix route is =
not deleted. With my initial patch, the Oops is fixed and the connected =
prefix route is also deleted.

Thanks,
Romain


--Apple-Mail=_999E9536-685C-4970-A175-2AA4F7F91AC3
Content-Disposition: attachment;
	filename=iproute2-blkhole-saddr.patch
Content-Type: application/octet-stream;
	name="iproute2-blkhole-saddr.patch"
Content-Transfer-Encoding: 7bit

diff --git a/ip/iprule.c b/ip/iprule.c
index a5fcd43..7aa94e8 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -349,6 +349,9 @@ static int iprule_modify(int cmd, int argc, char **argv)
 		argv++;
 	}
 
+	if (req.r.rtm_src_len && req.r.rtm_type == RTN_BLACKHOLE)
+		req.r.rtm_flags |= FIB_RULE_FIND_SADDR;
+
 	if (req.r.rtm_family == AF_UNSPEC)
 		req.r.rtm_family = AF_INET;
 

--Apple-Mail=_999E9536-685C-4970-A175-2AA4F7F91AC3--
