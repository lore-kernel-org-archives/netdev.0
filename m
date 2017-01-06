From: Sainath Grandhi <sainath.grandhi@intel.com>
Subject: [PATCHv1 6/7] TAP: tap as an independent module
Date: Fri,  6 Jan 2017 14:33:28 -0800
Message-ID: <1483742009-19184-7-git-send-email-sainath.grandhi@intel.com>
References: <1483742009-19184-1-git-send-email-sainath.grandhi@intel.com>
Cc: davem@davemloft.net, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org,
        Sainath Grandhi <sainath.grandhi@intel.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483742009-19184-1-git-send-email-sainath.grandhi@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes tap a separate module for other types of virtual interfaces, for example,
ipvlan to use.

Signed-off-by: Sainath Grandhi <sainath.grandhi@intel.com>
Tested-by: Sainath Grandhi <sainath.grandhi@intel.com>
---
 drivers/net/Kconfig        |  14 +++
 drivers/net/Makefile       |   3 +-
 drivers/net/macvtap.c      | 247 +++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/macvtap_main.c | 247 ---------------------------------------------
 drivers/net/tap.c          |  10 ++
 5 files changed, 272 insertions(+), 249 deletions(-)
 create mode 100644 drivers/net/macvtap.c
 delete mode 100644 drivers/net/macvtap_main.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 95c32f2..280380d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -284,6 +284,20 @@ config TUN
 
 	  If you don't know what to use this for, you don't need it.
 
+config TAP
+        tristate "TAP module support for virtual interfaces"
+        ---help---
+          TAP module serves two purposes. This can be used as library of functions
+          for virtual interfaces to implement tap functionality.
+
+          This module also includes character device file and socket operations
+          that can be used by virtual interface implementing tap.
+
+          To compile this driver as a module, choose M here: the module
+          will be called tap.
+
+          If you don't know what to use this for, you don't need it.
+
 config TUN_VNET_CROSS_LE
 	bool "Support for cross-endian vnet headers on little-endian kernels"
 	default n
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 19b03a9..7dd86ca 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -21,6 +21,7 @@ obj-$(CONFIG_PHYLIB) += phy/
 obj-$(CONFIG_RIONET) += rionet.o
 obj-$(CONFIG_NET_TEAM) += team/
 obj-$(CONFIG_TUN) += tun.o
+obj-$(CONFIG_TAP) += tap.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_VXLAN) += vxlan.o
@@ -29,8 +30,6 @@ obj-$(CONFIG_GTP) += gtp.o
 obj-$(CONFIG_NLMON) += nlmon.o
 obj-$(CONFIG_NET_VRF) += vrf.o
 
