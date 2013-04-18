From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 3/5] net/cpsw: don't rely on netif_running() to check
 which device is active
Date: Thu, 18 Apr 2013 17:20:34 +0530
Message-ID: <516FDE0A.70504@ti.com>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-4-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:60175 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753903Ab3DRLuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 07:50:50 -0400
In-Reply-To: <1366235536-15744-4-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/2013 3:22 AM, Sebastian Andrzej Siewior wrote:
> netif_running() reports false before even the ->ndo_stop() callback is
> called. That means if one executes "ifconfig down" and the system
> receives an interrupt before the interrupt source has been disabled we
> hang for always for two reasons:
> - we never disable the interrupt source because devices claim to be
>    already inactive (or non-present)
> - since the ISR always reports IRQ_HANDLED the line is never deactivated
>    because it looks like the ISR feels respsonsible.
>
> This patch introduces now the ->active field which is set/cleared in
> ndo_open / ndo_stop.
>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>   drivers/net/ethernet/ti/cpsw.c |   26 +++++++++++++++++---------
>   1 file changed, 17 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 3b22a36..c32780d 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -341,6 +341,7 @@ struct cpsw_priv {
>   	int				host_port;
>   	struct clk			*clk;
>   	u8				mac_addr[ETH_ALEN];
> +	u8				active;
Frame work is providing this feature then why you need to have additional
book keeping in device private?
>   	struct cpsw_slave		*slaves;
>   	struct cpdma_ctlr		*dma;
>   	struct cpdma_chan		*txch, *rxch;
> @@ -511,19 +512,24 @@ static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
>   {
>   	struct cpsw_priv *priv = dev_id;
>   
> -	if (likely(netif_running(priv->ndev))) {
> +	if (priv->active) {
>   		cpsw_intr_disable(priv);
>   		cpsw_disable_irq(priv);
>   		napi_schedule(&priv->napi);
> -	} else {
> -		priv = cpsw_get_slave_priv(priv, 1);
> -		if (likely(priv) && likely(netif_running(priv->ndev))) {
> -			cpsw_intr_disable(priv);
> -			cpsw_disable_irq(priv);
> -			napi_schedule(&priv->napi);
> -		}
> +		return IRQ_HANDLED;
> +	}
> +
> +	priv = cpsw_get_slave_priv(priv, 1);
> +	if (!priv)
> +		return IRQ_NONE;
> +
> +	if (priv->active) {
> +		cpsw_intr_disable(priv);
> +		cpsw_disable_irq(priv);
> +		napi_schedule(&priv->napi);
> +		return IRQ_HANDLED;
>   	}
> -	return IRQ_HANDLED;
> +	return IRQ_NONE;
>   }
>   
>   static int cpsw_poll(struct napi_struct *napi, int budget)
> @@ -937,6 +943,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
>   		cpsw_set_coalesce(ndev, &coal);
>   	}
>   
> +	priv->active = 1;
>   	cpdma_ctlr_start(priv->dma);
>   	cpsw_intr_enable(priv);
>   	napi_enable(&priv->napi);
> @@ -980,6 +987,7 @@ static int cpsw_ndo_stop(struct net_device *ndev)
>   	pm_runtime_put_sync(&priv->pdev->dev);
>   	if (priv->data.dual_emac)
>   		priv->slaves[priv->emac_port].open_stat = false;
> +	priv->active = 0;
>   	return 0;
>   }
>   

Regards
Mugunthan V N
