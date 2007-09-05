From: Mike Christie <mchristi@redhat.com>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Wed, 05 Sep 2007 13:34:05 -0500
Message-ID: <46DEF69D.3090901@redhat.com>
References: <1188599815.5176.12.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, anilgv@broadcom.com,
	talm@broadcom.com, lusinsky@broadcom.com, uri@broadcom.com,
	SCSI Mailing List <linux-scsi@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1188599815.5176.12.camel@dell>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> diff --git a/drivers/scsi/Kconfig b/drivers/scsi/Kconfig
> index 6f2c71e..adcfbbc 100644
> --- a/drivers/scsi/Kconfig
> +++ b/drivers/scsi/Kconfig
> @@ -1800,6 +1800,8 @@ config ZFCP
>            called zfcp. If you want to compile it as a module, say M here
>            and read <file:Documentation/kbuild/modules.txt>.
>  
> +source "drivers/scsi/bnx2i/Kconfig"
> +
>  config SCSI_SRP
>  	tristate "SCSI RDMA Protocol helper library"
>  	depends on SCSI && PCI
> diff --git a/drivers/scsi/Makefile b/drivers/scsi/Makefile
> index 86a7ba7..65fe633 100644
> --- a/drivers/scsi/Makefile
> +++ b/drivers/scsi/Makefile
> @@ -133,6 +133,7 @@ obj-$(CONFIG_SCSI_IBMVSCSIS)	+= ibmvscsi/
>  obj-$(CONFIG_SCSI_HPTIOP)	+= hptiop.o
>  obj-$(CONFIG_SCSI_STEX)		+= stex.o
>  obj-$(CONFIG_PS3_ROM)		+= ps3rom.o
> +obj-$(CONFIG_SCSI_BNX2_ISCSI)	+= bnx2i/
>  
>  obj-$(CONFIG_ARM)		+= arm/
>  
> diff --git a/drivers/scsi/bnx2i/57xx_iscsi_constants.h b/drivers/scsi/bnx2i/57xx_iscsi_constants.h
> new file mode 100644
> index 0000000..61f07f9
> --- /dev/null
> +++ b/drivers/scsi/bnx2i/57xx_iscsi_constants.h
> @@ -0,0 +1,212 @@
> +#ifndef __57XX_ISCSI_CONSTANTS_H_
> +#define __57XX_ISCSI_CONSTANTS_H_
> +
> +/**
> +* This file defines HSI constants for the iSCSI flows
> +*/
> +
> +/* iSCSI request op codes */
> +#define ISCSI_OPCODE_NOP_OUT 			(0 | 0x40)
> +#define ISCSI_OPCODE_SCSI_CMD 			(1)
> +#define ISCSI_OPCODE_TMF_REQUEST 		(2 | 0x40)
> +#define ISCSI_OPCODE_LOGIN_REQUEST 		(3 | 0x40)
> +#define ISCSI_OPCODE_TEXT_REQUEST 		(4 | 0x40)
> +#define ISCSI_OPCODE_DATA_OUT 			(5)
> +#define ISCSI_OPCODE_LOGOUT_REQUEST 		(6 | 0x00)
> +#define ISCSI_OPCODE_CLEANUP_REQUEST		(7)


What is ISCSI_OPCODE_CLEANUP_REQUEST?


> +
> +/* iSCSI response/messages op codes */
> +#define ISCSI_OPCODE_NOP_IN 			(0x20)
> +#define ISCSI_OPCODE_SCSI_RESPONSE 		(0x21)
> +#define ISCSI_OPCODE_TMF_RESPONSE 		(0x22)
> +#define ISCSI_OPCODE_LOGIN_RESPONSE 		(0x23)
> +#define ISCSI_OPCODE_TEXT_RESPONSE 		(0x24)
> +#define ISCSI_OPCODE_DATA_IN			(0x25)
> +#define ISCSI_OPCODE_LOGOUT_RESPONSE 		(0x26)
> +#define ISCSI_OPCODE_CLEANUP_RESPONSE 		(0x27)
> +#define ISCSI_OPCODE_R2T			(0x31)
> +#define ISCSI_OPCODE_ASYNC_MSG 			(0x32)
> +#define ISCSI_OPCODE_REJECT 			(0x3f)
> +#define ISCSI_OPCODE_NOPOUT_LOCAL_COMPLETION	(0)


What does the LOCAL_COMPLETION on the nopout mean?


