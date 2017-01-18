From: Sainath Grandhi <sainath.grandhi@intel.com>
Subject: [PATCHv2 3/7] TAP: Tap character device creation/destroy API
Date: Tue, 17 Jan 2017 16:03:02 -0800
Message-ID: <1484697786-50323-4-git-send-email-sainath.grandhi@intel.com>
References: <1484697786-50323-1-git-send-email-sainath.grandhi@intel.com>
Cc: davem@davemloft.net, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org, sainath.grandhi@intel.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484697786-50323-1-git-send-email-sainath.grandhi@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch provides tap device create/destroy APIs in tap.c.

Signed-off-by: Sainath Grandhi <sainath.grandhi@intel.com>
---
 drivers/net/macvtap_main.c | 29 +++++++--------------
 drivers/net/tap.c          | 63 ++++++++++++++++++++++++++++++++++++++--------
 include/linux/if_tap.h     |  5 +++-
 3 files changed, 65 insertions(+), 32 deletions(-)

diff --git a/drivers/net/macvtap_main.c b/drivers/net/macvtap_main.c
index 548f339..32ad560 100644
--- a/drivers/net/macvtap_main.c
+++ b/drivers/net/macvtap_main.c
@@ -28,7 +28,6 @@
  * Variables for dealing with macvtaps device numbers.
  */
 static dev_t macvtap_major;
-#define MACVTAP_NUM_DEVS (1U << MINORBITS)
 
 static const void *macvtap_net_namespace(struct device *d)
 {
@@ -159,43 +158,35 @@ static struct notifier_block macvtap_notifier_block __read_mostly = {
 	.notifier_call	= macvtap_device_event,
 };
 
-extern struct file_operations tap_fops;
 static int macvtap_init(void)
 {
 	int err;
 
-	err = alloc_chrdev_region(&macvtap_major, 0,
-				MACVTAP_NUM_DEVS, "macvtap");
-	if (err)
-		goto out1;
+	err = tap_create_cdev(&macvtap_cdev, &macvtap_major, "macvtap");
 
-	cdev_init(&macvtap_cdev, &tap_fops);
-	err = cdev_add(&macvtap_cdev, macvtap_major, MACVTAP_NUM_DEVS);
 	if (err)
-		goto out2;
+		goto out1;
 
 	err = class_register(&macvtap_class);
 	if (err)
-		goto out3;
+		goto out2;
 
 	err = register_netdevice_notifier(&macvtap_notifier_block);
 	if (err)
-		goto out4;
+		goto out3;
 
 	err = macvlan_link_register(&macvtap_link_ops);
 	if (err)
-		goto out5;
+		goto out4;
 
 	return 0;
 
-out5:
-	unregister_netdevice_notifier(&macvtap_notifier_block);
 out4:
-	class_unregister(&macvtap_class);
+	unregister_netdevice_notifier(&macvtap_notifier_block);
 out3:
-	cdev_del(&macvtap_cdev);
+	class_unregister(&macvtap_class);
 out2:
-	unregister_chrdev_region(macvtap_major, MACVTAP_NUM_DEVS);
+	cdev_del(&macvtap_cdev);
 out1:
 	return err;
 }
@@ -207,9 +198,7 @@ static void macvtap_exit(void)
 	rtnl_link_unregister(&macvtap_link_ops);
 	unregister_netdevice_notifier(&macvtap_notifier_block);
 	class_unregister(&macvtap_class);
-	cdev_del(&macvtap_cdev);
-	unregister_chrdev_region(macvtap_major, MACVTAP_NUM_DEVS);
-	idr_destroy(&minor_idr);
+	tap_destroy_cdev(macvtap_major, &macvtap_cdev);
 }
 module_exit(macvtap_exit);
 
diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index d0807c2..774ef33 100644
--- a/drivers/net/tap.c
+++ b/drivers/net/tap.c
@@ -123,8 +123,12 @@ static struct proto tap_proto = {
 };
 
 #define TAP_NUM_DEVS (1U << MINORBITS)
-static DEFINE_MUTEX(minor_lock);
-DEFINE_IDR(minor_idr);
+struct major_info {
+	dev_t major;
+	struct idr minor_idr;
+	struct mutex minor_lock;
+	const char *device_name;
+} macvtap_major;
 
 #define GOODCOPY_LEN 128
 
