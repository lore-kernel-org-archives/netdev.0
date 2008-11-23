From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] 8139too: use err.h macros
Date: Sun, 23 Nov 2008 10:22:37 -0800
Message-ID: <20081123102237.42cc99dd@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47159 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750887AbYKWSXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2008 13:23:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using call by reference use the PTR_ERR macros to handle
return value with error case. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/8139too.c	2008-11-23 10:16:26.000000000 -0800
+++ b/drivers/net/8139too.c	2008-11-23 10:19:05.000000000 -0800
@@ -741,8 +741,7 @@ static void rtl8139_chip_reset (void __i
 }
 
 
-static int __devinit rtl8139_init_board (struct pci_dev *pdev,
-					 struct net_device **dev_out)
+static __devinit struct net_device * rtl8139_init_board (struct pci_dev *pdev)
 {
 	void __iomem *ioaddr;
 	struct net_device *dev;
@@ -756,13 +755,11 @@ static int __devinit rtl8139_init_board 
 
 	assert (pdev != NULL);
 
-	*dev_out = NULL;
-
 	/* dev and priv zeroed in alloc_etherdev */
 	dev = alloc_etherdev (sizeof (*tp));
 	if (dev == NULL) {
 		dev_err(&pdev->dev, "Unable to alloc new net device\n");
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 	}
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -906,14 +903,13 @@ match:
 
 	rtl8139_chip_reset (ioaddr);
 
-	*dev_out = dev;
-	return 0;
+	return dev;
 
 err_out:
 	__rtl8139_cleanup_dev (dev);
 	if (disable_dev_on_err)
 		pci_disable_device (pdev);
-	return rc;
+	return ERR_PTR(rc);
 }
 
 static const struct net_device_ops rtl8139_netdev_ops = {
@@ -972,9 +968,9 @@ static int __devinit rtl8139_init_one (s
 		use_io = 1;
 	}
 
-	i = rtl8139_init_board (pdev, &dev);
-	if (i < 0)
-		return i;
+	dev = rtl8139_init_board (pdev);
+	if (IS_ERR(dev))
+		return PTR_ERR(dev);
 
 	assert (dev != NULL);
 	tp = netdev_priv(dev);
