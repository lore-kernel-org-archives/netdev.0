From: "Rangankar, Manish" <Manish.Rangankar@cavium.com>
Subject: Re: [RFC 3/6] qedi: Add QLogic FastLinQ offload iSCSI driver
 framework.
Date: Sun, 23 Oct 2016 14:04:55 +0000
Message-ID: <D432C019.34346%manish.rangankar@cavium.com>
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
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20161019100253.vxqxp5fhoxrlt6ay@linux-x5ow.site>
Content-Language: en-US
Content-ID: <4E65F5CC5A6CA4489E7F5686A203BEE5@namprd07.prod.outlook.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


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

If there is no serious objection with current per-cpu threads
implementation
then we will like to do workqueue changes just after first submission.
This is because,=20
for this change we have go through complete validation cycle on our part.


Thanks,
Manish R.

