From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 2/2] Re: net, mellanox mlx4 Fix compile warnings
Date: Tue, 17 Sep 2013 22:25:57 +0300
Message-ID: <CAJZOPZJ5kBW3_NQiw3S-DvDkYonzrW-EgxXdAqRcS1KGUrQu=w@mail.gmail.com>
References: <20130916.212559.252825159014181091.davem@davemloft.net>
	<1379445223-28550-1-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Amir Vadai <amirv@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Prarit Bhargava <prarit@redhat.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:38736 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239Ab3IQTZ6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 15:25:58 -0400
Received: by mail-qc0-f173.google.com with SMTP id c3so3982612qcv.32
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 12:25:57 -0700 (PDT)
In-Reply-To: <1379445223-28550-1-git-send-email-prarit@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 17, 2013 at 10:13 PM, Prarit Bhargava <prarit@redhat.com> w=
rote:
> Fix unitialized variable warnings.
>
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function =91=
mlx4_HW2SW_CQ_wrapper=92:
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:2551:16: error:=
 =91cq=92 may be used uninitialized in this function [-Werror=3Dmaybe-u=
ninitialized]
>   atomic_dec(&cq->mtt->ref_count);
>                 ^
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function =91=
mlx4_HW2SW_SRQ_wrapper=92:
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:2734:17: error:=
 =91srq=92 may be used uninitialized in this function [-Werror=3Dmaybe-=
uninitialized]
>   atomic_dec(&srq->mtt->ref_count);
>
> [v2]: davem suggested making cq_res_start_move_to() return 'cq' as an=
 error
> pointer instead of setting 'cq' by reference.  I also did the same fo=
r srq.

Pravit, as I wrote you earlier on this thread, Jack from our team
maintains this piece (SRIOV resource tracker) of the mlx4 core driver
code, so I am adding him. Dave, as many of us here he might be OOO for
the coming ten days for holiday vacation, so would ask you to please
wait patiently for his ack/nak...

Or.

> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
> Cc: dledford@redhat.com
> Cc: amirv@mellanox.com
> Cc: davem@davemloft.net
> Cc: ogerlitz@mellanox.com
> ---
>  .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   46 ++++++++++=
----------
>  1 file changed, 24 insertions(+), 22 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/=
drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> index dd68763..343206b 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> @@ -1073,8 +1073,9 @@ static int eq_res_start_move_to(struct mlx4_dev=
 *dev, int slave, int index,
>         return err;
>  }
>
> -static int cq_res_start_move_to(struct mlx4_dev *dev, int slave, int=
 cqn,
> -                               enum res_cq_states state, struct res_=
cq **cq)
> +static struct res_cq *cq_res_start_move_to(struct mlx4_dev *dev,
> +                                                 int slave, int cqn,
> +                                                 enum res_cq_states =
state)
>  {
>         struct mlx4_priv *priv =3D mlx4_priv(dev);
>         struct mlx4_resource_tracker *tracker =3D &priv->mfunc.master=
=2Eres_tracker;
> @@ -1117,18 +1118,19 @@ static int cq_res_start_move_to(struct mlx4_d=
ev *dev, int slave, int cqn,
>                         r->com.from_state =3D r->com.state;
>                         r->com.to_state =3D state;
>                         r->com.state =3D RES_CQ_BUSY;
> -                       if (cq)
> -                               *cq =3D r;
> +               } else {
> +                       r =3D ERR_PTR(err);
>                 }
>         }
>
>         spin_unlock_irq(mlx4_tlock(dev));
>
> -       return err;
> +       return r;
>  }
>
> -static int srq_res_start_move_to(struct mlx4_dev *dev, int slave, in=
t index,
> -                                enum res_cq_states state, struct res=
_srq **srq)
> +static struct res_srq *srq_res_start_move_to(struct mlx4_dev *dev, i=
nt slave,
> +                                            int index,
> +                                            enum res_cq_states state=
)
>  {
>         struct mlx4_priv *priv =3D mlx4_priv(dev);
>         struct mlx4_resource_tracker *tracker =3D &priv->mfunc.master=
=2Eres_tracker;
> @@ -1167,14 +1169,14 @@ static int srq_res_start_move_to(struct mlx4_=
dev *dev, int slave, int index,
>                         r->com.from_state =3D r->com.state;
>                         r->com.to_state =3D state;
>                         r->com.state =3D RES_SRQ_BUSY;
> -                       if (srq)
> -                               *srq =3D r;
> +               } else {
> +                       r =3D ERR_PTR(err);
>                 }
>         }
>
>         spin_unlock_irq(mlx4_tlock(dev));
>
> -       return err;
> +       return r;
>  }
>
>  static void res_abort_move(struct mlx4_dev *dev, int slave,
> @@ -2530,9 +2532,9 @@ int mlx4_SW2HW_CQ_wrapper(struct mlx4_dev *dev,=
 int slave,
>         struct res_cq *cq;
>         struct res_mtt *mtt;
>
> -       err =3D cq_res_start_move_to(dev, slave, cqn, RES_CQ_HW, &cq)=
;
> -       if (err)
> -               return err;
> +       cq =3D cq_res_start_move_to(dev, slave, cqn, RES_CQ_HW);
> +       if (IS_ERR(cq))
> +               return PTR_ERR(cq);
>         err =3D get_res(dev, slave, mtt_base, RES_MTT, &mtt);
>         if (err)
>                 goto out_move;
> @@ -2565,9 +2567,9 @@ int mlx4_HW2SW_CQ_wrapper(struct mlx4_dev *dev,=
 int slave,
>         int cqn =3D vhcr->in_modifier;
>         struct res_cq *cq;
>
> -       err =3D cq_res_start_move_to(dev, slave, cqn, RES_CQ_ALLOCATE=
D, &cq);
> -       if (err)
> -               return err;
> +       cq =3D cq_res_start_move_to(dev, slave, cqn, RES_CQ_ALLOCATED=
);
> +       if (IS_ERR(cq))
> +               return PTR_ERR(cq);
>         err =3D mlx4_DMA_wrapper(dev, slave, vhcr, inbox, outbox, cmd=
);
>         if (err)
>                 goto out_move;
> @@ -2709,9 +2711,9 @@ int mlx4_SW2HW_SRQ_wrapper(struct mlx4_dev *dev=
, int slave,
>         if (srqn !=3D (be32_to_cpu(srqc->state_logsize_srqn) & 0xffff=
ff))
>                 return -EINVAL;
>
> -       err =3D srq_res_start_move_to(dev, slave, srqn, RES_SRQ_HW, &=
srq);
> -       if (err)
> -               return err;
> +       srq =3D srq_res_start_move_to(dev, slave, srqn, RES_SRQ_ALLOC=
ATED);
> +       if (IS_ERR(srq))
> +               return PTR_ERR(srq);
>         err =3D get_res(dev, slave, mtt_base, RES_MTT, &mtt);
>         if (err)
>                 goto ex_abort;
> @@ -2748,9 +2750,9 @@ int mlx4_HW2SW_SRQ_wrapper(struct mlx4_dev *dev=
, int slave,
>         int srqn =3D vhcr->in_modifier;
>         struct res_srq *srq;
>
> -       err =3D srq_res_start_move_to(dev, slave, srqn, RES_SRQ_ALLOC=
ATED, &srq);
> -       if (err)
> -               return err;
> +       srq =3D srq_res_start_move_to(dev, slave, srqn, RES_SRQ_ALLOC=
ATED);
> +       if (IS_ERR(srq))
> +               return PTR_ERR(srq);
>         err =3D mlx4_DMA_wrapper(dev, slave, vhcr, inbox, outbox, cmd=
);
>         if (err)
>                 goto ex_abort;
> --
> 1.7.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
