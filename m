From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 01/12] net/mlx4_en: Reuse mapped memory in RX
 flow
Date: Mon, 9 Dec 2013 11:44:16 +0200
Message-ID: <52A590F0.7000508@mellanox.com>
References: <1386506152-10298-1-git-send-email-amirv@mellanox.com>	 <1386506152-10298-2-git-send-email-amirv@mellanox.com> <1386530458.30495.286.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	<netdev@vger.kernel.org>, Eugenia Emantayev <eugenia@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog123.obsmtp.com ([207.126.144.155]:57511 "EHLO
	eu1sys200aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761268Ab3LIJoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 04:44:22 -0500
In-Reply-To: <1386530458.30495.286.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2013 21:20, Eric Dumazet wrote:
> On Sun, 2013-12-08 at 14:35 +0200, Amir Vadai wrote:
>> From: Eugenia Emantayev <eugenia@mellanox.com>
>>
>> In receive flow use one fragment instead of multiple fragments.
>> Always allocate at least twice memory than needed for current MTU
>> and on each cycle use one hunk of the mapped memory.
>> Realloc and map new page only if this page was not freed.
>> This behavior allows to save unnecessary dma (un)mapping
>> operations that are very expensive when IOMMU is enabled.
>>
>>
>> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  12 +-
>>  drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 723 +++++++++----------------
>>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  56 +-
>>  3 files changed, 299 insertions(+), 492 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> index 709e5ec..9270006 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> @@ -1490,7 +1490,11 @@ int mlx4_en_start_port(struct net_device *dev)
>>  
>>  	/* Calculate Rx buf size */
>>  	dev->mtu = min(dev->mtu, priv->max_mtu);
>> -	mlx4_en_calc_rx_buf(dev);
>> +	priv->rx_skb_size = dev->mtu + ETH_HLEN + VLAN_HLEN;
>> +	priv->rx_buf_size = roundup_pow_of_two(priv->rx_skb_size);
>> +	priv->rx_alloc_size = max_t(int, 2 * priv->rx_buf_size, PAGE_SIZE);
>> +	priv->rx_alloc_order = get_order(priv->rx_alloc_size);
>> +	priv->log_rx_info = ROUNDUP_LOG2(sizeof(struct mlx4_en_rx_buf));
>>  	en_dbg(DRV, priv, "Rx buf size:%d\n", priv->rx_skb_size);
>>  
>>  	/* Configure rx cq's and rings */
>> @@ -1923,7 +1927,7 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
>>  			goto err;
>>  
>>  		if (mlx4_en_create_rx_ring(priv, &priv->rx_ring[i],
>> -					   prof->rx_ring_size, priv->stride,
>> +					   prof->rx_ring_size,
>>  					   node))
>>  			goto err;
>>  	}
>> @@ -2316,7 +2320,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
>>  	memcpy(priv->prev_mac, dev->dev_addr, sizeof(priv->prev_mac));
>>  
>>  	priv->stride = roundup_pow_of_two(sizeof(struct mlx4_en_rx_desc) +
>> -					  DS_SIZE * MLX4_EN_MAX_RX_FRAGS);
>> +					  DS_SIZE);
>>  	err = mlx4_en_alloc_resources(priv);
>>  	if (err)
>>  		goto out;
>> @@ -2393,7 +2397,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
>>  	mlx4_en_update_loopback_state(priv->dev, priv->dev->features);
>>  
>>  	/* Configure port */
>> -	mlx4_en_calc_rx_buf(dev);
>> +	priv->rx_skb_size = dev->mtu + ETH_HLEN + VLAN_HLEN;
>>  	err = mlx4_SET_PORT_general(mdev->dev, priv->port,
>>  				    priv->rx_skb_size + ETH_FCS_LEN,
>>  				    prof->tx_pause, prof->tx_ppp,
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> index 07a1d0f..965c021 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> @@ -43,197 +43,72 @@
>>  
>>  #include "mlx4_en.h"
>>  
>> -static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
>> -			    struct mlx4_en_rx_alloc *page_alloc,
>> -			    const struct mlx4_en_frag_info *frag_info,
>> -			    gfp_t _gfp)
>> +static int mlx4_en_alloc_frag(struct mlx4_en_priv *priv,
>> +			      struct mlx4_en_rx_ring *ring,
>> +			      struct mlx4_en_rx_desc *rx_desc,
>> +			      struct mlx4_en_rx_buf *rx_buf,
>> +			      enum mlx4_en_alloc_type type)
>>  {
>> -	int order;
>> +	struct device *dev = priv->ddev;
>>  	struct page *page;
>> -	dma_addr_t dma;
>> -
>> -	for (order = MLX4_EN_ALLOC_PREFER_ORDER; ;) {
>> -		gfp_t gfp = _gfp;
>> -
>> -		if (order)
>> -			gfp |= __GFP_COMP | __GFP_NOWARN;
>> -		page = alloc_pages(gfp, order);
>> -		if (likely(page))
>> -			break;
>> -		if (--order < 0 ||
>> -		    ((PAGE_SIZE << order) < frag_info->frag_size))
>> +	dma_addr_t dma = 0;
>> +	gfp_t gfp = GFP_ATOMIC | __GFP_COLD | __GFP_COMP | __GFP_NOWARN;
>> +
>> +	/* alloc new page */
>> +	page = alloc_pages_node(ring->numa_node, gfp, ring->rx_alloc_order);
> 
> Hey... what is numa_node ?
We get optimal performance when rx rings are mapped 1:1 to cpu's - IRQ
affinity is set to this CPU, and memory is allocated on the NUMA node
close to it (ring->numa_node)
In order to do that, we will post a patch soon to use
irq_set_affinity_hint() in order to hint the irq balancer. Till this
patch is applied, users should set irq affinity through sysfs and
disable the irq balancer.

> 
>> +	if (unlikely(!page)) {
>> +		page = alloc_pages(gfp, ring->rx_alloc_order);
>> +		if (unlikely(!page))
>>  			return -ENOMEM;
>>  	}
> 
> I find very worrying such a change, with non documented features.
> (Not even mentioned in the changelog)
Will improve the changelog in V1

> 
> We made a change in the past [1], that allocations always should be done
> on the node of the cpu handling the RX irqs.
This is the intention here too.
But, if can't do the allocation on the needed node (close to the cpu
handling the RX irqs), fallback to allocate from any node.

> 
> Have you tested the performance changes of this patch ?
Sure

> If yes, please describe the protocol.
Will send it later today

> 
> [1] commit 564824b0c52c34692d804bb6ea214451615b0b50
> ("net: allocate skbs on local node")
> 
> Also, it looks like your patch is now using 2048 bytes per frame,
> instead of 1536, yet truesize is not changed.
> 
> In fact, it seems you added yet another skb->truesize lie
> 
> As in :
> 
> 	skb->truesize = length + sizeof(struct sk_buff);
I'm sorry, the fix in [1] was dropped by mistake.
Will remove this line in V1

[1] 90278c9 "mlx4_en: fix skb truesize underestimation"

> 
> And :
> 
> 	skb->truesize += ring->rx_buf_size;
This is a bug - should be ring->rx_skb_size which is 1536 and not 2K.
Also used by mistake rx_buf_size when posted buffers to the HW - this
will also be fixed for V1.

> 
> This is absolutely wrong, I am very upset by this patch, its a step
> back.
This is part of a process we do to have only one driver (upstream
kernel) instead of having two: MLNX_OFED driver and upstream driver.
I hope that in the end it will be a huge step forward...

> 
> You drivers guys cannot ignore how the whole networking stack works.
If we ignored something it was by mistake. We take it very seriously,
and appreciate the hard work done here.
