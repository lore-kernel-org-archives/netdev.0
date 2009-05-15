From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 3/5] de620: convert PRINTK() to pr_debug() and cleanup
Date: Sat, 16 May 2009 00:22:40 +0400
Message-ID: <1242418962-1272-3-git-send-email-a.beregalov@gmail.com>
References: <1242418962-1272-1-git-send-email-a.beregalov@gmail.com>
 <1242418962-1272-2-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:65283 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886AbZEOUXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 16:23:08 -0400
Received: by fxm2 with SMTP id 2so2142199fxm.37
        for <netdev@vger.kernel.org>; Fri, 15 May 2009 13:23:08 -0700 (PDT)
In-Reply-To: <1242418962-1272-2-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also remove DE620_DEBUG and de620_debug.

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/de620.c |   59 +++++++++++++++-----------------------------------
 1 files changed, 18 insertions(+), 41 deletions(-)

diff --git a/drivers/net/de620.c b/drivers/net/de620.c
index c5cd6e3..039bc1a 100644
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -48,7 +48,6 @@ static const char version[] =
  * Compile-time options: (see below for descriptions)
  * -DDE620_IO=0x378	(lpt1)
  * -DDE620_IRQ=7	(lpt1)
- * -DDE602_DEBUG=...
  * -DSHUTDOWN_WHEN_LOST
  * -DCOUNT_LOOPS
  * -DLOWSPEED
@@ -98,15 +97,6 @@ static const char version[] =
 #define SHUTDOWN_WHEN_LOST
  */
 
-/*
- * Enable debugging by "-DDE620_DEBUG=3" when compiling,
- * OR by enabling the following #define
- *
- * use 0 for production, 1 for verification, >2 for debug
- *
-#define DE620_DEBUG 3
- */
-
 #ifdef LOWSPEED
 /*
  * Enable this #define if you want to see debugging output that show how long
@@ -160,14 +150,6 @@ typedef unsigned char byte;
 #define RUNT 60		/* Too small Ethernet packet */
 #define GIANT 1514	/* largest legal size packet, no fcs */
 
-#ifdef DE620_DEBUG /* Compile-time configurable */
-#define PRINTK(x) if (de620_debug >= 2) printk x
-#else
-#define DE620_DEBUG 0
-#define PRINTK(x) /**/
-#endif
-
-
 /*
  * Force media with insmod:
  *	insmod de620.o bnc=1
@@ -186,8 +168,6 @@ static int io  = DE620_IO;
 static int irq = DE620_IRQ;
 static int clone = DE620_CLONE;
 
-static unsigned int de620_debug = DE620_DEBUG;
-
 static spinlock_t de620_lock;
 
 module_param(bnc, int, 0);
@@ -195,13 +175,11 @@ module_param(utp, int, 0);
 module_param(io, int, 0);
 module_param(irq, int, 0);
 module_param(clone, int, 0);
-module_param(de620_debug, int, 0);
 MODULE_PARM_DESC(bnc, "DE-620 set BNC medium (0-1)");
 MODULE_PARM_DESC(utp, "DE-620 set UTP medium (0-1)");
 MODULE_PARM_DESC(io, "DE-620 I/O base address,required");
 MODULE_PARM_DESC(irq, "DE-620 IRQ number,required");
 MODULE_PARM_DESC(clone, "Check also for non-D-Link DE-620 clones (0-1)");
-MODULE_PARM_DESC(de620_debug, "DE-620 debug level (0-2)");
 
 /***********************************************
  *                                             *
@@ -534,8 +512,8 @@ static int de620_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Start real output */
 
 	spin_lock_irqsave(&de620_lock, flags);
