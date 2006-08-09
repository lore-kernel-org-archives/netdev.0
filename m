From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 6/9] [TULIP] Fix IRQ/DMA race
Date: Wed, 09 Aug 2006 01:35:05 -0400
Message-ID: <44D97409.1050002@garzik.org>
References: <20060807204418.GE401@athena.road.mcmartin.ca> <11549840122892-git-send-email-kyle@parisc-linux.org> <11549840321096-git-send-email-kyle@parisc-linux.org> <1154984032324-git-send-email-kyle@parisc-linux.org> <115498403384-git-send-email-kyle@parisc-linux.org> <11549840341728-git-send-email-kyle@parisc-linux.org> <11549840343640-git-send-email-kyle@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org,
	val_henson@linux.intel.com, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:4768 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965067AbWHIFfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 01:35:08 -0400
To: Kyle McMartin <kyle@parisc-linux.org>
In-Reply-To: <11549840343640-git-send-email-kyle@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kyle McMartin wrote:
> From: Grant Grundler <grundler@parisc-linux.org>
> 
> IRQs are racing with tulip_down().
> DMA can be restarted by tulip_interrupt() _after_ we call
> tulip_stop_rxtx() and the DMA buffers are unmapped.  The result
> is an MCA (hard crash on ia64) because of an IO TLB miss.
> 
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
> Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>
> ---
>  drivers/net/tulip/interrupt.c  |    4 ++++
>  drivers/net/tulip/tulip_core.c |   17 +++++++----------
>  2 files changed, 11 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
> index 99ccf2e..19faa0e 100644
> --- a/drivers/net/tulip/interrupt.c
> +++ b/drivers/net/tulip/interrupt.c
> @@ -87,6 +87,10 @@ int tulip_refill_rx(struct net_device *d
>  		}
>  		tp->rx_ring[entry].status = cpu_to_le32(DescOwned);
>  	}
> +
> +/* FIXME: restarting DMA breaks tulip_down() code path.
> +   tulip_down() will unmap the RX and TX descriptors.
> + */
>  	if(tp->chip_id == LC82C168) {
>  		if(((ioread32(tp->base_addr + CSR5)>>17)&0x07) == 4) {
>  			/* Rx stopped due to out of buffers,
> diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
> index 81905f4..363e5f6 100644
> --- a/drivers/net/tulip/tulip_core.c
> +++ b/drivers/net/tulip/tulip_core.c
> @@ -742,21 +742,20 @@ #endif
>  
>  	/* Disable interrupts by clearing the interrupt mask. */
>  	iowrite32 (0x00000000, ioaddr + CSR7);
> +	ioread32 (ioaddr + CSR7);	/* flush posted write */
>  
> -	/* Stop the Tx and Rx processes. */
> -	tulip_stop_rxtx(tp);
> +	spin_unlock_irqrestore (&tp->lock, flags);
>  
> -	/* prepare receive buffers */
> -	tulip_refill_rx(dev);
> +	free_irq (dev->irq, dev);	/* no more races after this */
> +	tulip_stop_rxtx(tp);		/* Stop DMA */

same old comment:  need to stop DMA before releasing interrupt handler.


