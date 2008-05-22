From: "Anil Veerabhadrappa" <anilgv@broadcom.com>
Subject: Re: [PATCH 3/3] bnx2i: Add bnx2i iSCSI driver.
Date: Thu, 22 May 2008 12:06:14 -0700
Message-ID: <1211483174.16180.72.camel@dhcp-10-13-110-217.broadcom.com>
References: <1211418386-18203-1-git-send-email-mchan@broadcom.com>
 <1211418386-18203-4-git-send-email-mchan@broadcom.com>
 <20080522151540.GA27897@mars.virtualiron.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: open-iscsi@googlegroups.com, davem@davemloft.net,
	michaelc@cs.wisc.edu, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: "Konrad Rzeszutek" <konrad@virtualiron.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20080522151540.GA27897@mars.virtualiron.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-05-22 at 11:15 -0400, Konrad Rzeszutek wrote:
> A cursory glance..
> 
> .. snip..
> > +struct bnx2i_cleanup_request {
> > +#if defined(__BIG_ENDIAN)
> > +	u8 op_code;
> > +	u8 reserved1;
> > +	u16 reserved0;
> > +#elif defined(__LITTLE_ENDIAN)
> > +	u16 reserved0;
> > +	u8 reserved1;
> > +	u8 op_code;
> > +#endif
> > +	u32 reserved2[3];
> > +#if defined(__BIG_ENDIAN)
> > +	u16 reserved3;
> > +	u16 itt;
> > +#define ISCSI_CLEANUP_REQUEST_INDEX (0x3FFF<<0)
> > +#define ISCSI_CLEANUP_REQUEST_INDEX_SHIFT 0
> > +#define ISCSI_CLEANUP_REQUEST_TYPE (0x3<<14)
> > +#define ISCSI_CLEANUP_REQUEST_TYPE_SHIFT 14
> > +#elif defined(__LITTLE_ENDIAN)
> > +	u16 itt;
> > +#define ISCSI_CLEANUP_REQUEST_INDEX (0x3FFF<<0)
> > +#define ISCSI_CLEANUP_REQUEST_INDEX_SHIFT 0
> > +#define ISCSI_CLEANUP_REQUEST_TYPE (0x3<<14)
> > +#define ISCSI_CLEANUP_REQUEST_TYPE_SHIFT 14
> > +	u16 reserved3;
> > +#endif
> 
> 
> Why the duplication of the #define values? They look the same.
> 
Sure we can take care of that by moving macros outside of #ifdef

> 
> .. snip ..
> > +/*
> > + * mnc - lookup Jeff Garzack's rule about defining this
> 
> Has this TODO been completed?
> 
> > + * type of junk. Base on enum and make it less error prone.
> > + *	Anil - these are bit masks, won't enum be little ugly?
> > + */
> .. snip ..
> 
> > + * bnx2i_iscsi_license_error - displays iscsi license related error message
> 
> Doesn't look very license related. Just says 'not supported'.
> 
> > + * @hba:		adapter instance pointer
> > + * @error_code:		error classification
> > + *
> > + * Puts out an error log when driver is unable to offload iscsi connection
> > + *	due to license restrictions
> 
> Maybe adding in some extra information to the error, such as: "Due to
> GPL restrictions, etc.." .. What does 'LOM' stand for?

This has nothing to do with code licensing but related to whether iSCSI
functionality is enabled on the device or not. iSCSI feature can be
controlled through NVRAM configuration and some OEM's do not enable
iscsi
 

> 
> > + */
> > +static void bnx2i_iscsi_license_error(struct bnx2i_hba *hba, u32 error_code)
> > +{
> > +	if (error_code == ISCSI_KCQE_COMPLETION_STATUS_ISCSI_NOT_SUPPORTED)
> > +		/* iSCSI offload not supported on this device */
> > +		printk(KERN_ERR "bnx2i: iSCSI not supported, dev=%s\n",
> > +				hba->netdev->name);
> > +	if (error_code == ISCSI_KCQE_COMPLETION_STATUS_LOM_ISCSI_NOT_ENABLED)
> > +		/* iSCSI offload not supported on this LOM device */
> > +		printk(KERN_ERR "bnx2i: LOM is not enable to "
>                                             ^^^^-enabled.
> > +				"offload iSCSI connections, dev=%s\n",
> > +				hba->netdev->name);
> > +	set_bit(ADAPTER_STATE_INIT_FAILED, &hba->adapter_state);
> > +}
> > +
> > +#ifdef _EVENT_COALESCE_
> > +#define CNIC_ARM_CQE			1
> > +#define CNIC_DISARM_CQE			0
> > +extern unsigned int event_coal_div;
> > +
> > +/**
> > + * bnx2i_arm_cq_event_coalescing - arms CQ to enable EQ notification
> > + * @ep:		endpoint (transport indentifier) structure
> > + * @action:	action, ARM or DISARM. For now only ARM_CQE is used
> > + *
> > + * Arm'ing CQ will enable chip to generate global EQ events inorder to interrupt
> > + *	the driver. EQ event is generated CQ index is hit or at least 1 CQ is
> > + *	outstanding and on chip timer expires
> > + */
> > +static void bnx2i_arm_cq_event_coalescing(struct bnx2i_endpoint *ep, u8 action)
> > +{
> > +	u16 cq_index;
> > +	if ((action == CNIC_ARM_CQE) && ep->sess) {
> > +		cq_index = ep->qp.cqe_exp_seq_sn +
> > +			   ep->sess->num_active_cmds / event_coal_div;
> > +		cq_index %= (ep->qp.cqe_size * 2 + 1);
> > +		if (!cq_index)
> > +			cq_index = 1;
> > +		writew(cq_index, ep->qp.ctx_base + CNIC_EVENT_COAL_INDEX);
> > +	}
> > +	writeb(action, ep->qp.ctx_base + CNIC_EVENT_CQ_ARM);
> 
> This code looks to be outside the function. Did you try to compile with the
> _EVENT_COALESCE_ define?

function construction is ok, may be an additional blank line after
writeb() the reason for confusion
 
> 
> .. snip ..
> > +int bnx2i_send_iscsi_tmf(struct bnx2i_conn *bnx2i_conn,
> > +			 struct iscsi_task *mtask)
> .. snip
> > +	tmfabort_wqe->op_attr = 0;
> > +	tmfabort_wqe->op_attr =
> > +		ISCSI_TMF_REQUEST_ALWAYS_ONE | ISCSI_TM_FUNC_ABORT_TASK;
> 
> Is the first assigment neccessary?
> 
> .. snip ..
> > +static int bnx2i_power_of2(u32 val)
> 
> There are no macros for this?

Did not find one. But there is is_power_of_2() to check if the given
integer is an exact power of 2

> 
> .. snip ..
> > +static void bnx2i_process_async_mesg(struct iscsi_session *session,
> > +				     struct bnx2i_conn *bnx2i_conn,
> > +				     struct cqe *cqe)
> > +{
> > +	struct bnx2i_async_msg *async_cqe;
> > +	struct iscsi_async *resp_hdr;
> > +	u8 async_event;
> > +
> > +	bnx2i_unsol_pdu_adjust_rq(bnx2i_conn);
> > +
> > +	async_cqe = (struct bnx2i_async_msg *)cqe;
> > +	async_event = async_cqe->async_event;
> > +
> > +	if (async_event == ISCSI_ASYNC_MSG_SCSI_EVENT) {
> > +		/* TODO mnc - can't we just copy the scsi sense buffer
> > +		 * to the conn->data buffer
> > +		 * Anil - currently there is no interface to push this
> > +		 * 	  up to SCSI layer. So far we have not seen any
> > +		 *	  target generating one. So could be one those
> > +		 *	  fancy unused feature
> > +		 *
> > +		 * For iser/tcp we pass this to libiscsi which does
> > +		 * iscsi_recv_pdu to send it to userspace.
> > +		 *
> > +		 * This event is used by Cisco to signal that a lun
> > +		 * has been added or removed. It is also used by
> > +		 * EMC celerra or centerra boxes, and EMC will ping
> > +		 * you one day :), so we have to do something.
> 
> Yes. This would be really nice if it was passed to the
> userspace.  Especially since the iscsi daemon re-scans
> the SCSI blk device when this is triggered.

yes, we will include this in later revision


> 
> > +		 */
> > +		iscsi_conn_printk(KERN_ALERT, bnx2i_conn->cls_conn->dd_data,
> > +				  "async: scsi events not supported\n");
> 
> You might want to include the SCSI sense buffer as well in the
> printk.
> 
> .. snip ..
> > +static void bnx2i_process_iscsi_error(struct bnx2i_hba *hba,
> > +				      struct iscsi_kcqe *iscsi_err)
> > +{
> .. snip ..
> > +	char additional_notice[64];
> .. snip ..
> > +	switch (iscsi_err->completion_status) {
> > +	case ISCSI_KCQE_COMPLETION_STATUS_HDR_DIG_ERR:
> > +		strcpy(additional_notice, "hdr digest err");
> 
> You don't want to memset the 'additional_notice' so that you are
> guaranteed to have the \0 at the end?
> .. snip ..
> 
> > +
> > +unsigned int event_coal_div = 1;
> > +module_param(event_coal_div, int, 0664);
> > +MODULE_PARM_DESC(event_coal_div, "Event Coalescing Divide Factor");
> 
> Should that have an #ifdef around it? You are not using it except
> in the code that has the #ifdef _EVENT_COALESCE_
> .. snip..

Thanks. Will make this change in the next revision

> > +static struct iscsi_endpoint *bnx2i_alloc_ep(struct bnx2i_hba *hba)
> > +{
> .. snip ..
> > +	tcp_port = bnx2i_alloc_tcp_port();
> > +	if (!tcp_port) {
> > +		printk(KERN_ERR "bnx2i: run 'bnx2id' to alloc tcp ports\n");
> 
> Is that correct? Or will this be handled by iscsid?
> 

This will be handled by a separate user daemon, bnx2id
 

> .. snip ..
> > +static void bnx2i_cleanup_task(struct iscsi_conn *conn,
> > +			       struct iscsi_task *task)
> > +{
> > +	struct bnx2i_conn *bnx2i_conn = conn->dd_data;
> > +	struct bnx2i_hba *hba = bnx2i_conn->hba;
> > +
> > +	/*
> > +	 * mgmt task or cmd completed while tmf in progress.
> > +	 */
> > +	if (!task->sc)
> > +		return;
> > +	/*
> > +	 * ANIL
> > +	 * do we have to do this for other tmfs?
> > +	 */
> 
> Not finished TODO?
> .. snip ..

We just forgot to remove the comments


> 
> > + */
> > +static struct scsi_host_template bnx2i_host_template = {
> > +	.module			= THIS_MODULE,
> > +	.name			= "Broadcom Offload iSCSI Initiator",
> > +	.proc_name		= "bnx2i",
> > +	.queuecommand		= iscsi_queuecommand,
> > +	.slave_alloc		= iscsi_slave_alloc,
> > +	.eh_abort_handler	= iscsi_eh_abort,
> > +/*
> > + * Anil
> > + * uncomment this when we know if we need to do a
> > + * ISCSI_OPCODE_CLEANUP_REQUEST on tasks that are affected by
> > + * the lu reset.
> 
> What is the verdict?

Will remove these old notes between Mike & myself. This has to do with
reclaiming task resources which got affected by lun reset and it
correctly handled by the driver set


> > +	.eh_device_reset_handler = iscsi_eh_device_reset,
> > +*/
> > +	.eh_target_reset_handler = iscsi_eh_target_reset,
> > +	/* TODO - just make this the max sessions * max_cmds_per_session */
> 
> And is 1024 the right value?
> 

Because the same driver handles multiple devices with different hardware
capabilities, we recently changed the driver to assign 'can_queue' value
based on the device type. This change got missed out in this revision as
Mike Christie merged this change a couple of days back. 

