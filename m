From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 08/13] net/mlx5e: Add fragmented memory support
 for RX multi packet WQE
Date: Fri, 11 Mar 2016 06:32:51 -0800
Message-ID: <1457706771.2663.37.camel@edumazet-ThinkPad-T530>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
	 <1457703594-9482-9-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36193 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932102AbcCKOcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 09:32:54 -0500
Received: by mail-pa0-f54.google.com with SMTP id tt10so99893799pab.3
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 06:32:54 -0800 (PST)
In-Reply-To: <1457703594-9482-9-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ven., 2016-03-11 at 15:39 +0200, Saeed Mahameed wrote:
> From: Tariq Toukan <tariqt@mellanox.com>
> 
> If the allocation of a linear (physically continuous) MPWQE fails,
> we allocate a fragmented MPWQE.
> 
> This is implemented via device's UMR (User Memory Registration)
> which allows to register multiple memory fragments into ConnectX
> hardware as a continuous buffer.
> UMR registration is an asynchronous operation and is done via
> ICO SQs.
> 
...

> +static int mlx5e_alloc_and_map_page(struct mlx5e_rq *rq,
> +				    struct mlx5e_mpw_info *wi,
> +				    int i)
> +{
> +	struct page *page;
> +
> +	page = alloc_page(GFP_ATOMIC | __GFP_COMP | __GFP_COLD);
> +	if (!page)
> +		return -ENOMEM;
> +
> +	wi->umr.dma_info[i].page = page;
> +	wi->umr.dma_info[i].addr = dma_map_page(rq->pdev, page, 0, PAGE_SIZE,
> +						PCI_DMA_FROMDEVICE);
> +	if (dma_mapping_error(rq->pdev, wi->umr.dma_info[i].addr)) {
> +		put_page(page);
> +		return -ENOMEM;
> +	}
> +	wi->umr.mtt[i] = cpu_to_be64(wi->umr.dma_info[i].addr | MLX5_EN_WR);
> +
> +	return 0;
> +}
> +
> +static int mlx5e_alloc_rx_fragmented_mpwqe(struct mlx5e_rq *rq,
> +					   struct mlx5e_rx_wqe *wqe,
> +					   u16 ix)
> +{
> +	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
> +	int mtt_sz = mlx5e_get_wqe_mtt_sz();
> +	u32 dma_offset = rq->ix * MLX5_CHANNEL_MAX_NUM_PAGES * PAGE_SIZE +
> +		ix * rq->wqe_sz;
> +	int i;
> +
> +	wi->umr.dma_info = kmalloc(sizeof(*wi->umr.dma_info) *
> +				   MLX5_MPWRQ_WQE_NUM_PAGES,
> +				   GFP_ATOMIC | __GFP_COMP | __GFP_COLD);
> +	if (!wi->umr.dma_info)
> +		goto err_out;
> +
> +	 /* To avoid copying garbage after the mtt array, we allocate
> +	  * a little more.
> +	  */
> +	wi->umr.mtt = kzalloc(mtt_sz + MLX5_UMR_ALIGN - 1,
> +			  GFP_ATOMIC | __GFP_COMP | __GFP_COLD);

__GFP_COLD right before a memset(0) (kzalloc) makes little sense.


> +	if (!wi->umr.mtt)
> +		goto err_free_umr;
> +
> +	wi->umr.mtt = PTR_ALIGN(wi->umr.mtt, MLX5_UMR_ALIGN);
> +	wi->umr.mtt_addr = dma_map_single(rq->pdev, wi->umr.mtt, mtt_sz,
> +				      PCI_DMA_TODEVICE);
> +	if (dma_mapping_error(rq->pdev, wi->umr.mtt_addr))
> +		goto err_free_mtt;
> +
...

>  
> -void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
> +static void mlx5e_add_skb_frag(struct sk_buff *skb, int len, struct page *page,
> +			       int page_offset)
> +{
> +	int f = skb_shinfo(skb)->nr_frags++;
> +	skb_frag_t *fr = &skb_shinfo(skb)->frags[f];
> +
> +	skb->len += len;
> +	skb->data_len += len;
> +	get_page(page);
> +	skb_frag_set_page(skb, f, page);
> +	skb_frag_size_set(fr, len);
> +	fr->page_offset = page_offset;
> +	skb->truesize  = SKB_TRUESIZE(skb->len);
> +}

Really I am speechless.

It is hard to believe how much effort some drivers authors spend trying
to fool linux stack and risk OOM a host under stress.

SKB_TRUESIZE() is absolutely not something a driver is allowed to use.

Here you want instead :

skb->truesize += PAGE_SIZE;

Assuming you allocate and use an order-0 page per fragment. Fact that
you receive say 100 bytes datagram is irrelevant to truesize.

truesize is the real memory usage of one skb. Not the minimal size of an
optimally allocated skb for a given payload.


Better RX speed should not be done at the risk of system stability.

Now if for some reason you need to increase max TCP RWIN, that would be
a TCP stack change, not some obscure lie in a driver trying to be faster
than competitors.

Thanks.
