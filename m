From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] convert wan/lmc to device model
Date: Tue, 16 Sep 2003 14:36:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916143627.51a08be0.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch converts drivers/net/wan/lmc for 2.6.0-test5
	- use pci_device model
	- get rid of MOD_INC/DEC
	- use alloc_netdev and dev->priv for private data

Builds and loads but don't have real hardware.

diff -Nru a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
--- a/drivers/net/wan/lmc/lmc_main.c	Tue Sep 16 14:33:16 2003
+++ b/drivers/net/wan/lmc/lmc_main.c	Tue Sep 16 14:33:16 2003
@@ -78,30 +78,20 @@
 #include "lmc_debug.h"
 #include "lmc_proto.h"
 
-
-static int Lmc_Count = 0;
-static struct net_device *Lmc_root_dev = NULL;
-static u8 cards_found = 0;
-
 static int lmc_first_load = 0;
 
-int LMC_PKT_BUF_SZ = 1542;
+static int LMC_PKT_BUF_SZ = 1542;
 
-#ifdef MODULE
 static struct pci_device_id lmc_pci_tbl[] = {
-    { 0x1011, 0x009, 0x1379, PCI_ANY_ID, 0, 0, 0},
-    { 0, }
+	{ CORRECT_VENDOR_ID, CORRECT_DEV_ID, PCI_VENDOR_LMC, PCI_ANY_ID },
+	{ CORRECT_VENDOR_ID, CORRECT_DEV_ID, PCI_ANY_ID, PCI_VENDOR_LMC },
+	{ 0 }
 };
 
 MODULE_DEVICE_TABLE(pci, lmc_pci_tbl);
-
 MODULE_LICENSE("GPL");
-#endif
 
 
-int lmc_probe_fake(struct net_device *dev);
-static struct net_device *lmc_probe1(struct net_device *dev, unsigned long ioaddr, unsigned int irq,
-				 int chip_id, int subdevice, int board_idx);
 static int lmc_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int lmc_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int lmc_rx (struct net_device *dev);
@@ -115,12 +105,9 @@
 static void lmc_running_reset(struct net_device *dev);
 static int lmc_ifdown(struct net_device * const);
 static void lmc_watchdog(unsigned long data);
-static int lmc_init(struct net_device * const);
 static void lmc_reset(lmc_softc_t * const sc);
 static void lmc_dec_reset(lmc_softc_t * const sc);
 static void lmc_driver_timeout(struct net_device *dev);
-int lmc_setup(void);
-
 
 /*
  * linux reserves 16 device specific IOCTLs.  We call them
@@ -815,67 +802,77 @@
 
 }
 
-static int lmc_init(struct net_device * const dev) /*fold00*/
+static void lmc_setup(struct net_device * const dev) /*fold00*/
 {
-    lmc_trace(dev, "lmc_init in");
-    lmc_trace(dev, "lmc_init out");
-	
-    return 0;
+    lmc_trace(dev, "lmc_setup in");
+
+    dev->type = ARPHRD_HDLC;
+    dev->hard_start_xmit = lmc_start_xmit;
+    dev->open = lmc_open;
+    dev->stop = lmc_close;
+    dev->get_stats = lmc_get_stats;
+    dev->do_ioctl = lmc_ioctl;
+    dev->set_config = lmc_set_config;
+    dev->tx_timeout = lmc_driver_timeout;
+    dev->watchdog_timeo = (HZ); /* 1 second */
+    
+    lmc_trace(dev, "lmc_setup out");
 }
 
