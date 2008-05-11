From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [PATCH] Re: atl1 64-bit => 32-bit DMA borkage (reproducible,
 bisected)
Date: Sat, 10 May 2008 20:58:47 -0500
Message-ID: <20080510205847.425801c0@osprey.hogchain.net>
References: <20080420133704.63f5cc10@osprey.hogchain.net>
	<20080420205500.GA4762@martell.zuzino.mipt.ru>
	<20080421210821.28053a92@osprey.hogchain.net>
	<20080425195743.2bfe66ee@osprey.hogchain.net>
	<20080504211507.GC1040@martell.zuzino.mipt.ru>
	<20080506110225.31fd61a4@osprey.hogchain.net>
	<20080509195149.GA4985@martell.zuzino.mipt.ru>
	<48249E55.1020300@redhat.com>
	<20080509200715.GA5040@martell.zuzino.mipt.ru>
	<20080509143854.7bc39ab7@osprey.hogchain.net>
	<20080510193107.GA4930@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>,
	Luca Tettamanti <kronos.it@gmail.com>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([204.127.217.104]:41924 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752129AbYEKB6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2008 21:58:52 -0400
In-Reply-To: <20080510193107.GA4930@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 10 May 2008 23:31:07 +0400
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> On Fri, May 09, 2008 at 02:38:54PM -0500, Jay Cliburn wrote:

> > The bug appears to be a "simple" skb write-after-free that happens
> > only when bounce buffers are in use, but I'll be damned if I can
> > find the cause of it.
> > 
> > <continues looking>
> 
> Try this patch! If scared, remove swiotlb poisoning, I'm not entirely
> sure it's correct, but it makes aforementioned second oops
> deterministic.

Seems to fix it for me.  Nicely done, Alexey!  Thanks!

I looked at that blasted unmap a thousand times, but never noticed the
missing buffer_info->dma clear.

I'll get input from one more tester, and if it's positive, I'll submit
this to Jeff.

Thanks again.

> 
> --- a/drivers/net/atlx/atl1.c
> +++ b/drivers/net/atlx/atl1.c
> @@ -2027,6 +2029,7 @@ rrd_ok:
>  		/* Good Receive */
>  		pci_unmap_page(adapter->pdev, buffer_info->dma,
>  			       buffer_info->length,
> PCI_DMA_FROMDEVICE);
> +		buffer_info->dma = 0;
>  		skb = buffer_info->skb;
>  		length = le16_to_cpu(rrd->xsz.xsum_sz.pkt_size);
>  
> diff --git a/lib/swiotlb.c b/lib/swiotlb.c
> index d568894..f6165ed 100644
> --- a/lib/swiotlb.c
> +++ b/lib/swiotlb.c
> @@ -399,12 +399,14 @@ unmap_single(struct device *hwdev, char
> *dma_addr, size_t size, int dir) /*
>  	 * First, sync the memory before unmapping the entry
>  	 */
> -	if (buffer && ((dir == DMA_FROM_DEVICE) || (dir ==
> DMA_BIDIRECTIONAL)))
> +	if (buffer && ((dir == DMA_FROM_DEVICE) || (dir ==
> DMA_BIDIRECTIONAL))) { /*
>  		 * bounce... copy the data back into the original
> buffer * and
>  		 * delete the bounce buffer.
>  		 */
>  		memcpy(buffer, dma_addr, size);
> +		io_tlb_orig_addr[index] = (void
> *)0x9a9a9a9a9a9a9a9aUL;
> +	}
>  
>  	/*
>  	 * Return the buffer to the free list by setting the
> corresponding
> 
