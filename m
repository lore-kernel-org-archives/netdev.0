From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH] fix for olympic cable pull induced hang
Date: Fri, 17 Oct 2003 15:54:27 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310172254.h9HMsRS10951@DYN318364.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mike_Phillips@URSCorp.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A system hang occurs when the cable is pulled with the olympic driver.
This was reported against 2.4.19 and this patch is against 2.6.0-test7.
I have tested this against 2.4.20, 2.5.67, and 2.6.0-test7.

The hang occurred when free_irq was done during interrupt handling of the
adapter.  I removed those calls, and modified the driver so that it can be
brought back into operation without having to rmmod or reboot (if compiled
into the kernel).

The only anomaly I have seen is that if the olympic card is the only card
on the ring and the cable is pulled, it takes two cycles of ifdown tr0,
ifup tr0 to become operational again.  After the first down/up the card
immediately reports another 'Short circuit detected...' and a second down/up
is needed.

If other cards are on the ring then just one down/up will work.  After that
when the active monitor is removed from the ring another down/up cycle is
required.


--- linux-2.6.0-test7/drivers/net/tokenring/olympic.h	Wed Oct  8 12:24:51 2003
+++ linux-2.6.0-test7p/drivers/net/tokenring/olympic.h	Fri Oct 17 13:56:59 2003
@@ -286,6 +286,9 @@
 	u32 rx_status_ring_dma_addr;
 	u32 tx_ring_dma_addr;
 	u32 tx_status_ring_dma_addr;