-macvtap-objs := macvtap_main.o tap.o
-
 #
 # Networking Drivers
 #
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
new file mode 100644
index 0000000..3f047b4
--- /dev/null
+++ b/drivers/net/macvtap.c
@@ -0,0 +1,247 @@
+#include <linux/etherdevice.h>
+#include <linux/if_macvlan.h>
+#include <linux/if_tap.h>
+#include <linux/if_vlan.h>
+#include <linux/interrupt.h>
+#include <linux/nsproxy.h>
+#include <linux/compat.h>
+#include <linux/if_tun.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/cache.h>
+#include <linux/sched.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/wait.h>
+#include <linux/cdev.h>
+#include <linux/idr.h>
+#include <linux/fs.h>
+#include <linux/uio.h>
+
+#include <net/net_namespace.h>
+#include <net/rtnetlink.h>
+#include <net/sock.h>
+#include <linux/virtio_net.h>
+#include <linux/skb_array.h>
+
+struct macvtap_dev {
+	struct macvlan_dev vlan;
+	struct tap_dev    tap;
+};
+
+/*
+ * Variables for dealing with macvtaps device numbers.
+ */
+static dev_t macvtap_major;
+
+static const void *macvtap_net_namespace(struct device *d)
+{
+	struct net_device *dev = to_net_dev(d->parent);
+	return dev_net(dev);
+}
+
+static struct class macvtap_class = {
+	.name = "macvtap",
+	.owner = THIS_MODULE,
+	.ns_type = &net_ns_type_operations,
+	.namespace = macvtap_net_namespace,
+};
+static struct cdev macvtap_cdev;
+
+#define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
+		      NETIF_F_TSO6 | NETIF_F_UFO)
+
+static void macvtap_count_tx_dropped(struct tap_dev *tap)
+{
+	struct macvlan_dev *vlan = (struct macvlan_dev *)container_of(tap, struct macvtap_dev, tap);
+
+	this_cpu_inc(vlan->pcpu_stats->tx_dropped);
+}
+
+static void macvtap_count_rx_dropped(struct tap_dev *tap)
+{
+	struct macvlan_dev *vlan = (struct macvlan_dev *)container_of(tap, struct macvtap_dev, tap);
+
+	macvlan_count_rx(vlan, 0, 0, 0);
+}
+
+static void macvtap_update_features(struct tap_dev *tap,
+				    netdev_features_t features)
+{
+	struct macvlan_dev *vlan = (struct macvlan_dev *)container_of(tap, struct macvtap_dev, tap);
+
+	vlan->set_features = features;
+	netdev_update_features(vlan->dev);
+}
+
+static int macvtap_newlink(struct net *src_net,
+			   struct net_device *dev,
+			   struct nlattr *tb[],
+			   struct nlattr *data[])
+{
+	struct macvtap_dev *vlantap = netdev_priv(dev);
+	int err;
+
+	INIT_LIST_HEAD(&vlantap->tap.queue_list);
+
+	/* Since macvlan supports all offloads by default, make
+	 * tap support all offloads also.
+	 */
+	vlantap->tap.tap_features = TUN_OFFLOADS;
+
+	/* Register callbacks for rx/tx drops accounting and updating
+	 * net_device features
+	 */
+	vlantap->tap.count_tx_dropped = macvtap_count_tx_dropped;
+	vlantap->tap.count_rx_dropped = macvtap_count_rx_dropped;
+	vlantap->tap.update_features  = macvtap_update_features;
+
+	err = netdev_rx_handler_register(dev, tap_handle_frame, &vlantap->tap);
+	if (err)
+		return err;
+
+	/* Don't put anything that may fail after macvlan_common_newlink
+	 * because we can't undo what it does.
+	 */
+	err = macvlan_common_newlink(src_net, dev, tb, data);
+	if (err) {
+		netdev_rx_handler_unregister(dev);
+		return err;
+	}
+
+	vlantap->tap.dev = vlantap->vlan.dev;
+
+	return 0;
+}
+
+static void macvtap_dellink(struct net_device *dev,
+			    struct list_head *head)
+{
+	struct macvtap_dev *vlantap = netdev_priv(dev);
+
+	netdev_rx_handler_unregister(dev);
+	tap_del_queues(&vlantap->tap);
+	macvlan_dellink(dev, head);
+}
+
+static void macvtap_setup(struct net_device *dev)
+{
+	macvlan_common_setup(dev);
+	dev->tx_queue_len = TUN_READQ_SIZE;
+}
+
+static struct rtnl_link_ops macvtap_link_ops __read_mostly = {
+	.kind		= "macvtap",
+	.setup		= macvtap_setup,
+	.newlink	= macvtap_newlink,
+	.dellink	= macvtap_dellink,
+	.priv_size      = sizeof(struct macvtap_dev),
+};
+
+static int macvtap_device_event(struct notifier_block *unused,
+				unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct macvtap_dev *vlantap;
+	struct device *classdev;
+	dev_t devt;
+	int err;
+	char tap_name[IFNAMSIZ];
+
+	if (dev->rtnl_link_ops != &macvtap_link_ops)
+		return NOTIFY_DONE;
+
+	snprintf(tap_name, IFNAMSIZ, "tap%d", dev->ifindex);
+	vlantap = netdev_priv(dev);
+
+	switch (event) {
+	case NETDEV_REGISTER:
+		/* Create the device node here after the network device has
+		 * been registered but before register_netdevice has
+		 * finished running.
+		 */
+		err = tap_get_minor(macvtap_major, &vlantap->tap);
+		if (err)
+			return notifier_from_errno(err);
+
+		devt = MKDEV(MAJOR(macvtap_major), vlantap->tap.minor);
+		classdev = device_create(&macvtap_class, &dev->dev, devt,
+					 dev, tap_name);
+		if (IS_ERR(classdev)) {
+			tap_free_minor(macvtap_major, &vlantap->tap);
+			return notifier_from_errno(PTR_ERR(classdev));
+		}
+		err = sysfs_create_link(&dev->dev.kobj, &classdev->kobj,
+					tap_name);
+		if (err)
+			return notifier_from_errno(err);
+		break;
+	case NETDEV_UNREGISTER:
+		/* vlan->minor == 0 if NETDEV_REGISTER above failed */
+		if (vlantap->tap.minor == 0)
+			break;
+		sysfs_remove_link(&dev->dev.kobj, tap_name);
+		devt = MKDEV(MAJOR(macvtap_major), vlantap->tap.minor);
+		device_destroy(&macvtap_class, devt);
+		tap_free_minor(macvtap_major, &vlantap->tap);
+		break;
+	case NETDEV_CHANGE_TX_QUEUE_LEN:
+		if (tap_queue_resize(&vlantap->tap))
+			return NOTIFY_BAD;
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block macvtap_notifier_block __read_mostly = {
+	.notifier_call	= macvtap_device_event,
+};
+
+static int macvtap_init(void)
+{
+	int err;
+
+	err = tap_create_cdev(&macvtap_cdev, &macvtap_major, "macvtap");
+
+	if (err)
+		goto out1;
+
+	err = class_register(&macvtap_class);
+	if (err)
+		goto out2;
+
+	err = register_netdevice_notifier(&macvtap_notifier_block);
+	if (err)
+		goto out3;
+
+	err = macvlan_link_register(&macvtap_link_ops);
+	if (err)
+		goto out4;
+
+	return 0;
+
+out4:
+	unregister_netdevice_notifier(&macvtap_notifier_block);
+out3:
+	class_unregister(&macvtap_class);
+out2:
+	cdev_del(&macvtap_cdev);
+out1:
+	return err;
+}
+module_init(macvtap_init);
+
+extern struct idr minor_idr;
+static void macvtap_exit(void)
+{
+	rtnl_link_unregister(&macvtap_link_ops);
+	unregister_netdevice_notifier(&macvtap_notifier_block);
+	class_unregister(&macvtap_class);
+	tap_destroy_cdev(macvtap_major, &macvtap_cdev);
+}
+module_exit(macvtap_exit);
+
+MODULE_ALIAS_RTNL_LINK("macvtap");
+MODULE_AUTHOR("Arnd Bergmann <arnd@arndb.de>");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/macvtap_main.c b/drivers/net/macvtap_main.c
deleted file mode 100644
index 3f047b4..0000000
--- a/drivers/net/macvtap_main.c
+++ /dev/null
@@ -1,247 +0,0 @@
-#include <linux/etherdevice.h>
-#include <linux/if_macvlan.h>
-#include <linux/if_tap.h>
-#include <linux/if_vlan.h>
-#include <linux/interrupt.h>
-#include <linux/nsproxy.h>
-#include <linux/compat.h>
-#include <linux/if_tun.h>
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/cache.h>
-#include <linux/sched.h>
-#include <linux/types.h>
-#include <linux/slab.h>
-#include <linux/wait.h>
-#include <linux/cdev.h>
-#include <linux/idr.h>
-#include <linux/fs.h>
-#include <linux/uio.h>
-
-#include <net/net_namespace.h>
-#include <net/rtnetlink.h>
-#include <net/sock.h>
-#include <linux/virtio_net.h>
-#include <linux/skb_array.h>
-
-struct macvtap_dev {
-	struct macvlan_dev vlan;
-	struct tap_dev    tap;
-};
-
-/*
- * Variables for dealing with macvtaps device numbers.
- */
-static dev_t macvtap_major;
-
-static const void *macvtap_net_namespace(struct device *d)
-{
-	struct net_device *dev = to_net_dev(d->parent);
-	return dev_net(dev);
-}
-
-static struct class macvtap_class = {
-	.name = "macvtap",
-	.owner = THIS_MODULE,
-	.ns_type = &net_ns_type_operations,
-	.namespace = macvtap_net_namespace,
-};
-static struct cdev macvtap_cdev;
-
-#define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
-		      NETIF_F_TSO6 | NETIF_F_UFO)
-
-static void macvtap_count_tx_dropped(struct tap_dev *tap)
-{
-	struct macvlan_dev *vlan = (struct macvlan_dev *)container_of(tap, struct macvtap_dev, tap);
-
-	this_cpu_inc(vlan->pcpu_stats->tx_dropped);
-}
-
-static void macvtap_count_rx_dropped(struct tap_dev *tap)
-{
-	struct macvlan_dev *vlan = (struct macvlan_dev *)container_of(tap, struct macvtap_dev, tap);
-
-	macvlan_count_rx(vlan, 0, 0, 0);
-}
-
-static void macvtap_update_features(struct tap_dev *tap,
-				    netdev_features_t features)
-{
-	struct macvlan_dev *vlan = (struct macvlan_dev *)container_of(tap, struct macvtap_dev, tap);
-
-	vlan->set_features = features;
-	netdev_update_features(vlan->dev);
-}
-
-static int macvtap_newlink(struct net *src_net,
-			   struct net_device *dev,
-			   struct nlattr *tb[],
-			   struct nlattr *data[])
-{
-	struct macvtap_dev *vlantap = netdev_priv(dev);
-	int err;
-
-	INIT_LIST_HEAD(&vlantap->tap.queue_list);
-
-	/* Since macvlan supports all offloads by default, make
-	 * tap support all offloads also.
-	 */
-	vlantap->tap.tap_features = TUN_OFFLOADS;
-
-	/* Register callbacks for rx/tx drops accounting and updating
-	 * net_device features
-	 */
-	vlantap->tap.count_tx_dropped = macvtap_count_tx_dropped;
-	vlantap->tap.count_rx_dropped = macvtap_count_rx_dropped;
-	vlantap->tap.update_features  = macvtap_update_features;
-
-	err = netdev_rx_handler_register(dev, tap_handle_frame, &vlantap->tap);
-	if (err)
-		return err;
-
-	/* Don't put anything that may fail after macvlan_common_newlink
-	 * because we can't undo what it does.
-	 */
-	err = macvlan_common_newlink(src_net, dev, tb, data);
-	if (err) {
-		netdev_rx_handler_unregister(dev);
-		return err;
-	}
-
-	vlantap->tap.dev = vlantap->vlan.dev;
-
-	return 0;
-}
-
-static void macvtap_dellink(struct net_device *dev,
-			    struct list_head *head)
-{
-	struct macvtap_dev *vlantap = netdev_priv(dev);
-
-	netdev_rx_handler_unregister(dev);
-	tap_del_queues(&vlantap->tap);
-	macvlan_dellink(dev, head);
-}
-
-static void macvtap_setup(struct net_device *dev)
-{
-	macvlan_common_setup(dev);
-	dev->tx_queue_len = TUN_READQ_SIZE;
-}
-
-static struct rtnl_link_ops macvtap_link_ops __read_mostly = {
-	.kind		= "macvtap",
-	.setup		= macvtap_setup,
-	.newlink	= macvtap_newlink,
-	.dellink	= macvtap_dellink,
-	.priv_size      = sizeof(struct macvtap_dev),
-};
-
-static int macvtap_device_event(struct notifier_block *unused,
-				unsigned long event, void *ptr)
-{
-	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-	struct macvtap_dev *vlantap;
-	struct device *classdev;
-	dev_t devt;
-	int err;
-	char tap_name[IFNAMSIZ];
-
-	if (dev->rtnl_link_ops != &macvtap_link_ops)
-		return NOTIFY_DONE;
-
-	snprintf(tap_name, IFNAMSIZ, "tap%d", dev->ifindex);
-	vlantap = netdev_priv(dev);
-
-	switch (event) {
-	case NETDEV_REGISTER:
-		/* Create the device node here after the network device has
-		 * been registered but before register_netdevice has
-		 * finished running.
-		 */
-		err = tap_get_minor(macvtap_major, &vlantap->tap);
-		if (err)
-			return notifier_from_errno(err);
-
-		devt = MKDEV(MAJOR(macvtap_major), vlantap->tap.minor);
-		classdev = device_create(&macvtap_class, &dev->dev, devt,
-					 dev, tap_name);
-		if (IS_ERR(classdev)) {
-			tap_free_minor(macvtap_major, &vlantap->tap);
-			return notifier_from_errno(PTR_ERR(classdev));
-		}
-		err = sysfs_create_link(&dev->dev.kobj, &classdev->kobj,
-					tap_name);
-		if (err)
-			return notifier_from_errno(err);
-		break;
-	case NETDEV_UNREGISTER:
-		/* vlan->minor == 0 if NETDEV_REGISTER above failed */
-		if (vlantap->tap.minor == 0)
-			break;
-		sysfs_remove_link(&dev->dev.kobj, tap_name);
-		devt = MKDEV(MAJOR(macvtap_major), vlantap->tap.minor);
-		device_destroy(&macvtap_class, devt);
-		tap_free_minor(macvtap_major, &vlantap->tap);
-		break;
-	case NETDEV_CHANGE_TX_QUEUE_LEN:
-		if (tap_queue_resize(&vlantap->tap))
-			return NOTIFY_BAD;
-		break;
-	}
-
-	return NOTIFY_DONE;
-}
-
-static struct notifier_block macvtap_notifier_block __read_mostly = {
-	.notifier_call	= macvtap_device_event,
-};
-
-static int macvtap_init(void)
-{
-	int err;
-
-	err = tap_create_cdev(&macvtap_cdev, &macvtap_major, "macvtap");
-
-	if (err)
-		goto out1;
-
-	err = class_register(&macvtap_class);
-	if (err)
-		goto out2;
-
-	err = register_netdevice_notifier(&macvtap_notifier_block);
-	if (err)
-		goto out3;
-
-	err = macvlan_link_register(&macvtap_link_ops);
-	if (err)
-		goto out4;
-
-	return 0;
-
-out4:
-	unregister_netdevice_notifier(&macvtap_notifier_block);
-out3:
-	class_unregister(&macvtap_class);
-out2:
-	cdev_del(&macvtap_cdev);
-out1:
-	return err;
-}
-module_init(macvtap_init);
-
-extern struct idr minor_idr;
-static void macvtap_exit(void)
-{
-	rtnl_link_unregister(&macvtap_link_ops);
-	unregister_netdevice_notifier(&macvtap_notifier_block);
-	class_unregister(&macvtap_class);
-	tap_destroy_cdev(macvtap_major, &macvtap_cdev);
-}
-module_exit(macvtap_exit);
-
-MODULE_ALIAS_RTNL_LINK("macvtap");
-MODULE_AUTHOR("Arnd Bergmann <arnd@arndb.de>");
-MODULE_LICENSE("GPL");
diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index 1d5bcf3..ee0d49a 100644
--- a/drivers/net/tap.c
+++ b/drivers/net/tap.c
@@ -311,6 +311,7 @@ void tap_del_queues(struct tap_dev *tap)
 	/* guarantee that any future tap_set_queue will fail */
 	tap->numvtaps = MAX_TAP_QUEUES;
 }
