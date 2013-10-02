From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 34/77] ioat: Update MSI/MSI-X interrupts enablement code
Date: Wed,  2 Oct 2013 12:48:50 +0200
Message-ID: <63caad476ca6b7f3481d5512febcb4ef3db72209.1380703263.git.agordeev@redhat.com>
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
 drivers/dma/ioat/dma.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index acee3b2..b352ee6 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -915,15 +915,19 @@ int ioat_dma_setup_interrupts(struct ioatdma_device *device)
 
 msix:
 	/* The number of MSI-X vectors should equal the number of channels */
+	err = pci_msix_table_size(pdev);
+	if (err < 0)
+		goto msi;
+	if (err < device->common.chancnt)
+		goto msix_single_vector;
+
 	msixcnt = device->common.chancnt;
 	for (i = 0; i < msixcnt; i++)
 		device->msix_entries[i].entry = i;
 
 	err = pci_enable_msix(pdev, device->msix_entries, msixcnt);
-	if (err < 0)
+	if (err)
 		goto msi;
-	if (err > 0)
-		goto msix_single_vector;
 
 	for (i = 0; i < msixcnt; i++) {
 		msix = &device->msix_entries[i];
-- 
1.7.7.6
