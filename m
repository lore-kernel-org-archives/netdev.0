From: Stas Sergeev <stsp@list.ru>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 29 Dec 2015 15:43:44 +0300
Message-ID: <56828000.9040703@list.ru>
References: <5682665A.7090102@list.ru> <20151229115821.GA9352@oracle.com>
 <56827759.8020605@list.ru> <20151229123229.GA22743@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback3.mail.ru ([94.100.181.189]:50403 "EHLO
	fallback3.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392AbbL2Mva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 07:51:30 -0500
Received: from smtp10.mail.ru (smtp10.mail.ru [94.100.181.92])
	by fallback3.mail.ru (mPOP.Fallback_MX) with ESMTP id 152E2167FCEDF
	for <netdev@vger.kernel.org>; Tue, 29 Dec 2015 15:43:55 +0300 (MSK)
In-Reply-To: <20151229123229.GA22743@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

29.12.2015 15:32, Sowmini Varadhan =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On (12/29/15 15:06), Stas Sergeev wrote:
>> Router on 192.168.8.1 is just a PC with ubuntu, w/o any special
>> software. I'd be very surprised if it does so. As I understand,
>> linux would accept such ICMP redirect only from the router, or
>> could someone else also send them?
>=20
> If someone elase can spoof redirects on your network, you have
> a much bigger network management problem- at that point, how can you
> trust anything, e.g., a default rdisc rtradv?
Well, I have /proc/sys/net/ipv4/conf/all/secure_redirects set to 1,
so it should be a router I suppose. But this is strange and I wonder
why does it do so very rarely (but that's something for me to investiga=
te).

>> But what worries me more, is the question:
>> Should the linux kernel really silently accept those, breaking
>> the routing in a completely unexpected ways? Isn't it a bug?
>=20
> How is the receiver supposed to know that the redirect was "bad"?
>=20
> In your example, you claimed that
>=20
> a "good" redirect was:
>      ip route get 91.189.89.237
>      91.189.89.237 via 192.168.8.1 dev eth0  src 192.168.10.202
>          cache
>=20
> but a "bad" one was:
>=20
>     ip route get 91.189.89.238
>     91.189.89.238 via 192.168.0.1 dev eth0  src 192.168.10.202
>         cache <redirected>
>=20
> Its not clear to me what the netmask on eth0 is - is this a /16
But I demonstrated the netmask in a very first posting, and here it is:

ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:50:43:00:0b:e0
          inet addr:192.168.10.202  Bcast:192.168.11.255  Mask:255.255.=
252.0


> (in which case both redirs are "good" as far as the receiver can tell=
)?
> Are the 2 gws also on a /16? or something longer?
Yes, the problem is exactly that: the mask is longer.
So the route is bad, and the packets are routed to the "lo"
interface instead - I checked that with tcpdump.

>> The sanity check against netmask looks trivial, so why it is not the=
re?
>=20
> According to rfc1812 (pg 82-84)
>=20
>    Routers MUST NOT generate a Redirect Message unless all the follow=
ing
>    conditions are met:
>=20
>    o The packet is being forwarded out the same physical interface th=
at
>       it was received from,
>=20
>    o The IP source address in the packet is on the same Logical IP
>       (sub)network as the next-hop IP address, and
>=20
>    o The packet does not contain an IP source route option.
>=20
> The second condition seems to have been violated by the router. I=20
> suppose it might not hurt if the receiver can do some sanity checking
> on the redirect but this might not eliminate every error, since
> it might not be possible to detect netmask mismatch in every case.
Not sure what case you mean, but at least as simple error as I am
having, should be possible to detect.
