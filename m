From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Wed, 18 Aug 2010 17:12:56 -0700
Message-ID: <1282176776.2865.100.camel@localhost.localdomain>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	 <363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
	 <AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>
	 <20100817085324.GB3330@riccoc20.at.omicron.at>
	 <1282090963.1734.97.camel@localhost>
	 <20100818071942.GA4096@riccoc20.at.omicron.at>
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
In-Reply-To: <20100818071942.GA4096@riccoc20.at.omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-08-18 at 09:19 +0200, Richard Cochran wrote:
> On Tue, Aug 17, 2010 at 05:22:43PM -0700, john stultz wrote:
>>
> > So while to me, it think it would be more ideal (or maybe just less
> > different) to have a read-only interface (like the RTC), leaving PTPd to
> > manage offset calculations and use that to steer the system time. I can
> > acknowledge the need to have some way to correct the freq so the packet
> > timestamps are corrected.
> 
> The PTPd need not change the system time at all for PTP clock to be
> useful. (see below)

Right, obviously an ok-solution is often more useful then no-solution.
But that doesn't mean we shouldn't shoot for a good or even
great-solution. :)


> > I still feel a little concerned over the timer/alarm related interfaces.
> > Could you explain why the alarm interface is necessary? 
> 
> The timer/alarm stuff is "ancillary" and is not at all necessary. It
> is just a "nice to have." I will happily remove it, if it is too
> troubling for people.

If there's a compelling argument for it, I'm interested to hear. But
again, it seems like just
yet-another-way-to-get-alarm/timer-functionality, so before we add an
extra API (or widen an existing API) I'd like to understand the need.

But maybe it might simplify the discussion to pull it for now, but
keeping it in mind to possibly include later as an extension?

> > So really I think my initial negative gut reaction to this was mostly
> > out of the fact that you introduced a char dev that provides almost 100%
> > coverage of the posix-time interface. That is duplication we definitely
> > don't want. 
> 
> The reason why I modelled the char device on the posix interface was
> to make the API more familiar to application programmers. After the
> recent discussion (and having reviewed the posix clock implementation
> in Linux), I now think it would be even better to simply offer a new
> posic clock ID for PTP.
> 
> I was emulating the posix interface. Instead I should use it directly.

I'm definitely interested to see what you come up with here. I'm still
hesitant with adding a PTP clock_id, but extending the posix-clocks
interface in this way isn't unprecedented (see: CLOCK_SGI_CYCLE) I just
would like to make sure we don't end up with a clock_id namespace
littered with oddball clocks that were not well abstracted (see:
CLOCK_SGI_CYCLE :).

For instance: imagine if instead of keeping the clocksource abstraction
internal to the timekeeping core, we exposed each clocksource to
userland via a clock_id.  Every arch would have different ids, and each
arch might have multiple ids. Programming against that would be a huge
pain.

So in thinking about this, try to focus on what the new clock_id
provides that the other existing clockids do not? Are they at comparable
levels of abstraction? 15 years from now, are folks likely to still be
using it? Will it be maintainable? etc...


> > Also I think the documentation I've read about PTP (likely just due to
> > the engineering focus) has an odd inverted sense of priority, focusing
> > on keeping obscure hardware clocks on NIC cards in sync, rather then the
> > the more tangible feature of keeping the system time in sync.
> > 
> > This could be comically interpreted as trying to create a shadow-time on
> > the system that is the "real time" and "yea, maybe we'll let the system
> > know what time it is, but user-apps who want to know the score can send
> > a magic ioctl to /dev/something and get the real deal". ;)  I'm sure
> > that's not the case, but I'd like to keep any confusion in userland
> > about which time is the best time to a minimum (ie: use the system
> > time).
> 
> You are right. As John Eidson's excellent book points out, modern
> computers and operating systems provide surprisingly little support
> for programming based on absolute time. It is not PTP's fault. PTP is
> actually a step in the right direction, but it doesn't yet really fit
> in to the present computing world.

