From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: further fix for periodic work errors
Date: Sat, 23 Sep 2006 09:56:05 +0200
Message-ID: <200609230956.05475.mb@bu3sch.de>
References: <4514B322.mail1K91A36N8@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <4514B322.mail1K91A36N8-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 23 September 2006 06:08, Larry Finger wrote:
> Recent changes in the setup for preemptible periodic work fixed most
> of the problems with NETDEV watchdog timeouts; however, some variants
> of the bcm43xx device still had the problem. These were fixed by setting
> the parameter MAXIMUM_BADNESS to 0. By doing so, all the functionality
> associated with calculating the 'badness' of the upcoming periodic work
> is no longer needed; therefore it is removed.

Uhm, no. Wait. _Why_ does the watchdog trigger.
All periodic work in the fastpath (which you remove with this patch)
is supposed to execute in a few microseconds.
I don't think we want to fix this my removing the fastpath and always
taking the _expensive_ slowpath periodic work.

So why does the watchdog trigger for the fast periodic work?
We need to find out.
Removing the fastpath is just bad for overall latency.

The two fastpath periodic works are 15 and 30, if executed
standalone. If the 15 and/or 30 is execiuted alongside with
a 60sec work, it's all slowpath, of course.

> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> ---
> 
> John,
> 
> This patch relies on "[PATCH] bcm43xx: fix netdev watchdog timeouts", which
> was submitted on 9/14/06. It is important for this one, as well as those
> already queued, to make the 2.6.19 cutoff.
> 
> Thanks,
> 
> Larry
> 
> 
> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> @@ -3136,67 +3136,32 @@ static void do_periodic_work(struct bcm4
>  	schedule_delayed_work(&bcm->periodic_work, HZ * 15);
>  }
>  
> -/* Estimate a "Badness" value based on the periodic work
> - * state-machine state. "Badness" is worse (bigger), if the
> - * periodic work will take longer.
> - */
> -static int estimate_periodic_work_badness(unsigned int state)
> -{
> -	int badness = 0;
> -
> -	if (state % 8 == 0) /* every 120 sec */
> -		badness += 10;
> -	if (state % 4 == 0) /* every 60 sec */
> -		badness += 5;
> -	if (state % 2 == 0) /* every 30 sec */
> -		badness += 1;
> -	if (state % 1 == 0) /* every 15 sec */
> -		badness += 1;
> -
> -#define BADNESS_LIMIT	4
> -	return badness;
> -}
> -
>  static void bcm43xx_periodic_work_handler(void *d)
>  {
>  	struct bcm43xx_private *bcm = d;
>  	unsigned long flags;
>  	u32 savedirqs = 0;
> -	int badness;
> -
> -	badness = estimate_periodic_work_badness(bcm->periodic_state);
> -	if (badness > BADNESS_LIMIT) {
> -		/* Periodic work will take a long time, so we want it to
> -		 * be preemtible.
> -		 */
> -		mutex_lock(&bcm->mutex);
> -		netif_tx_disable(bcm->net_dev);
> -		spin_lock_irqsave(&bcm->irq_lock, flags);
> -		bcm43xx_mac_suspend(bcm);
> -		if (bcm43xx_using_pio(bcm))
> -			bcm43xx_pio_freeze_txqueues(bcm);
> -		savedirqs = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
> -		spin_unlock_irqrestore(&bcm->irq_lock, flags);
> -		bcm43xx_synchronize_irq(bcm);
> -	} else {
> -		/* Periodic work should take short time, so we want low
> -		 * locking overhead.
> -		 */
> -		mutex_lock(&bcm->mutex);
> -		spin_lock_irqsave(&bcm->irq_lock, flags);
> -	}
>  
> +	/* Periodic work may take a long time, so we want it to
> +	 * be preemtible. In any case, we need to disable transmits.
> +	 */
> +	mutex_lock(&bcm->mutex);
> +	netif_tx_disable(bcm->net_dev);
> +	spin_lock_irqsave(&bcm->irq_lock, flags);
> +	bcm43xx_mac_suspend(bcm);
> +	if (bcm43xx_using_pio(bcm))
> +		bcm43xx_pio_freeze_txqueues(bcm);
> +	savedirqs = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
> +	spin_unlock_irqrestore(&bcm->irq_lock, flags);
> +	bcm43xx_synchronize_irq(bcm);
>  	do_periodic_work(bcm);
> -
> -	if (badness > BADNESS_LIMIT) {
> -		spin_lock_irqsave(&bcm->irq_lock, flags);
> -		tasklet_enable(&bcm->isr_tasklet);
> -		bcm43xx_interrupt_enable(bcm, savedirqs);
> -		if (bcm43xx_using_pio(bcm))
> -			bcm43xx_pio_thaw_txqueues(bcm);
> -		bcm43xx_mac_enable(bcm);
> -		netif_wake_queue(bcm->net_dev);
> -	}
> +	spin_lock_irqsave(&bcm->irq_lock, flags);
> +	tasklet_enable(&bcm->isr_tasklet);
> +	bcm43xx_interrupt_enable(bcm, savedirqs);
> +	if (bcm43xx_using_pio(bcm))
> +		bcm43xx_pio_thaw_txqueues(bcm);
> +	bcm43xx_mac_enable(bcm);
> +	netif_wake_queue(bcm->net_dev);
>  	mmiowb();
>  	spin_unlock_irqrestore(&bcm->irq_lock, flags);
>  	mutex_unlock(&bcm->mutex);
> 

-- 
Greetings Michael.
