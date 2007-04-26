From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 09/12] r8169: MSI support
Date: Thu, 26 Apr 2007 23:49:07 +0200
Message-ID: <20070426214907.GJ7344@electric-eye.fr.zoreil.com>
References: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Bernhard Walle <bernhard.walle@gmx.de>,
	Edward Hsu <edward_hsu@realtek.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58563 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755063AbXDZVvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 17:51:55 -0400
Content-Disposition: inline
In-Reply-To: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is currently limited to 0x8136 and 0x8168. 8169sb/8110sb ought to
handle it as well where they support MSI.

Includes unregister_netdev() fix from Bernhard Walle <bwalle@suse.de>
against BUG_ON(irq_has_action(dev->first_msi_irq)) (2007/02/24).

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Fixed-by: Bernhard Walle <bernhard.walle@gmx.de>
Cc: Edward Hsu <edward_hsu@realtek.com>
---
 drivers/net/r8169.c |  102 ++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 97 insertions(+), 5 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7a0c5e7..e6dbfc9 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -250,6 +250,9 @@ enum rtl_register_content {
 	CmdTxEnb	= 0x04,
 	RxBufEmpty	= 0x01,
 
+	/* TXPoll register p.5 */
+	FSWInt		= 1,		/* Forced software interrupt */
+
 	/* Cfg9346Bits */
 	Cfg9346_Lock	= 0x00,
 	Cfg9346_Unlock	= 0xc0,
@@ -271,6 +274,7 @@ enum rtl_register_content {
 	TxDMAShift = 8,	/* DMA burst value (0-7) is shift this many bits */
 
 	/* Config1 register p.24 */
+	MSIEnable	= (1 << 5),	/* Enable Message Signaled Interrupt */
 	PMEnable	= (1 << 0),	/* Power Management Enable */
 
 	/* Config2 register p. 25 */
@@ -414,6 +418,7 @@ struct rtl8169_private {
 	unsigned int (*link_ok)(void __iomem *);
 	struct delayed_work task;
 	unsigned wol_enabled : 1;
+	unsigned msi : 1;
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -1410,12 +1415,85 @@ static int rtl8169_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
+static irqreturn_t __devinit rtl_test_intr(int irq, void *dev_instance)
+{
+	struct rtl8169_private *tp = dev_instance;
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 status;
+
+	status = RTL_R16(IntrStatus);
+	if ((status == 0xffff) || !status)
+		return IRQ_NONE;
+
+	if (status & SWInt) {
+		tp->msi = 1;
+		smp_wmb();
+		RTL_W16(IntrStatus, SWInt);
+	}
+
+	return IRQ_HANDLED;
+}
+
+static int __devinit rtl_try_msi(struct rtl8169_private *tp)
+{
+	struct pci_dev *pdev = tp->pci_dev;
+	void __iomem *ioaddr = tp->mmio_addr;
+	unsigned int i;
+	int rc;
+
+	rc = pci_enable_msi(pdev);
+	if (rc < 0)
+		return 0;
+
+	RTL_W8(Config2, RTL_R8(Config2) | MSIEnable);
+
+	rc = request_irq(pdev->irq, rtl_test_intr, 0, pci_name(pdev), tp);
+	if (rc < 0)
+		goto err_disable_msi_0;
+
+	RTL_W16(IntrMask, SWInt);
+	RTL_W8(TxPoll, FSWInt);
+	/* Commit */
+	RTL_R8(IntrMask);
+
+	for (i = 0; i < 100; i++) {
+		smp_rmb();
+		if (tp->msi)
+			break;
+		msleep(10);
+	}
+
+	RTL_W16(IntrStatus, SWInt);
+	RTL_W16(IntrMask, 0);
+	RTL_R8(IntrMask);
+
+	free_irq(pdev->irq, tp);
+
+	smp_rmb();
+
+	if (!tp->msi && netif_msg_drv(tp))
+		goto err_status_ok_1;
+
+	tp->dev->irq = pdev->irq;
+out:
+	return rc;
+
+err_status_ok_1:
+	printk(KERN_INFO "%s: no MSI. Back to INTx.\n", pci_name(pdev));
+	rc = 0;
+err_disable_msi_0:
+	RTL_W8(Config2, RTL_R8(Config2) & ~MSIEnable);
+	pci_disable_msi(pdev);
+	goto out;
+}
+
 static const struct rtl_cfg_info {
 	void (*hw_start)(struct net_device *);
 	unsigned int region;
 	unsigned int align;
 	u16 intr_event;
 	u16 napi_event;
+	unsigned msi : 1;
 } rtl_cfg_infos [] = {
 	[RTL_CFG_0] = {
 		.hw_start	= rtl_hw_start_8169,
@@ -1423,7 +1501,8 @@ static const struct rtl_cfg_info {
 		.align		= 2,
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
-		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
+		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
+		.msi		= 0
 	},
 	[RTL_CFG_1] = {
 		.hw_start	= rtl_hw_start_8168,
@@ -1431,7 +1510,8 @@ static const struct rtl_cfg_info {
 		.align		= 8,
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  TxErr | TxOK | RxOK | RxErr,
-		.napi_event	= TxErr | TxOK | RxOK | RxOverflow
+		.napi_event	= TxErr | TxOK | RxOK | RxOverflow,
+		.msi		= 1
 	},
 	[RTL_CFG_2] = {
 		.hw_start	= rtl_hw_start_8101,
@@ -1439,7 +1519,8 @@ static const struct rtl_cfg_info {
 		.align		= 8,
 		.intr_event	= SYSErr | LinkChg | RxOverflow | PCSTimeout |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
-		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
+		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
+		.msi		= 1
 	}
 };
 
@@ -1663,6 +1744,12 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc < 0)
 		goto err_out_unmap_5;
 
+	if (cfg->msi) {
+		rc = rtl_try_msi(tp);
+		if (rc < 0)
+			goto err_out_unregister_netdev_6;
+	}
+
 	pci_set_drvdata(pdev, dev);
 
 	if (netif_msg_probe(tp)) {
@@ -1682,6 +1769,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 out:
 	return rc;
 
+err_out_unregister_netdev_6:
+	unregister_netdev(dev);
 err_out_unmap_5:
 	iounmap(ioaddr);
 err_out_free_res_4:
@@ -1703,6 +1792,9 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 	flush_scheduled_work();
 
 	unregister_netdev(dev);
+	if (tp->msi)
+		pci_disable_msi(pdev);
+	tp->msi = 0;
 	rtl8169_release_board(pdev, dev, tp->mmio_addr);
 	pci_set_drvdata(pdev, NULL);
 }
@@ -1746,8 +1838,8 @@ static int rtl8169_open(struct net_device *dev)
 
 	smp_mb();
 
-	retval = request_irq(dev->irq, rtl8169_interrupt, IRQF_SHARED,
-			     dev->name, dev);
+	retval = request_irq(dev->irq, rtl8169_interrupt,
+			     tp->msi ? 0 : IRQF_SHARED, dev->name, dev);
 	if (retval < 0)
 		goto err_release_ring_2;
 
-- 
1.4.4.2
