From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [zatm] eliminate pci_find_device() (from Francois Romieu <romieu@fr.zoreil.com>)
Date: Thu, 21 Oct 2004 07:28:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410211128.i9LBSt4W008894@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com, romieu@fr.zoreil.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6

thanks!

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/18 16:30:49-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [zatm] eliminate pci_find_device() (from Francois Romieu <romieu@fr.zoreil.com>)
# 
# drivers/atm/zatm.c
#   2004/10/18 16:30:32-04:00 chas@relax.cmf.nrl.navy.mil +65 -37
#   [ATM]: [zatm] eliminate pci_find_device() (from Francois Romieu <romieu@fr.zoreil.com>)
# 
diff -Nru a/drivers/atm/zatm.c b/drivers/atm/zatm.c
--- a/drivers/atm/zatm.c	2004-10-18 16:52:06 -04:00
+++ b/drivers/atm/zatm.c	2004-10-18 16:52:06 -04:00
@@ -46,6 +46,8 @@
  *  - OAM
  */
 
+#define ZATM_COPPER	1
+
 #if 0
 #define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
 #else
@@ -1577,51 +1579,77 @@
 	.change_qos	= zatm_change_qos,
 };
 
-static int __init zatm_module_init(void)
+static int __devinit zatm_init_one(struct pci_dev *pci_dev,
+				   const struct pci_device_id *ent)
 {
 	struct atm_dev *dev;
 	struct zatm_dev *zatm_dev;
-	int devs,type;
+	int ret = -ENOMEM;
 
-	zatm_dev = (struct zatm_dev *) kmalloc(sizeof(struct zatm_dev),
-	    GFP_KERNEL);
-	if (!zatm_dev) return -ENOMEM;
-	devs = 0;
-	for (type = 0; type < 2; type++) {
-		struct pci_dev *pci_dev;
-
-		pci_dev = NULL;
-		while ((pci_dev = pci_find_device(PCI_VENDOR_ID_ZEITNET,type ?
-		    PCI_DEVICE_ID_ZEITNET_1225 : PCI_DEVICE_ID_ZEITNET_1221,
-		    pci_dev))) {
-			if (pci_enable_device(pci_dev)) break;
-			dev = atm_dev_register(DEV_LABEL,&ops,-1,NULL);
-			if (!dev) break;
-			zatm_dev->pci_dev = pci_dev;
-			dev->dev_data = zatm_dev;
-			zatm_dev->copper = type;
-			if (zatm_init(dev) || zatm_start(dev)) {
-				atm_dev_deregister(dev);
-				break;
-			}
-			zatm_dev->more = zatm_boards;
-			zatm_boards = dev;
-			devs++;
-			zatm_dev = (struct zatm_dev *) kmalloc(sizeof(struct
-			    zatm_dev),GFP_KERNEL);
-			if (!zatm_dev) {
-				printk(KERN_EMERG "zatm.c: memory shortage\n");
-				goto out;
-			}
-		}
-	}
+	zatm_dev = (struct zatm_dev *) kmalloc(sizeof(*zatm_dev), GFP_KERNEL);
+	if (!zatm_dev) {
+		printk(KERN_EMERG "%s: memory shortage\n", DEV_LABEL);
+		goto out;
+	}
+
+	dev = atm_dev_register(DEV_LABEL, &ops, -1, NULL);
+	if (!dev)
+		goto out_free;
+
+	ret = pci_enable_device(pci_dev);
+	if (ret < 0)
+		goto out_deregister;
+
+	ret = pci_request_regions(pci_dev, DEV_LABEL);
+	if (ret < 0)
+		goto out_disable;
+
+	zatm_dev->pci_dev = pci_dev;
+	ZATM_DEV(dev) = zatm_dev;
+	zatm_dev->copper = (int)ent->driver_data;
+	if ((ret = zatm_init(dev)) || (ret = zatm_start(dev)))
+		goto out_release;
+
+	pci_set_drvdata(pci_dev, dev);
+	zatm_dev->more = zatm_boards;
+	zatm_boards = dev;
+	ret = 0;
 out:
-	kfree(zatm_dev);
+	return ret;
 
-	return 0;
+out_release:
+	pci_release_regions(pci_dev);
+out_disable:
+	pci_disable_device(pci_dev);
+out_deregister:
+	atm_dev_deregister(dev);
+out_free:
+	kfree(zatm_dev);
+	goto out;
 }
 
+
 MODULE_LICENSE("GPL");
 
-module_init(zatm_module_init);
+static struct pci_device_id zatm_pci_tbl[] __devinitdata = {
+	{ PCI_VENDOR_ID_ZEITNET, PCI_DEVICE_ID_ZEITNET_1221,
+		PCI_ANY_ID, PCI_ANY_ID, 0, 0, ZATM_COPPER },
+	{ PCI_VENDOR_ID_ZEITNET, PCI_DEVICE_ID_ZEITNET_1225,
+		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ 0, }
+};
+MODULE_DEVICE_TABLE(pci, zatm_pci_tbl);
+
+static struct pci_driver zatm_driver = {
+	.name =		DEV_LABEL,
+	.id_table =	zatm_pci_tbl,
+	.probe =	zatm_init_one,
+};
+
+static int __init zatm_init_module(void)
+{
+	return pci_module_init(&zatm_driver);
+}
+
+module_init(zatm_init_module);
 /* module_exit not defined so not unloadable */
