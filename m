From: "Rangankar, Manish" <Manish.Rangankar@cavium.com>
Subject: Re: [RFC 5/6] qedi: Add support for iSCSI session management.
Date: Thu, 20 Oct 2016 09:09:01 +0000
Message-ID: <D42E83FD.34116%manish.rangankar@cavium.com>
References: <1476853273-22960-1-git-send-email-manish.rangankar@cavium.com>
 <1476853273-22960-6-git-send-email-manish.rangankar@cavium.com>
 <6f79e92c-ea12-331b-5c20-e9a3587b1d80@suse.de>
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
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <6f79e92c-ea12-331b-5c20-e9a3587b1d80@suse.de>
Content-Language: en-US
Content-ID: <4BA0FED753D050468A0C4973F864B35E@namprd07.prod.outlook.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 19/10/16 1:33 PM, "Hannes Reinecke" <hare@suse.de> wrote:

>On 10/19/2016 07:01 AM, manish.rangankar@cavium.com wrote:
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
>>  drivers/scsi/qedi/qedi_fw.c    | 1123 ++++++++++++++++++++++++++++
>>  drivers/scsi/qedi/qedi_gbl.h   |   67 ++
>>  drivers/scsi/qedi/qedi_iscsi.c | 1604
>>++++++++++++++++++++++++++++++++++++++++
>>  drivers/scsi/qedi/qedi_iscsi.h |  228 ++++++
>>  drivers/scsi/qedi/qedi_main.c  |  164 ++++
>>  5 files changed, 3186 insertions(+)
>>  create mode 100644 drivers/scsi/qedi/qedi_fw.c
>>  create mode 100644 drivers/scsi/qedi/qedi_gbl.h
>>  create mode 100644 drivers/scsi/qedi/qedi_iscsi.c
>>  create mode 100644 drivers/scsi/qedi/qedi_iscsi.h
>>=20

