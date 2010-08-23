From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Mon, 23 Aug 2010 13:08:45 -0700
Message-ID: <1282594125.3111.344.camel@localhost.localdomain>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	 <363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
	 <AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>
	 <20100817085324.GB3330@riccoc20.at.omicron.at>
	 <1282090963.1734.97.camel@localhost>
	 <20100818071942.GA4096@riccoc20.at.omicron.at>
	 <1282176776.2865.100.camel@localhost.localdomain>
	 <20100819055518.GA4084@riccoc20.at.omicron.at>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100819055518.GA4084@riccoc20.at.omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for the slow response here, I got busy with other work at the end
of last week.

On Thu, 2010-08-19 at 07:55 +0200, Richard Cochran wrote:
> On Wed, Aug 18, 2010 at 05:12:56PM -0700, john stultz wrote:
> > On Wed, 2010-08-18 at 09:19 +0200, Richard Cochran wrote:
> > > The timer/alarm stuff is "ancillary" and is not at all necessary. It
> > > is just a "nice to have." I will happily remove it, if it is too
> > > troubling for people.
> > 
> > If there's a compelling argument for it, I'm interested to hear. But
> > again, it seems like just
> > yet-another-way-to-get-alarm/timer-functionality, so before we add an
> > extra API (or widen an existing API) I'd like to understand the need.
> 
> We don't really need it, IMHO.
> 
> But if we offer clockid_t CLOCK_PTP, then we get timer_settime()
> without any extra effort.

Sure. There are some clear parallels and the API seems to match, but
what I'm asking is: does it make sense from an overall API view that
application developers have to understand?

> > > I was emulating the posix interface. Instead I should use it directly.
> > 
> > I'm definitely interested to see what you come up with here. I'm still
> > hesitant with adding a PTP clock_id, but extending the posix-clocks
> > interface in this way isn't unprecedented (see: CLOCK_SGI_CYCLE) I just
> > would like to make sure we don't end up with a clock_id namespace
> > littered with oddball clocks that were not well abstracted (see:
> > CLOCK_SGI_CYCLE :).
> > 
> > For instance: imagine if instead of keeping the clocksource abstraction
> > internal to the timekeeping core, we exposed each clocksource to
> > userland via a clock_id.  Every arch would have different ids, and each
> > arch might have multiple ids. Programming against that would be a huge
> > pain.
> 
> The clockid_t CLOCK_PTP will be arch-neutral.

Sure, but are they conceptually neutral? There are other clock
synchronization algorithms out there. Will they need their own
similar-but-different clock_ids?

Look at the other clock ids and what the represent:

CLOCK_REALTIME : Wall time (possibly freq/offset corrected)
CLOCK_MONOTONIC: Monotonic time (possibly freq corrected).
CLOCK_PROCESS_CPUTIME_ID: Process cpu time.
CLOCK_THREAD_CPUTIME_ID: Thread cpu time.
CLOCK_MONOTONIC_RAW: Non freq corrected monotonic time.
CLOCK_REALTIME_COARSE: Tick granular wall time (filesystem timestamp)
CLOCK_MONOTONIC_COARSE: Tick granular monotonic time.

CLOCK_PTP that you're proposing doesn't seem to be at the same level of
abstraction. I'm not saying that this isn't the right place for it, but
can we take a step back from PTP and consider what your exposing in more
generic terms. In other words, could someone use the same
packet-timestamping hardware to implement a different non-PTP time
synchronization algorithm?

Further, if we're using PTP to synchoronize the system time, then there
shouldn't be any measurable difference between CLOCK_PTP and
CLOCK_REALTIME, no?

> > So in thinking about this, try to focus on what the new clock_id
> > provides that the other existing clockids do not? Are they at comparable
> > levels of abstraction? 15 years from now, are folks likely to still be
> > using it? Will it be maintainable? etc...
> 
> Arnd convinced me that clockid_t=CLOCK_PTP is a good fit. My plan
> would be to introduce just one additional syscall:
> 
> SYSCALL_DEFINE3(clock_adjtime, const clockid_t, clkid,
> 		int, ppb, struct timespec __user *, ts)
> 
> ppb - desired frequency adjustment in parts per billion
> ts  - desired time step (or jump) in <sec,nsec> to correct
>       a measured offset
> 
> Arguably, this syscall might be useful for other clocks, too.

So yea, obviously the syscall should not be CLOCK_PTP specific, so we
would want it to be usable against CLOCK_REALTIME.

That said, the clock_adjtime your proposing does not seem to be
sufficient for usage by NTPd. So this suggests that it is not generic
enough.

> I think the ancillary features from PTP hardware clocks should be made
> available throught the sysfs. A syscall for these would end up very
> ugly, looking like an ioctl. Also, it is hard to see how these
> features relate to the more general idea of the clockid.

This may be a good approach, but be aware that adding stuff to sysfs
requires similar scrutiny as adding a syscall.  

> In contrast, sysfs attributes will fit the need nicely:
> 
> 1. enable or disable pps
> 2. enable or disable external timestamps
> 3. read out external timestamp
> 4. configure period for periodic output

Things to consider here:
Do having these options really make sense? 

Why would we want pps disabled?  And if that does make sense, would it
be better to do so via the existing pps interface instead of adding a
new ptp specific one? 

Same for the timestamps and periodic output (ie: and how do they differ
from reading or setting a timer on CLOCK_PTP?)


> > > 1. Use Case: SW timestamping
> > The way I tend to see it: PTP is just one of the many ways to sync
> > system time.
> 
> > > 2. Use Case: HW timestamping for industrial control
> > These specialized applications are part of what concerns me the most. 
> 
> PTP was not invented to just to get a computer's system time in the
> ball park. For that, NTP is good enough. Rather, some people want to
> use their computers for tasks that require close synchronization, like
> industrial control, audio/video streaming, and many others.
> 
> Are you saying that we should not support such applications?

