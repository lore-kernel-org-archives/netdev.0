From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH 09/10] r6040: handle RX fifo full and no descriptor interrupts
Date: Sun, 13 Jul 2008 14:35:32 +0200
Message-ID: <200807131435.33015.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:39570 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753036AbYGMMfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 08:35:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows the MAC to handle the RX FIFO full
and no descriptor available interrupts. While we are at it
replace the TX interrupt with its corresponding definition.

Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index b68781d..99dbe46 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -163,9 +163,9 @@ MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("RDC R6040 NAPI PCI FastEthernet driver");
 
 /* RX and TX interrupts that we handle */
-#define RX_INT			(RX_FINISH)
-#define TX_INT			(TX_FINISH)
-#define INT_MASK		(RX_INT | TX_INT)
+#define RX_INTS			(RX_FIFO_FULL | RX_NO_DESC | RX_FINISH)
+#define TX_INTS			(TX_FINISH)
+#define INT_MASK		(RX_INTS | TX_INTS)
 
 struct r6040_descriptor {
 	u16	status, len;		/* 0-3 */
@@ -671,7 +671,7 @@ static int r6040_poll(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		netif_rx_complete(dev, napi);
 		/* Enable RX interrupt */
-		iowrite16(ioread16(ioaddr + MIER) | RX_INT, ioaddr + MIER);
+		iowrite16(ioread16(ioaddr + MIER) | RX_INTS, ioaddr + MIER);
 	}
 	return work_done;
 }
@@ -693,14 +693,22 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 		return IRQ_NONE;
 
 	/* RX interrupt request */
-	if (status & 0x01) {
+	if (status & RX_INTS) {
+		if (status & RX_NO_DESC) {
+			/* RX descriptor unavailable */
+			dev->stats.rx_dropped++;
+			dev->stats.rx_missed_errors++;
+		}
+		if (status & RX_FIFO_FULL)
+			dev->stats.rx_fifo_errors++;
+
 		/* Mask off RX interrupt */
-		iowrite16(ioread16(ioaddr + MIER) & ~RX_INT, ioaddr + MIER);
+		iowrite16(ioread16(ioaddr + MIER) & ~RX_INTS, ioaddr + MIER);
 		netif_rx_schedule(dev, &lp->napi);
 	}
 
 	/* TX interrupt request */
-	if (status & 0x10)
+	if (status & TX_INTS)
 		r6040_tx(dev);
 
 	return IRQ_HANDLED;
