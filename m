From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 08/15] i40iw: add files for iwarp interface
Date: Thu, 17 Dec 2015 08:27:38 -0800
Message-ID: <20151217162738.GA12875@infradead.org>
References: <1450295919-17292-1-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-2-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-3-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-4-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-5-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-6-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-7-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-8-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-9-git-send-email-faisal.latif@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	e1000-rdma@lists.sourceforge.net
To: Faisal Latif <faisal.latif@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:40494 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755731AbbLQQ1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 11:27:39 -0500
Content-Disposition: inline
In-Reply-To: <1450295919-17292-9-git-send-email-faisal.latif@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +		i40iw_next_iw_state(iwqp, I40IW_QP_STATE_ERROR, 0, 0, 0);
> +
> +	if (!iwqp->user_mode) {
> +		if (iwqp->iwscq)
> +			i40iw_clean_cqes(iwqp, iwqp->iwscq);
> +		if ((iwqp->iwrcq) && (iwqp->iwrcq != iwqp->iwscq))

Please try to do a pass over your code and remove all these pointless
braces.

> +static int i40iw_setup_virt_qp(struct i40iw_device *iwdev,
> +			       struct i40iw_qp *iwqp,
> +			       struct i40iw_qp_init_info *init_info)
> +{
> +	struct i40iw_pbl *iwpbl = iwqp->iwpbl;
> +	struct i40iw_qp_mr *qpmr = &iwpbl->qp_mr;
> +	u64 *sq_base;
> +
> +	sq_base = kmap(qpmr->sq_page);
> +	iwqp->sq_kmapped = 1;


You must never use kmap for any long lived resource.  Just allocate
it it out of lowmem so that you don't need the kmap.

> +	ukinfo->rq = (u64 *)((u8 *)mem->va + (sqdepth * I40IW_QP_WQE_MIN_SIZE));
> +	info->rq_pa = (uintptr_t)((u8 *)mem->pa + (sqdepth * I40IW_QP_WQE_MIN_SIZE));
> +
> +	ukinfo->shadow_area = (u64 *)((u8 *)ukinfo->rq +
> +				      (rqdepth * I40IW_QP_WQE_MIN_SIZE));
> +	info->shadow_area_pa = info->rq_pa + (rqdepth * I40IW_QP_WQE_MIN_SIZE);

Can you please try to get away with less casts here?  Note that Linux does
use GCC extensions for void pointer arithmetics.  Even without that you
never need to use casts to or from void pointers.  All this happes in
lots of places in the code, so a little audit would be useful.

> +/**
> + * i40iw_alloc_mw - Allocate memory window
> + * @ibpd: protection domain
> + * @type: memory window type
> + */
> +static struct ib_mw *i40iw_alloc_mw(struct ib_pd *ibpd,
> +				    enum ib_mw_type type)
> +{
> +	return ERR_PTR(-ENOSYS);
> +}
> +
> +/**
> + * i40iw_dealloc_mw - Free a memory window
> + * @ibmw: memory window to free
> + */
> +static int i40iw_dealloc_mw(struct ib_mw *ibmw)
> +{
> +	return -EIO;
> +}
> +
> +/**
> + * i40iw_bind_mw - Bind a memory window to a qp
> + * @ibqp: queue pair
> + * @ibmw: memory window
> + * @ibmw_bind: pointer to bind structure
> + */
> +static int i40iw_bind_mw(struct ib_qp *ibqp,
> +			 struct ib_mw *ibmw,
> +			 struct ib_mw_bind *ibmw_bind)
> +{
> +	return -ENOSYS;
> +}

There shouldn't be any need to stub all these out.

> +/**
> + * i40iw_init_ofa_device - initialization of iwarp device
> + * @iwdev: iwarp device
> + */
> +static struct i40iw_ib_device *i40iw_init_ofa_device(struct i40iw_device *iwdev)

Where is that weird ofa prefix coming from?

> +	iwibdev->ibdev.reg_phys_mr = i40iw_reg_phys_mr;

Please don't add phys MR support in new drivers, it's about to
disappear.

> +	iwibdev->ibdev.detach_mcast = NULL;
> +	iwibdev->ibdev.attach_mcast = NULL;
> +	iwibdev->ibdev.get_protocol_stats = i40iw_get_protocol_stats;
> +	iwibdev->ibdev.process_mad = NULL;

All the unused fields should already be zeroed.
