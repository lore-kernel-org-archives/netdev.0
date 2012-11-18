From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 1/3] mlx4_en: Remove remnants of LRO support
Date: Sun, 18 Nov 2012 11:03:10 +0200
Message-ID: <CAPcc5Pi-xO8D5ndYTo7czuOAKSSMPHzAsvy5UoQ+-j1LVtE1Bw@mail.gmail.com>
References: <1353105635.2743.49.camel@bwh-desktop.uk.solarflarecom.com>
	<1353105896.2743.53.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Roland Dreier <roland@purestorage.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:61591 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321Ab2KRJDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2012 04:03:12 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so581045eek.19
        for <netdev@vger.kernel.org>; Sun, 18 Nov 2012 01:03:11 -0800 (PST)
In-Reply-To: <1353105896.2743.53.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Amir Vadai <amirv@mellanox.com>

On Sat, Nov 17, 2012 at 12:44 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> Commit fa37a9586f92051de03a13e55e5ec3880bb6783e ('mlx4_en: Moving to
> work with GRO') left behind the Kconfig depends/select, some dead
> code and comments referring to LRO.
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> The check for GRO eligibility in mlx4_en_process_rx_cq() should also be
> redundant, but I didn't touch it.
>
> Ben.
>
>  drivers/net/ethernet/mellanox/mlx4/Kconfig   |    3 +--
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c   |    9 +++------
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |   17 -----------------
>  3 files changed, 4 insertions(+), 25 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/ethernet/mellanox/mlx4/Kconfig
> index 5f027f9..eb520ab 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/Kconfig
> +++ b/drivers/net/ethernet/mellanox/mlx4/Kconfig
> @@ -4,9 +4,8 @@
>
>  config MLX4_EN
>         tristate "Mellanox Technologies 10Gbit Ethernet support"
> -       depends on PCI && INET
> +       depends on PCI
>         select MLX4_CORE
> -       select INET_LRO
>         ---help---
>           This driver supports Mellanox Technologies ConnectX Ethernet
>           devices.
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 5aba5ec..f76c967 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -630,7 +630,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>                         if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
>                             (cqe->checksum == cpu_to_be16(0xffff))) {
>                                 ring->csum_ok++;
> -                               /* This packet is eligible for LRO if it is:
> +                               /* This packet is eligible for GRO if it is:
>                                  * - DIX Ethernet (type interpretation)
>                                  * - TCP/IP (v4)
>                                  * - without IP options
> @@ -667,7 +667,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>                                         goto next;
>                                 }
>
> -                               /* LRO not possible, complete processing here */
> +                               /* GRO not possible, complete processing here */
>                                 ip_summed = CHECKSUM_UNNECESSARY;
>                         } else {
>                                 ip_summed = CHECKSUM_NONE;
> @@ -710,11 +710,8 @@ next:
>                 ++cq->mcq.cons_index;
>                 index = (cq->mcq.cons_index) & ring->size_mask;
>                 cqe = &cq->buf[index];
> -               if (++polled == budget) {
> -                       /* We are here because we reached the NAPI budget -
> -                        * flush only pending LRO sessions */
> +               if (++polled == budget)
>                         goto out;
> -               }
>         }
>
>  out:
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index 9d27e42..1809a8b 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -95,8 +95,6 @@
>  #define MLX4_EN_ALLOC_SIZE     PAGE_ALIGN(16384)
>  #define MLX4_EN_ALLOC_ORDER    get_order(MLX4_EN_ALLOC_SIZE)
>
> -#define MLX4_EN_MAX_LRO_DESCRIPTORS    32
> -
>  /* Receive fragment sizes; we use at most 4 fragments (for 9600 byte MTU
>   * and 4K allocations) */
>  enum {
> @@ -290,21 +288,6 @@ struct mlx4_en_rx_ring {
>         unsigned long csum_none;
>  };
>
> -
> -static inline int mlx4_en_can_lro(__be16 status)
> -{
> -       return (status & cpu_to_be16(MLX4_CQE_STATUS_IPV4       |
> -                                    MLX4_CQE_STATUS_IPV4F      |
> -                                    MLX4_CQE_STATUS_IPV6       |
> -                                    MLX4_CQE_STATUS_IPV4OPT    |
> -                                    MLX4_CQE_STATUS_TCP        |
> -                                    MLX4_CQE_STATUS_UDP        |
> -                                    MLX4_CQE_STATUS_IPOK)) ==
> -               cpu_to_be16(MLX4_CQE_STATUS_IPV4 |
> -                           MLX4_CQE_STATUS_IPOK |
> -                           MLX4_CQE_STATUS_TCP);
> -}
> -
>  struct mlx4_en_cq {
>         struct mlx4_cq          mcq;
>         struct mlx4_hwq_resources wqres;
> --
> 1.7.7.6
>
>
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
