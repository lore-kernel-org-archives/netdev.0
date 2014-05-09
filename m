From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH] net: Provide linear backoff mechanism for
 constrained resources at the driver
Date: Fri, 9 May 2014 07:17:51 -0400
Message-ID: <20140509111751.GB13793@hmsreliant.think-freely.org>
References: <20140507.155613.630399521517455317.davem@davemloft.net>
 <1399577392-4457-1-git-send-email-nhorman@tuxdriver.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F71037C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40820 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaEILR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 07:17:58 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F71037C@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 09, 2014 at 08:55:10AM +0000, David Laight wrote:
> From: Neil Horman
> > What about something like this?  Its not even compile tested, but let me know
> > what you think of the idea.  The reasoning behind it is that transient resources
> > like dma address ranges in the iommu or swiotlb have the following attributes
> > 
> > 1) they are quickly allocated and freed
> 
> I'm not sure that is true for iommu entries.
> The ones allocated for ethernet receive are effectively permanently allocated.
> 
I disagree.  A review of several NIC drivers shows the pseudocode for the RX
patch to be:

For SKB X on the RX ring:
	If LENGTH(SKB) < COPYBREAK
		SKB2 = ALLOCATE_SKB
		COPY_DATA(SKB2, SKB1)
		RECEIVE(SKB2)
	Else
		UNMAP(SKB1)
		RECEIVE(SKB1)
		SKB1 = ALLOCATE_SKB
		MAP(SKB1)
Done

The value of COPYBREAK is configurable, but is never more than 256 bytes, and is
often 128 or fewer bytes (sometimes zero).  This will cause some udp traffic to
get handled as copies, but never more reasonably sized udp packets, and no well
behaved tcp traffic will ever get copied.  Those iommu entries will come and go
very quickly.

> Imagine a system with 512 iommu entries.
> An ethernet driver allocates 128 RX ring entries using one iommu entry each.
> There are now no iommu entries left for anything else.
That actually leaves 384 entries remaiing, but thats neither here nor there :).
  iommus work like tlbs, in that they don't have a fixed number of entries.
Each iommu has a set of page tables, wherein a set of pages can be mapped.  If
a packet fits within a single page, then yes, it takes up a single 'pte', if a
packet takes multiple pages (say a gso packet for example), or if some other
device is doing lots of high volume dma (FCoE/iscsi/roce/infiniband), then
multiple pte's will be taken up handling the larger data buffer.  Its a
limited resource shared unevenly between all dma-ing devices.  Thats why we
can't reserve entries, because you don't have alot of space to begin with, and
you don't know how much you'll need until you have the data to send, which can
vary wildly depending on the device.
 
> That system will only work if the ethernet driver reduces the number of
> active rx buffers.
> 
Reducing the number of active rx buffers is tantamount to reducing the ring size
of a NIC, which is already a tunable feature, and not one to be received overly
well by people trying to maximize their network througput.

> It is also possible (but less likely) that ethernet transmit will
> use so many iommu entries that none are left for more important things.
This is possible in all cases, not just transmit.

> The network will work with only one active transmit, but you may
> have to do disc and/or usb transfers even when resource limited.
> 
Hence my RFC patch in my prior note.  If we're resource constrained, push back
on the qdisc such that we try not to use as many mappings for short time without
causing too much overhead.  It doesn't affect receive of course, but its very
hard to deal with managing mapping use when the producer is not directly
controllable by us.

Neil

> 	David
> 
> 
> 
> 
