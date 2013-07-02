From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: PHC device sharing between PCI functions
Date: Tue, 2 Jul 2013 16:17:42 +0100
Message-ID: <1372778262.1919.12.camel@bwh-desktop.uk.level5networks.com>
References: <1372697768.2083.21.camel@bwh-desktop.uk.level5networks.com>
	 <20130702142420.GC14630@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31583 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550Ab3GBPRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 11:17:49 -0400
In-Reply-To: <20130702142420.GC14630@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-02 at 16:24 +0200, Richard Cochran wrote:
> Ben,
> 
> I really don't understand what the use case is...
> 
> On Mon, Jul 01, 2013 at 05:56:08PM +0100, Ben Hutchings wrote:
> > Future Solarflare NICs may allow multiple PCI functions to make use of a
> > PTP hardware clock, but without a separate clock per function (probably
> > only one per controller).
> > 
> > I understand that shared PTP hardware clocks already exist, but they
> > usually have an independent existence as a separate PCI or platform
> > device.  In this case the clock would be accessible through any of the
> > PCI functions that also have a net device.
> > 
> > Options I see are:
> > 
> > 1. Instantiate a clock only for the first function.  But that would
> > preclude making the clock available within multiple VMs and their host.
> 
> So, I guess PCI functions on one card may be divided up among the
> guests in a VM environment?

Yes.  I don't know whether that's actually useful given the jitter that
virtualisation tends to introduce, but I wouldn't want to close off the
possibility.

> Even if you did make your one clock visible to mutiple guests, still
> only one would be able to adjust the clock, right?

Yes.

> And if so, then how will the mutiple, read-only MAC clocks help other
> guests? Seems kinda useless to me.

It would allow them to convert hardware timestamps or sync system time
to NIC time.
 
> > 3. Keep track of controllers in the driver, instantiate a 'platform
> > device' for each of them, and instantiate a clock for each of them.
> > This is a little weird, as it wouldn't have any obvious association to
> > the PCI device hierarchy.  But it would let us control the lifetime of
> > the clock devices independently of any one function.
> 
> I think clock and MAC must go hand in hand. Does one card appear as a
> MAC in more than one VM?

Yes, SR-IOV allows for up to 256 PCI functions (or even more) on a
single endpoint (i.e. a single controller).  The hardware will
filter/steer packets to and from the multiple functions based on the
packet header.  In the current chip, hardware timestamping is limited to
a single port and function, but the next generation should be less
constrained.

Ben.

> > I prefer option 3 as I dislike introducing special cases, but I would be
> > interested to hear your (or other people's) opinion on this.
> 
> Sorry, my brain just isn't letting any of this in.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
