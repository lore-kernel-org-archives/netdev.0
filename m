From: "Rangankar, Manish" <Manish.Rangankar@cavium.com>
Subject: Re: [RFC 6/6] qedi: Add support for data path.
Date: Thu, 20 Oct 2016 09:24:13 +0000
Message-ID: <D42E8924.3413A%manish.rangankar@cavium.com>
References: <1476853273-22960-1-git-send-email-manish.rangankar@cavium.com>
 <1476853273-22960-7-git-send-email-manish.rangankar@cavium.com>
 <fc58b63a-ac67-59e4-7698-4ab742848080@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "martin.petersen@oracle.com" <martin.petersen@oracle.com>,
        "jejb@linux.vnet.ibm.com" <jejb@linux.vnet.ibm.com>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        Dept-Eng QLogic Storage Upstream
        <QLogic-Storage-Upstream@cavium.com>,
        "Javali, Nilesh" <Nilesh.Javali@cavium.com>,
        Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>,
        "Dupuis, Chad" <Chad.Dupuis@cavium.com>,
        "Kashyap, Saurav" <Saurav.Kashyap@cavium.com>,
        "Easi, Arun" <Arun.Easi@cavium.com>
To: Hannes Reinecke <hare@suse.de>,
        "lduncan@suse.com" <lduncan@suse.com>,
        "cleech@redhat.com" <cleech@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0051.outbound.protection.outlook.com ([104.47.40.51]:53981
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1758494AbcJTJj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 05:39:29 -0400
In-Reply-To: <fc58b63a-ac67-59e4-7698-4ab742848080@suse.de>
Content-Language: en-US
Content-ID: <874D47A4F8092649AB48C1530E9C0C0A@namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 19/10/16 3:54 PM, "Hannes Reinecke" <hare@suse.de> wrote:

>On 10/19/2016 07:01 AM, manish.rangankar@cavium.com wrote:
>> From: Manish Rangankar <manish.rangankar@cavium.com>
>>=20
>> This patch adds support for data path and TMF handling.
>>=20
>> Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
>> Signed-off-by: Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>
>> Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
>> Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
>> Signed-off-by: Arun Easi <arun.easi@cavium.com>
>> Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
>> ---
>>  drivers/scsi/qedi/qedi_fw.c    | 1282
>>++++++++++++++++++++++++++++++++++++++++
>>  drivers/scsi/qedi/qedi_gbl.h   |    6 +
>>  drivers/scsi/qedi/qedi_iscsi.c |    6 +
>>  drivers/scsi/qedi/qedi_main.c  |    4 +
>>  4 files changed, 1298 insertions(+)
>>=20
>> diff --git a/drivers/scsi/qedi/qedi_fw.c b/drivers/scsi/qedi/qedi_fw.c
>> index a820785..af1e14d 100644
>> --- a/drivers/scsi/qedi/qedi_fw.c
>> +++ b/drivers/scsi/qedi/qedi_fw.c
>> @@ -147,6 +147,114 @@ static void qedi_process_text_resp(struct
>>qedi_ctx *qedi,
>>  	spin_unlock(&session->back_lock);
>>  }

--snipped--
>> +void qedi_trace_io(struct qedi_ctx *qedi, struct iscsi_task *task,
>> +		   u16 tid, int8_t direction)
>> +{
>> +	struct qedi_io_log *io_log;
>> +	struct iscsi_conn *conn =3D task->conn;
>> +	struct qedi_conn *qedi_conn =3D conn->dd_data;
>> +	struct scsi_cmnd *sc_cmd =3D task->sc;
>> +	unsigned long flags;
>> +	u8 op;
>> +
>> +	spin_lock_irqsave(&qedi->io_trace_lock, flags);
>> +
>> +	io_log =3D &qedi->io_trace_buf[qedi->io_trace_idx];
>> +	io_log->direction =3D direction;
>> +	io_log->task_id =3D tid;
>> +	io_log->cid =3D qedi_conn->iscsi_conn_id;
>> +	io_log->lun =3D sc_cmd->device->lun;
>> +	io_log->op =3D sc_cmd->cmnd[0];
>> +	op =3D sc_cmd->cmnd[0];
>> +
>> +	if (op =3D=3D READ_10 || op =3D=3D WRITE_10) {
>> +		io_log->lba[0] =3D sc_cmd->cmnd[2];
>> +		io_log->lba[1] =3D sc_cmd->cmnd[3];
>> +		io_log->lba[2] =3D sc_cmd->cmnd[4];
>> +		io_log->lba[3] =3D sc_cmd->cmnd[5];
>> +	} else {
>> +		io_log->lba[0] =3D 0;
>> +		io_log->lba[1] =3D 0;
>> +		io_log->lba[2] =3D 0;
>> +		io_log->lba[3] =3D 0;
>> +	}
>Only for READ_10 and WRITE_10? What about the other read or write
>commands?

We will add support for other scsi commands in the next revision.

>
>> +	io_log->bufflen =3D scsi_bufflen(sc_cmd);
>> +	io_log->sg_count =3D scsi_sg_count(sc_cmd);
>> +	io_log->fast_sgs =3D qedi->fast_sgls;
>> +	io_log->cached_sgs =3D qedi->cached_sgls;
>> +	io_log->slow_sgs =3D qedi->slow_sgls;
>> +	io_log->cached_sge =3D qedi->use_cached_sge;
>> +	io_log->slow_sge =3D qedi->use_slow_sge;
>> +	io_log->fast_sge =3D qedi->use_fast_sge;
>> +	io_log->result =3D sc_cmd->result;
>> +	io_log->jiffies =3D jiffies;
>> +	io_log->blk_req_cpu =3D smp_processor_id();
>> +
>> +	if (direction =3D=3D QEDI_IO_TRACE_REQ) {
>> +		/* For requests we only care about the submission CPU */
>> +		io_log->req_cpu =3D smp_processor_id() % qedi->num_queues;
>> +		io_log->intr_cpu =3D 0;
>> +		io_log->blk_rsp_cpu =3D 0;
>> +	} else if (direction =3D=3D QEDI_IO_TRACE_RSP) {
>> +		io_log->req_cpu =3D smp_processor_id() % qedi->num_queues;
>> +		io_log->intr_cpu =3D qedi->intr_cpu;
>> +		io_log->blk_rsp_cpu =3D smp_processor_id();
>> +	}
>> +
>> +	qedi->io_trace_idx++;
>> +	if (qedi->io_trace_idx =3D=3D QEDI_IO_TRACE_SIZE)
>> +		qedi->io_trace_idx =3D 0;
>> +
>> +	qedi->use_cached_sge =3D false;
>> +	qedi->use_slow_sge =3D false;
>> +	qedi->use_fast_sge =3D false;
>> +
>> +	spin_unlock_irqrestore(&qedi->io_trace_lock, flags);
>> +}
>> +
>> +int qedi_iscsi_send_ioreq(struct iscsi_task *task)
>> +{
>> +	struct iscsi_conn *conn =3D task->conn;
>> +	struct iscsi_session *session =3D conn->session;
>> +	struct Scsi_Host *shost =3D
>>iscsi_session_to_shost(session->cls_session);
>> +	struct qedi_ctx *qedi =3D iscsi_host_priv(shost);
>> +	struct qedi_conn *qedi_conn =3D conn->dd_data;
>> +	struct qedi_cmd *cmd =3D task->dd_data;
>> +	struct scsi_cmnd *sc =3D task->sc;
>> +	struct iscsi_task_context *fw_task_ctx;
>> +	struct iscsi_cached_sge_ctx *cached_sge;
>> +	struct iscsi_phys_sgl_ctx *phys_sgl;
>> +	struct iscsi_virt_sgl_ctx *virt_sgl;
>> +	struct ystorm_iscsi_task_st_ctx *yst_cxt;
>> +	struct mstorm_iscsi_task_st_ctx *mst_cxt;
>> +	struct iscsi_sgl *sgl_struct;
>> +	struct iscsi_sge *single_sge;
>> +	struct iscsi_scsi_req *hdr =3D (struct iscsi_scsi_req *)task->hdr;
>> +	struct iscsi_sge *bd =3D cmd->io_tbl.sge_tbl;
>> +	enum iscsi_task_type task_type;
>> +	struct iscsi_cmd_hdr *fw_cmd;
>> +	u32 scsi_lun[2];
>> +	u16 cq_idx =3D smp_processor_id() % qedi->num_queues;
>> +	s16 ptu_invalidate =3D 0;
>> +	s16 tid =3D 0;
>> +	u8 num_fast_sgs;
>> +
>> +	tid =3D qedi_get_task_idx(qedi);
>> +	if (tid =3D=3D -1)
>> +		return -ENOMEM;
>> +
>> +	qedi_iscsi_map_sg_list(cmd);
>> +
>> +	int_to_scsilun(sc->device->lun, (struct scsi_lun *)scsi_lun);
>> +	fw_task_ctx =3D
>> +	      (struct iscsi_task_context *)qedi_get_task_mem(&qedi->tasks,
>>tid);
>> +
>> +	memset(fw_task_ctx, 0, sizeof(struct iscsi_task_context));
>> +	cmd->task_id =3D tid;
>> +
>> +	/* Ystrom context */
>Ystrom or Ystorm?

Noted

>
>> +	fw_cmd =3D &fw_task_ctx->ystorm_st_context.pdu_hdr.cmd;
>> +	SET_FIELD(fw_cmd->flags_attr, ISCSI_CMD_HDR_ATTR, ISCSI_ATTR_SIMPLE);
>> +
>> +	if (sc->sc_data_direction =3D=3D DMA_TO_DEVICE) {
>> +		if (conn->session->initial_r2t_en) {
>> +			fw_task_ctx->ustorm_ag_context.exp_data_acked =3D
>> +				min((conn->session->imm_data_en *
>> +				    conn->max_xmit_dlength),
>> +				    conn->session->first_burst);
>> +			fw_task_ctx->ustorm_ag_context.exp_data_acked =3D
>> +			      min(fw_task_ctx->ustorm_ag_context.exp_data_acked,
>> +				  scsi_bufflen(sc));
>> +		} else {
>> +			fw_task_ctx->ustorm_ag_context.exp_data_acked =3D
>> +			      min(conn->session->first_burst, scsi_bufflen(sc));
>> +		}
>> +
>> +		SET_FIELD(fw_cmd->flags_attr, ISCSI_CMD_HDR_WRITE, 1);
>> +		task_type =3D ISCSI_TASK_TYPE_INITIATOR_WRITE;
>> +	} else {
>> +		if (scsi_bufflen(sc))
>> +			SET_FIELD(fw_cmd->flags_attr, ISCSI_CMD_HDR_READ, 1);
>> +		task_type =3D ISCSI_TASK_TYPE_INITIATOR_READ;
>> +	}
>> +
>> +	fw_cmd->lun.lo =3D be32_to_cpu(scsi_lun[0]);
>> +	fw_cmd->lun.hi =3D be32_to_cpu(scsi_lun[1]);
>> +
>> +	qedi_update_itt_map(qedi, tid, task->itt);
>> +	fw_cmd->itt =3D qedi_set_itt(tid, get_itt(task->itt));
>> +	fw_cmd->expected_transfer_length =3D scsi_bufflen(sc);
>> +	fw_cmd->cmd_sn =3D be32_to_cpu(hdr->cmdsn);
>> +	fw_cmd->opcode =3D hdr->opcode;
>> +	qedi_cpy_scsi_cdb(sc, (u32 *)fw_cmd->cdb);
>> +
>> +	/* Mstorm context */
>> +	fw_task_ctx->mstorm_st_context.sense_db.lo =3D
>>(u32)cmd->sense_buffer_dma;
>> +	fw_task_ctx->mstorm_st_context.sense_db.hi =3D
>> +					(u32)((u64)cmd->sense_buffer_dma >> 32);
>> +	fw_task_ctx->mstorm_ag_context.task_cid =3D qedi_conn->iscsi_conn_id;
>> +	fw_task_ctx->mstorm_st_context.task_type =3D task_type;
>> +
>> +	if (qedi->tid_reuse_count[tid] =3D=3D QEDI_MAX_TASK_NUM) {
>> +		ptu_invalidate =3D 1;
>> +		qedi->tid_reuse_count[tid] =3D 0;
>> +	}
>> +	fw_task_ctx->ystorm_st_context.state.reuse_count =3D
>> +						     qedi->tid_reuse_count[tid];
>> +	fw_task_ctx->mstorm_st_context.reuse_count =3D
>> +						   qedi->tid_reuse_count[tid]++;
>> +
>> +	/* Ustrorm context */
>Ustrorm?

Noted

Thanks,
Manish R.