> +
> +/* iSCSI stages */
> +#define ISCSI_STAGE_SECURITY_NEGOTIATION (0)
> +#define ISCSI_STAGE_LOGIN_OPERATIONAL_NEGOTIATION (1)
> +#define ISCSI_STAGE_FULL_FEATURE_PHASE (3)
> +
> +/* iSCSI parameter defaults */
> +#define ISCSI_DEFAULT_HEADER_DIGEST 		(0)
> +#define ISCSI_DEFAULT_DATA_DIGEST 		(0)
> +#define ISCSI_DEFAULT_INITIAL_R2T 		(1)
> +#define ISCSI_DEFAULT_IMMEDIATE_DATA 		(1)
> +#define ISCSI_DEFAULT_MAX_PDU_LENGTH 		(0x2000)
> +#define ISCSI_DEFAULT_FIRST_BURST_LENGTH 	(0x10000)
> +#define ISCSI_DEFAULT_MAX_BURST_LENGTH 		(0x40000)
> +#define ISCSI_DEFAULT_MAX_OUTSTANDING_R2T 	(1)
> +
> +/* iSCSI parameter limits */
> +#define ISCSI_MIN_VAL_MAX_PDU_LENGTH (0x200)
> +#define ISCSI_MAX_VAL_MAX_PDU_LENGTH (0xffffff)
> +#define ISCSI_MIN_VAL_BURST_LENGTH (0x200)
> +#define ISCSI_MAX_VAL_BURST_LENGTH (0xffffff)
> +#define ISCSI_MIN_VAL_MAX_OUTSTANDING_R2T (1)
> +#define ISCSI_MAX_VAL_MAX_OUTSTANDING_R2T (0xff) /* 0x10000 according to RFC */
> +
> +/* SCSI command response codes */
> +#define ISCSI_SCSI_CMD_RESPONSE_CMD_COMPLETED	(0x00)
> +#define ISCSI_SCSI_CMD_RESPONSE_TARGET_FAILURE	(0x01)
> +
> +/* SCSI command status codes */
> +#define ISCSI_SCSI_CMD_STATUS_GOOD 		(0x00)
> +#define ISCSI_SCSI_CMD_STATUS_CHECK_CONDITION 	(0x02)
> +#define ISCSI_SCSI_CMD_STATUS_INTERMIDIATE 	(0x10)
> +
> +/* TMF codes */
> +#define ISCSI_TMF_ABORT_TASK 			(1)
> +#define ISCSI_TMF_LOGICAL_UNIT_RESET 		(5)
> +
> +/* TMF response codes */
> +#define ISCSI_TMF_RESPONSE_FUNCTION_COMPLETE			(0x00)
> +#define ISCSI_TMF_RESPONSE_TASK_DOESNT_EXIST			(0x01)
> +#define ISCSI_TMF_RESPONSE_LUN_DOESNT_EXIST			(0x02)
> +#define ISCSI_TMF_RESPONSE_TASK_STILL_ALLEGIANT			(0x03)
> +#define ISCSI_TMF_RESPONSE_FUNCTION_NOT_SUPPORTED		(0x05)
> +#define ISCSI_TMF_RESPONSE_FUNCTION_AUTHORIZATION_FAILED	(0x06)
> +#define ISCSI_TMF_RESPONSE_FUNCTION_REJECTED			(0xff)
> +
> +/* Logout reason codes */
> +/*#define ISCSI_LOGOUT_REASON_CLOSE_CONNECTION (1) */
> +
> +/* Logout response codes */
> +#define ISCSI_LOGOUT_RESPONSE_CONNECTION_CLOSED (0)
> +#define ISCSI_LOGOUT_RESPONSE_CID_NOT_FOUND (1)
> +#define ISCSI_LOGOUT_RESPONSE_CLEANUP_FAILED (3)
> +
> +/* iSCSI task types */
> +#define ISCSI_TASK_TYPE_READ    (0)
> +#define ISCSI_TASK_TYPE_WRITE   (1)
> +#define ISCSI_TASK_TYPE_MPATH   (2)




All of these iscsi code shoulds be in iscsi_proto.h or should be added 
there.


> +
> +#endif
> diff --git a/drivers/scsi/bnx2i/bnx2i_hwi.c b/drivers/scsi/bnx2i/bnx2i_hwi.c
> new file mode 100644
> index 0000000..b74a93c
> --- /dev/null
> +++ b/drivers/scsi/bnx2i/bnx2i_hwi.c
> @@ -0,0 +1,1977 @@



