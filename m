From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/8] cosa: Update to current logging forms
Date: Sun, 26 Jun 2011 22:01:29 -0700
Message-ID: <61af65d0325575eea0bbd7af411e6ea29e1cc443.1309150684.git.joe@perches.com>
References: <cover.1309150683.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, "Jan \"Yenya\" Kasprzak" <kas@fi.muni.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1309150683.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use pr_fmt, pr_<level> and netdev_<level> as appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wan/cosa.c |  226 ++++++++++++++++++++++-------------------------
 1 files changed, 106 insertions(+), 120 deletions(-)

diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index 6fb6f8e..6aed238 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -74,6 +74,8 @@
  * The Sync PPP/Cisco HDLC layer (syncppp.c) ported to Linux by Alan Cox
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
@@ -361,14 +363,13 @@ static int __init cosa_init(void)
 
 	if (cosa_major > 0) {
 		if (register_chrdev(cosa_major, "cosa", &cosa_fops)) {
-			printk(KERN_WARNING "cosa: unable to get major %d\n",
-				cosa_major);
+			pr_warn("unable to get major %d\n", cosa_major);
 			err = -EIO;
 			goto out;
 		}
 	} else {
 		if (!(cosa_major=register_chrdev(0, "cosa", &cosa_fops))) {
-			printk(KERN_WARNING "cosa: unable to register chardev\n");
+			pr_warn("unable to register chardev\n");
 			err = -EIO;
 			goto out;
 		}
@@ -378,7 +379,7 @@ static int __init cosa_init(void)
 	for (i=0; io[i] != 0 && i < MAX_CARDS; i++)
 		cosa_probe(io[i], irq[i], dma[i]);
 	if (!nr_cards) {
-		printk(KERN_WARNING "cosa: no devices found.\n");
+		pr_warn("no devices found\n");
 		unregister_chrdev(cosa_major, "cosa");
 		err = -ENODEV;
 		goto out;
@@ -447,26 +448,25 @@ static int cosa_probe(int base, int irq, int dma)
 	/* Checking validity of parameters: */
 	/* IRQ should be 2-7 or 10-15; negative IRQ means autoprobe */
 	if ((irq >= 0  && irq < 2) || irq > 15 || (irq < 10 && irq > 7)) {
-		printk (KERN_INFO "cosa_probe: invalid IRQ %d\n", irq);
+		pr_info("invalid IRQ %d\n", irq);
 		return -1;
 	}
 	/* I/O address should be between 0x100 and 0x3ff and should be
 	 * multiple of 8. */
 	if (base < 0x100 || base > 0x3ff || base & 0x7) {
-		printk (KERN_INFO "cosa_probe: invalid I/O address 0x%x\n",
-			base);
+		pr_info("invalid I/O address 0x%x\n", base);
 		return -1;
 	}
 	/* DMA should be 0,1 or 3-7 */
 	if (dma < 0 || dma == 4 || dma > 7) {
-		printk (KERN_INFO "cosa_probe: invalid DMA %d\n", dma);
+		pr_info("invalid DMA %d\n", dma);
 		return -1;
 	}
 	/* and finally, on 16-bit COSA DMA should be 4-7 and 
 	 * I/O base should not be multiple of 0x10 */
 	if (((base & 0x8) && dma < 4) || (!(base & 0x8) && dma > 3)) {
-		printk (KERN_INFO "cosa_probe: 8/16 bit base and DMA mismatch"
-			" (base=0x%x, dma=%d)\n", base, dma);
+		pr_info("8/16 bit base and DMA mismatch (base=0x%x, dma=%d)\n",
+			base, dma);
 		return -1;
 	}
 
@@ -479,7 +479,7 @@ static int cosa_probe(int base, int irq, int dma)
 		return -1;
 	
 	if (cosa_reset_and_read_id(cosa, cosa->id_string) < 0) {
-		printk(KERN_DEBUG "cosa: probe at 0x%x failed.\n", base);
+		printk(KERN_DEBUG "probe at 0x%x failed.\n", base);
 		err = -1;
 		goto err_out;
 	}
@@ -492,8 +492,7 @@ static int cosa_probe(int base, int irq, int dma)
 	else {
 /* Print a warning only if we are not autoprobing */
 #ifndef COSA_ISA_AUTOPROBE
-		printk(KERN_INFO "cosa: valid signature not found at 0x%x.\n",
-			base);
+		pr_info("valid signature not found at 0x%x\n", base);
 #endif
 		err = -1;
 		goto err_out;
@@ -501,14 +500,14 @@ static int cosa_probe(int base, int irq, int dma)
 	/* Update the name of the region now we know the type of card */ 
 	release_region(base, is_8bit(cosa)?2:4);
 	if (!request_region(base, is_8bit(cosa)?2:4, cosa->type)) {
-		printk(KERN_DEBUG "cosa: changing name at 0x%x failed.\n", base);
+		printk(KERN_DEBUG "changing name at 0x%x failed.\n", base);
 		return -1;
 	}
 
 	/* Now do IRQ autoprobe */
 	if (irq < 0) {
 		unsigned long irqs;
-/*		printk(KERN_INFO "IRQ autoprobe\n"); */
+/*		pr_info("IRQ autoprobe\n"); */
 		irqs = probe_irq_on();
 		/* 
 		 * Enable interrupt on tx buffer empty (it sure is) 
@@ -526,13 +525,13 @@ static int cosa_probe(int base, int irq, int dma)
 		cosa_getdata8(cosa);
 
 		if (irq < 0) {
-			printk (KERN_INFO "cosa IRQ autoprobe: multiple interrupts obtained (%d, board at 0x%x)\n",
+			pr_info("multiple interrupts obtained (%d, board at 0x%x)\n",
 				irq, cosa->datareg);
 			err = -1;
 			goto err_out;
 		}
 		if (irq == 0) {
-			printk (KERN_INFO "cosa IRQ autoprobe: no interrupt obtained (board at 0x%x)\n",
+			pr_info("no interrupt obtained (board at 0x%x)\n",
 				cosa->datareg);
 		/*	return -1; */
 		}
@@ -579,8 +578,7 @@ static int cosa_probe(int base, int irq, int dma)
 
 		/* Register the network interface */
 		if (!(chan->netdev = alloc_hdlcdev(chan))) {
-			printk(KERN_WARNING "%s: alloc_hdlcdev failed.\n",
-			       chan->name);
+			pr_warn("%s: alloc_hdlcdev failed\n", chan->name);
 			goto err_hdlcdev;
 		}
 		dev_to_hdlc(chan->netdev)->attach = cosa_net_attach;
@@ -591,14 +589,14 @@ static int cosa_probe(int base, int irq, int dma)
 		chan->netdev->irq = chan->cosa->irq;
 		chan->netdev->dma = chan->cosa->dma;
 		if (register_hdlc_device(chan->netdev)) {
-			printk(KERN_WARNING "%s: register_hdlc_device()"
-			       " failed.\n", chan->netdev->name);
+			netdev_warn(chan->netdev,
+				    "register_hdlc_device() failed\n");
 			free_netdev(chan->netdev);
 			goto err_hdlcdev;
 		}
 	}
 
-	printk (KERN_INFO "cosa%d: %s (%s at 0x%x irq %d dma %d), %d channels\n",
+	pr_info("cosa%d: %s (%s at 0x%x irq %d dma %d), %d channels\n",
 		cosa->num, cosa->id_string, cosa->type,
 		cosa->datareg, cosa->irq, cosa->dma, cosa->nchannels);
 
@@ -618,8 +616,7 @@ err_out1:
 	free_irq(cosa->irq, cosa);
 err_out:
 	release_region(cosa->datareg,is_8bit(cosa)?2:4);
-	printk(KERN_NOTICE "cosa%d: allocating resources failed\n",
-	       cosa->num);
+	pr_notice("cosa%d: allocating resources failed\n", cosa->num);
 	return err;
 }
 
@@ -641,14 +638,14 @@ static int cosa_net_open(struct net_device *dev)
 	unsigned long flags;
 
 	if (!(chan->cosa->firmware_status & COSA_FW_START)) {
-		printk(KERN_NOTICE "%s: start the firmware first (status %d)\n",
-			chan->cosa->name, chan->cosa->firmware_status);
+		pr_notice("%s: start the firmware first (status %d)\n",
+			  chan->cosa->name, chan->cosa->firmware_status);
 		return -EPERM;
 	}
 	spin_lock_irqsave(&chan->cosa->lock, flags);
 	if (chan->usage != 0) {
-		printk(KERN_WARNING "%s: cosa_net_open called with usage count"
-		       " %d\n", chan->name, chan->usage);
+		pr_warn("%s: cosa_net_open called with usage count %d\n",
+			chan->name, chan->usage);
 		spin_unlock_irqrestore(&chan->cosa->lock, flags);
 		return -EBUSY;
 	}
@@ -736,8 +733,7 @@ static char *cosa_net_setup_rx(struct channel_data *chan, int size)
 	kfree_skb(chan->rx_skb);
 	chan->rx_skb = dev_alloc_skb(size);
 	if (chan->rx_skb == NULL) {
-		printk(KERN_NOTICE "%s: Memory squeeze, dropping packet\n",
-			chan->name);
+		pr_notice("%s: Memory squeeze, dropping packet\n", chan->name);
 		chan->netdev->stats.rx_dropped++;
 		return NULL;
 	}
@@ -748,8 +744,7 @@ static char *cosa_net_setup_rx(struct channel_data *chan, int size)
 static int cosa_net_rx_done(struct channel_data *chan)
 {
 	if (!chan->rx_skb) {
-		printk(KERN_WARNING "%s: rx_done with empty skb!\n",
-			chan->name);
+		pr_warn("%s: rx_done with empty skb!\n", chan->name);
 		chan->netdev->stats.rx_errors++;
 		chan->netdev->stats.rx_frame_errors++;
 		return 0;
@@ -768,8 +763,7 @@ static int cosa_net_rx_done(struct channel_data *chan)
 static int cosa_net_tx_done(struct channel_data *chan, int size)
 {
 	if (!chan->tx_skb) {
-		printk(KERN_WARNING "%s: tx_done with empty skb!\n",
-			chan->name);
+		pr_warn("%s: tx_done with empty skb!\n", chan->name);
 		chan->netdev->stats.tx_errors++;
 		chan->netdev->stats.tx_aborted_errors++;
 		return 1;
@@ -794,15 +788,15 @@ static ssize_t cosa_read(struct file *file,
 	char *kbuf;
 
 	if (!(cosa->firmware_status & COSA_FW_START)) {
-		printk(KERN_NOTICE "%s: start the firmware first (status %d)\n",
-			cosa->name, cosa->firmware_status);
+		pr_notice("%s: start the firmware first (status %d)\n",
+			  cosa->name, cosa->firmware_status);
 		return -EPERM;
 	}
 	if (mutex_lock_interruptible(&chan->rlock))
 		return -ERESTARTSYS;
 	
 	if ((chan->rxdata = kmalloc(COSA_MTU, GFP_DMA|GFP_KERNEL)) == NULL) {
-		printk(KERN_INFO "%s: cosa_read() - OOM\n", cosa->name);
+		pr_info("%s: cosa_read() - OOM\n", cosa->name);
 		mutex_unlock(&chan->rlock);
 		return -ENOMEM;
 	}
@@ -869,8 +863,8 @@ static ssize_t cosa_write(struct file *file,
 	char *kbuf;
 
 	if (!(cosa->firmware_status & COSA_FW_START)) {
-		printk(KERN_NOTICE "%s: start the firmware first (status %d)\n",
-			cosa->name, cosa->firmware_status);
+		pr_notice("%s: start the firmware first (status %d)\n",
+			  cosa->name, cosa->firmware_status);
 		return -EPERM;
 	}
 	if (down_interruptible(&chan->wsem))
@@ -881,8 +875,8 @@ static ssize_t cosa_write(struct file *file,
 	
 	/* Allocate the buffer */
 	if ((kbuf = kmalloc(count, GFP_KERNEL|GFP_DMA)) == NULL) {
-		printk(KERN_NOTICE "%s: cosa_write() OOM - dropping packet\n",
-			cosa->name);
+		pr_notice("%s: cosa_write() OOM - dropping packet\n",
+			  cosa->name);
 		up(&chan->wsem);
 		return -ENOMEM;
 	}
@@ -932,7 +926,7 @@ static int chrdev_tx_done(struct channel_data *chan, int size)
 
 static unsigned int cosa_poll(struct file *file, poll_table *poll)
 {
-	printk(KERN_INFO "cosa_poll is here\n");
+	pr_info("cosa_poll is here\n");
 	return 0;
 }
 
@@ -1017,15 +1011,14 @@ static inline int cosa_reset(struct cosa_data *cosa)
 {
 	char idstring[COSA_MAX_ID_STRING];
 	if (cosa->usage > 1)
-		printk(KERN_INFO "cosa%d: WARNING: reset requested with cosa->usage > 1 (%d). Odd things may happen.\n",
+		pr_info("cosa%d: WARNING: reset requested with cosa->usage > 1 (%d). Odd things may happen.\n",
 			cosa->num, cosa->usage);
 	cosa->firmware_status &= ~(COSA_FW_RESET|COSA_FW_START);
 	if (cosa_reset_and_read_id(cosa, idstring) < 0) {
-		printk(KERN_NOTICE "cosa%d: reset failed\n", cosa->num);
+		pr_notice("cosa%d: reset failed\n", cosa->num);
 		return -EIO;
 	}
-	printk(KERN_INFO "cosa%d: resetting device: %s\n", cosa->num,
-		idstring);
+	pr_info("cosa%d: resetting device: %s\n", cosa->num, idstring);
 	cosa->firmware_status |= COSA_FW_RESET;
 	return 0;
 }
@@ -1037,11 +1030,11 @@ static inline int cosa_download(struct cosa_data *cosa, void __user *arg)
 	int i;
 
 	if (cosa->usage > 1)
-		printk(KERN_INFO "%s: WARNING: download of microcode requested with cosa->usage > 1 (%d). Odd things may happen.\n",
+		pr_info("%s: WARNING: download of microcode requested with cosa->usage > 1 (%d). Odd things may happen.\n",
 			cosa->name, cosa->usage);
 	if (!(cosa->firmware_status & COSA_FW_RESET)) {
-		printk(KERN_NOTICE "%s: reset the card first (status %d).\n",
-			cosa->name, cosa->firmware_status);
+		pr_notice("%s: reset the card first (status %d)\n",
+			  cosa->name, cosa->firmware_status);
 		return -EPERM;
 	}
 	
@@ -1059,11 +1052,11 @@ static inline int cosa_download(struct cosa_data *cosa, void __user *arg)
 
 	i = download(cosa, d.code, d.len, d.addr);
 	if (i < 0) {
-		printk(KERN_NOTICE "cosa%d: microcode download failed: %d\n",
-			cosa->num, i);
+		pr_notice("cosa%d: microcode download failed: %d\n",
+			  cosa->num, i);
 		return -EIO;
 	}
-	printk(KERN_INFO "cosa%d: downloading microcode - 0x%04x bytes at 0x%04x\n",
+	pr_info("cosa%d: downloading microcode - 0x%04x bytes at 0x%04x\n",
 		cosa->num, d.len, d.addr);
 	cosa->firmware_status |= COSA_FW_RESET|COSA_FW_DOWNLOAD;
 	return 0;
@@ -1076,12 +1069,11 @@ static inline int cosa_readmem(struct cosa_data *cosa, void __user *arg)
 	int i;
 
 	if (cosa->usage > 1)
-		printk(KERN_INFO "cosa%d: WARNING: readmem requested with "
-			"cosa->usage > 1 (%d). Odd things may happen.\n",
+		pr_info("cosa%d: WARNING: readmem requested with cosa->usage > 1 (%d). Odd things may happen.\n",
 			cosa->num, cosa->usage);
 	if (!(cosa->firmware_status & COSA_FW_RESET)) {
-		printk(KERN_NOTICE "%s: reset the card first (status %d).\n",
-			cosa->name, cosa->firmware_status);
+		pr_notice("%s: reset the card first (status %d)\n",
+			  cosa->name, cosa->firmware_status);
 		return -EPERM;
 	}
 
@@ -1093,11 +1085,10 @@ static inline int cosa_readmem(struct cosa_data *cosa, void __user *arg)
 
 	i = readmem(cosa, d.code, d.len, d.addr);
 	if (i < 0) {
-		printk(KERN_NOTICE "cosa%d: reading memory failed: %d\n",
-			cosa->num, i);
+		pr_notice("cosa%d: reading memory failed: %d\n", cosa->num, i);
 		return -EIO;
 	}
-	printk(KERN_INFO "cosa%d: reading card memory - 0x%04x bytes at 0x%04x\n",
+	pr_info("cosa%d: reading card memory - 0x%04x bytes at 0x%04x\n",
 		cosa->num, d.len, d.addr);
 	cosa->firmware_status |= COSA_FW_RESET;
 	return 0;
@@ -1109,23 +1100,22 @@ static inline int cosa_start(struct cosa_data *cosa, int address)
 	int i;
 
 	if (cosa->usage > 1)
-		printk(KERN_INFO "cosa%d: WARNING: start microcode requested with cosa->usage > 1 (%d). Odd things may happen.\n",
+		pr_info("cosa%d: WARNING: start microcode requested with cosa->usage > 1 (%d). Odd things may happen.\n",
 			cosa->num, cosa->usage);
 
 	if ((cosa->firmware_status & (COSA_FW_RESET|COSA_FW_DOWNLOAD))
 		!= (COSA_FW_RESET|COSA_FW_DOWNLOAD)) {
-		printk(KERN_NOTICE "%s: download the microcode and/or reset the card first (status %d).\n",
-			cosa->name, cosa->firmware_status);
+		pr_notice("%s: download the microcode and/or reset the card first (status %d)\n",
+			  cosa->name, cosa->firmware_status);
 		return -EPERM;
 	}
 	cosa->firmware_status &= ~COSA_FW_RESET;
 	if ((i=startmicrocode(cosa, address)) < 0) {
-		printk(KERN_NOTICE "cosa%d: start microcode at 0x%04x failed: %d\n",
-			cosa->num, address, i);
+		pr_notice("cosa%d: start microcode at 0x%04x failed: %d\n",
+			  cosa->num, address, i);
 		return -EIO;
 	}
-	printk(KERN_INFO "cosa%d: starting microcode at 0x%04x\n",
-		cosa->num, address);
+	pr_info("cosa%d: starting microcode at 0x%04x\n", cosa->num, address);
 	cosa->startaddr = address;
 	cosa->firmware_status |= COSA_FW_START;
 	return 0;
@@ -1255,11 +1245,11 @@ static int cosa_start_tx(struct channel_data *chan, char *buf, int len)
 #ifdef DEBUG_DATA
 	int i;
 
-	printk(KERN_INFO "cosa%dc%d: starting tx(0x%x)", chan->cosa->num,
-		chan->num, len);
+	pr_info("cosa%dc%d: starting tx(0x%x)",
+		chan->cosa->num, chan->num, len);
 	for (i=0; i<len; i++)
-		printk(" %02x", buf[i]&0xff);
-	printk("\n");
+		pr_cont(" %02x", buf[i]&0xff);
+	pr_cont("\n");
 #endif
 	spin_lock_irqsave(&cosa->lock, flags);
 	chan->txbuf = buf;
@@ -1353,7 +1343,7 @@ static void cosa_kick(struct cosa_data *cosa)
 	if (test_bit(TXBIT, &cosa->rxtx))
 		s = "TX DMA";
 
-	printk(KERN_INFO "%s: %s timeout - restarting.\n", cosa->name, s); 
+	pr_info("%s: %s timeout - restarting\n", cosa->name, s);
 	spin_lock_irqsave(&cosa->lock, flags);
 	cosa->rxtx = 0;
 
@@ -1387,7 +1377,7 @@ static int cosa_dma_able(struct channel_data *chan, char *buf, int len)
 		return 0;
 	if ((b^ (b+len)) & 0x10000) {
 		if (count++ < 5)
-			printk(KERN_INFO "%s: packet spanning a 64k boundary\n",
+			pr_info("%s: packet spanning a 64k boundary\n",
 				chan->name);
 		return 0;
 	}
@@ -1498,8 +1488,7 @@ static int readmem(struct cosa_data *cosa, char __user *microcode, int length, i
 		char c;
 		int i;
 		if ((i=get_wait_data(cosa)) == -1) {
-			printk (KERN_INFO "cosa: 0x%04x bytes remaining\n",
-				length);
+			pr_info("0x%04x bytes remaining\n", length);
 			return -11;
 		}
 		c=i;
@@ -1582,14 +1571,15 @@ static int get_wait_data(struct cosa_data *cosa)
 			short r;
 			r = cosa_getdata8(cosa);
 #if 0
-			printk(KERN_INFO "cosa: get_wait_data returning after %d retries\n", 999-retries);
+			pr_info("get_wait_data returning after %d retries\n",
+				999-retries);
 #endif
 			return r;
 		}
 		/* sleep if not ready to read */
 		schedule_timeout_interruptible(1);
 	}
-	printk(KERN_INFO "cosa: timeout in get_wait_data (status 0x%x)\n",
+	pr_info("timeout in get_wait_data (status 0x%x)\n",
 		cosa_getstatus(cosa));
 	return -1;
 }
@@ -1607,7 +1597,7 @@ static int put_wait_data(struct cosa_data *cosa, int data)
 		if (cosa_getstatus(cosa) & SR_TX_RDY) {
 			cosa_putdata8(cosa, data);
 #if 0
-			printk(KERN_INFO "Putdata: %d retries\n", 999-retries);
+			pr_info("Putdata: %d retries\n", 999-retries);
 #endif
 			return 0;
 		}
@@ -1616,7 +1606,7 @@ static int put_wait_data(struct cosa_data *cosa, int data)
 		schedule_timeout_interruptible(1);
 #endif
 	}
-	printk(KERN_INFO "cosa%d: timeout in put_wait_data (status 0x%x)\n",
+	pr_info("cosa%d: timeout in put_wait_data (status 0x%x)\n",
 		cosa->num, cosa_getstatus(cosa));
 	return -1;
 }
@@ -1636,13 +1626,13 @@ static int puthexnumber(struct cosa_data *cosa, int number)
 	sprintf(temp, "%04X", number);
 	for (i=0; i<4; i++) {
 		if (put_wait_data(cosa, temp[i]) == -1) {
-			printk(KERN_NOTICE "cosa%d: puthexnumber failed to write byte %d\n",
-				cosa->num, i);
+			pr_notice("cosa%d: puthexnumber failed to write byte %d\n",
+				  cosa->num, i);
 			return -1-2*i;
 		}
 		if (get_wait_data(cosa) != temp[i]) {
-			printk(KERN_NOTICE "cosa%d: puthexhumber failed to read echo of byte %d\n",
-				cosa->num, i);
+			pr_notice("cosa%d: puthexhumber failed to read echo of byte %d\n",
+				  cosa->num, i);
 			return -2-2*i;
 		}
 	}
@@ -1687,8 +1677,7 @@ static inline void tx_interrupt(struct cosa_data *cosa, int status)
 {
 	unsigned long flags, flags1;
 #ifdef DEBUG_IRQS
-	printk(KERN_INFO "cosa%d: SR_DOWN_REQUEST status=0x%04x\n",
-		cosa->num, status);
+	pr_info("cosa%d: SR_DOWN_REQUEST status=0x%04x\n", cosa->num, status);
 #endif
 	spin_lock_irqsave(&cosa->lock, flags);
 	set_bit(TXBIT, &cosa->rxtx);
@@ -1696,8 +1685,7 @@ static inline void tx_interrupt(struct cosa_data *cosa, int status)
 		/* flow control, see the comment above */
 		int i=0;
 		if (!cosa->txbitmap) {
-			printk(KERN_WARNING "%s: No channel wants data "
-				"in TX IRQ. Expect DMA timeout.",
+			pr_warn("%s: No channel wants data in TX IRQ. Expect DMA timeout.\n",
 				cosa->name);
 			put_driver_status_nolock(cosa);
 			clear_bit(TXBIT, &cosa->rxtx);
@@ -1780,14 +1768,14 @@ static inline void tx_interrupt(struct cosa_data *cosa, int status)
 	if (cosa->busmaster) {
 		unsigned long addr = virt_to_bus(cosa->txbuf);
 		int count=0;
-		printk(KERN_INFO "busmaster IRQ\n");
+		pr_info("busmaster IRQ\n");
 		while (!(cosa_getstatus(cosa)&SR_TX_RDY)) {
 			count++;
 			udelay(10);
 			if (count > 1000) break;
 		}
-		printk(KERN_INFO "status %x\n", cosa_getstatus(cosa));
-		printk(KERN_INFO "ready after %d loops\n", count);
+		pr_info("status %x\n", cosa_getstatus(cosa));
+		pr_info("ready after %d loops\n", count);
 		cosa_putdata16(cosa, (addr >> 16)&0xffff);
 
 		count = 0;
@@ -1796,7 +1784,7 @@ static inline void tx_interrupt(struct cosa_data *cosa, int status)
 			if (count > 1000) break;
 			udelay(10);
 		}
-		printk(KERN_INFO "ready after %d loops\n", count);
+		pr_info("ready after %d loops\n", count);
 		cosa_putdata16(cosa, addr &0xffff);
 		flags1 = claim_dma_lock();
 		set_dma_mode(cosa->dma, DMA_MODE_CASCADE);
@@ -1824,7 +1812,7 @@ static inline void rx_interrupt(struct cosa_data *cosa, int status)
 {
 	unsigned long flags;
 #ifdef DEBUG_IRQS
-	printk(KERN_INFO "cosa%d: SR_UP_REQUEST\n", cosa->num);
+	pr_info("cosa%d: SR_UP_REQUEST\n", cosa->num);
 #endif
 
 	spin_lock_irqsave(&cosa->lock, flags);
@@ -1847,7 +1835,7 @@ static inline void rx_interrupt(struct cosa_data *cosa, int status)
 			debug_data_in(cosa, cosa->rxsize & 0xff);
 #endif
 #if 0
-			printk(KERN_INFO "cosa%d: receive rxsize = (0x%04x).\n",
+			pr_info("cosa%d: receive rxsize = (0x%04x)\n",
 				cosa->num, cosa->rxsize);
 #endif
 		}
@@ -1857,12 +1845,12 @@ static inline void rx_interrupt(struct cosa_data *cosa, int status)
 		debug_data_in(cosa, cosa->rxsize);
 #endif
 #if 0
-		printk(KERN_INFO "cosa%d: receive rxsize = (0x%04x).\n",
+		pr_info("cosa%d: receive rxsize = (0x%04x)\n",
 			cosa->num, cosa->rxsize);
 #endif
 	}
 	if (((cosa->rxsize & 0xe000) >> 13) >= cosa->nchannels) {
-		printk(KERN_WARNING "%s: rx for unknown channel (0x%04x)\n",
+		pr_warn("%s: rx for unknown channel (0x%04x)\n",
 			cosa->name, cosa->rxsize);
 		spin_unlock_irqrestore(&cosa->lock, flags);
 		goto reject;
@@ -1877,7 +1865,7 @@ static inline void rx_interrupt(struct cosa_data *cosa, int status)
 
 	if (!cosa->rxbuf) {
 reject:		/* Reject the packet */
-		printk(KERN_INFO "cosa%d: rejecting packet on channel %d\n",
+		pr_info("cosa%d: rejecting packet on channel %d\n",
 			cosa->num, cosa->rxchan->num);
 		cosa->rxbuf = cosa->bouncebuf;
 	}
@@ -1924,11 +1912,11 @@ static inline void eot_interrupt(struct cosa_data *cosa, int status)
 #ifdef DEBUG_DATA
 	{
 		int i;
-		printk(KERN_INFO "cosa%dc%d: done rx(0x%x)", cosa->num, 
-			cosa->rxchan->num, cosa->rxsize);
+		pr_info("cosa%dc%d: done rx(0x%x)",
+			cosa->num, cosa->rxchan->num, cosa->rxsize);
 		for (i=0; i<cosa->rxsize; i++)
-			printk (" %02x", cosa->rxbuf[i]&0xff);
-		printk("\n");
+			pr_cont(" %02x", cosa->rxbuf[i]&0xff);
+		pr_cont("\n");
 	}
 #endif
 		/* Packet for unknown channel? */
@@ -1940,8 +1928,7 @@ static inline void eot_interrupt(struct cosa_data *cosa, int status)
 			if (cosa->rxchan->rx_done(cosa->rxchan))
 				clear_bit(cosa->rxchan->num, &cosa->rxbitmap);
 	} else {
-		printk(KERN_NOTICE "cosa%d: unexpected EOT interrupt\n",
-			cosa->num);
+		pr_notice("cosa%d: unexpected EOT interrupt\n", cosa->num);
 	}
 	/*
 	 * Clear the RXBIT, TXBIT and IRQBIT (the latest should be
@@ -1963,8 +1950,7 @@ static irqreturn_t cosa_interrupt(int irq, void *cosa_)
 again:
 	status = cosa_getstatus(cosa);
 #ifdef DEBUG_IRQS
-	printk(KERN_INFO "cosa%d: got IRQ, status 0x%02x\n", cosa->num,
-		status & 0xff);
+	pr_info("cosa%d: got IRQ, status 0x%02x\n", cosa->num, status & 0xff);
 #endif
 #ifdef DEBUG_IO
 	debug_status_in(cosa, status);
@@ -1985,15 +1971,15 @@ again:
 			udelay(100);
 			goto again;
 		}
-		printk(KERN_INFO "cosa%d: unknown status 0x%02x in IRQ after %d retries\n",
+		pr_info("cosa%d: unknown status 0x%02x in IRQ after %d retries\n",
 			cosa->num, status & 0xff, count);
 	}
 #ifdef DEBUG_IRQS
 	if (count)
-		printk(KERN_INFO "%s: %d-times got unknown status in IRQ\n",
+		pr_info("%s: %d-times got unknown status in IRQ\n",
 			cosa->name, count);
 	else
-		printk(KERN_INFO "%s: returning from IRQ\n", cosa->name);
+		pr_info("%s: returning from IRQ\n", cosa->name);
 #endif
 	return IRQ_HANDLED;
 }
@@ -2024,41 +2010,41 @@ static void debug_status_in(struct cosa_data *cosa, int status)
 		s = "NO_REQ";
 		break;
 	}
-	printk(KERN_INFO "%s: IO: status -> 0x%02x (%s%s%s%s)\n",
+	pr_info("%s: IO: status -> 0x%02x (%s%s%s%s)\n",
 		cosa->name,
 		status,
-		status & SR_USR_RQ ? "USR_RQ|":"",
-		status & SR_TX_RDY ? "TX_RDY|":"",
-		status & SR_RX_RDY ? "RX_RDY|":"",
+		status & SR_USR_RQ ? "USR_RQ|" : "",
+		status & SR_TX_RDY ? "TX_RDY|" : "",
+		status & SR_RX_RDY ? "RX_RDY|" : "",
 		s);
 }
 
 static void debug_status_out(struct cosa_data *cosa, int status)
 {
-	printk(KERN_INFO "%s: IO: status <- 0x%02x (%s%s%s%s%s%s)\n",
+	pr_info("%s: IO: status <- 0x%02x (%s%s%s%s%s%s)\n",
 		cosa->name,
 		status,
-		status & SR_RX_DMA_ENA  ? "RXDMA|":"!rxdma|",
-		status & SR_TX_DMA_ENA  ? "TXDMA|":"!txdma|",
-		status & SR_RST         ? "RESET|":"",
-		status & SR_USR_INT_ENA ? "USRINT|":"!usrint|",
-		status & SR_TX_INT_ENA  ? "TXINT|":"!txint|",
-		status & SR_RX_INT_ENA  ? "RXINT":"!rxint");
+		status & SR_RX_DMA_ENA  ? "RXDMA|"  : "!rxdma|",
+		status & SR_TX_DMA_ENA  ? "TXDMA|"  : "!txdma|",
+		status & SR_RST         ? "RESET|"  : "",
+		status & SR_USR_INT_ENA ? "USRINT|" : "!usrint|",
+		status & SR_TX_INT_ENA  ? "TXINT|"  : "!txint|",
+		status & SR_RX_INT_ENA  ? "RXINT"   : "!rxint");
 }
 
 static void debug_data_in(struct cosa_data *cosa, int data)
 {
-	printk(KERN_INFO "%s: IO: data -> 0x%04x\n", cosa->name, data);
+	pr_info("%s: IO: data -> 0x%04x\n", cosa->name, data);
 }
 
 static void debug_data_out(struct cosa_data *cosa, int data)
 {
-	printk(KERN_INFO "%s: IO: data <- 0x%04x\n", cosa->name, data);
+	pr_info("%s: IO: data <- 0x%04x\n", cosa->name, data);
 }
 
 static void debug_data_cmd(struct cosa_data *cosa, int data)
 {
-	printk(KERN_INFO "%s: IO: data <- 0x%04x (%s|%s)\n",
+	pr_info("%s: IO: data <- 0x%04x (%s|%s)\n",
 		cosa->name, data,
 		data & SR_RDY_RCV ? "RX_RDY" : "!rx_rdy",
 		data & SR_RDY_SND ? "TX_RDY" : "!tx_rdy");
-- 
1.7.6.rc1
