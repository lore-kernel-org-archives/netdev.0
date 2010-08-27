From: John Stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Fri, 27 Aug 2010 15:30:39 -0700
Message-ID: <1282948239.2268.155.camel@jstultz-laptop>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	 <363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
	 <AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>
	 <20100817085324.GB3330@riccoc20.at.omicron.at>
	 <1282090963.1734.97.camel@localhost>
	 <20100818071942.GA4096@riccoc20.at.omicron.at>
	 <1282176776.2865.100.camel@localhost.localdomain>
	 <20100819055518.GA4084@riccoc20.at.omicron.at>
	 <1282594125.3111.344.camel@localhost.localdomain>
	 <20100827123849.GC11657@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Rodolfo Giometti <giometti@linux.it>,
	Arnd Bergmann <arnd@arndb.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:50138 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753382Ab0H0Waq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Aug 2010 18:30:46 -0400
In-Reply-To: <20100827123849.GC11657@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-08-27 at 14:38 +0200, Richard Cochran wrote:
> On Mon, Aug 23, 2010 at 01:08:45PM -0700, john stultz wrote:
> > On Thu, 2010-08-19 at 07:55 +0200, Richard Cochran wrote:
> > > The clockid_t CLOCK_PTP will be arch-neutral.
> > 
> > Sure, but are they conceptually neutral? There are other clock
> > synchronization algorithms out there. Will they need their own
> > similar-but-different clock_ids?
> > 
> > Look at the other clock ids and what the represent:
> 
> IMHO, the presently offered clock ids are a mixed bag...
> 
> > CLOCK_REALTIME : Wall time (possibly freq/offset corrected)
> > CLOCK_MONOTONIC: Monotonic time (possibly freq corrected).
> > CLOCK_PROCESS_CPUTIME_ID: Process cpu time.
> > CLOCK_THREAD_CPUTIME_ID: Thread cpu time.
> 
> The amount of time a thread has been granted by the kernel is really
> not connected to the real passage of time, at least not in a direct
> way.
> 
> > CLOCK_MONOTONIC_RAW: Non freq corrected monotonic time.
> 
> This one comes from commit 2d42244ae71d6c7b0884b5664cf2eda30fb2ae68
> and is surely a special case, unrelated to the other clock ids. The
> commit message mentions that this was added to help the btime.sf.net
> project. That project does not seem to have had any activity since
> 2007. If we can justify adding a clock id in this case, surely we can
> add one for PTP as well!

I'm not opposed to adding a clock id, I just want it to be generic
enough to make sense. 

So while MONOTONIC_RAW it was spurred into being from btime, it isn't a
CLOCK_BTIME interface. 

I've also been pushing the RADClock folks to use it since it avoids the
ugly raw hardware access they want to get access to a constant freq
counter. In addition, I've used it to monitor freq adjustments done by
NTP.


> > CLOCK_REALTIME_COARSE: Tick granular wall time (filesystem timestamp)
> > CLOCK_MONOTONIC_COARSE: Tick granular monotonic time.
> 
> These were added in commit da15cfdae03351c689736f8d142618592e3cebc3
> in order to fulfill needs of special applications.

Right, but what they represent and how its different from CLOCK_REALTIME
is easy to describe in a generic way.


> > CLOCK_PTP that you're proposing doesn't seem to be at the same level of
> > abstraction. I'm not saying that this isn't the right place for it, but
> > can we take a step back from PTP and consider what your exposing in more
> > generic terms. In other words, could someone use the same
> > packet-timestamping hardware to implement a different non-PTP time
> > synchronization algorithm?
> 
> Yes, of course. There is nothing at all in the patch set about the PTP
> protocol itself. It just lets you access the hardware. In short:
> 
> 1. SO_TIMESTAMPING delivers timestamped packets
> 2. the PTP API lets you tune the clock.
> 
> "That's all, folks."

