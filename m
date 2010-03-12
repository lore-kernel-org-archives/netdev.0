From: Kevin Hilman <khilman-1D3HCaltpLuhEniVeURVKkEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH 1/2] TI DaVinci EMAC: Add EMAC PHY clock handling.
Date: Fri, 12 Mar 2010 14:27:09 -0800
Message-ID: <87bpet6urm.fsf@deeprootsystems.com>
References: <1268317491-3822-1-git-send-email-srk@ti.com>
	<1268317491-3822-2-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <1268317491-3822-2-git-send-email-srk-l0cyMroinI0@public.gmane.org> (Sriramakrishnan's
	message of "Thu\, 11 Mar 2010 19\:54\:50 +0530")
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org> writes:

> Source for the EMAC PHY clock can be different from the
> module clock and driver needs to request/enable the EMAC
> phy clock explicitly. This was not required earlier as on
> most Davinci platforms the phy clock is always on . On AM35x
> platform the phy clock needs to be managed explicitly , hence
> adding clock management for phy clock.
>
> Signed-off-by: Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>

Acked-by: Kevin Hilman <khilman-1D3HCaltpLuhEniVeURVKkEOCMrvLtNR@public.gmane.org>

Dave, if you prefer, with your ack, I'll merge this via the davinci
tree along with corresponding platform changes.

Kevin


> ---
>  drivers/net/davinci_emac.c |   22 ++++++++++++++++++++--
>  1 files changed, 20 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
> index 8a42dbe..d9ae6ee 100644
> --- a/drivers/net/davinci_emac.c
> +++ b/drivers/net/davinci_emac.c
> @@ -491,6 +491,7 @@ struct emac_priv {
>  
>  /* clock frequency for EMAC */
>  static struct clk *emac_clk;
> +static struct clk *emac_phy_clk;
>  static unsigned long emac_bus_frequency;
>  static unsigned long mdio_max_freq;
>  
> @@ -2637,18 +2638,28 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
>  	struct emac_platform_data *pdata;
>  	struct device *emac_dev;
>  
> -	/* obtain emac clock from kernel */
> -	emac_clk = clk_get(&pdev->dev, NULL);
> +	/* obtain emac module clock from kernel */
> +	emac_clk = clk_get(&pdev->dev, "emac_clk");
>  	if (IS_ERR(emac_clk)) {
>  		printk(KERN_ERR "DaVinci EMAC: Failed to get EMAC clock\n");
>  		return -EBUSY;
>  	}
> +
> +	/* obtain emac phy clock from kernel */
> +	emac_phy_clk = clk_get(&pdev->dev, "phy_clk");
> +	if (IS_ERR(emac_phy_clk)) {
> +		printk(KERN_ERR "DaVinci EMAC: Failed to get PHY clock\n");
> +		clk_put(emac_clk);
> +		return -EBUSY;
> +	}
> +
>  	emac_bus_frequency = clk_get_rate(emac_clk);
>  	/* TODO: Probe PHY here if possible */
>  
>  	ndev = alloc_etherdev(sizeof(struct emac_priv));
>  	if (!ndev) {
>  		printk(KERN_ERR "DaVinci EMAC: Error allocating net_device\n");
> +		clk_put(emac_phy_clk);
>  		clk_put(emac_clk);
>  		return -ENOMEM;
>  	}
> @@ -2734,6 +2745,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
>  	netif_napi_add(ndev, &priv->napi, emac_poll, EMAC_POLL_WEIGHT);
>  
>  	clk_enable(emac_clk);
> +	clk_enable(emac_phy_clk);
>  
>  	/* register the network device */
>  	SET_NETDEV_DEV(ndev, &pdev->dev);
> @@ -2783,6 +2795,7 @@ mdiobus_quit:
>  
>  netdev_reg_err:
>  mdio_alloc_err:
> +	clk_disable(emac_phy_clk);
>  	clk_disable(emac_clk);
>  no_irq_res:
>  	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> @@ -2790,6 +2803,7 @@ no_irq_res:
>  	iounmap(priv->remap_addr);
>  
>  probe_quit:
> +	clk_put(emac_phy_clk);
>  	clk_put(emac_clk);
>  	free_netdev(ndev);
>  	return rc;
> @@ -2821,7 +2835,9 @@ static int __devexit davinci_emac_remove(struct platform_device *pdev)
>  	free_netdev(ndev);
>  	iounmap(priv->remap_addr);
>  
> +	clk_disable(emac_phy_clk);
>  	clk_disable(emac_clk);
> +	clk_put(emac_phy_clk);
>  	clk_put(emac_clk);
>  
>  	return 0;
> @@ -2835,6 +2851,7 @@ static int davinci_emac_suspend(struct device *dev)
>  	if (netif_running(ndev))
>  		emac_dev_stop(ndev);
>  
> +	clk_disable(emac_phy_clk);
>  	clk_disable(emac_clk);
>  
>  	return 0;
> @@ -2846,6 +2863,7 @@ static int davinci_emac_resume(struct device *dev)
>  	struct net_device *ndev = platform_get_drvdata(pdev);
>  
>  	clk_enable(emac_clk);
> +	clk_enable(emac_phy_clk);
>  
>  	if (netif_running(ndev))
>  		emac_dev_open(ndev);
> -- 
> 1.6.2.4
>
> _______________________________________________
> Davinci-linux-open-source mailing list
> Davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
> http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source