> + * process iSCSI TMF Response CQE & wake up driver EH thread.
> + */
> +static int bnx2i_process_tmf_resp(struct bnx2i_conn *conn, struct cqe *cqe)
> +{
> +	u32 itt;
> +	struct bnx2i_cmd *cmd;
> +	struct bnx2i_cmd *aborted_cmd;
> +	struct iscsi_tmf_response *tmf_cqe;
> +
> +	tmf_cqe = (struct iscsi_tmf_response *) cqe;
> +	itt = (tmf_cqe->itt & ISCSI_TMF_RESPONSE_INDEX);
> +	cmd = get_cmnd(conn->sess, itt);
> +	if (!cmd) {
> +		printk(KERN_ALERT "tmf_resp: ITT 0x%x is not active\n",
> +				  tmf_cqe->itt);
> +		return 0;
> +	}
> +
> +	bnx2i_update_cmd_sequence(conn->sess, tmf_cqe->exp_cmd_sn,
> +				  tmf_cqe->max_cmd_sn);
> +
> +	aborted_cmd = cmd->tmf_ref_cmd;
> +
> +	if (tmf_cqe->response == ISCSI_TMF_RSP_COMPLETE) {
> +		if (aborted_cmd->scsi_cmd) {
> +			aborted_cmd->scsi_cmd->result = DID_ABORT << 16;
> +			aborted_cmd->scsi_cmd->resid =

should use resid wrappers throughout driver.

> +				aborted_cmd->scsi_cmd->request_bufflen;

Should use bufflen wrappers throught driver.


> +}
> diff --git a/drivers/scsi/bnx2i/bnx2i_init.c b/drivers/scsi/bnx2i/bnx2i_init.c
> new file mode 100644
> index 0000000..837bd95
> --- /dev/null
> +++ b/drivers/scsi/bnx2i/bnx2i_init.c
>
> + * handles SCSI command queued by SCSI-ML, allocates a command structure,
> + *	assigning CMDSN, mapping SG buffers and handing over request to CNIC.
> + */
> +int bnx2i_queuecommand(struct scsi_cmnd *sc,
> +		       void (*done) (struct scsi_cmnd *))
> +{
> +	struct bnx2i_sess *sess;
> +	struct bnx2i_conn *conn;
> +	struct bnx2i_cmd *cmd;
> +	static int old_recovery_state = 0;
> +
> +	sc->scsi_done = done;
> +	sc->result = 0;
> +	sess = iscsi_hostdata(sc->device->host->hostdata);
> +
> +#define iscsi_cmd_win_closed(_sess)	\
> +	((int) (_sess->max_cmdsn - _sess->cmdsn) < 0)
> +
> +	if (iscsi_cmd_win_closed(sess) ||
> +	    test_bit(ADAPTER_STATE_LINK_DOWN, &sess->hba->adapter_state))
> +		goto iscsi_win_closed;
> +
> +	if ((sess->state & BNX2I_SESS_IN_SHUTDOWN) ||
> +		(sess->state & BNX2I_SESS_IN_LOGOUT))
> +		goto dev_not_found;
> +
> +	if (sess->recovery_state) {
> +		if (old_recovery_state != sess->recovery_state)
> +			old_recovery_state = sess->recovery_state;
> +
> +		if (sess->recovery_state & ISCSI_SESS_RECOVERY_FAILED)
> +			goto dev_not_found;
> +		else if (!(sess->recovery_state & ISCSI_SESS_RECOVERY_COMPLETE))
> +			goto iscsi_win_closed;
> +		else
> +			sess->recovery_state = 0;
> +	}
> +
> +	cmd = bnx2i_alloc_cmd(sess);
> +	if (cmd == NULL)
> +		/* should never happen as cmd list size == SHT->can_queue */
> +		goto cmd_not_accepted;
> +
> +	cmd->conn = conn = sess->lead_conn;
> +	cmd->scsi_cmd = sc;
> +	cmd->req.total_data_transfer_length = sc->request_bufflen;
> +	cmd->iscsi_opcode = ISCSI_OPCODE_SCSI_CMD;
> +	cmd->req.cmd_sn = sess->cmdsn++;
> +
> +	bnx2i_iscsi_map_sg_list(cmd);
> +	bnx2i_cpy_scsi_cdb(sc, cmd);
> +
> +	if (sc->sc_data_direction == DMA_TO_DEVICE) {
> +		cmd->req.op_attr = ISCSI_CMD_REQUEST_WRITE;
> +		cmd->req.itt |= (ISCSI_TASK_TYPE_WRITE <<
> +				 ISCSI_CMD_REQUEST_TYPE_SHIFT);
> +		bnx2i_setup_write_cmd_bd_info(cmd);
> +	} else {
> +		cmd->req.op_attr = ISCSI_CMD_REQUEST_READ;
> +		cmd->req.itt |= (ISCSI_TASK_TYPE_READ <<
> +				 ISCSI_CMD_REQUEST_TYPE_SHIFT);
> +	}
> +	cmd->req.num_bds = cmd->bd_tbl->bd_valid;
> +	if (!cmd->bd_tbl->bd_valid) {
> +		cmd->req.bd_list_addr_lo = (u32) sess->hba->mp_bd_dma;
> +		cmd->req.bd_list_addr_hi =
> +			(u32) ((u64) sess->hba->mp_bd_dma >> 32);
> +		cmd->req.num_bds = 1;
> +	}
> +
> +	cmd->cmd_state = ISCSI_CMD_STATE_INITIATED;
> +	sc->SCp.ptr = (char *) cmd;
> +
> +	if (cmd->req.itt != ITT_INVALID_SIGNATURE) {
> +		bnx2i_send_iscsi_scsicmd(conn, cmd);
> +		list_add_tail(&cmd->link, &sess->active_cmds);
> +		sess->num_active_cmds++;
> +	}
> +	return 0;
> +
> +iscsi_win_closed:
> +cmd_not_accepted:
> +	return SCSI_MLQUEUE_HOST_BUSY;
> +
> +dev_not_found:
> +	sc->sense_buffer[0] = 0x70;
> +	sc->sense_buffer[2] = NOT_READY;
> +	sc->sense_buffer[7] = 0x6;
> +	sc->sense_buffer[12] = 0x08;
> +	sc->sense_buffer[13] = 0x00;


do not fake sense and do not face sense and set a host byte of 
DID_NO_CONNECT. DID_NO_CONNECT is fine.


> +	sc->result = (DID_NO_CONNECT << 16);
> +	sc->resid = sc->request_bufflen;
> +	sc->scsi_done(sc);
> +	return 0;
> +}
> +
> +
> +
> +/*
> + * TMF request timeout handler
> + */
> +static void bnx2i_iscsi_tmf_timer(unsigned long data)
> +{
> +	struct bnx2i_cmd *cmd = (struct bnx2i_cmd *) data;
> +
> +	printk(KERN_ALERT "TMF timer: abort failed, cmd 0x%p\n", cmd);
> +	cmd->cmd_state = ISCSI_CMD_STATE_TMF_TIMEOUT;
> +	cmd->conn->sess->recovery_state = ISCSI_SESS_RECOVERY_OPEN_ISCSI;
> +	iscsi_conn_error(cmd->conn->cls_conn, ISCSI_ERR_CONN_FAILED);
> +}
> +
> +
> +/*
> + * initiate command abort process by requesting CNIC to send
> + *	an iSCSI TMF request to target
> + */
> +static int bnx2i_initiate_abort_cmd(struct scsi_cmnd *sc)
> +{
> +	struct bnx2i_cmd *cmd = (struct bnx2i_cmd *) sc->SCp.ptr;
> +	struct bnx2i_cmd *tmf_cmd;
> +	struct Scsi_Host *shost = cmd->scsi_cmd->device->host;
> +	struct bnx2i_conn *conn = cmd->conn;
> +	struct bnx2i_sess *sess;
> +	struct bnx2i_hba *hba;
> +
> +	shost = cmd->scsi_cmd->device->host;
> +	sess = iscsi_hostdata(shost->hostdata);
> +	BUG_ON(shost != sess->host);
> +
> +	if (sess && (is_sess_active(sess)))
> +		hba = sess->hba;
> +	else
> +		return FAILED;
> +
> +	if (test_bit(ADAPTER_STATE_LINK_DOWN, &hba->adapter_state))
> +		return FAILED;
> +
> +	bnx2i_setup_ictx_dump(hba, conn);
> +
> +	if (cmd->scsi_cmd != sc)
> +		/* command already completed to scsi mid-layer */
> +		goto cmd_not_active;
> +
> +	tmf_cmd = bnx2i_alloc_cmd(sess);
> +	if (tmf_cmd == NULL)
> +		goto lack_of_resc;
> +
> +	tmf_cmd->conn = conn = sess->lead_conn;
> +	tmf_cmd->scsi_cmd = NULL;
> +	tmf_cmd->iscsi_opcode = ISCSI_OPCODE_TMF_REQUEST;
> +	tmf_cmd->req.cmd_sn = sess->cmdsn;
> +	tmf_cmd->tmf_ref_itt = cmd->req.itt;
> +	tmf_cmd->tmf_ref_cmd = cmd;
> +	tmf_cmd->tmf_ref_sc = cmd->scsi_cmd;
> +	cmd->cmd_state = ISCSI_CMD_STATE_ABORT_PEND;
> +	tmf_cmd->cmd_state = ISCSI_CMD_STATE_INITIATED;
> +
> +#define BNX2I_TMF_TIMEOUT	10 * HZ
> +	sess->abort_timer.expires = BNX2I_TMF_TIMEOUT + jiffies;
> +	sess->abort_timer.function = bnx2i_iscsi_tmf_timer;
> +	sess->abort_timer.data = (unsigned long)tmf_cmd;
> +	add_timer(&sess->abort_timer);
> +
> +	bnx2i_send_iscsi_tmf(conn, tmf_cmd);
> +
> +	/* update iSCSI context for this conn, wait for CNIC to complete */
> +	wait_event_interruptible(sess->er_wait, (!conn->ep ||
> +		 			 (tmf_cmd->cmd_state ==
> +					  ISCSI_CMD_STATE_FAILED) ||
> +					 (tmf_cmd->cmd_state ==
> +					  ISCSI_CMD_STATE_COMPLETED)));
> +
> +	if (signal_pending(current))
> +		flush_signals(current);
> +
> +	del_timer_sync(&sess->abort_timer);
> +
> +	if (tmf_cmd->cmd_state == ISCSI_CMD_STATE_TMF_TIMEOUT) {
> +		printk(KERN_ALERT "abort: abort failed, cmd 0x%p\n", tmf_cmd);
> +		/* TMF timed out, return error status and let SCSI-ML do
> +		 * session recovery.
> +		 */
> +		list_del_init(&tmf_cmd->link);
> +		bnx2i_free_cmd(sess, tmf_cmd);
> +		return SUCCESS;
> +	}
> +
> +	list_del_init(&tmf_cmd->link);
> +	bnx2i_free_cmd(sess, tmf_cmd);
> +
> +	if ((cmd->scsi_cmd->result & 0xFF0000) == (DID_ABORT << 16)) {
> +		cmd->cmd_state = ISCSI_CMD_STATE_CLEANUP_PEND;
> +		bnx2i_send_cmd_cleanup_req(hba, cmd);
> +		wait_event_interruptible_timeout(sess->er_wait,
> +						 (cmd->cmd_state ==
> +						  ISCSI_CMD_STATE_CLEANUP_CMPL),
> +						 msecs_to_jiffies(
> +						  ISCSI_CMD_CLEANUP_TIMEOUT));
> +
> +		if (signal_pending(current))
> +			flush_signals(current);
> +	} else
> +		cmd->scsi_cmd->result = (DID_ABORT << 16);
> +
> +	cmd->conn->sess->num_active_cmds--;
> +	list_del_init(&cmd->link);
> +	bnx2i_return_failed_command(sess, cmd, DID_ABORT);
> +	bnx2i_free_cmd(sess, cmd);
> +
> +cmd_not_active:
> +	return SUCCESS;
> +
> +lack_of_resc:
> +	return FAILED;
> +}
> +
> +
> +/*
> + * SCSI abort request handler.
> + */
> +int bnx2i_abort(struct scsi_cmnd *sc)
> +{
> +	int reason;
> +	struct bnx2i_cmd *cmd = (struct bnx2i_cmd *) sc->SCp.ptr;
> +
> +	if (unlikely(!cmd)) {
> +		/* command already completed to scsi mid-layer */
> +		printk(KERN_INFO "bnx2i_abort: sc 0x%p, not active\n", sc);
> +		return SUCCESS;
> +	}
> +
> +	reason = bnx2i_initiate_abort_cmd(sc);
> +	return reason;
> +}
> +
> +
> +
> +/*
> + * hardware reset
> + */
> +int bnx2i_reset(struct scsi_cmnd *sc)
> +{
> +	return 0;
> +}


So what is up with this one? It seems like if there is a way to reset 
hardware then you would want it as the scsi eh host reset callout 
instead of dropping the session. We could add some transport level 
recovery callouts for the iscsi specifics.


> +
> +
> +void bnx2i_return_failed_command(struct bnx2i_sess *sess,
> +				 struct bnx2i_cmd *cmd, int err_code)
> +{
> +	struct scsi_cmnd *sc = cmd->scsi_cmd;
> +	sc->result = err_code << 16;
> +	sc->resid = cmd->scsi_cmd->request_bufflen;
> +	cmd->scsi_cmd = NULL;
> +	sess->num_active_cmds--;
> +	sc->SCp.ptr = NULL;
> +	sc->scsi_done(sc);
> +}
> +
> +
> +
> +/*
> + * SCSI host reset handler - iSCSI session recovery
> + */
> +int bnx2i_host_reset(struct scsi_cmnd *sc)
> +{
> +	struct Scsi_Host *shost;
> +	struct bnx2i_sess *sess;
> +	int rc = 0;
> +
> +	shost = sc->device->host;
> +	sess = iscsi_hostdata(shost->hostdata);
> +	printk(KERN_INFO "bnx2i: attempting to reset host, #%d\n",
> +			  sess->host->host_no);
> +
> +	BUG_ON(shost != sess->host);
> +	rc = bnx2i_do_iscsi_sess_recovery(sess, DID_RESET);
> +
> +	return rc;
> +}
> +
> +
> +
> +/**********************************************************************
> + *		open-iscsi interface
> + **********************************************************************/
> +
> +
> +#define get_bnx2_device(_hba, _devc) 	do {				\
> +		if ((_hba->pci_did == PCI_DEVICE_ID_NX2_5706) ||	\
> +			(_hba->pci_did == PCI_DEVICE_ID_NX2_5706S)) {	\
> +			_devc = '6';					\
> +		} else if ((_hba->pci_did == PCI_DEVICE_ID_NX2_5708) ||	\
> +			(_hba->pci_did == PCI_DEVICE_ID_NX2_5708S)) {	\
> +			_devc = '8';					\
> +		} else if ((_hba->pci_did == PCI_DEVICE_ID_NX2_5709) ||	\
> +			(_hba->pci_did == PCI_DEVICE_ID_NX2_5709S)) {	\
> +			_devc = '9';					\
> +		}							\
> +	} while (0)
> +
> +/* from open-iscsi project */
> +/*
> + * iSCSI Session's hostdata organization:
> + *
> + *    *------------------* <== hostdata_session(host->hostdata)
> + *    | ptr to class sess|
> + *    |------------------| <== iscsi_hostdata(host->hostdata)
> + *    | iscsi_session    |
> + *    *------------------*
> + */



I think it is going to be nicer to not allocate the host with the 
session for bnx2i like was done for qla4xxx. If you are going to 
allocate the host with the session then it seems like you should be able 
to intergrate into libiscsi like was done with iscsi_tcp and ib_iser. 
And even if you do not allocate a host per session it seems like you 
should be able to better integreate with libiscsi like was done with 
iscsi_tcp and ib_iser. Right now, it is sort of a mix of qla4xxx's model 
and iscsi_tcp/ib_iser's model which is not going to work well in the 
long run.

You can change libiscsi so that you do not run in the host's workq and 
so data structs are better optimized for you and whatever else is 
needed. I mean feel free to change that code so it better suits your 
model. Your code is probably closer to ib_iser since that module does 
not have to handle operations like responding to r2ts and has to make 
its own connections.

There seem to be some bugs from when you might have modeled bnx2i's 
callouts after a older iscsi_tcp or ib_iser. Those bugs got fixed for 
both modules for free when libiscsi got fixed.


> +
> +#define hostdata_privsize(_sz)	(sizeof(unsigned long) + _sz + \
> +				 _sz % sizeof(unsigned long))
> +
> +#define hostdata_session(_hostdata) (iscsi_ptr(*(unsigned long *)_hostdata))
> +
> +#define session_to_cls(_sess) 	hostdata_session(_sess->host->hostdata)
> +
> +
> +
> +
> +/*
> + * Function: bnx2i_register_xport
> + * Description: this routine will allocate memory for SCSI host template,
> + * 		iSCSI template and registers one instance of NX2 device with
> + *		iSCSI Transport Kernel module.
> + */
> +int bnx2i_register_xport(struct bnx2i_hba *hba)
> +{
> +	void *mem_ptr;
> +	char dev_id = '8';
> +
> +	get_bnx2_device(hba, dev_id);
> +
> +	mem_ptr = kmalloc(sizeof(struct scsi_host_template), GFP_KERNEL);
> +	hba->scsi_template = mem_ptr;
> +	if (hba->scsi_template == NULL) {
> +		printk(KERN_ALERT "bnx2i: failed to alloc memory for sht\n");
> +		return -ENOMEM;
> +	}
> +
> +	mem_ptr = kmalloc(sizeof(struct iscsi_transport), GFP_KERNEL);
> +	hba->iscsi_transport = mem_ptr;
> +	if (hba->iscsi_transport == NULL) {
> +		printk(KERN_ALERT "mem error for iscsi_transport template\n");
> +		goto iscsi_xport_err;
> +	}
> +
> +	mem_ptr = kmalloc(BRCM_ISCSI_XPORT_NAME_SIZE_MAX, GFP_KERNEL);
> +	if (mem_ptr == NULL) {
> +		printk(KERN_ALERT "failed to alloc memory for xport name\n");
> +		goto scsi_name_mem_err;
> +	}
> +
> +	memcpy(hba->scsi_template, (const void *) &bnx2i_host_template,
> +	       sizeof(struct scsi_host_template));
> +	hba->scsi_template->name = mem_ptr;
> +	memcpy((void *) hba->scsi_template->name,
> +	       (const void *) bnx2i_host_template.name,
> +	       strlen(bnx2i_host_template.name) + 1);
> +
> +	mem_ptr = kmalloc(BRCM_ISCSI_XPORT_NAME_SIZE_MAX, GFP_KERNEL);
> +	if (mem_ptr == NULL) {
> +		printk(KERN_ALERT "failed to alloc proc name mem\n");
> +		goto scsi_proc_name_mem_err;
> +	}
> +	hba->scsi_template->proc_name = mem_ptr;
> +
> +	memcpy((void *) hba->iscsi_transport,
> +	       (const void *) &bnx2i_iscsi_transport,
> +	       sizeof(struct iscsi_transport));
> +
> +	hba->iscsi_transport->host_template = hba->scsi_template;
> +
> +	mem_ptr = kmalloc(BRCM_ISCSI_XPORT_NAME_SIZE_MAX, GFP_KERNEL);
> +	if (mem_ptr == NULL) {
> +		printk(KERN_ALERT "mem alloc error, iscsi xport name\n");
> +		goto xport_name_mem_err;
> +	}
> +	hba->iscsi_transport->name = mem_ptr;
> +	sprintf(mem_ptr, "%s%c-%.2x%.2x%.2x", BRCM_ISCSI_XPORT_NAME_PREFIX,
> +			 dev_id, (u8)hba->pci_dev->bus->number,
> +			 hba->pci_devno, (u8)hba->pci_func);
> +
> +	memcpy((void *) hba->scsi_template->proc_name, (const void *) mem_ptr,
> +	       strlen(mem_ptr) + 1);
> +
> +	hba->shost_template = iscsi_register_transport(hba->iscsi_transport);
> +	if (!hba->shost_template) {
> +		printk(KERN_ALERT "bnx2i: xport reg failed, hba 0x%p\n", hba);
> +		goto failed_registration;
> +	}


The transport should be allocated like qla4xxx or iscsi_tcp/ib_iser. 
Userspace then sets everything up based on usersettings like with 
qla4xxx and iscsi_tcp and ib_iser.

I started that patch that I sent to you guys to modify 
scsi_transport_iscsi abd libiscsi for you guys, but have not finished it 
yet. I am trying to finish merging Olafs iscsi_tcp patches. Feel free to 
change iscsid, scsi_transport_iscsi and libiscsi for me.


> +}
> +
> +int bnx2i_sysfs_setup(void)
> +{
> +	int ret;
> +	ret = class_register(&bnx2i_class);
> +
> +	bnx2i_register_port_class_dev(&port_class_dev);
> +	return ret;
> +}
> +
> +void bnx2i_sysfs_cleanup(void)
> +{
> +	class_device_unregister(&port_class_dev);
> +	class_unregister(&bnx2i_class);
> +}

The sysfs bits related to the hba should be use one of the scsi sysfs 
facilities or if they are related to iscsi bits and are generic then 
through the iscsi hba
