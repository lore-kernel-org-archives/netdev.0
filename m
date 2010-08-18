From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Tue, 17 Aug 2010 17:22:43 -0700
Message-ID: <1282090963.1734.97.camel@localhost>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	 <363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
	 <AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>
	 <20100817085324.GB3330@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Rodolfo Giometti <giometti@linux.it>,
	Arnd Bergmann <arnd@arndb.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:60466 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752017Ab0HRAW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 20:22:56 -0400
In-Reply-To: <20100817085324.GB3330@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-08-17 at 10:53 +0200, Richard Cochran wrote:
> On Mon, Aug 16, 2010 at 12:24:48PM -0700, john stultz wrote:
> > 3) I'm not sure I see the benefit of being able to have multiple
> > frequency corrected time domains.  In other words, what benefit would
> > you get from adjusting a PTP clock's frequency instead of just
> > adjusting the system's time freq? Having the PTP time as a reference
> > to correct the system time seems reasonable, but I'm not sure I see
> > why userland would want to adjust the PTP clock's freq.
> 
> For PTP enabled hardware, the timestamp on the network packet comes
> from from the PTP clock, not from the system time.
> 
> Of course, you can always just leave the PTP clock alone, figure the
> needed correction, and apply it whenever needed. But this has some
> disadvantages. First of all, the (one and only) open source PTPd does
> not do it that way. Also, only one program (the PTPd or equivalent)
> will know the correct time. Other programs will not be able to ask the
> operating system for time services. Instead, they would need to use
> IPC to the PTPd.

Why would system time not be adjusted to the PTP time?

This is my main concern, that we're presenting a fractured API to
userland. Suddenly there isn't just system time, but ptp time as well,
and possibly multiple different ptp times.

Forgive me, as I suspect I'm missing something key here.

> The PTP protocol (and some PTP hardware) offers a "one step" method,
> where the timestamps are inserted by the hardware on the fly. Here you
> really do need the PTP clock to be correctly adjusted.
> 
> All of the PTP hardware that I am familiar with provides a clock
> adjustment method, so it simpler and cleaner just to use this facility
> to tune the PTP clock.

Hmm. So trying to recap here to see if I'm understanding properly:

The PTP clock is a bit of hardware (usually on the NIC) that can put
timestamps on packets (both incoming or outgoing?).

The need to offset/freq correct the PTP clock is important so that the
timestamps (incoming and outgoing) are correct, which makes future
offset calculations simpler.

Hmm. So I'm actually starting to come around to the chardev interface.

In a way, it seems it has some similarities to how the RTC device is
used in NTPd. Granted, NTPd doesn't correct the RTC (the kernel does
when we're synced, but its not a perfect parallel), but it can be used
as an input the steer the clock.

So while to me, it think it would be more ideal (or maybe just less
different) to have a read-only interface (like the RTC), leaving PTPd to
manage offset calculations and use that to steer the system time. I can
acknowledge the need to have some way to correct the freq so the packet
timestamps are corrected.

I still feel a little concerned over the timer/alarm related interfaces.
Could you explain why the alarm interface is necessary? 

So really I think my initial negative gut reaction to this was mostly
out of the fact that you introduced a char dev that provides almost 100%
coverage of the posix-time interface. That is duplication we definitely
don't want. 

Also I think the documentation I've read about PTP (likely just due to
the engineering focus) has an odd inverted sense of priority, focusing
on keeping obscure hardware clocks on NIC cards in sync, rather then the
the more tangible feature of keeping the system time in sync.

This could be comically interpreted as trying to create a shadow-time on
the system that is the "real time" and "yea, maybe we'll let the system
know what time it is, but user-apps who want to know the score can send
a magic ioctl to /dev/something and get the real deal". ;)  I'm sure
that's not the case, but I'd like to keep any confusion in userland
about which time is the best time to a minimum (ie: use the system
time).

thanks
-john


