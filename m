From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Fri, 27 Aug 2010 14:38:49 +0200
Message-ID: <20100827123849.GC11657@riccoc20.at.omicron.at>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	<363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
	<AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>
	<20100817085324.GB3330@riccoc20.at.omicron.at>
	<1282090963.1734.97.camel@localhost>
	<20100818071942.GA4096@riccoc20.at.omicron.at>
	<1282176776.2865.100.camel@localhost.localdomain>
	<20100819055518.GA4084@riccoc20.at.omicron.at>
	<1282594125.3111.344.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1282594125.3111.344.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 23, 2010 at 01:08:45PM -0700, john stultz wrote:
> On Thu, 2010-08-19 at 07:55 +0200, Richard Cochran wrote:
> > The clockid_t CLOCK_PTP will be arch-neutral.
> 
> Sure, but are they conceptually neutral? There are other clock
> synchronization algorithms out there. Will they need their own
> similar-but-different clock_ids?
> 
> Look at the other clock ids and what the represent:

IMHO, the presently offered clock ids are a mixed bag...
 
> CLOCK_REALTIME : Wall time (possibly freq/offset corrected)
> CLOCK_MONOTONIC: Monotonic time (possibly freq corrected).
> CLOCK_PROCESS_CPUTIME_ID: Process cpu time.
> CLOCK_THREAD_CPUTIME_ID: Thread cpu time.

The amount of time a thread has been granted by the kernel is really
not connected to the real passage of time, at least not in a direct
way.

> CLOCK_MONOTONIC_RAW: Non freq corrected monotonic time.

This one comes from commit 2d42244ae71d6c7b0884b5664cf2eda30fb2ae68
and is surely a special case, unrelated to the other clock ids. The
commit message mentions that this was added to help the btime.sf.net
project. That project does not seem to have had any activity since
2007. If we can justify adding a clock id in this case, surely we can
add one for PTP as well!

> CLOCK_REALTIME_COARSE: Tick granular wall time (filesystem timestamp)
> CLOCK_MONOTONIC_COARSE: Tick granular monotonic time.

These were added in commit da15cfdae03351c689736f8d142618592e3cebc3
in order to fulfill needs of special applications.

> CLOCK_PTP that you're proposing doesn't seem to be at the same level of
> abstraction. I'm not saying that this isn't the right place for it, but
> can we take a step back from PTP and consider what your exposing in more
> generic terms. In other words, could someone use the same
> packet-timestamping hardware to implement a different non-PTP time
> synchronization algorithm?

Yes, of course. There is nothing at all in the patch set about the PTP
protocol itself. It just lets you access the hardware. In short:

1. SO_TIMESTAMPING delivers timestamped packets
2. the PTP API lets you tune the clock.

"That's all, folks."

> Further, if we're using PTP to synchoronize the system time, then there
> shouldn't be any measurable difference between CLOCK_PTP and
> CLOCK_REALTIME, no?

When using software timestamping, then the clocks are one in the same.

When using PTP, with the PPS hook to synchoronize the Linux system
time, the clocks will be a close as the servo algorithm provides. I
have not measured this yet, but it cannot be much different than using
any other PPS source.

> > SYSCALL_DEFINE3(clock_adjtime, const clockid_t, clkid,
> > 		int, ppb, struct timespec __user *, ts)
> > 
> > ppb - desired frequency adjustment in parts per billion
> > ts  - desired time step (or jump) in <sec,nsec> to correct
> >       a measured offset
> > 
> > Arguably, this syscall might be useful for other clocks, too.
> 
> So yea, obviously the syscall should not be CLOCK_PTP specific, so we
> would want it to be usable against CLOCK_REALTIME.
> 
> That said, the clock_adjtime your proposing does not seem to be
> sufficient for usage by NTPd. So this suggests that it is not generic
> enough.

I don't think we need to support ntpd. It already has adjtimex, and it
won't get any better by using another interface.

> > I think the ancillary features from PTP hardware clocks should be made
> > available throught the sysfs. A syscall for these would end up very
> > ugly, looking like an ioctl. Also, it is hard to see how these
> > features relate to the more general idea of the clockid.
> 
> This may be a good approach, but be aware that adding stuff to sysfs
> requires similar scrutiny as adding a syscall.  

Yes, it will be properly documented and maintained. I have already
implemented the ancillary stuff in two ways, via sysfs and with a
character device. The next patch set will include them both, and you
all can just choose which one to delete (or leave them both).

> > In contrast, sysfs attributes will fit the need nicely:
> > 
> > 1. enable or disable pps
> > 2. enable or disable external timestamps
> > 3. read out external timestamp
> > 4. configure period for periodic output
> 
> Things to consider here:
> Do having these options really make sense? 

Yes, since they represent the PTP clock's hardware features. As I
explained previously, if you don't have any hardware interfaces, then
having your clocks synchoronized to under 100 nanoseconds does not
help you more than having them to within 1 microsecond.

> Why would we want pps disabled?

