From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM]: [ambassador] eliminate pci_find_device()
Date: Thu, 21 Oct 2004 21:29:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410220129.i9M1TvPr026209@ginger.cmf.nrl.navy.mil>
References: <20041021113841.GA3720@infradead.org>
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-reply-to: Your message of "Thu, 21 Oct 2004 12:38:41 BST."
             <20041021113841.GA3720@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

better?

# This is a BitKeeper generated diff -Nru style patch.
#
#   [ATM]: [ambassador] eliminate pci_find_device()
# 
diff -Nru a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
--- a/drivers/atm/ambassador.c	2004-10-21 21:24:47 -04:00
+++ b/drivers/atm/ambassador.c	2004-10-21 21:24:47 -04:00
@@ -313,9 +313,6 @@
 static void do_housekeeping (unsigned long arg);
 /********** globals **********/
 
-static amb_dev * amb_devs = NULL;
-static struct timer_list housekeeping = TIMER_INITIALIZER(do_housekeeping, 0, 1);
-
 static unsigned short debug = 0;
 static unsigned int cmds = 8;
 static unsigned int txs = 32;
@@ -870,7 +867,7 @@
 
 static irqreturn_t interrupt_handler(int irq, void *dev_id,
 					struct pt_regs *pt_regs) {
-  amb_dev * dev = amb_devs;
+  amb_dev * dev = (amb_dev *) dev_id;
   (void) pt_regs;
   
   PRINTD (DBG_IRQ|DBG_FLOW, "interrupt_handler: %p", dev_id);
@@ -879,24 +876,6 @@
     PRINTD (DBG_IRQ|DBG_ERR, "irq with NULL dev_id: %d", irq);
     return IRQ_NONE;
   }
-  // Did one of our cards generate the interrupt?
-  while (dev) {
-    if (dev == dev_id)
-      break;
-    dev = dev->prev;
-  }
-  // impossible - unless we add the device to our list after both
-  // registering the IRQ handler for it and enabling interrupts, AND
-  // the card generates an IRQ at startup - should not happen again
-  if (!dev) {
-    PRINTD (DBG_IRQ, "irq for unknown device: %d", irq);
-    return IRQ_NONE;
-  }
-  // impossible - unless we have memory corruption of dev or kernel
-  if (irq != dev->irq) {
-    PRINTD (DBG_IRQ|DBG_ERR, "irq mismatch: %d", irq);
-    return IRQ_NONE;
-  }
   
   {
     u32 interrupt = rd_plain (dev, offsetof(amb_mem, interrupt));
@@ -1554,22 +1533,13 @@
 
 /********** housekeeping **********/
 static void do_housekeeping (unsigned long arg) {
-  amb_dev * dev = amb_devs;
-  // data is set to zero at module unload
-  (void) arg;
+  amb_dev * dev = (amb_dev *) arg;
   
-  if (housekeeping.data) {
-    while (dev) {
-      
-      // could collect device-specific (not driver/atm-linux) stats here
+  // could collect device-specific (not driver/atm-linux) stats here
       
-      // last resort refill once every ten seconds
-      fill_rx_pools (dev);
-      
-      dev = dev->prev;
-    }
-    mod_timer(&housekeeping, jiffies + 10*HZ);
-  }
+  // last resort refill once every ten seconds
+  fill_rx_pools (dev);
+  mod_timer(&dev->housekeeping, jiffies + 10*HZ);
   
   return;
 }
@@ -2225,6 +2195,7 @@
       
       // set up known dev items straight away
       dev->pci_dev = pci_dev; 
+      pci_set_drvdata(pci_dev, dev);
       
       dev->iobase = pci_resource_start (pci_dev, 1);
       dev->irq = pci_dev->irq; 
@@ -2284,7 +2255,7 @@
 	return ret;
 }
 
