From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH] net: Provide linear backoff mechanism for
 constrained resources at the driver
Date: Fri, 9 May 2014 12:53:29 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F710574@AcuExch.aculab.com>
References: <20140507.155613.630399521517455317.davem@davemloft.net>
 <1399577392-4457-1-git-send-email-nhorman@tuxdriver.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F71037C@AcuExch.aculab.com>
 <20140509111751.GB13793@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: 'Neil Horman' <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54991 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750824AbaEIMy7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 08:54:59 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00750-09 for <netdev@vger.kernel.org>;
 Fri,  9 May 2014 13:54:51 +0100 (BST)
In-Reply-To: <20140509111751.GB13793@hmsreliant.think-freely.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman 
> On Fri, May 09, 2014 at 08:55:10AM +0000, David Laight wrote:
> > From: Neil Horman
> > > What about something like this?  Its not even compile tested, but let me know
> > > what you think of the idea.  The reasoning behind it is that transient resources
> > > like dma address ranges in the iommu or swiotlb have the following attributes
> > >
> > > 1) they are quickly allocated and freed
> >
> > I'm not sure that is true for iommu entries.
> > The ones allocated for ethernet receive are effectively permanently allocated.
> >
> I disagree.  A review of several NIC drivers shows the pseudocode for the RX
> patch to be:
> 
> For SKB X on the RX ring:
> 	If LENGTH(SKB) < COPYBREAK
> 		SKB2 = ALLOCATE_SKB
> 		COPY_DATA(SKB2, SKB1)
> 		RECEIVE(SKB2)
> 	Else
> 		UNMAP(SKB1)
> 		RECEIVE(SKB1)
> 		SKB1 = ALLOCATE_SKB
> 		MAP(SKB1)
> Done
> 
> The value of COPYBREAK is configurable, but is never more than 256 bytes, and is
> often 128 or fewer bytes (sometimes zero).  This will cause some udp traffic to
> get handled as copies, but never more reasonably sized udp packets, and no well
> behaved tcp traffic will ever get copied.  Those iommu entries will come and go
> very quickly.

If I understand correctly the iommu entries are needed for the ethernet
chip to access main memory. The usual state is that RX ring is full
buffers - all of which are mapped for dma.

> > Imagine a system with 512 iommu entries.
> > An ethernet driver allocates 128 RX ring entries using one iommu entry each.
> > There are now no iommu entries left for anything else.

> That actually leaves 384 entries remaiing, but thats neither here nor there :).
I seem to fail to write 'include 4 such interfaces and' ...

>   iommus work like tlbs, in that they don't have a fixed number of entries.
> Each iommu has a set of page tables, wherein a set of pages can be mapped.
> ...

Yes I realise that what is actually being allocated is io virtual address space.
But the '1 buffer' == '1 slot' simplification is reasonable appropriate for
some 'thought designs'.


> Its a
> limited resource shared unevenly between all dma-ing devices.  Thats why we
> can't reserve entries, because you don't have alot of space to begin with, and
> you don't know how much you'll need until you have the data to send, which can
> vary wildly depending on the device.

You do know how much resource is left though.

> > That system will only work if the ethernet driver reduces the number of
> > active rx buffers.
> >
> Reducing the number of active rx buffers is tantamount to reducing the ring size
> of a NIC, which is already a tunable feature, and not one to be received overly
> well by people trying to maximize their network througput.

Except that it needs to done automatically if there is a global constraint
(be it iommu space or dma-able memory).
In isolation a large rx ring is almost always an advantage.

> > It is also possible (but less likely) that ethernet transmit will
> > use so many iommu entries that none are left for more important things.
> This is possible in all cases, not just transmit.
> 
> > The network will work with only one active transmit, but you may
> > have to do disc and/or usb transfers even when resource limited.
> >
> Hence my RFC patch in my prior note.  If we're resource constrained, push back
> on the qdisc such that we try not to use as many mappings for short time without
> causing too much overhead.  It doesn't affect receive of course, but its very
> hard to deal with managing mapping use when the producer is not directly
> controllable by us.

But ethernet receive is likely to be the big user of iommu entries.
If you constrain it, then there probably won't be allocation failures
elsewhere.

	David
