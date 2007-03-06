From: akpm@linux-foundation.org
Subject: [patch 17/19] sk98lin: handle pci_enable_device() return value in skge_resume()
Date: Tue, 06 Mar 2007 02:42:01 -0800
Message-ID: <200703061042.l26Ag1Y3019784@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	dmonakhov@openvz.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34726 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934072AbXCFKm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:42:56 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitriy Monakhov <dmonakhov@openvz.org>

Signed-off-by: Monakhov Dmitriy <dmonakhov@openvz.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/sk98lin/skge.c |   20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff -puN drivers/net/sk98lin/skge.c~sk98lin-handle-pci_enable_device-return-value-in-skge_resume drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c~sk98lin-handle-pci_enable_device-return-value-in-skge_resume
+++ a/drivers/net/sk98lin/skge.c
@@ -5125,7 +5125,12 @@ static int skge_resume(struct pci_dev *p
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	pci_enable_device(pdev);
+	ret = pci_enable_device(pdev);
+	if (ret) {
+		printk(KERN_WARNING "sk98lin: unable to enable device %s "
+				"in resume\n", dev->name);
+		goto err_out;
+	}
 	pci_set_master(pdev);
 	if (pAC->GIni.GIMacsFound == 2)
 		ret = request_irq(dev->irq, SkGeIsr, IRQF_SHARED, "sk98lin", dev);
@@ -5133,10 +5138,8 @@ static int skge_resume(struct pci_dev *p
 		ret = request_irq(dev->irq, SkGeIsrOnePort, IRQF_SHARED, "sk98lin", dev);
 	if (ret) {
 		printk(KERN_WARNING "sk98lin: unable to acquire IRQ %d\n", dev->irq);
-		pAC->AllocFlag &= ~SK_ALLOC_IRQ;
-		dev->irq = 0;
-		pci_disable_device(pdev);
-		return -EBUSY;
+		ret = -EBUSY;
+		goto err_out_disable_pdev;
 	}
 
 	netif_device_attach(dev);
@@ -5153,6 +5156,13 @@ static int skge_resume(struct pci_dev *p
 	}
 
 	return 0;
+
+err_out_disable_pdev:
+	pci_disable_device(pdev);
+err_out:
+	pAC->AllocFlag &= ~SK_ALLOC_IRQ;
+	dev->irq = 0;
+	return ret;
 }
 #else
 #define skge_suspend NULL
_
