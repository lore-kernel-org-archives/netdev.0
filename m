From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: Re: Multicast Fails Over Multipoint GRE Tunnel
Date: Tue, 15 Mar 2011 20:28:21 +0200
Message-ID: <4D7FAFC5.9080101@iki.fi>
References: <998769.91206.qm@web39301.mail.mud.yahoo.com> <1300203277.2927.9.camel@edumazet-laptop> <4D7F9592.5050408@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Doug Kehn <rdkehn@yahoo.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41204 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758218Ab1COS2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 14:28:24 -0400
Received: by wya21 with SMTP id 21so829449wya.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 11:28:23 -0700 (PDT)
In-Reply-To: <4D7F9592.5050408@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/15/2011 06:36 PM, Timo Ter=C3=A4s wrote:
> On 03/15/2011 05:34 PM, Eric Dumazet wrote:
>> (Timo mentioned :=20
>> 	If the NOARP packets are not dropped, ipgre_tunnel_xmit() will
>> 	take rt->rt_gateway (=3D NBMA IP) and use that for route
>> 	look up (and may lead to bogus xfrm acquires).)
>>
>> Is the following works for you ?
>=20
> I have memory that _header() is called with daddr being valid pointer=
,
> but pointing to zero memory. So basically my situation would break wi=
th
> this.

Ok, I've gone through now the code paths. And I believe I made
originally the assumption that ipgre_tunnel_xmit would should not ever
get tiph->daddr =3D=3D 0 if we got ipgre_header() call.

However, what actually happens is for (NOARP interfaces) in arp.c:
 - unicast traffic gets NOARP entries mapped to dev->dev_addr (in gre
case it's the tunnel 'local' address)
 - multicast gets mapped to dev->broadcast

And if we create gre tunnel without local or remote address we end up
getting the NOARP entries with hwaddr 0.0.0.0.

Now, for unicast traffic it's mostly pointless. If the tunnel was
locally bound the packets would never leave: they'd get NOARP entry for
local address. And if it's locally unbound, the packets get rt_gateway,
which is pretty confusing routing wise (it apparently assumes your link
device has same ipv4 subnet as the gre device).

On multicast side it makes a bit more sense to map multicast groups. An=
d
this happened implicitly.

IMHO, we should fix the arp code in ipv4 and ipv6 to do proper
ARPHRD_IPGRE mappings so that the _header() gets called with proper
data. I think the multicast-to-same-multicast group mapping makes sense=
=2E
But do not really know what to do with unicast packets sent to gre
interface with NOARP and no link broadcast IP address.

Actually this was my problem: the unicast packets for gre interface wit=
h
NOARP flag resulted in trying to send packets out. So I could probably
just fix this by creating my gre interface *with* the ARP flag in the
first place.

But is there any sensible thing to do with the unicast packets in above
case? I think those should be just dropped. Or does someone think that
it'd ever make sense to take the inner unicast address and use it as th=
e
outer address too? If so, my patch should be just reverted.

My honest thought is to keep the ip_gre header check as it is currently
and fix arp code in ipv4 / neighbour code in ipv6 to do the proper NOAR=
P
mappings as needed. We might be able to get rid of the huge protocol
dependent "tiph->daddr =3D=3D 0" check in xmit path this way, and make =
sure
that the header is set properly.

This would also allow us to see proper NOARP entries when doing "ip
neigh show nud noarp". Now it will just show 0.0.0.0 entries with gre
devices without telling where to the packets are actually being sent to=
=2E

Any thoughts?

Cheers,
  Timo
