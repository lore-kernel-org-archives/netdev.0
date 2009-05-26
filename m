From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [net-2.6 PATCH V2] mlx4_en: Fix a kernel panic when waking tx
 queue
Date: Tue, 26 May 2009 12:48:04 +0200
Message-ID: <4A1BC8E4.1050009@cosmosbay.com>
References: <49EC859C.700@mellanox.co.il> <4A0AB34A.10100@mellanox.co.il> <4A1948D7.8010504@mellanox.co.il> <4A1A57AA.1080209@mellanox.co.il> <4A1B92D1.8070907@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59907 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbZEZKsN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 06:48:13 -0400
In-Reply-To: <4A1B92D1.8070907@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yevgeny Petrilin a =E9crit :
> When the transmit queue gets full we enable interrupts for TX complet=
ions
> There was a race that we handled the TX queue both from the interrupt=
 context
> and from the transmit function. Using "spin_trylock_irq()" ensures th=
is
> doesn't happen.
>=20
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> ---
>  drivers/net/mlx4/en_tx.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
> index ac6fc49..e5c98a9 100644
> --- a/drivers/net/mlx4/en_tx.c
> +++ b/drivers/net/mlx4/en_tx.c
> @@ -426,7 +426,7 @@ void mlx4_en_poll_tx_cq(unsigned long data)
>=20
>  	INC_PERF_COUNTER(priv->pstats.tx_poll);
>=20
> -	if (!spin_trylock(&ring->comp_lock)) {
> +	if (!spin_trylock_irq(&ring->comp_lock)) {
>  		mod_timer(&cq->timer, jiffies + MLX4_EN_TX_POLL_TIMEOUT);
>  		return;
>  	}
> @@ -439,7 +439,7 @@ void mlx4_en_poll_tx_cq(unsigned long data)
>  	if (inflight && priv->port_up)
>  		mod_timer(&cq->timer, jiffies + MLX4_EN_TX_POLL_TIMEOUT);
>=20
> -	spin_unlock(&ring->comp_lock);
> +	spin_unlock_irq(&ring->comp_lock);
>  }
>=20
>  static struct mlx4_en_tx_desc *mlx4_en_bounce_to_desc(struct mlx4_en=
_priv *priv,
> @@ -482,9 +482,9 @@ static inline void mlx4_en_xmit_poll(struct mlx4_=
en_priv *priv, int tx_ind)
>=20
>  	/* Poll the CQ every mlx4_en_TX_MODER_POLL packets */
>  	if ((++ring->poll_cnt & (MLX4_EN_TX_POLL_MODER - 1)) =3D=3D 0)
> -		if (spin_trylock(&ring->comp_lock)) {
> +		if (spin_trylock_irq(&ring->comp_lock)) {
>  			mlx4_en_process_tx_cq(priv->dev, cq);
> -			spin_unlock(&ring->comp_lock);
> +			spin_unlock_irq(&ring->comp_lock);
>  		}
>  }
>=20

Just curious.

Blocking hard IRQ while doing TX completion is quite nasty,
as freeing one hundred of skb take long.

Could you try something in process context instead ?

Is this timer driven tx completion thing really good for performance ?


static inline void mlx4_en_xmit_poll(struct mlx4_en_priv *priv, int tx_=
ind)
{
        struct mlx4_en_cq *cq =3D &priv->tx_cq[tx_ind];
        struct mlx4_en_tx_ring *ring =3D &priv->tx_ring[tx_ind];

        /* If we don't have a pending timer, set one up to catch our re=
cent
           post in case the interface becomes idle */
        if (!timer_pending(&cq->timer))
                mod_timer(&cq->timer, jiffies + MLX4_EN_TX_POLL_TIMEOUT=
);


        /* Poll the CQ every mlx4_en_TX_MODER_POLL packets */
        if ((++ring->poll_cnt & (MLX4_EN_TX_POLL_MODER - 1)) =3D=3D 0)
                if (spin_trylock(&ring->comp_lock)) {
                        mlx4_en_process_tx_cq(priv->dev, cq);
                        spin_unlock(&ring->comp_lock);
                }
}


One interesting thing is calling mlx4_en_process_tx_cq() once every 16 =
packets,
this means the producer cpu is also the cpu doing the TX completion, I =
like this.

