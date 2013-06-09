From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] 3c59x: consolidate error cleanup in vortex_init_one()
Date: Mon, 10 Jun 2013 00:16:52 +0400
Message-ID: <201306100016.52820.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: klassert@mathematik.tu-chemnitz.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:43492 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919Ab3FIUQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jun 2013 16:16:56 -0400
Received: by mail-lb0-f170.google.com with SMTP id t13so738985lbd.1
        for <netdev@vger.kernel.org>; Sun, 09 Jun 2013 13:16:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCI driver's probe() method  duplicates the error cleanup code each time it
has to do error exit. Consolidate the error cleanup code  in  one place and use
*goto* to jump to the right places.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against Dave Miller's 'net-next.git' repo. 
Andrew Morton asked me to do this years ago.  It's high time to finally do this.
Too bad it doesn't save much...

 drivers/net/ethernet/3com/3c59x.c |   25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

Index: net-next/drivers/net/ethernet/3com/3c59x.c
===================================================================
--- net-next.orig/drivers/net/ethernet/3com/3c59x.c
+++ net-next/drivers/net/ethernet/3com/3c59x.c
@@ -1012,10 +1012,8 @@ static int vortex_init_one(struct pci_de
 		goto out;
 
 	rc = pci_request_regions(pdev, DRV_NAME);
-	if (rc < 0) {
-		pci_disable_device(pdev);
-		goto out;
-	}
+	if (rc < 0)
+		goto out_disable;
 
 	unit = vortex_cards_found;
 
@@ -1032,23 +1030,24 @@ static int vortex_init_one(struct pci_de
 	if (!ioaddr) /* If mapping fails, fall-back to BAR 0... */
 		ioaddr = pci_iomap(pdev, 0, 0);
 	if (!ioaddr) {
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
 		rc = -ENOMEM;
-		goto out;
+		goto out_release;
 	}
 
 	rc = vortex_probe1(&pdev->dev, ioaddr, pdev->irq,
 			   ent->driver_data, unit);
-	if (rc < 0) {
-		pci_iounmap(pdev, ioaddr);
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
-		goto out;
-	}
+	if (rc < 0)
+		goto out_iounmap;
 
 	vortex_cards_found++;
+	goto out;
 
+out_iounmap:
+	pci_iounmap(pdev, ioaddr);
+out_release:
+	pci_release_regions(pdev);
+out_disable:
+	pci_disable_device(pdev);
 out:
 	return rc;
 }
