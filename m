From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next] mlx4: reorganize struct mlx4_en_tx_ring
Date: Thu, 24 Nov 2016 14:36:47 +0200
Message-ID: <f25767d3-4191-1fe9-d9cd-97f4bbee458c@gmail.com>
References: <1479858970.8455.461.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35032 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936406AbcKXMgw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 07:36:52 -0500
Received: by mail-wm0-f68.google.com with SMTP id a20so4875061wme.2
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 04:36:51 -0800 (PST)
In-Reply-To: <1479858970.8455.461.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,
Thanks for your patch.

On 23/11/2016 1:56 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Goal is to reorganize this critical structure to increase performance.
>
> ndo_start_xmit() should only dirty one cache line, and access as few
> cache lines as possible.
>
> Add sp_ (Slow Path) prefix to fields that are not used in fast path,
> to make clear what is going on.
>
> After this patch pahole reports something much better, as all
> ndo_start_xmit() needed fields are packed into two cache lines instead
> of seven or eight
>
> struct mlx4_en_tx_ring {
> 	u32                        last_nr_txbb;         /*     0   0x4 */
> 	u32                        cons;                 /*   0x4   0x4 */
> 	long unsigned int          wake_queue;           /*   0x8   0x8 */
> 	struct netdev_queue *      tx_queue;             /*  0x10   0x8 */
> 	u32                        (*free_tx_desc)(struct mlx4_en_priv *, struct mlx4_en_tx_ring *, int, u8, u64, int); /*  0x18   0x8 */
> 	struct mlx4_en_rx_ring *   recycle_ring;         /*  0x20   0x8 */
>
> 	/* XXX 24 bytes hole, try to pack */
>
> 	/* --- cacheline 1 boundary (64 bytes) --- */
> 	u32                        prod;                 /*  0x40   0x4 */
> 	unsigned int               tx_dropped;           /*  0x44   0x4 */
> 	long unsigned int          bytes;                /*  0x48   0x8 */
> 	long unsigned int          packets;              /*  0x50   0x8 */
> 	long unsigned int          tx_csum;              /*  0x58   0x8 */
> 	long unsigned int          tso_packets;          /*  0x60   0x8 */
> 	long unsigned int          xmit_more;            /*  0x68   0x8 */
> 	struct mlx4_bf             bf;                   /*  0x70  0x18 */
> 	/* --- cacheline 2 boundary (128 bytes) was 8 bytes ago --- */
> 	__be32                     doorbell_qpn;         /*  0x88   0x4 */
> 	__be32                     mr_key;               /*  0x8c   0x4 */
> 	u32                        size;                 /*  0x90   0x4 */
> 	u32                        size_mask;            /*  0x94   0x4 */
> 	u32                        full_size;            /*  0x98   0x4 */
> 	u32                        buf_size;             /*  0x9c   0x4 */
> 	void *                     buf;                  /*  0xa0   0x8 */
> 	struct mlx4_en_tx_info *   tx_info;              /*  0xa8   0x8 */
> 	int                        qpn;                  /*  0xb0   0x4 */
> 	u8                         queue_index;          /*  0xb4   0x1 */
> 	bool                       bf_enabled;           /*  0xb5   0x1 */
> 	bool                       bf_alloced;           /*  0xb6   0x1 */
> 	u8                         hwtstamp_tx_type;     /*  0xb7   0x1 */
> 	u8 *                       bounce_buf;           /*  0xb8   0x8 */
> 	/* --- cacheline 3 boundary (192 bytes) --- */
> 	long unsigned int          queue_stopped;        /*  0xc0   0x8 */
> 	struct mlx4_hwq_resources  sp_wqres;             /*  0xc8  0x58 */
> 	/* --- cacheline 4 boundary (256 bytes) was 32 bytes ago --- */
> 	struct mlx4_qp             sp_qp;                /* 0x120  0x30 */
> 	/* --- cacheline 5 boundary (320 bytes) was 16 bytes ago --- */
> 	struct mlx4_qp_context     sp_context;           /* 0x150  0xf8 */
> 	/* --- cacheline 9 boundary (576 bytes) was 8 bytes ago --- */
> 	cpumask_t                  sp_affinity_mask;     /* 0x248  0x20 */
> 	enum mlx4_qp_state         sp_qp_state;          /* 0x268   0x4 */
> 	u16                        sp_stride;            /* 0x26c   0x2 */
> 	u16                        sp_cqn;               /* 0x26e   0x2 */
>
> 	/* size: 640, cachelines: 10, members: 36 */
> 	/* sum members: 600, holes: 1, sum holes: 24 */
> 	/* padding: 16 */
> };
>
> Instead of this silly placement :
>
> struct mlx4_en_tx_ring {
> 	u32                        last_nr_txbb;         /*     0   0x4 */
> 	u32                        cons;                 /*   0x4   0x4 */
> 	long unsigned int          wake_queue;           /*   0x8   0x8 */
>
> 	/* XXX 48 bytes hole, try to pack */
>
> 	/* --- cacheline 1 boundary (64 bytes) --- */
> 	u32                        prod;                 /*  0x40   0x4 */
>
> 	/* XXX 4 bytes hole, try to pack */
>
> 	long unsigned int          bytes;                /*  0x48   0x8 */
> 	long unsigned int          packets;              /*  0x50   0x8 */
> 	long unsigned int          tx_csum;              /*  0x58   0x8 */
> 	long unsigned int          tso_packets;          /*  0x60   0x8 */
> 	long unsigned int          xmit_more;            /*  0x68   0x8 */
> 	unsigned int               tx_dropped;           /*  0x70   0x4 */
>
> 	/* XXX 4 bytes hole, try to pack */
>
> 	struct mlx4_bf             bf;                   /*  0x78  0x18 */
> 	/* --- cacheline 2 boundary (128 bytes) was 16 bytes ago --- */
> 	long unsigned int          queue_stopped;        /*  0x90   0x8 */
> 	cpumask_t                  affinity_mask;        /*  0x98  0x10 */
> 	struct mlx4_qp             qp;                   /*  0xa8  0x30 */
> 	/* --- cacheline 3 boundary (192 bytes) was 24 bytes ago --- */
> 	struct mlx4_hwq_resources  wqres;                /*  0xd8  0x58 */
> 	/* --- cacheline 4 boundary (256 bytes) was 48 bytes ago --- */
> 	u32                        size;                 /* 0x130   0x4 */
> 	u32                        size_mask;            /* 0x134   0x4 */
> 	u16                        stride;               /* 0x138   0x2 */
>
> 	/* XXX 2 bytes hole, try to pack */
>
> 	u32                        full_size;            /* 0x13c   0x4 */
> 	/* --- cacheline 5 boundary (320 bytes) --- */
> 	u16                        cqn;                  /* 0x140   0x2 */
>
> 	/* XXX 2 bytes hole, try to pack */
>
> 	u32                        buf_size;             /* 0x144   0x4 */
> 	__be32                     doorbell_qpn;         /* 0x148   0x4 */
> 	__be32                     mr_key;               /* 0x14c   0x4 */
> 	void *                     buf;                  /* 0x150   0x8 */
> 	struct mlx4_en_tx_info *   tx_info;              /* 0x158   0x8 */
> 	struct mlx4_en_rx_ring *   recycle_ring;         /* 0x160   0x8 */
> 	u32                        (*free_tx_desc)(struct mlx4_en_priv *, struct mlx4_en_tx_ring *, int, u8, u64, int); /* 0x168   0x8 */
> 	u8 *                       bounce_buf;           /* 0x170   0x8 */
> 	struct mlx4_qp_context     context;              /* 0x178  0xf8 */
> 	/* --- cacheline 9 boundary (576 bytes) was 48 bytes ago --- */
> 	int                        qpn;                  /* 0x270   0x4 */
> 	enum mlx4_qp_state         qp_state;             /* 0x274   0x4 */
> 	u8                         queue_index;          /* 0x278   0x1 */
> 	bool                       bf_enabled;           /* 0x279   0x1 */
> 	bool                       bf_alloced;           /* 0x27a   0x1 */
>
> 	/* XXX 5 bytes hole, try to pack */
>
> 	/* --- cacheline 10 boundary (640 bytes) --- */
> 	struct netdev_queue *      tx_queue;             /* 0x280   0x8 */
> 	int                        hwtstamp_tx_type;     /* 0x288   0x4 */
>
> 	/* size: 704, cachelines: 11, members: 36 */
> 	/* sum members: 587, holes: 6, sum holes: 65 */
> 	/* padding: 52 */
> };
>
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2
>   drivers/net/ethernet/mellanox/mlx4/en_tx.c     |   48 +++++++--------
>   drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |   42 +++++++------
>   3 files changed, 48 insertions(+), 44 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 9a807e93c9fdd81e61e561208aa1480a244d0bdb..9018bb1b2e12142e048281a9d28ddf95e0023a61 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1305,7 +1305,7 @@ static void mlx4_en_tx_timeout(struct net_device *dev)
>   		if (!netif_tx_queue_stopped(netdev_get_tx_queue(dev, i)))
>   			continue;
>   		en_warn(priv, "TX timeout on queue: %d, QP: 0x%x, CQ: 0x%x, Cons: 0x%x, Prod: 0x%x\n",
> -			i, tx_ring->qpn, tx_ring->cqn,
> +			i, tx_ring->qpn, tx_ring->sp_cqn,
>   			tx_ring->cons, tx_ring->prod);
>   	}
>   
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 5de3cbe24f2bf467f9a8f7d499e131b6d2a1844c..4b597dca5c52d114344d638895275ed0d378bd96 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -66,7 +66,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
>   
>   	ring->size = size;
>   	ring->size_mask = size - 1;
> -	ring->stride = stride;
> +	ring->sp_stride = stride;
>   	ring->full_size = ring->size - HEADROOM - MAX_DESC_TXBBS;
>   
>   	tmp = size * sizeof(struct mlx4_en_tx_info);
> @@ -90,22 +90,22 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
>   			goto err_info;
>   		}
>   	}
> -	ring->buf_size = ALIGN(size * ring->stride, MLX4_EN_PAGE_SIZE);
> +	ring->buf_size = ALIGN(size * ring->sp_stride, MLX4_EN_PAGE_SIZE);
>   
>   	/* Allocate HW buffers on provided NUMA node */
>   	set_dev_node(&mdev->dev->persist->pdev->dev, node);
> -	err = mlx4_alloc_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
> +	err = mlx4_alloc_hwq_res(mdev->dev, &ring->sp_wqres, ring->buf_size);
>   	set_dev_node(&mdev->dev->persist->pdev->dev, mdev->dev->numa_node);
>   	if (err) {
>   		en_err(priv, "Failed allocating hwq resources\n");
>   		goto err_bounce;
>   	}
>   
> -	ring->buf = ring->wqres.buf.direct.buf;
> +	ring->buf = ring->sp_wqres.buf.direct.buf;
>   
>   	en_dbg(DRV, priv, "Allocated TX ring (addr:%p) - buf:%p size:%d buf_size:%d dma:%llx\n",
>   	       ring, ring->buf, ring->size, ring->buf_size,
> -	       (unsigned long long) ring->wqres.buf.direct.map);
> +	       (unsigned long long) ring->sp_wqres.buf.direct.map);
>   
>   	err = mlx4_qp_reserve_range(mdev->dev, 1, 1, &ring->qpn,
>   				    MLX4_RESERVE_ETH_BF_QP);
> @@ -114,12 +114,12 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
>   		goto err_hwq_res;
>   	}
>   
> -	err = mlx4_qp_alloc(mdev->dev, ring->qpn, &ring->qp, GFP_KERNEL);
> +	err = mlx4_qp_alloc(mdev->dev, ring->qpn, &ring->sp_qp, GFP_KERNEL);
>   	if (err) {
>   		en_err(priv, "Failed allocating qp %d\n", ring->qpn);
>   		goto err_reserve;
>   	}
> -	ring->qp.event = mlx4_en_sqp_event;
> +	ring->sp_qp.event = mlx4_en_sqp_event;
>   
>   	err = mlx4_bf_alloc(mdev->dev, &ring->bf, node);
>   	if (err) {
> @@ -141,7 +141,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
>   	if (queue_index < priv->num_tx_rings_p_up)
>   		cpumask_set_cpu(cpumask_local_spread(queue_index,
>   						     priv->mdev->dev->numa_node),
> -				&ring->affinity_mask);
> +				&ring->sp_affinity_mask);
>   
>   	*pring = ring;
>   	return 0;
> @@ -149,7 +149,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
>   err_reserve:
>   	mlx4_qp_release_range(mdev->dev, ring->qpn, 1);
>   err_hwq_res:
> -	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
> +	mlx4_free_hwq_res(mdev->dev, &ring->sp_wqres, ring->buf_size);
>   err_bounce:
>   	kfree(ring->bounce_buf);
>   	ring->bounce_buf = NULL;
> @@ -171,10 +171,10 @@ void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
>   
>   	if (ring->bf_alloced)
>   		mlx4_bf_free(mdev->dev, &ring->bf);
> -	mlx4_qp_remove(mdev->dev, &ring->qp);
> -	mlx4_qp_free(mdev->dev, &ring->qp);
> +	mlx4_qp_remove(mdev->dev, &ring->sp_qp);
> +	mlx4_qp_free(mdev->dev, &ring->sp_qp);
>   	mlx4_qp_release_range(priv->mdev->dev, ring->qpn, 1);
> -	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
> +	mlx4_free_hwq_res(mdev->dev, &ring->sp_wqres, ring->buf_size);
>   	kfree(ring->bounce_buf);
>   	ring->bounce_buf = NULL;
>   	kvfree(ring->tx_info);
> @@ -190,7 +190,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
>   	struct mlx4_en_dev *mdev = priv->mdev;
>   	int err;
>   
> -	ring->cqn = cq;
> +	ring->sp_cqn = cq;
>   	ring->prod = 0;
>   	ring->cons = 0xffffffff;
>   	ring->last_nr_txbb = 1;
> @@ -198,21 +198,21 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
>   	memset(ring->buf, 0, ring->buf_size);
>   	ring->free_tx_desc = mlx4_en_free_tx_desc;
>   
> -	ring->qp_state = MLX4_QP_STATE_RST;
> -	ring->doorbell_qpn = cpu_to_be32(ring->qp.qpn << 8);
> +	ring->sp_qp_state = MLX4_QP_STATE_RST;
> +	ring->doorbell_qpn = cpu_to_be32(ring->sp_qp.qpn << 8);
>   	ring->mr_key = cpu_to_be32(mdev->mr.key);
>   
> -	mlx4_en_fill_qp_context(priv, ring->size, ring->stride, 1, 0, ring->qpn,
> -				ring->cqn, user_prio, &ring->context);
> +	mlx4_en_fill_qp_context(priv, ring->size, ring->sp_stride, 1, 0, ring->qpn,
> +				ring->sp_cqn, user_prio, &ring->sp_context);
>   	if (ring->bf_alloced)
> -		ring->context.usr_page =
> +		ring->sp_context.usr_page =
>   			cpu_to_be32(mlx4_to_hw_uar_index(mdev->dev,
>   							 ring->bf.uar->index));
>   
> -	err = mlx4_qp_to_ready(mdev->dev, &ring->wqres.mtt, &ring->context,
> -			       &ring->qp, &ring->qp_state);
> -	if (!cpumask_empty(&ring->affinity_mask))
> -		netif_set_xps_queue(priv->dev, &ring->affinity_mask,
> +	err = mlx4_qp_to_ready(mdev->dev, &ring->sp_wqres.mtt, &ring->sp_context,
> +			       &ring->sp_qp, &ring->sp_qp_state);
> +	if (!cpumask_empty(&ring->sp_affinity_mask))
> +		netif_set_xps_queue(priv->dev, &ring->sp_affinity_mask,
>   				    ring->queue_index);
>   
>   	return err;
> @@ -223,8 +223,8 @@ void mlx4_en_deactivate_tx_ring(struct mlx4_en_priv *priv,
>   {
>   	struct mlx4_en_dev *mdev = priv->mdev;
>   
> -	mlx4_qp_modify(mdev->dev, NULL, ring->qp_state,
> -		       MLX4_QP_STATE_RST, NULL, 0, 0, &ring->qp);
> +	mlx4_qp_modify(mdev->dev, NULL, ring->sp_qp_state,
> +		       MLX4_QP_STATE_RST, NULL, 0, 0, &ring->sp_qp);
>   }
>   
>   static inline bool mlx4_en_is_tx_ring_full(struct mlx4_en_tx_ring *ring)
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index eff21651b67308a17fe3d60d236cd0b6800a3fd2..574bcbb1b38fc4758511d8f7bd17a87b0a507a73 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -281,46 +281,50 @@ struct mlx4_en_tx_ring {
>   	u32			last_nr_txbb;
>   	u32			cons;
>   	unsigned long		wake_queue;
> +	struct netdev_queue	*tx_queue;
> +	u32			(*free_tx_desc)(struct mlx4_en_priv *priv,
> +						struct mlx4_en_tx_ring *ring,
> +						int index, u8 owner,
> +						u64 timestamp, int napi_mode);
> +	struct mlx4_en_rx_ring	*recycle_ring;
>   
>   	/* cache line used and dirtied in mlx4_en_xmit() */
>   	u32			prod ____cacheline_aligned_in_smp;
> +	unsigned int		tx_dropped;
>   	unsigned long		bytes;
>   	unsigned long		packets;
>   	unsigned long		tx_csum;
>   	unsigned long		tso_packets;
>   	unsigned long		xmit_more;
> -	unsigned int		tx_dropped;
>   	struct mlx4_bf		bf;
> -	unsigned long		queue_stopped;
>   
>   	/* Following part should be mostly read */
> -	cpumask_t		affinity_mask;
> -	struct mlx4_qp		qp;
> -	struct mlx4_hwq_resources wqres;
> +	__be32			doorbell_qpn;
> +	__be32			mr_key;
>   	u32			size; /* number of TXBBs */
>   	u32			size_mask;
> -	u16			stride;
>   	u32			full_size;
> -	u16			cqn;	/* index of port CQ associated with this ring */
>   	u32			buf_size;
> -	__be32			doorbell_qpn;
> -	__be32			mr_key;
>   	void			*buf;
>   	struct mlx4_en_tx_info	*tx_info;
> -	struct mlx4_en_rx_ring	*recycle_ring;
> -	u32			(*free_tx_desc)(struct mlx4_en_priv *priv,
> -						struct mlx4_en_tx_ring *ring,
> -						int index, u8 owner,
> -						u64 timestamp, int napi_mode);
> -	u8			*bounce_buf;
> -	struct mlx4_qp_context	context;
>   	int			qpn;
> -	enum mlx4_qp_state	qp_state;
>   	u8			queue_index;
>   	bool			bf_enabled;
>   	bool			bf_alloced;
> -	struct netdev_queue	*tx_queue;
> -	int			hwtstamp_tx_type;
> +	u8			hwtstamp_tx_type;
> +	u8			*bounce_buf;
> +
> +	/* Not used in fast path
> +	 * Only queue_stopped might be used if BQL is not properly working.
> +	 */
> +	unsigned long		queue_stopped;
> +	struct mlx4_hwq_resources sp_wqres;
> +	struct mlx4_qp		sp_qp;
> +	struct mlx4_qp_context	sp_context;
> +	cpumask_t		sp_affinity_mask;
> +	enum mlx4_qp_state	sp_qp_state;
> +	u16			sp_stride;
> +	u16			sp_cqn;	/* index of port CQ associated with this ring */
>   } ____cacheline_aligned_in_smp;
>   
>   struct mlx4_en_rx_desc {
>
>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>

Regards,
Tariq
