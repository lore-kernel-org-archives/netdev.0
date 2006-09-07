From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] ucode debug status via sysfs for wireless-2.6
Date: Thu, 7 Sep 2006 22:48:39 +0200
Message-ID: <200609072248.39588.mb@bu3sch.de>
References: <20060904205340.GB3726@tuba> <200609071033.52258.mb@bu3sch.de>
	<45001CCA.1000304@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Martin Langer <martin-langer-Mmb7MZpHnFY@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <45001CCA.1000304-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

On Thursday 07 September 2006 15:21, Larry Finger wrote:
> Michael Buesch wrote:
> > On Thursday 07 September 2006 03:34, Larry Finger wrote:
> >> +		return -EPERM;
> >> +
> > 
> > you want to take the spinlock lock here, too.
> 
> Obviously, I copied the wrong model. Is it correct that one should take both locks if your code will 
> touch the hardware, but the mutex lock only is sufficient if your code just accesses data 
> structures? This seems to be the pattern in the other bcm43xx_attr_xxxx_show routines.

In general, no.
But, for some sysfs attrs it is sufficient to only take
the mutex, because:
* We don't access hardware.
* We don't modify this data in a spinlock-only critical section.

Yes, I know that having two locks does not really fit the
"lock data, not code" model. But it's well defined in bcm43xx,
so I think we can live with it. (and we must live with it,
if we want to have preemptible periodic work. And we _want_).
It's defined by the following rules:

1) Always take both, mutex and lock.
2) There are only two places where we can't take the
   mutex, but only the spinlock. IRQ and TX paths.

(Yes, I know that there are still exceptions to 2.
At least in dscape. The softmac port should be OK.
These are bugs, I am aware of them and will fix it)

So these two rules lead to the following rule:

* Code where we only take the mutex can race against the
TX and IRQ paths.
Now we come back to the sysfs problem above. If the data, we
access in this sysfs code, is not touched in either TX or IRQ path
we don't need to take the spinlock. Yes, it's a little bit black
magic. So if you aren't sure, always take both locks.

-- 
Greetings Michael.