You'll have to forgive me, as I haven't had the time to check out that
book. What exactly do you mean by operating systems provide little
support for programming based on absolute time?


> Okay, here is the Big Picture.
> 
> 1. Use Case: SW timestamping
> 
>    PTP with software timestamping (ie without special hardware) can
>    acheive synchronization within a few dozen microseconds, after
>    about twenty minutes. This is sufficient for very many people. The
>    new API (whether char device or syscall) fully and simply supports
>    this use case. When the PTPd adjusts the PTP clock, it is actually
>    adjusting the system time, just like NTPd.

Again this illustrates the inversion of focus: system time is merely one
of many possible PTP clocks in the larger PTP framework.

The way I tend to see it: PTP is just one of the many ways to sync
system time.


> 2. Use Case: HW timestamping for industrial control
> 
>    PTP with hardware timestamping can acheive synchronization within
>    100 nanoseconds after one minute. If you want to do something with
>    your wonderfully synchronization PTP clock, it must have some kind
>    of special hardware, like timestamping external signals or
>    generating one-shot or periodic outputs. The new API (whether char
>    device or syscall) supports this use case via the ancillary
>    commands.
> 
>    In this case, the end user has an application that interfaces with
>    the outside world via the PTP clock API. Such a specialized
>    application (for example, motor control) uses only the PTP API,
>    since it knows that the standard posix API cannot help. It is
>    irrelevant that the system time is not synchronized, in this case.
> 
>    The PTP clock hardware may or may not provide a hardware interface
>    (interrupt) to the main CPU. In this case, it does not matter. The
>    PTP clock is useful all by itself.

These specialized applications are part of what concerns me the most. 

For example, I can see some parallels between things like audio
processing, where you have a buffer consumed by the card at a certain
rate. Now, the card has its own crystal it uses to time its consumption,
so it has its own time domain, and could drift from system time. Thus
you want to trigger buffer-refill interrupts off of the audio card's
clock, not the system time which might run the risk of being late.

But again, we don't expose the audio hardware clock to userland in the
same way we expose system time.

So, instead of a chardev or a posix clock id, would it make more sense
for the PTP adjustment interface to be more closely to the
nic/phy/whatever interface?  Much like how the audio apis do it?

Again, my knowledge in the networking stack is pretty limited. But it
would seem that having an interface that does something to the effect of
"adjust the timestamp clock on the hardware that generated it from this
packet by Xppb" would feel like the right level of abstraction. Its
closely related to SO_TIMESTAMP, option right? Would something like
using the setsockopt/getsockopt interface with
SO_TIMESTAMP_ADJUST/OFFSET/SET/etc be reasonable?


> 3. Use Case: HW timestamping with PPS to host
> 
>    This case is the same as case 2, with the exception that the PTP
>    clock can interrupt the main CPU. The PTP clock driver advertises
>    the "PPS" capability. When enabled, the PTP layer delivers events
>    via the existing Linux PPS subsystem. Programs like NTPd can use
>    these events to regulate the system time.
> 
>    This means that the system clock and the PTP clock will be at least
>    as well synchronized as when using a traditionial radio clock, GPS,
>    or IRIG-B method. In my opinion, this will be good enough for any
>    practical purpose. For example, let's say you want to run a
>    periodic task synchronized to the absolute wall clock time. Your
>    scheduling latency will be a dozen microseconds or so. Your PPS
>    synchronized system clock should be close enough to the PTP clock
>    to support this.

And yes, this seems perfectly reasonable feature to add. Its not
controversial to me, because its likely to work within the existing
interfaces and won't expose anything new to userland.


Again, sorry to be such a pain about all of this. I know its frustrating
to bring your hard work to lkml and then get a lot of non-specific
push-back to "do it differently". You're earlier comments about being
wary of adding syscalls because it requires lots of review and debate
were spot on, but *any* user-visible API really requires the same level
of care (which, of course, they don't always get). So please don't take
my comments personally. Keep pushing and I will either come around or
maybe we can find a better middle-ground.

thanks
-john
