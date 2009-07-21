From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH net-next-2.6] can: sja1000: Add support for the new 4 channel
 EMS CPC-PCI cards
Date: Tue, 21 Jul 2009 18:23:20 +0200
Message-ID: <4A65EB78.80008@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core@lists.berlios.de,
	Sebastian Haas <haas@ems-wuensche.com>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:49776 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754950AbZGUQXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 12:23:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to the ems_pci driver for the new, v2,
4 channel CPC-PCI/PCIe/104P CAN cards from EMS Dr. Thomas Wuensche.

Signed-off-by: Sebastian Haas <haas@ems-wuensche.com>
Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/Kconfig           |    7 +
 drivers/net/can/sja1000/ems_pci.c |  152 +++++++++++++++++++++++++++-----------
 2 files changed, 112 insertions(+), 47 deletions(-)

Index: net-next-2.6/drivers/net/can/sja1000/ems_pci.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/ems_pci.c
+++ net-next-2.6/drivers/net/can/sja1000/ems_pci.c
@@ -32,13 +32,16 @@
 #define DRV_NAME  "ems_pci"
 
 MODULE_AUTHOR("Sebastian Haas <haas@ems-wuenche.com>");
-MODULE_DESCRIPTION("Socket-CAN driver for EMS CPC-PCI/PCIe CAN cards");
-MODULE_SUPPORTED_DEVICE("EMS CPC-PCI/PCIe CAN card");
+MODULE_DESCRIPTION("Socket-CAN driver for EMS CPC-PCI/PCIe/104P CAN cards");
+MODULE_SUPPORTED_DEVICE("EMS CPC-PCI/PCIe/104P CAN card");
 MODULE_LICENSE("GPL v2");
 
