From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: ixgbe: Set IXGBE_RSC_CB(skb)->DMA field to zero after
 unmapping the address
Date: Tue, 23 Mar 2010 14:57:50 +1100
Message-ID: <1269316670.8599.101.camel@pasglop>
References: <201003221759.o2MHxEaj015546@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201003221759.o2MHxEaj015546@hera.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-03-22 at 17:59 +0000, Linux Kernel Mailing List wrote:
> Gitweb:     http://git.kernel.org/linus/fd3686a842717b890fbe3024b83a616c54d5dba0
> Commit:     fd3686a842717b890fbe3024b83a616c54d5dba0
> Parent:     936332b8e00103fc20eb7e915c9a3bcb2835a11a
> Author:     Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> AuthorDate: Fri Mar 19 04:41:33 2010 +0000
> Committer:  David S. Miller <davem@davemloft.net>
> CommitDate: Fri Mar 19 21:00:44 2010 -0700
> 
>     ixgbe: Set IXGBE_RSC_CB(skb)->DMA field to zero after unmapping the address
>     
>     As per Simon Horman's feedback set IXGBE_RSC_CB(skb)->dma to zero
>     after unmapping HWRSC DMA address to avoid double freeing.
>    

Note that this whole code is bogus :-) You cannot just assume that 0 is
a invalid DMA address. It is not. In fact, while you can check if a
dma_addr_t is invalid using dma_mapping_error(), the generic APIs
don't provide you with a magic "bad" value you can use for what you are
trying to do.

Granted, I think we should make our iommu code reserve the first page
for the sake of everybody's sanity and to avoid such pitfalls, but
this code is wrong with today iommu implementations.

Cheers,
Ben.

>     Signed-off-by:  Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
>     Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/ixgbe/ixgbe_main.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index 18b5b21..d75c46f 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -935,10 +935,12 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>  			if (skb->prev)
>  				skb = ixgbe_transform_rsc_queue(skb, &(rx_ring->rsc_count));
>  			if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
> -				if (IXGBE_RSC_CB(skb)->dma)
> +				if (IXGBE_RSC_CB(skb)->dma) {
>  					pci_unmap_single(pdev, IXGBE_RSC_CB(skb)->dma,
>  					                 rx_ring->rx_buf_len,
>  					                 PCI_DMA_FROMDEVICE);
> +					IXGBE_RSC_CB(skb)->dma = 0;
> +				}
>  				if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED)
>  					rx_ring->rsc_count += skb_shinfo(skb)->nr_frags;
>  				else
> @@ -3126,10 +3128,12 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
>  			rx_buffer_info->skb = NULL;
>  			do {
>  				struct sk_buff *this = skb;
> -				if (IXGBE_RSC_CB(this)->dma)
> +				if (IXGBE_RSC_CB(this)->dma) {
>  					pci_unmap_single(pdev, IXGBE_RSC_CB(this)->dma,
>  					                 rx_ring->rx_buf_len,
>  					                 PCI_DMA_FROMDEVICE);
> +					IXGBE_RSC_CB(this)->dma = 0;
> +				}
>  				skb = skb->prev;
>  				dev_kfree_skb(this);
>  			} while (skb);
> --
> To unsubscribe from this list: send the line "unsubscribe git-commits-head" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
