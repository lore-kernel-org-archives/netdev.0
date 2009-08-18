From: =?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: bad nat connection tracking performance with ip_gre
Date: Tue, 18 Aug 2009 16:53:30 +0300
Message-ID: <4A8AB25A.4000105@iki.fi>
References: <4A8A7F14.3010103@iki.fi> <4A8A84AF.7050901@trash.net> <4A8AA253.8090300@iki.fi> <4A8AA63D.4000702@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4A8AA63D.4000702@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Timo Ter=E4s wrote:
>> LOCALLY GENERATED PACKET, hogs CPU
>> ----------------------------------
>>
>> IN=3D OUT=3Deth1 SRC=3D10.252.5.1 DST=3D239.255.12.42 LEN=3D1344
>> TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D41664 DF PROTO=3DUDP SPT=3D47920
>> DPT=3D1234 LEN=3D1324 UID=3D1007 GID=3D1007
>>     1. raw:OUTPUT
>>     2. mangle:OUTPUT
>>     3. filter:OUTPUT
>>     4. mangle:POSTROUTING
>>
>=20
> Please include the complete output, I need to see the devices logged
> at each hook.

The devices are identical for each hook grouped under same line.

Here are the interesting lines from one packet:

Generation:

raw:OUTPUT:policy:2 IN=3D OUT=3Deth1 SRC=3D10.252.5.1 DST=3D239.255.12.=
42 LEN=3D1344 TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D36594 DF PROTO=3DUDP =
SPT=3D33977 DPT=3D1234 LEN=3D1324 UID=3D1007 GID=3D1007=20
mangle:OUTPUT:policy:1 IN=3D OUT=3Deth1 SRC=3D10.252.5.1 DST=3D239.255.=
12.42 LEN=3D1344 TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D36594 DF PROTO=3DU=
DP SPT=3D33977 DPT=3D1234 LEN=3D1324 UID=3D1007 GID=3D1007=20

(the nat hook is called for initial packet only):
nat:OUTPUT:policy:1 IN=3D OUT=3Deth1 SRC=3D10.252.5.1 DST=3D239.255.12.=
42 LEN=3D1344 TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D36593 DF PROTO=3DUDP =
SPT=3D33977 DPT=3D1234 LEN=3D1324 UID=3D1007 GID=3D1007=20

filter:OUTPUT:policy:1 IN=3D OUT=3Deth1 SRC=3D10.252.5.1 DST=3D239.255.=
12.42 LEN=3D1344 TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D36594 DF PROTO=3DU=
DP SPT=3D33977 DPT=3D1234 LEN=3D1324 UID=3D1007 GID=3D1007=20
mangle:POSTROUTING:policy:1 IN=3D OUT=3Deth1 SRC=3D10.252.5.1 DST=3D239=
=2E255.12.42 LEN=3D1344 TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D36594 DF PR=
OTO=3DUDP SPT=3D33977 DPT=3D1234 LEN=3D1324=20
mangle:POSTROUTING:policy:1 IN=3D OUT=3Deth1 SRC=3D10.252.5.1 DST=3D239=
=2E255.12.42 LEN=3D1344 TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D36594 DF PR=
OTO=3DUDP SPT=3D33977 DPT=3D1234 LEN=3D1324 UID=3D1007 GID=3D1007=20

Looped back by multicast routing:

raw:PREROUTING:policy:1 IN=3Deth1 OUT=3D MAC=3D SRC=3D10.252.5.1 DST=3D=
239.255.12.42 LEN=3D1344 TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D36594 DF P=
ROTO=3DUDP SPT=3D33977 DPT=3D1234 LEN=3D1324=20
mangle:PREROUTING:policy:1 IN=3Deth1 OUT=3D MAC=3D SRC=3D10.252.5.1 DST=
=3D239.255.12.42 LEN=3D1344 TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D36594 D=
=46 PROTO=3DUDP SPT=3D33977 DPT=3D1234 LEN=3D1324=20

The cpu hogging happens somewhere below this, since the more
multicast destinations I have the more CPU it takes.

Multicast forwarded (I hacked this into the code; but similar
dump happens on local sendto()):

Actually, now that I think, here we should have the inner IP
contents, and not the incomplete outer yet. So apparently
the ipgre_header() messes the network_header position.

mangle:FORWARD:policy:1 IN=3Deth1 OUT=3Dgre1 SRC=3D0.0.0.0 DST=3Dre.mo.=
te.ip LEN=3D0 TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3D47=20
filter:FORWARD:rule:2 IN=3Deth1 OUT=3Dgre1 SRC=3D0.0.0.0 DST=3Dre.mo.te=
=2Eip LEN=3D0 TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3D47=20

ip_gre xmit sends out:

raw:OUTPUT:rule:1 IN=3D OUT=3Deth0 SRC=3Dlo.ca.l.ip DST=3Dre.mo.te.ip L=
EN=3D1372 TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3D47=20
raw:OUTPUT:policy:2 IN=3D OUT=3Deth0 SRC=3Dlo.ca.l.ip DST=3Dre.mo.te.ip=
 LEN=3D1372 TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3D47=20
mangle:OUTPUT:policy:1 IN=3D OUT=3Deth0 SRC=3Dlo.ca.l.ip DST=3Dre.mo.te=
=2Eip LEN=3D1372 TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3D47=20

(nat hook for initial packets)
nat:OUTPUT:policy:1 IN=3D OUT=3Deth0 SRC=3Dlo.ca.l.ip DST=3Dre.mo.te.ip=
 LEN=3D1372 TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3D47=20

filter:OUTPUT:policy:1 IN=3D OUT=3Deth0 SRC=3Dlo.ca.l.ip DST=3Dre.mo.te=
=2Eip LEN=3D1372 TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3D47=20

- Timo
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
