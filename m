From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH] be2net: use PCIe AER capability
Date: Wed, 5 Sep 2012 17:26:48 +0530
Message-ID: <2fad6337-6291-43f5-af76-e8ba8a9a5296@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:14254 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864Ab2IEMQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 08:16:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows code to handle the PCIe AER capability.
The PCI callbacks for error handling/reset/recovery already exist in be2net
and have been tested with EEH/ppc.
This patch has been tested using the aer-inject tool.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6d139d6..cc2947d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -20,6 +20,7 @@
 #include "be.h"
 #include "be_cmds.h"
 #include <asm/div64.h>
+#include <linux/aer.h>
 
 MODULE_VERSION(DRV_VER);
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
@@ -3551,6 +3552,8 @@ static void __devexit be_remove(struct pci_dev *pdev)
 
 	be_ctrl_cleanup(adapter);
 
+	pci_disable_pcie_error_reporting(pdev);
+
 	pci_set_drvdata(pdev, NULL);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
@@ -3844,6 +3847,10 @@ static int __devinit be_probe(struct pci_dev *pdev,
 		}
 	}
 
+	status = pci_enable_pcie_error_reporting(pdev);
+	if (status)
+		dev_err(&pdev->dev, "Could not use PCIe error reporting\n");
+
 	status = be_ctrl_init(adapter);
 	if (status)
 		goto free_netdev;
@@ -4066,6 +4073,7 @@ static pci_ers_result_t be_eeh_reset(struct pci_dev *pdev)
 	if (status)
 		return PCI_ERS_RESULT_DISCONNECT;
 
+	pci_cleanup_aer_uncorrect_error_status(pdev);
 	return PCI_ERS_RESULT_RECOVERED;
 }
 
-- 
1.7.4
