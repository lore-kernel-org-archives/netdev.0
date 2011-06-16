From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: Re: [PATCH 05/14] SIWv2: User interface: siw_verbs.h, siw_verbs.c,
 siw_user.h, siw_ae.c
Date: Thu, 16 Jun 2011 10:53:32 -0500
Message-ID: <4DFA26FC.5040902@opengridcomputing.com>
References: <1308228127-22634-1-git-send-email-bmt@zurich.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1308228127-22634-1-git-send-email-bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


<snip>

> +
> +/*
> + * siw_create_qp()
> + *
> + * Create QP of requested size on given device.
> + *
> + * @ofa_pd:	OFA PD contained in siw PD
> + * @attrs:	Initial QP attributes.
> + * @udata:	used to provide QP ID, SQ and RQ size back to user.
> + */
> +
> +struct ib_qp *siw_create_qp(struct ib_pd *ofa_pd,
> +			    struct ib_qp_init_attr *attrs,
> +			    struct ib_udata *udata)
> +{
> +	struct siw_qp			*qp = NULL;
> +	struct siw_pd			*pd = siw_pd_ofa2siw(ofa_pd);
> +	struct ib_device		*ofa_dev = ofa_pd->device;
> +	struct siw_dev			*dev = siw_dev_ofa2siw(ofa_dev);
> +	struct siw_cq			*scq = NULL, *rcq = NULL;
> +	struct siw_iwarp_tx		*c_tx;
> +	struct siw_iwarp_rx		*c_rx;
> +	struct siw_uresp_create_qp	uresp;
> +
> +	unsigned long flags;
> +	int kernel_verbs = ofa_pd->uobject ? 0 : 1;
> +	int rv = 0;
> +
> +	dprint(DBG_OBJ|DBG_CM, ": new QP on device %s\n",
> +		ofa_dev->name);
> +
> +	if (atomic_inc_return(&dev->num_qp)>  SIW_MAX_QP) {
> +		dprint(DBG_ON, ": Out of QP's\n");
> +		rv = -ENOMEM;
> +		goto err_out;
> +	}
> +	if (attrs->qp_type != IB_QPT_RC) {
> +		dprint(DBG_ON, ": Only RC QP's supported\n");
> +		rv = -EINVAL;
> +		goto err_out;
> +	}
> +	if ((attrs->cap.max_send_wr>  SIW_MAX_QP_WR) ||
> +	    (attrs->cap.max_recv_wr>  SIW_MAX_QP_WR) ||
> +	    (attrs->cap.max_send_sge>  SIW_MAX_SGE)  ||
> +	    (attrs->cap.max_recv_sge>  SIW_MAX_SGE)) {
> +		dprint(DBG_ON, ": QP Size!\n");
> +		rv = -EINVAL;
> +		goto err_out;
> +	}
> +	if (attrs->cap.max_inline_data>  SIW_MAX_INLINE ||
> +	    (kernel_verbs&&  attrs->cap.max_inline_data != 0)) {
> +		dprint(DBG_ON, ": Max Inline Send %d>  %d!\n",
> +		       attrs->cap.max_inline_data, SIW_MAX_INLINE);
> +		rv = -EINVAL;
> +		goto err_out;

Why no inline support for kernel users?


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