+
+	u16 init_srb; /* be16 */
+	u16 reset_needed;	/* reset and restart required to correct */
 };
 
 struct olympic_adapter_addr_table {
--- linux-2.6.0-test7/drivers/net/tokenring/olympic.c	Wed Oct  8 12:24:26 2003
+++ linux-2.6.0-test7p/drivers/net/tokenring/olympic.c	Fri Oct 17 14:23:35 2003
@@ -65,6 +65,10 @@
  * 	      went into version 1.0.0 
  * 06/04/02 - Add correct start up sequence for the cardbus adapters.
  * 	      Required for strict compliance with pci power mgmt specs.
+ * 10/17/03 - Removed free_irq calls which could cause a hang, added
+ * 	      netif_carrier_{on|off}, if cable is removed then ifdown & ifup
+ * 	      will bring adapter up, might recover from more errors without
+ * 	      removing module. - <donf@us.ibm.com>
  *  To Do:
  *
  *	     Wake on lan	
@@ -117,7 +121,7 @@
  */
 
 static char version[] __devinitdata = 
-"Olympic.c v1.0.5 6/04/02 - Peter De Schrijver & Mike Phillips" ; 
+"Olympic.c v1.0.6 10/17/03 - Peter De Schrijver & Mike Phillips" ; 
 
 static char *open_maj_error[]  = {"No error", "Lobe Media Test", "Physical Insertion",
 				   "Address Verification", "Neighbor Notification (Ring Poll)",
@@ -179,7 +183,7 @@
 
 
 static int olympic_probe(struct pci_dev *pdev, const struct pci_device_id *ent); 
-static int olympic_init(struct net_device *dev);
+static int olympic_reset(struct net_device *dev);
 static int olympic_open(struct net_device *dev);
 static int olympic_xmit(struct sk_buff *skb, struct net_device *dev);
 static int olympic_close(struct net_device *dev);
@@ -247,7 +251,12 @@
 	olympic_priv->olympic_message_level = message_level[card_no] ; 
 	olympic_priv->olympic_network_monitor = network_monitor[card_no];
 	
-	if ((i = olympic_init(dev))) {
+	spin_lock_init(&olympic_priv->olympic_lock) ; 
+
+	printk("%s \n", version);
+	printk("%s. I/O at %hx, MMIO at %p, LAP at %p, using irq %d\n", olympic_priv->olympic_card_name, (unsigned int) dev->base_addr,olympic_priv->olympic_mmio, olympic_priv->olympic_lap, dev->irq);
+
+	if ((i = olympic_reset(dev))) {
 		goto op_free_iomap;
 	}				
 
@@ -288,7 +297,7 @@
 	return i;
 }
 
-static int __devinit olympic_init(struct net_device *dev)
+static int olympic_reset(struct net_device *dev)
 {
     	struct olympic_private *olympic_priv;
 	u8 *olympic_mmio, *init_srb,*adapter_addr;
@@ -298,9 +307,6 @@
     	olympic_priv=(struct olympic_private *)dev->priv;
 	olympic_mmio=olympic_priv->olympic_mmio;
 
-	printk("%s \n", version);
-	printk("%s. I/O at %hx, MMIO at %p, LAP at %p, using irq %d\n", olympic_priv->olympic_card_name, (unsigned int) dev->base_addr,olympic_priv->olympic_mmio, olympic_priv->olympic_lap, dev->irq);
-
 	writel(readl(olympic_mmio+BCTL) | BCTL_SOFTRESET,olympic_mmio+BCTL);
 	t=jiffies;
 	while((readl(olympic_mmio+BCTL)) & BCTL_SOFTRESET) {
@@ -311,8 +317,6 @@
 		}
 	}
 
-	spin_lock_init(&olympic_priv->olympic_lock) ; 
-
 	/* Needed for cardbus */
 	if(!(readl(olympic_mmio+BCTL) & BCTL_MODE_INDICATOR)) {
 		writel(readl(olympic_priv->olympic_mmio+FERMASK)|FERMASK_INT_BIT, olympic_mmio+FERMASK);
@@ -384,7 +388,8 @@
 	printk("LAPWWO: %x, LAPA: %x\n",readl(olympic_mmio+LAPWWO), readl(olympic_mmio+LAPA));
 #endif
 
-	init_srb=olympic_priv->olympic_lap + ((readw(olympic_mmio+LAPWWO)) & (~0xf800));
+	olympic_priv->init_srb = ((readw(olympic_mmio+LAPWWO)) & (~0xf800));
+	init_srb=olympic_priv->olympic_lap + olympic_priv->init_srb;
 
 #if OLYMPIC_DEBUG		
 {
@@ -442,7 +447,7 @@
 
 	DECLARE_WAITQUEUE(wait,current) ; 
 
-	if(request_irq(dev->irq, &olympic_interrupt, SA_SHIRQ , "olympic", dev)) {
+	if (request_irq(dev->irq, &olympic_interrupt, SA_SHIRQ , dev->name, dev)) {
 		return -EAGAIN;
 	}
 
@@ -451,6 +456,20 @@
 	printk("pending ints: %x\n",readl(olympic_mmio+SISR_RR));
 #endif
 
+	if (olympic_priv->reset_needed) {
+		int i;
+
+		olympic_priv->srb = olympic_priv->init_srb;
+		if ((i = olympic_reset(dev))) {
+			printk(KERN_WARNING "%s: Adapter really broken.\n", dev->name);
+			/* disable all interrupts */
+			writel(0, olympic_mmio+SISR_MASK); 
+			free_irq(dev->irq, dev);
+			return -EIO ; 
+		}
+		olympic_priv->reset_needed = 0;
+	}
+
 	writel(SISR_MI,olympic_mmio+SISR_MASK_SUM);
 
 	writel(SISR_MI | SISR_SRB_REPLY, olympic_mmio+SISR_MASK); /* more ints later, doesn't stop arb cmd interrupt */
@@ -470,7 +489,7 @@
 	do {
 		int i;
 
-		for(i=0;i<SRB_COMMAND_SIZE;i+=4)
+		for(i=0;i<SRB_COMMAND_SIZE-3;i+=4)
 			writel(0,init_srb+i);
 		if(SRB_COMMAND_SIZE & 2)
 			writew(0,init_srb+(SRB_COMMAND_SIZE & ~3));
@@ -546,6 +565,10 @@
 
 		if(readb(init_srb+2)== OLYMPIC_CLEAR_RET_CODE) {
 			printk(KERN_WARNING "%s: Adapter Open time out or error.\n", dev->name) ; 
+			/* disable all interrupts */
+			writel(0, olympic_mmio+SISR_MASK); 
+			free_irq(dev->irq, dev);
+			olympic_priv->reset_needed = 1;
 			return -EIO ; 
 		}	
 
@@ -563,11 +586,15 @@
 					if (!olympic_priv->olympic_ring_speed && ((readb(init_srb+7) & 0x0f) == 0x0d)) { 
 						printk(KERN_WARNING "%s: Tried to autosense ring speed with no monitors present\n",dev->name);
 						printk(KERN_WARNING "%s: Please try again with a specified ring speed \n",dev->name);
+						/* disable all interrupts */
+						writel(0, olympic_mmio+SISR_MASK); 
 						free_irq(dev->irq, dev);
 						return -EIO ;
 					}
 
 					printk(KERN_WARNING "%s: %s\n",dev->name,open_error);
+					/* disable all interrupts */
+					writel(0, olympic_mmio+SISR_MASK); 
 					free_irq(dev->irq,dev) ; 
 					return -EIO ; 
  
@@ -581,10 +608,14 @@
 					olympic_priv->olympic_laa[3],
 					olympic_priv->olympic_laa[4],
 					olympic_priv->olympic_laa[5]) ; 
+				/* disable all interrupts */
+				writel(0, olympic_mmio+SISR_MASK); 
 				free_irq(dev->irq,dev) ; 
 				return -EIO ; 
 			} else {  
 				printk(KERN_WARNING "%s: Bad OPEN response: %x\n", dev->name,init_srb[2]);
+				/* disable all interrupts */
+				writel(0, olympic_mmio+SISR_MASK); 
 				free_irq(dev->irq, dev);
 				return -EIO;
 			} 
@@ -638,6 +669,8 @@
 
 	if (i==0) {
 		printk(KERN_WARNING "%s: Not enough memory to allocate rx buffers. Adapter disabled\n",dev->name);
+		/* disable all interrupts */
+		writel(0, olympic_mmio+SISR_MASK); 
 		free_irq(dev->irq, dev);
 		return -EIO;
 	}
@@ -740,6 +773,7 @@
 	}
 	
 	netif_start_queue(dev);
+	netif_carrier_on(dev);
 	return 0;
 	
 }	
@@ -945,9 +979,8 @@
 	/* Hotswap gives us this on removal */
 	if (sisr == 0xffffffff) { 
 		printk(KERN_WARNING "%s: Hotswap adapter removal.\n",dev->name) ; 
-		olympic_freemem(dev) ; 
-		free_irq(dev->irq, dev) ;
-		dev->stop = NULL ;  
+		netif_stop_queue(dev);
+		netif_carrier_off(dev);
 		spin_unlock(&olympic_priv->olympic_lock) ; 
 		return IRQ_NONE;
 	} 
@@ -958,13 +991,13 @@
 		/* If we ever get this the adapter is seriously dead. Only a reset is going to 
 		 * bring it back to life. We're talking pci bus errors and such like :( */ 
 		if((sisr & SISR_ERR) && (readl(olympic_mmio+EISR) & EISR_MASK_OPTIONS)) {
+			netif_stop_queue(dev);
+			netif_carrier_off(dev);
 			printk(KERN_ERR "Olympic: EISR Error, EISR=%08x\n",readl(olympic_mmio+EISR)) ; 
 			printk(KERN_ERR "The adapter must be reset to clear this condition.\n") ; 
 			printk(KERN_ERR "Please report this error to the driver maintainer and/\n") ; 
 			printk(KERN_ERR "or the linux-tr mailing list.\n") ; 
-			olympic_freemem(dev) ; 
-			free_irq(dev->irq, dev) ;
-			dev->stop = NULL ;  
+			olympic_priv->reset_needed = 1;
 			spin_unlock(&olympic_priv->olympic_lock) ; 
 			return IRQ_HANDLED;
 		} /* SISR_ERR */
@@ -1003,13 +1036,12 @@
 	
 		if (sisr & SISR_ADAPTER_CHECK) {
 			netif_stop_queue(dev);
+			netif_carrier_off(dev);
 			printk(KERN_WARNING "%s: Adapter Check Interrupt Raised, 8 bytes of information follow:\n", dev->name);
 			writel(readl(olympic_mmio+LAPWWC),olympic_mmio+LAPA);
 			adapter_check_area = olympic_priv->olympic_lap + ((readl(olympic_mmio+LAPWWC)) & (~0xf800)) ;
 			printk(KERN_WARNING "%s: Bytes %02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x\n",dev->name, readb(adapter_check_area+0), readb(adapter_check_area+1), readb(adapter_check_area+2), readb(adapter_check_area+3), readb(adapter_check_area+4), readb(adapter_check_area+5), readb(adapter_check_area+6), readb(adapter_check_area+7)) ; 
-			olympic_freemem(dev) ;
-			free_irq(dev->irq, dev) ;
-			dev->stop = NULL ;  
+			olympic_priv->reset_needed = 1;
 			spin_unlock(&olympic_priv->olympic_lock) ; 
 			return IRQ_HANDLED; 
 		} /* SISR_ADAPTER_CHECK */
@@ -1087,7 +1119,20 @@
 	DECLARE_WAITQUEUE(wait,current) ; 
 
 	netif_stop_queue(dev);
+	netif_carrier_off(dev);
 	
+	t = jiffies ; 
+
+	/* if some other command is pending, wait for it */
+	while (olympic_priv->srb_queued) {
+		schedule() ; 
+		if ((jiffies-t) > 10*HZ) { 
+			printk(KERN_WARNING "%s: SRB timed out. May not be fatal. \n",dev->name) ; 
+			olympic_priv->srb_queued=0;
+			break ; 
+		} 
+    	}
+
 	writel(olympic_priv->srb,olympic_mmio+LAPA);
 	srb=olympic_priv->olympic_lap + (olympic_priv->srb & (~0xf800));
 	
@@ -1106,9 +1151,9 @@
 	add_wait_queue(&olympic_priv->srb_wait,&wait) ;
 	set_current_state(TASK_INTERRUPTIBLE) ; 
 
-	while(olympic_priv->srb_queued) {
+	while (olympic_priv->srb_queued) {
 		schedule() ; 
-        	if(signal_pending(current))	{            
+        	if (signal_pending(current)) {            
 			printk(KERN_WARNING "%s: SRB timed out.\n",dev->name);
             		printk(KERN_WARNING "SISR=%x MISR=%x\n",readl(olympic_mmio+SISR),readl(olympic_mmio+LISR));
             		olympic_priv->srb_queued=0;
@@ -1129,6 +1174,9 @@
 
 	olympic_freemem(dev) ; 	
 
+	/* disable all interrupts */
+	writel(0, olympic_mmio+SISR_MASK);
+
 	/* reset tx/rx fifo's and busmaster logic */
 
 	writel(readl(olympic_mmio+BCTL)|(3<<13),olympic_mmio+BCTL);
@@ -1506,37 +1554,24 @@
 					printk(KERN_WARNING "%s: Force remove MAC frame received\n",dev->name);
 		
 			/* Adapter has been closed by the hardware */
+			netif_stop_queue(dev);
+			netif_carrier_off(dev);
 		
 			/* reset tx/rx fifo's and busmaster logic */
 
 			writel(readl(olympic_mmio+BCTL)|(3<<13),olympic_mmio+BCTL);
 			udelay(1);
 			writel(readl(olympic_mmio+BCTL)&~(3<<13),olympic_mmio+BCTL);
-			netif_stop_queue(dev);
-			olympic_priv->srb = readw(olympic_priv->olympic_lap + LAPWWO) ; 
-			for(i=0;i<OLYMPIC_RX_RING_SIZE;i++) {
-				dev_kfree_skb_irq(olympic_priv->rx_ring_skb[olympic_priv->rx_status_last_received]);
-				if (olympic_priv->olympic_rx_ring[olympic_priv->rx_status_last_received].buffer != 0xdeadbeef) {
-					pci_unmap_single(olympic_priv->pdev, 
-						le32_to_cpu(olympic_priv->olympic_rx_ring[olympic_priv->rx_status_last_received].buffer),
-						olympic_priv->pkt_buf_sz, PCI_DMA_FROMDEVICE);
-				}
-				olympic_priv->rx_status_last_received++;
-				olympic_priv->rx_status_last_received&=OLYMPIC_RX_RING_SIZE-1;
-			}
-			/* unmap rings */
-			pci_unmap_single(olympic_priv->pdev, olympic_priv->rx_status_ring_dma_addr, 
-				sizeof(struct olympic_rx_status) * OLYMPIC_RX_RING_SIZE, PCI_DMA_FROMDEVICE);
-			pci_unmap_single(olympic_priv->pdev, olympic_priv->rx_ring_dma_addr,
-				sizeof(struct olympic_rx_desc) * OLYMPIC_RX_RING_SIZE, PCI_DMA_TODEVICE);
-
-			pci_unmap_single(olympic_priv->pdev, olympic_priv->tx_status_ring_dma_addr, 
-				sizeof(struct olympic_tx_status) * OLYMPIC_TX_RING_SIZE, PCI_DMA_FROMDEVICE);
-			pci_unmap_single(olympic_priv->pdev, olympic_priv->tx_ring_dma_addr, 
-				sizeof(struct olympic_tx_desc) * OLYMPIC_TX_RING_SIZE, PCI_DMA_TODEVICE);
+			i = 0;
+			/* after a hardware close the LAPWWO takes time to settle */
+			do {
+				olympic_priv->srb = readw(olympic_mmio+LAPWWO) ; 
+				if (olympic_priv->srb == olympic_priv->init_srb)
+					break;
+				udelay(2);
+			} while ((i++) < 50);
+			olympic_priv->reset_needed = 1;
 
-			free_irq(dev->irq,dev);
-			dev->stop=NULL;
 			printk(KERN_WARNING "%s: Adapter has been closed \n", dev->name) ; 
 		} /* If serious error */
 		
@@ -1791,6 +1826,7 @@
 	pci_release_regions(pdev) ;
 	pci_set_drvdata(pdev,NULL) ;  	
 	free_netdev(dev) ; 
+	pci_disable_device(pdev);
 }
 
 static struct pci_driver olympic_driver = { 
-- 
Don Fry
brazilnut@us.ibm.com
