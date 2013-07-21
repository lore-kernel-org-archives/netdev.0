From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] via-rhine: Fix tx_timeout handling
Date: Sun, 21 Jul 2013 17:18:50 +0100
Message-ID: <1374423530.2804.13.camel@deadeye.wl.decadent.org.uk>
References: <1374269428-6827-1-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <rl@hellgate.ch>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374269428-6827-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-07-19 at 23:30 +0200, Richard Weinberger wrote:
> rhine_reset_task() misses to call netif_stop_queue(),
> this can lead to a crash if work is still scheduled while
> we're resetting the tx queue.
> 
> Fixes:
> [   93.591707] BUG: unable to handle kernel NULL pointer dereference at 0000004c
> [   93.595514] IP: [<c119d10d>] rhine_napipoll+0x491/0x6e
> 
> Signed-off-by: Richard Weinberger <richard@nod.at>
> ---
>  drivers/net/ethernet/via/via-rhine.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
> index b75eb9e..57e1b40 100644
> --- a/drivers/net/ethernet/via/via-rhine.c
> +++ b/drivers/net/ethernet/via/via-rhine.c
> @@ -1615,6 +1615,7 @@ static void rhine_reset_task(struct work_struct *work)
>  		goto out_unlock;
>  
>  	napi_disable(&rp->napi);
> +	netif_stop_queue(dev);

This is not really fixing the bug because there is no synchronisation
with the TX scheduler.  You can call netif_tx_disable() instead to do
that.

(I also think that it is preferable to use
netif_device_{detach,attach}() to stop the queue during reconfiguration,
as this is independent of TX completions and the watchdog.)

Ben.

>  	spin_lock_bh(&rp->lock);
>  
>  	/* clear all descriptors */

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
