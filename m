From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 5/5] 2.6.6-bk8 pcnet32 remove timer and complexity.
Date: Fri, 21 May 2004 13:34:31 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405212034.i4LKYV510215@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This removes the timer I recently added, and the 'ltint' interrupt
mitigation from the 79C971 and 79C972. It did not improve performance,
added complexity, and was a bad idea in hind sight.

--- linux-2.6.6-bk5/drivers/net/static.pcnet32.c	Tue May 18 10:35:20 2004
+++ linux-2.6.6-bk5/drivers/net/pcnet32.c	Tue May 18 10:34:33 2004
@@ -22,8 +22,8 @@
  *************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#define DRV_VERSION	"1.29"
-#define DRV_RELDATE	"04.06.2004"
+#define DRV_VERSION	"1.30"
+#define DRV_RELDATE	"05.18.2004"
 #define PFX		DRV_NAME ": "
 
 static const char *version =
@@ -239,6 +239,8 @@
  *	   identification code (blink led's) and register dump.
  *	   Don Fry added timer for 971/972 so skbufs don't remain on tx ring
  *	   forever.
+ * v1.30   18 May 2004 Don Fry removed timer and Last Transmit Interrupt
+ *	   (ltint) as they added complexity and didn't give good throughput.
  */
 
 
@@ -343,7 +345,6 @@
     char		tx_full;
     int			options;
     int	shared_irq:1,			/* shared irq possible */
-	ltint:1,			/* enable TxDone-intr inhibitor */
 	dxsuflo:1,			/* disable transmit stop on uflo */
 	mii:1;				/* mii port available */
     struct net_device	*next;
@@ -999,7 +1000,7 @@
     struct pcnet32_private *lp;
     dma_addr_t lp_dma_addr;
     int i, media;
-    int fdx, mii, fset, dxsuflo, ltint;
+    int fdx, mii, fset, dxsuflo;
     int chip_version;
     char *chipname;
     struct net_device *dev;
@@ -1031,7 +1032,7 @@
     }
 
     /* initialize variables */
-    fdx = mii = fset = dxsuflo = ltint = 0;
+    fdx = mii = fset = dxsuflo = 0;
     chip_version = (chip_version >> 12) & 0xffff;
 
     switch (chip_version) {
@@ -1051,7 +1052,6 @@
     case 0x2623:
 	chipname = "PCnet/FAST 79C971"; /* PCI */
 	fdx = 1; mii = 1; fset = 1;
-	ltint = 1;
 	break;
     case 0x2624:
 	chipname = "PCnet/FAST+ 79C972"; /* PCI */
@@ -1104,14 +1104,6 @@
 	a->write_bcr(ioaddr, 18, (a->read_bcr(ioaddr, 18) | 0x0860));
 	a->write_csr(ioaddr, 80, (a->read_csr(ioaddr, 80) & 0x0C00) | 0x0c00);
 	dxsuflo = 1;
-	ltint = 1;
-    }
-
-    if (ltint) {
-	/* Enable timer to prevent skbuffs from remaining on the tx ring
-	 * forever if no other tx being done.  Set timer period to about
-	 * 122 ms */
-	a->write_bcr(ioaddr, 31, 0x253b);
     }
 
     dev = alloc_etherdev(0);
@@ -1218,7 +1210,6 @@
     lp->mii_if.phy_id_mask = 0x1f;
     lp->mii_if.reg_num_mask = 0x1f;
     lp->dxsuflo = dxsuflo;
-    lp->ltint = ltint;
     lp->mii = mii;
     lp->msg_enable = pcnet32_debug;
     if ((cards_found >= MAX_UNITS) || (options[cards_found] > sizeof(options_mapping)))
@@ -1437,12 +1428,6 @@
     }
 #endif
 
-    if (lp->ltint) { /* Enable TxDone-intr inhibitor */
-	val = lp->a.read_csr (ioaddr, 5);
-	val |= (1<<14);
-	lp->a.write_csr (ioaddr, 5, val);
-    }
-
     lp->init_block.mode = le16_to_cpu((lp->options & PCNET32_PORT_PORTSEL) << 7);
     pcnet32_load_multicast(dev);
 
