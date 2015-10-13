From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Tue, 13 Oct 2015 21:42:52 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1510132116480.25029@nanos>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com> <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, peterz@infradead.org, x86@kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.b.stanton@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Oct 2015, Christopher S. Hall wrote:
> Another representative use case of time sync and the correlated
> clocksource (in addition to PTP noted above) is PTP synchronized
> audio.

This wants to be a seperate patch, really.
 
> +/* This needs to be 3 or greater for backtracking to be useful */

Why?

> +#define SHADOW_HISTORY_DEPTH 7

And that number is 7 because?

>  static DEFINE_RAW_SPINLOCK(timekeeper_lock);
> -static struct timekeeper shadow_timekeeper;
> +static struct timekeeper shadow_timekeeper[SHADOW_HISTORY_DEPTH];
> +static int shadow_index = -1; /* incremented to zero in timekeeping_init() */

What's the point of this? Aside of that, please do not use tail comments.

> +static bool shadow_timekeeper_full;

That's silly. Make DEPTH a power of 2 and do:

       idx = (idx + 1) & (DEPTH - 1);

> +/*
> + * Modifies shadow index argument to point to the next array element
> + * Returns bool indicating shadow array fullness after the update
> + */
> +static bool get_next_shadow_index(int *shadow_index_out)
> +{
> +	*shadow_index_out = (shadow_index + 1) % SHADOW_HISTORY_DEPTH;
> +	/*
> +	 * If shadow timekeeper is full it stays full, otherwise compute
> +	 * the next value based on whether the index rolls over
> +	 */
> +	return shadow_timekeeper_full ?
> +		true : *shadow_index_out < shadow_index;

All this can go away.

> +	if (action & TK_MIRROR) {
> +		int next_shadow_index;
> +		bool next_shadow_full =
> +			get_next_shadow_index(&next_shadow_index);
> +		memcpy(shadow_timekeeper+next_shadow_index,
> +		       &tk_core.timekeeper, sizeof(tk_core.timekeeper));
> +		shadow_index = next_shadow_index;
> +		shadow_timekeeper_full = next_shadow_full;

Ditto.

> +	}
>  }
>  
>  /**
> @@ -884,6 +923,142 @@ EXPORT_SYMBOL(getnstime_raw_and_real);
>  
>  #endif /* CONFIG_NTP_PPS */
>  
> +/*
> + * Iterator-like function which can be called multiple times to return the
> + * previous shadow_index
> + * Returns false when finding previous is not possible because:
> + * - The array is not full
> + * - The previous shadow_index refers to an entry that may be in-flight
> + */
> +static bool get_prev_shadow_index(int *shadow_index_io)
> +{
> +	int guard_index;
> +	int ret = (*shadow_index_io - 1) % SHADOW_HISTORY_DEPTH;
> +
> +	ret += ret < 0 ? SHADOW_HISTORY_DEPTH : 0;
> +	/*
> +	 * guard_index references the next shadow entry, assume that this
> +	 * isn't valid since its not protected by sequence lock
> +	 */
> +	get_next_shadow_index(&guard_index);
> +	/* if the array isn't full and index references top (invalid) entry */
> +	if (!shadow_timekeeper_full && ret > *shadow_index_io)
> +		return false;
> +	/* the next entry may be in-flight and may be invalid  */
> +	if (ret == guard_index)
> +		return false;
> +	/* Also make sure that entry is valid based on current shadow_index */
> +	*shadow_index_io = ret;
> +	return true;

You surely try hard to do stuff in the most unreadable way. 

> +/**
> + * get_correlated_timestamp - Get a correlated timestamp
> + * @crs: conversion between correlated clock and system clock
> + * @crt: callback to get simultaneous device and correlated clock value *or*
> + *	contains a valid correlated clock value and NULL callback
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
> +	struct timekeeper *tk = &tk_core.timekeeper;
> +	unsigned long seq;
> +	cycles_t cycles, cycles_now, cycles_last;
> +	ktime_t base;
> +	s64 nsecs;
> +	int ret;
> +
> +	do {
> +		seq = read_seqcount_begin(&tk_core.seq);
> +		/*
> +		 * Verify that the correlated clocksoure is related to
> +		 * the currently installed timekeeper clocksoure
> +		 */
> +		if (tk->tkr_mono.clock != crs->related_cs)
> +			return -ENODEV;
> +
> +		/*
> +		 * Get a timestamp from the device if get_ts is non-NULL
> +		 */
> +		if( crt->get_ts ) {
> +			ret = crt->get_ts(crt);
> +			if (ret)
> +				return ret;
> +		}

What's the point of this? Why are you not making the few lines which
you can actually reuse a helper function and leave the PTP code alone?

> -- 
> 2.1.4

So I reached enf of patch and did not find anything in
timekeeping_init() which tells that the index is incremented to 0. It
really would need a comment, but why do you want to do that at all. It
does not matter whether the first entry is at 0 or 1. You need a
validity check for the entries anyway.

Thanks,

	tglx
