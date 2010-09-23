From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 23 Sep 2010 13:28:04 -0700
Message-ID: <1285273684.2587.92.camel@localhost.localdomain>
References: <cover.1285261533.git.richard.cochran@omicron.at>
	 <alpine.DEB.2.00.1009231238170.2962@router.home>
	 <1285268380.2587.11.camel@localhost.localdomain>
	 <alpine.DEB.2.00.1009231402420.2962@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-api@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:42586 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753671Ab0IWU2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Sep 2010 16:28:18 -0400
In-Reply-To: <alpine.DEB.2.00.1009231402420.2962@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-09-23 at 14:15 -0500, Christoph Lameter wrote:
> On Thu, 23 Sep 2010, john stultz wrote:
> 
> > This was my initial gut reaction as well, but in the end, I agree with
> > Richard that in the case of one or multiple PTP hardware clocks, we
> > really can't abstract over the different time domains.
> 
> My (arguably still superficial) review of the source does not show
> anything that would make me reach that conclusion.
> 
> > I really don't think the PTP clock can be used as a clocksource sanely.
> >
> > First, the hardware access is much to slow for system timekeeping.
> 
> The HPET or pit timesource are also quite slow these days. You only need
> access periodically to essentially tune the TSC ratio.

If we're using the TSC, then we're not using the PTP clock as you
suggest. Further the HPET and PIT aren't used to steer the system time
when we are using the TSC as a clocksource. Its only used to calibrate
the initial constant freq used by the timekeeping code (and if its
non-constant, we throw it out).

> > Second, there is the problem that the system time is a software clock,
> > and adjustments made (like freq) are made in the layer that interprets
> > the underlying hardware cycle counter. Adjustments made in PTP (in order
> > to sync the network timestamps) are made at the hardware level.
> 
> From what I can see the PTP clocks are periodic hardware cycle counters
> like any other clock that we currently support. If its configurable enough
> then setup a hardware cycle counter that mimics nanoseconds since the
> epoch as closely as possible and use that to sync the TSC rate to. Makes
> it very easy.

I guess I'm confused by what you're suggesting.
If we're using the TSC, then that's the clocksource timekeeping uses.
The original issue seemed to be around the suggestion of using the PTP
clock as a clocksource, which I don't think is really feasible.

Again, that's because
1) The PTP access latency is slow (so is the PIT, true enough, but no
one should be using the PIT as a clocksource unless they really have no
better hardware - its really only useful for 486s and old freq scaling
laptops that have no other stable clocksource).

2) The way PTP clocks are steered to sync with network time causes their
hardware freq to actually change. Since these adjustments are done on
the hardware clock level, and not on the system time level, the
adjustments to sync the system time/freq would then be made incorrect by
PTP hardware adjustments. 

3) Further, the PTP hardware counter can be simply set to a new offset
to put it in line with the network time. This could cause trouble with
timekeeping much like unsynced TSCs do.


Now, what you seem to be suggesting is to use the TSC (or whatever
clocksource the system time is using) but to steer the system time using
the PTP clock. This is actually what is being proposed, however, the
steering is done in userland. This is due to the fact that there are two
components to the steering, 1) adjusting the PTP clock hardware to
network time and 2) adjusting the system time to the PTP hardware. By
exposing the PTP clock to userland via the posix clocks interface, we
allow this to easily be done.


> > This would cause a disconnect between the hardware freq understood by
> > the system time management code and the actual hardware freq.
> 
> We can switch underlying clocks for system time already. We can adapt to a
> different hw frequency.

Actually no. The timekeeping code requires a fixed freq counter. Dealing
with hardware freq changes is difficult, because error is introduced by
the latency between when the freq changes and when the timekeeping code
is notified of it. So the system treats the hardware counters as fixed
freq. Now, hardware does vary freq ever so slightly as thermal
conditions change, but this is addressed in userland and corrected via
adjtimex.

>  But then I do not know why adjust the freq? I
> thought the point was that the periodic clock was network synchronized and
> can be used as "the" master clock for multiple machines?

Not parsing that. What do you mean by periodic clock?

> > Richard, I'd actually strike this paragraph from the rational, as I feel
> > it has the tendency to confuse as it suggests having the PHC as a
> > clocksource is feasible when really it isn't. Or alternatively, maybe
> > express more clearly why its not feasible, so it doesn't just seem like
> > a minor design choice.
> 
> Sorry but I still feel that this is pretty much a misguided approach that
> creates unnecessary layers in the kernel.

Unnecessary layers? Where? This approach has less in-kernel layers, as
it exposes the PTP clock to userland, instead of trying to layer things
on top of it and stretching the system time abstraction to cover it.

>  The trivial easy approach was
> not done (copy a driver from drivers/clocksource, modify so that it
> programs access to a centralized periodic ptp signal and uses it for
> system sync).

I disagree.

I've argued through the approach trying to keep it all internal to the
kernel, but to do so would be anything but trivial. Further, there's the
case of master-clocks, where the PTP hardware must be synced to system
time, instead of the other way around. And then there's the case of
boundary-clocks, which may have multiple PTP hardware clocks that have
to be synced.

I think exposing this through the posix clock interface is really the
best approach. Its not a static clockid, so its not something most apps
will ever have to deal with, but it allows the few apps that really need
to have access to the PTP clock hardware can do so in a clean way.


And credits to Richard for having to slowly explain this to me (and
others) many times over, before I got it.

thanks
-john

