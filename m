From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 06/13] net/mlx5e: Support RX multi-packet WQE
 (Striding RQ)
Date: Mon, 14 Mar 2016 22:33:44 +0100
Message-ID: <20160314223344.48621fa7@redhat.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
	<1457703594-9482-7-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>, brouer@redhat.com
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35288 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901AbcCNVdu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 17:33:50 -0400
In-Reply-To: <1457703594-9482-7-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 11 Mar 2016 15:39:47 +0200 Saeed Mahameed <saeedm@mellanox.com> wrote:

> From: Tariq Toukan <tariqt@mellanox.com>
> 
> Introduce the feature of multi-packet WQE (RX Work Queue Element)
> referred to as (MPWQE or Striding RQ), in which WQEs are larger
> and serve multiple packets each.
> 
> Every WQE consists of many strides of the same size, every received
> packet is aligned to a beginning of a stride and is written to
> consecutive strides within a WQE.

I really like this HW support! :-)

I noticed the "Multi-Packet WQE" send format, but I could not find the
receive part in the programmers ref doc, until I started looking after
"stride".


> In the regular approach, each regular WQE is big enough to be capable
> of serving one received packet of any size up to MTU or 64K in case of
> device LRO is enabeled, making it very wasteful when dealing with
> small packets or device LRO is enabeled.
> 
> For its flexibility, MPWQE allows a better memory utilization (implying
> improvements in CPU utilization and packet rate) as packets consume
> strides according to their size, preserving the rest of the WQE to be
> available for other packets.

It does allow significant better memory utilization (even if Eric
cannot see it, I can).

One issue with this approach is that we no-longer can use the
packet-data as the skb->data pointer.  (AFAIK because we cannot use
dma_unmap any longer, and instead we need to use dma_sync).

Thus, for every single packet you are now allocating a new memory area
for skb->data.


> MPWQE default configuration:
> 	NUM WQEs = 16
> 	Strides Per WQE = 1024
> 	Stride Size = 128

