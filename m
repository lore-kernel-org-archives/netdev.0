From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: Fix CWV being too strict on thin
 streams
Date: Wed, 23 Sep 2015 11:05:10 -0700
Message-ID: <1443031510.29850.123.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443026993-12358-1-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>, netdev@vger.kernel.org,
	Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad
	<bro.devel+kernel@gmail.com>, Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Mads Johannessen <madsjoh@ifi.uio.no>
To: Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33175 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbbIWSFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 14:05:12 -0400
Received: by pacex6 with SMTP id ex6so46898610pac.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 11:05:12 -0700 (PDT)
In-Reply-To: <1443026993-12358-1-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-23 at 18:49 +0200, Bendik R=C3=B8nning Opstad wrote:
> Application limited streams such as thin streams, that transmit small
> amounts of payload in relatively few packets per RTT, can be prevente=
d
> from growing the CWND when in congestion avoidance. This leads to
> increased sojourn times for data segments in streams that often trans=
mit
> time-dependent data.
>=20
> Currently, a connection is considered CWND limited only after having
> successfully transmitted at least one packet with new data, while at =
the
> same time failing to transmit some unsent data from the output queue
> because the CWND is full. Applications that produce small amounts of
> data may be left in a state where it is never considered to be CWND
> limited, because all unsent data is successfully transmitted each tim=
e
> an incoming ACK opens up for more data to be transmitted in the send
> window.
>=20
> Fix by always testing whether the CWND is fully used after successful
> packet transmissions, such that a connection is considered CWND limit=
ed
> whenever the CWND has been filled. This is the correct behavior as
> specified in RFC2861 (section 3.1).
>=20
> Cc: Andreas Petlund <apetlund@simula.no>
> Cc: Carsten Griwodz <griff@simula.no>
> Cc: Jonas Markussen <jonassm@ifi.uio.no>
> Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
> Cc: Mads Johannessen <madsjoh@ifi.uio.no>
> Signed-off-by: Bendik R=C3=B8nning Opstad <bro.devel+kernel@gmail.com=
>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Tested-by: Eric Dumazet <edumazet@google.com>

Tested with following packetdrill script :

// Establish a connection and send 1 MSS.
0     socket(..., SOCK_STREAM, IPPROTO_TCP) =3D 3
   +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
   +0 setsockopt(3, SOL_TCP, TCP_NODELAY, [1], 4) =3D 0
   +0 setsockopt(3, IPPROTO_TCP, TCP_CONGESTION, "reno", 4) =3D 0
   +0 bind(3, ..., ...) =3D 0
   +0 listen(3, 1) =3D 0

   +0 < S 0:0(0) win 65535 <mss 1000,sackOK,nop,nop>
   +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK>
+.200 < . 1:1(0) ack 1 win 65535
   +0 accept(3, ..., ...) =3D 4

   +0 write(4, ..., 100) =3D 100
   +0 > P. 1:101(100) ack 1
+.000 %{ print  tcpi_rto }%

// TLP
+.500~+.505 > P. 1:101(100) ack 1
// RTO
+.600~+.605 > P. 1:101(100) ack 1

+.200 < . 1:1(0) ack 101 win 65535
// cwnd should be 2, ssthresh should be 7
+0 %{ print "tcpi_snd_cwnd=3D%d tcpi_snd_ssthresh=3D%d" % (tcpi_snd_cwn=
d, tcpi_snd_ssthresh) }%
2.000 write(4, ..., 100) =3D 100
   +0  > P. 101:201(100) ack 1

// TLP
+.500~+.505 > P. 101:201(100) ack 1
+0 %{ print "tcpi_snd_cwnd=3D%d tcpi_snd_ssthresh=3D%d" % (tcpi_snd_cwn=
d, tcpi_snd_ssthresh) }%
// RTO
+1.200~+1.210 > P. 101:201(100) ack 1

+0 %{ print "tcpi_snd_cwnd=3D%d tcpi_snd_ssthresh=3D%d" % (tcpi_snd_cwn=
d, tcpi_snd_ssthresh) }%
+.200 < . 1:1(0) ack 201 win 65535

4.00 write(4, ..., 100) =3D 100
    +0  > P. 201:301(100) ack 1
4.01 write(4, ..., 100) =3D 100
	+0 > P. 301:401(100) ack 1
