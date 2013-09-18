From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [REGRESSION][BISECTED] skge: add dma_mapping check
Date: Wed, 18 Sep 2013 16:22:27 +0100
Message-ID: <1379517747.1522.9.camel@bwh-desktop.uk.level5networks.com>
References: <1379494844.2294.12.camel@ThinkPad-X230.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <mlindner@marvell.com>,
	<linux-kernel@vger.kernel.org>,
	Igor Gnatenko <i.gnatenko.brain@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379494844.2294.12.camel@ThinkPad-X230.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-09-18 at 13:00 +0400, Igor Gnatenko wrote:
> Since 136d8f377e1575463b47840bc5f1b22d94bf8f63 commit we have kernel
> panic on:
[...]

At a first glance, it looks like this bit is wrong:

> @@ -3058,13 +3090,17 @@ static struct sk_buff *skge_rx_get(struct net_device *dev,
>  		if (!nskb)
>  			goto resubmit;
>  
> +		if (skge_rx_setup(skge, e, nskb, skge->rx_buf_size) < 0) {
> +			dev_kfree_skb(nskb);
> +			goto resubmit;
> +		}
> +
>  		pci_unmap_single(skge->hw->pdev,
>  				 dma_unmap_addr(e, mapaddr),
>  				 dma_unmap_len(e, maplen),
>  				 PCI_DMA_FROMDEVICE);
>  		skb = e->skb;
>  		prefetch(skb->data);
> -		skge_rx_setup(skge, e, nskb, skge->rx_buf_size);
>  	}
>  
>  	skb_put(skb, len);

That pci_unmap_single() appears to unmap the *new*, rather than old, DMA
mapping.  I think you need to copy out the old DMA address and length
before doing skge_rx_setup().

Try it with an IOMMU in strict mode (intel_iommu=on,strict or
amd_iommu=fullflush).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
