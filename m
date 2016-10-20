From: "Rangankar, Manish" <Manish.Rangankar@cavium.com>
Subject: Re: [RFC 5/6] qedi: Add support for iSCSI session management.
Date: Thu, 20 Oct 2016 09:12:40 +0000
Message-ID: <D42E87DE.34132%manish.rangankar@cavium.com>
References: <1476853273-22960-1-git-send-email-manish.rangankar@cavium.com>
 <1476853273-22960-6-git-send-email-manish.rangankar@cavium.com>
 <20161019132801.eptbf2dpuoilplpd@linux-x5ow.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "lduncan@suse.com" <lduncan@suse.com>,
        "cleech@redhat.com" <cleech@redhat.com>,
        "martin.petersen@oracle.com" <martin.petersen@oracle.com>,
        "jejb@linux.vnet.ibm.com" <jejb@linux.vnet.ibm.com>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "Dept-Eng QLogic Storage Upstream"
        <QLogic-Storage-Upstream@cavium.com>,
        "Javali, Nilesh" <Nilesh.Javali@cavium.com>,
        Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>,
        "Dupuis, Chad" <Chad.Dupuis@cavium.com>,
        "Kashyap, Saurav" <Saurav.Kashyap@cavium.com>,
        "Easi, Arun" <Arun.Easi@cavium.com>
To: Johannes Thumshirn <jthumshirn@suse.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20161019132801.eptbf2dpuoilplpd@linux-x5ow.site>
Content-Language: en-US
Content-ID: <A3F470EB09CA3844BA91697D5E2DFD49@namprd07.prod.outlook.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 19/10/16 6:58 PM, "Johannes Thumshirn" <jthumshirn@suse.de> wrote:

