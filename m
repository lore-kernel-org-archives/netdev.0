From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [Y2038] [PATCH 04/11] posix timers:Introduce the 64bit methods
 with timespec64 type for k_clock structure
Date: Wed, 22 Apr 2015 15:37:47 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1504221531470.13914@nanos>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org> <alpine.DEB.2.11.1504212204130.13914@nanos> <alpine.DEB.2.11.1504220946460.13914@nanos> <2233518.Z2Q4dpO62C@wuerfel>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: y2038@lists.linaro.org, pang.xunlei@linaro.org,
	Peter Zijlstra <peterz@infradead.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Paul Mackerras <paulus@samba.org>, cl@linux.com,
	Ingo Molnar <mingo@kernel.org>, heenasirwani@gmail.com,
	linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
	mpe@ellerman.id.au, rafael.j.wysocki@intel.com, ahh@google.com,
	Frederic Weisbecker <fweisbec@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, pjt@google.com,
	riel@redhat.com, richardcochran@gmail.com,
	Tejun Heo <tj@kernel.org>,
	John Stultz <john.stultz@linaro.org>, rth@twiddle.net,
	Baolin Wang <baolin.wang@linaro.org>,
	gregkh@linuxfoundation.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	linux390@de.ibm.com, linuxppc-dev@lists.ozlabs.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <2233518.Z2Q4dpO62C@wuerfel>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Apr 2015, Arnd Bergmann wrote:
> On Wednesday 22 April 2015 10:45:23 Thomas Gleixner wrote:
> > On Tue, 21 Apr 2015, Thomas Gleixner wrote:
> 
> > So we could save one translation step if we implement new syscalls
> > which have a scalar nsec interface instead of the timespec/timeval
> > cruft and let user space do the translation to whatever it wants.
> > 
> > So
> > 
> > sys_clock_nanosleep(const clockid_t which_clock, int flags,
> > 	            const struct timespec __user *expires,
> > 		    struct timespec __user *reminder)
> > 
> > would get the new syscall variant:
> > 
> > sys_clock_nanosleep_ns(const clockid_t which_clock, int flags,
> > 		       const s64 expires, s64 __user *reminder)
> 
> As you might expect, there are a number of complications with this
> approach:
> 
> - John Stultz likes to point out that it's easier to do one change
>   at a time, so extending the interface to 64-bit has less potential
>   of breaking things than a more fundamental change. I think it's
>   useful to drop a lot of the syscalls when a more modern version
>   is around (e.g. let libc implement usleep and nanosleep through
>   clock_nanosleep), but keep the syscalls as close to the known-working
>   64-bit versions as we can.

Well. I don't see a massive risk when implementing
e.g. usleep/nanosleep & al with clock_nanosleep_ns().

> - The inode timestamp related syscalls (stat, utimes and variants
>   thereof) require the full range of time64_t and cannot use ktime_t.

I'm aware that there are a lot of interfaces which cannot use
ktime_t. That's fine.

> - converting between timespec types of different size is cheap,
>   converting timespec to ktime_t is still relatively cheap, but
>   converting ktime_t to timespec is rather expensive (at least eight
>   32-bit multiplies, plus a few shifts and additions if you don't
>   have 64-bit arithmetic).

Right. That's what I said vs. gettime().

> - ioctls that pass a timespec need to keep doing that or would require
>   a source-level change in user space instead of recompiling.

No argument here.

> We should probably look at it separately for each syscall. It's
> quite possible that we find a number of them for which it helps
> and others for which it hurts, so we need to see the big pictures.

Agreed.

> There are also a few other calls that will never need 64-bit
> time_t because the range is limited by the need to only ever
> pass relative timeouts (select, poll, io_getevents, recvmmsg,
> clock_getres, rt_sigtimedwait, sched_rr_get_interval, getrusage,
> waitid, semtimedop, sysinfo), so we could actually leave them
> using a 32-bit structure and have the libc do the conversion.

Indeed.
 
> I've started a list of affected syscalls at
> https://docs.google.com/spreadsheets/d/1HCYwHXxs48TsTb6IGUduNjQnmfRvMPzCN6T_0YiQwis/edit?usp=sharing
> 
> Still adding more calls and description, let me know if you want edit
> permissions.

Only if you have a strong backup system for this file. My GUI foo is
rather limited :)

Thanks,

	tglx
