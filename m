From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: E100 RX ring buffers continued...
Date: Sun, 23 Aug 2009 22:43:29 +0200
Message-ID: <m3k50utg5q.fsf@intrepid.localdomain>
References: <1288246454.81251051629969.JavaMail.root@mail.holmansrus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	jeffrey t kirsher <jeffrey.t.kirsher@intel.com>,
	jesse brandeburg <jesse.brandeburg@intel.com>,
	bruce w allan <bruce.w.allan@intel.com>,
	peter p waskiewicz jr <peter.p.waskiewicz.jr@intel.com>,
	john ronciak <john.ronciak@intel.com>,
	David Miller <davem@davemloft.net>
To: Walt Holman <walt@holmansrus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:32923 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934078AbZHWUng convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2009 16:43:36 -0400
In-Reply-To: <1288246454.81251051629969.JavaMail.root@mail.holmansrus.com> (Walt Holman's message of "Sun\, 23 Aug 2009 13\:20\:29 -0500 \(CDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Walt Holman <walt@holmansrus.com> writes:

> I've tested this under 2.6.31-rc7 (which was also broken to begin
> with) and this appears to have fixed it.  It's a fairly limited test
> at this point, as I've just been downloading a large file for the pas=
t
> 15 mins. or so, but this was normally enough to have multiple
> stoppages.  Do you still need 2.6.30.5 tested as well?

No, these tests and the drivers in both versions are equivalent. Thanks
a lot.


David, I think it's safe to apply this. Probably to "stable" series,
too.

I think at least this should theoretically be changed as well:

e100_rx_indicate()
        ...
        /* Need to sync before taking a peek at cb_complete bit */
        pci_dma_sync_single_for_cpu(nic->pdev, rx->dma_addr,
                sizeof(struct rfd), PCI_DMA_BIDIRECTIONAL);
        rfd_status =3D le16_to_cpu(rfd->status);

but since it appears to work I wouldn't touch it ATM. I guess the
swiotlb code is smart enough to not write to device-owner memory on
for_cpu() call.

=2E..

E100: fix interaction with swiotlb on X86.

E100 places it's RX packet descriptors inside skb->data and uses them
with bidirectional streaming DMA mapping. Data in descriptors is
accessed simultaneously by the chip (writing status and size when
a packet is received) and CPU (reading to check if the packet was
received). This isn't a valid usage of PCI DMA API, which requires use
of the coherent (consistent) memory for such purpose. Unfortunately e10=
0
chips working in "simplified" RX mode have to store received data
directly after the descriptor. Fixing the driver to conform to the API
would require using unsupported "flexible" RX mode or receiving data
into a coherent memory and using CPU to copy it to network buffers.

This patch, while not yet making the driver conform to the PCI DMA API,
allows it to work correctly on X86 with swiotlb (while not breaking
other architectures).

Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 014dfb6..53e8252 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1764,7 +1764,7 @@ static int e100_rx_indicate(struct nic *nic, stru=
ct rx *rx,
 				nic->ru_running =3D RU_SUSPENDED;
 		pci_dma_sync_single_for_device(nic->pdev, rx->dma_addr,
 					       sizeof(struct rfd),
-					       PCI_DMA_BIDIRECTIONAL);
+					       PCI_DMA_FROMDEVICE);
 		return -ENODATA;
 	}
=20

--=20
Krzysztof Halasa
