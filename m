From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] pktgen: Avoid dirtying skb->users when txq is full
Date: Wed, 30 Sep 2009 17:25:32 -0700
Message-ID: <20090930172532.2c2d1d42@s6510>
References: <20090922224902.17ed6cc4@nehalam>
	<20090923174141.1d350103@s6510>
	<4AC3E3C5.1090108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	Robert Olsson <robert@herjulf.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40167 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755190AbZJAAZb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 20:25:31 -0400
In-Reply-To: <4AC3E3C5.1090108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 01 Oct 2009 01:03:33 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > On Tue, 22 Sep 2009 22:49:02 -0700
> > Stephen Hemminger <shemminger@vyatta.com> wrote:
> >=20
> >> I thought others want to know how to get maximum speed of pktgen.
> >>
> >> 1. Run nothing else (even X11), just a command line
> >> 2. Make sure ethernet flow control is disabled
> >>    ethtool -A eth0 autoneg off rx off tx off
> >> 3. Make sure clocksource is TSC.  On my old SMP Opteron's
> >>    needed to get patch since in 2.6.30 or later, the clock guru's
> >>    decided to remove it on all non Intel machines.  Look for patch
> >>    than enables "tsc=3Dreliable"
> >> 4. Compile Ethernet drivers in, the overhead of the indirect
> >>    function call required for modules (or cache footprint),
> >>    slows things down.
> >> 5. Increase transmit ring size to 1000
> >>    ethtool -G eth0 tx 1000
> >>
>=20
> Thanks a lot Stephen.
>=20
> I did some pktgen session tonight and found one contention on skb->us=
ers field
> that following patch avoids.
>=20
>=20
> Before patch :
> ---------------------------------------------------------------------=
---------
>    PerfTop:    5187 irqs/sec  kernel:100.0% [100000 cycles],  (all, c=
pu: 0)
> ---------------------------------------------------------------------=
---------
>=20
>              samples    pcnt   kernel function
>              _______   _____   _______________
>=20
>             16688.00 - 50.9% : consume_skb
>              6541.00 - 20.0% : skb_dma_unmap
>              3277.00 - 10.0% : tg3_poll
>              1968.00 -  6.0% : mwait_idle
>               651.00 -  2.0% : irq_entries_start
>               466.00 -  1.4% : _spin_lock
>               442.00 -  1.3% : mix_pool_bytes_extract
>               373.00 -  1.1% : tg3_msi
>               353.00 -  1.1% : read_tsc
>               177.00 -  0.5% : sched_clock_local
>               176.00 -  0.5% : sched_clock
>               137.00 -  0.4% : tick_nohz_stop_sched_tick
>=20
> After patch:
> ---------------------------------------------------------------------=
---------
>    PerfTop:    3530 irqs/sec  kernel:99.9% [100000 cycles],  (all, cp=
u: 0)
> ---------------------------------------------------------------------=
---------
>=20
>              samples    pcnt   kernel function
>              _______   _____   _______________
>=20
>             17127.00 - 34.0% : tg3_poll
>             12691.00 - 25.2% : consume_skb
>              5299.00 - 10.5% : skb_dma_unmap
>              4179.00 -  8.3% : mwait_idle
>              1583.00 -  3.1% : irq_entries_start
>              1288.00 -  2.6% : mix_pool_bytes_extract
>              1239.00 -  2.5% : tg3_msi
>              1062.00 -  2.1% : read_tsc
>               583.00 -  1.2% : _spin_lock
>               432.00 -  0.9% : sched_clock
>               416.00 -  0.8% : sched_clock_local
>               360.00 -  0.7% : tick_nohz_stop_sched_tick
>               329.00 -  0.7% : ktime_get
>               263.00 -  0.5% : _spin_lock_irqsave
>=20
> I believe we could go further, batching the atomic_inc(&skb->users) w=
e do all the
> time, competing with the atomic_dec() done by tx completion handler (=
possibly run
> on other cpu): Reserve XXXXXXX units to the skb->users, and decrement=
 a pktgen
> local variable and refill the reserve if necessary, once in a while..=
=2E

When buffer is allocated we know the number of times it will be cloned.=
 So why
not set it there, would need to cleanup on interrupt but that should be=
 possible.

Alternatively, just change skb->destructor on last packet and use a pro=
per
completion mechanism.

> [PATCH] pktgen: Avoid dirtying skb->users when txq is full
>=20
> We can avoid two atomic ops on skb->users if packet is not going to b=
e
> sent to the device (because hardware txqueue is full)
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>=20
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 4d11c28..6a9ab28 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -3439,12 +3439,14 @@ static void pktgen_xmit(struct pktgen_dev *pk=
t_dev)
>  	txq =3D netdev_get_tx_queue(odev, queue_map);
> =20
>  	__netif_tx_lock_bh(txq);
> -	atomic_inc(&(pkt_dev->skb->users));
> =20
> -	if (unlikely(netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(t=
xq)))
> +	if (unlikely(netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(t=
xq))) {
>  		ret =3D NETDEV_TX_BUSY;
> -	else
> -		ret =3D (*xmit)(pkt_dev->skb, odev);
> +		pkt_dev->last_ok =3D 0;
> +		goto unlock;
> +	}
> +	atomic_inc(&(pkt_dev->skb->users));
> +	ret =3D (*xmit)(pkt_dev->skb, odev);
> =20
>  	switch (ret) {
>  	case NETDEV_TX_OK:
> @@ -3466,6 +3468,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_=
dev)
>  		atomic_dec(&(pkt_dev->skb->users));
>  		pkt_dev->last_ok =3D 0;
>  	}
> +unlock:
>  	__netif_tx_unlock_bh(txq);
> =20
>  	/* If pkt_dev->count is zero, then run forever */

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
