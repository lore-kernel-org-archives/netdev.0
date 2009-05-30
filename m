From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [net-next-2.6 PATCH 2/3] can: sja1000: stop misusing member base_addr of struct net_device
Date: Sat, 30 May 2009 19:55:49 +0200
Message-ID: <20090530175548.148509355@denx.de>
References: <20090530175547.772116783@denx.de>
Cc: socketcan-core@lists.berlios.de,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:56731 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932535AbZE3Rzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 13:55:48 -0400
Content-Disposition: inline; filename=sja1000-priv-base-addr.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As discussed on the netdev mailing list, the member "base_addr" of
"struct net_device" should not be (mis)used to store the virtual
address to the SJA1000 register area. According to David Miller,
it's only use is to allow ISA and similar primitive bus devices to
have their I/O ports changed via ifconfig. The virtual address is
now stored in the private data structure of the SJA1000 device and
the callback functions use "struct sja1000_priv" instead of the
unneeded "struct net_device".

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/sja1000/ems_pci.c          |   36 +++------
 drivers/net/can/sja1000/kvaser_pci.c       |   21 ++---
 drivers/net/can/sja1000/sja1000.c          |  110 ++++++++++++++---------------
 drivers/net/can/sja1000/sja1000.h          |    9 +-
 drivers/net/can/sja1000/sja1000_platform.c |   19 ++---
 5 files changed, 96 insertions(+), 99 deletions(-)

Index: net-next-2.6/drivers/net/can/sja1000/ems_pci.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/ems_pci.c	2009-05-30 19:48:38.045719203 +0200
+++ net-next-2.6/drivers/net/can/sja1000/ems_pci.c	2009-05-30 19:48:39.352720495 +0200
@@ -99,25 +99,21 @@
  */
 static u8 ems_pci_readb(struct ems_pci_card *card, unsigned int port)
 {
-	return readb((void __iomem *)card->base_addr
-			+ (port * EMS_PCI_PORT_BYTES));
+	return readb(card->base_addr + (port * EMS_PCI_PORT_BYTES));
 }
 
-static u8 ems_pci_read_reg(const struct net_device *dev, int port)
+static u8 ems_pci_read_reg(const struct sja1000_priv *priv, int port)
 {
-	return readb((void __iomem *)dev->base_addr
-			+ (port * EMS_PCI_PORT_BYTES));
+	return readb(priv->reg_base + (port * EMS_PCI_PORT_BYTES));
 }
 
-static void ems_pci_write_reg(const struct net_device *dev, int port, u8 val)
+static void ems_pci_write_reg(const struct sja1000_priv *priv, int port, u8 val)
 {
-	writeb(val, (void __iomem *)dev->base_addr
-		+ (port * EMS_PCI_PORT_BYTES));
+	writeb(val, priv->reg_base + (port * EMS_PCI_PORT_BYTES));
 }
 
