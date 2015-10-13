From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Tue, 13 Oct 2015 15:50:32 +0200
Message-ID: <20151013135032.GA5422@localhost.localdomain>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
 <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	tglx@linutronix.de, john.stultz@linaro.org, peterz@infradead.org,
	x86@kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kevin.b.stanton@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that I am starting to understand what this code is trying to
achieve...

On Mon, Oct 12, 2015 at 11:45:19AM -0700, Christopher S. Hall wrote:
> The modification to the original patch accomodates these
> slow devices by adding the option of providing an ART value outside
> of the retry loop and adding a history which can consulted in the
> case of an out of date counter value. The history is kept by
> making the shadow_timekeeper an array. Each write to the
> timekeeper rotates through the array, preserving a
> history of updates.

You did not provide an example of how this function is called, in the
special case where correlated_ts.get_ts = NULL and the caller provides
system_ts and device_ts.  Until that user appears, we do not need the
interface at all.

> +/* This needs to be 3 or greater for backtracking to be useful */
> +#define SHADOW_HISTORY_DEPTH 7

Why then have you put 7?

This comment should really explain what is needed and why.

> +/**
> + * get_correlated_timestamp - Get a correlated timestamp

This function is tremendously confusing.  The overloading with special
semenatics when the callback is NULL is not nice.  There is hardly
much shared logic, and so nothing speaks against having two methods.
I would call them "get_correlated_timestamp" and "correlate_timestamp"
or similar.  The "get_" prefix in the name is totally misleading in
your special case.

> + * @crs: conversion between correlated clock and system clock
> + * @crt: callback to get simultaneous device and correlated clock value *or*
> + *	contains a valid correlated clock value and NULL callback

This description stinks.  What is crs?  It is *not* a conversion.  It is:

	struct correlated_ts - Descriptor for taking a correlated time stamp

What is crt?  It is *not* a callback.  It is:

	struct correlated_cs - Descriptor for a clocksource correlated to another

For the crt, the kerneldoc should explain which of the fields

	int			(*get_ts)(struct correlated_ts *ts);
	u64			system_ts;
	u64			device_ts;
	ktime_t			system_real;
	ktime_t			system_raw;
	void			*private;

are provided by the caller and which are set by the function.  The
fact that fields are set either by the caller or by the method is a
funny code smell.

> + *
> + * Reads a timestamp from a device and correlates it to system time.  This
> + * function can be used in two ways.  If a non-NULL get_ts function pointer is
> + * supplied in @crt, this function is called within the retry loop to
> + * read the current correlated clock value and associated device time.
> + * Otherwise (get_ts is NULL) a correlated clock value is supplied and
> + * the history in shadow_timekeeper is consulted if necessary.
> + */
> +int get_correlated_timestamp(struct correlated_ts *crt,
> +			     struct correlated_cs *crs)
> +{
...
> +	do {

This code is only used in the special case:

> +		/*
> +		 * Since the cycles value is supplied outside of the loop,
> +		 * there is no guarantee that it represents a time *after*
> +		 * cycle_last do some checks to figure out whether it's
> +		 * represents the past or the future taking rollover
> +		 * into account. If the value is in the past, try to backtrack
> +		 */

BTW, isn't there an easier way to deal with time stamps in the past?
(Compare with timecounter_cyc2time.)

> +		cycles_now = tk->tkr_mono.read(tk->tkr_mono.clock);
> +		cycles_last = tk->tkr_mono.cycle_last;
> +		if ((cycles >= cycles_last && cycles_now < cycles) ||
> +		    (cycles < cycles_last && cycles_now >= cycles_last)) {
> +			/* cycles is in the past try to backtrack */
> +			int backtrack_index = shadow_index;
> +
> +			while (get_prev_shadow_index(&backtrack_index)) {
> +				tk = shadow_timekeeper+backtrack_index;
> +				if (cycle_between(cycles_last, cycles,
> +						  tk->tkr_mono.cycle_last))
> +					goto do_convert;
> +				cycles_last = tk->tkr_mono.cycle_last;
> +			}
> +			return -EAGAIN;
> +		}

And this is the shared stuff:

> +do_convert:
> +		/* Convert to clock realtime */
> +		base = ktime_add(tk->tkr_mono.base,
> +				 tk_core.timekeeper.offs_real);
> +		nsecs = timekeeping_convert_to_ns(&tk->tkr_mono, cycles);
> +		crt->system_real = ktime_add_ns(base, nsecs);
> +
> +		/* Convert to clock raw monotonic */
> +		base = tk->tkr_raw.base;
> +		nsecs = timekeeping_convert_to_ns(&tk->tkr_raw, cycles);
> +		crt->system_raw = ktime_add_ns(base, nsecs);
> +
> +	} while (read_seqcount_retry(&tk_core.seq, seq));
> +	return 0;
> +}

I suggest moving the shared stuff into a subroutine and providing two
different functions.

Thanks,
Richard
