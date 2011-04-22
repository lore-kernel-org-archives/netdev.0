From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netconsole: prevent deadlock when removing net driver
 that netconsole is using
Date: Fri, 22 Apr 2011 10:44:40 -0400
Message-ID: <20110422144439.GA5610@neilslaptop.think-freely.org>
References: <1303481216-10348-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58518 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248Ab1DVOp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 10:45:27 -0400
Content-Disposition: inline
In-Reply-To: <1303481216-10348-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 22, 2011 at 10:06:56AM -0400, Neil Horman wrote:
> A deadlock was reported to me recently that occured when netconsole was being
> used in a virtual guest.  If the virtio_net driver was removed while netconsole
> was setup to use an interface that was driven by that driver, the guest
> deadlocked.  No backtrace was provided because netconsole was the only console
> configured, but it became clear pretty quickly what the problem was.  In
> netconsole_netdev_event, if we get an unregister event, we call
> __netpoll_cleanup with the target_list_lock held and irqs disabled.
> __netpoll_cleanup can, if pending netpoll packets are waiting call
> cancel_delayed_work_sync, which is a sleeping path.  the might_sleep call in
> that path gets triggered, causing a console warning to be issued.  The
> netconsole write handler of course tries to take the target_list_lock again,
> which we already hold, causing deadlock.
> 
> The fix is pretty striaghtforward.  Simply drop the target_list_lock and
> re-enable irqs prior to calling __netpoll_cleanup, the re-acquire the lock, and
> restart the loop.  Confirmed by myself to fix the problem reported.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: "David S. Miller" <davem@davemloft.net>
> ---
>  drivers/net/netconsole.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> index dfb67eb..f365840 100644
> --- a/drivers/net/netconsole.c
> +++ b/drivers/net/netconsole.c
> @@ -670,6 +670,7 @@ static int netconsole_netdev_event(struct notifier_block *this,
>  	      event == NETDEV_BONDING_DESLAVE || event == NETDEV_GOING_DOWN))
>  		goto done;
>  
> +restart:
>  	spin_lock_irqsave(&target_list_lock, flags);
>  	list_for_each_entry(nt, &target_list, list) {
>  		netconsole_target_get(nt);
> @@ -683,9 +684,12 @@ static int netconsole_netdev_event(struct notifier_block *this,
>  				 * rtnl_lock already held
>  				 */
>  				if (nt->np.dev) {
> +					spin_unlock_irqrestore(&target_list_lock,
> +							       flags);
>  					__netpoll_cleanup(&nt->np);
>  					dev_put(nt->np.dev);
>  					nt->np.dev = NULL;
> +					goto restart;
>  				}
>  				/* Fall through */
>  			case NETDEV_GOING_DOWN:
> -- 
> 1.7.4.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Crap, hold on this, sorry.  Just saw that I forgot to issue a
netconsole_target_put to balance the get in the restart path.  I'll send a new
patch shortly.
Neil