If you are a master clock, then you want to take your PPS from an
external time source, like GPS.  If you leave the PTP PPS events on,
then they will occur close in time to the GPS PPS events and may add
unwanted latency to the interrupt handler.

> And if that does make sense, would it
> be better to do so via the existing pps interface instead of adding a
> new ptp specific one? 

We have not introduced new PPS interface. We use existing PPS subsystem.

> Same for the timestamps and periodic output (ie: and how do they differ
> from reading or setting a timer on CLOCK_PTP?)

The posix timer calls won't work:

I have a PTP hardware clocks with multiple external timestamp
channels. Using timer_gettime, how can I specify (or decode) the
channel of interest to me?

> > This is a good example of the poverty (in regards to time
> > synchronization) of our current systems.
> > 
> > Lets say I want to build a surround sound audio system, using a set of
> > distributed computers, each host connected to one speaker. How I can
> > be sure that the samples in one channel (ie one host) pass through the
> > DA converter at exactly the same time?
> 
> They won't be exactly the same, but to minimize any noticeable
> difference we'd need each speaker/client-system that have their system
> time closely synced. Then the server-system would need to send the
> channel stream and frame times to each client. The clients would then
> feed the audio frames to the audio card at the designated times.
> 
> This is a little high level and generic and of course, the devil's in
> the details:
> 
> 1) How is the system time synchronized across systems?
> 
> 2) How is the error between the system time freq and the audio cards
> rate addressed?
> 
> These are things that need to be addressed, but the high-level design is
> what the applications should target, because it doesn't limit them to
> the specifics of the details.
> 
> By suggesting the application be designed to use CLOCK_PTP, it limits
> itself to systems with CLOCK_PTP hardware, and should the application be
> ported to a different distributed system that's using RADclocks or some
> other synchronization method, it won't function.
> 
> What the kernel needs to provide are ways to address #1 and #2 above,
> but what the kernel needs to expose to userland should be minimal and
> generic.

My point was this:

The application requires that the soundcard DA clocks (*not* the CPU
clocks) be synchronized. Currently the Linux kernel offers no way at
all to do this at all.

> > The clock and its adjustment have nothing to do with a network
> > socket. The current PTP hacks floating around all add private ioctls
> > to the MAC driver. That is the *wrong* way to do it.
> 
> Could you clarify on *why* that is the wrong approach?

Christian explained this pretty well.

> Questions:
> 1) When the PTP hardware is doing the timestamping, what API/interface
> does PTPd use to get and send the Sync/Delay_req/Delay_Resp messages?
>
> SO_TIMESTAMPed packets from a network device seems the obvious answer,
> but your comments above about with regards to my SO_TIMESTAMP_ADJ idea
> suggest there's something more subtle here.

Nope, no magic here, just a plain old UDP socket.

> 2) You've mentioned multiple PTP hardware clocks are possible, but maybe
> not practically useful. How does PTPd enumerate the existing clocks, and
> know which devices to listen to for Sync/Delay_Resp messages?
> 
> The issue I'm trying to address here is the interface inconsistency
> between the message timestamping interface (ie: likely from a packet,
> possibly multiple sources) and the proposed CLOCK_PTP interface (with
> only a single clock being exposed at a time, and that being controlled
> by a sysfs interface).

The sysfs will include one class device for each PTP clock. Each clock
has a sysfs attribute with the corresponding clock id.

For the network timestamps, they need to be enabled using the
SIOCSHWTSTAMP ioctl. We can easily extend that ioctl to include the
desired clock id.

> My concerns: 
> 1) Again, I'm not totally comfortable exposing the PTP hardware via the
> posix-clocks/timers interface. I'm not dead set against it, but it just
> doesn't seem right as a top-level abstraction.

I would also be happy with the character device idea already
posted. Just pick one of the two, and I'll resubmit the patch set...

> I'm curious if its possible to do the PTP hardware offset/adjustment
> calculation in a module internally to the kernel? That would allow the
> PPS interface to still be used to sync the system time, and not expose
> additional interfaces.

It would be possible, but not too nice, IMHO. In contrast to NTP,
there is no real need to place the servo in the kernel. Having the
protocol code and servo in user space makes life much easier.

> 2) If this is a top-level interface, I'd prefer the inconsistency
> between how the timestamped messages are received and the proposed
> posix_clocks/timer interface be clarified. 
> 
> For example: does the networking stack need to have the source clock_id
> to use for SO_TIMESTAMPing be specified?

We could do it that way. I never liked the <SW,SYS,RAW> tuple in the
SO_TIMESTAMPING control message in the first place. Sending three
fields with two blank seems wasteful. Instead, <clockid,timestamp>
would be sufficient. Maybe that it is too late to change this.

Even without altering the timestamp, we can simply augment
SIOCSHWTSTAMP with a clock id.

At this point I would just like to go forward with one of the two
proposed APIs. I had modelled the character device on the posix clock
calls in order to make it immediately familar, and I think it is a
viable approach. After the lkml discussion, I think it is even cleaner
and nicer to just offer a new clock id.

Thanks for all the feedback and comments,

Richard
