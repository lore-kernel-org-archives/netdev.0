From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] bonding: replace system timer with work queue
Date: Wed, 28 Feb 2007 23:35:12 -0800
Message-ID: <20070228233512.d2d275a2.akpm@linux-foundation.org>
References: <Pine.LNX.4.61.0702281000050.9439@tm8103-a.perex-int.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Oleg Nesterov <oleg@tv-sign.ru>, netdev@vger.kernel.org
To: Jaroslav Kysela <perex@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:60205 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933086AbXCAHf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 02:35:29 -0500
In-Reply-To: <Pine.LNX.4.61.0702281000050.9439@tm8103-a.perex-int.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Feb 2007 10:12:01 +0100 (CET) Jaroslav Kysela <perex@suse.cz> wrote:

> Hi,
> 
> 	please, review and apply to mm tree for further testing. The patch 
> is also available at 
> ftp://ftp.alsa-project.org/pub/kernel-patches/bonding-workqueue.patch .

Please cc netdev@vger.kernel.org on net-related patches, thanks.

> 					Thank you,
> 						Jaroslav
> 
> ==================
> bonding: replace system timer with work queue
> 
> This patch replaces system timer with work queue in monitor functions.
> The reason for this change is that bonding handlers calls various
> sleeping functions from the timer handler which is not allowed.

Which sleeping functions?  I'd have expected the kernel to spew runtime
warnings when this happens, but I don't recall any such reports.


> Because we cannot share the main workqueue threads (rtnl_lock is used
> also in linkwatch_event) - new bond workqueue thread is created.
> 
> Signed-off-by: Jaroslav Kysela <perex@suse.cz>
> 
> diff -rupN linux-2.6.20.orig/drivers/net/bonding/bond_3ad.c linux-2.6.20/drivers/net/bonding/bond_3ad.c
> --- linux-2.6.20.orig/drivers/net/bonding/bond_3ad.c	2007-02-04 19:44:54.000000000 +0100
> +++ linux-2.6.20/drivers/net/bonding/bond_3ad.c	2007-02-28 09:19:43.831369202 +0100
> @@ -2097,8 +2097,10 @@ void bond_3ad_unbind_slave(struct slave 
>   * times out, and it selects an aggregator for the ports that are yet not
>   * related to any aggregator, and selects the active aggregator for a bond.
>   */
> -void bond_3ad_state_machine_handler(struct bonding *bond)
> +void bond_3ad_state_machine_handler(struct work_struct *work)
>  {
> +	struct ad_bond_info *ad_info = container_of(work, struct ad_bond_info, ad_work.work);
> +	struct bonding *bond = (struct bonding *)((char *)ad_info - offsetof(struct bonding, ad_info));

We can use containers_of here too?

> -void bond_alb_monitor(struct bonding *bond)
> +void bond_alb_monitor(struct work_struct *work)
>  {
> -	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
> +	struct alb_bond_info *bond_info = container_of(work, struct alb_bond_info, alb_work.work);
> +	struct bonding *bond = (struct bonding *)((char *)bond_info - offsetof(struct bonding, alb_info));

And here.

> +		cancel_rearming_delayed_workqueue(bond_wq, &(BOND_AD_INFO(bond).ad_work));
>  		break;
>  	case BOND_MODE_TLB:
>  	case BOND_MODE_ALB:
> -		del_timer_sync(&(BOND_ALB_INFO(bond).alb_timer));
> +		cancel_rearming_delayed_workqueue(bond_wq, &(BOND_ALB_INFO(bond).alb_work));
>  		break;
>  	default:
>  		break;
> @@ -4289,6 +4272,14 @@ static int bond_init(struct net_device *
>  	rwlock_init(&bond->lock);
>  	rwlock_init(&bond->curr_slave_lock);
>  
> +	/* initialize work */
> +	INIT_DELAYED_WORK(&bond->mii_work, (void *)&bond_mii_monitor);
> +	if (params->mode == BOND_MODE_ACTIVEBACKUP) {
> +	        INIT_DELAYED_WORK(&bond->arp_work, (void *)&bond_activebackup_arp_mon);
> +	} else {
> +		INIT_DELAYED_WORK(&bond->arp_work, (void *)&bond_loadbalance_arp_mon);
> +	}

Can we lose the unneeded braces, the unneeded typecasts and fit the code
into 80 cols?

<does all that>

yup.

>  	bond->params = *params; /* copy params struct */
>  
>  	/* Initialize pointers */
> @@ -4782,6 +4773,12 @@ static int __init bonding_init(void)
>  			goto err;
>  	}
>  
> +	bond_wq = create_singlethread_workqueue("bond");
> +	if (bond_wq == NULL) {
> +		res = -ENOMEM;
> +		goto err;
> +	}
> +
>  	res = bond_create_sysfs();
>  	if (res)
>  		goto err;
> @@ -4807,6 +4804,7 @@ static void __exit bonding_exit(void)
>  
>  	rtnl_lock();
>  	bond_free_all();
> +	destroy_workqueue(bond_wq);
>  	bond_destroy_sysfs();
>  	rtnl_unlock();

Are you sure that all pending delayed works have been cancelled when we
destroy this workqueue?


