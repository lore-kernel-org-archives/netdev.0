From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 3/7] stmmac: add the initial tx coalesce schema
Date: Wed, 5 Sep 2012 17:11:59 +0100
Message-ID: <1346861519.5325.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com>
	 <1346857432-24657-4-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23781 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751265Ab2IEQMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 12:12:02 -0400
In-Reply-To: <1346857432-24657-4-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-05 at 17:03 +0200, Giuseppe CAVALLARO wrote:
> This patch adds a new schema used for mitigating the
> number of transmit interrupts.
> It is based on a sw timer and a threshold value.
> The timer is used to periodically call the stmmac_tx
> function that can be invoked by the ISR but only for
> the descriptors where the interrupt on completion
> field has been set. This is tuned by a threshold.
> 
> Next step is to add the ability to tune these coalesce
> values by ethtool.
> 
> Till now I have put a default that showed a real gain
> on all the platforms ARM/SH4 where I performed benchmarks.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/common.h       |    8 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    4 +
>  .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    9 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   86 +++++++++++++-------
>  4 files changed, 72 insertions(+), 35 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
> index bd32fe6..1d6bd3e 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -95,11 +95,13 @@ struct stmmac_extra_stats {
>  	unsigned long threshold;
>  	unsigned long tx_pkt_n;
>  	unsigned long rx_pkt_n;
> -	unsigned long rx_napi_poll;
> +	unsigned long normal_irq_n;
>  	unsigned long rx_normal_irq_n;
> +	unsigned long rx_napi_poll;
>  	unsigned long tx_normal_irq_n;
> -	unsigned long sched_timer_n;
> -	unsigned long normal_irq_n;
> +	unsigned long txtimer;
> +	unsigned long tx_clean;
> +	unsigned long tx_reset_ic_bit;
>  	unsigned long mmc_tx_irq_n;
>  	unsigned long mmc_rx_irq_n;
>  	unsigned long mmc_rx_csum_offload_irq_n;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> index 9f35769..0f5ab28 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> @@ -88,6 +88,10 @@ struct stmmac_priv {
>  	int eee_enabled;
>  	int eee_active;
>  	int tx_lpi_timer;
> +	struct timer_list txtimer;
> +	u32 tx_count_frames;
> +	u32 tx_coal_frames;
> +	u32 tx_coal_timer;
>  };
>  
>  extern int phyaddr;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
> index 505fe71..48ad0bc 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
> @@ -90,12 +90,13 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
>  	STMMAC_STAT(threshold),
>  	STMMAC_STAT(tx_pkt_n),
>  	STMMAC_STAT(rx_pkt_n),
> -	STMMAC_STAT(rx_napi_poll),
> +	STMMAC_STAT(normal_irq_n),
>  	STMMAC_STAT(rx_normal_irq_n),
> +	STMMAC_STAT(rx_napi_poll),
>  	STMMAC_STAT(tx_normal_irq_n),
> -	STMMAC_STAT(sched_timer_n),
> -	STMMAC_STAT(normal_irq_n),
> -	STMMAC_STAT(normal_irq_n),
> +	STMMAC_STAT(txtimer),
> +	STMMAC_STAT(tx_clean),
> +	STMMAC_STAT(tx_reset_ic_bit),
>  	STMMAC_STAT(mmc_tx_irq_n),
>  	STMMAC_STAT(mmc_rx_irq_n),
>  	STMMAC_STAT(mmc_rx_csum_offload_irq_n),
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index b247c39..d7f5482 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -77,6 +77,8 @@
>  
>  #define STMMAC_ALIGN(x)	L1_CACHE_ALIGN(x)
>  #define JUMBO_LEN	9000
> +#define	STMMAC_TX_TM	40000
> +#define STMMAC_TX_MAX_FRAMES	64	/* Max coalesced frame */
>  
>  /* Module parameters */
>  #define TX_TIMEO 5000 /* default 5 seconds */
> @@ -695,8 +697,11 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
>  static void stmmac_tx(struct stmmac_priv *priv)
>  {
>  	unsigned int txsize = priv->dma_tx_size;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->tx_lock, flags);
>  
> -	spin_lock(&priv->tx_lock);
> +	priv->xstats.tx_clean++;
>  
>  	while (priv->dirty_tx != priv->cur_tx) {
>  		int last;
> @@ -765,7 +770,7 @@ static void stmmac_tx(struct stmmac_priv *priv)
>  		stmmac_enable_eee_mode(priv);
>  		mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_TIMER(eee_timer));
>  	}
> -	spin_unlock(&priv->tx_lock);
> +	spin_unlock_irqrestore(&priv->tx_lock, flags);
>  }
>  
>  static inline void stmmac_enable_irq(struct stmmac_priv *priv)
> @@ -778,29 +783,16 @@ static inline void stmmac_disable_irq(struct stmmac_priv *priv)
>  	priv->hw->dma->disable_dma_irq(priv->ioaddr);
>  }
>  
> -static int stmmac_has_work(struct stmmac_priv *priv)
> +static void stmmac_txtimer(unsigned long data)
>  {
> -	unsigned int has_work = 0;
> -	int rxret, tx_work = 0;
> +	struct stmmac_priv *priv = (struct stmmac_priv *)data;
>  
> -	rxret = priv->hw->desc->get_rx_owner(priv->dma_rx +
> -		(priv->cur_rx % priv->dma_rx_size));
> +	priv->xstats.txtimer++;
>  
>  	if (priv->dirty_tx != priv->cur_tx)
> -		tx_work = 1;
> -
> -	if (likely(!rxret || tx_work))
> -		has_work = 1;
> +		stmmac_tx(priv);
>  
> -	return has_work;
> -}
> -
> -static inline void _stmmac_schedule(struct stmmac_priv *priv)
> -{
> -	if (likely(stmmac_has_work(priv))) {
> -		stmmac_disable_irq(priv);
> -		napi_schedule(&priv->napi);
> -	}
> +	return;
>  }
>  
>  /**
> @@ -824,7 +816,7 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
>  	netif_wake_queue(priv->dev);
>  }
>  
> -static inline void stmmac_rx_schedule(struct stmmac_priv *priv)
> +static void stmmac_rx_schedule(struct stmmac_priv *priv)
>  {
>  	if (likely(napi_schedule_prep(&priv->napi))) {
>  		stmmac_disable_irq(priv);
> @@ -1001,6 +993,36 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
>  				   priv->dma_rx_phy);
>  }
>  
> +static int stmmac_check_coal(int size, int max_coal_frames)
> +{
> +	int ret = 0;
> +
> +	if (max_coal_frames >= size)
> +		return ret;
> +
> +	return max_coal_frames;
> +}

Not sure this makes sense.  You're limiting the number of frames to be
coalesced to the size of the TX DMA ring.  But each frame can consume
multiple DMA descriptors, so it doesn't make sense to compare these
numbers.

It looks like patch 6 reverts this, but why do it in the first place?

[...]
> @@ -1213,10 +1240,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  		return NETDEV_TX_BUSY;
>  	}
>  
> -	spin_lock(&priv->tx_lock);
> -
> -	if (priv->tx_path_in_lpi_mode)
> -		stmmac_disable_eee_mode(priv);

Why are you removing the call to stmmac_disable_eee_mode()?

> +	spin_lock_irqsave(&priv->tx_lock, flags);
>  
>  	entry = priv->cur_tx % txsize;
>  
> @@ -1272,7 +1296,14 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  	/* Interrupt on completition only for the latest segment */
>  	priv->hw->desc->close_tx_desc(desc);

Comment above this is now incorrect.

> -	wmb();

Why are you removing this barrier?

> +	/* Do not set the IC according to the coalesce patameters */
> +	priv->tx_count_frames++;
> +	if (priv->tx_coal_frames > priv->tx_count_frames) {
> +		priv->hw->desc->clear_tx_ic(desc);
> +		priv->xstats.tx_reset_ic_bit++;
> +		mod_timer(&priv->txtimer, priv->tx_coal_timer);
> +	} else
> +		priv->tx_count_frames = 0;
>  
>  	/* To avoid raise condition */
>  	priv->hw->desc->set_tx_owner(first);
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
