From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH RFC 5/5] net: macb: Adjust tx_clk when link speed changes
Date: Tue, 15 Oct 2013 09:54:21 +0200
Message-ID: <525CF4AD.1070304@atmel.com>
References: <1381795140-10792-1-git-send-email-soren.brinkmann@xilinx.com> <1381795140-10792-6-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>
To: Soren Brinkmann <soren.brinkmann@xilinx.com>,
	<netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381795140-10792-6-git-send-email-soren.brinkmann@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/10/2013 01:59, Soren Brinkmann :
> Adjust the ethernet clock according to the negotiated link speed.
>
> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>

I will need more time to study this one.

Moreover, I will have to add the "tx_clk" to every user of this driver 
before switchin to the addition of this clock.

Best regards,

> ---
>   drivers/net/ethernet/cadence/macb.c | 66 +++++++++++++++++++++++++++++++++++++
>   drivers/net/ethernet/cadence/macb.h |  1 +
>   2 files changed, 67 insertions(+)
>
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 603844b1d483..beb9fa863811 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -204,6 +204,49 @@ static int macb_mdio_reset(struct mii_bus *bus)
>   	return 0;
>   }
>
> +/**
> + * macb_set_tx_clk() - Set a clock to a new frequency
> + * @clk		Pointer to the clock to change
> + * @rate	New frequency in Hz
> + * @dev		Pointer to the struct net_device
> + */
> +static void macb_set_tx_clk(struct clk *clk, int speed, struct net_device *dev)
> +{
> +	long ferr;
> +	long rate;
> +	long rate_rounded;
> +
> +	switch (speed) {
> +	case SPEED_10:
> +		rate = 2500000;
> +		break;
> +	case SPEED_100:
> +		rate = 25000000;
> +		break;
> +	case SPEED_1000:
> +		rate = 125000000;
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	rate_rounded = clk_round_rate(clk, rate);
> +	if (rate_rounded < 0)
> +		return;
> +
> +	/* RGMII allows 50 ppm frequency error. Test and warn if this limit
> +	 * are not satisfied.
> +	 */
> +	ferr = abs(rate_rounded - rate);
> +	ferr = DIV_ROUND_UP(ferr, rate / 100000);
> +	if (ferr > 5)
> +		netdev_warn(dev, "unable to generate target frequency: %ld Hz\n",
> +				rate);
> +
> +	if (clk_set_rate(clk, rate_rounded))
> +		netdev_err(dev, "adjusting tx_clk failed.\n");
> +}
> +
>   static void macb_handle_link_change(struct net_device *dev)
>   {
>   	struct macb *bp = netdev_priv(dev);
> @@ -251,6 +294,9 @@ static void macb_handle_link_change(struct net_device *dev)
>
>   	spin_unlock_irqrestore(&bp->lock, flags);
>
> +	if (!IS_ERR(bp->tx_clk))
> +		macb_set_tx_clk(bp->tx_clk, phydev->speed, dev);
> +
>   	if (status_change) {
>   		if (phydev->link) {
>   			netif_carrier_on(dev);
> @@ -1805,6 +1851,8 @@ static int __init macb_probe(struct platform_device *pdev)
>   		goto err_out_free_dev;
>   	}
>
> +	bp->tx_clk = devm_clk_get(&pdev->dev, "tx_clk");
> +
>   	err = clk_prepare_enable(bp->pclk);
>   	if (err) {
>   		dev_err(&pdev->dev, "failed to enable pclk (%u)\n", err);
> @@ -1817,6 +1865,15 @@ static int __init macb_probe(struct platform_device *pdev)
>   		goto err_out_disable_pclk;
>   	}
>
> +	if (!IS_ERR(bp->tx_clk)) {
> +		err = clk_prepare_enable(bp->tx_clk);
> +		if (err) {
> +			dev_err(&pdev->dev, "failed to enable tx_clk (%u)\n",
> +					err);
> +			goto err_out_disable_hclk;
> +		}
> +	}
> +
>   	bp->regs = devm_ioremap(&pdev->dev, regs->start, resource_size(regs));
>   	if (!bp->regs) {
>   		dev_err(&pdev->dev, "failed to map registers, aborting.\n");
> @@ -1917,6 +1974,9 @@ static int __init macb_probe(struct platform_device *pdev)
>   err_out_unregister_netdev:
>   	unregister_netdev(dev);
>   err_out_disable_clocks:
> +	if (!IS_ERR(bp->tx_clk))
> +		clk_disable_unprepare(bp->tx_clk);
> +err_out_disable_hclk:
>   	clk_disable_unprepare(bp->hclk);
>   err_out_disable_pclk:
>   	clk_disable_unprepare(bp->pclk);
> @@ -1941,6 +2001,8 @@ static int __exit macb_remove(struct platform_device *pdev)
>   		kfree(bp->mii_bus->irq);
>   		mdiobus_free(bp->mii_bus);
>   		unregister_netdev(dev);
> +		if (!IS_ERR(bp->tx_clk))
> +			clk_disable_unprepare(bp->tx_clk);
>   		clk_disable_unprepare(bp->hclk);
>   		clk_disable_unprepare(bp->pclk);
>   		free_netdev(dev);
> @@ -1959,6 +2021,8 @@ static int macb_suspend(struct device *dev)
>   	netif_carrier_off(netdev);
>   	netif_device_detach(netdev);
>
> +	if (!IS_ERR(bp->tx_clk))
> +		clk_disable_unprepare(bp->tx_clk);
>   	clk_disable_unprepare(bp->hclk);
>   	clk_disable_unprepare(bp->pclk);
>
> @@ -1973,6 +2037,8 @@ static int macb_resume(struct device *dev)
>
>   	clk_prepare_enable(bp->pclk);
>   	clk_prepare_enable(bp->hclk);
> +	if (!IS_ERR(bp->tx_clk))
> +		clk_prepare_enable(bp->tx_clk);
>
>   	netif_device_attach(netdev);
>
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index f4076155bed7..51c02442160a 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -572,6 +572,7 @@ struct macb {
>   	struct platform_device	*pdev;
>   	struct clk		*pclk;
>   	struct clk		*hclk;
> +	struct clk		*tx_clk;
>   	struct net_device	*dev;
>   	struct napi_struct	napi;
>   	struct work_struct	tx_error_task;
>


-- 
Nicolas Ferre