-static int __init do_pci_device(struct pci_dev *pci_dev)
+static int __devinit amb_probe(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
 {
 	amb_dev * dev;
 	int err;
@@ -2292,6 +2263,12 @@
 	// read resources from PCI configuration space
 	u8 irq = pci_dev->irq;
 
+	if (pci_dev->device == PCI_DEVICE_ID_MADGE_AMBASSADOR_BAD) {
+		PRINTK (KERN_ERR, "skipped broken (PLX rev 2) card");
+		err = -EINVAL;
+		goto out;
+	}
+
 	PRINTD (DBG_INFO, "found Madge ATM adapter (amb) at"
 		" IO %x, IRQ %u, MEM %p", pci_resource_start(pci_dev, 1),
 		irq, bus_to_virt(pci_resource_start(pci_dev, 0)));
@@ -2347,9 +2324,10 @@
 	dev->atm_dev->ci_range.vpi_bits = NUM_VPI_BITS;
 	dev->atm_dev->ci_range.vci_bits = NUM_VCI_BITS;
 
-	// update linked list
-	dev->prev = amb_devs;
-	amb_devs = dev;
+	init_timer(&dev->housekeeping);
+	dev->housekeeping.function = do_housekeeping;
+	dev->housekeeping.data = (unsigned long) dev;
+	mod_timer(&dev->housekeeping, jiffies);
 
 	// enable host interrupts
 	interrupts_on (dev);
@@ -2370,29 +2348,25 @@
 	goto out;
 }
 
-static int __init amb_probe (void) {
-  struct pci_dev * pci_dev;
-  int devs;
-  
-  PRINTD (DBG_FLOW, "amb_probe");
-  
-  devs = 0;
-  pci_dev = NULL;
-  while ((pci_dev = pci_find_device
-          (PCI_VENDOR_ID_MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR, pci_dev)
-          )) {
-	if (do_pci_device(pci_dev) == 0)
-		devs++;
-  }
 
-  
-  pci_dev = NULL;
-  while ((pci_dev = pci_find_device
-          (PCI_VENDOR_ID_MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR_BAD, pci_dev)
-          ))
-    PRINTK (KERN_ERR, "skipped broken (PLX rev 2) card");
-  
-  return devs;
+static void __devexit amb_remove_one(struct pci_dev *pci_dev)
+{
+	struct amb_dev *dev;
+
+	dev = pci_get_drvdata(pci_dev);
+
+	PRINTD(DBG_INFO|DBG_INIT, "closing %p (atm_dev = %p)", dev, dev->atm_dev);
+	del_timer_sync(&dev->housekeeping);
+	// the drain should not be necessary
+	drain_rx_pools(dev);
+	interrupts_off(dev);
+	amb_reset(dev, 0);
+	free_irq(dev->irq, dev);
+	pci_disable_device(pci_dev);
+	destroy_queues(dev);
+	atm_dev_deregister(dev->atm_dev);
+	kfree(dev);
+	pci_release_region(pci_dev, 1);
 }
 
 static void __init amb_check_args (void) {
@@ -2457,9 +2431,23 @@
 
 /********** module entry **********/
 
-static int __init amb_module_init (void) {
-  int devs;
-  
+static struct pci_device_id amb_pci_tbl[] = {
+	{ PCI_VENDOR_ID_MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR, PCI_ANY_ID, PCI_ANY_ID,
+	  0, 0, 0 },
+	{ PCI_VENDOR_ID_MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR_BAD, PCI_ANY_ID, PCI_ANY_ID,
+	  0, 0, 0 },
+	{ 0, }
+};
+
+static struct pci_driver amb_driver = {
+	.name =		"amb",
+	.probe =	amb_probe,
+	.remove =	__devexit_p(amb_remove_one),
+	.id_table =	amb_pci_tbl,
+};
+
+static int __init amb_module_init (void)
+{
   PRINTD (DBG_FLOW|DBG_INIT, "init_module");
   
   // sanity check - cast needed as printk does not support %Zu
@@ -2474,49 +2462,16 @@
   amb_check_args();
   
   // get the juice
-  devs = amb_probe();
-  
-  if (devs) {
-    mod_timer (&housekeeping, jiffies);
-  } else {
-    PRINTK (KERN_INFO, "no (usable) adapters found");
-  }
-  
-  return devs ? 0 : -ENODEV;
+  return pci_module_init(&amb_driver);
 }
 
 /********** module exit **********/
 
-static void __exit amb_module_exit (void) {
-  amb_dev * dev;
-  
+static void __exit amb_module_exit (void)
+{
   PRINTD (DBG_FLOW|DBG_INIT, "cleanup_module");
   
-  // paranoia
-  housekeeping.data = 0;
-  del_timer_sync(&housekeeping);
-  
-  while (amb_devs) {
-    struct pci_dev *pdev;
-
-    dev = amb_devs;
-    pdev = dev->pci_dev;
-    amb_devs = dev->prev;
-    
-    PRINTD (DBG_INFO|DBG_INIT, "closing %p (atm_dev = %p)", dev, dev->atm_dev);
-    // the drain should not be necessary
-    drain_rx_pools (dev);
-    interrupts_off (dev);
-    amb_reset (dev, 0);
-    free_irq (dev->irq, dev);
-    pci_disable_device (pdev);
-    destroy_queues (dev);
-    atm_dev_deregister (dev->atm_dev);
-    kfree (dev);
-    pci_release_region (pdev, 1);
-  }
-  
-  return;
+  return pci_unregister_driver(&amb_driver);
 }
 
 module_init(amb_module_init);
diff -Nru a/drivers/atm/ambassador.h b/drivers/atm/ambassador.h
--- a/drivers/atm/ambassador.h	2004-10-21 21:24:47 -04:00
+++ b/drivers/atm/ambassador.h	2004-10-21 21:24:47 -04:00
@@ -649,7 +649,7 @@
   
   struct atm_dev * atm_dev;
   struct pci_dev * pci_dev;
-  struct amb_dev * prev;
+  struct timer_list housekeeping;
 };
 
 typedef struct amb_dev amb_dev;