-	PRINTK(("de620_start_xmit: len=%d, bufs 0x%02x\n",
-		(int)skb->len, using_txbuf));
+	pr_debug("de620_start_xmit: len=%d, bufs 0x%02x\n",
+		(int)skb->len, using_txbuf);
 
 	/* select a free tx buffer. if there is one... */
 	switch (using_txbuf) {
@@ -585,12 +563,12 @@ de620_interrupt(int irq_in, void *dev_id)
 	/* Read the status register (_not_ the status port) */
 	irq_status = de620_get_register(dev, R_STS);
 
-	PRINTK(("de620_interrupt (%2.2X)\n", irq_status));
+	pr_debug("de620_interrupt (%2.2X)\n", irq_status);
 
 	if (irq_status & RXGOOD) {
 		do {
 			again = de620_rx_intr(dev);
-			PRINTK(("again=%d\n", again));
+			pr_debug("again=%d\n", again);
 		}
 		while (again && (++bogus_count < 100));
 	}
@@ -622,7 +600,7 @@ static int de620_rx_intr(struct net_device *dev)
 	byte pagelink;
 	byte curr_page;
 
-	PRINTK(("de620_rx_intr: next_rx_page = %d\n", next_rx_page));
+	pr_debug("de620_rx_intr: next_rx_page = %d\n", next_rx_page);
 
 	/* Tell the adapter that we are going to read data, and from where */
 	de620_send_command(dev, W_CR | RRN);
@@ -631,8 +609,9 @@ static int de620_rx_intr(struct net_device *dev)
 
 	/* Deep breath, and away we goooooo */
 	de620_read_block(dev, (byte *)&header_buf, sizeof(struct header_buf));
-	PRINTK(("page status=0x%02x, nextpage=%d, packetsize=%d\n",
-	header_buf.status, header_buf.Rx_NextPage, header_buf.Rx_ByteCount));
+	pr_debug("page status=0x%02x, nextpage=%d, packetsize=%d\n",
+		header_buf.status, header_buf.Rx_NextPage,
+		header_buf.Rx_ByteCount);
 
 	/* Plausible page header? */
 	pagelink = header_buf.Rx_NextPage;
@@ -683,7 +662,7 @@ static int de620_rx_intr(struct net_device *dev)
 			buffer = skb_put(skb,size);
 			/* copy the packet into the buffer */
 			de620_read_block(dev, buffer, size);
-			PRINTK(("Read %d bytes\n", size));
+			pr_debug("Read %d bytes\n", size);
 			skb->protocol=eth_type_trans(skb,dev);
 			netif_rx(skb); /* deliver it "upstairs" */
 			/* count all receives */
@@ -696,7 +675,7 @@ static int de620_rx_intr(struct net_device *dev)
 	/* NOTE! We're _not_ checking the 'EMPTY'-flag! This seems better... */
 	curr_page = de620_get_register(dev, R_CPR);
 	de620_set_register(dev, W_NPRF, next_rx_page);
-	PRINTK(("next_rx_page=%d CPR=%d\n", next_rx_page, curr_page));
+	pr_debug("next_rx_page=%d CPR=%d\n", next_rx_page, curr_page);
 
 	return (next_rx_page != curr_page); /* That was slightly tricky... */
 }
@@ -830,8 +809,7 @@ struct net_device * __init de620_probe(int unit)
 		netdev_boot_setup_check(dev);
 	}
 
-	if (de620_debug)
-		printk(version);
+	pr_debug("%s", version);
 
 	printk(KERN_INFO "D-Link DE-620 pocket adapter");
 
@@ -878,14 +856,13 @@ struct net_device * __init de620_probe(int unit)
 	/* base_addr and irq are already set, see above! */
 
 	/* dump eeprom */
-	if (de620_debug) {
-		printk("\nEEPROM contents:\n");
-		printk("RAM_Size = 0x%02X\n", nic_data.RAM_Size);
-		printk("NodeID = %pM\n", nic_data.NodeID);
-		printk("Model = %d\n", nic_data.Model);
-		printk("Media = %d\n", nic_data.Media);
-		printk("SCR = 0x%02x\n", nic_data.SCR);
-	}
+	pr_debug("\nEEPROM contents:\n"
+		"RAM_Size = 0x%02X\n"
+		"NodeID = %pM\n"
+		"Model = %d\n"
+		"Media = %d\n"
+		"SCR = 0x%02x\n", nic_data.RAM_Size, nic_data.NodeID,
+		nic_data.Model, nic_data.Media, nic_data.SCR);
 
 	err = register_netdev(dev);
 	if (err)
-- 
1.6.3

