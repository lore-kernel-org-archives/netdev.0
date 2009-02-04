From: Daniel Walker <dwalker@fifo99.com>
Subject: Re: [PATCH NET-NEXT 01/10] clocksource: allow usage independent of
	timekeeping.c
Date: Wed, 04 Feb 2009 06:03:55 -0800
Message-ID: <1233756235.15119.54.camel@desktop>
References: <1233752517-30010-1-git-send-email-patrick.ohly@intel.com>
	 <1233752517-30010-2-git-send-email-patrick.ohly@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fifo99.com ([67.223.236.141]:38756 "EHLO fifo99.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572AbZBDOD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 09:03:57 -0500
In-Reply-To: <1233752517-30010-2-git-send-email-patrick.ohly@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-02-04 at 14:01 +0100, Patrick Ohly wrote:

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

Where are these defined? I don't see any in created in your code.

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
> + * @cycle_last:		most recent cycle counter value seen by
> + *			timecounter_read()
> + * @nsec:		continuously increasing count
> + */
> +struct timecounter {
> +	const struct cyclecounter *cc;
> +	cycle_t cycle_last;
> +	u64 nsec;
> +};

If your mixing generic and non-generic code, it seems a little
presumptuous to assume the code would get called more often than the
counter wraps. If this cyclecounter is what I think it is (a
clocksource) they wrap at varied times.

> +/**
> + * cyclecounter_cyc2ns - converts cycle counter cycles to nanoseconds
> + * @tc:		Pointer to cycle counter.
> + * @cycles:	Cycles
> + *
> + * XXX - This could use some mult_lxl_ll() asm optimization. Same code
> + * as in cyc2ns, but with unsigned result.
> + */
> +static inline u64 cyclecounter_cyc2ns(const struct cyclecounter *cc,
> +				      cycle_t cycles)
> +{
> +	u64 ret = (u64)cycles;
> +	ret = (ret * cc->mult) >> cc->shift;
> +	return ret;
> +}

This is just outright duplication.. Why wouldn't you use the function
that already exists for this?

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

"bogus results" doesn't sound very pretty..

Daniel

