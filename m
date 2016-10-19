From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [RFC 5/6] qedi: Add support for iSCSI session management.
Date: Wed, 19 Oct 2016 15:28:01 +0200
Message-ID: <20161019132801.eptbf2dpuoilplpd@linux-x5ow.site>
References: <1476853273-22960-1-git-send-email-manish.rangankar@cavium.com>
 <1476853273-22960-6-git-send-email-manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: lduncan@suse.com, cleech@redhat.com, martin.petersen@oracle.com,
        jejb@linux.vnet.ibm.com, linux-scsi@vger.kernel.org,
        netdev@vger.kernel.org, Yuval.Mintz@cavium.com,
        QLogic-Storage-Upstream@cavium.com,
        Nilesh Javali <nilesh.javali@cavium.com>,
        Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>,
        Chad Dupuis <chad.dupuis@cavium.com>,
        Saurav Kashyap <saurav.kashyap@cavium.com>,
        Arun Easi <arun.easi@cavium.com>
To: manish.rangankar@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42944 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S942494AbcJSOnx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Oct 2016 10:43:53 -0400
Content-Disposition: inline
In-Reply-To: <1476853273-22960-6-git-send-email-manish.rangankar@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2016 at 01:01:12AM -0400, manish.rangankar@cavium.com wrote:
> From: Manish Rangankar <manish.rangankar@cavium.com>
> 
> This patch adds support for iscsi_transport LLD Login,
> Logout, NOP-IN/NOP-OUT, Async, Reject PDU processing
> and Firmware async event handling support.
> 
> Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
> Signed-off-by: Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>
> Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
> Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
> Signed-off-by: Arun Easi <arun.easi@cavium.com>
> Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
> ---

[...]

> +void qedi_iscsi_unmap_sg_list(struct qedi_cmd *cmd)
> +{
> +	struct scsi_cmnd *sc = cmd->scsi_cmd;
> +
> +	if (cmd->io_tbl.sge_valid && sc) {
> +		scsi_dma_unmap(sc);
> +		cmd->io_tbl.sge_valid = 0;
> +	}
> +}

Maybe set sge_valid to 0 and then call scsi_dma_unmap(). I don't know if it's
really racy but it looks like it is.

[...]

> +static void qedi_process_text_resp(struct qedi_ctx *qedi,
> +				   union iscsi_cqe *cqe,
> +				   struct iscsi_task *task,
> +				   struct qedi_conn *qedi_conn)
> +{
> +	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
> +	struct iscsi_session *session = conn->session;
> +	struct iscsi_task_context *task_ctx;
> +	struct iscsi_text_rsp *resp_hdr_ptr;
> +	struct iscsi_text_response_hdr *cqe_text_response;
> +	struct qedi_cmd *cmd;
> +	int pld_len;
> +	u32 *tmp;
> +
> +	cmd = (struct qedi_cmd *)task->dd_data;
> +	task_ctx = (struct iscsi_task_context *)qedi_get_task_mem(&qedi->tasks,
> +								  cmd->task_id);

No need to cast here, qedi_get_task_mem() returns void *.

[...]

> +	cqe_login_response = &cqe->cqe_common.iscsi_hdr.login_response;
> +	task_ctx = (struct iscsi_task_context *)qedi_get_task_mem(&qedi->tasks,
> +							  cmd->task_id);

Same here.

[...]

> +	}
> +
> +	pbl = (struct scsi_bd *)qedi->bdq_pbl;
> +	pbl += (qedi->bdq_prod_idx % qedi->rq_num_entries);
> +	pbl->address.hi =
> +		      cpu_to_le32((u32)(((u64)(qedi->bdq[idx].buf_dma)) >> 32));
> +	pbl->address.lo =
> +			cpu_to_le32(((u32)(((u64)(qedi->bdq[idx].buf_dma)) &
> +					    0xffffffff)));

Is this LISP or C?

> +	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
> +		  "pbl [0x%p] pbl->address hi [0x%llx] lo [0x%llx] idx [%d]\n",
> +		  pbl, pbl->address.hi, pbl->address.lo, idx);
> +	pbl->opaque.hi = cpu_to_le32((u32)(((u64)0) >> 32));

Isn't this plain pbl->opaque.hi = 0; ?

> +	pbl->opaque.lo = cpu_to_le32(((u32)(((u64)idx) & 0xffffffff)));
> +

[...]

> +	switch (comp_type) {
> +	case ISCSI_CQE_TYPE_SOLICITED:
> +	case ISCSI_CQE_TYPE_SOLICITED_WITH_SENSE:
> +		fw_task_ctx =
> +		  (struct iscsi_task_context *)qedi_get_task_mem(&qedi->tasks,
> +						      cqe->cqe_solicited.itid);

Again, no cast needed.

[...]

> +	writel(*(u32 *)&dbell, qedi_conn->ep->p_doorbell);
> +	/* Make sure fw idx is coherent */
> +	wmb();
> +	mmiowb();

Isn't either wmb() or mmiowb() enough?

[..]

> +
> +	fw_task_ctx =
> +	     (struct iscsi_task_context *)qedi_get_task_mem(&qedi->tasks, tid);

Cast again.

[...]

> +	fw_task_ctx =
> +	     (struct iscsi_task_context *)qedi_get_task_mem(&qedi->tasks, tid);

^^

[...]

> +	fw_task_ctx =
> +	(struct iscsi_task_context *)qedi_get_task_mem(&qedi->tasks, tid);


[...]

> +	fw_task_ctx =
> +	      (struct iscsi_task_context *)qedi_get_task_mem(&qedi->tasks, tid);
> +

[...]

> +
> +	qedi = (struct qedi_ctx *)iscsi_host_priv(shost);

Same goes for iscsi_host_priv();

[...]

> +	ret = wait_event_interruptible_timeout(qedi_ep->ofld_wait,
> +					       ((qedi_ep->state ==
> +						EP_STATE_OFLDCONN_FAILED) ||
> +						(qedi_ep->state ==
> +						EP_STATE_OFLDCONN_COMPL)),
> +						msecs_to_jiffies(timeout_ms));

Maybe:
#define QEDI_OLDCON_STATE(q) ((q)->state == EP_STATE_OFLDCONN_FAILED || \
				(q)->state == EP_STATE_OFLDCONN_COMPL)

ret = wait_event_interruptible_timeout(qedi_ep->ofld_wait,
					QEDI_OLDCON_STATE(qedi_ep),
					msec_to_jiffies(timeout_ms));

But that could be just me hating linewraps.

[...]

Thanks,
	Johannes

-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: Felix Imendörffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nürnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
