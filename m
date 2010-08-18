From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Tue, 17 Aug 2010 17:40:39 -0700
Message-ID: <1282092039.1734.115.camel@localhost>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	 <201008170925.55592.arnd@arndb.de>
	 <20100817105232.GA9079@riccoc20.at.omicron.at>
	 <201008171336.29375.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	linuxppc-dev@lists.ozlabs.org,
	Rodolfo Giometti <giometti@linux.it>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:59182 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453Ab0HRAkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 20:40:43 -0400
In-Reply-To: <201008171336.29375.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-08-17 at 13:36 +0200, Arnd Bergmann wrote:
> On Tuesday 17 August 2010, Richard Cochran wrote:
> > On Tue, Aug 17, 2010 at 09:25:55AM +0000, Arnd Bergmann wrote:
> > > Another difference is that we generally use ioctl for devices that can
> > > be enumerated, while syscalls are for system services that are not tied to
> > > a specific device. This argument works both ways for PTP IMHO: On the one
> > > hand you want to have a reliable clock that you can use without knowing
> > > where it comes from, on the other you might have multiple PTP sources that
> > > you need to differentiate.
> > 
> > Yes, I agree. In normal use, there will be only one PTP clock in a
> > system. However, for research purposes, it would be nice to have more
> > than one.
> > 
> > I've been looking at offering the PTP clock as a posix clock, and it
> > is not as hard as I first thought. The PTP clock or clocks just have
> > to be registered as one of the posix_clocks[MAX_CLOCKS] in
> > posix-timers.c.
> 
> Ok sounds good.

Oh no. I'm starting to waffle here. :)

So while I'm not a fan of the duplication of the posix clocks interface
that the proposed chardev interface introduced, I'm not sure if
absorbing the PTP clocks as a clockid is much better.

Mainly due to the fact that userland apps now have to chose between two
clockids that supposedly represent the same thing (the current wall
time).

> > My suggestion would be to reserve three clock ids in time.h,
> > CLOCK_PTP0, CLOCK_PTP1, and CLOCK_PTP2. The first one would be the
> > same as CLOCK_REALTIME, for SW timestamping, and the other two would
> > allow two different PTP clocks at the same time, for the research use
> > case.

Why would you have CLOCK_PTP0 == CLOCK_REALTIME? Whats the point of
that?

> I don't think there is a point in making exactly two independent sources
> available. The clockid_t space is not really limited, so we could define
> an arbitrary range of ids for ptp sources that could be used simultaneously,
> as long as we have space more more ids with a fixed number.
> 
> Would it be reasonable to assume that on a machine with a large number
> of NICs, you'd want a separate ptp source for each of them for timestamping?
> Or would you preferably define just one source in such a setup?
> 
> I think both could be done with the use of class device attributes in
> sysfs for configuration. Maybe you can have one CLOCK_PTP value for one
> global PTP source and use sysfs to configure which device that is.
> 
> If you also need simultaneous access to the specific clocks, you could
> have run-time configured clockid numbers in a sysfs attribute for each
> ptp class device.
> 
> > Using the clock id will bring another advantage, since it will then be
> > possible for user space to specify the desired timestamp source for
> > SO_TIMESTAMPING.

So how exactly would one map CLOCK_PTPx to an eth device?

So this is a little bit further out there, but assuming PTPd can sync
the PTP clock correctly, why could the kernel itself not sync the PTP
clock to system time?

So instead of the sync path looking like:
1) packet from master arrives on NIC, is timestamped by PTP clock
2) PTPd calculates offset between PTP clock and master time
3) PTPd corrects PTP clock freq/offset
4) PTPd corrects system time freq/offset

It would look like:
1) packet from master arrives on NIC, is timestamped by PTP clock
2) PTPd calculates offset between PTP clock and master time
3) PTPd corrects system time freq/offset
4) kernel corrects PTP clock freq/offset

I'm guessing the indirect PTP clock sync would have greater error, but
it avoids the fractured sense of time.


thanks
-john


