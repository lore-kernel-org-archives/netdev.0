From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: [RFC 2/2] shrink size of scatterlist on common i386/x86-64
Date: Sun, 8 Jul 2007 19:17:30 +0300
Message-ID: <20070708161730.GA4146@rhun.haifa.ibm.com>
References: <20070705.171535.105173068.davem@davemloft.net> <08FE5CC30C9A3F41BF819A502CF7BF6E0198249D@fmsmsx411.amr.corp.intel.com> <20070706.122019.55506705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mitch.a.williams@intel.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:33529 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292AbXGHQRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2007 12:17:33 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l68GHWfq145598
	for <netdev@vger.kernel.org>; Sun, 8 Jul 2007 16:17:32 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l68GHVsL3137722
	for <netdev@vger.kernel.org>; Sun, 8 Jul 2007 17:17:32 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l68GHV5S020950
	for <netdev@vger.kernel.org>; Sun, 8 Jul 2007 17:17:31 +0100
Content-Disposition: inline
In-Reply-To: <20070706.122019.55506705.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 06, 2007 at 12:20:19PM -0700, David Miller wrote:
> From: "Williams, Mitch A" <mitch.a.williams@intel.com>
> Date: Fri, 6 Jul 2007 10:14:56 -0700
> 
> > In my opinion, IOMMU table locking is the major issue with this
> > type of architecture.  Since both Intel and AMD are touting IOMMUs
> > for virtual- ization support, this is an issue that's going to
> > need a lot of scrutiny.
> 
> For the allocation of IOMMU entries themselves you can play tricks
> using atomic operations on 64-bit words of the allocator bitmap to
> avoid locking that.

Hmm, any pointers?

> You can use per-cpu salts to determine where to start the search and
> avoid hitting the same cachelines as other cpus working on the same
> table.
> 
> But you'll need to lock in order to flush the IOMMU tlb I'm afraid.
> The way to mitigate that is to only flush the IOMMU tlb once per
> allocator generation.

That works, but isn't optimal when you have an isolation-capable IOMMU
and you want the full isolation properties of the IOMMU. If you only
flush the IOTLB when the allocator wraps around, a stale entry in the
IOTLB can allow a DMA to go through for an IO entry that has already
been unmapped. One way to mitigate that and still retain full
isolation is to make sure no one else gets to use the frames that are
the targets of the DMA until the translation has been flushed out of
the IOTLB, but that requires pretty deep surgery.

Cheers,
Muli


