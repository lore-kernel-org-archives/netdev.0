From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v2 00/46] Clean up RX copybreak and DMA handling
Date: Mon, 11 Jul 2011 11:16:49 +0200
Message-ID: <20110711091649.GA6380@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
 <20110710.235458.1549578255936886669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50684 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750721Ab1GKJQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 05:16:50 -0400
Content-Disposition: inline
In-Reply-To: <20110710.235458.1549578255936886669.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 10, 2011 at 11:54:58PM -0700, David Miller wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Date: Mon, 11 Jul 2011 02:52:46 +0200 (CEST)
>=20
> >   1. under packet storm and memory pressure NIC keeps generating in=
terrupts
> >      (if non-NAPI) and indicating new buffers because it always has=
 free
> >      RX buffers --- this only wastes CPU and bus bandwidth transfer=
ring
> >      data that is going to be immediately discarded;
> Actually, this is exactly how I, and others advise people to implemen=
t
> drivers.  It is the right thing to do.
>=20
> The worst thing that can happen is to let the RX ring empty of
> buffers.  Some cards hang as a result of this, and also it causes hea=
d
> of line blocking on multiqueue cards, etc.
>=20
> So the first thing the driver should do is try to allocate a
> replacement buffer.
>=20
> And if that fails, it should give the RX packet right back to the
> card, and not pass it up the stack.

=46or now, lets ignore those badly broken cards which can't cope with
insufficient receive buffers. (BTW, are there that many of them?
Some examples, please?)

Lets compare the two cases (replacing buffers immediately vs replacing
later) under the hostile conditions. Keep in mind that the strategy
doesn't matter much when the buffers can be allocated right away --- th=
e
discussion is about the corner case when memory runs out.

1. replacing buffers immediately

Packet is indicated in queue N, theres no memory for new skb, so its
dropped, and the buffer goes back to free list. In parallel, queue M
(!=3D N) indicates new packet. Still, there's no memory for new skb so
its also dropped and its buffer is reused. The effect is that all
packets are dropped, whatever queue they appear on.

2. replacing buffers later

Packet is indicated in queue N, its delivered up the stack. No new buff=
er
is available, so after a while queue stalls and the packets are dropped
by the card. If the queues share free buffer list, then all get stalled
at the same time, if not they run out independently. Net effect is the
same as above --- all packets are dropped.

The differences are:
 - where the packets are dropped:
   1. in driver core after transfer
   2. in the card
 - where accounting happens:
   1. in driver: rx_dropped
   2. in card: rx discards
 - memory usage:
   1. memory is held in empty rx ring buffers
   2. memory is held in packets waiting to be processed
 - CPU usage:
   1. >0% - queues are cleared repeatedly, card 'thinks' everything is =
ok
   2. 0% - queues are stalled, no more rx indications
 - hardware throttling (or pause frame generation):
   1. broken --- card always sees full free rx ring, so does not try to
      throttle (unless driver also indicates congestion to the card)
   2. hardware throttling is possible as the card sees only really free
      rx buffers

The HOL blocking does not matter here, because there's only one head --=
-
the system memory. If I misunderstood this point, please explain it fur=
ther.

Scheme #1 has the potential use when combined with small emergency buff=
er
pool if the driver looks for specific packets or indications that come
in the same queue as other packets. These are rare cases, though.

Best Regards,
Micha=B3 Miros=B3aw
