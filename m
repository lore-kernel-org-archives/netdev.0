From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 0/2] make POSIX timers optional
Date: Tue, 20 Sep 2016 23:09:52 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1609202300140.5476@nanos>
References: <1474401400-18491-1-git-send-email-nicolas.pitre@linaro.org> <20160920202556.GA6713@localhost.localdomain> <20160920204556.GA7555@localhost.localdomain> <alpine.LFD.2.20.1609201655200.9311@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Richard Cochran <richardcochran@gmail.com>,
        John Stultz <john.stultz@linaro.org>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.20.1609201655200.9311@knanqh.ubzr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Sep 2016, Nicolas Pitre wrote:
> On Tue, 20 Sep 2016, Richard Cochran wrote:
> 
> > On Tue, Sep 20, 2016 at 10:25:56PM +0200, Richard Cochran wrote:
> > > After this series, if I don't pay enough attention to dmesg, then I
> > > have lost functionality that I had in step #1.  That sucks, and it has
> > > nothing to do with the tinification option at all.  It will bite even
> > > if I have no knowledge of it.  That isn't acceptable to me.
> > 
> > Can't you leave all the "select PTP_1588_CLOCK" alone and simply add
> > 
> > #ifdef CONFIG_POSIX_TIMERS
> > 	// global declarations
> > #else
> > 	// static inlines
> > #endif

Eew. No! That's an even more blantant layering violation.
 
> > to ptp_clock_kernel.h, and then sandwich ptp_clock.c in
> > #ifdef CONFIG_POSIX_TIMERS ... #endif ?
> 
> Sure I could... but I'm sure I'll be flamed by others for making things 
> even more obscure and hackish than they are right now.

I think the whole approach is wrong because it makes the PTP split at the
wrong level.

Currently we have:

	  DRIVER_X
	  tristate "Driver X"
	  select PTP

In order to make POSIX_CLOCK configurable we should have

       	  PTP
	  tristate "PTP"
	  select POSIX_CLOCK

Now if you want to distangle PTP from a driver then you split it at the
driver level and not at the PTP level:

      	  DRIVER_X
	  tristate "Driver X"

	  DRIVER_X_PTP
	  bool "Enable PTP support"
	  default y if !MAKE_IT_TINY
	  depends on DRIVER_X
	  select PTP

We have already drivers following that scheme. That way you make the PTP
support in the driver conditional on DRIVER_X_PTP and have no hassle with
modules and dependencies.

Your tiny config can simply disable all the PTP extra bits and then you can
disable PTP and finally POSIX_TIMERS.

Thanks,

	tglx
