From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/3] r6040: save and restore MIER correctly in the interrupt routine
Date: Fri, 19 Dec 2008 11:02:16 +0100
Message-ID: <200812191102.16497.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, Joe Chou <Joe.Chou@rdc.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:61777 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752914AbYLSKCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 05:02:20 -0500
Received: by bwz14 with SMTP id 14so3316797bwz.13
        for <netdev@vger.kernel.org>; Fri, 19 Dec 2008 02:02:18 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/3] r6040: save and restore MIER correctly in the interrupt routine

This patch saves the MIER register contents before treating
interrupts, then restores them correcty at the end of the
interrupt routine.

Signed-off-by: Joe Chou <Joe.Chou@rdc.com.tw>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index c2e8ac1..1117ffa 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -681,8 +681,10 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 	struct net_device *dev = dev_id;
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
-	u16 status;
+	u16 misr, status;
 
+	/* Save MIER */
+	misr = ioread16(ioaddr + MIER);
 	/* Mask off RDC MAC interrupt */
 	iowrite16(MSK_INT, ioaddr + MIER);
 	/* Read MISR status and clear */
@@ -702,7 +704,7 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 			dev->stats.rx_fifo_errors++;
 
 		/* Mask off RX interrupt */
-		iowrite16(ioread16(ioaddr + MIER) & ~RX_INTS, ioaddr + MIER);
+		misr &= ~RX_INTS;
 		netif_rx_schedule(dev, &lp->napi);
 	}
 
@@ -710,6 +712,9 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 	if (status & TX_INTS)
 		r6040_tx(dev);
 
+	/* Restore RDC MAC interrupt */
+	iowrite16(misr, ioaddr + MIER);	
+
 	return IRQ_HANDLED;
 }
