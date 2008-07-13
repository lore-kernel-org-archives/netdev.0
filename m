From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH 05/10] r6040: call napi_disable when puting down the interface and set lp->dev accordingly.
Date: Sun, 13 Jul 2008 14:32:45 +0200
Message-ID: <200807131432.46495.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:42262 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846AbYGMMeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 08:34:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We did not call napi_disabled when putting down the interface
which should be done. Finally initialize lp->dev when everything
is set.

Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 4f2ebb2..5eb057d 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -485,6 +485,7 @@ static int r6040_close(struct net_device *dev)
 	del_timer_sync(&lp->timer);
 
 	spin_lock_irq(&lp->lock);
+	napi_disable(&lp->napi);
 	netif_stop_queue(dev);
 	r6040_down(dev);
 	spin_unlock_irq(&lp->lock);
@@ -1080,8 +1081,6 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	}
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	lp = netdev_priv(dev);
-	lp->pdev = pdev;
-	lp->dev = dev;
 
 	if (pci_request_regions(pdev, DRV_NAME)) {
 		printk(KERN_ERR DRV_NAME ": Failed to request PCI regions\n");
@@ -1113,6 +1112,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 
 	/* Link new device into r6040_root_dev */
 	lp->pdev = pdev;
+	lp->dev = dev;
 
 	/* Init RDC private data */
 	lp->mcr0 = 0x1002;
