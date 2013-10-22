From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] 3c59x: fix incorrect use of spin_lock_bh in interrupts
Date: Tue, 22 Oct 2013 12:07:01 -0400 (EDT)
Message-ID: <alpine.LRH.2.02.1310221148010.29454@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1310211950360.5325@file01.intranet.prod.int.rdu2.redhat.com> <20131022.025514.1611245390510932009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: klassert@mathematik.tu-chemnitz.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33154 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753234Ab3JVQHI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 12:07:08 -0400
In-Reply-To: <20131022.025514.1611245390510932009.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 22 Oct 2013, David Miller wrote:

> From: Mikulas Patocka <mpatocka@redhat.com>
> Date: Mon, 21 Oct 2013 19:53:22 -0400 (EDT)
> 
> > The functions mdio_read and mdio_write may be called from interrupt
> > context. Consequently, we must use spin_lock_irqsave instead of
> > spin_lock_bh.
> > 
> > This patch should be backported to stable kernels.
> 
> vortex_down() does a lot of other things which are really dangerous
> from an interrupt handler, such as del_timer_sync().
> 
> The real fix for this bug is to defer the vortex_error() work into
> a workqueue, and thus process context, like every other driver does.

That del_timer_sync() could be skipped - if we reset the card, we don't 
need to reinitialize the times. Do you see anything else there that 
prevents the functions vortex_down and vortex_up from being called from an 
interrupt?

There is another bug in the driver - vortex_up(dev);  /* AKPM: bug.  
vortex_up() assumes that the rx ring is full. It may not be. */ --- so it 
likely needs more rework of the receive path.



Another thing - I'd like to ask about this part of the driver:
                        vp->rx_ring[entry].addr = 
cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->data, PKT_BUF_SZ, 
PCI_DMA_FROMDEVICE));
                        vp->rx_skbuff[entry] = skb;
                }
                vp->rx_ring[entry].status = 0;  /* Clear complete bit. */
                iowrite16(UpUnstall, ioaddr + EL3_CMD);

We set vp->rx_ring[entry].addr as an address of the new buffer and then 
vp->rx_ring[entry].status, that enables the card to write to the 
descriptor.

The ring is allocated with dma_alloc_coherent. Does dma_alloc_coherent 
guarantee that the writes to "addr" and "status" field won't be reordered 
by the processor? (on x86 it is guaranteed, but what about others). Should 
there be wmb() between write to "addr" and "status" and between write to 
"status" and "EL3_CMD"? Some other drivers have wmb() in these sections.

Mikulas
