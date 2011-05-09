From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 5/4] tulip: xircom_cb: Remove useless func_enter
 and func_exit
Date: Mon, 09 May 2011 12:08:01 -0700
Message-ID: <1304968081.19586.66.camel@Joe-Laptop>
References: <cover.1304733889.git.joe@perches.com>
	 <20110509.114706.189685729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110509.114706.189685729.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-05-09 at 11:47 -0700, David Miller wrote:
> With the advent of the function tracer, those silly function entry/exit
> logging things are entirely superfluous.
> They make the code look ugly too.

I don't much like a lot of debugging messages
throughout drivers/net, but that's a whole 'nother
set of patches.

> Please do that and respin this patch set, thanks Joe!

How 'bout I just add another patch to delete them.

Signed-off-by: Joe Perches <joe@perches.com>

---

 drivers/net/tulip/xircom_cb.c |  119 ++---------------------------------------
 1 files changed, 5 insertions(+), 114 deletions(-)

diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 71d4304..2f77daa 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -37,15 +37,6 @@
 #include <asm/irq.h>
 #endif
 
-#if defined DEBUG && DEBUG > 1
-#define func_enter(x)	pr_debug("Enter: %s\n", __func__)
-#define func_exit(x)	pr_debug("Exit: %s\n", __func__)
-#else
-#define func_enter(x)	no_printk(KERN_DEBUG "Enter: %s\n", __func__)
-#define func_exit(x)	no_printk(KERN_DEBUG "Exit: %s\n", __func__)
-#endif
-
-
 MODULE_DESCRIPTION("Xircom Cardbus ethernet driver");
 MODULE_AUTHOR("Arjan van de Ven <arjanv@redhat.com>");
 MODULE_LICENSE("GPL");
@@ -205,7 +196,6 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 	struct xircom_private *private;
 	unsigned long flags;
 	unsigned short tmp16;
-	func_enter();
 
 	/* First do the PCI initialisation */
 
@@ -285,7 +275,6 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 
 	trigger_receive(private);
 
-	func_exit();
 	return 0;
 
 reg_fail:
@@ -310,7 +299,6 @@ static void __devexit xircom_remove(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct xircom_private *card = netdev_priv(dev);
 
-	func_enter();
 	pci_free_consistent(pdev,8192,card->rx_buffer,card->rx_dma_handle);
 	pci_free_consistent(pdev,8192,card->tx_buffer,card->tx_dma_handle);
 
@@ -318,7 +306,6 @@ static void __devexit xircom_remove(struct pci_dev *pdev)
 	unregister_netdev(dev);
 	free_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
-	func_exit();
 }
 
 static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
@@ -328,8 +315,6 @@ static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
 	unsigned int status;
 	int i;
 
-	func_enter();
-
 	spin_lock(&card->lock);
 	status = inl(card->io_port+CSR5);
 
@@ -369,9 +354,7 @@ static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
 	for (i=0;i<NUMDESCRIPTORS;i++)
 		investigate_read_descriptor(dev,card,i,bufferoffsets[i]);
 
-
 	spin_unlock(&card->lock);
-	func_exit();
 	return IRQ_HANDLED;
 }
 
@@ -382,7 +365,6 @@ static netdev_tx_t xircom_start_xmit(struct sk_buff *skb,
 	unsigned long flags;
 	int nextdescriptor;
 	int desc;
-	func_enter();
 
 	card = netdev_priv(dev);
 	spin_lock_irqsave(&card->lock,flags);
@@ -424,13 +406,10 @@ static netdev_tx_t xircom_start_xmit(struct sk_buff *skb,
 				netif_stop_queue(dev);
 			}
 			card->transmit_used = nextdescriptor;
-			func_exit();
 			spin_unlock_irqrestore(&card->lock,flags);
 			return NETDEV_TX_OK;
 	}
 
-
-
 	/* Uh oh... no free descriptor... drop the packet */
 	netif_stop_queue(dev);
 	spin_unlock_irqrestore(&card->lock,flags);