Right. So CLOCK_SO_TIMESTAMP is maybe a better description? And isn't it
just an adjustment interface, not a PTP API to tune the clock?


> > Further, if we're using PTP to synchoronize the system time, then there
> > shouldn't be any measurable difference between CLOCK_PTP and
> > CLOCK_REALTIME, no?
> 
> When using software timestamping, then the clocks are one in the same.

So this is the duplication I don't like. If the API represents CLOCK_PTP
or whatever as something different from CLOCK_REALTIME, there shouldn't
be a mode where they're the same. That would just cause confusion.
Instead CLOCK_PTP calls just return -EINVAL and the PTPd application
should use CLOCK_REALTIME.


> When using PTP, with the PPS hook to synchoronize the Linux system
> time, the clocks will be a close as the servo algorithm provides. I
> have not measured this yet, but it cannot be much different than using
> any other PPS source.
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
> > So yea, obviously the syscall should not be CLOCK_PTP specific, so we
> > would want it to be usable against CLOCK_REALTIME.
> > 
> > That said, the clock_adjtime your proposing does not seem to be
> > sufficient for usage by NTPd. So this suggests that it is not generic
> > enough.
> 
> I don't think we need to support ntpd. It already has adjtimex, and it
> won't get any better by using another interface.

I strongly disagree. If the new interface isn't generic enough that NTPd
couldn't use it to adjust CLOCK_REALTIME, then its too specific to only
your needs.

There will be other clock sync algorithms down the road, so if we have
to expose this sort of timestamping hardware to userland, we need to
allow those other sync methods to use the API you're providing, so if
you're API isn't a superset of the existing adjustment needs, then its
already missing something.

I'm not saying we have to implement the kernel PLL adjustment and every
other adjustment mode for every CLOCK_ID right now, but we should be
able to extend things in the future.


> > > In contrast, sysfs attributes will fit the need nicely:
> > > 
> > > 1. enable or disable pps
> > > 2. enable or disable external timestamps
> > > 3. read out external timestamp
> > > 4. configure period for periodic output
> > 
> > Things to consider here:
> > Do having these options really make sense? 
> 
> Yes, since they represent the PTP clock's hardware features. As I
> explained previously, if you don't have any hardware interfaces, then
> having your clocks synchoronized to under 100 nanoseconds does not
> help you more than having them to within 1 microsecond.
> 
> > Why would we want pps disabled?
> 
> If you are a master clock, then you want to take your PPS from an
> external time source, like GPS.  If you leave the PTP PPS events on,
> then they will occur close in time to the GPS PPS events and may add
> unwanted latency to the interrupt handler.
> 
> > And if that does make sense, would it
> > be better to do so via the existing pps interface instead of adding a
> > new ptp specific one? 
> 
> We have not introduced new PPS interface. We use existing PPS subsystem.

Doesn't the pps subsystem have its own way to control the pps signal
interrupt? I'm not totally sure here, but given your point above that
having multiple pps events it seems like they should be selectable. It
seems something that we'd want to control via the global pps interface,
rather then having a pps-enable flag on every random bit of hardware
that can support it.


> > Same for the timestamps and periodic output (ie: and how do they differ
> > from reading or setting a timer on CLOCK_PTP?)
> 
> The posix timer calls won't work:
> 
> I have a PTP hardware clocks with multiple external timestamp
> channels. Using timer_gettime, how can I specify (or decode) the
> channel of interest to me?

I guess I'm not following you here. Again, I'm not super familiar with
the hardware involved. Could you clarify a bit more? What do you mean by
external timestamp? Is this what is used on the packet timestamping? 

> > What the kernel needs to provide are ways to address #1 and #2 above,
> > but what the kernel needs to expose to userland should be minimal and
> > generic.
> 
> My point was this:
> 
> The application requires that the soundcard DA clocks (*not* the CPU
> clocks) be synchronized. Currently the Linux kernel offers no way at
> all to do this at all.


