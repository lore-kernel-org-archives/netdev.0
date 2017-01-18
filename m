From: Sainath Grandhi <sainath.grandhi@intel.com>
Subject: [PATCHv2 1/7] TAP: Refactoring macvtap.c
Date: Tue, 17 Jan 2017 16:03:00 -0800
Message-ID: <1484697786-50323-2-git-send-email-sainath.grandhi@intel.com>
References: <1484697786-50323-1-git-send-email-sainath.grandhi@intel.com>
Cc: davem@davemloft.net, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org, sainath.grandhi@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52373 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751696AbdARAEW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Jan 2017 19:04:22 -0500
In-Reply-To: <1484697786-50323-1-git-send-email-sainath.grandhi@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macvtap module has code for tap/queue management and link management. This patch splits
the code into macvtap_main.c for link management and tap.c for tap/queue management.
Functionality in tap.c can be re-used for implementing tap on other virtual interfaces.

Signed-off-by: Sainath Grandhi <sainath.grandhi@intel.com>
---
 drivers/net/Makefile             |   2 +
 drivers/net/macvtap_main.c       | 218 +++++++++++++++++++++++++++++++++++++++
 drivers/net/{macvtap.c => tap.c} | 204 ++----------------------------------
 include/linux/if_macvtap.h       |  10 ++
 4 files changed, 238 insertions(+), 196 deletions(-)
 create mode 100644 drivers/net/macvtap_main.c
 rename drivers/net/{macvtap.c => tap.c} (84%)
 create mode 100644 include/linux/if_macvtap.h

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 7336cbd..19b03a9 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -29,6 +29,8 @@ obj-$(CONFIG_GTP) += gtp.o
 obj-$(CONFIG_NLMON) += nlmon.o
 obj-$(CONFIG_NET_VRF) += vrf.o
 
+macvtap-objs := macvtap_main.o tap.o
+
 #
 # Networking Drivers
 #
