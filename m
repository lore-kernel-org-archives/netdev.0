From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 1/3] 3c50x: convert printk() to pr_<foo>()
Date: Wed, 27 May 2009 02:35:25 +0400
Message-ID: <1243377327-8313-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f168.google.com ([209.85.220.168]:50543 "EHLO
	mail-fx0-f168.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755902AbZEZWfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 18:35:46 -0400
Received: by fxm12 with SMTP id 12so2419345fxm.37
        for <netdev@vger.kernel.org>; Tue, 26 May 2009 15:35:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/3c501.c |   65 +++++++---------
 drivers/net/3c503.c |   36 +++++----
 drivers/net/3c505.c |  215 ++++++++++++++++++++++++++-------------------------
 drivers/net/3c507.c |   55 ++++++-------
 drivers/net/3c509.c |   64 ++++++++--------
 5 files changed, 216 insertions(+), 219 deletions(-)

diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 1c5344a..367bec6 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -281,7 +281,7 @@ static int __init el1_probe1(struct net_device *dev, int ioaddr)
 		autoirq = probe_irq_off(irq_mask);
 
 		if (autoirq == 0) {
-			printk(KERN_WARNING "%s probe at %#x failed to detect IRQ line.\n",
+			pr_warning("%s probe at %#x failed to detect IRQ line.\n",
 				mname, ioaddr);
 			release_region(ioaddr, EL1_IO_EXTENT);
 			return -EAGAIN;
@@ -297,16 +297,16 @@ static int __init el1_probe1(struct net_device *dev, int ioaddr)
 	if (autoirq)
 		dev->irq = autoirq;
 
-	printk(KERN_INFO "%s: %s EtherLink at %#lx, using %sIRQ %d.\n",
+	pr_info("%s: %s EtherLink at %#lx, using %sIRQ %d.\n",
 			dev->name, mname, dev->base_addr,
 			autoirq ? "auto":"assigned ", dev->irq);
 
 #ifdef CONFIG_IP_MULTICAST
-	printk(KERN_WARNING "WARNING: Use of the 3c501 in a multicast kernel is NOT recommended.\n");
+	pr_warning("WARNING: Use of the 3c501 in a multicast kernel is NOT recommended.\n");
 #endif
 
 	if (el_debug)
-		printk(KERN_DEBUG "%s", version);
+		pr_debug("%s", version);
 
 	lp = netdev_priv(dev);
 	memset(lp, 0, sizeof(struct net_local));
@@ -343,7 +343,7 @@ static int el_open(struct net_device *dev)
 	unsigned long flags;
 
 	if (el_debug > 2)
-		printk(KERN_DEBUG "%s: Doing el_open()...", dev->name);
+		pr_debug("%s: Doing el_open()...\n", dev->name);
 
 	retval = request_irq(dev->irq, &el_interrupt, 0, dev->name, dev);
 	if (retval)
@@ -374,7 +374,7 @@ static void el_timeout(struct net_device *dev)
 	int ioaddr = dev->base_addr;
 
 	if (el_debug)
-		printk(KERN_DEBUG "%s: transmit timed out, txsr %#2x axsr=%02x rxsr=%02x.\n",
+		pr_debug("%s: transmit timed out, txsr %#2x axsr=%02x rxsr=%02x.\n",
 			dev->name, inb(TX_STATUS),
 			inb(AX_STATUS), inb(RX_STATUS));
 	dev->stats.tx_errors++;
@@ -483,14 +483,13 @@ static int el_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			lp->loading = 0;
 			dev->trans_start = jiffies;
 			if (el_debug > 2)
-				printk(KERN_DEBUG " queued xmit.\n");
+				pr_debug(" queued xmit.\n");
 			dev_kfree_skb(skb);
 			return 0;
 		}
 		/* A receive upset our load, despite our best efforts */
 		if (el_debug > 2)
-			printk(KERN_DEBUG "%s: burped during tx load.\n",
-				dev->name);
+			pr_debug("%s: burped during tx load.\n", dev->name);
 		spin_lock_irqsave(&lp->lock, flags);
 	} while (1);
 }
@@ -540,11 +539,10 @@ static irqreturn_t el_interrupt(int irq, void *dev_id)
 	 */
 
 	if (el_debug > 3)
-		printk(KERN_DEBUG "%s: el_interrupt() aux=%#02x",
-							dev->name, axsr);
+		pr_debug("%s: el_interrupt() aux=%#02x\n", dev->name, axsr);
 
 	if (lp->loading == 1 && !lp->txing)
-		printk(KERN_WARNING "%s: Inconsistent state loading while not in tx\n",
+		pr_warning("%s: Inconsistent state loading while not in tx\n",
 			dev->name);
 
 	if (lp->txing) {
@@ -555,19 +553,17 @@ static irqreturn_t el_interrupt(int irq, void *dev_id)
 		int txsr = inb(TX_STATUS);
 
 		if (lp->loading == 1) {
-			if (el_debug > 2) {
-				printk(KERN_DEBUG "%s: Interrupt while loading [",
-					dev->name);
-				printk(" txsr=%02x gp=%04x rp=%04x]\n",
-					txsr, inw(GP_LOW), inw(RX_LOW));
-			}
+			if (el_debug > 2)
+				pr_debug("%s: Interrupt while loading [txsr=%02x gp=%04x rp=%04x]\n",
+					dev->name, txsr, inw(GP_LOW), inw(RX_LOW));
+
 			/* Force a reload */
 			lp->loading = 2;
 			spin_unlock(&lp->lock);
 			goto out;
 		}
 		if (el_debug > 6)
-			printk(KERN_DEBUG " txsr=%02x gp=%04x rp=%04x",
+			pr_debug("%s: txsr=%02x gp=%04x rp=%04x\n", dev->name,
 					txsr, inw(GP_LOW), inw(RX_LOW));
 
 		if ((axsr & 0x80) && (txsr & TX_READY) == 0) {
@@ -576,7 +572,7 @@ static irqreturn_t el_interrupt(int irq, void *dev_id)
 			 *	on trying or reset immediately ?
 			 */
 			if (el_debug > 1)
-				printk(KERN_DEBUG "%s: Unusual interrupt during Tx, txsr=%02x axsr=%02x gp=%03x rp=%03x.\n",
+				pr_debug("%s: Unusual interrupt during Tx, txsr=%02x axsr=%02x gp=%03x rp=%03x.\n",
 					dev->name, txsr, axsr,
 					inw(ioaddr + EL1_DATAPTR),
 					inw(ioaddr + EL1_RXPTR));
@@ -587,7 +583,7 @@ static irqreturn_t el_interrupt(int irq, void *dev_id)
 			 *	Timed out
 			 */
 			if (el_debug)
-				printk(KERN_DEBUG "%s: Transmit failed 16 times, Ethernet jammed?\n", dev->name);
+				pr_debug("%s: Transmit failed 16 times, Ethernet jammed?\n", dev->name);
 			outb(AX_SYS, AX_CMD);
 			lp->txing = 0;
 			dev->stats.tx_aborted_errors++;
@@ -598,7 +594,7 @@ static irqreturn_t el_interrupt(int irq, void *dev_id)
 			 */
 
 			if (el_debug > 6)
-				printk(KERN_DEBUG " retransmitting after a collision.\n");
+				pr_debug("%s: retransmitting after a collision.\n", dev->name);
 			/*
 			 *	Poor little chip can't reset its own start
 			 *	pointer
@@ -616,9 +612,8 @@ static irqreturn_t el_interrupt(int irq, void *dev_id)
 			 */
 			dev->stats.tx_packets++;
 			if (el_debug > 6)
-				printk(KERN_DEBUG " Tx succeeded %s\n",
-					(txsr & TX_RDY) ? "." :
-							"but tx is busy!");
+				pr_debug("%s: Tx succeeded %s\n", dev->name,
+					(txsr & TX_RDY) ? "." : "but tx is busy!");
 			/*
 			 *	This is safe the interrupt is atomic WRT itself.
 			 */
@@ -633,7 +628,8 @@ static irqreturn_t el_interrupt(int irq, void *dev_id)
 
 		int rxsr = inb(RX_STATUS);
 		if (el_debug > 5)
-			printk(KERN_DEBUG " rxsr=%02x txsr=%02x rp=%04x", rxsr, inb(TX_STATUS), inw(RX_LOW));
+			pr_debug("%s: rxsr=%02x txsr=%02x rp=%04x\n",
+				dev->name, rxsr, inb(TX_STATUS), inw(RX_LOW));
 		/*
 		 *	Just reading rx_status fixes most errors.
 		 */
@@ -643,7 +639,7 @@ static irqreturn_t el_interrupt(int irq, void *dev_id)
 			/* Handled to avoid board lock-up. */
 			dev->stats.rx_length_errors++;
 			if (el_debug > 5)
-				printk(KERN_DEBUG " runt.\n");
+				pr_debug("%s: runt.\n", dev->name);
 		} else if (rxsr & RX_GOOD) {
 			/*
 			 *	Receive worked.
@@ -654,12 +650,10 @@ static irqreturn_t el_interrupt(int irq, void *dev_id)
 			 *	Nothing?  Something is broken!
 			 */
 			if (el_debug > 2)
-				printk(KERN_DEBUG "%s: No packet seen, rxsr=%02x **resetting 3c501***\n",
+				pr_debug("%s: No packet seen, rxsr=%02x **resetting 3c501***\n",
 					dev->name, rxsr);
 			el_reset(dev);
 		}
-		if (el_debug > 3)
-			printk(KERN_DEBUG ".\n");
 	}
 
 	/*
@@ -695,11 +689,11 @@ static void el_receive(struct net_device *dev)
 	pkt_len = inw(RX_LOW);
 
 	if (el_debug > 4)
-		printk(KERN_DEBUG " el_receive %d.\n", pkt_len);
+		pr_debug(" el_receive %d.\n", pkt_len);
 
 	if (pkt_len < 60 || pkt_len > 1536) {
 		if (el_debug)
-			printk(KERN_DEBUG "%s: bogus packet, length=%d\n",
+			pr_debug("%s: bogus packet, length=%d\n",
 						dev->name, pkt_len);
 		dev->stats.rx_over_errors++;
 		return;
@@ -718,8 +712,7 @@ static void el_receive(struct net_device *dev)
 
 	outw(0x00, GP_LOW);
 	if (skb == NULL) {
-		printk(KERN_INFO "%s: Memory squeeze, dropping packet.\n",
-								dev->name);
+		pr_info("%s: Memory squeeze, dropping packet.\n", dev->name);
 		dev->stats.rx_dropped++;
 		return;
 	} else {
@@ -753,7 +746,7 @@ static void  el_reset(struct net_device *dev)
 	int ioaddr = dev->base_addr;
 
 	if (el_debug > 2)
-		printk(KERN_INFO "3c501 reset...");
+		pr_info("3c501 reset...\n");
 	outb(AX_RESET, AX_CMD);		/* Reset the chip */
 	/* Aux control, irq and loopback enabled */
 	outb(AX_LOOP, AX_CMD);
@@ -787,7 +780,7 @@ static int el1_close(struct net_device *dev)
 	int ioaddr = dev->base_addr;
 
 	if (el_debug > 2)
-		printk(KERN_INFO "%s: Shutting down Ethernet card at %#x.\n",
+		pr_info("%s: Shutting down Ethernet card at %#x.\n",
 						dev->name, ioaddr);
 
 	netif_stop_queue(dev);
diff --git a/drivers/net/3c503.c b/drivers/net/3c503.c
index 4f08bd9..134638a 100644
--- a/drivers/net/3c503.c
+++ b/drivers/net/3c503.c
@@ -234,16 +234,16 @@ el2_probe1(struct net_device *dev, int ioaddr)
     }
 
     if (ei_debug  &&  version_printed++ == 0)
-	printk(version);
+	pr_debug("%s", version);
 
     dev->base_addr = ioaddr;
 
-    printk("%s: 3c503 at i/o base %#3x, node ", dev->name, ioaddr);
+    pr_info("%s: 3c503 at i/o base %#3x, node ", dev->name, ioaddr);
 
     /* Retrieve and print the ethernet address. */
     for (i = 0; i < 6; i++)
 	dev->dev_addr[i] = inb(ioaddr + i);
-    printk("%pM", dev->dev_addr);
+    pr_cont("%pM", dev->dev_addr);
 
     /* Map the 8390 back into the window. */
     outb(ECNTRL_THIN, ioaddr + 0x406);
@@ -256,7 +256,8 @@ el2_probe1(struct net_device *dev, int ioaddr)
     outb_p(E8390_PAGE0, ioaddr + E8390_CMD);
 
     /* Probe for, turn on and clear the board's shared memory. */
-    if (ei_debug > 2) printk(" memory jumpers %2.2x ", membase_reg);
+    if (ei_debug > 2)
+	pr_cont(" memory jumpers %2.2x ", membase_reg);
     outb(EGACFR_NORM, ioaddr + 0x405);	/* Enable RAM */
 
     /* This should be probed for (or set via an ioctl()) at run-time.
@@ -268,7 +269,7 @@ el2_probe1(struct net_device *dev, int ioaddr)
 #else
     ei_status.interface_num = dev->mem_end & 0xf;
 #endif
-    printk(", using %sternal xcvr.\n", ei_status.interface_num == 0 ? "in" : "ex");
+    pr_cont(", using %sternal xcvr.\n", ei_status.interface_num == 0 ? "in" : "ex");
 
     if ((membase_reg & 0xf0) == 0) {
 	dev->mem_start = 0;
@@ -292,7 +293,7 @@ el2_probe1(struct net_device *dev, int ioaddr)
 		writel(test_val, mem_base + i);
 		if (readl(mem_base) != 0xba5eba5e
 		    || readl(mem_base + i) != test_val) {
-		    printk("3c503: memory failure or memory address conflict.\n");
+		    pr_warning("3c503: memory failure or memory address conflict.\n");
 		    dev->mem_start = 0;
 		    ei_status.name = "3c503-PIO";
 		    iounmap(mem_base);
@@ -344,7 +345,7 @@ el2_probe1(struct net_device *dev, int ioaddr)
     if (dev->irq == 2)
 	dev->irq = 9;
     else if (dev->irq > 5 && dev->irq != 9) {
-	printk("3c503: configured interrupt %d invalid, will use autoIRQ.\n",
+	pr_warning("3c503: configured interrupt %d invalid, will use autoIRQ.\n",
 	       dev->irq);
 	dev->irq = 0;
     }
@@ -359,7 +360,7 @@ el2_probe1(struct net_device *dev, int ioaddr)
 	goto out1;
 
     if (dev->mem_start)
-	printk("%s: %s - %dkB RAM, 8kB shared mem window at %#6lx-%#6lx.\n",
+	pr_info("%s: %s - %dkB RAM, 8kB shared mem window at %#6lx-%#6lx.\n",
 		dev->name, ei_status.name, (wordlength+1)<<3,
 		dev->mem_start, dev->mem_end-1);
 
@@ -367,7 +368,7 @@ el2_probe1(struct net_device *dev, int ioaddr)
     {
 	ei_status.tx_start_page = EL2_MB1_START_PG;
 	ei_status.rx_start_page = EL2_MB1_START_PG + TX_PAGES;
-	printk("\n%s: %s, %dkB RAM, using programmed I/O (REJUMPER for SHARED MEMORY).\n",
+	pr_info("%s: %s, %dkB RAM, using programmed I/O (REJUMPER for SHARED MEMORY).\n",
 	       dev->name, ei_status.name, (wordlength+1)<<3);
     }
     release_region(ioaddr + 0x400, 8);
@@ -435,15 +436,16 @@ static void
 el2_reset_8390(struct net_device *dev)
 {
     if (ei_debug > 1) {
-	printk("%s: Resetting the 3c503 board...", dev->name);
-	printk("%#lx=%#02x %#lx=%#02x %#lx=%#02x...", E33G_IDCFR, inb(E33G_IDCFR),
+	pr_debug("%s: Resetting the 3c503 board...", dev->name);
+	pr_cont(" %#lx=%#02x %#lx=%#02x %#lx=%#02x...", E33G_IDCFR, inb(E33G_IDCFR),
 	       E33G_CNTRL, inb(E33G_CNTRL), E33G_GACFR, inb(E33G_GACFR));
     }
     outb_p(ECNTRL_RESET|ECNTRL_THIN, E33G_CNTRL);
     ei_status.txing = 0;
     outb_p(ei_status.interface_num==0 ? ECNTRL_THIN : ECNTRL_AUI, E33G_CNTRL);
     el2_init_card(dev);
-    if (ei_debug > 1) printk("done\n");
+    if (ei_debug > 1)
+	pr_cont("done\n");
 }
 
 /* Initialize the 3c503 GA registers after a reset. */
@@ -529,7 +531,7 @@ el2_block_output(struct net_device *dev, int count,
         {
             if(!boguscount--)
             {
-                printk("%s: FIFO blocked in el2_block_output.\n", dev->name);
+                pr_notice("%s: FIFO blocked in el2_block_output.\n", dev->name);
                 el2_reset_8390(dev);
                 goto blocked;
             }
@@ -581,7 +583,7 @@ el2_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr, int ring_pag
     {
         if(!boguscount--)
         {
-            printk("%s: FIFO blocked in el2_get_8390_hdr.\n", dev->name);
+            pr_notice("%s: FIFO blocked in el2_get_8390_hdr.\n", dev->name);
             memset(hdr, 0x00, sizeof(struct e8390_pkt_hdr));
             el2_reset_8390(dev);
             goto blocked;
@@ -645,7 +647,7 @@ el2_block_input(struct net_device *dev, int count, struct sk_buff *skb, int ring
         {
             if(!boguscount--)
             {
-                printk("%s: FIFO blocked in el2_block_input.\n", dev->name);
+                pr_notice("%s: FIFO blocked in el2_block_input.\n", dev->name);
                 el2_reset_8390(dev);
                 goto blocked;
             }
@@ -707,7 +709,7 @@ init_module(void)
 	for (this_dev = 0; this_dev < MAX_EL2_CARDS; this_dev++) {
 		if (io[this_dev] == 0)  {
 			if (this_dev != 0) break; /* only autoprobe 1st one */
-			printk(KERN_NOTICE "3c503.c: Presently autoprobing (not recommended) for a single card.\n");
+			pr_notice("3c503.c: Presently autoprobing (not recommended) for a single card.\n");
 		}
 		dev = alloc_eip_netdev();
 		if (!dev)
@@ -720,7 +722,7 @@ init_module(void)
 			continue;
 		}
 		free_netdev(dev);
-		printk(KERN_WARNING "3c503.c: No 3c503 card found (i/o = 0x%x).\n", io[this_dev]);
+		pr_warning("3c503.c: No 3c503 card found (i/o = 0x%x).\n", io[this_dev]);
 		break;
 	}
 	if (found)
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index 2de1c9c..b284994 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -126,26 +126,25 @@
  *
  *********************************************************/
 
-static const char filename[] = __FILE__;
+#define filename __FILE__
 
-static const char timeout_msg[] = "*** timeout at %s:%s (line %d) ***\n";
+#define timeout_msg "*** timeout at %s:%s (line %d) ***\n"
 #define TIMEOUT_MSG(lineno) \
-	printk(timeout_msg, filename,__func__,(lineno))
+	pr_notice(timeout_msg, filename, __func__, (lineno))
 
-static const char invalid_pcb_msg[] =
-"*** invalid pcb length %d at %s:%s (line %d) ***\n";
+#define invalid_pcb_msg "*** invalid pcb length %d at %s:%s (line %d) ***\n"
 #define INVALID_PCB_MSG(len) \
-	printk(invalid_pcb_msg, (len),filename,__func__,__LINE__)
+	pr_notice(invalid_pcb_msg, (len), filename, __func__, __LINE__)
 
-static char search_msg[] __initdata = KERN_INFO "%s: Looking for 3c505 adapter at address %#x...";
+#define search_msg "%s: Looking for 3c505 adapter at address %#x..."
 
-static char stilllooking_msg[] __initdata = "still looking...";
+#define stilllooking_msg "still looking..."
 
-static char found_msg[] __initdata = "found.\n";
+#define found_msg "found.\n"
 
-static char notfound_msg[] __initdata = "not found (reason = %d)\n";
+#define notfound_msg "not found (reason = %d)\n"
 
-static char couldnot_msg[] __initdata = KERN_INFO "%s: 3c505 not found\n";
+#define couldnot_msg "%s: 3c505 not found\n"
 
 /*********************************************************
  *
@@ -284,7 +283,7 @@ static inline void adapter_reset(struct net_device *dev)
 
 	outb_control(orig_hcr, dev);
 	if (!start_receive(dev, &adapter->tx_pcb))
-		printk(KERN_ERR "%s: start receive command failed \n", dev->name);
+		pr_err("%s: start receive command failed\n", dev->name);
 }
 
 /* Check to make sure that a DMA transfer hasn't timed out.  This should
@@ -296,7 +295,9 @@ static inline void check_3c505_dma(struct net_device *dev)
 	elp_device *adapter = netdev_priv(dev);
 	if (adapter->dmaing && time_after(jiffies, adapter->current_dma.start_time + 10)) {
 		unsigned long flags, f;
-		printk(KERN_ERR "%s: DMA %s timed out, %d bytes left\n", dev->name, adapter->current_dma.direction ? "download" : "upload", get_dma_residue(dev->dma));
+		pr_err("%s: DMA %s timed out, %d bytes left\n", dev->name,
+			adapter->current_dma.direction ? "download" : "upload",
+			get_dma_residue(dev->dma));
 		spin_lock_irqsave(&adapter->lock, flags);
 		adapter->dmaing = 0;
 		adapter->busy = 0;
@@ -321,7 +322,7 @@ static inline bool send_pcb_slow(unsigned int base_addr, unsigned char byte)
 		if (inb_status(base_addr) & HCRE)
 			return false;
 	}
-	printk(KERN_WARNING "3c505: send_pcb_slow timed out\n");
+	pr_warning("3c505: send_pcb_slow timed out\n");
 	return true;
 }
 
@@ -333,7 +334,7 @@ static inline bool send_pcb_fast(unsigned int base_addr, unsigned char byte)
 		if (inb_status(base_addr) & HCRE)
 			return false;
 	}
-	printk(KERN_WARNING "3c505: send_pcb_fast timed out\n");
+	pr_warning("3c505: send_pcb_fast timed out\n");
 	return true;
 }
 
@@ -386,7 +387,7 @@ static bool send_pcb(struct net_device *dev, pcb_struct * pcb)
 	/* Avoid contention */
 	if (test_and_set_bit(1, &adapter->send_pcb_semaphore)) {
 		if (elp_debug >= 3) {
-			printk(KERN_DEBUG "%s: send_pcb entered while threaded\n", dev->name);
+			pr_debug("%s: send_pcb entered while threaded\n", dev->name);
 		}
 		return false;
 	}
@@ -424,14 +425,15 @@ static bool send_pcb(struct net_device *dev, pcb_struct * pcb)
 
 		case ASF_PCB_NAK:
 #ifdef ELP_DEBUG
-			printk(KERN_DEBUG "%s: send_pcb got NAK\n", dev->name);
+			pr_debug("%s: send_pcb got NAK\n", dev->name);
 #endif
 			goto abort;
 		}
 	}
 
 	if (elp_debug >= 1)
-		printk(KERN_DEBUG "%s: timeout waiting for PCB acknowledge (status %02x)\n", dev->name, inb_status(dev->base_addr));
+		pr_debug("%s: timeout waiting for PCB acknowledge (status %02x)\n",
+			dev->name, inb_status(dev->base_addr));
 	goto abort;
 
       sti_abort:
@@ -481,7 +483,7 @@ static bool receive_pcb(struct net_device *dev, pcb_struct * pcb)
 	while (((stat = get_status(dev->base_addr)) & ACRF) == 0 && time_before(jiffies, timeout));
 	if (time_after_eq(jiffies, timeout)) {
 		TIMEOUT_MSG(__LINE__);
-		printk(KERN_INFO "%s: status %02x\n", dev->name, stat);
+		pr_info("%s: status %02x\n", dev->name, stat);
 		return false;
 	}
 	pcb->length = inb_command(dev->base_addr);
@@ -518,7 +520,7 @@ static bool receive_pcb(struct net_device *dev, pcb_struct * pcb)
 	/* safety check total length vs data length */
 	if (total_length != (pcb->length + 2)) {
 		if (elp_debug >= 2)
-			printk(KERN_WARNING "%s: mangled PCB received\n", dev->name);
+			pr_warning("%s: mangled PCB received\n", dev->name);
 		set_hsf(dev, HSF_PCB_NAK);
 		return false;
 	}
@@ -527,7 +529,7 @@ static bool receive_pcb(struct net_device *dev, pcb_struct * pcb)
 		if (test_and_set_bit(0, (void *) &adapter->busy)) {
 			if (backlog_next(adapter->rx_backlog.in) == adapter->rx_backlog.out) {
 				set_hsf(dev, HSF_PCB_NAK);
-				printk(KERN_WARNING "%s: PCB rejected, transfer in progress and backlog full\n", dev->name);
+				pr_warning("%s: PCB rejected, transfer in progress and backlog full\n", dev->name);
 				pcb->command = 0;
 				return true;
 			} else {
@@ -552,7 +554,7 @@ static bool start_receive(struct net_device *dev, pcb_struct * tx_pcb)
 	elp_device *adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
-		printk(KERN_DEBUG "%s: restarting receiver\n", dev->name);
+		pr_debug("%s: restarting receiver\n", dev->name);
 	tx_pcb->command = CMD_RECEIVE_PACKET;
 	tx_pcb->length = sizeof(struct Rcv_pkt);
 	tx_pcb->data.rcv_pkt.buf_seg
@@ -586,7 +588,7 @@ static void receive_packet(struct net_device *dev, int len)
 	skb = dev_alloc_skb(rlen + 2);
 
 	if (!skb) {
-		printk(KERN_WARNING "%s: memory squeeze, dropping packet\n", dev->name);
+		pr_warning("%s: memory squeeze, dropping packet\n", dev->name);
 		target = adapter->dma_buffer;
 		adapter->current_dma.target = NULL;
 		/* FIXME: stats */
@@ -604,7 +606,8 @@ static void receive_packet(struct net_device *dev, int len)
 
 	/* if this happens, we die */
 	if (test_and_set_bit(0, (void *) &adapter->dmaing))
-		printk(KERN_ERR "%s: rx blocked, DMA in progress, dir %d\n", dev->name, adapter->current_dma.direction);
+		pr_err("%s: rx blocked, DMA in progress, dir %d\n",
+			dev->name, adapter->current_dma.direction);
 
 	adapter->current_dma.direction = 0;
 	adapter->current_dma.length = rlen;
@@ -623,14 +626,14 @@ static void receive_packet(struct net_device *dev, int len)
 	release_dma_lock(flags);
 
 	if (elp_debug >= 3) {
-		printk(KERN_DEBUG "%s: rx DMA transfer started\n", dev->name);
+		pr_debug("%s: rx DMA transfer started\n", dev->name);
 	}
 
 	if (adapter->rx_active)
 		adapter->rx_active--;
 
 	if (!adapter->busy)
-		printk(KERN_WARNING "%s: receive_packet called, busy not set.\n", dev->name);
+		pr_warning("%s: receive_packet called, busy not set.\n", dev->name);
 }
 
 /******************************************************
@@ -655,12 +658,13 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 		 * has a DMA transfer finished?
 		 */
 		if (inb_status(dev->base_addr) & DONE) {
-			if (!adapter->dmaing) {
-				printk(KERN_WARNING "%s: phantom DMA completed\n", dev->name);
-			}
-			if (elp_debug >= 3) {
-				printk(KERN_DEBUG "%s: %s DMA complete, status %02x\n", dev->name, adapter->current_dma.direction ? "tx" : "rx", inb_status(dev->base_addr));
-			}
+			if (!adapter->dmaing)
+				pr_warning("%s: phantom DMA completed\n", dev->name);
+
+			if (elp_debug >= 3)
+				pr_debug("%s: %s DMA complete, status %02x\n", dev->name,
+					adapter->current_dma.direction ? "tx" : "rx",
+					inb_status(dev->base_addr));
 
 			outb_control(adapter->hcr_val & ~(DMAE | TCEN | DIR), dev);
 			if (adapter->current_dma.direction) {
@@ -682,7 +686,7 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 				int t = adapter->rx_backlog.length[adapter->rx_backlog.out];
 				adapter->rx_backlog.out = backlog_next(adapter->rx_backlog.out);
 				if (elp_debug >= 2)
-					printk(KERN_DEBUG "%s: receiving backlogged packet (%d)\n", dev->name, t);
+					pr_debug("%s: receiving backlogged packet (%d)\n", dev->name, t);
 				receive_packet(dev, t);
 			} else {
 				adapter->busy = 0;
@@ -713,21 +717,23 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 					len = adapter->irx_pcb.data.rcv_resp.pkt_len;
 					dlen = adapter->irx_pcb.data.rcv_resp.buf_len;
 					if (adapter->irx_pcb.data.rcv_resp.timeout != 0) {
-						printk(KERN_ERR "%s: interrupt - packet not received correctly\n", dev->name);
+						pr_err("%s: interrupt - packet not received correctly\n", dev->name);
 					} else {
 						if (elp_debug >= 3) {
-							printk(KERN_DEBUG "%s: interrupt - packet received of length %i (%i)\n", dev->name, len, dlen);
+							pr_debug("%s: interrupt - packet received of length %i (%i)\n",
+								dev->name, len, dlen);
 						}
 						if (adapter->irx_pcb.command == 0xff) {
 							if (elp_debug >= 2)
-								printk(KERN_DEBUG "%s: adding packet to backlog (len = %d)\n", dev->name, dlen);
+								pr_debug("%s: adding packet to backlog (len = %d)\n",
+									dev->name, dlen);
 							adapter->rx_backlog.length[adapter->rx_backlog.in] = dlen;
 							adapter->rx_backlog.in = backlog_next(adapter->rx_backlog.in);
 						} else {
 							receive_packet(dev, dlen);
 						}
 						if (elp_debug >= 3)
-							printk(KERN_DEBUG "%s: packet received\n", dev->name);
+							pr_debug("%s: packet received\n", dev->name);
 					}
 					break;
 
@@ -737,7 +743,7 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 				case CMD_CONFIGURE_82586_RESPONSE:
 					adapter->got[CMD_CONFIGURE_82586] = 1;
 					if (elp_debug >= 3)
-						printk(KERN_DEBUG "%s: interrupt - configure response received\n", dev->name);
+						pr_debug("%s: interrupt - configure response received\n", dev->name);
 					break;
 
 					/*
@@ -746,7 +752,7 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 				case CMD_CONFIGURE_ADAPTER_RESPONSE:
 					adapter->got[CMD_CONFIGURE_ADAPTER_MEMORY] = 1;
 					if (elp_debug >= 3)
-						printk(KERN_DEBUG "%s: Adapter memory configuration %s.\n", dev->name,
+						pr_debug("%s: Adapter memory configuration %s.\n", dev->name,
 						       adapter->irx_pcb.data.failed ? "failed" : "succeeded");
 					break;
 
@@ -756,7 +762,7 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 				case CMD_LOAD_MULTICAST_RESPONSE:
 					adapter->got[CMD_LOAD_MULTICAST_LIST] = 1;
 					if (elp_debug >= 3)
-						printk(KERN_DEBUG "%s: Multicast address list loading %s.\n", dev->name,
+						pr_debug("%s: Multicast address list loading %s.\n", dev->name,
 						       adapter->irx_pcb.data.failed ? "failed" : "succeeded");
 					break;
 
@@ -766,7 +772,7 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 				case CMD_SET_ADDRESS_RESPONSE:
 					adapter->got[CMD_SET_STATION_ADDRESS] = 1;
 					if (elp_debug >= 3)
-						printk(KERN_DEBUG "%s: Ethernet address setting %s.\n", dev->name,
+						pr_debug("%s: Ethernet address setting %s.\n", dev->name,
 						       adapter->irx_pcb.data.failed ? "failed" : "succeeded");
 					break;
 
@@ -783,7 +789,7 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 					dev->stats.rx_over_errors += adapter->irx_pcb.data.netstat.err_res;
 					adapter->got[CMD_NETWORK_STATISTICS] = 1;
 					if (elp_debug >= 3)
-						printk(KERN_DEBUG "%s: interrupt - statistics response received\n", dev->name);
+						pr_debug("%s: interrupt - statistics response received\n", dev->name);
 					break;
 
 					/*
@@ -791,17 +797,17 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 					 */
 				case CMD_TRANSMIT_PACKET_COMPLETE:
 					if (elp_debug >= 3)
-						printk(KERN_DEBUG "%s: interrupt - packet sent\n", dev->name);
+						pr_debug("%s: interrupt - packet sent\n", dev->name);
 					if (!netif_running(dev))
 						break;
 					switch (adapter->irx_pcb.data.xmit_resp.c_stat) {
 					case 0xffff:
 						dev->stats.tx_aborted_errors++;
-						printk(KERN_INFO "%s: transmit timed out, network cable problem?\n", dev->name);
+						pr_info("%s: transmit timed out, network cable problem?\n", dev->name);
 						break;
 					case 0xfffe:
 						dev->stats.tx_fifo_errors++;
-						printk(KERN_INFO "%s: transmit timed out, FIFO underrun\n", dev->name);
+						pr_info("%s: transmit timed out, FIFO underrun\n", dev->name);
 						break;
 					}
 					netif_wake_queue(dev);
@@ -811,11 +817,12 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 					 * some unknown PCB
 					 */
 				default:
-					printk(KERN_DEBUG "%s: unknown PCB received - %2.2x\n", dev->name, adapter->irx_pcb.command);
+					pr_debug("%s: unknown PCB received - %2.2x\n",
+						dev->name, adapter->irx_pcb.command);
 					break;
 				}
 			} else {
-				printk(KERN_WARNING "%s: failed to read PCB on interrupt\n", dev->name);
+				pr_warning("%s: failed to read PCB on interrupt\n", dev->name);
 				adapter_reset(dev);
 			}
 		}
@@ -844,13 +851,13 @@ static int elp_open(struct net_device *dev)
 	int retval;
 
 	if (elp_debug >= 3)
-		printk(KERN_DEBUG "%s: request to open device\n", dev->name);
+		pr_debug("%s: request to open device\n", dev->name);
 
 	/*
 	 * make sure we actually found the device
 	 */
 	if (adapter == NULL) {
-		printk(KERN_ERR "%s: Opening a non-existent physical device\n", dev->name);
+		pr_err("%s: Opening a non-existent physical device\n", dev->name);
 		return -EAGAIN;
 	}
 	/*
@@ -880,17 +887,17 @@ static int elp_open(struct net_device *dev)
 	 * install our interrupt service routine
 	 */
 	if ((retval = request_irq(dev->irq, &elp_interrupt, 0, dev->name, dev))) {
-		printk(KERN_ERR "%s: could not allocate IRQ%d\n", dev->name, dev->irq);
+		pr_err("%s: could not allocate IRQ%d\n", dev->name, dev->irq);
 		return retval;
 	}
 	if ((retval = request_dma(dev->dma, dev->name))) {
 		free_irq(dev->irq, dev);
-		printk(KERN_ERR "%s: could not allocate DMA%d channel\n", dev->name, dev->dma);
+		pr_err("%s: could not allocate DMA%d channel\n", dev->name, dev->dma);
 		return retval;
 	}
 	adapter->dma_buffer = (void *) dma_mem_alloc(DMA_BUFFER_SIZE);
 	if (!adapter->dma_buffer) {
-		printk(KERN_ERR "%s: could not allocate DMA buffer\n", dev->name);
+		pr_err("%s: could not allocate DMA buffer\n", dev->name);
 		free_dma(dev->dma);
 		free_irq(dev->irq, dev);
 		return -ENOMEM;
@@ -906,7 +913,7 @@ static int elp_open(struct net_device *dev)
 	 * configure adapter memory: we need 10 multicast addresses, default==0
 	 */
 	if (elp_debug >= 3)
-		printk(KERN_DEBUG "%s: sending 3c505 memory configuration command\n", dev->name);
+		pr_debug("%s: sending 3c505 memory configuration command\n", dev->name);
 	adapter->tx_pcb.command = CMD_CONFIGURE_ADAPTER_MEMORY;
 	adapter->tx_pcb.data.memconf.cmd_q = 10;
 	adapter->tx_pcb.data.memconf.rcv_q = 20;
@@ -917,7 +924,7 @@ static int elp_open(struct net_device *dev)
 	adapter->tx_pcb.length = sizeof(struct Memconf);
 	adapter->got[CMD_CONFIGURE_ADAPTER_MEMORY] = 0;
 	if (!send_pcb(dev, &adapter->tx_pcb))
-		printk(KERN_ERR "%s: couldn't send memory configuration command\n", dev->name);
+		pr_err("%s: couldn't send memory configuration command\n", dev->name);
 	else {
 		unsigned long timeout = jiffies + TIMEOUT;
 		while (adapter->got[CMD_CONFIGURE_ADAPTER_MEMORY] == 0 && time_before(jiffies, timeout));
@@ -930,13 +937,13 @@ static int elp_open(struct net_device *dev)
 	 * configure adapter to receive broadcast messages and wait for response
 	 */
 	if (elp_debug >= 3)
-		printk(KERN_DEBUG "%s: sending 82586 configure command\n", dev->name);
+		pr_debug("%s: sending 82586 configure command\n", dev->name);
 	adapter->tx_pcb.command = CMD_CONFIGURE_82586;
 	adapter->tx_pcb.data.configure = NO_LOOPBACK | RECV_BROAD;
 	adapter->tx_pcb.length = 2;
 	adapter->got[CMD_CONFIGURE_82586] = 0;
 	if (!send_pcb(dev, &adapter->tx_pcb))
-		printk(KERN_ERR "%s: couldn't send 82586 configure command\n", dev->name);
+		pr_err("%s: couldn't send 82586 configure command\n", dev->name);
 	else {
 		unsigned long timeout = jiffies + TIMEOUT;
 		while (adapter->got[CMD_CONFIGURE_82586] == 0 && time_before(jiffies, timeout));
@@ -952,7 +959,7 @@ static int elp_open(struct net_device *dev)
 	 */
 	prime_rx(dev);
 	if (elp_debug >= 3)
-		printk(KERN_DEBUG "%s: %d receive PCBs active\n", dev->name, adapter->rx_active);
+		pr_debug("%s: %d receive PCBs active\n", dev->name, adapter->rx_active);
 
 	/*
 	 * device is now officially open!
@@ -982,7 +989,7 @@ static bool send_packet(struct net_device *dev, struct sk_buff *skb)
 
 	if (test_and_set_bit(0, (void *) &adapter->busy)) {
 		if (elp_debug >= 2)
-			printk(KERN_DEBUG "%s: transmit blocked\n", dev->name);
+			pr_debug("%s: transmit blocked\n", dev->name);
 		return false;
 	}
 
@@ -1004,7 +1011,7 @@ static bool send_packet(struct net_device *dev, struct sk_buff *skb)
 	}
 	/* if this happens, we die */
 	if (test_and_set_bit(0, (void *) &adapter->dmaing))
-		printk(KERN_DEBUG "%s: tx: DMA %d in progress\n", dev->name, adapter->current_dma.direction);
+		pr_debug("%s: tx: DMA %d in progress\n", dev->name, adapter->current_dma.direction);
 
 	adapter->current_dma.direction = 1;
 	adapter->current_dma.start_time = jiffies;
@@ -1030,7 +1037,7 @@ static bool send_packet(struct net_device *dev, struct sk_buff *skb)
 	release_dma_lock(flags);
 
 	if (elp_debug >= 3)
-		printk(KERN_DEBUG "%s: DMA transfer started\n", dev->name);
+		pr_debug("%s: DMA transfer started\n", dev->name);
 
 	return true;
 }
@@ -1044,9 +1051,10 @@ static void elp_timeout(struct net_device *dev)
 	int stat;
 
 	stat = inb_status(dev->base_addr);
-	printk(KERN_WARNING "%s: transmit timed out, lost %s?\n", dev->name, (stat & ACRF) ? "interrupt" : "command");
+	pr_warning("%s: transmit timed out, lost %s?\n", dev->name,
+		   (stat & ACRF) ? "interrupt" : "command");
 	if (elp_debug >= 1)
-		printk(KERN_DEBUG "%s: status %#02x\n", dev->name, stat);
+		pr_debug("%s: status %#02x\n", dev->name, stat);
 	dev->trans_start = jiffies;
 	dev->stats.tx_dropped++;
 	netif_wake_queue(dev);
@@ -1068,7 +1076,7 @@ static int elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	check_3c505_dma(dev);
 
 	if (elp_debug >= 3)
-		printk(KERN_DEBUG "%s: request to send packet of length %d\n", dev->name, (int) skb->len);
+		pr_debug("%s: request to send packet of length %d\n", dev->name, (int) skb->len);
 
 	netif_stop_queue(dev);
 
@@ -1077,13 +1085,13 @@ static int elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	if (!send_packet(dev, skb)) {
 		if (elp_debug >= 2) {
-			printk(KERN_DEBUG "%s: failed to transmit packet\n", dev->name);
+			pr_debug("%s: failed to transmit packet\n", dev->name);
 		}
 		spin_unlock_irqrestore(&adapter->lock, flags);
 		return 1;
 	}
 	if (elp_debug >= 3)
-		printk(KERN_DEBUG "%s: packet of length %d sent\n", dev->name, (int) skb->len);
+		pr_debug("%s: packet of length %d sent\n", dev->name, (int) skb->len);
 
 	/*
 	 * start the transmit timeout
@@ -1107,7 +1115,7 @@ static struct net_device_stats *elp_get_stats(struct net_device *dev)
 	elp_device *adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
-		printk(KERN_DEBUG "%s: request for stats\n", dev->name);
+		pr_debug("%s: request for stats\n", dev->name);
 
 	/* If the device is closed, just return the latest stats we have,
 	   - we cannot ask from the adapter without interrupts */
@@ -1119,7 +1127,7 @@ static struct net_device_stats *elp_get_stats(struct net_device *dev)
 	adapter->tx_pcb.length = 0;
 	adapter->got[CMD_NETWORK_STATISTICS] = 0;
 	if (!send_pcb(dev, &adapter->tx_pcb))
-		printk(KERN_ERR "%s: couldn't send get statistics command\n", dev->name);
+		pr_err("%s: couldn't send get statistics command\n", dev->name);
 	else {
 		unsigned long timeout = jiffies + TIMEOUT;
 		while (adapter->got[CMD_NETWORK_STATISTICS] == 0 && time_before(jiffies, timeout));
@@ -1169,7 +1177,7 @@ static int elp_close(struct net_device *dev)
 	elp_device *adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
-		printk(KERN_DEBUG "%s: request to close device\n", dev->name);
+		pr_debug("%s: request to close device\n", dev->name);
 
 	netif_stop_queue(dev);
 
@@ -1213,7 +1221,7 @@ static void elp_set_mc_list(struct net_device *dev)
 	unsigned long flags;
 
 	if (elp_debug >= 3)
-		printk(KERN_DEBUG "%s: request to set multicast list\n", dev->name);
+		pr_debug("%s: request to set multicast list\n", dev->name);
 
 	spin_lock_irqsave(&adapter->lock, flags);
 
@@ -1228,7 +1236,7 @@ static void elp_set_mc_list(struct net_device *dev)
 		}
 		adapter->got[CMD_LOAD_MULTICAST_LIST] = 0;
 		if (!send_pcb(dev, &adapter->tx_pcb))
-			printk(KERN_ERR "%s: couldn't send set_multicast command\n", dev->name);
+			pr_err("%s: couldn't send set_multicast command\n", dev->name);
 		else {
 			unsigned long timeout = jiffies + TIMEOUT;
 			while (adapter->got[CMD_LOAD_MULTICAST_LIST] == 0 && time_before(jiffies, timeout));
@@ -1247,14 +1255,14 @@ static void elp_set_mc_list(struct net_device *dev)
 	 * and wait for response
 	 */
 	if (elp_debug >= 3)
-		printk(KERN_DEBUG "%s: sending 82586 configure command\n", dev->name);
+		pr_debug("%s: sending 82586 configure command\n", dev->name);
 	adapter->tx_pcb.command = CMD_CONFIGURE_82586;
 	adapter->tx_pcb.length = 2;
 	adapter->got[CMD_CONFIGURE_82586] = 0;
 	if (!send_pcb(dev, &adapter->tx_pcb))
 	{
 		spin_unlock_irqrestore(&adapter->lock, flags);
-		printk(KERN_ERR "%s: couldn't send 82586 configure command\n", dev->name);
+		pr_err("%s: couldn't send 82586 configure command\n", dev->name);
 	}
 	else {
 		unsigned long timeout = jiffies + TIMEOUT;
@@ -1283,17 +1291,17 @@ static int __init elp_sense(struct net_device *dev)
 	orig_HSR = inb_status(addr);
 
 	if (elp_debug > 0)
-		printk(search_msg, name, addr);
+		pr_debug(search_msg, name, addr);
 
 	if (orig_HSR == 0xff) {
 		if (elp_debug > 0)
-			printk(notfound_msg, 1);
+			pr_cont(notfound_msg, 1);
 		goto out;
 	}
 
 	/* Wait for a while; the adapter may still be booting up */
 	if (elp_debug > 0)
-		printk(stilllooking_msg);
+		pr_cont(stilllooking_msg);
 
 	if (orig_HSR & DIR) {
 		/* If HCR.DIR is up, we pull it down. HSR.DIR should follow. */
@@ -1301,7 +1309,7 @@ static int __init elp_sense(struct net_device *dev)
 		msleep(300);
 		if (inb_status(addr) & DIR) {
 			if (elp_debug > 0)
-				printk(notfound_msg, 2);
+				pr_cont(notfound_msg, 2);
 			goto out;
 		}
 	} else {
@@ -1310,7 +1318,7 @@ static int __init elp_sense(struct net_device *dev)
 		msleep(300);
 		if (!(inb_status(addr) & DIR)) {
 			if (elp_debug > 0)
-				printk(notfound_msg, 3);
+				pr_cont(notfound_msg, 3);
 			goto out;
 		}
 	}
@@ -1318,7 +1326,7 @@ static int __init elp_sense(struct net_device *dev)
 	 * It certainly looks like a 3c505.
 	 */
 	if (elp_debug > 0)
-		printk(found_msg);
+		pr_cont(found_msg);
 
 	return 0;
 out:
@@ -1349,7 +1357,7 @@ static int __init elp_autodetect(struct net_device *dev)
 
 	/* could not find an adapter */
 	if (elp_debug > 0)
-		printk(couldnot_msg, dev->name);
+		pr_debug(couldnot_msg, dev->name);
 
 	return 0;		/* Because of this, the layer above will return -ENODEV */
 }
@@ -1424,16 +1432,16 @@ static int __init elplus_setup(struct net_device *dev)
 			/* Nope, it's ignoring the command register.  This means that
 			 * either it's still booting up, or it's died.
 			 */
-			printk(KERN_ERR "%s: command register wouldn't drain, ", dev->name);
+			pr_err("%s: command register wouldn't drain, ", dev->name);
 			if ((inb_status(dev->base_addr) & 7) == 3) {
 				/* If the adapter status is 3, it *could* still be booting.
 				 * Give it the benefit of the doubt for 10 seconds.
 				 */
-				printk("assuming 3c505 still starting\n");
+				pr_cont("assuming 3c505 still starting\n");
 				timeout = jiffies + 10*HZ;
 				while (time_before(jiffies, timeout) && (inb_status(dev->base_addr) & 7));
 				if (inb_status(dev->base_addr) & 7) {
-					printk(KERN_ERR "%s: 3c505 failed to start\n", dev->name);
+					pr_err("%s: 3c505 failed to start\n", dev->name);
 				} else {
 					okay = 1;  /* It started */
 				}
@@ -1441,7 +1449,7 @@ static int __init elplus_setup(struct net_device *dev)
 				/* Otherwise, it must just be in a strange
 				 * state.  We probably need to kick it.
 				 */
-				printk("3c505 is sulking\n");
+				pr_cont("3c505 is sulking\n");
 			}
 		}
 		for (tries = 0; tries < 5 && okay; tries++) {
@@ -1454,18 +1462,19 @@ static int __init elplus_setup(struct net_device *dev)
 			adapter->tx_pcb.length = 0;
 			cookie = probe_irq_on();
 			if (!send_pcb(dev, &adapter->tx_pcb)) {
-				printk(KERN_ERR "%s: could not send first PCB\n", dev->name);
+				pr_err("%s: could not send first PCB\n", dev->name);
 				probe_irq_off(cookie);
 				continue;
 			}
 			if (!receive_pcb(dev, &adapter->rx_pcb)) {
-				printk(KERN_ERR "%s: could not read first PCB\n", dev->name);
+				pr_err("%s: could not read first PCB\n", dev->name);
 				probe_irq_off(cookie);
 				continue;
 			}
 			if ((adapter->rx_pcb.command != CMD_ADDRESS_RESPONSE) ||
 			    (adapter->rx_pcb.length != 6)) {
-				printk(KERN_ERR "%s: first PCB wrong (%d, %d)\n", dev->name, adapter->rx_pcb.command, adapter->rx_pcb.length);
+				pr_err("%s: first PCB wrong (%d, %d)\n", dev->name,
+					adapter->rx_pcb.command, adapter->rx_pcb.length);
 				probe_irq_off(cookie);
 				continue;
 			}
@@ -1474,32 +1483,32 @@ static int __init elplus_setup(struct net_device *dev)
 		/* It's broken.  Do a hard reset to re-initialise the board,
 		 * and try again.
 		 */
-		printk(KERN_INFO "%s: resetting adapter\n", dev->name);
+		pr_info("%s: resetting adapter\n", dev->name);
 		outb_control(adapter->hcr_val | FLSH | ATTN, dev);
 		outb_control(adapter->hcr_val & ~(FLSH | ATTN), dev);
 	}
-	printk(KERN_ERR "%s: failed to initialise 3c505\n", dev->name);
+	pr_err("%s: failed to initialise 3c505\n", dev->name);
 	goto out;
 
       okay:
 	if (dev->irq) {		/* Is there a preset IRQ? */
 		int rpt = probe_irq_off(cookie);
 		if (dev->irq != rpt) {
-			printk(KERN_WARNING "%s: warning, irq %d configured but %d detected\n", dev->name, dev->irq, rpt);
+			pr_warning("%s: warning, irq %d configured but %d detected\n", dev->name, dev->irq, rpt);
 		}
 		/* if dev->irq == probe_irq_off(cookie), all is well */
 	} else		       /* No preset IRQ; just use what we can detect */
 		dev->irq = probe_irq_off(cookie);
 	switch (dev->irq) {    /* Legal, sane? */
 	case 0:
-		printk(KERN_ERR "%s: IRQ probe failed: check 3c505 jumpers.\n",
+		pr_err("%s: IRQ probe failed: check 3c505 jumpers.\n",
 		       dev->name);
 		goto out;
 	case 1:
 	case 6:
 	case 8:
 	case 13:
-		printk(KERN_ERR "%s: Impossible IRQ %d reported by probe_irq_off().\n",
+		pr_err("%s: Impossible IRQ %d reported by probe_irq_off().\n",
 		       dev->name, dev->irq);
 		       goto out;
 	}
@@ -1521,7 +1530,7 @@ static int __init elplus_setup(struct net_device *dev)
 			dev->dma = dev->mem_start & 7;
 		}
 		else {
-			printk(KERN_WARNING "%s: warning, DMA channel not specified, using default\n", dev->name);
+			pr_warning("%s: warning, DMA channel not specified, using default\n", dev->name);
 			dev->dma = ELP_DMA;
 		}
 	}
@@ -1529,11 +1538,8 @@ static int __init elplus_setup(struct net_device *dev)
 	/*
 	 * print remainder of startup message
 	 */
-	printk(KERN_INFO "%s: 3c505 at %#lx, irq %d, dma %d, "
-	       "addr %pM, ",
-	       dev->name, dev->base_addr, dev->irq, dev->dma,
-	       dev->dev_addr);
-
+	pr_info("%s: 3c505 at %#lx, irq %d, dma %d, addr %pM, ",
+		dev->name, dev->base_addr, dev->irq, dev->dma, dev->dev_addr);
 	/*
 	 * read more information from the adapter
 	 */
@@ -1544,9 +1550,10 @@ static int __init elplus_setup(struct net_device *dev)
 	    !receive_pcb(dev, &adapter->rx_pcb) ||
 	    (adapter->rx_pcb.command != CMD_ADAPTER_INFO_RESPONSE) ||
 	    (adapter->rx_pcb.length != 10)) {
-		printk("not responding to second PCB\n");
+		pr_cont("not responding to second PCB\n");
 	}
-	printk("rev %d.%d, %dk\n", adapter->rx_pcb.data.info.major_vers, adapter->rx_pcb.data.info.minor_vers, adapter->rx_pcb.data.info.RAM_sz);
+	pr_cont("rev %d.%d, %dk\n", adapter->rx_pcb.data.info.major_vers,
+		adapter->rx_pcb.data.info.minor_vers, adapter->rx_pcb.data.info.RAM_sz);
 
 	/*
 	 * reconfigure the adapter memory to better suit our purposes
@@ -1563,10 +1570,10 @@ static int __init elplus_setup(struct net_device *dev)
 	    !receive_pcb(dev, &adapter->rx_pcb) ||
 	    (adapter->rx_pcb.command != CMD_CONFIGURE_ADAPTER_RESPONSE) ||
 	    (adapter->rx_pcb.length != 2)) {
-		printk(KERN_ERR "%s: could not configure adapter memory\n", dev->name);
+		pr_err("%s: could not configure adapter memory\n", dev->name);
 	}
 	if (adapter->rx_pcb.data.configure) {
-		printk(KERN_ERR "%s: adapter configuration failed\n", dev->name);
+		pr_err("%s: adapter configuration failed\n", dev->name);
 	}
 
 	dev->netdev_ops = &elp_netdev_ops;
@@ -1631,17 +1638,17 @@ int __init init_module(void)
 			dev->dma = dma[this_dev];
 		} else {
 			dev->dma = ELP_DMA;
-			printk(KERN_WARNING "3c505.c: warning, using default DMA channel,\n");
+			pr_warning("3c505.c: warning, using default DMA channel,\n");
 		}
 		if (io[this_dev] == 0) {
 			if (this_dev) {
 				free_netdev(dev);
 				break;
 			}
-			printk(KERN_NOTICE "3c505.c: module autoprobe not recommended, give io=xx.\n");
+			pr_notice("3c505.c: module autoprobe not recommended, give io=xx.\n");
 		}
 		if (elplus_setup(dev) != 0) {
-			printk(KERN_WARNING "3c505.c: Failed to register card at 0x%x.\n", io[this_dev]);
+			pr_warning("3c505.c: Failed to register card at 0x%x.\n", io[this_dev]);
 			free_netdev(dev);
 			break;
 		}
diff --git a/drivers/net/3c507.c b/drivers/net/3c507.c
index fbbaf82..96b8665 100644
--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -364,7 +364,7 @@ static const struct net_device_ops netdev_ops = {
 
 static int __init el16_probe1(struct net_device *dev, int ioaddr)
 {
-	static unsigned char init_ID_done, version_printed;
+	static unsigned char init_ID_done;
 	int i, irq, irqval, retval;
 	struct net_local *lp;
 
@@ -391,10 +391,7 @@ static int __init el16_probe1(struct net_device *dev, int ioaddr)
 		goto out;
 	}
 
-	if (net_debug  &&  version_printed++ == 0)
-		printk(version);
-
-	printk("%s: 3c507 at %#x,", dev->name, ioaddr);
+	pr_info("%s: 3c507 at %#x,", dev->name, ioaddr);
 
 	/* We should make a few more checks here, like the first three octets of
 	   the S.A. for the manufacturer's code. */
@@ -403,7 +400,8 @@ static int __init el16_probe1(struct net_device *dev, int ioaddr)
 
 	irqval = request_irq(irq, &el16_interrupt, 0, DRV_NAME, dev);
 	if (irqval) {
-		printk(KERN_ERR "3c507: unable to get IRQ %d (irqval=%d).\n", irq, irqval);
+		pr_cont("\n");
+		pr_err("3c507: unable to get IRQ %d (irqval=%d).\n", irq, irqval);
 		retval = -EAGAIN;
 		goto out;
 	}
@@ -414,7 +412,7 @@ static int __init el16_probe1(struct net_device *dev, int ioaddr)
 	outb(0x01, ioaddr + MISC_CTRL);
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = inb(ioaddr + i);
-	printk(" %pM", dev->dev_addr);
+	pr_cont(" %pM", dev->dev_addr);
 
 	if (mem_start)
 		net_debug = mem_start & 7;
@@ -443,18 +441,18 @@ static int __init el16_probe1(struct net_device *dev, int ioaddr)
 	dev->if_port = (inb(ioaddr + ROM_CONFIG) & 0x80) ? 1 : 0;
 	dev->irq = inb(ioaddr + IRQ_CONFIG) & 0x0f;
 
-	printk(", IRQ %d, %sternal xcvr, memory %#lx-%#lx.\n", dev->irq,
+	pr_cont(", IRQ %d, %sternal xcvr, memory %#lx-%#lx.\n", dev->irq,
 		   dev->if_port ? "ex" : "in", dev->mem_start, dev->mem_end-1);
 
 	if (net_debug)
-		printk(version);
+		pr_debug("%s", version);
 
 	lp = netdev_priv(dev);
  	memset(lp, 0, sizeof(*lp));
 	spin_lock_init(&lp->lock);
 	lp->base = ioremap(dev->mem_start, RX_BUF_END);
 	if (!lp->base) {
-		printk(KERN_ERR "3c507: unable to remap memory\n");
+		pr_err("3c507: unable to remap memory\n");
 		retval = -EAGAIN;
 		goto out1;
 	}
@@ -488,20 +486,20 @@ static void el16_tx_timeout (struct net_device *dev)
 	void __iomem *shmem = lp->base;
 
 	if (net_debug > 1)
-		printk ("%s: transmit timed out, %s?  ", dev->name,
+		pr_debug("%s: transmit timed out, %s?  ", dev->name,
 			readw(shmem + iSCB_STATUS) & 0x8000 ? "IRQ conflict" :
 			"network cable problem");
 	/* Try to restart the adaptor. */
 	if (lp->last_restart == dev->stats.tx_packets) {
 		if (net_debug > 1)
-			printk ("Resetting board.\n");
+			pr_cont("Resetting board.\n");
 		/* Completely reset the adaptor. */
 		init_82586_mem (dev);
 		lp->tx_pkts_in_ring = 0;
 	} else {
 		/* Issue the channel attention signal and hope it "gets better". */
 		if (net_debug > 1)
-			printk ("Kicking board.\n");
+			pr_cont("Kicking board.\n");
 		writew(0xf000 | CUC_START | RX_START, shmem + iSCB_CMD);
 		outb (0, ioaddr + SIGNAL_CA);	/* Issue channel-attn. */
 		lp->last_restart = dev->stats.tx_packets;
@@ -553,7 +551,8 @@ static irqreturn_t el16_interrupt(int irq, void *dev_id)
 	void __iomem *shmem;
 
 	if (dev == NULL) {
-		printk ("net_interrupt(): irq %d for unknown device.\n", irq);
+		pr_err("%s: net_interrupt(): irq %d for unknown device.\n",
+			dev->name, irq);
 		return IRQ_NONE;
 	}
 
@@ -566,7 +565,7 @@ static irqreturn_t el16_interrupt(int irq, void *dev_id)
 	status = readw(shmem+iSCB_STATUS);
 
 	if (net_debug > 4) {
-		printk("%s: 3c507 interrupt, status %4.4x.\n", dev->name, status);
+		pr_debug("%s: 3c507 interrupt, status %4.4x.\n", dev->name, status);
 	}
 
 	/* Disable the 82586's input to the interrupt line. */
@@ -577,7 +576,7 @@ static irqreturn_t el16_interrupt(int irq, void *dev_id)
 	  unsigned short tx_status = readw(shmem+lp->tx_reap);
 	  if (!(tx_status & 0x8000)) {
 		if (net_debug > 5)
-			printk("Tx command incomplete (%#x).\n", lp->tx_reap);
+			pr_debug("Tx command incomplete (%#x).\n", lp->tx_reap);
 		break;
 	  }
 	  /* Tx unsuccessful or some interesting status bit set. */
@@ -591,7 +590,7 @@ static irqreturn_t el16_interrupt(int irq, void *dev_id)
 	  }
 	  dev->stats.tx_packets++;
 	  if (net_debug > 5)
-		  printk("Reaped %x, Tx status %04x.\n" , lp->tx_reap, tx_status);
+		  pr_debug("Reaped %x, Tx status %04x.\n" , lp->tx_reap, tx_status);
 	  lp->tx_reap += TX_BUF_SIZE;
 	  if (lp->tx_reap > RX_BUF_START - TX_BUF_SIZE)
 		lp->tx_reap = TX_BUF_START;
@@ -606,7 +605,7 @@ static irqreturn_t el16_interrupt(int irq, void *dev_id)
 
 	if (status & 0x4000) { /* Packet received. */
 		if (net_debug > 5)
-			printk("Received packet, rx_head %04x.\n", lp->rx_head);
+			pr_debug("Received packet, rx_head %04x.\n", lp->rx_head);
 		el16_rx(dev);
 	}
 
@@ -615,7 +614,7 @@ static irqreturn_t el16_interrupt(int irq, void *dev_id)
 
 	if ((status & 0x0700) != 0x0200 && netif_running(dev)) {
 		if (net_debug)
-			printk("%s: Command unit stopped, status %04x, restarting.\n",
+			pr_debug("%s: Command unit stopped, status %04x, restarting.\n",
 				   dev->name, status);
 		/* If this ever occurs we should really re-write the idle loop, reset
 		   the Tx list, and do a complete restart of the command unit.
@@ -627,7 +626,7 @@ static irqreturn_t el16_interrupt(int irq, void *dev_id)
 		/* The Rx unit is not ready, it must be hung.  Restart the receiver by
 		   initializing the rx buffers, and issuing an Rx start command. */
 		if (net_debug)
-			printk("%s: Rx unit stopped, status %04x, restarting.\n",
+			pr_debug("%s: Rx unit stopped, status %04x, restarting.\n",
 				   dev->name, status);
 		init_rx_bufs(dev);
 		writew(RX_BUF_START,shmem+iSCB_RFA);
@@ -753,9 +752,8 @@ static void init_82586_mem(struct net_device *dev)
 		int boguscnt = 50;
 		while (readw(shmem+iSCB_STATUS) == 0)
 			if (--boguscnt == 0) {
-				printk("%s: i82586 initialization timed out with status %04x, "
-					   "cmd %04x.\n", dev->name,
-					   readw(shmem+iSCB_STATUS), readw(shmem+iSCB_CMD));
+				pr_warning("%s: i82586 initialization timed out with status %04x, cmd %04x.\n",
+					dev->name, readw(shmem+iSCB_STATUS), readw(shmem+iSCB_CMD));
 				break;
 			}
 		/* Issue channel-attn -- the 82586 won't start. */
@@ -765,7 +763,7 @@ static void init_82586_mem(struct net_device *dev)
 	/* Disable loopback and enable interrupts. */
 	outb(0x84, ioaddr + MISC_CTRL);
 	if (net_debug > 4)
-		printk("%s: Initialized 82586, status %04x.\n", dev->name,
+		pr_debug("%s: Initialized 82586, status %04x.\n", dev->name,
 			   readw(shmem+iSCB_STATUS));
 	return;
 }
@@ -810,7 +808,7 @@ static void hardware_send_packet(struct net_device *dev, void *buf, short length
 		lp->tx_head = TX_BUF_START;
 
 	if (net_debug > 4) {
-		printk("%s: 3c507 @%x send length = %d, tx_block %3x, next %3x.\n",
+		pr_debug("%s: 3c507 @%x send length = %d, tx_block %3x, next %3x.\n",
 			   dev->name, ioaddr, length, tx_block, lp->tx_head);
 	}
 
@@ -838,7 +836,7 @@ static void el16_rx(struct net_device *dev)
 
 		if (rfd_cmd != 0 || data_buffer_addr != rx_head + 22
 			|| (pkt_len & 0xC000) != 0xC000) {
-			printk(KERN_ERR "%s: Rx frame at %#x corrupted, "
+			pr_err("%s: Rx frame at %#x corrupted, "
 			       "status %04x cmd %04x next %04x "
 			       "data-buf @%04x %04x.\n",
 			       dev->name, rx_head, frame_status, rfd_cmd,
@@ -858,8 +856,7 @@ static void el16_rx(struct net_device *dev)
 			pkt_len &= 0x3fff;
 			skb = dev_alloc_skb(pkt_len+2);
 			if (skb == NULL) {
-				printk(KERN_ERR "%s: Memory squeeze, "
-				       "dropping packet.\n",
+				pr_err("%s: Memory squeeze, dropping packet.\n",
 				       dev->name);
 				dev->stats.rx_dropped++;
 				break;
@@ -926,7 +923,7 @@ MODULE_PARM_DESC(irq, "(ignored)");
 int __init init_module(void)
 {
 	if (io == 0)
-		printk("3c507: You should not use auto-probing with insmod!\n");
+		pr_notice("3c507: You should not use auto-probing with insmod!\n");
 	dev_3c507 = el16_probe(-1);
 	return IS_ERR(dev_3c507) ? PTR_ERR(dev_3c507) : 0;
 }
diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index 393e4e7..8d9aa49 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -257,7 +257,7 @@ static int el3_isa_id_sequence(__be16 *phys_addr)
 			    && !memcmp(phys_addr, el3_devs[i]->dev_addr,
 				       ETH_ALEN)) {
 				if (el3_debug > 3)
-					printk(KERN_DEBUG "3c509 with address %02x %02x %02x %02x %02x %02x was found by ISAPnP\n",
+					pr_debug("3c509 with address %02x %02x %02x %02x %02x %02x was found by ISAPnP\n",
 						phys_addr[0] & 0xff, phys_addr[0] >> 8,
 						phys_addr[1] & 0xff, phys_addr[1] >> 8,
 						phys_addr[2] & 0xff, phys_addr[2] >> 8);
@@ -574,19 +574,18 @@ static int __devinit el3_common_init(struct net_device *dev)
 
 	err = register_netdev(dev);
 	if (err) {
-		printk(KERN_ERR "Failed to register 3c5x9 at %#3.3lx, IRQ %d.\n",
+		pr_err("Failed to register 3c5x9 at %#3.3lx, IRQ %d.\n",
 			dev->base_addr, dev->irq);
 		release_region(dev->base_addr, EL3_IO_EXTENT);
 		return err;
 	}
 
-	printk(KERN_INFO "%s: 3c5x9 found at %#3.3lx, %s port, "
-	       "address %pM, IRQ %d.\n",
+	pr_info("%s: 3c5x9 found at %#3.3lx, %s port, address %pM, IRQ %d.\n",
 	       dev->name, dev->base_addr, if_names[(dev->if_port & 0x03)],
 	       dev->dev_addr, dev->irq);
 
 	if (el3_debug > 0)
-		printk(KERN_INFO "%s", version);
+		pr_info("%s", version);
 	return 0;
 
 }
@@ -625,8 +624,8 @@ static int __init el3_mca_probe(struct device *device)
 	irq = pos5 & 0x0f;
 
 
-	printk(KERN_INFO "3c529: found %s at slot %d\n",
-		   el3_mca_adapter_names[mdev->index], slot + 1);
+	pr_info("3c529: found %s at slot %d\n",
+		el3_mca_adapter_names[mdev->index], slot + 1);
 
 	/* claim the slot */
 	strncpy(mdev->name, el3_mca_adapter_names[mdev->index],
@@ -638,7 +637,7 @@ static int __init el3_mca_probe(struct device *device)
 	irq = mca_device_transform_irq(mdev, irq);
 	ioaddr = mca_device_transform_ioport(mdev, ioaddr);
 	if (el3_debug > 2) {
-			printk(KERN_DEBUG "3c529: irq %d  ioaddr 0x%x  ifport %d\n", irq, ioaddr, if_port);
+		pr_debug("3c529: irq %d  ioaddr 0x%x  ifport %d\n", irq, ioaddr, if_port);
 	}
 	EL3WINDOW(0);
 	for (i = 0; i < 3; i++)
@@ -761,7 +760,7 @@ static ushort id_read_eeprom(int index)
 		word = (word << 1) + (inb(id_port) & 0x01);
 
 	if (el3_debug > 3)
-		printk(KERN_DEBUG "  3c509 EEPROM word %d %#4.4x.\n", index, word);
+		pr_debug("  3c509 EEPROM word %d %#4.4x.\n", index, word);
 
 	return word;
 }
@@ -783,13 +782,13 @@ el3_open(struct net_device *dev)
 
 	EL3WINDOW(0);
 	if (el3_debug > 3)
-		printk(KERN_DEBUG "%s: Opening, IRQ %d	 status@%x %4.4x.\n", dev->name,
+		pr_debug("%s: Opening, IRQ %d	 status@%x %4.4x.\n", dev->name,
 			   dev->irq, ioaddr + EL3_STATUS, inw(ioaddr + EL3_STATUS));
 
 	el3_up(dev);
 
 	if (el3_debug > 3)
-		printk(KERN_DEBUG "%s: Opened 3c509  IRQ %d  status %4.4x.\n",
+		pr_debug("%s: Opened 3c509  IRQ %d  status %4.4x.\n",
 			   dev->name, dev->irq, inw(ioaddr + EL3_STATUS));
 
 	return 0;
@@ -801,8 +800,7 @@ el3_tx_timeout (struct net_device *dev)
 	int ioaddr = dev->base_addr;
 
 	/* Transmitter timeout, serious problems. */
-	printk(KERN_WARNING "%s: transmit timed out, Tx_status %2.2x status %4.4x "
-		   "Tx FIFO room %d.\n",
+	pr_warning("%s: transmit timed out, Tx_status %2.2x status %4.4x Tx FIFO room %d.\n",
 		   dev->name, inb(ioaddr + TX_STATUS), inw(ioaddr + EL3_STATUS),
 		   inw(ioaddr + TX_FREE));
 	dev->stats.tx_errors++;
@@ -826,7 +824,7 @@ el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_bytes += skb->len;
 
 	if (el3_debug > 4) {
-		printk(KERN_DEBUG "%s: el3_start_xmit(length = %u) called, status %4.4x.\n",
+		pr_debug("%s: el3_start_xmit(length = %u) called, status %4.4x.\n",
 			   dev->name, skb->len, inw(ioaddr + EL3_STATUS));
 	}
 #if 0
@@ -835,7 +833,7 @@ el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		ushort status = inw(ioaddr + EL3_STATUS);
 		if (status & 0x0001 		/* IRQ line active, missed one. */
 			&& inw(ioaddr + EL3_STATUS) & 1) { 			/* Make sure. */
-			printk(KERN_DEBUG "%s: Missed interrupt, status then %04x now %04x"
+			pr_debug("%s: Missed interrupt, status then %04x now %04x"
 				   "  Tx %2.2x Rx %4.4x.\n", dev->name, status,
 				   inw(ioaddr + EL3_STATUS), inb(ioaddr + TX_STATUS),
 				   inw(ioaddr + RX_STATUS));
@@ -909,7 +907,7 @@ el3_interrupt(int irq, void *dev_id)
 
 	if (el3_debug > 4) {
 		status = inw(ioaddr + EL3_STATUS);
-		printk(KERN_DEBUG "%s: interrupt, status %4.4x.\n", dev->name, status);
+		pr_debug("%s: interrupt, status %4.4x.\n", dev->name, status);
 	}
 
 	while ((status = inw(ioaddr + EL3_STATUS)) &
@@ -920,7 +918,7 @@ el3_interrupt(int irq, void *dev_id)
 
 		if (status & TxAvailable) {
 			if (el3_debug > 5)
-				printk(KERN_DEBUG "	TX room bit was handled.\n");
+				pr_debug("	TX room bit was handled.\n");
 			/* There's room in the FIFO for a full-sized packet. */
 			outw(AckIntr | TxAvailable, ioaddr + EL3_CMD);
 			netif_wake_queue (dev);
@@ -958,7 +956,7 @@ el3_interrupt(int irq, void *dev_id)
 		}
 
 		if (--i < 0) {
-			printk(KERN_ERR "%s: Infinite loop in interrupt, status %4.4x.\n",
+			pr_err("%s: Infinite loop in interrupt, status %4.4x.\n",
 				   dev->name, status);
 			/* Clear all interrupts. */
 			outw(AckIntr | 0xFF, ioaddr + EL3_CMD);
@@ -969,7 +967,7 @@ el3_interrupt(int irq, void *dev_id)
 	}
 
 	if (el3_debug > 4) {
-		printk(KERN_DEBUG "%s: exiting interrupt, status %4.4x.\n", dev->name,
+		pr_debug("%s: exiting interrupt, status %4.4x.\n", dev->name,
 			   inw(ioaddr + EL3_STATUS));
 	}
 	spin_unlock(&lp->lock);
@@ -1017,7 +1015,7 @@ static void update_stats(struct net_device *dev)
 	int ioaddr = dev->base_addr;
 
 	if (el3_debug > 5)
-		printk("   Updating the statistics.\n");
+		pr_debug("   Updating the statistics.\n");
 	/* Turn off statistics updates while reading. */
 	outw(StatsDisable, ioaddr + EL3_CMD);
 	/* Switch to the stats window, and read everything. */
@@ -1047,7 +1045,7 @@ el3_rx(struct net_device *dev)
 	short rx_status;
 
 	if (el3_debug > 5)
-		printk("   In rx_packet(), status %4.4x, rx_status %4.4x.\n",
+		pr_debug("   In rx_packet(), status %4.4x, rx_status %4.4x.\n",
 			   inw(ioaddr+EL3_STATUS), inw(ioaddr+RX_STATUS));
 	while ((rx_status = inw(ioaddr + RX_STATUS)) > 0) {
 		if (rx_status & 0x4000) { /* Error, update stats. */
@@ -1069,7 +1067,7 @@ el3_rx(struct net_device *dev)
 
 			skb = dev_alloc_skb(pkt_len+5);
 			if (el3_debug > 4)
-				printk("Receiving packet size %d status %4.4x.\n",
+				pr_debug("Receiving packet size %d status %4.4x.\n",
 					   pkt_len, rx_status);
 			if (skb != NULL) {
 				skb_reserve(skb, 2);     /* Align IP on 16 byte */
@@ -1088,12 +1086,12 @@ el3_rx(struct net_device *dev)
 			outw(RxDiscard, ioaddr + EL3_CMD);
 			dev->stats.rx_dropped++;
 			if (el3_debug)
-				printk("%s: Couldn't allocate a sk_buff of size %d.\n",
+				pr_debug("%s: Couldn't allocate a sk_buff of size %d.\n",
 					   dev->name, pkt_len);
 		}
 		inw(ioaddr + EL3_STATUS); 				/* Delay. */
 		while (inw(ioaddr + EL3_STATUS) & 0x1000)
-			printk(KERN_DEBUG "	Waiting for 3c509 to discard packet, status %x.\n",
+			pr_debug("	Waiting for 3c509 to discard packet, status %x.\n",
 				   inw(ioaddr + EL3_STATUS) );
 	}
 
@@ -1114,7 +1112,7 @@ set_multicast_list(struct net_device *dev)
 		static int old;
 		if (old != dev->mc_count) {
 			old = dev->mc_count;
-			printk("%s: Setting Rx mode to %d addresses.\n", dev->name, dev->mc_count);
+			pr_debug("%s: Setting Rx mode to %d addresses.\n", dev->name, dev->mc_count);
 		}
 	}
 	spin_lock_irqsave(&lp->lock, flags);
@@ -1137,7 +1135,7 @@ el3_close(struct net_device *dev)
 	struct el3_private *lp = netdev_priv(dev);
 
 	if (el3_debug > 2)
-		printk("%s: Shutting down ethercard.\n", dev->name);
+		pr_debug("%s: Shutting down ethercard.\n", dev->name);
 
 	el3_down(dev);
 
@@ -1384,30 +1382,30 @@ el3_up(struct net_device *dev)
 		EL3WINDOW(4);
 		net_diag = inw(ioaddr + WN4_NETDIAG);
 		net_diag = (net_diag | FD_ENABLE); /* temporarily assume full-duplex will be set */
-		printk("%s: ", dev->name);
+		pr_info("%s: ", dev->name);
 		switch (dev->if_port & 0x0c) {
 			case 12:
 				/* force full-duplex mode if 3c5x9b */
 				if (sw_info & 0x000f) {
-					printk("Forcing 3c5x9b full-duplex mode");
+					pr_cont("Forcing 3c5x9b full-duplex mode");
 					break;
 				}
 			case 8:
 				/* set full-duplex mode based on eeprom config setting */
 				if ((sw_info & 0x000f) && (sw_info & 0x8000)) {
-					printk("Setting 3c5x9b full-duplex mode (from EEPROM configuration bit)");
+					pr_cont("Setting 3c5x9b full-duplex mode (from EEPROM configuration bit)");
 					break;
 				}
 			default:
 				/* xcvr=(0 || 4) OR user has an old 3c5x9 non "B" model */
-				printk("Setting 3c5x9/3c5x9B half-duplex mode");
+				pr_cont("Setting 3c5x9/3c5x9B half-duplex mode");
 				net_diag = (net_diag & ~FD_ENABLE); /* disable full duplex */
 		}
 
 		outw(net_diag, ioaddr + WN4_NETDIAG);
-		printk(" if_port: %d, sw_info: %4.4x\n", dev->if_port, sw_info);
+		pr_cont(" if_port: %d, sw_info: %4.4x\n", dev->if_port, sw_info);
 		if (el3_debug > 3)
-			printk("%s: 3c5x9 net diag word is now: %4.4x.\n", dev->name, net_diag);
+			pr_debug("%s: 3c5x9 net diag word is now: %4.4x.\n", dev->name, net_diag);
 		/* Enable link beat and jabber check. */
 		outw(inw(ioaddr + WN4_MEDIA) | MEDIA_TP, ioaddr + WN4_MEDIA);
 	}
@@ -1535,7 +1533,7 @@ static int __init el3_init_module(void)
 	}
 	if (id_port >= 0x200) {
 		id_port = 0;
-		printk(KERN_ERR "No I/O port available for 3c509 activation.\n");
+		pr_err("No I/O port available for 3c509 activation.\n");
 	} else {
 		ret = isa_register_driver(&el3_isa_driver, EL3_MAX_CARDS);
 		if (!ret)
-- 
1.6.3.1

