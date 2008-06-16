From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-2.6 3/7] atm: [iphase] doesn't call phy->start due to a bogus #ifndef
Date: Mon, 16 Jun 2008 13:27:23 -0400
Message-ID: <200806161727.m5GHROpt003352@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:45508 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412AbYFPR13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 13:27:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit e8f40697490f1972d716326375085b0b08df13bc
Author: Jorge Boncompte [DTI2] <jorge@dti2.net>
Date:   Sat Jun 14 17:21:20 2008 -0400

    atm: [iphase] doesn't call phy->start due to a bogus #ifndef
    
    This causes the suni driver to oops if you try to use sonetdiag to get
    the statistics. Also add the corresponding phy->stop call to fix another
    oops if you try to remove the module.
    
    Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 1925915..14e4638 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -2557,17 +2557,11 @@ static int __devinit ia_start(struct atm_dev *dev)
 		error = suni_init(dev);
 		if (error)
 			goto err_free_rx;
-		/* 
-		 * Enable interrupt on loss of signal
-		 * SUNI_RSOP_CIE - 0x10
-		 * SUNI_RSOP_CIE_LOSE - 0x04
-		 */
-		ia_phy_put(dev, ia_phy_get(dev, 0x10) | 0x04, 0x10);
-#ifndef MODULE
-		error = dev->phy->start(dev);
-		if (error)
-			goto err_free_rx;
-#endif
+		if (dev->phy->start) {
+			error = dev->phy->start(dev);
+			if (error)
+				goto err_free_rx;
+		}
 		/* Get iadev->carrier_detect status */
 		IaFrontEndIntr(iadev);
 	}
@@ -3233,9 +3227,14 @@ static void __devexit ia_remove_one(struct pci_dev *pdev)
 	struct atm_dev *dev = pci_get_drvdata(pdev);
 	IADEV *iadev = INPH_IA_DEV(dev);
 
-	ia_phy_put(dev, ia_phy_get(dev,0x10) & ~(0x4), 0x10); 
+	/* Disable phy interrupts */
+	ia_phy_put(dev, ia_phy_get(dev, SUNI_RSOP_CIE) & ~(SUNI_RSOP_CIE_LOSE),
+				   SUNI_RSOP_CIE);
 	udelay(1);
 
+	if (dev->phy && dev->phy->stop)
+		dev->phy->stop(dev);
+
 	/* De-register device */  
       	free_irq(iadev->irq, dev);
 	iadev_count--;
