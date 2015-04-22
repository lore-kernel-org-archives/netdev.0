From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Y2038] [PATCH 04/11] posix timers:Introduce the 64bit methods with timespec64 type for k_clock structure
Date: Wed, 22 Apr 2015 15:50:45 +0200
Message-ID: <2500914.bVUENZ0dAZ@wuerfel>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org> <alpine.DEB.2.11.1504220946460.13914@nanos> <2233518.Z2Q4dpO62C@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: pang.xunlei@linaro.org, Peter Zijlstra <peterz@infradead.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Paul Mackerras <paulus@samba.org>, cl@linux.com,
	Ingo Molnar <mingo@kernel.org>, heenasirwani@gmail.com,
	linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
	mpe@ellerman.id.au, rafael.j.wysocki@intel.com, ahh@google.com,
	Frederic Weisbecker <fweisbec@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, pjt@google.com,
	riel@redhat.com, richardcochran@gmail.com,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>, rth@twiddle.net,
	Baolin Wang <baolin.wang@linaro.org>,
	gregkh@linuxfoundation.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	linux390@de.ibm.com, linuxppc-dev@lists.ozlabs.org
To: y2038@lists.linaro.org
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <2233518.Z2Q4dpO62C@wuerfel>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 22 April 2015 13:07:44 Arnd Bergmann wrote:
> 
> I've started a list of affected syscalls at
> https://docs.google.com/spreadsheets/d/1HCYwHXxs48TsTb6IGUduNjQnmfRvMPzCN6T_0YiQwis/edit?usp=sharing
> 
> Still adding more calls and description, let me know if you want edit
> permissions.
> 

Got a first draft now, I'm relatively sure that the list is complete,
but it's not the end of the world if I missed a syscall now.

Here are my findings, and I guess we should discuss these with the libc
folks too. I'll group the syscalls according to subsystems:

=== clocks and timers ===

clock_gettime, clock_settime, clock_adjtime, clock_getres, clock_nanosleep,
timer_gettime, timer_settime, timerfd_gettime, timerfd_settime:

 these should be done consistently, either using timespec64 or 64-bit
 nanoseconds, either one works. 64-bit nanoseconds would simplify the
 kernel internally quite a bit by avoiding the double timekeeping (we
 keep track of both nanoseconds and timespec in the timekeeper struct).
 the downside of nanoseconds-only is that each existing caller would
 need a conversion in user space, where currently we can avoid the
 expensive ktime_to_ts() for some cases.

time, stime, gettimeofday, settimeofday, adjtimex, nanosleep,
getitimer, setitimer:
 all deprecated => wontfix

=== i/o ===

pselect6, ppoll, io_getevents, recvmmsg:
 These currently pass a timespec into the kernel with *relative*
 timeouts. Internally, they convert it to ktime_t and back on the
 way out. We have three options:
 - leave as is, get the libc to convert 64-bit timespec to 32-bit
   timespec on the way into the kernel and back on the way out,
   which works because the relative timeout will not overflow
 - use ktime_t to make these more efficient in the kernel, at the
   expense of requiring user space to convert it (all except 
   io_getevents pass back the remaining time).
 - leave the current behavior, but use 64-bit timespec.

select, old_selct, pselect6: deprecated

=== ipc ===

mq_timedsend, mqtimedreceive: These get an *absolute* timeout,
so we have to change them. Internally they use ktime_t, so that
would be the natural interface, but timespec64 would work as well.

semtimedop: This uses a relative timeout that is converted to
jiffies internally, so using ktime_t would not be as natural,
unless we rewrite the function to use hrtimers.

msgctl, semctl, shmctl: These have an output, which is a time_t
that stores the absolute seconds value of the last time something
happened. Internally this comes from get_seconds(), which has to
be efficient anyway. The best way forward is probably to use a
structure layout for these that is compatible with what 64-bit
architectures do. Note that the structures sometimes have padding
to deal with the extension of time_t to 64-bit, but not all
architectures have that, and some (notably big-endian arm) have
it in the wrong place, so my feeling is that we're better off not
using that padding and instead doing something that works for
everyone.

=== inodes and filesystems ===

utimesnsat, fstat64, fstatat64:

inode timestamps need to represent times before 1970 and way into
the future, so we need 64-bit time_t here, I see no other alternatives
here, so we have to pass struct timespec64 into utimensat, and
create version 4 of 'struct stat' to pass into the future fstat and
fstatat. I would use a version that matches the 64-bit layout
of 'struct stat'.

utime, utimes, futimensat, oldstat, oldlstat, oldfstat, newstat,
newlstat, newfstat, newfstatat, stat64 and lstat64: these are all
deprecated now, we have to stop getting this wrong!

=== tasks ===

getrusage, waitid: these pass a 'struct rusage' that contains a
'struct timeval' with elapsed time. Again there are multiple options:
- We could change rusage to contain a new 'struct relative_timeval'
  instead, with an unchanged layout, which makes the format incompatible
  with a standard libc that uses a 64-bit based timeval.
- We could make the layout the same as on 64-bit machines, as x32 does,
  which is again incompatible with posix but would work better
- We could make the layout what glibc expects, using 64-bit based
  timeval structures at the beginning.
- We could define a new structure usings pure nanosecond counters.

rt_sigtimedwait: This passes a relative timespec value in back out,
so we could keep the current layout and have glibc convert it, or
change it to something else. The kernel internally converts to jiffies
to call schedule_timeout.

futex: this passes a relative *or* absolute timespec in, so we have to
change it. The kernel uses ktime_t internally here, so we could make
the interface nanosecond based or stick with timespec64.

sched_rr_get_interval: This returns a timespec with the schedule interval
to user space, using a 32-bit based format is fine here, or we could
convert to timespec64. The kernel uses jiffies internally.

wait4: replaced by waitid

=== system wide ===

sysinfo: struct sysinfo contains '__kernel_long_t uptime', we can keep
that, it's fine.

	Arnd