@@ -446,18 +425,15 @@ static int xircom_open(struct net_device *dev)
 {
 	struct xircom_private *xp = netdev_priv(dev);
 	int retval;
-	func_enter();
+
 	netdev_info(dev, "xircom cardbus adaptor found, using irq %i\n",
 		    dev->irq);
 	retval = request_irq(dev->irq, xircom_interrupt, IRQF_SHARED, dev->name, dev);
-	if (retval) {
-		func_exit();
+	if (retval)
 		return retval;
-	}
 
 	xircom_up(xp);
 	xp->open = 1;
-	func_exit();
 	return 0;
 }
 
@@ -466,7 +442,6 @@ static int xircom_close(struct net_device *dev)
 	struct xircom_private *card;
 	unsigned long flags;
 
-	func_enter();
 	card = netdev_priv(dev);
 	netif_stop_queue(dev); /* we don't want new packets */
 
@@ -486,8 +461,6 @@ static int xircom_close(struct net_device *dev)
 	card->open = 0;
 	free_irq(dev->irq,dev);
 
-	func_exit();
-
 	return 0;
 
 }
@@ -507,8 +480,6 @@ static void initialize_card(struct xircom_private *card)
 {
 	unsigned int val;
 	unsigned long flags;
-	func_enter();
-
 
 	spin_lock_irqsave(&card->lock, flags);
 
@@ -534,8 +505,6 @@ static void initialize_card(struct xircom_private *card)
 	deactivate_transmitter(card);
 
 	spin_unlock_irqrestore(&card->lock, flags);
-
-	func_exit();
 }
 
 /*
@@ -547,12 +516,9 @@ ignored; I chose zero.
 static void trigger_transmit(struct xircom_private *card)
 {
 	unsigned int val;
-	func_enter();
 
 	val = 0;
 	outl(val, card->io_port + CSR1);
-
-	func_exit();
 }
 
 /*
@@ -565,12 +531,9 @@ ignored; I chose zero.
 static void trigger_receive(struct xircom_private *card)
 {
 	unsigned int val;
-	func_enter();
 
 	val = 0;
 	outl(val, card->io_port + CSR2);
-
-	func_exit();
 }
 
 /*
@@ -581,8 +544,6 @@ static void setup_descriptors(struct xircom_private *card)
 {
 	u32 address;
 	int i;
-	func_enter();
-
 
 	BUG_ON(card->rx_buffer == NULL);
 	BUG_ON(card->tx_buffer == NULL);
@@ -636,8 +597,6 @@ static void setup_descriptors(struct xircom_private *card)
 	/* wite the transmit descriptor ring to the card */
 	address = card->tx_dma_handle;
 	outl(address, card->io_port + CSR4);	/* xmit descr list address */
-
-	func_exit();
 }
 
 /*
@@ -647,13 +606,10 @@ valid by setting the address in the card to 0x00.
 static void remove_descriptors(struct xircom_private *card)
 {
 	unsigned int val;
-	func_enter();
 
 	val = 0;
 	outl(val, card->io_port + CSR3);	/* Receive descriptor address */
 	outl(val, card->io_port + CSR4);	/* Send descriptor address */
-
-	func_exit();
 }
 
 /*
@@ -665,21 +621,17 @@ This function also clears the status-bit.
 static int link_status_changed(struct xircom_private *card)
 {
 	unsigned int val;
-	func_enter();
 
 	val = inl(card->io_port + CSR5);	/* Status register */
 
-	if ((val & (1 << 27)) == 0) {	/* no change */
-		func_exit();
+	if ((val & (1 << 27)) == 0)		/* no change */
 		return 0;
-	}
 
 	/* clear the event by writing a 1 to the bit in the
 	   status register. */
 	val = (1 << 27);
 	outl(val, card->io_port + CSR5);
 
-	func_exit();
 	return 1;
 }
 
@@ -691,16 +643,12 @@ in a non-stopped state.
 static int transmit_active(struct xircom_private *card)
 {
 	unsigned int val;
-	func_enter();
 
 	val = inl(card->io_port + CSR5);	/* Status register */
 
-	if ((val & (7 << 20)) == 0) {	/* transmitter disabled */
-		func_exit();
+	if ((val & (7 << 20)) == 0)		/* transmitter disabled */
 		return 0;
-	}
 
-	func_exit();
 	return 1;
 }
 
