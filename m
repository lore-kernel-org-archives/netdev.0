From: John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 09/12] clocksource: allow usage independent of
 timekeeping.c
Date: Mon, 15 Dec 2008 08:26:50 -0800
Message-ID: <1229358410.8699.13.camel@jstultz-laptop>
References: <1229352899-31330-1-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-2-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-3-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-4-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-5-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-6-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-7-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-8-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-9-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-10-git-send-email-patrick.ohly@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1229352899-31330-10-git-send-email-patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-12-15 at 15:54 +0100, Patrick Ohly wrote:
> So far struct clocksource acted as the interface between time/timekeeping.c
> and hardware. This patch generalizes the concept so that a similar
> interface can also be used in other contexts. For that it introduces
> new structures and related functions *without* touching the existing
> struct clocksource.
> 
> The reasons for adding these new structures to clocksource.[ch] are
> * the APIs are clearly related
> * struct clocksource could be cleaned up to use the new structs
> * avoids proliferation of files with similar names (timesource.h?
>   timecounter.h?)
> 
> As outlined in the discussion with John Stultz, this patch adds
> * struct cyclecounter: stateless API to hardware which counts clock cycles
> * struct timecounter: stateful utility code built on a cyclecounter which
>   provides a nanosecond counter
> * only the function to read the nanosecond counter; deltas are used internally
>   and not exposed to users of timecounter
> 
> The code does no locking of the shared state. It must be called at least
> as often as the cycle counter wraps around to detect these wrap arounds.
> Both is the responsibility of the timecounter user.
> 
> Signed-off-by: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Nice. The cyclecounter struct can work as a good base that I can shift
the clocksource bits over to as I clean that up.

We will probably want to split this out down the road, but for now its
small enough and related enough that I think its fine in the
clocksource.h/c.

Also since Magnus has been working on it, does enable/disable accessors
in the cyclecounter struct make sense for your hardware as well?

Also the corner cases on overflows (how we manage the state, should
reads be deferred for too long) will need to be addressed, but I guess
we can solve that when it becomes an issue. Just to be clear: none of
the hardware you're submitting this round has wrapping issues? Or is
that not the case?

Otherwise,
Acked-by: John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

thanks
-john


