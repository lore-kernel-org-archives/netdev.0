From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.3] pcnet32.c add PCI hot remove support
Date: Fri, 20 Feb 2004 14:55:32 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402202255.i1KMtX007392@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds support for PCI hot remove.  Tested on PPC64 boxes.
The driver has also been checked to comply with PCMCIA/cardbus remove
requirements, but as I don't have a PCMCIA card, it is untested.
If a PCMCIA card is removed, reads will return FFFF.  The FFFF will
cause all while loops to exit.

--- linux-2.6.3/drivers/net/mii.pcnet32.c	Fri Feb 20 14:32:10 2004
+++ linux-2.6.3/drivers/net/pcnet32.c	Fri Feb 20 14:43:55 2004
@@ -935,8 +935,13 @@
     if (register_netdev(dev))
 	goto err_free_consistent;
 
-    lp->next = pcnet32_dev;
-    pcnet32_dev = dev;
+    if (pdev) {
+	pci_set_drvdata(pdev, dev);
+    } else {
+	lp->next = pcnet32_dev;
+	pcnet32_dev = dev;
+    }
+
     printk(KERN_INFO "%s: registered as %s\n",dev->name, lp->name);
     cards_found++;
     return 0;
@@ -1330,6 +1335,9 @@
     
     rap = lp->a.read_rap(ioaddr);
     while ((csr0 = lp->a.read_csr (ioaddr, 0)) & 0x8600 && --boguscnt >= 0) {
+	if (csr == 0xffff) {
+	    break;			/* PCMCIA remove happened */
+	}
 	/* Acknowledge all of the current interrupt sources ASAP. */
 	lp->a.write_csr (ioaddr, 0, csr0 & ~0x004f);
 
@@ -1764,9 +1772,25 @@
     mod_timer (&(lp->watchdog_timer), PCNET32_WATCHDOG_TIMEOUT);
 }
 
+static void __devexit pcnet32_remove_one(struct pci_dev *pdev)
+{
+    struct net_device *dev = pci_get_drvdata(pdev);
+
+    if (dev) {
+	struct pcnet32_private *lp = dev->priv;
+
+	unregister_netdev(dev);
+	release_region(dev->base_addr, PCNET32_TOTAL_SIZE);
+	pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
+	free_netdev(dev);
+	pci_set_drvdata(pdev, NULL);
+    }
+}
+
 static struct pci_driver pcnet32_driver = {
     .name	= DRV_NAME,
     .probe	= pcnet32_probe_pci,
+    .remove	= __devexit_p(pcnet32_remove_one),
     .id_table	= pcnet32_pci_tbl,
 };
 

-- 
Don Fry
brazilnut@us.ibm.com
