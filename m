From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug? GRE tunnel periodically won't transmit some packets
Date: Tue, 08 Nov 2011 15:05:53 +0100
Message-ID: <1320761153.3444.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111108130555.D6FE6361C8@apps0.cs.toronto.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chris Siebenmann <cks@cs.toronto.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65127 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840Ab1KHOF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 09:05:57 -0500
Received: by wyh15 with SMTP id 15so503428wyh.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 06:05:56 -0800 (PST)
In-Reply-To: <20111108130555.D6FE6361C8@apps0.cs.toronto.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 novembre 2011 =C3=A0 08:05 -0500, Chris Siebenmann a =C3=A9=
crit :
> | Le mardi 08 novembre 2011 =C3=A0 02:08 -0500, Chris Siebenmann a =C3=
=A9crit :
> | >  Let me know if you want a full dump of 'ip link show' (with or
> | > without verbosity).
> | >=20
> | > 	- cks
> |=20
> | Oh yes, I meant "ip -s -s link show dev extun"
>=20
> 7: extun: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1200 qdisc noqueue stat=
e UNKNOWN=20
>     link/gre 66.96.18.208 peer 128.100.3.58
>     RX: bytes  packets  errors  dropped overrun mcast  =20
>     3465662    19823    0       0       0       0     =20
>     RX errors: length  crc     frame   fifo    missed
>                0        0       0       0       0     =20
>     TX: bytes  packets  errors  dropped carrier collsns=20
>     2590152    30918    18      0       0       0     =20
>     TX errors: aborted fifo    window  heartbeat
>                0        0       0       0     =20
>=20
> Then:
> | You might have packet drops at the ppp0 device itself
> |=20
> | ip -s -s link show dev ppp0 ; tc -s -d qdisc show dev ppp0
>=20
> ; ip -s -s link show dev ppp0 ; tc -s -d qdisc show dev ppp0
> 5: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1492 qdisc pfi=
fo_fast state UNKNOWN qlen 3
>     link/ppp=20
>     RX: bytes  packets  errors  dropped overrun mcast  =20
>     1065281803 2474545  0       0       0       0     =20
>     RX errors: length  crc     frame   fifo    missed
>                0        0       0       0       0     =20
>     TX: bytes  packets  errors  dropped carrier collsns=20
>     1046103545 2887730  0       0       0       0     =20
>     TX errors: aborted fifo    window  heartbeat
>                0        0       0       0     =20
> qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 =
1 1 1 1 1 1 1
>  Sent 1046103557 bytes 2887727 pkt (dropped 20, overlimits 0 requeues=
 0)=20
>  backlog 0b 0p requeues 0=20
>=20
>  I have now seen 552-byte mtus listed in 'ip route show table cache'
> output. I can include the full output if you think it's of interest.
> One of the remote IPs is a host we run, so I was able to test ssh to =
it
> and it did not stall and did not seem to use 'length 500' packets in =
the
> SSH connection, so this may be a red herring.
>=20
> Okay, I just rebooted the machine (into the Fedora 15 kernel) and had
> the problem reproduce. This time ppp0 shows no dropped packets while
> extun counts up errors and I have a 552 mtu route (actually several o=
f
> them) in 'ip route show table cache':
>=20
> 6: extun: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1200 qdisc noqueue stat=
e UNKNOWN=20
>     link/gre 66.96.18.208 peer 128.100.3.58
>     RX: bytes  packets  errors  dropped overrun mcast  =20
>     119000     653      0       0       0       0     =20
>     RX errors: length  crc     frame   fifo    missed
>                0        0       0       0       0     =20
>     TX: bytes  packets  errors  dropped carrier collsns=20
>     85848      989      17      0       0       0     =20
>     TX errors: aborted fifo    window  heartbeat
>                0        0       0       0     =20
>=20
> 4: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1492 qdisc pfi=
fo_fast state UNKNOWN qlen 3
>     link/ppp=20
>     RX: bytes  packets  errors  dropped overrun mcast  =20
>     2152137    3743     0       0       0       0     =20
>     RX errors: length  crc     frame   fifo    missed
>                0        0       0       0       0     =20
>     TX: bytes  packets  errors  dropped carrier collsns=20
>     360478     4022     0       0       0       0     =20
>     TX errors: aborted fifo    window  heartbeat
>                0        0       0       0     =20
> qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 =
1 1 1 1 1 1 1
>  Sent 360438 bytes 4018 pkt (dropped 0, overlimits 0 requeues 0)=20
>  backlog 0b 0p requeues 0=20
>=20
> Routes with low mtus for either the GRE gateway target or the host I =
am
> trying to ssh to:
>=20
> 128.100.3.51 dev extun  src 128.100.3.52=20
>     cache  expires 401sec ipid 0x941a mtu 552 rtt 27ms rttvar 27ms cw=
nd 10
> --
> 128.100.3.58 from 128.100.3.52 dev extun=20
>     cache  expires 397sec ipid 0xdeda mtu 614 rtt 15ms rttvar 15ms cw=
nd 10
> --
> 128.100.3.58 from 66.96.18.208 dev ppp0=20
>     cache  expires 397sec ipid 0xdeda mtu 614 rtt 15ms rttvar 15ms cw=
nd 10
> --
> 128.100.3.58 from 66.96.18.208 dev ppp0=20
>     cache  expires 397sec ipid 0xdeda mtu 614 rtt 15ms rttvar 15ms cw=
nd 10
> --
> 128.100.3.51 from 128.100.3.52 dev extun=20
>     cache  expires 401sec ipid 0x941a mtu 552 rtt 27ms rttvar 27ms cw=
nd 10
> 128.100.3.58 dev extun  src 128.100.3.52=20
>     cache  expires 397sec ipid 0xdeda mtu 614 rtt 15ms rttvar 15ms cw=
nd 10
> --
> 128.100.3.51 from 128.100.3.52 tos throughput dev extun=20
>     cache  expires 401sec ipid 0x941a mtu 552 rtt 27ms rttvar 27ms cw=
nd 10
> 128.100.3.51 from 128.100.3.52 dev extun=20
>     cache  expires 401sec ipid 0x941a mtu 552 rtt 27ms rttvar 27ms cw=
nd 10
> 128.100.3.51 from 128.100.3.52 tos lowdelay dev extun=20
>     cache  expires 401sec ipid 0x941a mtu 552 rtt 27ms rttvar 27ms cw=
nd 10
>=20
>  With the problem not happening any more, 'ip route' shows only a few
> mtu 552 routes, none to the machines I am doing test ssh's to. The fi=
nal
> error count was 46 errors on extun (with 0 for all of the specific
> causes) and no errors or dropped packets on ppp0.
>=20

So it appears the drop is in gre xmit because frame is bigger than
mtu...

Maybe you receive some strange ICMP (ICMP_FRAG_NEEDED) from a buggy
host ?

You could catch it with "tcpdump -s 1000 -i any icmp" maybe...
