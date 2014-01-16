From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 11/13] net: mvneta: implement rx_copybreak
Date: Thu, 16 Jan 2014 21:07:57 +0100
Message-ID: <20140116200757.GA19969@1wt.eu>
References: <1389856819-6503-12-git-send-email-w@1wt.eu> <063D6719AE5E284EB5DD2968C1650D6D45D866@AcuExch.aculab.com> <20140116093640.GA16457@1wt.eu> <20140116.114905.1582218754259744747.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55525 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751557AbaAPUIE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 15:08:04 -0500
Content-Disposition: inline
In-Reply-To: <20140116.114905.1582218754259744747.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Thu, Jan 16, 2014 at 11:49:05AM -0800, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Thu, 16 Jan 2014 10:36:40 +0100
> 
> > On Thu, Jan 16, 2014 at 09:14:00AM +0000, David Laight wrote:
> >> From: Of Willy Tarreau
> >> > calling dma_map_single()/dma_unmap_single() is quite expensive compared
> >> > to copying a small packet. So let's copy short frames and keep the buffers
> >> > mapped. We set the limit to 256 bytes which seems to give good results both
> >> > on the XP-GP board and on the AX3/4.
> >> 
> >> Have you tried something similar for transmits?
> >> Copying short tx into a preallocated memory area that is dma_mapped
> >> at driver initialisation?
> > 
> > Not yet by lack of time, but I intend to do so. Both the NIC and the driver
> > are capable of running at line rate (1.488 Mpps) when filling descriptors
> > directly, so many improvements are still possible.
> 
> I don't know if this is relevant for your hardware, but there is a trick
> with IOMMUs that I at least at one point was doing on sparc64.
> 
> I never flushed the IOMMU mappings explicitly on a dma_unmap call.
> 
> Instead I always allocate by moving the allocation cursor to higher
> addresses in the IOMMU range looking for free space.
> 
> Then when I hit the end of the range and had to wrap the allocation
> cursor back to the beginning, I flush the entire IOMMU.
> 
> So for %99 of IOMMU mapping creation and teardown calls, I didn't even
> touch the hardware.

Ah that's an interesting trick! We don't have an IOMMU on this platform
so the call is cheap. However, it relies on an I/O barrier to wait for
a cache snoop completion. From what I read, it's not needed when going
to the device. But when going to the CPU for the Rx case, we're calling
it for every packet which is counter productive because I'd like to do
it only once when entering the rx loop and avoid any other call during
the loop. I measured that I could save 300 ns per packet by doing this
(thus slightly modifying the DMA API to add a new dma_io_barrier function).

I think it could be interesting (at least for this platform, I don't know
if other platforms work with cache coherent DMA which only require to
verify end of snooping), to have two distinct set of DMA calls, something
like this :

    rx_loop(napi, budget)
    {
         dma_wait_for_snoop_completion(dev);
         ...
         for_each_rx_packet(pkt) {
             dma_sync_single_range_for_cpu_unless_completed(dev, pkt->addr);
             /* use packet */
         }
    }

The dma_wait_for_snoop_completion() call would call this I/O barrier on
platforms which provide one, and dma_sync_single_range_unless_completed()
would do the equivalent call only when the I/O barrier is not provided.
However I don't like this principle because it requires adding many new
entries to the struct dma_ops while we could avoid this by just adding
the first entry and changing all drivers at once to add the first call
before the loop. I'm just having a hard time believing that it's possible
anymore to change all drivers at once, especially when there are out of
tree drivers... So such a change would probably require to add a number
of new calls to the DMA API. I really don't know what's the best solution
would be in fact :-/

Thanks,
Willy
