From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problem with tcp (2.6.31) as first, http://bugzilla.kernel.org/show_bug.cgi?id=14580
Date: Fri, 27 Nov 2009 12:48:05 +0100
Message-ID: <4B0FBC75.5060000@gmail.com>
References: <alpine.LNX.1.10.0911251626500.13662@bizon.gios.gov.pl> <4B0D83E8.3000009@gmail.com> <4B0D86BD.4010902@ans.pl> <4B0D8EC6.9050204@gmail.com> <4B0D8FB2.1060606@ans.pl> <4B0E1D1C.30000@gmail.com> <4B0E6D50.1020906@ans.pl> <4B0EAC4F.3080202@gmail.com> <alpine.LNX.1.10.0911261749100.16993@bizon.gios.gov.pl> <4B0EE958.7090607@gmail.com> <4B0EECE5.5050406@ans.pl> <4B0EEF76.1070803@gmail.com> <4B0EF273.4030003@gmail.com> <alpine.DEB.2.00.0911262327130.24189@melkinpaasi.cs.helsinki.fi> <4B0F0466.8080006@gmail.com> <alpine.LNX.1.10.0911271013330.24080@bizon.gios.gov.pl> <alpine.DEB.2.00.0911271246030.2459@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Krzysztof Oledzki <ole@ans.pl>, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>
To: =?ISO-8859-2?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36864 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbZK0LsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 06:48:17 -0500
In-Reply-To: <alpine.DEB.2.00.0911271246030.2459@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen a =E9crit :

> What would you expect to happen? If out-of-window stuff arrives we se=
nd=20
> dupacks. If we would send resets, that would introduce blind rst atta=
cks.
> In theory we might be able to quench the loop by using pingpong thing=
 but=20
> that needs very careful thought in order to not introduce other probl=
ems,
> and even then your connections will not be re-usable until either end=
=20
> times out so the gain is rather limited. We simply cannot rst the=20
> connection, that's not an option.
>=20
> I find this problem simply stem from the introduced loss of end-to-en=
d=20
> connectivity. Would you really "lose" that server so that its TCP sta=
te is=20
> not maintained, you'd get resets etc (crash, scheduled reboot or=20
> whatever). Only real solution would be a kill switch for TCP connecti=
on=20
> when you break e-2-e connectivity (ie., switch servers so that the sa=
me IP=20
> is reacquired by somebody else). In theory you can "simulate" the kil=
l=20
> switch by setting tcp_retries sysctls to small values to make the=20
> connections to timeout much faster, but still that might not be enoug=
h for=20
> you (and has other implications you might not like).=20
>

RST is not an option, sure, but ACK storms are unlikely good things too=
=2E


Could'nt we do something smart in presence of tcp timestamps ?

11:23:27.669910 IP 192.168.20.110.3434 > 192.168.200.200.333: . ack 245=
7299512 win 92 <nop,nop,timestamp 42408589 1506086404>
11:23:27.669991 IP 192.168.200.200.333 > 192.168.20.110.3434: . ack 116=
87 win 91 <nop,nop,timestamp 1704614538 42406583>
11:23:27.670000 IP 192.168.20.110.3434 > 192.168.200.200.333: . ack 245=
7299512 win 92 <nop,nop,timestamp 42408589 1506086404>
11:23:27.670093 IP 192.168.200.200.333 > 192.168.20.110.3434: . ack 116=
87 win 91 <nop,nop,timestamp 1704614538 42406583>
11:23:27.670099 IP 192.168.20.110.3434 > 192.168.200.200.333: . ack 245=
7299512 win 92 <nop,nop,timestamp 42408589 1506086404>
11:23:27.670175 IP 192.168.200.200.333 > 192.168.20.110.3434: . ack 116=
87 win 91 <nop,nop,timestamp 1704614538 42406583>
11:23:27.670183 IP 192.168.20.110.3434 > 192.168.200.200.333: . ack 245=
7299512 win 92 <nop,nop,timestamp 42408589 1506086404>
11:23:27.670268 IP 192.168.200.200.333 > 192.168.20.110.3434: . ack 116=
87 win 91 <nop,nop,timestamp 1704614538 42406583>
11:23:27.670276 IP 192.168.20.110.3434 > 192.168.200.200.333: . ack 245=
7299512 win 92 <nop,nop,timestamp 42408589 1506086404>
11:23:27.670359 IP 192.168.200.200.333 > 192.168.20.110.3434: . ack 116=
87 win 91 <nop,nop,timestamp 1704614538 42406583>
11:23:27.670368 IP 192.168.20.110.3434 > 192.168.200.200.333: . ack 245=
7299512 win 92 <nop,nop,timestamp 42408589 1506086404>


Or we could=20

Count number N of strange/bad acks we received from peer.

- At first one, send our ACK immediately

- For following, delay our ACK answer by N*100 ms, to reduce the flood.
(or if we have data in flight, only rely on retransmit timer and not se=
nding acks)
