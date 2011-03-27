From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: Multicast Fails Over Multipoint GRE Tunnel
Date: Sun, 27 Mar 2011 19:17:23 +0300
Message-ID: <4D8F6313.60408@iki.fi>
References: <500208.18069.qm@web39303.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Doug Kehn <rdkehn@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:32992 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753949Ab1C0QR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 12:17:27 -0400
Received: by ewy4 with SMTP id 4so970593ewy.19
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2011 09:17:25 -0700 (PDT)
In-Reply-To: <500208.18069.qm@web39303.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2011 10:02 PM, Doug Kehn wrote:
>> From: Timo Ter=E4s <timo.teras@iki.fi>
>> Subject: Re: Multicast Fails Over Multipoint GRE Tunnel
>> To: "Doug Kehn" <rdkehn@yahoo.com>
>> Cc: "Eric Dumazet" <eric.dumazet@gmail.com>, netdev@vger.kernel.org
>> Date: Wednesday, March 16, 2011, 2:01 AM
>> On 03/15/2011 11:35 PM, Doug Kehn
>> wrote:
>>>> From: Timo Ter=E4s <timo.teras@iki.fi>
>>>> Subject: Re: Multicast Fails Over Multipoint GRE Tunnel
>>>> To: "Eric Dumazet" <eric.dumazet@gmail.com>
>>>> Cc: "Doug Kehn" <rdkehn@yahoo.com>, netdev@vger.kernel.org
>>>> Date: Tuesday, March 15, 2011, 12:36 PM
>>>> On 03/15/2011 05:34 PM, Eric Dumazet wrote:
>>>> Le lundi 14 mars 2011 =E0 16:34 -0700, Doug Kehn a =E9crit :
>>>> I'm running kernel version 2.6.36 on ARM XSCALE
>>>> (big-endian) and multicast over a multipoint GRE tunnel
>>>> isn't working.  For my architecture, this worked on
>>>> 2.6.26.8.  For x86, multicast over a multipoint GRE
>>>> tunnel worked with kernel version 2.6.31 but failed with
>>>> version 2.6.35.  Multicast over a multipoint GRE tunnel
>>>> fails because ipgre_header() fails the 'if (iph->daddr)'
>>>> check and reutrns -t->hlen. ipgre_header() is being
>>>> called, from neigh_connected_output(), with a non-null
>>>> daddr; the contents of daddr is zero.
>>>
>>> I wasn't sure if the above patch was in addition too
>>> or in lieu of the partial revert of ipgre_header() suggested
>>> by Eric; both cases were attempted.
>>
>> It was intended without the ipgre_header revert. The
>> partial revert does
>> not differ from full revert related to my problem.
>>
>>> The multicast scenario described does not work if only
>> the arp_mc_map() patch is applied.
>>
>> Uh. Right, the if test had wrong condition. The intention
>> was to show the idea that we create the multicast-to-multicast
>> GRE NOARP mappings in arp code where it should've been done in
>> the first place (IMHO).
>>
>> Could you try the below patch? That should work better. And
>> the ipgre_header should not be touched.
>=20
> It does!  With this patch my configuration works.

I've been trying to think what would be the proper way to handle
multicast in ip_gre. I would also hope to get the ipmr code integrated
with opennhrp and ip_gre (see my earlier mail from couple of years ago:
http://lists.openwall.net/netdev/2009/08/11/27).

I believe we should just create the noarp multicast mappings as my patc=
h
suggests. Both for IPv4 and IPv6 we map the inner multicast group to th=
e
IPv4 header of GRE. And I believe we should drop the support of
auto-mapping unicast addresses to unicast address. Does anyone think
it's useful if sending to 1.2.3.4 in gre1, would result in automapping
the outer IP also to 1.2.3.4 in case the interface was in NOARP mode? I
believe the user should just insert manually the ARP entries in this ca=
se.

Also, I noticed that ipmr got support for multiple tables, that fixes
one of the problem I stated along with the old patch. So I'm planning t=
o
reimplement at some point the patch from the above link. It'd probably
involve also hooking link-local multicast traffic through the ipmr
engine when using the NBMA mode. Obviously the ipmr when configured
would override the static NOARP multicast mappings.

If no one has objections I'll write up an official-looking patch that
adds the IPv4 multicast mappings, and try to fix up the same for IPv6
side. When this is done, it should be possible the get rid of the "if
((dst =3D tiph->daddr) =3D=3D 0) {" block in ipgre_tunnel_xmit(), since=
 we are
then creating all the mappings from the ARP code where it should be don=
e
anyway.

Any comments for this plan? Eric? Dave?

Cheers,
  Timo
