From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [ambassador] eliminate pci_find_device()
Date: Thu, 21 Oct 2004 07:26:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410211126.i9LBQbFT008844@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6.

thanks!

Signed-off-by: Chas Williams <chas@....>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/18 16:39:40-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [ambassador] eliminate pci_find_device()
# 
# drivers/atm/ambassador.h
#   2004/10/18 16:39:25-04:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: [ambassador] eliminate pci_find_device()
# 
# drivers/atm/ambassador.c
#   2004/10/18 16:39:25-04:00 chas@relax.cmf.nrl.navy.mil +65 -67
#   [ATM]: [ambassador] eliminate pci_find_device()
# 
diff -Nru a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
--- a/drivers/atm/ambassador.c	2004-10-18 16:52:28 -04:00
+++ b/drivers/atm/ambassador.c	2004-10-18 16:52:28 -04:00
@@ -313,7 +313,7 @@
 static void do_housekeeping (unsigned long arg);
 /********** globals **********/
 
-static amb_dev * amb_devs = NULL;
+static LIST_HEAD(amb_devs);
 static struct timer_list housekeeping = TIMER_INITIALIZER(do_housekeeping, 0, 1);
 
 static unsigned short debug = 0;
@@ -870,7 +870,8 @@
 
 static irqreturn_t interrupt_handler(int irq, void *dev_id,
 					struct pt_regs *pt_regs) {
-  amb_dev * dev = amb_devs;
+  amb_dev * dev = NULL;
+  struct list_head *p;
   (void) pt_regs;
   
   PRINTD (DBG_IRQ|DBG_FLOW, "interrupt_handler: %p", dev_id);
@@ -880,10 +881,11 @@
     return IRQ_NONE;
   }
   // Did one of our cards generate the interrupt?
-  while (dev) {
+  list_for_each(p, &amb_devs) {
+    dev = list_entry(p, struct amb_dev, entry);
     if (dev == dev_id)
       break;
-    dev = dev->prev;
+    dev = NULL;
   }
   // impossible - unless we add the device to our list after both
   // registering the IRQ handler for it and enabling interrupts, AND
@@ -1554,19 +1556,19 @@
 
 /********** housekeeping **********/
 static void do_housekeeping (unsigned long arg) {
-  amb_dev * dev = amb_devs;
+  amb_dev * dev;
+  struct list_head *p;
   // data is set to zero at module unload
   (void) arg;
   
   if (housekeeping.data) {
-    while (dev) {
+    list_for_each(p, &amb_devs) {
+      dev = list_entry(p, struct amb_dev, entry);
       
       // could collect device-specific (not driver/atm-linux) stats here
       
       // last resort refill once every ten seconds
       fill_rx_pools (dev);
-      
-      dev = dev->prev;
     }
     mod_timer(&housekeeping, jiffies + 10*HZ);
   }
@@ -2225,6 +2227,7 @@
       
       // set up known dev items straight away
       dev->pci_dev = pci_dev; 
+      pci_set_drvdata(pci_dev, dev);
       
       dev->iobase = pci_resource_start (pci_dev, 1);
       dev->irq = pci_dev->irq; 
@@ -2284,7 +2287,7 @@
 	return ret;
 }
 
-static int __init do_pci_device(struct pci_dev *pci_dev)
+static int __devinit amb_probe(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
 {
 	amb_dev * dev;
 	int err;
@@ -2292,6 +2295,12 @@
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
@@ -2348,8 +2357,7 @@
 	dev->atm_dev->ci_range.vci_bits = NUM_VCI_BITS;
 
 	// update linked list
-	dev->prev = amb_devs;
-	amb_devs = dev;
+	list_add_tail(&dev->entry, &amb_devs);
 
 	// enable host interrupts
 	interrupts_on (dev);
@@ -2370,29 +2378,26 @@
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
+	list_del(&dev->entry);
+    
+	PRINTD(DBG_INFO|DBG_INIT, "closing %p (atm_dev = %p)", dev, dev->atm_dev);
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
@@ -2457,9 +2462,25 @@
 
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
+  int err;
+
   PRINTD (DBG_FLOW|DBG_INIT, "init_module");
   
   // sanity check - cast needed as printk does not support %Zu
@@ -2474,49 +2495,26 @@
   amb_check_args();
   
   // get the juice
-  devs = amb_probe();
-  
-  if (devs) {
+  err = pci_module_init(&amb_driver);
+  if (err == 0)
     mod_timer (&housekeeping, jiffies);
-  } else {
+  else
     PRINTK (KERN_INFO, "no (usable) adapters found");
-  }
-  
-  return devs ? 0 : -ENODEV;
+
+  return err;
 }
 
 /********** module exit **********/
 
-static void __exit amb_module_exit (void) {
-  amb_dev * dev;
-  
+static void __exit amb_module_exit (void)
+{
   PRINTD (DBG_FLOW|DBG_INIT, "cleanup_module");
   
   // paranoia
   housekeeping.data = 0;
   del_timer_sync(&housekeeping);
   
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
--- a/drivers/atm/ambassador.h	2004-10-18 16:52:28 -04:00
+++ b/drivers/atm/ambassador.h	2004-10-18 16:52:28 -04:00
@@ -649,7 +649,7 @@
   
   struct atm_dev * atm_dev;
   struct pci_dev * pci_dev;
-  struct amb_dev * prev;
+  struct list_head entry;
 };
 
 typedef struct amb_dev amb_dev;
