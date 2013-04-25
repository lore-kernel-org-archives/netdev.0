From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 4/4] net/cpsw: fix irq_disable() with threaded interrupts
Date: Thu, 25 Apr 2013 12:05:57 +0530
Message-ID: <5178CECD.10008@ti.com>
References: <1366829305-9752-1-git-send-email-bigeasy@linutronix.de> <1366829305-9752-5-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <tglx@linutronix.de>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:43089 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928Ab3DYGge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 02:36:34 -0400
In-Reply-To: <1366829305-9752-5-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/25/2013 12:18 AM, Sebastian Andrzej Siewior wrote:
> During high throughput it is likely that we receive both: an RX and TX
> interrupt. The normal behaviour is that once we enter the ISR the
> interrupts are disabled in the IRQ chip and so the ISR is invoked only
> once and the interrupt line is disabled once. It will be re-enabled
> after napi completes.
> With threaded interrupts on the other hand the interrupt the interrupt
> is disabled immediately and the ISR is marked for "later". By having TX
> and RX interrupt marked pending we invoke them both and disable the
> interrupt line twice. The napi callback is still executed once and so
> after it completes we remain with interrupts disabled.
>
> The initial patch simply removed the cpsw_{enable|disable}_irq() calls
> and it worked well on my AM335X ES1.0 (beagle bone). On ES2.0 (beagle
> bone black) it caused an never ending interrupt (even after the mask via
> cpsw_intr_disable()) according to Mugunthan V N. Since I don't have the
> ES2.0 and no idea what is going on this patch tracks the state of the
> irq_disable() call and execute it only when not yet done.
> The book keeping is done on the first struct since with dual_emac we can
> have two of those and only one interrupt line.
>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>   drivers/net/ethernet/ti/cpsw.c |   25 ++++++++++++++++++++++---
>   1 file changed, 22 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 8b643d9..2633be6 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -348,6 +348,7 @@ struct cpsw_priv {
>   	/* snapshot of IRQ numbers */
>   	u32 irqs_table[4];
>   	u32 num_irqs;
> +	bool irq_enabled;
>   	struct cpts *cpts;
>   	u32 emac_port;
>   };
> @@ -515,7 +516,10 @@ static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
>   		return IRQ_NONE;
>   
>   	cpsw_intr_disable(priv);
> -	cpsw_disable_irq(priv);
> +	if (priv->irq_enabled == true) {
> +		cpsw_disable_irq(priv);
> +		priv->irq_enabled = false;
> +	}
>   
>   	if (netif_running(priv->ndev)) {
>   		napi_schedule(&priv->napi);
> @@ -544,10 +548,16 @@ static int cpsw_poll(struct napi_struct *napi, int budget)
>   
>   	num_rx = cpdma_chan_process(priv->rxch, budget);
>   	if (num_rx < budget) {
> +		struct cpsw_priv *prim_cpsw;
> +
>   		napi_complete(napi);
>   		cpsw_intr_enable(priv);
>   		cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
> -		cpsw_enable_irq(priv);
> +		prim_cpsw = cpsw_get_slave_priv(priv, 0);
> +		if (prim_cpsw->irq_enabled == false) {
> +			cpsw_enable_irq(priv);
> +			prim_cpsw->irq_enabled = true;
> +		}
>   	}
>   
>   	if (num_rx || num_tx)
> @@ -886,6 +896,7 @@ static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
>   static int cpsw_ndo_open(struct net_device *ndev)
>   {
>   	struct cpsw_priv *priv = netdev_priv(ndev);
> +	struct cpsw_priv *prim_cpsw;
>   	int i, ret;
>   	u32 reg;
>   
> @@ -953,6 +964,14 @@ static int cpsw_ndo_open(struct net_device *ndev)
>   		cpsw_set_coalesce(ndev, &coal);
>   	}
>   
> +	prim_cpsw = cpsw_get_slave_priv(priv, 0);
> +	if (prim_cpsw->irq_enabled == false) {
> +		if ((priv == prim_cpsw) || !netif_running(prim_cpsw->ndev)) {
> +			prim_cpsw->irq_enabled = true;
> +			cpsw_enable_irq(prim_cpsw);
> +		}
> +	}
> +
>   	cpdma_ctlr_start(priv->dma);
>   	cpsw_intr_enable(priv);
>   	napi_enable(&priv->napi);
> @@ -1856,7 +1875,7 @@ static int cpsw_probe(struct platform_device *pdev)
>   		}
>   		k++;
>   	}
> -
> +	priv->irq_enabled = true;
>   	ndev->features |= NETIF_F_HW_VLAN_FILTER;
>   
>   	ndev->netdev_ops = &cpsw_netdev_ops;

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
