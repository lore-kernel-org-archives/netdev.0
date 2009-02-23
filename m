From: David Miller <davem@davemloft.net>
Subject: Re: Subject: [PATCH 001/001] bonding: add support for netdev link
 events.
Date: Mon, 23 Feb 2009 15:47:03 -0800 (PST)
Message-ID: <20090223.154703.114857595.davem@davemloft.net>
References: <97949e3e0902231201n4781d2c4q261bfc62ba1cb7fc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41532
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751910AbZBWXrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 18:47:22 -0500
In-Reply-To: <97949e3e0902231201n4781d2c4q261bfc62ba1cb7fc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laurent Chavey <chavey@google.com>
Date: Mon, 23 Feb 2009 12:01:38 -0800

> From: Laurent Chavey <chavey@google.com>
> 
> kernel:2.6.28
> 
> Add a netdev link event handler so the bond state machine can react to
> link state changes using async netdev events rather than having to
> use mii monitor polling.
> 
> Signed-off-by: Laurent Chavey <chavey@google.com>

Please post networking patches to netdev@vger.kernel.org,
thank you.

> ---
> 
> 
> --- linux-2.6.28.org/drivers/net/bonding/bond_main.c	2008-12-24
> 15:26:37.000000000 -0800
> +++ linux-2.6.28/drivers/net/bonding/bond_main.c	2009-02-23
> 10:59:12.000000000 -0800
> @@ -2477,7 +2477,11 @@ void bond_mii_monitor(struct work_struct
>  	}
> 
>  re_arm:
> -	if (bond->params.miimon)
> +	 /* A netdev event may have set some delay work, in that
> +	  * case do not remove it and let it take priority.
> +	  */
> +	if  (bond->params.miimon && !bond->kill_timers &&
> +	     !delayed_work_pending(&bond->mii_work))
>  		queue_delayed_work(bond->wq, &bond->mii_work,
>  				   msecs_to_jiffies(bond->params.miimon));
>  out:
> @@ -3521,6 +3525,33 @@ static int bond_master_netdev_event(unsi
>  	return NOTIFY_DONE;
>  }
> 
> +static inline void bond_netdev_link_event(struct bonding *bond)
> +{
> +	if (!bond->params.use_carrier)
> +		return;
> +
> +	write_lock_bh(&bond->lock);
> +	if (bond->kill_timers) {
> +		write_unlock_bh(&bond->lock);
> +		return;
> +	}
> +
> +	if (delayed_work_pending(&bond->mii_work)) {
> +		/* cancel_delayed_work(&bond->mii_work); calls del_timer_sync().
> +		 * We implement a version that does not call del_timer_sync().
> +		 *  if an active timer is found, then the job is not on the WQ.
> +		 *    we clear the PENDING bit, so the job can be added later
> +		 *  else the job maybe done (PENDING bit is clear) or it maybe
> +		 *    running, then we do not care and do only  add a new job
> +		 *    if the job has completed.
> +		 */
> +		if (del_timer(&bond->mii_work.timer))
> +			work_clear_pending(&bond->mii_work.work);
> +	}
> +	queue_delayed_work(bond->wq, &bond->mii_work, 0);
> +	write_unlock_bh(&bond->lock);
> +}
> +
>  static int bond_slave_netdev_event(unsigned long event, struct
> net_device *slave_dev)
>  {
>  	struct net_device *bond_dev = slave_dev->master;
> @@ -3536,15 +3567,17 @@ static int bond_slave_netdev_event(unsig
>  		}
>  		break;
>  	case NETDEV_CHANGE:
> -		/*
> -		 * TODO: is this what we get if somebody
> -		 * sets up a hierarchical bond, then rmmod's
> -		 * one of the slave bonding devices?
> -		 */
> -		break;
> +	case NETDEV_UP:
>  	case NETDEV_DOWN:
> +		if (bond_dev && bond_dev->priv &&
> +		    ARPHRD_ETHER == slave_dev->type) {
> +			bond_netdev_link_event(bond_dev->priv);
> +		}
> +
>  		/*
> -		 * ... Or is it this?
> +		 * TODO: do we get a NETDEV_CHANGE or NETDEV_DOWN event
> +		 * if somebody sets up a hierarchical bond, then rmmod's
> +		 * one of the slave bonding devices?
>  		 */
>  		break;
>  	case NETDEV_CHANGEMTU:
> @@ -5196,4 +5229,3 @@ MODULE_SUPPORTED_DEVICE("most ethernet d
>   *  tab-width: 8
>   * End:
>   */
> -
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
