From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM]: [horizon] eliminate pci_find_device()
Date: Fri, 22 Oct 2004 08:03:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410221203.i9MC3Ecw003142@ginger.cmf.nrl.navy.mil>
References: <20041021113949.GB3720@infradead.org>
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-reply-to: Your message of "Thu, 21 Oct 2004 12:39:49 BST."
             <20041021113949.GB3720@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20041021113949.GB3720@infradead.org>,Christoph Hellwig writes:
>The same device list comments as for ambassador apply here aswell.

better?

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/22 08:02:03-04:00 chas@relax.cmf.nrl.navy.mil 
#   horizon.h, horizon.c:
#     [ATM]: [horizon] eliminate pci_find_device()
# 
# drivers/atm/horizon.h
#   2004/10/22 08:01:18-04:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: [horizon] eliminate pci_find_device()
# 
# drivers/atm/horizon.c
#   2004/10/22 08:01:05-04:00 chas@relax.cmf.nrl.navy.mil +156 -176
#   [ATM]: [horizon] eliminate pci_find_device()
# 
diff -Nru a/drivers/atm/horizon.c b/drivers/atm/horizon.c
--- a/drivers/atm/horizon.c	2004-10-22 08:02:29 -04:00
+++ b/drivers/atm/horizon.c	2004-10-22 08:02:29 -04:00
@@ -354,8 +354,7 @@
 
 /********** globals **********/
 
-static hrz_dev * hrz_devs = NULL;
-static struct timer_list housekeeping;
+static void do_housekeeping (unsigned long arg);
 
 static unsigned short debug = 0;
 static unsigned short vpi_bits = 0;
@@ -1386,7 +1385,7 @@
 
 static irqreturn_t interrupt_handler(int irq, void *dev_id,
 					struct pt_regs *pt_regs) {
-  hrz_dev * dev = hrz_devs;
+  hrz_dev * dev = (hrz_dev *) dev_id;
   u32 int_source;
   unsigned int irq_ok;
   (void) pt_regs;
@@ -1397,16 +1396,6 @@
     PRINTD (DBG_IRQ|DBG_ERR, "irq with NULL dev_id: %d", irq);
     return IRQ_NONE;
   }
-  // Did one of our cards generate the interrupt?
-  while (dev) {
-    if (dev == dev_id)
-      break;
-    dev = dev->prev;
-  }
-  if (!dev) {
-    PRINTD (DBG_IRQ, "irq not for me: %d", irq);
-    return IRQ_NONE;
-  }
   if (irq != dev->irq) {
     PRINTD (DBG_IRQ|DBG_ERR, "irq mismatch: %d", irq);
     return IRQ_NONE;
@@ -1462,28 +1451,18 @@
 
 /********** housekeeping **********/
 
-static void set_timer (struct timer_list * timer, unsigned int delay) {
-  timer->expires = jiffies + delay;
-  add_timer (timer);
-  return;
-}
-
 static void do_housekeeping (unsigned long arg) {
   // just stats at the moment
-  hrz_dev * dev = hrz_devs;
-  (void) arg;
-  // data is set to zero at module unload
-  if (housekeeping.data) {
-    while (dev) {
-      // collect device-specific (not driver/atm-linux) stats here
-      dev->tx_cell_count += rd_regw (dev, TX_CELL_COUNT_OFF);
-      dev->rx_cell_count += rd_regw (dev, RX_CELL_COUNT_OFF);
-      dev->hec_error_count += rd_regw (dev, HEC_ERROR_COUNT_OFF);
-      dev->unassigned_cell_count += rd_regw (dev, UNASSIGNED_CELL_COUNT_OFF);
-      dev = dev->prev;
-    }
-    set_timer (&housekeeping, HZ/10);
-  }
+  hrz_dev * dev = (hrz_dev *) arg;
+
+  // collect device-specific (not driver/atm-linux) stats here
+  dev->tx_cell_count += rd_regw (dev, TX_CELL_COUNT_OFF);
+  dev->rx_cell_count += rd_regw (dev, RX_CELL_COUNT_OFF);
+  dev->hec_error_count += rd_regw (dev, HEC_ERROR_COUNT_OFF);
+  dev->unassigned_cell_count += rd_regw (dev, UNASSIGNED_CELL_COUNT_OFF);
+
+  mod_timer (&dev->housekeeping, jiffies + HZ/10);
+
   return;
 }
 
@@ -2719,157 +2698,176 @@
   .owner	= THIS_MODULE,
 };
 
