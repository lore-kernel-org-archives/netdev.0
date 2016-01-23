From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v3 net-next] ravb: Add dma queue interrupt support
Date: Sun, 24 Jan 2016 01:17:50 +0300
Message-ID: <56A3FC0E.4080108@cogentembedded.com>
References: <1453028133-7670-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1453028133-7670-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01/17/2016 01:55 PM, Yoshihiro Kaneko wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> This patch supports the following interrupts.
>
> - One interrupt for multiple (descriptor, error, management)
> - One interrupt for emac
> - Four interrupts for dma queue (best effort rx/tx, network control rx/tx)
>
> This patch improve efficiency of the interrupt handler by adding the
> interrupt handler corresponding to each interrupt source described
> above. Additionally, it reduces the number of times of the access to
> EthernetAVB IF.

    Not sure I got the last sentence right... Did you mean that we save on the 
register reads?
    Yet another reason could be that we don't want to depend on the boot 
loader's whim any more...

> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> ---
>
> This patch is based on the master branch of David Miller's next networking
> tree.
>
> v3 [Yoshihiro Kaneko]
> * compile tested only

    Doesn't sound very encouraging... couldn't you manage to re-test the patch 
before Dave merges it?

[...]
> diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
> index 9fbe92a..385f06b 100644
> --- a/drivers/net/ethernet/renesas/ravb.h
> +++ b/drivers/net/ethernet/renesas/ravb.h
[...]
> @@ -556,6 +566,18 @@ enum ISS_BIT {
>   	ISS_DPS15	= 0x80000000,
>   };
>
> +/* CIE
> + * R-Car Gen3 only
> + */

    I'd be more happy with one line comment like:

/* CIE (R-Car Gen3 only) */

[...]
> @@ -592,6 +614,212 @@ enum GIS_BIT {
>   	GIS_PTMF	= 0x00000004,
>   };
>
> +/* GIE
> + * R-Car Gen3 only
> + */
> +enum GIE_BIT {
[...]
> +	GIE_ALL		= 0xffff03ff,

    GIE_ALL isn't used, no need to define it.

> +};
> +
> +/* GID
> + * R-Car Gen3 only
> + */
> +enum GID_BIT {
[...]
> +	GID_ALL		= 0xffff03ff,

    Not used any more.

> +};
> +
> +/* RIE0
> + * R-Car Gen3 only
> + */
> +enum RIE0_BIT {
[...]
> +	RIE0_ALL	= 0x0003ffff,

    Likewise.

> +};
> +
> +/* RID0
> + * R-Car Gen3 only
> + */
> +enum RID0_BIT {
[...]
> +	RID0_ALL	= 0x0003ffff,

    Likewise.

> +};
> +
> +/* RIE2
> + * R-Car Gen3 only
> + */
> +enum RIE2_BIT {
[...]
> +	RIE2_ALL	= 0x8003ffff,

    Likewise.

> +};
> +
> +/* RID2
> + * R-Car Gen3 only
> + */
> +enum RID2_BIT {

> +	RID2_ALL	= 0x8003ffff,

     Likewise.

> +};
> +
> +/* TIE
> + * R-Car Gen3 only
> + */
> +enum TIE_BIT {
[...]
> +	TIE_ALL		= 0x000f0f0f,

    Likewise.

> +};
> +
> +/* TID
> + * R-Car Gen3 only
> + */
> +enum TID_BIT {
[...]
> +	TID_ALL		= 0x000f0f0f,

    Likewise.

[...]
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index ac43ed9..4c4912e0 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -42,6 +42,16 @@
>   		 NETIF_MSG_RX_ERR | \
>   		 NETIF_MSG_TX_ERR)
>
> +static const char *ravb_rx_irqs[NUM_RX_QUEUE] = {
> +	"ch0", /* RAVB_BE */
> +	"ch1", /* RAVB_NC */
> +};
> +
> +static const char *ravb_tx_irqs[NUM_TX_QUEUE] = {
> +	"ch18", /* RAVB_BE */
> +	"ch19", /* RAVB_NC */
> +};
> +

    Do what you wish but I don't like these...

