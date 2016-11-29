From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/7] net/mlx5e: Implement Fragmented Work Queue
 (WQ)
Date: Tue, 29 Nov 2016 15:31:22 -0800
Message-ID: <1480462282.18162.161.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480457972-31286-1-git-send-email-saeedm@mellanox.com>
         <1480457972-31286-2-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Tariq Toukan <tariqt@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Sebastian Ott <sebott@linux.vnet.ibm.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35045 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755551AbcK2Xb0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 18:31:26 -0500
Received: by mail-pf0-f195.google.com with SMTP id i88so8988224pfk.2
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 15:31:25 -0800 (PST)
In-Reply-To: <1480457972-31286-2-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-30 at 00:19 +0200, Saeed Mahameed wrote:
> From: Tariq Toukan <tariqt@mellanox.com>
> 
> Add new type of struct mlx5_frag_buf which is used to allocate fragmented
> buffers rather than contiguous, and make the Completion Queues (CQs) use
> it as they are big (default of 2MB per CQ in Striding RQ).
> 
> This fixes the failures of type:
> "mlx5e_open_locked: mlx5e_open_channels failed, -12"
> due to dma_zalloc_coherent insufficient contiguous coherent memory to
> satisfy the driver's request when the user tries to setup more or larger
> rings.
> 
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> Reported-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/alloc.c   | 66 +++++++++++++++++++++++
>  drivers/net/ethernet/mellanox/mlx5/core/en.h      |  2 +-
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 10 ++--
>  drivers/net/ethernet/mellanox/mlx5/core/wq.c      | 26 ++++++---
>  drivers/net/ethernet/mellanox/mlx5/core/wq.h      | 18 +++++--
>  include/linux/mlx5/driver.h                       | 11 ++++
>  6 files changed, 116 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
> index 2c6e3c7..bc8357d 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
> @@ -106,6 +106,63 @@ void mlx5_buf_free(struct mlx5_core_dev *dev, struct mlx5_buf *buf)
>  }
>  EXPORT_SYMBOL_GPL(mlx5_buf_free);
>  
> +int mlx5_frag_buf_alloc_node(struct mlx5_core_dev *dev, int size,
> +			     struct mlx5_frag_buf *buf, int node)
> +{
> +	int i;
> +
> +	buf->size = size;
> +	buf->npages = 1 << get_order(size);
> +	buf->page_shift = PAGE_SHIFT;
> +	buf->frags = kcalloc(buf->npages, sizeof(struct mlx5_buf_list),
> +			     GFP_KERNEL);
> +	if (!buf->frags)
> +		goto err_out;
> +
> +	for (i = 0; i < buf->npages; i++) {
> +		struct mlx5_buf_list *frag = &buf->frags[i];
> +		int frag_sz = min_t(int, size, PAGE_SIZE);
> +
> +		frag->buf = mlx5_dma_zalloc_coherent_node(dev, frag_sz,
> +							  &frag->map, node);
> +		if (!frag->buf)
> +			goto err_free_buf;
> +		if (frag->map & ((1 << buf->page_shift) - 1)) {
> +			dma_free_coherent(&dev->pdev->dev, frag_sz,
> +					  buf->frags[i].buf, buf->frags[i].map);

There is a bug if this happens with i = 0

> +			mlx5_core_warn(dev, "unexpected map alignment: 0x%p, page_shift=%d\n",
> +				       (void *)frag->map, buf->page_shift);
> +			goto err_free_buf;
> +		}
> +		size -= frag_sz;
> +	}
> +
> +	return 0;
> +
> +err_free_buf:
> +	while (--i)

Because this loop will be done about 2^32 times.

> +		dma_free_coherent(&dev->pdev->dev, PAGE_SIZE, buf->frags[i].buf,
> +				  buf->frags[i].map);
> +	kfree(buf->frags);
> +err_out:
> +	return -ENOMEM;
> +}
