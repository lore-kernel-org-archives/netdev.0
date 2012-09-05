From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 2/7] stmmac: manage tx clean out of rx_poll
Date: Wed, 5 Sep 2012 16:51:30 +0100
Message-ID: <1346860290.5325.4.camel@bwh-desktop.uk.solarflarecom.com>
References: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com>
	 <1346857432-24657-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60065 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754101Ab2IEPve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 11:51:34 -0400
In-Reply-To: <1346857432-24657-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-05 at 17:03 +0200, Giuseppe CAVALLARO wrote:
> This patch is to invoke the stmmac_tx (tx handler)
> out of the NAPI poll method.
> This will make easier the next step to add the new
> mitigation schema.
> Also the patch enhances the ethtool to report some
> stats for normal TX and RX IRQs.
[...]
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -824,16 +824,27 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
>  	netif_wake_queue(priv->dev);
>  }
>  
> +static inline void stmmac_rx_schedule(struct stmmac_priv *priv)
> +{
> +	if (likely(napi_schedule_prep(&priv->napi))) {
> +		stmmac_disable_irq(priv);
> +		__napi_schedule(&priv->napi);
> +	}
> +}
>  
>  static void stmmac_dma_interrupt(struct stmmac_priv *priv)
>  {
>  	int status;
>  
>  	status = priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats);
> -	if (likely(status == handle_tx_rx))
> -		_stmmac_schedule(priv);
> -
> -	else if (unlikely(status == tx_hard_error_bump_tc)) {
> +	if (likely(status == handle_rx)) {

Surely 'status & handle_rx'?

> +		priv->xstats.rx_normal_irq_n++;
> +		stmmac_rx_schedule(priv);
> +	}
> +	if (likely(status == handle_tx)) {

'status & handle_tx'?

> +		priv->xstats.tx_normal_irq_n++;
> +		stmmac_tx(priv);
> +	} else if (unlikely(status == tx_hard_error_bump_tc)) {
>  		/* Try to bump up the dma threshold on this failure */
>  		if (unlikely(tc != SF_DMA_MODE) && (tc <= 256)) {
>  			tc += 64;
> @@ -1443,8 +1454,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
>  	struct stmmac_priv *priv = container_of(napi, struct stmmac_priv, napi);
>  	int work_done = 0;
>  
> -	priv->xstats.poll_n++;
> -	stmmac_tx(priv);
> +	priv->xstats.rx_napi_poll++;
>  	work_done = stmmac_rx(priv, budget);
>  
>  	if (work_done < budget) {

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
