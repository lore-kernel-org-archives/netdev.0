From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/4] r6040: fix ifconfig down and freeing of tx/rx descriptors
Date: Fri, 9 Jan 2009 02:04:39 +0100
Message-ID: <200901090204.39930.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org, Joe Chou <Joe.Chou@rdc.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:31276 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757917AbZAIBEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 20:04:46 -0500
Received: by fg-out-1718.google.com with SMTP id 19so3353070fgg.17
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 17:04:44 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/4] r6040: fix ifconfig down and freeing of tx/rx descriptors

This patch fixes warnings and such traces that appear when doing
an ifconfig down on the interface:

WARNING: at arch/x86/kernel/pci-dma.c:376 dma_free_coherent+0x40/0x7d()
Modules linked in:

Signed-off-by: Joe Chou <joe.chou@rdc.com.tw>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 706a0af..6b8bc6d 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -457,17 +457,6 @@ static void r6040_down(struct net_device *dev)
 	iowrite16(adrp[0], ioaddr + MID_0L);
 	iowrite16(adrp[1], ioaddr + MID_0M);
 	iowrite16(adrp[2], ioaddr + MID_0H);
-	free_irq(dev->irq, dev);
-
-	/* Free RX buffer */
-	r6040_free_rxbufs(dev);
-
-	/* Free TX buffer */
-	r6040_free_txbufs(dev);
-
-	/* Free Descriptor memory */
-	pci_free_consistent(pdev, RX_DESC_SIZE, lp->rx_ring, lp->rx_ring_dma);
-	pci_free_consistent(pdev, TX_DESC_SIZE, lp->tx_ring, lp->tx_ring_dma);
 }
 
 static int r6040_close(struct net_device *dev)
@@ -481,8 +470,28 @@ static int r6040_close(struct net_device *dev)
 	napi_disable(&lp->napi);
 	netif_stop_queue(dev);
 	r6040_down(dev);
+	
+	free_irq(dev->irq, dev);
+
+	/* Free RX buffer */
+	r6040_free_rxbufs(dev);
+
+	/* Free TX buffer */
+	r6040_free_txbufs(dev);
+	
 	spin_unlock_irq(&lp->lock);
 
+	/* Free Descriptor memory */
+	if (lp->rx_ring) {
+		pci_free_consistent(pdev, RX_DESC_SIZE, lp->rx_ring, lp->rx_ring_dma);
+		lp->rx_ring = 0;
+	}
+
+	if (lp->tx_ring) {
+		pci_free_consistent(pdev, TX_DESC_SIZE, lp->tx_ring, lp->tx_ring_dma);
+		lp->tx_ring = 0;
+	}
+
 	return 0;
 }
 
