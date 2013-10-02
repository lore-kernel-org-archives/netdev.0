From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 45/77] megaraid: Update MSI/MSI-X interrupts enablement code
Date: Wed,  2 Oct 2013 12:49:01 +0200
Message-ID: <9c28bb824f403b6418840970f2a3b63d9fa9d924.1380703263.git.agordeev@redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Michael Ellerman <michael@ellerman.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
        Matt Porter <mporter@kernel.crashing.org>,
        linux-pci@vger.kernel.org, linux-mips@linux-mips.org,
        linuxppc-dev@lists.ozlabs.org, linux390@de.ibm.com,
        linux-s390@vger.kernel.org, x86@kernel.org,
        linux-ide@vger.kernel.org, iss_storagedev@hp.com,
        linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, e1000-devel@lists.sourceforge.ne
To: linux-kernel@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <cover.1380703262.git.agordeev@redhat.com>
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

As result of recent re-design of the MSI/MSI-X interrupts enabling
pattern this driver has to be updated to use the new technique to
obtain a optimal number of MSI/MSI-X interrupts required.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/scsi/megaraid/megaraid_sas_base.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/scsi/megaraid/megaraid_sas_base.c b/drivers/scsi/megaraid/megaraid_sas_base.c
index 3020921..b5973e4 100644
--- a/drivers/scsi/megaraid/megaraid_sas_base.c
+++ b/drivers/scsi/megaraid/megaraid_sas_base.c
@@ -3727,18 +3727,16 @@ static int megasas_init_fw(struct megasas_instance *instance)
 					     (unsigned int)num_online_cpus());
 		for (i = 0; i < instance->msix_vectors; i++)
 			instance->msixentry[i].entry = i;
-		i = pci_enable_msix(instance->pdev, instance->msixentry,
-				    instance->msix_vectors);
-		if (i >= 0) {
-			if (i) {
-				if (!pci_enable_msix(instance->pdev,
-						     instance->msixentry, i))
-					instance->msix_vectors = i;
-				else
-					instance->msix_vectors = 0;
-			}
-		} else
+		i = pci_msix_table_size(instance->pdev);
+		if (i < 0) {
 			instance->msix_vectors = 0;
+		} else {
+			if (!pci_enable_msix(instance->pdev,
+					     instance->msixentry, i))
+				instance->msix_vectors = i;
+			else
+				instance->msix_vectors = 0;
+		}
 
 		dev_info(&instance->pdev->dev, "[scsi%d]: FW supports"
 			"<%d> MSIX vector,Online CPUs: <%d>,"
-- 
1.7.7.6
