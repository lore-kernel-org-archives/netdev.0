From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: PHC device sharing between PCI functions
Date: Wed, 3 Jul 2013 20:30:37 +0200
Message-ID: <20130703183035.GA4446@netboy>
References: <1372697768.2083.21.camel@bwh-desktop.uk.level5networks.com>
 <20130702142420.GC14630@netboy>
 <1372778262.1919.12.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36550 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754184Ab3GCSat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 14:30:49 -0400
Received: by mail-wi0-f179.google.com with SMTP id hj3so450638wib.12
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 11:30:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1372778262.1919.12.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 02, 2013 at 04:17:42PM +0100, Ben Hutchings wrote:
> On Tue, 2013-07-02 at 16:24 +0200, Richard Cochran wrote:
> 
> > And if so, then how will the mutiple, read-only MAC clocks help other
> > guests? Seems kinda useless to me.
> 
> It would allow them to convert hardware timestamps or sync system time
> to NIC time.

Okay, so let's talk about HW time stamps. That is a separate issue
from the PHC. You would think that you could offer HW time stamping to
each VM guest using the MAC. But wait, how will the guests enable it?

They will have to call the HWTSTAMP ioctl. Unfortunately, your driver
is one of those that offers fine grained choices (as opposed to all
packets or none), and that means that the guests will be potentially
spoiling each others settings (unless you implement per-function
filters).

WRT the PHC, I guess you could offer:

- gettime	to all functions
- set/adjtime	works in one, throws error in others
- pps hook	to all functions

You just need to decide how to determine which function will have the
writable clock.

Also, it might be worth thinking about how well the pps interrupt will
work. When there are many guest, will the card produce multiple MSI
interrupts every second, on the second? That won't work too well, I
think.

As an alternative to the pps interrupt, the phc2sys program (from
linuxptp) can periodically read out the system and PHC times in a
tight loop in order to discipline the system clock. This works quite
well in practice, but, again, what happens when multiple guest all try
to read the PHC time over PCIe simultaneously?

Thanks,
Richard

BTW, I am working on adding Tx time stamping to the tuntap driver. My
motivation is be able to conveniently test some of the PTP aspects
(like Best Master Clock selection) over a virtual switch. I also
wonder whether this could be used to distribute the host's system time
to VM guests, and how well it would work.
