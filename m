From: akpm@linux-foundation.org
Subject: [patch 15/19] 3c59x: Handle pci_enable_device() failure while resuming
Date: Tue, 06 Mar 2007 02:41:59 -0800
Message-ID: <200703061041.l26Afx8Q019778@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, dmonakhov@sw.ru,
	dmonakhov@openvz.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34775 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964771AbXCFKnc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:43:32 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitriy Monakhov <dmonakhov@sw.ru>

Handle pci_enable_device() failure while resuming, we can safely exit here.

Signed-off-by: Monakhov Dmitriy <dmonakhov@openvz.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/3c59x.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff -puN drivers/net/3c59x.c~3c59x-handle-pci_enable_device-failure-while-resuming drivers/net/3c59x.c
--- a/drivers/net/3c59x.c~3c59x-handle-pci_enable_device-failure-while-resuming
+++ a/drivers/net/3c59x.c
@@ -822,11 +822,17 @@ static int vortex_resume(struct pci_dev 
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct vortex_private *vp = netdev_priv(dev);
+	int err;
 
 	if (dev && vp) {
 		pci_set_power_state(pdev, PCI_D0);
 		pci_restore_state(pdev);
-		pci_enable_device(pdev);
+		err = pci_enable_device(pdev);
+		if (err) {
+			printk(KERN_WARNING "%s: Could not enable device \n",
+				dev->name);
+			return err;
+		}
 		pci_set_master(pdev);
 		if (request_irq(dev->irq, vp->full_bus_master_rx ?
 				&boomerang_interrupt : &vortex_interrupt, IRQF_SHARED, dev->name, dev)) {
_