4.02 write(4, ..., 100) =3D 100
4.03 write(4, ..., 100) =3D 100
4.04 write(4, ..., 100) =3D 100
4.05 write(4, ..., 100) =3D 100
4.06 write(4, ..., 100) =3D 100
4.07 write(4, ..., 100) =3D 100
4.08 write(4, ..., 100) =3D 100
4.09 write(4, ..., 100) =3D 100
4.10 write(4, ..., 100) =3D 100
4.11 write(4, ..., 100) =3D 100
4.12 write(4, ..., 100) =3D 100
4.13 write(4, ..., 100) =3D 100
4.14 write(4, ..., 100) =3D 100
4.15 write(4, ..., 100) =3D 100
4.16 write(4, ..., 100) =3D 100
4.17 write(4, ..., 100) =3D 100
4.18 write(4, ..., 100) =3D 100
4.19 write(4, ..., 100) =3D 100

4.20 write(4, ..., 100) =3D 100
4.20 < . 1:1(0) ack 301 win 65535
4.20 > . 401:1401(1000) ack 1

4.21 write(4, ..., 100) =3D 100
4.21 < . 1:1(0) ack 401 win 65535
4.21 > P. 1401:2401(1000) ack 1
   +0 %{ print "tcpi_snd_cwnd=3D%d tcpi_snd_ssthresh=3D%d" % (tcpi_snd_=
cwnd, tcpi_snd_ssthresh) }%
4.22 write(4, ..., 100) =3D 100
4.22 > P. 2401:2501(100) ack 1
4.23 write(4, ..., 100) =3D 100
4.24 write(4, ..., 100) =3D 100
4.25 write(4, ..., 100) =3D 100
4.26 write(4, ..., 100) =3D 100
4.27 write(4, ..., 100) =3D 100
4.28 write(4, ..., 100) =3D 100
4.29 write(4, ..., 100) =3D 100
4.31 write(4, ..., 100) =3D 100
4.32 write(4, ..., 100) =3D 100
4.33 write(4, ..., 100) =3D 100
4.34 write(4, ..., 100) =3D 100
4.35 write(4, ..., 100) =3D 100
4.36 write(4, ..., 100) =3D 100
4.37 write(4, ..., 100) =3D 100
4.38 write(4, ..., 100) =3D 100
4.39 write(4, ..., 100) =3D 100