-/* This initializes each card from lmc_probe() */
-static struct net_device *lmc_probe1 (struct net_device *dev, unsigned long ioaddr, unsigned int irq, /*fold00*/
-                                  int chip_id, int subdevice, int board_idx)
+
+static int __devinit lmc_init_one(struct pci_dev *pdev,
+				  const struct pci_device_id *ent)
 {
-    lmc_softc_t *sc = NULL;
+    struct net_device *dev;
+    lmc_softc_t *sc;
+    u16 subdevice;
     u_int16_t AdapModelNum;
-
-    /*
-     * Allocate our own device structure
-     */
-
-    dev = kmalloc (sizeof (struct net_device)+8, GFP_KERNEL);
-    if (dev == NULL){
-        printk (KERN_ERR "lmc: kmalloc for device failed\n");
-        return NULL;
-    }
-    memset (dev, 0, sizeof (struct net_device));
-
+    int err = -ENOMEM;
+    static int cards_found;
 #ifndef GCOM
-    /*
-     *	Switch to common hdlc%d naming. We name by type not by vendor
-     */
-    
-    dev_alloc_name(dev, "hdlc%d");
+    /* We name by type not by vendor */
+    static const char lmcname[] = "hdlc%d";
 #else
-    /*
+    /* 
      * GCOM uses LMC vendor name so that clients can know which card
      * to attach to.
      */
-    dev_alloc_name(dev, "lmc%d");
+    static const char lmcname[] = "lmc%d";
 #endif
 
-    lmc_trace(dev, "lmc_probe1 in");
+
+    /*
+     * Allocate our own device structure
+     */
+    dev = alloc_netdev(sizeof(lmc_softc_t), lmcname, lmc_setup);
+    if (!dev) {
+        printk (KERN_ERR "lmc:alloc_netdev for device failed\n");
+	goto out1;
+    }
+ 
+    lmc_trace(dev, "lmc_init_one in");
+
+    err = pci_enable_device(pdev);
+    if (err) {
+	    printk(KERN_ERR "lmc: pci enable failed:%d\n", err);
+	    goto out2;
+    }
     
-    Lmc_Count++;
+    if (pci_request_regions(pdev, "lmc")) {
+	    printk(KERN_ERR "lmc: pci_request_region failed\n");
+	    err = -EIO;
+	    goto out3;
+    }
+
+    pci_set_drvdata(pdev, dev);
 
     if(lmc_first_load == 0){
-        printk(KERN_INFO "Lan Media Corporation WAN Driver Version %d.%d.%d\n",DRIVER_MAJOR_VERSION, DRIVER_MINOR_VERSION,DRIVER_SUB_VERSION);
+        printk(KERN_INFO "Lan Media Corporation WAN Driver Version %d.%d.%d\n",
+	       DRIVER_MAJOR_VERSION, DRIVER_MINOR_VERSION,DRIVER_SUB_VERSION);
         lmc_first_load = 1;
     }
     
-    /*
-     * Allocate space for the private data structure
-     */
-
-    sc = kmalloc (sizeof (lmc_softc_t), GFP_KERNEL);
-    if (sc == NULL) {
-        printk (KERN_WARNING "%s: Cannot allocate memory for device state\n",
-                dev->name);
-        return (NULL);
-    }
-    memset (sc, 0, sizeof (lmc_softc_t));
-    dev->priv = sc;
+    sc = dev->priv;
     sc->lmc_device = dev;
     sc->name = dev->name;
 
@@ -883,8 +880,12 @@
     /* An ioctl can cause a subsequent detach for raw frame interface */
     sc->if_type = LMC_PPP;
     sc->check = 0xBEAFCAFE;
-    dev->base_addr = ioaddr;
-    dev->irq = irq;
+    dev->base_addr = pci_resource_start(pdev, 0);
+    dev->irq = pdev->irq;
+
+    SET_MODULE_OWNER(dev);
+    SET_NETDEV_DEV(dev, &pdev->dev);
+
     /*
      * This will get the protocol layer ready and do any 1 time init's
      * Must have a valid sc and dev structure
@@ -893,19 +894,6 @@
 
     lmc_proto_attach(sc);
 
-    /* Just fill in the entries for the device */
-
-    dev->init = lmc_init;
-    dev->type = ARPHRD_HDLC;
-    dev->hard_start_xmit = lmc_start_xmit;
-    dev->open = lmc_open;
-    dev->stop = lmc_close;
-    dev->get_stats = lmc_get_stats;
-    dev->do_ioctl = lmc_ioctl;
-    dev->set_config = lmc_set_config;
-    dev->tx_timeout = lmc_driver_timeout;
-    dev->watchdog_timeo = (HZ); /* 1 second */
-    
     /*
      * Why were we changing this???
      dev->tx_queue_len = 100;
@@ -914,27 +902,28 @@
     /* Init the spin lock so can call it latter */
 
     spin_lock_init(&sc->lmc_lock);
+    pci_set_master(pdev);
 
-    printk ("%s: detected at %lx, irq %d\n", dev->name, ioaddr, dev->irq);
+    printk ("%s: detected at %lx, irq %d\n", dev->name,
+	    dev->base_addr, dev->irq);
 
     if (register_netdev (dev) != 0) {
         printk (KERN_ERR "%s: register_netdev failed.\n", dev->name);
-        lmc_proto_detach(sc);
-        kfree (dev->priv);
-        kfree (dev);
-        return NULL;
+	goto out4;
     }
 
-    /*
-     * Request the region of registers we need, so that
-     * later on, no one else will take our card away from
-     * us.
-     */
-    request_region (ioaddr, LMC_REG_RANGE, dev->name);
-
     sc->lmc_cardtype = LMC_CARDTYPE_UNKNOWN;
     sc->lmc_timing = LMC_CTL_CLOCK_SOURCE_EXT;
 
+    /*
+     *
+     * Check either the subvendor or the subdevice, some systems reverse
+     * the setting in the bois, seems to be version and arch dependent?
+     * Fix the error, exchange the two values 
+     */
+    if ((subdevice = pdev->subsystem_device) == PCI_VENDOR_LMC)
+	    subdevice = pdev->subsystem_vendor;
+
     switch (subdevice) {
     case PCI_PRODUCT_LMC_HSSI:
         printk ("%s: LMC HSSI\n", dev->name);
@@ -996,10 +985,7 @@
      */
     LMC_CSR_WRITE (sc, csr_gp_timer, 0xFFFFFFFFUL);
 
-    sc->board_idx = board_idx;
-
-    memset (&sc->stats, 0, sizeof (struct lmc_statistics));
-
+    sc->board_idx = cards_found++;
     sc->stats.check = STATCHECK;
     sc->stats.version_size = (DRIVER_VERSION << 16) +
         sizeof (struct lmc_statistics);
@@ -1008,105 +994,40 @@
     sc->lmc_ok = 0;
     sc->last_link_status = 0;
 
-    lmc_trace(dev, "lmc_probe1 out");
-
-    return dev;
-}
-
-
-/* This is the entry point.  This is what is called immediately. */
-/* This goes out and finds the card */
+    lmc_trace(dev, "lmc_init_one out");
+    return 0;
 
-int lmc_probe_fake(struct net_device *dev) /*fold00*/
-{
-    lmc_probe(NULL);
-    /* Return 1 to unloaded bogus device */
-    return 1;
+ out4:
+    lmc_proto_detach(sc);
+ out3:
+    if (pdev) {
+	    pci_release_regions(pdev);
+	    pci_set_drvdata(pdev, NULL);
+    }
+ out2:
+    free_netdev(dev);
+ out1:
+    return err;
 }
 
-int lmc_probe (struct net_device *dev) /*fold00*/
+/*
+ * Called from pci when removing module.
+ */
+static void __devexit lmc_remove_one (struct pci_dev *pdev)
 {
-    int pci_index = 0;
-    unsigned long pci_ioaddr;
-    unsigned int pci_irq_line;
-    u16 vendor, subvendor, device, subdevice;
-    u32 foundaddr = 0;
-    u8 intcf = 0;
-    struct pci_dev *pdev = NULL;
-
-    /* Loop basically until we don't find anymore. */
-    while ((pdev = pci_find_class (PCI_CLASS_NETWORK_ETHERNET << 8, pdev))) {
-	if (pci_enable_device(pdev))
-		break;
-
-        vendor = pdev->vendor;
-        device = pdev->device;
-        pci_irq_line = pdev->irq;
-        pci_ioaddr = pci_resource_start (pdev, 0);
-	subvendor = pdev->subsystem_vendor;
-	subdevice = pdev->subsystem_device;
-
-	pci_set_master (pdev);
-
-        /*
-         * Make sure it's the correct card.  CHECK SUBVENDOR ID!
-         * There are lots of tulip's out there.
-         * Also check the region of registers we will soon be
-         * poking, to make sure no one else has reserved them.
-         * This prevents taking someone else's device.
-         *
-         * Check either the subvendor or the subdevice, some systems reverse
-         * the setting in the bois, seems to be version and arch dependent?
-         * Fix the two variables
-         *
-         */
-        if (!(check_region (pci_ioaddr, LMC_REG_RANGE)) &&
-            (vendor == CORRECT_VENDOR_ID) &&
-            (device == CORRECT_DEV_ID) &&
-            ((subvendor == PCI_VENDOR_LMC)  || (subdevice == PCI_VENDOR_LMC))){
-            struct net_device *cur, *prev = NULL;
-
-            /* Fix the error, exchange the two values */
-            if(subdevice == PCI_VENDOR_LMC){
-                subdevice = subvendor;
-                subvendor = PCI_VENDOR_LMC ;
-            }
-
-            /* Make the call to actually setup this card */
-            dev = lmc_probe1 (dev, pci_ioaddr, pci_irq_line,
-                              device, subdevice, cards_found);
-            if (dev == NULL) {
-                printk ("lmc_probe: lmc_probe1 failed\n");
-                goto lmc_probe_next_card;
-            }
-            /* insert the device into the chain of lmc devices */
-            for (cur = Lmc_root_dev;
-                 cur != NULL;
-                 cur = ((lmc_softc_t *) cur->priv)->next_module) {
-                prev = cur;
-            }
-
-            if (prev == NULL)
-                Lmc_root_dev = dev;
-            else
-                ((lmc_softc_t *) prev->priv)->next_module = dev;
-
-            ((lmc_softc_t *) dev->priv)->next_module = NULL;
-            /* end insert */
-
-            foundaddr = dev->base_addr;
-
-            cards_found++;
-            intcf++;
-        }
-    lmc_probe_next_card:
-        pci_index++;
+    struct net_device *dev = pci_get_drvdata(pdev);
+    
+    if (dev) {
+	    lmc_softc_t *sc = dev->priv;
+	    
+	    printk("%s: removing...\n", dev->name);
+	    lmc_proto_detach(sc);
+	    unregister_netdev(dev);
+	    free_netdev(dev);
+	    pci_release_regions(pdev);
+	    pci_disable_device(pdev);
+	    pci_set_drvdata(pdev, NULL);
     }
-
-    if (cards_found < 1)
-        return -1;
-
-    return foundaddr;
 }
 
 /* After this is called, packets can be sent.
@@ -1181,8 +1102,6 @@
     
     sc->stats.tx_tbusy0++ ;
 
-    MOD_INC_USE_COUNT;
-
     /*
      * select what interrupts we want to get
      */
@@ -1352,7 +1271,6 @@
 
     lmc_trace(dev, "lmc_ifdown out");
 
-    MOD_DEC_USE_COUNT;
     return 0;
 }
 
@@ -1850,12 +1768,11 @@
 
 static struct net_device_stats *lmc_get_stats (struct net_device *dev) /*fold00*/
 {
-    lmc_softc_t *sc;
+    lmc_softc_t *sc = dev->priv;
     unsigned long flags;
 
     lmc_trace(dev, "lmc_get_stats in");
 
-    sc = dev->priv;
 
     spin_lock_irqsave(&sc->lmc_lock, flags);
 
@@ -1868,58 +1785,21 @@
     return (struct net_device_stats *) &sc->stats;
 }
 
+static struct pci_driver lmc_driver = {
+	.name		= "lmc",
+	.id_table	= lmc_pci_tbl,
+	.probe		= lmc_init_one,
+	.remove		= __devexit_p(lmc_remove_one),
+};
+
 static int __init init_lmc(void)
 {
-    printk ("lmc: module loaded\n");
-
-    /* Have lmc_probe search for all the cards, and allocate devices */
-    if (lmc_probe (NULL) < 0)
-        return -EIO;
-
-    return 0;
+    return pci_module_init(&lmc_driver);
 }
 
 static void __exit exit_lmc(void)
 {
-    struct net_device *dev, *next;
-    lmc_softc_t *sc;
-
-    /* we have no pointer to our devices, since they are all dynamically
-     * allocated.  So, here we loop through all the network devices
-     * looking for ours.  When found, dispose of them properly.
-     */
-
-    for (dev = Lmc_root_dev;
-         dev != NULL;
-         dev = next )
-    {
-
-        next = ((lmc_softc_t *) dev->priv)->next_module; /* get it now before we deallocate it */
-        printk ("%s: removing...\n", dev->name);
-
-        /* close the syncppp stuff, and release irq. Close is run on unreg net */
-        lmc_close (dev);
-	sc = dev->priv;
-        if (sc != NULL)
-            lmc_proto_detach(sc);
-
-        /* Remove the device from the linked list */
-        unregister_netdev (dev);
-
-        /* Let go of the io region */;
-        release_region (dev->base_addr, LMC_REG_RANGE);
-
-        /* free our allocated structures. */
-        kfree (dev->priv);
-        dev->priv = NULL;
-
-        free_netdev (dev);
-        dev = NULL;
-    }
-
-
-    Lmc_root_dev = NULL;
-    printk ("lmc module unloaded\n");
+    pci_unregister_driver(&lmc_driver);
 }
 
 module_init(init_lmc);
@@ -2326,8 +2206,3 @@
 
 
 }
-
-int lmc_setup(void) { /*FOLD00*/
-   return lmc_probe(NULL);
-}
-
diff -Nru a/drivers/net/wan/lmc/lmc_var.h b/drivers/net/wan/lmc/lmc_var.h
--- a/drivers/net/wan/lmc/lmc_var.h	Tue Sep 16 14:33:16 2003
+++ b/drivers/net/wan/lmc/lmc_var.h	Tue Sep 16 14:33:16 2003
@@ -390,7 +390,7 @@
 	struct timer_list	timer;
 	lmc_ctl_t		ictl;
 	u_int32_t		TxDescriptControlInit;  
-	struct net_device		*next_module;   /* Link to the next module  */
+
 	int                     tx_TimeoutInd; /* additional driver state */
 	int                     tx_TimeoutDisplay;
 	unsigned int		lastlmc_taint_tx;
