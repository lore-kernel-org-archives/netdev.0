From: Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/4] cxgb4/iw_cxgb4: display TPTE on errors
Date: Sun, 13 Jul 2014 14:36:45 +0200
Message-ID: <1405255005.32637.33.camel@localhost.localdomain>
References: <1405091662-5270-1-git-send-email-hariprasad@chelsio.com>
	 <1405091662-5270-4-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405091662-5270-4-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Le vendredi 11 juillet 2014 =C3=A0 20:44 +0530, Hariprasad Shenai a =C3=
=A9crit :
> With ingress WRITE or READ RESPONSE errors, HW provides the offending
> stag from the packet.  This patch adds logic to log the parsed TPTE
> in this case. cxgb4 now exports a function to read a TPTE entry
> from adapter memory.
>=20
> Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
> Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
> ---
>  drivers/infiniband/hw/cxgb4/device.c            |   27 ++++++++--
>  drivers/infiniband/hw/cxgb4/ev.c                |   53 +++++++++++++=
+++--
>  drivers/infiniband/hw/cxgb4/t4.h                |    4 +-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   66 +++++++++++++=
++++++++++
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    1 +
>  5 files changed, 140 insertions(+), 11 deletions(-)
>=20
> diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniban=
d/hw/cxgb4/device.c
> index d2d3dba..e8b79a3 100644
> --- a/drivers/infiniband/hw/cxgb4/device.c
> +++ b/drivers/infiniband/hw/cxgb4/device.c
> @@ -241,12 +241,31 @@ static int dump_stag(int id, void *p, void *dat=
a)
>  	struct c4iw_debugfs_data *stagd =3D data;
>  	int space;
>  	int cc;
> +	struct fw_ri_tpte tpte;
> +	int ret;
> =20
>  	space =3D stagd->bufsize - stagd->pos - 1;
>  	if (space =3D=3D 0)
>  		return 1;
> =20
> -	cc =3D snprintf(stagd->buf + stagd->pos, space, "0x%x\n", id<<8);
> +	ret =3D cxgb4_read_tpte(stagd->devp->rdev.lldi.ports[0], (u32)id<<8=
,
> +			      (__be32 *)&tpte);
> +	if (ret) {
> +		pr_info("%s cxgb4_read_tpte err %d\n", __func__, ret);
> +		return ret;

If it's an error, use pr_err(), and perhaps better, dev_err().

> +	}
> +	cc =3D snprintf(stagd->buf + stagd->pos, space,
> +		      "stag: idx 0x%x valid %d key 0x%x state %d pdid %d "
> +		      "perm 0x%x ps %d len 0x%llx va 0x%llx\n",
> +		      (u32)id<<8,
> +		      G_FW_RI_TPTE_VALID(ntohl(tpte.valid_to_pdid)),
> +		      G_FW_RI_TPTE_STAGKEY(ntohl(tpte.valid_to_pdid)),
> +		      G_FW_RI_TPTE_STAGSTATE(ntohl(tpte.valid_to_pdid)),
> +		      G_FW_RI_TPTE_PDID(ntohl(tpte.valid_to_pdid)),
> +		      G_FW_RI_TPTE_PERM(ntohl(tpte.locread_to_qpid)),
> +		      G_FW_RI_TPTE_PS(ntohl(tpte.locread_to_qpid)),
> +		      ((u64)ntohl(tpte.len_hi) << 32) | ntohl(tpte.len_lo),
> +		      ((u64)ntohl(tpte.va_hi) << 32) | ntohl(tpte.va_lo_fbo));
>  	if (cc < space)
>  		stagd->pos +=3D cc;
>  	return 0;
> @@ -259,7 +278,7 @@ static int stag_release(struct inode *inode, stru=
ct file *file)
>  		printk(KERN_INFO "%s null stagd?\n", __func__);
>  		return 0;
>  	}
> -	kfree(stagd->buf);
> +	vfree(stagd->buf);
>  	kfree(stagd);
>  	return 0;
>  }
> @@ -282,8 +301,8 @@ static int stag_open(struct inode *inode, struct =
file *file)
>  	idr_for_each(&stagd->devp->mmidr, count_idrs, &count);
>  	spin_unlock_irq(&stagd->devp->lock);
> =20
> -	stagd->bufsize =3D count * sizeof("0x12345678\n");
> -	stagd->buf =3D kmalloc(stagd->bufsize, GFP_KERNEL);
> +	stagd->bufsize =3D count * 256;
> +	stagd->buf =3D vmalloc(stagd->bufsize);
>  	if (!stagd->buf) {
>  		ret =3D -ENOMEM;
>  		goto err1;
> diff --git a/drivers/infiniband/hw/cxgb4/ev.c b/drivers/infiniband/hw=
/cxgb4/ev.c
> index d61d0a1..97379f4 100644
> --- a/drivers/infiniband/hw/cxgb4/ev.c
> +++ b/drivers/infiniband/hw/cxgb4/ev.c
> @@ -35,6 +35,53 @@
> =20
>  #include "iw_cxgb4.h"
> =20
> +static void print_tpte(struct c4iw_dev *dev, u32 stag)
> +{
> +	int ret;
> +	struct fw_ri_tpte tpte;
> +
> +	ret =3D cxgb4_read_tpte(dev->rdev.lldi.ports[0], stag,
> +			      (__be32 *)&tpte);
> +	if (ret) {
> +		pr_err("%s cxgb4_read_tpte err %d\n", __func__, ret);

pr_err() is used here. Perhaps dev_err() can be used here too.

> +		return;
> +	}
> +	pr_err("stag idx 0x%x valid %d key 0x%x state %d pdid %d "
> +	       "perm 0x%x ps %d len 0x%llx va 0x%llx\n",
> +	       stag & 0xffffff00,
> +	       G_FW_RI_TPTE_VALID(ntohl(tpte.valid_to_pdid)),
> +	       G_FW_RI_TPTE_STAGKEY(ntohl(tpte.valid_to_pdid)),
> +	       G_FW_RI_TPTE_STAGSTATE(ntohl(tpte.valid_to_pdid)),
> +	       G_FW_RI_TPTE_PDID(ntohl(tpte.valid_to_pdid)),
> +	       G_FW_RI_TPTE_PERM(ntohl(tpte.locread_to_qpid)),
> +	       G_FW_RI_TPTE_PS(ntohl(tpte.locread_to_qpid)),
> +	       ((u64)ntohl(tpte.len_hi) << 32) | ntohl(tpte.len_lo),
> +	       ((u64)ntohl(tpte.va_hi) << 32) | ntohl(tpte.va_lo_fbo));

That's not an error.

Perhaps it's a debug message, then use dev_dbg().

> +}
> +
> +static void dump_err_cqe(struct c4iw_dev *dev, struct t4_cqe *err_cq=
e)
> +{
> +	__be64 *p =3D (void *)err_cqe;
> +
> +	pr_err("AE qpid %d opcode %d status 0x%x "
> +	       "type %d len 0x%x wrid.hi 0x%x wrid.lo 0x%x\n",
> +	       CQE_QPID(err_cqe), CQE_OPCODE(err_cqe),
> +	       CQE_STATUS(err_cqe), CQE_TYPE(err_cqe), ntohl(err_cqe->len),
> +	       CQE_WRID_HI(err_cqe), CQE_WRID_LOW(err_cqe));
> +

You could use dev_err().

> +	pr_err("%016llx %016llx %016llx %016llx\n",
> +	       be64_to_cpu(p[0]), be64_to_cpu(p[1]), be64_to_cpu(p[2]),
> +	       be64_to_cpu(p[3]));
> +

Is it really required to do a "raw dump" of the err_cqe content ?
It looks like a debug message, so use dev_dbg().

> +	/*
> +	 * Ingress WRITE and READ_RESP errors provide
> +	 * the offending stag, so parse and log it.
> +	 */
> +	if (RQ_TYPE(err_cqe) && (CQE_OPCODE(err_cqe) =3D=3D FW_RI_RDMA_WRIT=
E ||
> +				 CQE_OPCODE(err_cqe) =3D=3D FW_RI_READ_RESP))
> +		print_tpte(dev, CQE_WRID_STAG(err_cqe));
> +}
> +
>  static void post_qp_event(struct c4iw_dev *dev, struct c4iw_cq *chp,
>  			  struct c4iw_qp *qhp,
>  			  struct t4_cqe *err_cqe,
> @@ -44,11 +91,7 @@ static void post_qp_event(struct c4iw_dev *dev, st=
ruct c4iw_cq *chp,
>  	struct c4iw_qp_attributes attrs;
>  	unsigned long flag;
> =20
> -	printk(KERN_ERR MOD "AE qpid 0x%x opcode %d status 0x%x "
> -	       "type %d wrid.hi 0x%x wrid.lo 0x%x\n",
> -	       CQE_QPID(err_cqe), CQE_OPCODE(err_cqe),
> -	       CQE_STATUS(err_cqe), CQE_TYPE(err_cqe),
> -	       CQE_WRID_HI(err_cqe), CQE_WRID_LOW(err_cqe));
> +	dump_err_cqe(dev, err_cqe);
> =20
>  	if (qhp->attr.state =3D=3D C4IW_QP_STATE_RTS) {
>  		attrs.next_state =3D C4IW_QP_STATE_TERMINATE;
> diff --git a/drivers/infiniband/hw/cxgb4/t4.h b/drivers/infiniband/hw=
/cxgb4/t4.h
> index e64fa8b..dd45186 100644
> --- a/drivers/infiniband/hw/cxgb4/t4.h
> +++ b/drivers/infiniband/hw/cxgb4/t4.h
> @@ -236,8 +236,8 @@ struct t4_cqe {
>  #define CQE_WRID_SQ_IDX(x)	((x)->u.scqe.cidx)
> =20
>  /* generic accessor macros */
> -#define CQE_WRID_HI(x)		((x)->u.gen.wrid_hi)
> -#define CQE_WRID_LOW(x)		((x)->u.gen.wrid_low)
> +#define CQE_WRID_HI(x)		(be32_to_cpu((x)->u.gen.wrid_hi))
> +#define CQE_WRID_LOW(x)		(be32_to_cpu((x)->u.gen.wrid_low))

Is these accessor macros used elsewhere ?

If yes, changing the endianness should be taken in account.

Perhaps this kink of change should be put in its own commit.

Regards.

--=20
Yann Droneaud
OPTEYA



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
