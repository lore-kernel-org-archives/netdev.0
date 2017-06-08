From: Robin Murphy <robin.murphy-5wv7dgnIgG8@public.gmane.org>
Subject: Re: [PATCH 06/44] iommu/dma: don't rely on DMA_ERROR_CODE
Date: Thu, 8 Jun 2017 14:59:07 +0100
Message-ID: <0bfb0841-f054-78de-628d-a0955336bcb4@arm.com>
References: <20170608132609.32662-1-hch@lst.de>
	<20170608132609.32662-7-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org,
	linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	openrisc-cunTk1MwBs9a3B2Vnqf2dGD2FQJk+8+b@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org,
	dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170608132609.32662-7-hch-jcswGhMUV9g@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Christoph,

On 08/06/17 14:25, Christoph Hellwig wrote:
> DMA_ERROR_CODE is not a public API and will go away soon.  dma dma-iommu
> driver already implements a proper ->mapping_error method, so it's only
> using the value internally.  Add a new local define using the value
> that arm64 which is the only current user of dma-iommu.

It would be fine to just use 0, since dma-iommu already makes sure that
that will never be allocated for a valid DMA address.

Otherwise, looks good!

Robin.

> Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
> ---
>  drivers/iommu/dma-iommu.c | 18 ++++++++++--------
>  1 file changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
> index 62618e77bedc..638aea814b94 100644
> --- a/drivers/iommu/dma-iommu.c
> +++ b/drivers/iommu/dma-iommu.c
> @@ -31,6 +31,8 @@
>  #include <linux/scatterlist.h>
>  #include <linux/vmalloc.h>
>  
> +#define IOMMU_MAPPING_ERROR	(~(dma_addr_t)0)
> +
>  struct iommu_dma_msi_page {
>  	struct list_head	list;
>  	dma_addr_t		iova;
> @@ -500,7 +502,7 @@ void iommu_dma_free(struct device *dev, struct page **pages, size_t size,
>  {
>  	__iommu_dma_unmap(iommu_get_domain_for_dev(dev), *handle, size);
>  	__iommu_dma_free_pages(pages, PAGE_ALIGN(size) >> PAGE_SHIFT);
> -	*handle = DMA_ERROR_CODE;
> +	*handle = IOMMU_MAPPING_ERROR;
>  }
>  
>  /**
> @@ -533,7 +535,7 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
>  	dma_addr_t iova;
>  	unsigned int count, min_size, alloc_sizes = domain->pgsize_bitmap;
>  
> -	*handle = DMA_ERROR_CODE;
> +	*handle = IOMMU_MAPPING_ERROR;
>  
>  	min_size = alloc_sizes & -alloc_sizes;
>  	if (min_size < PAGE_SIZE) {
> @@ -627,11 +629,11 @@ static dma_addr_t __iommu_dma_map(struct device *dev, phys_addr_t phys,
>  
>  	iova = iommu_dma_alloc_iova(domain, size, dma_get_mask(dev), dev);
>  	if (!iova)
> -		return DMA_ERROR_CODE;
> +		return IOMMU_MAPPING_ERROR;
>  
>  	if (iommu_map(domain, iova, phys - iova_off, size, prot)) {
>  		iommu_dma_free_iova(cookie, iova, size);
> -		return DMA_ERROR_CODE;
> +		return IOMMU_MAPPING_ERROR;
>  	}
>  	return iova + iova_off;
>  }
> @@ -671,7 +673,7 @@ static int __finalise_sg(struct device *dev, struct scatterlist *sg, int nents,
>  
>  		s->offset += s_iova_off;
>  		s->length = s_length;
> -		sg_dma_address(s) = DMA_ERROR_CODE;
> +		sg_dma_address(s) = IOMMU_MAPPING_ERROR;
>  		sg_dma_len(s) = 0;
>  
>  		/*
> @@ -714,11 +716,11 @@ static void __invalidate_sg(struct scatterlist *sg, int nents)
>  	int i;
>  
>  	for_each_sg(sg, s, nents, i) {
> -		if (sg_dma_address(s) != DMA_ERROR_CODE)
> +		if (sg_dma_address(s) != IOMMU_MAPPING_ERROR)
>  			s->offset += sg_dma_address(s);
>  		if (sg_dma_len(s))
>  			s->length = sg_dma_len(s);
> -		sg_dma_address(s) = DMA_ERROR_CODE;
> +		sg_dma_address(s) = IOMMU_MAPPING_ERROR;
>  		sg_dma_len(s) = 0;
>  	}
>  }
> @@ -836,7 +838,7 @@ void iommu_dma_unmap_resource(struct device *dev, dma_addr_t handle,
>  
>  int iommu_dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
>  {
> -	return dma_addr == DMA_ERROR_CODE;
> +	return dma_addr == IOMMU_MAPPING_ERROR;
>  }
>  
>  static struct iommu_dma_msi_page *iommu_dma_get_msi_page(struct device *dev,
> 
