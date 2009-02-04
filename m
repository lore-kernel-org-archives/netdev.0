From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [PATCH NET-NEXT 01/10] clocksource: allow usage independent of
	timekeeping.c
Date: Wed, 04 Feb 2009 15:46:36 +0100
Message-ID: <1233758796.15940.198.camel@ecld0pohly>
References: <1233752517-30010-1-git-send-email-patrick.ohly@intel.com>
	 <1233752517-30010-2-git-send-email-patrick.ohly@intel.com>
	 <1233756235.15119.54.camel@desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Daniel Walker <dwalker@fifo99.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:29177 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751338AbZBDOql (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 09:46:41 -0500
In-Reply-To: <1233756235.15119.54.camel@desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel!

Thanks for looking at this. I think the previous discussion of this
patch under the same subject on LKML already addressed your concerns,
but I'll also reply in detail below.

On Wed, 2009-02-04 at 14:03 +0000, Daniel Walker wrote:
> On Wed, 2009-02-04 at 14:01 +0100, Patrick Ohly wrote:
> 
> >  /**
> > + * struct cyclecounter - hardware abstraction for a free running counter
> > + *	Provides completely state-free accessors to the underlying hardware.
> > + *	Depending on which hardware it reads, the cycle counter may wrap
> > + *	around quickly. Locking rules (if necessary) have to be defined
> > + *	by the implementor and user of specific instances of this API.
> > + *
> > + * @read:		returns the current cycle value
> > + * @mask:		bitmask for two's complement
> > + *			subtraction of non 64 bit counters,
> > + *			see CLOCKSOURCE_MASK() helper macro
> > + * @mult:		cycle to nanosecond multiplier
> > + * @shift:		cycle to nanosecond divisor (power of two)
> > + */
> > +struct cyclecounter {
> > +	cycle_t (*read)(const struct cyclecounter *cc);
> > +	cycle_t mask;
> > +	u32 mult;
> > +	u32 shift;
> > +};
> 
> Where are these defined? I don't see any in created in your code.

What do you mean with "these"? cycle_t? That type is defined in
clocksource.h. This patch intentionally adds these definitions to the
existing file because of the large conceptual overlap.

In an earlier revision of the patch I had adapted clocksource itself so
that it could be used outside of the time keeping code; John wanted me
to use these smaller structs instead that you now find in the current
patch.

Eventually John wants to refactor clocksource so that it uses them and
just adds additional elements in clocksource. Right now clocksource is a
mixture of different concepts. Breaking out cyclecounter and timecounter
is a first step towards that cleanup.

> > +/**
> > + * struct timecounter - layer above a %struct cyclecounter which counts nanoseconds
> > + *	Contains the state needed by timecounter_read() to detect
> > + *	cycle counter wrap around. Initialize with
> > + *	timecounter_init(). Also used to convert cycle counts into the
> > + *	corresponding nanosecond counts with timecounter_cyc2time(). Users
> > + *	of this code are responsible for initializing the underlying
> > + *	cycle counter hardware, locking issues and reading the time
> > + *	more often than the cycle counter wraps around. The nanosecond
> > + *	counter will only wrap around after ~585 years.
> > + *
> > + * @cc:			the cycle counter used by this instance
> > + * @cycle_last:		most recent cycle counter value seen by
> > + *			timecounter_read()
> > + * @nsec:		continuously increasing count
> > + */
> > +struct timecounter {
> > +	const struct cyclecounter *cc;
> > +	cycle_t cycle_last;
> > +	u64 nsec;
> > +};
> 
> If your mixing generic and non-generic code, it seems a little
> presumptuous to assume the code would get called more often than the
> counter wraps. If this cyclecounter is what I think it is (a
> clocksource) they wrap at varied times.

timecounter and cyclecounter will have the same owner, so that owner
knows how often the cycle counter will run over and can use it
accordingly.

The cyclecounter is a pointer and not just a an instance of cyclecounter
so that the owner can pick an instance of a timecounter which has
additional private data attached to it.

The initial user of the new code will have a 64 bit hardware register as
cycle counter. We decided to leave the "counter runs over too often"
problem unsolved until we actually have hardware which exhibits the
problem.

> > +/**
> > + * cyclecounter_cyc2ns - converts cycle counter cycles to nanoseconds
> > + * @tc:		Pointer to cycle counter.
> > + * @cycles:	Cycles
> > + *
> > + * XXX - This could use some mult_lxl_ll() asm optimization. Same code
> > + * as in cyc2ns, but with unsigned result.
> > + */
> > +static inline u64 cyclecounter_cyc2ns(const struct cyclecounter *cc,
> > +				      cycle_t cycles)
> > +{
> > +	u64 ret = (u64)cycles;
> > +	ret = (ret * cc->mult) >> cc->shift;
> > +	return ret;
> > +}
> 
> This is just outright duplication.. Why wouldn't you use the function
> that already exists for this?

Because it only works with a clocksource. Adding a second function also
allows using a saner return type (unsigned instead of signed). Removing
the code duplication can be done as part of the code refactoring. But
that really is beyond the scope of the patch series and shouldn't be
done in the network tree.

> > +/**
> > + * clocksource_read_ns - get nanoseconds since last call of this function
> > + * @tc:         Pointer to time counter
> > + *
> > + * When the underlying cycle counter runs over, this will be handled
> > + * correctly as long as it does not run over more than once between
> > + * calls.
> > + *
> > + * The first call to this function for a new time counter initializes
> > + * the time tracking and returns bogus results.
> > + */
> 
> "bogus results" doesn't sound very pretty..

I can call it "undefined" if that sounds better ;-)

When you quoted the comment I noticed that the function name was still
the old one - fixed.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

