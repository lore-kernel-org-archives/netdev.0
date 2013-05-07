From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH v4 1/1 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Tue, 07 May 2013 11:58:48 +0200
Message-ID: <1367920728.4126.32.camel@weser.hi.pengutronix.de>
References: <1367898205-6272-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, r.schwebel@pengutronix.de,
	davem@davemloft.net, netdev@vger.kernel.org, festevam@gmail.com,
	shawn.guo@linaro.org, lznuaa@gmail.com
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47362 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021Ab3EGKAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 06:00:12 -0400
In-Reply-To: <1367898205-6272-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, den 07.05.2013, 11:43 +0800 schrieb Frank Li:
> reproduce steps
>  1. flood ping from other machine
>  	ping -f -s 41000 IP
>  2. run below script
>     while [ 1 ]; do ethtool -s eth0 autoneg off;
>     sleep 3;ethtool -s eth0 autoneg on; sleep 4; done;
> 
> You can see oops in one hour.
> 
> The reason is fec_restart clear BD but NAPI may use it.
> The solution is disable NAPI and stop xmit when reset BD.
> disable NAPI may sleep, so fec_restart can't be call in
> atomic context.
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
One minor nitpick below, otherwise
Reviewed-by: Lucas Stach <l.stach@pengutronix.de>
Tested-by: Lucas Stach <l.stach@pengutronix.de>

Could this patch please be marked as a candidate for the 3.9 stable
tree? It fixes a real and severe problem for me, as I seem to be able to
trigger the bug much more easily than Frank.

> ---
> Change from v1 to v2
>  * Add netif_tx_lock(ndev) to avoid xmit runing when reset hardware
> Change from v2 to v3
>  * Move put real statements after function variable declarations according to David's comments
>  * Remove lock in adjust_link according to Lucas Stach's comments
> Change from v3 to v4
>  * rebase to latest net/master
>  * remove hw_lock because not used again
>  * reduce delay work to 0
>  * group delay work related feild to one structure
>  * call netif_device_detach() in fec_restart
> 
>  drivers/net/ethernet/freescale/fec.h      |   10 ++++--
>  drivers/net/ethernet/freescale/fec_main.c |   44 +++++++++++++++++++++-------
>  2 files changed, 39 insertions(+), 15 deletions(-)
> 
[...]
>  
>  static void
> @@ -644,8 +658,22 @@ fec_timeout(struct net_device *ndev)
>  
>  	ndev->stats.tx_errors++;
>  
> -	fec_restart(ndev, fep->full_duplex);
> -	netif_wake_queue(ndev);
> +	fep->delay_work.timeout = 1;
I would like to see a proper true/false used in conjunction with the
bool data type.

> +	schedule_delayed_work(&(fep->delay_work.delay_work), 0);
> +}
> +
> +static void fec_enet_work(struct work_struct *work)
> +{
> +	struct fec_enet_private *fep =
> +		container_of(work,
> +			     struct fec_enet_private,
> +			     delay_work.delay_work.work);
> +
> +	if (fep->delay_work.timeout) {
> +		fep->delay_work.timeout = 0;
Same as above.

> +		fec_restart(fep->netdev, fep->full_duplex);
> +		netif_wake_queue(fep->netdev);
> +	}
>  }
>  
[...]
-- 
Pengutronix e.K.                           | Lucas Stach                 |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-5076 |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