So yea.. I think this gets to the main point of contention.

On one side, there is the view that the kernel should abstract and hide
the hardware details to increase app portability. And the other is that
the raw hardware details should be exposed, so the OS stays out of the
way.

Neither of these views are always right. Ideally we can come up with a
abstracted way to provide the hardware data needed that's generic enough
that applications don't have to be changed when moving between hardware
or configurations.

The posix clock id interface is frustrating because the flat static
enumeration is really limiting.

I wonder if a dynamic enumeration for posix clocks would be possibly a
way to go?

In other words, a driver registers a clock with the system, and the
system reserves a clock_id for it from the designated available pool and
assigns it back. Then userland could query the driver via something like
sysfs to get the clockid for the hardware. 

Would that maybe work? 


> > 2) You've mentioned multiple PTP hardware clocks are possible, but maybe
> > not practically useful. How does PTPd enumerate the existing clocks, and
> > know which devices to listen to for Sync/Delay_Resp messages?
> > 
> > The issue I'm trying to address here is the interface inconsistency
> > between the message timestamping interface (ie: likely from a packet,
> > possibly multiple sources) and the proposed CLOCK_PTP interface (with
> > only a single clock being exposed at a time, and that being controlled
> > by a sysfs interface).
> 
> The sysfs will include one class device for each PTP clock. Each clock
> has a sysfs attribute with the corresponding clock id.

Do you mean the clock_id # in the posix clocks namespace?


> For the network timestamps, they need to be enabled using the
> SIOCSHWTSTAMP ioctl. We can easily extend that ioctl to include the
> desired clock id.
> 
> > My concerns: 
> > 1) Again, I'm not totally comfortable exposing the PTP hardware via the
> > posix-clocks/timers interface. I'm not dead set against it, but it just
> > doesn't seem right as a top-level abstraction.
> 
> I would also be happy with the character device idea already
> posted. Just pick one of the two, and I'll resubmit the patch set...

Personally, with regard to exposing the ptp clock to userland I'm more
comfortable via the chardev. However, the posix clocks/timer api is
really close to what you need, so I'm not totally set against it. And
maybe the dynamic enumeration would resolve my main problems with it?

That said, with the chardev method, I don't like the idea of duplicating
the existing time apis via a systemtime device. Dropping that from your
earlier patch would ease the majority of my objections.

> > I'm curious if its possible to do the PTP hardware offset/adjustment
> > calculation in a module internally to the kernel? That would allow the
> > PPS interface to still be used to sync the system time, and not expose
> > additional interfaces.
> 
> It would be possible, but not too nice, IMHO. In contrast to NTP,
> there is no real need to place the servo in the kernel. Having the
> protocol code and servo in user space makes life much easier.

For you, yes, but from an API maintenance view its just adding to the
list of interfaces we have to preserve forever. :)


> > 2) If this is a top-level interface, I'd prefer the inconsistency
> > between how the timestamped messages are received and the proposed
> > posix_clocks/timer interface be clarified. 
> > 
> > For example: does the networking stack need to have the source clock_id
> > to use for SO_TIMESTAMPing be specified?
> 
> We could do it that way. I never liked the <SW,SYS,RAW> tuple in the
> SO_TIMESTAMPING control message in the first place. Sending three
> fields with two blank seems wasteful. Instead, <clockid,timestamp>
> would be sufficient. Maybe that it is too late to change this.
> 
> Even without altering the timestamp, we can simply augment
> SIOCSHWTSTAMP with a clock id.
> 
> At this point I would just like to go forward with one of the two
> proposed APIs. I had modelled the character device on the posix clock
> calls in order to make it immediately familar, and I think it is a
> viable approach. After the lkml discussion, I think it is even cleaner
> and nicer to just offer a new clock id.
> 
> Thanks for all the feedback and comments,

Thanks for the clarifications and putting up with my questions!
-john


