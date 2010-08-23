From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Mon, 23 Aug 2010 13:21:39 -0700
Message-ID: <1282594899.3111.358.camel@localhost.localdomain>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	 <1282176776.2865.100.camel@localhost.localdomain>
	 <20100819055518.GA4084@riccoc20.at.omicron.at>
	 <201008191428.04546.arnd@arndb.de>
	 <20100819153847.GA10695@riccoc20.at.omicron.at>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:48956 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754307Ab0HWUVr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 16:21:47 -0400
In-Reply-To: <20100819153847.GA10695@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-08-19 at 17:38 +0200, Richard Cochran wrote:
> On Thu, Aug 19, 2010 at 02:28:04PM +0200, Arnd Bergmann wrote:
> > My point was that a syscall is better than an ioctl based interface here,
> > which I definitely still think. Given that John knows much more about
> > clocks than I do, we still need to get agreement on the question that
> > he raised, which is whether we actually need to expose this clock to the
> > user or not.
> > 
> > If we can find a way to sync system time accurate enough with PTP and
> > PPS, user applications may not need to see two separate clocks at all.
> 
> At the very least, one user application (the PTPd) needs to see the
> PTP clock.
> 
> > > SYSCALL_DEFINE3(clock_adjtime, const clockid_t, clkid,
> > > 		int, ppb, struct timespec __user *, ts)
> > > 
> > > ppb - desired frequency adjustment in parts per billion
> > > ts  - desired time step (or jump) in <sec,nsec> to correct
> > >       a measured offset
> > > 
> > > Arguably, this syscall might be useful for other clocks, too.
> > 
> > This is a mix of adjtime and adjtimex with the addition of
> > the clkid parameter, right?
> 
> Sort of, but not really. ADJTIME(3) takes an offset and slowly
> corrects the clock using a servo in the kernel, over hours.
> 
> For this function, the offset passed in the 'ts' parameter will be
> immediately corrected, by jumping to the new time. This reflects the
> way that PTP works. After the first few samples, the PTPd has an
> estimate of the offset to the master and the rate difference. The PTPd
> can proceed in one of two ways.
> 
> 1. If resetting the clock is not desired, then the clock is set to the
>    maximum adjustment (in the right direction) until the clock time is
>    close to the master's time.
> 
> 2. The estimated offset is added to the current time, resulting in a
>    jump in time.
> 
> We need clock_adjtime(id, 0, ts) for the second case.
>
> > Have you considered passing a struct timex instead of ppb and ts?
> 
> Yes, but the timex is not suitable, IMHO.

Could you expand on this?

Could we not add a adjustment mode ADJ_SETOFFSET or something that would
provide the instantaneous offset correction?

> > Is using ppb instead of the timex ppm required to get the accuracy
> > you want?
> 
> That is one very good reason.
> 
> Another is this: can you explain what the 20+ fields mean?
> 
> Consider the field, freq. The comment says "frequency offset (scaled
> ppm)."  To what is it scaled? The only way I know of to find out is to
> read the NTP code (which is fairly complex) and see what the unit
> really is meant to be. Ditto for the other fields.
> 
> The timex structure reveals, AFAICT, the inner workings of the kernel
> clock servo. For PTP, we don't need or want the kernel servo. The PTPd
> has its own clock servo in user space.

You're right that the timex is a little crufty. But its legacy that we
will support indefinitely. So following the established interface helps
maintainability.

So if the clock_adjtime interface is needed, it would seem best for it
to be generic enough to support not only PTP, but also the NTP kernel
PLL. 

In effect, this would make clock_adjtime(or clock_adjtimex) identical to
adjtimex, but only applicable to different CLOCK_ids. Additionally, it
would simplify the code for the CLOCK_REALTIME case as you could just
call directly into do_adjtimex(). 

Of course, extending adjtimex for ADJ_SETOFFSET would be needed first,
but that seems like a reasonable expansion of the interface that could
be used by more then just PTP.

thanks
-john