-static int __init hrz_probe (void) {
-  struct pci_dev * pci_dev;
-  int devs;
-  
-  PRINTD (DBG_FLOW, "hrz_probe");
-  
-  devs = 0;
-  pci_dev = NULL;
-  while ((pci_dev = pci_find_device
-	  (PCI_VENDOR_ID_MADGE, PCI_DEVICE_ID_MADGE_HORIZON, pci_dev)
-	  )) {
-    hrz_dev * dev;
-    
-    // adapter slot free, read resources from PCI configuration space
-    u32 iobase = pci_resource_start (pci_dev, 0);
-    u32 * membase = bus_to_virt (pci_resource_start (pci_dev, 1));
-    u8 irq = pci_dev->irq;
-    
-    /* XXX DEV_LABEL is a guess */
-    if (!request_region (iobase, HRZ_IO_EXTENT, DEV_LABEL))
-  	  continue;
-
-    if (pci_enable_device (pci_dev))
-      continue;
-    
-    dev = kmalloc (sizeof(hrz_dev), GFP_KERNEL);
-    if (!dev) {
-      // perhaps we should be nice: deregister all adapters and abort?
-      PRINTD (DBG_ERR, "out of memory");
-      continue;
-    }
-    
-    memset (dev, 0, sizeof(hrz_dev));
-    
-    // grab IRQ and install handler - move this someplace more sensible
-    if (request_irq (irq,
-		     interrupt_handler,
-		     SA_SHIRQ, /* irqflags guess */
-		     DEV_LABEL, /* name guess */
-		     dev)) {
-      PRINTD (DBG_WARN, "request IRQ failed!");
-      // free_irq is at "endif"
-    } else {
-      
-      PRINTD (DBG_INFO, "found Madge ATM adapter (hrz) at: IO %x, IRQ %u, MEM %p",
-	      iobase, irq, membase);
-      
-      dev->atm_dev = atm_dev_register (DEV_LABEL, &hrz_ops, -1, NULL);
-      if (!(dev->atm_dev)) {
-	PRINTD (DBG_ERR, "failed to register Madge ATM adapter");
-      } else {
+static int __devinit hrz_probe(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
+{
+	hrz_dev * dev;
+	int err = 0;
+
+	// adapter slot free, read resources from PCI configuration space
+	u32 iobase = pci_resource_start (pci_dev, 0);
+	u32 * membase = bus_to_virt (pci_resource_start (pci_dev, 1));
+	u8 irq = pci_dev->irq;
 	unsigned char lat;
-	
-	PRINTD (DBG_INFO, "registered Madge ATM adapter (no. %d) (%p) at %p",
-		dev->atm_dev->number, dev, dev->atm_dev);
+
+	PRINTD (DBG_FLOW, "hrz_probe");
+
+	/* XXX DEV_LABEL is a guess */
+	if (!request_region(iobase, HRZ_IO_EXTENT, DEV_LABEL))
+		return -EINVAL;
+
+	if (pci_enable_device(pci_dev)) {
+		err = -EINVAL;
+		goto out_release;
+	}
+
+	dev = kmalloc(sizeof(hrz_dev), GFP_KERNEL);
+	if (!dev) {
+		// perhaps we should be nice: deregister all adapters and abort?
+		PRINTD(DBG_ERR, "out of memory");
+		err = -ENOMEM;
+		goto out_disable;
+	}
+
+	memset(dev, 0, sizeof(hrz_dev));
+
+	pci_set_drvdata(pci_dev, dev);
+
+	// grab IRQ and install handler - move this someplace more sensible
+	if (request_irq(irq,
+			interrupt_handler,
+			SA_SHIRQ, /* irqflags guess */
+			DEV_LABEL, /* name guess */
+			dev)) {
+		PRINTD(DBG_WARN, "request IRQ failed!");
+		err = -EINVAL;
+		goto out_free;
+	}
+
+	PRINTD(DBG_INFO, "found Madge ATM adapter (hrz) at: IO %x, IRQ %u, MEM %p",
+	       iobase, irq, membase);
+
+	dev->atm_dev = atm_dev_register(DEV_LABEL, &hrz_ops, -1, NULL);
+	if (!(dev->atm_dev)) {
+		PRINTD(DBG_ERR, "failed to register Madge ATM adapter");
+		err = -EINVAL;
+		goto out_free_irq;
+	}
+
+	PRINTD(DBG_INFO, "registered Madge ATM adapter (no. %d) (%p) at %p",
+	       dev->atm_dev->number, dev, dev->atm_dev);
 	dev->atm_dev->dev_data = (void *) dev;
 	dev->pci_dev = pci_dev; 
-	
+
 	// enable bus master accesses
-	pci_set_master (pci_dev);
-	
+	pci_set_master(pci_dev);
+
 	// frobnicate latency (upwards, usually)
-	pci_read_config_byte (pci_dev, PCI_LATENCY_TIMER, &lat);
+	pci_read_config_byte(pci_dev, PCI_LATENCY_TIMER, &lat);
 	if (pci_lat) {
-	  PRINTD (DBG_INFO, "%s PCI latency timer from %hu to %hu",
-		  "changing", lat, pci_lat);
-	  pci_write_config_byte (pci_dev, PCI_LATENCY_TIMER, pci_lat);
+		PRINTD(DBG_INFO, "%s PCI latency timer from %hu to %hu",
+		       "changing", lat, pci_lat);
+		pci_write_config_byte(pci_dev, PCI_LATENCY_TIMER, pci_lat);
 	} else if (lat < MIN_PCI_LATENCY) {
-	  PRINTK (KERN_INFO, "%s PCI latency timer from %hu to %hu",
-		  "increasing", lat, MIN_PCI_LATENCY);
-	  pci_write_config_byte (pci_dev, PCI_LATENCY_TIMER, MIN_PCI_LATENCY);
+		PRINTK(KERN_INFO, "%s PCI latency timer from %hu to %hu",
+		       "increasing", lat, MIN_PCI_LATENCY);
+		pci_write_config_byte(pci_dev, PCI_LATENCY_TIMER, MIN_PCI_LATENCY);
 	}
-	
+
 	dev->iobase = iobase;
 	dev->irq = irq; 
 	dev->membase = membase; 
-	
+
 	dev->rx_q_entry = dev->rx_q_reset = &memmap->rx_q_entries[0];
 	dev->rx_q_wrap  = &memmap->rx_q_entries[RX_CHANS-1];
-	
+
 	// these next three are performance hacks
 	dev->last_vc = -1;
 	dev->tx_last = -1;
 	dev->tx_idle = 0;
-	
+
 	dev->tx_regions = 0;
 	dev->tx_bytes = 0;
 	dev->tx_skb = NULL;
 	dev->tx_iovec = NULL;
-	
+
 	dev->tx_cell_count = 0;
 	dev->rx_cell_count = 0;
 	dev->hec_error_count = 0;
 	dev->unassigned_cell_count = 0;
-	
+
 	dev->noof_spare_buffers = 0;
-	
+
 	{
-	  unsigned int i;
-	  for (i = 0; i < TX_CHANS; ++i)
-	    dev->tx_channel_record[i] = -1;
+		unsigned int i;
+		for (i = 0; i < TX_CHANS; ++i)
+			dev->tx_channel_record[i] = -1;
 	}
-	
+
 	dev->flags = 0;
-	
+
 	// Allocate cell rates and remember ASIC version
 	// Fibre: ATM_OC3_PCR = 1555200000/8/270*260/53 - 29/53
 	// Copper: (WRONG) we want 6 into the above, close to 25Mb/s
 	// Copper: (plagarise!) 25600000/8/270*260/53 - n/53
-	
-	if (hrz_init (dev)) {
-	  // to be really pedantic, this should be ATM_OC3c_PCR
-	  dev->tx_avail = ATM_OC3_PCR;
-	  dev->rx_avail = ATM_OC3_PCR;
-	  set_bit (ultra, &dev->flags); // NOT "|= ultra" !
+
+	if (hrz_init(dev)) {
+		// to be really pedantic, this should be ATM_OC3c_PCR
+		dev->tx_avail = ATM_OC3_PCR;
+		dev->rx_avail = ATM_OC3_PCR;
+		set_bit(ultra, &dev->flags); // NOT "|= ultra" !
 	} else {
-	  dev->tx_avail = ((25600000/8)*26)/(27*53);
-	  dev->rx_avail = ((25600000/8)*26)/(27*53);
-	  PRINTD (DBG_WARN, "Buggy ASIC: no TX bus-mastering.");
+		dev->tx_avail = ((25600000/8)*26)/(27*53);
+		dev->rx_avail = ((25600000/8)*26)/(27*53);
+		PRINTD(DBG_WARN, "Buggy ASIC: no TX bus-mastering.");
 	}
-	
+
 	// rate changes spinlock
-	spin_lock_init (&dev->rate_lock);
-	
+	spin_lock_init(&dev->rate_lock);
+
 	// on-board memory access spinlock; we want atomic reads and
 	// writes to adapter memory (handles IRQ and SMP)
-	spin_lock_init (&dev->mem_lock);
-	
-	init_waitqueue_head (&dev->tx_queue);
-	
+	spin_lock_init(&dev->mem_lock);
+
+	init_waitqueue_head(&dev->tx_queue);
+
 	// vpi in 0..4, vci in 6..10
 	dev->atm_dev->ci_range.vpi_bits = vpi_bits;
 	dev->atm_dev->ci_range.vci_bits = 10-vpi_bits;
-	
-	// update count and linked list
-	++devs;
-	dev->prev = hrz_devs;
-	hrz_devs = dev;
-	// success
-	continue;
-	
-	/* not currently reached */
-	atm_dev_deregister (dev->atm_dev);
-      } /* atm_dev_register */
-      free_irq (irq, dev);
-	
-    } /* request_irq */
-    kfree (dev);
-    release_region(iobase, HRZ_IO_EXTENT);
-  } /* kmalloc and while */
-  return devs;
+
+	init_timer(&dev->housekeeping);
+	dev->housekeeping.function = do_housekeeping;
+	dev->housekeeping.data = (unsigned long) dev;
+	mod_timer(&dev->housekeeping, jiffies);
+
+out:
+	return err;
+
+out_free_irq:
+	free_irq(dev->irq, dev);
+out_free:
+	kfree(dev);
+out_disable:
+	pci_disable_device(pci_dev);
+out_release:
+	release_region(iobase, HRZ_IO_EXTENT);
+	goto out;
+}
+
+static void __devexit hrz_remove_one(struct pci_dev *pci_dev)
+{
+	hrz_dev *dev;
+
+	dev = pci_get_drvdata(pci_dev);
+
+	PRINTD(DBG_INFO, "closing %p (atm_dev = %p)", dev, dev->atm_dev);
+	del_timer_sync(&dev->housekeeping);
+	hrz_reset(dev);
+	atm_dev_deregister(dev->atm_dev);
+	free_irq(dev->irq, dev);
+	release_region(dev->iobase, HRZ_IO_EXTENT);
+	kfree(dev);
+
+	pci_disable_device(pci_dev);
 }
 
 static void __init hrz_check_args (void) {
@@ -2909,11 +2907,22 @@
 MODULE_PARM_DESC(max_rx_size, "maximum size of RX AAL5 frames");
 MODULE_PARM_DESC(pci_lat, "PCI latency in bus cycles");
 
+static struct pci_device_id hrz_pci_tbl[] = {
+	{ PCI_VENDOR_ID_MADGE, PCI_DEVICE_ID_MADGE_HORIZON, PCI_ANY_ID, PCI_ANY_ID,
+	  0, 0, 0 },
+	{ 0, }
+};
+
+static struct pci_driver hrz_driver = {
+	.name =		"horizon",
+	.probe =	hrz_probe,
+	.remove =	__devexit_p(hrz_remove_one),
+	.id_table =	hrz_pci_tbl,
+};
+
 /********** module entry **********/
 
 static int __init hrz_module_init (void) {
-  int devs;
-  
   // sanity check - cast is needed since printk does not support %Zu
   if (sizeof(struct MEMMAP) != 128*1024/4) {
     PRINTK (KERN_ERR, "Fix struct MEMMAP (is %lu fakewords).",
@@ -2927,44 +2936,15 @@
   hrz_check_args();
   
   // get the juice
-  devs = hrz_probe();
-  
-  if (devs) {
-    init_timer (&housekeeping);
-    housekeeping.function = do_housekeeping;
-    // paranoia
-    housekeeping.data = 1;
-    set_timer (&housekeeping, 0);
-  } else {
-    PRINTK (KERN_ERR, "no (usable) adapters found");
-  }
-  
-  return devs ? 0 : -ENODEV;
+  return pci_module_init(&hrz_driver);
 }
 
 /********** module exit **********/
 
 static void __exit hrz_module_exit (void) {
-  hrz_dev * dev;
   PRINTD (DBG_FLOW, "cleanup_module");
   
-  // paranoia
-  housekeeping.data = 0;
-  del_timer (&housekeeping);
-  
-  while (hrz_devs) {
-    dev = hrz_devs;
-    hrz_devs = dev->prev;
-    
-    PRINTD (DBG_INFO, "closing %p (atm_dev = %p)", dev, dev->atm_dev);
-    hrz_reset (dev);
-    atm_dev_deregister (dev->atm_dev);
-    free_irq (dev->irq, dev);
-    release_region (dev->iobase, HRZ_IO_EXTENT);
-    kfree (dev);
-  }
-  
-  return;
+  return pci_unregister_driver(&hrz_driver);
 }
 
 module_init(hrz_module_init);
diff -Nru a/drivers/atm/horizon.h b/drivers/atm/horizon.h
--- a/drivers/atm/horizon.h	2004-10-22 08:02:29 -04:00
+++ b/drivers/atm/horizon.h	2004-10-22 08:02:29 -04:00
@@ -457,7 +457,7 @@
   unsigned long    unassigned_cell_count;
 
   struct pci_dev * pci_dev;
-  struct hrz_dev * prev;
+  struct timer_list housekeeping;
 };
 
 typedef struct hrz_dev hrz_dev;
