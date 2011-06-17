From: Bernard Metzler <BMT@zurich.ibm.com>
Subject: Re: [PATCH 05/14] SIWv2: User interface: siw_verbs.h, siw_verbs.c, siw_user.h, siw_ae.c
Date: Fri, 17 Jun 2011 16:14:16 +0200
Message-ID: <OF7426A1EE.BBD67937-ONC12578B2.003B466D-C12578B2.004E3647@ch.ibm.com>
References: <4DFA26FC.5040902@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-rdma@vger.kernel.org, linux-rdma-owner@vger.kernel.org,
	netdev@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:54836 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758969Ab1FQOOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 10:14:45 -0400
In-Reply-To: <4DFA26FC.5040902@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve,
we currently do not support inline data for kernel clients since
we copy those data into a malloc'd buffer, where kmalloc()
might block. Using an explicit buffer comes from experiments
to allow for larger blocks of inlined data.
I could put the inline data directly into the wqe restricting it
to some 200 bytes or less (dependent on wqe size which
is mainly determined by numer of sge's supported).
would that make sense? maybe it would better reflect the
intended nature of inline data - put some bytes out w/o
doing memory registration...

thanks,
Bernard

linux-rdma-owner@vger.kernel.org wrote on 06/16/2011 05:53:32 PM:

>
> <snip>
>
> > +
> > +/*
> > + * siw_create_qp()
> > + *
> > + * Create QP of requested size on given device.
> > + *
> > + * @ofa_pd:   OFA PD contained in siw PD
> > + * @attrs:   Initial QP attributes.
> > + * @udata:   used to provide QP ID, SQ and RQ size back to user.
> > + */
> > +
> > +struct ib_qp *siw_create_qp(struct ib_pd *ofa_pd,
> > +             struct ib_qp_init_attr *attrs,
> > +             struct ib_udata *udata)
> > +{
> > +   struct siw_qp         *qp = NULL;
> > +   struct siw_pd         *pd = siw_pd_ofa2siw(ofa_pd);
> > +   struct ib_device      *ofa_dev = ofa_pd->device;
> > +   struct siw_dev         *dev = siw_dev_ofa2siw(ofa_dev);
> > +   struct siw_cq         *scq = NULL, *rcq = NULL;
> > +   struct siw_iwarp_tx      *c_tx;
> > +   struct siw_iwarp_rx      *c_rx;
> > +   struct siw_uresp_create_qp   uresp;
> > +
> > +   unsigned long flags;
> > +   int kernel_verbs = ofa_pd->uobject ? 0 : 1;
> > +   int rv = 0;
> > +
> > +   dprint(DBG_OBJ|DBG_CM, ": new QP on device %s\n",
> > +      ofa_dev->name);
> > +
> > +   if (atomic_inc_return(&dev->num_qp)>  SIW_MAX_QP) {
> > +      dprint(DBG_ON, ": Out of QP's\n");
> > +      rv = -ENOMEM;
> > +      goto err_out;
> > +   }
> > +   if (attrs->qp_type != IB_QPT_RC) {
> > +      dprint(DBG_ON, ": Only RC QP's supported\n");
> > +      rv = -EINVAL;
> > +      goto err_out;
> > +   }
> > +   if ((attrs->cap.max_send_wr>  SIW_MAX_QP_WR) ||
> > +       (attrs->cap.max_recv_wr>  SIW_MAX_QP_WR) ||
> > +       (attrs->cap.max_send_sge>  SIW_MAX_SGE)  ||
> > +       (attrs->cap.max_recv_sge>  SIW_MAX_SGE)) {
> > +      dprint(DBG_ON, ": QP Size!\n");
> > +      rv = -EINVAL;
> > +      goto err_out;
> > +   }
> > +   if (attrs->cap.max_inline_data>  SIW_MAX_INLINE ||
> > +       (kernel_verbs&&  attrs->cap.max_inline_data != 0)) {
> > +      dprint(DBG_ON, ": Max Inline Send %d>  %d!\n",
> > +             attrs->cap.max_inline_data, SIW_MAX_INLINE);
> > +      rv = -EINVAL;
> > +      goto err_out;
>
> Why no inline support for kernel users?
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

