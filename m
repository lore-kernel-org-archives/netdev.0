From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Debounce code vs. dma_sync_single_range_for_cpu() and e100 driver.
Date: Tue, 14 Jul 2009 21:34:01 +0200
Message-ID: <m3d483m53q.fsf@intrepid.localdomain>
References: <m31vokbi6p.fsf@intrepid.localdomain>
	<20090713181237.GD31979@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:36477 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756190AbZGNTeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2009 15:34:05 -0400
Received: from intrepid.localdomain (intrepid.localdomain [10.0.0.2])
	by khc.piap.pl (Postfix) with ESMTP id 22A839316
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 21:34:02 +0200 (CEST)
In-Reply-To: <20090713181237.GD31979@n2100.arm.linux.org.uk> (Russell King's message of "Mon\, 13 Jul 2009 19\:12\:37 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A copy of my mail to linux-arm list.

Arch = ARM, CPU = IXP425, net device = 82551 using e100 driver.

Russell King - ARM Linux <linux@arm.linux.org.uk> writes:

> Cache handling is performed when ownership of buffers transfer from the
> CPU to the device.  At this point in time, the CPU must not read or write
> any cache lines associated with the buffer.

Well, e100 driver uses streaming mapping for it's RX/TX buffers as well
as for the descriptors. Now it gets tricky - RX ring descriptors can be
written by the device at any time (when completing RX) and at the same
time the CPU has to be able to check the descriptor's status. It seems
it can't be formally done with the streaming DMA API, since it doesn't
provide invalidate and flush operations, it's rather about transfering
control.

I guess the coherent/consistent allocations should be used for this
purpose (= uncached RAM pages on IXP4xx if I understand it correctly).

Now that I know the inner working of DMA API the attached patch "fixes"
the e100 problems, but it still doesn't seem to be a valid use of the
API.

Comments?

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
 

Without the patch:

$ ping 10.150 -i 0.2
PING 10.150 (10.0.0.150) 56(84) bytes of data.
64 bytes from 10.0.0.150: icmp_seq=1 ttl=64 time=619 ms
64 bytes from 10.0.0.150: icmp_seq=2 ttl=64 time=410 ms
64 bytes from 10.0.0.150: icmp_seq=3 ttl=64 time=200 ms
64 bytes from 10.0.0.150: icmp_seq=4 ttl=64 time=0.498 ms
64 bytes from 10.0.0.150: icmp_seq=5 ttl=64 time=2880 ms

With the patch:

$ ping 10.150 -i 0.2
PING 10.150 (10.0.0.150) 56(84) bytes of data.
64 bytes from 10.0.0.150: icmp_seq=1 ttl=64 time=7.05 ms
64 bytes from 10.0.0.150: icmp_seq=2 ttl=64 time=0.269 ms
64 bytes from 10.0.0.150: icmp_seq=3 ttl=64 time=0.887 ms
64 bytes from 10.0.0.150: icmp_seq=4 ttl=64 time=0.311 ms
64 bytes from 10.0.0.150: icmp_seq=5 ttl=64 time=0.878 ms

IXP425 533 MHz, i82551, 2.6.30.

OTOH, nobody uses e100 on non-coherent ARM? Perhaps a slower CPU (with
maybe higher IRQ latency) would hit the problem less frequently?

Thanks for your help.
-- 
Krzysztof Halasa
