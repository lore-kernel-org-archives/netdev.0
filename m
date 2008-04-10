From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 4/6] tc35815: Use managed pci iomap helper
Date: Fri, 11 Apr 2008 00:24:45 +0900 (JST)
Message-ID: <20080411.002445.122254468.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:50068 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758048AbYDJPXz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 11:23:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use managed pci functions and kill unnecessary volatiles.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |  121 +++++++++++++++---------------------------------
 1 files changed, 38 insertions(+), 83 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 5f4a14f..60eff78 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -94,37 +94,37 @@ static struct tc35815_options {
  * Registers
  */
 struct tc35815_regs {
-	volatile __u32 DMA_Ctl;		/* 0x00 */
-	volatile __u32 TxFrmPtr;
-	volatile __u32 TxThrsh;
-	volatile __u32 TxPollCtr;
-	volatile __u32 BLFrmPtr;
-	volatile __u32 RxFragSize;
-	volatile __u32 Int_En;
-	volatile __u32 FDA_Bas;
-	volatile __u32 FDA_Lim;		/* 0x20 */
-	volatile __u32 Int_Src;
-	volatile __u32 unused0[2];
-	volatile __u32 PauseCnt;
-	volatile __u32 RemPauCnt;
-	volatile __u32 TxCtlFrmStat;
-	volatile __u32 unused1;
-	volatile __u32 MAC_Ctl;		/* 0x40 */
-	volatile __u32 CAM_Ctl;
-	volatile __u32 Tx_Ctl;
-	volatile __u32 Tx_Stat;
-	volatile __u32 Rx_Ctl;
-	volatile __u32 Rx_Stat;
-	volatile __u32 MD_Data;
-	volatile __u32 MD_CA;
-	volatile __u32 CAM_Adr;		/* 0x60 */
-	volatile __u32 CAM_Data;
-	volatile __u32 CAM_Ena;
-	volatile __u32 PROM_Ctl;
-	volatile __u32 PROM_Data;
-	volatile __u32 Algn_Cnt;
-	volatile __u32 CRC_Cnt;
-	volatile __u32 Miss_Cnt;
+	__u32 DMA_Ctl;		/* 0x00 */
+	__u32 TxFrmPtr;
+	__u32 TxThrsh;
+	__u32 TxPollCtr;
+	__u32 BLFrmPtr;
+	__u32 RxFragSize;
+	__u32 Int_En;
+	__u32 FDA_Bas;
+	__u32 FDA_Lim;		/* 0x20 */
+	__u32 Int_Src;
+	__u32 unused0[2];
+	__u32 PauseCnt;
+	__u32 RemPauCnt;
+	__u32 TxCtlFrmStat;
+	__u32 unused1;
+	__u32 MAC_Ctl;		/* 0x40 */
+	__u32 CAM_Ctl;
+	__u32 Tx_Ctl;
+	__u32 Tx_Stat;
+	__u32 Rx_Ctl;
+	__u32 Rx_Stat;
+	__u32 MD_Data;
+	__u32 MD_CA;
+	__u32 CAM_Adr;		/* 0x60 */
+	__u32 CAM_Data;
+	__u32 CAM_Ena;
+	__u32 PROM_Ctl;
+	__u32 PROM_Data;
+	__u32 Algn_Cnt;
+	__u32 CRC_Cnt;
+	__u32 Miss_Cnt;
 };
 
 /*
@@ -396,8 +396,8 @@ struct FrFD {
 };
 
 
-#define tc_readl(addr)	readl(addr)
-#define tc_writel(d, addr)	writel(d, addr)
+#define tc_readl(addr)	ioread32(addr)
+#define tc_writel(d, addr)	iowrite32(d, addr)
 
 #define TC35815_TX_TIMEOUT  msecs_to_jiffies(400)
 
@@ -663,7 +663,6 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 	struct net_device *dev;
 	struct tc35815_local *lp;
 	int rc;
-	unsigned long mmio_start, mmio_end, mmio_flags, mmio_len;
 	DECLARE_MAC_BUF(mac);
 
 	static int printed_version;
@@ -690,45 +689,14 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 	lp->dev = dev;
 
 	/* enable device (incl. PCI PM wakeup), and bus-mastering */
-	rc = pci_enable_device (pdev);
+	rc = pcim_enable_device(pdev);
 	if (rc)
 		goto err_out;
-
-	mmio_start = pci_resource_start (pdev, 1);
-	mmio_end = pci_resource_end (pdev, 1);
-	mmio_flags = pci_resource_flags (pdev, 1);
-	mmio_len = pci_resource_len (pdev, 1);
-
-	/* set this immediately, we need to know before
-	 * we talk to the chip directly */
-
-	/* make sure PCI base addr 1 is MMIO */
-	if (!(mmio_flags & IORESOURCE_MEM)) {
-		dev_err(&pdev->dev, "region #1 not an MMIO resource, aborting\n");
-		rc = -ENODEV;
-		goto err_out;
-	}
-
-	/* check for weird/broken PCI region reporting */
-	if ((mmio_len < sizeof(struct tc35815_regs))) {
-		dev_err(&pdev->dev, "Invalid PCI region size(s), aborting\n");
-		rc = -ENODEV;
-		goto err_out;
-	}
-
-	rc = pci_request_regions (pdev, MODNAME);
+	rc = pcim_iomap_regions(pdev, 1 << 1, MODNAME);
 	if (rc)
 		goto err_out;
-
-	pci_set_master (pdev);
-
-	/* ioremap MMIO region */
-	ioaddr = ioremap (mmio_start, mmio_len);
-	if (ioaddr == NULL) {
-		dev_err(&pdev->dev, "cannot remap MMIO, aborting\n");
-		rc = -EIO;
-		goto err_out_free_res;
-	}
+	pci_set_master(pdev);
+	ioaddr = pcim_iomap_table(pdev)[1];
 
 	/* Initialize the device structure. */
 	dev->open = tc35815_open;
@@ -768,7 +736,7 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 
 	rc = register_netdev (dev);
 	if (rc)
-		goto err_out_unmap;
+		goto err_out;
 
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 	printk(KERN_INFO "%s: %s at 0x%lx, %s, IRQ %d\n",
@@ -791,10 +759,6 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 
 	return 0;
 
-err_out_unmap:
-	iounmap(ioaddr);
-err_out_free_res:
-	pci_release_regions (pdev);
 err_out:
 	free_netdev (dev);
 	return rc;
@@ -804,17 +768,8 @@ err_out:
 static void __devexit tc35815_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	unsigned long mmio_addr;
-
-	mmio_addr = dev->base_addr;
 
 	unregister_netdev (dev);
-
-	if (mmio_addr) {
-		iounmap ((void __iomem *)mmio_addr);
-		pci_release_regions (pdev);
-	}
-
 	free_netdev (dev);
 
 	pci_set_drvdata (pdev, NULL);
