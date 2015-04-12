From: Ido Shamay <idos@dev.mellanox.co.il>
Subject: Re: [PATCH] mlx4: Fix tx ring affinity_mask creation
Date: Sun, 12 Apr 2015 10:03:04 +0300
Message-ID: <552A18A8.1040109@dev.mellanox.co.il>
References: <1428683240-22879-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.de>,
	Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:38037 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbbDLHDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 03:03:08 -0400
Received: by wiun10 with SMTP id n10so35993679wiu.1
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 00:03:07 -0700 (PDT)
In-Reply-To: <1428683240-22879-1-git-send-email-bpoirier@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Benjamin,

On 4/10/2015 7:27 PM, Benjamin Poirier wrote:
> By default, the number of tx queues is limited by the number of online cpus in
> mlx4_en_get_profile(). However, this limit no longer holds after the ethtool
> .set_channels method has been called. In that situation, the driver may access
> invalid bits of certain cpumask variables when queue_index > nr_cpu_ids.

I must say I don't see the above issue with the current code.
Whatever is the modified value of priv->num_tx_rings_p_up, it will set 
XPS only on queues which have
been set with CPU affinity mask (no access to invalid bits).

It's true that when priv->num_tx_rings_p_up > nr_cpus. not all queues 
will be set with XPS.
This is because the code tries to preserve 1:1 mapping of queues to 
cores, to avoid a double mapping
of queues to cores.
I guess it's ok to break the 1:1 mapping in this condition, but the 
commit message should say that instead
of invalid bits. Please fix me if I'm wrong.

> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_tx.c | 8 +++++---
>   1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 55f9f5c..8c234ec 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -143,8 +143,10 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
>   	ring->hwtstamp_tx_type = priv->hwtstamp_config.tx_type;
>   	ring->queue_index = queue_index;
>   
> -	if (queue_index < priv->num_tx_rings_p_up && cpu_online(queue_index))
> -		cpumask_set_cpu(queue_index, &ring->affinity_mask);
> +	if (queue_index < priv->num_tx_rings_p_up)
> +			cpumask_set_cpu_local_first(queue_index,
> +					    priv->mdev->dev->numa_node,
> +					    &ring->affinity_mask);
Moving from cpumask_set_cpu to cpumask_set_cpu_local_first is great, but 
should come in a different commit, since
the behavior of the XPS is changed here (xps_cpus[tx_ring[queue_index]] 
!= queue_index from now).
Commit should state of this behavior change.
Thanks a lot Benjamin.
>   
>   	*pring = ring;
>   	return 0;
> @@ -213,7 +215,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
>   
>   	err = mlx4_qp_to_ready(mdev->dev, &ring->wqres.mtt, &ring->context,
>   			       &ring->qp, &ring->qp_state);
> -	if (!user_prio && cpu_online(ring->queue_index))
> +	if (!cpumask_empty(&ring->affinity_mask))
>   		netif_set_xps_queue(priv->dev, &ring->affinity_mask,
>   				    ring->queue_index);
>   
