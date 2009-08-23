From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: E100 RX ring buffers continued...
Date: Sun, 23 Aug 2009 17:30:37 +0200
Message-ID: <m3tyzytun6.fsf@intrepid.localdomain>
References: <m38whchrer.fsf@intrepid.localdomain>
	<20090822.181552.152398363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: David Miller <davem@davemloft.net>,
	Walt Holman <walt@holmansrus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:48503 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933839AbZHWPai (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2009 11:30:38 -0400
In-Reply-To: <20090822.181552.152398363.davem@davemloft.net> (David Miller's message of "Sat\, 22 Aug 2009 18\:15\:52 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> I think going down the road of trying to use the flexible mode is a
> dead end.  I doubt any other OS driver is using it, and that means
> that there are likely many other errata hiding in the bushes which you
> will unearth by trying to use this new descriptor mode.  And it won't
> show up when you test it, it will show up when some random person in
> some remote data center somewhere updates their kernel, and they won't
> send us a bug report, they'll replace their card or downgrade their
> kernel instead.

Well, I'm afraid it's a possible scenario. I won't touch the flexible
mode unless Intel folks tell me it's safe.
OTOH it seems it was used by less common software, at least in the
82557-9 times. Not sure about Windows driver.
(It seems the simplified mode was meant for Linux-alike "1 buffer per
packet" approach while the flexible mode was to support systems using
mbuf-like structures).

> Just make the driver use consistent buffers for RX, and when packets
> arrive an SKB is allocated and the packet data is copied into the SKB
>>From the consistent buffer.

That would be a performance hit, wouldn't it? Especially in older
machines, where e100 was typically installed. I think it should be the
last resort.

> And for 2.6.31-rcX we probably have to simply revert your change.

Unfortunately it seems that reverting will not fix operation completely
on a system with swiotlb (checking the descriptor status isn't the only
racy operation which depends on the cache behaviour, though it's the
most frequent). And it will break all non-coherent archs again, they
will either need to use the patch or still stick to (already removed)
eepro100.c

I looked at the eepro100.c sources. It uses BIDIR mapping the same way
as e100.c does, but then syncs using FROM_DEVICE/TO_DEVICE instead of
e100's always-BIDIR. I think the same in e100.c would work on all
platforms (though still violating the DMA API a bit). Perhaps we should
do that instead?

Walt, can you check if 2.6.30.5 with the following patch applied still
breaks e100 with the 6 GB of RAM, please? TIA.
(This patch makes swiotlb aware that the CPU didn't alter the buffer,
though I don't know if swiotlb will use this info).

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 014dfb6..53e8252 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1764,7 +1764,7 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 				nic->ru_running = RU_SUSPENDED;
 		pci_dma_sync_single_for_device(nic->pdev, rx->dma_addr,
 					       sizeof(struct rfd),
-					       PCI_DMA_BIDIRECTIONAL);
+					       PCI_DMA_FROMDEVICE);
 		return -ENODATA;
 	}
 
-- 
Krzysztof Halasa
