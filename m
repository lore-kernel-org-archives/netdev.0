From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: do not start the interface if reset fails
Date: Thu, 14 Jul 2011 17:13:25 -0700
Message-ID: <1310688805.7032.1.camel@HP1>
References: <1310579690-24622-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Flavio Leitner" <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3405 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753938Ab1GOAUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 20:20:18 -0400
In-Reply-To: <1310579690-24622-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2011-07-13 at 10:54 -0700, Flavio Leitner wrote:
> When bnx2_reset_task() is called, it will stop,
> (re)initialize and start the interface to restore
> the working condition.
> 
> The bnx2_init_nic() calls bnx2_reset_nic() which will
> reset the chip and then call bnx2_free_skbs() to free
> all the skbs.
> 
> The problem happens when bnx2_init_chip() fails because
> bnx2_reset_nic() will just return skipping the ring
> initializations at bnx2_init_all_rings(). Later, the
> reset task starts the interface again and the system
> crashes due a NULL pointer access (no skb in the ring).
> 
> This patch just check the return code and if an error is
> reported, warn the user and abort. It's better to have a
> non working interface than a crash.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>
> ---
>  drivers/net/bnx2.c |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 7915d14..7fb71fc 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -6296,6 +6296,7 @@ static void
>  bnx2_reset_task(struct work_struct *work)
>  {
>  	struct bnx2 *bp = container_of(work, struct bnx2, reset_task);
> +	int rc;
>  
>  	rtnl_lock();
>  	if (!netif_running(bp->dev)) {
> @@ -6305,10 +6306,15 @@ bnx2_reset_task(struct work_struct *work)
>  
>  	bnx2_netif_stop(bp, true);
>  
> -	bnx2_init_nic(bp, 1);
> +	rc = bnx2_init_nic(bp, 1);
> +	if (rc) {
> +		netdev_err(bp->dev, "failed to reset the NIC, aborting\n");
> +		goto out;
> +	}

I think it is better to call dev_close() instead.  I'll post a patch
soon.  Thanks.

>  
>  	atomic_set(&bp->intr_sem, 1);
>  	bnx2_netif_start(bp, true);
> +out:
>  	rtnl_unlock();
>  }
>  