[...]
> @@ -693,7 +722,7 @@ static void ravb_error_interrupt(struct net_device *ndev)
>   		if (ris2 & RIS2_QFF0)
>   			priv->stats[RAVB_BE].rx_over_errors++;
>
> -		    /* Receive Descriptor Empty int */
> +		/* Receive Descriptor Empty int */

    It's not even a "drove-by" change, please don't do this here, submit a 
separate patch (or I can do it).

[...]
> @@ -773,6 +829,55 @@ static irqreturn_t ravb_interrupt(int irq, void *dev_id)
>   	return result;
>   }
>
> +static irqreturn_t ravb_dmaq_interrupt(int irq, void *dev_id, int ravb_queue)
> +{
> +	struct net_device *ndev = dev_id;
> +	struct ravb_private *priv = netdev_priv(ndev);
> +	irqreturn_t result = IRQ_NONE;
> +	u32 ris0, ric0, tis, tic;
> +	int q = ravb_queue;
> +
> +	spin_lock(&priv->lock);
> +
> +	ris0 = ravb_read(ndev, RIS0);
> +	ric0 = ravb_read(ndev, RIC0);
> +	tis  = ravb_read(ndev, TIS);
> +	tic  = ravb_read(ndev, TIC);
> +
> +	/* Timestamp updated */
> +	if (tis & TIS_TFUF) {
> +		ravb_write(ndev, TID_TFUD, TID);
> +		ravb_get_tx_tstamp(ndev);
> +		result = IRQ_HANDLED;
> +	}
> +
> +	/* Best effort queue RX/TX */
> +	if (((ris0 & ric0) & BIT(q)) ||
> +	    ((tis  & tic)  & BIT(q))) {
> +		if (napi_schedule_prep(&priv->napi[q])) {
> +			/* Mask RX and TX interrupts */
> +			ravb_write(ndev, BIT(q), RID0);
> +			ravb_write(ndev, BIT(q), TID);
> +			__napi_schedule(&priv->napi[q]);
> +		}

    There was an *else* branch originally (napi_schedule_prep()'s failure is a 
serious issue deserving an explanation), not sure why you dropped it here...

[...]
> @@ -1215,29 +1325,63 @@ static const struct ethtool_ops ravb_ethtool_ops = {
>   	.get_ts_info		= ravb_get_ts_info,
>   };
>
> +static inline int req_irq(unsigned int irq, irq_handler_t handler,

    I'd suggest hook_irq() instead.

> +			  struct net_device *ndev, struct device *dev,
> +			  const char *ch)
> +{
> +	char *name;
> +	int error;
> +
> +	name = devm_kasprintf(dev, GFP_KERNEL, "%s:%s", ndev->name, ch);
> +	error = request_irq(irq, handler, IRQF_SHARED, name, ndev);

    Looks like you missed a line here. Compile testing is not enough, 
apparently... :-(

> +		netdev_err(ndev, "cannot request IRQ %s\n", name);
> +
> +	return error;
> +}
> +
[...]
> @@ -1268,6 +1412,10 @@ out_free_irq2:
>   		free_irq(priv->emac_irq, ndev);
>   out_free_irq:
>   	free_irq(ndev->irq, ndev);
> +	for (i = 0; i < NUM_RX_QUEUE; i++)
> +		free_irq(priv->rx_irqs[i], ndev);
> +	for (i = 0; i < NUM_TX_QUEUE; i++)
> +		free_irq(priv->tx_irqs[i], ndev);

    If these are left uninitialized (as done for gen2), __free_irq() will 
curse loudly. Please only do this for gen3 like was done in my fix just above 
this code.

[...]

MBR, Sergei

