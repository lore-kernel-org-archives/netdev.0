From: Robert Hancock <hancockrwd@gmail.com>
Subject: NETIF_F_HIGHDMA misuse in networking drivers?
Date: Sat, 20 Feb 2010 12:29:14 -0600
Message-ID: <4B8029FA.2000404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Was just part of a discussion in another thread talking about 64-bit DMA 
support issues where NETIF_F_HIGHDMA came up. I was originally under the 
impression that this flag indicated the device supported 64-bit DMA 
addressing. However, from looking at the code that checks for it (and, 
well, the actual comment for the flag) it really means "can access 
highmem" which has nothing to do with 64-bit at all. And if there's no 
highmem (like on x86_64) it has no effect at all.

 From looking at some drivers, however, it seems a lot of others had 
similar confusion, as they are doing things like setting NETIF_F_HIGHDMA 
conditionally on whether setting 64-bit DMA mask succeeds:

drivers/net/8139cp.c:

         if (pci_using_dac)
                 dev->features |= NETIF_F_HIGHDMA;

drivers/net/jme.c:

         if (jme->dev->features & NETIF_F_HIGHDMA)
                 rxdesc->desc1.flags = RXFLAG_64BIT;

drivers/net/forcedeth.c:

                 if (dma_64bit) {
                         if (pci_set_dma_mask(pci_dev, DMA_BIT_MASK(39)))
                                 dev_printk(KERN_INFO, &pci_dev->dev,
                                         "64-bit DMA failed, using 
32-bit addressing\n");
                         else
                                 dev->features |= NETIF_F_HIGHDMA;

(the last one is extra funny because it keeps saying 64-bit when it's 
really only 39-bit..)

The net result is that a lot of drivers aren't setting the HIGHDMA flag 
where they should, and thus on architectures where highmem exists, 
resulting in a bunch of unnecessary copying.

Assuming my interpretation is correct, I could try and fix up some of 
this mess.. any comments?
