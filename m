From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 56/77] nvme: Update MSI/MSI-X interrupts enablement code
Date: Wed,  2 Oct 2013 12:49:12 +0200
Message-ID: <e8ea98c33d82a110db6bfdda092402ef45692f43.1380703263.git.agordeev@redhat.com>
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
 drivers/block/nvme-core.c |   48 +++++++++++++++++++++++---------------------
 1 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/drivers/block/nvme-core.c b/drivers/block/nvme-core.c
index da52092..f69d7af 100644
--- a/drivers/block/nvme-core.c
+++ b/drivers/block/nvme-core.c
@@ -1774,34 +1774,36 @@ static int nvme_setup_io_queues(struct nvme_dev *dev)
 	/* Deregister the admin queue's interrupt */
 	free_irq(dev->entry[0].vector, dev->queues[0]);
 
-	vecs = nr_io_queues;
+	result = pci_msix_table_size(pdev);
+	if (result < 0)
+		goto msi;
+
+	vecs = min(result, nr_io_queues);
 	for (i = 0; i < vecs; i++)
 		dev->entry[i].entry = i;
-	for (;;) {
-		result = pci_enable_msix(pdev, dev->entry, vecs);
-		if (result <= 0)
-			break;
-		vecs = result;
-	}
 
-	if (result < 0) {
-		vecs = nr_io_queues;
-		if (vecs > 32)
-			vecs = 32;
-		for (;;) {
-			result = pci_enable_msi_block(pdev, vecs);
-			if (result == 0) {
-				for (i = 0; i < vecs; i++)
-					dev->entry[i].vector = i + pdev->irq;
-				break;
-			} else if (result < 0) {
-				vecs = 1;
-				break;
-			}
-			vecs = result;
-		}
+	result = pci_enable_msix(pdev, dev->entry, vecs);
+	if (result == 0)
+		goto irq;
+
+ msi:
+	result = pci_get_msi_cap(pdev);
+	if (result < 0)
+		goto no_msi;
+
+	vecs = min(result, nr_io_queues);
+
+	result = pci_enable_msi_block(pdev, vecs);
+	if (result == 0) {
+		for (i = 0; i < vecs; i++)
+			dev->entry[i].vector = i + pdev->irq;
+		goto irq;
 	}
 
+ no_msi:
+	vecs = 1;
+
+ irq:
 	/*
 	 * Should investigate if there's a performance win from allocating
 	 * more queues than interrupt vectors; it might allow the submission
-- 
1.7.7.6
