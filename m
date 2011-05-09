From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/4] tulip: xircom_cb: Convert #ifdef DEBUG blocks and enter/leave uses
Date: Mon,  9 May 2011 12:45:20 -0700
Message-ID: <abc11d127dbde89baf98eaa6c409d89b2a8a5a21.1304970062.git.joe@perches.com>
References: <cover.1304970062.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1304970062.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the blocks that are guarded by #if DEBUG to
be #if defined DEBUG && DEBUG > 1 so that pr_debug
can be used later.

Remove enter/leave macros and uses.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/xircom_cb.c |  134 ++++-------------------------------------
 1 files changed, 13 insertions(+), 121 deletions(-)

diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 5a73752..d0d0cbe 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -37,15 +37,6 @@
 #include <asm/irq.h>
 #endif
 
-#ifdef DEBUG
-#define enter(x)   printk("Enter: %s, %s line %i\n",x,__FILE__,__LINE__)
-#define leave(x)   printk("Leave: %s, %s line %i\n",x,__FILE__,__LINE__)
-#else
-#define enter(x)   do {} while (0)
-#define leave(x)   do {} while (0)
-#endif
-
-
 MODULE_DESCRIPTION("Xircom Cardbus ethernet driver");
 MODULE_AUTHOR("Arjan van de Ven <arjanv@redhat.com>");
 MODULE_LICENSE("GPL");
@@ -161,7 +152,7 @@ static struct pci_driver xircom_ops = {
 };
 
 
-#ifdef DEBUG
+#if defined DEBUG && DEBUG > 1
 static void print_binary(unsigned int number)
 {
 	int i,i2;
@@ -176,7 +167,7 @@ static void print_binary(unsigned int number)
 		if ((i&3)==0)
 			buffer[i2++]=' ';
 	}
-	printk("%s\n",buffer);
+	pr_debug("%s\n",buffer);
 }
 #endif
 
@@ -205,7 +196,6 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 	struct xircom_private *private;
 	unsigned long flags;
 	unsigned short tmp16;
-	enter("xircom_probe");
 
 	/* First do the PCI initialisation */
 
@@ -285,7 +275,6 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 
 	trigger_receive(private);
 
-	leave("xircom_probe");
 	return 0;
 
 reg_fail:
@@ -310,7 +299,6 @@ static void __devexit xircom_remove(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct xircom_private *card = netdev_priv(dev);
 
-	enter("xircom_remove");
 	pci_free_consistent(pdev,8192,card->rx_buffer,card->rx_dma_handle);
 	pci_free_consistent(pdev,8192,card->tx_buffer,card->tx_dma_handle);
 
@@ -318,7 +306,6 @@ static void __devexit xircom_remove(struct pci_dev *pdev)
 	unregister_netdev(dev);
 	free_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
-	leave("xircom_remove");
 }
 
 static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
@@ -328,17 +315,15 @@ static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
 	unsigned int status;
 	int i;
 
-	enter("xircom_interrupt\n");
-
 	spin_lock(&card->lock);
 	status = inl(card->io_port+CSR5);
 
-#ifdef DEBUG
+#if defined DEBUG && DEBUG > 1
 	print_binary(status);
-	printk("tx status 0x%08x 0x%08x\n",
-	       card->tx_buffer[0], card->tx_buffer[4]);
-	printk("rx status 0x%08x 0x%08x\n",
-	       card->rx_buffer[0], card->rx_buffer[4]);
+	pr_debug("tx status 0x%08x 0x%08x\n",
+		 card->tx_buffer[0], card->tx_buffer[4]);
+	pr_debug("rx status 0x%08x 0x%08x\n",
+		 card->rx_buffer[0], card->rx_buffer[4]);
 #endif
 	/* Handle shared irq and hotplug */
 	if (status == 0 || status == 0xffffffff) {
@@ -369,9 +354,7 @@ static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
 	for (i=0;i<NUMDESCRIPTORS;i++)
 		investigate_read_descriptor(dev,card,i,bufferoffsets[i]);
 
-
 	spin_unlock(&card->lock);
-	leave("xircom_interrupt");
 	return IRQ_HANDLED;
 }
 
@@ -382,7 +365,6 @@ static netdev_tx_t xircom_start_xmit(struct sk_buff *skb,
 	unsigned long flags;
 	int nextdescriptor;
 	int desc;
-	enter("xircom_start_xmit");
 
 	card = netdev_priv(dev);
 	spin_lock_irqsave(&card->lock,flags);
@@ -424,13 +406,10 @@ static netdev_tx_t xircom_start_xmit(struct sk_buff *skb,
 				netif_stop_queue(dev);
 			}
 			card->transmit_used = nextdescriptor;
-			leave("xircom-start_xmit - sent");
 			spin_unlock_irqrestore(&card->lock,flags);
 			return NETDEV_TX_OK;
 	}
 
