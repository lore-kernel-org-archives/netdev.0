From: Richard Gooch <rgooch@ras.ucalgary.ca>
Subject: Update on problems with sundance driver
Date: Sat, 12 Oct 2002 10:43:12 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210121643.g9CGhCS12921@vindaloo.ras.ucalgary.ca>
References: <200210052348.g95NmXK31793@vindaloo.ras.ucalgary.ca>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, Donald Becker <becker@scyld.com>,
   Jason Lunz <lunz@falooley.org>, "Patrick R. McManus" <mcmanus@ducksong.com>,
   edward_peng@dlink.com.tw
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  Hi, all. I think I've found found a clue as to why my 4-port D-Link
DFE-580TX hasn't being behaving well. To recap: using 2.4.19 plus one
of Jason's patches (v1.01d), the machine locks up every few days or
so. It doesn't respond to pings, nor console activity. Even SysRq is
unresponsive.

With 2.4.20-pre9 and the appended patch from D-Link (with corrections
by me to make the patch apply and compile), I was getting transmitter
timeouts every minute or so. This was causing traffic through the
firewall to stall each time.

I've now forced eth1 to 100 Mb/s FD, and the machine has run overnight
with no transmitter timeouts. Before, eth1 was auto negotiated to 100
Mb/s HD (the other end doesn't do auto negotiation properly, but is
locked down to 100 Mb/s FD).

So it seems that running an interface at HD while the other end is set
to FD causes transmitter timeouts. Why is this?

There is a problem with the D-Link patch, though: throughput has been
drastically reduced. With the D-Link patch, I'm getting 6.8 MB/s over
TCP through this box, compared to 11.4 MB/s with Jason's 1.01d driver.
Can anyone see something obvious in the patch that would cause this
slowdown?

				Regards,

					Richard....
Permanent: rgooch@atnf.csiro.au
Current:   rgooch@ras.ucalgary.ca
===============================================================================
--- sundance.c.orig	2002-10-08 17:10:02.000000000 +0800
+++ sundance.c	2002-10-08 17:48:07.000000000 +0800
@@ -63,14 +63,14 @@
 	- Better rx buf size calculation (Donald Becker)

 	Version LK1.05 (D-Link):
-	- fix DFE-580TX packet drop issue
+	- fix DFE-580TX packet drop issue (for DL10050C)
 	- fix reset_tx logic

 */

 #define DRV_NAME	"sundance"
-#define DRV_VERSION	"1.01+LK1.05"
-#define DRV_RELDATE	"28-Sep-2002"
+#define DRV_VERSION	"1.01+LK1.05b"
+#define DRV_RELDATE	"8-Oct-2002"


 /* The user-configurable values.
@@ -114,7 +114,7 @@
    bonding and packet priority, and more than 128 requires modifying the
    Tx error recovery.
    Large receive rings merely waste memory. */
-#define TX_RING_SIZE	64
+#define TX_RING_SIZE	32
 #define TX_QUEUE_LEN	(TX_RING_SIZE - 1) /* Limit ring entries actually used.  */
 #define RX_RING_SIZE	64
 #define RX_BUDGET	32
@@ -468,6 +468,7 @@
 	int mii_preamble_required;
 	unsigned char phys[MII_CNT];		/* MII device addresses, only first one used.*/
 	struct pci_dev *pci_dev;
+	unsigned char pci_rev_id;
 };

 /* The station address location in the EEPROM. */
@@ -588,6 +589,8 @@
 	dev->change_mtu = &change_mtu;
 	pci_set_drvdata(pdev, dev);

+	pci_read_config_byte(pdev, PCI_REVISION_ID, &np->pci_rev_id);
+
 	i = register_netdev(dev);
 	if (i)
 		goto err_out_unmap_rx;
@@ -867,7 +870,8 @@
 	writeb(100, ioaddr + RxDMAPollPeriod);
 	writeb(127, ioaddr + TxDMAPollPeriod);
 	/* Fix DFE-580TX packet drop issue */
