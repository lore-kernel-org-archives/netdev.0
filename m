From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Thu, 12 Jun 2008 06:13:34 +0000
Message-ID: <20080612061334.GA4005@ff.dom.local>
References: <20080610.224023.116817726.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.179]:63473 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbYFLGJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 02:09:28 -0400
Received: by ik-out-1112.google.com with SMTP id c28so2477331ika.5
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2008 23:09:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080610.224023.116817726.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-06-2008 07:40, David Miller wrote:
...
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 4b46e68..48ed410 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -5907,12 +5907,7 @@ bnx2_close(struct net_device *dev)
>  	struct bnx2 *bp = netdev_priv(dev);
>  	u32 reset_code;
>  
> -	/* Calling flush_scheduled_work() may deadlock because
> -	 * linkwatch_event() may be on the workqueue and it will try to get
> -	 * the rtnl_lock which we are holding.
> -	 */
> -	while (bp->in_reset_task)
> -		msleep(1);
> +	cancel_work_sync(&bp->reset_task);

It seems after this change bp->in_reset_task could be removed totally
from the code.

...
> diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
> index 4e28002..5c71098 100644
> --- a/drivers/net/smc911x.c
> +++ b/drivers/net/smc911x.c
> @@ -1531,16 +1531,8 @@ static int smc911x_close(struct net_device *dev)
>  	if (lp->phy_type != 0) {
>  		/* We need to ensure that no calls to
>  		 * smc911x_phy_configure are pending.
> -
> -		 * flush_scheduled_work() cannot be called because we
> -		 * are running with the netlink semaphore held (from
> -		 * devinet_ioctl()) and the pending work queue
> -		 * contains linkwatch_event() (scheduled by
> -		 * netif_carrier_off() above). linkwatch_event() also
> -		 * wants the netlink semaphore.
>  		 */
> -		while (lp->work_pending)
> -			schedule();
> +		cancel_work_sync(&lp->phy_configure);

... likewise lp->work_pending,


>  		smc911x_phy_powerdown(dev, lp->mii.phy_id);
>  	}
>  
> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> index a188e33..5dbe4d3 100644
> --- a/drivers/net/smc91x.c
> +++ b/drivers/net/smc91x.c
> @@ -1016,15 +1016,8 @@ static void smc_phy_powerdown(struct net_device *dev)
>  
>  	/* We need to ensure that no calls to smc_phy_configure are
>  	   pending.
> -
> -	   flush_scheduled_work() cannot be called because we are
> -	   running with the netlink semaphore held (from
> -	   devinet_ioctl()) and the pending work queue contains
> -	   linkwatch_event() (scheduled by netif_carrier_off()
> -	   above). linkwatch_event() also wants the netlink semaphore.
>  	*/
> -	while(lp->work_pending)
> -		yield();
> +	cancel_work_sync(&lp->phy_configure);

... likewise lp->work_pending.

...
> diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
> index 20d387f..57b800f 100644
> --- a/drivers/net/wireless/hostap/hostap_main.c
> +++ b/drivers/net/wireless/hostap/hostap_main.c
> @@ -682,7 +682,11 @@ static int prism2_close(struct net_device *dev)
>  		netif_device_detach(dev);
>  	}
>  
> -	flush_scheduled_work();
> +	cancel_work_sync(&local->reset_queue);
> +	cancel_work_sync(&local->set_multicast_list_queue);
> +	cancel_work_sync(&local->set_tim_queue);
> +	cancel_work_sync(&local->info_queue);

local->info_queue probably needs some #ifndef like in hostap_info_init()
or could be skipped here at all (waiting for remove).

> +	cancel_work_sync(&local->comms_qual_update);
>  
>  	module_put(local->hw_module);

Regards,
Jarek P.
