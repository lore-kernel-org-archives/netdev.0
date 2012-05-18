From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 4/5] cirrus: cs89x0: Neaten debugging and logging
Date: Fri, 18 May 2012 15:56:30 -0700
Message-ID: <330e39158fcb7f0d088640a05f5c4f11ce93ced1.1337381533.git.joe@perches.com>
References: <cover.1337381533.git.joe@perches.com>
Cc: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1337381533.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce and use a debug macro to test and print.
Convert printks to pr_<level>.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/cirrus/cs89x0.c |  187 +++++++++++++++-------------------
 1 files changed, 82 insertions(+), 105 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 6e5b2c7..859f8be 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -77,8 +77,14 @@
 
 #include "cs89x0.h"
 
+#define cs89_dbg(val, level, fmt, ...)				\
+do {								\
+	if (val <= net_debug)					\
+		pr_##level(fmt, ##__VA_ARGS__);			\
+} while (0)
+
 static char version[] __initdata =
-	"v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew Morton\n";
+	"v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew Morton";
 
 #define DRV_NAME "cs89x0"
 
@@ -315,8 +321,7 @@ get_eeprom_data(struct net_device *dev, int off, int len, int *buffer)
 {
 	int i;
 
-	if (net_debug > 3)
-		printk("EEPROM data from %x for %x:\n", off, len);
+	cs89_dbg(3, info, "EEPROM data from %x for %x:\n", off, len);
 	for (i = 0; i < len; i++) {
 		if (wait_eeprom_ready(dev) < 0)
 			return -1;
@@ -325,11 +330,9 @@ get_eeprom_data(struct net_device *dev, int off, int len, int *buffer)
 		if (wait_eeprom_ready(dev) < 0)
 			return -1;
 		buffer[i] = readreg(dev, PP_EEData);
-		if (net_debug > 3)
-			printk("%04x ", buffer[i]);
+		cs89_dbg(3, cont, "%04x ", buffer[i]);
 	}
-	if (net_debug > 3)
-		printk("\n");
+	cs89_dbg(3, cont, "\n");
 	return 0;
 }
 
@@ -435,8 +438,7 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 	if (lp->chip_type != CS8900 && lp->chip_revision >= 'C')
 		lp->send_cmd = TX_NOW;
 
-	if (net_debug)
-		printk_once(version);
+	pr_info_once("%s\n", version);
 
 	pr_info("%s: cs89%c0%s rev %c found at %p ",
 		dev->name,
@@ -495,18 +497,17 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 			lp->adapter_cnf |=  A_CNF_AUI | A_CNF_10B_T |
 				A_CNF_MEDIA_AUI | A_CNF_MEDIA_10B_T | A_CNF_MEDIA_AUTO;
 
-		if (net_debug > 1)
-			pr_info("%s: PP_LineCTL=0x%x, adapter_cnf=0x%x\n",
-				dev->name, i, lp->adapter_cnf);
+		cs89_dbg(1, info, "%s: PP_LineCTL=0x%x, adapter_cnf=0x%x\n",
+			 dev->name, i, lp->adapter_cnf);
 
 		/* IRQ. Other chips already probe, see below. */
 		if (lp->chip_type == CS8900)
 			lp->isa_config = readreg(dev, PP_CS8900_ISAINT) & INT_NO_MASK;
 
-		printk("[Cirrus EEPROM] ");
+		pr_cont("[Cirrus EEPROM] ");
 	}
 
-	printk("\n");
+	pr_cont("\n");
 
 	/* First check to see if an EEPROM is attached. */
 
@@ -542,9 +543,8 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 			dev->dev_addr[i * 2] = eeprom_buff[i];
 			dev->dev_addr[i * 2 + 1] = eeprom_buff[i] >> 8;
 		}
