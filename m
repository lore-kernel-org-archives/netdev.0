From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V5 for-next 16/21] RDMA/bnxt_re: Support poll_cq verb
Date: Sun, 12 Feb 2017 16:30:51 +0200
Message-ID: <20170212143051.GD14015@mtr-leonro.local>
References: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
 <1486725593-9872-17-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="zS7rBR6csb6tI2e1"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1486725593-9872-17-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--zS7rBR6csb6tI2e1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Feb 10, 2017 at 03:19:48AM -0800, Selvin Xavier wrote:
> Enables the fastpath ib_poll_cq verb.
>
> v2: Fixed sparse warnings
> v3: Fixes endianness related warnings reported by sparse. Also, fixes
>     smatch and checkpatch warnings
> v5: Uses ETH_P_IBOE macro for RoCE ethertype
>
> Signed-off-by: Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> ---
>  drivers/infiniband/hw/bnxt_re/ib_verbs.c | 522 ++++++++++++++++++++++++++++
>  drivers/infiniband/hw/bnxt_re/ib_verbs.h |   1 +
>  drivers/infiniband/hw/bnxt_re/main.c     |  22 +-
>  drivers/infiniband/hw/bnxt_re/qplib_fp.c | 560 ++++++++++++++++++++++++++++++-
>  drivers/infiniband/hw/bnxt_re/qplib_fp.h |   7 +-
>  5 files changed, 1107 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.c b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
> index 54d85bc..33af2e3 100644
> --- a/drivers/infiniband/hw/bnxt_re/ib_verbs.c
> +++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
> @@ -2230,6 +2230,528 @@ struct ib_cq *bnxt_re_create_cq(struct ib_device *ibdev,
>  	return ERR_PTR(rc);
>  }
>
> +static u8 __req_to_ib_wc_status(u8 qstatus)
> +{
> +	switch (qstatus) {
> +	case CQ_REQ_STATUS_OK:
> +		return IB_WC_SUCCESS;
> +	case CQ_REQ_STATUS_BAD_RESPONSE_ERR:
> +		return IB_WC_BAD_RESP_ERR;
> +	case CQ_REQ_STATUS_LOCAL_LENGTH_ERR:
> +		return IB_WC_LOC_LEN_ERR;
> +	case CQ_REQ_STATUS_LOCAL_QP_OPERATION_ERR:
> +		return IB_WC_LOC_QP_OP_ERR;
> +	case CQ_REQ_STATUS_LOCAL_PROTECTION_ERR:
> +		return IB_WC_LOC_PROT_ERR;
> +	case CQ_REQ_STATUS_MEMORY_MGT_OPERATION_ERR:
> +		return IB_WC_GENERAL_ERR;
> +	case CQ_REQ_STATUS_REMOTE_INVALID_REQUEST_ERR:
> +		return IB_WC_REM_INV_REQ_ERR;
> +	case CQ_REQ_STATUS_REMOTE_ACCESS_ERR:
> +		return IB_WC_REM_ACCESS_ERR;
> +	case CQ_REQ_STATUS_REMOTE_OPERATION_ERR:
> +		return IB_WC_REM_OP_ERR;
> +	case CQ_REQ_STATUS_RNR_NAK_RETRY_CNT_ERR:
> +		return IB_WC_RNR_RETRY_EXC_ERR;
> +	case CQ_REQ_STATUS_TRANSPORT_RETRY_CNT_ERR:
> +		return IB_WC_RETRY_EXC_ERR;
> +	case CQ_REQ_STATUS_WORK_REQUEST_FLUSHED_ERR:
> +		return IB_WC_WR_FLUSH_ERR;
> +	default:
> +		return IB_WC_GENERAL_ERR;
> +	}
> +	return 0;
> +}
> +
> +static u8 __rawqp1_to_ib_wc_status(u8 qstatus)
> +{
> +	switch (qstatus) {
> +	case CQ_RES_RAWETH_QP1_STATUS_OK:
> +		return IB_WC_SUCCESS;
> +	case CQ_RES_RAWETH_QP1_STATUS_LOCAL_ACCESS_ERROR:
> +		return IB_WC_LOC_ACCESS_ERR;
> +	case CQ_RES_RAWETH_QP1_STATUS_HW_LOCAL_LENGTH_ERR:
> +		return IB_WC_LOC_LEN_ERR;
> +	case CQ_RES_RAWETH_QP1_STATUS_LOCAL_PROTECTION_ERR:
> +		return IB_WC_LOC_PROT_ERR;
> +	case CQ_RES_RAWETH_QP1_STATUS_LOCAL_QP_OPERATION_ERR:
> +		return IB_WC_LOC_QP_OP_ERR;
> +	case CQ_RES_RAWETH_QP1_STATUS_MEMORY_MGT_OPERATION_ERR:
> +		return IB_WC_GENERAL_ERR;
> +	case CQ_RES_RAWETH_QP1_STATUS_WORK_REQUEST_FLUSHED_ERR:
> +		return IB_WC_WR_FLUSH_ERR;
> +	case CQ_RES_RAWETH_QP1_STATUS_HW_FLUSH_ERR:
> +		return IB_WC_WR_FLUSH_ERR;
> +	default:
> +		return IB_WC_GENERAL_ERR;
> +	}
> +}
> +
> +static u8 __rc_to_ib_wc_status(u8 qstatus)
> +{
> +	switch (qstatus) {
> +	case CQ_RES_RC_STATUS_OK:
> +		return IB_WC_SUCCESS;
> +	case CQ_RES_RC_STATUS_LOCAL_ACCESS_ERROR:
> +		return IB_WC_LOC_ACCESS_ERR;
> +	case CQ_RES_RC_STATUS_LOCAL_LENGTH_ERR:
> +		return IB_WC_LOC_LEN_ERR;
> +	case CQ_RES_RC_STATUS_LOCAL_PROTECTION_ERR:
> +		return IB_WC_LOC_PROT_ERR;
> +	case CQ_RES_RC_STATUS_LOCAL_QP_OPERATION_ERR:
> +		return IB_WC_LOC_QP_OP_ERR;
> +	case CQ_RES_RC_STATUS_MEMORY_MGT_OPERATION_ERR:
> +		return IB_WC_GENERAL_ERR;
> +	case CQ_RES_RC_STATUS_REMOTE_INVALID_REQUEST_ERR:
> +		return IB_WC_REM_INV_REQ_ERR;
> +	case CQ_RES_RC_STATUS_WORK_REQUEST_FLUSHED_ERR:
> +		return IB_WC_WR_FLUSH_ERR;
> +	case CQ_RES_RC_STATUS_HW_FLUSH_ERR:
> +		return IB_WC_WR_FLUSH_ERR;
> +	default:
> +		return IB_WC_GENERAL_ERR;
> +	}
> +}
> +

