From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Fri, 28 Aug 2009 17:07:32 +0200
Message-ID: <4A97F2B4.7030900@gmail.com>
References: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>  <alpine.DEB.1.10.0908251514190.17963@gentwo.org>  <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908261223210.9933@gentwo.org>  <1251309040.10599.34.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908261506590.9933@gentwo.org> <1251324666.10599.72.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908271139450.14277@gentwo.org> <alpine.DEB.1.10.0908271621260.28029@gentwo.org> <alpine.DEB.1.10.0908280948320.3747@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52267 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbZH1PIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 11:08:17 -0400
In-Reply-To: <alpine.DEB.1.10.0908280948320.3747@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> The qdisc drop counter is incremented in pfifo_fast. So Sridhar's pat=
ch is
> not necessary.
>=20
> Seems though that the qdisc drop count does not flow into the tx_drop=
ped
> counter for the interface. Incrementing the tx_dropped count in the
> netdev_queue associated with the outbound qdisc also had no effect (s=
ee
> the following patch).
>=20
> Plus I only see one queue for eth0 with "tc -s qdisc show". I think t=
hat
> what I see there is the queue for receiving packets. tc uses this ugl=
y
> netlink interface. Could be a bug in there or in the netlink interfac=
e?
> Or is there some other trick to display queue statistics for outgoing
> packets?

"tc -s qdisc show" only displays queue info for tx packets.

>=20
> WTH is going on here? Noone was ever interested in making outbound pa=
cket
> loss account right?
>=20

I have no idea of what your problem can be Christoph.

Here, on unpatched git linux-2.6 kernel, default qdisc, and an udp tx f=
lood I get :

# tc -s -d qdisc show dev eth3
qdisc pfifo_fast 0: root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1=
 1
 Sent 18025794122 bytes 17299241 pkt (dropped 264892, overlimits 0 requ=
eues 68282)
 rate 0bit 0pps backlog 20840b 20p requeues 68282



>=20
> Index: linux-2.6.31-rc7/include/net/sch_generic.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.31-rc7.orig/include/net/sch_generic.h	2009-08-27
> 21:20:03.000000000 +0000
> +++ linux-2.6.31-rc7/include/net/sch_generic.h	2009-08-27
> 21:26:33.000000000 +0000
> @@ -509,6 +509,9 @@ static inline int qdisc_drop(struct sk_b
>  	kfree_skb(skb);
>  	sch->qstats.drops++;
>=20
> +	/* device queue statistics */
> +	sch->dev_queue->tx_dropped++;
> +
>  	return NET_XMIT_DROP;
>  }

locking problem here, tx_dropped can be changed by another cpu.


As David Stevens pointed out, device was not ever called at all when yo=
ur packet(s) was/were lost.
Why should we account a non existent drop at device level ?

When a process wants a new memory page and hits its own limit, do you w=
ant to increment a system global
counter saying 'memory allocation failed' ?


So in my case :

$ ifconfig eth3
eth3      Link encap:Ethernet  HWaddr 00:1E:0B:92:78:51
          inet addr:192.168.0.2  Bcast:192.168.0.255  Mask:255.255.255.=
0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1188 errors:0 dropped:0 overruns:0 frame:0
          TX packets:63774907 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:633918 (619.0 KiB)  TX bytes:105287564 (100.4 MiB)
          Interrupt:16

And yes, dropped:0 is OK here, since packets where dropped at qdisc lay=
er.


Only change you want is eventually to account for the UDP drop (SndbufE=
rrors).

