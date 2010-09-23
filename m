From: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 23 Sep 2010 14:42:16 -0700
Message-ID: <1285278136.2587.154.camel@localhost.localdomain>
References: <cover.1285261533.git.richard.cochran@omicron.at>
	 <alpine.DEB.2.00.1009231238170.2962@router.home>
	 <1285268380.2587.11.camel@localhost.localdomain>
	 <alpine.DEB.2.00.1009231402420.2962@router.home>
	 <1285273684.2587.92.camel@localhost.localdomain>
	 <alpine.DEB.2.00.1009231533040.7522@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1009231533040.7522-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-23 at 15:49 -0500, Christoph Lameter wrote:
> On Thu, 23 Sep 2010, john stultz wrote:
> 
> > > The HPET or pit timesource are also quite slow these days. You only need
> > > access periodically to essentially tune the TSC ratio.
> >
> > If we're using the TSC, then we're not using the PTP clock as you
> > suggest. Further the HPET and PIT aren't used to steer the system time
> > when we are using the TSC as a clocksource. Its only used to calibrate
> > the initial constant freq used by the timekeeping code (and if its
> > non-constant, we throw it out).
> 
> There is no other scalable time source available for fast timer access
> than the time stamp counter in the cpu. Other time source require
> memory accesses which is inherently slower.

Right, but no one likes the HPET or ACPI PM for a clocksource, its just
the TSC isn't usable in some cases, so they have to be used.

We don't want to force folks to decide between closely sycned time and
fast time reads. So that is part of the reason why PTP as a clocksource
isn't a good idea.

> An accurate other time source is used to adjust this clock. NTP does that
> via the clock interfaces from user space which has its problems with
> accuracy. PTP can provide the network synced time access
> that would a more accurate calibration of the time.

Calibration isn't whats needed here (it is an issue, but a separate one
- and I've got some patches if you're interested!) as its a one-time
source of error and can be corrected by ntp today without trouble.
Adjustments to the system time is something that has to be done
continuously to handle for variable thermal drift over time.

> > 2) The way PTP clocks are steered to sync with network time causes their
> > hardware freq to actually change. Since these adjustments are done on
> > the hardware clock level, and not on the system time level, the
> > adjustments to sync the system time/freq would then be made incorrect by
> > PTP hardware adjustments.
> 
> Right. So use these as a way to fine tune the TSC clock (and thereby the
> system time).

So you're then not suggesting to "use the PTP as a clocksource".

Using the PTP hardware to adjust the system time freq is exactly whats
being proposed.

> > 3) Further, the PTP hardware counter can be simply set to a new offset
> > to put it in line with the network time. This could cause trouble with
> > timekeeping much like unsynced TSCs do.
> 
> You can do the same for system time.

Settimeofday does allow CLOCK_REALTIME to jump, but the CLOCK_MONOTONIC
time cannot jump around. Having a clocksource that is non-monotonic
would break this.

> > Now, what you seem to be suggesting is to use the TSC (or whatever
> > clocksource the system time is using) but to steer the system time using
> > the PTP clock. This is actually what is being proposed, however, the
> > steering is done in userland. This is due to the fact that there are two
> > components to the steering, 1) adjusting the PTP clock hardware to
> > network time and 2) adjusting the system time to the PTP hardware. By
> > exposing the PTP clock to userland via the posix clocks interface, we
> > allow this to easily be done.
> 
> Userland code would introduce latencies that would make sub microsecond
> time sync very difficult.

The design actually avoids most userland induced latency.

1) On the PTP hardware syncing point, the reference packet gets
timestamped with the PTP hardware time on arrival. This allows the
offset calculation to be done in userland without introducing latency.

2) On the system syncing side, the proposal for the PPS interrupt allows
the PTP hardware to trigger an interrupt on the second boundary that
would take a timestamp of the system time. Then the pps interface allows
for the timestamp to be read from userland allowing the offset to be
calculated without introducing additional latency.


> > > We can switch underlying clocks for system time already. We can adapt to a
> > > different hw frequency.
> >
> > Actually no. The timekeeping code requires a fixed freq counter. Dealing
> > with hardware freq changes is difficult, because error is introduced by
> > the latency between when the freq changes and when the timekeeping code
> > is notified of it. So the system treats the hardware counters as fixed
> > freq. Now, hardware does vary freq ever so slightly as thermal
> > conditions change, but this is addressed in userland and corrected via
> > adjtimex.
> 
> Acadmic hair splitting? I have repeatedly switched between different
> clocks on various systems. So its difficult but we do it?

Sure, we handle the fairly-rare case of switching clocksources. And that
introduces a bit of error each time. But one doesn't expect to be
switching clock-sources every second and still keep synced time.


> > Unnecessary layers? Where? This approach has less in-kernel layers, as
> > it exposes the PTP clock to userland, instead of trying to layer things
> > on top of it and stretching the system time abstraction to cover it.
> 
> You dont need the user APIs if you directly use the PTP time source to
> steer the system clock. In fact I think you have to do it in kernel space
> since user space latencies will degrade accuracy otherwise.

Via the PPS interface, this can be done easily without large latency.

Additionally, even just in userland, it would be easy to bracket two
reads of the system time around one read of the PTP clock to bound any
userland latency fairly well. It may not be as good as the PPS interface
(although that depends on the interrupt latency), but if the accesses
are all local, it probably could get fairly close.

> > I've argued through the approach trying to keep it all internal to the
> > kernel, but to do so would be anything but trivial. Further, there's the
> > case of master-clocks, where the PTP hardware must be synced to system
> > time, instead of the other way around. And then there's the case of
> > boundary-clocks, which may have multiple PTP hardware clocks that have
> > to be synced.
> 
> Ok maybe we need some sort of control interface to manage the clock like
> the others have.

That's what the clock_adjtime call provides.


> > I think exposing this through the posix clock interface is really the
> > best approach. Its not a static clockid, so its not something most apps
> > will ever have to deal with, but it allows the few apps that really need
> > to have access to the PTP clock hardware can do so in a clean way.
> 
> It implies clock tuning in userspace for a potential sub microsecond
> accurate clock. The clock accuracy will be limited by user space
> latencies and noise. You wont be able to discipline the system clock
> accurately.

I think you'll find that the userspace latency issue is fairly well
addressed by the existing design.


> The posix clocks today assumes one notion of real "time" in the kernel.
> All clocks increase in lockstep (aside from offset updates).

Not true. The cputime clockids do not increment at the same rate (as the
apps don't always run). Further CLOCK_MONOTONIC_RAW provides a non-freq
corrected view of CLOCK_MONOTONIC, so it increments at a slightly
different rate.

>  This approach
> here result in multiple notions of "time" increasing at various speeds.

Yes. I found this initially to be distasteful as well. But the more I
realized its just a reality of the hardware, and that as long as its not
advertised along side of CLOCK_REALTIME and CLOCK_MONOTONIC (the ptp
clock ids are dynamic and somewhat hidden in the sysfs tree), so
userland developers don't get confused, its not so bad. 

Especially since driver writers will just expose the same stuff via a
chardev ioctl in a less standard way and its likely no one will notice.
Re-using the fairly nice (Alan of course disagrees :) posix interface
seems at least a little better for application developers who actually
have to use the hardware.

thanks
-john