Why don't you use these defines directly?

Thanks

--zS7rBR6csb6tI2e1
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAligcZsACgkQ5GN7iDZy
WKecsg//esDvBb4y8uDy4QNJ1hxwurPbQjcfBpmguWCIngHhy8OAdhnjJ+lLuYHW
+6YehJk7l51do1qdYfG+YRMx2loiwLjPCpS+2BBnNkPLlgF70wAFHq2Iq80Lkdyr
Av4YBucunmMtej5blQY8JPN4TxXLjEzce6Zt9HWYdx7TUZRso3c8VwtAwDDpJYBP
y4P6XuIeg2APdwGRt5zD0vjMOejYSAri2QsSEUdF8e6rHcHya9xlClvHysqqWRyF
D1dVVu07xbphwiuCkdR3fH+qv9WiClUqfL9q0oQJe/sHkoC8ZTDUeBbJRh68SRzW
ZrQWkbliNNSPENYhhFD+OUvRnWQwsF3jhew4CsG72slke9dU5+wa8FXL08hzwVp3
IECtnAf9IXsd5WTWb+dEC1RpAGAeMddj8gf0ty5S3Px+DH2LoPf/Z4VhDhb2VW33
DdP6iEqt2DE3BAJgN/h0m0fTxT2tFyO0OqFDijcaXtDWpwAxk9hh9ysnluPA6Tfz
6LKDfIWf5wnco8AIoeVaMmp9e6UhOSpCPZKGyP1lbVy4FYMycTJs3jF0/v4j9cZP
CarcBRJ1l3c2aPQRP2iR7SNhno92S3WSBs7ILBFe4nSVM0fjASu6Ul9vvH03c2Oj
FfBVVeCvdfWbJoSDHNE+pKKqXGZO0lF0/2YI24b5Etiek7oFdzg=
=+33p
-----END PGP SIGNATURE-----

--zS7rBR6csb6tI2e1--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
