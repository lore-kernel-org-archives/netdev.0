From: Robert Hancock <hancockrwd@gmail.com>
Subject: [PATCH 2.6.34] r8169: enable 64-bit DMA by default for PCI Express
 devices
Date: Wed, 17 Feb 2010 21:06:41 -0600
Message-ID: <4B7CAEC1.6090408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f197.google.com ([209.85.211.197]:38658 "EHLO
	mail-yw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932586Ab0BRDLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 22:11:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently use of 64-bit DMA is disabled in r8169 unless the user passes the
use_dac module option. This is reasonable for conventional PCI devices where
broken chipsets may not handle dual-address-cycle transfers properly for
32-bit slots and so this may not be safe. However, PCI Express should not have
this problem and not using 64-bit DMA results in DMA transfers needlessly using
the IOMMU or SWIOTLB. Set the use_dac module parameter to a new default value of
-1 which results in 64-bit DMA being enabled by default for PCI Express devices
only.

Signed-off-by: Robert Hancock <hancockrwd@gmail.com>

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 60f96c4..8943385 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -187,7 +187,7 @@ static struct pci_device_id rtl8169_pci_tbl[] = {
 MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
 
 static int rx_copybreak = 200;
-static int use_dac;
+static int use_dac = -1;
 static struct {
 	u32 msg_enable;
 } debug = { -1 };
@@ -511,7 +511,8 @@ MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
 module_param(rx_copybreak, int, 0);
 MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
 module_param(use_dac, int, 0);
-MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
+MODULE_PARM_DESC(use_dac, "Enable PCI DAC. -1 defaults on for PCI Express only."
+" Unsafe on 32 bit PCI slot.");
 module_param_named(debug, debug.msg_enable, int, 0);
 MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 16=all)");
 MODULE_LICENSE("GPL");
@@ -2980,6 +2981,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	void __iomem *ioaddr;
 	unsigned int i;
 	int rc;
+	int this_use_dac = use_dac;
 
 	if (netif_msg_drv(&debug)) {
 		printk(KERN_INFO "%s Gigabit Ethernet driver %s loaded\n",
@@ -3051,8 +3053,18 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	tp->cp_cmd = PCIMulRW | RxChkSum;
 
+	tp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+	if (!tp->pcie_cap && netif_msg_probe(tp))
+		dev_info(&pdev->dev, "no PCI Express capability\n");
+
+	if (this_use_dac < 0)
+		this_use_dac = tp->pcie_cap != 0;
+
 	if ((sizeof(dma_addr_t) > 4) &&
-	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) && use_dac) {
+	    this_use_dac &&
+	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
+		if (netif_msg_probe(tp))
+			dev_info(&pdev->dev, "using 64-bit DMA\n");
 		tp->cp_cmd |= PCIDAC;
 		dev->features |= NETIF_F_HIGHDMA;
 	} else {
@@ -3075,10 +3087,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_free_res_4;
 	}
 
-	tp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	if (!tp->pcie_cap && netif_msg_probe(tp))
-		dev_info(&pdev->dev, "no PCI Express capability\n");
-
 	RTL_W16(IntrMask, 0x0000);
 
 	/* Soft reset the chip. */
