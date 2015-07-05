From: Ido Shamay <idos@dev.mellanox.co.il>
Subject: Re: [PATCH net] mlx4: TCP/UDP packets have L4 hash
Date: Mon, 06 Jul 2015 00:16:19 +0300
Message-ID: <55999EA3.4010303@dev.mellanox.co.il>
References: <1435836284.11970.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:33397 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbbGEVQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2015 17:16:06 -0400
Received: by wgck11 with SMTP id k11so124890800wgc.0
        for <netdev@vger.kernel.org>; Sun, 05 Jul 2015 14:16:05 -0700 (PDT)
In-Reply-To: <1435836284.11970.16.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/2/2015 2:24 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Mellanox driver has the knowledge if rxhash is a L4 hash,
> if it receives a non fragmented TCP or UDP frame and
> NETIF_F_RXCSUM is enabled on netdev.
>
> ip_summed value is CHECKSUM_UNNECESSARY in this case.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Amir Vadai <amirv@mellanox.com>
> Cc: Ido Shamay <idos@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_rx.c |    8 ++++++--
>   1 file changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 7a4f20bb7fcb..12c65e1ad6a9 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -917,7 +917,9 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>   			if (dev->features & NETIF_F_RXHASH)
>   				skb_set_hash(gro_skb,
>   					     be32_to_cpu(cqe->immed_rss_invalid),
> -					     PKT_HASH_TYPE_L3);
> +					     (ip_summed == CHECKSUM_UNNECESSARY) ?
> +						PKT_HASH_TYPE_L4 :
> +						PKT_HASH_TYPE_L3);
Thanks Eric,

We can have a relaxation of the condition  by looking only at TCP/UDP 
CQE indication (without check-sum indications)
This can cover us also when device rx-checksuming feature is off.
Do we want it or a correlation between check-sum and l4_hash is needed?

Ido
>   
>   			skb_record_rx_queue(gro_skb, cq->ring);
>   			skb_mark_napi_id(gro_skb, &cq->napi);
> @@ -963,7 +965,9 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>   		if (dev->features & NETIF_F_RXHASH)
>   			skb_set_hash(skb,
>   				     be32_to_cpu(cqe->immed_rss_invalid),
> -				     PKT_HASH_TYPE_L3);
> +				     (ip_summed == CHECKSUM_UNNECESSARY) ?
> +					PKT_HASH_TYPE_L4 :
> +					PKT_HASH_TYPE_L3);
>   
>   		if ((be32_to_cpu(cqe->vlan_my_qpn) &
>   		    MLX4_CQE_VLAN_PRESENT_MASK) &&
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
