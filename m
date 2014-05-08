From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] jme: Fix DMA unmap warning
Date: Thu, 8 May 2014 07:00:48 -0400
Message-ID: <20140508110048.GA9696@hmsreliant.think-freely.org>
References: <1399315907-27148-1-git-send-email-nhorman@tuxdriver.com>
 <20140507.155613.630399521517455317.davem@davemloft.net>
 <20140507203317.GC8786@hmsreliant.think-freely.org>
 <063D6719AE5E284EB5DD2968C1650D6D0F70F4EB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"cooldavid@cooldavid.org" <cooldavid@cooldavid.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54635 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752673AbaEHLA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 07:00:57 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F70F4EB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 08, 2014 at 09:02:04AM +0000, David Laight wrote:
> From: Neil Horman
> ...
> > Perhaps a solution is a signalling mechanism tied to completion interrupts?
> > I.e. a mapping failure gets reported to the stack, which causes the
> > correspondnig queue to be stopped, until such time a the driver signals a safe
> > restart by the reception of a tx completion interrupt?  I'm actually tinkering
> > right now with a mechanism that provides guidance to the stack as to how many
> > dma descriptors are available in a given net_device that might come in handy
> 
> Is there any mileage in the driver pre-allocating a block of iommu entries
> and then allocating them to the tx and rx buffers itself?
> This might need some 'claw back' mechanism to get 'fair' (ok working)
> allocations when there aren't enough entries for all the drivers.
> 
I don't think that will work (or more specifically, it won't work in a wide
enough range of cases).  We can't reasonably predict how many devices will need
to use dma and how much space each device will need.  A common desktop system
will likely have no issue with reserving enough room for each nic, but a system
with 5+ nics/infiniband/fcoe on board is going to have a lot more trouble.  And
if you happen to be using swiotlb for whatever reason, you may not be able to
reserve enough space at all.  

What we really need is just a way for the dma_* api to put backpressure on
callers for a very brief period of time.  Thats why I was thinking something
involving completion interupts or unmapping events.

> I remember some old systems where the cost of setting up the iommu
> entries was such that the breakeven point for copying data was
> measured as about 1k bytes. I've no idea what it is for these systems.
> 
> 	David
> 
> 
> 
> 
