From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Mon, 31 Aug 2009 21:54:49 +0200
Message-ID: <4A9C2A89.9060002@gmail.com>
References: <alpine.DEB.1.10.0908311632170.1507@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@linux-foundation.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55577 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbZHaTzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 15:55:21 -0400
In-Reply-To: <alpine.DEB.1.10.0908311632170.1507@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> This is with 2.6.31-rc7. If I send icmp then its correctly registered=
 as a
> packet by the qdisc layer:
>=20
> #tc -s qdisc show
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 =
1 1 1 1 1 1 1
>  Sent 10491 bytes 72 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
>=20
> #ping yy
> PING yy (10.2.36.120) 56(84) bytes of data.
> 64 bytes from yy (10.2.36.120): icmp_seq=3D1 ttl=3D64 time=3D0.933 ms
> 64 bytes from yy (10.2.36.120): icmp_seq=3D2 ttl=3D64 time=3D0.122 ms
> 64 bytes from yy (10.2.36.120): icmp_seq=3D3 ttl=3D64 time=3D0.119 ms
> ^C
> --- yy ping statistics ---
> 3 packets transmitted, 3 received, 0% packet loss, time 2003ms
> rtt min/avg/max/mdev =3D 0.119/0.391/0.933/0.383 ms
>=20
> #tc -s qdisc show
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 =
1 1 1 1 1 1 1
>  Sent 10839 bytes 75 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
>=20
>=20
> Now I overrun the transmitter with udp multicast traffic:
>=20
> #./mcast -n1 -r400000
> Receiver: Listening to control channel 239.0.192.1
> Receiver: Subscribing to 0 MC addresses 239.0.192-254.2-254 offset 0
> origin 10.2.36.120
> Sender: Sending 400000 msgs/ch/sec on 1 channels. Probe interval=3D0.=
001-1 sec.
> ^C
> Unsubscribing from multicast groups
> Done.
>=20
> #tc -s qdisc show
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 =
1 1 1 1 1 1 1
>  Sent 13359 bytes 101 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
>=20
>=20
> The mcast invocation send over 3 million packets(!) but they are not
> accounted for in the qdisc. 500k of those were lost. Also not counted=
=2E
> The 26 packets receives are likely only covering the ssh session usin=
g
> TCP.
>=20
> Receiver log:
>=20
> yy#./mcast
> Receiver: Listening to control channel 239.0.192.1
> Receiver: Subscribing to 1 MC addresses 239.0.192-254.2-254 offset 0 =
origin 10.2.36.121
>=20
> TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us=
 StdDv
>  3110416 531472  25555 531472  307958     0.0  151.45 1648.21 1875.68=
 499.92
> Unsubscribing from 1 multicast addresses origin 10.2.36.121.
>=20
> What is wrong here? Is UDP bypassing the qdisc layer?
>=20
> Tried UDP unicast with similar effects.


Not reproductible here, I can see bytes/pkts counts increasing while mc=
ast -n1 -r400000 runs.

# tc -s -d qdisc show dev eth0 ; sleep 1 ; tc -s -d qdisc show dev eth0
qdisc pfifo_fast 0: root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1=
 1
 Sent 7694155580 bytes 36894415 pkt (dropped 0, overlimits 0 requeues 2=
)
 rate 0bit 0pps backlog 0b 0p requeues 2
qdisc pfifo_fast 0: root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1=
 1
 Sent 7778853932 bytes 37142071 pkt (dropped 0, overlimits 0 requeues 2=
)
 rate 0bit 0pps backlog 0b 0p requeues 2


Check :

# ip ro=20
# ip ro get 10.2.36.120
# ip ro get 239.0.192.2

maybe your pings do use eth0, and your multicast doesnt.

loopback device do bypass qdisc layer for example...
