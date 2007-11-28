From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] Fix e100 on systems that have cache incoherent DMA
Date: Wed, 28 Nov 2007 14:12:38 -0500
Message-ID: <474DBDA6.50705@roinet.com>
References: <20071108181741.8648.61629.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, akpm@linux-foundation.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, miltonm@bga.com,
	e1000-devel@lists.sourceforge.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:52073
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbXK1TNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 14:13:00 -0500
In-Reply-To: <20071108181741.8648.61629.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

What is the status of this patch?  Is there anything folks would like me to do in order to move it forward?  As an FYI, 
my company has been using this patch since I posted it and so far we have not had any problems with it.
-Ack

Auke Kok wrote:
> From: David Acker <dacker@roinet.com>
> 
> On the systems that have cache incoherent DMA, including ARM, there
> is a race condition between software allocating a new receive buffer
> and hardware writing into a buffer.  The two race on touching the last
> Receive Frame Descriptor (RFD).  It has its el-bit set and its next
> link equal to 0.  When hardware encounters this buffer it attempts to
> write data to it and then update Status Word bits and Actual Count in
> the RFD.  At the same time software may try to clear the el-bit and
> set the link address to a new buffer.
> 
> Since the entire RFD is once cache-line, the two write operations can
> collide.  This can lead to the receive unit stalling or interpreting
> random memory as its receive area.
> 
> The fix is to set the el-bit on and the size to 0 on the next to last
> buffer in the chain.  When the hardware encounters this buffer it stops
> and does not write to it at all.  The hardware issues an RNR interrupt
> with the receive unit in the No Resources state.  Software can write
> to the tail of the list because it knows hardware will stop on the
> previous descriptor that was marked as the end of list.
> 
> Once it has a new next to last buffer prepared, it can clear the el-bit
> and set the size on the previous one.  The race on this buffer is safe
> since the link already points to a valid next buffer and the software
> can handle the race setting the size (assuming aligned 16 bit writes
> are atomic with respect to the DMA read). If the hardware sees the
> el-bit cleared without the size set, it will move on to the next buffer
> and skip this one.  If it sees the size set but the el-bit still set,
> it will complete that buffer and then RNR interrupt and wait.
> 
> Signed-off-by: David Acker <dacker@roinet.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e100.c |  128 ++++++++++++++++++++++++++++++++++++++++------------
>  1 files changed, 99 insertions(+), 29 deletions(-)
> 
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index 3dbaec6..2153058 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -106,6 +106,13 @@
>   *	the RFD, the RFD must be dma_sync'ed to maintain a consistent
>   *	view from software and hardware.
>   *
> + *	In order to keep updates to the RFD link field from colliding with
> + *	hardware writes to mark packets complete, we use the feature that
> + *	hardware will not write to a size 0 descriptor and mark the previous
> + *	packet as end-of-list (EL).   After updating the link, we remove EL
> + *	and only then restore the size such that hardware may use the
> + *	previous-to-end RFD.
> + *
>   *	Under typical operation, the  receive unit (RU) is start once,
>   *	and the controller happily fills RFDs as frames arrive.  If
>   *	replacement RFDs cannot be allocated, or the RU goes non-active,
> @@ -281,6 +288,7 @@ struct csr {
>  };
>  
>  enum scb_status {
> +	rus_no_res       = 0x08,
>  	rus_ready        = 0x10,
>  	rus_mask         = 0x3C,
>  };
> @@ -952,7 +960,7 @@ static void e100_get_defaults(struct nic *nic)
>  		((nic->mac >= mac_82558_D101_A4) ? cb_cid : cb_i));
>  
>  	/* Template for a freshly allocated RFD */
> -	nic->blank_rfd.command = cpu_to_le16(cb_el);
> +	nic->blank_rfd.command = 0;
>  	nic->blank_rfd.rbd = 0xFFFFFFFF;
>  	nic->blank_rfd.size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
>  
> @@ -1791,15 +1799,12 @@ static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
>  	}
>  
>  	/* Link the RFD to end of RFA by linking previous RFD to
> -	 * this one, and clearing EL bit of previous.  */
> +	 * this one.  We are safe to touch the previous RFD because
> +	 * it is protected by the before last buffer's el bit being set */
>  	if(rx->prev->skb) {
>  		struct rfd *prev_rfd = (struct rfd *)rx->prev->skb->data;
>  		put_unaligned(cpu_to_le32(rx->dma_addr),
>  			(u32 *)&prev_rfd->link);
> -		wmb();
> -		prev_rfd->command &= ~cpu_to_le16(cb_el);
> -		pci_dma_sync_single_for_device(nic->pdev, rx->prev->dma_addr,
> -			sizeof(struct rfd), PCI_DMA_TODEVICE);
>  	}
>  
>  	return 0;
> @@ -1824,8 +1829,19 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
>  	DPRINTK(RX_STATUS, DEBUG, "status=0x%04X\n", rfd_status);
>  
>  	/* If data isn't ready, nothing to indicate */
> -	if(unlikely(!(rfd_status & cb_complete)))
> +	if (unlikely(!(rfd_status & cb_complete))) {
> +		/* If the next buffer has the el bit, but we think the receiver
> +		 * is still running, check to see if it really stopped while
> +		 * we had interrupts off.
> +		 * This allows for a fast restart without re-enabling
> +		 * interrupts */
> +		if ((le16_to_cpu(rfd->command) & cb_el) &&
> +		    (RU_RUNNING == nic->ru_running))
> +
> +			if (readb(&nic->csr->scb.status) & rus_no_res)
> +				nic->ru_running = RU_SUSPENDED;
>  		return -ENODATA;
> +	}
>  
>  	/* Get actual data size */
>  	actual_size = le16_to_cpu(rfd->actual_size) & 0x3FFF;
> @@ -1836,9 +1852,18 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
>  	pci_unmap_single(nic->pdev, rx->dma_addr,
>  		RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
>  
> -	/* this allows for a fast restart without re-enabling interrupts */
> -	if(le16_to_cpu(rfd->command) & cb_el)
> +	/* If this buffer has the el bit, but we think the receiver
> +	 * is still running, check to see if it really stopped while
> +	 * we had interrupts off.
> +	 * This allows for a fast restart without re-enabling interrupts.
> +	 * This can happen when the RU sees the size change but also sees
> +	 * the el bit set. */
> +	if ((le16_to_cpu(rfd->command) & cb_el) &&
> +	    (RU_RUNNING == nic->ru_running)) {
> +
> +	    if (readb(&nic->csr->scb.status) & rus_no_res)
>  		nic->ru_running = RU_SUSPENDED;
> +	}
>  
>  	/* Pull off the RFD and put the actual data (minus eth hdr) */
>  	skb_reserve(skb, sizeof(struct rfd));
> @@ -1870,31 +1895,30 @@ static void e100_rx_clean(struct nic *nic, unsigned int *work_done,
>  	unsigned int work_to_do)
>  {
>  	struct rx *rx;
> -	int restart_required = 0;
> -	struct rx *rx_to_start = NULL;
> -
> -	/* are we already rnr? then pay attention!!! this ensures that
> -	 * the state machine progression never allows a start with a
> -	 * partially cleaned list, avoiding a race between hardware
> -	 * and rx_to_clean when in NAPI mode */
> -	if(RU_SUSPENDED == nic->ru_running)
> -		restart_required = 1;
> +	int restart_required = 0, err = 0;
> +	struct rx *old_before_last_rx, *new_before_last_rx;
> +	struct rfd *old_before_last_rfd, *new_before_last_rfd;
>  
>  	/* Indicate newly arrived packets */
>  	for(rx = nic->rx_to_clean; rx->skb; rx = nic->rx_to_clean = rx->next) {
> -		int err = e100_rx_indicate(nic, rx, work_done, work_to_do);
> -		if(-EAGAIN == err) {
> -			/* hit quota so have more work to do, restart once
> -			 * cleanup is complete */
> -			restart_required = 0;
> +		err = e100_rx_indicate(nic, rx, work_done, work_to_do);
> +		/* Hit quota or no more to clean */
> +		if (-EAGAIN == err || -ENODATA == err)
>  			break;
> -		} else if(-ENODATA == err)
> -			break; /* No more to clean */
>  	}
>  
> -	/* save our starting point as the place we'll restart the receiver */
> -	if(restart_required)
> -		rx_to_start = nic->rx_to_clean;
> +
> +	/* On EAGAIN, hit quota so have more work to do, restart once
> +	 * cleanup is complete.
> +	 * Else, are we already rnr? then pay attention!!! this ensures that
> +	 * the state machine progression never allows a start with a
> +	 * partially cleaned list, avoiding a race between hardware
> +	 * and rx_to_clean when in NAPI mode */
> +	if (-EAGAIN != err && RU_SUSPENDED == nic->ru_running)
> +		restart_required = 1;
> +
> +	old_before_last_rx = nic->rx_to_use->prev->prev;
> +	old_before_last_rfd = (struct rfd *)old_before_last_rx->skb->data;
>  
>  	/* Alloc new skbs to refill list */
>  	for(rx = nic->rx_to_use; !rx->skb; rx = nic->rx_to_use = rx->next) {
> @@ -1902,10 +1926,42 @@ static void e100_rx_clean(struct nic *nic, unsigned int *work_done,
>  			break; /* Better luck next time (see watchdog) */
>  	}
>  
> +	new_before_last_rx = nic->rx_to_use->prev->prev;
> +	if (new_before_last_rx != old_before_last_rx) {
> +		/* Set the el-bit on the buffer that is before the last buffer.
> +		 * This lets us update the next pointer on the last buffer
> +		 * without worrying about hardware touching it.
> +		 * We set the size to 0 to prevent hardware from touching this
> +		 * buffer.
> +		 * When the hardware hits the before last buffer with el-bit
> +		 * and size of 0, it will RNR interrupt, the RUS will go into
> +		 * the No Resources state.  It will not complete nor write to
> +		 * this buffer. */
> +		new_before_last_rfd =
> +			(struct rfd *)new_before_last_rx->skb->data;
> +		new_before_last_rfd->size = 0;
> +		new_before_last_rfd->command |= cpu_to_le16(cb_el);
> +		pci_dma_sync_single_for_device(nic->pdev,
> +			new_before_last_rx->dma_addr, sizeof(struct rfd),
> +			PCI_DMA_TODEVICE);
> +
> +		/* Now that we have a new stopping point, we can clear the old
> +		 * stopping point.  We must sync twice to get the proper
> +		 * ordering on the hardware side of things. */
> +		old_before_last_rfd->command &= ~cpu_to_le16(cb_el);
> +		pci_dma_sync_single_for_device(nic->pdev,
> +			old_before_last_rx->dma_addr, sizeof(struct rfd),
> +			PCI_DMA_TODEVICE);
> +		old_before_last_rfd->size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
> +		pci_dma_sync_single_for_device(nic->pdev,
> +			old_before_last_rx->dma_addr, sizeof(struct rfd),
> +			PCI_DMA_TODEVICE);
> +	}
> +
>  	if(restart_required) {
>  		// ack the rnr?
>  		writeb(stat_ack_rnr, &nic->csr->scb.stat_ack);
> -		e100_start_receiver(nic, rx_to_start);
> +		e100_start_receiver(nic, nic->rx_to_clean);
>  		if(work_done)
>  			(*work_done)++;
>  	}
> @@ -1937,6 +1993,7 @@ static int e100_rx_alloc_list(struct nic *nic)
>  {
>  	struct rx *rx;
>  	unsigned int i, count = nic->params.rfds.count;
> +	struct rfd *before_last;
>  
>  	nic->rx_to_use = nic->rx_to_clean = NULL;
>  	nic->ru_running = RU_UNINITIALIZED;
> @@ -1952,6 +2009,19 @@ static int e100_rx_alloc_list(struct nic *nic)
>  			return -ENOMEM;
>  		}
>  	}
> +	/* Set the el-bit on the buffer that is before the last buffer.
> +	 * This lets us update the next pointer on the last buffer without
> +	 * worrying about hardware touching it.
> +	 * We set the size to 0 to prevent hardware from touching this buffer.
> +	 * When the hardware hits the before last buffer with el-bit and size
> +	 * of 0, it will RNR interrupt, the RU will go into the No Resources
> +	 * state.  It will not complete nor write to this buffer. */
> +	rx = nic->rxs->prev->prev;
> +	before_last = (struct rfd *)rx->skb->data;
> +	before_last->command |= cpu_to_le16(cb_el);
> +	before_last->size = 0;
> +	pci_dma_sync_single_for_device(nic->pdev, rx->dma_addr,
> +		sizeof(struct rfd), PCI_DMA_TODEVICE);
>  
>  	nic->rx_to_use = nic->rx_to_clean = nic->rxs;
>  	nic->ru_running = RU_SUSPENDED;
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