-
-
 	/* Uh oh... no free descriptor... drop the packet */
 	netif_stop_queue(dev);
 	spin_unlock_irqrestore(&card->lock,flags);
@@ -446,18 +425,16 @@ static int xircom_open(struct net_device *dev)
 {
 	struct xircom_private *xp = netdev_priv(dev);
 	int retval;
-	enter("xircom_open");
+
 	pr_info("xircom cardbus adaptor found, registering as %s, using irq %i\n",
 		dev->name, dev->irq);
 	retval = request_irq(dev->irq, xircom_interrupt, IRQF_SHARED, dev->name, dev);
-	if (retval) {
-		leave("xircom_open - No IRQ");
+	if (retval)
 		return retval;
-	}
 
 	xircom_up(xp);
 	xp->open = 1;
-	leave("xircom_open");
+
 	return 0;
 }
 
@@ -466,7 +443,6 @@ static int xircom_close(struct net_device *dev)
 	struct xircom_private *card;
 	unsigned long flags;
 
-	enter("xircom_close");
 	card = netdev_priv(dev);
 	netif_stop_queue(dev); /* we don't want new packets */
 
@@ -486,8 +462,6 @@ static int xircom_close(struct net_device *dev)
 	card->open = 0;
 	free_irq(dev->irq,dev);
 
-	leave("xircom_close");
-
 	return 0;
 
 }
@@ -507,8 +481,6 @@ static void initialize_card(struct xircom_private *card)
 {
 	unsigned int val;
 	unsigned long flags;
-	enter("initialize_card");
-
 
 	spin_lock_irqsave(&card->lock, flags);
 
@@ -534,8 +506,6 @@ static void initialize_card(struct xircom_private *card)
 	deactivate_transmitter(card);
 
 	spin_unlock_irqrestore(&card->lock, flags);
-
-	leave("initialize_card");
 }
 
 /*
@@ -547,12 +517,9 @@ ignored; I chose zero.
 static void trigger_transmit(struct xircom_private *card)
 {
 	unsigned int val;
-	enter("trigger_transmit");
 
 	val = 0;
 	outl(val, card->io_port + CSR1);
-
-	leave("trigger_transmit");
 }
 
 /*
@@ -565,12 +532,9 @@ ignored; I chose zero.
 static void trigger_receive(struct xircom_private *card)
 {
 	unsigned int val;
-	enter("trigger_receive");
 
 	val = 0;
 	outl(val, card->io_port + CSR2);
-
-	leave("trigger_receive");
 }
 
 /*
@@ -581,8 +545,6 @@ static void setup_descriptors(struct xircom_private *card)
 {
 	u32 address;
 	int i;
-	enter("setup_descriptors");
-
 
 	BUG_ON(card->rx_buffer == NULL);
 	BUG_ON(card->tx_buffer == NULL);
@@ -636,8 +598,6 @@ static void setup_descriptors(struct xircom_private *card)
 	/* wite the transmit descriptor ring to the card */
 	address = card->tx_dma_handle;
 	outl(address, card->io_port + CSR4);	/* xmit descr list address */
-
-	leave("setup_descriptors");
 }
 
 /*
@@ -647,13 +607,10 @@ valid by setting the address in the card to 0x00.
 static void remove_descriptors(struct xircom_private *card)
 {
 	unsigned int val;
-	enter("remove_descriptors");
 
 	val = 0;
 	outl(val, card->io_port + CSR3);	/* Receive descriptor address */
 	outl(val, card->io_port + CSR4);	/* Send descriptor address */
-
-	leave("remove_descriptors");
 }
 
 /*
@@ -665,21 +622,17 @@ This function also clears the status-bit.
 static int link_status_changed(struct xircom_private *card)
 {
 	unsigned int val;
-	enter("link_status_changed");
 
 	val = inl(card->io_port + CSR5);	/* Status register */
 
-	if ((val & (1 << 27)) == 0) {	/* no change */
-		leave("link_status_changed - nochange");
+	if ((val & (1 << 27)) == 0)		/* no change */
 		return 0;
-	}
 
 	/* clear the event by writing a 1 to the bit in the
 	   status register. */
 	val = (1 << 27);
 	outl(val, card->io_port + CSR5);
 
-	leave("link_status_changed - changed");
 	return 1;
 }
 
