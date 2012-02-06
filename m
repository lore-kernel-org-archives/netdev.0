From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/fec: infinite spin on sirq-net-tx on real-time
Date: Mon, 06 Feb 2012 10:56:31 +0100
Message-ID: <1328522191.2220.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328520810-28030-1-git-send-email-hector.palacios@digi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, shawn.guo@linaro.org,
	jgq516@gmail.com, rostedt@goodmis.org, tim.sander@hbm.com,
	u.kleine-koenig@pengutronix.de, tglx@linutronix.de,
	Zeng Zhaoming <b32542@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: Hector Palacios <hector.palacios@digi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48180 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754215Ab2BFJ4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 04:56:36 -0500
Received: by wgbdt10 with SMTP id dt10so6033187wgb.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2012 01:56:35 -0800 (PST)
In-Reply-To: <1328520810-28030-1-git-send-email-hector.palacios@digi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 f=C3=A9vrier 2012 =C3=A0 10:33 +0100, Hector Palacios a =C3=
=A9crit :
> If softirqd is a real time task, an inifinite spin is hit
> if the FEC driver tries to send a packet before the autonegotiation
> with the PHY has completed.
>=20
> This was seen when booting the platform with DHCP on. The driver
> sends the DHCP request before the PHY has completed autonegotiation.
> As a consequence, the driver's dev_hard_start_xmit returns NETDEV_TX_=
BUSY.
> NETDEV_TX_BUSY is part of NET_TX_MASK thus the packet is requeued (th=
e
> skb->next =3D nskb) in dev_hard_start_xmit(). And the NETDEV_TX_BUSY =
is
> passed back to sch_derect_xmit() which calls dev_requeue_skb() which
> then calls __netif_schedule(q) which will call __netif_reschedule(q)
> which will then do raise_softirq_irqoff(NET_TX_SOFTIRQ).
>=20
> Thus, as soon as ksoftirq exits this routine, it will restart the
> process over again. As the fec driver never finished with its
> negotiations, the process starts over again and we never move forward=
=2E
>=20
> Newsgroup reference: linux-rt-users http://www.spinics.net/lists/linu=
x-rt-users/msg07551.html
>=20
> Signed-off-by: Zeng Zhaoming <b32542@freescale.com>
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> Signed-off-by: Hector Palacios <hector.palacios@digi.com>
> ---
>  drivers/net/ethernet/freescale/fec.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ether=
net/freescale/fec.c
> index c136230..3fa7d3b 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -284,6 +284,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct n=
et_device *ndev)
> =20
>  	if (!fep->link) {
>  		/* Link is down or autonegotiation is in progress. */
> +		netif_stop_queue(dev);

This seems odd.

IMHO, NETDEV_TX_BUSY should be avoided as much as possible.

Its part of the old driver API.

If queue was stopped, you would not have to test fep->link at all in
fast path, and Qdisc would not have to requeue a packet eventually.

>  		return NETDEV_TX_BUSY;
>  	}
> =20
> @@ -530,6 +531,7 @@ fec_stop(struct net_device *ndev)
>  	udelay(10);
>  	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
>  	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
> +	fep->link =3D 0;


Why not call netif_stop_queue(dev) here ?

> =20
>  	/* We have to keep ENET enabled to have MII interrupt stay working =
*/
>  	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC)
> @@ -866,6 +868,7 @@ static void fec_enet_adjust_link(struct net_devic=
e *ndev)
>  	if (phy_dev->link) {
>  		if (fep->full_duplex !=3D phy_dev->duplex) {
>  			fec_restart(ndev, phy_dev->duplex);
> +			netif_wake_queue(dev);
>  			status_change =3D 1;
>  		}
>  	}
