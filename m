From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/5] net: sh_eth: remove unnecessary function
Date: Fri, 16 Mar 2012 10:57:19 +0100
Message-ID: <4F630E7F.3060304@openwrt.org>
References: <4F62FDCE.8010609@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	SH-Linux <linux-sh@vger.kernel.org>
To: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4F62FDCE.8010609@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Le 03/16/12 09:46, Shimoda, Yoshihiro a =C3=A9crit :
> The sh_eth_timer() called mod_timer() for itself.
> So, this patch removes the function.

You could avoid using this timer if you implement PHYLIB in your driver=
,=20
which will poll the PHY for you and report the link state consistently.

>
> Signed-off-by: Yoshihiro Shimoda<yoshihiro.shimoda.uh@renesas.com>
> ---
>   drivers/net/ethernet/renesas/sh_eth.c |   22 ----------------------
>   drivers/net/ethernet/renesas/sh_eth.h |    1 -
>   2 files changed, 0 insertions(+), 23 deletions(-)
>
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethe=
rnet/renesas/sh_eth.c
> index 8615961..2c99b10 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -1163,14 +1163,6 @@ other_irq:
>   	return ret;
>   }
>
> -static void sh_eth_timer(unsigned long data)
> -{
> -	struct net_device *ndev =3D (struct net_device *)data;
> -	struct sh_eth_private *mdp =3D netdev_priv(ndev);
> -
> -	mod_timer(&mdp->timer, jiffies + (10 * HZ));
> -}
> -
>   /* PHY state control function */
>   static void sh_eth_adjust_link(struct net_device *ndev)
>   {
> @@ -1418,11 +1410,6 @@ static int sh_eth_open(struct net_device *ndev=
)
>   	if (ret)
>   		goto out_free_irq;
>
> -	/* Set the timer to check for link beat. */
> -	init_timer(&mdp->timer);
> -	mdp->timer.expires =3D (jiffies + (24 * HZ)) / 10;/* 2.4 sec. */
> -	setup_timer(&mdp->timer, sh_eth_timer, (unsigned long)ndev);
> -
>   	return ret;
>
>   out_free_irq:
> @@ -1447,9 +1434,6 @@ static void sh_eth_tx_timeout(struct net_device=
 *ndev)
>   	/* tx_errors count up */
>   	ndev->stats.tx_errors++;
>
> -	/* timer off */
> -	del_timer_sync(&mdp->timer);
> -
>   	/* Free all the skbuffs in the Rx queue. */
>   	for (i =3D 0; i<  RX_RING_SIZE; i++) {
>   		rxdesc =3D&mdp->rx_ring[i];
> @@ -1467,10 +1451,6 @@ static void sh_eth_tx_timeout(struct net_devic=
e *ndev)
>
>   	/* device init */
>   	sh_eth_dev_init(ndev);
> -
> -	/* timer on */
> -	mdp->timer.expires =3D (jiffies + (24 * HZ)) / 10;/* 2.4 sec. */
> -	add_timer(&mdp->timer);
>   }
>
>   /* Packet transmit function */
> @@ -1543,8 +1523,6 @@ static int sh_eth_close(struct net_device *ndev=
)
>
>   	free_irq(ndev->irq, ndev);
>
> -	del_timer_sync(&mdp->timer);
> -
>   	/* Free all the skbuffs in the Rx queue. */
>   	sh_eth_ring_free(ndev);
>
> diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethe=
rnet/renesas/sh_eth.h
> index 57dc262..e4e4d18 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.h
> +++ b/drivers/net/ethernet/renesas/sh_eth.h
> @@ -765,7 +765,6 @@ struct sh_eth_private {
>   	struct sh_eth_txdesc *tx_ring;
>   	struct sk_buff **rx_skbuff;
>   	struct sk_buff **tx_skbuff;
> -	struct timer_list timer;
>   	spinlock_t lock;
>   	u32 cur_rx, dirty_rx;	/* Producer/consumer ring indices */
>   	u32 cur_tx, dirty_tx;
