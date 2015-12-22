From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v2 net-next] ravb: Add dma queue interrupt support
Date: Tue, 22 Dec 2015 18:02:24 +0300
Message-ID: <56796600.3010407@cogentembedded.com>
References: <1450602948-6777-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1450602948-6777-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/20/2015 12:15 PM, Yoshihiro Kaneko wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> This patch supports the following interrupts.
>
> - One interrupt for multiple (descriptor, error, management)
> - One interrupt for emac
> - Four interrupts for dma queue (best effort rx/tx, network control rx/tx)

    You still don't say why it's better than the current scheme...

> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> ---
>
> This patch is based on the master branch of David Miller's next networking
> tree.
>
> v2 [Yoshihiro Kaneko]
> * compile tested only
> * As suggested by Sergei Shtylyov
>    - add comment to CIE
>    - remove comments from CIE bits
>    - fix value of TIx_ALL
>    - define each bits for CIE, GIE, GID, RIE0, RID0, RIE2, RID2, TIE, TID
>    - reversed Christmas tree declaration ordered
>    - rename _ravb_emac_interrupt() to ravb_emac_interrupt_unlocked()
>    - remove unnecessary clearing of CIE
>    - use a bit name corresponding to the target register, RIE0, RIE2, TIE,
>      TID, RID2, GID, GIE
>
>   drivers/net/ethernet/renesas/ravb.h      | 213 ++++++++++++++++++++++++++
>   drivers/net/ethernet/renesas/ravb_main.c | 247 +++++++++++++++++++++++++++----
>   drivers/net/ethernet/renesas/ravb_ptp.c  |  45 ++++--
>   3 files changed, 464 insertions(+), 41 deletions(-)
>
> diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
> index 9fbe92a..71badd6d 100644
> --- a/drivers/net/ethernet/renesas/ravb.h
> +++ b/drivers/net/ethernet/renesas/ravb.h
> @@ -157,6 +157,7 @@ enum ravb_reg {
>   	TIC	= 0x0378,
>   	TIS	= 0x037C,
>   	ISS	= 0x0380,
> +	CIE	= 0x0384,	/* R-Car Gen3 only */
>   	GCCR	= 0x0390,
>   	GMTT	= 0x0394,
>   	GPTC	= 0x0398,
> @@ -170,6 +171,15 @@ enum ravb_reg {
>   	GCT0	= 0x03B8,
>   	GCT1	= 0x03BC,
>   	GCT2	= 0x03C0,
> +	GIE	= 0x03CC,
> +	GID	= 0x03D0,
> +	DIL	= 0x0440,
> +	RIE0	= 0x0460,
> +	RID0	= 0x0464,
> +	RIE2	= 0x0470,
> +	RID2	= 0x0474,
> +	TIE	= 0x0478,
> +	TID	= 0x047c,

    So you only commented on CIE and considered it done? :-)

[...]
> @@ -411,14 +422,27 @@ static int ravb_dmac_init(struct net_device *ndev)
>   	ravb_write(ndev, TCCR_TFEN, TCCR);
>
>   	/* Interrupt init: */
> -	/* Frame receive */
> -	ravb_write(ndev, RIC0_FRE0 | RIC0_FRE1, RIC0);
> -	/* Disable FIFO full warning */
> -	ravb_write(ndev, 0, RIC1);
> -	/* Receive FIFO full error, descriptor empty */
> -	ravb_write(ndev, RIC2_QFE0 | RIC2_QFE1 | RIC2_RFFE, RIC2);
> -	/* Frame transmitted, timestamp FIFO updated */
> -	ravb_write(ndev, TIC_FTE0 | TIC_FTE1 | TIC_TFUE, TIC);
> +	if (priv->chip_id == RCAR_GEN2) {
> +		/* Frame receive */
> +		ravb_write(ndev, RIC0_FRE0 | RIC0_FRE1, RIC0);
> +		/* Disable FIFO full warning */
> +		ravb_write(ndev, 0, RIC1);
> +		/* Receive FIFO full error, descriptor empty */
> +		ravb_write(ndev, RIC2_QFE0 | RIC2_QFE1 | RIC2_RFFE, RIC2);
> +		/* Frame transmitted, timestamp FIFO updated */
> +		ravb_write(ndev, TIC_FTE0 | TIC_FTE1 | TIC_TFUE, TIC);
> +	} else {
> +		/* Clear DIL.DPLx */
> +		ravb_write(ndev, 0, DIL);
> +		/* Set queue specific interrupt */
> +		ravb_write(ndev, CIE_CRIE | CIE_CTIE | CIE_CL0M, CIE);
> +		/* Frame receive */
> +		ravb_write(ndev, RIE0_FRS0 | RIE0_FRS1, RIE0);
> +		/* Receive FIFO full error, descriptor empty */
> +		ravb_write(ndev, RIE2_QFS0 | RIE2_QFS1 | RIE2_RFFS, RIE2);
> +		/* Frame transmitted, timestamp FIFO updated */
> +		ravb_write(ndev, TIE_FTS0 | TIE_FTS1 | TIE_TFUS, TIE);
> +	}

    So in this case for gen3 we enable interrupts we need in addition to already
enabled (by a boot loader perhaps)? I don't think you actually want it...

[...]
> @@ -690,7 +726,10 @@ static void ravb_error_interrupt(struct net_device *ndev)
>   	ravb_write(ndev, ~EIS_QFS, EIS);
>   	if (eis & EIS_QFS) {
>   		ris2 = ravb_read(ndev, RIS2);
> -		ravb_write(ndev, ~(RIS2_QFF0 | RIS2_RFFF), RIS2);
> +		if (priv->chip_id == RCAR_GEN2)
> +			ravb_write(ndev, ~(RIS2_QFF0 | RIS2_RFFF), RIS2);
> +		else
> +			ravb_write(ndev, RID2_QFD0 | RID2_RFFD, RID2);

    Err, aren't you doing 2 different things for gen2 and gen3 here. For gen2 
you're clearing the QFF0/RFFF interrupts, for gen3 you're disabling them, no?

[...]
> @@ -758,16 +797,43 @@ static irqreturn_t ravb_interrupt(int irq, void *dev_id)
[...]
> +/* Descriptor IRQ/Error/Management interrupt handler */
> +static irqreturn_t ravb_multi_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *ndev = dev_id;
> +	struct ravb_private *priv = netdev_priv(ndev);
> +	irqreturn_t result = IRQ_NONE;
> +	u32 iss;
> +
> +	spin_lock(&priv->lock);
> +	/* Get interrupt status */
> +	iss = ravb_read(ndev, ISS);
> +
>   	/* Error status summary */
>   	if (iss & ISS_ES) {
>   		ravb_error_interrupt(ndev);
>   		result = IRQ_HANDLED;
>   	}
>
> +	/* Management */

    I still doubt this comment is valid...

>   	if (iss & ISS_CGIS)
>   		result = ravb_ptp_interrupt(ndev);
>
[...]
> @@ -1223,23 +1343,68 @@ static const struct ethtool_ops ravb_ethtool_ops = {
>   static int ravb_open(struct net_device *ndev)
>   {
>   	struct ravb_private *priv = netdev_priv(ndev);
> -	int error;
> +	struct platform_device *pdev = priv->pdev;
> +	struct device *dev = &pdev->dev;
> +	int error, i;
> +	char *name;
>
>   	napi_enable(&priv->napi[RAVB_BE]);
>   	napi_enable(&priv->napi[RAVB_NC]);
>
> -	error = request_irq(ndev->irq, ravb_interrupt, IRQF_SHARED, ndev->name,
> -			    ndev);
> -	if (error) {
> -		netdev_err(ndev, "cannot request IRQ\n");
> -		goto out_napi_off;
> -	}
> -
> -	if (priv->chip_id == RCAR_GEN3) {
> -		error = request_irq(priv->emac_irq, ravb_interrupt,
> -				    IRQF_SHARED, ndev->name, ndev);
> +	if (priv->chip_id == RCAR_GEN2) {
> +		error = request_irq(ndev->irq, ravb_interrupt, IRQF_SHARED,
> +				    ndev->name, ndev);
>   		if (error) {
>   			netdev_err(ndev, "cannot request IRQ\n");
> +			goto out_napi_off;
> +		}
> +	} else {
> +		name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch22:multi",
> +				      ndev->name);
> +		error = request_irq(ndev->irq, ravb_multi_interrupt,
> +				    IRQF_SHARED, name, ndev);
> +		if (error) {
> +			netdev_err(ndev, "cannot request IRQ %s\n", name);
> +			goto out_napi_off;
> +		}
> +		name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch24:emac",
> +				      ndev->name);
> +		error = request_irq(priv->emac_irq, ravb_emac_interrupt,
> +				    IRQF_SHARED, name, ndev);
> +		if (error) {
> +			netdev_err(ndev, "cannot request IRQ %s\n", name);
> +			goto out_free_irq;
> +		}
> +		name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch0:rx_be",
> +				      ndev->name);
> +		error = request_irq(priv->rx_irqs[RAVB_BE], ravb_be_interrupt,
> +				    IRQF_SHARED, name, ndev);
> +		if (error) {
> +			netdev_err(ndev, "cannot request IRQ %s\n", name);
> +			goto out_free_irq;
> +		}
> +		name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch18:tx_be",
> +				      ndev->name);
> +		error = request_irq(priv->tx_irqs[RAVB_BE], ravb_be_interrupt,
> +				    IRQF_SHARED, name, ndev);
> +		if (error) {
> +			netdev_err(ndev, "cannot request IRQ %s\n", name);
> +			goto out_free_irq;
> +		}
> +		name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch1:rx_nc",
> +				      ndev->name);
> +		error = request_irq(priv->rx_irqs[RAVB_NC], ravb_nc_interrupt,
> +				    IRQF_SHARED, name, ndev);
> +		if (error) {
> +			netdev_err(ndev, "cannot request IRQ %s\n", name);
> +			goto out_free_irq;
> +		}
> +		name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch19:tx_nc",
> +				      ndev->name);
> +		error = request_irq(priv->tx_irqs[RAVB_NC], ravb_nc_interrupt,
> +				    IRQF_SHARED, name, ndev);
> +		if (error) {
> +			netdev_err(ndev, "cannot request IRQ %s\n", name);
>   			goto out_free_irq;
>   		}

    This error case is repetitive, couldn't you consolidate it somehow?

