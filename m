From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to KVM guest
Date: Mon, 03 Mar 2014 16:40:40 -0500
Message-ID: <5314F6D8.2050701@gmail.com>
References: <1566805413.12693479.1393872931017.JavaMail.zimbra@redhat.com> <2107636851.12713862.1393876035292.JavaMail.zimbra@redhat.com> <20140303212759.GW5090@Linus-Debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org
To: =?UTF-8?B?TGludXMgTMO8c3Npbmc=?= <linus.luessing@web.de>,
	Jan Stancek <jstancek@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:62430 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754533AbaCCVkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 16:40:43 -0500
Received: by mail-qc0-f169.google.com with SMTP id i17so1532119qcy.28
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2014 13:40:42 -0800 (PST)
In-Reply-To: <20140303212759.GW5090@Linus-Debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/2014 04:27 PM, Linus L=C3=BCssing wrote:
> Hi Jan,
>=20
> On Mon, Mar 03, 2014 at 02:47:15PM -0500, Jan Stancek wrote:
>> I'm seeing an issue where bridge (sometimes) stops forwarding ICMP6
>> neighbor solicitation packets to KVM guest and as result KVM guest d=
oesn't
>> respond with neighbor advertisement.
>=20
> Hm, okay, that's not supposed to happen.
>=20
>> The reason I think this packet is related is because when I send sam=
e exact
>> packet I'm often hitting same issue - bridge stops forwarding ICMP6 =
neigh.
>> solicitation packets to KVM guest.
>=20
> Yes, the MLD query is kicking the multicast snooping into gear. If
> there's never a query, then snooping is basically disabled
> (compare: "bridge: disable snooping if there is no querier").
>=20
>>
>> My current way to reproduce this is:
>> 0. host B IP / MAC is: 2620:52:0:1040:221:5aff:fe47:931c / 00:21:5a:=
47:93:1c
>>    guest IP / MAC is: 2620:52:0:1040:5056:ff:fe00:29 / 52:56:00:00:0=
0:29
>> 1. host B is sending neigh solicit packets every 5 seconds with KVM =
guest IP
>>    using ns6 from ipv6toolkit: http://www.si6networks.com/tools/ipv6=
toolkit/
>>    with parameters:
>>    --src-address=3D2620:52:0:1040:221:5aff:fe47:931c --dst-address=3D=
ff02::1:ff00:0029
>>    -t 2620:52:0:1040:5056:ff:fe00:29 --link-src-address=3D00:21:5a:4=
7:93:1c
>>    --source-lla-opt=3D00:21:5a:47:93:1c --link-dst-address=3D33:33:f=
f:00:00:29
>>    tcpdump running on guest can see both solicit and advertisement p=
ackets
>> 2. wait ~5 minutes
>> 3. host B sends Multicast Listener Query packet described above
>> 4. tcpdump running on guest is no longer seeing any neigh solicit pa=
ckets
>=20
> Just to clarify, host B is behind eno1 and vnet0 is directly
> connected to the interface of the guest, no additional bridge or
> anything else on top of that, right?
>=20
> Would it be possible for you to upload the tcpdumps from host B
> (or if you can't tcpdump on host B, then capturing on eno1)
> and the guest somewhere and saying at which time/packet in the dumps
> it stops working (probably ~10 seconds after the query). Filtering
> for ICMPv6 should be sufficient.=20
>=20
> What I'm curious about is, whether the guest receives
> the MLD query and responds with an MLD report. I suspect that
> either the bridge doesn't get an MLD report and therefore is
> shutting down the according port or there's a bug in parsing the
> MLD report in the bridge code.
>=20

I did notice a minor issue in the bridge code.  The following
code:
       /* Prevent flooding this packet if there is no listener present =
*/
        if (!ipv6_addr_is_ll_all_nodes(&ip6h->daddr))
                BR_INPUT_SKB_CB(skb)->mrouters_only =3D 1;

        if (ip6h->nexthdr !=3D IPPROTO_HOPOPTS ||
            ip6h->payload_len =3D=3D 0)
                return 0;

will mark most multicast traffic is mrouters_only.  The two
statement should be probably be reversed.  However, that's shouldn't
cause the reported problem.

-vlad

>=20
> Thanks for the detailed report so far!
>=20
> Cheers, Linus
>=20
