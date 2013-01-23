From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH 1/2 net-next] net: fec: add napi support to improve
 proformance
Date: Tue, 22 Jan 2013 22:37:47 -0800
Message-ID: <20130123063744.GA16454@ppwaskie-mobl2.amr.corp.intel.com>
References: <1358914330-3768-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, B38611@freescale.com,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	s.hauer@pengutronix.de
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38067 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750856Ab3AWGiM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 01:38:12 -0500
Content-Disposition: inline
In-Reply-To: <1358914330-3768-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 12:12:10PM +0800, Frank Li wrote:

[...]

> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
> index f52ba33..8fa420c 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -67,6 +67,8 @@
>  #endif
>  
>  #define DRIVER_NAME	"fec"
> +#define FEC_NAPI_WEIGHT	64
> +#define INT32_MAX	0x7FFFFFFF

This seems awfully big as an upper-limit to your ISR processing.  See below
for more comments.

>  
>  /* Pause frame feild and FIFO threshold */
>  #define FEC_ENET_FCE	(1 << 5)
> @@ -565,6 +567,20 @@ fec_timeout(struct net_device *ndev)
>  }
>  
>  static void
> +fec_enet_rx_int_is_enabled(struct net_device *ndev, bool enabled)
> +{
> +	struct fec_enet_private *fep = netdev_priv(ndev);
> +	uint    int_events;
> +
> +	int_events = readl(fep->hwp + FEC_IMASK);
> +	if (enabled)
> +		int_events |= FEC_ENET_RXF;
> +	else
> +		int_events &= ~FEC_ENET_RXF;
> +	writel(int_events, fep->hwp + FEC_IMASK);
> +}
> +
> +static void
>  fec_enet_tx(struct net_device *ndev)
>  {
>  	struct	fec_enet_private *fep;
> @@ -656,8 +672,8 @@ fec_enet_tx(struct net_device *ndev)
>   * not been given to the system, we just set the empty indicator,
>   * effectively tossing the packet.
>   */
> -static void
> -fec_enet_rx(struct net_device *ndev)
> +static int
> +fec_enet_rx(struct net_device *ndev, int budget)
>  {
>  	struct fec_enet_private *fep = netdev_priv(ndev);
>  	const struct platform_device_id *id_entry =
> @@ -667,13 +683,12 @@ fec_enet_rx(struct net_device *ndev)
>  	struct	sk_buff	*skb;
>  	ushort	pkt_len;
>  	__u8 *data;
> +	int	pkt_received = 0;
>  
>  #ifdef CONFIG_M532x
>  	flush_cache_all();
>  #endif
>  
> -	spin_lock(&fep->hw_lock);
> -
>  	/* First, grab all of the stats for the incoming packet.
>  	 * These get messed up if we get called due to a busy condition.
>  	 */
> @@ -681,6 +696,10 @@ fec_enet_rx(struct net_device *ndev)
>  
>  	while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
>  
> +		if (pkt_received >= budget)
> +			break;
> +		pkt_received++;
> +

This seems wrong given how it's called from the ISR when NAPI isn't being
used.  If you have continuous packets coming in, you won't exit your ISR
and release your spin_lock until you hit INT32_MAX.

>  		/* Since we have allocated space to hold a complete frame,
>  		 * the last indicator should be set.
>  		 */
> @@ -796,7 +815,7 @@ rx_processing_done:
>  	}
>  	fep->cur_rx = bdp;
>  
> -	spin_unlock(&fep->hw_lock);
> +	return pkt_received;
>  }
>  
>  static irqreturn_t
> @@ -805,6 +824,7 @@ fec_enet_interrupt(int irq, void *dev_id)
>  	struct net_device *ndev = dev_id;
>  	struct fec_enet_private *fep = netdev_priv(ndev);
>  	uint int_events;
> +	ulong flags;
>  	irqreturn_t ret = IRQ_NONE;
>  
>  	do {
> @@ -813,7 +833,18 @@ fec_enet_interrupt(int irq, void *dev_id)
>  
>  		if (int_events & FEC_ENET_RXF) {
>  			ret = IRQ_HANDLED;
> -			fec_enet_rx(ndev);
> +			spin_lock_irqsave(&fep->hw_lock, flags);
> +
> +			if (fep->use_napi) {
> +				/* Disable the RX interrupt */
> +				if (napi_schedule_prep(&fep->napi)) {
> +					fec_enet_rx_int_is_enabled(ndev, false);
> +					__napi_schedule(&fep->napi);
> +				}
> +			} else
> +				fec_enet_rx(ndev, INT32_MAX);

As mentioned above, you may want to check this a bit closer since this
can run for a very, very long time if you have constant packets flowing
when not using NAPI.

Also, the code formatting here should also have braces around the else
clause since the if clause has them.

> +
> +			spin_unlock_irqrestore(&fep->hw_lock, flags);
>  		}
>  
>  		/* Transmit OK, or non-fatal error. Update the buffer
> @@ -834,7 +865,16 @@ fec_enet_interrupt(int irq, void *dev_id)
>  	return ret;
>  }
>  
> -
> +static int fec_enet_rx_napi(struct napi_struct *napi, int budget)
> +{
> +	struct net_device *ndev = napi->dev;
> +	int pkgs = fec_enet_rx(ndev, budget);
> +	if (pkgs < budget) {
> +		napi_complete(napi);
> +		fec_enet_rx_int_is_enabled(ndev, true);
> +	}
> +	return pkgs;
> +}
>  
>  /* ------------------------------------------------------------------------- */
>  static void fec_get_mac(struct net_device *ndev)
> @@ -1392,6 +1432,9 @@ fec_enet_open(struct net_device *ndev)
>  	struct fec_enet_private *fep = netdev_priv(ndev);
>  	int ret;
>  
> +	if (fep->use_napi)
> +		napi_enable(&fep->napi);
> +
>  	/* I should reset the ring buffers here, but I don't yet know
>  	 * a simple way to do that.
>  	 */
> @@ -1604,6 +1647,11 @@ static int fec_enet_init(struct net_device *ndev)
>  	ndev->netdev_ops = &fec_netdev_ops;
>  	ndev->ethtool_ops = &fec_enet_ethtool_ops;
>  
> +	if (fep->use_napi) {
> +		fec_enet_rx_int_is_enabled(ndev, false);
> +		netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, fep->napi_weight);

Make sure not to exceed 80 characters here.

> +	}
> +
>  	/* Initialize the receive buffer descriptors. */
>  	bdp = fep->rx_bd_base;
>  	for (i = 0; i < RX_RING_SIZE; i++) {
> @@ -1698,6 +1746,7 @@ fec_probe(struct platform_device *pdev)
>  	static int dev_id;
>  	struct pinctrl *pinctrl;
>  	struct regulator *reg_phy;
> +	struct device_node *np = pdev->dev.of_node;
>  
>  	of_id = of_match_device(fec_dt_ids, &pdev->dev);
>  	if (of_id)
> @@ -1811,6 +1860,11 @@ fec_probe(struct platform_device *pdev)
>  		}
>  	}
>  
> +	fep->use_napi = !of_property_read_bool(np, "disable_napi");
> +
> +	if (of_property_read_u32(np, "napi_weight", &fep->napi_weight))
> +		fep->napi_weight = FEC_NAPI_WEIGHT; /*using default value*/
> +
>  	fec_reset_phy(pdev);
>  
>  	ret = fec_enet_init(ndev);
> diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
> index 2ebedaf..31fcdd0 100644
> --- a/drivers/net/ethernet/freescale/fec.h
> +++ b/drivers/net/ethernet/freescale/fec.h
> @@ -249,6 +249,10 @@ struct fec_enet_private {
>  	int	bufdesc_ex;
>  	int	pause_flag;
>  
> +	struct	napi_struct napi;
> +	int	napi_weight;
> +	bool	use_napi;
> +
>  	struct ptp_clock *ptp_clock;
>  	struct ptp_clock_info ptp_caps;
>  	unsigned long last_overflow_check;
> -- 
> 1.7.1
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