> Performance tested on ConnectX4-Lx 50G.
> 
> * Netperf single TCP stream:
> - message size = 1024,  bw raised from ~12300 mbps to 14900 mbps (+20%)
> - message size = 65536, bw raised from ~21800 mbps to 33500 mbps (+50%)
> - with other message sized we saw some gain or no degradation.
> 
> * Netperf multi TCP stream:
> - No degradation, line rate reached.
> 
> * Pktgen: packet loss in bursts of N small messages (64byte), single
> stream
> - | num packets | packets loss before	| packets loss after
>   |	2K	|       ~ 1K		|	0
>   |	16K	|       ~13K 		|	0
>   |	32K	|	~29K		|      14K
> 
> As expected as the driver can recive as many small packets (<=128) as
> the number of total strides in the ring (default = 1024 * 16) vs. 1024
> (default ring size regardless of packets size) before this feautre.
> 
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> Signed-off-by: Achiad Shochat <achiad@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en.h       |   71 +++++++++++-
>  .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   15 ++-
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  109 +++++++++++++----
>  drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  126 ++++++++++++++++++--
>  include/linux/mlx5/device.h                        |   39 ++++++-
>  include/linux/mlx5/mlx5_ifc.h                      |   13 ++-
>  6 files changed, 327 insertions(+), 46 deletions(-)
> 
[...]
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> @@ -76,6 +76,33 @@ err_free_skb:
>  	return -ENOMEM;
>  }
>  
> +int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
> +{
> +	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
> +	int ret = 0;
> +
> +	wi->dma_info.page = alloc_pages(GFP_ATOMIC | __GFP_COMP | __GFP_COLD,
> +					MLX5_MPWRQ_WQE_PAGE_ORDER);

Order 5 page = 131072 bytes, but we only alloc 16 of them.

> +	if (unlikely(!wi->dma_info.page))
> +		return -ENOMEM;
> +
> +	wi->dma_info.addr = dma_map_page(rq->pdev, wi->dma_info.page, 0,
> +					 rq->wqe_sz, PCI_DMA_FROMDEVICE);

Mapping the entire page is going to make PowerPC owners happy.

> +	if (dma_mapping_error(rq->pdev, wi->dma_info.addr)) {
> +		ret = -ENOMEM;
> +		goto err_put_page;
> +	}
> +
> +	wi->consumed_strides = 0;
> +	wqe->data.addr = cpu_to_be64(wi->dma_info.addr);
> +
> +	return 0;
> +
> +err_put_page:
> +	put_page(wi->dma_info.page);
> +	return ret;
> +}
> +
[...]
> +void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
> +{
> +	u16 cstrides       = mpwrq_get_cqe_consumed_strides(cqe);
> +	u16 stride_ix      = mpwrq_get_cqe_stride_index(cqe);
> +	u32 consumed_bytes = cstrides  * MLX5_MPWRQ_STRIDE_SIZE;
> +	u32 stride_offset  = stride_ix * MLX5_MPWRQ_STRIDE_SIZE;
> +	u16 wqe_id         = be16_to_cpu(cqe->wqe_id);
> +	struct mlx5e_mpw_info *wi = &rq->wqe_info[wqe_id];
> +	struct mlx5e_rx_wqe  *wqe = mlx5_wq_ll_get_wqe(&rq->wq, wqe_id);
> +	struct sk_buff *skb;
> +	u16 byte_cnt;
> +	u16 cqe_bcnt;
> +	u16 headlen;
> +
> +	wi->consumed_strides += cstrides;

Ok, moving N strides, for next round.

> +
> +	if (unlikely((cqe->op_own >> 4) != MLX5_CQE_RESP_SEND)) {
> +		rq->stats.wqe_err++;
> +		goto mpwrq_cqe_out;
> +	}
> +
> +	if (mpwrq_is_filler_cqe(cqe)) {
> +		rq->stats.mpwqe_filler++;
> +		goto mpwrq_cqe_out;
> +	}
> +
> +	skb = netdev_alloc_skb(rq->netdev, MLX5_MPWRQ_SMALL_PACKET_THRESHOLD);
> +	if (unlikely(!skb))
> +		goto mpwrq_cqe_out;
> +
> +	dma_sync_single_for_cpu(rq->pdev, wi->dma_info.addr + stride_offset,
> +				consumed_bytes, DMA_FROM_DEVICE);
> +
> +	cqe_bcnt = mpwrq_get_cqe_byte_cnt(cqe);
> +	headlen = min_t(u16, MLX5_MPWRQ_SMALL_PACKET_THRESHOLD, cqe_bcnt);
> +	skb_copy_to_linear_data(skb,
> +				page_address(wi->dma_info.page) + stride_offset,
> +				headlen);
> +	skb_put(skb, headlen);
> +
> +	byte_cnt = cqe_bcnt - headlen;
> +	if (byte_cnt) {
> +		skb_frag_t *f0 = &skb_shinfo(skb)->frags[0];
> +
> +		skb_shinfo(skb)->nr_frags = 1;
> +
> +		skb->data_len  = byte_cnt;
> +		skb->len      += byte_cnt;
> +		skb->truesize  = SKB_TRUESIZE(skb->len);
> +
> +		get_page(wi->dma_info.page);
> +		skb_frag_set_page(skb, 0, wi->dma_info.page);
> +		skb_frag_size_set(f0, skb->data_len);
> +		f0->page_offset = stride_offset + headlen;
> +	}
> +
> +	mlx5e_complete_rx_cqe(rq, cqe, cqe_bcnt, skb);
> +
> +mpwrq_cqe_out:
> +	if (likely(wi->consumed_strides < MLX5_MPWRQ_NUM_STRIDES))
> +		return;

Due to return statement, we keep working on the same big page, only
dma_sync'ing what we need.

> +
> +	dma_unmap_page(rq->pdev, wi->dma_info.addr, rq->wqe_sz,
> +		       PCI_DMA_FROMDEVICE);

Page is first fully dma_unmap'ed after all stride-entries have been
processed/consumed.

> +	put_page(wi->dma_info.page);
> +	mlx5_wq_ll_pop(&rq->wq, cqe->wqe_id, &wqe->next.next_wqe_index);
> +}
> +
>  int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
>  {
>  	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