-	writeb(0x01, ioaddr + DebugCtrl1);
+	if (np->pci_rev_id >= 0x14)
+		writeb(0x01, ioaddr + DebugCtrl1);
 	netif_start_queue(dev);

 	writew(StatsEnable | RxEnable | TxEnable, ioaddr + MACCtrl1);
@@ -944,6 +948,7 @@
 	long ioaddr = dev->base_addr;
 	long flag;

+	netif_stop_queue(dev);
 	writew(0, ioaddr + IntrEnable);
 	printk(KERN_WARNING "%s: Transmit timed out, TxStatus %2.2x "
 		   "TxFrameId %2.2x,"
@@ -952,31 +957,36 @@

 	{
 		int i;
-		printk(KERN_DEBUG "  Rx ring %p: ", np->rx_ring);
-		for (i = 0; i < RX_RING_SIZE; i++)
-			printk(" %8.8x", (unsigned int)np->rx_ring[i].status);
-		printk("\n"KERN_DEBUG"  Tx ring %p: ", np->tx_ring);
-		for (i = 0; i < TX_RING_SIZE; i++)
-			printk(" %8.8x", np->tx_ring[i].status);
-		printk("\n");
-		printk(KERN_DEBUG "cur_tx=%d dirty_tx=%d\n", np->cur_tx, np->dirty_tx);
+		for (i=0; i<TX_RING_SIZE; i++) {
+			printk(KERN_DEBUG "%02x %08x %08x %08x(%02x) %08x %08x\n", i,
+				np->tx_ring_dma + i*sizeof(*np->tx_ring),
+				np->tx_ring[i].next_desc,
+				np->tx_ring[i].status,
+				(np->tx_ring[i].status >> 2) & 0xff,
+				np->tx_ring[i].frag[0].addr,
+				np->tx_ring[i].frag[0].length);
+		}
+		printk(KERN_DEBUG "TxListPtr=%08x netif_queue_stopped=%d\n",
+			readl(dev->base_addr + TxListPtr),
+			netif_queue_stopped(dev));
+		printk(KERN_DEBUG "cur_tx=%d(%02x) dirty_tx=%d(%02x)\n",
+			np->cur_tx, np->cur_tx % TX_RING_SIZE,
+			np->dirty_tx, np->dirty_tx % TX_RING_SIZE);
 		printk(KERN_DEBUG "cur_rx=%d dirty_rx=%d\n", np->cur_rx, np->dirty_rx);
 	}
 	spin_lock_irqsave(&np->lock, flag);
+	/* Stop and restart the chip's Tx processes . */
 	reset_tx(dev);
 	spin_unlock_irqrestore(&np->lock, flag);

-	/* Perhaps we should reinitialize the hardware here. */
 	dev->if_port = 0;
-	/* Stop and restart the chip's Tx processes . */
-
-	/* Trigger an immediate transmit demand. */
-	writew(DEFAULT_INTR, ioaddr + IntrEnable);

 	dev->trans_start = jiffies;
 	np->stats.tx_errors++;
-	if (!netif_queue_stopped(dev))
+	if (np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 4) {
 		netif_wake_queue(dev);
+	}
+	writew(DEFAULT_INTR, ioaddr + IntrEnable);
 }


@@ -1090,7 +1100,8 @@
 	int irq = in_interrupt();

 	/* reset tx logic */
-	writel (0, dev->base_addr + TxListPtr);
+	writew (TxDisable, ioaddr + MACCtrl1);
+	mdelay(10);
 	writew (TxReset | DMAReset | FIFOReset | NetworkReset,
 			ioaddr + ASICCtrl + 2);
 	for (i=50; i > 0; i--) {
@@ -1114,6 +1125,8 @@
 		}
 	}
 	np->cur_tx = np->dirty_tx = 0;
