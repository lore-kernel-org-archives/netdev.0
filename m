From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] jme: Fix DMA unmap warning
Date: Thu, 8 May 2014 11:16:21 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F70F71B@AcuExch.aculab.com>
References: <1399315907-27148-1-git-send-email-nhorman@tuxdriver.com>
 <20140507.155613.630399521517455317.davem@davemloft.net>
 <20140507203317.GC8786@hmsreliant.think-freely.org>
 <063D6719AE5E284EB5DD2968C1650D6D0F70F4EB@AcuExch.aculab.com>
 <20140508110048.GA9696@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"cooldavid@cooldavid.org" <cooldavid@cooldavid.org>
To: 'Neil Horman' <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35740 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752940AbaEHLRr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 07:17:47 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31132-08 for <netdev@vger.kernel.org>;
 Thu,  8 May 2014 12:17:38 +0100 (BST)
In-Reply-To: <20140508110048.GA9696@hmsreliant.think-freely.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman
> On Thu, May 08, 2014 at 09:02:04AM +0000, David Laight wrote:
> > From: Neil Horman
> > ...
> > > Perhaps a solution is a signalling mechanism tied to completion interrupts?
> > > I.e. a mapping failure gets reported to the stack, which causes the
> > > correspondnig queue to be stopped, until such time a the driver signals a safe
> > > restart by the reception of a tx completion interrupt?  I'm actually tinkering
> > > right now with a mechanism that provides guidance to the stack as to how many
> > > dma descriptors are available in a given net_device that might come in handy
> >
> > Is there any mileage in the driver pre-allocating a block of iommu entries
> > and then allocating them to the tx and rx buffers itself?
> > This might need some 'claw back' mechanism to get 'fair' (ok working)
> > allocations when there aren't enough entries for all the drivers.
> >
> I don't think that will work (or more specifically, it won't work in a wide
> enough range of cases).  We can't reasonably predict how many devices will need
> to use dma and how much space each device will need.  A common desktop system
> will likely have no issue with reserving enough room for each nic, but a system
> with 5+ nics/infiniband/fcoe on board is going to have a lot more trouble.  And
> if you happen to be using swiotlb for whatever reason, you may not be able to
> reserve enough space at all.

Which is why I suggested a 'claw back' mechanism to reclaim some entries.
NFI how it could be made to work though.

> What we really need is just a way for the dma_* api to put backpressure on
> callers for a very brief period of time.  Thats why I was thinking something
> involving completion interupts or unmapping events.

A problem I see is that a large number of iommu entries can get used
by network drivers for receive buffers.
If the system is short of iommu entries, then the number of rx buffers
will need to be limited.

Maybe there should be 'low' and 'high' priority requests?
Ethernet drivers using low priority requests for most requests
- except the first few rx buffers, and the first tx buffer?

Your wakeup mechanism would still be needed.

	David
