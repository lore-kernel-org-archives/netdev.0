From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: PHC device sharing between PCI functions
Date: Wed, 3 Jul 2013 20:52:33 +0100
Message-ID: <1372881153.1919.49.camel@bwh-desktop.uk.level5networks.com>
References: <1372697768.2083.21.camel@bwh-desktop.uk.level5networks.com>
	 <20130702142420.GC14630@netboy>
	 <1372778262.1919.12.camel@bwh-desktop.uk.level5networks.com>
	 <20130703183035.GA4446@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Laurence Evans <levans@solarflare.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31797 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932690Ab3GCTwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 15:52:38 -0400
In-Reply-To: <20130703183035.GA4446@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-03 at 20:30 +0200, Richard Cochran wrote:
> On Tue, Jul 02, 2013 at 04:17:42PM +0100, Ben Hutchings wrote:
> > On Tue, 2013-07-02 at 16:24 +0200, Richard Cochran wrote:
> > 
> > > And if so, then how will the mutiple, read-only MAC clocks help other
> > > guests? Seems kinda useless to me.
> > 
> > It would allow them to convert hardware timestamps or sync system time
> > to NIC time.
> 
> Okay, so let's talk about HW time stamps. That is a separate issue
> from the PHC. You would think that you could offer HW time stamping to
> each VM guest using the MAC. But wait, how will the guests enable it?
> 
> They will have to call the HWTSTAMP ioctl. Unfortunately, your driver
> is one of those that offers fine grained choices (as opposed to all
> packets or none), and that means that the guests will be potentially
> spoiling each others settings (unless you implement per-function
> filters).

The SFC9000 family doesn't really support timestamping at all.  It is
implemented on some boards using the management controller, debug probe
signals and an FPGA.  It therefore takes a relatively long time for the
hardware to process each packet, so this has to be limited to only PTP
packets.

For future controllers with integrated timestamping, the driver should
be able to provide more flexibility.

> WRT the PHC, I guess you could offer:
> 
> - gettime	to all functions
> - set/adjtime	works in one, throws error in others
> - pps hook	to all functions
> 
> You just need to decide how to determine which function will have the
> writable clock.

So you think each function should have its own clock device, but it's
only writable on one?  I think that would work, but I thought it would
be undesirable to have multiple aliases for the same physical clock.

> Also, it might be worth thinking about how well the pps interrupt will
> work. When there are many guest, will the card produce multiple MSI
> interrupts every second, on the second? That won't work too well, I
> think.
>
> As an alternative to the pps interrupt, the phc2sys program (from
> linuxptp) can periodically read out the system and PHC times in a
> tight loop in order to discipline the system clock. This works quite
> well in practice, but, again, what happens when multiple guest all try
> to read the PHC time over PCIe simultaneously?

Clock registers are currently only accessible through the management
controller, with high and unpredictable latency.  Forwarding of PPS
events may also be delayed by packet processing etc.  So when the driver
handles a PPS event, the driver and firmware perform this kind of synch
loop for a short while, and then the driver adjusts the PPS event back
to the top of the second with pps_sub_ts().

Running that kind of synch loop from userland probably wouldn't work
nearly as well.

I don't think clock registers will be exposed to the host in future
either, so the driver will still have to handle this in a similar way.
If PPS events are enabled in multiple functions, the driver may spend
some more time spinning but it will do this in process context (work
item) and it won't write anything over the PCIe link while waiting for
the firmware to service its request.

> BTW, I am working on adding Tx time stamping to the tuntap driver. My
> motivation is be able to conveniently test some of the PTP aspects
> (like Best Master Clock selection) over a virtual switch. I also
> wonder whether this could be used to distribute the host's system time
> to VM guests, and how well it would work.

No idea.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
