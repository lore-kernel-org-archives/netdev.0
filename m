From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.34: Problem with UDP traffic on lo + poll(?)
Date: Wed, 08 Sep 2010 06:12:40 +0200
Message-ID: <1283919160.2634.662.camel@edumazet-laptop>
References: <alpine.LNX.1.10.1009061745280.20113@bizon.gios.gov.pl>
	 <1283802132.2585.4.camel@edumazet-laptop>  <4C854737.5040503@ans.pl>
	 <1283804955.2585.12.camel@edumazet-laptop> <4C8552B1.8020806@ans.pl>
	 <4C855385.7030203@ans.pl>  <4C865C21.5010803@ans.pl>
	 <1283877391.2313.62.camel@edumazet-laptop>
	 <1283887569.2634.95.camel@edumazet-laptop>  <4C86AE96.40704@ans.pl>
	 <1283895544.2634.256.camel@edumazet-laptop>  <4C86B3C6.7040809@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Krzysztof =?UTF-8?Q?Ol=C4=99dzki?= <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51485 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab0IHEMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 00:12:46 -0400
Received: by fxm16 with SMTP id 16so494009fxm.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 21:12:45 -0700 (PDT)
In-Reply-To: <4C86B3C6.7040809@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 septembre 2010 =C3=A0 23:51 +0200, Krzysztof Ol=C4=99dzki a=
 =C3=A9crit :
> On 2010-09-07 23:39, Eric Dumazet wrote:
> > Le mardi 07 septembre 2010 =C3=A0 23:28 +0200, Krzysztof Ol=C4=99dz=
ki a =C3=A9crit :
> >=20
> >> With the above patch I'm no longer able to reproduce the problem. =
Thanks!
> >>
> >> Tested-by: Krzysztof Piotr Oledzki<ole@ans.pl>
> >>
> >=20
> > Thanks a lot !
> >=20
> >> BTW: why it takes so long to trigger this bug and it is only possi=
ble
> >> over a loopback interface?
> >=20
> > Its a bit tricky : You need at least 10 sockets linked in a particu=
lar
> > hash chain.
> >=20
> > To check this, you can :
> >=20
> > cat /proc/net/udp
> >=20
> > maybe you have many sockets on port 123 or 53 ?
>=20
> On one affected host I have 3+7 and on the other, also affacted one, =
I have 3+6:
>=20
> root@sowa:~# egrep -cw '(53|123):' /proc/net/udp
> 10
> root@sowa:~# egrep -w '(53|123):' /proc/net/udp
>    53: 3582A8C0:0035 00000000:0000 07 00000000:00000000 00:00000000 0=
0000000     0        0 6084654 2 ffff8800cc012700 0
>    53: 0100007F:0035 00000000:0000 07 00000000:00000000 00:00000000 0=
0000000     0        0 6084652 2 ffff8800cc010900 0
>   123: D683A8C0:007B 00000000:0000 07 00000000:00000000 00:00000000 0=
0000000     0        0 4911 2 ffff88012de96400 0
>   123: 7B85A8C0:007B 00000000:0000 07 00000000:00000000 00:00000000 0=
0000000     0        0 4910 2 ffff88012de96100 0
>   123: 8982A8C0:007B 00000000:0000 07 00000000:00000000 00:00000000 0=
0000000     0        0 4909 2 ffff88012de95e00 0
>   123: 7B82A8C0:007B 00000000:0000 07 00000000:00000000 00:00000000 0=
0000000     0        0 4908 2 ffff88012de95b00 0
>   123: 3582A8C0:007B 00000000:0000 07 00000000:00000000 00:00000000 0=
0000000     0        0 4907 2 ffff88012de95800 0
>   123: 1F7EA8C0:007B 00000000:0000 07 00000000:00000000 00:00000000 0=
0000000     0        0 4906 2 ffff88012de95500 0
>   123: 0100007F:007B 00000000:0000 07 00000000:00000000 00:00000000 0=
0000000     0        0 4905 2 ffff88012de95200 0
>   123: 00000000:007B 00000000:0000 07 00000000:00000000 00:00000000 0=
0000000     0        0 4899 2 ffff88012de94c00 0
>=20
> But how 123 is related to 53?
>=20

I was mentioning 123 or 53, as probable suspects :)


When a socket is created, and connect() called, autobind() chooses a
source port X for this socket.=20

if ((X % udp_hash_size) =3D=3D 123), socket is inserted in hash chain n=
umber
123.

Bug then triggers, because when a packet is received for this socket, w=
e
find a slot with more than 10 sockets -> Search is done on secondary
chain Z2, where we dont find the socket since its rcv_addr changed afte=
r
we inserted it (in chain Y2). Packet is dropped (as seen in netstat -s)


> > And about loopback, I have no idea... I am pretty sure I can trigge=
r the
> > bug with other interfaces.
>=20
> OK. Probably it is because my other hosts have only a single IP and o=
nly
> the problematic ones have both DNS server and multiple IP (many socke=
ts).
>=20

Yes


