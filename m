From: Brice Goglin <brice@myri.com>
Subject: [PATCH] myri10ge update
Date: Thu, 8 Jun 2006 10:25:00 -0400
Message-ID: <20060608142458.GA14261@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:16538 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S964838AbWFHOZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 10:25:06 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patch updates the myri10ge to 1.0.0, with the following changes:
* Switch to dma_alloc_coherent API.
* Avoid PCI burst when writing the firmware on chipset with unaligned completions.
* Use ethtool_op_set_tx_hw_csum instead of ethtool_op_set_tx_csum.
* Include linux/dma-mapping.h to bring DMA_32/64BIT_MASK on all architectures
  (was missing at least on alpha).
* Some typo and warning fixes.

Please apply.

Note that Andrew's myri10ge-alpha-build-fix.patch would conflict,
but it does not seem to have been merged in netdev-2.6 anyway.

Thanks.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew J. Gallatin <gallatin@myri.com>

 drivers/net/myri10ge/myri10ge.c |   57 +++++++++++++++++++-----------
 1 file changed, 37 insertions(+), 20 deletions(-)

diff -urNp linux-mm.old/drivers/net/myri10ge/myri10ge.c linux-mm/drivers/net/myri10ge/myri10ge.c
--- linux-mm.old/drivers/net/myri10ge/myri10ge.c	2006-06-04 08:51:00.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-06-07 11:28:20.000000000 -0400
@@ -44,6 +44,7 @@
 #include <linux/string.h>
 #include <linux/module.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/etherdevice.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
@@ -62,7 +63,6 @@
 #include <net/checksum.h>
 #include <asm/byteorder.h>
 #include <asm/io.h>
-#include <asm/pci.h>
 #include <asm/processor.h>
 #ifdef CONFIG_MTRR
 #include <asm/mtrr.h>
@@ -71,7 +71,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "0.9.0"
+#define MYRI10GE_VERSION_STR "1.0.0"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -480,7 +478,19 @@ static int myri10ge_load_hotplug_firmwar
 		goto abort_with_fw;
 
 	crc = crc32(~0, fw->data, fw->size);
-	memcpy_toio(mgp->sram + MYRI10GE_FW_OFFSET, fw->data, fw->size);
+	if (mgp->tx.boundary == 2048) {
+		/* Avoid PCI burst on chipset with unaligned completions. */
+		int i;
+		__iomem u32 *ptr = (__iomem u32 *) (mgp->sram +
+						    MYRI10GE_FW_OFFSET);
+		for (i = 0; i < fw->size / 4; i++) {
+			__raw_writel(((u32 *) fw->data)[i], ptr + i);
+			wmb();
+		}
+	} else {
+		myri10ge_pio_copy(mgp->sram + MYRI10GE_FW_OFFSET, fw->data,
+				  fw->size);
+	}
 	/* corruption checking is good for parity recovery and buggy chipset */
 	memcpy_fromio(fw->data, mgp->sram + MYRI10GE_FW_OFFSET, fw->size);
 	reread_crc = crc32(~0, fw->data, fw->size);
