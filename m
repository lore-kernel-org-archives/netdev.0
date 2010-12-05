From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] atm: correct sysfs 'device' link creation and parent
 relationships
Date: Sun, 05 Dec 2010 16:17:59 -0600
Message-ID: <1291587480.17538.12.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Duncan Sands <duncan.sands-GANU6spQydw@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Chas Williams <chas-vT06rRrALxcmhCb6mdbn6A@public.gmane.org>,
	Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The ATM subsystem was incorrectly creating the 'device' link for ATM
nodes in sysfs.  This led to incorrect device/parent relationships
exposed by sysfs and udev.  Instead of rolling the 'device' link by hand
in the generic ATM code, pass each ATM driver's bus device down to the
sysfs code and let sysfs do this stuff correctly.

Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

---
Note: I preserved original formatting for style consistency instead of
fixing up checkpatch.pl errors for "space required before XXXX".

diff --git a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
index b910181..2b464b6 100644
--- a/drivers/atm/atmtcp.c
+++ b/drivers/atm/atmtcp.c
@@ -366,7 +366,7 @@ static int atmtcp_create(int itf,int persist,struct atm_dev **result)
 	if (!dev_data)
 		return -ENOMEM;
 
-	dev = atm_dev_register(DEV_LABEL,&atmtcp_v_dev_ops,itf,NULL);
+	dev = atm_dev_register(DEV_LABEL,NULL,&atmtcp_v_dev_ops,itf,NULL);
 	if (!dev) {
 		kfree(dev_data);
 		return itf == -1 ? -ENOMEM : -EBUSY;
diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 97c5898..c495fae 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -2244,7 +2244,7 @@ static int __devinit eni_init_one(struct pci_dev *pci_dev,
 		    &zeroes);
 		if (!cpu_zeroes) goto out1;
 	}
-	dev = atm_dev_register(DEV_LABEL,&ops,-1,NULL);
+	dev = atm_dev_register(DEV_LABEL, &pci_dev->dev, &ops, -1, NULL);
 	if (!dev) goto out2;
 	pci_set_drvdata(pci_dev, dev);
 	eni_dev->pci_dev = pci_dev;
diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index 5d86bb8..7d912ba 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -1911,7 +1911,7 @@ static int __devinit firestream_init_one (struct pci_dev *pci_dev,
 		    fs_dev, sizeof (struct fs_dev));
 	if (!fs_dev)
 		goto err_out;
-	atm_dev = atm_dev_register("fs", &ops, -1, NULL);
+	atm_dev = atm_dev_register("fs", &pci_dev->dev, &ops, -1, NULL);
 	if (!atm_dev)
 		goto err_out_free_fs_dev;
   
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 801e8b6..6cf59bf 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -366,7 +366,7 @@ he_init_one(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
 		goto init_one_failure;
 	}
 
-	atm_dev = atm_dev_register(DEV_LABEL, &he_ops, -1, NULL);
+	atm_dev = atm_dev_register(DEV_LABEL, &pci_dev->dev, &he_ops, -1, NULL);
 	if (!atm_dev) {
 		err = -ENODEV;
 		goto init_one_failure;
diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 2f3516b..af37a5f 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -771,7 +771,7 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
 	}
 
 	/* Register device */
-	card->atmdev = atm_dev_register("nicstar", &atm_ops, -1, NULL);
+	card->atmdev = atm_dev_register("nicstar", &card->pcidev->dev, &atm_ops, -1, NULL);
 	if (card->atmdev == NULL) {
 		printk("nicstar%d: can't register device.\n", i);
 		error = 17;
diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 2e08c99..73fb1c4 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -166,7 +166,7 @@ static irqreturn_t solos_irq(int irq, void *dev_id);
 static struct atm_vcc* find_vcc(struct atm_dev *dev, short vpi, int vci);
 static int list_vccs(int vci);
 static void release_vccs(struct atm_dev *dev);
-static int atm_init(struct solos_card *);
+static int atm_init(struct solos_card *, struct device *);
 static void atm_remove(struct solos_card *);
 static int send_command(struct solos_card *card, int dev, const char *buf, size_t size);
 static void solos_bh(unsigned long);
@@ -1210,7 +1210,7 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	if (db_firmware_upgrade)
 		flash_upgrade(card, 3);
 
-	err = atm_init(card);
+	err = atm_init(card, &dev->dev);
 	if (err)
 		goto out_free_irq;
 
@@ -1233,7 +1233,7 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	return err;
 }
 