@@ -711,17 +659,12 @@ in a non-stopped state.
 static int receive_active(struct xircom_private *card)
 {
 	unsigned int val;
-	func_enter();
-
 
 	val = inl(card->io_port + CSR5);	/* Status register */
 
-	if ((val & (7 << 17)) == 0) {	/* receiver disabled */
-		func_exit();
+	if ((val & (7 << 17)) == 0)		/* receiver disabled */
 		return 0;
-	}
 
-	func_exit();
 	return 1;
 }
 
@@ -739,8 +682,6 @@ static void activate_receiver(struct xircom_private *card)
 {
 	unsigned int val;
 	int counter;
-	func_enter();
-
 
 	val = inl(card->io_port + CSR6);	/* Operation mode */
 
@@ -781,8 +722,6 @@ static void activate_receiver(struct xircom_private *card)
 			netdev_err(card->dev,
 				   "Receiver failed to re-activate\n");
 	}
-
-	func_exit();
 }
 
 /*
@@ -796,7 +735,6 @@ static void deactivate_receiver(struct xircom_private *card)
 {
 	unsigned int val;
 	int counter;
-	func_enter();
 
 	val = inl(card->io_port + CSR6);	/* Operation mode */
 	val = val & ~2;				/* disable the receiver */
@@ -812,9 +750,6 @@ static void deactivate_receiver(struct xircom_private *card)
 		if (counter <= 0)
 			netdev_err(card->dev, "Receiver failed to deactivate\n");
 	}
-
-
-	func_exit();
 }
 
 
@@ -832,8 +767,6 @@ static void activate_transmitter(struct xircom_private *card)
 {
 	unsigned int val;
 	int counter;
-	func_enter();
-
 
 	val = inl(card->io_port + CSR6);	/* Operation mode */
 
@@ -874,8 +807,6 @@ static void activate_transmitter(struct xircom_private *card)
 			netdev_err(card->dev,
 				   "Transmitter failed to re-activate\n");
 	}
-
-	func_exit();
 }
 
 /*
@@ -889,7 +820,6 @@ static void deactivate_transmitter(struct xircom_private *card)
 {
 	unsigned int val;
 	int counter;
-	func_enter();
 
 	val = inl(card->io_port + CSR6);	/* Operation mode */
 	val = val & ~2;		/* disable the transmitter */
@@ -906,9 +836,6 @@ static void deactivate_transmitter(struct xircom_private *card)
 			netdev_err(card->dev,
 				   "Transmitter failed to deactivate\n");
 	}
-
-
-	func_exit();
 }
 
 
@@ -920,13 +847,10 @@ must be called with the lock held and interrupts disabled.
 static void enable_transmit_interrupt(struct xircom_private *card)
 {
 	unsigned int val;
-	func_enter();
 
 	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
 	val |= 1;				/* enable the transmit interrupt */
 	outl(val, card->io_port + CSR7);
-
-	func_exit();
 }
 
 
@@ -938,13 +862,10 @@ must be called with the lock held and interrupts disabled.
 static void enable_receive_interrupt(struct xircom_private *card)
 {
 	unsigned int val;
-	func_enter();
 
 	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
 	val = val | (1 << 6);			/* enable the receive interrupt */
 	outl(val, card->io_port + CSR7);
-
-	func_exit();
 }
 
 /*
@@ -955,13 +876,10 @@ must be called with the lock held and interrupts disabled.
 static void enable_link_interrupt(struct xircom_private *card)
 {
 	unsigned int val;
-	func_enter();
 
 	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
 	val = val | (1 << 27);			/* enable the link status chage interrupt */
 	outl(val, card->io_port + CSR7);
-
-	func_exit();
 }
 
 
@@ -974,12 +892,9 @@ must be called with the lock held and interrupts disabled.
 static void disable_all_interrupts(struct xircom_private *card)
 {
 	unsigned int val;
-	func_enter();
 
 	val = 0;				/* disable all interrupts */
 	outl(val, card->io_port + CSR7);
-
-	func_exit();
 }
 
 /*
@@ -990,7 +905,6 @@ must be called with the lock held and interrupts disabled.
 static void enable_common_interrupts(struct xircom_private *card)
 {
 	unsigned int val;
-	func_enter();
 
 	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
 	val |= (1<<16); /* Normal Interrupt Summary */