@@ -413,26 +417,26 @@ int tap_get_minor(struct macvlan_dev *vlan)
 {
 	int retval = -ENOMEM;
 
-	mutex_lock(&minor_lock);
-	retval = idr_alloc(&minor_idr, vlan, 1, TAP_NUM_DEVS, GFP_KERNEL);
+	mutex_lock(&macvtap_major.minor_lock);
+	retval = idr_alloc(&macvtap_major.minor_idr, vlan, 1, TAP_NUM_DEVS, GFP_KERNEL);
 	if (retval >= 0) {
 		vlan->minor = retval;
 	} else if (retval == -ENOSPC) {
 		netdev_err(vlan->dev, "Too many tap devices\n");
 		retval = -EINVAL;
 	}
-	mutex_unlock(&minor_lock);
+	mutex_unlock(&macvtap_major.minor_lock);
 	return retval < 0 ? retval : 0;
 }
 
 void tap_free_minor(struct macvlan_dev *vlan)
 {
-	mutex_lock(&minor_lock);
+	mutex_lock(&macvtap_major.minor_lock);
 	if (vlan->minor) {
-		idr_remove(&minor_idr, vlan->minor);
+		idr_remove(&macvtap_major.minor_idr, vlan->minor);
 		vlan->minor = 0;
 	}
-	mutex_unlock(&minor_lock);
+	mutex_unlock(&macvtap_major.minor_lock);
 }
 
 static struct net_device *dev_get_by_tap_minor(int minor)
@@ -440,13 +444,13 @@ static struct net_device *dev_get_by_tap_minor(int minor)
 	struct net_device *dev = NULL;
 	struct macvlan_dev *vlan;
 
-	mutex_lock(&minor_lock);
-	vlan = idr_find(&minor_idr, minor);
+	mutex_lock(&macvtap_major.minor_lock);
+	vlan = idr_find(&macvtap_major.minor_idr, minor);
 	if (vlan) {
 		dev = vlan->dev;
 		dev_hold(dev);
 	}
-	mutex_unlock(&minor_lock);
+	mutex_unlock(&macvtap_major.minor_lock);
 	return dev;
 }
 
@@ -1184,3 +1188,40 @@ int tap_queue_resize(struct macvlan_dev *vlan)
 	kfree(arrays);
 	return ret;
 }
+
+int tap_create_cdev(struct cdev *tap_cdev,
+		    dev_t *tap_major, const char *device_name)
+{
+	int err;
+
+	err = alloc_chrdev_region(tap_major, 0, TAP_NUM_DEVS, device_name);
+
+	if (err)
+		goto out1;
+
+	cdev_init(tap_cdev, &tap_fops);
+	err = cdev_add(tap_cdev, *tap_major, TAP_NUM_DEVS);
+	if (err)
+		goto out2;
+
+	macvtap_major.major = MAJOR(*tap_major);
+
+	idr_init(&macvtap_major.minor_idr);
+	mutex_init(&macvtap_major.minor_lock);
+
+	macvtap_major.device_name = device_name;
+
+	return err;
+
+out2:
+	unregister_chrdev_region(*tap_major, TAP_NUM_DEVS);
+out1:
+	return err;
+}
+
+void tap_destroy_cdev(dev_t major, struct cdev *tap_cdev)
+{
+	cdev_del(tap_cdev);
+	unregister_chrdev_region(major, TAP_NUM_DEVS);
+	idr_destroy(&macvtap_major.minor_idr);
+}
diff --git a/include/linux/if_tap.h b/include/linux/if_tap.h
index d887aaa..a2dfd90 100644
--- a/include/linux/if_tap.h
+++ b/include/linux/if_tap.h
@@ -10,7 +10,7 @@ struct file;
 struct socket;
 static inline struct socket *tap_get_socket(struct file *f)
 {
-        return ERR_PTR(-EINVAL);
+	return ERR_PTR(-EINVAL);
 }
 #endif /* CONFIG_MACVTAP */
 
@@ -19,5 +19,8 @@ void tap_del_queues(struct net_device *dev);
 int tap_get_minor(struct macvlan_dev *vlan);
 void tap_free_minor(struct macvlan_dev *vlan);
 int tap_queue_resize(struct macvlan_dev *vlan);
+int tap_create_cdev(struct cdev *tap_cdev,
+		    dev_t *tap_major, const char *device_name);
+void tap_destroy_cdev(dev_t major, struct cdev *tap_cdev);
 
 #endif /*_LINUX_IF_TAP_H_*/
-- 
2.7.4
