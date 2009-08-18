From: Patrick McHardy <kaber@trash.net>
Subject: Re: bad nat connection tracking performance with ip_gre
Date: Tue, 18 Aug 2009 16:58:40 +0200
Message-ID: <4A8AC1A0.6000602@trash.net>
References: <4A8A7F14.3010103@iki.fi> <4A8A84AF.7050901@trash.net> <4A8AA253.8090300@iki.fi> <4A8AA63D.4000702@trash.net> <4A8AB25A.4000105@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60165 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758641AbZHRO6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 10:58:42 -0400
In-Reply-To: <4A8AB25A.4000105@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Patrick McHardy wrote:
>> Timo Ter=E4s wrote:
>>> LOCALLY GENERATED PACKET, hogs CPU
>>> ----------------------------------
>>>
>>> IN=3D OUT=3Deth1 SRC=3D10.252.5.1 DST=3D239.255.12.42 LEN=3D1344
>>> TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D41664 DF PROTO=3DUDP SPT=3D4792=
0
>>> DPT=3D1234 LEN=3D1324 UID=3D1007 GID=3D1007
>>>     1. raw:OUTPUT
>>>     2. mangle:OUTPUT
>>>     3. filter:OUTPUT
>>>     4. mangle:POSTROUTING
>>>
>>
>> Please include the complete output, I need to see the devices logged
>> at each hook.
>=20
> The devices are identical for each hook grouped under same line.
>=20
> Here are the interesting lines from one packet:
>=20
> Generation:
>=20
> raw:OUTPUT:policy:2 IN=3D OUT=3Deth1 SRC=3D10.252.5.1 DST=3D239.255.1=
2.42
> LEN=3D1344 TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D36594 DF PROTO=3DUDP S=
PT=3D33977
> DPT=3D1234 LEN=3D1324 UID=3D1007 GID=3D1007 mangle:OUTPUT:policy:1 IN=
=3D OUT=3Deth1
> SRC=3D10.252.5.1 DST=3D239.255.12.42 LEN=3D1344 TOS=3D0x00 PREC=3D0x0=
0 TTL=3D8
> ID=3D36594 DF PROTO=3DUDP SPT=3D33977 DPT=3D1234 LEN=3D1324 UID=3D100=
7 GID=3D1007
> (the nat hook is called for initial packet only):
> nat:OUTPUT:policy:1 IN=3D OUT=3Deth1 SRC=3D10.252.5.1 DST=3D239.255.1=
2.42
> LEN=3D1344 TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D36593 DF PROTO=3DUDP S=
PT=3D33977
> DPT=3D1234 LEN=3D1324 UID=3D1007 GID=3D1007
> filter:OUTPUT:policy:1 IN=3D OUT=3Deth1 SRC=3D10.252.5.1 DST=3D239.25=
5.12.42
> LEN=3D1344 TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D36594 DF PROTO=3DUDP S=
PT=3D33977
> DPT=3D1234 LEN=3D1324 UID=3D1007 GID=3D1007 mangle:POSTROUTING:policy=
:1 IN=3D
> OUT=3Deth1 SRC=3D10.252.5.1 DST=3D239.255.12.42 LEN=3D1344 TOS=3D0x00=
 PREC=3D0x00
> TTL=3D8 ID=3D36594 DF PROTO=3DUDP SPT=3D33977 DPT=3D1234 LEN=3D1324
> mangle:POSTROUTING:policy:1 IN=3D OUT=3Deth1 SRC=3D10.252.5.1
> DST=3D239.255.12.42 LEN=3D1344 TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D36=
594 DF
> PROTO=3DUDP SPT=3D33977 DPT=3D1234 LEN=3D1324 UID=3D1007 GID=3D1007
> Looped back by multicast routing:
>=20
> raw:PREROUTING:policy:1 IN=3Deth1 OUT=3D MAC=3D SRC=3D10.252.5.1
> DST=3D239.255.12.42 LEN=3D1344 TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D36=
594 DF
> PROTO=3DUDP SPT=3D33977 DPT=3D1234 LEN=3D1324 mangle:PREROUTING:polic=
y:1 IN=3Deth1
> OUT=3D MAC=3D SRC=3D10.252.5.1 DST=3D239.255.12.42 LEN=3D1344 TOS=3D0=
x00 PREC=3D0x00
> TTL=3D8 ID=3D36594 DF PROTO=3DUDP SPT=3D33977 DPT=3D1234 LEN=3D1324
> The cpu hogging happens somewhere below this, since the more
> multicast destinations I have the more CPU it takes.

So you're sending to multiple destinations? That obviously increases
the time spent in netfilter and the remaining networking stack.

> Multicast forwarded (I hacked this into the code; but similar
> dump happens on local sendto()):
>=20
> Actually, now that I think, here we should have the inner IP
> contents, and not the incomplete outer yet. So apparently
> the ipgre_header() messes the network_header position.

It shouldn't even have been called at this point. Please retry this
without your changes.

> mangle:FORWARD:policy:1 IN=3Deth1 OUT=3Dgre1 SRC=3D0.0.0.0 DST=3Dre.m=
o.te.ip
> LEN=3D0 TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3D47 filter:F=
ORWARD:rule:2
> IN=3Deth1 OUT=3Dgre1 SRC=3D0.0.0.0 DST=3Dre.mo.te.ip LEN=3D0 TOS=3D0x=
00 PREC=3D0x00
> TTL=3D64 ID=3D0 DF PROTO=3D47

This looks really broken. Why is the protocol already 47 before it even
reaches the gre tunnel?

> ip_gre xmit sends out:

There should be a POSTROUTING hook here.

> raw:OUTPUT:rule:1 IN=3D OUT=3Deth0 SRC=3Dlo.ca.l.ip DST=3Dre.mo.te.ip=
 LEN=3D1372
> TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3D47 raw:OUTPUT:polic=
y:2 IN=3D
> OUT=3Deth0 SRC=3Dlo.ca.l.ip DST=3Dre.mo.te.ip LEN=3D1372 TOS=3D0x00 P=
REC=3D0x00
> TTL=3D64 ID=3D0 DF PROTO=3D47 mangle:OUTPUT:policy:1 IN=3D OUT=3Deth0
> SRC=3Dlo.ca.l.ip DST=3Dre.mo.te.ip LEN=3D1372 TOS=3D0x00 PREC=3D0x00 =
TTL=3D64 ID=3D0
> DF PROTO=3D47
> (nat hook for initial packets)
> nat:OUTPUT:policy:1 IN=3D OUT=3Deth0 SRC=3Dlo.ca.l.ip DST=3Dre.mo.te.=
ip LEN=3D1372
> TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3D47
> filter:OUTPUT:policy:1 IN=3D OUT=3Deth0 SRC=3Dlo.ca.l.ip DST=3Dre.mo.=
te.ip
> LEN=3D1372 TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3D47
> - Timo
>=20

