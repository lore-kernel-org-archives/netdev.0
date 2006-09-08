From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: RFC/T: Possible fix for bcm43xx periodic work bug
Date: Fri, 8 Sep 2006 22:42:48 +0200
Message-ID: <200609082242.48773.mb@bu3sch.de>
References: <45006221.4090603@lwfinger.net> <200609072239.20074.mb@bu3sch.de>
	<45016F63.9000200@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Broadcom Linux <bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <45016F63.9000200-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

On Friday 08 September 2006 15:25, Larry Finger wrote:
> Michael Buesch wrote:
> > On Thursday 07 September 2006 20:17, Larry Finger wrote:
> >> Hi all,
> >>
> >> I think I have a fix for the bcm43xx bug that leads to NETDEV WATCHDOG tx timeouts and would like it
> >> to get as much testing as possible as this bug affects V2.6.18-rcX. If the problem is truly
> >> fixed, I hope to get the fix into mainline before release of the bug into the stable series.
> >>
> >> I got the idea for the fix when I discovered that the timeout interval used for the watchdog is the 
> >> default value of 5 seconds. Obviously, the few milliseconds used in the periodic work handler 
> >> weren't causing us to "just miss".
> >>
> >> To exacerbate the problem, I changed the repeat timer for periodic work from 15 to 1 sec. I also set 
> >> BADNESS_LIMIT to 0. As a result, I was running the problem code once per second instead of once per 
> >> minute. Now failures would occur in minutes instead of hours.
> >>
> >> Operating from the premise that the DMA needed some time to reach the idle state after the MAC was 
> >> suspended, I tried various delays, but nothing worked.
> >>
> >> Then I decided to test the premise that the problem was associated with shutting down and restarting 
> >> the network. That lead to the current patch, which has run for what is effectively 100 times longer 
> >> than previous versions.
> >>
> >> Larry
> >> -------------------------------------------------------------------
> >>
> >>
> >> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> >> ===================================================================
> >> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> >> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> >> @@ -3244,8 +3244,6 @@ static void bcm43xx_periodic_work_handle
> >>   		 * be preemtible.
> >>   		 */
> >>   		mutex_lock(&bcm->mutex);
> >> -		netif_stop_queue(bcm->net_dev);
> >> -		synchronize_net();
> >>   		spin_lock_irqsave(&bcm->irq_lock, flags);
> >>   		bcm43xx_mac_suspend(bcm);
> >>   		if (bcm43xx_using_pio(bcm))
> >> @@ -3270,7 +3268,6 @@ static void bcm43xx_periodic_work_handle
> >>   		if (bcm43xx_using_pio(bcm))
> >>   			bcm43xx_pio_thaw_txqueues(bcm);
> >>   		bcm43xx_mac_enable(bcm);
> >> -		netif_wake_queue(bcm->net_dev);
> >>   	}
> >>   	mmiowb();
> >>   	spin_unlock_irqrestore(&bcm->irq_lock, flags);
> > 
> > The real question is: Why does this patch help?
> > 
> > Let's explain it. We don't stop networking just for fun there.
> > While executing long preemptible periodic work, we must ensure
> > that the TX path into the driver is not entered. It's the same
> > reason why we disable IRQs in the first place. We can't take the
> > mutex in the TX path and the IRQ handler. (That are the only places
> > where we can't take the mutex).
> > Short: We must stop netif here.
> > The question is: Why does stopping netif queue cause a watchdog
> > trigger here? The maximum time it can take for the periodic
> > work inside of the critical section is about 0.2sec. So the queue
> > is stopped for about 0.2sec max. Why does the watchdog trigger?
> > Any idea from some networking guru?
> > Could synchronize_net() take over 5sec in some worst case? Why?
> > Questions over questions :D
> 
> This may be a stupid question, but does the synchronize_net call belong?
> 
> The reason I ask is because the code for synchronize_net is

synchronize_net() ensures that all currently running TX handlers
complete before returning from synchronize_net(). That's what I have
been told.
So what we do is: Disable TX queue and wait for any running TX queue
to finish. We must do this to make sure no TX handler can run after
the sync. I previously explained the exact reasons.

> When I look through the mutex_lock code, I don't find any rcu code. What did I miss?

This is bot about synchronoizing bcm43xx, but the net layer.

> BTW, I still  
> got NETDEV tx timeouts with a 30 second timeout.

So, well. I don't think synchronize_net can take 30 seconds.
That would be a big bug in the net layer.

> I'm currently testing with the netif_stop_queue and netif_wake_queue statements restored, but 
> without the synchronize_net. It has run for over 11 hours with the accelerated testing, which would 
> correspond to almost 4 weeks at regular rates.

Well, we can brute-force it to death, or we can ask someone who actually has
a clue what is going on. Some networking guru, please help. :)

-- 
Greetings Michael.