[...]
> @@ -1494,10 +1663,15 @@ static int ravb_close(struct net_device *ndev)
>   	netif_tx_stop_all_queues(ndev);
>
>   	/* Disable interrupts by clearing the interrupt masks. */
> -	ravb_write(ndev, 0, RIC0);
> -	ravb_write(ndev, 0, RIC2);
> -	ravb_write(ndev, 0, TIC);
> -
> +	if (priv->chip_id == RCAR_GEN2) {
> +		ravb_write(ndev, 0, RIC0);
> +		ravb_write(ndev, 0, RIC2);
> +		ravb_write(ndev, 0, TIC);
> +	} else {
> +		ravb_write(ndev, RID0_ALL, RID0);
> +		ravb_write(ndev, RID2_ALL, RID2);
> +		ravb_write(ndev, TID_ALL, TID);
> +	}

    Don't see why this is better than the old code. We don't care about 
atomicity here AFAIU.

[...]
> @@ -1798,6 +1973,22 @@ static int ravb_probe(struct platform_device *pdev)
>   			goto out_release;
>   		}
>   		priv->emac_irq = irq;
> +		for (i = 0; i < NUM_RX_QUEUE; i++) {
> +			irq = platform_get_irq_byname(pdev, ravb_rx_irqs[i]);
> +			if (irq < 0) {
> +				error = irq;
> +				goto out_release;
> +			}
> +			priv->rx_irqs[i] = irq;
> +		}
> +		for (i = 0; i < NUM_TX_QUEUE; i++) {
> +			irq = platform_get_irq_byname(pdev, ravb_tx_irqs[i]);
> +			if (irq < 0) {
> +				error = irq;
> +				goto out_release;
> +			}
> +			priv->tx_irqs[i] = irq;
> +		}

    Perhaps it would better to use sprintf() here, in both loops...

[...]
> diff --git a/drivers/net/ethernet/renesas/ravb_ptp.c b/drivers/net/ethernet/renesas/ravb_ptp.c
> index 7a8ce92..870d7b7 100644
> --- a/drivers/net/ethernet/renesas/ravb_ptp.c
> +++ b/drivers/net/ethernet/renesas/ravb_ptp.c
[...]
> @@ -352,7 +367,11 @@ void ravb_ptp_stop(struct net_device *ndev)
>   {
>   	struct ravb_private *priv = netdev_priv(ndev);
>
> -	ravb_write(ndev, 0, GIC);
> +	if (priv->chip_id == RCAR_GEN2)
> +		ravb_write(ndev, 0, GIC);
> +	else
> +		ravb_write(ndev, GID_ALL, GID);

    Again, don't see why it's better than the old code.

[...]

MBR, Sergei

