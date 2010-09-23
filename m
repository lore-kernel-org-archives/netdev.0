From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 23 Sep 2010 15:49:32 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009231533040.7522@router.home>
References: <cover.1285261533.git.richard.cochran@omicron.at>
	<alpine.DEB.2.00.1009231238170.2962@router.home>
	<1285268380.2587.11.camel@localhost.localdomain>
	<alpine.DEB.2.00.1009231402420.2962@router.home>
	<1285273684.2587.92.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rodolfo Giometti <giometti@linux.it>, Arnd Bergmann <arnd@arndb.de>,
	Peter Zijlstra <peterz@infradead.org>, linux-api@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	linuxppc-dev@lists.ozlabs.org, Richard Cochran <richardcochran@gmail.com>,
	linux-arm-kernel@lists.infradead.org, Krzysztof Halasa <khc@pm.waw.pl>
To: john stultz <johnstul@us.ibm.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1285273684.2587.92.camel@localhost.localdomain>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Sep 2010, john stultz wrote:

> > The HPET or pit timesource are also quite slow these days. You only need
> > access periodically to essentially tune the TSC ratio.
>
> If we're using the TSC, then we're not using the PTP clock as you
> suggest. Further the HPET and PIT aren't used to steer the system time
> when we are using the TSC as a clocksource. Its only used to calibrate
> the initial constant freq used by the timekeeping code (and if its
> non-constant, we throw it out).

There is no other scalable time source available for fast timer access
than the time stamp counter in the cpu. Other time source require
memory accesses which is inherently slower.

An accurate other time source is used to adjust this clock. NTP does that
via the clock interfaces from user space which has its problems with
accuracy. PTP can provide the network synced time access
that would a more accurate calibration of the time.

> 2) The way PTP clocks are steered to sync with network time causes their
> hardware freq to actually change. Since these adjustments are done on
> the hardware clock level, and not on the system time level, the
> adjustments to sync the system time/freq would then be made incorrect by
> PTP hardware adjustments.

Right. So use these as a way to fine tune the TSC clock (and thereby the
system time).

> 3) Further, the PTP hardware counter can be simply set to a new offset
> to put it in line with the network time. This could cause trouble with
> timekeeping much like unsynced TSCs do.

You can do the same for system time.

> Now, what you seem to be suggesting is to use the TSC (or whatever
> clocksource the system time is using) but to steer the system time using
> the PTP clock. This is actually what is being proposed, however, the
> steering is done in userland. This is due to the fact that there are two
> components to the steering, 1) adjusting the PTP clock hardware to
> network time and 2) adjusting the system time to the PTP hardware. By
> exposing the PTP clock to userland via the posix clocks interface, we
> allow this to easily be done.

Userland code would introduce latencies that would make sub microsecond
time sync very difficult.

> > We can switch underlying clocks for system time already. We can adapt to a
> > different hw frequency.
>
> Actually no. The timekeeping code requires a fixed freq counter. Dealing
> with hardware freq changes is difficult, because error is introduced by
> the latency between when the freq changes and when the timekeeping code
> is notified of it. So the system treats the hardware counters as fixed
> freq. Now, hardware does vary freq ever so slightly as thermal
> conditions change, but this is addressed in userland and corrected via
> adjtimex.

Acadmic hair splitting? I have repeatedly switched between different
clocks on various systems. So its difficult but we do it?

> Unnecessary layers? Where? This approach has less in-kernel layers, as
> it exposes the PTP clock to userland, instead of trying to layer things
> on top of it and stretching the system time abstraction to cover it.

You dont need the user APIs if you directly use the PTP time source to
steer the system clock. In fact I think you have to do it in kernel space
since user space latencies will degrade accuracy otherwise.

> I've argued through the approach trying to keep it all internal to the
> kernel, but to do so would be anything but trivial. Further, there's the
> case of master-clocks, where the PTP hardware must be synced to system
> time, instead of the other way around. And then there's the case of
> boundary-clocks, which may have multiple PTP hardware clocks that have
> to be synced.

Ok maybe we need some sort of control interface to manage the clock like
the others have.

> I think exposing this through the posix clock interface is really the
> best approach. Its not a static clockid, so its not something most apps
> will ever have to deal with, but it allows the few apps that really need
> to have access to the PTP clock hardware can do so in a clean way.

It implies clock tuning in userspace for a potential sub microsecond
accurate clock. The clock accuracy will be limited by user space
latencies and noise. You wont be able to discipline the system clock
accurately.

The posix clocks today assumes one notion of real "time" in the kernel.
All clocks increase in lockstep (aside from offset updates). This approach
here result in multiple notions of "time" increasing at various speeds.
And it implies that someone is user space is trying to tinker around with
extremely low latencies using system call APIs that take much longer than
these intervals to process the data.
