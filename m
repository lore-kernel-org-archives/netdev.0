From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 25/39] xircom_cb: stop using net_device.{base_addr, irq} and convert to __iomem.
Date: Fri,  6 Apr 2012 12:06:39 +0200
Message-ID: <d8cb2b1097a9c64778dc1ab9bb33bcf5bf62bfc7.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43494 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756090Ab2DFKKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:43 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Grant Grundler <grundler@parisc-linux.org>
---
 drivers/net/ethernet/dec/tulip/xircom_cb.c |  227 +++++++++++++++-------------
 1 files changed, 124 insertions(+), 103 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
index cbcc6d6..138bf83 100644
--- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
+++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
@@ -41,7 +41,9 @@ MODULE_DESCRIPTION("Xircom Cardbus ethernet driver");
 MODULE_AUTHOR("Arjan van de Ven <arjanv@redhat.com>");
 MODULE_LICENSE("GPL");
 
-
+#define xw32(reg, val)	iowrite32(val, ioaddr + (reg))
+#define xr32(reg)	ioread32(ioaddr + (reg))
+#define xr8(reg)	ioread8(ioaddr + (reg))
 
 /* IO registers on the card, offsets */
 #define CSR0	0x00
@@ -83,7 +85,7 @@ struct xircom_private {
 
 	struct sk_buff *tx_skb[4];
 
-	unsigned long io_port;
+	void __iomem *ioaddr;
 	int open;
 
 	/* transmit_used is the rotating counter that indicates which transmit
@@ -137,7 +139,7 @@ static int link_status(struct xircom_private *card);
 
 
 static DEFINE_PCI_DEVICE_TABLE(xircom_pci_table) = {
-	{0x115D, 0x0003, PCI_ANY_ID, PCI_ANY_ID,},
+	{ PCI_VDEVICE(XIRCOM, 0x0003), },
 	{0,},
 };
 MODULE_DEVICE_TABLE(pci, xircom_pci_table);
@@ -146,9 +148,7 @@ static struct pci_driver xircom_ops = {
 	.name		= "xircom_cb",
 	.id_table	= xircom_pci_table,
 	.probe		= xircom_probe,
-	.remove		= xircom_remove,
-	.suspend =NULL,
-	.resume =NULL
+	.remove		= __devexit_p(xircom_remove),
 };
 
 
@@ -253,10 +253,13 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 
 	private->dev = dev;
 	private->pdev = pdev;
-	private->io_port = pci_resource_start(pdev, 0);
+
+	/* IO range. */
+	private->ioaddr = pci_iomap(pdev, 0, 0);
+	if (!private->ioaddr)
+		goto reg_fail;
+
 	spin_lock_init(&private->lock);
-	dev->irq = pdev->irq;
-	dev->base_addr = private->io_port;
 
 	initialize_card(private);
 	read_mac_address(private);
@@ -268,7 +271,7 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 	rc = register_netdev(dev);
 	if (rc < 0) {
 		pr_err("%s: netdevice registration failed\n", __func__);
-		goto reg_fail;
+		goto err_unmap;
 	}
 
 	netdev_info(dev, "Xircom cardbus revision %i at irq %i\n",
@@ -286,6 +289,8 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 out:
 	return rc;
 
+err_unmap:
+	pci_iounmap(pdev, private->ioaddr);
 reg_fail:
 	pci_set_drvdata(pdev, NULL);
 	dma_free_coherent(d, 8192, private->tx_buffer, private->tx_dma_handle);
@@ -314,6 +319,7 @@ static void __devexit xircom_remove(struct pci_dev *pdev)
 	struct device *d = &pdev->dev;
 
 	unregister_netdev(dev);
+	pci_iounmap(pdev, card->ioaddr);
 	pci_set_drvdata(pdev, NULL);
 	dma_free_coherent(d, 8192, card->tx_buffer, card->tx_dma_handle);
 	dma_free_coherent(d, 8192, card->rx_buffer, card->rx_dma_handle);
@@ -326,11 +332,12 @@ static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
 	struct xircom_private *card = netdev_priv(dev);
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int status;
 	int i;
 
 	spin_lock(&card->lock);
-	status = inl(card->io_port+CSR5);
+	status = xr32(CSR5);
 
 #if defined DEBUG && DEBUG > 1
 	print_binary(status);
@@ -360,7 +367,7 @@ static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
 	/* Clear all remaining interrupts */
 	status |= 0xffffffff; /* FIXME: make this clear only the
 				        real existing bits */
-	outl(status,card->io_port+CSR5);
+	xw32(CSR5, status);
 
 
 	for (i=0;i<NUMDESCRIPTORS;i++)
@@ -438,11 +445,11 @@ static netdev_tx_t xircom_start_xmit(struct sk_buff *skb,
 static int xircom_open(struct net_device *dev)
 {
 	struct xircom_private *xp = netdev_priv(dev);
+	const int irq = xp->pdev->irq;
 	int retval;
 
-	netdev_info(dev, "xircom cardbus adaptor found, using irq %i\n",
-		    dev->irq);
-	retval = request_irq(dev->irq, xircom_interrupt, IRQF_SHARED, dev->name, dev);
+	netdev_info(dev, "xircom cardbus adaptor found, using irq %i\n", irq);
+	retval = request_irq(irq, xircom_interrupt, IRQF_SHARED, dev->name, dev);
 	if (retval)
 		return retval;
 
@@ -474,7 +481,7 @@ static int xircom_close(struct net_device *dev)
 	spin_unlock_irqrestore(&card->lock,flags);
 
 	card->open = 0;
-	free_irq(dev->irq,dev);
+	free_irq(card->pdev->irq, dev);
 
 	return 0;
 
@@ -484,35 +491,39 @@ static int xircom_close(struct net_device *dev)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void xircom_poll_controller(struct net_device *dev)
 {
-	disable_irq(dev->irq);
-	xircom_interrupt(dev->irq, dev);
-	enable_irq(dev->irq);
+	struct xircom_private *xp = netdev_priv(dev);
+	const int irq = xp->pdev->irq;
+
+	disable_irq(irq);
+	xircom_interrupt(irq, dev);
+	enable_irq(irq);
 }
 #endif
 
 
 static void initialize_card(struct xircom_private *card)
 {
-	unsigned int val;
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned long flags;
+	u32 val;
 
 	spin_lock_irqsave(&card->lock, flags);
 
 	/* First: reset the card */
-	val = inl(card->io_port + CSR0);
+	val = xr32(CSR0);
 	val |= 0x01;		/* Software reset */
-	outl(val, card->io_port + CSR0);
+	xw32(CSR0, val);
 
 	udelay(100);		/* give the card some time to reset */
 
-	val = inl(card->io_port + CSR0);
+	val = xr32(CSR0);
 	val &= ~0x01;		/* disable Software reset */
-	outl(val, card->io_port + CSR0);
+	xw32(CSR0, val);
 
 
 	val = 0;		/* Value 0x00 is a safe and conservative value
 				   for the PCI configuration settings */
-	outl(val, card->io_port + CSR0);
+	xw32(CSR0, val);
 
 
 	disable_all_interrupts(card);
@@ -530,10 +541,9 @@ ignored; I chose zero.
 */
 static void trigger_transmit(struct xircom_private *card)
 {
-	unsigned int val;
+	void __iomem *ioaddr = card->ioaddr;
 
-	val = 0;
-	outl(val, card->io_port + CSR1);
+	xw32(CSR1, 0);
 }
 
 /*
@@ -545,10 +555,9 @@ ignored; I chose zero.
 */
 static void trigger_receive(struct xircom_private *card)
 {
-	unsigned int val;
+	void __iomem *ioaddr = card->ioaddr;
 
-	val = 0;
-	outl(val, card->io_port + CSR2);
+	xw32(CSR2, 0);
 }
 
 /*
@@ -557,6 +566,7 @@ descriptors and programs the addresses into the card.
 */
 static void setup_descriptors(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	u32 address;
 	int i;
 
@@ -586,7 +596,7 @@ static void setup_descriptors(struct xircom_private *card)
 	wmb();
 	/* Write the receive descriptor ring address to the card */
 	address = card->rx_dma_handle;
-	outl(address, card->io_port + CSR3);	/* Receive descr list address */
+	xw32(CSR3, address);	/* Receive descr list address */
 
 
 	/* transmit descriptors */
@@ -611,7 +621,7 @@ static void setup_descriptors(struct xircom_private *card)
 	wmb();
 	/* wite the transmit descriptor ring to the card */
 	address = card->tx_dma_handle;
-	outl(address, card->io_port + CSR4);	/* xmit descr list address */
+	xw32(CSR4, address);	/* xmit descr list address */
 }
 
 /*
@@ -620,11 +630,12 @@ valid by setting the address in the card to 0x00.
 */
 static void remove_descriptors(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 
 	val = 0;
-	outl(val, card->io_port + CSR3);	/* Receive descriptor address */
-	outl(val, card->io_port + CSR4);	/* Send descriptor address */
+	xw32(CSR3, val);	/* Receive descriptor address */
+	xw32(CSR4, val);	/* Send descriptor address */
 }
 
 /*
@@ -635,17 +646,17 @@ This function also clears the status-bit.
 */
 static int link_status_changed(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 
-	val = inl(card->io_port + CSR5);	/* Status register */
-
-	if ((val & (1 << 27)) == 0)		/* no change */
+	val = xr32(CSR5);	/* Status register */
+	if (!(val & (1 << 27)))	/* no change */
 		return 0;
 
 	/* clear the event by writing a 1 to the bit in the
 	   status register. */
 	val = (1 << 27);
-	outl(val, card->io_port + CSR5);
+	xw32(CSR5, val);
 
 	return 1;
 }
@@ -657,11 +668,9 @@ in a non-stopped state.
 */
 static int transmit_active(struct xircom_private *card)
 {
-	unsigned int val;
+	void __iomem *ioaddr = card->ioaddr;
 
-	val = inl(card->io_port + CSR5);	/* Status register */
-
-	if ((val & (7 << 20)) == 0)		/* transmitter disabled */
+	if (!(xr32(CSR5) & (7 << 20)))	/* transmitter disabled */
 		return 0;
 
 	return 1;
@@ -673,11 +682,9 @@ in a non-stopped state.
 */
 static int receive_active(struct xircom_private *card)
 {
-	unsigned int val;
-
-	val = inl(card->io_port + CSR5);	/* Status register */
+	void __iomem *ioaddr = card->ioaddr;
 
-	if ((val & (7 << 17)) == 0)		/* receiver disabled */
+	if (!(xr32(CSR5) & (7 << 17)))	/* receiver disabled */
 		return 0;
 
 	return 1;
@@ -695,10 +702,11 @@ must be called with the lock held and interrupts disabled.
 */
 static void activate_receiver(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 	int counter;
 
-	val = inl(card->io_port + CSR6);	/* Operation mode */
+	val = xr32(CSR6);	/* Operation mode */
 
 	/* If the "active" bit is set and the receiver is already
 	   active, no need to do the expensive thing */
@@ -707,7 +715,7 @@ static void activate_receiver(struct xircom_private *card)
 
 
 	val = val & ~2;		/* disable the receiver */
-	outl(val, card->io_port + CSR6);
+	xw32(CSR6, val);
 
 	counter = 10;
 	while (counter > 0) {
@@ -721,9 +729,9 @@ static void activate_receiver(struct xircom_private *card)
 	}
 
 	/* enable the receiver */
-	val = inl(card->io_port + CSR6);	/* Operation mode */
-	val = val | 2;				/* enable the receiver */
-	outl(val, card->io_port + CSR6);
+	val = xr32(CSR6);	/* Operation mode */
+	val = val | 2;		/* enable the receiver */
+	xw32(CSR6, val);
 
 	/* now wait for the card to activate again */
 	counter = 10;
@@ -748,12 +756,13 @@ must be called with the lock held and interrupts disabled.
 */
 static void deactivate_receiver(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 	int counter;
 
-	val = inl(card->io_port + CSR6);	/* Operation mode */
-	val = val & ~2;				/* disable the receiver */
-	outl(val, card->io_port + CSR6);
+	val = xr32(CSR6);	/* Operation mode */
+	val = val & ~2;		/* disable the receiver */
+	xw32(CSR6, val);
 
 	counter = 10;
 	while (counter > 0) {
@@ -780,10 +789,11 @@ must be called with the lock held and interrupts disabled.
 */
 static void activate_transmitter(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 	int counter;
 
-	val = inl(card->io_port + CSR6);	/* Operation mode */
+	val = xr32(CSR6);	/* Operation mode */
 
 	/* If the "active" bit is set and the receiver is already
 	   active, no need to do the expensive thing */
@@ -791,7 +801,7 @@ static void activate_transmitter(struct xircom_private *card)
 		return;
 
 	val = val & ~(1 << 13);	/* disable the transmitter */
-	outl(val, card->io_port + CSR6);
+	xw32(CSR6, val);
 
 	counter = 10;
 	while (counter > 0) {
@@ -806,9 +816,9 @@ static void activate_transmitter(struct xircom_private *card)
 	}
 
 	/* enable the transmitter */
-	val = inl(card->io_port + CSR6);	/* Operation mode */
+	val = xr32(CSR6);	/* Operation mode */
 	val = val | (1 << 13);	/* enable the transmitter */
-	outl(val, card->io_port + CSR6);
+	xw32(CSR6, val);
 
 	/* now wait for the card to activate again */
 	counter = 10;
@@ -833,12 +843,13 @@ must be called with the lock held and interrupts disabled.
 */
 static void deactivate_transmitter(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 	int counter;
 
-	val = inl(card->io_port + CSR6);	/* Operation mode */
+	val = xr32(CSR6);	/* Operation mode */
 	val = val & ~2;		/* disable the transmitter */
-	outl(val, card->io_port + CSR6);
+	xw32(CSR6, val);
 
 	counter = 20;
 	while (counter > 0) {
@@ -861,11 +872,12 @@ must be called with the lock held and interrupts disabled.
 */
 static void enable_transmit_interrupt(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 
-	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
-	val |= 1;				/* enable the transmit interrupt */
-	outl(val, card->io_port + CSR7);
+	val = xr32(CSR7);	/* Interrupt enable register */
+	val |= 1;		/* enable the transmit interrupt */
+	xw32(CSR7, val);
 }
 
 
@@ -876,11 +888,12 @@ must be called with the lock held and interrupts disabled.
 */
 static void enable_receive_interrupt(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 
-	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
-	val = val | (1 << 6);			/* enable the receive interrupt */
-	outl(val, card->io_port + CSR7);
+	val = xr32(CSR7);	/* Interrupt enable register */
+	val = val | (1 << 6);	/* enable the receive interrupt */
+	xw32(CSR7, val);
 }
 
 /*
@@ -890,11 +903,12 @@ must be called with the lock held and interrupts disabled.
 */
 static void enable_link_interrupt(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 
-	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
-	val = val | (1 << 27);			/* enable the link status chage interrupt */
-	outl(val, card->io_port + CSR7);
+	val = xr32(CSR7);	/* Interrupt enable register */
+	val = val | (1 << 27);	/* enable the link status chage interrupt */
+	xw32(CSR7, val);
 }
 
 
@@ -906,10 +920,9 @@ must be called with the lock held and interrupts disabled.
 */
 static void disable_all_interrupts(struct xircom_private *card)
 {
-	unsigned int val;
+	void __iomem *ioaddr = card->ioaddr;
 
-	val = 0;				/* disable all interrupts */
-	outl(val, card->io_port + CSR7);
+	xw32(CSR7, 0);
 }
 
 /*
@@ -919,9 +932,10 @@ must be called with the lock held and interrupts disabled.
 */
 static void enable_common_interrupts(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 
-	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
+	val = xr32(CSR7);	/* Interrupt enable register */
 	val |= (1<<16); /* Normal Interrupt Summary */
 	val |= (1<<15); /* Abnormal Interrupt Summary */
 	val |= (1<<13); /* Fatal bus error */
@@ -930,7 +944,7 @@ static void enable_common_interrupts(struct xircom_private *card)
 	val |= (1<<5);  /* Transmit Underflow */
 	val |= (1<<2);  /* Transmit Buffer Unavailable */
 	val |= (1<<1);  /* Transmit Process Stopped */
-	outl(val, card->io_port + CSR7);
+	xw32(CSR7, val);
 }
 
 /*
@@ -940,11 +954,12 @@ must be called with the lock held and interrupts disabled.
 */
 static int enable_promisc(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 
-	val = inl(card->io_port + CSR6);
+	val = xr32(CSR6);
 	val = val | (1 << 6);
-	outl(val, card->io_port + CSR6);
+	xw32(CSR6, val);
 
 	return 1;
 }
@@ -959,13 +974,16 @@ Must be called in locked state with interrupts disabled
 */
 static int link_status(struct xircom_private *card)
 {
-	unsigned int val;
+	void __iomem *ioaddr = card->ioaddr;
+	u8 val;
 
-	val = inb(card->io_port + CSR12);
+	val = xr8(CSR12);
 
-	if (!(val&(1<<2)))  /* bit 2 is 0 for 10mbit link, 1 for not an 10mbit link */
+	/* bit 2 is 0 for 10mbit link, 1 for not an 10mbit link */
+	if (!(val & (1 << 2)))
 		return 10;
-	if (!(val&(1<<1)))  /* bit 1 is 0 for 100mbit link, 1 for not an 100mbit link */
+	/* bit 1 is 0 for 100mbit link, 1 for not an 100mbit link */
+	if (!(val & (1 << 1)))
 		return 100;
 
 	/* If we get here -> no link at all */
@@ -984,29 +1002,31 @@ static int link_status(struct xircom_private *card)
  */
 static void read_mac_address(struct xircom_private *card)
 {
-	unsigned char j, tuple, link, data_id, data_count;
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned long flags;
+	u8 link;
 	int i;
 
 	spin_lock_irqsave(&card->lock, flags);
 
-	outl(1 << 12, card->io_port + CSR9);	/* enable boot rom access */
+	xw32(CSR9, 1 << 12);	/* enable boot rom access */
 	for (i = 0x100; i < 0x1f7; i += link + 2) {
-		outl(i, card->io_port + CSR10);
-		tuple = inl(card->io_port + CSR9) & 0xff;
-		outl(i + 1, card->io_port + CSR10);
-		link = inl(card->io_port + CSR9) & 0xff;
-		outl(i + 2, card->io_port + CSR10);
-		data_id = inl(card->io_port + CSR9) & 0xff;
-		outl(i + 3, card->io_port + CSR10);
-		data_count = inl(card->io_port + CSR9) & 0xff;
+		u8 tuple, data_id, data_count;
+
+		xw32(CSR10, i);
+		tuple = xr32(CSR9);
+		xw32(CSR10, i + 1);
+		link = xr32(CSR9);
+		xw32(CSR10, i + 2);
+		data_id = xr32(CSR9);
+		xw32(CSR10, i + 3);
+		data_count = xr32(CSR9);
 		if ((tuple == 0x22) && (data_id == 0x04) && (data_count == 0x06)) {
-			/*
-			 * This is it.  We have the data we want.
-			 */
+			int j;
+
 			for (j = 0; j < 6; j++) {
-				outl(i + j + 4, card->io_port + CSR10);
-				card->dev->dev_addr[j] = inl(card->io_port + CSR9) & 0xff;
+				xw32(CSR10, i + j + 4);
+				card->dev->dev_addr[j] = xr32(CSR9) & 0xff;
 			}
 			break;
 		} else if (link == 0) {
@@ -1025,6 +1045,7 @@ static void read_mac_address(struct xircom_private *card)
  */
 static void transceiver_voodoo(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned long flags;
 
 	/* disable all powermanagement */
@@ -1034,14 +1055,14 @@ static void transceiver_voodoo(struct xircom_private *card)
 
 	spin_lock_irqsave(&card->lock, flags);
 
-	outl(0x0008, card->io_port + CSR15);
-        udelay(25);
-        outl(0xa8050000, card->io_port + CSR15);
-        udelay(25);
-        outl(0xa00f0000, card->io_port + CSR15);
-        udelay(25);
+	xw32(CSR15, 0x0008);
+	udelay(25);
+	xw32(CSR15, 0xa8050000);
+	udelay(25);
+	xw32(CSR15, 0xa00f0000);
+	udelay(25);
 
-        spin_unlock_irqrestore(&card->lock, flags);
+	spin_unlock_irqrestore(&card->lock, flags);
 
 	netif_start_queue(card->dev);
 }
-- 
1.7.7.6
