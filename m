From: Eli Cohen <eli@mellanox.com>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Mon, 18 Apr 2016 09:54:47 +0300
Message-ID: <20160418065447.GA11539@x-vnc01.mtx.labs.mlnx>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-rdma@vger.kernel.org, timur@codeaurora.org,
	cov@codeaurora.org, Yishai Hadas <yishaih@mellanox.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sinan Kaya <okaya@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:49983 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751422AbcDRGzc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2016 02:55:32 -0400
Content-Disposition: inline
In-Reply-To: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sinan,

if we get rid of the part this code:

                if (BITS_PER_LONG == 64) {
                        struct page **pages;
                        pages = kmalloc(sizeof *pages * buf->nbufs, gfp);
                        if (!pages)
                                goto err_free;
                        ...
                        ...
                        if (!buf->direct.buf)
                                goto err_free;
                }

Does that solve the arm issue?

The other parts of the driver using the allocated buffer can still
work with list of coherent chunks.

On Sat, Apr 16, 2016 at 06:23:32PM -0400, Sinan Kaya wrote:
> Current code is assuming that the address returned by dma_alloc_coherent
> is a logical address. This is not true on ARM/ARM64 systems. This patch
> replaces dma_alloc_coherent with dma_map_page API. The address returned
> can later by virtually mapped from the CPU side with vmap API.
> 
> Signed-off-by: Sinan Kaya <okaya@codeaurora.org>
> ---
>  drivers/net/ethernet/mellanox/mlx4/alloc.c | 37 ++++++++++++++++++++++--------
>  1 file changed, 27 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/alloc.c b/drivers/net/ethernet/mellanox/mlx4/alloc.c
> index 0c51c69..22a7ae7 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/alloc.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/alloc.c
> @@ -618,13 +618,26 @@ int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
>  			return -ENOMEM;
>  
>  		for (i = 0; i < buf->nbufs; ++i) {
> -			buf->page_list[i].buf =
> -				dma_alloc_coherent(&dev->persist->pdev->dev,
> -						   PAGE_SIZE,
> -						   &t, gfp);
> -			if (!buf->page_list[i].buf)
> +			struct page *page;
> +
> +			page = alloc_page(GFP_KERNEL);
> +			if (!page)
>  				goto err_free;
>  
> +			t = dma_map_page(&dev->persist->pdev->dev, page, 0,
> +					 PAGE_SIZE, DMA_BIDIRECTIONAL);
> +
> +			if (dma_mapping_error(&dev->persist->pdev->dev, t)) {
> +				__free_page(page);
> +				goto err_free;
> +			}
> +
> +			buf->page_list[i].buf = page_address(page);
> +			if (!buf->page_list[i].buf) {
> +				__free_page(page);
> +				goto err_free;
> +			}
> +
>  			buf->page_list[i].map = t;
>  
>  			memset(buf->page_list[i].buf, 0, PAGE_SIZE);
> @@ -666,11 +679,15 @@ void mlx4_buf_free(struct mlx4_dev *dev, int size, struct mlx4_buf *buf)
>  			vunmap(buf->direct.buf);
>  
>  		for (i = 0; i < buf->nbufs; ++i)
> -			if (buf->page_list[i].buf)
> -				dma_free_coherent(&dev->persist->pdev->dev,
> -						  PAGE_SIZE,
> -						  buf->page_list[i].buf,
> -						  buf->page_list[i].map);
> +			if (buf->page_list[i].buf) {
> +				struct page *page;
> +
> +				page = virt_to_page(buf->page_list[i].buf);
> +				dma_unmap_page(&dev->persist->pdev->dev,
> +					       buf->page_list[i].map,
> +					       PAGE_SIZE, DMA_BIDIRECTIONAL);
> +				__free_page(page);
> +			}
>  		kfree(buf->page_list);
>  	}
>  }
> -- 
> 1.8.2.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
