From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4_en: call gro handler for encapsulated frames
Date: Fri, 10 Jan 2014 00:24:22 +0200
Message-ID: <CAJZOPZ+U=q==kyYzqgObrmPwj_qYXvon2o40FxkU6AmsprG2og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jerry Chu <hkchu@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:49129 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbaAIWYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 17:24:22 -0500
Received: by mail-pa0-f51.google.com with SMTP id fa1so3896976pad.38
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 14:24:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 9, 2014 at 8:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> In order to use the native GRO handling of encapsulated protocols on
> mlx4, we need to call napi_gro_receive() instead of netif_receive_skb()
> unless busy polling is in action.
>
> While we are at it, rename mlx4_en_cq_ll_polling() to
> mlx4_en_cq_busy_polling()
>
> Tested with GRE tunnel : GRO aggregation is now performed on the
> ethernet device instead of being done later on gre device.

Hi Eric,

Just to make clear, this patch serves (very nicely!) encapsulated
frames for which the HW is not able to do checksum check. For
non-encapsulated packets or (e.g) vxlan encapsulated packets which are
checksummed  by the HW we already go to the GRO path of the ethernet
device.



> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Amir Vadai <amirv@mellanox.com>
> Cc: Jerry Chu <hkchu@google.com>
> Cc: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c   |    8 +++++---
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    4 ++--
>  2 files changed, 7 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 3b66f26ba049..890922c1c8ee 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -724,7 +724,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>                                  * - not an IP fragment
>                                  * - no LLS polling in progress
>                                  */
> -                               if (!mlx4_en_cq_ll_polling(cq) &&
> +                               if (!mlx4_en_cq_busy_polling(cq) &&
>                                     (dev->features & NETIF_F_GRO)) {
>                                         struct sk_buff *gro_skb = napi_get_frags(&cq->napi);
>                                         if (!gro_skb)
> @@ -816,8 +816,10 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>
>                 skb_mark_napi_id(skb, &cq->napi);
>
> -               /* Push it up the stack */
> -               netif_receive_skb(skb);
> +               if (!mlx4_en_cq_busy_polling(cq))
> +                       napi_gro_receive(&cq->napi, skb);
> +               else
> +                       netif_receive_skb(skb);
>
>  next:
>                 for (nr = 0; nr < priv->num_frags; nr++)
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index 2f1e200f2e4c..fe7bdfebf353 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -661,7 +661,7 @@ static inline bool mlx4_en_cq_unlock_poll(struct mlx4_en_cq *cq)
>  }
>
>  /* true if a socket is polling, even if it did not get the lock */
> -static inline bool mlx4_en_cq_ll_polling(struct mlx4_en_cq *cq)
> +static inline bool mlx4_en_cq_busy_polling(struct mlx4_en_cq *cq)
>  {
>         WARN_ON(!(cq->state & MLX4_CQ_LOCKED));
>         return cq->state & CQ_USER_PEND;
> @@ -691,7 +691,7 @@ static inline bool mlx4_en_cq_unlock_poll(struct mlx4_en_cq *cq)
>         return false;
>  }
>
> -static inline bool mlx4_en_cq_ll_polling(struct mlx4_en_cq *cq)
> +static inline bool mlx4_en_cq_busy_polling(struct mlx4_en_cq *cq)
>  {
>         return false;
>  }
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
