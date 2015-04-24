From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH v2] bnx2x: Alloc 4k fragment for each rx ring buffer element
Date: Sat, 25 Apr 2015 01:24:07 +0200
Message-ID: <553AD097.4020209@gmx.de>
References: <1429908351-12262-1-git-send-email-krisman@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cascardo@linux.vnet.ibm.com,
	cascardo@cascardo.eti.br, brking@linux.vnet.ibm.com
To: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>,
	ariel.elior@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:61672 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932372AbbDXXYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2015 19:24:15 -0400
In-Reply-To: <1429908351-12262-1-git-send-email-krisman@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 24.04.2015 22:45, Gabriel Krisman Bertazi wrote:
> @@ -544,30 +544,52 @@ static void bnx2x_set_gro_params(struct sk_buff *skb, u16 parsing_flags,
>  static int bnx2x_alloc_rx_sge(struct bnx2x *bp, struct bnx2x_fastpath *fp,
>  			      u16 index, gfp_t gfp_mask)
>  {
> -	struct page *page = alloc_pages(gfp_mask, PAGES_PER_SGE_SHIFT);
>  	struct sw_rx_page *sw_buf = &fp->rx_page_ring[index];
>  	struct eth_rx_sge *sge = &fp->rx_sge_ring[index];
> +	struct bnx2x_alloc_pool *pool = &fp->page_pool;
>  	dma_addr_t mapping;
>  
> -	if (unlikely(page == NULL)) {
> -		BNX2X_ERR("Can't alloc sge\n");
> -		return -ENOMEM;
> -	}
> +	if (!pool->page || pool->offset > pool->last_offset) {
>  
> -	mapping = dma_map_page(&bp->pdev->dev, page, 0,
> -			       SGE_PAGES, DMA_FROM_DEVICE);
> -	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
> -		__free_pages(page, PAGES_PER_SGE_SHIFT);
> -		BNX2X_ERR("Can't map sge\n");
> -		return -ENOMEM;
> +		/* put page reference used by the memory pool, since we
> +		 * won't be using this page as the mempool anymore.
> +		 */
> +		if (pool->page)
> +			put_page(pool->page);
> +
> +		pool->page = alloc_pages(gfp_mask, PAGES_PER_SGE_SHIFT);
> +		if (unlikely(!pool->page)) {
> +			BNX2X_ERR("Can't alloc sge\n");
> +			return -ENOMEM;
> +		}
> +
> +		pool->dma = dma_map_page(&bp->pdev->dev, pool->page, 0,
> +					 PAGE_SIZE, DMA_FROM_DEVICE);
> +		if (unlikely(dma_mapping_error(&bp->pdev->dev,
> +					       pool->dma))) {
> +			__free_pages(pool->page, PAGES_PER_SGE_SHIFT);
> +			BNX2X_ERR("Can't map sge\n");
> +			return -ENOMEM;

Looks like setting pool->page to NULL is missing in case that dma
mapping failed. Otherwise put_page is called on the freed page the next
time bnx2x_alloc_rx_sge is called.

Regards,
Lino
