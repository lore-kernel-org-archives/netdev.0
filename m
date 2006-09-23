From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: further fix for periodic work errors
Date: Sat, 23 Sep 2006 22:22:30 +0200
Message-ID: <200609232222.31126.mb@bu3sch.de>
References: <4514B322.mail1K91A36N8@lwfinger.net>
	<200609232141.20720.mb@bu3sch.de> <451593A0.8030104@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <451593A0.8030104-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

On Saturday 23 September 2006 22:05, Larry Finger wrote:
> Michael Buesch wrote:
> > 
> > Well, even _if_ mac_suspend takes a few milliseconds (which it
> > does not), it would not trigger the watchdog.
> > I measured the time it takes to execute the various works
> > and based the badness selection on the results.
> > 
> > If the 15 or 30 second work is really able to trigger a watchdog
> > timeout, it's a _bug_ that needs to be fixed and not to be
> > papered over.
> > It won't trigger the watchdog, because it is running too long
> > uninterruptible (it won't run 5sec...). If it triggers, it's
> > triggered by something else (like the synchronize_net thingie
> > in the past).
> 
> Even the synchronize_net problem wasn't taking 5 seconds to complete, it was messing up the transmit 
> process.

That's what I am saying. There must be another similiar bug.

> I went back to check my logs again, and the actual error was "BCM43xx_IRQ_XMIT_ERROR", which is 
> always preceded by a MAC suspend failed. These never happened all the time I was running with 
> MAXIMUM_BADNESS of 0.

We can debug with the recently spec'ed reason and error registers why
this is triggered. See v4 specs.

> I think the _bug_ is letting the transmit process run while doing the periodic work,

No. We don't let TX run while doing any periodic work (slow or fast).
Same for the IRQ handler.
We take the IRQ lock, which protects against IRQ and TX path (and everything else).
The _only_ difference between slowpath and fastpath periodic work is
that slowpath (long) periodic work is preemptible. This is gained
by not taking the IRQ lock, but protecting it otherwise (disabling IRQs and TX).

So what you are doing by your patch is: _never_ taking the lock.

> which is why  
> I'm testing with the tx_disable before all periodic work. I'll let you know in 2 or 3 days if it 

It is not needed. tx_disable is only needed for long periodic work.

-- 
Greetings Michael.
