From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 04/13] r8169: MSI support
Date: Thu, 18 Oct 2007 23:01:06 +0200
Message-ID: <20071018210106.GE31724@electric-eye.fr.zoreil.com>
References: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	Rolf Eike Beer <eike-kernel@sf-tec.de>,
	Will Trives <will@trivescon.com.au>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36978 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754846AbXJRVK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 17:10:58 -0400
Content-Disposition: inline
In-Reply-To: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is currently limited to the tested 0x8136 and 0x8168. 8169sb/8110sb ought
to handle it as well where they support MSI.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
Tester-Cc: Rolf Eike Beer <eike-kernel@sf-tec.de>
---
 drivers/net/r8169.c |   50 ++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 44 insertions(+), 6 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 16ecba1..ee1c274 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -278,6 +278,7 @@ enum rtl_register_content {
 	TxDMAShift = 8,	/* DMA burst value (0-7) is shift this many bits */
 
 	/* Config1 register p.24 */
+	MSIEnable	= (1 << 5),	/* Enable Message Signaled Interrupt */
 	PMEnable	= (1 << 0),	/* Power Management Enable */
 
 	/* Config2 register p. 25 */
@@ -383,6 +384,7 @@ struct ring_info {
 
 enum features {
 	RTL_FEATURE_WOL	= (1 << 0),
+	RTL_FEATURE_MSI	= (1 << 1),
 };
 
 struct rtl8169_private {
@@ -1465,6 +1467,7 @@ static const struct rtl_cfg_info {
 	unsigned int align;
 	u16 intr_event;
 	u16 napi_event;
+	unsigned msi;
 } rtl_cfg_infos [] = {
 	[RTL_CFG_0] = {
 		.hw_start	= rtl_hw_start_8169,
@@ -1472,7 +1475,8 @@ static const struct rtl_cfg_info {
 		.align		= 0,
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
-		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
+		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
+		.msi		= 0
 	},
 	[RTL_CFG_1] = {
 		.hw_start	= rtl_hw_start_8168,
@@ -1480,7 +1484,8 @@ static const struct rtl_cfg_info {
 		.align		= 8,
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  TxErr | TxOK | RxOK | RxErr,
-		.napi_event	= TxErr | TxOK | RxOK | RxOverflow
+		.napi_event	= TxErr | TxOK | RxOK | RxOverflow,
+		.msi		= RTL_FEATURE_MSI
 	},
 	[RTL_CFG_2] = {
 		.hw_start	= rtl_hw_start_8101,
@@ -1488,10 +1493,39 @@ static const struct rtl_cfg_info {
 		.align		= 8,
 		.intr_event	= SYSErr | LinkChg | RxOverflow | PCSTimeout |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
-		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
+		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
+		.msi		= RTL_FEATURE_MSI
 	}
 };
 
+/* Cfg9346_Unlock assumed. */
+static unsigned rtl_try_msi(struct pci_dev *pdev, void __iomem *ioaddr,
+			    const struct rtl_cfg_info *cfg)
+{
+	unsigned msi = 0;
+	u8 cfg2;
+
+	cfg2 = RTL_R8(Config2) & ~MSIEnable;
+	if (cfg->msi) {
+		if (pci_enable_msi(pdev)) {
+			dev_info(&pdev->dev, "no MSI. Back to INTx.\n");
+		} else {
+			cfg2 |= MSIEnable;
+			msi = RTL_FEATURE_MSI;
+		}
+	}
+	RTL_W8(Config2, cfg2);
+	return msi;
+}
+
+static void rtl_disable_msi(struct pci_dev *pdev, struct rtl8169_private *tp)
+{
+	if (tp->features & RTL_FEATURE_MSI) {
+		pci_disable_msi(pdev);
+		tp->features &= ~RTL_FEATURE_MSI;
+	}
+}
+
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1627,6 +1661,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
 	RTL_W8(Config5, RTL_R8(Config5) & PMEStatus);
+	tp->features |= rtl_try_msi(pdev, ioaddr, cfg);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	if (RTL_R8(PHYstatus) & TBI_Enable) {
@@ -1694,7 +1729,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rc = register_netdev(dev);
 	if (rc < 0)
-		goto err_out_unmap_5;
+		goto err_out_msi_5;
 
 	pci_set_drvdata(pdev, dev);
 
@@ -1717,7 +1752,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 out:
 	return rc;
 
-err_out_unmap_5:
+err_out_msi_5:
+	rtl_disable_msi(pdev, tp);
 	iounmap(ioaddr);
 err_out_free_res_4:
 	pci_release_regions(pdev);
@@ -1738,6 +1774,7 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 	flush_scheduled_work();
 
 	unregister_netdev(dev);
+	rtl_disable_msi(pdev, tp);
 	rtl8169_release_board(pdev, dev, tp->mmio_addr);
 	pci_set_drvdata(pdev, NULL);
 }
@@ -1781,7 +1818,8 @@ static int rtl8169_open(struct net_device *dev)
 
 	smp_mb();
 
-	retval = request_irq(dev->irq, rtl8169_interrupt, IRQF_SHARED,
+	retval = request_irq(dev->irq, rtl8169_interrupt,
+			     (tp->features & RTL_FEATURE_MSI) ? 0 : IRQF_SHARED,
 			     dev->name, dev);
 	if (retval < 0)
 		goto err_release_ring_2;
-- 
1.5.2.4

