From: =?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: bad nat connection tracking performance with ip_gre
Date: Tue, 18 Aug 2009 15:45:07 +0300
Message-ID: <4A8AA253.8090300@iki.fi>
References: <4A8A7F14.3010103@iki.fi> <4A8A84AF.7050901@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:43336 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756526AbZHRMpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 08:45:09 -0400
In-Reply-To: <4A8A84AF.7050901@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Timo Ter=E4s wrote:
>> However, if a local process on the router box is sending
>> packets that go to gre tunnel, each packet causes a new
>> lookup on nat table OUTPUT chain. This is easily verified
>> by doing flood ping on router box on private IP and the
>> counters on nat table OUTPUT chain default policy start
>> to get incremented wildly.

So ping test is not good as the connection tracking entry
is apparently removed once ICMP reply is received.

The one way to reliably to reproduce this is when I'm
sending packets with sendto() from user-land to nbma gre=20
tunnel and specifying the nbma ip address.

>> Monitoring the connection tracking stats, it looks like
>> all packets are reusing the proper connection tracking
>> cache entry. But somehow the nat target still gets
>> called for the locally originating packets to gre.
>>
>> Any ideas how to fix this?
>=20
> Please use the TRACE target in raw/OUTPUT to trace the flow of
> packets through the netfilter hooks:
>=20
> modprobe ipt_LOG
> iptables -t raw -A OUTPUT -j TRACE

=46ORWARDED PACKET, does not hog CPU
----------------------------------

IN=3Deth1 OUT=3D MAC=3Dx:x:x:x:x SRC=3D10.252.5.10 DST=3D239.255.12.42
LEN=3D1428 TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D31320 DF PROTO=3DUDP
SPT=3D34757 DPT=3D50002 LEN=3D1408
	1. mangle:INPUT
	2. filter:INPUT
	3. raw:PREROUTING
	4. mangle:PREROUTING

Next it turns it to GRE encapsulated packet like:

IN=3Deth1 OUT=3Dgre1 SRC=3D0.0.0.0 DST=3Dre.mo.te.ip LEN=3D0
TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3D47
	1. mangle:FORWARD
	2. filter:FORWARD

Gets proper SRC and LEN at this point and:
	1. raw:OUTPUT
	2. mangle:OUTPUT
	3. nat:OUTPUT
	4. filter:OUTPUT

LOCALLY GENERATED PACKET, hogs CPU
----------------------------------

IN=3D OUT=3Deth1 SRC=3D10.252.5.1 DST=3D239.255.12.42 LEN=3D1344
TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D41664 DF PROTO=3DUDP SPT=3D47920
DPT=3D1234 LEN=3D1324 UID=3D1007 GID=3D1007
	1. raw:OUTPUT
	2. mangle:OUTPUT
	3. filter:OUTPUT
	4. mangle:POSTROUTING

Picked up by multicast routing.

IN=3Deth1 OUT=3D MAC=3D SRC=3D10.252.5.1 DST=3D239.255.12.42 LEN=3D1344
TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D41664 DF PROTO=3DUDP SPT=3D47920
DPT=3D1234 LEN=3D1324
	1. raw:PREROUTING
	2. mangle:PREROUTING

=46orwarded to GRE tunnel.

IN=3Deth1 OUT=3Dgre1 SRC=3D0.0.0.0 DST=3Dre.mo.te.ip LEN=3D0 TOS=3D0x00
PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3D47
	1. mangle:FORWARD
	2. filter:FORWARD

Apparently GRE xmit code fixes it to:

IN=3D OUT=3Deth0 SRC=3Dmy.pub.lic.ip DST=3Dre.mo.te.ip LEN=3D1372 TOS=3D=
0x00
PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3D47
	1. raw:OUTPUT
	2. mangle:OUTPUT

---

It's starting to smell like ip_gre problem. ipgre_header() seems
to set only the destination IP address. And that probably confuses
the connection tracking code for locally originating packets.

I suppose we should construct almost full IP header in ipgre_header().

- Timo

