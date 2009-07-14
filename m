From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Debounce code vs. dma_sync_single_range_for_cpu() and e100 driver.
Date: Tue, 14 Jul 2009 23:01:54 +0200
Message-ID: <m38wirm119.fsf@intrepid.localdomain>
References: <m31vokbi6p.fsf@intrepid.localdomain>
	<20090713181237.GD31979@n2100.arm.linux.org.uk>
	<m3d483m53q.fsf@intrepid.localdomain>
	<20090714.123848.189674670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:38515 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752193AbZGNVB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2009 17:01:57 -0400
In-Reply-To: <20090714.123848.189674670.davem@davemloft.net> (David Miller's message of "Tue\, 14 Jul 2009 12\:38\:48 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Added Cc:)

David Miller <davem@davemloft.net> writes:

> And it's especially buggy if it isn't doing DMA API sync calls before
> looking at descriptor fields, as your patch seems to cure.

Well, it does that but doesn't "sync for device" _after_ looking at the
RX descriptor (when the device is to own the desc again). On IXP4xx the
ownership transfer (cache flush/invalidate) happens on "sync for device"
only (which IMHO seems a bit fragile, though).

So what do we do?

Maybe you apply the workaround for 2.6.31 and I (or someone) will
convert e100 to coherent allocs for packet descriptors, post-31?

This isn't a terrible problem (x86 isn't affected), perhaps we should
leave it as is for 2.6.31 making sure it doesn't get out of sight with
the workaround in place?

Guess it's too risky for me to mess with the coherent allocs conversion
for 31, I don't know e100 code at all (and I have to leave for few weeks
on Thursday).



E100: work around the driver using streaming DMA mapping for RX descriptors.

E100 places it's RX packet descriptors inside skb->data and uses them
with bidirectional streaming DMA mapping. Unfortunately it fails to
transfer skb->data ownership to the device after it reads the
descriptor's status, breaking on non-coherent (e.g., ARM) platforms.

This have to be converted to use coherent memory for the descriptors.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1762,6 +1762,9 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 
 			if (ioread8(&nic->csr->scb.status) & rus_no_res)
 				nic->ru_running = RU_SUSPENDED;
+		pci_dma_sync_single_for_device(nic->pdev, rx->dma_addr,
+					       sizeof(struct rfd),
+					       PCI_DMA_BIDIRECTIONAL);
 		return -ENODATA;
 	}
 
