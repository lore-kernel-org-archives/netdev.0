From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Fri, 27 Aug 2010 09:57:27 +0200
Message-ID: <20100827075727.GA3818@riccoc20.at.omicron.at>
References: <363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
	<AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>
	<20100817085324.GB3330@riccoc20.at.omicron.at>
	<1282090963.1734.97.camel@localhost>
	<20100818071942.GA4096@riccoc20.at.omicron.at>
	<1282176776.2865.100.camel@localhost.localdomain>
	<20100819055518.GA4084@riccoc20.at.omicron.at>
	<1282594125.3111.344.camel@localhost.localdomain>
	<AANLkTi=nKrRHH6+9mvny718gov8Q+u7DHFikdgNY8YdX@mail.gmail.com>
	<1282874269.4371.74.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1282874269.4371.74.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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

On Thu, Aug 26, 2010 at 06:57:49PM -0700, john stultz wrote:
> On Wed, 2010-08-25 at 11:40 +0200, Christian Riesch wrote:
> > 2) Master clock:
> > We have one or more network ports. Our system has a really good clock
> > (ovenized quartz crystal, an atomic clock, a GPS timing receiver...)
> > and it distributes this time on the network. In such a case we do not
> > steer our clock based on the (packet) timestamps we get from our
> > timestamping unit. Instead, we directly drive our clock hardware with
> > a very stable frequency that we get from the OCXO or the atomic
> > clock...
>
> Ok. Following you here...
>
> > or we use one of the ancillary features of the PTP clock that
> > Richard mentioned to timestamp not network packets but a 1pps signal
> > and use these timestamps to steer the clock.
>
> Wait.. I thought we weren't using PTP to steer the clock? But now we're
> using the pps signal from it to do so? Do I misunderstand you? Or did
> you just not mean this?

The master node in a PTP network probably takes its time from a
precise external time source, like GPS. The GPS provides a 1 PPS
directly to the PTP clock hardware, which latches the PTP hardware
clock time on the PPS edge. This provides one sample as input to a
clock servo (in the PTPd) that, in turn, regulates the PTP clock
hardware.

> > Packet time stamping is
> > used to distribute the time to the slaves, but it is not part of the
> > control loop in this case.
>
> I assume here you mean PTPd is steering the PTP clock according to the
> system time (which is NTP/GPS/whatever sourced)? And then the PTP clock
> distributes that time through the network?

Yes, but in this case, "system time" has nothing to do with the Linux
system time. For a PTP master clock, it really doesn't matter whether
the Linux time is correct, or not. It doesn't hurt either (but see
below about chaining servos).

> So first of all, thanks for the extra explanation and context here! I
> really appreciate it, as I'm not familiar with all the hardware details
> and possible use cases, but I'm trying to learn.
>
> So in the two cases you mention, the time "flow" is something like:
>
> #1) [Master Clock on Network1] => [PTP Clock] => [PTPd] =>
> 	[PTP Clock] => [PTP Clients on Network2]

I would only draw the PTP clock once, perhaps like this:

                                +------------------------------+
                                |                              ^
                                V                              |
[Master Clock on NW 1]--->[HW timestamp]--->[PTPd]--adj-->[PTP Clock]
[Slaves on NW 2,3,...]<---[HW timestamp]<---[    ]

>
> #2) [GPS] => [NTPd] => [System Time] => [PTPd] => [PTP clock] =>
> 	[PTP clients on Network]

Nope. More like this:

                                      +------------------------------+
                                      |                              ^
                                      V                              |
[GPS]----------PPS--------->[Latch  timestamp]--->[PTPd]--adj-->[PTP Clock]
[Slaves on NW 1,2,3,...]<---[HW pkt timestamp]<---[    ]

> And the original case:
> #3) [Master Clock on Network] => [PTP clock] => [PTPd] => [PTP clock]

More like:

[Master Clock on NW 1]--->[HW timestamp]--->[PTPd]--adj-->[PTP Clock]

> With a secondary control flow:
> 	[PPS signal from PTP clock] => [NTPd] => [System Time]

Yes.


> So, just brainstorming here, I guess the question I'm trying to figure
> out here, is can the "System Time" and "PTP clock" be merged/globbed
> into a single "Time" interface from the userspace point of view?

This is the core issue and source of misunderstanding, in my view. The
fact of the matter is, the current generation of computers has
multiple clocks, and these are usually unsynchronized. I think we
should not try too hard to cover up or work around this. It is a fact
of life.

It would be nice if there were only one clock, and that clock could do
everything that we need. Indeed, the next generation of SoC computers may
all have PTP build in to the main CPU. Well, one can always wish.

If we can make it appear that multiple clocks are just one clock, then
I agree that we should do it. But I would not want to sacrifice
synchronization accuracy or application features just to keep that
illusion.

> In other words, if internal to the kernel, the PTP clock was always
> synced to the system time, couldn't the flow look something like:
>
> #3') [Master clock on network] => [PTP clock] => [PTPd] =>
> 	 [System Time] => [in-kernel sync thread] => [PTP clock]
>
> So PTPd sees the offset adjustment from the PTP clock, and then feeds
> that offset correction right into (a possibly enhanced) adjtimex. The
> kernel would then immediately steer the PTP clock by the same amount to
> keep it in sync with system time (along with a periodic offset/freq
> correction step to deal with crystal drift).
>
> Similarly:
>
> #2') [GPS] => [NTPd] => [System Time] => [in-kernel sync thread] =>
> 		[PTP clock] => [PTP clients on Network]
>
> and
>
> #1') [Master Clock on Network1] => [PTP Clock] => [PTPd] =>
> 	[System Time] => [in-kernel sync thread] => [PTP Clock] =>
> 	[PTP Clients on Network2]
>
> Now, I realize PTP purists probably won't like this, because it
> effectively makes the in-kernel sync thread similar to a PTP boundary
> clock (or worse, since the control loop isn't exactly direct).

I don't like it. The experience with PTP boundary clocks already shows
that the errors in servo loops cascade. It worsens the PTP performance.

However, I think it would fine just to synch the Linux system time to
the PTP clock using the PPS interface, which is what my patch set
implements. Linux user applications would not be able to detect the
difference.

Richard
