From: Saurav Kashyap <saurav.kashyap@qlogic.com>
Subject: Re: [PATCH RFC 59/77] qla2xxx: Update MSI/MSI-X interrupts
 enablement code
Date: Thu, 3 Oct 2013 17:42:33 +0000
Message-ID: <F5D084D6342F9B479C34599BB0A03E4D8982E209@AVMB1.qlogic.org>
References: <54f6b89372f51cd27a6adf6ecc91b8bf6bb5ba74.1380703263.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Bjorn Helgaas <bhelgaas@google.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Michael Ellerman <michael@ellerman.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        "Ingo Molnar" <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
        Matt Porter <mporter@kernel.crashing.org>,
        linux-pci <linux-pci@vger.kernel.org>,
        "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "linux390@de.ibm.com" <linux390@de.ibm.com>,
        "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
        "x86@kernel.org" <x86@kernel.org>,
        "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>
To: Alexander Gordeev <agordeev@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <54f6b89372f51cd27a6adf6ecc91b8bf6bb5ba74.1380703263.git.agordeev@redhat.com>
Content-Language: en-US
Content-ID: <7ECF417E2B641E48ADC3CD2AEF525292@qlogic.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Acked-by: Saurav Kashyap <saurav.kashyap@qlogic.com>


>As result of recent re-design of the MSI/MSI-X interrupts enabling
>pattern this driver has to be updated to use the new technique to
>obtain a optimal number of MSI/MSI-X interrupts required.
>
>Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
>---
> drivers/scsi/qla2xxx/qla_isr.c |   18 +++++++++++-------
> 1 files changed, 11 insertions(+), 7 deletions(-)
>
>diff --git a/drivers/scsi/qla2xxx/qla_isr.c
>b/drivers/scsi/qla2xxx/qla_isr.c
>index df1b30b..6c11ab9 100644
>--- a/drivers/scsi/qla2xxx/qla_isr.c
>+++ b/drivers/scsi/qla2xxx/qla_isr.c
>@@ -2836,16 +2836,20 @@ qla24xx_enable_msix(struct qla_hw_data *ha,
>struct rsp_que *rsp)
> 	for (i = 0; i < ha->msix_count; i++)
> 		entries[i].entry = i;
> 
>-	ret = pci_enable_msix(ha->pdev, entries, ha->msix_count);
>-	if (ret) {
>+	ret = pci_msix_table_size(ha->pdev);
>+	if (ret < 0) {
>+		goto msix_failed;
>+	} else {
> 		if (ret < MIN_MSIX_COUNT)
> 			goto msix_failed;
> 
>-		ql_log(ql_log_warn, vha, 0x00c6,
>-		    "MSI-X: Failed to enable support "
>-		    "-- %d/%d\n Retry with %d vectors.\n",
>-		    ha->msix_count, ret, ret);
>-		ha->msix_count = ret;
>+		if (ret < ha->msix_count) {
>+			ql_log(ql_log_warn, vha, 0x00c6,
>+			    "MSI-X: Failed to enable support "
>+			    "-- %d/%d\n Retry with %d vectors.\n",
>+			    ha->msix_count, ret, ret);
>+			ha->msix_count = ret;
>+		}
> 		ret = pci_enable_msix(ha->pdev, entries, ha->msix_count);
> 		if (ret) {
> msix_failed:
>-- 
>1.7.7.6
>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-scsi" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