--snipped--
>>
>> +static void qedi_process_async_mesg(struct qedi_ctx *qedi,
>> +				    union iscsi_cqe *cqe,
>> +				    struct iscsi_task *task,
>> +				    struct qedi_conn *qedi_conn,
>> +				    u16 que_idx)
>> +{
>> +	struct iscsi_conn *conn =3D qedi_conn->cls_conn->dd_data;
>> +	struct iscsi_session *session =3D conn->session;
>> +	struct iscsi_async_msg_hdr *cqe_async_msg;
>> +	struct iscsi_async *resp_hdr;
>> +	u32 scsi_lun[2];
>> +	u32 pdu_len, num_bdqs;
>> +	char bdq_data[QEDI_BDQ_BUF_SIZE];
>> +	unsigned long flags;
>> +
>> +	spin_lock_bh(&session->back_lock);
>> +
>> +	cqe_async_msg =3D &cqe->cqe_common.iscsi_hdr.async_msg;
>> +	pdu_len =3D cqe_async_msg->hdr_second_dword &
>> +		ISCSI_ASYNC_MSG_HDR_DATA_SEG_LEN_MASK;
>> +	num_bdqs =3D pdu_len / QEDI_BDQ_BUF_SIZE;
>> +
>> +	if (cqe->cqe_common.cqe_type =3D=3D ISCSI_CQE_TYPE_UNSOLICITED) {
>> +		spin_lock_irqsave(&qedi->hba_lock, flags);
>> +		qedi_unsol_pdu_adjust_bdq(qedi, &cqe->cqe_unsolicited,
>> +					  pdu_len, num_bdqs, bdq_data);
>> +		spin_unlock_irqrestore(&qedi->hba_lock, flags);
>> +	}
>> +
>> +	resp_hdr =3D (struct iscsi_async *)&qedi_conn->gen_pdu.resp_hdr;
>> +	memset(resp_hdr, 0, sizeof(struct iscsi_hdr));
>> +	resp_hdr->opcode =3D cqe_async_msg->opcode;
>> +	resp_hdr->flags =3D 0x80;
>> +
>> +	scsi_lun[0] =3D cpu_to_be32(cqe_async_msg->lun.lo);
>> +	scsi_lun[1] =3D cpu_to_be32(cqe_async_msg->lun.hi);
>I _think_ we have a SCSI LUN structure ...

Will do.

--snipped--
>> +void qedi_process_iscsi_error(struct qedi_endpoint *ep, struct
>>async_data *data)
>> +{
>> +	struct qedi_conn *qedi_conn;
>> +	struct qedi_ctx *qedi;
>> +	char warn_notice[] =3D "iscsi_warning";
>> +	char error_notice[] =3D "iscsi_error";
>> +	char *message;
>> +	int need_recovery =3D 0;
>> +	u32 err_mask =3D 0;
>> +	char msg[64];
>> +
>> +	if (!ep)
>> +		return;
>> +
>> +	qedi_conn =3D ep->conn;
>> +	if (!qedi_conn)
>> +		return;
>> +
>> +	qedi =3D ep->qedi;
>> +
>> +	QEDI_ERR(&qedi->dbg_ctx, "async event iscsi error:0x%x\n",
>> +		 data->error_code);
>> +
>> +	if (err_mask) {
>> +		need_recovery =3D 0;
>> +		message =3D warn_notice;
>> +	} else {
>> +		need_recovery =3D 1;
>> +		message =3D error_notice;
>> +	}
>> +
>> +	switch (data->error_code) {
>> +	case ISCSI_STATUS_NONE:
>> +		strcpy(msg, "tcp_error none");
>> +		break;
>> +	case ISCSI_CONN_ERROR_TASK_CID_MISMATCH:
>> +		strcpy(msg, "task cid mismatch");
>> +		break;
>> +	case ISCSI_CONN_ERROR_TASK_NOT_VALID:
>> +		strcpy(msg, "invalid task");
>> +		break;
>> +	case ISCSI_CONN_ERROR_RQ_RING_IS_FULL:
>> +		strcpy(msg, "rq ring full");
>> +		break;
>> +	case ISCSI_CONN_ERROR_CMDQ_RING_IS_FULL:
>> +		strcpy(msg, "cmdq ring full");
>> +		break;
>> +	case ISCSI_CONN_ERROR_HQE_CACHING_FAILED:
>> +		strcpy(msg, "sge caching failed");
>> +		break;
>> +	case ISCSI_CONN_ERROR_HEADER_DIGEST_ERROR:
>> +		strcpy(msg, "hdr digest error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_LOCAL_COMPLETION_ERROR:
>> +		strcpy(msg, "local cmpl error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_DATA_OVERRUN:
>> +		strcpy(msg, "invalid task");
>> +		break;
>> +	case ISCSI_CONN_ERROR_OUT_OF_SGES_ERROR:
>> +		strcpy(msg, "out of sge error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_TCP_SEG_PROC_IP_OPTIONS_ERROR:
>> +		strcpy(msg, "tcp seg ip options error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_TCP_IP_FRAGMENT_ERROR:
>> +		strcpy(msg, "tcp ip fragment error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_AHS_LEN:
>> +		strcpy(msg, "AHS len protocol error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_ITT_OUT_OF_RANGE:
>> +		strcpy(msg, "itt out of range error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_DATA_SEG_LEN_EXCEEDS_PDU_SIZE:
>> +		strcpy(msg, "data seg more than pdu size");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_INVALID_OPCODE:
>> +		strcpy(msg, "invalid opcode");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_INVALID_OPCODE_BEFORE_UPDATE:
>> +		strcpy(msg, "invalid opcode before update");
>> +		break;
>> +	case ISCSI_CONN_ERROR_UNVALID_NOPIN_DSL:
>> +		strcpy(msg, "unexpected opcode");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_R2T_CARRIES_NO_DATA:
>> +		strcpy(msg, "r2t carries no data");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_DATA_SN:
>> +		strcpy(msg, "data sn error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_DATA_IN_TTT:
>> +		strcpy(msg, "data TTT error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_R2T_TTT:
>> +		strcpy(msg, "r2t TTT error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_R2T_BUFFER_OFFSET:
>> +		strcpy(msg, "buffer offset error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_BUFFER_OFFSET_OOO:
>> +		strcpy(msg, "buffer offset ooo");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_R2T_SN:
>> +		strcpy(msg, "data seg len 0");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_DESIRED_DATA_TRNS_LEN_0:
>> +		strcpy(msg, "data xer len error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_DESIRED_DATA_TRNS_LEN_1:
>> +		strcpy(msg, "data xer len1 error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_DESIRED_DATA_TRNS_LEN_2:
>> +		strcpy(msg, "data xer len2 error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_LUN:
>> +		strcpy(msg, "protocol lun error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_F_BIT_ZERO:
>> +		strcpy(msg, "f bit zero error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_F_BIT_ZERO_S_BIT_ONE:
>> +		strcpy(msg, "f bit zero s bit one error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_EXP_STAT_SN:
>> +		strcpy(msg, "exp stat sn error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_DSL_NOT_ZERO:
>> +		strcpy(msg, "dsl not zero error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_INVALID_DSL:
>> +		strcpy(msg, "invalid dsl");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_DATA_SEG_LEN_TOO_BIG:
>> +		strcpy(msg, "data seg len too big");
>> +		break;
>> +	case ISCSI_CONN_ERROR_PROTOCOL_ERR_OUTSTANDING_R2T_COUNT:
>> +		strcpy(msg, "outstanding r2t count error");
>> +		break;
>> +	case ISCSI_CONN_ERROR_SENSE_DATA_LENGTH:
>> +		strcpy(msg, "sense datalen error");
>> +		break;
>Please use an array for mapping values onto strings.

Will add this change in next revision.

Thanks,
Manish R.