Of course not! Just because I'm reviewing and critiquing your work does
not mean our goals are incompatible.


> > For example, I can see some parallels between things like audio
> > processing, where you have a buffer consumed by the card at a certain
> > rate. Now, the card has its own crystal it uses to time its consumption,
> > so it has its own time domain, and could drift from system time. Thus
> > you want to trigger buffer-refill interrupts off of the audio card's
> > clock, not the system time which might run the risk of being late.
> > 
> > But again, we don't expose the audio hardware clock to userland in the
> > same way we expose system time.
> 
> This is a good example of the poverty (in regards to time
> synchronization) of our current systems.
> 
> Lets say I want to build a surround sound audio system, using a set of
> distributed computers, each host connected to one speaker. How I can
> be sure that the samples in one channel (ie one host) pass through the
> DA converter at exactly the same time?

They won't be exactly the same, but to minimize any noticeable
difference we'd need each speaker/client-system that have their system
time closely synced. Then the server-system would need to send the
channel stream and frame times to each client. The clients would then
feed the audio frames to the audio card at the designated times.

This is a little high level and generic and of course, the devil's in
the details:

1) How is the system time synchronized across systems?

2) How is the error between the system time freq and the audio cards
rate addressed?

These are things that need to be addressed, but the high-level design is
what the applications should target, because it doesn't limit them to
the specifics of the details.

By suggesting the application be designed to use CLOCK_PTP, it limits
itself to systems with CLOCK_PTP hardware, and should the application be
ported to a different distributed system that's using RADclocks or some
other synchronization method, it won't function.

What the kernel needs to provide are ways to address #1 and #2 above,
but what the kernel needs to expose to userland should be minimal and
generic.


> > Again, my knowledge in the networking stack is pretty limited. But it
> > would seem that having an interface that does something to the effect of
> > "adjust the timestamp clock on the hardware that generated it from this
> > packet by Xppb" would feel like the right level of abstraction. Its
> > closely related to SO_TIMESTAMP, option right? Would something like
> > using the setsockopt/getsockopt interface with
> > SO_TIMESTAMP_ADJUST/OFFSET/SET/etc be reasonable?
> 
> The clock and its adjustment have nothing to do with a network
> socket. The current PTP hacks floating around all add private ioctls
> to the MAC driver. That is the *wrong* way to do it.

Could you clarify on *why* that is the wrong approach?

Maybe this is where some of the confusion is coming from? The subtleties
of the more generic PTP algorithm and how the existence of PTP hardware
clocks change things are not clear to me. My understanding of ptp and
the networking details around it is limited, so your expertise is
appreciated.  Might you consider covering some of this via a
Documentation/ptp/overview.txt file in a future version of your patch?

Here's a summary of what I understand:
So from:
http://en.wikipedia.org/wiki/Precision_Time_Protocol#Synchronization

We see the message exchange of Sync/Delay_Req/Delay_Resp, and the
calculation of the local offset from the server (and then a frequency
adjustment over time as offsets values are accumulated).

Without the hardware clock, this all of these messages and their
corresponding timestamps are likely created by PTPd, using clock_gettime
and then adjtimex() to correct for the calculated offset or freq
adjustment. No extra interfaces are necessary, and PTPd is syncing the
system time as accurately as it can. This is how the existing ptpd
projects on the web seem to function.

Now, with PTP hardware on the system, my understanding of what you're
trying to enable with your patches is that the PTP hardware does the
timestamping on both incoming and outgoing messages. PTPd then reads the
pre-timestamped messages, calculates the offset and freq correction, and
then feeds that back into the PTP hardware via your interface. No time
correction is done at all by PTPd.

Instead, you're proposing then to have a PPS signal emitted by the PTP
hardware (via the timer interface on that hardware, if I'm understanding
correctly). This PPS signal would then be picked up by something like
NTPd which would use it to correct the system time.


Questions:
1) When the PTP hardware is doing the timestamping, what API/interface
does PTPd use to get and send the Sync/Delay_req/Delay_Resp messages?

SO_TIMESTAMPed packets from a network device seems the obvious answer,
but your comments above about with regards to my SO_TIMESTAMP_ADJ idea
suggest there's something more subtle here.

2) You've mentioned multiple PTP hardware clocks are possible, but maybe
not practically useful. How does PTPd enumerate the existing clocks, and
know which devices to listen to for Sync/Delay_Resp messages?

The issue I'm trying to address here is the interface inconsistency
between the message timestamping interface (ie: likely from a packet,
possibly multiple sources) and the proposed CLOCK_PTP interface (with
only a single clock being exposed at a time, and that being controlled
by a sysfs interface).



My concerns: 
1) Again, I'm not totally comfortable exposing the PTP hardware via the
posix-clocks/timers interface. I'm not dead set against it, but it just
doesn't seem right as a top-level abstraction.

I'm curious if its possible to do the PTP hardware offset/adjustment
calculation in a module internally to the kernel? That would allow the
PPS interface to still be used to sync the system time, and not expose
additional interfaces.

2) If this is a top-level interface, I'd prefer the inconsistency
between how the timestamped messages are received and the proposed
posix_clocks/timer interface be clarified. 

For example: does the networking stack need to have the source clock_id
to use for SO_TIMESTAMPing be specified?

3) I still prefer the idea of keeping the PTP hardware adjustment API
close to the existing API to enable the SO_TIMESTAMPing. I realize you
disagree, but would like to understand better why.


thanks again,
-john
