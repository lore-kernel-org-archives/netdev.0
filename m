From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH for bnxt_re V4 15/21] RDMA/bnxt_re: Support post_recv
Date: Tue, 24 Jan 2017 13:59:43 +0200
Message-ID: <20170124115943.GF6005@mtr-leonro.local>
References: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
 <1482320530-5344-16-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="jkO+KyKz7TfD21mV"
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, michael.chan@broadcom.com,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Selvin Xavier <selvin.xavier@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:48756 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750763AbdAXL7m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 06:59:42 -0500
Content-Disposition: inline
In-Reply-To: <1482320530-5344-16-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jkO+KyKz7TfD21mV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Dec 21, 2016 at 03:42:04AM -0800, Selvin Xavier wrote:
> Enables the fastpath verb ib_post_recv.
>
> v3: Fixes sparse warnings
>
> Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
> Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
> ---
>  drivers/infiniband/hw/bnxt_re/ib_verbs.c | 123 +++++++++++++++++++++++++++++++
>  drivers/infiniband/hw/bnxt_re/ib_verbs.h |   2 +
>  drivers/infiniband/hw/bnxt_re/main.c     |   2 +
>  drivers/infiniband/hw/bnxt_re/qplib_fp.c | 100 +++++++++++++++++++++++++
>  drivers/infiniband/hw/bnxt_re/qplib_fp.h |   8 ++
>  5 files changed, 235 insertions(+)
>
> diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.c b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
> index e659490..7476994c 100644
> --- a/drivers/infiniband/hw/bnxt_re/ib_verbs.c
> +++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
> @@ -1637,6 +1637,51 @@ static int bnxt_re_build_qp1_send_v2(struct bnxt_re_qp *qp,
>  	return rc;
>  }
>
> +/* For the MAD layer, it only provides the recv SGE the size of
> + * ib_grh + MAD datagram.  No Ethernet headers, Ethertype, BTH, DETH,
> + * nor RoCE iCRC.  The Cu+ solution must provide buffer for the entire
> + * receive packet (334 bytes) with no VLAN and then copy the GRH
> + * and the MAD datagram out to the provided SGE.
> + */
> +static int bnxt_re_build_qp1_shadow_qp_recv(struct bnxt_re_qp *qp,
> +					    struct ib_recv_wr *wr,
> +					    struct bnxt_qplib_swqe *wqe,
> +					    int payload_size)
> +{
> +	struct bnxt_qplib_sge ref, sge;
> +	u32 rq_prod_index;
> +	struct bnxt_re_sqp_entries *sqp_entry;
> +
> +	rq_prod_index = bnxt_qplib_get_rq_prod_index(&qp->qplib_qp);
> +
> +	if (bnxt_qplib_get_qp1_rq_buf(&qp->qplib_qp, &sge)) {
> +		/* Create 1 SGE to receive the entire
> +		 * ethernet packet
> +		 */
> +		/* Save the reference from ULP */
> +		ref.addr = wqe->sg_list[0].addr;
> +		ref.lkey = wqe->sg_list[0].lkey;
> +		ref.size = wqe->sg_list[0].size;
> +
> +		sqp_entry = &qp->rdev->sqp_tbl[rq_prod_index];
> +
> +		/* SGE 1 */
> +		wqe->sg_list[0].addr = sge.addr;
> +		wqe->sg_list[0].lkey = sge.lkey;
> +		wqe->sg_list[0].size = BNXT_QPLIB_MAX_QP1_RQ_HDR_SIZE_V2;
> +		sge.size -= wqe->sg_list[0].size;
> +
> +		sqp_entry->sge.addr = ref.addr;
> +		sqp_entry->sge.lkey = ref.lkey;
> +		sqp_entry->sge.size = ref.size;
> +		/* Store the wrid for reporting completion */
> +		sqp_entry->wrid = wqe->wr_id;
> +		/* change the wqe->wrid to table index */
> +		wqe->wr_id = rq_prod_index;
> +	}
> +	return 0;
> +}
> +
>  static int is_ud_qp(struct bnxt_re_qp *qp)
>  {
>  	return qp->qplib_qp.type == CMDQ_CREATE_QP_TYPE_UD;
> @@ -1983,6 +2028,84 @@ int bnxt_re_post_send(struct ib_qp *ib_qp, struct ib_send_wr *wr,
>  	return rc;
>  }
>
> +static int bnxt_re_post_recv_shadow_qp(struct bnxt_re_dev *rdev,
> +				       struct bnxt_re_qp *qp,
> +				       struct ib_recv_wr *wr)
> +{
> +	struct bnxt_qplib_swqe wqe;
> +	int rc = 0, payload_sz = 0;
> +
> +	memset(&wqe, 0, sizeof(wqe));
> +	while (wr) {
> +		/* House keeping */
> +		memset(&wqe, 0, sizeof(wqe));
> +
> +		/* Common */
> +		wqe.num_sge = wr->num_sge;
> +		if (wr->num_sge > qp->qplib_qp.rq.max_sge) {
> +			dev_err(rdev_to_dev(rdev),
> +				"Limit exceeded for Receive SGEs");
> +			rc = -EINVAL;
> +			goto bad;

"goto bad" directly to other place in while() to call the "break".
It will be more convenient to call "break" here.


> +		}
> +		payload_sz = bnxt_re_build_sgl(wr->sg_list, wqe.sg_list,
> +					       wr->num_sge);
> +		wqe.wr_id = wr->wr_id;
> +		wqe.type = BNXT_QPLIB_SWQE_TYPE_RECV;
> +
> +		if (!rc)

If we are here, we will always have rc == 0.

> +			rc = bnxt_qplib_post_recv(&qp->qplib_qp, &wqe);
> +bad:
> +		if (rc)
> +			break;
> +
> +		wr = wr->next;
> +	}
> +	bnxt_qplib_post_recv_db(&qp->qplib_qp);
> +	return rc;
> +}

--jkO+KyKz7TfD21mV
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAliHQa8ACgkQ5GN7iDZy
WKcRCw/6AyuTlh4uy/V+0ByWlRrbhn+8ITgjCPkIPNASWD5k9gRGwFu0o5s1Hl4Q
JijCRuL1rCNbgi0DBoe6oPkK0UPWj/RN10TxHeFErKRpWosxrtvSm7PJdmUVp1rd
Hmos4nz8I/0tOHUp2NTUmYVMQk1StQLSbcu8hizk/hRF2DKQfqBFXtmj7Ww8OmuG
CT1i5Uhsa3I1n65zbk5rpn94Dqs206I83/ejeOSEeqvGIIwTzyuZhlxM886S6Kg1
eT7p/eZlNgd7BWhSQPoqxvt12mXkZjQ1PFNUHBUDdL55FkLStm3VT/aRxvqRONqi
MZ4nlango1gyjrHDdnH88QPXg4e42l/Nzrp8ZWDzKDigAhn8mSzKBxN3LFcXxJzE
iOWHuXzRRvQdf9TM1kVhA1oRIPzv5JpYXWVKNK5UkfEof0VUQJ+jOaSXU8rEa13x
1CMb3hwSyXfGpWc2Ic7m+iwRdCvOygzfbk0IrFahI/ORTTaqHmNRGAsg9OCO1+mZ
kwFjFCNRM7DSjX1qNTcBrj762bZeXcFxXHBxB2eW81I+V0WItn/ieA1OfHrcGLlt
TuB61BPK9vRlVIoCL8FqwF16d8NkA1Hm5rt/clE8TUkeznYHwV3UFKPq42jbqvSA
xwq+lItzCU3sGS29OLeoG/v2Mc3iDmk7hgtttfHedC1CFVoi9Z8=
=v03l
-----END PGP SIGNATURE-----

--jkO+KyKz7TfD21mV--