-static void ems_pci_post_irq(const struct net_device *dev)
+static void ems_pci_post_irq(const struct sja1000_priv *priv)
 {
-	struct sja1000_priv *priv = netdev_priv(dev);
 	struct ems_pci_card *card = (struct ems_pci_card *)priv->priv;
 
 	/* reset int flag of pita */
@@ -129,17 +125,17 @@
  * Check if a CAN controller is present at the specified location
  * by trying to set 'em into the PeliCAN mode
  */
-static inline int ems_pci_check_chan(struct net_device *dev)
+static inline int ems_pci_check_chan(const struct sja1000_priv *priv)
 {
 	unsigned char res;
 
 	/* Make sure SJA1000 is in reset mode */
-	ems_pci_write_reg(dev, REG_MOD, 1);
+	ems_pci_write_reg(priv, REG_MOD, 1);
 
-	ems_pci_write_reg(dev, REG_CDR, CDR_PELICAN);
+	ems_pci_write_reg(priv, REG_CDR, CDR_PELICAN);
 
 	/* read reset-values */
-	res = ems_pci_read_reg(dev, REG_CDR);
+	res = ems_pci_read_reg(priv, REG_CDR);
 
 	if (res == CDR_PELICAN)
 		return 1;
@@ -257,12 +253,11 @@
 		priv->irq_flags = IRQF_SHARED;
 
 		dev->irq = pdev->irq;
-		dev->base_addr = (unsigned long)(card->base_addr
-						+ EMS_PCI_CAN_BASE_OFFSET
-						+ (i * EMS_PCI_CAN_CTRL_SIZE));
+		priv->reg_base = card->base_addr + EMS_PCI_CAN_BASE_OFFSET
+					+ (i * EMS_PCI_CAN_CTRL_SIZE);
 
 		/* Check if channel is present */
-		if (ems_pci_check_chan(dev)) {
+		if (ems_pci_check_chan(priv)) {
 			priv->read_reg  = ems_pci_read_reg;
 			priv->write_reg = ems_pci_write_reg;
 			priv->post_irq  = ems_pci_post_irq;
@@ -286,9 +281,8 @@
 
 			card->channels++;
 
-			dev_info(&pdev->dev, "Channel #%d at %#lX, irq %d\n",
-						i + 1, dev->base_addr,
-						dev->irq);
+			dev_info(&pdev->dev, "Channel #%d at 0x%p, irq %d\n",
+					i + 1, priv->reg_base, dev->irq);
 		} else {
 			free_sja1000dev(dev);
 		}
Index: net-next-2.6/drivers/net/can/sja1000/kvaser_pci.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/kvaser_pci.c	2009-05-30 19:48:32.763721448 +0200
+++ net-next-2.6/drivers/net/can/sja1000/kvaser_pci.c	2009-05-30 19:48:39.353720637 +0200
@@ -117,14 +117,15 @@
 
 MODULE_DEVICE_TABLE(pci, kvaser_pci_tbl);
 
-static u8 kvaser_pci_read_reg(const struct net_device *dev, int port)
+static u8 kvaser_pci_read_reg(const struct sja1000_priv *priv, int port)
 {
-	return ioread8((void __iomem *)(dev->base_addr + port));
+	return ioread8(priv->reg_base + port);
 }
 
-static void kvaser_pci_write_reg(const struct net_device *dev, int port, u8 val)
+static void kvaser_pci_write_reg(const struct sja1000_priv *priv,
+				 int port, u8 val)
 {
-	iowrite8(val, (void __iomem *)(dev->base_addr + port));
+	iowrite8(val, priv->reg_base + port);
 }
 
 static void kvaser_pci_disable_irq(struct net_device *dev)
@@ -199,7 +200,7 @@
 	}
 	unregister_sja1000dev(dev);
 
-	pci_iounmap(board->pci_dev, (void __iomem *)dev->base_addr);
+	pci_iounmap(board->pci_dev, priv->reg_base);
 	pci_iounmap(board->pci_dev, board->conf_addr);
 	pci_iounmap(board->pci_dev, board->res_addr);
 
@@ -210,7 +211,7 @@
 			       struct net_device **master_dev,
 			       void __iomem *conf_addr,
 			       void __iomem *res_addr,
-			       unsigned long base_addr)
+			       void __iomem *base_addr)
 {
 	struct net_device *dev;
 	struct sja1000_priv *priv;
@@ -252,7 +253,7 @@
 		board->xilinx_ver = master_board->xilinx_ver;
 	}
 
-	dev->base_addr = base_addr + channel * KVASER_PCI_PORT_BYTES;
+	priv->reg_base = base_addr + channel * KVASER_PCI_PORT_BYTES;
 
 	priv->read_reg = kvaser_pci_read_reg;
 	priv->write_reg = kvaser_pci_write_reg;
@@ -267,8 +268,8 @@
 
 	init_step = 4;
 
-	dev_info(&pdev->dev, "base_addr=%#lx conf_addr=%p irq=%d\n",
-		 dev->base_addr, board->conf_addr, dev->irq);
+	dev_info(&pdev->dev, "reg_base=%p conf_addr=%p irq=%d\n",
+		 priv->reg_base, board->conf_addr, dev->irq);
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -343,7 +344,7 @@
 	for (i = 0; i < no_channels; i++) {
 		err = kvaser_pci_add_chan(pdev, i, &master_dev,
 					  conf_addr, res_addr,
-					  (unsigned long)base_addr);
+					  base_addr);
 		if (err)
 			goto failure_cleanup;
 	}
