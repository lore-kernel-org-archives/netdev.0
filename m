From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 3 2.4.27] pcnet32: cleanup IRQ limitation
Date: Mon, 9 Aug 2004 16:16:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040809231635.GD13717@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cleanup pcnet32 IRQ handling based on suggestions from Ralf Baechle
<ralf@linux-mips.org> and Brian Murphy <brian@murphy.dk>

Tested by myself and Brian Murphy.

Signed-off-by: Don Fry <brazilnut@us.ibm.com>

--- linux-2.4.27/drivers/net/hung.pcnet32.c	Mon Aug  9 15:41:42 2004
+++ linux-2.4.27/drivers/net/pcnet32.c	Mon Aug  9 15:41:52 2004
@@ -22,8 +22,8 @@
  *************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#define DRV_VERSION	"1.30e"
-#define DRV_RELDATE	"06.11.2004"
+#define DRV_VERSION	"1.30f"
+#define DRV_RELDATE	"06.16.2004"
 #define PFX		DRV_NAME ": "
 
 static const char *version =
@@ -247,6 +247,9 @@ static int full_duplex[MAX_UNITS];
  * v1.30c  25 May 2004 Don Fry added netif_wake_queue after pcnet32_restart.
  * v1.30d  01 Jun 2004 Don Fry discard oversize rx packets.
  * v1.30e  11 Jun 2004 Don Fry recover after fifo error and rx hang.
+ * v1.30f  16 Jun 2004 Don Fry cleanup IRQ to allow 0 and 1 for PCI,
+ * 	   expanding on suggestions from Ralf Baechle <ralf@linux-mips.org>,
+ * 	   and Brian Murphy <brian@murphy.dk>.
  */
 
 
@@ -362,7 +365,7 @@ struct pcnet32_private {
 
 static void pcnet32_probe_vlbus(void);
 static int  pcnet32_probe_pci(struct pci_dev *, const struct pci_device_id *);
-static int  pcnet32_probe1(unsigned long, unsigned int, int, struct pci_dev *);
+static int  pcnet32_probe1(unsigned long, int, struct pci_dev *);
 static int  pcnet32_open(struct net_device *);
 static int  pcnet32_init_ring(struct net_device *);
 static int  pcnet32_start_xmit(struct sk_buff *, struct net_device *);
@@ -959,7 +962,7 @@ pcnet32_probe_vlbus(void)
 	if (request_region(ioaddr, PCNET32_TOTAL_SIZE, "pcnet32_probe_vlbus")) {
 	    /* check if there is really a pcnet chip on that ioaddr */
 	    if ((inb(ioaddr + 14) == 0x57) && (inb(ioaddr + 15) == 0x57)) {
-		pcnet32_probe1(ioaddr, 0, 0, NULL);
+		pcnet32_probe1(ioaddr, 0, NULL);
 	    } else {
 		release_region(ioaddr, PCNET32_TOTAL_SIZE);
 	    }
@@ -1000,7 +1003,7 @@ pcnet32_probe_pci(struct pci_dev *pdev, 
 	return -EBUSY;
     }
 
-    return pcnet32_probe1(ioaddr, pdev->irq, 1, pdev);
+    return pcnet32_probe1(ioaddr, 1, pdev);
 }
 
 
@@ -1009,8 +1012,7 @@ pcnet32_probe_pci(struct pci_dev *pdev, 
  *  pdev will be NULL when called from pcnet32_probe_vlbus.
  */
 static int __devinit
-pcnet32_probe1(unsigned long ioaddr, unsigned int irq_line, int shared,
-		struct pci_dev *pdev)
+pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 {
     struct pcnet32_private *lp;
     dma_addr_t lp_dma_addr;
@@ -1271,11 +1273,8 @@ pcnet32_probe1(unsigned long ioaddr, uns
     a->write_csr(ioaddr, 2, (lp->dma_addr + offsetof(struct pcnet32_private,
 		    init_block)) >> 16);
 
-    if (irq_line) {
-	dev->irq = irq_line;
-    }
-
-    if (dev->irq >= 2) {
+    if (pdev) {		/* use the IRQ provided by PCI */
+	dev->irq = pdev->irq;
 	if (pcnet32_debug & NETIF_MSG_PROBE)
 	    printk(" assigned IRQ %d.\n", dev->irq);
     } else {
@@ -1363,8 +1362,7 @@ pcnet32_open(struct net_device *dev)
     int rc;
     unsigned long flags;
 
-    if (dev->irq == 0 ||
-	request_irq(dev->irq, &pcnet32_interrupt,
+    if (request_irq(dev->irq, &pcnet32_interrupt,
 		    lp->shared_irq ? SA_SHIRQ : 0, dev->name, (void *)dev)) {
 	return -EAGAIN;
     }

-- 
Don Fry
brazilnut@us.ibm.com
