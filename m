From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH] 2.4.25 pcnet32.c convert to use netif_msg_*
Date: Thu, 19 Feb 2004 14:43:41 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402192243.i1JMhfx05557@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch converts the driver to use netif_msg_* for printing messages.
Tested IA32.

--- linux-2.4.25/drivers/net/fail.pcnet32.c	Thu Feb 19 13:48:02 2004
+++ linux-2.4.25/drivers/net/pcnet32.c	Thu Feb 19 14:26:27 2004
@@ -82,7 +82,7 @@
 
 
 
-static int pcnet32_debug = 1;
+static int pcnet32_debug = 0;
 static int tx_start = 1; /* Mapping -- 0:20, 1:64, 2:128, 3:~220 (depends on chip vers) */
 static int pcnet32vlb;	 /* check for VLB cards ? */
 
@@ -325,6 +325,7 @@
 	mii:1;				/* mii port available */
     struct net_device	*next;
     struct mii_if_info mii_if;
+    u32			msg_enable;	/* debug message level */
 };
 
 static void pcnet32_probe_vlbus(void);
@@ -541,7 +542,7 @@
     }
 
     chip_version = a->read_csr(ioaddr, 88) | (a->read_csr(ioaddr,89) << 16);
-    if (pcnet32_debug > 2)
+    if (pcnet32_debug & NETIF_MSG_PROBE)
 	printk(KERN_INFO "  PCnet chip version is %#x.\n", chip_version);
     if ((chip_version & 0xfff) != 0x003)
 	return -ENODEV;
@@ -595,7 +596,7 @@
 	media &= ~3;
 	media |= 1;
 #endif
-	if (pcnet32_debug > 2)
+	if (pcnet32_debug & NETIF_MSG_PROBE)
 	    printk(KERN_DEBUG PFX "media reset to %#x.\n",  media);
 	a->write_bcr(ioaddr, 49, media);
 	break;
@@ -718,6 +719,7 @@
     lp->dxsuflo = dxsuflo;
     lp->ltint = ltint;
     lp->mii = mii;
+    lp->msg_enable = pcnet32_debug;
     if ((cards_found >= MAX_UNITS) || (options[cards_found] > sizeof(options_mapping)))
 	lp->options = PCNET32_PORT_ASEL;
     else
@@ -835,7 +837,7 @@
     /* switch pcnet32 to 32bit mode */
     lp->a.write_bcr (ioaddr, 20, 2);
 
-    if (pcnet32_debug > 1)
+    if (netif_msg_ifup(lp))
 	printk(KERN_DEBUG "%s: pcnet32_open() irq %d tx/rx rings %#x/%#x init %#x.\n",
 	       dev->name, dev->irq,
 	       (u32) (lp->dma_addr + offsetof(struct pcnet32_private, tx_ring)),
@@ -923,7 +925,7 @@
      */
     lp->a.write_csr (ioaddr, 0, 0x0042);
 
-    if (pcnet32_debug > 2)
+    if (netif_msg_ifup(lp))
 	printk(KERN_DEBUG "%s: pcnet32 open after %d ticks, init block %#x csr0 %4.4x.\n",
 	       dev->name, i, (u32) (lp->dma_addr + offsetof(struct pcnet32_private, init_block)),
 	       lp->a.read_csr(ioaddr, 0));
@@ -1043,7 +1045,7 @@
 	       dev->name, lp->a.read_csr(ioaddr, 0));
 	lp->a.write_csr (ioaddr, 0, 0x0004);
 	lp->stats.tx_errors++;
-	if (pcnet32_debug > 2) {
+	if (netif_msg_tx_err(lp)) {
 	    int i;
 	    printk(KERN_DEBUG " Ring data dump: dirty_tx %d cur_tx %d%s cur_rx %d.",
 	       lp->dirty_tx, lp->cur_tx, lp->tx_full ? " (full)" : "",
@@ -1076,7 +1078,7 @@
     int entry;
     unsigned long flags;
 
-    if (pcnet32_debug > 3) {
+    if (netif_msg_tx_queued(lp)) {
 	printk(KERN_DEBUG "%s: pcnet32_start_xmit() called, csr0 %4.4x.\n",
 	       dev->name, lp->a.read_csr(ioaddr, 0));
     }
@@ -1165,7 +1167,7 @@
 
 	must_restart = 0;
 
-	if (pcnet32_debug > 5)
+	if (netif_msg_intr(lp))
 	    printk(KERN_DEBUG "%s: interrupt  csr0=%#2.2x new csr=%#2.2x.\n",
 		   dev->name, csr0, lp->a.read_csr (ioaddr, 0));
 
@@ -1280,7 +1282,7 @@
     lp->a.write_csr (ioaddr, 0, 0x7940);
     lp->a.write_rap (ioaddr,rap);
     
-    if (pcnet32_debug > 4)
+    if (netif_msg_intr(lp))
 	printk(KERN_DEBUG "%s: exiting interrupt, csr0=%#4.4x.\n",
 	       dev->name, lp->a.read_csr (ioaddr, 0));
 
@@ -1400,7 +1402,7 @@
 
     lp->stats.rx_missed_errors = lp->a.read_csr (ioaddr, 112);
 
-    if (pcnet32_debug > 1)
+    if (netif_msg_ifdown(lp))
 	printk(KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
 	       dev->name, lp->a.read_csr (ioaddr, 0));
 
@@ -1629,7 +1631,7 @@
 	/* get message-level */
 	case ETHTOOL_GMSGLVL: {
 		struct ethtool_value edata = {ETHTOOL_GMSGLVL};
-		edata.data = pcnet32_debug;
+		edata.data = lp->msg_enable;
 		if (copy_to_user(useraddr, &edata, sizeof(edata)))
 			return -EFAULT;
 		return 0;
@@ -1639,7 +1641,7 @@
 		struct ethtool_value edata;
 		if (copy_from_user(&edata, useraddr, sizeof(edata)))
 			return -EFAULT;
-		pcnet32_debug = edata.data;
+		lp->msg_enable = edata.data;
 		return 0;
 	}
 	default:

-- 
Don Fry
brazilnut@us.ibm.com
