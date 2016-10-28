From: Mark Salter <msalter@redhat.com>
Subject: Re: [net-next PATCH RFC 07/26] arch/c6x: Add option to skip sync on
 DMA map and unmap
Date: Fri, 28 Oct 2016 10:59:00 -0400
Message-ID: <1477666740.31844.9.camel@redhat.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
         <20161024120503.16276.44357.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: brouer@redhat.com, davem@davemloft.net,
        linux-c6x-dev@linux-c6x.org, Aurelien Jacquiot <a-jacquiot@ti.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59730 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S937878AbcJ1O7C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 10:59:02 -0400
In-Reply-To: <20161024120503.16276.44357.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-10-24 at 08:05 -0400, Alexander Duyck wrote:
> This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
> avoid invoking cache line invalidation if the driver will just handle it
> later via a sync_for_cpu or sync_for_device call.
> 
> Cc: Mark Salter <msalter@redhat.com>
> Cc: Aurelien Jacquiot <a-jacquiot@ti.com>
> Cc: linux-c6x-dev@linux-c6x.org
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---

Acked-by: Mark Salter <msalter@redhat.com>

>  arch/c6x/kernel/dma.c |   16 +++++++++++-----
>  1 file changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/c6x/kernel/dma.c b/arch/c6x/kernel/dma.c
> index db4a6a3..d28df74 100644
> --- a/arch/c6x/kernel/dma.c
> +++ b/arch/c6x/kernel/dma.c
> @@ -42,14 +42,17 @@ static dma_addr_t c6x_dma_map_page(struct device *dev, struct page *page,
>  {
>  	dma_addr_t handle = virt_to_phys(page_address(page) + offset);
>  
> -	c6x_dma_sync(handle, size, dir);
> +	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
> +		c6x_dma_sync(handle, size, dir);
> +
>  	return handle;
>  }
>  
>  static void c6x_dma_unmap_page(struct device *dev, dma_addr_t handle,
>  		size_t size, enum dma_data_direction dir, unsigned long attrs)
>  {
> -	c6x_dma_sync(handle, size, dir);
> +	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
> +		c6x_dma_sync(handle, size, dir);
>  }
>  
>  static int c6x_dma_map_sg(struct device *dev, struct scatterlist *sglist,
> @@ -60,7 +63,8 @@ static int c6x_dma_map_sg(struct device *dev, struct scatterlist *sglist,
>  
>  	for_each_sg(sglist, sg, nents, i) {
>  		sg->dma_address = sg_phys(sg);
> -		c6x_dma_sync(sg->dma_address, sg->length, dir);
> +		if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
> +			c6x_dma_sync(sg->dma_address, sg->length, dir);
>  	}
>  
>  	return nents;
> @@ -72,8 +76,10 @@ static void c6x_dma_unmap_sg(struct device *dev, struct scatterlist *sglist,
>  	struct scatterlist *sg;
>  	int i;
>  
> -	for_each_sg(sglist, sg, nents, i)
> -		c6x_dma_sync(sg_dma_address(sg), sg->length, dir);
> +	for_each_sg(sglist, sg, nents, i) {
> +		if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
> +			c6x_dma_sync(sg_dma_address(sg), sg->length, dir);
> +	}
>  
>  }
>  
> 
