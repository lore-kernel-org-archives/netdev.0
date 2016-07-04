From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 4 Jul 2016 14:34:15 +0300
Message-ID: <CALzJLG_pXO4pbRdgOe912OGhR-HAUBcTEA9AhChsikSaSSO0Lg@mail.gmail.com>
References: <20160704130722.735f94c9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Daniel Jurgens <danielj@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:34791 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402AbcGDLef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 07:34:35 -0400
Received: by mail-yw0-f194.google.com with SMTP id l125so4907388ywb.1
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 04:34:35 -0700 (PDT)
In-Reply-To: <20160704130722.735f94c9@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 4, 2016 at 6:07 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in:
>
>   drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>
> between commit:
>
>   29429f3300a3 ("net/mlx5e: Timeout if SQ doesn't flush during close")
>
> from the net tree and commit:
>
>   507f0c817f7a ("net/mlx5e: Add TXQ set max rate support")
>
> from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.
>
> --
> Cheers,
> Stephen Rothwell
>
> diff --cc drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index 7a0dca29c642,96ec53a6a595..000000000000
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@@ -39,16 -39,10 +39,17 @@@
>   #include "eswitch.h"
>   #include "vxlan.h"
>
>  +enum {
>  +      MLX5_EN_QP_FLUSH_TIMEOUT_MS     = 5000,
>  +      MLX5_EN_QP_FLUSH_MSLEEP_QUANT   = 20,
>  +      MLX5_EN_QP_FLUSH_MAX_ITER       = MLX5_EN_QP_FLUSH_TIMEOUT_MS /
>  +                                        MLX5_EN_QP_FLUSH_MSLEEP_QUANT,
>  +};
>  +
>   struct mlx5e_rq_param {
> -       u32                        rqc[MLX5_ST_SZ_DW(rqc)];
> -       struct mlx5_wq_param       wq;
> +       u32                     rqc[MLX5_ST_SZ_DW(rqc)];
> +       struct mlx5_wq_param    wq;
> +       bool                    am_enabled;
>   };
>
>   struct mlx5e_sq_param {
> @@@ -574,8 -543,9 +582,10 @@@ static void mlx5e_close_rq(struct mlx5e
>         /* avoid destroying rq before mlx5e_poll_rx_cq() is done with it */
>         napi_synchronize(&rq->channel->napi);
>
> +       cancel_work_sync(&rq->am.work);
> +
>         mlx5e_disable_rq(rq);
>  +      mlx5e_free_rx_descs(rq);
>         mlx5e_destroy_rq(rq);
>   }
>
> @@@ -835,19 -810,12 +853,19 @@@ static void mlx5e_close_sq(struct mlx5e
>                 if (mlx5e_sq_has_room_for(sq, 1))
>                         mlx5e_send_nop(sq, true);
>
>  -              mlx5e_modify_sq(sq, MLX5_SQC_STATE_RDY, MLX5_SQC_STATE_ERR,
>  -                              false, 0);
>  +              err = mlx5e_modify_sq(sq, MLX5_SQC_STATE_RDY,
> -                                     MLX5_SQC_STATE_ERR);
> ++                                    MLX5_SQC_STATE_ERR, false, 0);
>  +              if (err)
>  +                      set_bit(MLX5E_SQ_STATE_TX_TIMEOUT, &sq->state);
>         }


Thanks Stephen, the fixup looks good.

I already notified Dave on those issues and how to fix, see mail
thread "Mellanox 100G mlx5 resiliency and xmit path fixes"

Thanks,
Saeed.