-		if (net_debug > 1)
-			pr_debug("%s: new adapter_cnf: 0x%x\n",
-				 dev->name, lp->adapter_cnf);
+		cs89_dbg(1, debug, "%s: new adapter_cnf: 0x%x\n",
+			 dev->name, lp->adapter_cnf);
 	}
 
 	/* allow them to force multiple transceivers.  If they force multiple, autosense */
@@ -572,9 +572,8 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 			lp->adapter_cnf |= A_CNF_MEDIA_10B_2;
 	}
 
-	if (net_debug > 1)
-		pr_debug("%s: after force 0x%x, adapter_cnf=0x%x\n",
-			 dev->name, lp->force, lp->adapter_cnf);
+	cs89_dbg(1, debug, "%s: after force 0x%x, adapter_cnf=0x%x\n",
+		 dev->name, lp->force, lp->adapter_cnf);
 
 	/* FIXME: We don't let you set dc-dc polarity or low RX squelch from the command line: add it here */
 
@@ -629,24 +628,23 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 			dev->irq = i;
 	}
 
-	printk(" IRQ %d", dev->irq);
+	pr_cont(" IRQ %d", dev->irq);
 
 #if ALLOW_DMA
 	if (lp->use_dma) {
 		get_dma_channel(dev);
-		printk(", DMA %d", dev->dma);
+		pr_cont(", DMA %d", dev->dma);
 	} else
 #endif
-		printk(", programmed I/O");
+		pr_cont(", programmed I/O");
 
 	/* print the ethernet address. */
-	printk(", MAC %pM\n", dev->dev_addr);
+	pr_cont(", MAC %pM\n", dev->dev_addr);
 
 	dev->netdev_ops	= &net_ops;
 	dev->watchdog_timeo = HZ;
 
-	if (net_debug)
-		printk("cs89x0_probe1() successful\n");
+	cs89_dbg(0, info, "cs89x0_probe1() successful\n");
 
 	retval = register_netdev(dev);
 	if (retval)