@@ -691,16 +644,12 @@ in a non-stopped state.
 static int transmit_active(struct xircom_private *card)
 {
 	unsigned int val;
-	enter("transmit_active");
 
 	val = inl(card->io_port + CSR5);	/* Status register */
 
-	if ((val & (7 << 20)) == 0) {	/* transmitter disabled */
-		leave("transmit_active - inactive");
+	if ((val & (7 << 20)) == 0)		/* transmitter disabled */
 		return 0;
-	}
 
-	leave("transmit_active - active");
 	return 1;
 }
 
@@ -711,17 +660,12 @@ in a non-stopped state.
 static int receive_active(struct xircom_private *card)
 {
 	unsigned int val;
-	enter("receive_active");
-
 
 	val = inl(card->io_port + CSR5);	/* Status register */
 
-	if ((val & (7 << 17)) == 0) {	/* receiver disabled */
-		leave("receive_active - inactive");
+	if ((val & (7 << 17)) == 0)		/* receiver disabled */
 		return 0;
-	}
 
-	leave("receive_active - active");
 	return 1;
 }
 
@@ -739,8 +683,6 @@ static void activate_receiver(struct xircom_private *card)
 {
 	unsigned int val;
 	int counter;
-	enter("activate_receiver");
-
 
 	val = inl(card->io_port + CSR6);	/* Operation mode */
 
@@ -780,8 +722,6 @@ static void activate_receiver(struct xircom_private *card)
 		if (counter <= 0)
 			pr_err("Receiver failed to re-activate\n");
 	}
-
-	leave("activate_receiver");
 }
 
 /*
@@ -795,7 +735,6 @@ static void deactivate_receiver(struct xircom_private *card)
 {
 	unsigned int val;
 	int counter;
-	enter("deactivate_receiver");
 
 	val = inl(card->io_port + CSR6);	/* Operation mode */
 	val = val & ~2;				/* disable the receiver */
@@ -811,9 +750,6 @@ static void deactivate_receiver(struct xircom_private *card)
 		if (counter <= 0)
 			pr_err("Receiver failed to deactivate\n");
 	}
-
-
-	leave("deactivate_receiver");
 }
 
 
@@ -831,8 +767,6 @@ static void activate_transmitter(struct xircom_private *card)
 {
 	unsigned int val;
 	int counter;
-	enter("activate_transmitter");
-
 
 	val = inl(card->io_port + CSR6);	/* Operation mode */
 
@@ -871,8 +805,6 @@ static void activate_transmitter(struct xircom_private *card)
 		if (counter <= 0)
 			pr_err("Transmitter failed to re-activate\n");
 	}
-
-	leave("activate_transmitter");
 }
 
 /*
@@ -886,7 +818,6 @@ static void deactivate_transmitter(struct xircom_private *card)
 {
 	unsigned int val;
 	int counter;
-	enter("deactivate_transmitter");
 
 	val = inl(card->io_port + CSR6);	/* Operation mode */
 	val = val & ~2;		/* disable the transmitter */
@@ -902,9 +833,6 @@ static void deactivate_transmitter(struct xircom_private *card)
 		if (counter <= 0)
 			pr_err("Transmitter failed to deactivate\n");
 	}
-
-
-	leave("deactivate_transmitter");
 }
 
 
@@ -916,13 +844,10 @@ must be called with the lock held and interrupts disabled.
 static void enable_transmit_interrupt(struct xircom_private *card)
 {
 	unsigned int val;
-	enter("enable_transmit_interrupt");
 
 	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
 	val |= 1;				/* enable the transmit interrupt */
 	outl(val, card->io_port + CSR7);
-
-	leave("enable_transmit_interrupt");
 }
 
 
@@ -934,13 +859,10 @@ must be called with the lock held and interrupts disabled.
 static void enable_receive_interrupt(struct xircom_private *card)
 {
 	unsigned int val;
-	enter("enable_receive_interrupt");
 
 	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
 	val = val | (1 << 6);			/* enable the receive interrupt */
 	outl(val, card->io_port + CSR7);
-
-	leave("enable_receive_interrupt");
 }
 
 /*
@@ -951,13 +873,10 @@ must be called with the lock held and interrupts disabled.
 static void enable_link_interrupt(struct xircom_private *card)
 {
 	unsigned int val;
-	enter("enable_link_interrupt");
 
 	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
 	val = val | (1 << 27);			/* enable the link status chage interrupt */
 	outl(val, card->io_port + CSR7);
-
-	leave("enable_link_interrupt");
 }
 
 
