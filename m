From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: ioremap() failure checks in drivers
Date: Thu, 22 Jun 2006 22:29:28 +0200
Message-ID: <m3odwlvsrb.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:57309 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1161334AbWFVU3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 16:29:30 -0400
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Sesterhenn found that pci200syn initialization lacks return
statement in ioremap() error path (coverity bug id #195). It looks
like more WAN drivers have problems with ioremap().

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

--- a/drivers/net/wan/c101.c
+++ b/drivers/net/wan/c101.c
@@ -326,21 +326,21 @@ static int __init c101_run(unsigned long
 	if (request_irq(irq, sca_intr, 0, devname, card)) {
 		printk(KERN_ERR "c101: could not allocate IRQ\n");
 		c101_destroy_card(card);
-		return(-EBUSY);
+		return -EBUSY;
 	}
 	card->irq = irq;
 
 	if (!request_mem_region(winbase, C101_MAPPED_RAM_SIZE, devname)) {
 		printk(KERN_ERR "c101: could not request RAM window\n");
 		c101_destroy_card(card);
-		return(-EBUSY);
+		return -EBUSY;
 	}
 	card->phy_winbase = winbase;
 	card->win0base = ioremap(winbase, C101_MAPPED_RAM_SIZE);
 	if (!card->win0base) {
 		printk(KERN_ERR "c101: could not map I/O address\n");
 		c101_destroy_card(card);
-		return -EBUSY;
+		return -EFAULT;
 	}
 
 	card->tx_ring_buffers = TX_RING_BUFFERS;
--- a/drivers/net/wan/n2.c
+++ b/drivers/net/wan/n2.c
@@ -387,6 +387,11 @@ static int __init n2_run(unsigned long i
 	}
 	card->phy_winbase = winbase;
 	card->winbase = ioremap(winbase, USE_WINDOWSIZE);
+	if (!card->winbase) {
+		printk(KERN_ERR "n2: ioremap() failed\n");
+		n2_destroy_card(card);
+		return -EFAULT;
+	}
 
 	outb(0, io + N2_PCR);
 	outb(winbase >> 12, io + N2_BAR);
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -358,6 +358,7 @@ #endif
 	    card->rambase == NULL) {
 		printk(KERN_ERR "pci200syn: ioremap() failed\n");
 		pci200_pci_remove_one(pdev);
+		return -EFAULT;
 	}
 
 	/* Reset PLX */
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -634,7 +634,13 @@ #endif
 
 	/* set up PLX mapping */
 	plx_phy = pci_resource_start(pdev, 0);
+
 	card->plx = ioremap_nocache(plx_phy, 0x70);
+	if (!card->plx) {
+		printk(KERN_ERR "wanxl: ioremap() failed\n");
+ 		wanxl_pci_remove_one(pdev);
+		return -EFAULT;
+	}
 
 #if RESET_WHILE_LOADING
 	wanxl_reset(card);
@@ -700,6 +706,12 @@ #endif
 	}
 
 	mem = ioremap_nocache(mem_phy, PDM_OFFSET + sizeof(firmware));
+	if (!mem) {
+		printk(KERN_ERR "wanxl: ioremap() failed\n");
+ 		wanxl_pci_remove_one(pdev);
+		return -EFAULT;
+	}
+
 	for (i = 0; i < sizeof(firmware); i += 4)
 		writel(htonl(*(u32*)(firmware + i)), mem + PDM_OFFSET + i);
 
