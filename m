From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH 02/10] r6040: fix null pointer access and tx timeouts
Date: Sun, 13 Jul 2008 14:28:27 +0200
Message-ID: <200807131428.28035.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:50108 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752851AbYGMM2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 08:28:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a null pointer access in r6040_rx due
to lp->dev not being initialized.

Fix the TX timeouts, TX irq was not re-enabled on RX irq

Signed-Off-By: Joerg Albert <jal2@gmx.de>
Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 4e67884..d277deb 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -91,6 +91,14 @@
 #define MISR		0x3C	/* Status register */
 #define MIER		0x40	/* INT enable register */
 #define  MSK_INT	0x0000	/* Mask off interrupts */
+#define  RX_FINISH	0x0001  /* RX finished */
+#define  RX_NO_DESC	0x0002  /* No RX descriptor available */
+#define  RX_FIFO_FULL	0x0004  /* RX FIFO full */
+#define  RX_EARLY	0x0008  /* RX early */
+#define  TX_FINISH	0x0010  /* TX finished */
+#define  TX_EARLY	0x0080  /* TX early */
+#define  EVENT_OVRFL	0x0100  /* Event counter overflow */
+#define  LINK_CHANGED	0x0200  /* PHY link changed */
 #define ME_CISR		0x44	/* Event counter INT status */
 #define ME_CIER		0x48	/* Event counter INT enable  */
 #define MR_CNT		0x50	/* Successfully received packet counter */
@@ -139,10 +147,10 @@ MODULE_AUTHOR("Sten Wang <sten.wang@rdc.com.tw>,"
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("RDC R6040 NAPI PCI FastEthernet driver");
 
-#define RX_INT                         0x0001
-#define TX_INT                         0x0010
-#define RX_NO_DESC_INT                 0x0002
-#define INT_MASK                 (RX_INT | TX_INT)
+/* RX and TX interrupts that we handle */
+#define RX_INT			(RX_FINISH)
+#define TX_INT			(TX_FINISH)
+#define INT_MASK		(RX_INT | TX_INT)
 
 struct r6040_descriptor {
 	u16	status, len;		/* 0-3 */
@@ -502,8 +510,6 @@ static int r6040_rx(struct net_device *dev, int limit)
 		struct r6040_descriptor *descptr = priv->rx_remove_ptr;
 		struct sk_buff *skb_ptr;
 
-		/* Disable RX interrupt */
-		iowrite16(ioread16(ioaddr + MIER) & (~RX_INT), ioaddr + MIER);
 		descptr = priv->rx_remove_ptr;
 
 		/* Check for errors */
@@ -639,8 +645,9 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 
 	/* RX interrupt request */
 	if (status & 0x01) {
+		/* Mask off RX interrupt */
+		iowrite16(ioread16(ioaddr + MIER) & ~RX_INT, ioaddr + MIER);
 		netif_rx_schedule(dev, &lp->napi);
-		iowrite16(TX_INT, ioaddr + MIER);
 	}
 
 	/* TX interrupt request */
@@ -687,7 +694,11 @@ static void r6040_up(struct net_device *dev)
 		else
 			lp->phy_mode = (PHY_MODE & 0x0100) ? 0x8000:0x0;
 	}
-	/* MAC Bus Control Register */
+	/* MAC Bus Control Register :
+	 * - wait 1 host clock SDRAM bus request
+	 * - RX FIFO : 32 bytes 
+	 * - TX FIFO : 64 bytes 
+	 * - FIFO transfer lenght : 16 bytes */
 	iowrite16(MBCR_DEFAULT, ioaddr + MBCR);
 
 	/* MAC TX/RX Enable */
@@ -1018,6 +1029,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	lp = netdev_priv(dev);
 	lp->pdev = pdev;
+	lp->dev = dev;
 
 	if (pci_request_regions(pdev, DRV_NAME)) {
 		printk(KERN_ERR DRV_NAME ": Failed to request PCI regions\n");