diff --git a/drivers/net/macvtap_main.c b/drivers/net/macvtap_main.c
new file mode 100644
index 0000000..96ffa60
--- /dev/null
+++ b/drivers/net/macvtap_main.c
@@ -0,0 +1,218 @@
+#include <linux/etherdevice.h>
+#include <linux/if_macvlan.h>
+#include <linux/if_macvtap.h>
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
+/*
+ * Variables for dealing with macvtaps device numbers.
+ */
+static dev_t macvtap_major;
+#define MACVTAP_NUM_DEVS (1U << MINORBITS)
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
+static int macvtap_newlink(struct net *src_net,
+			   struct net_device *dev,
+			   struct nlattr *tb[],
+			   struct nlattr *data[])
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	int err;
+
+	INIT_LIST_HEAD(&vlan->queue_list);
+
+	/* Since macvlan supports all offloads by default, make
+	 * tap support all offloads also.
+	 */
+	vlan->tap_features = TUN_OFFLOADS;
+
+	err = netdev_rx_handler_register(dev, macvtap_handle_frame, vlan);
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
+	return 0;
+}
+
+static void macvtap_dellink(struct net_device *dev,
+			    struct list_head *head)
+{
+	netdev_rx_handler_unregister(dev);
+	macvtap_del_queues(dev);
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
+};
+
+static int macvtap_device_event(struct notifier_block *unused,
+				unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct macvlan_dev *vlan;
+	struct device *classdev;
+	dev_t devt;
+	int err;
+	char tap_name[IFNAMSIZ];
+
+	if (dev->rtnl_link_ops != &macvtap_link_ops)
+		return NOTIFY_DONE;
+
+	snprintf(tap_name, IFNAMSIZ, "tap%d", dev->ifindex);
+	vlan = netdev_priv(dev);
+
+	switch (event) {
+	case NETDEV_REGISTER:
+		/* Create the device node here after the network device has
+		 * been registered but before register_netdevice has
+		 * finished running.
+		 */
+		err = macvtap_get_minor(vlan);
+		if (err)
+			return notifier_from_errno(err);
+
+		devt = MKDEV(MAJOR(macvtap_major), vlan->minor);
+		classdev = device_create(&macvtap_class, &dev->dev, devt,
+					 dev, tap_name);
+		if (IS_ERR(classdev)) {
+			macvtap_free_minor(vlan);
+			return notifier_from_errno(PTR_ERR(classdev));
+		}
+		err = sysfs_create_link(&dev->dev.kobj, &classdev->kobj,
+					tap_name);
+		if (err)
+			return notifier_from_errno(err);
+		break;
+	case NETDEV_UNREGISTER:
+		/* vlan->minor == 0 if NETDEV_REGISTER above failed */
+		if (vlan->minor == 0)
+			break;
+		sysfs_remove_link(&dev->dev.kobj, tap_name);
+		devt = MKDEV(MAJOR(macvtap_major), vlan->minor);
+		device_destroy(&macvtap_class, devt);
+		macvtap_free_minor(vlan);
+		break;
+	case NETDEV_CHANGE_TX_QUEUE_LEN:
+		if (macvtap_queue_resize(vlan))
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
+extern struct file_operations macvtap_fops;
+static int macvtap_init(void)
+{
+	int err;
+
+	err = alloc_chrdev_region(&macvtap_major, 0,
+				MACVTAP_NUM_DEVS, "macvtap");
+	if (err)
+		goto out1;
+
+	cdev_init(&macvtap_cdev, &macvtap_fops);
+	err = cdev_add(&macvtap_cdev, macvtap_major, MACVTAP_NUM_DEVS);
+	if (err)
+		goto out2;
+
+	err = class_register(&macvtap_class);
+	if (err)
+		goto out3;
+
+	err = register_netdevice_notifier(&macvtap_notifier_block);
+	if (err)
+		goto out4;
+
+	err = macvlan_link_register(&macvtap_link_ops);
+	if (err)
+		goto out5;
+
+	return 0;
+
+out5:
+	unregister_netdevice_notifier(&macvtap_notifier_block);
+out4:
+	class_unregister(&macvtap_class);
+out3:
+	cdev_del(&macvtap_cdev);
+out2:
+	unregister_chrdev_region(macvtap_major, MACVTAP_NUM_DEVS);
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
+	cdev_del(&macvtap_cdev);
+	unregister_chrdev_region(macvtap_major, MACVTAP_NUM_DEVS);
+	idr_destroy(&minor_idr);
+}
+module_exit(macvtap_exit);
+
+MODULE_ALIAS_RTNL_LINK("macvtap");
+MODULE_AUTHOR("Arnd Bergmann <arnd@arndb.de>");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/macvtap.c b/drivers/net/tap.c
similarity index 84%
rename from drivers/net/macvtap.c
rename to drivers/net/tap.c
index 5c26653..8f12a39 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/tap.c
@@ -122,33 +122,14 @@ static struct proto macvtap_proto = {
 	.obj_size = sizeof (struct macvtap_queue),
 };
 
-/*
- * Variables for dealing with macvtaps device numbers.
- */
-static dev_t macvtap_major;
 #define MACVTAP_NUM_DEVS (1U << MINORBITS)
 static DEFINE_MUTEX(minor_lock);
-static DEFINE_IDR(minor_idr);
+DEFINE_IDR(minor_idr);
 
 #define GOODCOPY_LEN 128
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
 
 static const struct proto_ops macvtap_socket_ops;
 
-#define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
-		      NETIF_F_TSO6 | NETIF_F_UFO)
 #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
 #define TAP_FEATURES (NETIF_F_GSO | NETIF_F_SG | NETIF_F_FRAGLIST)
 
@@ -332,7 +313,7 @@ static struct macvtap_queue *macvtap_get_queue(struct net_device *dev,
  * that it holds on all queues and safely set the pointer
  * from the queues to NULL.
  */
-static void macvtap_del_queues(struct net_device *dev)
+void macvtap_del_queues(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct macvtap_queue *q, *tmp;
@@ -352,7 +333,7 @@ static void macvtap_del_queues(struct net_device *dev)
 	vlan->numvtaps = MAX_MACVTAP_QUEUES;
 }
 
-static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
+rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
 	struct net_device *dev = skb->dev;
@@ -407,7 +388,7 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 		/* If we receive a partial checksum and the tap side
 		 * doesn't support checksum offload, compute the checksum.
 		 * Note: it doesn't matter which checksum feature to
-		 *        check, we either support them all or none.
+		 *	  check, we either support them all or none.
 		 */
 		if (skb->ip_summed == CHECKSUM_PARTIAL &&
 		    !(features & NETIF_F_CSUM_MASK) &&
@@ -428,7 +409,7 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 	return RX_HANDLER_CONSUMED;
 }
 
-static int macvtap_get_minor(struct macvlan_dev *vlan)
+int macvtap_get_minor(struct macvlan_dev *vlan)
 {
 	int retval = -ENOMEM;
 
@@ -444,7 +425,7 @@ static int macvtap_get_minor(struct macvlan_dev *vlan)
 	return retval < 0 ? retval : 0;
 }
 
-static void macvtap_free_minor(struct macvlan_dev *vlan)
+void macvtap_free_minor(struct macvlan_dev *vlan)
 {
 	mutex_lock(&minor_lock);
 	if (vlan->minor) {
@@ -469,59 +450,6 @@ static struct net_device *dev_get_by_macvtap_minor(int minor)
 	return dev;
 }
 
-static int macvtap_newlink(struct net *src_net,
-			   struct net_device *dev,
-			   struct nlattr *tb[],
-			   struct nlattr *data[])
-{
-	struct macvlan_dev *vlan = netdev_priv(dev);
-	int err;
-
-	INIT_LIST_HEAD(&vlan->queue_list);
-
-	/* Since macvlan supports all offloads by default, make
-	 * tap support all offloads also.
-	 */
-	vlan->tap_features = TUN_OFFLOADS;
-
-	err = netdev_rx_handler_register(dev, macvtap_handle_frame, vlan);
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
-	return 0;
-}
-
-static void macvtap_dellink(struct net_device *dev,
-			    struct list_head *head)
-{
-	netdev_rx_handler_unregister(dev);
-	macvtap_del_queues(dev);
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
-};
-
-
 static void macvtap_sock_write_space(struct sock *sk)
 {
 	wait_queue_head_t *wqueue;
@@ -1169,7 +1097,7 @@ static long macvtap_compat_ioctl(struct file *file, unsigned int cmd,
 }
 #endif
 
-static const struct file_operations macvtap_fops = {
+const struct file_operations macvtap_fops = {
 	.owner		= THIS_MODULE,
 	.open		= macvtap_open,
 	.release	= macvtap_release,
@@ -1235,7 +1163,7 @@ struct socket *macvtap_get_socket(struct file *file)
 }
 EXPORT_SYMBOL_GPL(macvtap_get_socket);
 
-static int macvtap_queue_resize(struct macvlan_dev *vlan)
+int macvtap_queue_resize(struct macvlan_dev *vlan)
 {
 	struct net_device *dev = vlan->dev;
 	struct macvtap_queue *q;
@@ -1256,119 +1184,3 @@ static int macvtap_queue_resize(struct macvlan_dev *vlan)
 	kfree(arrays);
 	return ret;
 }
-
-static int macvtap_device_event(struct notifier_block *unused,
-				unsigned long event, void *ptr)
-{
-	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-	struct macvlan_dev *vlan;
-	struct device *classdev;
-	dev_t devt;
-	int err;
-	char tap_name[IFNAMSIZ];
-
-	if (dev->rtnl_link_ops != &macvtap_link_ops)
-		return NOTIFY_DONE;
-
-	snprintf(tap_name, IFNAMSIZ, "tap%d", dev->ifindex);
-	vlan = netdev_priv(dev);
-
-	switch (event) {
-	case NETDEV_REGISTER:
-		/* Create the device node here after the network device has
-		 * been registered but before register_netdevice has
-		 * finished running.
-		 */
-		err = macvtap_get_minor(vlan);
-		if (err)
-			return notifier_from_errno(err);
-
-		devt = MKDEV(MAJOR(macvtap_major), vlan->minor);
-		classdev = device_create(&macvtap_class, &dev->dev, devt,
-					 dev, tap_name);
-		if (IS_ERR(classdev)) {
-			macvtap_free_minor(vlan);
-			return notifier_from_errno(PTR_ERR(classdev));
-		}
-		err = sysfs_create_link(&dev->dev.kobj, &classdev->kobj,
-					tap_name);
-		if (err)
-			return notifier_from_errno(err);
-		break;
-	case NETDEV_UNREGISTER:
-		/* vlan->minor == 0 if NETDEV_REGISTER above failed */
-		if (vlan->minor == 0)
-			break;
-		sysfs_remove_link(&dev->dev.kobj, tap_name);
-		devt = MKDEV(MAJOR(macvtap_major), vlan->minor);
-		device_destroy(&macvtap_class, devt);
-		macvtap_free_minor(vlan);
-		break;
-	case NETDEV_CHANGE_TX_QUEUE_LEN:
-		if (macvtap_queue_resize(vlan))
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
-	err = alloc_chrdev_region(&macvtap_major, 0,
-				MACVTAP_NUM_DEVS, "macvtap");
-	if (err)
-		goto out1;
-
-	cdev_init(&macvtap_cdev, &macvtap_fops);
-	err = cdev_add(&macvtap_cdev, macvtap_major, MACVTAP_NUM_DEVS);
-	if (err)
-		goto out2;
-
-	err = class_register(&macvtap_class);
-	if (err)
-		goto out3;
-
-	err = register_netdevice_notifier(&macvtap_notifier_block);
-	if (err)
-		goto out4;
-
-	err = macvlan_link_register(&macvtap_link_ops);
-	if (err)
-		goto out5;
-
-	return 0;
-
-out5:
-	unregister_netdevice_notifier(&macvtap_notifier_block);
-out4:
-	class_unregister(&macvtap_class);
-out3:
-	cdev_del(&macvtap_cdev);
-out2:
-	unregister_chrdev_region(macvtap_major, MACVTAP_NUM_DEVS);
-out1:
-	return err;
-}
-module_init(macvtap_init);
-
-static void macvtap_exit(void)
-{
-	rtnl_link_unregister(&macvtap_link_ops);
-	unregister_netdevice_notifier(&macvtap_notifier_block);
-	class_unregister(&macvtap_class);
-	cdev_del(&macvtap_cdev);
-	unregister_chrdev_region(macvtap_major, MACVTAP_NUM_DEVS);
-	idr_destroy(&minor_idr);
-}
-module_exit(macvtap_exit);
-
-MODULE_ALIAS_RTNL_LINK("macvtap");
-MODULE_AUTHOR("Arnd Bergmann <arnd@arndb.de>");
-MODULE_LICENSE("GPL");
diff --git a/include/linux/if_macvtap.h b/include/linux/if_macvtap.h
new file mode 100644
index 0000000..c9bf84b
--- /dev/null
+++ b/include/linux/if_macvtap.h
@@ -0,0 +1,10 @@
+#ifndef _LINUX_IF_MACVTAP_H_
+#define _LINUX_IF_MACVTAP_H_
+
+rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb);
+void macvtap_del_queues(struct net_device *dev);
+int macvtap_get_minor(struct macvlan_dev *vlan);
+void macvtap_free_minor(struct macvlan_dev *vlan);
+int macvtap_queue_resize(struct macvlan_dev *vlan);
+
+#endif /*_LINUX_IF_MACVTAP_H_*/
-- 
2.7.4
