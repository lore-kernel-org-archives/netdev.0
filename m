From: Igor Gnatenko <i.gnatenko.brain@gmail.com>
Subject: Re: [REGRESSION][BISECTED] skge: add dma_mapping check
Date: Thu, 19 Sep 2013 12:18:52 +0400
Message-ID: <1379578732.2403.4.camel@ThinkPad-X230.localdomain>
References: <1379494844.2294.12.camel@ThinkPad-X230.localdomain>
	 <20130918220819.GA11989@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <mlindner@marvell.com>, linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	member graysky <graysky@archlinux.us>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130918220819.GA11989@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-09-19 at 00:08 +0200, Francois Romieu wrote:
> Igor Gnatenko <i.gnatenko.brain@gmail.com> :
> > Since 136d8f377e1575463b47840bc5f1b22d94bf8f63 commit we have kernel
> > panic on:
> > 01:05.0 Ethernet controller [0200]: Marvell Technology Group Ltd.
> > 
> > Screen: https://www.dropbox.com/s/mu3t3wxpxbn4ou5/IMAG0507.jpg
> > 
> > RHBZ: https://bugzilla.redhat.com/show_bug.cgi?id=1008323
> 
> Does the ugly stuff below against mainline make a difference ?
> 
> Note to testers: use a size argument above 500 for 'ping' to
> exercize the relevant code path.
Reported-and-tested-by: Vasiliy Glazov <vascom2@gmail.com>
Bisected-by: Igor Gnatenko <i.gnatenko.brain@gmail.com>
> 
> diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
> index ef94a59..aa85a3f 100644
> --- a/drivers/net/ethernet/marvell/skge.c
> +++ b/drivers/net/ethernet/marvell/skge.c
> @@ -3086,6 +3086,7 @@ static struct sk_buff *skge_rx_get(struct net_device *dev,
>  					       PCI_DMA_FROMDEVICE);
>  		skge_rx_reuse(e, skge->rx_buf_size);
>  	} else {
> +		struct skge_element ee = *e;
>  		struct sk_buff *nskb;
>  
>  		nskb = netdev_alloc_skb_ip_align(dev, skge->rx_buf_size);
> @@ -3098,10 +3099,10 @@ static struct sk_buff *skge_rx_get(struct net_device *dev,
>  		}
>  
>  		pci_unmap_single(skge->hw->pdev,
> -				 dma_unmap_addr(e, mapaddr),
> -				 dma_unmap_len(e, maplen),
> +				 dma_unmap_addr(&ee, mapaddr),
> +				 dma_unmap_len(&ee, maplen),
>  				 PCI_DMA_FROMDEVICE);
> -		skb = e->skb;
> +		skb = ee.skb;
>  		prefetch(skb->data);
>  	}
>  
Yes. This patch fixes problem. ping www.ru -s 500 works fine.


-- 
Igor Gnatenko
Fedora release 20 (Heisenbug)
Linux 3.11.1-300.fc20.x86_64
