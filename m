From: "Rangankar, Manish" <Manish.Rangankar@cavium.com>
Subject: Re: [RFC 3/6] qedi: Add QLogic FastLinQ offload iSCSI driver
 framework.
Date: Thu, 20 Oct 2016 08:41:01 +0000
Message-ID: <D42E7DDF.340F3%manish.rangankar@cavium.com>
References: <1476853273-22960-1-git-send-email-manish.rangankar@cavium.com>
 <1476853273-22960-4-git-send-email-manish.rangankar@cavium.com>
 <20161019100253.vxqxp5fhoxrlt6ay@linux-x5ow.site>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0075.outbound.protection.outlook.com ([104.47.41.75]:38992
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935266AbcJTI4T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 04:56:19 -0400
In-Reply-To: <20161019100253.vxqxp5fhoxrlt6ay@linux-x5ow.site>
Content-Language: en-US
Content-ID: <CB0E4C3039646C4FAFAF68EBC8D63AEA@namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Johannes for the review, please see comments below,


On 19/10/16 3:32 PM, "Johannes Thumshirn" <jthumshirn@suse.de> wrote:

>On Wed, Oct 19, 2016 at 01:01:10AM -0400, manish.rangankar@cavium.com
>wrote:
>> From: Manish Rangankar <manish.rangankar@cavium.com>
>>=20
>> The QLogic FastLinQ Driver for iSCSI (qedi) is the iSCSI specific module
>> for 41000 Series Converged Network Adapters by QLogic.
>>=20
>> This patch consists of following changes:
>>   - MAINTAINERS Makefile and Kconfig changes for qedi,
>>   - PCI driver registration,
>>   - iSCSI host level initialization,
>>   - Debugfs and log level infrastructure.
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
>> +static inline void *qedi_get_task_mem(struct qed_iscsi_tid *info, u32
>>tid)
>> +{
>> +	return (void *)(info->blocks[tid / info->num_tids_per_block] +
>> +			(tid % info->num_tids_per_block) * info->size);
>> +}
>
>Unnecessary cast here.

Noted

>
>
>[...]
>
>> +void
>> +qedi_dbg_err(struct qedi_dbg_ctx *qedi, const char *func, u32 line,
>> +	     const char *fmt, ...)
>> +{
>> +	va_list va;
>> +	struct va_format vaf;
>> +	char nfunc[32];
>> +
>> +	memset(nfunc, 0, sizeof(nfunc));
>> +	memcpy(nfunc, func, sizeof(nfunc) - 1);
>> +
>> +	va_start(va, fmt);
>> +
>> +	vaf.fmt =3D fmt;
>> +	vaf.va =3D &va;
>> +
>> +	if (likely(qedi) && likely(qedi->pdev))
>> +		pr_crit("[%s]:[%s:%d]:%d: %pV", dev_name(&qedi->pdev->dev),
>> +			nfunc, line, qedi->host_no, &vaf);
>> +	else
>> +		pr_crit("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
>
>pr_crit, seriously?

We will change it to pr_err.

>
>[...]
>
>> +static void qedi_int_fp(struct qedi_ctx *qedi)
>> +{
>> +	struct qedi_fastpath *fp;
>> +	int id;
>> +
>> +	memset((void *)qedi->fp_array, 0, MIN_NUM_CPUS_MSIX(qedi) *
>> +	       sizeof(*qedi->fp_array));
>> +	memset((void *)qedi->sb_array, 0, MIN_NUM_CPUS_MSIX(qedi) *
>> +	       sizeof(*qedi->sb_array));
>
>I don't think the cast is necessary here.

Noted


>
>[...]
>
>> +static int qedi_setup_cid_que(struct qedi_ctx *qedi)
>> +{
>> +	int i;
>> +
>> +	qedi->cid_que.cid_que_base =3D kmalloc((qedi->max_active_conns *
>> +					      sizeof(u32)), GFP_KERNEL);
>> +	if (!qedi->cid_que.cid_que_base)
>> +		return -ENOMEM;
>> +
>> +	qedi->cid_que.conn_cid_tbl =3D kmalloc((qedi->max_active_conns *
>> +					      sizeof(struct qedi_conn *)),
>> +					     GFP_KERNEL);
>
>Please use kmalloc_array() here.

Will do.

>
>[...]
>
>> +/* MSI-X fastpath handler code */
>> +static irqreturn_t qedi_msix_handler(int irq, void *dev_id)
>> +{
>> +	struct qedi_fastpath *fp =3D dev_id;
>> +	struct qedi_ctx *qedi =3D fp->qedi;
>> +	bool wake_io_thread =3D true;
>> +
>> +	qed_sb_ack(fp->sb_info, IGU_INT_DISABLE, 0);
>> +
>> +process_again:
>> +	wake_io_thread =3D qedi_process_completions(fp);
>> +	if (wake_io_thread) {
>> +		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_DISC,
>> +			  "process already running\n");
>> +	}
>> +
>> +	if (qedi_fp_has_work(fp) =3D=3D 0)
>> +		qed_sb_update_sb_idx(fp->sb_info);
>> +
>> +	/* Check for more work */
>> +	rmb();
>> +
>> +	if (qedi_fp_has_work(fp) =3D=3D 0)
>> +		qed_sb_ack(fp->sb_info, IGU_INT_ENABLE, 1);
>> +	else
>> +		goto process_again;
>> +
>> +	return IRQ_HANDLED;
>> +}
>
>You might want to consider workqueues here.

We will revisit this code.

>
>[...]
>
>> +static int qedi_alloc_itt(struct qedi_ctx *qedi)
>> +{
>> +	qedi->itt_map =3D kzalloc((sizeof(struct qedi_itt_map) *
>> +				MAX_ISCSI_TASK_ENTRIES), GFP_KERNEL);
>
>that screams for kcalloc()
>
>> +	if (!qedi->itt_map) {
>> +		QEDI_ERR(&qedi->dbg_ctx,
>> +			 "Unable to allocate itt map array memory\n");
>> +		return -ENOMEM;
>> +	}
>> +	return 0;
>> +}
>> +
>> +static void qedi_free_itt(struct qedi_ctx *qedi)
>> +{
>> +	kfree(qedi->itt_map);
>> +}
>> +
>> +static struct qed_ll2_cb_ops qedi_ll2_cb_ops =3D {
>> +	.rx_cb =3D qedi_ll2_rx,
>> +	.tx_cb =3D NULL,
>> +};
>> +
>> +static int qedi_percpu_io_thread(void *arg)
>> +{
>> +	struct qedi_percpu_s *p =3D arg;
>> +	struct qedi_work *work, *tmp;
>> +	unsigned long flags;
>> +	LIST_HEAD(work_list);
>> +
>> +	set_user_nice(current, -20);
>> +
>> +	while (!kthread_should_stop()) {
>> +		spin_lock_irqsave(&p->p_work_lock, flags);
>> +		while (!list_empty(&p->work_list)) {
>> +			list_splice_init(&p->work_list, &work_list);
>> +			spin_unlock_irqrestore(&p->p_work_lock, flags);
>> +
>> +			list_for_each_entry_safe(work, tmp, &work_list, list) {
>> +				list_del_init(&work->list);
>> +				qedi_fp_process_cqes(work->qedi, &work->cqe,
>> +						     work->que_idx);
>> +				kfree(work);
>> +			}
>> +			spin_lock_irqsave(&p->p_work_lock, flags);
>> +		}
>> +		set_current_state(TASK_INTERRUPTIBLE);
>> +		spin_unlock_irqrestore(&p->p_work_lock, flags);
>> +		schedule();
>> +	}
>> +	__set_current_state(TASK_RUNNING);
>> +
>> +	return 0;
>> +}
>
>A kthread with prio -20 IRQs turned off looping over a list, what could
>possibly go wrong here. I bet you your favorite beverage that this will
>cause Soft Lockups when running I/O stress tests BTDT.

Will remove this.

>
>[...]
>
>> +	if (mode !=3D QEDI_MODE_RECOVERY) {
>> +		if (iscsi_host_add(qedi->shost, &pdev->dev)) {
>> +			QEDI_ERR(&qedi->dbg_ctx,
>> +				 "Could not add iscsi host\n");
>> +			rc =3D -ENOMEM;
>> +			goto remove_host;
>> +		}
>> +
>> +		/* Allocate uio buffers */
>> +		rc =3D qedi_alloc_uio_rings(qedi);
>> +		if (rc) {
>> +			QEDI_ERR(&qedi->dbg_ctx,
>> +				 "UIO alloc ring failed err=3D%d\n", rc);
>> +			goto remove_host;
>> +		}
>> +
>> +		rc =3D qedi_init_uio(qedi);
>> +		if (rc) {
>> +			QEDI_ERR(&qedi->dbg_ctx,
>> +				 "UIO init failed, err=3D%d\n", rc);
>> +			goto free_uio;
>> +		}
>> +
>> +		/* host the array on iscsi_conn */
>> +		rc =3D qedi_setup_cid_que(qedi);
>> +		if (rc) {
>> +			QEDI_ERR(&qedi->dbg_ctx,
>> +				 "Could not setup cid que\n");
>> +			goto free_uio;
>> +		}
>> +
>> +		rc =3D qedi_cm_alloc_mem(qedi);
>> +		if (rc) {
>> +			QEDI_ERR(&qedi->dbg_ctx,
>> +				 "Could not alloc cm memory\n");
>> +			goto free_cid_que;
>> +		}
>> +
>> +		rc =3D qedi_alloc_itt(qedi);
>> +		if (rc) {
>> +			QEDI_ERR(&qedi->dbg_ctx,
>> +				 "Could not alloc itt memory\n");
>> +			goto free_cid_que;
>> +		}
>> +
>> +		sprintf(host_buf, "host_%d", qedi->shost->host_no);
>> +		qedi->tmf_thread =3D create_singlethread_workqueue(host_buf);
>> +		if (!qedi->tmf_thread) {
>> +			QEDI_ERR(&qedi->dbg_ctx,
>> +				 "Unable to start tmf thread!\n");
>> +			rc =3D -ENODEV;
>> +			goto free_cid_que;
>> +		}
>> +
>> +		sprintf(host_buf, "qedi_ofld%d", qedi->shost->host_no);
>> +		qedi->offload_thread =3D create_workqueue(host_buf);
>> +		if (!qedi->offload_thread) {
>> +			QEDI_ERR(&qedi->dbg_ctx,
>> +				 "Unable to start offload thread!\n");
>> +			rc =3D -ENODEV;
>> +			goto free_cid_que;
>> +		}
>> +
>> +		/* F/w needs 1st task context memory entry for performance */
>> +		set_bit(QEDI_RESERVE_TASK_ID, qedi->task_idx_map);
>> +		atomic_set(&qedi->num_offloads, 0);
>> +	}
>> +
>> +	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
>> +		  "QLogic FastLinQ iSCSI Module qedi %s, FW %d.%d.%d.%d\n",
>> +		  QEDI_MODULE_VERSION, FW_MAJOR_VERSION, FW_MINOR_VERSION,
>> +		   FW_REVISION_VERSION, FW_ENGINEERING_VERSION);
>> +	return 0;
>
>Please put the QEDI_INFO() above the if and invert the condition.

Will do.
