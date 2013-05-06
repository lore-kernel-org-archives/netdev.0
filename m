From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH v3 1/1 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Mon, 06 May 2013 11:19:33 +0200
Message-ID: <1367831973.4126.16.camel@weser.hi.pengutronix.de>
References: <1367456138-27172-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, r.schwebel@pengutronix.de,
	davem@davemloft.net, netdev@vger.kernel.org, festevam@gmail.com,
	shawn.guo@linaro.org, lznuaa@gmail.com
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53135 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502Ab3EFJUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 05:20:55 -0400
In-Reply-To: <1367456138-27172-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Frank,

Am Donnerstag, den 02.05.2013, 08:55 +0800 schrieb Frank Li:
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
> ---
> Change from v1 to v2
>  * Add netif_tx_lock(ndev) to avoid xmit runing when reset hardware
> Change from v2 to v3
>  * Move put real statements after function variable declarations according to David's comments
>  * Remove lock in adjust_link according to Lucas Stach's comments
>  
>  drivers/net/ethernet/freescale/fec.c |   42 +++++++++++++++++++++++++---------
>  drivers/net/ethernet/freescale/fec.h |    3 +-
>  2 files changed, 33 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
> index 73195f6..5a9345c 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -407,6 +407,12 @@ fec_restart(struct net_device *ndev, int duplex)
>  	u32 rcntl = OPT_FRAME_SIZE | 0x04;
>  	u32 ecntl = 0x2; /* ETHEREN */
>  
> +	if (netif_running(ndev)) {
> +		napi_disable(&fep->napi);
> +		netif_stop_queue(ndev);
> +		netif_tx_lock(ndev);
> +	}
> +
You did not address the comment from Ben Hutchings here. To make sure we
are not triggering the netdev watchdog immediately when calling
netif_stop_queue() we must call netif_device_detach() when entering the
fec_restart and netif_device_attach() when leaving.

fec_restart gets called when duplex or phy speed changes, not only in
response to a link up/down change.

>  	/* Whack a reset.  We should wait for this. */
>  	writel(1, fep->hwp + FEC_ECNTRL);
>  	udelay(10);
> @@ -559,6 +565,12 @@ fec_restart(struct net_device *ndev, int duplex)
>  
>  	/* Enable interrupts we wish to service */
>  	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
> +
> +	if (netif_running(ndev)) {
> +		napi_enable(&fep->napi);
> +		netif_wake_queue(ndev);
> +		netif_tx_unlock(ndev);
> +	}
>  }
>  
>  static void
> @@ -598,8 +610,20 @@ fec_timeout(struct net_device *ndev)
>  
>  	ndev->stats.tx_errors++;
>  
> -	fec_restart(ndev, fep->full_duplex);
> -	netif_wake_queue(ndev);
> +	fep->timeout = 1;
> +	schedule_delayed_work(&fep->delay_work, msecs_to_jiffies(1));
> +}
Okay, I understand you want to reuse this workqueue to do other things
which might require delayed work so a delay workqueue is fine, but
really use a delay of 0 here.

schedule_delayed_work() internally calls down to queue_delayed_work_on()
where the documentation states: "If delay is zero and dwork is idle, it
will be scheduled for immediate execution.", so this is the right thing
to do here.

> +
> +static void fec_enet_work(struct work_struct *work)
> +{
> +	struct fec_enet_private *fep =
> +		container_of(work, struct fec_enet_private, delay_work.work);
> +
> +	if (fep->timeout) {
> +		fep->timeout = 0;
> +		fec_restart(fep->netdev, fep->full_duplex);
> +		netif_wake_queue(fep->netdev);
> +	}
>  }
>  
>  static void
> @@ -970,16 +994,12 @@ static void fec_enet_adjust_link(struct net_device *ndev)
>  {
>  	struct fec_enet_private *fep = netdev_priv(ndev);
>  	struct phy_device *phy_dev = fep->phy_dev;
> -	unsigned long flags;
> -
>  	int status_change = 0;
>  
> -	spin_lock_irqsave(&fep->hw_lock, flags);
> -
>  	/* Prevent a state halted on mii error */
>  	if (fep->mii_timeout && phy_dev->state == PHY_HALTED) {
>  		phy_dev->state = PHY_RESUMING;
> -		goto spin_unlock;
> +		goto exit;
If we bail out here there is zero chance that we detect a link change,
so drop the label and just return here.

>  	}
>  
>  	if (phy_dev->link) {
> @@ -995,7 +1015,6 @@ static void fec_enet_adjust_link(struct net_device *ndev)
>  			fep->speed = phy_dev->speed;
>  			status_change = 1;
>  		}
> -
Unnecessary whitespace change.

>  		/* if any of the above changed restart the FEC */
>  		if (status_change)
>  			fec_restart(ndev, phy_dev->duplex);
> @@ -1007,11 +1026,10 @@ static void fec_enet_adjust_link(struct net_device *ndev)
>  		}
>  	}
>  
> -spin_unlock:
> -	spin_unlock_irqrestore(&fep->hw_lock, flags);
> -
You are eliminating all users of the hw_lock, so please remove it
altogether. Eliminate it from the fec_enet_private struct and the init
in fec_enet_init().

> +exit:
>  	if (status_change)
>  		phy_print_status(phy_dev);
> +
>  }
>  
>  static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
> @@ -1882,6 +1900,7 @@ fec_probe(struct platform_device *pdev)
>  	if (ret)
>  		goto failed_register;
>  
> +	INIT_DELAYED_WORK(&fep->delay_work, fec_enet_work);
>  	return 0;
>  
>  failed_register:
> @@ -1918,6 +1937,7 @@ fec_drv_remove(struct platform_device *pdev)
>  	struct resource *r;
>  	int i;
>  
> +	cancel_delayed_work_sync(&fep->delay_work);
>  	unregister_netdev(ndev);
>  	fec_enet_mii_remove(fep);
>  	del_timer_sync(&fep->time_keep);
> diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
> index eb43729..a367b21 100644
> --- a/drivers/net/ethernet/freescale/fec.h
> +++ b/drivers/net/ethernet/freescale/fec.h
> @@ -260,7 +260,8 @@ struct fec_enet_private {
>  	int hwts_rx_en;
>  	int hwts_tx_en;
>  	struct timer_list time_keep;
> -
> +	struct delayed_work delay_work;
> +	int timeout;
I suspect you are going to add more variables like this in the future if
you are using the workqueue more extensively. This is a massive
pollution of the fec_enet_private struct. Please make this a bitfield
with a proper define for the timeout, so we can reuse one variable for
different tasks, or even split this out into it's own struct for the
delayed tasks.

>  };
>  
>  void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev);

-- 
Pengutronix e.K.                           | Lucas Stach                 |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-5076 |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
