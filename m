From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH] cxgb3 - convert to user struct device instead of class_device
Date: Thu, 08 Feb 2007 12:41:28 -0800
Message-ID: <adalkj8l6vb.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Divy Le Ray <divy@chelsio.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Steve Wise <swise@opengridcomputing.com>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:1627 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423325AbXBHUle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 15:41:34 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 43cb76d9 ("Network: convert network devices to use struct
device instead of class_device") breaks the just-merged cxgb3 driver,
since the code that was merged predates the change and was not in the
tree when Greg made the change.

This patch fixes cxgb3 to build with the change.  It also removes the
private to_net_dev() macro and changes the use of bare netdev->priv in
favor of netdev_priv(netdev) in the sysfs attribute functions.

I tested this on my system which has cxgb3 hardware, and it looks like
all the sysfs files are created correctly and contain sane-looking
values, although I don't actually know how to test that every
attribute is working as it should.

Signed-off-by: Roland Dreier <rolandd@cisco.com>

---

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index dfa035a..8d2fd21 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -74,8 +74,6 @@ enum {
 
 #define EEPROM_MAGIC 0x38E2F10C
 
-#define to_net_dev(class) container_of(class, struct net_device, class_dev)
-
 #define CH_DEVICE(devid, ssid, idx) \
 	{ PCI_VENDOR_ID_CHELSIO, devid, PCI_ANY_ID, ssid, 0, 0, idx }
 
@@ -434,11 +432,11 @@ static int setup_sge_qsets(struct adapter *adap)
 	return 0;
 }
 
-static ssize_t attr_show(struct class_device *cd, char *buf,
+static ssize_t attr_show(struct device *d, char *buf,
 			 ssize_t(*format) (struct adapter *, char *))
 {
 	ssize_t len;
-	struct adapter *adap = to_net_dev(cd)->priv;
+	struct adapter *adap = netdev_priv(to_net_dev(d));
 
 	/* Synchronize with ioctls that may shut down the device */
 	rtnl_lock();
@@ -447,14 +445,14 @@ static ssize_t attr_show(struct class_device *cd, char *buf,
 	return len;
 }
 
-static ssize_t attr_store(struct class_device *cd, const char *buf, size_t len,
+static ssize_t attr_store(struct device *d, const char *buf, size_t len,
 			  ssize_t(*set) (struct adapter *, unsigned int),
 			  unsigned int min_val, unsigned int max_val)
 {
 	char *endp;
 	ssize_t ret;
 	unsigned int val;
-	struct adapter *adap = to_net_dev(cd)->priv;
+	struct adapter *adap = netdev_priv(to_net_dev(d));
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -476,9 +474,10 @@ static ssize_t format_##name(struct adapter *adap, char *buf) \
 { \
 	return sprintf(buf, "%u\n", val_expr); \
 } \
-static ssize_t show_##name(struct class_device *cd, char *buf) \
+static ssize_t show_##name(struct device *d, struct device_attribute *attr, \
+			   char *buf)					\
 { \
-	return attr_show(cd, buf, format_##name); \
+	return attr_show(d, buf, format_##name); \
 }
 
 static ssize_t set_nfilters(struct adapter *adap, unsigned int val)
@@ -493,10 +492,10 @@ static ssize_t set_nfilters(struct adapter *adap, unsigned int val)
 	return 0;
 }
 
-static ssize_t store_nfilters(struct class_device *cd, const char *buf,
-			      size_t len)
+static ssize_t store_nfilters(struct device *d, struct device_attribute *attr,
+			      const char *buf, size_t len)
 {
-	return attr_store(cd, buf, len, set_nfilters, 0, ~0);
+	return attr_store(d, buf, len, set_nfilters, 0, ~0);
 }
 
 static ssize_t set_nservers(struct adapter *adap, unsigned int val)
@@ -509,38 +508,38 @@ static ssize_t set_nservers(struct adapter *adap, unsigned int val)
 	return 0;
 }
 
-static ssize_t store_nservers(struct class_device *cd, const char *buf,
-			      size_t len)
+static ssize_t store_nservers(struct device *d, struct device_attribute *attr,
+			      const char *buf, size_t len)
 {
-	return attr_store(cd, buf, len, set_nservers, 0, ~0);
+	return attr_store(d, buf, len, set_nservers, 0, ~0);
 }
 
 #define CXGB3_ATTR_R(name, val_expr) \
 CXGB3_SHOW(name, val_expr) \
-static CLASS_DEVICE_ATTR(name, S_IRUGO, show_##name, NULL)
+static DEVICE_ATTR(name, S_IRUGO, show_##name, NULL)
 
 #define CXGB3_ATTR_RW(name, val_expr, store_method) \
 CXGB3_SHOW(name, val_expr) \
-static CLASS_DEVICE_ATTR(name, S_IRUGO | S_IWUSR, show_##name, store_method)
+static DEVICE_ATTR(name, S_IRUGO | S_IWUSR, show_##name, store_method)
 
 CXGB3_ATTR_R(cam_size, t3_mc5_size(&adap->mc5));
 CXGB3_ATTR_RW(nfilters, adap->params.mc5.nfilters, store_nfilters);
 CXGB3_ATTR_RW(nservers, adap->params.mc5.nservers, store_nservers);
 
 static struct attribute *cxgb3_attrs[] = {
-	&class_device_attr_cam_size.attr,
-	&class_device_attr_nfilters.attr,
-	&class_device_attr_nservers.attr,
+	&dev_attr_cam_size.attr,
+	&dev_attr_nfilters.attr,
+	&dev_attr_nservers.attr,
 	NULL
 };
 
 static struct attribute_group cxgb3_attr_group = {.attrs = cxgb3_attrs };
 
-static ssize_t tm_attr_show(struct class_device *cd, char *buf, int sched)
+static ssize_t tm_attr_show(struct device *d, char *buf, int sched)
 {
 	ssize_t len;
 	unsigned int v, addr, bpt, cpt;
-	struct adapter *adap = to_net_dev(cd)->priv;
+	struct adapter *adap = netdev_priv(to_net_dev(d));
 
 	addr = A_TP_TX_MOD_Q1_Q0_RATE_LIMIT - sched / 2;
 	rtnl_lock();
@@ -560,13 +559,13 @@ static ssize_t tm_attr_show(struct class_device *cd, char *buf, int sched)
 	return len;
 }
 
-static ssize_t tm_attr_store(struct class_device *cd, const char *buf,
+static ssize_t tm_attr_store(struct device *d, const char *buf,
 			     size_t len, int sched)
 {
 	char *endp;
 	ssize_t ret;
 	unsigned int val;
-	struct adapter *adap = to_net_dev(cd)->priv;
+	struct adapter *adap = netdev_priv(to_net_dev(d));
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -584,15 +583,17 @@ static ssize_t tm_attr_store(struct class_device *cd, const char *buf,
 }
 
 #define TM_ATTR(name, sched) \
-static ssize_t show_##name(struct class_device *cd, char *buf) \
+static ssize_t show_##name(struct device *d, struct device_attribute *attr, \
+			   char *buf)					\
 { \
-	return tm_attr_show(cd, buf, sched); \
+	return tm_attr_show(d, buf, sched); \
 } \
-static ssize_t store_##name(struct class_device *cd, const char *buf, size_t len) \
+static ssize_t store_##name(struct device *d, struct device_attribute *attr, \
+			    const char *buf, size_t len)		\
 { \
-	return tm_attr_store(cd, buf, len, sched); \
+	return tm_attr_store(d, buf, len, sched); \
 } \
-static CLASS_DEVICE_ATTR(name, S_IRUGO | S_IWUSR, show_##name, store_##name)
+static DEVICE_ATTR(name, S_IRUGO | S_IWUSR, show_##name, store_##name)
 
 TM_ATTR(sched0, 0);
 TM_ATTR(sched1, 1);
@@ -604,14 +605,14 @@ TM_ATTR(sched6, 6);
 TM_ATTR(sched7, 7);
 
 static struct attribute *offload_attrs[] = {
-	&class_device_attr_sched0.attr,
-	&class_device_attr_sched1.attr,
-	&class_device_attr_sched2.attr,
-	&class_device_attr_sched3.attr,
-	&class_device_attr_sched4.attr,
-	&class_device_attr_sched5.attr,
-	&class_device_attr_sched6.attr,
-	&class_device_attr_sched7.attr,
+	&dev_attr_sched0.attr,
+	&dev_attr_sched1.attr,
+	&dev_attr_sched2.attr,
+	&dev_attr_sched3.attr,
+	&dev_attr_sched4.attr,
+	&dev_attr_sched5.attr,
+	&dev_attr_sched6.attr,
+	&dev_attr_sched7.attr,
 	NULL
 };
 
@@ -836,7 +837,7 @@ static int offload_open(struct net_device *dev)
 	init_smt(adapter);
 
 	/* Never mind if the next step fails */
-	sysfs_create_group(&tdev->lldev->class_dev.kobj, &offload_attr_group);
+	sysfs_create_group(&tdev->lldev->dev.kobj, &offload_attr_group);
 
 	/* Call back all registered clients */
 	cxgb3_add_clients(tdev);
@@ -861,7 +862,7 @@ static int offload_close(struct t3cdev *tdev)
 	/* Call back all registered clients */
 	cxgb3_remove_clients(tdev);
 
-	sysfs_remove_group(&tdev->lldev->class_dev.kobj, &offload_attr_group);
+	sysfs_remove_group(&tdev->lldev->dev.kobj, &offload_attr_group);
 
 	tdev->lldev = NULL;
 	cxgb3_set_dummy_ops(tdev);
@@ -2420,7 +2421,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 	else if (msi > 0 && pci_enable_msi(pdev) == 0)
 		adapter->flags |= USING_MSI;
 
-	err = sysfs_create_group(&adapter->port[0]->class_dev.kobj,
+	err = sysfs_create_group(&adapter->port[0]->dev.kobj,
 				 &cxgb3_attr_group);
 
 	print_port_info(adapter, ai);
@@ -2452,7 +2453,7 @@ static void __devexit remove_one(struct pci_dev *pdev)
 		struct adapter *adapter = dev->priv;
 
 		t3_sge_stop(adapter);
-		sysfs_remove_group(&adapter->port[0]->class_dev.kobj,
+		sysfs_remove_group(&adapter->port[0]->dev.kobj,
 				   &cxgb3_attr_group);
 
 		for_each_port(adapter, i)