4.40 write(4, ..., 100) =3D 100
4.40 < . 1:1(0) ack 1401 win 65535
4.40 > . 2501:3501(1000) ack 1
4.41 write(4, ..., 100) =3D 100
4.41 < . 1:1(0) ack 2401 win 65535
4.41 > P. 3501:4301(800) ack 1
   +0 %{ print "tcpi_snd_cwnd=3D%d tcpi_snd_ssthresh=3D%d" % (tcpi_snd_=
cwnd, tcpi_snd_ssthresh) }%
4.42 write(4, ..., 100) =3D 100
4.43 write(4, ..., 100) =3D 100
4.44 write(4, ..., 100) =3D 100
4.45 write(4, ..., 100) =3D 100
4.46 write(4, ..., 100) =3D 100
4.47 write(4, ..., 100) =3D 100
4.48 write(4, ..., 100) =3D 100
4.49 write(4, ..., 100) =3D 100
4.50 write(4, ..., 100) =3D 100
4.51 write(4, ..., 100) =3D 100
4.52 write(4, ..., 100) =3D 100
4.53 write(4, ..., 100) =3D 100
4.54 write(4, ..., 100) =3D 100
4.55 write(4, ..., 100) =3D 100
4.56 write(4, ..., 100) =3D 100
4.57 write(4, ..., 100) =3D 100
4.58 write(4, ..., 100) =3D 100
4.59 write(4, ..., 100) =3D 100
4.60 write(4, ..., 100) =3D 100
4.60 < . 1:1(0) ack 3401 win 65535
4.60 > P. 4301:6201(1900) ack 1
4.61 write(4, ..., 100) =3D 100
4.61 < . 1:1(0) ack 4301 win 65535
   +0 %{ print "tcpi_snd_cwnd=3D%d tcpi_snd_ssthresh=3D%d" % (tcpi_snd_=
cwnd, tcpi_snd_ssthresh) }%
4.61 > P. 6201:6301(100) ack 1
4.62 write(4, ..., 100) =3D 100
4.62 > P. 6301:6401(100) ack 1
4.63 write(4, ..., 100) =3D 100
4.64 write(4, ..., 100) =3D 100
4.65 write(4, ..., 100) =3D 100
4.66 write(4, ..., 100) =3D 100
4.67 write(4, ..., 100) =3D 100
4.68 write(4, ..., 100) =3D 100
4.69 write(4, ..., 100) =3D 100
4.70 write(4, ..., 100) =3D 100
4.71 write(4, ..., 100) =3D 100
4.72 write(4, ..., 100) =3D 100
4.73 write(4, ..., 100) =3D 100
4.74 write(4, ..., 100) =3D 100
4.75 write(4, ..., 100) =3D 100
4.76 write(4, ..., 100) =3D 100
4.77 write(4, ..., 100) =3D 100
4.78 write(4, ..., 100) =3D 100
4.79 write(4, ..., 100) =3D 100
4.80 write(4, ..., 100) =3D 100
4.80 < . 1:1(0) ack 5301 win 65535
4.80 > . 6401:7401(1000) ack 1
4.81 write(4, ..., 100) =3D 100
4.81 < . 1:1(0) ack 6301 win 65535
   +0 %{ print "tcpi_snd_cwnd=3D%d tcpi_snd_ssthresh=3D%d" % (tcpi_snd_=
cwnd, tcpi_snd_ssthresh) }%
4.81 > P. 7401:8301(900) ack 1
4.82 write(4, ..., 100) =3D 100
4.82 > P. 8301:8401(100) ack 1
4.83 write(4, ..., 100) =3D 100
4.83 > P. 8401:8501(100) ack 1
4.84 write(4, ..., 100) =3D 100
4.85 write(4, ..., 100) =3D 100
4.86 write(4, ..., 100) =3D 100
4.87 write(4, ..., 100) =3D 100
4.88 write(4, ..., 100) =3D 100
4.89 write(4, ..., 100) =3D 100
4.90 write(4, ..., 100) =3D 100
4.91 write(4, ..., 100) =3D 100
4.92 write(4, ..., 100) =3D 100
4.93 write(4, ..., 100) =3D 100
4.94 write(4, ..., 100) =3D 100
4.95 write(4, ..., 100) =3D 100
4.96 write(4, ..., 100) =3D 100
4.97 write(4, ..., 100) =3D 100
4.98 write(4, ..., 100) =3D 100
4.99 write(4, ..., 100) =3D 100
5.00 write(4, ..., 100) =3D 100
5.00 < . 1:1(0) ack 7301 win 65535
5.00 > . 8501:9501(1000) ack 1=20
5.01 write(4, ..., 100) =3D 100
5.01 < . 1:1(0) ack 8301 win 65535
5.01 > P. 9501:10301(800) ack 1
  +0 %{ print "tcpi_snd_cwnd=3D%d tcpi_snd_ssthresh=3D%d" % (tcpi_snd_c=
wnd, tcpi_snd_ssthresh) }%
5.02 write(4, ..., 100) =3D 100
5.02 > P. 10301:10401(100) ack 1
5.03 write(4, ..., 100) =3D 100
5.04 write(4, ..., 100) =3D 100
5.05 write(4, ..., 100) =3D 100
5.06 write(4, ..., 100) =3D 100
5.07 write(4, ..., 100) =3D 100
5.08 write(4, ..., 100) =3D 100
5.09 write(4, ..., 100) =3D 100
5.10 write(4, ..., 100) =3D 100
5.11 write(4, ..., 100) =3D 100
5.12 write(4, ..., 100) =3D 100
5.13 write(4, ..., 100) =3D 100
5.14 write(4, ..., 100) =3D 100
5.15 write(4, ..., 100) =3D 100
5.16 write(4, ..., 100) =3D 100
5.17 write(4, ..., 100) =3D 100
5.18 write(4, ..., 100) =3D 100
5.19 write(4, ..., 100) =3D 100
5.20 write(4, ..., 100) =3D 100
5.20 < . 1:1(0) ack 9301 win 65535
5.20 > P. 10401:12201(1800) ack 1=20
+0 %{ print "tcpi_snd_cwnd=3D%d tcpi_snd_ssthresh=3D%d" % (tcpi_snd_cwn=
d, tcpi_snd_ssthresh) }%

Result :

601000
tcpi_snd_cwnd=3D2 tcpi_snd_ssthresh=3D5
tcpi_snd_cwnd=3D2 tcpi_snd_ssthresh=3D5
tcpi_snd_cwnd=3D1 tcpi_snd_ssthresh=3D2
tcpi_snd_cwnd=3D3 tcpi_snd_ssthresh=3D2
tcpi_snd_cwnd=3D3 tcpi_snd_ssthresh=3D2
tcpi_snd_cwnd=3D4 tcpi_snd_ssthresh=3D2
tcpi_snd_cwnd=3D5 tcpi_snd_ssthresh=3D2
tcpi_snd_cwnd=3D5 tcpi_snd_ssthresh=3D2
tcpi_snd_cwnd=3D6 tcpi_snd_ssthresh=3D2
