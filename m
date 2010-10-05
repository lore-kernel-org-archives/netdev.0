From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH] SIW: Object management
Date: Tue, 05 Oct 2010 09:26:48 -0500
Message-ID: <4CAB35A8.6080906@opengridcomputing.com>
References: <1286261665-5175-1-git-send-email-bmt@zurich.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
To: Bernard Metzler <bmt@zurich.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:46906 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753311Ab0JEO0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 10:26:53 -0400
In-Reply-To: <1286261665-5175-1-git-send-email-bmt@zurich.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2010 01:54 AM, Bernard Metzler wrote:

<snip>+
> +
> +/***** routines for WQE handling ***/
> +
> +/*
> + * siw_wqe_get()
> + *
> + * Get new WQE. For READ RESPONSE, take it from the free list which
> + * has a maximum size of maximum inbound READs. All other WQE are
> + * malloc'ed which creates some overhead. Consider change to
> + *
> + * 1. malloc WR only if it cannot be synchonously completed, or
> + * 2. operate own cache of reuseable WQE's.
> + *
> + * Current code trusts on malloc efficiency.
> + */
> +inline struct siw_wqe *siw_wqe_get(struct siw_qp *qp, enum siw_wr_opcode op)
> +{
> +	struct siw_wqe *wqe;
> +
> +	if (op == SIW_WR_RDMA_READ_RESP) {
> +		spin_lock(&qp->freelist_lock);
> +		if (!(list_empty(&qp->wqe_freelist))) {
> +			wqe = list_entry(qp->wqe_freelist.next,
> +					 struct siw_wqe, list);
> +			list_del(&wqe->list);
> +			spin_unlock(&qp->freelist_lock);
> +			wqe->processed = 0;
> +			dprint(DBG_OBJ|DBG_WR,
> +				"(QP%d): WQE from FreeList p: %p\n",
> +				QP_ID(qp), wqe);
> +		} else {
> +			spin_unlock(&qp->freelist_lock);
> +			wqe = NULL;
> +			dprint(DBG_ON|DBG_OBJ|DBG_WR,
> +				"(QP%d): FreeList empty!\n", QP_ID(qp));
> +		}
> +	} else {
> +		wqe = kzalloc(sizeof(struct siw_wqe), GFP_KERNEL);
> +		dprint(DBG_OBJ|DBG_WR, "(QP%d): New WQE p: %p\n",
> +			QP_ID(qp), wqe);
> +	}
>    

I think you can't allocate at GFP_KERNEL here if this is called from the 
post_ functions.  I think you might want to pre-allocate these when you 
create the QP...


Steve.