-static int atm_init(struct solos_card *card)
+static int atm_init(struct solos_card *card, struct device *parent)
 {
 	int i;
 
@@ -1244,7 +1244,7 @@ static int atm_init(struct solos_card *card)
 		skb_queue_head_init(&card->tx_queue[i]);
 		skb_queue_head_init(&card->cli_queue[i]);
 
-		card->atmdev[i] = atm_dev_register("solos-pci", &fpga_ops, -1, NULL);
+		card->atmdev[i] = atm_dev_register("solos-pci", parent, &fpga_ops, -1, NULL);
 		if (!card->atmdev[i]) {
 			dev_err(&card->dev->dev, "Could not register ATM device %d\n", i);
 			atm_remove(card);
diff --git a/drivers/usb/atm/usbatm.c b/drivers/usb/atm/usbatm.c
index 05bf5a2..989e16e 100644
--- a/drivers/usb/atm/usbatm.c
+++ b/drivers/usb/atm/usbatm.c
@@ -951,7 +951,9 @@ static int usbatm_atm_init(struct usbatm_data *instance)
 	 * condition: callbacks we register can be executed at once, before we have
 	 * initialized the struct atm_dev.  To protect against this, all callbacks
 	 * abort if atm_dev->dev_data is NULL. */
-	atm_dev = atm_dev_register(instance->driver_name, &usbatm_atm_devops, -1, NULL);
+	atm_dev = atm_dev_register(instance->driver_name,
+				   &instance->usb_intf->dev, &usbatm_atm_devops,
+				   -1, NULL);
 	if (!atm_dev) {
 		usb_err(instance, "%s: failed to register ATM device!\n", __func__);
 		return -1;
@@ -966,14 +968,6 @@ static int usbatm_atm_init(struct usbatm_data *instance)
 	/* temp init ATM device, set to 128kbit */
 	atm_dev->link_rate = 128 * 1000 / 424;
 
-	ret = sysfs_create_link(&atm_dev->class_dev.kobj,
-				&instance->usb_intf->dev.kobj, "device");
-	if (ret) {
-		atm_err(instance, "%s: sysfs_create_link failed: %d\n",
-					__func__, ret);
-		goto fail_sysfs;
-	}
-
 	if (instance->driver->atm_start && ((ret = instance->driver->atm_start(instance, atm_dev)) < 0)) {
 		atm_err(instance, "%s: atm_start failed: %d!\n", __func__, ret);
 		goto fail;
@@ -992,8 +986,6 @@ static int usbatm_atm_init(struct usbatm_data *instance)
 	return 0;
 
  fail:
-	sysfs_remove_link(&atm_dev->class_dev.kobj, "device");
- fail_sysfs:
 	instance->atm_dev = NULL;
 	atm_dev_deregister(atm_dev); /* usbatm_atm_dev_close will eventually be called */
 	return ret;
@@ -1329,7 +1321,6 @@ void usbatm_usb_disconnect(struct usb_interface *intf)
 
 	/* ATM finalize */
 	if (instance->atm_dev) {
-		sysfs_remove_link(&instance->atm_dev->class_dev.kobj, "device");
 		atm_dev_deregister(instance->atm_dev);
 		instance->atm_dev = NULL;
 	}
diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index a8e4e83..475f8c4 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -427,8 +427,10 @@ extern rwlock_t vcc_sklist_lock;
 
 #define ATM_SKB(skb) (((struct atm_skb_data *) (skb)->cb))
 
-struct atm_dev *atm_dev_register(const char *type,const struct atmdev_ops *ops,
-    int number,unsigned long *flags); /* number == -1: pick first available */
+struct atm_dev *atm_dev_register(const char *type, struct device *parent,
+				 const struct atmdev_ops *ops,
+				 int number, /* -1 == pick first available */
+				 unsigned long *flags);
 struct atm_dev *atm_dev_lookup(int number);
 void atm_dev_deregister(struct atm_dev *dev);
 
diff --git a/net/atm/atm_sysfs.c b/net/atm/atm_sysfs.c
index 799c631..f7fa67c 100644
--- a/net/atm/atm_sysfs.c
+++ b/net/atm/atm_sysfs.c
@@ -143,12 +143,13 @@ static struct class atm_class = {
 	.dev_uevent		= atm_uevent,
 };
 
-int atm_register_sysfs(struct atm_dev *adev)
+int atm_register_sysfs(struct atm_dev *adev, struct device *parent)
 {
 	struct device *cdev = &adev->class_dev;
 	int i, j, err;
 
 	cdev->class = &atm_class;
+	cdev->parent = parent;
 	dev_set_drvdata(cdev, adev);
 
 	dev_set_name(cdev, "%s%d", adev->type, adev->number);
diff --git a/net/atm/resources.c b/net/atm/resources.c
index d29e582..23f45ce 100644
--- a/net/atm/resources.c
+++ b/net/atm/resources.c
@@ -74,8 +74,9 @@ struct atm_dev *atm_dev_lookup(int number)
 }
 EXPORT_SYMBOL(atm_dev_lookup);
 
-struct atm_dev *atm_dev_register(const char *type, const struct atmdev_ops *ops,
-				 int number, unsigned long *flags)
+struct atm_dev *atm_dev_register(const char *type, struct device *parent,
+				 const struct atmdev_ops *ops, int number,
+				 unsigned long *flags)
 {
 	struct atm_dev *dev, *inuse;
 
@@ -115,7 +116,7 @@ struct atm_dev *atm_dev_register(const char *type, const struct atmdev_ops *ops,
 		goto out_fail;
 	}
 
-	if (atm_register_sysfs(dev) < 0) {
+	if (atm_register_sysfs(dev, parent) < 0) {
 		pr_err("atm_register_sysfs failed for dev %s\n", type);
 		atm_proc_dev_deregister(dev);
 		goto out_fail;
diff --git a/net/atm/resources.h b/net/atm/resources.h
index 126fb18..521431e 100644
--- a/net/atm/resources.h
+++ b/net/atm/resources.h
@@ -42,6 +42,6 @@ static inline void atm_proc_dev_deregister(struct atm_dev *dev)
 
 #endif /* CONFIG_PROC_FS */
 
-int atm_register_sysfs(struct atm_dev *adev);
+int atm_register_sysfs(struct atm_dev *adev, struct device *parent);
 void atm_unregister_sysfs(struct atm_dev *adev);
 #endif


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
