From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/7] PCI: call pcie_flr from reset_intel_82599_sfp_virtfn
Date: Fri, 14 Apr 2017 21:11:26 +0200
Message-ID: <20170414191131.14286-3-hch@lst.de>
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
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20170414191131.14286-1-hch@lst.de>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 82599 quirk contained an outdated copy of the FLR code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/pci/quirks.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 823271b13d12..8195ca294ee5 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -3641,19 +3641,11 @@ static int reset_intel_82599_sfp_virtfn(struct pci_dev *dev, int probe)
 	 *
 	 * The 82599 supports FLR on VFs, but FLR support is reported only
 	 * in the PF DEVCAP (sec 9.3.10.4), not in the VF DEVCAP (sec 9.5).
-	 * Therefore, we can't use pcie_flr(), which checks the VF DEVCAP.
+	 * Thus we must call pcie_flr directly without first checking if it is
+	 * supported.
 	 */
-
-	if (probe)
-		return 0;
-
-	if (!pci_wait_for_pending_transaction(dev))
-		dev_err(&dev->dev, "transaction is not cleared; proceeding with reset anyway\n");
-
-	pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_BCR_FLR);
-
-	msleep(100);
-
+	if (!probe)
+		pcie_flr(dev);
 	return 0;
 }
 
-- 
2.11.0
