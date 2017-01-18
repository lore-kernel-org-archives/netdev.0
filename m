From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH for bnxt_re V4 10/21] RDMA/bnxt_re: Support for CQ verbs
Date: Wed, 18 Jan 2017 10:19:15 +0200
Message-ID: <20170118081915.GU32481@mtr-leonro.local>
References: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
 <1482320530-5344-11-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="JMCz+drDJ1SjddZX"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1482320530-5344-11-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--JMCz+drDJ1SjddZX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Dec 21, 2016 at 03:41:59AM -0800, Selvin Xavier wrote:
> Implements support for create_cq, destroy_cq and req_notify_cq
> verbs.
>
> v3: Code cleanup based on errors reported by sparse on endianness check.
>     Removes unwanted macros.
>
> Signed-off-by: Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> ---
>  drivers/infiniband/hw/bnxt_re/ib_verbs.c | 146 +++++++++++++++++++++++++
>  drivers/infiniband/hw/bnxt_re/ib_verbs.h |  19 ++++
>  drivers/infiniband/hw/bnxt_re/main.c     |   4 +
>  drivers/infiniband/hw/bnxt_re/qplib_fp.c | 181 +++++++++++++++++++++++++++++++
>  drivers/infiniband/hw/bnxt_re/qplib_fp.h |  50 +++++++++
>  include/uapi/rdma/bnxt_re-abi.h          |  12 ++
>  6 files changed, 412 insertions(+)
>
> diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.c b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
> index b09c2cb..e12e0c2 100644
> --- a/drivers/infiniband/hw/bnxt_re/ib_verbs.c
> +++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
> @@ -492,6 +492,152 @@ struct ib_pd *bnxt_re_alloc_pd(struct ib_device *ibdev,
>  	return ERR_PTR(rc);
>  }
>
> +/* Completion Queues */
> +int bnxt_re_destroy_cq(struct ib_cq *ib_cq)
> +{
> +	struct bnxt_re_cq *cq = container_of(ib_cq, struct bnxt_re_cq, ib_cq);
> +	struct bnxt_re_dev *rdev = cq->rdev;
> +	int rc;
> +
> +	rc = bnxt_qplib_destroy_cq(&rdev->qplib_res, &cq->qplib_cq);
> +	if (rc) {
> +		dev_err(rdev_to_dev(rdev), "Failed to destroy HW CQ");
> +		return rc;
> +	}
> +	if (cq->umem && !IS_ERR(cq->umem))
> +		ib_umem_release(cq->umem);
> +
> +	if (cq) {
> +		kfree(cq->cql);
> +		kfree(cq);
> +	}
> +	atomic_dec(&rdev->cq_count);
> +	rdev->nq.budget--;
> +	return 0;
> +}
> +
> +struct ib_cq *bnxt_re_create_cq(struct ib_device *ibdev,
> +				const struct ib_cq_init_attr *attr,
> +				struct ib_ucontext *context,
> +				struct ib_udata *udata)
> +{
> +	struct bnxt_re_dev *rdev = to_bnxt_re_dev(ibdev, ibdev);
> +	struct bnxt_qplib_dev_attr *dev_attr = &rdev->dev_attr;
> +	struct bnxt_re_cq *cq = NULL;
> +	int rc, entries;
> +	int cqe = attr->cqe;
> +
> +	/* Validate CQ fields */
> +	if (cqe < 1 || cqe > dev_attr->max_cq_wqes) {
> +		dev_err(rdev_to_dev(rdev), "Failed to create CQ -max exceeded");
> +		return ERR_PTR(-EINVAL);
> +	}
> +	cq = kzalloc(sizeof(*cq), GFP_KERNEL);
> +	if (!cq)
> +		return ERR_PTR(-ENOMEM);
> +
> +	cq->rdev = rdev;
> +	cq->qplib_cq.cq_handle = (u64)(unsigned long)(&cq->qplib_cq);
> +
> +	entries = roundup_pow_of_two(cqe + 1);
> +	if (entries > dev_attr->max_cq_wqes + 1)
> +		entries = dev_attr->max_cq_wqes + 1;
> +
> +	if (context) {
> +		struct bnxt_re_cq_req req;
> +		struct bnxt_re_ucontext *uctx = container_of
> +						(context,
> +						 struct bnxt_re_ucontext,
> +						 ib_uctx);
> +		if (ib_copy_from_udata(&req, udata, sizeof(req))) {
> +			rc = -EFAULT;
> +			goto fail;
> +		}
> +
> +		cq->umem = ib_umem_get(context, req.cq_va,
> +				       entries * sizeof(struct cq_base),
> +				       IB_ACCESS_LOCAL_WRITE, 1);
> +		if (IS_ERR(cq->umem)) {
> +			rc = PTR_ERR(cq->umem);
> +			goto fail;
> +		}
> +		cq->qplib_cq.sghead = cq->umem->sg_head.sgl;
> +		cq->qplib_cq.nmap = cq->umem->nmap;
> +		cq->qplib_cq.dpi = uctx->dpi;
> +	} else {
> +		cq->max_cql = entries > MAX_CQL_PER_POLL ? MAX_CQL_PER_POLL :
> +					entries;

It is better to use already existing macros - min()
cq->max_cql = min(entries, MAX_CQL_PER_POLL);

I afraid that you can't avoid the respinning, you have more than month
till merge window.

Can you please remove useless wrappers and try to reuse kernel macros?

Thanks

--JMCz+drDJ1SjddZX
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh/JQMACgkQ5GN7iDZy
WKelkxAAnB33cz7eKZREROx8HGo4leocC42roL1I994J6JV6hjIA0HgfHizmgkLA
+p9pqrSXXD7NpYSMiBD35FBWewoLfyAXUtCorv1BrOmbQWQOlE3MlPyRM22QtMtx
riMke/i027w0NWfj5hZAlhHabTorybWpH5LaiAoQPUWKw9OUV5fPPFWpPOjm8V0d
62wZ56OTw65sBiUn7kBMvz3EtGA3QGg9eerqiNeMty2yBf2jdi7lteLYkP2eRfNf
kp61t8l293FJJzwoWYw95mwvxYgKIPkw1t+KkZ1ug+nkbFlLSpkw08Pg01P+SOTn
jfb/XHwXs0PBZBKViwjyxnWsKgTcLc21dSCbEk9w7b6WVs/McpCqViHBtSnB4eLL
Saa7uzoT8a2YNmpHGeZ4FsWb2Mfj4QPcuptm8K8LPp0yltMzfKfmX74GJ2fsGXA8
WTJF0AiQDhlCdTiQlJfEnv+rxmzq7LmUOFO3N+hhcdDse62BvcwajMm/GSX9LqwT
ZHDpy791s7+rR+ko4Qv5YYgXCzGp2GJ9/+d6J5M9bV7Duy8hudDd9ToMDGI829Wm
nOyTfEq07XfRlkBoTgKFKXh55tUygbJsvtSjF66Zg3Fsi2w/vEQQPCwyIbGizuNs
cmewQP0X/Lpha7kJhws2OF2hfLQrs2xIo+GSTuvCbawll2nifRU=
=veO0
-----END PGP SIGNATURE-----

--JMCz+drDJ1SjddZX--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
