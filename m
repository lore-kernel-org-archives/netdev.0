From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][1 of 7][ATM]: [drivers] pci_enable_device() before finding irq
Date: Tue, 18 Jan 2005 14:02:49 -0500
Message-ID: <200501181902.j0IJ2nif022216@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6.

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/06 13:13:50-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [drivers] pci_enable_device() before finding irq
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/horizon.c
#   2005/01/06 13:13:32-05:00 chas@relax.cmf.nrl.navy.mil +10 -9
#   [ATM]: [drivers] pci_enable_device() before finding irq
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/ambassador.c
#   2005/01/06 13:13:32-05:00 chas@relax.cmf.nrl.navy.mil +15 -17
#   [ATM]: [drivers] pci_enable_device() before finding irq
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
--- a/drivers/atm/ambassador.c	2005-01-14 08:42:14 -05:00
+++ b/drivers/atm/ambassador.c	2005-01-14 08:42:14 -05:00
@@ -2228,17 +2228,12 @@
 	spin_lock_init (&dev->rxq[pool].lock);
 }
 
-static int setup_pci_dev(struct pci_dev *pci_dev)
+static void setup_pci_dev(struct pci_dev *pci_dev)
 {
 	unsigned char lat;
-	int ret;
       
 	// enable bus master accesses
 	pci_set_master(pci_dev);
-      
-	ret = pci_enable_device(pci_dev);
-	if (ret < 0)
-		goto out;
 
 	// frobnicate latency (upwards, usually)
 	pci_read_config_byte (pci_dev, PCI_LATENCY_TIMER, &lat);
@@ -2251,22 +2246,27 @@
 			lat, pci_lat);
 		pci_write_config_byte(pci_dev, PCI_LATENCY_TIMER, pci_lat);
 	}
-out:
-	return ret;
 }
 
 static int __devinit amb_probe(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
 {
 	amb_dev * dev;
 	int err;
+	unsigned int irq;
+      
+	err = pci_enable_device(pci_dev);
+	if (err < 0) {
+		PRINTK (KERN_ERR, "skipped broken (PLX rev 2) card");
+		goto out;
+	}
 
 	// read resources from PCI configuration space
-	unsigned int irq = pci_dev->irq;
+	irq = pci_dev->irq;
 
 	if (pci_dev->device == PCI_DEVICE_ID_MADGE_AMBASSADOR_BAD) {
 		PRINTK (KERN_ERR, "skipped broken (PLX rev 2) card");
 		err = -EINVAL;
-		goto out;
+		goto out_disable;
 	}
 
 	PRINTD (DBG_INFO, "found Madge ATM adapter (amb) at"
@@ -2277,7 +2277,7 @@
 	err = pci_request_region(pci_dev, 1, DEV_LABEL);
 	if (err < 0) {
 		PRINTK (KERN_ERR, "IO range already in use!");
-		goto out;
+		goto out_disable;
 	}
 
 	dev = kmalloc (sizeof(amb_dev), GFP_KERNEL);
@@ -2295,15 +2295,13 @@
 		goto out_free;
 	}
 
-	err = setup_pci_dev(pci_dev);
-	if (err < 0)
-		goto out_reset;
+	setup_pci_dev(pci_dev);
 
 	// grab (but share) IRQ and install handler
 	err = request_irq(irq, interrupt_handler, SA_SHIRQ, DEV_LABEL, dev);
 	if (err < 0) {
 		PRINTK (KERN_ERR, "request IRQ failed!");
-		goto out_disable;
+		goto out_reset;
 	}
 
 	dev->atm_dev = atm_dev_register (DEV_LABEL, &amb_ops, -1, NULL);
@@ -2337,14 +2335,14 @@
 
 out_free_irq:
 	free_irq(irq, dev);
-out_disable:
-	pci_disable_device(pci_dev);
 out_reset:
 	amb_reset(dev, 0);
 out_free:
 	kfree(dev);
 out_release:
 	pci_release_region(pci_dev, 1);
+out_disable:
+	pci_disable_device(pci_dev);
 	goto out;
 }
 
diff -Nru a/drivers/atm/horizon.c b/drivers/atm/horizon.c
--- a/drivers/atm/horizon.c	2005-01-14 08:42:14 -05:00
+++ b/drivers/atm/horizon.c	2005-01-14 08:42:14 -05:00
@@ -2706,18 +2706,18 @@
 	// adapter slot free, read resources from PCI configuration space
 	u32 iobase = pci_resource_start (pci_dev, 0);
 	u32 * membase = bus_to_virt (pci_resource_start (pci_dev, 1));
-	u8 irq = pci_dev->irq;
+	unsigned int irq;
 	unsigned char lat;
 
 	PRINTD (DBG_FLOW, "hrz_probe");
 
-	/* XXX DEV_LABEL is a guess */
-	if (!request_region(iobase, HRZ_IO_EXTENT, DEV_LABEL))
+	if (pci_enable_device(pci_dev))
 		return -EINVAL;
 
-	if (pci_enable_device(pci_dev)) {
-		err = -EINVAL;
-		goto out_release;
+	/* XXX DEV_LABEL is a guess */
+	if (!request_region(iobase, HRZ_IO_EXTENT, DEV_LABEL)) {
+		return -EINVAL;
+		goto out_disable;
 	}
 
 	dev = kmalloc(sizeof(hrz_dev), GFP_KERNEL);
@@ -2725,7 +2725,7 @@
 		// perhaps we should be nice: deregister all adapters and abort?
 		PRINTD(DBG_ERR, "out of memory");
 		err = -ENOMEM;
-		goto out_disable;
+		goto out_release;
 	}
 
 	memset(dev, 0, sizeof(hrz_dev));
@@ -2733,6 +2733,7 @@
 	pci_set_drvdata(pci_dev, dev);
 
 	// grab IRQ and install handler - move this someplace more sensible
+	irq = pci_dev->irq;
 	if (request_irq(irq,
 			interrupt_handler,
 			SA_SHIRQ, /* irqflags guess */
@@ -2846,10 +2847,10 @@
 	free_irq(dev->irq, dev);
 out_free:
 	kfree(dev);
-out_disable:
-	pci_disable_device(pci_dev);
 out_release:
 	release_region(iobase, HRZ_IO_EXTENT);
+out_disable:
+	pci_disable_device(pci_dev);
 	goto out;
 }
 