@@ -970,12 +889,9 @@ must be called with the lock held and interrupts disabled.
 static void disable_all_interrupts(struct xircom_private *card)
 {
 	unsigned int val;
-	enter("enable_all_interrupts");
 
 	val = 0;				/* disable all interrupts */
 	outl(val, card->io_port + CSR7);
-
-	leave("disable_all_interrupts");
 }
 
 /*
@@ -986,7 +902,6 @@ must be called with the lock held and interrupts disabled.
 static void enable_common_interrupts(struct xircom_private *card)
 {
 	unsigned int val;
-	enter("enable_link_interrupt");
 
 	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
 	val |= (1<<16); /* Normal Interrupt Summary */
@@ -998,8 +913,6 @@ static void enable_common_interrupts(struct xircom_private *card)
 	val |= (1<<2);  /* Transmit Buffer Unavailable */
 	val |= (1<<1);  /* Transmit Process Stopped */
 	outl(val, card->io_port + CSR7);
-
-	leave("enable_link_interrupt");
 }
 
 /*
@@ -1010,13 +923,11 @@ must be called with the lock held and interrupts disabled.
 static int enable_promisc(struct xircom_private *card)
 {
 	unsigned int val;
-	enter("enable_promisc");
 
 	val = inl(card->io_port + CSR6);
 	val = val | (1 << 6);
 	outl(val, card->io_port + CSR6);
 
-	leave("enable_promisc");
 	return 1;
 }
 
@@ -1031,7 +942,6 @@ Must be called in locked state with interrupts disabled
 static int link_status(struct xircom_private *card)
 {
 	unsigned int val;
-	enter("link_status");
 
 	val = inb(card->io_port + CSR12);
 
@@ -1042,7 +952,6 @@ static int link_status(struct xircom_private *card)
 
 	/* If we get here -> no link at all */
 
-	leave("link_status");
 	return 0;
 }
 
@@ -1061,8 +970,6 @@ static void read_mac_address(struct xircom_private *card)
 	unsigned long flags;
 	int i;
 
-	enter("read_mac_address");
-
 	spin_lock_irqsave(&card->lock, flags);
 
 	outl(1 << 12, card->io_port + CSR9);	/* enable boot rom access */
@@ -1090,7 +997,6 @@ static void read_mac_address(struct xircom_private *card)
 	}
 	spin_unlock_irqrestore(&card->lock, flags);
 	pr_debug(" %pM\n", card->dev->dev_addr);
-	leave("read_mac_address");
 }
 
 
@@ -1103,8 +1009,6 @@ static void transceiver_voodoo(struct xircom_private *card)
 {
 	unsigned long flags;
 
-	enter("transceiver_voodoo");
-
 	/* disable all powermanagement */
 	pci_write_config_dword(card->pdev, PCI_POWERMGMT, 0x0000);
 
@@ -1122,7 +1026,6 @@ static void transceiver_voodoo(struct xircom_private *card)
         spin_unlock_irqrestore(&card->lock, flags);
 
 	netif_start_queue(card->dev);
-	leave("transceiver_voodoo");
 }
 
 
@@ -1131,8 +1034,6 @@ static void xircom_up(struct xircom_private *card)
 	unsigned long flags;
 	int i;
 
-	enter("xircom_up");
-
 	/* disable all powermanagement */
 	pci_write_config_dword(card->pdev, PCI_POWERMGMT, 0x0000);
 
@@ -1156,7 +1057,6 @@ static void xircom_up(struct xircom_private *card)
 	trigger_receive(card);
 	trigger_transmit(card);
 	netif_start_queue(card->dev);
-	leave("xircom_up");
 }
 
 /* Bufferoffset is in BYTES */
@@ -1164,7 +1064,6 @@ static void investigate_read_descriptor(struct net_device *dev,struct xircom_pri
 {
 		int status;
 
-		enter("investigate_read_descriptor");
 		status = le32_to_cpu(card->rx_buffer[4*descnr]);
 
 		if ((status > 0)) {	/* packet received */
@@ -1197,9 +1096,6 @@ static void investigate_read_descriptor(struct net_device *dev,struct xircom_pri
 			card->rx_buffer[4*descnr] =  cpu_to_le32(0x80000000);
 			trigger_receive(card);
 		}
-
-		leave("investigate_read_descriptor");
-
 }
 
 
@@ -1208,8 +1104,6 @@ static void investigate_write_descriptor(struct net_device *dev, struct xircom_p
 {
 		int status;
 
-		enter("investigate_write_descriptor");
-
 		status = le32_to_cpu(card->tx_buffer[4*descnr]);
 #if 0
 		if (status & 0x8000) {	/* Major error */
@@ -1232,8 +1126,6 @@ static void investigate_write_descriptor(struct net_device *dev, struct xircom_p
 			dev->stats.tx_packets++;
 		}
 
-		leave("investigate_write_descriptor");
-
 }
 
 
-- 
1.7.5.rc3.dirty
