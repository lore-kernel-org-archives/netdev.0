From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: gettimeofday scalability
Date: Tue, 5 Oct 2004 21:35:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005193545.GI26820@dualathlon.random>
References: <4162CD76.4070204@draigBrady.com> <20041005185553.GG26820@dualathlon.random> <4162F311.4050009@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
Content-Disposition: inline
In-Reply-To: <4162F311.4050009@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 05, 2004 at 08:16:33PM +0100, P@draigBrady.com wrote:
> Andrea Arcangeli wrote:
> >On Tue, Oct 05, 2004 at 05:36:06PM +0100, P@draigBrady.com wrote:
> >
> >>So can anyone summarise the relative merits of these locking
> >>mechanisms, before I start benchmarking?
> >
> >
> >frlock/seqlock (2.4/2.6 respectively) is the way to go, no write
> >starvation, and zero cacheline bouncing. 
> 
> Cheers.
> 
> Perhaps the confusing comment wrt brlock at the
> top of seqlock.h can be changed so?

I guess so.

> This is all in kernel space.

vsyscalls are in userspace, but you will not notice the difference.

Or do you mean your code is in kernel space? vsyscalls would run from
kernel space too, but then you can use gettimeofday by hand with seqlock
and it won't be any different.

> However Stephen's suggestion of reading the tsc in user space
> may be a runner, as I just care about relative times.

Stephen's suggestion will lead to your app breaking on asymmetric TSC on
SMP if you're not careful, if you use the vsyscall on a correct kernel
(like x86-64) you won't take that risk (HPETS avoids that, slower than
the tsc but the only safe one). Otherwise you've to use process affinity
+ tsc, only with cpu binding you're safe. Some big app uses TSC but only
optionally, so you can turn it on/off depending on the hardware (on
x86-64 this obsoleted by vgettimeofday, that's a x86-only hack).

hope this helps ;)
