From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Y2038] [PATCH 04/11] posix timers:Introduce the 64bit methods with timespec64 type for k_clock structure
Date: Tue, 21 Apr 2015 17:40:32 +0200
Message-ID: <2819798.f0KhjY3UAe@wuerfel>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org> <3231171.5TrYVVBLh4@wuerfel> <alpine.DEB.2.11.1504211701140.13914@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: y2038@lists.linaro.org, Baolin Wang <baolin.wang@linaro.org>,
	pang.xunlei@linaro.org, peterz@infradead.org,
	benh@kernel.crashing.org, heiko.carstens@de.ibm.com,
	paulus@samba.org, cl@linux.com, heenasirwani@gmail.com,
	linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
	mpe@ellerman.id.au, rafael.j.wysocki@intel.com, ahh@google.com,
	fweisbec@gmail.com, pjt@google.com, riel@redhat.com,
	richardcochran@gmail.com, schwidefsky@de.ibm.com,
	john.stultz@linaro.org, rth@twiddle.net,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tj@kernel.org, linux390@de.ibm.com,
	linuxppc-dev@lists.ozlabs.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1504211701140.13914@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 21 April 2015 17:13:32 Thomas Gleixner wrote:
> On Tue, 21 Apr 2015, Arnd Bergmann wrote:
> > On Tuesday 21 April 2015 16:14:26 Thomas Gleixner wrote:
> > > > Note the use of a separate __kernel_itimerspec64 for the user interface
> > > > here, which I think will be needed to hide the differences between the
> > > > normal itimerspec on 64-bit machines, and the new itimerspec on 32-bit
> > > > platforms that will be defined differently (using 'long long').
> > > 
> > > Confused.
> > > 
> > > timespec64 / itimerspec64 should be the same independent of 64bit and
> > > 32bit. So why do we need another variant ?
> > 
> > There are multiple reasons:
> > 
> > * On 64-bit systems, timespec64 would always be defined in the same way
> >   as struct timespec { __kernel_time_t tv_sec; long tv_nsec; }, with
> >   __kernel_time_t being 'long'. On 32-bit, we probably need to make both
> >   members 'long long' for the user space side, in order to share the
> >   syscall implementation with the kernel side, but we may also want to
> >   keep the internal timespec64 using a 'long' for tv_nsec, as we do
> >   today. This means that both the binary layout (padding or no padding)
> >   and the basic types (long or long long) are different between 32-bit
> >   and 64-bit, and between kernel and user space
> 
> So you want to avoid a compat syscall for 32bit applications on a
> 64bit kernel, right?

That is the idea at the moment, yes. At least for the kernel-user
interface.

> That burdens 32bit with the extra 'long long' in user space. Not sure
> whether user space folks will be happy about it.

I know there are concerns about this, in particular because C11 and
POSIX both require tv_nsec to be 'long', unlike timeval->tv_usec,
which is a 'suseconds_t' and can be defined as 'long long'.

There are four possible ways that 32-bit user space could define
timespec based on the uncontroversial (I hope) 'typedef long long
time_t;'.

a)

struct timespec {
	time_t tv_sec;
	long long tv_nsec; /* or typedef long long snseconds_t */
};

This is not directly compatible with C11 or POSIX.1-2008, but it
matches what we do inside of 64-bit kernels, so probably has the
highest chance of working correctly in practice

b)

struct timespec {
	time_t tv_sec;
	long tv_nsec;
};

This is the definition according to C11 and POSIX, and the main problem
here is the padding, which may cause a 4-byte data leak and has the tv_nsec
in the wrong place when used together with the timespec we have in the kernel
on big-endian 64-bit machines.

c)

struct timespec {
	time_t tv_sec;
#if __BITS_PER_LONG == 32 && __BYTE_ORDER == __BIG_ENDIAN
	long __pad;
#endif
	long tv_nsec; /* or typedef long long snseconds_t */
#if __BITS_PER_LONG == 32 && __BYTE_ORDER == __LITTLE_ENDIAN
	long __pad;
#endif
};

This version could be used transparently by user space, but has
the potential to cause problems with existing user space doing
things like

struct timespec ts = { 0, 1000 }; /* one microsecond */

even though it is probably compliant.

d)

struct timespec {
	time_t tv_sec;
#if __BITS_PER_LONG == 32 && __BYTE_ORDER == __BIG_ENDIAN
	long :32;
#endif
	long tv_nsec; /* or typedef long long snseconds_t */
#if __BITS_PER_LONG == 32 && __BYTE_ORDER == __LITTLE_ENDIAN
	long :32;
#endif
};

This is very similar to c, but trades the problem I described
above for a dependency on a gcc extension that is not part of
C11 or any earlier standard.


>From the kernel's point of view, b), c) and d) can all be
treated the same for output data, as we only ever pass back
normalized timespec structures that have zeroes in the upper
bits of timespec. However, for input to the kernel, we would
require an extra conditional on 64-bit kernels to decide whether
we ignore the upper bits (doing tv->tv_nsec &= 0xffffffff) or 
a structure that has the upper bits set  needs to cause EINVAL.
We could still do that in get_timespec() if we decide to not to
go with a).

See also https://lwn.net/Articles/457089/ for an earlier discussion
on the topic when debating the x32 ABI.

	Arnd
