From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC] A change in periodic work scheduling in bcm43xx
Date: Tue, 5 Sep 2006 22:47:27 +0200
Message-ID: <200609052247.27986.mb@bu3sch.de>
References: <44FDBAA8.6090709@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <44FDBAA8.6090709-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

On Tuesday 05 September 2006 19:58, Larry Finger wrote:
> Michael,
> 
> Based on user reports and my own experiences, the current problems with NETDEV WATCHDOG tx timeouts, 
> and the device just falling over do not happen when periodic work is not preemptible. These problems 
> seem to affect BCM4306 rev 2 & 3 chips. Since I changed BADNESS_LIMIT to 20 to disable preemption 
> during periodic work, my device has stayed up continuously for more than 18 hours. Previously, the 
> longest time between failures was less than 6 hours, and sometimes as short as 10 minutes.
> 
> As you know, the present scheme for periodic work scheduling for bcm43xx in both wireless-2.6 and 
> wireless-dev runs all 4 periodic tasks on certain ticks of the 15-second clock. Using your values of 
> "badness" of 1, 1, 5, and 10 for the 15, 30, 60, and 120 second periodic tasks, respectively, the 
> badness repeat cycle is ..., 1, 2, 1, 7, 1, 2, 1, 17, ...
> 
> I propose that we reduce the size of the spike in badness by shifting the 120 second task from a 
> clock value of 8n to 8n+7, and the 60 second task from 4n to 4n+1. This way no more than 2 of the 
> periodic tasks will be run in any clock period, and the badness repeat cycle becomes ..., 6, 2, 1, 
> 2, 6, 2, 11, 2, .... The tasks are run with the same periodicity as before, just a little more 
> asynchronously. I recall that they were completely asynchronous in early versions of this driver.
> 
> Until we can locate and fix the problem that occurs during preemption, should we consider setting 
> BADNESS_LIMIT to 20 in the wireless-2.6 kernels? For those of us whose cards have the problem, it 
> certainly makes the device a lot more usable.

Oh well...
And if we do this, it will take two weeks for the latency-people to
show up and request a revert of this again.

Well, I _really_ don't want to have a patch like this, because
it just papers over a real bug.
There are only two choices: Either we want preemption or we don't.
It's worthless to tune the badness limit to a point where it is least
likely for the bug to trigger. Sooner or later it _will_ trigger.

What we really want is:
1st: A relieable way to reproduce the bug in short time.
     Waiting 20hours isn't really a good way of debugging.
2nd: If we can reproduce it in reasonable time, we can track
     down what is actually causing the bug.

My thoughts on the bug:

When a preemptible work happens, we completely shutdown IRQ
handling and we suspend the MAC. We do this, because we must
not take the IRQ spinlock if we want to be preemptible.
By not taking the IRQ spinlock, we race against the DMA engine
(and other parts). So we must shutdown any data flow during
the periodic work to ensure the IRQ handler does not trigger.
The sad thing is: We don't know much about how the card and
the firmware works (yet). So the big question is:
How to suspend the card in an easy and _inexpensive_ way?
We currently mask all IRQs and suspend the MAC. I guess MAC
suspending is part of the problem. I _guess_ the card is
confused by suspending the MAC in the middle of possible
transmissions. It's all just a guess. That's why I want to
have a good way to reproduce the bug to do experiments.
We could suspend the DMA TX channel before we suspend the MAC,
for example. We could try other things as well. For example
don't suspend the MAC at all. Just mask IRQs.

We must be _careful_ here. The preemptible periodic work
is a damn fragile part of the whole driver and it is easily
possible to break it even more with a patch that looks
correct.

Short:
We don't need a patch to paper over the bug, but we need
_ideas_ of what is actually going on.

-- 
Greetings Michael.
