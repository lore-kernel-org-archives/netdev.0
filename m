From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next V1 08/12] net/mlx5e: Move to checksum complete
Date: Thu, 18 Feb 2016 18:25:23 -0800
Message-ID: <CALx6S36MtF+Z44_ti57tJ+RMKNehTLYW18HfAHsvGJpUDXty4g@mail.gmail.com>
References: <1455791573-5270-1-git-send-email-saeedm@mellanox.com>
	<1455791573-5270-9-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34215 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947163AbcBSCZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 21:25:24 -0500
Received: by mail-ig0-f173.google.com with SMTP id g6so28809101igt.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 18:25:24 -0800 (PST)
In-Reply-To: <1455791573-5270-9-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 18, 2016 at 2:32 AM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> From: Matthew Finlay <matt@mellanox.com>
>
> Use checksum complete for all IP packets, unless they are HW LRO,
> in which case, use checksum unnecessary.
>
Awesome! Thanks for this fix.


> Signed-off-by: Matt Finlay <matt@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en_rx.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> index dd959d9..519a07f 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> @@ -167,14 +167,15 @@ static inline bool is_first_ethertype_ip(struct sk_buff *skb)
>  static inline void mlx5e_handle_csum(struct net_device *netdev,
>                                      struct mlx5_cqe64 *cqe,
>                                      struct mlx5e_rq *rq,
> -                                    struct sk_buff *skb)
> +                                    struct sk_buff *skb,
> +                                    bool   lro)
>  {
>         if (unlikely(!(netdev->features & NETIF_F_RXCSUM)))
>                 goto csum_none;
>
> -       if (likely(cqe->hds_ip_ext & CQE_L4_OK)) {
> +       if (lro) {
>                 skb->ip_summed = CHECKSUM_UNNECESSARY;
> -       } else if (is_first_ethertype_ip(skb)) {
> +       } else if (likely(is_first_ethertype_ip(skb))) {
>                 skb->ip_summed = CHECKSUM_COMPLETE;
>                 skb->csum = csum_unfold((__force __sum16)cqe->check_sum);
>                 rq->stats.csum_sw++;
> @@ -211,7 +212,7 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
>         if (unlikely(mlx5e_rx_hw_stamp(tstamp)))
>                 mlx5e_fill_hwstamp(tstamp, get_cqe_ts(cqe), skb_hwtstamps(skb));
>
> -       mlx5e_handle_csum(netdev, cqe, rq, skb);
> +       mlx5e_handle_csum(netdev, cqe, rq, skb, !!lro_num_seg);
>
>         skb->protocol = eth_type_trans(skb, netdev);
>
> --
> 1.7.1
>
