From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH][ATM] iphase: doesn't call phy->start due to a bogus #ifndef
Date: Thu, 05 Jun 2008 18:17:00 +0200
Message-ID: <4848117C.5040801@dti2.net>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chas williams <chas@cmf.nrl.navy.mil>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:2151 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbYFEQRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 12:17:22 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v9.6.5)
	with ESMTP id md50013608999.msg
	for <netdev@vger.kernel.org>; Thu, 05 Jun 2008 18:17:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	This causes the suni driver to oops if you try to use sonetdiag to
get the statistics. Also add the corresponding phy->stop call to fix another
oops if you try to remove the module.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
  drivers/atm/iphase.c |   25 +++++++++++++------------
  1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 1b7090a..521d8af 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -2556,17 +2556,13 @@ static int __devinit ia_start(struct atm_dev *dev)
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
+
+		if (dev->phy->start) {
+			error = dev->phy->start(dev);
+			if (error)
+				goto err_free_rx;
+		}
+
  		/* Get iadev->carrier_detect status */
  		IaFrontEndIntr(iadev);
  	}
@@ -3226,9 +3222,14 @@ static void __devexit ia_remove_one(struct pci_dev *pdev)
  	struct atm_dev *dev = pci_get_drvdata(pdev);
  	IADEV *iadev = INPH_IA_DEV(dev);

-	ia_phy_put(dev, ia_phy_get(dev,0x10) & ~(0x4), 0x10);
+	/* Disable phy interrupts */
+	ia_phy_put(dev, ia_phy_get(dev,
+			SUNI_RSOP_CIE) & ~(SUNI_RSOP_CIE_LOSE), SUNI_RSOP_CIE);
  	udelay(1);

+	if (dev->phy && dev->phy->stop)
+		dev->phy->stop(dev);
+
  	/* De-register device */
        	free_irq(iadev->irq, dev);
  	iadev_count--;
-- 

