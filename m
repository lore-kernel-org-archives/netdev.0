From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH] net: Provide linear backoff mechanism for
 constrained resources at the driver
Date: Fri, 9 May 2014 13:02:42 -0400
Message-ID: <20140509170242.GF13793@hmsreliant.think-freely.org>
References: <20140507.155613.630399521517455317.davem@davemloft.net>
 <1399577392-4457-1-git-send-email-nhorman@tuxdriver.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F71037C@AcuExch.aculab.com>
 <20140509111751.GB13793@hmsreliant.think-freely.org>
 <063D6719AE5E284EB5DD2968C1650D6D0F710574@AcuExch.aculab.com>
 <20140509153321.GE13793@hmsreliant.think-freely.org>
 <063D6719AE5E284EB5DD2968C1650D6D0F710792@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45489 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932286AbaEIRCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 13:02:54 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F710792@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 09, 2014 at 03:46:14PM +0000, David Laight wrote:
> From: Neil Horman [mailto:nhorman@tuxdriver.com]
> ...
> > 2 Things:
> > 
> > 1) Need is really a strong term here.  The penalty for failing a dma mapping is
> > to drop the frame.  Thats not unacceptible in many use cases.
> 
> Indeed, but dropping an ethernet frame will be recovered by the higher layers.
> While not ideal, it is a 'last resort' action.
No argument there, but its the best we have at the moment.

> Note that I'm not suggesting that your deferred retry of the transmit isn't
> a good idea, just that it is probably papering over the cracks.
> 
Except that forcing everyone to a lower througput based on worst case scenarios
doesn't seem like a better solution to me.

> > 2) It seems to me that global constraint here implies a static, well known
> > number.  While its true we can interrogate an iommu, and compare its mapping
> > size to the ring size of all the NICS/devices on a system to see if we're likely
> > to exceed the iommu space available, we shouldn't do that.  If a given NIC
> > doesn't produce much traffic, its ring sizes aren't relevant to the computation.
> 
> An idle NIC will be using a lot of iommu entries for its receive buffers.
> 
Yes, and thats really the point!  Only an Idle NIC will be (mis)using alot of
extra iommu entries.  But we have no way to know if a NIC will be idle, we have
to reserve space for them in the iommu because thats how the hardware is
designed.  The only recourse we have here is to reserve less space for each NIC
RX ring, which punishes those NICS that are active, which is the opposite of
what we really want to do here.

> > We're not trying to address a static allocation scheme here.  If a system boots,
> > it implies that all the recive rings on all the devices were able to reserve the
> > amount of space they needed in the iommu (as you note earlier, they populate
> > their rings on init, effectively doing a iommu reservation).  The problem we're
> > addressing is the periodic lack of space that arises from temporary exhaustion
> > of iommu space under heavy I/O loads.  We won't know if that happens, until it
> > happens, and we can't just allocate for the worst case, because then we're sure
> > to run out of space as devices scale up.  Sharing is the way to do this whenever
> > possible.
> 
> Do you have any data for which drivers have active iommu entries when an
> allocate fails?
> 
No, but I'm not sure it matters which driver holds DMA descriptors when an
allocation failure occurs.  I'm operating under the assumption here that drivers
are attempting to allocate a reasonable number of buffers for the work they need
to do.  I'm not arguing that we can't reclaim space by forcing any given drier
to allocate less, only that doing so isn't helpful in that it will just decrease
receive througput.  We're trading in one problem for another.

> I can imagine systems where almost all the iommu entries are being used
> for ethernet rx buffers, and everything else is fighting for the last
> few entries.
> 
I would argue that its not quite as unbalance as all/few, but yes, your ponit is
sound in that the tx path is fighting for a reduced pool of shared buffers
because of the nature of the RX paths' pre-allocation needs.  We could reduce
the number of those buffers statically, but thats really an administrative job
because the kernel never really knows when a NIC is going to be a high volume
producer or consumer.

Hmm, that actually makes me wonder, is this a job for something like tuned up in
user space?  or a cmobination of something like my backoff patch and tuned?  The
backoff patch helps the tx path in case of an actuall exhaustion, and tuned can
be administratively loaded with a profile to indicate which nics are likely to
be low volume, and therefore can have their ring sizes reduced, giving the iommu
the maximum free pool to services all the other dma users?

What do you think?
Neil