>On Wed, Oct 19, 2016 at 01:01:12AM -0400, manish.rangankar@cavium.com
>wrote:
>> From: Manish Rangankar <manish.rangankar@cavium.com>
>>=20
>> This patch adds support for iscsi_transport LLD Login,
>> Logout, NOP-IN/NOP-OUT, Async, Reject PDU processing
>> and Firmware async event handling support.
>>=20
>> Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
>> Signed-off-by: Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>
>> Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
>> Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
>> Signed-off-by: Arun Easi <arun.easi@cavium.com>
>> Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
>> ---
>
>[...]
>
>> +void qedi_iscsi_unmap_sg_list(struct qedi_cmd *cmd)
>> +{
>> +	struct scsi_cmnd *sc =3D cmd->scsi_cmd;
>> +
>> +	if (cmd->io_tbl.sge_valid && sc) {
>> +		scsi_dma_unmap(sc);
>> +		cmd->io_tbl.sge_valid =3D 0;
>> +	}
>> +}
>
>Maybe set sge_valid to 0 and then call scsi_dma_unmap(). I don't know if
>it's
>really racy but it looks like it is.
>
>[...]
>
>> +static void qedi_process_text_resp(struct qedi_ctx *qedi,
>> +				   union iscsi_cqe *cqe,
>> +				   struct iscsi_task *task,
>> +				   struct qedi_conn *qedi_conn)
>> +{
>> +	struct iscsi_conn *conn =3D qedi_conn->cls_conn->dd_data;
>> +	struct iscsi_session *session =3D conn->session;
>> +	struct iscsi_task_context *task_ctx;
>> +	struct iscsi_text_rsp *resp_hdr_ptr;
>> +	struct iscsi_text_response_hdr *cqe_text_response;
>> +	struct qedi_cmd *cmd;
>> +	int pld_len;
>> +	u32 *tmp;
>> +
>> +	cmd =3D (struct qedi_cmd *)task->dd_data;
>> +	task_ctx =3D (struct iscsi_task_context
>>*)qedi_get_task_mem(&qedi->tasks,
>> +								  cmd->task_id);
>
>No need to cast here, qedi_get_task_mem() returns void *.
>
>[...]
>
>> +	cqe_login_response =3D &cqe->cqe_common.iscsi_hdr.login_response;
>> +	task_ctx =3D (struct iscsi_task_context
>>*)qedi_get_task_mem(&qedi->tasks,
>> +							  cmd->task_id);
>
>Same here.
>
>[...]
>
>> +	}
>> +
>> +	pbl =3D (struct scsi_bd *)qedi->bdq_pbl;
>> +	pbl +=3D (qedi->bdq_prod_idx % qedi->rq_num_entries);
>> +	pbl->address.hi =3D
>> +		      cpu_to_le32((u32)(((u64)(qedi->bdq[idx].buf_dma)) >> 32));
>> +	pbl->address.lo =3D
>> +			cpu_to_le32(((u32)(((u64)(qedi->bdq[idx].buf_dma)) &
>> +					    0xffffffff)));
>
>Is this LISP or C?
>
>> +	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
>> +		  "pbl [0x%p] pbl->address hi [0x%llx] lo [0x%llx] idx [%d]\n",
>> +		  pbl, pbl->address.hi, pbl->address.lo, idx);
>> +	pbl->opaque.hi =3D cpu_to_le32((u32)(((u64)0) >> 32));
>
>Isn't this plain pbl->opaque.hi =3D 0; ?
>
>> +	pbl->opaque.lo =3D cpu_to_le32(((u32)(((u64)idx) & 0xffffffff)));
>> +
>
>[...]
>
>> +	switch (comp_type) {
>> +	case ISCSI_CQE_TYPE_SOLICITED:
>> +	case ISCSI_CQE_TYPE_SOLICITED_WITH_SENSE:
>> +		fw_task_ctx =3D
>> +		  (struct iscsi_task_context *)qedi_get_task_mem(&qedi->tasks,
>> +						      cqe->cqe_solicited.itid);
>
>Again, no cast needed.
>
>[...]
>
>> +	writel(*(u32 *)&dbell, qedi_conn->ep->p_doorbell);
>> +	/* Make sure fw idx is coherent */
>> +	wmb();
>> +	mmiowb();
>
>Isn't either wmb() or mmiowb() enough?
>
>[..]
>
>> +
>> +	fw_task_ctx =3D
>> +	     (struct iscsi_task_context *)qedi_get_task_mem(&qedi->tasks,
>>tid);
>
>Cast again.
>
>[...]
>
>> +	fw_task_ctx =3D
>> +	     (struct iscsi_task_context *)qedi_get_task_mem(&qedi->tasks,
>>tid);
>
>^^
>
>[...]
>
>> +	fw_task_ctx =3D
>> +	(struct iscsi_task_context *)qedi_get_task_mem(&qedi->tasks, tid);
>
>
>[...]
>
>> +	fw_task_ctx =3D
>> +	      (struct iscsi_task_context *)qedi_get_task_mem(&qedi->tasks,
>>tid);
>> +
>
>[...]
>
>> +
>> +	qedi =3D (struct qedi_ctx *)iscsi_host_priv(shost);
>
>Same goes for iscsi_host_priv();
>
>[...]
>
>> +	ret =3D wait_event_interruptible_timeout(qedi_ep->ofld_wait,
>> +					       ((qedi_ep->state =3D=3D
>> +						EP_STATE_OFLDCONN_FAILED) ||
>> +						(qedi_ep->state =3D=3D
>> +						EP_STATE_OFLDCONN_COMPL)),
>> +						msecs_to_jiffies(timeout_ms));
>
>Maybe:
>#define QEDI_OLDCON_STATE(q) ((q)->state =3D=3D EP_STATE_OFLDCONN_FAILED |=
| \
>				(q)->state =3D=3D EP_STATE_OFLDCONN_COMPL)
>
>ret =3D wait_event_interruptible_timeout(qedi_ep->ofld_wait,
>					QEDI_OLDCON_STATE(qedi_ep),
>					msec_to_jiffies(timeout_ms));
>
>But that could be just me hating linewraps.
>
>[...]

We will address all the above review comments in the next revision.

Thanks,
Manish R.

