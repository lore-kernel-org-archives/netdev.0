From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v4 net-next] ravb: Add dma queue interrupt support
Date: Thu, 28 Jan 2016 19:48:52 +0300
Message-ID: <56AA4674.6020001@cogentembedded.com>
References: <1453650775-19886-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:36291 "EHLO
	mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755433AbcA1Qs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 11:48:56 -0500
Received: by mail-lf0-f49.google.com with SMTP id h129so31114081lfh.3
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 08:48:55 -0800 (PST)
In-Reply-To: <1453650775-19886-1-git-send-email-ykaneko0929@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/24/2016 06:52 PM, Yoshihiro Kaneko wrote:

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
>
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> ---
>
> This patch is based on the master branch of David Miller's next networking
> tree.
>
> v4 [Yoshihiro Kaneko]
> * compile tested only
> * As suggested by Sergei Shtylyov
>    drivers/net/ethernet/renesas/ravb.h:
>      - make two lines of comment into one line.
>      - remove unused definition of xxx_ALL.
>    drivers/net/ethernet/renesas/ravb_main.c:
>      - remove unrelated change (fix indentation).
>      - output warning messages when napi_schedule_prep() fails in ravb_dmaq_
>        interrupt() like ravb_interrupt().
>      - change the function name from req_irq to hook_irq.
>      - fix programming error in hook_irq().
>      - do free_irq() for rx_irqs[] and tx_irqs[] for only gen3 in out_free_
>        irq label in ravb_open().
>
> v3 [Yoshihiro Kaneko]
> * compile tested only
> * As suggested by Sergei Shtylyov
>    - update changelog
>    drivers/net/ethernet/renesas/ravb.h:
>      - add comments to the additional registers like CIE
>    drivers/net/ethernet/renesas/ravb_main.c:
>      - fix the initialization of the interrupt in ravb_dmac_init()
>      - revert ravb_error_interrupt() because gen3 code is wrong
>      - change the comment "Management" in ravb_multi_interrupt()
>      - add a helper function for request_irq() in ravb_open()
>      - revert ravb_close() because atomicity is not necessary here
>    drivers/net/ethernet/renesas/ravb_ptp.c:
>      - revert ravb_ptp_stop() because atomicity is not necessary here
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

    As I already noted, the changes made to the original patch are supposed to 
be documented above --- (no need to separate diff versions there though).
    Either that, or just say that it's your patch, based on Mizuguchi-san's 
work (the amount of changes makes that possible, I think).

[...]
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index ac43ed9..076f25f 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
[...]
> +static irqreturn_t ravb_dmaq_interrupt(int irq, void *dev_id, int ravb_queue)
> +{
> +	struct net_device *ndev = dev_id;
> +	struct ravb_private *priv = netdev_priv(ndev);
> +	irqreturn_t result = IRQ_NONE;
> +	u32 ris0, ric0, tis, tic;
> +	int q = ravb_queue;

    Just give a shorter name to the 'ravb_queue' parameter, no need to copy it.

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

    Wait, you're supposed to clear the TFUF interrupt, not to disable!
And with that fixed, this interrupt's handler could get factored out into a 
function...

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
> +		} else {
> +			netdev_warn(ndev,
> +				    "ignoring interrupt, rx status 0x%08x, rx mask 0x%08x,\n",
> +				    ris0, ric0);
> +			netdev_warn(ndev,
> +				    "                    tx status 0x%08x, tx mask 0x%08x.\n",
> +				    tis, tic);
> +		}
> +		result = IRQ_HANDLED;
> +	}

    In principle, this also can get factored out.

[...]
> @@ -1215,29 +1332,64 @@ static const struct ethtool_ops ravb_ethtool_ops = {
>   	.get_ts_info		= ravb_get_ts_info,
>   };
>
> +static inline int hook_irq(unsigned int irq, irq_handler_t handler,

    Namespacing this function with 'ravb_' prefix would be preferable, I did 
that for all functions, even those that didn't have this prefix in sh_eth...

> +			   struct net_device *ndev, struct device *dev,
> +			   const char *ch)
> +{
> +	char *name;
> +	int error;
> +
> +	name = devm_kasprintf(dev, GFP_KERNEL, "%s:%s", ndev->name, ch);
> +	error = request_irq(irq, handler, IRQF_SHARED, name, ndev);

    Not sure if we need IRQF_SHARED on those IRQs, they're not really shareable...

[...]
>   /* Network device open function for Ethernet AVB */
>   static int ravb_open(struct net_device *ndev)
>   {
>   	struct ravb_private *priv = netdev_priv(ndev);
> -	int error;
> +	struct platform_device *pdev = priv->pdev;
> +	struct device *dev = &pdev->dev;
> +	int error, i;
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
> -			goto out_free_irq;
> +			goto out_napi_off;
>   		}
> +	} else {
> +		error = hook_irq(ndev->irq, ravb_multi_interrupt, ndev, dev,
> +				 "ch22:multi");
> +		if (error)
> +			goto out_napi_off;
> +		error = hook_irq(priv->emac_irq, ravb_emac_interrupt, ndev,
> +				 dev, "ch24:emac");
> +		if (error)
> +			goto out_free_irq;
> +		error = hook_irq(priv->rx_irqs[RAVB_BE], ravb_be_interrupt,
> +				 ndev, dev, "ch0:rx_be");
> +		if (error)
> +			goto out_free_irq;

    And you fail to call free_irq() for the EMAC IRQ... :-(
    Sorry for not noticing this in a previous review.

> +		error = hook_irq(priv->tx_irqs[RAVB_BE], ravb_be_interrupt,
> +				 ndev, dev, "ch18:tx_be");
> +		if (error)
> +			goto out_free_irq;
> +		error = hook_irq(priv->rx_irqs[RAVB_NC], ravb_nc_interrupt,
> +				 ndev, dev, "ch1:rx_nc");
> +		if (error)
> +			goto out_free_irq;
> +		error = hook_irq(priv->tx_irqs[RAVB_NC], ravb_nc_interrupt,
> +				 ndev, dev, "ch19:tx_nc");
> +		if (error)
> +			goto out_free_irq;

    Same comment for all these *goto* statements...

[...]
> @@ -1268,6 +1420,12 @@ out_free_irq2:
>   		free_irq(priv->emac_irq, ndev);
>   out_free_irq:
>   	free_irq(ndev->irq, ndev);
> +	if (priv->chip_id == RCAR_GEN3) {
> +		for (i = 0; i < NUM_RX_QUEUE; i++)
> +			free_irq(priv->rx_irqs[i], ndev);
> +		for (i = 0; i < NUM_TX_QUEUE; i++)
> +			free_irq(priv->tx_irqs[i], ndev);
> +	}

    I'm afraid __free_irq() would complain anyway in case not all IRQs had 
been successfully hooked... I don't have an easy recipe for fixing that... you 
probably just shouldn't use loops here.

[...]

    OK, I'll now proceed to sanity-testing this patch on the gen2 hardware.

MBR, Sergei
