From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 2/6] qlge: Stand-up card should not report supporting wol.
Date: Fri, 29 Jun 2012 23:37:47 +0200
Message-ID: <20120629213747.GB19152@electric-eye.fr.zoreil.com>
References: <1340994290-28832-1-git-send-email-jitendra.kalsaria@qlogic.com> <1340994290-28832-3-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, Ron@linux-zupk.site,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40306 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840Ab2F2Vsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 17:48:47 -0400
Content-Disposition: inline
In-Reply-To: <1340994290-28832-3-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jitendra Kalsaria <jitendra.kalsaria@qlogic.com> :
> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> 
> Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> ---
>  drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c |   43 ++++++++++++++--------
>  1 files changed, 27 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
> index 8e2c2a7..81672f5 100644
> --- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
> +++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
> @@ -388,10 +388,14 @@ static void ql_get_drvinfo(struct net_device *ndev,
>  static void ql_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
>  {
>  	struct ql_adapter *qdev = netdev_priv(ndev);
> -	/* What we support. */
> -	wol->supported = WAKE_MAGIC;
> -	/* What we've currently got set. */
> -	wol->wolopts = qdev->wol;
> +
> +	if (qdev->pdev->subsystem_device == 0x0068 ||
> +			qdev->pdev->subsystem_device == 0x0180) {
> +		/* What we support. */
> +		wol->supported = WAKE_MAGIC;
> +		/* What we've currently got set. */
> +		wol->wolopts = qdev->wol;
> +	}

	unsigned short ssys_dev = qdev->pdev->subsystem_device;

	if (ssys_dev == 0x0068 || ssys_dev == 0x0180) {
		wol->supported = WAKE_MAGIC;
		wol->wolopts = qdev->wol;
	}
>  }
>  
>  static int ql_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
> @@ -399,19 +403,26 @@ static int ql_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
>  	struct ql_adapter *qdev = netdev_priv(ndev);
>  	int status;
>  
> -	if (wol->wolopts & ~WAKE_MAGIC)
> -		return -EINVAL;
> -	qdev->wol = wol->wolopts;
> -
> -	netif_info(qdev, drv, qdev->ndev, "Set wol option 0x%x\n", qdev->wol);
> -	if (!qdev->wol) {
> -		u32 wol = 0;
> -		status = ql_mb_wol_mode(qdev, wol);
> -		netif_err(qdev, drv, qdev->ndev, "WOL %s (wol code 0x%x)\n",
> -			  status == 0 ? "cleared successfully" : "clear failed",
> -			  wol);
> +	if (qdev->pdev->subsystem_device == 0x0068 ||
> +			qdev->pdev->subsystem_device == 0x0180) {

See above.

> +		if (wol->wolopts & ~WAKE_MAGIC)
> +			return -EINVAL;
> +		qdev->wol = wol->wolopts;
> +
> +		netif_info(qdev, drv, qdev->ndev,
> +				"Set wol option 0x%x\n", qdev->wol);

qdev->ndev == ndev, right ?

> +		if (!qdev->wol) {
> +			u32 wol = 0;
> +			status = ql_mb_wol_mode(qdev, wol);

Missing empty line.

status should be declared here.

> +			netif_err(qdev, drv, qdev->ndev,
> +			"WOL %s (wol code 0x%x)\n",
> +			status == 0 ? "cleared successfully" : "clear failed",
> +			wol);

- broken indent
- netif_err(... "cleared successfully" ...)

> +		}
> +	} else {
> +		netif_info(qdev, drv, qdev->ndev,
> +				"WOL is not supported on stand-up card\n");
>  	}
> -
>  	return 0;

If I read things correctly, WAKE_MAGIC can not be cleared and it makes no
difference on the status code. It should be fixed.

-- 
Ueimor
