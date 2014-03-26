From: Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 2/2] cxgb4/iw_cxgb4: Doorbell Drop Avoidance
 Bug Fixes
Date: Wed, 26 Mar 2014 16:49:37 +0100
Message-ID: <1395848977.3297.15.camel@localhost.localdomain>
References: <1394814128-8815-1-git-send-email-hariprasad@chelsio.com>
	 <1394814128-8815-3-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394814128-8815-3-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le vendredi 14 mars 2014 =C3=A0 21:52 +0530, Hariprasad Shenai a =C3=A9=
crit :
> From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>

[...]

> Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
> ---
>  drivers/infiniband/hw/cxgb4/device.c            | 177 ++++++++++++++=
----------
>  drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |   9 +-
>  drivers/infiniband/hw/cxgb4/provider.c          |  43 +++++-
>  drivers/infiniband/hw/cxgb4/qp.c                | 140 +++++++++-----=
-----
>  drivers/infiniband/hw/cxgb4/t4.h                |   6 +
>  drivers/infiniband/hw/cxgb4/user.h              |   5 +
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   1 +
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  87 +++++++-----
>  drivers/net/ethernet/chelsio/cxgb4/sge.c        |   8 +-
>  9 files changed, 286 insertions(+), 190 deletions(-)
>=20

[...]

> diff --git a/drivers/infiniband/hw/cxgb4/provider.c b/drivers/infinib=
and/hw/cxgb4/provider.c
> index 7e94c9a..e36d2a2 100644
> --- a/drivers/infiniband/hw/cxgb4/provider.c
> +++ b/drivers/infiniband/hw/cxgb4/provider.c
> @@ -106,15 +106,54 @@ static struct ib_ucontext *c4iw_alloc_ucontext(=
struct ib_device *ibdev,
>  {
>  	struct c4iw_ucontext *context;
>  	struct c4iw_dev *rhp =3D to_c4iw_dev(ibdev);
> +	static int warned;
> +	struct c4iw_alloc_ucontext_resp uresp;
> +	int ret =3D 0;
> +	struct c4iw_mm_entry *mm =3D NULL;
> =20
>  	PDBG("%s ibdev %p\n", __func__, ibdev);
>  	context =3D kzalloc(sizeof(*context), GFP_KERNEL);
> -	if (!context)
> -		return ERR_PTR(-ENOMEM);
> +	if (!context) {
> +		ret =3D -ENOMEM;
> +		goto err;
> +	}
> +
>  	c4iw_init_dev_ucontext(&rhp->rdev, &context->uctx);
>  	INIT_LIST_HEAD(&context->mmaps);
>  	spin_lock_init(&context->mmap_lock);
> +
> +	if (udata->outlen < sizeof(uresp)) {
> +		if (!warned++)
> +			pr_err(MOD "Warning - downlevel libcxgb4 (non-fatal), device stat=
us page disabled.");
> +		rhp->rdev.flags |=3D T4_STATUS_PAGE_DISABLED;
> +	} else {
> +		mm =3D kmalloc(sizeof(*mm), GFP_KERNEL);
> +		if (!mm)
> +			goto err_free;
> +

OK, that's the origin of the missing error I've noticed in my latest
review on linux-next.

See
<http://marc.info/?i=3D1395846311-29288-1-git-send-email-ydroneaud@opte=
ya.com>
<http://marc.info/?i=3D005b01cf4907$9adfa320$d09ee960
$@opengridcomputing.com>

Sorry, I've missed the opportunity to report it.

> +		uresp.status_page_size =3D PAGE_SIZE;
> +
> +		spin_lock(&context->mmap_lock);
> +		uresp.status_page_key =3D context->key;
> +		context->key +=3D PAGE_SIZE;
> +		spin_unlock(&context->mmap_lock);
> +

Is it really necessary to spinlock here since context is local to the
function ?

> +		ret =3D ib_copy_to_udata(udata, &uresp, sizeof(uresp));
> +		if (ret)
> +			goto err_mm;
> +
> +		mm->key =3D uresp.status_page_key;
> +		mm->addr =3D virt_to_phys(rhp->rdev.status_page);
> +		mm->len =3D PAGE_SIZE;
> +		insert_mmap(context, mm);
> +	}
>  	return &context->ibucontext;
> +err_mm:
> +	kfree(mm);
> +err_free:
> +	kfree(context);
> +err:
> +	return ERR_PTR(ret);
>  }
> =20

[...]

> diff --git a/drivers/infiniband/hw/cxgb4/user.h b/drivers/infiniband/=
hw/cxgb4/user.h
> index 32b754c..11ccd27 100644
> --- a/drivers/infiniband/hw/cxgb4/user.h
> +++ b/drivers/infiniband/hw/cxgb4/user.h
> @@ -70,4 +70,9 @@ struct c4iw_create_qp_resp {
>  	__u32 qid_mask;
>  	__u32 flags;
>  };
> +
> +struct c4iw_alloc_ucontext_resp {
> +	__u64 status_page_key;
> +	__u32 status_page_size;
> +};

If this is going to be part of the ABI, mind add an explicit padding to
align the structure on 64bits.

Regards

--=20
Yann Droneaud
OPTEYA


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
