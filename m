From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 9/9][ATM]: [fore200e] rewrite to eliminate pci_find_device() but preserve sbus support
Date: Mon, 07 Mar 2005 17:08:28 -0500
Message-ID: <200503072208.j27M8SOt021044@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/07 15:31:25-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [fore200e] rewrite to eliminate pci_find_device() but preserve sbus support
#   
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/fore200e.h
#   2005/03/07 15:31:07-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: [fore200e] rewrite to eliminate pci_find_device() but preserve sbus support
#   
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/fore200e.c
#   2005/03/07 15:31:07-05:00 chas@relax.cmf.nrl.navy.mil +107 -47
#   [ATM]: [fore200e] rewrite to eliminate pci_find_device() but preserve sbus support
#   
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
--- a/drivers/atm/fore200e.c	2005-03-07 15:36:53 -05:00
+++ b/drivers/atm/fore200e.c	2005-03-07 15:36:53 -05:00
@@ -110,7 +110,7 @@
 static const struct atmdev_ops   fore200e_ops;
 static const struct fore200e_bus fore200e_bus[];
 
-static struct fore200e* fore200e_boards = NULL;
+static LIST_HEAD(fore200e_boards);
 
 
 MODULE_AUTHOR("Christophe Lizzi - credits to Uwe Dannowski and Heikki Vatiainen");
@@ -633,39 +633,6 @@
 }
 
 
-static struct fore200e* __init
-fore200e_pca_detect(const struct fore200e_bus* bus, int index)
-{
-    struct fore200e* fore200e;
-    struct pci_dev*  pci_dev = NULL;
-    int              count = index;
-    
-    do {
-	pci_dev = pci_find_device(PCI_VENDOR_ID_FORE, PCI_DEVICE_ID_FORE_PCA200E, pci_dev);
-	if (pci_dev == NULL)
-	    return NULL;
-    } while (count--);
-
-    if (pci_enable_device(pci_dev))
-	return NULL;
-    
-    fore200e = fore200e_kmalloc(sizeof(struct fore200e), GFP_KERNEL);
-    if (fore200e == NULL)
-	return NULL;
-
-    fore200e->bus       = bus;
-    fore200e->bus_dev   = pci_dev;    
-    fore200e->irq       = pci_dev->irq;
-    fore200e->phys_base = pci_resource_start(pci_dev, 0);
-
-    sprintf(fore200e->name, "%s-%d", bus->model_name, index - 1);
-
-    pci_set_master(pci_dev);
-
-    return fore200e;
-}
-
-
 static int __init
 fore200e_pca_prom_read(struct fore200e* fore200e, struct prom_data* prom)
 {
@@ -2764,20 +2731,107 @@
     return 0;
 }
 
