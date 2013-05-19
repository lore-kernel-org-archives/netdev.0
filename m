From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] 3c59x: remove useless VORTEX_PCI() invocations
Date: Mon, 20 May 2013 00:17:13 +0400
Message-ID: <201305200017.14069.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:65061 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754167Ab3ESURS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 16:17:18 -0400
Received: by mail-lb0-f176.google.com with SMTP id x10so5917128lbi.35
        for <netdev@vger.kernel.org>; Sun, 19 May 2013 13:17:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's suboptimal to invoke quite complex VORTEX_PCI() macro every time we want
to get a 'struct pci_dev *' when we already have it in a variable... 

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the Dave's 'net-next' repo. 

 drivers/net/ethernet/3com/3c59x.c |   17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

Index: net-next/drivers/net/ethernet/3com/3c59x.c
===================================================================
--- net-next.orig/drivers/net/ethernet/3com/3c59x.c
+++ net-next/drivers/net/ethernet/3com/3c59x.c
@@ -1473,7 +1473,7 @@ static int vortex_probe1(struct device *
 
 	if (pdev) {
 		vp->pm_state_valid = 1;
- 		pci_save_state(VORTEX_PCI(vp));
+ 		pci_save_state(pdev);
  		acpi_set_WOL(dev);
 	}
 	retval = register_netdev(dev);
@@ -3233,21 +3233,20 @@ static void vortex_remove_one(struct pci
 	vp = netdev_priv(dev);
 
 	if (vp->cb_fn_base)
-		pci_iounmap(VORTEX_PCI(vp), vp->cb_fn_base);
+		pci_iounmap(pdev, vp->cb_fn_base);
 
 	unregister_netdev(dev);
 
-	if (VORTEX_PCI(vp)) {
-		pci_set_power_state(VORTEX_PCI(vp), PCI_D0);	/* Go active */
-		if (vp->pm_state_valid)
-			pci_restore_state(VORTEX_PCI(vp));
-		pci_disable_device(VORTEX_PCI(vp));
-	}
+	pci_set_power_state(pdev, PCI_D0);	/* Go active */
+	if (vp->pm_state_valid)
+		pci_restore_state(pdev);
+	pci_disable_device(pdev);
+
 	/* Should really use issue_and_wait() here */
 	iowrite16(TotalReset | ((vp->drv_flags & EEPROM_RESET) ? 0x04 : 0x14),
 	     vp->ioaddr + EL3_CMD);
 
-	pci_iounmap(VORTEX_PCI(vp), vp->ioaddr);
+	pci_iounmap(pdev, vp->ioaddr);
 
 	pci_free_consistent(pdev,
 						sizeof(struct boom_rx_desc) * RX_RING_SIZE
