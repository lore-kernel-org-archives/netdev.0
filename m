From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 7/8 net-next] cnic: Decouple uio close from cnic
 shutdown
Date: Wed, 13 Oct 2010 17:06:50 -0700
Message-ID: <1287014811-10979-8-git-send-email-mchan@broadcom.com>
References: <1287014811-10979-1-git-send-email-mchan@broadcom.com>
 <1287014811-10979-2-git-send-email-mchan@broadcom.com>
 <1287014811-10979-3-git-send-email-mchan@broadcom.com>
 <1287014811-10979-4-git-send-email-mchan@broadcom.com>
 <1287014811-10979-5-git-send-email-mchan@broadcom.com>
 <1287014811-10979-6-git-send-email-mchan@broadcom.com>
 <1287014811-10979-7-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1647 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752974Ab0JNBEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 21:04:01 -0400
In-Reply-To: <1287014811-10979-7-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During cnic shutdown, the original driver code requires userspace to
close the uio device within a few seconds.  This doesn't always happen
as the userapp may be hung or otherwise take a long time to close.  The
system may crash when this happens.

We fix the problem by decoupling the uio structures from the cnic
structures during cnic shutdown.  We do not unregister the uio device
until the cnic driver is unloaded.  This eliminates the unreliable wait
loop for uio to close.

All uio structures are kept in a linked list.  If the device is shutdown
and later brought back up again, the uio strcture will be found in the
linked list and coupled back to the cnic structures.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   56 +++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 42 insertions(+), 14 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index e8f2836..3f923a7 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -60,6 +60,7 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(CNIC_MODULE_VERSION);
 
 static LIST_HEAD(cnic_dev_list);
+static LIST_HEAD(cnic_udev_list);
 static DEFINE_RWLOCK(cnic_dev_lock);
 static DEFINE_MUTEX(cnic_lock);
 
@@ -101,13 +102,14 @@ static int cnic_uio_open(struct uio_info *uinfo, struct inode *inode)
 	rtnl_lock();
 	dev = udev->dev;
 
-	if (!test_bit(CNIC_F_CNIC_UP, &dev->flags)) {
+	if (!dev || !test_bit(CNIC_F_CNIC_UP, &dev->flags)) {
 		rtnl_unlock();
 		return -ENODEV;
 	}
 
 	udev->uio_dev = iminor(inode);
 
+	cnic_shutdown_rings(dev);
 	cnic_init_rings(dev);
 	rtnl_unlock();
 
@@ -117,9 +119,6 @@ static int cnic_uio_open(struct uio_info *uinfo, struct inode *inode)
 static int cnic_uio_close(struct uio_info *uinfo, struct inode *inode)
 {
 	struct cnic_uio_dev *udev = uinfo->priv;
-	struct cnic_dev *dev = udev->dev;
-
-	cnic_shutdown_rings(dev);
 
 	udev->uio_dev = -1;
 	return 0;
@@ -787,6 +786,9 @@ static void __cnic_free_uio(struct cnic_uio_dev *udev)
 				  udev->l2_ring, udev->l2_ring_map);
 		udev->l2_ring = NULL;
 	}
+
+	pci_dev_put(udev->pdev);
+	kfree(udev);
 }
 
 static void cnic_free_uio(struct cnic_uio_dev *udev)
@@ -794,6 +796,9 @@ static void cnic_free_uio(struct cnic_uio_dev *udev)
 	if (!udev)
 		return;
 
+	write_lock(&cnic_dev_lock);
+	list_del_init(&udev->list);
+	write_unlock(&cnic_dev_lock);
 	__cnic_free_uio(udev);
 }
 
@@ -801,14 +806,9 @@ static void cnic_free_resc(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
 	struct cnic_uio_dev *udev = cp->udev;
-	int i = 0;
 
 	if (udev) {
-		while (udev->uio_dev != -1 && i < 15) {
-			msleep(100);
-			i++;
-		}
-		cnic_free_uio(udev);
+		udev->dev = NULL;
 		cp->udev = NULL;
 	}
 
@@ -916,6 +916,17 @@ static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
 	struct cnic_local *cp = dev->cnic_priv;
 	struct cnic_uio_dev *udev;
 
+	read_lock(&cnic_dev_lock);
+	list_for_each_entry(udev, &cnic_udev_list, list) {
+		if (udev->pdev == dev->pcidev) {
+			udev->dev = dev;
+			cp->udev = udev;
+			read_unlock(&cnic_dev_lock);
+			return 0;
+		}
+	}
+	read_unlock(&cnic_dev_lock);
+
 	udev = kzalloc(sizeof(struct cnic_uio_dev), GFP_ATOMIC);
 	if (!udev)
 		return -ENOMEM;
@@ -939,6 +950,12 @@ static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
 	if (!udev->l2_buf)
 		return -ENOMEM;
 
+	write_lock(&cnic_dev_lock);
+	list_add(&udev->list, &cnic_udev_list);
+	write_unlock(&cnic_dev_lock);
+
+	pci_dev_get(udev->pdev);
+
 	cp->udev = udev;
 
 	return 0;
@@ -954,8 +971,6 @@ static int cnic_init_uio(struct cnic_dev *dev)
 	if (!udev)
 		return -ENOMEM;
 
-	udev->uio_dev = -1;
-
 	uinfo = &udev->cnic_uinfo;
 
 	uinfo->mem[0].addr = dev->netdev->base_addr;
@@ -996,9 +1011,15 @@ static int cnic_init_uio(struct cnic_dev *dev)
 	uinfo->open = cnic_uio_open;
 	uinfo->release = cnic_uio_close;
 
-	uinfo->priv = udev;
+	if (udev->uio_dev == -1) {
+		if (!uinfo->priv) {
+			uinfo->priv = udev;
 
-	ret = uio_register_device(&udev->pdev->dev, uinfo);
+			ret = uio_register_device(&udev->pdev->dev, uinfo);
+		}
+	} else {
+		cnic_init_rings(dev);
+	}
 
 	return ret;
 }
@@ -4559,6 +4580,7 @@ static void cnic_stop_hw(struct cnic_dev *dev)
 			msleep(100);
 			i++;
 		}
+		cnic_shutdown_rings(dev);
 		clear_bit(CNIC_F_CNIC_UP, &dev->flags);
 		rcu_assign_pointer(cp->ulp_ops[CNIC_ULP_L4], NULL);
 		synchronize_rcu();
@@ -4834,6 +4856,7 @@ static struct notifier_block cnic_netdev_notifier = {
 static void cnic_release(void)
 {
 	struct cnic_dev *dev;
+	struct cnic_uio_dev *udev;
 
 	while (!list_empty(&cnic_dev_list)) {
 		dev = list_entry(cnic_dev_list.next, struct cnic_dev, list);
@@ -4847,6 +4870,11 @@ static void cnic_release(void)
 		list_del_init(&dev->list);
 		cnic_free_dev(dev);
 	}
+	while (!list_empty(&cnic_udev_list)) {
+		udev = list_entry(cnic_udev_list.next, struct cnic_uio_dev,
+				  list);
+		cnic_free_uio(udev);
+	}
 }
 
 static int __init cnic_init(void)
-- 
1.6.4.GIT


