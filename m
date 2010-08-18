From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Wed, 18 Aug 2010 09:19:43 +0200
Message-ID: <20100818071942.GA4096@riccoc20.at.omicron.at>
References: <cover.1281956490.git.richard.cochran@omicron.at>
 <363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
 <AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>
 <20100817085324.GB3330@riccoc20.at.omicron.at>
 <1282090963.1734.97.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Rodolfo Giometti <giometti@linux.it>,
	Arnd Bergmann <arnd@arndb.de>
To: john stultz <johnstul@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52342 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab0HRHTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 03:19:23 -0400
Content-Disposition: inline
In-Reply-To: <1282090963.1734.97.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 17, 2010 at 05:22:43PM -0700, john stultz wrote:
> Why would system time not be adjusted to the PTP time?
> 
> This is my main concern, that we're presenting a fractured API to
> userland. Suddenly there isn't just system time, but ptp time as well,
> and possibly multiple different ptp times.

John, it is a good thing to make thoughts about the big picture with
PTP clocks and the system time, like you are doing. However, the
situation is not as troubled as you think. Let me try to explain.

> The PTP clock is a bit of hardware (usually on the NIC) that can put
> timestamps on packets (both incoming or outgoing?).

Not only on the NIC. There are bunch of new products doing the
timestamping in the PHY or in a switch fabric attached to the host
like a PHY. The synchronization that one can achieve with PHY
timestamps is better that that with MAC timestamping.

> So while to me, it think it would be more ideal (or maybe just less
> different) to have a read-only interface (like the RTC), leaving PTPd to
> manage offset calculations and use that to steer the system time. I can
> acknowledge the need to have some way to correct the freq so the packet
> timestamps are corrected.

The PTPd need not change the system time at all for PTP clock to be
useful. (see below)

> I still feel a little concerned over the timer/alarm related interfaces.
> Could you explain why the alarm interface is necessary? 

The timer/alarm stuff is "ancillary" and is not at all necessary. It
is just a "nice to have." I will happily remove it, if it is too
troubling for people.
 
> So really I think my initial negative gut reaction to this was mostly
> out of the fact that you introduced a char dev that provides almost 100%
> coverage of the posix-time interface. That is duplication we definitely
> don't want. 

The reason why I modelled the char device on the posix interface was
to make the API more familiar to application programmers. After the
recent discussion (and having reviewed the posix clock implementation
in Linux), I now think it would be even better to simply offer a new
posic clock ID for PTP.

I was emulating the posix interface. Instead I should use it directly.

> Also I think the documentation I've read about PTP (likely just due to
> the engineering focus) has an odd inverted sense of priority, focusing
> on keeping obscure hardware clocks on NIC cards in sync, rather then the
> the more tangible feature of keeping the system time in sync.
> 
> This could be comically interpreted as trying to create a shadow-time on
> the system that is the "real time" and "yea, maybe we'll let the system
> know what time it is, but user-apps who want to know the score can send
> a magic ioctl to /dev/something and get the real deal". ;)  I'm sure
> that's not the case, but I'd like to keep any confusion in userland
> about which time is the best time to a minimum (ie: use the system
> time).

You are right. As John Eidson's excellent book points out, modern
computers and operating systems provide surprisingly little support
for programming based on absolute time. It is not PTP's fault. PTP is
actually a step in the right direction, but it doesn't yet really fit
in to the present computing world.

Okay, here is the Big Picture.

1. Use Case: SW timestamping

   PTP with software timestamping (ie without special hardware) can
   acheive synchronization within a few dozen microseconds, after
   about twenty minutes. This is sufficient for very many people. The
   new API (whether char device or syscall) fully and simply supports
   this use case. When the PTPd adjusts the PTP clock, it is actually
   adjusting the system time, just like NTPd.

2. Use Case: HW timestamping for industrial control

   PTP with hardware timestamping can acheive synchronization within
   100 nanoseconds after one minute. If you want to do something with
   your wonderfully synchronization PTP clock, it must have some kind
   of special hardware, like timestamping external signals or
   generating one-shot or periodic outputs. The new API (whether char
   device or syscall) supports this use case via the ancillary
   commands.

   In this case, the end user has an application that interfaces with
   the outside world via the PTP clock API. Such a specialized
   application (for example, motor control) uses only the PTP API,
   since it knows that the standard posix API cannot help. It is
   irrelevant that the system time is not synchronized, in this case.

   The PTP clock hardware may or may not provide a hardware interface
   (interrupt) to the main CPU. In this case, it does not matter. The
   PTP clock is useful all by itself.

3. Use Case: HW timestamping with PPS to host

   This case is the same as case 2, with the exception that the PTP
   clock can interrupt the main CPU. The PTP clock driver advertises
   the "PPS" capability. When enabled, the PTP layer delivers events
   via the existing Linux PPS subsystem. Programs like NTPd can use
   these events to regulate the system time.

   This means that the system clock and the PTP clock will be at least
   as well synchronized as when using a traditionial radio clock, GPS,
   or IRIG-B method. In my opinion, this will be good enough for any
   practical purpose. For example, let's say you want to run a
   periodic task synchronized to the absolute wall clock time. Your
   scheduling latency will be a dozen microseconds or so. Your PPS
   synchronized system clock should be close enough to the PTP clock
   to support this.

The API that I have suggested, whether offered as a char device or as
syscalls, supports all of the use cases using a single API.

Richard
