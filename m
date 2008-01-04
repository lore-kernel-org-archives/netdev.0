From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-2.6.24][ATM]: [nicstar] delay irq setup until card is configured
Date: Fri, 04 Jan 2008 16:29:15 -0500
Message-ID: <200801042129.m04LTFxZ030640@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:65315 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029AbYADV3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 16:29:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if an interrupt occurs too soon, the driver oops while trying to handle
a shortage of buffers condition (caused by no buffers having been
allocated yet).

commit a3322d3d34854edf27f7950efaa93e68f5f71ace
Author: Chas Williams - CONTRACTOR <chas@relax.cmf.nrl.navy.mil>
Date:   Fri Jan 4 16:27:07 2008 -0500

    [ATM]: [nicstar] delay irq setup until card is configured
    
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 14ced85..0c205b0 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -625,14 +625,6 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
    if (mac[i] == NULL)
       nicstar_init_eprom(card->membase);
 
-   if (request_irq(pcidev->irq, &ns_irq_handler, IRQF_DISABLED | IRQF_SHARED, "nicstar", card) != 0)
-   {
-      printk("nicstar%d: can't allocate IRQ %d.\n", i, pcidev->irq);
-      error = 9;
-      ns_init_card_error(card, error);
-      return error;
-   }
-
    /* Set the VPI/VCI MSb mask to zero so we can receive OAM cells */
    writel(0x00000000, card->membase + VPM);
       
@@ -858,8 +850,6 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
       card->iovpool.count++;
    }
 
-   card->intcnt = 0;
-
    /* Configure NICStAR */
    if (card->rct_size == 4096)
       ns_cfg_rctsize = NS_CFG_RCTSIZE_4096_ENTRIES;
@@ -868,6 +858,15 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
 
    card->efbie = 1;
 
+   card->intcnt = 0;
+   if (request_irq(pcidev->irq, &ns_irq_handler, IRQF_DISABLED | IRQF_SHARED, "nicstar", card) != 0)
+   {
+      printk("nicstar%d: can't allocate IRQ %d.\n", i, pcidev->irq);
+      error = 9;
+      ns_init_card_error(card, error);
+      return error;
+   }
+
    /* Register device */
    card->atmdev = atm_dev_register("nicstar", &atm_ops, -1, NULL);
    if (card->atmdev == NULL)
