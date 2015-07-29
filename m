From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/5] Add functions producing system time given a backing
 counter value
Date: Wed, 29 Jul 2015 12:49:44 +0200
Message-ID: <20150729104944.GM19282@twins.programming.kicks-ass.net>
References: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
 <1438044416-15588-2-git-send-email-christopher.s.hall@intel.com>
 <CALAqxLWSakB1zdnYAE=2yQTPLdzkjO3wLA82Q+CJoJccGLWM8Q@mail.gmail.com>
 <CALAqxLVkwJ5cmvSZ9bL-F7YTFprZ+CvZW4MrMN0sEkk5yFqMRQ@mail.gmail.com>
 <alpine.DEB.2.11.1507291014490.3825@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Stultz <john.stultz@linaro.org>,
	Christopher Hall <christopher.s.hall@intel.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	john.ronciak@intel.com, "H. Peter Anvin" <hpa@zytor.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1507291014490.3825@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 29, 2015 at 12:19:06PM +0200, Thomas Gleixner wrote:
> I don't know whether we need functionality to convert arbitrary
> timestamps at all, but if we really need them then they are going to
> be pretty simple and explicitely not precise for anything else than
> clock monotonic raw. But that's a different story.

I think we need that too, and agreed, given NTP anything other than
MONO_RAW is going to be fuzzy at best.

> Index: linux/arch/x86/kernel/tsc.c
> ===================================================================
> --- linux.orig/arch/x86/kernel/tsc.c
> +++ linux/arch/x86/kernel/tsc.c
> @@ -1059,6 +1059,23 @@ int unsynchronized_tsc(void)
>  	return 0;
>  }
>  
> +static u32 tsc_numerator;
> +static u32 tsc_denominator;
> +/*
> + * CHECKME: Do we need the adjust value? It should be 0, but if we run
> + * in a VM this might be a different story.
> + */
> +static u64 tsc_adjust;
> +
> +static u64 art_to_tsc(u64 cycles)
> +{
> +	/* FIXME: This needs 128bit math to work proper */
> +	return tsc_adjust + (cycles * tsc_numerator) / tsc_denominator;

Yeah, its really unfortunate its given as a divisor and not a shift.
That said I think, at least on the initial hardware, its 2, so:

	return mul_u64_u32_shr(cycles, tsc_numerator, 1);

Should do, given that TSC_ADJUST had better be 0.

> +}



> + * get_correlated_timestamp - Get a correlated timestamp
> + *
> + * Reads a timestamp from a device and correlates it to system time
> + */
> +int get_correlated_timestamp(struct correlated_ts *crt,
> +			     struct correlated_cs *crs)
> +{
> +	struct timekeeper *tk = &tk_core.timekeeper;
> +	unsigned long seq;
> +	cycles_t cycles;
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
> +		 * Try to get a timestamp from the device.
> +		 */
> +		ret = crt->get_ts(crt);
> +		if (ret)
> +			return ret;
> +
> +		/*
> +		 * Convert the timestamp to timekeeper clock cycles
> +		 */
> +		cycles = crs->convert(crs, crt->system_ts);
> +
> +		/* Convert to clock realtime */
> +		base = ktime_add(tk->tkr_mono.base, tk_core.timekeeper.offs_real);
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

This is still fuzzy, right? The hardware ART timestamp could be from
_before_ the NTP adjust; or the NTP adjust could happen while we do this
conversion and we'll take the retry loop.

In both cases, the resulting value is computed using a different slope
than was in effect at the time of the stamp. With the end result being
slightly off from what it should be.

With the PTP case the ART timestamp is very recent, so the fuzz is
smallest, but its still there.

Any other ART users (buffered ETH frames) the delay will only get
bigger.
