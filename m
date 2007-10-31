From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][RFC] Add support for the RDC R6040 Fast Ethernet controller
Date: Wed, 31 Oct 2007 04:57:54 -0400
Message-ID: <47284392.80009@garzik.org>
References: <200710292251.43257.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51431 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756061AbXJaI56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 04:57:58 -0400
In-Reply-To: <200710292251.43257.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli wrote:
> This patch adds support for the RDC R6040 MAC we can find in the RDC R-321x System-on-chips.
> This driver really needs improvements especially on the NAPI part which probably does not
> fully use the new NAPI structure.
> You will need the RDC PCI identifiers if you want to test this driver which are the following ones :
> 
> RDC_PCI_VENDOR_ID = 0x17f3
> RDC_PCI_DEVICE_ID_RDC_R6040 = 0x6040
> 
> Thank you very much in advance for your comments.
> 
> Signed-off-by: Sten Wang <sten.wang@rdc.com.tw>
> Signed-off-by: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
> Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>

Looks nice and clean to me.  Pre-merge stuff I think needs fixing:

* clean up NAPI as you describe (and delete non-NAPI code paths, unless 
there is a strong reason to keep them).

* unconditional local_irq_{enable,disable} stuff

* spin_lock_irqsave() should not be needed in interrupt handler. 
[perhaps you did this rather than put the slower locking in 
->poll_controller()]

* remove changelog from C header (git repository log is our changelog)

* handle large dev->mc_count, as you note in the C header

* use __le32 and similar data types. validate with sparse 
(Documentation/sparse.txt)

* consider using ioread{8,16,32} and iowrite{8,16,32}, if your platform 
permits.  Then switch from 'unsigned long' to special marker 'void 
__iomem *' for all I/O port addresses

* use DMA_32BIT_MASK rather than 0xffffffff in pci_set_dma_mask() call

* in r6040_init_one() call is_valid_ether_addr(), rather than 
hand-rolling the same code yourself

* you need to note carrier state when it changes, using 
netif_carrier_on() and netif_carrier_off()

