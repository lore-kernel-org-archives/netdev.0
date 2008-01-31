From: Ben Dooks <ben-linux@fluff.org>
Subject: NET: AX88796 use dev_dbg() instead of printk()
Date: Thu, 31 Jan 2008 11:25:31 +0000
Message-ID: <20080131112531.187305225@fluff.org.uk>
Cc: davem@davemloft.net, jgarzik@redhat.com,
	Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:62369 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758386AbYAaL4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 06:56:30 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-ax88796-consitentdebug.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change to using dev_dbg() and the other dev_xxx()
macros instead of printk, and update to use the
print_mac() helper.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.24-quilt1/drivers/net/ax88796.c
===================================================================
--- linux-2.6.24-quilt1.orig/drivers/net/ax88796.c
+++ linux-2.6.24-quilt1/drivers/net/ax88796.c
@@ -137,11 +137,12 @@ static int ax_initial_check(struct net_d
 static void ax_reset_8390(struct net_device *dev)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
+	struct ax_device  *ax = to_ax_dev(dev);
 	unsigned long reset_start_time = jiffies;
 	void __iomem *addr = (void __iomem *)dev->base_addr;
 
 	if (ei_debug > 1)
-		printk(KERN_DEBUG "resetting the 8390 t=%ld...", jiffies);
+		dev_dbg(&ax->dev->dev, "resetting the 8390 t=%ld\n", jiffies);
 
 	ei_outb(ei_inb(addr + NE_RESET), addr + NE_RESET);
 
@@ -151,7 +152,7 @@ static void ax_reset_8390(struct net_dev
 	/* This check _should_not_ be necessary, omit eventually. */
 	while ((ei_inb(addr + EN0_ISR) & ENISR_RESET) == 0) {
 		if (jiffies - reset_start_time > 2*HZ/100) {
-			printk(KERN_WARNING "%s: %s did not complete.\n",
+			dev_warn(&ax->dev->dev, "%s: %s did not complete.\n",
 			       __FUNCTION__, dev->name);
 			break;
 		}
@@ -165,13 +166,15 @@ static void ax_get_8390_hdr(struct net_d
 			    int ring_page)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
+	struct ax_device  *ax = to_ax_dev(dev);
 	void __iomem *nic_base = ei_local->mem;
 
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_status.dmaing) {
-		printk(KERN_EMERG "%s: DMAing conflict in %s [DMAstat:%d][irqlock:%d].\n",
+		dev_err(&ax->dev->dev, "%s: DMAing conflict in %s "
+			"[DMAstat:%d][irqlock:%d].\n",
 			dev->name, __FUNCTION__,
-		       ei_status.dmaing, ei_status.irqlock);
+			ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
 
@@ -204,13 +207,16 @@ static void ax_block_input(struct net_de
 			   struct sk_buff *skb, int ring_offset)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
+	struct ax_device  *ax = to_ax_dev(dev);
 	void __iomem *nic_base = ei_local->mem;
 	char *buf = skb->data;
 
 	if (ei_status.dmaing) {
-		printk(KERN_EMERG "%s: DMAing conflict in ax_block_input "
+		dev_err(&ax->dev->dev,
+			"%s: DMAing conflict in %s "
 			"[DMAstat:%d][irqlock:%d].\n",
-			dev->name, ei_status.dmaing, ei_status.irqlock);
+			dev->name, __FUNCTION__,
+			ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
 
@@ -239,6 +245,7 @@ static void ax_block_output(struct net_d
 			    const unsigned char *buf, const int start_page)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
+	struct ax_device  *ax = to_ax_dev(dev);
 	void __iomem *nic_base = ei_local->mem;
 	unsigned long dma_start;
 
@@ -251,7 +258,7 @@ static void ax_block_output(struct net_d
 
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_status.dmaing) {
-		printk(KERN_EMERG "%s: DMAing conflict in %s."
+		dev_err(&ax->dev->dev, "%s: DMAing conflict in %s."
 			"[DMAstat:%d][irqlock:%d]\n",
 			dev->name, __FUNCTION__,
 		       ei_status.dmaing, ei_status.irqlock);
@@ -281,7 +288,8 @@ static void ax_block_output(struct net_d
 
 	while ((ei_inb(nic_base + EN0_ISR) & ENISR_RDC) == 0) {
 		if (jiffies - dma_start > 2*HZ/100) {		/* 20ms */
-			printk(KERN_WARNING "%s: timeout waiting for Tx RDC.\n", dev->name);
+			dev_warn(&ax->dev->dev,
+				 "%s: timeout waiting for Tx RDC.\n", dev->name);
 			ax_reset_8390(dev);
 			ax_NS8390_init(dev,1);
 			break;
@@ -424,10 +432,11 @@ static void
 ax_phy_write(struct net_device *dev, int phy_addr, int reg, int value)
 {
 	struct ei_device *ei = (struct ei_device *) netdev_priv(dev);
+	struct ax_device  *ax = to_ax_dev(dev);
 	unsigned long flags;
 
-	printk(KERN_DEBUG "%s: %p, %04x, %04x %04x\n",
-	       __FUNCTION__, dev, phy_addr, reg, value);
+	dev_dbg(&ax->dev->dev, "%s: %p, %04x, %04x %04x\n",
+		__FUNCTION__, dev, phy_addr, reg, value);
 
       	spin_lock_irqsave(&ei->page_lock, flags);
 
@@ -750,14 +759,11 @@ static int ax_init_dev(struct net_device
 	ax_NS8390_init(dev, 0);
 
 	if (first_init) {
-		printk("AX88796: %dbit, irq %d, %lx, MAC: ",
-		       ei_status.word16 ? 16:8, dev->irq, dev->base_addr);
-
-		for (i = 0; i < ETHER_ADDR_LEN; i++)
-			printk("%2.2x%c", dev->dev_addr[i],
-			       (i < (ETHER_ADDR_LEN-1) ? ':' : ' '));
+		DECLARE_MAC_BUF(mac);
 
-		printk("\n");
+		dev_info(&ax->dev->dev, "%dbit, irq %d, %lx, MAC: %s\n",
+			 ei_status.word16 ? 16:8, dev->irq, dev->base_addr,
+			 print_mac(mac, dev->dev_addr));
 	}
 
 	ret = register_netdev(dev);

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
