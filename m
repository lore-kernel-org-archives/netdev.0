From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH] net: Provide linear backoff mechanism for
 constrained resources at the driver
Date: Fri, 9 May 2014 11:33:21 -0400
Message-ID: <20140509153321.GE13793@hmsreliant.think-freely.org>
References: <20140507.155613.630399521517455317.davem@davemloft.net>
 <1399577392-4457-1-git-send-email-nhorman@tuxdriver.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F71037C@AcuExch.aculab.com>
 <20140509111751.GB13793@hmsreliant.think-freely.org>
 <063D6719AE5E284EB5DD2968C1650D6D0F710574@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44327 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757309AbaEIPdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 11:33:33 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F710574@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 09, 2014 at 12:53:29PM +0000, David Laight wrote:
> From: Neil Horman 
> > On Fri, May 09, 2014 at 08:55:10AM +0000, David Laight wrote:
> > > From: Neil Horman
> > > > What about something like this?  Its not even compile tested, but let me know
> > > > what you think of the idea.  The reasoning behind it is that transient resources
> > > > like dma address ranges in the iommu or swiotlb have the following attributes
> > > >
> > > > 1) they are quickly allocated and freed
> > >
> > > I'm not sure that is true for iommu entries.
> > > The ones allocated for ethernet receive are effectively permanently allocated.
> > >
> > I disagree.  A review of several NIC drivers shows the pseudocode for the RX
> > patch to be:
> > 
> > For SKB X on the RX ring:
> > 	If LENGTH(SKB) < COPYBREAK
> > 		SKB2 = ALLOCATE_SKB
> > 		COPY_DATA(SKB2, SKB1)
> > 		RECEIVE(SKB2)
> > 	Else
> > 		UNMAP(SKB1)
> > 		RECEIVE(SKB1)
> > 		SKB1 = ALLOCATE_SKB
> > 		MAP(SKB1)
> > Done
> > 
> > The value of COPYBREAK is configurable, but is never more than 256 bytes, and is
> > often 128 or fewer bytes (sometimes zero).  This will cause some udp traffic to
> > get handled as copies, but never more reasonably sized udp packets, and no well
> > behaved tcp traffic will ever get copied.  Those iommu entries will come and go
> > very quickly.
> 
> If I understand correctly the iommu entries are needed for the ethernet
> chip to access main memory. The usual state is that RX ring is full
> buffers - all of which are mapped for dma.
> 
This is true, but those buffers are not static, they are unmapped, and new ones
are mapped in their place on recieve, so theres an opportunity for those
unmapped buffers to get used by other entities/hardware during the recieve
process.  We could do something as you suggest, in which we create an api to
reserve the address space for a buffer, and just continually reuse them, but as
Dave points out, its a limited resource and reserving them may be unfair to
other transient users, especially given that the RX path has to 'over-reserve'
allocating space for the largest packet size receivable, even if we get less
than that.

> > > Imagine a system with 512 iommu entries.
> > > An ethernet driver allocates 128 RX ring entries using one iommu entry each.
> > > There are now no iommu entries left for anything else.
> 
> > That actually leaves 384 entries remaiing, but thats neither here nor there :).
> I seem to fail to write 'include 4 such interfaces and' ...
> 
Ah, that makes more sense

> >   iommus work like tlbs, in that they don't have a fixed number of entries.
> > Each iommu has a set of page tables, wherein a set of pages can be mapped.
> > ...
> 
> Yes I realise that what is actually being allocated is io virtual address space.
> But the '1 buffer' == '1 slot' simplification is reasonable appropriate for
> some 'thought designs'.
> 
Only partly.  Continuity is also a factor here.  You might have 1000 sots
remaining, but under heavy use, your largest contiguous slot could be
significantly smaller, which is what a dma using bit of code is actually
interested in.  Keeping track of the largest contiguous slot is significantly
more difficult, and its all still a bit dicey, because the larges slot might
change between the time a device asks what it is, and actually allocates it.

> 
> > Its a
> > limited resource shared unevenly between all dma-ing devices.  Thats why we
> > can't reserve entries, because you don't have alot of space to begin with, and
> > you don't know how much you'll need until you have the data to send, which can
> > vary wildly depending on the device.
> 
> You do know how much resource is left though.
> 
See above, you can certainly tell in aggregate how much free space is available,
but not what your largest free chunk is.

> > > That system will only work if the ethernet driver reduces the number of
> > > active rx buffers.
> > >
> > Reducing the number of active rx buffers is tantamount to reducing the ring size
> > of a NIC, which is already a tunable feature, and not one to be received overly
> > well by people trying to maximize their network througput.
> 
> Except that it needs to done automatically if there is a global constraint
> (be it iommu space or dma-able memory).
2 Things:

1) Need is really a strong term here.  The penalty for failing a dma mapping is
to drop the frame.  Thats not unacceptible in many use cases.

2) It seems to me that global constraint here implies a static, well known
number.  While its true we can interrogate an iommu, and compare its mapping
size to the ring size of all the NICS/devices on a system to see if we're likely
to exceed the iommu space available, we shouldn't do that.  If a given NIC
doesn't produce much traffic, its ring sizes aren't relevant to the computation.

We're not trying to address a static allocation scheme here.  If a system boots,
it implies that all the recive rings on all the devices were able to reserve the
amount of space they needed in the iommu (as you note earlier, they populate
their rings on init, effectively doing a iommu reservation).  The problem we're
addressing is the periodic lack of space that arises from temporary exhaustion
of iommu space under heavy I/O loads.  We won't know if that happens, until it
happens, and we can't just allocate for the worst case, because then we're sure
to run out of space as devices scale up.  Sharing is the way to do this whenever
possible.

> In isolation a large rx ring is almost always an advantage.
> 
No argument there.  But requiring a user to size a ring based on expected
traffic patterns seems like it won't be well received.

> > > It is also possible (but less likely) that ethernet transmit will
> > > use so many iommu entries that none are left for more important things.
> > This is possible in all cases, not just transmit.
> > 
> > > The network will work with only one active transmit, but you may
> > > have to do disc and/or usb transfers even when resource limited.
> > >
> > Hence my RFC patch in my prior note.  If we're resource constrained, push back
> > on the qdisc such that we try not to use as many mappings for short time without
> > causing too much overhead.  It doesn't affect receive of course, but its very
> > hard to deal with managing mapping use when the producer is not directly
> > controllable by us.
> 
> But ethernet receive is likely to be the big user of iommu entries.
> If you constrain it, then there probably won't be allocation failures
> elsewhere.
> 
What makes you say that?  Theres no reason a tx ring can't be just as full as a
receive ring under heavy traffic load.  If you want to constrain receive
allocations, do so, we have a knob for that already.

Neil

> 	David
> 
> 
> 
> 