@@ -1460,11 +1445,6 @@
     lp->a.write_csr (ioaddr, 4, 0x0915);
     lp->a.write_csr (ioaddr, 0, 0x0001);
 
-    if (lp->ltint) {
-	/* start the software timer */
-	lp->a.write_csr(ioaddr, 7, 0x0400);	/* set STINTE */
-    }
-
     netif_start_queue(dev);
 
     /* If we have mii, print the link status and start the watchdog */
@@ -1677,19 +1657,6 @@
      * interrupt when that option is available to us.
      */
     status = 0x8300;
-    entry = (lp->cur_tx - lp->dirty_tx) & TX_RING_MOD_MASK;
-    if ((lp->ltint) &&
-	((entry == TX_RING_SIZE/3) ||
-	 (entry == (TX_RING_SIZE*2)/3) ||
-	 (entry >= TX_RING_SIZE-2)))
-    {
-	/* Enable Successful-TxDone interrupt if we have
-	 * 1/3, 2/3 or nearly all of, our ring buffer Tx'd
-	 * but not yet cleaned up.  Thus, most of the time,
-	 * we will not enable Successful-TxDone interrupts.
-	 */
-	status = 0x9300;
-    }
 
     /* Fill in a Tx ring entry */
 
@@ -1733,7 +1700,7 @@
     struct net_device *dev = dev_id;
     struct pcnet32_private *lp;
     unsigned long ioaddr;
-    u16 csr0, csr7, rap;
+    u16 csr0,rap;
     int boguscnt =  max_interrupt_work;
     int must_restart;
 
@@ -1750,19 +1717,13 @@
     spin_lock(&lp->lock);
 
     rap = lp->a.read_rap(ioaddr);
-    csr0 = lp->a.read_csr (ioaddr, 0);
-    csr7 = lp->ltint ? lp->a.read_csr(ioaddr, 7) : 0;
-
-    while ((csr0 & 0x8600 || csr7 & 0x0800) && --boguscnt >= 0) {
+    while ((csr0 = lp->a.read_csr (ioaddr, 0)) & 0x8600 && --boguscnt >= 0) {
 	if (csr0 == 0xffff) {
 	    break;			/* PCMCIA remove happened */
 	}
 	/* Acknowledge all of the current interrupt sources ASAP. */
 	lp->a.write_csr (ioaddr, 0, csr0 & ~0x004f);
 
-	if (csr7 & 0x0800)
-	    lp->a.write_csr(ioaddr, 7, csr7);
-
 	must_restart = 0;
 
 	if (netif_msg_intr(lp))
@@ -1772,7 +1733,7 @@
 	if (csr0 & 0x0400)		/* Rx interrupt */
 	    pcnet32_rx(dev);
 
-	if (csr0 & 0x0200 || csr7 & 0x0800) {	/* Tx-done or Timer interrupt */
+	if (csr0 & 0x0200) {		/* Tx-done interrupt */
 	    unsigned int dirty_tx = lp->dirty_tx;
 	    int delta;
 
@@ -1879,9 +1840,6 @@
 	    lp->a.write_csr (ioaddr, 0, 0x0004);
 	    pcnet32_restart(dev, 0x0002);
 	}
-
-	csr0 = lp->a.read_csr (ioaddr, 0);
-	csr7 = lp->ltint ? lp->a.read_csr(ioaddr, 7) : 0;
     }
 
     /* Clear any other interrupt, and set interrupt enable. */
@@ -2032,10 +1990,6 @@
     /* We stop the PCNET32 here -- it occasionally polls memory if we don't. */
     lp->a.write_csr (ioaddr, 0, 0x0004);
 
-    if (lp->ltint) {	/* Disable timer interrupts */
-	lp->a.write_csr(ioaddr, 7, 0x0000);
-    }
-
     /*
      * Switch back to 16bit mode to avoid problems with dumb
      * DOS packet driver after a warm reboot

-- 
Don Fry
brazilnut@us.ibm.com
