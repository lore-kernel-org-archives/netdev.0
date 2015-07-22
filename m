From: Duan Andy <fugang.duan@freescale.com>
Subject: RE: [PATCH v2 2/2] net: fec: introduce fec_ptp_stop and use in probe
 fail path
Date: Wed, 22 Jul 2015 01:58:43 +0000
Message-ID: <BLUPR03MB373972BFA572EE213A62B83F5830@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1437491462-28599-1-git-send-email-l.stach@pengutronix.de>
 <1437491462-28599-2-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Li Frank <Frank.Li@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"patchwork-lst@pengutronix.de" <patchwork-lst@pengutronix.de>
To: Lucas Stach <l.stach@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0134.outbound.protection.outlook.com ([157.56.111.134]:32000
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751769AbbGVB6o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 21:58:44 -0400
In-Reply-To: <1437491462-28599-2-git-send-email-l.stach@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <l.stach@pengutronix.de> Sent: Tuesday, July 21, 2015 11:11 PM
> To: David S. Miller
> Cc: Duan Fugang-B38611; Li Frank-B20596; netdev@vger.kernel.org;
> kernel@pengutronix.de; patchwork-lst@pengutronix.de
> Subject: [PATCH v2 2/2] net: fec: introduce fec_ptp_stop and use in probe
> fail path
> 
> This function frees resources and cancels delayed work item that have
> been initialized in fec_ptp_init().
> 
> Use this to do proper error handling if something goes wrong in probe
> function after fec_ptp_init has been called.
> 
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> ---
>  drivers/net/ethernet/freescale/fec.h      |  1 +
>  drivers/net/ethernet/freescale/fec_main.c |  5 ++---
> drivers/net/ethernet/freescale/fec_ptp.c  | 10 ++++++++++
>  3 files changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec.h
> b/drivers/net/ethernet/freescale/fec.h
> index 1eee73cccdf5..99d33e2d35e6 100644
> --- a/drivers/net/ethernet/freescale/fec.h
> +++ b/drivers/net/ethernet/freescale/fec.h
> @@ -562,6 +562,7 @@ struct fec_enet_private {  };
> 
>  void fec_ptp_init(struct platform_device *pdev);
> +void fec_ptp_stop(struct platform_device *pdev);
>  void fec_ptp_start_cyclecounter(struct net_device *ndev);  int
> fec_ptp_set(struct net_device *ndev, struct ifreq *ifr);  int
> fec_ptp_get(struct net_device *ndev, struct ifreq *ifr); diff --git
> a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index a7f1bdf718f8..32e3807c650e 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -3494,6 +3494,7 @@ failed_register:
>  failed_mii_init:
>  failed_irq:
>  failed_init:
> +	fec_ptp_stop(pdev);
>  	if (fep->reg_phy)
>  		regulator_disable(fep->reg_phy);
>  failed_regulator:
> @@ -3515,14 +3516,12 @@ fec_drv_remove(struct platform_device *pdev)
>  	struct net_device *ndev = platform_get_drvdata(pdev);
>  	struct fec_enet_private *fep = netdev_priv(ndev);
> 
> -	cancel_delayed_work_sync(&fep->time_keep);
>  	cancel_work_sync(&fep->tx_timeout_work);
> +	fec_ptp_stop(pdev);
>  	unregister_netdev(ndev);
>  	fec_enet_mii_remove(fep);
>  	if (fep->reg_phy)
>  		regulator_disable(fep->reg_phy);
> -	if (fep->ptp_clock)
> -		ptp_clock_unregister(fep->ptp_clock);
>  	of_node_put(fep->phy_node);
>  	free_netdev(ndev);
> 
> diff --git a/drivers/net/ethernet/freescale/fec_ptp.c
> b/drivers/net/ethernet/freescale/fec_ptp.c
> index a15663ad7f5e..f457a23d0bfb 100644
> --- a/drivers/net/ethernet/freescale/fec_ptp.c
> +++ b/drivers/net/ethernet/freescale/fec_ptp.c
> @@ -604,6 +604,16 @@ void fec_ptp_init(struct platform_device *pdev)
>  	schedule_delayed_work(&fep->time_keep, HZ);  }
> 
> +void fec_ptp_stop(struct platform_device *pdev) {
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +	struct fec_enet_private *fep = netdev_priv(ndev);
> +
> +	cancel_delayed_work_sync(&fep->time_keep);
> +	if (fep->ptp_clock)
> +		ptp_clock_unregister(fep->ptp_clock);
> +}
> +
>  /**
>   * fec_ptp_check_pps_event
>   * @fep: the fec_enet_private structure handle
> --
> 2.1.4

Acked-by: Fugang Duan <B38611@freescale.com>
