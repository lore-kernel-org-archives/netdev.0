From: Meelis Roos <mroos@linux.ee>
Subject: [PATCH] tmspci: fix request_irq race
Date: Wed, 4 Mar 2009 16:59:41 +0200 (EET)
Message-ID: <Pine.SOC.4.64.0903041646030.12608@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:32953 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753046AbZCDO7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2009 09:59:43 -0500
Received: from math.ut.ee (math.ut.ee [193.40.36.2])
	by smtp2.it.da.ut.ee (Postfix) with ESMTP id A419E73DA5D
	for <netdev@vger.kernel.org>; Wed,  4 Mar 2009 16:59:41 +0200 (EET)
Received: from localhost (localhost [127.0.0.1])
	by math.ut.ee (Postfix) with ESMTP id 92DDBFD79B
	for <netdev@vger.kernel.org>; Wed,  4 Mar 2009 16:59:41 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, tmspci tokenring driver crashes on device initialization 
because it requests its irq before initializing corresponding data 
structures. Fix this by moving request_irq call to a safer place.

Signed-off-by: Meelis Roos <mroos@linux.ee>

diff --git a/drivers/net/tokenring/tmspci.c b/drivers/net/tokenring/tmspci.c
index 5f60177..e2150b3 100644
--- a/drivers/net/tokenring/tmspci.c
+++ b/drivers/net/tokenring/tmspci.c
@@ -121,11 +121,6 @@ static int __devinit tms_pci_attach(struct pci_dev *pdev, const struct pci_devic
 		goto err_out_trdev;
 	}
 
-	ret = request_irq(pdev->irq, tms380tr_interrupt, IRQF_SHARED,
-			  dev->name, dev);
-	if (ret)
-		goto err_out_region;
-
 	dev->base_addr	= pci_ioaddr;
 	dev->irq 	= pci_irq_line;
 	dev->dma	= 0;
@@ -142,7 +137,7 @@ static int __devinit tms_pci_attach(struct pci_dev *pdev, const struct pci_devic
 	ret = tmsdev_init(dev, &pdev->dev);
 	if (ret) {
 		printk("%s: unable to get memory for dev->priv.\n", dev->name);
-		goto err_out_irq;
+		goto err_out_region;
 	}
 
 	tp = netdev_priv(dev);
@@ -157,6 +152,11 @@ static int __devinit tms_pci_attach(struct pci_dev *pdev, const struct pci_devic
 
 	tp->tmspriv = cardinfo;
 
+	ret = request_irq(pdev->irq, tms380tr_interrupt, IRQF_SHARED,
+			  dev->name, dev);
+	if (ret)
+		goto err_out_tmsdev;
+
 	dev->open = tms380tr_open;
 	dev->stop = tms380tr_close;
 	pci_set_drvdata(pdev, dev);
@@ -164,15 +164,15 @@ static int __devinit tms_pci_attach(struct pci_dev *pdev, const struct pci_devic
 
 	ret = register_netdev(dev);
 	if (ret)
-		goto err_out_tmsdev;
+		goto err_out_irq;
 	
 	return 0;
 
+err_out_irq:
+	free_irq(pdev->irq, dev);
 err_out_tmsdev:
 	pci_set_drvdata(pdev, NULL);
 	tmsdev_term(dev);
-err_out_irq:
-	free_irq(pdev->irq, dev);
 err_out_region:
 	release_region(pci_ioaddr, TMS_PCI_IO_EXTENT);
 err_out_trdev:

-- 
Meelis Roos (mroos@linux.ee)
