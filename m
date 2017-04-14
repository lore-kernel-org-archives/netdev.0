From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 4/7] ixgbe: use pcie_flr instead of duplicating it
Date: Fri, 14 Apr 2017 21:11:28 +0200
Message-ID: <20170414191131.14286-5-hch@lst.de>
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
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a7a430a7be2c..543ddde5f8e2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7112,18 +7112,6 @@ static void ixgbe_watchdog_flush_tx(struct ixgbe_adapter *adapter)
 }
 
 #ifdef CONFIG_PCI_IOV
-static inline void ixgbe_issue_vf_flr(struct ixgbe_adapter *adapter,
-				      struct pci_dev *vfdev)
-{
-	if (!pci_wait_for_pending_transaction(vfdev))
-		e_dev_warn("Issuing VFLR with pending transactions\n");
-
-	e_dev_err("Issuing VFLR for VF %s\n", pci_name(vfdev));
-	pcie_capability_set_word(vfdev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_BCR_FLR);
-
-	msleep(100);
-}
-
 static void ixgbe_check_for_bad_vf(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -7156,7 +7144,7 @@ static void ixgbe_check_for_bad_vf(struct ixgbe_adapter *adapter)
 		pci_read_config_word(vfdev, PCI_STATUS, &status_reg);
 		if (status_reg != IXGBE_FAILED_READ_CFG_WORD &&
 		    status_reg & PCI_STATUS_REC_MASTER_ABORT)
-			ixgbe_issue_vf_flr(adapter, vfdev);
+			pcie_flr(vfdev);
 	}
 }
 
@@ -10244,7 +10232,7 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
 		 * VFLR.  Just clean up the AER in that case.
 		 */
 		if (vfdev) {
-			ixgbe_issue_vf_flr(adapter, vfdev);
+			pcie_flr(vfdev);
 			/* Free device reference count */
 			pci_dev_put(vfdev);
 		}
-- 
2.11.0
