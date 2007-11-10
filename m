From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 1/13] tg3: Fix 5761 PXEboot crash
Date: Fri, 09 Nov 2007 16:38:37 -0800
Message-ID: <1194655117.5745.263.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3312 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752540AbXKJAjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 19:39:10 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When 5761 devices boot the machine using PXEboot, PXE leaves the device
active when it terminates.  The tg3 driver has code to detect this
condition and resets the device during initialization.  On 5761 devices,
device resets involve sending a driver state update message to the APE
on the 5761.  However, during this initialization stage, communications
to the APE registers have not yet been set up.  The driver then
dereferences a NULL pointer and crashes the machine.  The fix is to move
the APE register access setup earlier in the initialization code to
cover this condition.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index cad5199..ddeaa0c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12464,6 +12464,28 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		goto err_out_iounmap;
 	}
 
+	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
+		if (!(pci_resource_flags(pdev, 2) & IORESOURCE_MEM)) {
+			printk(KERN_ERR PFX "Cannot find proper PCI device "
+			       "base address for APE, aborting.\n");
+			err = -ENODEV;
+			goto err_out_iounmap;
+		}
+
+		tg3reg_base = pci_resource_start(pdev, 2);
+		tg3reg_len = pci_resource_len(pdev, 2);
+
+		tp->aperegs = ioremap_nocache(tg3reg_base, tg3reg_len);
+		if (tp->aperegs == 0UL) {
+			printk(KERN_ERR PFX "Cannot map APE registers, "
+			       "aborting.\n");
+			err = -ENOMEM;
+			goto err_out_iounmap;
+		}
+
+		tg3_ape_lock_init(tp);
+	}
+
 	/*
 	 * Reset chip in case UNDI or EFI driver did not shutdown
 	 * DMA self test will enable WDMAC and we'll see (spurious)
@@ -12478,7 +12500,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	err = tg3_test_dma(tp);
 	if (err) {
 		printk(KERN_ERR PFX "DMA engine test failed, aborting.\n");
-		goto err_out_iounmap;
+		goto err_out_apeunmap;
 	}
 
 	/* Tigon3 can do ipv4 only... and some chips have buggy
@@ -12501,28 +12523,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	tg3_init_coal(tp);
 
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
-		if (!(pci_resource_flags(pdev, 2) & IORESOURCE_MEM)) {
-			printk(KERN_ERR PFX "Cannot find proper PCI device "
-			       "base address for APE, aborting.\n");
-			err = -ENODEV;
-			goto err_out_iounmap;
-		}
-
-		tg3reg_base = pci_resource_start(pdev, 2);
-		tg3reg_len = pci_resource_len(pdev, 2);
-
-		tp->aperegs = ioremap_nocache(tg3reg_base, tg3reg_len);
-		if (tp->aperegs == 0UL) {
-			printk(KERN_ERR PFX "Cannot map APE registers, "
-			       "aborting.\n");
-			err = -ENOMEM;
-			goto err_out_iounmap;
-		}
-
-		tg3_ape_lock_init(tp);
-	}
-
 	pci_set_drvdata(pdev, dev);
 
 	err = register_netdev(dev);


