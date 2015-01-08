From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is
 received
Date: Thu, 08 Jan 2015 07:59:32 -0800
Message-ID: <1420732772.5947.56.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
	 <1420729656.5947.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54AEA11A.1000603@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: =?ISO-8859-1?Q?S=E9bastien_Barr=E9?= <sebastien.barre@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:52108 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877AbbAHP7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:59:34 -0500
Received: by mail-ig0-f175.google.com with SMTP id h15so3424112igd.2
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 07:59:34 -0800 (PST)
In-Reply-To: <54AEA11A.1000603@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-08 at 16:24 +0100, S=C3=A9bastien Barr=C3=A9 wrote:
> Hi Eric,
>=20
> Le 08/01/2015 16:07, Eric Dumazet a =C3=A9crit :
> >
> >>   In the current code,
> >> such ACK+DSACK will be missed and only at next, higher ack will th=
e TLP
> >> episode be considered done. Since the DSACK is not present anymore=
,
> >> this will cost a cwnd reduction.
> >>
> >> This patch ensures that this scenario does not cause a cwnd reduct=
ion, since
> >> receiving an ACK+DSACK indicates that both the initial segment and=
 the probe
> >> have been received by the peer.
> > Do you have at hand a packetdrill test to demonstrate that the patc=
h
> > works ?
> Not currently, but that would be very good indeed.
> I will prepare one and send it.

Here is a skeleton you might adapt :

// TLP test when a sender does not have any new segments for transmissi=
on.
// In the absence of ACKs, the sender retransmits an old segment as a p=
robe
// after 2 RTTs.

// Tolerate RTO variations
--tolerance_usecs=3D15000

// Set up production config.
`../common/defaults.sh
sysctl -q net.ipv4.tcp_early_retrans=3D3
`

// Establish a connection.
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) =3D 3
0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
0.000 bind(3, ..., ...) =3D 0
0.000 listen(3, 1) =3D 0

0.100  < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
+0     > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 6>
+0.100 < . 1:1(0) ack 1 win 257
+0     accept(3, ..., ...) =3D 4

// Send 10 MSS.
+0.100 write(4, ..., 10000) =3D 10000
+0 > . 1:5001(5000) ack 1
+0 > P. 5001:10001(5000) ack 1

// TLP retransmission in 2 RTTs.
+0.200 > P. 9001:10001(1000) ack 1
+0 %{
assert tcpi_snd_cwnd =3D=3D 10, 'tcpi_snd_cwnd=3D%d' % tcpi_snd_cwnd
assert tcpi_unacked =3D=3D 10
}%

+0.100 < . 1:1(0) ack 10001 win 257 <sack 9001:1001,nop,nop>

+0 %{
assert tcpi_snd_cwnd =3D=3D 20, 'tcpi_snd_cwnd=3D%d' % tcpi_snd_cwnd
assert tcpi_unacked =3D=3D 0, 'tcpi_unacked=3D%d' % tcpi_unacked
}%