> ---
>  include/linux/clocksource.h |   99 +++++++++++++++++++++++++++++++++++++++++++
>  kernel/time/clocksource.c   |   76 +++++++++++++++++++++++++++++++++
>  2 files changed, 175 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
> index f88d32f..d379189 100644
> --- a/include/linux/clocksource.h
> +++ b/include/linux/clocksource.h
> @@ -22,8 +22,107 @@ typedef u64 cycle_t;
>  struct clocksource;
> 
>  /**
> + * struct cyclecounter - hardware abstraction for a free running counter
> + *	Provides completely state-free accessors to the underlying hardware.
> + *	Depending on which hardware it reads, the cycle counter may wrap
> + *	around quickly. Locking rules (if necessary) have to be defined
> + *	by the implementor and user of specific instances of this API.
> + *
> + * @read:		returns the current cycle value
> + * @mask:		bitmask for two's complement
> + *			subtraction of non 64 bit counters,
> + *			see CLOCKSOURCE_MASK() helper macro
> + * @mult:		cycle to nanosecond multiplier
> + * @shift:		cycle to nanosecond divisor (power of two)
> + */
> +struct cyclecounter {
> +	cycle_t (*read)(const struct cyclecounter *cc);
> +	cycle_t mask;
> +	u32 mult;
> +	u32 shift;
> +};
> +
> +/**
> + * struct timecounter - layer above a %struct cyclecounter which counts nanoseconds
> + *	Contains the state needed by timecounter_read() to detect
> + *	cycle counter wrap around. Initialize with
> + *	timecounter_init(). Also used to convert cycle counts into the
> + *	corresponding nanosecond counts with timecounter_cyc2time(). Users
> + *	of this code are responsible for initializing the underlying
> + *	cycle counter hardware, locking issues and reading the time
> + *	more often than the cycle counter wraps around. The nanosecond
> + *	counter will only wrap around after ~585 years.
> + *
> + * @cc:			the cycle counter used by this instance
> + * @cycle_last:		most recent cycle counter value seen by timecounter_read()
> + * @nsec:		
> + */
> +struct timecounter {
> +	const struct cyclecounter *cc;
> +	cycle_t cycle_last;
> +	u64 nsec;
> +};
> +
> +/**
> + * cyclecounter_cyc2ns - converts cycle counter cycles to nanoseconds
> + * @tc:		Pointer to cycle counter.
> + * @cycles:	Cycles
> + *
> + * XXX - This could use some mult_lxl_ll() asm optimization. Same code
> + * as in cyc2ns, but with unsigned result.
> + */
> +static inline u64 cyclecounter_cyc2ns(const struct cyclecounter *cc, cycle_t cycles)
> +{
> +	u64 ret = (u64)cycles;
> +	ret = (ret * cc->mult) >> cc->shift;
> +	return ret;
> +}
> +
> +/**
> + * timecounter_init - initialize a time counter
> + * @tc:			Pointer to time counter which is to be initialized/reset
> + * @cc:			A cycle counter, ready to be used.
> + * @start_tstamp:	Arbitrary initial time stamp.
> + *
> + * After this call the current cycle register (roughly) corresponds to
> + * the initial time stamp. Every call to timecounter_read() increments
> + * the time stamp counter by the number of elapsed nanoseconds.
> + */
> +extern void timecounter_init(struct timecounter *tc,
> +			const struct cyclecounter *cc,
> +			u64 start_tstamp);
> +
> +/**
> + * timecounter_read - return nanoseconds elapsed since timecounter_init()
> + *                         plus the initial time stamp
> + * @tc:          Pointer to time counter.
> + *
> + * In other words, keeps track of time since the same epoch as
> + * the function which generated the initial time stamp.
> + */
> +extern u64 timecounter_read(struct timecounter *tc);
> +
> +/**
> + * timecounter_cyc2time - convert a cycle counter to same
> + *                        time base as values returned by
> + *                        timecounter_read()
> + * @tc:		Pointer to time counter.
> + * @cycle:	a value returned by tc->cc->read()
> + *
> + * Cycle counts that are converted correctly as long as they
> + * fall into the interval [-1/2 max cycle count, +1/2 max cycle count],
> + * with "max cycle count" == cs->mask+1.
> + *
> + * This allows conversion of cycle counter values which were generated
> + * in the past.
> + */
> +extern u64 timecounter_cyc2time(struct timecounter *tc,
> +				cycle_t cycle_tstamp);
> +
> +/**
>   * struct clocksource - hardware abstraction for a free running counter
>   *	Provides mostly state-free accessors to the underlying hardware.
> + *	This is the structure used for system time.
>   *
>   * @name:		ptr to clocksource name
>   * @list:		list head for registration
> diff --git a/kernel/time/clocksource.c b/kernel/time/clocksource.c
> index 9ed2eec..0d7a2cb 100644
> --- a/kernel/time/clocksource.c
> +++ b/kernel/time/clocksource.c
> @@ -31,6 +31,82 @@
>  #include <linux/sched.h> /* for spin_unlock_irq() using preempt_count() m68k */
>  #include <linux/tick.h>
> 
> +void timecounter_init(struct timecounter *tc,
> +		const struct cyclecounter *cc,
> +		u64 start_tstamp)
> +{
> +	tc->cc = cc;
> +	tc->cycle_last = cc->read(cc);
> +	tc->nsec = start_tstamp;
> +}
> +EXPORT_SYMBOL(timecounter_init);
> +
> +/**
> + * clocksource_read_ns - get nanoseconds since last call of this function
> + * @tc:         Pointer to time counter
> + *
> + * When the underlying cycle counter runs over, this will be handled
> + * correctly as long as it does not run over more than once between
> + * calls.
> + *
> + * The first call to this function for a new time counter initializes
> + * the time tracking and returns bogus results.
> + */
> +static u64 timecounter_read_delta(struct timecounter *tc)
> +{
> +	cycle_t cycle_now, cycle_delta;
> +	u64 ns_offset;
> +
> +	/* read cycle counter: */
> +	cycle_now = tc->cc->read(tc->cc);
> +
> +	/* calculate the delta since the last timecounter_read_delta(): */
> +	cycle_delta = (cycle_now - tc->cycle_last) & tc->cc->mask;
> +
> +	/* convert to nanoseconds: */
> +	ns_offset = cyclecounter_cyc2ns(tc->cc, cycle_delta);
> +
> +	/* update time stamp of timecounter_read_delta() call: */
> +	tc->cycle_last = cycle_now;
> +
> +	return ns_offset;
> +}
> +
> +u64 timecounter_read(struct timecounter *tc)
> +{
> +	u64 nsec;
> +
> +	/* increment time by nanoseconds since last call */
> +	nsec = timecounter_read_delta(tc);
> +	nsec += tc->nsec;
> +	tc->nsec = nsec;
> +
> +	return nsec;
> +}
> +EXPORT_SYMBOL(timecounter_read);
> +
> +u64 timecounter_cyc2time(struct timecounter *tc,
> +			cycle_t cycle_tstamp)
> +{
> +	u64 cycle_delta = (cycle_tstamp - tc->cycle_last) & tc->cc->mask;
> +	u64 nsec;
> +
> +	/*
> +	 * Instead of always treating cycle_tstamp as more recent
> +	 * than tc->cycle_last, detect when it is too far in the
> +	 * future and treat it as old time stamp instead.
> +	 */
> +	if (cycle_delta > tc->cc->mask / 2) {
> +		cycle_delta = (tc->cycle_last - cycle_tstamp) & tc->cc->mask;
> +		nsec = tc->nsec - cyclecounter_cyc2ns(tc->cc, cycle_delta);
> +	} else {
> +		nsec = cyclecounter_cyc2ns(tc->cc, cycle_delta) + tc->nsec;
> +	}
> +
> +	return nsec;
> +}
> +EXPORT_SYMBOL(timecounter_cyc2time);
> +
>  /* XXX - Would like a better way for initializing curr_clocksource */
>  extern struct clocksource clocksource_jiffies;
> 

--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