Index: net-next-2.6/drivers/net/can/sja1000/sja1000.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/sja1000.c	2009-05-30 19:48:38.057718952 +0200
+++ net-next-2.6/drivers/net/can/sja1000/sja1000.c	2009-05-30 19:48:39.357720646 +0200
@@ -89,7 +89,7 @@
 {
 	struct sja1000_priv *priv = netdev_priv(dev);
 
-	if (dev->base_addr && (priv->read_reg(dev, 0) == 0xFF)) {
+	if (priv->reg_base && (priv->read_reg(priv, 0) == 0xFF)) {
 		printk(KERN_INFO "%s: probing @0x%lX failed\n",
 		       DRV_NAME, dev->base_addr);
 		return 0;
@@ -100,11 +100,11 @@
 static void set_reset_mode(struct net_device *dev)
 {
 	struct sja1000_priv *priv = netdev_priv(dev);
-	unsigned char status = priv->read_reg(dev, REG_MOD);
+	unsigned char status = priv->read_reg(priv, REG_MOD);
 	int i;
 
 	/* disable interrupts */
-	priv->write_reg(dev, REG_IER, IRQ_OFF);
+	priv->write_reg(priv, REG_IER, IRQ_OFF);
 
 	for (i = 0; i < 100; i++) {
 		/* check reset bit */
@@ -113,9 +113,9 @@
 			return;
 		}
 
-		priv->write_reg(dev, REG_MOD, MOD_RM);	/* reset chip */
+		priv->write_reg(priv, REG_MOD, MOD_RM);	/* reset chip */
 		udelay(10);
-		status = priv->read_reg(dev, REG_MOD);
+		status = priv->read_reg(priv, REG_MOD);
 	}
 
 	dev_err(dev->dev.parent, "setting SJA1000 into reset mode failed!\n");
@@ -124,7 +124,7 @@
 static void set_normal_mode(struct net_device *dev)
 {
 	struct sja1000_priv *priv = netdev_priv(dev);
-	unsigned char status = priv->read_reg(dev, REG_MOD);
+	unsigned char status = priv->read_reg(priv, REG_MOD);
 	int i;
 
 	for (i = 0; i < 100; i++) {
@@ -132,14 +132,14 @@
 		if ((status & MOD_RM) == 0) {
 			priv->can.state = CAN_STATE_ERROR_ACTIVE;
 			/* enable all interrupts */
-			priv->write_reg(dev, REG_IER, IRQ_ALL);
+			priv->write_reg(priv, REG_IER, IRQ_ALL);
 			return;
 		}
 
 		/* set chip to normal mode */
-		priv->write_reg(dev, REG_MOD, 0x00);
+		priv->write_reg(priv, REG_MOD, 0x00);
 		udelay(10);
-		status = priv->read_reg(dev, REG_MOD);
+		status = priv->read_reg(priv, REG_MOD);
 	}
 
 	dev_err(dev->dev.parent, "setting SJA1000 into normal mode failed!\n");
@@ -154,9 +154,9 @@
 		set_reset_mode(dev);
 
 	/* Clear error counters and error code capture */
-	priv->write_reg(dev, REG_TXERR, 0x0);
-	priv->write_reg(dev, REG_RXERR, 0x0);
-	priv->read_reg(dev, REG_ECC);
+	priv->write_reg(priv, REG_TXERR, 0x0);
+	priv->write_reg(priv, REG_RXERR, 0x0);
+	priv->read_reg(priv, REG_ECC);
 
 	/* leave reset mode */
 	set_normal_mode(dev);
@@ -198,8 +198,8 @@
 	dev_info(dev->dev.parent,
 		 "setting BTR0=0x%02x BTR1=0x%02x\n", btr0, btr1);
 
-	priv->write_reg(dev, REG_BTR0, btr0);
-	priv->write_reg(dev, REG_BTR1, btr1);
+	priv->write_reg(priv, REG_BTR0, btr0);
+	priv->write_reg(priv, REG_BTR1, btr1);
 
 	return 0;
 }
@@ -217,20 +217,20 @@
 	struct sja1000_priv *priv = netdev_priv(dev);
 
 	/* set clock divider and output control register */
-	priv->write_reg(dev, REG_CDR, priv->cdr | CDR_PELICAN);
+	priv->write_reg(priv, REG_CDR, priv->cdr | CDR_PELICAN);
 
 	/* set acceptance filter (accept all) */
-	priv->write_reg(dev, REG_ACCC0, 0x00);
-	priv->write_reg(dev, REG_ACCC1, 0x00);
-	priv->write_reg(dev, REG_ACCC2, 0x00);
-	priv->write_reg(dev, REG_ACCC3, 0x00);
-
-	priv->write_reg(dev, REG_ACCM0, 0xFF);
-	priv->write_reg(dev, REG_ACCM1, 0xFF);
-	priv->write_reg(dev, REG_ACCM2, 0xFF);
-	priv->write_reg(dev, REG_ACCM3, 0xFF);
+	priv->write_reg(priv, REG_ACCC0, 0x00);
+	priv->write_reg(priv, REG_ACCC1, 0x00);
+	priv->write_reg(priv, REG_ACCC2, 0x00);
+	priv->write_reg(priv, REG_ACCC3, 0x00);
+
+	priv->write_reg(priv, REG_ACCM0, 0xFF);
+	priv->write_reg(priv, REG_ACCM1, 0xFF);
+	priv->write_reg(priv, REG_ACCM2, 0xFF);
+	priv->write_reg(priv, REG_ACCM3, 0xFF);
 
-	priv->write_reg(dev, REG_OCR, priv->ocr | OCR_MODE_NORMAL);
+	priv->write_reg(priv, REG_OCR, priv->ocr | OCR_MODE_NORMAL);
 }
 
 /*
@@ -261,27 +261,27 @@
 	if (id & CAN_EFF_FLAG) {
 		fi |= FI_FF;
 		dreg = EFF_BUF;
-		priv->write_reg(dev, REG_FI, fi);
-		priv->write_reg(dev, REG_ID1, (id & 0x1fe00000) >> (5 + 16));
-		priv->write_reg(dev, REG_ID2, (id & 0x001fe000) >> (5 + 8));
-		priv->write_reg(dev, REG_ID3, (id & 0x00001fe0) >> 5);
-		priv->write_reg(dev, REG_ID4, (id & 0x0000001f) << 3);
+		priv->write_reg(priv, REG_FI, fi);
+		priv->write_reg(priv, REG_ID1, (id & 0x1fe00000) >> (5 + 16));
+		priv->write_reg(priv, REG_ID2, (id & 0x001fe000) >> (5 + 8));
+		priv->write_reg(priv, REG_ID3, (id & 0x00001fe0) >> 5);
+		priv->write_reg(priv, REG_ID4, (id & 0x0000001f) << 3);
 	} else {
 		dreg = SFF_BUF;
-		priv->write_reg(dev, REG_FI, fi);
-		priv->write_reg(dev, REG_ID1, (id & 0x000007f8) >> 3);
-		priv->write_reg(dev, REG_ID2, (id & 0x00000007) << 5);
+		priv->write_reg(priv, REG_FI, fi);
+		priv->write_reg(priv, REG_ID1, (id & 0x000007f8) >> 3);
+		priv->write_reg(priv, REG_ID2, (id & 0x00000007) << 5);
 	}
 
 	for (i = 0; i < dlc; i++)
-		priv->write_reg(dev, dreg++, cf->data[i]);
+		priv->write_reg(priv, dreg++, cf->data[i]);
 
 	stats->tx_bytes += dlc;
 	dev->trans_start = jiffies;
 
 	can_put_echo_skb(skb, dev, 0);
 
-	priv->write_reg(dev, REG_CMR, CMD_TR);
+	priv->write_reg(priv, REG_CMR, CMD_TR);
 
 	return 0;
 }
@@ -304,22 +304,22 @@
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_CAN);
 
-	fi = priv->read_reg(dev, REG_FI);
+	fi = priv->read_reg(priv, REG_FI);
 	dlc = fi & 0x0F;
 
 	if (fi & FI_FF) {
 		/* extended frame format (EFF) */
 		dreg = EFF_BUF;
-		id = (priv->read_reg(dev, REG_ID1) << (5 + 16))
-		    | (priv->read_reg(dev, REG_ID2) << (5 + 8))
-		    | (priv->read_reg(dev, REG_ID3) << 5)
-		    | (priv->read_reg(dev, REG_ID4) >> 3);
+		id = (priv->read_reg(priv, REG_ID1) << (5 + 16))
+		    | (priv->read_reg(priv, REG_ID2) << (5 + 8))
+		    | (priv->read_reg(priv, REG_ID3) << 5)
+		    | (priv->read_reg(priv, REG_ID4) >> 3);
 		id |= CAN_EFF_FLAG;
 	} else {
 		/* standard frame format (SFF) */
 		dreg = SFF_BUF;
-		id = (priv->read_reg(dev, REG_ID1) << 3)
-		    | (priv->read_reg(dev, REG_ID2) >> 5);
+		id = (priv->read_reg(priv, REG_ID1) << 3)
+		    | (priv->read_reg(priv, REG_ID2) >> 5);
 	}
 
 	if (fi & FI_RTR)
@@ -330,13 +330,13 @@
 	cf->can_id = id;
 	cf->can_dlc = dlc;
 	for (i = 0; i < dlc; i++)
-		cf->data[i] = priv->read_reg(dev, dreg++);
+		cf->data[i] = priv->read_reg(priv, dreg++);
 
 	while (i < 8)
 		cf->data[i++] = 0;
 
 	/* release receive buffer */
-	priv->write_reg(dev, REG_CMR, CMD_RRB);
+	priv->write_reg(priv, REG_CMR, CMD_RRB);
 
 	netif_rx(skb);
 
@@ -371,7 +371,7 @@
 		cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
 		stats->rx_over_errors++;
 		stats->rx_errors++;
-		priv->write_reg(dev, REG_CMR, CMD_CDO);	/* clear bit */
+		priv->write_reg(priv, REG_CMR, CMD_CDO);	/* clear bit */
 	}
 
 	if (isrc & IRQ_EI) {
@@ -392,7 +392,7 @@
 		priv->can.can_stats.bus_error++;
 		stats->rx_errors++;
 
-		ecc = priv->read_reg(dev, REG_ECC);
+		ecc = priv->read_reg(priv, REG_ECC);
 
 		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
 
@@ -426,7 +426,7 @@
 	if (isrc & IRQ_ALI) {
 		/* arbitration lost interrupt */
 		dev_dbg(dev->dev.parent, "arbitration lost interrupt\n");
-		alc = priv->read_reg(dev, REG_ALC);
+		alc = priv->read_reg(priv, REG_ALC);
 		priv->can.can_stats.arbitration_lost++;
 		stats->rx_errors++;
 		cf->can_id |= CAN_ERR_LOSTARB;
@@ -435,8 +435,8 @@
 
 	if (state != priv->can.state && (state == CAN_STATE_ERROR_WARNING ||
 					 state == CAN_STATE_ERROR_PASSIVE)) {
-		uint8_t rxerr = priv->read_reg(dev, REG_RXERR);
-		uint8_t txerr = priv->read_reg(dev, REG_TXERR);
+		uint8_t rxerr = priv->read_reg(priv, REG_RXERR);
+		uint8_t txerr = priv->read_reg(priv, REG_TXERR);
 		cf->can_id |= CAN_ERR_CRTL;
 		if (state == CAN_STATE_ERROR_WARNING) {
 			priv->can.can_stats.error_warning++;
@@ -471,15 +471,15 @@
 	int n = 0;
 
 	/* Shared interrupts and IRQ off? */
-	if (priv->read_reg(dev, REG_IER) == IRQ_OFF)
+	if (priv->read_reg(priv, REG_IER) == IRQ_OFF)
 		return IRQ_NONE;
 
 	if (priv->pre_irq)
-		priv->pre_irq(dev);
+		priv->pre_irq(priv);
 
-	while ((isrc = priv->read_reg(dev, REG_IR)) && (n < SJA1000_MAX_IRQ)) {
+	while ((isrc = priv->read_reg(priv, REG_IR)) && (n < SJA1000_MAX_IRQ)) {
 		n++;
-		status = priv->read_reg(dev, REG_SR);
+		status = priv->read_reg(priv, REG_SR);
 
 		if (isrc & IRQ_WUI)
 			dev_warn(dev->dev.parent, "wakeup interrupt\n");
@@ -494,7 +494,7 @@
 			/* receive interrupt */
 			while (status & SR_RBS) {
 				sja1000_rx(dev);
-				status = priv->read_reg(dev, REG_SR);
+				status = priv->read_reg(priv, REG_SR);
 			}
 		}
 		if (isrc & (IRQ_DOI | IRQ_EI | IRQ_BEI | IRQ_EPI | IRQ_ALI)) {
@@ -505,7 +505,7 @@
 	}
 
 	if (priv->post_irq)
-		priv->post_irq(dev);
+		priv->post_irq(priv);
 
 	if (n >= SJA1000_MAX_IRQ)
 		dev_dbg(dev->dev.parent, "%d messages handled in ISR", n);
Index: net-next-2.6/drivers/net/can/sja1000/sja1000.h
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/sja1000.h	2009-05-30 19:48:32.763721448 +0200
+++ net-next-2.6/drivers/net/can/sja1000/sja1000.h	2009-05-30 19:48:39.361720656 +0200
@@ -155,14 +155,15 @@
 	struct sk_buff *echo_skb;
 
 	/* the lower-layer is responsible for appropriate locking */
-	u8 (*read_reg) (const struct net_device *dev, int reg);
-	void (*write_reg) (const struct net_device *dev, int reg, u8 val);
-	void (*pre_irq) (const struct net_device *dev);
-	void (*post_irq) (const struct net_device *dev);
+	u8 (*read_reg) (const struct sja1000_priv *priv, int reg);
+	void (*write_reg) (const struct sja1000_priv *priv, int reg, u8 val);
+	void (*pre_irq) (const struct sja1000_priv *priv);
+	void (*post_irq) (const struct sja1000_priv *priv);
 
 	void *priv;		/* for board-specific data */
 	struct net_device *dev;
 
+	void __iomem *reg_base;	 /* ioremap'ed address to registers */
 	unsigned long irq_flags; /* for request_irq() */
 
 	u16 flags;		/* custom mode flags */
Index: net-next-2.6/drivers/net/can/sja1000/sja1000_platform.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/sja1000_platform.c	2009-05-30 19:48:32.763721448 +0200
+++ net-next-2.6/drivers/net/can/sja1000/sja1000_platform.c	2009-05-30 19:48:39.364721082 +0200
@@ -37,14 +37,14 @@
 MODULE_DESCRIPTION("Socket-CAN driver for SJA1000 on the platform bus");
 MODULE_LICENSE("GPL v2");
 
-static u8 sp_read_reg(const struct net_device *dev, int reg)
+static u8 sp_read_reg(const struct sja1000_priv *priv, int reg)
 {
-	return ioread8((void __iomem *)(dev->base_addr + reg));
+	return ioread8(priv->reg_base + reg);
 }
 
-static void sp_write_reg(const struct net_device *dev, int reg, u8 val)
+static void sp_write_reg(const struct sja1000_priv *priv, int reg, u8 val)
 {
-	iowrite8(val, (void __iomem *)(dev->base_addr + reg));
+	iowrite8(val, priv->reg_base + reg);
 }
 
 static int sp_probe(struct platform_device *pdev)
@@ -89,9 +89,9 @@
 	}
 	priv = netdev_priv(dev);
 
-	dev->base_addr = (unsigned long)addr;
 	dev->irq = res_irq->start;
 	priv->irq_flags = res_irq->flags & IRQF_TRIGGER_MASK;
+	priv->reg_base = addr;
 	priv->read_reg = sp_read_reg;
 	priv->write_reg = sp_write_reg;
 	priv->can.clock.freq = pdata->clock;
@@ -108,8 +108,8 @@
 		goto exit_free;
 	}
 
-	dev_info(&pdev->dev, "%s device registered (base_addr=%#lx, irq=%d)\n",
-		 DRV_NAME, dev->base_addr, dev->irq);
+	dev_info(&pdev->dev, "%s device registered (reg_base=%p, irq=%d)\n",
+		 DRV_NAME, priv->reg_base, dev->irq);
 	return 0;
 
  exit_free:
@@ -125,13 +125,14 @@
 static int sp_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = dev_get_drvdata(&pdev->dev);
+	struct sja1000_priv *priv = netdev_priv(dev);
 	struct resource *res;
 
 	unregister_sja1000dev(dev);
 	dev_set_drvdata(&pdev->dev, NULL);
 
-	if (dev->base_addr)
-		iounmap((void __iomem *)dev->base_addr);
+	if (priv->reg_base)
+		iounmap(priv->reg_base);
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	release_mem_region(res->start, resource_size(res));