+	mdelay(10);
+	writew (StatsEnable | RxEnable | TxEnable, ioaddr + MACCtrl1);
 	return 0;
 }

@@ -1126,6 +1139,8 @@
 	long ioaddr;
 	int boguscnt = max_interrupt_work;
 	int hw_frame_id;
+	int tx_cnt;
+	int tx_status;

 	ioaddr = dev->base_addr;
 	np = dev->priv;
@@ -1148,15 +1163,13 @@
 				np->budget = RX_BUDGET;
 			tasklet_schedule(&np->rx_tasklet);
 		}
-
 		if (intr_status & (IntrTxDone | IntrDrvRqst)) {
-			int boguscnt = 32;
-			int tx_status = readw (ioaddr + TxStatus);
-			while (tx_status & 0x80) {
+			tx_status = readw (ioaddr + TxStatus);
+			for (tx_cnt=32; tx_status & 0x80; --tx_cnt) {
 				if (netif_msg_tx_done(np))
 					printk
 					    ("%s: Transmit status is %2.2x.\n",
-					     dev->name, tx_status);
+				     	dev->name, tx_status);
 				if (tx_status & 0x1e) {
 					np->stats.tx_errors++;
 					if (tx_status & 0x10)
@@ -1179,20 +1192,30 @@
 				/* Yup, this is a documentation bug.  It cost me *hours*. */
 				writew (0, ioaddr + TxStatus);
 				tx_status = readw (ioaddr + TxStatus);
-				if (--boguscnt < 0)
+				if (tx_cnt < 0)
 					break;
 			}
+			hw_frame_id = (tx_status >> 8) & 0xff;
+		} else 	{
+			hw_frame_id = readb(ioaddr + TxFrameId);
 		}
+
 		spin_lock(&np->lock);
-		hw_frame_id = readb(ioaddr + TxFrameId);
 		for (; np->cur_tx - np->dirty_tx > 0; np->dirty_tx++) {
 			int entry = np->dirty_tx % TX_RING_SIZE;
 			struct sk_buff *skb;
 			int sw_frame_id;
 			sw_frame_id = (np->tx_ring[entry].status >> 2) & 0xff;
-			
-			if (sw_frame_id == hw_frame_id)
-				break;
+			if (np->pci_rev_id >= 0x14)
+				if (sw_frame_id == hw_frame_id &&
+					!(np->tx_ring[entry].status & 0x00010000))
+					break;
+				if (sw_frame_id == (hw_frame_id + 1) % TX_RING_SIZE)
+					break;
+			} else {
+				if (!(np->tx_ring[entry].status & 0x00010000))
+					break;
+			}
 			skb = np->tx_skbuff[entry];
 			/* Free the original skb. */
 			pci_unmap_single(np->pci_dev,
@@ -1200,14 +1223,16 @@
 				skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb_irq (np->tx_skbuff[entry]);
 			np->tx_skbuff[entry] = 0;
+			np->tx_ring[entry].frag[0].addr = 0;
+			np->tx_ring[entry].frag[0].length = 0;
 		}
 		spin_unlock(&np->lock);
+
 		if (netif_queue_stopped(dev) &&
 			np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 4) {
 			/* The ring is no longer full, clear tbusy. */
 			netif_wake_queue (dev);
 		}
-
 		/* Abnormal error summary/uncommon events handlers. */
 		if (intr_status & (IntrPCIErr | LinkChange | StatsMax))
 			netdev_error(dev, intr_status);
@@ -1223,7 +1248,7 @@
 	if (netif_msg_intr(np))
 		printk(KERN_DEBUG "%s: exiting interrupt, status=%#4.4x.\n",
 			   dev->name, readw(ioaddr + IntrStatus));
-	if (np->cur_tx - np->dirty_tx > 0 && tx_coalesce > 1)
+	if (np->cur_tx - np->dirty_tx > 0)
 		writel(100, ioaddr + DownCounter);

 }
