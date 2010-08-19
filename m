From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Thu, 19 Aug 2010 07:55:18 +0200
Message-ID: <20100819055518.GA4084@riccoc20.at.omicron.at>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	<363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
	<AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>
	<20100817085324.GB3330@riccoc20.at.omicron.at>
	<1282090963.1734.97.camel@localhost>
	<20100818071942.GA4096@riccoc20.at.omicron.at>
	<1282176776.2865.100.camel@localhost.localdomain>
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
In-Reply-To: <1282176776.2865.100.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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

On Wed, Aug 18, 2010 at 05:12:56PM -0700, john stultz wrote:
> On Wed, 2010-08-18 at 09:19 +0200, Richard Cochran wrote:
> > The timer/alarm stuff is "ancillary" and is not at all necessary. It
> > is just a "nice to have." I will happily remove it, if it is too
> > troubling for people.
> 
> If there's a compelling argument for it, I'm interested to hear. But
> again, it seems like just
> yet-another-way-to-get-alarm/timer-functionality, so before we add an
> extra API (or widen an existing API) I'd like to understand the need.

We don't really need it, IMHO.

But if we offer clockid_t CLOCK_PTP, then we get timer_settime()
without any extra effort.

> > I was emulating the posix interface. Instead I should use it directly.
> 
> I'm definitely interested to see what you come up with here. I'm still
> hesitant with adding a PTP clock_id, but extending the posix-clocks
> interface in this way isn't unprecedented (see: CLOCK_SGI_CYCLE) I just
> would like to make sure we don't end up with a clock_id namespace
> littered with oddball clocks that were not well abstracted (see:
> CLOCK_SGI_CYCLE :).
> 
> For instance: imagine if instead of keeping the clocksource abstraction
> internal to the timekeeping core, we exposed each clocksource to
> userland via a clock_id.  Every arch would have different ids, and each
> arch might have multiple ids. Programming against that would be a huge
> pain.

The clockid_t CLOCK_PTP will be arch-neutral.

> So in thinking about this, try to focus on what the new clock_id
> provides that the other existing clockids do not? Are they at comparable
> levels of abstraction? 15 years from now, are folks likely to still be
> using it? Will it be maintainable? etc...

Arnd convinced me that clockid_t=CLOCK_PTP is a good fit. My plan
would be to introduce just one additional syscall:

SYSCALL_DEFINE3(clock_adjtime, const clockid_t, clkid,
		int, ppb, struct timespec __user *, ts)

ppb - desired frequency adjustment in parts per billion
ts  - desired time step (or jump) in <sec,nsec> to correct
      a measured offset

Arguably, this syscall might be useful for other clocks, too.

I think the ancillary features from PTP hardware clocks should be made
available throught the sysfs. A syscall for these would end up very
ugly, looking like an ioctl. Also, it is hard to see how these
features relate to the more general idea of the clockid.

In contrast, sysfs attributes will fit the need nicely:

1. enable or disable pps
2. enable or disable external timestamps
3. read out external timestamp
4. configure period for periodic output

> > 1. Use Case: SW timestamping
> The way I tend to see it: PTP is just one of the many ways to sync
> system time.

> > 2. Use Case: HW timestamping for industrial control
> These specialized applications are part of what concerns me the most. 

PTP was not invented to just to get a computer's system time in the
ball park. For that, NTP is good enough. Rather, some people want to
use their computers for tasks that require close synchronization, like
industrial control, audio/video streaming, and many others.

Are you saying that we should not support such applications?

> For example, I can see some parallels between things like audio
> processing, where you have a buffer consumed by the card at a certain
> rate. Now, the card has its own crystal it uses to time its consumption,
> so it has its own time domain, and could drift from system time. Thus
> you want to trigger buffer-refill interrupts off of the audio card's
> clock, not the system time which might run the risk of being late.
> 
> But again, we don't expose the audio hardware clock to userland in the
> same way we expose system time.

This is a good example of the poverty (in regards to time
synchronization) of our current systems.

Lets say I want to build a surround sound audio system, using a set of
distributed computers, each host connected to one speaker. How I can
be sure that the samples in one channel (ie one host) pass through the
DA converter at exactly the same time?

> Again, my knowledge in the networking stack is pretty limited. But it
> would seem that having an interface that does something to the effect of
> "adjust the timestamp clock on the hardware that generated it from this
> packet by Xppb" would feel like the right level of abstraction. Its
> closely related to SO_TIMESTAMP, option right? Would something like
> using the setsockopt/getsockopt interface with
> SO_TIMESTAMP_ADJUST/OFFSET/SET/etc be reasonable?

The clock and its adjustment have nothing to do with a network
socket. The current PTP hacks floating around all add private ioctls
to the MAC driver. That is the *wrong* way to do it.

> > 3. Use Case: HW timestamping with PPS to host
...
> And yes, this seems perfectly reasonable feature to add. Its not
> controversial to me, because its likely to work within the existing
> interfaces and won't expose anything new to userland.

Okay, then will you support an elegant solution for case 3, that also
supports cases 1 and 2 without any additional work?

> Again, sorry to be such a pain about all of this. I know its frustrating...

Thanks for your comments!

Richard
