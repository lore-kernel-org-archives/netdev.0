From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 03/11] net/mlx5_core: Virtually extend
 work/completion queue buffers by one page
Date: Wed, 08 Apr 2015 12:25:20 -0400 (EDT)
Message-ID: <20150408.122520.1452310225826617365.davem@davemloft.net>
References: <1428504685-8945-1-git-send-email-amirv@mellanox.com>
	<1428504685-8945-4-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com, saeedm@mellanox.com,
	ogerlitz@mellanox.com, achiad@mellanox.com, idos@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753364AbbDHQZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 12:25:22 -0400
In-Reply-To: <1428504685-8945-4-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Wed,  8 Apr 2015 17:51:17 +0300

> +	for (i = 0; i < buf->nbufs; i++) {
> +		buf->page_list[i].buf =
> +			dma_zalloc_coherent(&dev->pdev->dev, PAGE_SIZE,
> +					    &t, GFP_KERNEL);
> +		if (!buf->page_list[i].buf)
> +			goto err_free;
> +
> +		buf->page_list[i].map = t;
> +	}
> +
> +	if (BITS_PER_LONG == 64) {
> +		struct page **pages;
> +		int npages = buf->nbufs + (virtual_extension ? 1 : 0);
> +
> +		pages = kcalloc(npages, sizeof(*pages), GFP_KERNEL);
> +		if (!pages)
> +			goto err_free;
> +
> +		for (i = 0; i < buf->nbufs; i++)
> +			pages[i] = virt_to_page(buf->page_list[i].buf);
> +
> +		if (virtual_extension)
> +			pages[buf->nbufs] = pages[0];
> +
> +		buf->direct.buf = vmap(pages, npages, VM_MAP, PAGE_KERNEL);

I'm sorry but I'm going to require that you fix this mis-use of the DMA
API first.

You absolutely cannot vmap() pages backing coherent DMA memory, the
memory is mapped in a particular way by dma_*_coherent() and you must
therefore only use the virtual address provided to you by that
function to access the memory.
