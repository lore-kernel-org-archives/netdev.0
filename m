From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.3] pcnet32.c handle failures in open
Date: Fri, 20 Feb 2004 14:13:57 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402202213.i1KMDwW07327@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If there are errors in the open routine, the driver does not correctly clean
up and free resources. 

This also removes an unnecessary netif_wake_queue, correctly supports the
debug parameter, and updates the version and date.

--- linux-2.6.3/drivers/net/tool.pcnet32.c	Thu Feb 19 16:17:30 2004
+++ linux-2.6.3/drivers/net/pcnet32.c	Fri Feb 20 10:27:45 2004
@@ -22,8 +22,8 @@
  *************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#define DRV_VERSION	"1.27b"
-#define DRV_RELDATE	"01.10.2002"
+#define DRV_VERSION	"1.28"
+#define DRV_RELDATE	"02.20.2004"
 #define PFX		DRV_NAME ": "
 
 static const char *version =
@@ -219,6 +219,11 @@
  *	   clean up and using new mii module
  * v1.27b  Sep 30 2002 Kent Yoder <yoder1@us.ibm.com>
  * 	   Added timer for cable connection state changes.
+ * v1.28   20 Feb 2004 Don Fry <brazilnut@us.ibm.com>
+ *	   Jon Lewis <jonmason@us.ibm.com>, Chinmay Albal <albal@in.ibm.com>
+ *	   Now uses ethtool_ops, netif_msg_* and generic_mii_ioctl.
+ *	   Fixes bogus 'Bus master arbitration failure', pci_[un]map_single
+ *	   length errors, and transmit hangs.  Cleans up after errors in open.
  */
 
 
@@ -650,8 +655,10 @@
     chip_version = a->read_csr(ioaddr, 88) | (a->read_csr(ioaddr,89) << 16);
     if (pcnet32_debug & NETIF_MSG_PROBE)
 	printk(KERN_INFO "  PCnet chip version is %#x.\n", chip_version);
-    if ((chip_version & 0xfff) != 0x003)
+    if ((chip_version & 0xfff) != 0x003) {
+	    printk(KERN_INFO PFX "Unsupported chip version.\n");
 	    goto err_release_region;
+    }
     
     /* initialize variables */
     fdx = mii = fset = dxsuflo = ltint = 0;
@@ -733,6 +740,7 @@
     
     dev = alloc_etherdev(0);
     if(!dev) {
+	    printk(KERN_ERR PFX "Memory allocation failed.\n");
 	    ret = -ENOMEM;
 	    goto err_release_region;
     }
@@ -806,6 +814,7 @@
     dev->base_addr = ioaddr;
     /* pci_alloc_consistent returns page-aligned memory, so we do not have to check the alignment */
     if ((lp = pci_alloc_consistent(pdev, sizeof(*lp), &lp_dma_addr)) == NULL) {
+	printk(KERN_ERR PFX "Consistent memory allocation failed.\n");
 	ret = -ENOMEM;
 	goto err_free_netdev;
     }
@@ -939,6 +948,7 @@
     unsigned long ioaddr = dev->base_addr;
     u16 val;
     int i;
+    int rc;
 
     if (dev->irq == 0 ||
 	request_irq(dev->irq, &pcnet32_interrupt,
@@ -947,8 +957,10 @@
     }
 
     /* Check for a valid station address */
-    if( !is_valid_ether_addr(dev->dev_addr) )
-	return -EINVAL;
+    if (!is_valid_ether_addr(dev->dev_addr)) {
+	rc = -EINVAL;
+	goto err_free_irq;
+    }
 
     /* Reset the PCNET32 */
     lp->a.reset (ioaddr);
@@ -1022,8 +1034,10 @@
     lp->init_block.mode = le16_to_cpu((lp->options & PCNET32_PORT_PORTSEL) << 7);
     lp->init_block.filter[0] = 0x00000000;
     lp->init_block.filter[1] = 0x00000000;
-    if (pcnet32_init_ring(dev))
-	return -ENOMEM;
+    if (pcnet32_init_ring(dev)) {
+	rc = -ENOMEM;
+	goto err_free_ring;
+    }
     
     /* Re-initialize the PCNET32, and start it when done. */
     lp->a.write_csr (ioaddr, 1, (lp->dma_addr + offsetof(struct pcnet32_private, init_block)) &0xffff);
@@ -1057,6 +1071,28 @@
 
 
     return 0;	/* Always succeed */
+
+err_free_ring:
+    /* free any allocated skbuffs */
+    for (i = 0; i < RX_RING_SIZE; i++) {
+	lp->rx_ring[i].status = 0;			    
+	if (lp->rx_skbuff[i]) {
+            pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i], PKT_BUF_SZ-2,
+		    PCI_DMA_FROMDEVICE);
+	    dev_kfree_skb(lp->rx_skbuff[i]);
+        }
+	lp->rx_skbuff[i] = NULL;
+        lp->rx_dma_addr[i] = 0;
+    }
+    /*
+     * Switch back to 16bit mode to avoid problems with dumb 
+     * DOS packet driver after a warm reboot
+     */
+    lp->a.write_bcr (ioaddr, 20, 4);
+
+err_free_irq:
+    free_irq(dev->irq, dev);
+    return rc;
 }
 
 /*
@@ -1125,6 +1161,7 @@
 	lp->tx_ring[i].status = 0;
         lp->tx_dma_addr[i] = 0;
     }
+    wmb(); /* Make sure all changes are visible */
 
     lp->init_block.tlen_rlen = le16_to_cpu(TX_RING_LEN_BITS | RX_RING_LEN_BITS);
     for (i = 0; i < 6; i++)
@@ -1251,9 +1288,7 @@
 
     dev->trans_start = jiffies;
 
-    if (lp->tx_ring[(entry+1) & TX_RING_MOD_MASK].base == 0)
-	netif_wake_queue(dev);
-    else {
+    if (lp->tx_ring[(entry+1) & TX_RING_MOD_MASK].base != 0) {
 	lp->tx_full = 1;
 	netif_stop_queue(dev);
     }
@@ -1509,6 +1544,7 @@
 	 * of QNX reports that some revs of the 79C965 clear it.
 	 */
 	lp->rx_ring[entry].buf_length = le16_to_cpu(2-PKT_BUF_SZ);
+	wmb(); /* Make sure owner changes after all others are visible */
 	lp->rx_ring[entry].status |= le16_to_cpu(0x8000);
 	entry = (++lp->cur_rx) & RX_RING_MOD_MASK;
     }
@@ -1725,7 +1761,7 @@
 };
 
 MODULE_PARM(debug, "i");
-MODULE_PARM_DESC(debug, DRV_NAME " debug level (0-6)");
+MODULE_PARM_DESC(debug, DRV_NAME " debug level");
 MODULE_PARM(max_interrupt_work, "i");
 MODULE_PARM_DESC(max_interrupt_work, DRV_NAME " maximum events handled per interrupt");  
 MODULE_PARM(rx_copybreak, "i");
@@ -1752,8 +1788,8 @@
 {
     printk(KERN_INFO "%s", version);
 
-    if (debug > 0)
-	pcnet32_debug = debug;
+    if (debug >= 0 && debug < (sizeof(int) - 1))
+	pcnet32_debug = 1 << debug;
 
     if ((tx_start_pt >= 0) && (tx_start_pt <= 3))
 	tx_start = tx_start_pt;

-- 
Don Fry
brazilnut@us.ibm.com
