From: "Frank.Li@freescale.com" <Frank.Li@freescale.com>
Subject: RE: [PATCH 1/2] net: fec: optimize the clock management to save
 power
Date: Tue, 20 May 2014 13:21:12 +0000
Message-ID: <b6af0ca953484226893c10ba43e607a9@BLUPR03MB486.namprd03.prod.outlook.com>
References: <1400563371-3359-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0207.outbound.protection.outlook.com ([207.46.163.207]:45783
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753125AbaETNVV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 09:21:21 -0400
In-Reply-To: <1400563371-3359-1-git-send-email-b38611@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Fugang Duan [mailto:b38611@freescale.com]
> Sent: Tuesday, May 20, 2014 12:23 AM
> To: Li Frank-B20596; davem@davemloft.net
> Cc: netdev@vger.kernel.org; Duan Fugang-B38611; bhutchings@solarflare.com;
> stephen@networkplumber.org
> Subject: [PATCH 1/2] net: fec: optimize the clock management to save power
> 
> Add below clock management to save fec power:
> - After probe, disable all clocks incluing ipg, ahb, enet_out, ptp clock.
> - Open ethx interface enable necessary clocks.
>   Close ethx interface disable all clocks.
> 
> The patch also encapsulates the all enet clocks enable/disable
> to .fec_enet_clk_enable(), which can reduce the repetitional code in
> driver.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Acked-by: Frank Li <Frank.li@freescale.com>

> ---
>  drivers/net/ethernet/freescale/fec_main.c |  120 +++++++++++++-----------
> ----
>  1 files changed, 56 insertions(+), 64 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 8d69e43..99fb0dc 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1255,6 +1255,49 @@ static int fec_enet_mdio_write(struct mii_bus *bus,
> int mii_id, int regnum,
>  	return 0;
>  }
> 
> +static int fec_enet_clk_enable(struct net_device *ndev, bool enable) {
> +	struct fec_enet_private *fep = netdev_priv(ndev);
> +	int ret;
> +
> +	if (enable) {
> +		ret = clk_prepare_enable(fep->clk_ahb);
> +		if (ret)
> +			return ret;
> +		ret = clk_prepare_enable(fep->clk_ipg);
> +		if (ret)
> +			goto failed_clk_ipg;
> +		if (fep->clk_enet_out) {
> +			ret = clk_prepare_enable(fep->clk_enet_out);
> +			if (ret)
> +				goto failed_clk_enet_out;
> +		}
> +		if (fep->clk_ptp) {
> +			ret = clk_prepare_enable(fep->clk_ptp);
> +			if (ret)
> +				goto failed_clk_ptp;
> +		}
> +	} else {
> +		clk_disable_unprepare(fep->clk_ahb);
> +		clk_disable_unprepare(fep->clk_ipg);
> +		if (fep->clk_enet_out)
> +			clk_disable_unprepare(fep->clk_enet_out);
> +		if (fep->clk_ptp)
> +			clk_disable_unprepare(fep->clk_ptp);
> +	}
> +
> +	return 0;
> +failed_clk_ptp:
> +	if (fep->clk_enet_out)
> +		clk_disable_unprepare(fep->clk_enet_out);
> +failed_clk_enet_out:
> +		clk_disable_unprepare(fep->clk_ipg);
> +failed_clk_ipg:
> +		clk_disable_unprepare(fep->clk_ahb);
> +
> +	return ret;
> +}
> +
>  static int fec_enet_mii_probe(struct net_device *ndev)  {
>  	struct fec_enet_private *fep = netdev_priv(ndev); @@ -1773,6
> +1816,10 @@ fec_enet_open(struct net_device *ndev)
>  	struct fec_enet_private *fep = netdev_priv(ndev);
>  	int ret;
> 
> +	ret = fec_enet_clk_enable(ndev, true);
> +	if (ret)
> +		return ret;
> +
>  	/* I should reset the ring buffers here, but I don't yet know
>  	 * a simple way to do that.
>  	 */
> @@ -1811,6 +1858,7 @@ fec_enet_close(struct net_device *ndev)
>  		phy_disconnect(fep->phy_dev);
>  	}
> 
> +	fec_enet_clk_enable(ndev, false);
>  	fec_enet_free_buffers(ndev);
> 
>  	return 0;
> @@ -2164,26 +2212,10 @@ fec_probe(struct platform_device *pdev)
>  		fep->bufdesc_ex = 0;
>  	}
> 
> -	ret = clk_prepare_enable(fep->clk_ahb);
> +	ret = fec_enet_clk_enable(ndev, true);
>  	if (ret)
>  		goto failed_clk;
> 
> -	ret = clk_prepare_enable(fep->clk_ipg);
> -	if (ret)
> -		goto failed_clk_ipg;
> -
> -	if (fep->clk_enet_out) {
> -		ret = clk_prepare_enable(fep->clk_enet_out);
> -		if (ret)
> -			goto failed_clk_enet_out;
> -	}
> -
> -	if (fep->clk_ptp) {
> -		ret = clk_prepare_enable(fep->clk_ptp);
> -		if (ret)
> -			goto failed_clk_ptp;
> -	}
> -
>  	fep->reg_phy = devm_regulator_get(&pdev->dev, "phy");
>  	if (!IS_ERR(fep->reg_phy)) {
>  		ret = regulator_enable(fep->reg_phy); @@ -2225,6 +2257,7 @@
> fec_probe(struct platform_device *pdev)
> 
>  	/* Carrier starts down, phylib will bring it up */
>  	netif_carrier_off(ndev);
> +	fec_enet_clk_enable(ndev, false);
> 
>  	ret = register_netdev(ndev);
>  	if (ret)
> @@ -2244,15 +2277,7 @@ failed_init:
>  	if (fep->reg_phy)
>  		regulator_disable(fep->reg_phy);
>  failed_regulator:
> -	if (fep->clk_ptp)
> -		clk_disable_unprepare(fep->clk_ptp);
> -failed_clk_ptp:
> -	if (fep->clk_enet_out)
> -		clk_disable_unprepare(fep->clk_enet_out);
> -failed_clk_enet_out:
> -	clk_disable_unprepare(fep->clk_ipg);
> -failed_clk_ipg:
> -	clk_disable_unprepare(fep->clk_ahb);
> +	fec_enet_clk_enable(ndev, false);
>  failed_clk:
>  failed_ioremap:
>  	free_netdev(ndev);
> @@ -2272,14 +2297,9 @@ fec_drv_remove(struct platform_device *pdev)
>  	del_timer_sync(&fep->time_keep);
>  	if (fep->reg_phy)
>  		regulator_disable(fep->reg_phy);
> -	if (fep->clk_ptp)
> -		clk_disable_unprepare(fep->clk_ptp);
>  	if (fep->ptp_clock)
>  		ptp_clock_unregister(fep->ptp_clock);
> -	if (fep->clk_enet_out)
> -		clk_disable_unprepare(fep->clk_enet_out);
> -	clk_disable_unprepare(fep->clk_ipg);
> -	clk_disable_unprepare(fep->clk_ahb);
> +	fec_enet_clk_enable(ndev, false);
>  	free_netdev(ndev);
> 
>  	return 0;
> @@ -2296,12 +2316,7 @@ fec_suspend(struct device *dev)
>  		fec_stop(ndev);
>  		netif_device_detach(ndev);
>  	}
> -	if (fep->clk_ptp)
> -		clk_disable_unprepare(fep->clk_ptp);
> -	if (fep->clk_enet_out)
> -		clk_disable_unprepare(fep->clk_enet_out);
> -	clk_disable_unprepare(fep->clk_ipg);
> -	clk_disable_unprepare(fep->clk_ahb);
> +	fec_enet_clk_enable(ndev, false);
> 
>  	if (fep->reg_phy)
>  		regulator_disable(fep->reg_phy);
> @@ -2322,25 +2337,9 @@ fec_resume(struct device *dev)
>  			return ret;
>  	}
> 
> -	ret = clk_prepare_enable(fep->clk_ahb);
> -	if (ret)
> -		goto failed_clk_ahb;
> -
> -	ret = clk_prepare_enable(fep->clk_ipg);
> +	ret = fec_enet_clk_enable(ndev, true);
>  	if (ret)
> -		goto failed_clk_ipg;
> -
> -	if (fep->clk_enet_out) {
> -		ret = clk_prepare_enable(fep->clk_enet_out);
> -		if (ret)
> -			goto failed_clk_enet_out;
> -	}
> -
> -	if (fep->clk_ptp) {
> -		ret = clk_prepare_enable(fep->clk_ptp);
> -		if (ret)
> -			goto failed_clk_ptp;
> -	}
> +		goto failed_clk;
> 
>  	if (netif_running(ndev)) {
>  		fec_restart(ndev, fep->full_duplex);
> @@ -2349,14 +2348,7 @@ fec_resume(struct device *dev)
> 
>  	return 0;
> 
> -failed_clk_ptp:
> -	if (fep->clk_enet_out)
> -		clk_disable_unprepare(fep->clk_enet_out);
> -failed_clk_enet_out:
> -	clk_disable_unprepare(fep->clk_ipg);
> -failed_clk_ipg:
> -	clk_disable_unprepare(fep->clk_ahb);
> -failed_clk_ahb:
> +failed_clk:
>  	if (fep->reg_phy)
>  		regulator_disable(fep->reg_phy);
>  	return ret;
> --
> 1.7.8