@@ -1002,8 +916,6 @@ static void enable_common_interrupts(struct xircom_private *card)
 	val |= (1<<2);  /* Transmit Buffer Unavailable */
 	val |= (1<<1);  /* Transmit Process Stopped */
 	outl(val, card->io_port + CSR7);
-
-	func_exit();
 }
 
 /*
@@ -1014,13 +926,11 @@ must be called with the lock held and interrupts disabled.
 static int enable_promisc(struct xircom_private *card)
 {
 	unsigned int val;
-	func_enter();
 
 	val = inl(card->io_port + CSR6);
 	val = val | (1 << 6);
 	outl(val, card->io_port + CSR6);
 
-	func_exit();
 	return 1;
 }
 
@@ -1035,7 +945,6 @@ Must be called in locked state with interrupts disabled
 static int link_status(struct xircom_private *card)
 {
 	unsigned int val;
-	func_enter();
 
 	val = inb(card->io_port + CSR12);
 
@@ -1046,7 +955,6 @@ static int link_status(struct xircom_private *card)
 
 	/* If we get here -> no link at all */
 
-	func_exit();
 	return 0;
 }
 
@@ -1065,8 +973,6 @@ static void read_mac_address(struct xircom_private *card)
 	unsigned long flags;
 	int i;
 
-	func_enter();
-
 	spin_lock_irqsave(&card->lock, flags);
 
 	outl(1 << 12, card->io_port + CSR9);	/* enable boot rom access */
@@ -1094,7 +1000,6 @@ static void read_mac_address(struct xircom_private *card)
 	}
 	spin_unlock_irqrestore(&card->lock, flags);
 	pr_debug(" %pM\n", card->dev->dev_addr);
-	func_exit();
 }
 
 
@@ -1107,8 +1012,6 @@ static void transceiver_voodoo(struct xircom_private *card)
 {
 	unsigned long flags;
 
-	func_enter();
-
 	/* disable all powermanagement */
 	pci_write_config_dword(card->pdev, PCI_POWERMGMT, 0x0000);
 
@@ -1126,7 +1029,6 @@ static void transceiver_voodoo(struct xircom_private *card)
         spin_unlock_irqrestore(&card->lock, flags);
 
 	netif_start_queue(card->dev);
-	func_exit();
 }
 
 
@@ -1135,8 +1037,6 @@ static void xircom_up(struct xircom_private *card)
 	unsigned long flags;
 	int i;
 
-	func_enter();
-
 	/* disable all powermanagement */
 	pci_write_config_dword(card->pdev, PCI_POWERMGMT, 0x0000);
 
@@ -1160,7 +1060,6 @@ static void xircom_up(struct xircom_private *card)
 	trigger_receive(card);
 	trigger_transmit(card);
 	netif_start_queue(card->dev);
-	func_exit();
 }
 
 /* Bufferoffset is in BYTES */
@@ -1170,8 +1069,6 @@ investigate_read_descriptor(struct net_device *dev, struct xircom_private *card,
 {
 	int status;
 
-	func_enter();
-
 	status = le32_to_cpu(card->rx_buffer[4*descnr]);
 	if (status > 0) {		/* packet received */
 
@@ -1206,8 +1103,6 @@ out:
 		card->rx_buffer[4*descnr] =  cpu_to_le32(0x80000000);
 		trigger_receive(card);
 	}
-
-	func_exit();
 }
 
 
@@ -1219,8 +1114,6 @@ investigate_write_descriptor(struct net_device *dev,
 {
 	int status;
 
-	func_enter();
-
 	status = le32_to_cpu(card->tx_buffer[4*descnr]);
 #if 0
 	if (status & 0x8000) {	/* Major error */
@@ -1242,8 +1135,6 @@ investigate_write_descriptor(struct net_device *dev,
 		netif_wake_queue(dev);
 		dev->stats.tx_packets++;
 	}
-
-	func_exit();
 }
 
 
