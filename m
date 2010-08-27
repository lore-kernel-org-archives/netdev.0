From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Thu, 26 Aug 2010 18:57:49 -0700
Message-ID: <1282874269.4371.74.camel@localhost.localdomain>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	 <363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
	 <AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>
	 <20100817085324.GB3330@riccoc20.at.omicron.at>
	 <1282090963.1734.97.camel@localhost>
	 <20100818071942.GA4096@riccoc20.at.omicron.at>
	 <1282176776.2865.100.camel@localhost.localdomain>
	 <20100819055518.GA4084@riccoc20.at.omicron.at>
	 <1282594125.3111.344.camel@localhost.localdomain>
	 <AANLkTi=nKrRHH6+9mvny718gov8Q+u7DHFikdgNY8YdX@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Rodolfo Giometti <giometti@linux.it>,
	Arnd Bergmann <arnd@arndb.de>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=nKrRHH6+9mvny718gov8Q+u7DHFikdgNY8YdX@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-08-25 at 11:40 +0200, Christian Riesch wrote:
> What you describe here is only one of the use cases. If the hardware
> has a single network port and operates as a PTP slave, it timestamps
> the PTP packets that are sent and received and subsequently uses these
> timestamps and the information it received from the master in the
> packets to steer its clock to align it with the master clock. In such
> a case the timestamping hardware and the clock hardware work together
> closely and it seems to be okay to use the same interface to control
> both the timestamping and the PTP clock.
> 
> But we have to consider other use cases, e.g.,
> 
> 1) Boundary clocks:
> We have more than one network port. One port operates as a slave
> clock, our system gets time information via this port and steers its
> PTP clock to align with the master clock. The other network ports of
> our system operate as master clocks and redistribute the time
> information we got from the master to other clocks on these networks.
> In such a case we do timestamping on each of the network ports, but we
> only have a single PTP clock. Each network port's timestamping
> hardware uses the same hardware clock to generate time stamps.
> 
> 2) Master clock:
> We have one or more network ports. Our system has a really good clock
> (ovenized quartz crystal, an atomic clock, a GPS timing receiver...)
> and it distributes this time on the network. In such a case we do not
> steer our clock based on the (packet) timestamps we get from our
> timestamping unit. Instead, we directly drive our clock hardware with
> a very stable frequency that we get from the OCXO or the atomic
> clock... 

Ok. Following you here...

> or we use one of the ancillary features of the PTP clock that
> Richard mentioned to timestamp not network packets but a 1pps signal
> and use these timestamps to steer the clock. 

Wait.. I thought we weren't using PTP to steer the clock? But now we're
using the pps signal from it to do so? Do I misunderstand you? Or did
you just not mean this?

> Packet time stamping is
> used to distribute the time to the slaves, but it is not part of the
> control loop in this case.

I assume here you mean PTPd is steering the PTP clock according to the
system time (which is NTP/GPS/whatever sourced)? And then the PTP clock
distributes that time through the network?

> So in the first case we have one PTP clock but several network packet
> timestamping units, whereas in the second case the packet timestamping
> is done but it is not part of the control loop that steers the clock.
> Of course in most hardware implementations both the PTP clock and the
> timestamping unit sit on the same chip and often use the same means of
> communication to the cpu, e.g., the MDIO bus, but I think we need some
> logical separation here.


So first of all, thanks for the extra explanation and context here! I
really appreciate it, as I'm not familiar with all the hardware details
and possible use cases, but I'm trying to learn.

So in the two cases you mention, the time "flow" is something like:

#1) [Master Clock on Network1] => [PTP Clock] => [PTPd] =>
	[PTP Clock] => [PTP Clients on Network2]

#2) [GPS] => [NTPd] => [System Time] => [PTPd] => [PTP clock] =>
	[PTP clients on Network]

And the original case:
#3) [Master Clock on Network] => [PTP clock] => [PTPd] => [PTP clock]

With a secondary control flow:
	[PPS signal from PTP clock] => [NTPd] => [System Time]


Right?


So, just brainstorming here, I guess the question I'm trying to figure
out here, is can the "System Time" and "PTP clock" be merged/globbed
into a single "Time" interface from the userspace point of view?

In other words, if internal to the kernel, the PTP clock was always
synced to the system time, couldn't the flow look something like:

#3') [Master clock on network] => [PTP clock] => [PTPd] =>
	 [System Time] => [in-kernel sync thread] => [PTP clock]

So PTPd sees the offset adjustment from the PTP clock, and then feeds
that offset correction right into (a possibly enhanced) adjtimex. The
kernel would then immediately steer the PTP clock by the same amount to
keep it in sync with system time (along with a periodic offset/freq
correction step to deal with crystal drift).

Similarly:

#2') [GPS] => [NTPd] => [System Time] => [in-kernel sync thread] => 
		[PTP clock] => [PTP clients on Network]

and 

#1') [Master Clock on Network1] => [PTP Clock] => [PTPd] =>
	[System Time] => [in-kernel sync thread] => [PTP Clock] => 
	[PTP Clients on Network2]

Now, I realize PTP purists probably won't like this, because it
effectively makes the in-kernel sync thread similar to a PTP boundary
clock (or worse, since the control loop isn't exactly direct).

But considering that the kernel (internally) allows for *very*
fine-grained adjustments (we keep our long-term offset error in
(nanoseconds << 32)  ie: ~quarter-*billion*ths of a nanosecond - I think
that's sub-attosecond, if I recall the unit). And even the existing
external adjtimex interface allows for adjustments of 1ppm<<16 which is
a granularity of ~15 parts-per-trillion (assuming i'm doing the math
right).

These are all much greater then the parts-per-billion adjustment
granularity proposed for the direct PTP clock steering, so I suspect any
error caused by the indirection in the control flow could be minimized
significantly.

Additionally my suggestion here has the benefit of:
A: Avoiding the fragmented time domains (ie CLOCK_REALTIME vs CLOCK_PTP)
caused by adding a new clock_id.

B: Avoiding the indirect system time sync through the PPS interface,
which isn't completely terrible, but just feels a little ugly
configuration wise from a users-perspective.

I'm sure I still have lots to learn about PTP, so please let me know
where I'm off-base.

thanks
-john
