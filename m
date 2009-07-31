From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Bandwidth of NIC bonding/trunking
Date: Fri, 31 Jul 2009 10:29:43 -0700
Message-ID: <5643.1249061383@death.nxdomain.ibm.com>
References: <869c36e20907310640m41163a2j57198d8ea5e91ba0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Sumedha Gupta <2sumedha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:50287 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751318AbZGaR3m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2009 13:29:42 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n6VHXOlM028400
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2009 13:33:24 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n6VHThUi228334
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2009 13:29:43 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6VHTgko020271
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2009 13:29:42 -0400
In-reply-to: <869c36e20907310640m41163a2j57198d8ea5e91ba0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sumedha Gupta <2sumedha@gmail.com> wrote:

>I configured bonding/trunking on a Netgear GS724TR switch. I am using
>a 4-port NIC card using=C2=A0Intel Corporation 82571EB ethernet contro=
ller
>on machine X with all four ports connected to the switch. There are
>four client machines (A, B, C, D) also connected to the switch.
>iperf is running on machine X as a server and machines A, B, C, D are
>running as iperf clients:

	A lot of this is explained in the bonding.txt documentation that
comes with the kernel source; there's probably more detail there on som=
e
of this.

>With round robin, I consistently get:
>=C2=A0Interval =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Transfer =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 Bandwidth
>=C2=A00.0-10.0 sec =C2=A0 =C2=A0992 MBytes =C2=A0 =C2=A0831 Mbits/sec
>=C2=A00.0-10.0 sec =C2=A0 =C2=A0989 MBytes =C2=A0 =C2=A0828 Mbits/sec
>=C2=A00.0-10.0 sec =C2=A01019 MBytes =C2=A0 =C2=A0854 Mbits/sec
>=C2=A00.0-10.0 sec =C2=A0 =C2=A0965 MBytes =C2=A0 =C2=A0808 Mbits/sec

	The danger of round-robin (balance-rr mode) is that it generally
delivers packets out of order.  This will irritate TCP's congestion
control (which can be moderated via the net.ipv6.tcp_reordering sysctl)=
,
causing reduced throughput and inefficient use of the media.  Also, UDP
or other protocol users must be able to tolerate out of order delivery.

>However with XOR, I am not getting enough bandwidth:
>=C2=A00.0-10.0 sec =C2=A0 =C2=A0619 MBytes =C2=A0 =C2=A0519 Mbits/sec
>=C2=A00.0-10.0 sec =C2=A0 =C2=A0398 MBytes =C2=A0 =C2=A0333 Mbits/sec
>=C2=A00.0-10.0 sec =C2=A0 =C2=A0338 MBytes =C2=A0 =C2=A0283 Mbits/sec
>=C2=A00.0-10.0 sec =C2=A0 =C2=A0612 MBytes =C2=A0 =C2=A0513 Mbits/sec

	The xor (balance-xor mode) selects the slave to use according to
a hash.  There are several hash algorithms available, the best is
generally the layer3+4, but, again, it's just math, and with a small
number of destinations relative to the number of slaves, you're fairly
likely to get traffic doubled up on the slaves.  The available hashes
are described in detail in the bonding.txt file.

	On the positive side, the balance-xor mode will not deliver
packets out of order.

>Similar results with transmit load balancing (tlb), 802.3ad, active
>backup and broadcast:
>=C2=A00.0-10.5 sec =C2=A0 =C2=A0421 MBytes =C2=A0 =C2=A0336 Mbits/sec
>=C2=A00.0-10.1 sec =C2=A0 =C2=A0323 MBytes =C2=A0 =C2=A0269 Mbits/sec
>=C2=A00.0-10.0 sec =C2=A0 =C2=A0301 MBytes =C2=A0 =C2=A0252 Mbits/sec
>=C2=A00.0-10.0 sec =C2=A0 =C2=A0405 MBytes =C2=A0 =C2=A0339 Mbits/sec

	The balance-tlb mode does some semi-intelligent selection of the
transmitting slave according to the load.  However, all reply traffic
comes in to one slave.  Nothing is reordered.

	The 802.3ad mode uses the same selection algorithms as
balance-xor, so again, you can select the best transmit hash policy.

	Don't use broadcast.  It just sends everything to every slave,
and I've never really figured out a rational use for it.  Somebody,
somewhere, probably has some obscure use for it.

>Although, with adaptive load balancing I was constantly getting
>perfect bandwidth:
>=C2=A00.0-10.0 sec =C2=A01.09 GBytes =C2=A0 =C2=A0937 Mbits/sec
>=C2=A00.0-10.0 sec =C2=A01.09 GBytes =C2=A0 =C2=A0937 Mbits/sec
>=C2=A00.0-10.0 sec =C2=A01.09 GBytes =C2=A0 =C2=A0937 Mbits/sec
>=C2=A00.0-10.0 sec =C2=A01.09 GBytes =C2=A0 =C2=A0937 Mbits/sec

	The balance-alb mode does the same thing as balance-tlb for
transmit, but it also uses tailored ARP messages to direct slaves to
respond to particular slaves.  In your case, each peer (there are four)
is effectively assigned its own slave interface, so there's no
contention for the bandwidth.

	Note that for -alb (and -tlb) the balancing is done according to
MAC address, so any hosts beyond a router will all be balanced together=
=2E

>I wanted to know if so much change with mode change in bonding is
>expected or did I configure something wrong in the switch which is
>causing xor, tlb, 802.3ad etc. to not work properly?

	Variation is expected depending upon the workload; if one mode
was perfect for every configuration there wouldn't be so many.

	Another factor for all modes is the switch's balancing of
traffic when sending back to the bond.  For the balance-tlb and -alb
modes, the switch isn't involved.  However, for the balance-rr,
balance-xor or 802.3ad modes, the switch has its own algorithm, usually
a hash of some kind, to direct packets to a particular port of the
etherchannel group (for -rr and -xor modes) or aggregator (for 802.3ad
mode, perhaps called LACP on the switch).

	If the switch isn't configured for Etherchannel or 802.3ad /
LACP when running the equivalent bonding modes, then the return traffic
from the switch will not be balanced correctly.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
