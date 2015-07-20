From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: fec: fix runtime PM when probing MII bus
Date: Tue, 21 Jul 2015 01:52:24 +0200
Message-ID: <20150720235224.GA22909@lunn.ch>
References: <1437400094-11453-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Duan Andy <fugang.duan@freescale.com>,
	Frank Li <Frank.Li@freescale.com>, netdev@vger.kernel.org,
	kernel@pengutronix.de, patchwork-lst@pengutronix.de
To: Lucas Stach <l.stach@pengutronix.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44611 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756510AbbGTX7B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2015 19:59:01 -0400
Content-Disposition: inline
In-Reply-To: <1437400094-11453-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 20, 2015 at 03:48:14PM +0200, Lucas Stach wrote:
> In the case where there is no "mdio" bus specified in the devicetree a plain
> mdiobus_register() will be called, which tries to probe the connected PHY
> by doing mdio_read() on the bus.
> Since 6c3e921b18ed (net: fec: Ensure clocks are enabled while using mdio bus)
> this needs runtime PM to be available, but as RPM is only later set up in the
> FEC probe function those calls will fail, which in turn prevents the FEC
> driver to be registered successfully.
> 
> Fix this by moving the RPM setup calls before the MII bus probing.
> 
> Also move autosuspend init calls before runtime_pm_enable() so that the RPM
> callbacks aren't invoked several times during the probe function.
> 
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> ---
> The offending commit got in with v4.2-rc3, so this should be applied as
> a fix for 4.2.

Hi David

You emailed saying you had reverted 6c3e921b18ed, but it is still in
net-next/master. If you are not going to revert it, please apply this
patch. I've tested it on my platform as well and it works for me.

If you still plan to revert 6c3e921b18ed, then i will squash this
patch into mine and resubmit.

Thanks
	Andrew

> ---
>  drivers/net/ethernet/freescale/fec_main.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 42e20e5385ac..349365d85b92 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -3431,6 +3431,11 @@ fec_probe(struct platform_device *pdev)
>  		fep->reg_phy = NULL;
>  	}
>  
> +	pm_runtime_set_autosuspend_delay(&pdev->dev, FEC_MDIO_PM_TIMEOUT);
> +	pm_runtime_use_autosuspend(&pdev->dev);
> +	pm_runtime_set_active(&pdev->dev);
> +	pm_runtime_enable(&pdev->dev);
> +
>  	fec_reset_phy(pdev);
>  
>  	if (fep->bufdesc_ex)
> @@ -3465,8 +3470,6 @@ fec_probe(struct platform_device *pdev)
>  	netif_carrier_off(ndev);
>  	fec_enet_clk_enable(ndev, false);
>  	pinctrl_pm_select_sleep_state(&pdev->dev);
> -	pm_runtime_set_active(&pdev->dev);
> -	pm_runtime_enable(&pdev->dev);
>  
>  	ret = register_netdev(ndev);
>  	if (ret)
> @@ -3481,8 +3484,6 @@ fec_probe(struct platform_device *pdev)
>  	fep->rx_copybreak = COPYBREAK_DEFAULT;
>  	INIT_WORK(&fep->tx_timeout_work, fec_enet_timeout_work);
>  
> -	pm_runtime_set_autosuspend_delay(&pdev->dev, FEC_MDIO_PM_TIMEOUT);
> -	pm_runtime_use_autosuspend(&pdev->dev);
>  	pm_runtime_mark_last_busy(&pdev->dev);
>  	pm_runtime_put_autosuspend(&pdev->dev);
>  
> -- 
> 2.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
