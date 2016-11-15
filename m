From: "Rangankar, Manish" <Manish.Rangankar@cavium.com>
Subject: Re: [PATCH v2 3/6] qedi: Add QLogic FastLinQ offload iSCSI driver
 framework.
Date: Tue, 15 Nov 2016 06:14:18 +0000
Message-ID: <D450A21F.3537A%manish.rangankar@cavium.com>
References: <1478588223-16183-1-git-send-email-manish.rangankar@cavium.com>
 <1478588223-16183-4-git-send-email-manish.rangankar@cavium.com>
 <d5abc303-1514-c521-390c-adfdd0e204af@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Dept-Eng QLogic Storage Upstream"
        <QLogic-Storage-Upstream@cavium.com>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>
To: "Martin K. Petersen" <martin.petersen@oracle.com>,
        "lduncan@suse.com" <lduncan@suse.com>,
        Chris Leech <cleech@redhat.com>, Hannes Reinecke <hare@suse.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <d5abc303-1514-c521-390c-adfdd0e204af@suse.de>
Content-Language: en-US
Content-ID: <67DBC82DBCA0964EB499101D1BC3368B@namprd07.prod.outlook.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Hannes,

Please find the response below,

On 11/11/16 10:13 PM, "Hannes Reinecke" <hare@suse.de> wrote:

>On 11/08/2016 07:57 AM, Manish Rangankar wrote:
>> The QLogic FastLinQ Driver for iSCSI (qedi) is the iSCSI specific module
>> for 41000 Series Converged Network Adapters by QLogic.
>>
>> This patch consists of following changes:
>>   - MAINTAINERS Makefile and Kconfig changes for qedi,
>>   - PCI driver registration,
>>   - iSCSI host level initialization,
>>   - Debugfs and log level infrastructure.
>>
>> Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
>> Signed-off-by: Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>
>> Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
>> Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
>> Signed-off-by: Arun Easi <arun.easi@cavium.com>
>> Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
>> ---
>>  MAINTAINERS                         |    6 +
>>  drivers/net/ethernet/qlogic/Kconfig |   12 -
>>  drivers/scsi/Kconfig                |    1 +
>>  drivers/scsi/Makefile               |    1 +
>>  drivers/scsi/qedi/Kconfig           |   10 +
>>  drivers/scsi/qedi/Makefile          |    5 +
>>  drivers/scsi/qedi/qedi.h            |  291 +++++++
>>  drivers/scsi/qedi/qedi_dbg.c        |  143 ++++
>>  drivers/scsi/qedi/qedi_dbg.h        |  144 ++++
>>  drivers/scsi/qedi/qedi_debugfs.c    |  244 ++++++
>>  drivers/scsi/qedi/qedi_hsi.h        |   52 ++
>>  drivers/scsi/qedi/qedi_main.c       | 1616
>>+++++++++++++++++++++++++++++++++++
>>  drivers/scsi/qedi/qedi_sysfs.c      |   52 ++
>>  drivers/scsi/qedi/qedi_version.h    |   14 +
>>  14 files changed, 2579 insertions(+), 12 deletions(-)
>>  create mode 100644 drivers/scsi/qedi/Kconfig
>>  create mode 100644 drivers/scsi/qedi/Makefile
>>  create mode 100644 drivers/scsi/qedi/qedi.h
>>  create mode 100644 drivers/scsi/qedi/qedi_dbg.c
>>  create mode 100644 drivers/scsi/qedi/qedi_dbg.h
>>  create mode 100644 drivers/scsi/qedi/qedi_debugfs.c
>>  create mode 100644 drivers/scsi/qedi/qedi_hsi.h
>>  create mode 100644 drivers/scsi/qedi/qedi_main.c
>>  create mode 100644 drivers/scsi/qedi/qedi_sysfs.c
>>  create mode 100644 drivers/scsi/qedi/qedi_version.h
>>
[...]
>>
>> +static enum qed_int_mode qedi_int_mode_to_enum(void)
>> +{
>> +	switch (int_mode) {
>> +	case 0: return QED_INT_MODE_MSIX;
>> +	case 1: return QED_INT_MODE_INTA;
>> +	case 2: return QED_INT_MODE_MSI;
>> +	default:
>> +		QEDI_ERR(NULL, "Unknown qede_int_mode=3D%08x; "
>> +			 "Defaulting to MSI-x\n", int_mode);
>> +		return QED_INT_MODE_MSIX;
>> +	}
>> +}
>Errm. A per-driver interrupt mode?
>How very curious.
>You surely want to make that per-HBA, right?

This was added for testing purpose, we will remove this code.
=20

[...]
>> +static int qedi_request_msix_irq(struct qedi_ctx *qedi)
>> +{
>> +	int i, rc, cpu;
>> +
>> +	cpu =3D cpumask_first(cpu_online_mask);
>> +	for (i =3D 0; i < MIN_NUM_CPUS_MSIX(qedi); i++) {
>> +		rc =3D request_irq(qedi->int_info.msix[i].vector,
>> +				 qedi_msix_handler, 0, "qedi",
>> +				 &qedi->fp_array[i]);
>> +
>> +		if (rc) {
>> +			QEDI_WARN(&qedi->dbg_ctx, "request_irq failed.\n");
>> +			qedi_sync_free_irqs(qedi);
>> +			return rc;
>> +		}
>> +		qedi->int_info.used_cnt++;
>> +		rc =3D irq_set_affinity_hint(qedi->int_info.msix[i].vector,
>> +					   get_cpu_mask(cpu));
>> +		cpu =3D cpumask_next(cpu, cpu_online_mask);
>> +	}
>> +
>> +	return 0;
>> +}
>Please use the irq-affinity rework from Christoph here; that'll save you
>the additional msix vectors allocation.

The existing qed* driver(s) and common module (qed) framework is built on
top of the older pci_enable_msix_*() API. The new framework requires
re-work on the existing qed common module API. That would need
co-ordination among other dependent drivers (e.g.: qede network driver,
which is already in the tree). We would prefer to add this as a follow on
(to the initial submission) effort, with additional testing done and
submission co-ordinated across protocol drivers.



Thanks,
Manish

