From: Brice Goglin <brice@myri.com>
Subject: [PATCH 6/6] myri10ge: replace the chipset whitelist with firmware
 autodetection
Date: Mon, 07 May 2007 23:52:22 +0200
Message-ID: <463F9F96.1040109@myri.com>
References: <463F9E9E.8000808@ens-lyon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:2000 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S966716AbXEGVwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 17:52:24 -0400
In-Reply-To: <463F9E9E.8000808@ens-lyon.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the aligned-completion whitelist, and replace it by using the 1.4.16
firmware's auto-detection features to choose which firmware to load.
The driver now loads the aligned firmware, performs a MXGEFW_CMD_UNALIGNED_TEST,
and falls back to using the unaligned firmware if:
- The firmware is too old (ie, MXGEFW_CMD_UNALIGNED_TEST is an unknown command).
- The MXGEFW_CMD_UNALIGNED_TEST returns MXGEFW_CMD_ERROR_UNALIGNED, meaning
  that it has seen an unaligned completion during the DMA test.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |  121 +++++++++++++++++++++-------------------
 1 file changed, 65 insertions(+), 56 deletions(-)

Index: linux-git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-git.orig/drivers/net/myri10ge/myri10ge.c	2007-05-07 23:21:52.000000000 +0200
+++ linux-git/drivers/net/myri10ge/myri10ge.c	2007-05-07 23:21:59.000000000 +0200
@@ -360,6 +360,8 @@
 			return 0;
 		} else if (result == MXGEFW_CMD_UNKNOWN) {
 			return -ENOSYS;
+		} else if (result == MXGEFW_CMD_ERROR_UNALIGNED) {
+			return -E2BIG;
 		} else {
 			dev_err(&mgp->pdev->dev,
 				"command %d failed, result = %d\n",
@@ -2488,8 +2490,6 @@
 	err_cap |= PCI_ERR_CAP_ECRC_GENE;
 	pci_write_config_dword(bridge, cap + PCI_ERR_CAP, err_cap);
 	dev_info(dev, "Enabled ECRC on upstream bridge %s\n", pci_name(bridge));
-	mgp->tx.boundary = 4096;
-	mgp->fw_name = myri10ge_fw_aligned;
 }
 
 /*
@@ -2511,22 +2511,70 @@
  * firmware image, and set tx.boundary to 4KB.
  */
 
-#define PCI_DEVICE_ID_INTEL_E5000_PCIE23 0x25f7
-#define PCI_DEVICE_ID_INTEL_E5000_PCIE47 0x25fa
-#define PCI_DEVICE_ID_INTEL_6300ESB_PCIEE1 0x3510
-#define PCI_DEVICE_ID_INTEL_6300ESB_PCIEE4 0x351b
-#define PCI_DEVICE_ID_INTEL_E3000_PCIE	0x2779
-#define PCI_DEVICE_ID_INTEL_E3010_PCIE	0x277a
-#define PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_FIRST 0x140
-#define PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_LAST 0x142
-
-static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
+static void myri10ge_firmware_probe(struct myri10ge_priv *mgp)
 {
-	struct pci_dev *bridge = mgp->pdev->bus->self;
+	struct pci_dev *pdev = mgp->pdev;
+	struct device *dev = &pdev->dev;
+	int cap, status;
+	u16 val;
+
+	mgp->tx.boundary = 4096;
+	/*
+	 * Verify the max read request size was set to 4KB
+	 * before trying the test with 4KB.
+	 */
+	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+	if (cap < 64) {
+		dev_err(dev, "Bad PCI_CAP_ID_EXP location %d\n", cap);
+		goto abort;
+	}
+	status = pci_read_config_word(pdev, cap + PCI_EXP_DEVCTL, &val);
+	if (status != 0) {
+		dev_err(dev, "Couldn't read max read req size: %d\n", status);
+		goto abort;
+	}
+	if ((val & (5 << 12)) != (5 << 12)) {
+		dev_warn(dev, "Max Read Request size != 4096 (0x%x)\n", val);
+		mgp->tx.boundary = 2048;
+	}
+	/*
+	 * load the optimized firmware (which assumes aligned PCIe
+	 * completions) in order to see if it works on this host.
+	 */
+	mgp->fw_name = myri10ge_fw_aligned;
+	status = myri10ge_load_firmware(mgp);
+	if (status != 0) {
+		goto abort;
+	}
+
+	/*
+	 * Enable ECRC if possible
+	 */
+	myri10ge_enable_ecrc(mgp);
 
+	/*
+	 * Run a DMA test which watches for unaligned completions and
+	 * aborts on the first one seen.
+	 */
+
+	status = myri10ge_dma_test(mgp, MXGEFW_CMD_UNALIGNED_TEST);
+	if (status == 0)
+		return;		/* keep the aligned firmware */
+
+	if (status != -E2BIG)
+		dev_warn(dev, "DMA test failed: %d\n", status);
+	if (status == -ENOSYS)
+		dev_warn(dev, "Falling back to ethp! "
+			 "Please install up to date fw\n");
+abort:
+	/* fall back to using the unaligned firmware */
 	mgp->tx.boundary = 2048;
 	mgp->fw_name = myri10ge_fw_unaligned;
 
+}
+
+static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
+{
 	if (myri10ge_force_firmware == 0) {
 		int link_width, exp_cap;
 		u16 lnk;
@@ -2535,8 +2583,6 @@
 		pci_read_config_word(mgp->pdev, exp_cap + PCI_EXP_LNKSTA, &lnk);
 		link_width = (lnk >> 4) & 0x3f;
 
-		myri10ge_enable_ecrc(mgp);
-
 		/* Check to see if Link is less than 8 or if the
 		 * upstream bridge is known to provide aligned
 		 * completions */
@@ -2545,46 +2591,8 @@
 				 link_width);
 			mgp->tx.boundary = 4096;
 			mgp->fw_name = myri10ge_fw_aligned;
-		} else if (bridge &&
-			   /* ServerWorks HT2000/HT1000 */
-			   ((bridge->vendor == PCI_VENDOR_ID_SERVERWORKS
-			     && bridge->device ==
-			     PCI_DEVICE_ID_SERVERWORKS_HT2000_PCIE)
-			    /* ServerWorks HT2100 */
-			    || (bridge->vendor == PCI_VENDOR_ID_SERVERWORKS
-				&& bridge->device >=
-				PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_FIRST
-				&& bridge->device <=
-				PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_LAST)
-			    /* All Intel E3000/E3010 PCIE ports */
-			    || (bridge->vendor == PCI_VENDOR_ID_INTEL
-				&& (bridge->device ==
-				    PCI_DEVICE_ID_INTEL_E3000_PCIE
-				    || bridge->device ==
-				    PCI_DEVICE_ID_INTEL_E3010_PCIE))
-			    /* All Intel 6310/6311/6321ESB PCIE ports */
-			    || (bridge->vendor == PCI_VENDOR_ID_INTEL
-				&& bridge->device >=
-				PCI_DEVICE_ID_INTEL_6300ESB_PCIEE1
-				&& bridge->device <=
-				PCI_DEVICE_ID_INTEL_6300ESB_PCIEE4)
-			    /* All Intel E5000 PCIE ports */
-			    || (bridge->vendor == PCI_VENDOR_ID_INTEL
-				&& bridge->device >=
-				PCI_DEVICE_ID_INTEL_E5000_PCIE23
-				&& bridge->device <=
-				PCI_DEVICE_ID_INTEL_E5000_PCIE47))) {
-			dev_info(&mgp->pdev->dev,
-				 "Assuming aligned completions (0x%x:0x%x)\n",
-				 bridge->vendor, bridge->device);
-			mgp->tx.boundary = 4096;
-			mgp->fw_name = myri10ge_fw_aligned;
-		} else if (bridge &&
-			   bridge->vendor == PCI_VENDOR_ID_SGI &&
-			   bridge->device == 0x4002 /* TIOCE pcie-port */ ) {
-			/* this pcie bridge does not support 4K rdma request */
-			mgp->tx.boundary = 2048;
-			mgp->fw_name = myri10ge_fw_aligned;
+		} else {
+			myri10ge_firmware_probe(mgp);
 		}
 	} else {
 		if (myri10ge_force_firmware == 1) {
@@ -2858,7 +2866,6 @@
 		status = -ENODEV;
 		goto abort_with_netdev;
 	}
-	myri10ge_select_firmware(mgp);
 
 	/* Find the vendor-specific cap so we can check
 	 * the reboot register later on */
@@ -2952,6 +2959,8 @@
 		goto abort_with_ioremap;
 	memset(mgp->rx_done.entry, 0, bytes);
 
+	myri10ge_select_firmware(mgp);
+
 	status = myri10ge_load_firmware(mgp);
 	if (status != 0) {
 		dev_err(&pdev->dev, "failed to load firmware\n");