+
+static int __devinit
+fore200e_pca_detect(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
+{
+    const struct fore200e_bus* bus = (struct fore200e_bus*) pci_ent->driver_data;
+    struct fore200e* fore200e;
+    int err = 0;
+    static int index = 0;
+
+    if (pci_enable_device(pci_dev)) {
+	err = -EINVAL;
+	goto out;
+    }
+    
+    fore200e = fore200e_kmalloc(sizeof(struct fore200e), GFP_KERNEL);
+    if (fore200e == NULL) {
+	err = -ENOMEM;
+	goto out_disable;
+    }
+
+    fore200e->bus       = bus;
+    fore200e->bus_dev   = pci_dev;    
+    fore200e->irq       = pci_dev->irq;
+    fore200e->phys_base = pci_resource_start(pci_dev, 0);
+
+    sprintf(fore200e->name, "%s-%d", bus->model_name, index - 1);
+
+    pci_set_master(pci_dev);
+
+    printk(FORE200E "device %s found at 0x%lx, IRQ %s\n",
+	   fore200e->bus->model_name, 
+	   fore200e->phys_base, fore200e_irq_itoa(fore200e->irq));
+
+    sprintf(fore200e->name, "%s-%d", bus->model_name, index);
+
+    err = fore200e_init(fore200e);
+    if (err < 0) {
+	fore200e_shutdown(fore200e);
+	goto out_free;
+    }
+
+    ++index;
+    pci_set_drvdata(pci_dev, fore200e);
+
+out:
+    return err;
+
+out_free:
+    kfree(fore200e);
+out_disable:
+    pci_disable_device(pci_dev);
+    goto out;
+}
+
+
+static void __devexit fore200e_pca_remove_one(struct pci_dev *pci_dev)
+{
+    struct fore200e *fore200e;
+
+    fore200e = pci_get_drvdata(pci_dev);
+
+    list_del(&fore200e->entry);
+
+    fore200e_shutdown(fore200e);
+    kfree(fore200e);
+    pci_disable_device(pci_dev);
+}
+
+
+#ifdef CONFIG_ATM_FORE200E_PCA
+static struct pci_device_id fore200e_pca_tbl[] = {
+    { PCI_VENDOR_ID_FORE, PCI_DEVICE_ID_FORE_PCA200E, PCI_ANY_ID, PCI_ANY_ID,
+      0, 0, (unsigned long) &fore200e_bus[0] },
+    { 0, }
+};
+
+MODULE_DEVICE_TABLE(pci, fore200e_pca_tbl);
+
+static struct pci_driver fore200e_pca_driver = {
+    .name =     "fore_200e",
+    .probe =    fore200e_pca_detect,
+    .remove =   __devexit_p(fore200e_pca_remove_one),
+    .id_table = fore200e_pca_tbl,
+};
+#endif
+
+
 static int __init
 fore200e_module_init(void)
 {
     const struct fore200e_bus* bus;
     struct       fore200e*     fore200e;
-    int                        index, link;
+    int                        index;
 
     printk(FORE200E "FORE Systems 200E-series ATM driver - version " FORE200E_VERSION "\n");
 
     /* for each configured bus interface */
-    for (link = 0, bus = fore200e_bus; bus->model_name; bus++) {
+    for (bus = fore200e_bus; bus->model_name; bus++) {
 
 	/* detect all boards present on that bus */
-	for (index = 0; (fore200e = bus->detect(bus, index)); index++) {
+	for (index = 0; bus->detect && (fore200e = bus->detect(bus, index)); index++) {
 	    
 	    printk(FORE200E "device %s found at 0x%lx, IRQ %s\n",
 		   fore200e->bus->model_name, 
@@ -2791,15 +2845,18 @@
 		break;
 	    }
 
-	    link++;
-
-	    fore200e->next  = fore200e_boards;
-	    fore200e_boards = fore200e;
+	    list_add(&fore200e->entry, &fore200e_boards);
 	}
     }
 
-    if (link)
-        return 0;
+#ifdef CONFIG_ATM_FORE200E_PCA
+    if (!pci_register_driver(&fore200e_pca_driver))
+	return 0;
+#endif
+
+    if (!list_empty(&fore200e_boards))
+	return 0;
+
     return -ENODEV;
 }
 
@@ -2807,11 +2864,14 @@
 static void __exit
 fore200e_module_cleanup(void)
 {
-    while (fore200e_boards) {
-        struct fore200e* fore200e = fore200e_boards;
+    struct fore200e *fore200e, *next;
+
+#ifdef CONFIG_ATM_FORE200E_PCA
+    pci_unregister_driver(&fore200e_pca_driver);
+#endif
 
+    list_for_each_entry_safe(fore200e, next, &fore200e_boards, entry) {
 	fore200e_shutdown(fore200e);
-	fore200e_boards = fore200e->next;
 	kfree(fore200e);
     }
     DPRINTK(1, "module being removed\n");
@@ -3146,7 +3206,7 @@
       fore200e_pca_dma_sync_for_device,
       fore200e_pca_dma_chunk_alloc,
       fore200e_pca_dma_chunk_free,
-      fore200e_pca_detect,
+      NULL,
       fore200e_pca_configure,
       fore200e_pca_map,
       fore200e_pca_reset,
diff -Nru a/drivers/atm/fore200e.h b/drivers/atm/fore200e.h
--- a/drivers/atm/fore200e.h	2005-03-07 15:36:53 -05:00
+++ b/drivers/atm/fore200e.h	2005-03-07 15:36:53 -05:00
@@ -841,7 +841,7 @@
 /* per-device data */
 
 typedef struct fore200e {
-    struct       fore200e*     next;                   /* next device                        */
+    struct       list_head     entry;                  /* next device                        */
     const struct fore200e_bus* bus;                    /* bus-dependent code and data        */
     union        fore200e_regs regs;                   /* bus-dependent registers            */
     struct       atm_dev*      atm_dev;                /* ATM device                         */
