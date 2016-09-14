From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [PATCH v4 09/16] IB/pvrdma: Add support for Completion Queues
Date: Wed, 14 Sep 2016 15:43:22 +0300
Message-ID: <20160914124321.GE15800@yuval-lap.uk.oracle.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-10-git-send-email-aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, jhansen@vmware.com, asarwade@vmware.com,
        georgezhang@vmware.com, bryantan@vmware.com
To: Adit Ranadive <aditr@vmware.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1473655766-31628-10-git-send-email-aditr@vmware.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 11, 2016 at 09:49:19PM -0700, Adit Ranadive wrote:
> +
> +static int pvrdma_poll_one(struct pvrdma_cq *cq, struct pvrdma_qp **cur_qp,
> +			   struct ib_wc *wc)
> +{
> +	struct pvrdma_dev *dev = to_vdev(cq->ibcq.device);
> +	int has_data;
> +	unsigned int head;
> +	bool tried = false;
> +	struct pvrdma_cqe *cqe;
> +
> +retry:
> +	has_data = pvrdma_idx_ring_has_data(&cq->ring_state->rx,
> +					    cq->ibcq.cqe, &head);
> +	if (has_data == 0) {
> +		if (tried)
> +			return -EAGAIN;
> +
> +		/* Pass down POLL to give physical HCA a chance to poll. */
> +		pvrdma_write_uar_cq(dev, cq->cq_handle | PVRDMA_UAR_CQ_POLL);
> +
> +		tried = true;
> +		goto retry;
> +	} else if (has_data == PVRDMA_INVALID_IDX) {

I didn't went throw the entire life cycle of RX-ring's head and tail but
you need to make sure that PVRDMA_INVALID_IDX error is recoverable one, i.e
there is probability that in the next call to pvrdma_poll_one it will be
fine. Otherwise it is an endless loop.

> +		dev_err(&dev->pdev->dev, "CQ ring state invalid\n");
> +		return -EAGAIN;
> +	}
> +
> +	cqe = get_cqe(cq, head);
> +
> +	/* Ensure cqe is valid. */
> +	rmb();
> +	if (dev->qp_tbl[cqe->qp & 0xffff])
> +		*cur_qp = (struct pvrdma_qp *)dev->qp_tbl[cqe->qp & 0xffff];
> +	else
> +		return -EAGAIN;
> +
> +	wc->opcode = pvrdma_wc_opcode_to_ib(cqe->opcode);
> +	wc->status = pvrdma_wc_status_to_ib(cqe->status);
> +	wc->wr_id = cqe->wr_id;
> +	wc->qp = &(*cur_qp)->ibqp;
> +	wc->byte_len = cqe->byte_len;
> +	wc->ex.imm_data = cqe->imm_data;
> +	wc->src_qp = cqe->src_qp;
> +	wc->wc_flags = pvrdma_wc_flags_to_ib(cqe->wc_flags);
> +	wc->pkey_index = cqe->pkey_index;
> +	wc->slid = cqe->slid;
> +	wc->sl = cqe->sl;
> +	wc->dlid_path_bits = cqe->dlid_path_bits;
> +	wc->port_num = cqe->port_num;
> +	wc->vendor_err = 0;
> +
> +	/* Update shared ring state */
> +	pvrdma_idx_ring_inc(&cq->ring_state->rx.cons_head, cq->ibcq.cqe);
> +
> +	return 0;
> +}
> +
> +/**
> + * pvrdma_poll_cq - poll for work completion queue entries
> + * @ibcq: completion queue
> + * @num_entries: the maximum number of entries
> + * @entry: pointer to work completion array
> + *
> + * @return: number of polled completion entries
> + */
> +int pvrdma_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc)
> +{
> +	struct pvrdma_cq *cq = to_vcq(ibcq);
> +	struct pvrdma_qp *cur_qp = NULL;
> +	unsigned long flags;
> +	int npolled;
> +
> +	if (num_entries < 1 || wc == NULL)
> +		return 0;
> +
> +	spin_lock_irqsave(&cq->cq_lock, flags);
> +	for (npolled = 0; npolled < num_entries; ++npolled) {
> +		if (pvrdma_poll_one(cq, &cur_qp, wc + npolled))
> +			break;
> +	}
> +
> +	spin_unlock_irqrestore(&cq->cq_lock, flags);
> +
> +	/* Ensure we do not return errors from poll_cq */
> +	return npolled;
> +}
> +
> +/**
> + * pvrdma_resize_cq - resize CQ
> + * @ibcq: the completion queue
> + * @entries: CQ entries
> + * @udata: user data
> + *
> + * @return: -EOPNOTSUPP as CQ resize is not supported.
> + */
> +int pvrdma_resize_cq(struct ib_cq *ibcq, int entries, struct ib_udata *udata)
> +{
> +	return -EOPNOTSUPP;
> +}
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
