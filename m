From: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
Subject: [PATCH] e100: Use pci pool to work around GFP_ATOMIC order 5 memory allocation failure
Date: Thu, 26 Nov 2009 16:49:54 +0200
Message-ID: <200911261649.54785.roger.oksanen@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Karol Lewandowski <karol.k.lewandowski@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Joh
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47848 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754557AbZKZOtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 09:49:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e100: Use pci pool to work around GFP_ATOMIC order 5 memory allocation failure.

pci_alloc_consistent uses GFP_ATOMIC allocation that may fail on some systems
with limited memory (Bug #14265). pci_pool_alloc allows waiting with
GFP_KERNEL.

Tested-by: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Signed-off-by: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
---
 drivers/net/e100.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 3c29a20..d269a68 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -157,6 +157,7 @@
 #include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
+#include <linux/dmapool.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/mii.h>
@@ -602,6 +603,7 @@ struct nic {
 	struct mem *mem;
 	dma_addr_t dma_addr;
 
+	struct pci_pool *cbs_pool;
 	dma_addr_t cbs_dma_addr;
 	u8 adaptive_ifs;
 	u8 tx_threshold;
@@ -1793,9 +1795,7 @@ static void e100_clean_cbs(struct nic *nic)
 			nic->cb_to_clean = nic->cb_to_clean->next;
 			nic->cbs_avail++;
 		}
-		pci_free_consistent(nic->pdev,
-			sizeof(struct cb) * nic->params.cbs.count,
-			nic->cbs, nic->cbs_dma_addr);
+		pci_pool_free(nic->cbs_pool, nic->cbs, nic->cbs_dma_addr);
 		nic->cbs = NULL;
 		nic->cbs_avail = 0;
 	}
@@ -1813,8 +1813,8 @@ static int e100_alloc_cbs(struct nic *nic)
 	nic->cb_to_use = nic->cb_to_send = nic->cb_to_clean = NULL;
 	nic->cbs_avail = 0;
 
-	nic->cbs = pci_alloc_consistent(nic->pdev,
-		sizeof(struct cb) * count, &nic->cbs_dma_addr);
+	nic->cbs = pci_pool_alloc(nic->cbs_pool, GFP_KERNEL,
+				  &nic->cbs_dma_addr);
 	if (!nic->cbs)
 		return -ENOMEM;
 
@@ -2841,7 +2841,11 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 		DPRINTK(PROBE, ERR, "Cannot register net device, aborting.\n");
 		goto err_out_free;
 	}
-
+	nic->cbs_pool = pci_pool_create(netdev->name,
+			   nic->pdev,
+			   nic->params.cbs.count * sizeof(struct cb),
+			   sizeof(u32),
+			   0);
 	DPRINTK(PROBE, INFO, "addr 0x%llx, irq %d, MAC addr %pM\n",
 		(unsigned long long)pci_resource_start(pdev, use_io ? 1 : 0),
 		pdev->irq, netdev->dev_addr);
@@ -2871,6 +2875,7 @@ static void __devexit e100_remove(struct pci_dev *pdev)
 		unregister_netdev(netdev);
 		e100_free(nic);
 		pci_iounmap(pdev, nic->csr);
+		pci_pool_destroy(nic->cbs_pool);
 		free_netdev(netdev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
