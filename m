From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/5] Add functions producing system time given a backing
 counter value
Date: Wed, 29 Jul 2015 14:52:16 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1507291444310.3825@nanos>
References: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com> <1438044416-15588-2-git-send-email-christopher.s.hall@intel.com> <CALAqxLWSakB1zdnYAE=2yQTPLdzkjO3wLA82Q+CJoJccGLWM8Q@mail.gmail.com> <CALAqxLVkwJ5cmvSZ9bL-F7YTFprZ+CvZW4MrMN0sEkk5yFqMRQ@mail.gmail.com>
 <alpine.DEB.2.11.1507291014490.3825@nanos> <20150729104944.GM19282@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
	Christopher Hall <christopher.s.hall@intel.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	john.ronciak@intel.com, "H. Peter Anvin" <hpa@zytor.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150729104944.GM19282@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Jul 2015, Peter Zijlstra wrote:
> On Wed, Jul 29, 2015 at 12:19:06PM +0200, Thomas Gleixner wrote:
> > I don't know whether we need functionality to convert arbitrary
> > timestamps at all, but if we really need them then they are going to
> > be pretty simple and explicitely not precise for anything else than
> > clock monotonic raw. But that's a different story.
> 
> I think we need that too, and agreed, given NTP anything other than
> MONO_RAW is going to be fuzzy at best.

Yes, but that's a trivial case.
 
> > +static u64 art_to_tsc(u64 cycles)
> > +{
> > +	/* FIXME: This needs 128bit math to work proper */
> > +	return tsc_adjust + (cycles * tsc_numerator) / tsc_denominator;
> 
> Yeah, its really unfortunate its given as a divisor and not a shift.
> That said I think, at least on the initial hardware, its 2, so:
> 
> 	return mul_u64_u32_shr(cycles, tsc_numerator, 1);
> 
> Should do, given that TSC_ADJUST had better be 0.

I don't trust BIOS folks :)

+       u64 tmp, res = tsc_adjust;
+
+       res += (cycles / tsc_denominator) * tsc_numerator;
+       tmp = (cycles % tsc_denominator) * tsc_numerator;
+       res += tmp / tsc_denominator;
+       return res;

That's what I have in my final patch.
 
> > +	do {
> > +		seq = read_seqcount_begin(&tk_core.seq);
> > +		/*
> > +		 * Verify that the correlated clocksoure is related to
> > +		 * the currently installed timekeeper clocksoure
> > +		 */
> > +		if (tk->tkr_mono.clock != crs->related_cs)
> > +			return -ENODEV;
> > +
> > +		/*
> > +		 * Try to get a timestamp from the device.
> > +		 */
> > +		ret = crt->get_ts(crt);
> > +		if (ret)
> > +			return ret;
> > +
> > +		/*
> > +		 * Convert the timestamp to timekeeper clock cycles
> > +		 */
> > +		cycles = crs->convert(crs, crt->system_ts);
> > +
> > +		/* Convert to clock realtime */
> > +		base = ktime_add(tk->tkr_mono.base, tk_core.timekeeper.offs_real);
> > +		nsecs = timekeeping_convert_to_ns(&tk->tkr_mono, cycles);
> > +		crt->system_real = ktime_add_ns(base, nsecs);
> > +
> > +		/* Convert to clock raw monotonic */
> > +		base = tk->tkr_raw.base;
> > +		nsecs = timekeeping_convert_to_ns(&tk->tkr_raw, cycles);
> > +		crt->system_raw = ktime_add_ns(base, nsecs);
> > +
> > +	} while (read_seqcount_retry(&tk_core.seq, seq));
> > +	return 0;
> > +}
> 
> This is still fuzzy, right? The hardware ART timestamp could be from
> _before_ the NTP adjust; or the NTP adjust could happen while we do this
> conversion and we'll take the retry loop.

I read the timestamp pair in the loop, so its always consistent.
 
> Any other ART users (buffered ETH frames) the delay will only get
> bigger.

That's a different story and we really can only convert this to
monotonic raw.

Thanks,

	tglx