@@ -536,6 +548,7 @@ static int myri10ge_load_firmware(struct
 	u32 dma_low, dma_high, size;
 	int status, i;
 
+	size = 0;
 	status = myri10ge_load_hotplug_firmware(mgp, &size);
 	if (status) {
 		dev_warn(&mgp->pdev->dev, "hotplug firmware loading failed\n");
@@ -778,7 +791,7 @@ myri10ge_submit_8rx(struct mcp_kreq_ethe
 }
 
 /*
- * Set of routunes to get a new receive buffer.  Any buffer which
+ * Set of routines to get a new receive buffer.  Any buffer which
  * crosses a 4KB boundary must start on a 4KB boundary due to PCIe
  * wdma restrictions. We also try to align any smaller allocation to
  * at least a 16 byte boundary for efficiency.  We assume the linux
@@ -1349,7 +1362,7 @@ static struct ethtool_ops myri10ge_ethto
 	.get_rx_csum = myri10ge_get_rx_csum,
 	.set_rx_csum = myri10ge_set_rx_csum,
 	.get_tx_csum = ethtool_op_get_tx_csum,
-	.set_tx_csum = ethtool_op_set_tx_csum,
+	.set_tx_csum = ethtool_op_set_tx_hw_csum,
 	.get_sg = ethtool_op_get_sg,
 	.set_sg = ethtool_op_set_sg,
 #ifdef NETIF_F_TSO
@@ -2615,12 +2628,13 @@ static int myri10ge_probe(struct pci_dev
 		dev_err(&pdev->dev, "Error %d setting DMA mask\n", status);
 		goto abort_with_netdev;
 	}
-	mgp->cmd = pci_alloc_consistent(pdev, sizeof(*mgp->cmd), &mgp->cmd_bus);
+	mgp->cmd = dma_alloc_coherent(&pdev->dev, sizeof(*mgp->cmd),
+				      &mgp->cmd_bus, GFP_KERNEL);
 	if (mgp->cmd == NULL)
 		goto abort_with_netdev;
 
-	mgp->fw_stats = pci_alloc_consistent(pdev, sizeof(*mgp->fw_stats),
-					     &mgp->fw_stats_bus);
+	mgp->fw_stats = dma_alloc_coherent(&pdev->dev, sizeof(*mgp->fw_stats),
+					   &mgp->fw_stats_bus, GFP_KERNEL);
 	if (mgp->fw_stats == NULL)
 		goto abort_with_cmd;
 
@@ -2659,8 +2673,8 @@ static int myri10ge_probe(struct pci_dev
 
 	/* allocate rx done ring */
 	bytes = myri10ge_max_intr_slots * sizeof(*mgp->rx_done.entry);
-	mgp->rx_done.entry =
-	    pci_alloc_consistent(pdev, bytes, &mgp->rx_done.bus);
+	mgp->rx_done.entry = dma_alloc_coherent(&pdev->dev, bytes,
+						&mgp->rx_done.bus, GFP_KERNEL);
 	if (mgp->rx_done.entry == NULL)
 		goto abort_with_ioremap;
 	memset(mgp->rx_done.entry, 0, bytes);
@@ -2750,7 +2762,8 @@ abort_with_firmware:
 
 abort_with_rx_done:
 	bytes = myri10ge_max_intr_slots * sizeof(*mgp->rx_done.entry);
-	pci_free_consistent(pdev, bytes, mgp->rx_done.entry, mgp->rx_done.bus);
+	dma_free_coherent(&pdev->dev, bytes,
+			  mgp->rx_done.entry, mgp->rx_done.bus);
 
 abort_with_ioremap:
 	iounmap(mgp->sram);
@@ -2760,11 +2775,12 @@ abort_with_wc:
 	if (mgp->mtrr >= 0)
 		mtrr_del(mgp->mtrr, mgp->iomem_base, mgp->board_span);
 #endif
-	pci_free_consistent(pdev, sizeof(*mgp->fw_stats),
-			    mgp->fw_stats, mgp->fw_stats_bus);
+	dma_free_coherent(&pdev->dev, sizeof(*mgp->fw_stats),
+			  mgp->fw_stats, mgp->fw_stats_bus);
 
 abort_with_cmd:
-	pci_free_consistent(pdev, sizeof(*mgp->cmd), mgp->cmd, mgp->cmd_bus);
+	dma_free_coherent(&pdev->dev, sizeof(*mgp->cmd),
+			  mgp->cmd, mgp->cmd_bus);
 
 abort_with_netdev:
 
@@ -2799,7 +2815,8 @@ static void myri10ge_remove(struct pci_d
 	myri10ge_dummy_rdma(mgp, 0);
 
 	bytes = myri10ge_max_intr_slots * sizeof(*mgp->rx_done.entry);
-	pci_free_consistent(pdev, bytes, mgp->rx_done.entry, mgp->rx_done.bus);
+	dma_free_coherent(&pdev->dev, bytes,
+			  mgp->rx_done.entry, mgp->rx_done.bus);
 
 	iounmap(mgp->sram);
 
@@ -2807,19 +2824,20 @@ static void myri10ge_remove(struct pci_d
 	if (mgp->mtrr >= 0)
 		mtrr_del(mgp->mtrr, mgp->iomem_base, mgp->board_span);
 #endif
-	pci_free_consistent(pdev, sizeof(*mgp->fw_stats),
-			    mgp->fw_stats, mgp->fw_stats_bus);
+	dma_free_coherent(&pdev->dev, sizeof(*mgp->fw_stats),
+			  mgp->fw_stats, mgp->fw_stats_bus);
 
-	pci_free_consistent(pdev, sizeof(*mgp->cmd), mgp->cmd, mgp->cmd_bus);
+	dma_free_coherent(&pdev->dev, sizeof(*mgp->cmd),
+			  mgp->cmd, mgp->cmd_bus);
 
 	free_netdev(netdev);
 	pci_set_drvdata(pdev, NULL);
 }
 
-#define PCI_DEVICE_ID_MYIRCOM_MYRI10GE_Z8E 	0x0008
+#define PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E 	0x0008
 
 static struct pci_device_id myri10ge_pci_tbl[] = {
-	{PCI_DEVICE(PCI_VENDOR_ID_MYRICOM, PCI_DEVICE_ID_MYIRCOM_MYRI10GE_Z8E)},
+	{PCI_DEVICE(PCI_VENDOR_ID_MYRICOM, PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E)},
 	{0},
 };
 
