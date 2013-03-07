From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netconsole: release the spinlock before
 __netpoll_cleanup()
Date: Wed, 6 Mar 2013 19:08:24 -0500
Message-ID: <20130307000824.GA5702@neilslaptop.think-freely.org>
References: <1362581203-8994-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, amwang@redhat.com, davem@davemloft.net
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41743 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753914Ab3CGAIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 19:08:38 -0500
Content-Disposition: inline
In-Reply-To: <1362581203-8994-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 06, 2013 at 03:46:43PM +0100, Veaceslav Falico wrote:
> Commit 3335f0ca130c201f8680e97f63612053fbc16e22 removed spinlock unlocking
> before __netpoll_cleanup() in netconsole_netdev_event(), however we still
> might sleep in __netpoll_cleanup() - via synchronize_srcu(). Revert it and
> add a comment.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>  drivers/net/netconsole.c |   10 ++++++++++
>  1 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> index 37add21..dd62b4c 100644
> --- a/drivers/net/netconsole.c
> +++ b/drivers/net/netconsole.c
> @@ -680,7 +680,17 @@ static int netconsole_netdev_event(struct notifier_block *this,
>  				 * rtnl_lock already held
>  				 */
>  				if (nt->np.dev) {
> +					/*
> +					 * we still might sleep in
> +					 * __netpoll_cleanup(), so release
> +					 * the lock
> +					 */
> +					spin_unlock_irqrestore(
> +							      &target_list_lock,
> +							      flags);
>  					__netpoll_cleanup(&nt->np);
> +					spin_lock_irqsave(&target_list_lock,
> +							  flags);
>  					dev_put(nt->np.dev);
>  					nt->np.dev = NULL;
>  				}
> -- 
> 1.7.1
> 
Thanks for noticing this Vaeceslav, but you can't just drop and re-acquire the
lock like this, as it protect the list_for_each_entry loop that you're in.  You
can drop the lock in the above if clause, but then, after the nt->np.dev = NULL,
go back an re-aquire the lock, and start the for loop.  I thought we had already
done this for some other purpose in this code using a label and a goto, but I
suppose I was mistaken

Best
Neil

> 
