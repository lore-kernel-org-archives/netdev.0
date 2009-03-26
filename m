From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 1/2] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Thu, 26 Mar 2009 15:15:25 +0100
Message-ID: <49CB8DFD.2050504@cosmosbay.com>
References: <1238072077-27044-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc-dev@ozlabs.org, leoli@freescale.com, netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <1238072077-27044-1-git-send-email-Joakim.Tjernlund@transmode.se>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Joakim Tjernlund a =E9crit :
> Also set NAPI weight to 64 as this is a common value.
> This will make the system alot more responsive while
> ping flooding the ucc_geth ethernet interaface.
> =

> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
>  drivers/net/ucc_geth.c |   32 ++++++++++++--------------------
>  drivers/net/ucc_geth.h |    1 -
>  2 files changed, 12 insertions(+), 21 deletions(-)
> =

> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index 097aed8..7fc91aa 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -3214,7 +3214,7 @@ static int ucc_geth_tx(struct net_device *dev, u8 t=
xQ)
>  		dev->stats.tx_packets++;
>  =

>  		/* Free the sk buffer associated with this TxBD */
> -		dev_kfree_skb_irq(ugeth->
> +		dev_kfree_skb(ugeth->
>  				  tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]]);
>  		ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]] =3D NULL;
>  		ugeth->skb_dirtytx[txQ] =3D
> @@ -3248,9 +3248,16 @@ static int ucc_geth_poll(struct napi_struct *napi,=
 int budget)

>  	for (i =3D 0; i < ug_info->numQueuesRx; i++)
>  		howmany +=3D ucc_geth_rx(ugeth, i, budget - howmany);

Not related to your patch, but seeing above code, I can understand
you might have a problem in flood situation : Only first queue(s) are
depleted, and last one cannot be because howmany >=3D budget.

This driver might have to remember last queue it handled at previous
call ucc_geth_poll(), so that all rxqueues have same probability to be scan=
ned.

j =3D ug->lastslot;
for (i =3D 0; ug_info->numQueuesRx; i++) {
	if (++j >=3D ug_info->numQueuesRx)
		j =3D 0;
	howmany +=3D ucc_geth_rx(ugeth, j, budget - howmany);
	if (howmany >=3D budget)
		break;
}
ug->lastslot =3D j;


>  =

> +	/* Tx event processing */
> +	spin_lock(&ugeth->lock);
> +	for (i =3D 0; i < ug_info->numQueuesTx; i++) {
> +		ucc_geth_tx(ugeth->dev, i);
> +	}
> +	spin_unlock(&ugeth->lock);
> +
>  	if (howmany < budget) {
>  		netif_rx_complete(napi);
> -		setbits32(ugeth->uccf->p_uccm, UCCE_RX_EVENTS);
> +		setbits32(ugeth->uccf->p_uccm, UCCE_RX_EVENTS | UCCE_TX_EVENTS);
>  	}
>  =

>  	return howmany;
> @@ -3264,8 +3271,6 @@ static irqreturn_t ucc_geth_irq_handler(int irq, vo=
id *info)
>  	struct ucc_geth_info *ug_info;
>  	register u32 ucce;
>  	register u32 uccm;
> -	register u32 tx_mask;
> -	u8 i;
>  =

>  	ugeth_vdbg("%s: IN", __func__);
>  =

> @@ -3279,27 +3284,14 @@ static irqreturn_t ucc_geth_irq_handler(int irq, =
void *info)
>  	out_be32(uccf->p_ucce, ucce);
>  =

>  	/* check for receive events that require processing */
> -	if (ucce & UCCE_RX_EVENTS) {
> +	if (ucce & (UCCE_RX_EVENTS | UCCE_TX_EVENTS)) {
>  		if (netif_rx_schedule_prep(&ugeth->napi)) {
> -			uccm &=3D ~UCCE_RX_EVENTS;
> +			uccm &=3D ~(UCCE_RX_EVENTS | UCCE_TX_EVENTS);
>  			out_be32(uccf->p_uccm, uccm);
>  			__netif_rx_schedule(&ugeth->napi);
>  		}
>  	}
>  =

> -	/* Tx event processing */
> -	if (ucce & UCCE_TX_EVENTS) {
> -		spin_lock(&ugeth->lock);
> -		tx_mask =3D UCC_GETH_UCCE_TXB0;
> -		for (i =3D 0; i < ug_info->numQueuesTx; i++) {
> -			if (ucce & tx_mask)
> -				ucc_geth_tx(dev, i);
> -			ucce &=3D ~tx_mask;
> -			tx_mask <<=3D 1;
> -		}
> -		spin_unlock(&ugeth->lock);
> -	}
> -
>  	/* Errors and other events */
>  	if (ucce & UCCE_OTHER) {
>  		if (ucce & UCC_GETH_UCCE_BSY)
> @@ -3733,7 +3725,7 @@ static int ucc_geth_probe(struct of_device* ofdev, =
const struct of_device_id *ma
>  	dev->netdev_ops =3D &ucc_geth_netdev_ops;
>  	dev->watchdog_timeo =3D TX_TIMEOUT;
>  	INIT_WORK(&ugeth->timeout_work, ucc_geth_timeout_work);
> -	netif_napi_add(dev, &ugeth->napi, ucc_geth_poll, UCC_GETH_DEV_WEIGHT);
> +	netif_napi_add(dev, &ugeth->napi, ucc_geth_poll, 64);
>  	dev->mtu =3D 1500;
>  =

>  	ugeth->msg_enable =3D netif_msg_init(debug.msg_enable, UGETH_MSG_DEFAUL=
T);
> diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
> index 44218b8..50bad53 100644
> --- a/drivers/net/ucc_geth.h
> +++ b/drivers/net/ucc_geth.h
> @@ -843,7 +843,6 @@ struct ucc_geth_hardware_statistics {
>  /* Driver definitions */
>  #define TX_BD_RING_LEN                          0x10
>  #define RX_BD_RING_LEN                          0x10
> -#define UCC_GETH_DEV_WEIGHT                     TX_BD_RING_LEN
>  =

>  #define TX_RING_MOD_MASK(size)                  (size-1)
>  #define RX_RING_MOD_MASK(size)                  (size-1)
