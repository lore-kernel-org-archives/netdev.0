From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netconsole: don't call __netpoll_cleanup() while atomic
Date: Mon, 11 Mar 2013 07:38:56 -0400
Message-ID: <20130311113856.GC12682@hmsreliant.think-freely.org>
References: <1362997308-5834-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, amwang@redhat.com, davem@davemloft.net
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38609 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735Ab3CKLjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 07:39:00 -0400
Content-Disposition: inline
In-Reply-To: <1362997308-5834-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 11, 2013 at 11:21:48AM +0100, Veaceslav Falico wrote:
> __netpoll_cleanup() is called in netconsole_netdev_event() while holding a
> spinlock. Release/acquire the spinlock before/after it and restart the
> loop. Also, disable the netconsole completely, because we won't have chance
> after the restart of the loop, and might end up in a situation where
> nt->enabled == 1 and nt->np.dev == NULL.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>  drivers/net/netconsole.c |   15 +++++++++------
>  1 files changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> index 37add21..59ac143 100644
> --- a/drivers/net/netconsole.c
> +++ b/drivers/net/netconsole.c
> @@ -666,6 +666,7 @@ static int netconsole_netdev_event(struct notifier_block *this,
>  		goto done;
>  
>  	spin_lock_irqsave(&target_list_lock, flags);
> +restart:
>  	list_for_each_entry(nt, &target_list, list) {
>  		netconsole_target_get(nt);
>  		if (nt->np.dev == dev) {
> @@ -678,15 +679,17 @@ static int netconsole_netdev_event(struct notifier_block *this,
>  			case NETDEV_UNREGISTER:
>  				/*
>  				 * rtnl_lock already held
> +				 * we might sleep in __netpoll_cleanup()
>  				 */
> -				if (nt->np.dev) {
> -					__netpoll_cleanup(&nt->np);
> -					dev_put(nt->np.dev);
> -					nt->np.dev = NULL;
> -				}
> +				spin_unlock_irqrestore(&target_list_lock, flags);
> +				__netpoll_cleanup(&nt->np);
> +				spin_lock_irqsave(&target_list_lock, flags);
> +				dev_put(nt->np.dev);
> +				nt->np.dev = NULL;
>  				nt->enabled = 0;
>  				stopped = true;
> -				break;
> +				netconsole_target_put(nt);
> +				goto restart;
>  			}
>  		}
>  		netconsole_target_put(nt);
> -- 
> 1.7.1
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
