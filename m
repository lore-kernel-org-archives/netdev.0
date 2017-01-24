From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH for bnxt_re V4 20/21] RDMA/bnxt_re: Add QP event handling
Date: Tue, 24 Jan 2017 14:20:08 +0200
Message-ID: <20170124122008.GH6005@mtr-leonro.local>
References: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
 <1482320530-5344-21-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="lrvsYIebpInmECXG"
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, michael.chan@broadcom.com,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Selvin Xavier <selvin.xavier@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:52830 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750792AbdAXMUH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 07:20:07 -0500
Content-Disposition: inline
In-Reply-To: <1482320530-5344-21-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--lrvsYIebpInmECXG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Dec 21, 2016 at 03:42:09AM -0800, Selvin Xavier wrote:
> Implements callback handler for processing Async events related to a QP.
> This patch also implements the control path command completion handling.
>
> v3: Removes unwanted braces
>
> Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
> Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
> ---
>  drivers/infiniband/hw/bnxt_re/qplib_rcfw.c | 47 ++++++++++++++++++++++++++++++
>  1 file changed, 47 insertions(+)
>
> diff --git a/drivers/infiniband/hw/bnxt_re/qplib_rcfw.c b/drivers/infiniband/hw/bnxt_re/qplib_rcfw.c
> index 9144b5a..a000397 100644
> --- a/drivers/infiniband/hw/bnxt_re/qplib_rcfw.c
> +++ b/drivers/infiniband/hw/bnxt_re/qplib_rcfw.c
> @@ -257,6 +257,44 @@ static int bnxt_qplib_process_func_event(struct bnxt_qplib_rcfw *rcfw,
>  	return 0;
>  }
>
> +static int bnxt_qplib_process_qp_event(struct bnxt_qplib_rcfw *rcfw,
> +				       struct creq_qp_event *qp_event)
> +{
> +	struct bnxt_qplib_crsq *crsq = &rcfw->crsq;
> +	struct bnxt_qplib_hwq *cmdq = &rcfw->cmdq;
> +	struct bnxt_qplib_crsqe *crsqe;
> +	u16 cbit, cookie, blocked = 0;
> +	unsigned long flags;
> +	u32 sw_cons;
> +
> +	switch (qp_event->event) {
> +	case CREQ_QP_EVENT_EVENT_QP_ERROR_NOTIFICATION:
> +		break;

it looks like if( ... ) return 0;

> +	default:
> +		/* Command Response */
> +		spin_lock_irqsave(&cmdq->lock, flags);
> +		sw_cons = HWQ_CMP(crsq->cons, crsq);
> +		crsqe = &crsq->crsq[sw_cons];
> +		crsq->cons++;
> +		memcpy(&crsqe->qp_event, qp_event, sizeof(crsqe->qp_event));
> +
> +		cookie = le16_to_cpu(crsqe->qp_event.cookie);
> +		blocked = cookie & RCFW_CMD_IS_BLOCKING;
> +		cookie &= RCFW_MAX_COOKIE_VALUE;
> +		cbit = cookie % RCFW_MAX_OUTSTANDING_CMD;
> +		if (!test_and_clear_bit(cbit, rcfw->cmdq_bitmap))
> +			dev_warn(&rcfw->pdev->dev,
> +				 "QPLIB: CMD bit %d was not requested", cbit);
> +
> +		cmdq->cons += crsqe->req_size;
> +		spin_unlock_irqrestore(&cmdq->lock, flags);
> +		if (!blocked)
> +			wake_up(&rcfw->waitq);
> +		break;
> +	}
> +	return 0;
> +}
> +
>  /* SP - CREQ Completion handlers */
>  static void bnxt_qplib_service_creq(unsigned long data)
>  {
> @@ -280,6 +318,15 @@ static void bnxt_qplib_service_creq(unsigned long data)
>  		type = creqe->type & CREQ_BASE_TYPE_MASK;
>  		switch (type) {
>  		case CREQ_BASE_TYPE_QP_EVENT:
> +			if (!bnxt_qplib_process_qp_event
> +			    (rcfw, (struct creq_qp_event *)creqe))
> +				rcfw->creq_qp_event_processed++;
> +			else {
> +				dev_warn(&rcfw->pdev->dev, "QPLIB: crsqe with");
> +				dev_warn(&rcfw->pdev->dev,
> +					 "QPLIB: type = 0x%x not handled",
> +					 type);
> +			}
>  			break;
>  		case CREQ_BASE_TYPE_FUNC_EVENT:
>  			if (!bnxt_qplib_process_func_event
> --
> 2.5.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--lrvsYIebpInmECXG
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAliHRngACgkQ5GN7iDZy
WKeung//bHske13aUv0nAQzEuYiobnPFFn+xcCuukKe1JBUujqVVnR3tI5lJeYAr
oqcaPGzBs+jzNu55lxfjS9arsSBufqG5De/pxVsSnZA9oBztOFWAqPA4/F3E0Ruo
W1rv9YWH27RizDyd//YZfI+Ej4iYEdcM8mskeHunn9xCOe7yBGTee2e2befSNERL
LpapZRcbGntjXd7IUGijiOCd2PzHX5NXB6coc2T7VyP0xj+LyhtTY7bpcU0YxZrM
YXwXWHgaCVjOHzZjK4acXx1CeDzb4YKRT8n3tDHs205Ihq59CS0mRWplG568KMZV
nJDvFR7DxQgt0CVz8YIF+pcTJHJYJLXhSg49c/k36cKDPg8R6OefMxzmq9cFvoG+
Nu+SmOFymy8GzJIngXXef9O+hEyCnmqe9v6M5ohJCHQNShYyQ6u5DmRaJ2CSS/Sk
RZzCZcG5MRP4+4HgIgkQ7amAfbL0Gn62YkXHhGjQDu8oMQ3Pljfoztk//e+gsQtG
FOlrYYiWvGxg1thHXhilMdh5JdCK2T6nz8v8BA6Wcbl5OVOnAKQP46fQKqyScPIL
6l543Fv4axGj2GkJDaxvgGj5S1XXZIZ5yEXUixpAXaoL34rVfVpstIuq+5VlFPgG
tj1eZMm+RL1kBe7hqrAxQMcCmZGgr1qxGYmzGTnmzLg0PucKuIY=
=zY8F
-----END PGP SIGNATURE-----

--lrvsYIebpInmECXG--
