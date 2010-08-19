From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Thu, 19 Aug 2010 17:38:47 +0200
Message-ID: <20100819153847.GA10695@riccoc20.at.omicron.at>
References: <cover.1281956490.git.richard.cochran@omicron.at>
 <1282176776.2865.100.camel@localhost.localdomain>
 <20100819055518.GA4084@riccoc20.at.omicron.at>
 <201008191428.04546.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john stultz <johnstul@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Rodolfo Giometti <giometti@linux.it>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39739 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824Ab0HSPi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 11:38:28 -0400
Content-Disposition: inline
In-Reply-To: <201008191428.04546.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 19, 2010 at 02:28:04PM +0200, Arnd Bergmann wrote:
> My point was that a syscall is better than an ioctl based interface here,
> which I definitely still think. Given that John knows much more about
> clocks than I do, we still need to get agreement on the question that
> he raised, which is whether we actually need to expose this clock to the
> user or not.
> 
> If we can find a way to sync system time accurate enough with PTP and
> PPS, user applications may not need to see two separate clocks at all.

At the very least, one user application (the PTPd) needs to see the
PTP clock.

> > SYSCALL_DEFINE3(clock_adjtime, const clockid_t, clkid,
> > 		int, ppb, struct timespec __user *, ts)
> > 
> > ppb - desired frequency adjustment in parts per billion
> > ts  - desired time step (or jump) in <sec,nsec> to correct
> >       a measured offset
> > 
> > Arguably, this syscall might be useful for other clocks, too.
> 
> This is a mix of adjtime and adjtimex with the addition of
> the clkid parameter, right?

Sort of, but not really. ADJTIME(3) takes an offset and slowly
corrects the clock using a servo in the kernel, over hours.

For this function, the offset passed in the 'ts' parameter will be
immediately corrected, by jumping to the new time. This reflects the
way that PTP works. After the first few samples, the PTPd has an
estimate of the offset to the master and the rate difference. The PTPd
can proceed in one of two ways.

1. If resetting the clock is not desired, then the clock is set to the
   maximum adjustment (in the right direction) until the clock time is
   close to the master's time.

2. The estimated offset is added to the current time, resulting in a
   jump in time.

We need clock_adjtime(id, 0, ts) for the second case.

> Have you considered passing a struct timex instead of ppb and ts?

Yes, but the timex is not suitable, IMHO.

> Is using ppb instead of the timex ppm required to get the accuracy
> you want?

That is one very good reason.

Another is this: can you explain what the 20+ fields mean?

Consider the field, freq. The comment says "frequency offset (scaled
ppm)."  To what is it scaled? The only way I know of to find out is to
read the NTP code (which is fairly complex) and see what the unit
really is meant to be. Ditto for the other fields.

The timex structure reveals, AFAICT, the inner workings of the kernel
clock servo. For PTP, we don't need or want the kernel servo. The PTPd
has its own clock servo in user space.

Richard