+EXPORT_SYMBOL_GPL(tap_del_queues);
 
 rx_handler_result_t tap_handle_frame(struct sk_buff **pskb)
 {
@@ -388,6 +389,7 @@ rx_handler_result_t tap_handle_frame(struct sk_buff **pskb)
 	kfree_skb(skb);
 	return RX_HANDLER_CONSUMED;
 }
+EXPORT_SYMBOL_GPL(tap_handle_frame);
 
 int tap_get_minor(dev_t major, struct tap_dev *tap)
 {
@@ -416,6 +418,7 @@ int tap_get_minor(dev_t major, struct tap_dev *tap)
 	mutex_unlock(&tap_major->minor_lock);
 	return retval < 0 ? retval : 0;
 }
+EXPORT_SYMBOL_GPL(tap_get_minor);
 
 void tap_free_minor(dev_t major, struct tap_dev *tap)
 {
@@ -439,6 +442,7 @@ void tap_free_minor(dev_t major, struct tap_dev *tap)
 	}
 	mutex_unlock(&tap_major->minor_lock);
 }
+EXPORT_SYMBOL_GPL(tap_free_minor);
 
 static struct tap_dev *dev_get_by_tap_file(int major, int minor)
 {
@@ -1201,6 +1205,7 @@ int tap_queue_resize(struct tap_dev *tap)
 	kfree(arrays);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(tap_queue_resize);
 
 static int tap_list_add(dev_t major, const char *device_name)
 {
@@ -1244,6 +1249,7 @@ int tap_create_cdev(struct cdev *tap_cdev,
 out1:
 	return err;
 }
+EXPORT_SYMBOL_GPL(tap_create_cdev);
 
 void tap_destroy_cdev(dev_t major, struct cdev *tap_cdev)
 {
@@ -1264,3 +1270,7 @@ void tap_destroy_cdev(dev_t major, struct cdev *tap_cdev)
 	unregister_chrdev_region(major, TAP_NUM_DEVS);
 	idr_destroy(&tap_major->minor_idr);
 }
+EXPORT_SYMBOL_GPL(tap_destroy_cdev);
+
+MODULE_AUTHOR("Arnd Bergmann <arnd@arndb.de>");
+MODULE_LICENSE("GPL");
-- 
2.7.4
