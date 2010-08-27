From: John Stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Fri, 27 Aug 2010 13:14:11 -0700
Message-ID: <1282940051.2268.18.camel@jstultz-laptop>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	 <1282176776.2865.100.camel@localhost.localdomain>
	 <20100819055518.GA4084@riccoc20.at.omicron.at>
	 <201008191428.04546.arnd@arndb.de>
	 <20100819153847.GA10695@riccoc20.at.omicron.at>
	 <1282594899.3111.358.camel@localhost.localdomain>
	 <20100827110855.GA11657@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Rodolfo Giometti <giometti@linux.it>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100827110855.GA11657@riccoc20.at.omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-08-27 at 13:08 +0200, Richard Cochran wrote:
> On Mon, Aug 23, 2010 at 01:21:39PM -0700, john stultz wrote:
> > On Thu, 2010-08-19 at 17:38 +0200, Richard Cochran wrote:
> > > On Thu, Aug 19, 2010 at 02:28:04PM +0200, Arnd Bergmann wrote:
> > > > My point was that a syscall is better than an ioctl based interface here,
> > > > which I definitely still think. Given that John knows much more about
> > > > clocks than I do, we still need to get agreement on the question that
> > > > he raised, which is whether we actually need to expose this clock to the
> > > > user or not.
> > > > 
> > > > If we can find a way to sync system time accurate enough with PTP and
> > > > PPS, user applications may not need to see two separate clocks at all.
> > > 
> > > At the very least, one user application (the PTPd) needs to see the
> > > PTP clock.
> > > 
> > > > > SYSCALL_DEFINE3(clock_adjtime, const clockid_t, clkid,
> > > > > 		int, ppb, struct timespec __user *, ts)
> > > > > 
> > > > > ppb - desired frequency adjustment in parts per billion
> > > > > ts  - desired time step (or jump) in <sec,nsec> to correct
> > > > >       a measured offset
> > > > > 
> > > > > Arguably, this syscall might be useful for other clocks, too.
> > > > 
> > > > This is a mix of adjtime and adjtimex with the addition of
> > > > the clkid parameter, right?
> > > 
> > > Sort of, but not really. ADJTIME(3) takes an offset and slowly
> > > corrects the clock using a servo in the kernel, over hours.
> > > 
> > > For this function, the offset passed in the 'ts' parameter will be
> > > immediately corrected, by jumping to the new time. This reflects the
> > > way that PTP works. After the first few samples, the PTPd has an
> > > estimate of the offset to the master and the rate difference. The PTPd
> > > can proceed in one of two ways.
> > > 
> > > 1. If resetting the clock is not desired, then the clock is set to the
> > >    maximum adjustment (in the right direction) until the clock time is
> > >    close to the master's time.
> > > 
> > > 2. The estimated offset is added to the current time, resulting in a
> > >    jump in time.
> > > 
> > > We need clock_adjtime(id, 0, ts) for the second case.
> > >
> > > > Have you considered passing a struct timex instead of ppb and ts?
> > > 
> > > Yes, but the timex is not suitable, IMHO.
> > 
> > Could you expand on this?
> 
> We need to able to specify that the call is for a PTP clock. We could
> add that to the modes flag, like this:
> 
> /*timex.h*/
> #define ADJ_PTP_0 0x10000
> #define ADJ_PTP_1 0x20000
> #define ADJ_PTP_2 0x30000
> #define ADJ_PTP_3 0x40000
> 
> I can live with this, if everyone else can, too.

I wasn't suggesting adding the clock multiplexing to the timex, just
using the timex to specify the adjustments in the clock_adjtime call. 

So I was asking why a timex was not suitable instead of using just the
ppb and timespec.


> > Could we not add a adjustment mode ADJ_SETOFFSET or something that would
> > provide the instantaneous offset correction?
> 
> Yes, but we would also need to add a struct timespec to the struct
> timex, in order to get nanosecond resolution. I think it would be
> possible to do in the padding at the end?


The existing struct timeval in the timex can be also used as a timespec.
NTPv4 uses it that way specifying the ADJ_NANO flag.


> > You're right that the timex is a little crufty. But its legacy that we
> > will support indefinitely. So following the established interface helps
> > maintainability.
> 
> We can use it for PTP, with the modifications suggested above. Or we
> can just introduce the clock_adjtime method, instead.

Again, I think you misunderstood my suggestion. I was suggesting
something like clock_adjtime(clock_id, struct timex*).


> > So if the clock_adjtime interface is needed, it would seem best for it
> > to be generic enough to support not only PTP, but also the NTP kernel
> > PLL.
> 
> For the proposed clock_adjime, what else is needed to support clock
> adjustment in general?
> 
> I don't mind making the interface generic enough to support any
> (realistic) conceivable clock adjustment scheme, but beyond the
> present PTP hardware clocks, I don't know what else might be needed.

I think using the timex struct covers most of the existing knowledge of
what is needed. 

thanks
-john
