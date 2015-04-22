From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [Y2038] [PATCH 04/11] posix timers:Introduce the 64bit methods
 with timespec64 type for k_clock structure
Date: Wed, 22 Apr 2015 10:45:23 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1504220946460.13914@nanos>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org> <3231171.5TrYVVBLh4@wuerfel> <alpine.DEB.2.11.1504211701140.13914@nanos> <2819798.f0KhjY3UAe@wuerfel> <alpine.DEB.2.11.1504212204130.13914@nanos>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: y2038@lists.linaro.org, Baolin Wang <baolin.wang@linaro.org>,
	pang.xunlei@linaro.org, Peter Zijlstra <peterz@infradead.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Paul Mackerras <paulus@samba.org>, cl@linux.com,
	heenasirwani@gmail.com, linux-arch@vger.kernel.org,
	linux-s390@vger.kernel.org, mpe@ellerman.id.au,
	rafael.j.wysocki@intel.com, ahh@google.com,
	Frederic Weisbecker <fweisbec@gmail.com>, pjt@google.com,
	riel@redhat.com, richardcochran@gmail.com,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	John Stultz <john.stultz@linaro.org>, rth@twiddle.net,
	gregkh@linuxfoundation.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	linux390@de.ibm.com, linuxppc-dev@lists.ozlabs.org,
	Ingo Molnar <mingo@kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1504212204130.13914@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Apr 2015, Thomas Gleixner wrote:
> On Tue, 21 Apr 2015, Arnd Bergmann wrote:
> > I know there are concerns about this, in particular because C11 and
> > POSIX both require tv_nsec to be 'long', unlike timeval->tv_usec,
> > which is a 'suseconds_t' and can be defined as 'long long'.
> >
> > a)
> > 
> > struct timespec {
> > 	time_t tv_sec;
> > 	long long tv_nsec; /* or typedef long long snseconds_t */
> > };
> > 
> > This is not directly compatible with C11 or POSIX.1-2008, but it
> > matches what we do inside of 64-bit kernels, so probably has the
> > highest chance of working correctly in practice
> 
> After reading Linus rant in the x32 thread again (thanks for the
> reminder), and looking at b/c/d - which rate between ugly and butt
> ugly - I think we should go for a) and screw POSIX and C11 as those
> committee dinosaurs seem to completely ignore the 2038 problem on
> 32bit machines. At least I have not found any hint that these folks
> care at all. So why should we comply to something which is completely
> useless?
> 
> That also makes the question about the upper 32bits check moot, so
> it's the simplest and clearest of the possible solutions.

Second thoughts after some sleep.

So the outcome of this is going to be that user space libraries will
not expose the syscall variant of

    syscall_timespec64 {
           s64 tv_sec;
	   s64 tv_nsec;
    };

to applications. The libs will translate them to spec conforming

   timespec {
           time_t tv_sec;
	   long   tv_nsec;
   };

anyway. That means we have two translation steps on 32bit systems:

  1) user space timespec -> syscall timespec64

  2) syscall timespec64 -> scalar nsec s64 (ktime_t)

and the other way round. The kernel internal representation is simply
s64 (nsec) based all over the place.

So we could save one translation step if we implement new syscalls
which have a scalar nsec interface instead of the timespec/timeval
cruft and let user space do the translation to whatever it wants.

So

sys_clock_nanosleep(const clockid_t which_clock, int flags,
	            const struct timespec __user *expires,
		    struct timespec __user *reminder)

would get the new syscall variant:

sys_clock_nanosleep_ns(const clockid_t which_clock, int flags,
		       const s64 expires, s64 __user *reminder)

I personally would welcome such an interface as it makes user space
programming simpler. Just (re)arming a periodic nanosleep based on
absolute expiry time is horrible stupid today:

	 struct timespec expires;
	 ....
	 while ()
	       expires.tv_nsec += period.tv_nsec;
	       expires.tv_sec += period.tv_sec;
	       normalize_timespec(&expires);
	       sys_clock_nanosleep(CLOCK_ID, ABS, &expires, NULL);

So with a scalar interface this would reduce to:

	 s64 expires;
	 ....
	 while ()
	       expires += period;
	       sys_clock_nanosleep_ns(CLOCK_ID, ABS, &expires, NULL);

There is a difference both in text and storage size plus the avoidance
of the two translation steps (one translation step on 64bit).

I know that this is non portable, but OTOH if I look at the non
portable mechanisms which are used by data bases, java VMs and other
apps which exist to squeeze the last cycles out of the system, there
is certainly some value to that.

The portable/spec conforming apps can still use the user space
assisted translated timespec/timeval mechanisms.

There is one caveat though: sys_clock_gettime and sys_gettimeofday
will still need a syscall_timespec64 variant. We have no double
translation steps there because we maintain the timespec
representation in the timekeeping code for performance reasons to
avoid the division in the syscall interface. But everything else can
do nicely without the timespec cruft.

We really should talk to libc folks and high performance users about
this before blindly adding a gazillion of new timespec64 based
interfaces.

Thoughts?

Thanks,

	tglx
