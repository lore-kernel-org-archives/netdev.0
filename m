From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 5/7] IB/hfi1: use pcie_flr instead of duplicating it
Date: Fri, 14 Apr 2017 21:11:29 +0200
Message-ID: <20170414191131.14286-6-hch@lst.de>
References: <20170414191131.14286-1-hch@lst.de>
Cc: linux-pci@vger.kernel.org, qat-linux@intel.com,
        linux-crypto@vger.kernel.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bjorn Helgaas <bhelgaas@google.com>,
        Giovanni Cabiddu <giovanni.cabiddu@intel.com>,
        Salvatore Benedetto <salvatore.benedetto@intel.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170414191131.14286-1-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/hw/hfi1/chip.c |  4 ++--
 drivers/infiniband/hw/hfi1/hfi.h  |  1 -
 drivers/infiniband/hw/hfi1/pcie.c | 30 ------------------------------
 3 files changed, 2 insertions(+), 33 deletions(-)

diff --git a/drivers/infiniband/hw/hfi1/chip.c b/drivers/infiniband/hw/hfi1/chip.c
index 121a4c920f1b..d037f72e4d96 100644
--- a/drivers/infiniband/hw/hfi1/chip.c
+++ b/drivers/infiniband/hw/hfi1/chip.c
@@ -13610,14 +13610,14 @@ static void init_chip(struct hfi1_devdata *dd)
 		dd_dev_info(dd, "Resetting CSRs with FLR\n");
 
 		/* do the FLR, the DC reset will remain */
-		hfi1_pcie_flr(dd);
+		pcie_flr(dd->pcidev);
 
 		/* restore command and BARs */
 		restore_pci_variables(dd);
 
 		if (is_ax(dd)) {
 			dd_dev_info(dd, "Resetting CSRs with FLR\n");
-			hfi1_pcie_flr(dd);
+			pcie_flr(dd->pcidev);
 			restore_pci_variables(dd);
 		}
 	} else {
diff --git a/drivers/infiniband/hw/hfi1/hfi.h b/drivers/infiniband/hw/hfi1/hfi.h
index 0808e3c3ba39..40d7559fa723 100644
--- a/drivers/infiniband/hw/hfi1/hfi.h
+++ b/drivers/infiniband/hw/hfi1/hfi.h
@@ -1764,7 +1764,6 @@ int hfi1_pcie_init(struct pci_dev *, const struct pci_device_id *);
 void hfi1_pcie_cleanup(struct pci_dev *);
 int hfi1_pcie_ddinit(struct hfi1_devdata *, struct pci_dev *);
 void hfi1_pcie_ddcleanup(struct hfi1_devdata *);
-void hfi1_pcie_flr(struct hfi1_devdata *);
 int pcie_speeds(struct hfi1_devdata *);
 void request_msix(struct hfi1_devdata *, u32 *, struct hfi1_msix_entry *);
 void hfi1_enable_intx(struct pci_dev *);
diff --git a/drivers/infiniband/hw/hfi1/pcie.c b/drivers/infiniband/hw/hfi1/pcie.c
index 0829fce06172..c81556e84831 100644
--- a/drivers/infiniband/hw/hfi1/pcie.c
+++ b/drivers/infiniband/hw/hfi1/pcie.c
@@ -240,36 +240,6 @@ void hfi1_pcie_ddcleanup(struct hfi1_devdata *dd)
 		iounmap(dd->piobase);
 }
 
-/*
- * Do a Function Level Reset (FLR) on the device.
- * Based on static function drivers/pci/pci.c:pcie_flr().
- */
-void hfi1_pcie_flr(struct hfi1_devdata *dd)
-{
-	int i;
-	u16 status;
-
-	/* no need to check for the capability - we know the device has it */
-
-	/* wait for Transaction Pending bit to clear, at most a few ms */
-	for (i = 0; i < 4; i++) {
-		if (i)
-			msleep((1 << (i - 1)) * 100);
-
-		pcie_capability_read_word(dd->pcidev, PCI_EXP_DEVSTA, &status);
-		if (!(status & PCI_EXP_DEVSTA_TRPND))
-			goto clear;
-	}
-
-	dd_dev_err(dd, "Transaction Pending bit is not clearing, proceeding with reset anyway\n");
-
-clear:
-	pcie_capability_set_word(dd->pcidev, PCI_EXP_DEVCTL,
-				 PCI_EXP_DEVCTL_BCR_FLR);
-	/* PCIe spec requires the function to be back within 100ms */
-	msleep(100);
-}
-
 static void msix_setup(struct hfi1_devdata *dd, int pos, u32 *msixcnt,
 		       struct hfi1_msix_entry *hfi1_msix_entry)
 {
-- 
2.11.0
