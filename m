From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH 2/2] net, mellanox mlx4 Fix compile warnings [v4]
Date: Tue, 1 Oct 2013 18:17:42 +0300
Message-ID: <20131001181742.72e603d1@jpm-OptiPlex-GX620>
References: <1380633877-24034-1-git-send-email-prarit@redhat.com>
	<1380633877-24034-2-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dledford@redhat.com, amirv@mellanox.com,
	davem@davemloft.net, ogerlitz@mellanox.com
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:45114 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752803Ab3JAPRr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 11:17:47 -0400
Received: by mail-ee0-f43.google.com with SMTP id e52so3517609eek.16
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 08:17:46 -0700 (PDT)
In-Reply-To: <1380633877-24034-2-git-send-email-prarit@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  1 Oct 2013 09:24:37 -0400
Prarit Bhargava <prarit@redhat.com> wrote:

Hi,

You missed some needed changes (You did not get compile warnings,
because indeed "r" was initialized in the paths below.  However,
in these error paths, "err" was ignored.
You should be setting "r" to the error return values:

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c index
343206b..c4a0a32 100644 ---
a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c +++
b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c @@ -1085,9
+1085,9 @@ static struct res_cq *cq_res_start_move_to(struct mlx4_dev
*dev,
 	spin_lock_irq(mlx4_tlock(dev));
 	r =3D res_tracker_lookup(&tracker->res_tree[RES_CQ], cqn);
 	if (!r)
-               err =3D -ENOENT;
+               r =3D ERR_PTR(-ENOENT);
        else if (r->com.owner !=3D slave)
-               err =3D -EPERM;
+               r =3D ERR_PTR(-EPERM);
        else {
                switch (state) {
                case RES_CQ_BUSY:
@@ -1140,9 +1140,9 @@ static struct res_srq
*srq_res_start_move_to(struct mlx4_dev *dev, int slave,
 	spin_lock_irq(mlx4_tlock(dev));
 	r =3D res_tracker_lookup(&tracker->res_tree[RES_SRQ], index);
 	if (!r)
-               err =3D -ENOENT;
+               r =3D ERR_PTR(-ENOENT);
        else if (r->com.owner !=3D slave)
-               err =3D -EPERM;
+               r =3D ERR_PTR(-EPERM);
        else {
                switch (state) {
                case RES_SRQ_BUSY:

There are also other calls which need to be changed in a similar
fashion (eq_res_start_move_to(), and one or two others -- I'm
surprised that these others did not also generate uninitialized-var
warnings). If we change cq and srq, we should also change the others.

Since we are in the middle of submitting patches which touch the file
"resource_tracker.c", I would really like to hold off on these warning
fixes for a bit, and I'll handle the changes for all the functions at
once to conform (correctly!) to the format suggested by Dave Miller.

 -Jack

> Fix unitialized variable warnings.
>=20
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function
> =E2=80=98mlx4_HW2SW_CQ_wrapper=E2=80=99:
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:2551:16: error:
> =E2=80=98cq=E2=80=99 may be used uninitialized in this function
> [-Werror=3Dmaybe-uninitialized] atomic_dec(&cq->mtt->ref_count); ^
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function
> =E2=80=98mlx4_HW2SW_SRQ_wrapper=E2=80=99:
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:2734:17: error:
> =E2=80=98srq=E2=80=99 may be used uninitialized in this function
> [-Werror=3Dmaybe-uninitialized] atomic_dec(&srq->mtt->ref_count);
>=20
> [v2]: davem suggested making cq_res_start_move_to() return 'cq' as an
> error pointer instead of setting 'cq' by reference.  I also did the
> same for srq.
>=20
> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
> Cc: dledford@redhat.com
> Cc: amirv@mellanox.com
> Cc: davem@davemloft.net
> Cc: ogerlitz@mellanox.com
> Cc: jackm@dev.mellanox.co.il
> ---
>  .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   46
> ++++++++++---------- 1 file changed, 24 insertions(+), 22 deletions(-=
)
>=20
> diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c index
> dd68763..343206b 100644 ---
> a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c +++
> b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c @@ -1073,8
> +1073,9 @@ static int eq_res_start_move_to(struct mlx4_dev *dev, int
> slave, int index, return err; }
> =20
> -static int cq_res_start_move_to(struct mlx4_dev *dev, int slave, int
> cqn,
> -				enum res_cq_states state, struct
> res_cq **cq) +static struct res_cq *cq_res_start_move_to(struct
> mlx4_dev *dev,
> +						  int slave, int cqn,
> +						  enum res_cq_states
> state) {
>  	struct mlx4_priv *priv =3D mlx4_priv(dev);
>  	struct mlx4_resource_tracker *tracker =3D
> &priv->mfunc.master.res_tracker; @@ -1117,18 +1118,19 @@ static int
> cq_res_start_move_to(struct mlx4_dev *dev, int slave, int cqn,
> r->com.from_state =3D r->com.state; r->com.to_state =3D state;
>  			r->com.state =3D RES_CQ_BUSY;
> -			if (cq)
> -				*cq =3D r;
> +		} else {
> +			r =3D ERR_PTR(err);
>  		}
>  	}
> =20
>  	spin_unlock_irq(mlx4_tlock(dev));
> =20
> -	return err;
> +	return r;
>  }
> =20
> -static int srq_res_start_move_to(struct mlx4_dev *dev, int slave,
> int index,
> -				 enum res_cq_states state, struct
> res_srq **srq) +static struct res_srq *srq_res_start_move_to(struct
> mlx4_dev *dev, int slave,
> +					     int index,
> +					     enum res_cq_states
> state) {
>  	struct mlx4_priv *priv =3D mlx4_priv(dev);
>  	struct mlx4_resource_tracker *tracker =3D
> &priv->mfunc.master.res_tracker; @@ -1167,14 +1169,14 @@ static int
> srq_res_start_move_to(struct mlx4_dev *dev, int slave, int index,
> r->com.from_state =3D r->com.state; r->com.to_state =3D state;
>  			r->com.state =3D RES_SRQ_BUSY;
> -			if (srq)
> -				*srq =3D r;
> +		} else {
> +			r =3D ERR_PTR(err);
>  		}
>  	}
> =20
>  	spin_unlock_irq(mlx4_tlock(dev));
> =20
> -	return err;
> +	return r;
>  }
> =20
>  static void res_abort_move(struct mlx4_dev *dev, int slave,
> @@ -2530,9 +2532,9 @@ int mlx4_SW2HW_CQ_wrapper(struct mlx4_dev *dev,
> int slave, struct res_cq *cq;
>  	struct res_mtt *mtt;
> =20
> -	err =3D cq_res_start_move_to(dev, slave, cqn, RES_CQ_HW, &cq);
> -	if (err)
> -		return err;
> +	cq =3D cq_res_start_move_to(dev, slave, cqn, RES_CQ_HW);
> +	if (IS_ERR(cq))
> +		return PTR_ERR(cq);
>  	err =3D get_res(dev, slave, mtt_base, RES_MTT, &mtt);
>  	if (err)
>  		goto out_move;
> @@ -2565,9 +2567,9 @@ int mlx4_HW2SW_CQ_wrapper(struct mlx4_dev *dev,
> int slave, int cqn =3D vhcr->in_modifier;
>  	struct res_cq *cq;
> =20
> -	err =3D cq_res_start_move_to(dev, slave, cqn,
> RES_CQ_ALLOCATED, &cq);
> -	if (err)
> -		return err;
> +	cq =3D cq_res_start_move_to(dev, slave, cqn, RES_CQ_ALLOCATED);
> +	if (IS_ERR(cq))
> +		return PTR_ERR(cq);
>  	err =3D mlx4_DMA_wrapper(dev, slave, vhcr, inbox, outbox, cmd);
>  	if (err)
>  		goto out_move;
> @@ -2709,9 +2711,9 @@ int mlx4_SW2HW_SRQ_wrapper(struct mlx4_dev
> *dev, int slave, if (srqn !=3D (be32_to_cpu(srqc->state_logsize_srqn)=
 &
> 0xffffff)) return -EINVAL;
> =20
> -	err =3D srq_res_start_move_to(dev, slave, srqn, RES_SRQ_HW,
> &srq);
> -	if (err)
> -		return err;
> +	srq =3D srq_res_start_move_to(dev, slave, srqn,
> RES_SRQ_ALLOCATED);
> +	if (IS_ERR(srq))
> +		return PTR_ERR(srq);
>  	err =3D get_res(dev, slave, mtt_base, RES_MTT, &mtt);
>  	if (err)
>  		goto ex_abort;
> @@ -2748,9 +2750,9 @@ int mlx4_HW2SW_SRQ_wrapper(struct mlx4_dev
> *dev, int slave, int srqn =3D vhcr->in_modifier;
>  	struct res_srq *srq;
> =20
> -	err =3D srq_res_start_move_to(dev, slave, srqn,
> RES_SRQ_ALLOCATED, &srq);
> -	if (err)
> -		return err;
> +	srq =3D srq_res_start_move_to(dev, slave, srqn,
> RES_SRQ_ALLOCATED);
> +	if (IS_ERR(srq))
> +		return PTR_ERR(srq);
>  	err =3D mlx4_DMA_wrapper(dev, slave, vhcr, inbox, outbox, cmd);
>  	if (err)
>  		goto ex_abort;
