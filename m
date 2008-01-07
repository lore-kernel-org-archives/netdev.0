From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] via-velocity big-endian support
Date: Tue, 8 Jan 2008 00:18:59 +0100
Message-ID: <20080107231859.GA3450@electric-eye.fr.zoreil.com>
References: <20071224050659.GS8181@ftp.linux.org.uk> <20071225224333.GA21585@electric-eye.fr.zoreil.com> <20071225225606.GC27894@ZenIV.linux.org.uk> <20071225232135.GA22589@electric-eye.fr.zoreil.com> <20071228184008.GN27894@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, linux@horizon.com,
	Brian Hall <brihall@pcisys.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jay Cliburn <jacliburn@bellsouth.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59823 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756733AbYAGXb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 18:31:59 -0500
Content-Disposition: inline
In-Reply-To: <20071228184008.GN27894@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro <viro@ZenIV.linux.org.uk> :
[...]
> Point taken...
> 
> * kill multibyte bitfields
> * annotate
> * add missing conversions
> * fix a couple of brainos in zerocopy stuff (fortunately, it's ifdef'ed out)
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Thanks a lot. After the usual xmas delay, split and review, it is
available at:

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git velocity

I have shortened the end-of-line comments associated with several #define
but the end result is otherwise the same.

Remarks for the random reader below.

> ---
>  drivers/net/via-velocity.c |   62 ++++++-------
>  drivers/net/via-velocity.h |  220 +++++++++++++++++++-------------------------
>  2 files changed, 125 insertions(+), 157 deletions(-)
> 
> diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
> index 35cd65d..3842516 100644
> --- a/drivers/net/via-velocity.c
> +++ b/drivers/net/via-velocity.c
[...]
> @@ -777,7 +776,7 @@ static void velocity_init_registers(struct velocity_info *vptr,
>  
>  		vptr->int_mask = INT_MASK_DEF;
>  
> -		writel(cpu_to_le32(vptr->rd_pool_dma), &regs->RDBaseLo);
> +		writel(vptr->rd_pool_dma, &regs->RDBaseLo);
>  		writew(vptr->options.numrx - 1, &regs->RDCSize);
>  		mac_rx_queue_run(regs);
>  		mac_rx_queue_wake(regs);

The cpu_to_le32 was probably wrong in the first place.

[...]
> @@ -785,7 +784,7 @@ static void velocity_init_registers(struct velocity_info *vptr,
>  		writew(vptr->options.numtx - 1, &regs->TDCSize);
>  
>  		for (i = 0; i < vptr->num_txq; i++) {
> -			writel(cpu_to_le32(vptr->td_pool_dma[i]), &(regs->TDBaseLo[i]));
> +			writel(vptr->td_pool_dma[i], &regs->TDBaseLo[i]);
>  			mac_tx_queue_run(regs, i);
>  		}
>  

Same thing.

[...]
> @@ -1421,7 +1420,7 @@ static int velocity_rx_srv(struct velocity_info *vptr, int status)
>  		/*
>  		 *	Don't drop CE or RL error frame although RXOK is off
>  		 */
> -		if ((rd->rdesc0.RSR & RSR_RXOK) || (!(rd->rdesc0.RSR & RSR_RXOK) && (rd->rdesc0.RSR & (RSR_CE | RSR_RL)))) {
> +		if (rd->rdesc0.RSR & (RSR_RXOK | RSR_CE | RSR_RL)) {
>  			if (velocity_receive_frame(vptr, rd_curr) < 0)
>  				stats->rx_dropped++;
>  		} else {

This one was fun.

[...]
> @@ -2122,22 +2121,23 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
>  			tdinfo->nskb_dma = 0;
>  			tdinfo->skb_dma[i] = pci_map_single(vptr->pdev, skb->data, skb->len - skb->data_len, PCI_DMA_TODEVICE);
>  
> -			td_ptr->tdesc0.pktsize = pktlen;
> +			td_ptr->tdesc0.len = len;
>  
>  			/* FIXME: support 48bit DMA later */
>  			td_ptr->td_buf[i].pa_low = cpu_to_le32(tdinfo->skb_dma);
>  			td_ptr->td_buf[i].pa_high = 0;
> -			td_ptr->td_buf[i].bufsize = skb->len->skb->data_len;
> +			td_ptr->td_buf[i].size =
> +				cpu_to_le16(skb->len->skb->data_len);

skb->len->skb->data_len...

Still a bit broken but it is endian clean now. Fine.

-- 
Ueimor
