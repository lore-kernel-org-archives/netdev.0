From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: introduce build_skb()
Date: Tue, 12 Jul 2011 17:40:16 +0200
Message-ID: <1310485216.2871.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
	 <ae7b531c89a01a21e4374907b69f4d997c9d5d1b.1310339688.git.mirq-linux@rere.qmqm.pl>
	 <1310363206.2512.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35148 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624Ab1GLPk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 11:40:28 -0400
Received: by wyg8 with SMTP id 8so117670wyg.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 08:40:27 -0700 (PDT)
In-Reply-To: <1310363206.2512.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 juillet 2011 =C3=A0 07:46 +0200, Eric Dumazet a =C3=A9crit =
:

> [PATCH] net: introduce build_skb()
>=20
> One of the thing we discussed during netdev 2011 conference was the i=
dea
> to change network drivers to allocate/populate their skb at RX
> completion time, right before feeding the skb to network stack.
>=20
> Right now, we allocate skbs when populating the RX ring, and thats a
> waste of CPU cache, since allocating skb means a full memset() to cle=
ar
> the skb and its skb_shared_info portion. By the time NIC fills a fram=
e
> in data buffer and host can get it, cpu probably threw away the cache
> lines from its caches, because of huge RX ring sizes.
>=20
> So the deal would be to allocate only the data buffer for the NIC to
> populate its RX ring buffer. And use build_skb() at RX completion to
> attach a data buffer (now filled with an ethernet frame) to a new skb=
,
> initialize the skb_shared_info portion, and give the hot skb to netwo=
rk
> stack.

Update :

=46irst results are impressive : About 15% of throughput increase with =
igb
driver on my small desktop machine, and I am limited by the wire
speed :)

(AMD Athlon(tm) II X2 B24 Processor, 3GHz, cache size : 1024K)

setup : One dual port Intel card : Ethernet controller: Intel
Corporation 82576 Gigabit Network Connection (rev 01)

eth1 direct attach on eth2, Gigabit speed.
eth2 RX ring set to 4096 slots (default is 256)

CPU0 : pktgen sending on eth1, line rate (1488137pps)
CPU1 : receive eth2 interrupts, packets dropped into raw netfilter tabl=
e
to bypass upper stacks.

Before patch : 15% packet losses, ksoftirqd/1 using 100% of cpu
After patch : residual losses (less than 0.1 %), ksoftirqd not used, 80=
%
cpu used=20

I'll do more tests with a 10Gb card (ixgbe driver) to not be wire
limited.