-#define EMS_PCI_MAX_CHAN 2
+#define EMS_PCI_V1_MAX_CHAN 2
+#define EMS_PCI_V2_MAX_CHAN 4
+#define EMS_PCI_MAX_CHAN    EMS_PCI_V2_MAX_CHAN
 
 struct ems_pci_card {
+	int version;
 	int channels;
 
 	struct pci_dev *pci_dev;
@@ -63,12 +66,22 @@ struct ems_pci_card {
 #define PITA2_MISC_CONFIG   0x04000000	/* Multiplexed parallel interface */
 
 /*
+ * Register definitions for the PLX 9030
+ */
+#define PLX_ICSR            0x4c   /* Interrupt Control/Status register */
+#define PLX_ICSR_LINTI1_ENA 0x0001 /* LINTi1 Enable */
+#define PLX_ICSR_PCIINT_ENA 0x0040 /* PCI Interrupt Enable */
+#define PLX_ICSR_LINTI1_CLR 0x0400 /* Local Edge Triggerable Interrupt Clear */
+#define PLX_ICSR_ENA_CLR    (PLX_ICSR_LINTI1_ENA | PLX_ICSR_PCIINT_ENA | \
+			     PLX_ICSR_LINTI1_CLR)
+
+/*
  * The board configuration is probably following:
  * RX1 is connected to ground.
  * TX1 is not connected.
  * CLKO is not connected.
  * Setting the OCR register to 0xDA is a good idea.
- * This means  normal output mode , push-pull and the correct polarity.
+ * This means normal output mode, push-pull and the correct polarity.
  */
 #define EMS_PCI_OCR         (OCR_TX0_PUSHPULL | OCR_TX1_PUSHPULL)
 
@@ -79,17 +92,21 @@ struct ems_pci_card {
  * is driven by the first one CLKOUT output.
  */
 #define EMS_PCI_CDR             (CDR_CBP | CDR_CLKOUT_MASK)
-#define EMS_PCI_MEM_SIZE        4096  /* Size of the remapped io-memory */
+
+#define EMS_PCI_V1_BASE_BAR     1
+#define EMS_PCI_V1_MEM_SIZE     4096
+#define EMS_PCI_V2_BASE_BAR     2
+#define EMS_PCI_V2_MEM_SIZE     128
 #define EMS_PCI_CAN_BASE_OFFSET 0x400 /* offset where the controllers starts */
 #define EMS_PCI_CAN_CTRL_SIZE   0x200 /* memory size for each controller */
 
-#define EMS_PCI_PORT_BYTES  0x4     /* Each register occupies 4 bytes */
-
-#define EMS_PCI_VENDOR_ID   0x110a  /* PCI device and vendor ID */
-#define EMS_PCI_DEVICE_ID   0x2104
-
 static struct pci_device_id ems_pci_tbl[] = {
-	{EMS_PCI_VENDOR_ID, EMS_PCI_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
+	/* CPC-PCI v1 */
+	{PCI_VENDOR_ID_SIEMENS, 0x2104, PCI_ANY_ID, PCI_ANY_ID,},
+	/* CPC-PCI v2 */
+	{PCI_VENDOR_ID_PLX, PCI_DEVICE_ID_PLX_9030, PCI_VENDOR_ID_PLX, 0x4000},
+	/* CPC-104P v2 */
+	{PCI_VENDOR_ID_PLX, PCI_DEVICE_ID_PLX_9030, PCI_VENDOR_ID_PLX, 0x4002},
 	{0,}
 };
 MODULE_DEVICE_TABLE(pci, ems_pci_tbl);
@@ -97,28 +114,47 @@ MODULE_DEVICE_TABLE(pci, ems_pci_tbl);
 /*
  * Helper to read internal registers from card logic (not CAN)
  */
-static u8 ems_pci_readb(struct ems_pci_card *card, unsigned int port)
+static u8 ems_pci_v1_readb(struct ems_pci_card *card, unsigned int port)
 {
-	return readb(card->base_addr + (port * EMS_PCI_PORT_BYTES));
+	return readb(card->base_addr + (port * 4));
 }
 
-static u8 ems_pci_read_reg(const struct sja1000_priv *priv, int port)
+static u8 ems_pci_v1_read_reg(const struct sja1000_priv *priv, int port)
 {
-	return readb(priv->reg_base + (port * EMS_PCI_PORT_BYTES));
+	return readb(priv->reg_base + (port * 4));
 }
 
-static void ems_pci_write_reg(const struct sja1000_priv *priv, int port, u8 val)
+static void ems_pci_v1_write_reg(const struct sja1000_priv *priv,
+				 int port, u8 val)
 {
-	writeb(val, priv->reg_base + (port * EMS_PCI_PORT_BYTES));
+	writeb(val, priv->reg_base + (port * 4));
 }
 
-static void ems_pci_post_irq(const struct sja1000_priv *priv)
+static void ems_pci_v1_post_irq(const struct sja1000_priv *priv)
 {
 	struct ems_pci_card *card = (struct ems_pci_card *)priv->priv;
 
 	/* reset int flag of pita */
-	writel(PITA2_ICR_INT0_EN | PITA2_ICR_INT0, card->conf_addr
-		+ PITA2_ICR);
+	writel(PITA2_ICR_INT0_EN | PITA2_ICR_INT0,
+	       card->conf_addr + PITA2_ICR);
+}
+
+static u8 ems_pci_v2_read_reg(const struct sja1000_priv *priv, int port)
+{
+	return readb(priv->reg_base + port);
+}
+
+static void ems_pci_v2_write_reg(const struct sja1000_priv *priv,
+				 int port, u8 val)
+{
+	writeb(val, priv->reg_base + port);
+}
+
+static void ems_pci_v2_post_irq(const struct sja1000_priv *priv)
+{
+	struct ems_pci_card *card = (struct ems_pci_card *)priv->priv;
+
+	writel(PLX_ICSR_ENA_CLR, card->conf_addr + PLX_ICSR);
 }
 
 /*
@@ -130,12 +166,12 @@ static inline int ems_pci_check_chan(con
 	unsigned char res;
 
 	/* Make sure SJA1000 is in reset mode */
-	ems_pci_write_reg(priv, REG_MOD, 1);
+	priv->write_reg(priv, REG_MOD, 1);
 
-	ems_pci_write_reg(priv, REG_CDR, CDR_PELICAN);
+	priv->write_reg(priv, REG_CDR, CDR_PELICAN);
 
 	/* read reset-values */
-	res = ems_pci_read_reg(priv, REG_CDR);
+	res = priv->read_reg(priv, REG_CDR);
 
 	if (res == CDR_PELICAN)
 		return 1;
@@ -188,6 +224,7 @@ static int __devinit ems_pci_add_card(st
 	struct sja1000_priv *priv;
 	struct net_device *dev;
 	struct ems_pci_card *card;
+	int max_chan, mem_size, base_bar;
 	int err, i;
 
 	/* Enabling PCI device */
@@ -210,37 +247,52 @@ static int __devinit ems_pci_add_card(st
 
 	card->channels = 0;
 
-	/* Remap PITA configuration space, and controller memory area */
-	card->conf_addr = pci_iomap(pdev, 0, EMS_PCI_MEM_SIZE);
+	if (pdev->vendor == PCI_VENDOR_ID_PLX) {
+		card->version = 2; /* CPC-PCI v2 */
+		max_chan = EMS_PCI_V2_MAX_CHAN;
+		base_bar = EMS_PCI_V2_BASE_BAR;
+		mem_size = EMS_PCI_V2_MEM_SIZE;
+	} else {
+		card->version = 1; /* CPC-PCI v1 */
+		max_chan = EMS_PCI_V1_MAX_CHAN;
+		base_bar = EMS_PCI_V1_BASE_BAR;
+		mem_size = EMS_PCI_V1_MEM_SIZE;
+	}
+
+	/* Remap configuration space and controller memory area */
+	card->conf_addr = pci_iomap(pdev, 0, mem_size);
 	if (card->conf_addr == NULL) {
 		err = -ENOMEM;
 		goto failure_cleanup;
 	}
 
-	card->base_addr = pci_iomap(pdev, 1, EMS_PCI_MEM_SIZE);
+	card->base_addr = pci_iomap(pdev, base_bar, mem_size);
 	if (card->base_addr == NULL) {
 		err = -ENOMEM;
 		goto failure_cleanup;
 	}
 
-	/* Configure PITA-2 parallel interface (enable MUX) */
-	writel(PITA2_MISC_CONFIG, card->conf_addr + PITA2_MISC);
-
-	/* Check for unique EMS CAN signature */
-	if (ems_pci_readb(card, 0) != 0x55 ||
-	    ems_pci_readb(card, 1) != 0xAA ||
-	    ems_pci_readb(card, 2) != 0x01 ||
-	    ems_pci_readb(card, 3) != 0xCB ||
-	    ems_pci_readb(card, 4) != 0x11) {
-		dev_err(&pdev->dev, "Not EMS Dr. Thomas Wuensche interface\n");
-		err = -ENODEV;
-		goto failure_cleanup;
+	if (card->version == 1) {
+		/* Configure PITA-2 parallel interface (enable MUX) */
+		writel(PITA2_MISC_CONFIG, card->conf_addr + PITA2_MISC);
+
+		/* Check for unique EMS CAN signature */
+		if (ems_pci_v1_readb(card, 0) != 0x55 ||
+		    ems_pci_v1_readb(card, 1) != 0xAA ||
+		    ems_pci_v1_readb(card, 2) != 0x01 ||
+		    ems_pci_v1_readb(card, 3) != 0xCB ||
+		    ems_pci_v1_readb(card, 4) != 0x11) {
+			dev_err(&pdev->dev,
+				"Not EMS Dr. Thomas Wuensche interface\n");
+			err = -ENODEV;
+			goto failure_cleanup;
+		}
 	}
 
 	ems_pci_card_reset(card);
 
 	/* Detect available channels */
-	for (i = 0; i < EMS_PCI_MAX_CHAN; i++) {
+	for (i = 0; i < max_chan; i++) {
 		dev = alloc_sja1000dev(0);
 		if (dev == NULL) {
 			err = -ENOMEM;
@@ -255,20 +307,32 @@ static int __devinit ems_pci_add_card(st
 		dev->irq = pdev->irq;
 		priv->reg_base = card->base_addr + EMS_PCI_CAN_BASE_OFFSET
 					+ (i * EMS_PCI_CAN_CTRL_SIZE);
+		if (card->version == 1) {
+			priv->read_reg  = ems_pci_v1_read_reg;
+			priv->write_reg = ems_pci_v1_write_reg;
+			priv->post_irq  = ems_pci_v1_post_irq;
+		} else {
+			priv->read_reg  = ems_pci_v2_read_reg;
+			priv->write_reg = ems_pci_v2_write_reg;
+			priv->post_irq  = ems_pci_v2_post_irq;
+		}
 
 		/* Check if channel is present */
 		if (ems_pci_check_chan(priv)) {
-			priv->read_reg  = ems_pci_read_reg;
-			priv->write_reg = ems_pci_write_reg;
-			priv->post_irq  = ems_pci_post_irq;
 			priv->can.clock.freq = EMS_PCI_CAN_CLOCK;
 			priv->ocr = EMS_PCI_OCR;
 			priv->cdr = EMS_PCI_CDR;
 
 			SET_NETDEV_DEV(dev, &pdev->dev);
 
-			/* Enable interrupts from card */
-			writel(PITA2_ICR_INT0_EN, card->conf_addr + PITA2_ICR);
+			if (card->version == 1)
+				/* reset int flag of pita */
+				writel(PITA2_ICR_INT0_EN | PITA2_ICR_INT0,
+				       card->conf_addr + PITA2_ICR);
+			else
+				/* enable IRQ in PLX 9030 */
+				writel(PLX_ICSR_ENA_CLR,
+				       card->conf_addr + PLX_ICSR);
 
 			/* Register SJA1000 device */
 			err = register_sja1000dev(dev);
Index: net-next-2.6/drivers/net/can/Kconfig
===================================================================
--- net-next-2.6.orig/drivers/net/can/Kconfig
+++ net-next-2.6/drivers/net/can/Kconfig
@@ -61,11 +61,12 @@ config CAN_SJA1000_OF_PLATFORM
 	  you may want to enable this option.
 
 config CAN_EMS_PCI
-	tristate "EMS CPC-PCI and CPC-PCIe Card"
+	tristate "EMS CPC-PCI, CPC-PCIe and CPC-104P Card"
 	depends on PCI && CAN_SJA1000
 	---help---
-	  This driver is for the one or two channel CPC-PCI and CPC-PCIe
-	  cards from EMS Dr. Thomas Wuensche (http://www.ems-wuensche.de).
+	  This driver is for the one, two or four channel CPC-PCI,
+	  CPC-PCIe and CPC-104P cards from EMS Dr. Thomas Wuensche
+	  (http://www.ems-wuensche.de).
 
 config CAN_KVASER_PCI
 	tristate "Kvaser PCIcanx and Kvaser PCIcan PCI Cards"
