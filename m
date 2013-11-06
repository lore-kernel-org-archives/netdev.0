From: Matthew Whitehead <tedheadster@gmail.com>
Subject: [PATCH net-next] 8390 : Replace ei_debug with msg_enable/NETIF_MSG_* feature
Date: Wed,  6 Nov 2013 15:56:58 -0500
Message-ID: <1383771418-28616-1-git-send-email-tedheadster@gmail.com>
Cc: Matthew Whitehead <tedheadster@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f43.google.com ([209.85.128.43]:60328 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755610Ab3KFU5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 15:57:16 -0500
Received: by mail-qe0-f43.google.com with SMTP id nc12so68721qeb.16
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 12:57:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed the shared ei_debug variable. Replaced it by adding u32 msg_enable to
the private struct ei_device. Now each 8390 ethernet instance has a per-device
logging variable.

Changed printk() calls to netdev_(dbg|info|warn|err) when possible.

Tested on: ne, ne2k-pci, smc-ultra, and wd hardware.

Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>
---
 drivers/net/ethernet/8390/8390.h      |    7 +--
 drivers/net/ethernet/8390/apne.c      |   62 ++++++++++-------
 drivers/net/ethernet/8390/ax88796.c   |   23 ++++++-
 drivers/net/ethernet/8390/axnet_cs.c  |  118 +++++++++++++++++----------------
 drivers/net/ethernet/8390/etherh.c    |   49 +++++++++-----
 drivers/net/ethernet/8390/hydra.c     |   12 +++-
 drivers/net/ethernet/8390/lib8390.c   |   65 +++++++++++--------
 drivers/net/ethernet/8390/mac8390.c   |   20 ++++--
 drivers/net/ethernet/8390/mcf8390.c   |    7 ++-
 drivers/net/ethernet/8390/ne-h8300.c  |   75 ++++++++++++---------
 drivers/net/ethernet/8390/ne.c        |   95 +++++++++++++++------------
 drivers/net/ethernet/8390/ne2k-pci.c  |   54 ++++++++++-----
 drivers/net/ethernet/8390/pcnet_cs.c  |   61 ++++++++++--------
 drivers/net/ethernet/8390/smc-ultra.c |   51 +++++++++-----
 drivers/net/ethernet/8390/stnic.c     |   32 ++++++---
 drivers/net/ethernet/8390/wd.c        |   45 ++++++++-----
 drivers/net/ethernet/8390/zorro8390.c |   20 ++++--
 17 files changed, 479 insertions(+), 317 deletions(-)

diff --git a/drivers/net/ethernet/8390/8390.h b/drivers/net/ethernet/8390/8390.h
index 2923c51..3e2f2c2 100644
--- a/drivers/net/ethernet/8390/8390.h
+++ b/drivers/net/ethernet/8390/8390.h
@@ -21,12 +21,6 @@ struct e8390_pkt_hdr {
   unsigned short count; /* header + packet length in bytes */
 };
 
-#ifdef notdef
-extern int ei_debug;
-#else
-#define ei_debug 1
-#endif
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 void ei_poll(struct net_device *dev);
 void eip_poll(struct net_device *dev);
@@ -99,6 +93,7 @@ struct ei_device {
 	u32 *reg_offset;		/* Register mapping table */
 	spinlock_t page_lock;		/* Page register locks */
 	unsigned long priv;		/* Private field to store bus IDs etc. */
+	u32 msg_enable;			/* debug message level */
 #ifdef AX88796_PLATFORM
 	unsigned char rxcr_base;	/* default value for RXCR */
 #endif
diff --git a/drivers/net/ethernet/8390/apne.c b/drivers/net/ethernet/8390/apne.c
index 912ed7a..046d14c 100644
--- a/drivers/net/ethernet/8390/apne.c
+++ b/drivers/net/ethernet/8390/apne.c
@@ -116,9 +116,15 @@ static const char version[] =
 
 static int apne_owned;	/* signal if card already owned */
 
+static u32 apne_debug;
+module_param_named(debug, apne_debug, uint, (S_IRUSR|S_IRGRP|S_IROTH));
+MODULE_PARM_DESC(debug, "Debug message level (see linux/netdevice.h for bitmap)");
+
 struct net_device * __init apne_probe(int unit)
 {
 	struct net_device *dev;
+	struct ei_device *ei_local;
+
 #ifndef MANUAL_CONFIG
 	char tuple[8];
 #endif
@@ -133,11 +139,11 @@ struct net_device * __init apne_probe(int unit)
 	if ( !(AMIGAHW_PRESENT(PCMCIA)) )
 		return ERR_PTR(-ENODEV);
 
-	printk("Looking for PCMCIA ethernet card : ");
+	printk(KERN_INFO "Looking for PCMCIA ethernet card : ");
 
 	/* check if a card is inserted */
 	if (!(PCMCIA_INSERTED)) {
-		printk("NO PCMCIA card inserted\n");
+		printk(KERN_INFO "NO PCMCIA card inserted\n");
 		return ERR_PTR(-ENODEV);
 	}
 
@@ -148,6 +154,8 @@ struct net_device * __init apne_probe(int unit)
 		sprintf(dev->name, "eth%d", unit);
 		netdev_boot_setup_check(dev);
 	}
+	ei_local = netdev_priv(dev);
+	ei_local->msg_enable = apne_debug;
 
 	/* disable pcmcia irq for readtuple */
 	pcmcia_disable_irq();
@@ -155,14 +163,14 @@ struct net_device * __init apne_probe(int unit)
 #ifndef MANUAL_CONFIG
 	if ((pcmcia_copy_tuple(CISTPL_FUNCID, tuple, 8) < 3) ||
 		(tuple[2] != CISTPL_FUNCID_NETWORK)) {
-		printk("not an ethernet card\n");
+		netdev_info(dev, "not an ethernet card\n");
 		/* XXX: shouldn't we re-enable irq here? */
 		free_netdev(dev);
 		return ERR_PTR(-ENODEV);
 	}
 #endif
 
-	printk("ethernet PCMCIA card inserted\n");
+	netdev_info(dev, "ethernet PCMCIA card inserted\n");
 
 	if (!init_pcmcia()) {
 		/* XXX: shouldn't we re-enable irq here? */
@@ -205,10 +213,10 @@ static int __init apne_probe1(struct net_device *dev, int ioaddr)
 #endif
     static unsigned version_printed;
 
-    if (ei_debug  &&  version_printed++ == 0)
-	printk(version);
+    if ((apne_debug & NETIF_MSG_DRV)  &&  version_printed++ == 0)
+		netdev_info(dev, version);
 
-    printk("PCMCIA NE*000 ethercard probe");
+    netdev_info(dev, "PCMCIA NE*000 ethercard probe");
 
     /* Reset card. Who knows what dain-bramaged state it was left in. */
     {	unsigned long reset_start_time = jiffies;
@@ -217,7 +225,7 @@ static int __init apne_probe1(struct net_device *dev, int ioaddr)
 
 	while ((inb(ioaddr + NE_EN0_ISR) & ENISR_RESET) == 0)
 		if (time_after(jiffies, reset_start_time + 2*HZ/100)) {
-			printk(" not found (no reset ack).\n");
+			pr_cont(" not found (no reset ack).\n");
 			return -ENODEV;
 		}
 
@@ -288,7 +296,7 @@ static int __init apne_probe1(struct net_device *dev, int ioaddr)
 	start_page = 0x01;
 	stop_page = (wordlength == 2) ? 0x40 : 0x20;
     } else {
-	printk(" not found.\n");
+	pr_cont(" not found.\n");
 	return -ENXIO;
 
     }
@@ -320,9 +328,9 @@ static int __init apne_probe1(struct net_device *dev, int ioaddr)
     for (i = 0; i < ETH_ALEN; i++)
 	dev->dev_addr[i] = SA_prom[i];
 
-    printk(" %pM\n", dev->dev_addr);
+    netdev_info(dev, " %pM\n", dev->dev_addr);
 
-    printk("%s: %s found.\n", dev->name, name);
+    netdev_info(dev, "%s found.\n", name);
 
     ei_status.name = name;
     ei_status.tx_start_page = start_page;
@@ -352,10 +360,12 @@ static void
 apne_reset_8390(struct net_device *dev)
 {
     unsigned long reset_start_time = jiffies;
+    struct ei_device *ei_local = netdev_priv(dev);
 
     init_pcmcia();
 
-    if (ei_debug > 1) printk("resetting the 8390 t=%ld...", jiffies);
+    if (ei_local->msg_enable & NETIF_MSG_HW)
+		netdev_dbg(dev, "resetting the 8390 t=%ld...\n", jiffies);
 
     outb(inb(NE_BASE + NE_RESET), NE_BASE + NE_RESET);
 
@@ -365,8 +375,8 @@ apne_reset_8390(struct net_device *dev)
     /* This check _should_not_ be necessary, omit eventually. */
     while ((inb(NE_BASE+NE_EN0_ISR) & ENISR_RESET) == 0)
 	if (time_after(jiffies, reset_start_time + 2*HZ/100)) {
-	    printk("%s: ne_reset_8390() did not complete.\n", dev->name);
-	    break;
+		netdev_err(dev, "ne_reset_8390() did not complete.\n");
+		break;
 	}
     outb(ENISR_RESET, NE_BASE + NE_EN0_ISR);	/* Ack intr. */
 }
@@ -386,9 +396,9 @@ apne_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr, int ring_pa
 
     /* This *shouldn't* happen. If it does, it's the last thing you'll see */
     if (ei_status.dmaing) {
-	printk("%s: DMAing conflict in ne_get_8390_hdr "
-	   "[DMAstat:%d][irqlock:%d][intr:%d].\n",
-	   dev->name, ei_status.dmaing, ei_status.irqlock, dev->irq);
+	netdev_err(dev, "DMAing conflict in ne_get_8390_hdr "
+		   "[DMAstat:%d][irqlock:%d][intr:%d].\n",
+		   ei_status.dmaing, ei_status.irqlock, dev->irq);
 	return;
     }
 
@@ -433,9 +443,9 @@ apne_block_input(struct net_device *dev, int count, struct sk_buff *skb, int rin
 
     /* This *shouldn't* happen. If it does, it's the last thing you'll see */
     if (ei_status.dmaing) {
-	printk("%s: DMAing conflict in ne_block_input "
-	   "[DMAstat:%d][irqlock:%d][intr:%d].\n",
-	   dev->name, ei_status.dmaing, ei_status.irqlock, dev->irq);
+		netdev_err(dev, "DMAing conflict in ne_block_input "
+			   "[DMAstat:%d][irqlock:%d][intr:%d].\n",
+			   ei_status.dmaing, ei_status.irqlock, dev->irq);
 	return;
     }
     ei_status.dmaing |= 0x01;
@@ -481,9 +491,9 @@ apne_block_output(struct net_device *dev, int count,
 
     /* This *shouldn't* happen. If it does, it's the last thing you'll see */
     if (ei_status.dmaing) {
-	printk("%s: DMAing conflict in ne_block_output."
-	   "[DMAstat:%d][irqlock:%d][intr:%d]\n",
-	   dev->name, ei_status.dmaing, ei_status.irqlock, dev->irq);
+		netdev_err(dev, "DMAing conflict in ne_block_output."
+			   "[DMAstat:%d][irqlock:%d][intr:%d]\n",
+			   ei_status.dmaing, ei_status.irqlock, dev->irq);
 	return;
     }
     ei_status.dmaing |= 0x01;
@@ -513,7 +523,7 @@ apne_block_output(struct net_device *dev, int count,
 
     while ((inb(NE_BASE + NE_EN0_ISR) & ENISR_RDC) == 0)
 	if (time_after(jiffies, dma_start + 2*HZ/100)) {	/* 20ms */
-		printk("%s: timeout waiting for Tx RDC.\n", dev->name);
+		netdev_warn(dev, "timeout waiting for Tx RDC.\n");
 		apne_reset_8390(dev);
 		NS8390_init(dev,1);
 		break;
@@ -536,8 +546,8 @@ static irqreturn_t apne_interrupt(int irq, void *dev_id)
         pcmcia_ack_int(pcmcia_intreq);
         return IRQ_NONE;
     }
-    if (ei_debug > 3)
-        printk("pcmcia intreq = %x\n", pcmcia_intreq);
+    if (apne_debug & NETIF_MSG_INTR)
+	printk(KERN_DEBUG "pcmcia intreq = %x\n", pcmcia_intreq);
     pcmcia_disable_irq();			/* to get rid of the sti() within ei_interrupt */
     ei_interrupt(irq, dev_id);
     pcmcia_ack_int(pcmcia_get_intreq());
diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index 36fa577..6da4cfe 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -78,6 +78,8 @@ static unsigned char version[] = "ax88796.c: Copyright 2005,2007 Simtec Electron
 
 #define AX_GPOC_PPDSET	BIT(6)
 
+static u32 ax_debug;
+
 /* device private data */
 
 struct ax_device {
@@ -147,8 +149,8 @@ static void ax_reset_8390(struct net_device *dev)
 	unsigned long reset_start_time = jiffies;
 	void __iomem *addr = (void __iomem *)dev->base_addr;
 
-	if (ei_debug > 1)
-		netdev_dbg(dev, "resetting the 8390 t=%ld\n", jiffies);
+	if (ei_local->msg_enable & NETIF_MSG_HW)
+		netdev_dbg(dev, "resetting the 8390 t=%ld...\n", jiffies);
 
 	ei_outb(ei_inb(addr + NE_RESET), addr + NE_RESET);
 
@@ -496,12 +498,28 @@ static int ax_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	return phy_ethtool_sset(phy_dev, cmd);
 }
 
+static u32 ax_get_msglevel(struct net_device *dev)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+
+	return ei_local->msg_enable;
+}
+
+static void ax_set_msglevel(struct net_device *dev, u32 v)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+
+	ei_local->msg_enable = v;
+}
+
 static const struct ethtool_ops ax_ethtool_ops = {
 	.get_drvinfo		= ax_get_drvinfo,
 	.get_settings		= ax_get_settings,
 	.set_settings		= ax_set_settings,
 	.get_link		= ethtool_op_get_link,
 	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_msglevel		= ax_get_msglevel,
+	.set_msglevel		= ax_set_msglevel,
 };
 
 #ifdef CONFIG_AX88796_93CX6
@@ -763,6 +781,7 @@ static int ax_init_dev(struct net_device *dev)
 	ei_local->block_output = &ax_block_output;
 	ei_local->get_8390_hdr = &ax_get_8390_hdr;
 	ei_local->priv = 0;
+	ei_local->msg_enable = ax_debug;
 
 	dev->netdev_ops = &ax_netdev_ops;
 	dev->ethtool_ops = &ax_ethtool_ops;
diff --git a/drivers/net/ethernet/8390/axnet_cs.c b/drivers/net/ethernet/8390/axnet_cs.c
index d801c14..1ad163b 100644
--- a/drivers/net/ethernet/8390/axnet_cs.c
+++ b/drivers/net/ethernet/8390/axnet_cs.c
@@ -105,6 +105,7 @@ static void AX88190_init(struct net_device *dev, int startp);
 static int ax_open(struct net_device *dev);
 static int ax_close(struct net_device *dev);
 static irqreturn_t ax_interrupt(int irq, void *dev_id);
+static u32 axnet_debug;
 
 /*====================================================================*/
 
@@ -152,6 +153,7 @@ static int axnet_probe(struct pcmcia_device *link)
 	return -ENOMEM;
 
     ei_local = netdev_priv(dev);
+    ei_local->msg_enable = axnet_debug;
     spin_lock_init(&ei_local->page_lock);
 
     info = PRIV(dev);
@@ -650,11 +652,12 @@ static void block_input(struct net_device *dev, int count,
 			struct sk_buff *skb, int ring_offset)
 {
     unsigned int nic_base = dev->base_addr;
+    struct ei_device *ei_local = netdev_priv(dev);
     int xfer_count = count;
     char *buf = skb->data;
 
-    if ((ei_debug > 4) && (count != 4))
-	    pr_debug("%s: [bi=%d]\n", dev->name, count+4);
+    if ((ei_local->msg_enable & NETIF_MSG_RX_STATUS) && (count != 4))
+	netdev_dbg(dev, "[bi=%d]\n", count+4);
     outb_p(ring_offset & 0xff, nic_base + EN0_RSARLO);
     outb_p(ring_offset >> 8, nic_base + EN0_RSARHI);
     outb_p(E8390_RREAD+E8390_START, nic_base + AXNET_CMD);
@@ -810,11 +813,6 @@ module_pcmcia_driver(axnet_cs_driver);
 #define ei_block_input (ei_local->block_input)
 #define ei_get_8390_hdr (ei_local->get_8390_hdr)
 
-/* use 0 for production, 1 for verification, >2 for debug */
-#ifndef ei_debug
-int ei_debug = 1;
-#endif
-
 /* Index to functions. */
 static void ei_tx_intr(struct net_device *dev);
 static void ei_tx_err(struct net_device *dev);
@@ -925,11 +923,10 @@ static void axnet_tx_timeout(struct net_device *dev)
 	isr = inb(e8390_base+EN0_ISR);
 	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 
-	netdev_printk(KERN_DEBUG, dev,
-		      "Tx timed out, %s TSR=%#2x, ISR=%#2x, t=%d.\n",
-		      (txsr & ENTSR_ABT) ? "excess collisions." :
-		      (isr) ? "lost interrupt?" : "cable problem?",
-		      txsr, isr, tickssofar);
+	netdev_dbg(dev, "Tx timed out, %s TSR=%#2x, ISR=%#2x, t=%d.\n",
+		   (txsr & ENTSR_ABT) ? "excess collisions." :
+		   (isr) ? "lost interrupt?" : "cable problem?",
+		   txsr, isr, tickssofar);
 
 	if (!isr && !dev->stats.tx_packets) 
 	{
@@ -998,29 +995,31 @@ static netdev_tx_t axnet_start_xmit(struct sk_buff *skb,
 	{
 		output_page = ei_local->tx_start_page;
 		ei_local->tx1 = send_length;
-		if (ei_debug  &&  ei_local->tx2 > 0)
-			netdev_printk(KERN_DEBUG, dev,
-				      "idle transmitter tx2=%d, lasttx=%d, txing=%d\n",
-				      ei_local->tx2, ei_local->lasttx,
-				      ei_local->txing);
+		if ((ei_local->msg_enable & NETIF_MSG_TX_QUEUED) &&
+		     ei_local->tx2 > 0)
+			netdev_dbg(dev,
+				   "idle transmitter tx2=%d, lasttx=%d, txing=%d\n",
+				   ei_local->tx2, ei_local->lasttx,
+				   ei_local->txing);
 	}
 	else if (ei_local->tx2 == 0) 
 	{
 		output_page = ei_local->tx_start_page + TX_PAGES/2;
 		ei_local->tx2 = send_length;
-		if (ei_debug  &&  ei_local->tx1 > 0)
-			netdev_printk(KERN_DEBUG, dev,
-				      "idle transmitter, tx1=%d, lasttx=%d, txing=%d\n",
-				      ei_local->tx1, ei_local->lasttx,
-				      ei_local->txing);
+		if ((ei_local->msg_enable & NETIF_MSG_TX_QUEUED) &&
+		    ei_local->tx1 > 0)
+			netdev_dbg(dev,
+				   "idle transmitter, tx1=%d, lasttx=%d, txing=%d\n",
+				   ei_local->tx1, ei_local->lasttx,
+				   ei_local->txing);
 	}
 	else
 	{	/* We should never get here. */
-		if (ei_debug)
-			netdev_printk(KERN_DEBUG, dev,
-				      "No Tx buffers free! tx1=%d tx2=%d last=%d\n",
-				      ei_local->tx1, ei_local->tx2,
-				      ei_local->lasttx);
+		if (ei_local->msg_enable & NETIF_MSG_TX_ERR)
+			netdev_dbg(dev,
+				   "No Tx buffers free! tx1=%d tx2=%d last=%d\n",
+				   ei_local->tx1, ei_local->tx2,
+				   ei_local->lasttx);
 		ei_local->irqlock = 0;
 		netif_stop_queue(dev);
 		outb_p(ENISR_ALL, e8390_base + EN0_IMR);
@@ -1125,9 +1124,9 @@ static irqreturn_t ax_interrupt(int irq, void *dev_id)
 		return IRQ_NONE;
 	}
     
-	if (ei_debug > 3)
-		netdev_printk(KERN_DEBUG, dev, "interrupt(isr=%#2.2x)\n",
-			      inb_p(e8390_base + EN0_ISR));
+	if (ei_local->msg_enable & NETIF_MSG_INTR)
+		netdev_dbg(dev, "interrupt(isr=%#2.2x)\n",
+			   inb_p(e8390_base + EN0_ISR));
 
 	outb_p(0x00, e8390_base + EN0_ISR);
 	ei_local->irqlock = 1;
@@ -1137,7 +1136,7 @@ static irqreturn_t ax_interrupt(int irq, void *dev_id)
 	       ++nr_serviced < MAX_SERVICE)
 	{
 		if (!netif_running(dev) || (interrupts == 0xff)) {
-			if (ei_debug > 1)
+			if (ei_local->msg_enable & NETIF_MSG_INTR)
 				netdev_warn(dev,
 					    "interrupt from stopped card\n");
 			outb_p(interrupts, e8390_base + EN0_ISR);
@@ -1175,14 +1174,15 @@ static irqreturn_t ax_interrupt(int irq, void *dev_id)
 		}
 	}
     
-	if (interrupts && ei_debug > 3) 
+	if (interrupts && (ei_local->msg_enable & NETIF_MSG_INTR))
 	{
 		handled = 1;
 		if (nr_serviced >= MAX_SERVICE) 
 		{
 			/* 0xFF is valid for a card removal */
-			if(interrupts!=0xFF)
-				netdev_warn(dev, "Too much work at interrupt, status %#2.2x\n",
+			if (interrupts != 0xFF)
+				netdev_warn(dev,
+					    "Too much work at interrupt, status %#2.2x\n",
 					    interrupts);
 			outb_p(ENISR_ALL, e8390_base + EN0_ISR); /* Ack. most intrs. */
 		} else {
@@ -1221,8 +1221,7 @@ static void ei_tx_err(struct net_device *dev)
 	unsigned char tx_was_aborted = txsr & (ENTSR_ABT+ENTSR_FU);
 
 #ifdef VERBOSE_ERROR_DUMP
-	netdev_printk(KERN_DEBUG, dev,
-		      "transmitter error (%#2x):", txsr);
+	netdev_dbg(dev, "transmitter error (%#2x):", txsr);
 	if (txsr & ENTSR_ABT)
 		pr_cont(" excess-collisions");
 	if (txsr & ENTSR_ND)
@@ -1287,9 +1286,9 @@ static void ei_tx_intr(struct net_device *dev)
 	else if (ei_local->tx2 < 0) 
 	{
 		if (ei_local->lasttx != 2  &&  ei_local->lasttx != -2)
-			netdev_info(dev, "%s: bogus last_tx_buffer %d, tx2=%d\n",
-				    ei_local->name, ei_local->lasttx,
-				    ei_local->tx2);
+			netdev_err(dev, "%s: bogus last_tx_buffer %d, tx2=%d\n",
+				   ei_local->name, ei_local->lasttx,
+				   ei_local->tx2);
 		ei_local->tx2 = 0;
 		if (ei_local->tx1 > 0) 
 		{
@@ -1366,9 +1365,11 @@ static void ei_receive(struct net_device *dev)
 		   Keep quiet if it looks like a card removal. One problem here
 		   is that some clones crash in roughly the same way.
 		 */
-		if (ei_debug > 0  &&  this_frame != ei_local->current_page && (this_frame!=0x0 || rxing_page!=0xFF))
-		    netdev_err(dev, "mismatched read page pointers %2x vs %2x\n",
-			       this_frame, ei_local->current_page);
+		if ((ei_local->msg_enable & NETIF_MSG_RX_ERR) &&
+		    this_frame != ei_local->current_page &&
+		    (this_frame != 0x0 || rxing_page != 0xFF))
+			netdev_err(dev, "mismatched read page pointers %2x vs %2x\n",
+				   this_frame, ei_local->current_page);
 		
 		if (this_frame == rxing_page)	/* Read all the frames? */
 			break;				/* Done for now */
@@ -1383,11 +1384,11 @@ static void ei_receive(struct net_device *dev)
 		
 		if (pkt_len < 60  ||  pkt_len > 1518) 
 		{
-			if (ei_debug)
-				netdev_printk(KERN_DEBUG, dev,
-					      "bogus packet size: %d, status=%#2x nxpg=%#2x\n",
-					      rx_frame.count, rx_frame.status,
-					      rx_frame.next);
+			if (ei_local->msg_enable & NETIF_MSG_RX_ERR)
+				netdev_err(dev,
+					   "bogus packet size: %d, status=%#2x nxpg=%#2x\n",
+					   rx_frame.count, rx_frame.status,
+					   rx_frame.next);
 			dev->stats.rx_errors++;
 			dev->stats.rx_length_errors++;
 		}
@@ -1398,10 +1399,10 @@ static void ei_receive(struct net_device *dev)
 			skb = netdev_alloc_skb(dev, pkt_len + 2);
 			if (skb == NULL) 
 			{
-				if (ei_debug > 1)
-					netdev_printk(KERN_DEBUG, dev,
-						      "Couldn't allocate a sk_buff of size %d\n",
-						      pkt_len);
+				if (ei_local->msg_enable & NETIF_MSG_RX_ERR)
+					netdev_err(dev,
+						   "Couldn't allocate a sk_buff of size %d\n",
+						   pkt_len);
 				dev->stats.rx_dropped++;
 				break;
 			}
@@ -1420,11 +1421,11 @@ static void ei_receive(struct net_device *dev)
 		} 
 		else 
 		{
-			if (ei_debug)
-				netdev_printk(KERN_DEBUG, dev,
-					      "bogus packet: status=%#2x nxpg=%#2x size=%d\n",
-					      rx_frame.status, rx_frame.next,
-					      rx_frame.count);
+			if (ei_local->msg_enable & NETIF_MSG_RX_ERR)
+				netdev_err(dev,
+					   "bogus packet: status=%#2x nxpg=%#2x size=%d\n",
+					   rx_frame.status, rx_frame.next,
+					   rx_frame.count);
 			dev->stats.rx_errors++;
 			/* NB: The NIC counts CRC, frame and missed errors. */
 			if (pkt_stat & ENRSR_FO)
@@ -1461,6 +1462,7 @@ static void ei_rx_overrun(struct net_device *dev)
 	axnet_dev_t *info = PRIV(dev);
 	long e8390_base = dev->base_addr;
 	unsigned char was_txing, must_resend = 0;
+	struct ei_device *ei_local = netdev_priv(dev);
     
 	/*
 	 * Record whether a Tx was in progress and then issue the
@@ -1469,8 +1471,8 @@ static void ei_rx_overrun(struct net_device *dev)
 	was_txing = inb_p(e8390_base+E8390_CMD) & E8390_TRANS;
 	outb_p(E8390_NODMA+E8390_PAGE0+E8390_STOP, e8390_base+E8390_CMD);
     
-	if (ei_debug > 1)
-		netdev_printk(KERN_DEBUG, dev, "Receiver overrun\n");
+	if (ei_local->msg_enable & NETIF_MSG_RX_ERR)
+		netdev_dbg(dev, "Receiver overrun\n");
 	dev->stats.rx_over_errors++;
     
 	/* 
diff --git a/drivers/net/ethernet/8390/etherh.c b/drivers/net/ethernet/8390/etherh.c
index 78c6fb4..09b648e 100644
--- a/drivers/net/ethernet/8390/etherh.c
+++ b/drivers/net/ethernet/8390/etherh.c
@@ -56,9 +56,6 @@
 #define ei_inb_p(_p)	 readb((void __iomem *)_p)
 #define ei_outb_p(_v,_p) writeb(_v,(void __iomem *)_p)
 
-#define NET_DEBUG  0
-#define DEBUG_INIT 2
-
 #define DRV_NAME	"etherh"
 #define DRV_VERSION	"1.11"
 
@@ -67,7 +64,7 @@ static char version[] __initdata =
 
 #include "lib8390.c"
 
-static unsigned int net_debug = NET_DEBUG;
+static u32 etherh_debug;
 
 struct etherh_priv {
 	void __iomem	*ioc_fast;
@@ -317,9 +314,9 @@ etherh_block_output (struct net_device *dev, int count, const unsigned char *buf
 	void __iomem *dma_base, *addr;
 
 	if (ei_local->dmaing) {
-		printk(KERN_ERR "%s: DMAing conflict in etherh_block_input: "
-			" DMAstat %d irqlock %d\n", dev->name,
-			ei_local->dmaing, ei_local->irqlock);
+		netdev_err(dev, "DMAing conflict in etherh_block_input: "
+			   " DMAstat %d irqlock %d\n",
+			   ei_local->dmaing, ei_local->irqlock);
 		return;
 	}
 
@@ -361,8 +358,7 @@ etherh_block_output (struct net_device *dev, int count, const unsigned char *buf
 
 	while ((readb (addr + EN0_ISR) & ENISR_RDC) == 0)
 		if (time_after(jiffies, dma_start + 2*HZ/100)) { /* 20ms */
-			printk(KERN_ERR "%s: timeout waiting for TX RDC\n",
-				dev->name);
+			netdev_warn(dev, "timeout waiting for TX RDC\n");
 			etherh_reset (dev);
 			__NS8390_init (dev, 1);
 			break;
@@ -383,9 +379,9 @@ etherh_block_input (struct net_device *dev, int count, struct sk_buff *skb, int
 	void __iomem *dma_base, *addr;
 
 	if (ei_local->dmaing) {
-		printk(KERN_ERR "%s: DMAing conflict in etherh_block_input: "
-			" DMAstat %d irqlock %d\n", dev->name,
-			ei_local->dmaing, ei_local->irqlock);
+		netdev_err(dev, "DMAing conflict in etherh_block_input: "
+			   " DMAstat %d irqlock %d\n",
+			   ei_local->dmaing, ei_local->irqlock);
 		return;
 	}
 
@@ -423,9 +419,9 @@ etherh_get_header (struct net_device *dev, struct e8390_pkt_hdr *hdr, int ring_p
 	void __iomem *dma_base, *addr;
 
 	if (ei_local->dmaing) {
-		printk(KERN_ERR "%s: DMAing conflict in etherh_get_header: "
-			" DMAstat %d irqlock %d\n", dev->name,
-			ei_local->dmaing, ei_local->irqlock);
+		netdev_err(dev, "DMAing conflict in etherh_get_header: "
+			   " DMAstat %d irqlock %d\n",
+			   ei_local->dmaing, ei_local->irqlock);
 		return;
 	}
 
@@ -513,7 +509,7 @@ static void __init etherh_banner(void)
 {
 	static int version_printed;
 
-	if (net_debug && version_printed++ == 0)
+	if ((etherh_debug & NETIF_MSG_DRV) && version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
 }
 
@@ -625,11 +621,27 @@ static int etherh_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	return 0;
 }
 
+static u32 etherh_get_msglevel(struct net_device *dev)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+
+	return ei_local->msg_enable;
+}
+
+static void etherh_set_msglevel(struct net_device *dev, u32 v)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+
+	ei_local->msg_enable = v;
+}
+
 static const struct ethtool_ops etherh_ethtool_ops = {
 	.get_settings	= etherh_get_settings,
 	.set_settings	= etherh_set_settings,
 	.get_drvinfo	= etherh_get_drvinfo,
 	.get_ts_info	= ethtool_op_get_ts_info,
+	.get_msglevel	= etherh_get_msglevel,
+	.set_msglevel	= etherh_set_msglevel,
 };
 
 static const struct net_device_ops etherh_netdev_ops = {
@@ -746,6 +758,7 @@ etherh_probe(struct expansion_card *ec, const struct ecard_id *id)
 	ei_local->block_output  = etherh_block_output;
 	ei_local->get_8390_hdr  = etherh_get_header;
 	ei_local->interface_num = 0;
+	ei_local->msg_enable = etherh_debug;
 
 	etherh_reset(dev);
 	__NS8390_init(dev, 0);
@@ -754,8 +767,8 @@ etherh_probe(struct expansion_card *ec, const struct ecard_id *id)
 	if (ret)
 		goto free;
 
-	printk(KERN_INFO "%s: %s in slot %d, %pM\n",
-		dev->name, data->name, ec->slot_no, dev->dev_addr);
+	netdev_info(dev, "%s in slot %d, %pM\n",
+		    data->name, ec->slot_no, dev->dev_addr);
 
 	ecard_set_drvdata(ec, dev);
 
diff --git a/drivers/net/ethernet/8390/hydra.c b/drivers/net/ethernet/8390/hydra.c
index fb3dd43..dc03501 100644
--- a/drivers/net/ethernet/8390/hydra.c
+++ b/drivers/net/ethernet/8390/hydra.c
@@ -66,6 +66,7 @@ static void hydra_block_input(struct net_device *dev, int count,
 static void hydra_block_output(struct net_device *dev, int count,
 			       const unsigned char *buf, int start_page);
 static void hydra_remove_one(struct zorro_dev *z);
+static u32 hydra_debug;
 
 static struct zorro_device_id hydra_zorro_tbl[] = {
     { ZORRO_PROD_HYDRA_SYSTEMS_AMIGANET },
@@ -119,6 +120,7 @@ static int hydra_init(struct zorro_dev *z)
     int start_page, stop_page;
     int j;
     int err;
+    struct ei_device *ei_local;
 
     static u32 hydra_offsets[16] = {
 	0x00, 0x02, 0x04, 0x06, 0x08, 0x0a, 0x0c, 0x0e,
@@ -137,6 +139,8 @@ static int hydra_init(struct zorro_dev *z)
     start_page = NESM_START_PG;
     stop_page = NESM_STOP_PG;
 
+    ei_local = netdev_priv(dev);
+    ei_local->msg_enable = hydra_debug;
     dev->base_addr = ioaddr;
     dev->irq = IRQ_AMIGA_PORTS;
 
@@ -187,15 +191,17 @@ static int hydra_open(struct net_device *dev)
 
 static int hydra_close(struct net_device *dev)
 {
-    if (ei_debug > 1)
-	printk(KERN_DEBUG "%s: Shutting down ethercard.\n", dev->name);
+    struct ei_device *ei_local = netdev_priv(dev);
+
+    if (ei_local->msg_enable & NETIF_MSG_IFDOWN)
+		netdev_dbg(dev, "Shutting down ethercard.\n");
     __ei_close(dev);
     return 0;
 }
 
 static void hydra_reset_8390(struct net_device *dev)
 {
-    printk(KERN_INFO "Hydra hw reset not there\n");
+    netdev_info(dev, "Hydra hw reset not there\n");
 }
 
 static void hydra_get_8390_hdr(struct net_device *dev,
diff --git a/drivers/net/ethernet/8390/lib8390.c b/drivers/net/ethernet/8390/lib8390.c
index b329f5c..64c2a29 100644
--- a/drivers/net/ethernet/8390/lib8390.c
+++ b/drivers/net/ethernet/8390/lib8390.c
@@ -99,11 +99,6 @@
 #define ei_block_input (ei_local->block_input)
 #define ei_get_8390_hdr (ei_local->get_8390_hdr)
 
-/* use 0 for production, 1 for verification, >2 for debug */
-#ifndef ei_debug
-int ei_debug = 1;
-#endif
-
 /* Index to functions. */
 static void ei_tx_intr(struct net_device *dev);
 static void ei_tx_err(struct net_device *dev);
@@ -116,6 +111,11 @@ static void NS8390_trigger_send(struct net_device *dev, unsigned int length,
 static void do_set_multicast_list(struct net_device *dev);
 static void __NS8390_init(struct net_device *dev, int startp);
 
+static unsigned version_printed;
+static u32 msg_enable;
+module_param(msg_enable, uint, (S_IRUSR|S_IRGRP|S_IROTH));
+MODULE_PARM_DESC(msg_enable, "Debug message level (see linux/netdevice.h for bitmap)");
+
 /*
  *	SMP and the 8390 setup.
  *
@@ -345,18 +345,23 @@ static netdev_tx_t __ei_start_xmit(struct sk_buff *skb,
 	if (ei_local->tx1 == 0) {
 		output_page = ei_local->tx_start_page;
 		ei_local->tx1 = send_length;
-		if (ei_debug  &&  ei_local->tx2 > 0)
-			netdev_dbg(dev, "idle transmitter tx2=%d, lasttx=%d, txing=%d\n",
+		if ((ei_local->msg_enable & NETIF_MSG_TX_QUEUED) &&
+		    ei_local->tx2 > 0)
+			netdev_dbg(dev,
+				   "idle transmitter tx2=%d, lasttx=%d, txing=%d\n",
 				   ei_local->tx2, ei_local->lasttx, ei_local->txing);
 	} else if (ei_local->tx2 == 0) {
 		output_page = ei_local->tx_start_page + TX_PAGES/2;
 		ei_local->tx2 = send_length;
-		if (ei_debug  &&  ei_local->tx1 > 0)
-			netdev_dbg(dev, "idle transmitter, tx1=%d, lasttx=%d, txing=%d\n",
+		if ((ei_local->msg_enable & NETIF_MSG_TX_QUEUED) &&
+		    ei_local->tx1 > 0)
+			netdev_dbg(dev,
+				   "idle transmitter, tx1=%d, lasttx=%d, txing=%d\n",
 				   ei_local->tx1, ei_local->lasttx, ei_local->txing);
 	} else {			/* We should never get here. */
-		if (ei_debug)
-			netdev_dbg(dev, "No Tx buffers free! tx1=%d tx2=%d last=%d\n",
+		if (ei_local->msg_enable & NETIF_MSG_TX_ERR)
+			netdev_dbg(dev,
+				   "No Tx buffers free! tx1=%d tx2=%d last=%d\n",
 				   ei_local->tx1, ei_local->tx2, ei_local->lasttx);
 		ei_local->irqlock = 0;
 		netif_stop_queue(dev);
@@ -388,7 +393,7 @@ static netdev_tx_t __ei_start_xmit(struct sk_buff *skb,
 	} else
 		ei_local->txqueue++;
 
-	if (ei_local->tx1  &&  ei_local->tx2)
+	if (ei_local->tx1 && ei_local->tx2)
 		netif_stop_queue(dev);
 	else
 		netif_start_queue(dev);
@@ -445,7 +450,7 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 
 	/* Change to page 0 and read the intr status reg. */
 	ei_outb_p(E8390_NODMA+E8390_PAGE0, e8390_base + E8390_CMD);
-	if (ei_debug > 3)
+	if (ei_local->msg_enable & NETIF_MSG_INTR)
 		netdev_dbg(dev, "interrupt(isr=%#2.2x)\n",
 			   ei_inb_p(e8390_base + EN0_ISR));
 
@@ -485,7 +490,7 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 		ei_outb_p(E8390_NODMA+E8390_PAGE0+E8390_START, e8390_base + E8390_CMD);
 	}
 
-	if (interrupts && ei_debug) {
+	if (interrupts && (ei_local->msg_enable & NETIF_MSG_INTR)) {
 		ei_outb_p(E8390_NODMA+E8390_PAGE0+E8390_START, e8390_base + E8390_CMD);
 		if (nr_serviced >= MAX_SERVICE) {
 			/* 0xFF is valid for a card removal */
@@ -676,10 +681,11 @@ static void ei_receive(struct net_device *dev)
 		   Keep quiet if it looks like a card removal. One problem here
 		   is that some clones crash in roughly the same way.
 		 */
-		if (ei_debug > 0 &&
+		if ((ei_local->msg_enable & NETIF_MSG_RX_STATUS) &&
 		    this_frame != ei_local->current_page &&
 		    (this_frame != 0x0 || rxing_page != 0xFF))
-			netdev_err(dev, "mismatched read page pointers %2x vs %2x\n",
+			netdev_err(dev,
+				   "mismatched read page pointers %2x vs %2x\n",
 				   this_frame, ei_local->current_page);
 
 		if (this_frame == rxing_page)	/* Read all the frames? */
@@ -707,8 +713,9 @@ static void ei_receive(struct net_device *dev)
 		}
 
 		if (pkt_len < 60  ||  pkt_len > 1518) {
-			if (ei_debug)
-				netdev_dbg(dev, "bogus packet size: %d, status=%#2x nxpg=%#2x\n",
+			if (ei_local->msg_enable & NETIF_MSG_RX_STATUS)
+				netdev_dbg(dev,
+					   "bogus packet size: %d, status=%#2x nxpg=%#2x\n",
 					   rx_frame.count, rx_frame.status,
 					   rx_frame.next);
 			dev->stats.rx_errors++;
@@ -718,8 +725,9 @@ static void ei_receive(struct net_device *dev)
 
 			skb = netdev_alloc_skb(dev, pkt_len + 2);
 			if (skb == NULL) {
-				if (ei_debug > 1)
-					netdev_dbg(dev, "Couldn't allocate a sk_buff of size %d\n",
+				if (ei_local->msg_enable & NETIF_MSG_RX_ERR)
+					netdev_err(dev,
+						   "Couldn't allocate a sk_buff of size %d\n",
 						   pkt_len);
 				dev->stats.rx_dropped++;
 				break;
@@ -736,8 +744,9 @@ static void ei_receive(struct net_device *dev)
 					dev->stats.multicast++;
 			}
 		} else {
-			if (ei_debug)
-				netdev_dbg(dev, "bogus packet: status=%#2x nxpg=%#2x size=%d\n",
+			if (ei_local->msg_enable & NETIF_MSG_RX_ERR)
+				netdev_err(dev,
+					   "bogus packet: status=%#2x nxpg=%#2x size=%d\n",
 					   rx_frame.status, rx_frame.next,
 					   rx_frame.count);
 			dev->stats.rx_errors++;
@@ -789,7 +798,7 @@ static void ei_rx_overrun(struct net_device *dev)
 	was_txing = ei_inb_p(e8390_base+E8390_CMD) & E8390_TRANS;
 	ei_outb_p(E8390_NODMA+E8390_PAGE0+E8390_STOP, e8390_base+E8390_CMD);
 
-	if (ei_debug > 1)
+	if (ei_local->msg_enable & NETIF_MSG_RX_ERR)
 		netdev_dbg(dev, "Receiver overrun\n");
 	dev->stats.rx_over_errors++;
 
@@ -965,8 +974,9 @@ static void __ei_set_multicast_list(struct net_device *dev)
 static void ethdev_setup(struct net_device *dev)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
-	if (ei_debug > 1)
-		printk(version);
+
+	if ((msg_enable & NETIF_MSG_DRV) && (version_printed++ == 0))
+		pr_info("%s", version);
 
 	ether_setup(dev);
 
@@ -1035,9 +1045,10 @@ static void __NS8390_init(struct net_device *dev, int startp)
 	ei_outb_p(E8390_NODMA + E8390_PAGE1 + E8390_STOP, e8390_base+E8390_CMD); /* 0x61 */
 	for (i = 0; i < 6; i++) {
 		ei_outb_p(dev->dev_addr[i], e8390_base + EN1_PHYS_SHIFT(i));
-		if (ei_debug > 1 &&
+		if ((ei_local->msg_enable & NETIF_MSG_PROBE) &&
 		    ei_inb_p(e8390_base + EN1_PHYS_SHIFT(i)) != dev->dev_addr[i])
-			netdev_err(dev, "Hw. address read/write mismap %d\n", i);
+			netdev_err(dev,
+				   "Hw. address read/write mismap %d\n", i);
 	}
 
 	ei_outb_p(ei_local->rx_start_page, e8390_base + EN1_CURPAG);
diff --git a/drivers/net/ethernet/8390/mac8390.c b/drivers/net/ethernet/8390/mac8390.c
index 88ccc8b..38061cb 100644
--- a/drivers/net/ethernet/8390/mac8390.c
+++ b/drivers/net/ethernet/8390/mac8390.c
@@ -167,6 +167,7 @@ static void slow_sane_block_output(struct net_device *dev, int count,
 				   const unsigned char *buf, int start_page);
 static void word_memcpy_tocard(unsigned long tp, const void *fp, int count);
 static void word_memcpy_fromcard(void *tp, unsigned long fp, int count);
+static u32 mac8390_debug;
 
 static enum mac8390_type __init mac8390_ident(struct nubus_dev *dev)
 {
@@ -402,6 +403,7 @@ struct net_device * __init mac8390_probe(int unit)
 	struct net_device *dev;
 	struct nubus_dev *ndev = NULL;
 	int err = -ENODEV;
+	struct ei_device *ei_local;
 
 	static unsigned int slots;
 
@@ -440,6 +442,10 @@ struct net_device * __init mac8390_probe(int unit)
 
 	if (!ndev)
 		goto out;
+
+	 ei_local = netdev_priv(dev);
+	 ei_local->msg_enable = mac8390_debug;
+
 	err = register_netdev(dev);
 	if (err)
 		goto out;
@@ -660,19 +666,23 @@ static int mac8390_close(struct net_device *dev)
 
 static void mac8390_no_reset(struct net_device *dev)
 {
+	struct ei_device *ei_local = netdev_priv(dev);
+
 	ei_status.txing = 0;
-	if (ei_debug > 1)
-		pr_info("reset not supported\n");
+	if (ei_local->msg_enable & NETIF_MSG_HW)
+		netdev_info(dev, "reset not supported\n");
 }
 
 static void interlan_reset(struct net_device *dev)
 {
 	unsigned char *target = nubus_slot_addr(IRQ2SLOT(dev->irq));
-	if (ei_debug > 1)
-		pr_info("Need to reset the NS8390 t=%lu...", jiffies);
+	struct ei_device *ei_local = netdev_priv(dev);
+
+	if (ei_local->msg_enable & NETIF_MSG_HW)
+		netdev_info(dev, "Need to reset the NS8390 t=%lu...", jiffies);
 	ei_status.txing = 0;
 	target[0xC0000] = 0;
-	if (ei_debug > 1)
+	if (ei_local->msg_enable & NETIF_MSG_HW)
 		pr_cont("reset complete\n");
 }
 
diff --git a/drivers/net/ethernet/8390/mcf8390.c b/drivers/net/ethernet/8390/mcf8390.c
index 230efd6..e2db1cc 100644
--- a/drivers/net/ethernet/8390/mcf8390.c
+++ b/drivers/net/ethernet/8390/mcf8390.c
@@ -39,6 +39,7 @@ static const char version[] =
 
 #define NESM_START_PG	0x40	/* First page of TX buffer */
 #define NESM_STOP_PG	0x80	/* Last page +1 of RX ring */
+static u32 mcf8390_debug;
 
 #ifdef NE2000_ODDOFFSET
 /*
@@ -153,8 +154,9 @@ static void mcf8390_reset_8390(struct net_device *dev)
 {
 	unsigned long reset_start_time = jiffies;
 	u32 addr = dev->base_addr;
+	struct ei_device *ei_local = netdev_priv(dev);
 
-	if (ei_debug > 1)
+	if (ei_local->msg_enable & NETIF_MSG_HW)
 		netdev_dbg(dev, "resetting the 8390 t=%ld...\n", jiffies);
 
 	ei_outb(ei_inb(addr + NE_RESET), addr + NE_RESET);
@@ -288,7 +290,7 @@ static void mcf8390_block_output(struct net_device *dev, int count,
 	dma_start = jiffies;
 	while ((ei_inb(addr + NE_EN0_ISR) & ENISR_RDC) == 0) {
 		if (time_after(jiffies, dma_start + 2 * HZ / 100)) { /* 20ms */
-			netdev_err(dev, "timeout waiting for Tx RDC\n");
+			netdev_warn(dev, "timeout waiting for Tx RDC\n");
 			mcf8390_reset_8390(dev);
 			__NS8390_init(dev, 1);
 			break;
@@ -437,6 +439,7 @@ static int mcf8390_probe(struct platform_device *pdev)
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	platform_set_drvdata(pdev, dev);
 	ei_local = netdev_priv(dev);
+	ei_local->msg_enable = mcf8390_debug;
 
 	dev->irq = irq->start;
 	dev->base_addr = mem->start;
diff --git a/drivers/net/ethernet/8390/ne-h8300.c b/drivers/net/ethernet/8390/ne-h8300.c
index 7fc28f2..bdccda8 100644
--- a/drivers/net/ethernet/8390/ne-h8300.c
+++ b/drivers/net/ethernet/8390/ne-h8300.c
@@ -82,6 +82,7 @@ static void ne_block_output(struct net_device *dev, const int count,
 
 
 static u32 reg_offset[16];
+static u32 h8300_ne_debug;
 
 static int __init init_reg_offset(struct net_device *dev,unsigned long base_addr)
 {
@@ -245,10 +246,10 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 		}
 	}
 
-	if (ei_debug  &&  version_printed++ == 0)
-		printk(KERN_INFO "%s", version1);
+	if ((h8300_ne_debug  & NETIF_MSG_DRV) &&  version_printed++ == 0)
+		netdev_info(dev, "%s", version1);
 
-	printk(KERN_INFO "NE*000 ethercard probe at %08x:", ioaddr);
+	netdev_info(dev, "NE*000 ethercard probe at %08x:", ioaddr);
 
 	/* Read the 16 bytes of station address PROM.
 	   We must first initialize registers, similar to NS8390_init(eifdev, 0).
@@ -296,7 +297,7 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 	name = (wordlength == 2) ? "NE2000" : "NE1000";
 
 	if (! dev->irq) {
-		printk(" failed to detect IRQ line.\n");
+		pr_cont(" failed to detect IRQ line.\n");
 		ret = -EAGAIN;
 		goto err_out;
 	}
@@ -305,7 +306,7 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 	   share and the board will usually be enabled. */
 	ret = request_irq(dev->irq, __ei_interrupt, 0, name, dev);
 	if (ret) {
-		printk (" unable to get IRQ %d (errno=%d).\n", dev->irq, ret);
+		pr_cont(" unable to get IRQ %d (errno=%d).\n", dev->irq, ret);
 		goto err_out;
 	}
 
@@ -313,10 +314,10 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 
 	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = SA_prom[i];
-	printk(" %pM\n", dev->dev_addr);
+	pr_cont(" %pM\n", dev->dev_addr);
 
-	printk("%s: %s found at %#x, using IRQ %d.\n",
-		dev->name, name, ioaddr, dev->irq);
+	netdev_info(dev, "%s found at %#x, using IRQ %d.\n",
+		    name, ioaddr, dev->irq);
 
 	ei_status.name = name;
 	ei_status.tx_start_page = start_page;
@@ -339,6 +340,7 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 
 	__NS8390_init(dev, 0);
 
+	ei_local->msg_enable = h8300_ne_debug;
 	ret = register_netdev(dev);
 	if (ret)
 		goto out_irq;
@@ -358,8 +360,10 @@ static int ne_open(struct net_device *dev)
 
 static int ne_close(struct net_device *dev)
 {
-	if (ei_debug > 1)
-		printk(KERN_DEBUG "%s: Shutting down ethercard.\n", dev->name);
+	struct ei_device *ei_local = netdev_priv(dev);
+
+	if (ei_local->msg_enable & NETIF_MSG_IFDOWN)
+		netdev_dbg(dev, "Shutting down ethercard.\n");
 	__ei_close(dev);
 	return 0;
 }
@@ -372,8 +376,8 @@ static void ne_reset_8390(struct net_device *dev)
 	unsigned long reset_start_time = jiffies;
 	struct ei_device *ei_local = netdev_priv(dev);
 
-	if (ei_debug > 1)
-		printk(KERN_DEBUG "resetting the 8390 t=%ld...", jiffies);
+	if (ei_local->msg_enable & NETIF_MSG_HW)
+		netdev_dbg(dev, "resetting the 8390 t=%ld...\n", jiffies);
 
 	/* DON'T change these to inb_p/outb_p or reset will fail on clones. */
 	outb(inb(NE_BASE + NE_RESET), NE_BASE + NE_RESET);
@@ -384,7 +388,7 @@ static void ne_reset_8390(struct net_device *dev)
 	/* This check _should_not_ be necessary, omit eventually. */
 	while ((inb_p(NE_BASE+EN0_ISR) & ENISR_RESET) == 0)
 		if (time_after(jiffies, reset_start_time + 2*HZ/100)) {
-			printk(KERN_WARNING "%s: ne_reset_8390() did not complete.\n", dev->name);
+			netdev_err(dev, "ne_reset_8390() did not complete.\n");
 			break;
 		}
 	outb_p(ENISR_RESET, NE_BASE + EN0_ISR);	/* Ack intr. */
@@ -401,9 +405,9 @@ static void ne_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr, i
 
 	if (ei_status.dmaing)
 	{
-		printk(KERN_EMERG "%s: DMAing conflict in ne_get_8390_hdr "
-			"[DMAstat:%d][irqlock:%d].\n",
-			dev->name, ei_status.dmaing, ei_status.irqlock);
+		netdev_err(dev, "DMAing conflict in ne_get_8390_hdr "
+			   "[DMAstat:%d][irqlock:%d].\n",
+			   ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
 
@@ -445,9 +449,9 @@ static void ne_block_input(struct net_device *dev, int count, struct sk_buff *sk
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_status.dmaing)
 	{
-		printk(KERN_EMERG "%s: DMAing conflict in ne_block_input "
-			"[DMAstat:%d][irqlock:%d].\n",
-			dev->name, ei_status.dmaing, ei_status.irqlock);
+		netdev_err(dev, "DMAing conflict in ne_block_input "
+			   "[DMAstat:%d][irqlock:%d].\n",
+			   ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
 	ei_status.dmaing |= 0x01;
@@ -480,7 +484,7 @@ static void ne_block_input(struct net_device *dev, int count, struct sk_buff *sk
 	   this message you either 1) have a slightly incompatible clone
 	   or 2) have noise/speed problems with your bus. */
 
-	if (ei_debug > 1)
+	if (ei_local->msg_enable & NETIF_MSG_RX_STATUS)
 	{
 		/* DMA termination address check... */
 		int addr, tries = 20;
@@ -494,9 +498,9 @@ static void ne_block_input(struct net_device *dev, int count, struct sk_buff *sk
 				break;
 		} while (--tries > 0);
 	 	if (tries <= 0)
-			printk(KERN_WARNING "%s: RX transfer address mismatch,"
-				"%#4.4x (expected) vs. %#4.4x (actual).\n",
-				dev->name, ring_offset + xfer_count, addr);
+			netdev_warn(dev, "RX transfer address mismatch,"
+				    "%#4.4x (expected) vs. %#4.4x (actual).\n",
+				    ring_offset + xfer_count, addr);
 	}
 #endif
 	outb_p(ENISR_RDC, NE_BASE + EN0_ISR);	/* Ack intr. */
@@ -522,9 +526,9 @@ static void ne_block_output(struct net_device *dev, int count,
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_status.dmaing)
 	{
-		printk(KERN_EMERG "%s: DMAing conflict in ne_block_output."
-			"[DMAstat:%d][irqlock:%d]\n",
-			dev->name, ei_status.dmaing, ei_status.irqlock);
+		netdev_err(dev, "DMAing conflict in ne_block_output."
+			   "[DMAstat:%d][irqlock:%d]\n",
+			   ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
 	ei_status.dmaing |= 0x01;
@@ -574,7 +578,7 @@ retry:
 	/* This was for the ALPHA version only, but enough people have
 	   been encountering problems so it is still here. */
 
-	if (ei_debug > 1)
+	if (ei_local->msg_enable & NETIF_RX_TX_QUEUED)
 	{
 		/* DMA termination address check... */
 		int addr, tries = 20;
@@ -588,9 +592,9 @@ retry:
 
 		if (tries <= 0)
 		{
-			printk(KERN_WARNING "%s: Tx packet transfer address mismatch,"
-				"%#4.4x (expected) vs. %#4.4x (actual).\n",
-				dev->name, (start_page << 8) + count, addr);
+			netdev_warn(dev, "Tx packet transfer address mismatch,"
+				    "%#4.4x (expected) vs. %#4.4x (actual).\n",
+				    (start_page << 8) + count, addr);
 			if (retries++ == 0)
 				goto retry;
 		}
@@ -599,7 +603,7 @@ retry:
 
 	while ((inb_p(NE_BASE + EN0_ISR) & ENISR_RDC) == 0)
 		if (time_after(jiffies, dma_start + 2*HZ/100)) {		/* 20ms */
-			printk(KERN_WARNING "%s: timeout waiting for Tx RDC.\n", dev->name);
+			netdev_warn(dev, "timeout waiting for Tx RDC.\n");
 			ne_reset_8390(dev);
 			__NS8390_init(dev,1);
 			break;
@@ -620,8 +624,10 @@ static int bad[MAX_NE_CARDS];	/* 0xbad = bad sig or no reset ack */
 module_param_array(io, int, NULL, 0);
 module_param_array(irq, int, NULL, 0);
 module_param_array(bad, int, NULL, 0);
+module_param_named(debug, h8300_ne_debug, uint, (S_IRUSR|S_IRGRP|S_IROTH));
 MODULE_PARM_DESC(io, "I/O base address(es)");
 MODULE_PARM_DESC(irq, "IRQ number(s)");
+MODULE_PARM_DESC(debug, "Debug message level (see linux/netdevice.h for bitmap)");
 MODULE_DESCRIPTION("H8/300 NE2000 Ethernet driver");
 MODULE_LICENSE("GPL");
 
@@ -658,9 +664,12 @@ int init_module(void)
 		if (found)
 			break;
 		if (io[this_dev] != 0)
-			printk(KERN_WARNING "ne.c: No NE*000 card found at i/o = %#x\n", dev->base_addr);
+			netdev_warn(dev,
+				    "ne.c: No NE*000 card found at i/o = %#lx\n",
+				    dev->base_addr);
 		else
-			printk(KERN_NOTICE "ne.c: You must supply \"io=0xNNN\" value(s) for ISA cards.\n");
+			netdev_notice(dev,
+				      "ne.c: You must supply \"io=0xNNN\" value(s) for ISA cards.\n");
 		return -ENXIO;
 	}
 	if (found)
diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
index b2e8405..2ed9d12 100644
--- a/drivers/net/ethernet/8390/ne.c
+++ b/drivers/net/ethernet/8390/ne.c
@@ -71,14 +71,17 @@ static struct platform_device *pdev_ne[MAX_NE_CARDS];
 static int io[MAX_NE_CARDS];
 static int irq[MAX_NE_CARDS];
 static int bad[MAX_NE_CARDS];
+static u32 ne_debug;
 
 #ifdef MODULE
 module_param_array(io, int, NULL, 0);
 module_param_array(irq, int, NULL, 0);
 module_param_array(bad, int, NULL, 0);
+module_param_named(debug, ne_debug, uint, (S_IRUSR|S_IRGRP|S_IROTH));
 MODULE_PARM_DESC(io, "I/O base address(es),required");
 MODULE_PARM_DESC(irq, "IRQ number(s)");
 MODULE_PARM_DESC(bad, "Accept card(s) with bad signatures");
+MODULE_PARM_DESC(debug, "Debug message level (see linux/netdevice.h for bitmap)");
 MODULE_DESCRIPTION("NE1000/NE2000 ISA/PnP Ethernet driver");
 MODULE_LICENSE("GPL");
 #endif /* MODULE */
@@ -214,8 +217,8 @@ static int __init do_ne_probe(struct net_device *dev)
 	if (base_addr > 0x1ff) {	/* Check a single specified location. */
 		int ret = ne_probe1(dev, base_addr);
 		if (ret)
-			printk(KERN_WARNING "ne.c: No NE*000 card found at "
-				"i/o = %#lx\n", base_addr);
+			netdev_warn(dev, "ne.c: No NE*000 card found at "
+				    "i/o = %#lx\n", base_addr);
 		return ret;
 	}
 	else if (base_addr != 0)	/* Don't probe at all. */
@@ -264,11 +267,14 @@ static int __init ne_probe_isapnp(struct net_device *dev)
 			/* found it */
 			dev->base_addr = pnp_port_start(idev, 0);
 			dev->irq = pnp_irq(idev, 0);
-			printk(KERN_INFO "ne.c: ISAPnP reports %s at i/o %#lx, irq %d.\n",
-				(char *) isapnp_clone_list[i].driver_data,
-				dev->base_addr, dev->irq);
+			netdev_info(dev,
+				    "ne.c: ISAPnP reports %s at i/o %#lx, irq %d.\n",
+				    (char *) isapnp_clone_list[i].driver_data,
+				    dev->base_addr, dev->irq);
 			if (ne_probe1(dev, dev->base_addr) != 0) {	/* Shouldn't happen. */
-				printk(KERN_ERR "ne.c: Probe of ISAPnP card at %#lx failed.\n", dev->base_addr);
+				netdev_err(dev,
+					   "ne.c: Probe of ISAPnP card at %#lx failed.\n",
+					   dev->base_addr);
 				pnp_device_detach(idev);
 				return -ENXIO;
 			}
@@ -293,6 +299,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 	int neX000, ctron, copam, bad_card;
 	int reg0, ret;
 	static unsigned version_printed;
+	struct ei_device *ei_local = netdev_priv(dev);
 
 	if (!request_region(ioaddr, NE_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
@@ -319,10 +326,10 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 		}
 	}
 
-	if (ei_debug  &&  version_printed++ == 0)
-		printk(KERN_INFO "%s%s", version1, version2);
+	if ((ne_debug  & NETIF_MSG_DRV) &&  version_printed++ == 0)
+		netdev_info(dev, "%s%s", version1, version2);
 
-	printk(KERN_INFO "NE*000 ethercard probe at %#3lx:", ioaddr);
+	netdev_info(dev, "NE*000 ethercard probe at %#3lx:", ioaddr);
 
 	/* A user with a poor card that fails to ack the reset, or that
 	   does not have a valid 0x57,0x57 signature can still use this
@@ -343,10 +350,10 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 		while ((inb_p(ioaddr + EN0_ISR) & ENISR_RESET) == 0)
 		if (time_after(jiffies, reset_start_time + 2*HZ/100)) {
 			if (bad_card) {
-				printk(" (warning: no reset ack)");
+				pr_cont(" (warning: no reset ack)");
 				break;
 			} else {
-				printk(" not found (no reset ack).\n");
+				pr_cont(" not found (no reset ack).\n");
 				ret = -ENODEV;
 				goto err_out;
 			}
@@ -454,13 +461,13 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 		}
 		if (bad_clone_list[i].name8 == NULL)
 		{
-			printk(" not found (invalid signature %2.2x %2.2x).\n",
+			pr_cont(" not found (invalid signature %2.2x %2.2x).\n",
 				SA_prom[14], SA_prom[15]);
 			ret = -ENXIO;
 			goto err_out;
 		}
 #else
-		printk(" not found.\n");
+		pr_cont(" not found.\n");
 		ret = -ENXIO;
 		goto err_out;
 #endif
@@ -476,15 +483,15 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 		mdelay(10);		/* wait 10ms for interrupt to propagate */
 		outb_p(0x00, ioaddr + EN0_IMR); 		/* Mask it again. */
 		dev->irq = probe_irq_off(cookie);
-		if (ei_debug > 2)
-			printk(" autoirq is %d\n", dev->irq);
+		if (ne_debug & NETIF_MSG_PROBE)
+			pr_cont(" autoirq is %d", dev->irq);
 	} else if (dev->irq == 2)
 		/* Fixup for users that don't know that IRQ 2 is really IRQ 9,
 		   or don't know which one to set. */
 		dev->irq = 9;
 
 	if (! dev->irq) {
-		printk(" failed to detect IRQ line.\n");
+		pr_cont(" failed to detect IRQ line.\n");
 		ret = -EAGAIN;
 		goto err_out;
 	}
@@ -493,7 +500,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 	   share and the board will usually be enabled. */
 	ret = request_irq(dev->irq, eip_interrupt, 0, name, dev);
 	if (ret) {
-		printk (" unable to get IRQ %d (errno=%d).\n", dev->irq, ret);
+		pr_cont(" unable to get IRQ %d (errno=%d).\n", dev->irq, ret);
 		goto err_out;
 	}
 
@@ -512,7 +519,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 	}
 #endif
 
-	printk("%pM\n", dev->dev_addr);
+	pr_cont("%pM\n", dev->dev_addr);
 
 	ei_status.name = name;
 	ei_status.tx_start_page = start_page;
@@ -536,11 +543,12 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 	dev->netdev_ops = &eip_netdev_ops;
 	NS8390p_init(dev, 0);
 
+	ei_local->msg_enable = ne_debug;
 	ret = register_netdev(dev);
 	if (ret)
 		goto out_irq;
-	printk(KERN_INFO "%s: %s found at %#lx, using IRQ %d.\n",
-	       dev->name, name, ioaddr, dev->irq);
+	netdev_info(dev, "%s found at %#lx, using IRQ %d.\n",
+		    name, ioaddr, dev->irq);
 	return 0;
 
 out_irq:
@@ -556,9 +564,10 @@ err_out:
 static void ne_reset_8390(struct net_device *dev)
 {
 	unsigned long reset_start_time = jiffies;
+	struct ei_device *ei_local = netdev_priv(dev);
 
-	if (ei_debug > 1)
-		printk(KERN_DEBUG "resetting the 8390 t=%ld...", jiffies);
+	if (ei_local->msg_enable & NETIF_MSG_HW)
+		netdev_dbg(dev, "resetting the 8390 t=%ld...\n", jiffies);
 
 	/* DON'T change these to inb_p/outb_p or reset will fail on clones. */
 	outb(inb(NE_BASE + NE_RESET), NE_BASE + NE_RESET);
@@ -569,7 +578,7 @@ static void ne_reset_8390(struct net_device *dev)
 	/* This check _should_not_ be necessary, omit eventually. */
 	while ((inb_p(NE_BASE+EN0_ISR) & ENISR_RESET) == 0)
 		if (time_after(jiffies, reset_start_time + 2*HZ/100)) {
-			printk(KERN_WARNING "%s: ne_reset_8390() did not complete.\n", dev->name);
+			netdev_err(dev, "ne_reset_8390() did not complete.\n");
 			break;
 		}
 	outb_p(ENISR_RESET, NE_BASE + EN0_ISR);	/* Ack intr. */
@@ -587,9 +596,9 @@ static void ne_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr, i
 
 	if (ei_status.dmaing)
 	{
-		printk(KERN_EMERG "%s: DMAing conflict in ne_get_8390_hdr "
-			"[DMAstat:%d][irqlock:%d].\n",
-			dev->name, ei_status.dmaing, ei_status.irqlock);
+		netdev_err(dev, "DMAing conflict in ne_get_8390_hdr "
+			   "[DMAstat:%d][irqlock:%d].\n",
+			   ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
 
@@ -621,6 +630,7 @@ static void ne_block_input(struct net_device *dev, int count, struct sk_buff *sk
 {
 #ifdef NE_SANITY_CHECK
 	int xfer_count = count;
+	struct ei_device *ei_local = netdev_priv(dev);
 #endif
 	int nic_base = dev->base_addr;
 	char *buf = skb->data;
@@ -628,9 +638,9 @@ static void ne_block_input(struct net_device *dev, int count, struct sk_buff *sk
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_status.dmaing)
 	{
-		printk(KERN_EMERG "%s: DMAing conflict in ne_block_input "
-			"[DMAstat:%d][irqlock:%d].\n",
-			dev->name, ei_status.dmaing, ei_status.irqlock);
+		netdev_err(dev, "DMAing conflict in ne_block_input "
+			   "[DMAstat:%d][irqlock:%d].\n",
+			   ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
 	ei_status.dmaing |= 0x01;
@@ -660,7 +670,7 @@ static void ne_block_input(struct net_device *dev, int count, struct sk_buff *sk
 	   this message you either 1) have a slightly incompatible clone
 	   or 2) have noise/speed problems with your bus. */
 
-	if (ei_debug > 1)
+	if (ei_local->msg_enable & NETIF_MSG_RX_STATUS)
 	{
 		/* DMA termination address check... */
 		int addr, tries = 20;
@@ -674,9 +684,9 @@ static void ne_block_input(struct net_device *dev, int count, struct sk_buff *sk
 				break;
 		} while (--tries > 0);
 	 	if (tries <= 0)
-			printk(KERN_WARNING "%s: RX transfer address mismatch,"
-				"%#4.4x (expected) vs. %#4.4x (actual).\n",
-				dev->name, ring_offset + xfer_count, addr);
+			netdev_warn(dev, "RX transfer address mismatch,"
+				    "%#4.4x (expected) vs. %#4.4x (actual).\n",
+				    ring_offset + xfer_count, addr);
 	}
 #endif
 	outb_p(ENISR_RDC, nic_base + EN0_ISR);	/* Ack intr. */
@@ -690,6 +700,7 @@ static void ne_block_output(struct net_device *dev, int count,
 	unsigned long dma_start;
 #ifdef NE_SANITY_CHECK
 	int retries = 0;
+	struct ei_device *ei_local = netdev_priv(dev);
 #endif
 
 	/* Round the count up for word writes.  Do we need to do this?
@@ -702,9 +713,9 @@ static void ne_block_output(struct net_device *dev, int count,
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_status.dmaing)
 	{
-		printk(KERN_EMERG "%s: DMAing conflict in ne_block_output."
-			"[DMAstat:%d][irqlock:%d]\n",
-			dev->name, ei_status.dmaing, ei_status.irqlock);
+		netdev_err(dev, "DMAing conflict in ne_block_output."
+			   "[DMAstat:%d][irqlock:%d]\n",
+			   ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
 	ei_status.dmaing |= 0x01;
@@ -751,7 +762,7 @@ retry:
 	/* This was for the ALPHA version only, but enough people have
 	   been encountering problems so it is still here. */
 
-	if (ei_debug > 1)
+	if (ei_local->msg_enable & NETIF_MSG_TX_QUEUED)
 	{
 		/* DMA termination address check... */
 		int addr, tries = 20;
@@ -765,9 +776,9 @@ retry:
 
 		if (tries <= 0)
 		{
-			printk(KERN_WARNING "%s: Tx packet transfer address mismatch,"
-				"%#4.4x (expected) vs. %#4.4x (actual).\n",
-				dev->name, (start_page << 8) + count, addr);
+			netdev_warn(dev, "Tx packet transfer address mismatch,"
+				    "%#4.4x (expected) vs. %#4.4x (actual).\n",
+				    (start_page << 8) + count, addr);
 			if (retries++ == 0)
 				goto retry;
 		}
@@ -776,7 +787,7 @@ retry:
 
 	while ((inb_p(nic_base + EN0_ISR) & ENISR_RDC) == 0)
 		if (time_after(jiffies, dma_start + 2*HZ/100)) {		/* 20ms */
-			printk(KERN_WARNING "%s: timeout waiting for Tx RDC.\n", dev->name);
+			netdev_warn(dev, "timeout waiting for Tx RDC.\n");
 			ne_reset_8390(dev);
 			NS8390p_init(dev, 1);
 			break;
@@ -937,7 +948,7 @@ int __init init_module(void)
 	if (retval) {
 		if (io[0] == 0)
 			printk(KERN_NOTICE "ne.c: You must supply \"io=0xNNN\""
-				" value(s) for ISA cards.\n");
+			       " value(s) for ISA cards.\n");
 		ne_loop_rm_unreg(1);
 		return retval;
 	}
diff --git a/drivers/net/ethernet/8390/ne2k-pci.c b/drivers/net/ethernet/8390/ne2k-pci.c
index fc14a85..8a6a0b2 100644
--- a/drivers/net/ethernet/8390/ne2k-pci.c
+++ b/drivers/net/ethernet/8390/ne2k-pci.c
@@ -33,8 +33,6 @@
 /* The user-configurable values.
    These may be modified when a driver module is loaded.*/
 
-static int debug = 1;			/* 1 normal messages, 0 quiet .. 7 verbose. */
-
 #define MAX_UNITS 8				/* More are supported, limit only on options */
 /* Used to pass the full-duplex flag, etc. */
 static int full_duplex[MAX_UNITS];
@@ -60,6 +58,8 @@ static int options[MAX_UNITS];
 
 #include "8390.h"
 
+static u32 ne2k_debug;
+
 /* These identify the driver base version and may not be removed. */
 static const char version[] =
 	KERN_INFO DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE
@@ -76,10 +76,10 @@ MODULE_AUTHOR("Donald Becker / Paul Gortmaker");
 MODULE_DESCRIPTION("PCI NE2000 clone driver");
 MODULE_LICENSE("GPL");
 
-module_param(debug, int, 0);
+module_param_named(debug, ne2k_debug, uint, (S_IRUSR|S_IRGRP|S_IROTH));
 module_param_array(options, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
-MODULE_PARM_DESC(debug, "debug level (1-2)");
+MODULE_PARM_DESC(debug, "Debug message level (see linux/netdevice.h for bitmap)");
 MODULE_PARM_DESC(options, "Bit 5: full duplex");
 MODULE_PARM_DESC(full_duplex, "full duplex setting(s) (1)");
 
@@ -226,6 +226,7 @@ static int ne2k_pci_init_one(struct pci_dev *pdev,
 	static unsigned int fnd_cnt;
 	long ioaddr;
 	int flags = pci_clone_list[chip_idx].flags;
+	struct ei_device *ei_local;
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -280,6 +281,8 @@ static int ne2k_pci_init_one(struct pci_dev *pdev,
 		goto err_out_free_res;
 	}
 	dev->netdev_ops = &ne2k_netdev_ops;
+	ei_local = netdev_priv(dev);
+	ei_local->msg_enable = ne2k_debug;
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -379,9 +382,9 @@ static int ne2k_pci_init_one(struct pci_dev *pdev,
 	if (i)
 		goto err_out_free_netdev;
 
-	printk("%s: %s found at %#lx, IRQ %d, %pM.\n",
-	       dev->name, pci_clone_list[chip_idx].name, ioaddr, dev->irq,
-	       dev->dev_addr);
+	netdev_info(dev, "%s found at %#lx, IRQ %d, %pM.\n",
+		    pci_clone_list[chip_idx].name, ioaddr, dev->irq,
+		    dev->dev_addr);
 
 	return 0;
 
@@ -451,8 +454,9 @@ static void ne2k_pci_reset_8390(struct net_device *dev)
 {
 	unsigned long reset_start_time = jiffies;
 
-	if (debug > 1) printk("%s: Resetting the 8390 t=%ld...",
-						  dev->name, jiffies);
+	if (ne2k_debug & NETIF_MSG_HW)
+		netdev_dbg(dev, "resetting the 8390 t=%ld...\n",
+			   jiffies);
 
 	outb(inb(NE_BASE + NE_RESET), NE_BASE + NE_RESET);
 
@@ -462,7 +466,7 @@ static void ne2k_pci_reset_8390(struct net_device *dev)
 	/* This check _should_not_ be necessary, omit eventually. */
 	while ((inb(NE_BASE+EN0_ISR) & ENISR_RESET) == 0)
 		if (jiffies - reset_start_time > 2) {
-			printk("%s: ne2k_pci_reset_8390() did not complete.\n", dev->name);
+			netdev_err(dev, "ne2k_pci_reset_8390() did not complete.\n");
 			break;
 		}
 	outb(ENISR_RESET, NE_BASE + EN0_ISR);	/* Ack intr. */
@@ -479,9 +483,9 @@ static void ne2k_pci_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *
 
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_status.dmaing) {
-		printk("%s: DMAing conflict in ne2k_pci_get_8390_hdr "
+		netdev_err(dev, "DMAing conflict in ne2k_pci_get_8390_hdr "
 			   "[DMAstat:%d][irqlock:%d].\n",
-			   dev->name, ei_status.dmaing, ei_status.irqlock);
+			   ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
 
@@ -517,9 +521,9 @@ static void ne2k_pci_block_input(struct net_device *dev, int count,
 
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_status.dmaing) {
-		printk("%s: DMAing conflict in ne2k_pci_block_input "
+		netdev_err(dev, "DMAing conflict in ne2k_pci_block_input "
 			   "[DMAstat:%d][irqlock:%d].\n",
-			   dev->name, ei_status.dmaing, ei_status.irqlock);
+			   ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
 	ei_status.dmaing |= 0x01;
@@ -572,9 +576,9 @@ static void ne2k_pci_block_output(struct net_device *dev, int count,
 
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_status.dmaing) {
-		printk("%s: DMAing conflict in ne2k_pci_block_output."
+		netdev_err(dev, "DMAing conflict in ne2k_pci_block_output."
 			   "[DMAstat:%d][irqlock:%d]\n",
-			   dev->name, ei_status.dmaing, ei_status.irqlock);
+			   ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
 	ei_status.dmaing |= 0x01;
@@ -619,7 +623,7 @@ static void ne2k_pci_block_output(struct net_device *dev, int count,
 
 	while ((inb(nic_base + EN0_ISR) & ENISR_RDC) == 0)
 		if (jiffies - dma_start > 2) {			/* Avoid clock roll-over. */
-			printk(KERN_WARNING "%s: timeout waiting for Tx RDC.\n", dev->name);
+			netdev_warn(dev, "timeout waiting for Tx RDC.\n");
 			ne2k_pci_reset_8390(dev);
 			NS8390_init(dev,1);
 			break;
@@ -640,8 +644,24 @@ static void ne2k_pci_get_drvinfo(struct net_device *dev,
 	strlcpy(info->bus_info, pci_name(pci_dev), sizeof(info->bus_info));
 }
 
+static u32 ne2k_pci_get_msglevel(struct net_device *dev)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+
+	return ei_local->msg_enable;
+}
+
+static void ne2k_pci_set_msglevel(struct net_device *dev, u32 v)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+
+	ei_local->msg_enable = v;
+}
+
 static const struct ethtool_ops ne2k_pci_ethtool_ops = {
 	.get_drvinfo		= ne2k_pci_get_drvinfo,
+	.get_msglevel		= ne2k_pci_get_msglevel,
+	.set_msglevel		= ne2k_pci_set_msglevel,
 };
 
 static void ne2k_pci_remove_one(struct pci_dev *pdev)
diff --git a/drivers/net/ethernet/8390/pcnet_cs.c b/drivers/net/ethernet/8390/pcnet_cs.c
index 46c5aad..f7d6acb 100644
--- a/drivers/net/ethernet/8390/pcnet_cs.c
+++ b/drivers/net/ethernet/8390/pcnet_cs.c
@@ -67,7 +67,7 @@
 #define PCNET_RDC_TIMEOUT (2*HZ/100)	/* Max wait in jiffies for Tx RDC */
 
 static const char *if_names[] = { "auto", "10baseT", "10base2"};
-
+static u32 pcnet_debug;
 
 /*====================================================================*/
 
@@ -558,6 +558,7 @@ static int pcnet_config(struct pcmcia_device *link)
     int start_pg, stop_pg, cm_offset;
     int has_shmem = 0;
     hw_info_t *local_hw_info;
+    struct ei_device *ei_local;
 
     dev_dbg(&link->dev, "pcnet_config\n");
 
@@ -607,6 +608,8 @@ static int pcnet_config(struct pcmcia_device *link)
 	mii_phy_probe(dev);
 
     SET_NETDEV_DEV(dev, &link->dev);
+    ei_local = netdev_priv(dev);
+    ei_local->msg_enable = pcnet_debug;
 
     if (register_netdev(dev) != 0) {
 	pr_notice("register_netdev() failed\n");
@@ -616,7 +619,7 @@ static int pcnet_config(struct pcmcia_device *link)
     if (info->flags & (IS_DL10019|IS_DL10022)) {
 	u_char id = inb(dev->base_addr + 0x1a);
 	netdev_info(dev, "NE2000 (DL100%d rev %02x): ",
-	       (info->flags & IS_DL10022) ? 22 : 19, id);
+		    (info->flags & IS_DL10022) ? 22 : 19, id);
 	if (info->pna_phy)
 	    pr_cont("PNA, ");
     } else {
@@ -1063,9 +1066,9 @@ static void ei_watchdog(u_long arg)
 	    if (info->phy_id == info->eth_phy) {
 		if (p)
 		    netdev_info(dev, "autonegotiation complete: "
-			   "%sbaseT-%cD selected\n",
-			   ((p & 0x0180) ? "100" : "10"),
-			   ((p & 0x0140) ? 'F' : 'H'));
+				"%sbaseT-%cD selected\n",
+				((p & 0x0180) ? "100" : "10"),
+				((p & 0x0140) ? 'F' : 'H'));
 		else
 		    netdev_info(dev, "link partner did not autonegotiate\n");
 	    }
@@ -1081,7 +1084,7 @@ static void ei_watchdog(u_long arg)
 	    mdio_write(mii_addr, info->phy_id, 0, 0x0400);
 	    info->phy_id ^= info->pna_phy ^ info->eth_phy;
 	    netdev_info(dev, "switched to %s transceiver\n",
-		   (info->phy_id == info->eth_phy) ? "ethernet" : "PNA");
+			(info->phy_id == info->eth_phy) ? "ethernet" : "PNA");
 	    mdio_write(mii_addr, info->phy_id, 0,
 		       (info->phy_id == info->eth_phy) ? 0x1000 : 0);
 	    info->link_status = 0;
@@ -1128,9 +1131,9 @@ static void dma_get_8390_hdr(struct net_device *dev,
     unsigned int nic_base = dev->base_addr;
 
     if (ei_status.dmaing) {
-	netdev_notice(dev, "DMAing conflict in dma_block_input."
-	       "[DMAstat:%1x][irqlock:%1x]\n",
-	       ei_status.dmaing, ei_status.irqlock);
+	netdev_err(dev, "DMAing conflict in dma_block_input."
+		   "[DMAstat:%1x][irqlock:%1x]\n",
+		   ei_status.dmaing, ei_status.irqlock);
 	return;
     }
 
@@ -1159,13 +1162,14 @@ static void dma_block_input(struct net_device *dev, int count,
     unsigned int nic_base = dev->base_addr;
     int xfer_count = count;
     char *buf = skb->data;
+    struct ei_device *ei_local = netdev_priv(dev);
 
-    if ((ei_debug > 4) && (count != 4))
+    if ((ei_local->msg_enable & NETIF_MSG_RX_STATUS) && (count != 4))
 	netdev_dbg(dev, "[bi=%d]\n", count+4);
     if (ei_status.dmaing) {
-	netdev_notice(dev, "DMAing conflict in dma_block_input."
-	       "[DMAstat:%1x][irqlock:%1x]\n",
-	       ei_status.dmaing, ei_status.irqlock);
+	netdev_err(dev, "DMAing conflict in dma_block_input."
+		   "[DMAstat:%1x][irqlock:%1x]\n",
+		   ei_status.dmaing, ei_status.irqlock);
 	return;
     }
     ei_status.dmaing |= 0x01;
@@ -1183,7 +1187,8 @@ static void dma_block_input(struct net_device *dev, int count,
     /* This was for the ALPHA version only, but enough people have been
        encountering problems that it is still here. */
 #ifdef PCMCIA_DEBUG
-    if (ei_debug > 4) {		/* DMA termination address check... */
+      /* DMA termination address check... */
+    if (ei_local->msg_enable & NETIF_MSG_RX_STATUS) {
 	int addr, tries = 20;
 	do {
 	    /* DON'T check for 'inb_p(EN0_ISR) & ENISR_RDC' here
@@ -1196,8 +1201,8 @@ static void dma_block_input(struct net_device *dev, int count,
 	} while (--tries > 0);
 	if (tries <= 0)
 	    netdev_notice(dev, "RX transfer address mismatch,"
-		   "%#4.4x (expected) vs. %#4.4x (actual).\n",
-		   ring_offset + xfer_count, addr);
+			  "%#4.4x (expected) vs. %#4.4x (actual).\n",
+			  ring_offset + xfer_count, addr);
     }
 #endif
     outb_p(ENISR_RDC, nic_base + EN0_ISR);	/* Ack intr. */
@@ -1213,11 +1218,12 @@ static void dma_block_output(struct net_device *dev, int count,
     pcnet_dev_t *info = PRIV(dev);
 #ifdef PCMCIA_DEBUG
     int retries = 0;
+    struct ei_device *ei_local = netdev_priv(dev);
 #endif
     u_long dma_start;
 
 #ifdef PCMCIA_DEBUG
-    if (ei_debug > 4)
+    if (ei_local->msg_enable & NETIF_MSG_TX_QUEUED)
 	netdev_dbg(dev, "[bo=%d]\n", count);
 #endif
 
@@ -1227,9 +1233,9 @@ static void dma_block_output(struct net_device *dev, int count,
     if (count & 0x01)
 	count++;
     if (ei_status.dmaing) {
-	netdev_notice(dev, "DMAing conflict in dma_block_output."
-	       "[DMAstat:%1x][irqlock:%1x]\n",
-	       ei_status.dmaing, ei_status.irqlock);
+	netdev_err(dev, "DMAing conflict in dma_block_output."
+		   "[DMAstat:%1x][irqlock:%1x]\n",
+		   ei_status.dmaing, ei_status.irqlock);
 	return;
     }
     ei_status.dmaing |= 0x01;
@@ -1256,7 +1262,8 @@ static void dma_block_output(struct net_device *dev, int count,
 #ifdef PCMCIA_DEBUG
     /* This was for the ALPHA version only, but enough people have been
        encountering problems that it is still here. */
-    if (ei_debug > 4) {	/* DMA termination address check... */
+    /* DMA termination address check... */
+    if (ei_local->msg_enable & NETIF_MSG_TX_QUEUED) {
 	int addr, tries = 20;
 	do {
 	    int high = inb_p(nic_base + EN0_RSARHI);
@@ -1267,8 +1274,8 @@ static void dma_block_output(struct net_device *dev, int count,
 	} while (--tries > 0);
 	if (tries <= 0) {
 	    netdev_notice(dev, "Tx packet transfer address mismatch,"
-		   "%#4.4x (expected) vs. %#4.4x (actual).\n",
-		   (start_page << 8) + count, addr);
+			  "%#4.4x (expected) vs. %#4.4x (actual).\n",
+			  (start_page << 8) + count, addr);
 	    if (retries++ == 0)
 		goto retry;
 	}
@@ -1277,10 +1284,10 @@ static void dma_block_output(struct net_device *dev, int count,
 
     while ((inb_p(nic_base + EN0_ISR) & ENISR_RDC) == 0)
 	if (time_after(jiffies, dma_start + PCNET_RDC_TIMEOUT)) {
-	    netdev_notice(dev, "timeout waiting for Tx RDC.\n");
-	    pcnet_reset_8390(dev);
-	    NS8390_init(dev, 1);
-	    break;
+		netdev_warn(dev, "timeout waiting for Tx RDC.\n");
+		pcnet_reset_8390(dev);
+		NS8390_init(dev, 1);
+		break;
 	}
 
     outb_p(ENISR_RDC, nic_base + EN0_ISR);	/* Ack intr. */
diff --git a/drivers/net/ethernet/8390/smc-ultra.c b/drivers/net/ethernet/8390/smc-ultra.c
index b0fbce3..5747d1d 100644
--- a/drivers/net/ethernet/8390/smc-ultra.c
+++ b/drivers/net/ethernet/8390/smc-ultra.c
@@ -111,6 +111,7 @@ static struct isapnp_device_id ultra_device_ids[] __initdata = {
 MODULE_DEVICE_TABLE(isapnp, ultra_device_ids);
 #endif
 
+static u32 ultra_debug;
 
 #define START_PG		0x00	/* First page of TX buffer */
 
@@ -211,6 +212,7 @@ static int __init ultra_probe1(struct net_device *dev, int ioaddr)
 	unsigned char num_pages, irqreg, addr, piomode;
 	unsigned char idreg = inb(ioaddr + 7);
 	unsigned char reg4 = inb(ioaddr + 4) & 0x7f;
+	struct ei_device *ei_local = netdev_priv(dev);
 
 	if (!request_region(ioaddr, ULTRA_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
@@ -232,16 +234,16 @@ static int __init ultra_probe1(struct net_device *dev, int ioaddr)
 		goto out;
 	}
 
-	if (ei_debug  &&  version_printed++ == 0)
-		printk(version);
+	if ((ei_local->msg_enable & NETIF_MSG_DRV)  &&  version_printed++ == 0)
+		netdev_info(dev, version);
 
 	model_name = (idreg & 0xF0) == 0x20 ? "SMC Ultra" : "SMC EtherEZ";
 
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = inb(ioaddr + 8 + i);
 
-	printk("%s: %s at %#3x, %pM", dev->name, model_name,
-	       ioaddr, dev->dev_addr);
+	netdev_info(dev, "%s at %#3x, %pM", model_name,
+		    ioaddr, dev->dev_addr);
 
 	/* Switch from the station address to the alternate register set and
 	   read the useful registers there. */
@@ -265,7 +267,7 @@ static int __init ultra_probe1(struct net_device *dev, int ioaddr)
 		irq = irqmap[((irqreg & 0x40) >> 4) + ((irqreg & 0x0c) >> 2)];
 
 		if (irq == 0) {
-			printk(", failed to detect IRQ line.\n");
+			pr_cont(", failed to detect IRQ line.\n");
 			retval =  -EAGAIN;
 			goto out;
 		}
@@ -296,7 +298,7 @@ static int __init ultra_probe1(struct net_device *dev, int ioaddr)
 
 	ei_status.mem = ioremap(dev->mem_start, (ei_status.stop_page - START_PG)*256);
 	if (!ei_status.mem) {
-		printk(", failed to ioremap.\n");
+		pr_cont(", failed to ioremap.\n");
 		retval =  -ENOMEM;
 		goto out;
 	}
@@ -304,14 +306,15 @@ static int __init ultra_probe1(struct net_device *dev, int ioaddr)
 	dev->mem_end = dev->mem_start + (ei_status.stop_page - START_PG)*256;
 
 	if (piomode) {
-		printk(",%s IRQ %d programmed-I/O mode.\n",
-			   eeprom_irq ? "EEPROM" : "assigned ", dev->irq);
+		pr_cont(", %s IRQ %d programmed-I/O mode.\n",
+			eeprom_irq ? "EEPROM" : "assigned ", dev->irq);
 		ei_status.block_input = &ultra_pio_input;
 		ei_status.block_output = &ultra_pio_output;
 		ei_status.get_8390_hdr = &ultra_pio_get_hdr;
 	} else {
-		printk(",%s IRQ %d memory %#lx-%#lx.\n", eeprom_irq ? "" : "assigned ",
-			   dev->irq, dev->mem_start, dev->mem_end-1);
+		pr_cont(", %s IRQ %d memory %#lx-%#lx.\n",
+			eeprom_irq ? "" : "assigned ", dev->irq, dev->mem_start,
+			dev->mem_end-1);
 		ei_status.block_input = &ultra_block_input;
 		ei_status.block_output = &ultra_block_output;
 		ei_status.get_8390_hdr = &ultra_get_8390_hdr;
@@ -320,6 +323,7 @@ static int __init ultra_probe1(struct net_device *dev, int ioaddr)
 
 	dev->netdev_ops = &ultra_netdev_ops;
 	NS8390_init(dev, 0);
+	ei_local->msg_enable = ultra_debug;
 
 	retval = register_netdev(dev);
 	if (retval)
@@ -356,12 +360,15 @@ static int __init ultra_probe_isapnp(struct net_device *dev)
                         /* found it */
 			dev->base_addr = pnp_port_start(idev, 0);
 			dev->irq = pnp_irq(idev, 0);
-                        printk(KERN_INFO "smc-ultra.c: ISAPnP reports %s at i/o %#lx, irq %d.\n",
-                                (char *) ultra_device_ids[i].driver_data,
-                                dev->base_addr, dev->irq);
+			netdev_info(dev,
+				    "smc-ultra.c: ISAPnP reports %s at i/o %#lx, irq %d.\n",
+				    (char *) ultra_device_ids[i].driver_data,
+				    dev->base_addr, dev->irq);
                         if (ultra_probe1(dev, dev->base_addr) != 0) {      /* Shouldn't happen. */
-                                printk(KERN_ERR "smc-ultra.c: Probe of ISAPnP card at %#lx failed.\n", dev->base_addr);
-                                pnp_device_detach(idev);
+				netdev_err(dev,
+					   "smc-ultra.c: Probe of ISAPnP card at %#lx failed.\n",
+					   dev->base_addr);
+				pnp_device_detach(idev);
 				return -ENXIO;
                         }
                         ei_status.priv = (unsigned long)idev;
@@ -412,9 +419,11 @@ static void
 ultra_reset_8390(struct net_device *dev)
 {
 	int cmd_port = dev->base_addr - ULTRA_NIC_OFFSET; /* ASIC base addr */
+	struct ei_device *ei_local = netdev_priv(dev);
 
 	outb(ULTRA_RESET, cmd_port);
-	if (ei_debug > 1) printk("resetting Ultra, t=%ld...", jiffies);
+	if (ei_local->msg_enable & NETIF_MSG_HW)
+		netdev_dbg(dev, "resetting Ultra, t=%ld...\n", jiffies);
 	ei_status.txing = 0;
 
 	outb(0x00, cmd_port);	/* Disable shared memory for safety. */
@@ -424,7 +433,8 @@ ultra_reset_8390(struct net_device *dev)
 	else
 		outb(0x01, cmd_port + 6);		/* Enable interrupts and memory. */
 
-	if (ei_debug > 1) printk("reset done\n");
+	if (ei_local->msg_enable & NETIF_MSG_HW)
+		netdev_dbg(dev, "reset done\n");
 }
 
 /* Grab the 8390 specific header. Similar to the block_input routine, but
@@ -530,11 +540,12 @@ static int
 ultra_close_card(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr - ULTRA_NIC_OFFSET; /* CMDREG */
+	struct ei_device *ei_local = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
-	if (ei_debug > 1)
-		printk("%s: Shutting down ethercard.\n", dev->name);
+	if (ei_local->msg_enable & NETIF_MSG_IFDOWN)
+		netdev_dbg(dev, "Shutting down ethercard.\n");
 
 	outb(0x00, ioaddr + 6);		/* Disable interrupts. */
 	free_irq(dev->irq, dev);
@@ -556,8 +567,10 @@ static int irq[MAX_ULTRA_CARDS];
 
 module_param_array(io, int, NULL, 0);
 module_param_array(irq, int, NULL, 0);
+module_param_named(debug, ultra_debug, uint, (S_IRUSR|S_IRGRP|S_IROTH));
 MODULE_PARM_DESC(io, "I/O base address(es)");
 MODULE_PARM_DESC(irq, "IRQ number(s) (assigned)");
+MODULE_PARM_DESC(debug, "Debug message level (see linux/netdevice.h for bitmap)");
 MODULE_DESCRIPTION("SMC Ultra/EtherEZ ISA/PnP Ethernet driver");
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/net/ethernet/8390/stnic.c b/drivers/net/ethernet/8390/stnic.c
index 8df4c41..c59d8c8 100644
--- a/drivers/net/ethernet/8390/stnic.c
+++ b/drivers/net/ethernet/8390/stnic.c
@@ -69,6 +69,11 @@ static void stnic_block_output (struct net_device *dev, int count,
 
 static void stnic_init (struct net_device *dev);
 
+static u32 stnic_debug;
+
+module_param_named(debug, stnic_debug, uint, (S_IRUSR|S_IRGRP|S_IROTH));
+MODULE_PARM_DESC(debug, "Debug message level (see linux/netdevice.h for bitmap)");
+
 /* SH7750 specific read/write io. */
 static inline void
 STNIC_DELAY (void)
@@ -100,6 +105,7 @@ static int __init stnic_probe(void)
 {
   struct net_device *dev;
   int i, err;
+  struct ei_device *ei_local;
 
   /* If we are not running on a SolutionEngine, give up now */
   if (! MACH_SE)
@@ -125,10 +131,10 @@ static int __init stnic_probe(void)
      share and the board will usually be enabled. */
   err = request_irq (dev->irq, ei_interrupt, 0, DRV_NAME, dev);
   if (err)  {
-      printk (KERN_EMERG " unable to get IRQ %d.\n", dev->irq);
-      free_netdev(dev);
-      return err;
-    }
+	netdev_emerg(dev, " unable to get IRQ %d.\n", dev->irq);
+	free_netdev(dev);
+	return err;
+  }
 
   ei_status.name = dev->name;
   ei_status.word16 = 1;
@@ -147,6 +153,8 @@ static int __init stnic_probe(void)
   ei_status.block_output = &stnic_block_output;
 
   stnic_init (dev);
+  ei_local = netdev_priv(dev);
+  ei_local->msg_enable = stnic_debug;
 
   err = register_netdev(dev);
   if (err) {
@@ -156,7 +164,7 @@ static int __init stnic_probe(void)
   }
   stnic_dev = dev;
 
-  printk (KERN_INFO "NS ST-NIC 83902A\n");
+  netdev_info(dev, "NS ST-NIC 83902A\n");
 
   return 0;
 }
@@ -164,10 +172,12 @@ static int __init stnic_probe(void)
 static void
 stnic_reset (struct net_device *dev)
 {
+  struct ei_device *ei_local = netdev_priv(dev);
+
   *(vhalf *) PA_83902_RST = 0;
   udelay (5);
-  if (ei_debug > 1)
-    printk (KERN_WARNING "8390 reset done (%ld).\n", jiffies);
+  if (ei_local->msg_enable & NETIF_MSG_HW)
+		netdev_warn(dev, "8390 reset done (%ld).\n", jiffies);
   *(vhalf *) PA_83902_RST = ~0;
   udelay (5);
 }
@@ -176,6 +186,8 @@ static void
 stnic_get_hdr (struct net_device *dev, struct e8390_pkt_hdr *hdr,
 	       int ring_page)
 {
+  struct ei_device *ei_local = netdev_priv(dev);
+
   half buf[2];
 
   STNIC_WRITE (PG0_RSAR0, 0);
@@ -196,9 +208,9 @@ stnic_get_hdr (struct net_device *dev, struct e8390_pkt_hdr *hdr,
   hdr->count = ((buf[1] >> 8) & 0xff) | (buf[1] << 8);
 #endif
 
-  if (ei_debug > 1)
-    printk (KERN_DEBUG "ring %x status %02x next %02x count %04x.\n",
-	    ring_page, hdr->status, hdr->next, hdr->count);
+  if (ei_local->msg_enable & NETIF_MSG_PROBE)
+	netdev_dbg(dev, "ring %x status %02x next %02x count %04x.\n",
+		   ring_page, hdr->status, hdr->next, hdr->count);
 
   STNIC_WRITE (STNIC_CR, CR_RDMA | CR_PG0 | CR_STA);
 }
diff --git a/drivers/net/ethernet/8390/wd.c b/drivers/net/ethernet/8390/wd.c
index 03eb3ee..36fa7cc 100644
--- a/drivers/net/ethernet/8390/wd.c
+++ b/drivers/net/ethernet/8390/wd.c
@@ -60,6 +60,7 @@ static void wd_block_output(struct net_device *dev, int count,
 							const unsigned char *buf, int start_page);
 static int wd_close(struct net_device *dev);
 
+static u32 wd_debug;
 
 #define WD_START_PG		0x00	/* First page of TX buffer */
 #define WD03_STOP_PG	0x20	/* Last page +1 of RX ring */
@@ -170,6 +171,7 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 	int word16 = 0;				/* 0 = 8 bit, 1 = 16 bit */
 	const char *model_name;
 	static unsigned version_printed;
+	struct ei_device *ei_local = netdev_priv(dev);
 
 	for (i = 0; i < 8; i++)
 		checksum += inb(ioaddr + 8 + i);
@@ -180,19 +182,19 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 
 	/* Check for semi-valid mem_start/end values if supplied. */
 	if ((dev->mem_start % 0x2000) || (dev->mem_end % 0x2000)) {
-		printk(KERN_WARNING "wd.c: user supplied mem_start or mem_end not on 8kB boundary - ignored.\n");
+		netdev_warn(dev,
+			    "wd.c: user supplied mem_start or mem_end not on 8kB boundary - ignored.\n");
 		dev->mem_start = 0;
 		dev->mem_end = 0;
 	}
 
-	if (ei_debug  &&  version_printed++ == 0)
-		printk(version);
+	if ((ei_local->msg_enable & NETIF_MSG_DRV) &&  version_printed++ == 0)
+		netdev_info(dev, version);
 
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = inb(ioaddr + 8 + i);
 
-	printk("%s: WD80x3 at %#3x, %pM",
-	       dev->name, ioaddr, dev->dev_addr);
+	netdev_info(dev, "WD80x3 at %#3x, %pM", ioaddr, dev->dev_addr);
 
 	/* The following PureData probe code was contributed by
 	   Mike Jagdis <jaggy@purplet.demon.co.uk>. Puredata does software
@@ -244,8 +246,10 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 		}
 #ifndef final_version
 		if ( !ancient && (inb(ioaddr+1) & 0x01) != (word16 & 0x01))
-			printk("\nWD80?3: Bus width conflict, %d (probe) != %d (reg report).",
-				   word16 ? 16 : 8, (inb(ioaddr+1) & 0x01) ? 16 : 8);
+			netdev_dbg(dev,
+				   "\nWD80?3: Bus width conflict, %d (probe) != %d (reg report).",
+				   word16 ? 16 : 8,
+				   (inb(ioaddr+1) & 0x01) ? 16 : 8);
 #endif
 	}
 
@@ -259,7 +263,7 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 		if (reg0 == 0xff || reg0 == 0) {
 			/* Future plan: this could check a few likely locations first. */
 			dev->mem_start = 0xd0000;
-			printk(" assigning address %#lx", dev->mem_start);
+			pr_cont(" assigning address %#lx", dev->mem_start);
 		} else {
 			int high_addr_bits = inb(ioaddr+WD_CMDREG5) & 0x1f;
 			/* Some boards don't have the register 5 -- it returns 0xff. */
@@ -297,8 +301,8 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 
 			outb_p(0x00, nic_addr+EN0_IMR);	/* Mask all intrs. again. */
 
-			if (ei_debug > 2)
-				printk(" autoirq is %d", dev->irq);
+			if (wd_debug & NETIF_MSG_DRV)
+				pr_cont(" autoirq is %d", dev->irq);
 			if (dev->irq < 2)
 				dev->irq = word16 ? 10 : 5;
 		} else
@@ -310,7 +314,7 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 	   share and the board will usually be enabled. */
 	i = request_irq(dev->irq, ei_interrupt, 0, DRV_NAME, dev);
 	if (i) {
-		printk (" unable to get IRQ %d.\n", dev->irq);
+		pr_cont(" unable to get IRQ %d.\n", dev->irq);
 		return i;
 	}
 
@@ -338,8 +342,8 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 		return -ENOMEM;
 	}
 
-	printk(" %s, IRQ %d, shared memory at %#lx-%#lx.\n",
-		   model_name, dev->irq, dev->mem_start, dev->mem_end-1);
+	pr_cont(" %s, IRQ %d, shared memory at %#lx-%#lx.\n",
+		model_name, dev->irq, dev->mem_start, dev->mem_end-1);
 
 	ei_status.reset_8390 = wd_reset_8390;
 	ei_status.block_input = wd_block_input;
@@ -348,6 +352,7 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 
 	dev->netdev_ops = &wd_netdev_ops;
 	NS8390_init(dev, 0);
+	ei_local->msg_enable = wd_debug;
 
 #if 1
 	/* Enable interrupt generation on softconfig cards -- M.U */
@@ -385,9 +390,11 @@ static void
 wd_reset_8390(struct net_device *dev)
 {
 	int wd_cmd_port = dev->base_addr - WD_NIC_OFFSET; /* WD_CMDREG */
+	struct ei_device *ei_local = netdev_priv(dev);
 
 	outb(WD_RESET, wd_cmd_port);
-	if (ei_debug > 1) printk("resetting the WD80x3 t=%lu...", jiffies);
+	if (ei_local->msg_enable & NETIF_MSG_HW)
+		netdev_dbg(dev, "resetting the WD80x3 t=%lu...\n", jiffies);
 	ei_status.txing = 0;
 
 	/* Set up the ASIC registers, just in case something changed them. */
@@ -395,7 +402,8 @@ wd_reset_8390(struct net_device *dev)
 	if (ei_status.word16)
 		outb(NIC16 | ((dev->mem_start>>19) & 0x1f), wd_cmd_port+WD_CMDREG5);
 
-	if (ei_debug > 1) printk("reset done\n");
+	if (ei_local->msg_enable & NETIF_MSG_HW)
+		netdev_dbg(dev, "reset done\n");
 }
 
 /* Grab the 8390 specific header. Similar to the block_input routine, but
@@ -474,9 +482,10 @@ static int
 wd_close(struct net_device *dev)
 {
 	int wd_cmdreg = dev->base_addr - WD_NIC_OFFSET; /* WD_CMDREG */
+	struct ei_device *ei_local = netdev_priv(dev);
 
-	if (ei_debug > 1)
-		printk("%s: Shutting down ethercard.\n", dev->name);
+	if (ei_local->msg_enable & NETIF_MSG_IFDOWN)
+		netdev_dbg(dev, "Shutting down ethercard.\n");
 	ei_close(dev);
 
 	/* Change from 16-bit to 8-bit shared memory so reboot works. */
@@ -502,10 +511,12 @@ module_param_array(io, int, NULL, 0);
 module_param_array(irq, int, NULL, 0);
 module_param_array(mem, int, NULL, 0);
 module_param_array(mem_end, int, NULL, 0);
+module_param_named(debug, wd_debug, uint, (S_IRUSR|S_IRGRP|S_IROTH));
 MODULE_PARM_DESC(io, "I/O base address(es)");
 MODULE_PARM_DESC(irq, "IRQ number(s) (ignored for PureData boards)");
 MODULE_PARM_DESC(mem, "memory base address(es)(ignored for PureData boards)");
 MODULE_PARM_DESC(mem_end, "memory end address(es)");
+MODULE_PARM_DESC(debug, "Debug message level (see linux/netdevice.h for bitmap)");
 MODULE_DESCRIPTION("ISA Western Digital wd8003/wd8013 ; SMC Elite, Elite16 ethernet driver");
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/net/ethernet/8390/zorro8390.c b/drivers/net/ethernet/8390/zorro8390.c
index 85ec4c2..5bb859d 100644
--- a/drivers/net/ethernet/8390/zorro8390.c
+++ b/drivers/net/ethernet/8390/zorro8390.c
@@ -44,6 +44,8 @@
 static const char version[] =
 	"8390.c:v1.10cvs 9/23/94 Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
 
+static u32 zorro8390_debug;
+
 #include "lib8390.c"
 
 #define DRV_NAME	"zorro8390"
@@ -86,8 +88,9 @@ static struct card_info {
 static void zorro8390_reset_8390(struct net_device *dev)
 {
 	unsigned long reset_start_time = jiffies;
+	struct ei_device *ei_local = netdev_priv(dev);
 
-	if (ei_debug > 1)
+	if (ei_local->msg_enable & NETIF_MSG_HW)
 		netdev_dbg(dev, "resetting - t=%ld...\n", jiffies);
 
 	z_writeb(z_readb(NE_BASE + NE_RESET), NE_BASE + NE_RESET);
@@ -119,8 +122,9 @@ static void zorro8390_get_8390_hdr(struct net_device *dev,
 	 * If it does, it's the last thing you'll see
 	 */
 	if (ei_status.dmaing) {
-		netdev_err(dev, "%s: DMAing conflict [DMAstat:%d][irqlock:%d]\n",
-			   __func__, ei_status.dmaing, ei_status.irqlock);
+		netdev_warn(dev,
+			    "%s: DMAing conflict [DMAstat:%d][irqlock:%d]\n",
+			    __func__, ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
 
@@ -230,7 +234,7 @@ static void zorro8390_block_output(struct net_device *dev, int count,
 	while ((z_readb(NE_BASE + NE_EN0_ISR) & ENISR_RDC) == 0)
 		if (time_after(jiffies, dma_start + 2 * HZ / 100)) {
 					/* 20ms */
-			netdev_err(dev, "timeout waiting for Tx RDC\n");
+			netdev_warn(dev, "timeout waiting for Tx RDC\n");
 			zorro8390_reset_8390(dev);
 			__NS8390_init(dev, 1);
 			break;
@@ -248,7 +252,9 @@ static int zorro8390_open(struct net_device *dev)
 
 static int zorro8390_close(struct net_device *dev)
 {
-	if (ei_debug > 1)
+	struct ei_device *ei_local = netdev_priv(dev);
+
+	if (ei_local->msg_enable & NETIF_MSG_IFDOWN)
 		netdev_dbg(dev, "Shutting down ethercard\n");
 	__ei_close(dev);
 	return 0;
@@ -293,6 +299,7 @@ static int zorro8390_init(struct net_device *dev, unsigned long board,
 	int err;
 	unsigned char SA_prom[32];
 	int start_page, stop_page;
+	struct ei_device *ei_local = netdev_priv(dev);
 	static u32 zorro8390_offsets[16] = {
 		0x00, 0x02, 0x04, 0x06, 0x08, 0x0a, 0x0c, 0x0e,
 		0x10, 0x12, 0x14, 0x16, 0x18, 0x1a, 0x1c, 0x1e,
@@ -383,6 +390,9 @@ static int zorro8390_init(struct net_device *dev, unsigned long board,
 
 	dev->netdev_ops = &zorro8390_netdev_ops;
 	__NS8390_init(dev, 0);
+
+	ei_local->msg_enable = zorro8390_debug;
+
 	err = register_netdev(dev);
 	if (err) {
 		free_irq(IRQ_AMIGA_PORTS, dev);
-- 
1.7.1
