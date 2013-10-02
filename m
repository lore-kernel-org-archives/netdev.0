From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 16/77] cciss: Update MSI/MSI-X interrupts enablement code
Date: Wed,  2 Oct 2013 12:48:32 +0200
Message-ID: <0498333a0ddc360d43d4496310917a5d0f9a51fd.1380703262.git.agordeev@redhat.com>
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
 drivers/block/cciss.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/block/cciss.c b/drivers/block/cciss.c
index d2d95ff..80068a0 100644
--- a/drivers/block/cciss.c
+++ b/drivers/block/cciss.c
@@ -4079,7 +4079,11 @@ static void cciss_interrupt_mode(ctlr_info_t *h)
 		goto default_int_mode;
 
 	if (pci_find_capability(h->pdev, PCI_CAP_ID_MSIX)) {
-		err = pci_enable_msix(h->pdev, cciss_msix_entries, 4);
+		err = pci_msix_table_size(h->pdev);
+		if (err < ARRAY_SIZE(cciss_msix_entries))
+			goto default_int_mode;
+		err = pci_enable_msix(h->pdev, cciss_msix_entries,
+				      ARRAY_SIZE(cciss_msix_entries));
 		if (!err) {
 			h->intr[0] = cciss_msix_entries[0].vector;
 			h->intr[1] = cciss_msix_entries[1].vector;
@@ -4088,15 +4092,8 @@ static void cciss_interrupt_mode(ctlr_info_t *h)
 			h->msix_vector = 1;
 			return;
 		}
-		if (err > 0) {
-			dev_warn(&h->pdev->dev,
-				"only %d MSI-X vectors available\n", err);
-			goto default_int_mode;
-		} else {
-			dev_warn(&h->pdev->dev,
-				"MSI-X init failed %d\n", err);
-			goto default_int_mode;
-		}
+		dev_warn(&h->pdev->dev, "MSI-X init failed %d\n", err);
+		goto default_int_mode;
 	}
 	if (pci_find_capability(h->pdev, PCI_CAP_ID_MSI)) {
 		if (!pci_enable_msi(h->pdev))
-- 
1.7.7.6
