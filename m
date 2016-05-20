From: Feng Tang <feng.tang@intel.com>
Subject: Re: [PATCH] net: alx: use custom skb allocator
Date: Fri, 20 May 2016 15:56:23 +0800
Message-ID: <20160520075623.GA14140@shbuild888>
References: <1463722863-31241-1-git-send-email-feng.tang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarod Wilson <jarod@redhat.com>
To: "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1463722863-31241-1-git-send-email-feng.tang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Please ignore this patch. 

I found the problem and made the patch with kernel 4.4 with Ubuntu 12.04
on Lenovo Y580. 

After submitting the patch, I tried to google the datasheet for
Atheros 8161 dev, and found there was already a kernel bugzilla 
https://bugzilla.kernel.org/show_bug.cgi?id=70761
that had a fix from Jarod Wilson which get merged in v4.5 (commit c406700cd) 

Per my test, the new 4.6.0 kernel works fine with Jarod's patch. 

Thanks,
Feng

On Fri, May 20, 2016 at 01:41:03PM +0800, Feng Tang wrote:
> This patch follows Eric Dumazet's commit 7b70176421 to fix one
> exactly same bug in alx driver, that the network link will
> be lost in 1-5 minutes after the device is up.
> 
> Following is a git log from Eric's 7b70176421:
> 
> "We had reports ( https://bugzilla.kernel.org/show_bug.cgi?id=54021 )
> that using high order pages for skb allocations is problematic for atl1c
> 
> We do not know exactly what the problem is, but we suspect that crossing
> 4K pages is not well supported by this hardware.
> 
> Use a custom allocator, using page allocator and 2K fragments for
> optimal stack behavior. We might make this allocator generic
>  in future kernels."
> 
> And my debug shows the same suspect, most of the errors happen
> when there is a RX buffer address with 0x......f80, hopefully
> this will get noticed and fixed from silicon side.
> 
> My victim is a Lenovo Y580 Laptop with Atheros ALX AR8161 etherenet
> device(PCI ID 1969:1091), with this patch the ethernet dev
> works just fine
> 
> Signed-off-by: Feng Tang <feng.tang@intel.com>
> ---
>  drivers/net/ethernet/atheros/alx/alx.h  |  4 +++
>  drivers/net/ethernet/atheros/alx/main.c | 48 ++++++++++++++++++++++++++++++++-
>  2 files changed, 51 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/atheros/alx/alx.h b/drivers/net/ethernet/atheros/alx/alx.h
> index 8fc93c5..d02c424 100644
> --- a/drivers/net/ethernet/atheros/alx/alx.h
> +++ b/drivers/net/ethernet/atheros/alx/alx.h
> @@ -96,6 +96,10 @@ struct alx_priv {
>  	unsigned int rx_ringsz;
>  	unsigned int rxbuf_size;
>  
> +	struct page  *rx_page;
> +	unsigned int rx_page_offset;
> +	unsigned int rx_frag_size;
> +
>  	struct napi_struct napi;
>  	struct alx_tx_queue txq;
>  	struct alx_rx_queue rxq;
> diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
> index 9fe8b5e..c98acdc 100644
> --- a/drivers/net/ethernet/atheros/alx/main.c
> +++ b/drivers/net/ethernet/atheros/alx/main.c
> @@ -70,6 +70,35 @@ static void alx_free_txbuf(struct alx_priv *alx, int entry)
>  	}
>  }
>  
> +static struct sk_buff *alx_alloc_skb(struct alx_priv *alx, gfp_t gfp)
> +{
> +	struct sk_buff *skb;
> +	struct page *page;
> +
> +	if (alx->rx_frag_size > PAGE_SIZE)
> +		return __netdev_alloc_skb(alx->dev, alx->rxbuf_size, gfp);
> +
> +	page = alx->rx_page;
> +	if (!page) {
> +		alx->rx_page = page = alloc_page(gfp);
> +		if (unlikely(!page))
> +			return NULL;
> +		alx->rx_page_offset = 0;
> +	}
> +
> +	skb = build_skb(page_address(page) + alx->rx_page_offset,
> +			alx->rx_frag_size);
> +	if (likely(skb)) {
> +		alx->rx_page_offset += alx->rx_frag_size;
> +		if (alx->rx_page_offset >= PAGE_SIZE)
> +			alx->rx_page = NULL;
> +		else
> +			get_page(page);
> +	}
> +	return skb;
> +}
> +
> +
>  static int alx_refill_rx_ring(struct alx_priv *alx, gfp_t gfp)
>  {
>  	struct alx_rx_queue *rxq = &alx->rxq;
> @@ -86,7 +115,7 @@ static int alx_refill_rx_ring(struct alx_priv *alx, gfp_t gfp)
>  	while (!cur_buf->skb && next != rxq->read_idx) {
>  		struct alx_rfd *rfd = &rxq->rfd[cur];
>  
> -		skb = __netdev_alloc_skb(alx->dev, alx->rxbuf_size, gfp);
> +		skb = alx_alloc_skb(alx, gfp);
>  		if (!skb)
>  			break;
>  		dma = dma_map_single(&alx->hw.pdev->dev,
> @@ -124,6 +153,7 @@ static int alx_refill_rx_ring(struct alx_priv *alx, gfp_t gfp)
>  		alx_write_mem16(&alx->hw, ALX_RFD_PIDX, cur);
>  	}
>  
> +
>  	return count;
>  }
>  
> @@ -592,6 +622,11 @@ static void alx_free_rings(struct alx_priv *alx)
>  	kfree(alx->txq.bufs);
>  	kfree(alx->rxq.bufs);
>  
> +	if (alx->rx_page) {
> +		put_page(alx->rx_page);
> +		alx->rx_page = NULL;
> +	}
> +
>  	dma_free_coherent(&alx->hw.pdev->dev,
>  			  alx->descmem.size,
>  			  alx->descmem.virt,
> @@ -646,6 +681,7 @@ static int alx_request_irq(struct alx_priv *alx)
>  				  alx->dev->name, alx);
>  		if (!err)
>  			goto out;
> +
>  		/* fall back to legacy interrupt */
>  		pci_disable_msi(alx->hw.pdev);
>  	}
> @@ -689,6 +725,7 @@ static int alx_init_sw(struct alx_priv *alx)
>  	struct pci_dev *pdev = alx->hw.pdev;
>  	struct alx_hw *hw = &alx->hw;
>  	int err;
> +	unsigned int head_size;
>  
>  	err = alx_identify_hw(alx);
>  	if (err) {
> @@ -704,7 +741,12 @@ static int alx_init_sw(struct alx_priv *alx)
>  
>  	hw->smb_timer = 400;
>  	hw->mtu = alx->dev->mtu;
> +
>  	alx->rxbuf_size = ALX_MAX_FRAME_LEN(hw->mtu);
> +	head_size = SKB_DATA_ALIGN(alx->rxbuf_size + NET_SKB_PAD) +
> +		    SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> +	alx->rx_frag_size = roundup_pow_of_two(head_size);
> +
>  	alx->tx_ringsz = 256;
>  	alx->rx_ringsz = 512;
>  	hw->imt = 200;
> @@ -806,6 +848,7 @@ static int alx_change_mtu(struct net_device *netdev, int mtu)
>  {
>  	struct alx_priv *alx = netdev_priv(netdev);
>  	int max_frame = ALX_MAX_FRAME_LEN(mtu);
> +	unsigned int head_size;
>  
>  	if ((max_frame < ALX_MIN_FRAME_SIZE) ||
>  	    (max_frame > ALX_MAX_FRAME_SIZE))
> @@ -817,6 +860,9 @@ static int alx_change_mtu(struct net_device *netdev, int mtu)
>  	netdev->mtu = mtu;
>  	alx->hw.mtu = mtu;
>  	alx->rxbuf_size = max(max_frame, ALX_DEF_RXBUF_SIZE);
> +	head_size = SKB_DATA_ALIGN(alx->rxbuf_size + NET_SKB_PAD) +
> +		    SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> +	alx->rx_frag_size = roundup_pow_of_two(head_size);
>  	netdev_update_features(netdev);
>  	if (netif_running(netdev))
>  		alx_reinit(alx);
> -- 
> 2.5.0
