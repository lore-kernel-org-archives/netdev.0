From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH net-next-2.6] net: introduce build_skb()
Date: Tue, 12 Jul 2011 17:54:05 +0200
Message-ID: <20110712155404.GA10651@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
 <ae7b531c89a01a21e4374907b69f4d997c9d5d1b.1310339688.git.mirq-linux@rere.qmqm.pl>
 <1310363206.2512.26.camel@edumazet-laptop>
 <1310485216.2871.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:42123 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751259Ab1GLPyH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 11:54:07 -0400
Content-Disposition: inline
In-Reply-To: <1310485216.2871.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2011 at 05:40:16PM +0200, Eric Dumazet wrote:
> Le lundi 11 juillet 2011 =C3=A0 07:46 +0200, Eric Dumazet a =C3=A9cri=
t :
>=20
> > [PATCH] net: introduce build_skb()
> >=20
> > One of the thing we discussed during netdev 2011 conference was the=
 idea
> > to change network drivers to allocate/populate their skb at RX
> > completion time, right before feeding the skb to network stack.
> >=20
> > Right now, we allocate skbs when populating the RX ring, and thats =
a
> > waste of CPU cache, since allocating skb means a full memset() to c=
lear
> > the skb and its skb_shared_info portion. By the time NIC fills a fr=
ame
> > in data buffer and host can get it, cpu probably threw away the cac=
he
> > lines from its caches, because of huge RX ring sizes.
> >=20
> > So the deal would be to allocate only the data buffer for the NIC t=
o
> > populate its RX ring buffer. And use build_skb() at RX completion t=
o
> > attach a data buffer (now filled with an ethernet frame) to a new s=
kb,
> > initialize the skb_shared_info portion, and give the hot skb to net=
work
> > stack.
>=20
> Update :
>=20
> First results are impressive : About 15% of throughput increase with =
igb
> driver on my small desktop machine, and I am limited by the wire
> speed :)
>=20
> (AMD Athlon(tm) II X2 B24 Processor, 3GHz, cache size : 1024K)
>=20
> setup : One dual port Intel card : Ethernet controller: Intel
> Corporation 82576 Gigabit Network Connection (rev 01)
>=20
> eth1 direct attach on eth2, Gigabit speed.
> eth2 RX ring set to 4096 slots (default is 256)
>=20
> CPU0 : pktgen sending on eth1, line rate (1488137pps)
> CPU1 : receive eth2 interrupts, packets dropped into raw netfilter ta=
ble
> to bypass upper stacks.
>=20
> Before patch : 15% packet losses, ksoftirqd/1 using 100% of cpu
> After patch : residual losses (less than 0.1 %), ksoftirqd not used, =
80%
> cpu used=20
>=20
> I'll do more tests with a 10Gb card (ixgbe driver) to not be wire
> limited.

I remember observing similar increase after switching from allocating s=
kb
to allocating pages and using napi_get_frags() + napi_gro_frags(). That
was with sl351x driver posted for review some time ago.

Best Regards,
Micha=C5=82 Miros=C5=82aw
