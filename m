From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: Can someone please try...
Date: Wed, 24 Jan 2007 00:43:10 -0500
Message-ID: <1169617390.30511.27.camel@dv>
References: <200701161806.02780.mb@bu3sch.de>
	<200701222200.19784.mb@bu3sch.de> <1169532880.8258.2.camel@dv>
	<200701231021.34995.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <200701231021.34995.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
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

On Tue, 2007-01-23 at 10:21 +0100, Michael Buesch wrote:
> On Tuesday 23 January 2007 07:14, Pavel Roskin wrote:
> > I have tried the patch, and it doesn't fix the problem.  It's a separate
> > problem.  It happens when bcm43xx_interrupt_handler() is called on a
> > device that has already been removed.
> 
> That shouldn't happen and doesn't for me.
> 
> > It looks like 
> > bcm43xx_wireless_core_stop() should be called from
> > bcm43xx_one_core_detach().
> 
> No, well... . remove_interface should have been called by the stack, no?

It is not.  It's called if I bring the interface down with ifconfig.  If
I remove live interface with "rmmod bcm43xx_d80211",
bcm43xx_one_core_detach() is called first, followed by kernel panic in 
bcm43xx_interrupt_handler().

And that's what I see in the code.  Module removal calls bcm43xx_exit().
It unregisters the ssb driver first.  The ssb layer calls
bcm43xx_remove(), which calls bcm43xx_one_core_detach() before doing
anything with the wireless stack or with interrupts.

I tried to put bcm43xx_one_core_detach() to the end of bcm43xx_remove(),
but the result was the same.  Still, I think the solution lies in that
direction.  We should stop the hardware before dismantling any data
structures.

-- 
Regards,
Pavel Roskin
