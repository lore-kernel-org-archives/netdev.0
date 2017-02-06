From: Sainath Grandhi <sainath.grandhi@intel.com>
Subject: [PATCHv4 5/7] tap: Extending tap device create/destroy APIs
Date: Mon,  6 Feb 2017 13:36:13 -0800
Message-ID: <1486416975-14133-6-git-send-email-sainath.grandhi@intel.com>
References: <1486416975-14133-1-git-send-email-sainath.grandhi@intel.com>
Cc: davem@davemloft.net, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org, sainath.grandhi@intel.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486416975-14133-1-git-send-email-sainath.grandhi@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Extending tap APIs get/free_minor and create/destroy_cdev to handle more than one
type of virtual interface.

Signed-off-by: Sainath Grandhi <sainath.grandhi@intel.com>
---
 drivers/net/macvtap_main.c |   6 +--
 drivers/net/tap.c          | 101 +++++++++++++++++++++++++++++++++++----------
 include/linux/if_tap.h     |   4 +-
 3 files changed, 85 insertions(+), 26 deletions(-)

diff --git a/drivers/net/macvtap_main.c b/drivers/net/macvtap_main.c
index 0238df6..a4bfc10 100644
--- a/drivers/net/macvtap_main.c
+++ b/drivers/net/macvtap_main.c
@@ -163,7 +163,7 @@ static int macvtap_device_event(struct notifier_block *unused,
 		 * been registered but before register_netdevice has
 		 * finished running.
 		 */
-		err = tap_get_minor(&vlantap->tap);
+		err = tap_get_minor(macvtap_major, &vlantap->tap);
 		if (err)
 			return notifier_from_errno(err);
 
@@ -171,7 +171,7 @@ static int macvtap_device_event(struct notifier_block *unused,
 		classdev = device_create(&macvtap_class, &dev->dev, devt,
 					 dev, tap_name);
 		if (IS_ERR(classdev)) {
-			tap_free_minor(&vlantap->tap);
+			tap_free_minor(macvtap_major, &vlantap->tap);
 			return notifier_from_errno(PTR_ERR(classdev));
 		}
 		err = sysfs_create_link(&dev->dev.kobj, &classdev->kobj,
@@ -186,7 +186,7 @@ static int macvtap_device_event(struct notifier_block *unused,
 		sysfs_remove_link(&dev->dev.kobj, tap_name);
 		devt = MKDEV(MAJOR(macvtap_major), vlantap->tap.minor);
 		device_destroy(&macvtap_class, devt);
-		tap_free_minor(&vlantap->tap);
+		tap_free_minor(macvtap_major, &vlantap->tap);
 		break;
 	case NETDEV_CHANGE_TX_QUEUE_LEN:
 		if (tap_queue_resize(&vlantap->tap))
diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index 5d9c534..427a113 100644
--- a/drivers/net/tap.c
+++ b/drivers/net/tap.c
@@ -99,12 +99,17 @@ static struct proto tap_proto = {
 };
 
 #define TAP_NUM_DEVS (1U << MINORBITS)
+
+static LIST_HEAD(major_list);
+
 struct major_info {
+	struct rcu_head rcu;
 	dev_t major;
 	struct idr minor_idr;
 	struct mutex minor_lock;
 	const char *device_name;
-} macvtap_major;
+	struct list_head next;
+};
 
 #define GOODCOPY_LEN 128
 
@@ -385,44 +390,72 @@ rx_handler_result_t tap_handle_frame(struct sk_buff **pskb)
 	return RX_HANDLER_CONSUMED;
 }
 
-int tap_get_minor(struct tap_dev *tap)
+static struct major_info *tap_get_major(int major)
+{
+	struct major_info *tap_major;
+
+	list_for_each_entry_rcu(tap_major, &major_list, next) {
+		if (tap_major->major == major)
+			return tap_major;
+	}
+
+	return NULL;
+}
+
+int tap_get_minor(dev_t major, struct tap_dev *tap)
 {
 	int retval = -ENOMEM;
+	struct major_info *tap_major;
 
-	mutex_lock(&macvtap_major.minor_lock);
-	retval = idr_alloc(&macvtap_major.minor_idr, tap, 1, TAP_NUM_DEVS, GFP_KERNEL);
+	tap_major = tap_get_major(MAJOR(major));
+	if (!tap_major)
+		return -EINVAL;
+
+	mutex_lock(&tap_major->minor_lock);
+	retval = idr_alloc(&tap_major->minor_idr, tap, 1, TAP_NUM_DEVS, GFP_KERNEL);
 	if (retval >= 0) {
 		tap->minor = retval;
 	} else if (retval == -ENOSPC) {
 		netdev_err(tap->dev, "Too many tap devices\n");
 		retval = -EINVAL;
 	}
-	mutex_unlock(&macvtap_major.minor_lock);
+	mutex_unlock(&tap_major->minor_lock);
 	return retval < 0 ? retval : 0;
 }
 
-void tap_free_minor(struct tap_dev *tap)
+void tap_free_minor(dev_t major, struct tap_dev *tap)
 {
-	mutex_lock(&macvtap_major.minor_lock);
+	struct major_info *tap_major;
+
+	tap_major = tap_get_major(MAJOR(major));
+	if (!tap_major)
+		return;
+
+	mutex_lock(&tap_major->minor_lock);
 	if (tap->minor) {
-		idr_remove(&macvtap_major.minor_idr, tap->minor);
+		idr_remove(&tap_major->minor_idr, tap->minor);
 		tap->minor = 0;
 	}
-	mutex_unlock(&macvtap_major.minor_lock);
+	mutex_unlock(&tap_major->minor_lock);
 }
 
-static struct tap_dev *dev_get_by_tap_minor(int minor)
+static struct tap_dev *dev_get_by_tap_file(int major, int minor)
 {
 	struct net_device *dev = NULL;
 	struct tap_dev *tap;
+	struct major_info *tap_major;
+
+	tap_major = tap_get_major(major);
+	if (!tap_major)
+		return NULL;
 
-	mutex_lock(&macvtap_major.minor_lock);
-	tap = idr_find(&macvtap_major.minor_idr, minor);
+	mutex_lock(&tap_major->minor_lock);
+	tap = idr_find(&tap_major->minor_idr, minor);
 	if (tap) {
 		dev = tap->dev;
 		dev_hold(dev);
 	}
-	mutex_unlock(&macvtap_major.minor_lock);
+	mutex_unlock(&tap_major->minor_lock);
 	return tap;
 }
 
@@ -454,7 +487,7 @@ static int tap_open(struct inode *inode, struct file *file)
 	int err = -ENODEV;
 
 	rtnl_lock();
-	tap = dev_get_by_tap_minor(iminor(inode));
+	tap = dev_get_by_tap_file(imajor(inode), iminor(inode));
 	if (!tap)
 		goto err;
 
@@ -1161,6 +1194,25 @@ int tap_queue_resize(struct tap_dev *tap)
 	return ret;
 }
 
+static int tap_list_add(dev_t major, const char *device_name)
+{
+	struct major_info *tap_major;
+
+	tap_major = kzalloc(sizeof(*tap_major), GFP_ATOMIC);
+	if (!tap_major)
+		return -ENOMEM;
+
+	tap_major->major = MAJOR(major);
+
+	idr_init(&tap_major->minor_idr);
+	mutex_init(&tap_major->minor_lock);
+
+	tap_major->device_name = device_name;
+
+	list_add_tail_rcu(&tap_major->next, &major_list);
+	return 0;
+}
+
 int tap_create_cdev(struct cdev *tap_cdev,
 		    dev_t *tap_major, const char *device_name)
 {
@@ -1175,15 +1227,14 @@ int tap_create_cdev(struct cdev *tap_cdev,
 	if (err)
 		goto out2;
 
-	macvtap_major.major = MAJOR(*tap_major);
-
-	idr_init(&macvtap_major.minor_idr);
-	mutex_init(&macvtap_major.minor_lock);
-
-	macvtap_major.device_name = device_name;
+	err =  tap_list_add(*tap_major, device_name);
+	if (err)
+		goto out3;
 
 	return 0;
 
+out3:
+	cdev_del(tap_cdev);
 out2:
 	unregister_chrdev_region(*tap_major, TAP_NUM_DEVS);
 out1:
@@ -1192,7 +1243,15 @@ int tap_create_cdev(struct cdev *tap_cdev,
 
 void tap_destroy_cdev(dev_t major, struct cdev *tap_cdev)
 {
+	struct major_info *tap_major;
+
+	tap_major = tap_get_major(MAJOR(major));
+	if (!tap_major)
+		return;
+
 	cdev_del(tap_cdev);
 	unregister_chrdev_region(major, TAP_NUM_DEVS);
-	idr_destroy(&macvtap_major.minor_idr);
+	idr_destroy(&tap_major->minor_idr);
+	list_del_rcu(&tap_major->next);
+	kfree_rcu(tap_major, rcu);
 }
diff --git a/include/linux/if_tap.h b/include/linux/if_tap.h
index 75031e5..362e71c 100644
--- a/include/linux/if_tap.h
+++ b/include/linux/if_tap.h
@@ -65,8 +65,8 @@ struct tap_queue {
 
 rx_handler_result_t tap_handle_frame(struct sk_buff **pskb);
 void tap_del_queues(struct tap_dev *tap);
-int tap_get_minor(struct tap_dev *tap);
-void tap_free_minor(struct tap_dev *tap);
+int tap_get_minor(dev_t major, struct tap_dev *tap);
+void tap_free_minor(dev_t major, struct tap_dev *tap);
 int tap_queue_resize(struct tap_dev *tap);
 int tap_create_cdev(struct cdev *tap_cdev,
 		    dev_t *tap_major, const char *device_name);
-- 
2.7.4