@@ -693,8 +691,7 @@ cs89x0_ioport_probe(struct net_device *dev, unsigned long ioport, int modular)
 	 * will skip the test for the ADD_PORT.
 	 */
 	if (ioport & 1) {
-		if (net_debug > 1)
-			pr_info("%s: odd ioaddr 0x%lx\n", dev->name, ioport);
+		cs89_dbg(1, info, "%s: odd ioaddr 0x%lx\n", dev->name, ioport);
 		if ((ioport & 2) != 2) {
 			if ((ioread16(io_mem + ADD_PORT) & ADD_MASK) !=
 			    ADD_SIG) {
@@ -742,8 +739,7 @@ struct net_device * __init cs89x0_probe(int unit)
 	io = dev->base_addr;
 	irq = dev->irq;
 
-	if (net_debug)
-		pr_info("cs89x0_probe(0x%x)\n", io);
+	cs89_dbg(0, info, "cs89x0_probe(0x%x)\n", io);
 
 	if (io > 0x1ff)	{	/* Check a single specified location. */
 		err = cs89x0_ioport_probe(dev, io, 0);
@@ -817,18 +813,15 @@ set_dma_cfg(struct net_device *dev)
 
 	if (lp->use_dma) {
 		if ((lp->isa_config & ANY_ISA_DMA) == 0) {
-			if (net_debug > 3)
-				printk("set_dma_cfg(): no DMA\n");
+			cs89_dbg(3, err, "set_dma_cfg(): no DMA\n");
 			return;
 		}
 		if (lp->isa_config & ISA_RxDMA) {
 			lp->curr_rx_cfg |= RX_DMA_ONLY;
-			if (net_debug > 3)
-				printk("set_dma_cfg(): RX_DMA_ONLY\n");
+			cs89_dbg(3, info, "set_dma_cfg(): RX_DMA_ONLY\n");
 		} else {
 			lp->curr_rx_cfg |= AUTO_RX_DMA;	/* not that we support it... */
-			if (net_debug > 3)
-				printk("set_dma_cfg(): AUTO_RX_DMA\n");
+			cs89_dbg(3, info, "set_dma_cfg(): AUTO_RX_DMA\n");
 		}
 	}
 }
@@ -871,10 +864,10 @@ dma_rx(struct net_device *dev)
 	status = bp[0] + (bp[1] << 8);
 	length = bp[2] + (bp[3] << 8);
 	bp += 4;
-	if (net_debug > 5) {
-		printk("%s: receiving DMA packet at %lx, status %x, length %x\n",
-		       dev->name, (unsigned long)bp, status, length);
-	}
+
+	cs89_dbg(5, debug, "%s: receiving DMA packet at %lx, status %x, length %x\n",
+		 dev->name, (unsigned long)bp, status, length);
+
 	if ((status & RX_OK) == 0) {
 		count_rx_errors(status, dev);
 		goto skip_this_frame;
@@ -883,9 +876,9 @@ dma_rx(struct net_device *dev)
 	/* Malloc up new buffer. */
 	skb = netdev_alloc_skb(dev, length + 2);
 	if (skb == NULL) {
-		if (net_debug)	/* I don't think we want to do this to a stressed system */
-			printk("%s: Memory squeeze, dropping packet\n",
-			       dev->name);
+		/* I don't think we want to do this to a stressed system */
+		cs89_dbg(0, err, "%s: Memory squeeze, dropping packet\n",
+			 dev->name);
 		dev->stats.rx_dropped++;
 
 		/* AKPM: advance bp to the next frame */
@@ -911,12 +904,11 @@ skip_this_frame:
 		bp -= lp->dmasize*1024;
 	lp->rx_dma_ptr = bp;
 
-	if (net_debug > 3) {
-		printk("%s: received %d byte DMA packet of type %x\n",
-		       dev->name, length,
-		       ((skb->data[ETH_ALEN + ETH_ALEN] << 8) |
-			skb->data[ETH_ALEN + ETH_ALEN + 1]));
-	}
+	cs89_dbg(3, info, "%s: received %d byte DMA packet of type %x\n",
+		 dev->name, length,
+		 ((skb->data[ETH_ALEN + ETH_ALEN] << 8) |
+		  skb->data[ETH_ALEN + ETH_ALEN + 1]));
+
 	skb->protocol = eth_type_trans(skb, dev);
 	netif_rx(skb);
 	dev->stats.rx_packets++;
@@ -998,8 +990,7 @@ detect_tp(struct net_device *dev)
 	int timenow = jiffies;
 	int fdx;
 
-	if (net_debug > 1)
-		printk("%s: Attempting TP\n", dev->name);
+	cs89_dbg(1, debug, "%s: Attempting TP\n", dev->name);
 
 	/* If connected to another full duplex capable 10-Base-T card
 	 * the link pulses seem to be lost when the auto detect bit in
@@ -1023,7 +1014,8 @@ detect_tp(struct net_device *dev)
 		switch (lp->force & 0xf0) {
 #if 0
 		case FORCE_AUTO:
-			printk("%s: cs8900 doesn't autonegotiate\n", dev->name);
+			pr_info("%s: cs8900 doesn't autonegotiate\n",
+				dev->name);
 			return DETECTED_NONE;
 #endif
 			/* CS8900 doesn't support AUTO, change to HALF*/
@@ -1102,18 +1094,15 @@ send_test_pkt(struct net_device *dev)
 	/* Write the contents of the packet */
 	writewords(lp, TX_FRAME_PORT, test_packet, (ETH_ZLEN + 1) >> 1);
 
-	if (net_debug > 1)
-		printk("Sending test packet ");
+	cs89_dbg(1, debug, "Sending test packet ");
 	/* wait a couple of jiffies for packet to be received */
 	for (timenow = jiffies; jiffies - timenow < 3;)
 		;
 	if ((readreg(dev, PP_TxEvent) & TX_SEND_OK_BITS) == TX_OK) {
-		if (net_debug > 1)
-			printk("succeeded\n");
+		cs89_dbg(1, cont, "succeeded\n");
 		return 1;
 	}
-	if (net_debug > 1)
-		printk("failed\n");
+	cs89_dbg(1, cont, "failed\n");
 	return 0;
 }
 
@@ -1123,8 +1112,7 @@ detect_aui(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 
-	if (net_debug > 1)
-		printk("%s: Attempting AUI\n", dev->name);
+	cs89_dbg(1, debug, "%s: Attempting AUI\n", dev->name);
 	control_dc_dc(dev, 0);
 
 	writereg(dev, PP_LineCTL, (lp->linectl & ~AUTO_AUI_10BASET) | AUI_ONLY);
@@ -1140,8 +1128,7 @@ detect_bnc(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 
-	if (net_debug > 1)
-		printk("%s: Attempting BNC\n", dev->name);
+	cs89_dbg(1, debug, "%s: Attempting BNC\n", dev->name);
 	control_dc_dc(dev, 1);
 
 	writereg(dev, PP_LineCTL, (lp->linectl & ~AUTO_AUI_10BASET) | AUI_ONLY);
@@ -1255,12 +1242,10 @@ net_open(struct net_device *dev)
 			       dev->name, lp->dmasize);
 			goto release_irq;
 		}
-		if (net_debug > 1) {
-			printk("%s: dma %lx %lx\n",
-			       dev->name,
-			       (unsigned long)lp->dma_buff,
-			       (unsigned long)isa_virt_to_bus(lp->dma_buff));
-		}
+		cs89_dbg(1, debug, "%s: dma %lx %lx\n",
+			 dev->name,
+			 (unsigned long)lp->dma_buff,
+			 (unsigned long)isa_virt_to_bus(lp->dma_buff));
 		if ((unsigned long)lp->dma_buff >= MAX_DMA_ADDRESS ||
 		    !dma_page_eq(lp->dma_buff,
 				 lp->dma_buff + lp->dmasize * 1024 - 1)) {
@@ -1442,8 +1427,7 @@ release_irq:
 #endif
 			 ));
 	netif_start_queue(dev);
-	if (net_debug > 1)
-		printk("cs89x0: net_open() succeeded\n");
+	cs89_dbg(1, debug, "net_open() succeeded\n");
 	return 0;
 bad_out:
 	return ret;
@@ -1453,10 +1437,9 @@ static void net_timeout(struct net_device *dev)
 {
 	/* If we get here, some higher level has decided we are broken.
 	   There should really be a "kick me" function call instead. */
-	if (net_debug > 0)
-		printk("%s: transmit timed out, %s?\n",
-		       dev->name,
-		       tx_done(dev) ? "IRQ conflict" : "network cable problem");
+	cs89_dbg(0, err, "%s: transmit timed out, %s?\n",
+		 dev->name,
+		 tx_done(dev) ? "IRQ conflict" : "network cable problem");
 	/* Try to restart the adaptor. */
 	netif_wake_queue(dev);
 }
@@ -1466,12 +1449,10 @@ static netdev_tx_t net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
-	if (net_debug > 3) {
-		printk("%s: sent %d byte packet of type %x\n",
-		       dev->name, skb->len,
-		       ((skb->data[ETH_ALEN + ETH_ALEN] << 8) |
-			skb->data[ETH_ALEN + ETH_ALEN + 1]));
-	}
+	cs89_dbg(3, debug, "%s: sent %d byte packet of type %x\n",
+		 dev->name, skb->len,
+		 ((skb->data[ETH_ALEN + ETH_ALEN] << 8) |
+		  skb->data[ETH_ALEN + ETH_ALEN + 1]));
 
 	/* keep the upload from being interrupted, since we
 	 * ask the chip to start transmitting before the
@@ -1492,8 +1473,7 @@ static netdev_tx_t net_send_packet(struct sk_buff *skb, struct net_device *dev)
 		 */
 
 		spin_unlock_irqrestore(&lp->lock, flags);
-		if (net_debug)
-			printk("cs89x0: Tx buffer not free!\n");
+		cs89_dbg(0, err, "Tx buffer not free!\n");
 		return NETDEV_TX_BUSY;
 	}
 	/* Write the contents of the packet */
@@ -1537,8 +1517,7 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 	 * vista, baby!
 	 */
 	while ((status = ioread16(lp->virt_addr + ISQ_PORT))) {
-		if (net_debug > 4)
-			printk("%s: event=%04x\n", dev->name, status);
+		cs89_dbg(4, debug, "%s: event=%04x\n", dev->name, status);
 		handled = 1;
 		switch (status & ISQ_EVENT_MASK) {
 		case ISQ_RECEIVER_EVENT:
@@ -1576,9 +1555,8 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 				netif_wake_queue(dev);	/* Inform upper layers. */
 			}
 			if (status & TX_UNDERRUN) {
-				if (net_debug > 0)
-					printk("%s: transmit underrun\n",
-					       dev->name);
+				cs89_dbg(0, err, "%s: transmit underrun\n",
+					 dev->name);
 				lp->send_underrun++;
 				if (lp->send_underrun == 3)
 					lp->send_cmd = TX_AFTER_381;
@@ -1596,18 +1574,20 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 			if (lp->use_dma && (status & RX_DMA)) {
 				int count = readreg(dev, PP_DmaFrameCnt);
 				while (count) {
-					if (net_debug > 5)
-						printk("%s: receiving %d DMA frames\n",
-						       dev->name, count);
-					if (net_debug > 2 && count > 1)
-						printk("%s: receiving %d DMA frames\n",
-						       dev->name, count);
+					cs89_dbg(5, debug,
+						 "%s: receiving %d DMA frames\n",
+						 dev->name, count);
+					if (count > 1)
+						cs89_dbg(2, debug,
+							 "%s: receiving %d DMA frames\n",
+							 dev->name, count);
 					dma_rx(dev);
 					if (--count == 0)
 						count = readreg(dev, PP_DmaFrameCnt);
-					if (net_debug > 2 && count > 0)
-						printk("%s: continuing with %d DMA frames\n",
-						       dev->name, count);
+					if (count > 0)
+						cs89_dbg(2, debug,
+							 "%s: continuing with %d DMA frames\n",
+							 dev->name, count);
 				}
 			}
 #endif
@@ -1669,12 +1649,10 @@ net_rx(struct net_device *dev)
 	if (length & 1)
 		skb->data[length-1] = ioread16(lp->virt_addr + RX_FRAME_PORT);
 
-	if (net_debug > 3) {
-		printk("%s: received %d byte packet of type %x\n",
-		       dev->name, length,
-		       (skb->data[ETH_ALEN + ETH_ALEN] << 8) |
-		       skb->data[ETH_ALEN + ETH_ALEN + 1]);
-	}
+	cs89_dbg(3, debug, "%s: received %d byte packet of type %x\n",
+		 dev->name, length,
+		 (skb->data[ETH_ALEN + ETH_ALEN] << 8) |
+		 skb->data[ETH_ALEN + ETH_ALEN + 1]);
 
 	skb->protocol = eth_type_trans(skb, dev);
 	netif_rx(skb);
@@ -1778,9 +1756,8 @@ static int set_mac_address(struct net_device *dev, void *p)
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
-	if (net_debug)
-		printk("%s: Setting MAC address to %pM\n",
-		       dev->name, dev->dev_addr);
+	cs89_dbg(0, debug, "%s: Setting MAC address to %pM\n",
+		 dev->name, dev->dev_addr);
 
 	/* set the Ethernet address */
 	for (i = 0; i < ETH_ALEN / 2; i++)
-- 
1.7.8.111.gad25c.dirty
