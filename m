From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 3/5] net/cpsw: don't rely only on netif_running() to check
 which device is active
Date: Tue, 23 Apr 2013 23:11:29 +0530
Message-ID: <5176C7C9.8020705@ti.com>
References: <1366738299-21285-1-git-send-email-bigeasy@linutronix.de> <1366738299-21285-4-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	<tglx@linutronix.de>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:38129 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756685Ab3DWRlu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 13:41:50 -0400
In-Reply-To: <1366738299-21285-4-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/23/2013 11:01 PM, Sebastian Andrzej Siewior wrote:
> netif_running() reports false before the ->ndo_stop() callback is
> called. That means if one executes "ifconfig down" and the system
> receives an interrupt before the interrupt source has been disabled we
> hang for always for two reasons:
> - we never disable the interrupt source because devices claim to be
>    already inactive and don't feel responsible.
> - since the ISR always reports IRQ_HANDLED the line is never deactivated
>    because it looks like the ISR feels responsible.
>
> This patch changes the logic in the ISR a little:
> - If none of the status registers reports an active source (RX or TX,
>    misc is ignored because it is not actived) we leave with IRQ_NONE.
> - the interrupt is deactivated
> - The first active network device is taken and napi is scheduled. If
>    none are active (a small race window between ndo_down() and the
>    interrupt the) then we leave and should not come back because the
>    source is off.
>    There is no need to schedule the second NAPI because both share the
>    same dma queue.
>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>   drivers/net/ethernet/ti/cpsw.c |   33 ++++++++++++++++++++++-----------
>   1 file changed, 22 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 29700fb..13d4ed8 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -510,20 +510,31 @@ void cpsw_rx_handler(void *token, int len, int status)
>   static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
>   {
>   	struct cpsw_priv *priv = dev_id;
> +	u32 rx, tx, rx_thresh;
>   
> -	if (likely(netif_running(priv->ndev))) {
> -		cpsw_intr_disable(priv);
> -		cpsw_disable_irq(priv);
> +	rx_thresh = __raw_readl(&priv->wr_regs->rx_thresh_stat);
> +	rx = __raw_readl(&priv->wr_regs->rx_stat);
> +	tx = __raw_readl(&priv->wr_regs->tx_stat);
> +	if (!rx_thresh && !rx && !tx)
> +		return IRQ_NONE;
> +
> +	cpsw_intr_disable(priv);
> +	cpsw_disable_irq(priv);
> +
> +	if (netif_running(priv->ndev)) {
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
> +	if (netif_running(priv->ndev)) {
> +		napi_schedule(&priv->napi);
> +		return IRQ_HANDLED;
>   	}
> -	return IRQ_HANDLED;
> +	return IRQ_NONE;
>   }
>   
>   static int cpsw_poll(struct napi_struct *napi, int budget)
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
