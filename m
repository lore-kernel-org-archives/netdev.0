From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/2] r8169: issue request_irq after the private data are completely initialized
Date: Mon, 2 Apr 2007 22:59:59 +0200
Message-ID: <20070402205959.GA23368@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Cliburn <jacliburn@bellsouth.net>, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:49397 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965839AbXDBVAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 17:00:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The irq handler schedules a NAPI poll request unconditionally as soon as
the status register is not clean. It has been there - and wrong - for
ages but a recent timing change made it apparently easier to trigger.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/r8169.c |   33 ++++++++++++++++++---------------
 1 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 521b5f0..60f630e 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -66,6 +66,7 @@ VERSION 2.2LK	<2005/01/25>
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
 
+#include <asm/system.h>
 #include <asm/io.h>
 #include <asm/irq.h>
 
@@ -486,6 +487,7 @@ static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
 				void __iomem *);
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
 static void rtl8169_down(struct net_device *dev);
+static void rtl8169_rx_clear(struct rtl8169_private *tp);
 
 #ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct net_device *dev, int *budget);
@@ -1751,16 +1753,10 @@ static int rtl8169_open(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct pci_dev *pdev = tp->pci_dev;
-	int retval;
+	int retval = -ENOMEM;
 
-	rtl8169_set_rxbufsize(tp, dev);
-
-	retval =
-	    request_irq(dev->irq, rtl8169_interrupt, IRQF_SHARED, dev->name, dev);
-	if (retval < 0)
-		goto out;
 
-	retval = -ENOMEM;
+	rtl8169_set_rxbufsize(tp, dev);
 
 	/*
 	 * Rx and Tx desscriptors needs 256 bytes alignment.
@@ -1769,19 +1765,26 @@ static int rtl8169_open(struct net_device *dev)
 	tp->TxDescArray = pci_alloc_consistent(pdev, R8169_TX_RING_BYTES,
 					       &tp->TxPhyAddr);
 	if (!tp->TxDescArray)
-		goto err_free_irq;
+		goto out;
 
 	tp->RxDescArray = pci_alloc_consistent(pdev, R8169_RX_RING_BYTES,
 					       &tp->RxPhyAddr);
 	if (!tp->RxDescArray)
-		goto err_free_tx;
+		goto err_free_tx_0;
 
 	retval = rtl8169_init_ring(dev);
 	if (retval < 0)
-		goto err_free_rx;
+		goto err_free_rx_1;
 
 	INIT_DELAYED_WORK(&tp->task, NULL);
 
+	smp_mb();
+
+	retval = request_irq(dev->irq, rtl8169_interrupt, IRQF_SHARED,
+			     dev->name, dev);
+	if (retval < 0)
+		goto err_release_ring_2;
+
 	rtl8169_hw_start(dev);
 
 	rtl8169_request_timer(dev);
@@ -1790,14 +1793,14 @@ static int rtl8169_open(struct net_device *dev)
 out:
 	return retval;
 
-err_free_rx:
+err_release_ring_2:
+	rtl8169_rx_clear(tp);
+err_free_rx_1:
 	pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDescArray,
 			    tp->RxPhyAddr);
-err_free_tx:
+err_free_tx_0:
 	pci_free_consistent(pdev, R8169_TX_RING_BYTES, tp->TxDescArray,
 			    tp->TxPhyAddr);
-err_free_irq:
-	free_irq(dev->irq, dev);
 	goto out;
 }
 
-- 
1.5.0.5

