From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: RFC/T: Possible fix for bcm43xx periodic work bug
Date: Thu, 7 Sep 2006 22:39:19 +0200
Message-ID: <200609072239.20074.mb@bu3sch.de>
References: <45006221.4090603@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <45006221.4090603-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

On Thursday 07 September 2006 20:17, Larry Finger wrote:
> Hi all,
> 
> I think I have a fix for the bcm43xx bug that leads to NETDEV WATCHDOG tx timeouts and would like it
> to get as much testing as possible as this bug affects V2.6.18-rcX. If the problem is truly
> fixed, I hope to get the fix into mainline before release of the bug into the stable series.
> 
> I got the idea for the fix when I discovered that the timeout interval used for the watchdog is the 
> default value of 5 seconds. Obviously, the few milliseconds used in the periodic work handler 
> weren't causing us to "just miss".
> 
> To exacerbate the problem, I changed the repeat timer for periodic work from 15 to 1 sec. I also set 
> BADNESS_LIMIT to 0. As a result, I was running the problem code once per second instead of once per 
> minute. Now failures would occur in minutes instead of hours.
> 
> Operating from the premise that the DMA needed some time to reach the idle state after the MAC was 
> suspended, I tried various delays, but nothing worked.
> 
> Then I decided to test the premise that the problem was associated with shutting down and restarting 
> the network. That lead to the current patch, which has run for what is effectively 100 times longer 
> than previous versions.
> 
> Larry
> -------------------------------------------------------------------
> 
> 
> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> @@ -3244,8 +3244,6 @@ static void bcm43xx_periodic_work_handle
>   		 * be preemtible.
>   		 */
>   		mutex_lock(&bcm->mutex);
> -		netif_stop_queue(bcm->net_dev);
> -		synchronize_net();
>   		spin_lock_irqsave(&bcm->irq_lock, flags);
>   		bcm43xx_mac_suspend(bcm);
>   		if (bcm43xx_using_pio(bcm))
> @@ -3270,7 +3268,6 @@ static void bcm43xx_periodic_work_handle
>   		if (bcm43xx_using_pio(bcm))
>   			bcm43xx_pio_thaw_txqueues(bcm);
>   		bcm43xx_mac_enable(bcm);
> -		netif_wake_queue(bcm->net_dev);
>   	}
>   	mmiowb();
>   	spin_unlock_irqrestore(&bcm->irq_lock, flags);

The real question is: Why does this patch help?

Let's explain it. We don't stop networking just for fun there.
While executing long preemptible periodic work, we must ensure
that the TX path into the driver is not entered. It's the same
reason why we disable IRQs in the first place. We can't take the
mutex in the TX path and the IRQ handler. (That are the only places
where we can't take the mutex).
Short: We must stop netif here.
The question is: Why does stopping netif queue cause a watchdog
trigger here? The maximum time it can take for the periodic
work inside of the critical section is about 0.2sec. So the queue
is stopped for about 0.2sec max. Why does the watchdog trigger?
Any idea from some networking guru?
Could synchronize_net() take over 5sec in some worst case? Why?
Questions over questions :D

-- 
Greetings Michael.
