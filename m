From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] [PATCH] net: sxgbe: Fix waring for double kfree()
Date: Thu, 15 Jan 2015 11:12:39 +0300
Message-ID: <20150115081239.GE5520@mwanda>
References: <1421286191-9550-1-git-send-email-kgene@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dave Miller <davem@davemloft.ne>,
	Byungho An <bh74.an@samsung.com>
To: Kukjin Kim <kgene@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:16680 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636AbbAOINA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 03:13:00 -0500
Content-Disposition: inline
In-Reply-To: <1421286191-9550-1-git-send-email-kgene@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2015 at 10:43:11AM +0900, Kukjin Kim wrote:
>  	rx_ring->rx_skbuff = kmalloc_array(rx_rsize,
>  					   sizeof(struct sk_buff *), GFP_KERNEL);
> -	if (rx_ring->rx_skbuff == NULL)
> -		goto rxbuff_err;
> +	if (!rx_ring->rx_skbuff) {

This is missing a dma_free_coherent() here.

> +		kfree(rx_ring->rx_skbuff_dma);
> +		goto error;
> +	}
>  
>  	/* initialise the buffers */
>  	for (desc_index = 0; desc_index < rx_rsize; desc_index++) {
> @@ -502,13 +508,6 @@ static int init_rx_ring(struct net_device *dev, u8 queue_no,
>  err_init_rx_buffers:
>  	while (--desc_index >= 0)
>  		free_rx_ring(priv->device, rx_ring, desc_index);
> -	kfree(rx_ring->rx_skbuff);

The double free bug is that free_rx_ring() frees
kfree(rx_ring->rx_skbuff_dma); and kfree(rx_ring->rx_skbuff); so just
calling it in a loop here will cause a double free.

Also free_rx_ring() doesn't take an index parameter, it takes a size
parameter.

The right way to fix this is to create a release function that mirrors
sxgbe_init_rx_buffers().

static void sxgbe_free_rx_buffers(struct net_device *dev,
                                  struct sxgbe_rx_norm_desc *p, int i,
                                  unsigned int dma_buf_sz,
                                  struct sxgbe_rx_queue *rx_ring)
{
        struct sxgbe_priv_data *priv = netdev_priv(dev);

        kfree_skb(rx_ring->rx_skbuff[i]);
        dma_unmap_single(priv->device, rx_ring->rx_skbuff_dma[i],
                         dma_buf_sz, DMA_FROM_DEVICE);
}

Then just swap that into the free loop instead of the free_rx_ring().

err_init_rx_buffers:
	while (--desc_index >= 0) {
		struct sxgbe_rx_norm_desc *p;

		p = rx_ring->dma_rx + desc_index;
		sxgbe_init_rx_buffers(dev, p, desc_index, bfsize, rx_ring);
	}
	kfree(rx_ring->rx_skbuff);

Something like that.

regards,
dan carpenter
