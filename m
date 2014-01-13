From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 6/6] net: mvneta: implement rx_copybreak
Date: Mon, 13 Jan 2014 11:49:38 +0100
Message-ID: <20140113104938.GB20202@1wt.eu>
References: <1389525848-1814-1-git-send-email-w@1wt.eu> <1389525848-1814-7-git-send-email-w@1wt.eu> <063D6719AE5E284EB5DD2968C1650D6D458FB3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55302 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751246AbaAMKtq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jan 2014 05:49:46 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D458FB3@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Mon, Jan 13, 2014 at 10:13:16AM +0000, David Laight wrote:
> From: Willy Tarreau
> > calling dma_map_single()/dma_unmap_single() is quite expensive compared
> > to copying a small packet. So let's copy short frames and keep the buffers
> > mapped. We set the limit to 256 bytes which seems to give good results both
> > on the XP-GP board and on the AX3/4.
> 
> Which architecture is this?

It's an ARMv7.

> I presume it is one that needs iommu setup and/or cache flushing.

Just wait for cache snoop completion.

> > The Rx small packet rate increased by 16.4% doing this, from 486kpps to
> > 573kpps. It is worth noting that even the call to the function
> > dma_sync_single_range_for_cpu() is expensive (300 ns) although less
> > than dma_unmap_single(). Without it, the packet rate raises to 711kpps
> > (+24% more). Thus on systems where coherency from device to CPU is
> > guaranteed by a snoop control unit, this patch should provide even more
> > gains, and probably rx_copybreak could be increased.
> 
> Is that the right way around?
> If cache coherency is guaranteed then I'd have thought that the dma sync
> would be a nop.

It's a bit more tricky. I found that the DMA API is not optimal for such
an architecture, because we need to wait *once* for the cache snooping to
complete at the beginning of the Rx loop, and then all other access may be
done with a NOP. However, since we don't currently have the ability to do
a first call and replace the other ones with a NOP, we still have to do
a dma_sync_single_for_cpu() for each packet, resulting in waiting for cache
snoop completion for each packet.
 
I've hacked the DMA API to add support for ops->iobarrier and test for it
at the beginning of the loop, call it, then avoid doing dma_sync_* afterwards
if it's defined. That way I reach the higher performance mentionned above.

But in my opinion, this is only material for future discussions.

> ...
> > +			memcpy(skb_put(skb, rx_bytes),
> > +			       data + MVNETA_MH_SIZE + NET_SKB_PAD,
> > +			       rx_bytes);
> 
> You can probably arrange for the copy to be fully aligned since
> the partial words at both ends can be safely read and written.
> That might speed things up further.

In fact it does not, this is what the very first patch did but I did not
see any difference.

Thanks,
Willy
